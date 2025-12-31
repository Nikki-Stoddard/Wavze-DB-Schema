-- Table: wavze1.property

-- DROP TABLE IF EXISTS wavze1.property;

CREATE TABLE wavze1.property (
    property_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    created_ts timestamp with time zone,
    created_by uuid,
    street_addr1 text,
    street_addr2 text,
    city text,
    state character(2),
    region character varying(20),
    zip_cde character(5),
    country character varying(30),
    prop_type character varying(30),
    purchase_date date,
    est_prop_value numeric,
    appraisal_src character varying(20),
    modified_ts timestamp with time zone,
    modified_by uuid
);


ALTER TABLE wavze1.property OWNER TO "nikki.stoddard@taranginc.com";

--
-- TOC entry 4253 (class 2606 OID 25082)
-- Name: property property_pkey; Type: CONSTRAINT; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavze1.property
    ADD CONSTRAINT property_pkey PRIMARY KEY (property_id);


--
-- TOC entry 4255 (class 2620 OID 25083)
-- Name: property property_created_ts; Type: TRIGGER; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

CREATE TRIGGER property_created_ts BEFORE INSERT ON wavze1.property FOR EACH ROW EXECUTE FUNCTION wavze1.set_created_ts();

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


-- TOC entry 4256 (class 2620 OID 26272)
-- Name: property track_property_history; Type: TRIGGER; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

CREATE TRIGGER track_property_history AFTER INSERT OR DELETE OR UPDATE ON wavze1.property FOR EACH ROW EXECUTE FUNCTION wavze1.track_property_field_changes();

/*********************************************************************************************************************************************************************
-- FUNCTION: wavze1.track_property_field_changes()

-- DROP FUNCTION IF EXISTS wavze1.track_property_field_changes();

CREATE OR REPLACE FUNCTION wavze1.track_property_field_changes()
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
		AND table_name = 'property'
		AND column_name NOT IN ('property_hist_id','property_id','created_ts','created_by','modified_ts','modified_by')
	LOOP
		field_name := col_info.column_name;
		field_type := col_info.data_type;

		-- INSERT operation
		IF TG_OP = 'INSERT' THEN
			new_val := new_json->field_name; 

			-- only record non-NULL values
			IF new_val IS NOT NULL AND new_val != 'null'::JSONB THEN
				INSERT INTO wavze1.property_hist (
					property_id,
					operation,
					field_name,
					field_type,
					new_value,
					modified_ts
				) VALUES (
					NEW.property_id,
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
				INSERT INTO wavze1.property_hist (
					property_id,
					operation,
					field_name,
					field_type,
					old_value,
					new_value,
					modified_ts
				) VALUES (
					NEW.property_id,
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

			INSERT INTO wavze1.property_hist (
				property_id,
				operation,
				field_name,
				field_type,
				old_value,
				modified_ts
			) VALUES (
				OLD.property_id,
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


-- TOC entry 4254 (class 2606 OID 25651)
-- Name: property created_by; Type: FK CONSTRAINT; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavze1.property
    ADD CONSTRAINT created_by FOREIGN KEY (created_by) REFERENCES wavze1.wavze_user(user_id) NOT VALID;


--
-- TOC entry 4411 (class 0 OID 0)
-- Dependencies: 243
-- Name: TABLE property; Type: ACL; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE wavze1.property TO "erik.michaelson@taranginc.com";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE wavze1.property TO "jagadeesh.pasupulati@taranginc.com";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE wavze1.property TO "kevin.soderholm@taranginc.com";
GRANT SELECT,INSERT,REFERENCES,TRIGGER,TRUNCATE,UPDATE ON TABLE wavze1.property TO "wavze1@wavze1db2";

