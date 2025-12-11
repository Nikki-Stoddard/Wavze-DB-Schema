-- Table: wavzedemo.product

-- DROP TABLE IF EXISTS wavzedemo.product;

CREATE TABLE wavzedemo.product (
    product_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    product_category character varying(30) NOT NULL,
    product_name character varying(50) NOT NULL,
    created_ts timestamp with time zone,
    created_by uuid,
    product_active boolean DEFAULT true,
    modified_ts timestamp with time zone,
    modified_by uuid
);


ALTER TABLE wavzedemo.product OWNER TO "nikki.stoddard@taranginc.com";

--
-- TOC entry 4254 (class 2606 OID 25117)
-- Name: product product_pkey; Type: CONSTRAINT; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavzedemo.product
    ADD CONSTRAINT product_pkey PRIMARY KEY (product_id);


--
-- TOC entry 4255 (class 2620 OID 28209)
-- Name: product product_created_ts; Type: TRIGGER; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

CREATE TRIGGER product_created_ts BEFORE INSERT ON wavzedemo.product FOR EACH ROW EXECUTE FUNCTION wavzedemo.set_created_ts();

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


-- TOC entry 4256 (class 2620 OID 28243)
-- Name: product track_product_active; Type: TRIGGER; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

CREATE TRIGGER track_product_active AFTER UPDATE ON wavzedemo.product FOR EACH ROW EXECUTE FUNCTION wavzedemo.track_product_field_changes();

/*********************************************************************************************************************************************************************
-- FUNCTION: wavzedemo.track_product_field_changes()

-- DROP FUNCTION IF EXISTS wavzedemo.track_product_field_changes();

CREATE OR REPLACE FUNCTION wavzedemo.track_product_field_changes()
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
	END IF;

	-- get active flag column info for product table
	FOR col_info IN
		SELECT
			column_name,
			data_type,
			udt_name
		FROM information_schema.columns
		WHERE table_schema = 'wavzedemo'
		AND table_name = 'product'
		AND column_name = 'product_active'
	LOOP
		field_name := col_info.column_name;
		field_type := col_info.data_type;

		-- UPDATE operation
		IF TG_OP = 'UPDATE' THEN
			old_val := old_json->field_name;
			new_val := new_json->field_name;

			-- check if value changed
			IF old_val IS DISTINCT FROM new_val THEN
				INSERT INTO wavzedemo.product_hist (
					product_id,
					operation,
					field_name,
					field_type,
					old_value,
					new_value,
					modified_ts
				) VALUES (
					NEW.product_id,
					'UPDATE',
					field_name,
					field_type,
					old_val,
					new_val,
					CURRENT_TIMESTAMP
				);
			END IF;
		END IF;
	END LOOP;
RETURN NEW;
END;
	
	
$BODY$;
*********************************************************************************************************************************************************************/


-- TOC entry 4411 (class 0 OID 0)
-- Dependencies: 235
-- Name: TABLE product; Type: ACL; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE wavzedemo.product TO "erik.michaelson@taranginc.com";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE wavzedemo.product TO "kevin.soderholm@taranginc.com";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE wavzedemo.product TO "jagadeesh.pasupulati@taranginc.com";
GRANT SELECT,INSERT,REFERENCES,TRIGGER,TRUNCATE,UPDATE ON TABLE wavzedemo.product TO "wavzedemo@wavzedemodb2";

