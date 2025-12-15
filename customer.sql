
-- Table: wavzedemo.customer

-- DROP TABLE IF EXISTS wavzedemo.customer;

CREATE TABLE wavzedemo.customer (
    customer_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    property_id uuid,
    created_ts timestamp with time zone,
    created_by uuid,
    first_name text,
    middle_name text,
    last_name text,
    email text,
    phn1_type character varying(10),
    phn1_nbr numeric(10,0),
    phn2_type character varying(10),
    phn2_nbr numeric(10,0),
    method_pref character varying(20),
    time_zone character varying(20),
    time_window_pref character varying(20),
    language_pref character varying(20),
    language_othr text,
    street_addr1 text,
    street_addr2 text,
    city text,
    state character(2),
    region character varying(20),
    zip_cde character(5),
    country character varying(30),
    birth_date date,
    marital_status character varying(20),
    employer text,
    occupation text,
    annual_income numeric,
    est_credit_range character varying(20),
    modified_ts timestamp with time zone,
    modified_by uuid
);


ALTER TABLE wavzedemo.customer OWNER TO "nikki.stoddard@taranginc.com";

--
-- TOC entry 4413 (class 0 OID 0)
-- Dependencies: 257
-- Name: COLUMN customer.property_id; Type: COMMENT; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

COMMENT ON COLUMN wavzedemo.customer.property_id IS 'primary residence';


--
-- TOC entry 4253 (class 2606 OID 25621)
-- Name: customer customer_pkey; Type: CONSTRAINT; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavzedemo.customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (customer_id);


--
-- TOC entry 4256 (class 2620 OID 25632)
-- Name: customer customer_created_ts; Type: TRIGGER; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com

CREATE TRIGGER customer_created_ts BEFORE INSERT ON wavzedemo.customer FOR EACH ROW EXECUTE FUNCTION wavzedemo.set_created_ts();

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


-- TOC entry 4257 (class 2620 OID 26147)
-- Name: customer customer_uuid; Type: TRIGGER; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com

CREATE TRIGGER customer_uuid BEFORE INSERT OR UPDATE ON wavzedemo.customer FOR EACH ROW EXECUTE FUNCTION wavzedemo.customer_uuid_dup_check();

/*********************************************************************************************************************************************************************
-- FUNCTION: wavzedemo.customer_uuid_dup_check()

-- DROP FUNCTION IF EXISTS wavzedemo.customer_uuid_dup_check();

CREATE OR REPLACE FUNCTION wavzedemo.customer_uuid_dup_check()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
 	v_existing_customer_id UUID;
BEGIN
	-- check if customer_id with same name, email, and phone number already exists
	SELECT customer_id
	INTO v_existing_customer_id
	FROM wavzedemo.customer
	WHERE 
		-- check name (case-insensitive, trim whitespace)
		LOWER(TRIM(COALESCE(first_name, ''))) = LOWER(TRIM(COALESCE(NEW.first_name, '')))
		AND
		LOWER(TRIM(COALESCE(last_name, ''))) = LOWER(TRIM(COALESCE(NEW.last_name, '')))
		AND(
		-- check email (case-insensitive, trim whitespace)
		LOWER(TRIM(COALESCE(email, ''))) = LOWER(TRIM(COALESCE(NEW.email, '')))
		-- check phone number matches for first and second entries
		OR phn1_nbr = NEW.phn1_nbr OR phn2_nbr = NEW.phn2_nbr OR phn1_nbr = NEW.phn2_nbr OR phn2_nbr = NEW.phn1_nbr
		)
		AND
		-- exclude the current row if this is an UPDATE
		(TG_OP = 'INSERT' OR customer_id != NEW.customer_id)
	LIMIT 1;

	-- if duplicate found, raise an error
	IF v_existing_customer_id IS NOT NULL THEN
		RAISE EXCEPTION 'Duplicate customer found: A customer with name "%, email "%, and phone "% already exists (customer_id: %, uuid: %)', NEW.name, NEW.email, NEW.phone, v_existing_customer_id, v_existing_uuid;with first_name "%, last_name "%, email "%, phn1_nbr "%," and phn2_nbr "% already exists (customer_id: %, uuid: %)', NEW.first_name, NEW.last_name, NEW.email, NEW.phn1_nbr, NEW.phn2_nbr, v_existing_customer_id, v_existing_uuid;
	END IF;

	-- if no duplicate and uuid is not set, generate
	IF NEW.customer_id IS NULL THEN
		NEW.customer_id := uuid_generate_v4();
	END IF;

	RETURN NEW;
END;
$BODY$;
*********************************************************************************************************************************************************************/


-- TOC entry 4258 (class 2620 OID 26206)
-- Name: customer track_customer_history; Type: TRIGGER; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com

CREATE TRIGGER track_customer_history AFTER INSERT OR DELETE OR UPDATE ON wavzedemo.customer FOR EACH ROW EXECUTE FUNCTION wavzedemo.track_customer_field_changes();

/*********************************************************************************************************************************************************************
-- FUNCTION: wavzedemo.track_customer_field_changes()

-- DROP FUNCTION IF EXISTS wavzedemo.track_customer_field_changes();

CREATE OR REPLACE FUNCTION wavzedemo.track_customer_field_changes()
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

	-- get column info for customer table
	FOR col_info IN
		SELECT
			column_name,
			data_type,
			udt_name
		FROM information_schema.columns
		WHERE table_schema = 'wavzedemo'
		AND table_name = 'customer'
		AND column_name NOT IN ('customer_hist_id','customer_id','created_ts','created_by','modified_ts','modified_by')
	LOOP
		field_name := col_info.column_name;
		field_type := col_info.data_type;

		-- INSERT operation
		IF TG_OP = 'INSERT' THEN
			new_val := new_json->field_name; 

			-- only record non-NULL values
			IF new_val IS NOT NULL AND new_val != 'null'::JSONB THEN
				INSERT INTO wavzedemo.customer_hist (
					customer_id,
					operation,
					field_name,
					field_type,
					new_value,
					modified_ts
				) VALUES (
					NEW.customer_id,
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
				INSERT INTO wavzedemo.customer_hist (
					customer_id,
					operation,
					field_name,
					field_type,
					old_value,
					new_value,
					modified_ts
				) VALUES (
					NEW.customer_id,
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

			INSERT INTO wavzedemo.customer_hist (
				customer_id,
				operation,
				field_name,
				field_type,
				old_value,
				modified_ts
			) VALUES (
				OLD.customer_id,
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


-- TOC entry 4254 (class 2606 OID 25622)
-- Name: customer created_by; Type: FK CONSTRAINT; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavzedemo.customer
    ADD CONSTRAINT created_by FOREIGN KEY (created_by) REFERENCES wavzedemo.wavze_user(user_id);


--
-- TOC entry 4255 (class 2606 OID 25627)
-- Name: customer property_id; Type: FK CONSTRAINT; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavzedemo.customer
    ADD CONSTRAINT property_id FOREIGN KEY (property_id) REFERENCES wavzedemo.property(property_id);


--
-- TOC entry 4414 (class 0 OID 0)
-- Dependencies: 257
-- Name: TABLE customer; Type: ACL; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE wavzedemo.customer TO "erik.michaelson@taranginc.com";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE wavzedemo.customer TO "jagadeesh.pasupulati@taranginc.com";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE wavzedemo.customer TO "kevin.soderholm@taranginc.com";
GRANT SELECT,INSERT,REFERENCES,TRIGGER,TRUNCATE,UPDATE ON TABLE wavzedemo.customer TO "wavzedemo@wavzedemodb2";

