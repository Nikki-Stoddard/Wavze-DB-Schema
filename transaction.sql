-- Table: wavze1.transaction

-- DROP TABLE IF EXISTS wavze1.transaction;

CREATE TABLE wavze1.transaction (
    transaction_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    customer_id uuid NOT NULL,
    property_id uuid,
    user_id uuid,
    bob_id uuid,
    coi_id uuid,
    created_ts timestamp with time zone,
    created_by uuid,
    product_id uuid NOT NULL,
    product_category character varying(30) NOT NULL,
    product_name character varying(50),
    source character varying(30),
    milestone character varying(30),
    time_sensitive boolean DEFAULT false,
    sensitive_reason character varying(30),
    active boolean DEFAULT true,
    duplicate boolean DEFAULT false,
	next_contact_dt date,
    days_to_contact numeric(3,0),
    attempt_assigned numeric(2,0),
    attempt_complete numeric(2,0),
    modified_ts timestamp without time zone,
    modified_by uuid
);


ALTER TABLE wavze1.transaction OWNER TO "nikki.stoddard@taranginc.com";

--
-- Name: transaction transaction_pkey; Type: CONSTRAINT; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavze1.transaction
    ADD CONSTRAINT transaction_pkey PRIMARY KEY (transaction_id);


--
-- Name: transaction inactive_status; Type: TRIGGER; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

CREATE TRIGGER inactive_status BEFORE INSERT OR UPDATE ON wavze1.transaction FOR EACH ROW EXECUTE FUNCTION wavze1.transaction_active_check();

/*********************************************************************************************************************************************************************
-- FUNCTION: wavze1.transaction_active_check()

-- DROP FUNCTION IF EXISTS wavze1.transaction_active_check();

CREATE OR REPLACE FUNCTION wavze1.transaction_active_check()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
	IF UPPER(TRIM(NEW.milestone)) LIKE ('CLOSED%') OR UPPER(TRIM(NEW.milestone)) LIKE ('FUNDED%')
		THEN NEW.active := FALSE;
	END IF;

	RETURN NEW;
END;
$BODY$;
*********************************************************************************************************************************************************************/

--
-- Name: transaction set_product_id; Type: TRIGGER; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

CREATE TRIGGER set_product_id BEFORE INSERT OR UPDATE ON wavze1.transaction FOR EACH ROW EXECUTE FUNCTION wavze1.product_id_lookup();

/*********************************************************************************************************************************************************************
-- FUNCTION: wavze1.product_id_lookup()

-- DROP FUNCTION IF EXISTS wavze1.product_id_lookup();

CREATE OR REPLACE FUNCTION wavze1.product_id_lookup()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
	v_product_id UUID;
BEGIN
	-- only perform lookup if product_category and product_name is provided
	IF NEW.product_category IS NOT NULL AND NEW.product_name IS NOT NULL THEN
		-- lookup product_id from product table
		SELECT 
			p.product_id
		INTO
			v_product_id
		FROM wavze1.product p
		WHERE p.product_category = NEW.product_category
		AND p.product_name = NEW.product_name;

		-- if product found, populate ID
		IF FOUND THEN
			NEW.product_id := v_product_id;
		ELSE
			-- raise an error
			RAISE EXCEPTION 'Product_ID not found for product_name %', NEW.product_name;
		END IF;
	ELSE
		-- if product_name is NULL, clear product_id
		NEW.product_id := NULL;
	END IF;

	RETURN NEW;
END;
$BODY$;
*********************************************************************************************************************************************************************/

--
-- Name: transaction transaction_created_ts; Type: TRIGGER; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

CREATE TRIGGER transaction_created_ts BEFORE INSERT ON wavze1.transaction FOR EACH ROW EXECUTE FUNCTION wavze1.set_created_ts();

/*********************************************************************************************************************************************************************
-- FUNCTION: wavze1.set_created_ts()

-- DROP FUNCTION IF EXISTS wavze1.set_created_ts();

CREATE OR REPLACE FUNCTION wavze1.set_created_ts()
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

--
-- Name: transaction transaction_dup_flag; Type: TRIGGER; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

CREATE TRIGGER transaction_dup_flag AFTER INSERT OR UPDATE ON wavze1.transaction FOR EACH ROW EXECUTE FUNCTION wavze1.transaction_dup_check();

/*********************************************************************************************************************************************************************
-- FUNCTION: wavze1.transaction_dup_check()

-- DROP FUNCTION IF EXISTS wavze1.transaction_dup_check();

CREATE OR REPLACE FUNCTION wavze1.transaction_dup_check()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
--	v_time_window INTERVAL := '1 day'; replace intervals with current active status
	v_duplicate_count INTEGER;
BEGIN
	-- check for existing transactions with same customer_id and product_id within specified time window
	SELECT COUNT(*) 
	INTO v_duplicate_count
	FROM wavze1.transaction
	WHERE customer_id = NEW.customer_id
	AND product_id = NEW.product_id
	AND active = TRUE
--	AND created_ts BETWEEN (NEW.created_ts - v_time_window) AND (NEW.created_ts + v_time_window)
	;

	-- if duplcates found, set duplicate = 1
	IF v_duplicate_count > 0 THEN NEW.duplicate := TRUE;

		-- update existing duplicate transactions to flag
		UPDATE wavze1.transaction
		SET duplicate = TRUE
		WHERE customer_id = NEW.customer_id
		AND product_id = NEW.product_id
		AND active = TRUE
		AND transaction_id != NEW.transaction_id
--		AND created_ts BETWEEN (NEW.created_ts - v_time_window) AND (NEW.created_ts + v_time_window)
		AND duplicate = FALSE;  -- only update if not already flagged
	ELSE
		-- no duplicates found, ensure duplicate = 0
		NEW.duplicate := FALSE;
	END IF;

	RETURN NEW;
END;
$BODY$;
*********************************************************************************************************************************************************************/

--
-- Name: transaction transaction_id_detail; Type: TRIGGER; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

CREATE TRIGGER transaction_id_detail BEFORE INSERT ON wavze1.transaction FOR EACH ROW EXECUTE FUNCTION wavze1.transaction_detail_uuid();

/*********************************************************************************************************************************************************************
-- FUNCTION: wavze1.transaction_detail_uuid()

-- DROP FUNCTION IF EXISTS wavze1.transaction_detail_uuid();

CREATE OR REPLACE FUNCTION wavze1.transaction_detail_uuid()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
	INSERT INTO wavze1.transaction_detail (transaction_id)
	VALUES (NEW.transaction_id);
	RETURN NEW;
END;
$BODY$;
*********************************************************************************************************************************************************************/

--
-- Name: transaction transaction_id_milestone_kpi; Type: TRIGGER; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

CREATE TRIGGER transaction_id_milestone BEFORE INSERT ON wavze1.transaction FOR EACH ROW EXECUTE FUNCTION wavze1.transaction_milestone_kpi_uuid();

/*********************************************************************************************************************************************************************
-- FUNCTION: wavze1.transaction_milestone_kpi_uuid()

-- DROP FUNCTION IF EXISTS wavze1.transaction_milestone_kpi_uuid();

CREATE OR REPLACE FUNCTION wavze1.transaction_milestone_kpi_uuid()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
	INSERT INTO wavze1.transaction_milestone_kpi (transaction_id)
	VALUES (NEW.transaction_id);
	RETURN NEW;
END;
$BODY$;
*********************************************************************************************************************************************************************/

--
-- Name: transaction transaction_track_history; Type: TRIGGER; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

CREATE TRIGGER transaction_track_history AFTER INSERT OR DELETE OR UPDATE ON wavze1.transaction FOR EACH ROW EXECUTE FUNCTION wavze1.track_transaction1_field_changes();

/*********************************************************************************************************************************************************************
-- FUNCTION: wavze1.track_transaction1_field_changes()

-- DROP FUNCTION IF EXISTS wavze1.track_transaction1_field_changes();

CREATE OR REPLACE FUNCTION wavze1.track_transaction1_field_changes()
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

	-- get column info for transaction table
	FOR col_info IN
		SELECT
			column_name,
			data_type,
			udt_name
		FROM information_schema.columns
		WHERE table_schema = 'wavze1'
		AND table_name = 'transaction'
		AND column_name NOT IN ('transaction_id','created_ts','created_by','modified_ts','modified_by')
	LOOP
		field_name := col_info.column_name;
		field_type := col_info.data_type;

		-- INSERT operation
		IF TG_OP = 'INSERT' THEN
			new_val := new_json->field_name; 

			-- only record non-NULL values
			IF new_val IS NOT NULL AND new_val != 'null'::JSONB THEN
				INSERT INTO wavze1.transaction_hist (
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
				INSERT INTO wavze1.transaction_hist (
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

			INSERT INTO wavze1.transaction_hist (
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

--
-- Name: transaction customer_id; Type: FK CONSTRAINT; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavze1.transaction
    ADD CONSTRAINT customer_id FOREIGN KEY (customer_id) REFERENCES wavze1.customer(customer_id) NOT VALID;


--
-- Name: transaction product_id; Type: FK CONSTRAINT; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavze1.transaction
    ADD CONSTRAINT product_id FOREIGN KEY (product_id) REFERENCES wavze1.product(product_id) NOT VALID;


--
-- Name: transaction property_id; Type: FK CONSTRAINT; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavze1.transaction
    ADD CONSTRAINT property_id FOREIGN KEY (property_id) REFERENCES wavze1.property(property_id) NOT VALID;


--
-- Name: transaction user_id; Type: FK CONSTRAINT; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavze1.transaction
    ADD CONSTRAINT user_id FOREIGN KEY (user_id) REFERENCES wavze1.wavze_user(user_id) NOT VALID;


--
-- Name: TABLE transaction; Type: ACL; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE wavze1.transaction TO "erik.michaelson@taranginc.com";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE wavze1.transaction TO "kevin.soderholm@taranginc.com";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE wavze1.transaction TO "jagadeesh.pasupulati@taranginc.com";
GRANT SELECT,INSERT,REFERENCES,TRIGGER,TRUNCATE,UPDATE ON TABLE wavze1.transaction TO "wavze1@wavze1db2";

