-- Table: wavze1.customer

-- DROP TABLE IF EXISTS wavze1.customer;

CREATE TABLE wavze1.customer (
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
	orig_source character varying(30) COLLATE pg_catalog."default",
    first_contact_dt date,
    last_contact_dt date,
    rltn_owner_id uuid,
    rltn_owner_name text COLLATE pg_catalog."default",
    modified_ts timestamp with time zone,
    modified_by uuid
);


ALTER TABLE wavze1.customer OWNER TO "nikki.stoddard@taranginc.com";

--
-- Name: COLUMN customer.property_id; Type: COMMENT; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

COMMENT ON COLUMN wavze1.customer.property_id IS 'primary residence';

--
-- Name: customer customer_pkey; Type: CONSTRAINT; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavze1.customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (customer_id);

--
-- Name: customer customer_created_ts; Type: TRIGGER; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

CREATE TRIGGER customer_created_ts BEFORE INSERT ON wavze1.customer FOR EACH ROW EXECUTE FUNCTION wavze1.set_created_ts();

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
-- Name: customer customer_uuid; Type: TRIGGER; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

CREATE TRIGGER customer_uuid BEFORE INSERT OR UPDATE ON wavze1.customer FOR EACH ROW EXECUTE FUNCTION wavze1.customer_uuid_dup_check();

/*********************************************************************************************************************************************************************
-- FUNCTION: wavze1.customer_uuid_dup_check()

-- DROP FUNCTION IF EXISTS wavze1.customer_uuid_dup_check();

CREATE OR REPLACE FUNCTION wavze1.customer_uuid_dup_check()
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
	FROM wavze1.customer
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

--
-- Name: customer set_rltn_owner_name; Type: TRIGGER; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

CREATE TRIGGER set_rltn_owner_name BEFORE INSERT OR UPDATE ON wavze1.customer FOR EACH ROW EXECUTE FUNCTION wavze1.rltn_owner_name();

/*********************************************************************************************************************************************************************
-- FUNCTION: wavze1.rltn_owner_name()

-- DROP FUNCTION IF EXISTS wavze1.rltn_owner_name();

CREATE OR REPLACE FUNCTION wavze1.rltn_owner_name()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
	v_owner_name TEXT;
BEGIN
	-- only perform lookup if wavze user id is populated
	IF NEW.rltn_owner_id IS NOT NULL THEN
		-- lookup user_id from wavze_user table
		SELECT 
			first_name || ' ' || last_name 
		INTO
			v_owner_name
		FROM wavze1.wavze_user
		WHERE user_id = NEW.rltn_owner_id;

		-- if wavze user found, populate owner name
		IF FOUND THEN
			NEW.rltn_owner_name := v_owner_name;
		ELSE
			-- raise an error
			RAISE EXCEPTION 'Wavze user name not found for rltn_owner_id %', NEW.rltn_owner_id;
		END IF;
	ELSE
		-- if rltn_owner_id is NULL, clear rltn_owner_id
		NEW.rltn_owner_id := NULL;
	END IF;

	RETURN NEW;
END;
$BODY$;
*********************************************************************************************************************************************************************/

-- 
-- Name: customer track_customer_history; Type: TRIGGER; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

CREATE TRIGGER track_customer_history AFTER INSERT OR DELETE OR UPDATE ON wavze1.customer FOR EACH ROW EXECUTE FUNCTION wavze1.track_customer_field_changes();

/*********************************************************************************************************************************************************************
-- FUNCTION: wavze1.track_customer_field_changes()

-- DROP FUNCTION IF EXISTS wavze1.track_customer_field_changes();

CREATE OR REPLACE FUNCTION wavze1.track_customer_field_changes()
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
		WHERE table_schema = 'wavze1'
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
				INSERT INTO wavze1.customer_hist (
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
				INSERT INTO wavze1.customer_hist (
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

			INSERT INTO wavze1.customer_hist (
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


-- 
-- Name: customer created_by; Type: FK CONSTRAINT; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavze1.customer
    ADD CONSTRAINT created_by FOREIGN KEY (created_by) REFERENCES wavze1.wavze_user(user_id);


--
-- Name: customer property_id; Type: FK CONSTRAINT; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavze1.customer
    ADD CONSTRAINT property_id FOREIGN KEY (property_id) REFERENCES wavze1.property(property_id);


--
-- Name: TABLE customer; Type: ACL; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE wavze1.customer TO "erik.michaelson@taranginc.com";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE wavze1.customer TO "jagadeesh.pasupulati@taranginc.com";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE wavze1.customer TO "kevin.soderholm@taranginc.com";
GRANT SELECT,INSERT,REFERENCES,TRIGGER,TRUNCATE,UPDATE ON TABLE wavze1.customer TO "wavze1@wavze1db2";

