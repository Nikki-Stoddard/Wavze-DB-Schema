-- Table: wavze1.application_properties

-- DROP TABLE IF EXISTS wavze1.application_properties;

CREATE TABLE wavze1.application_properties (
    appl_prop_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    appl_prop_name text,
    appl_prop_value text,
    environment text,
    subscriber_id uuid,
    appl_prop_status character varying(10),
    created_ts timestamp with time zone,
    modified_ts timestamp with time zone
);


ALTER TABLE wavze1.application_properties OWNER TO "nikki.stoddard@taranginc.com";

--
-- Name: application_properties application_properties_pkey; Type: CONSTRAINT; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavze1.application_properties
    ADD CONSTRAINT application_properties_pkey PRIMARY KEY (appl_prop_id);


--
-- Name: application_properties appl_prop_created_ts; Type: TRIGGER; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

CREATE TRIGGER appl_prop_created_ts BEFORE INSERT ON wavze1.application_properties FOR EACH ROW EXECUTE FUNCTION wavze1.set_created_ts();

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
