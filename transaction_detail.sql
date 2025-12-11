-- Table: wavzedemo.transaction_detail

-- DROP TABLE IF EXISTS wavzedemo.transaction_detail;

CREATE TABLE wavzedemo.transaction_detail (
    transaction_id uuid NOT NULL,
    created_ts timestamp with time zone,
    created_by uuid,
    customer_id uuid,
    co_appl1 uuid,
    co_appl1_type character varying(20),
    co_appl2 uuid,
    co_appl2_type character varying(20),
    purchase_price numeric,
    down_payment numeric,
    loan_amount numeric,
    loan_term_type character varying(10),
    loan_term numeric,
    cash_out numeric,
    draw_amount numeric,
    pmi boolean,
    lien_position numeric(1,0),
    rate_type character varying(20),
    interest_rate numeric(7,4),
    apr numeric(7,4),
    cash_advance numeric,
    credit_limit numeric,
    deposit_amount numeric,
    funding_method character varying(30),
    ownership_type character varying(30),
    modified_ts timestamp with time zone,
    modified_by uuid
);


ALTER TABLE wavzedemo.transaction_detail OWNER TO "nikki.stoddard@taranginc.com";

--
-- TOC entry 4411 (class 0 OID 0)
-- Dependencies: 245
-- Name: TABLE transaction_detail; Type: COMMENT; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

COMMENT ON TABLE wavzedemo.transaction_detail IS 'banking industry product details';


--
-- TOC entry 4252 (class 2606 OID 25163)
-- Name: transaction_detail transaction_detail_pkey; Type: CONSTRAINT; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavzedemo.transaction_detail
    ADD CONSTRAINT transaction_detail_pkey PRIMARY KEY (transaction_id);


--
-- TOC entry 4255 (class 2620 OID 26001)
-- Name: transaction_detail transaction_dtl_created_ts; Type: TRIGGER; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

CREATE TRIGGER transaction_dtl_created_ts BEFORE INSERT ON wavzedemo.transaction_detail FOR EACH ROW EXECUTE FUNCTION wavzedemo.set_created_ts();

/*********************************************************************************************************************************************************************
-- FUNCTION: wavzedemo.set_created_ts()

-- DROP FUNCTION IF EXISTS wavzedemo.set_created_ts();

CREATE OR REPLACE FUNCTION wavzedemo.set_created_ts()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    STABLE NOT LEAKPROOF
AS $BODY$
BEGIN
	IF NEW.created_ts IS NULL THEN
		NEW.created_ts := CURRENT_TIMESTAMP;
	END IF;
	RETURN NEW;
END;
$BODY$;
*********************************************************************************************************************************************************************/


-- TOC entry 4256 (class 2620 OID 28249)
-- Name: transaction_detail transaction_track_history; Type: TRIGGER; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

CREATE TRIGGER transaction_track_history AFTER INSERT OR DELETE OR UPDATE ON wavzedemo.transaction_detail FOR EACH ROW EXECUTE FUNCTION wavzedemo.track_transaction2_field_changes();

/*********************************************************************************************************************************************************************
-- FUNCTION: wavzedemo.track_transaction2_field_changes()

-- DROP FUNCTION IF EXISTS wavzedemo.track_transaction2_field_changes();

CREATE OR REPLACE FUNCTION wavzedemo.track_transaction2_field_changes()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
	field_name TEXT;
	field_type TEXT;
	old_val JSONB;
	new_val JSONB;
	old_json JSONB;
	new_json JSONB;
	col_info RECORD;
BEGIN
	-- convert rows to JSONB for easier field access and type preservation
	IF TG_OP = 'UPDATE' THEN
		old_json := row_to_json(OLD)::JSONB;
		new_json := row_to_json(NEW)::JSONB;
	ELSIF TG_OP = 'INSERT' THEN
		new_json := row_to_json(NEW)::JSONB;
	ELSIF TG_OP = 'DELETE' THEN
		old_json := row_to_json(OLD)::JSONB;
	END IF;

	-- get column info for transaction detail table
	FOR col_info IN
		SELECT
			column_name,
			data_type,
			udt_name
		FROM information_schema.columns
		WHERE table_schema = 'wavzedemo'
		AND table_name = 'transaction_detail'
		AND column_name NOT IN ('transaction_id','created_ts','created_by','modified_ts','modified_by')
	LOOP
		field_name := col_info.column_name;
		field_type := col_info.data_type;

		-- INSERT operation
		IF TG_OP = 'INSERT' THEN
			new_val := new_json->field_name; 

			-- only record non-NULL values
			IF new_val IS NOT NULL AND new_val != 'null'::JSONB THEN
				INSERT INTO wavzedemo.transaction_hist (
					transaction_id,
					operation,
					field_name,
					field_type,
					new_value,
					modified_ts
				) VALUES (
					NEW.transaction_id,
					'INSERT',
					field_name,
					field_type,
					new_val,
					CURRENT_TIMESTAMP
				);
			END IF;

		-- UPDATE operation
		ELSIF TG_OP = 'UPDATE' THEN
			old_val := old_json->field_name;
			new_val := new_json->field_name;

			-- check if value changed
			IF old_val IS DISTINCT FROM new_val THEN
				INSERT INTO wavzedemo.transaction_hist (
					transaction_id,
					operation,
					field_name,
					field_type,
					old_value,
					new_value,
					modified_ts
				) VALUES (
					NEW.transaction_id,
					'UPDATE',
					field_name,
					field_type,
					old_val,
					new_val,
					CURRENT_TIMESTAMP
				);
			END IF;
		
		-- DELETE operation
		ELSIF TG_OP = 'DELETE' THEN
			old_val := old_json->field_name;

			INSERT INTO wavzedemo.transaction_hist (
				transaction_id,
				operation,
				field_name,
				field_type,
				old_value,
				modified_ts
			) VALUES (
				OLD.transaction_id,
				'DELETE',
				field_name,
				field_type,
				old_val,
				CURRENT_TIMESTAMP
			);
		END IF;
	END LOOP;

	-- return appropriate record
	IF TG_OP = 'DELETE' THEN
		RETURN OLD;
	ELSE
		RETURN NEW;
	END IF;
END;
	
$BODY$;
*********************************************************************************************************************************************************************/


-- TOC entry 4253 (class 2606 OID 25976)
-- Name: transaction_detail created_by; Type: FK CONSTRAINT; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavzedemo.transaction_detail
    ADD CONSTRAINT created_by FOREIGN KEY (created_by) REFERENCES wavzedemo.wavze_user(user_id) NOT VALID;


--
-- TOC entry 4254 (class 2606 OID 25981)
-- Name: transaction_detail customer_id; Type: FK CONSTRAINT; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavzedemo.transaction_detail
    ADD CONSTRAINT customer_id FOREIGN KEY (customer_id) REFERENCES wavzedemo.customer(customer_id) NOT VALID;


--
-- TOC entry 4412 (class 0 OID 0)
-- Dependencies: 245
-- Name: TABLE transaction_detail; Type: ACL; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE wavzedemo.transaction_detail TO "erik.michaelson@taranginc.com";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE wavzedemo.transaction_detail TO "jagadeesh.pasupulati@taranginc.com";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE wavzedemo.transaction_detail TO "kevin.soderholm@taranginc.com";
GRANT SELECT,INSERT,REFERENCES,TRIGGER,TRUNCATE,UPDATE ON TABLE wavzedemo.transaction_detail TO "wavzedemo@wavzedemodb2";

