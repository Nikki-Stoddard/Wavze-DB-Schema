-- Table: wavze1.property_rltn

-- DROP TABLE IF EXISTS wavze1.property_rltn;

CREATE TABLE wavze1.property_rltn (
    property_rltn_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    property_id uuid NOT NULL,
    customer_id uuid,
    prim_residence boolean,
    occupancy character varying(30),
    created_ts timestamp with time zone
);


ALTER TABLE wavze1.property_rltn OWNER TO "nikki.stoddard@taranginc.com";

--
-- TOC entry 4253 (class 2606 OID 25349)
-- Name: property_rltn property_rltn_pkey; Type: CONSTRAINT; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavze1.property_rltn
    ADD CONSTRAINT property_rltn_pkey PRIMARY KEY (property_rltn_id);


--
-- TOC entry 4254 (class 2620 OID 24948)
-- Name: property_rltn property_rltn_created_ts; Type: TRIGGER; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

CREATE TRIGGER property_rltn_created_ts BEFORE INSERT ON wavze1.property_rltn FOR EACH ROW EXECUTE FUNCTION wavze1.set_created_ts();

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


-- TOC entry 4255 (class 2620 OID 28338)
-- Name: property_rltn set_prim_residence_flag; Type: TRIGGER; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

CREATE TRIGGER set_prim_residence_flag BEFORE INSERT OR UPDATE ON wavze1.property_rltn FOR EACH ROW EXECUTE FUNCTION wavze1.set_prim_residence_from_occupancy();

/*********************************************************************************************************************************************************************
-- FUNCTION: wavze1.set_prim_residence_from_occupancy()

-- DROP FUNCTION IF EXISTS wavze1.set_prim_residence_from_occupancy();

CREATE OR REPLACE FUNCTION wavze1.set_prim_residence_from_occupancy()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN

	IF UPPER(TRIM(NEW.occupancy)) = 'PRIMARY RESIDENCE' THEN
		NEW.prim_residence := TRUE;
		ELSE NEW.prim_residence := FALSE;
	END IF;

	RETURN NEW;
END;
$BODY$;
*********************************************************************************************************************************************************************/


-- TOC entry 4256 (class 2620 OID 26246)
-- Name: property_rltn set_prim_residence_property_id; Type: TRIGGER; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

CREATE TRIGGER set_prim_residence_property_id AFTER INSERT OR DELETE OR UPDATE ON wavze1.property_rltn FOR EACH ROW EXECUTE FUNCTION wavze1.update_customer_prim_residence();

/*********************************************************************************************************************************************************************
-- FUNCTION: wavze1.update_customer_prim_residence()

-- DROP FUNCTION IF EXISTS wavze1.update_customer_prim_residence();

CREATE OR REPLACE FUNCTION wavze1.update_customer_prim_residence()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
	v_property_id uuid;
	v_street_addr1 text;
	v_street_addr2 text;
	v_city text;
	v_state character(2);
	v_region character varying(20);
	v_zip_cde character(5);
	v_country character varying(30);
BEGIN
	-- determine which customer_id and property_id to use based on trigger operation
	IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
		-- get the primary residence property_id from property_rltn
		SELECT pr.property_id,
			p.street_addr1,
			p.street_addr2,
			p.city,
			p.state,
			p.region,
			p.zip_cde,
			p.country
		INTO v_property_id,
			v_street_addr1,
			v_street_addr2,
			v_city,
			v_state,
			v_region,
			v_zip_cde,
			v_country
		FROM wavze1.property_rltn pr
		INNER JOIN wavze1.property p ON p.property_id = pr.property_id
		WHERE pr.property_id = NEW.property_id
		AND pr.prim_residence = 'TRUE';

		-- if found, update the customer property_id
		IF v_property_id IS NOT NULL THEN
			UPDATE wavze1.customer
			SET property_id = v_property_id,
				street_addr1 = v_street_addr1,
				street_addr2 = v_street_addr2,
				city = v_city,
				state = v_state,
				region = v_region,
				zip_cde = v_zip_cde,
				country = v_country
			WHERE customer_id = NEW.customer_id;
		END IF;

		RETURN NEW;

	ELSIF TG_OP = 'DELETE' THEN
		-- if property_rltn is deleted, check if customer.property_id should be cleared
		-- only clear if property_id was the primary residence
		SELECT p.property_id
		INTO v_property_id
		FROM wavze1.property_rltn p
		WHERE p.property_id = OLD.property_id
		AND p.prim_residence = 'TRUE';

		IF v_property_id IS NOT NULL THEN
			-- clear property_id on customer if it matches the deleted relationship
			-- do not clear address info from customer table in case it's a different address manually entered
			UPDATE wavze1.customer
			SET property_id = NULL
			WHERE customer_id = OLD.customer_id
			AND property_id = OLD.property_id;

			-- find another primary residence property for customer_id
			SELECT pr.property_id,
				p.street_addr1,
				p.street_addr2,
				p.city,
				p.state,
				p.region,
				p.zip_cde,
				p.country
			INTO v_property_id,
				v_street_addr1,
				v_street_addr2,
				v_city,
				v_state,
				v_region,
				v_zip_cde,
				v_country
			FROM wavze1.property_rltn pr
			INNER JOIN wavze1.property p ON p.property_id = pr.property_id
			WHERE p.customer_id = OLD.customer_id
			AND p.prim_residence = 'TRUE'
			LIMIT 1;

			-- if another primary residence exists, set it
			IF v_property_id IS NOT NULL THEN
				UPDATE wavze1.customer 
				SET property_id = v_property_id,
					street_addr1 = v_street_addr1,
					street_addr2 = v_street_addr2,
					city = v_city,
					state = v_state,
					region = v_region,
					zip_cde = v_zip_cde,
					country = v_country
				WHERE customer_id = OLD.customer_id;
			END IF;
		END IF;

		RETURN OLD;
	END IF;

	RETURN NULL;
END;
	
$BODY$;
*********************************************************************************************************************************************************************/


-- TOC entry 4411 (class 0 OID 0)
-- Dependencies: 233
-- Name: TABLE property_rltn; Type: ACL; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE wavze1.property_rltn TO "erik.michaelson@taranginc.com";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE wavze1.property_rltn TO "kevin.soderholm@taranginc.com";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE wavze1.property_rltn TO "jagadeesh.pasupulati@taranginc.com";
GRANT SELECT,INSERT,REFERENCES,TRIGGER,TRUNCATE,UPDATE ON TABLE wavze1.property_rltn TO "wavze1@wavze1db2";

