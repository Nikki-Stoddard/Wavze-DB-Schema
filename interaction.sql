-- Table: wavze1.interaction

-- DROP TABLE IF EXISTS wavze1.interaction;

CREATE TABLE wavze1.interaction (
    interaction_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    created_ts timestamp with time zone,
    created_by uuid,
    scheduled timestamp with time zone,
    completed timestamp with time zone,
    start_ts timestamp with time zone,
    end_ts timestamp with time zone,
    initiation_mthd character varying(10),
    phone_contact boolean,
    phone_result character varying(50),
    email_contact boolean,
    email_result character varying(50),
    chat_contact boolean,
    chat_result character varying(50),
    offline_contact boolean,
    offline_result character varying(50),
    comments text,
    modified_ts timestamp with time zone,
    modified_by uuid
);


ALTER TABLE wavze1.interaction OWNER TO "nikki.stoddard@taranginc.com";

--
-- Name: interaction interaction_pkey; Type: CONSTRAINT; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavze1.interaction
    ADD CONSTRAINT interaction_pkey PRIMARY KEY (interaction_id);


--
-- Name: interaction interaction_created_ts; Type: TRIGGER; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

CREATE TRIGGER interaction_created_ts BEFORE INSERT ON wavze1.interaction FOR EACH ROW EXECUTE FUNCTION wavze1.set_created_ts();

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
-- Name: interaction created_by; Type: FK CONSTRAINT; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavze1.interaction
    ADD CONSTRAINT created_by FOREIGN KEY (created_by) REFERENCES wavze1.wavze_user(user_id) NOT VALID;


--
-- Name: TABLE interaction; Type: ACL; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

GRANT SELECT,INSERT,REFERENCES,TRIGGER,TRUNCATE,UPDATE ON TABLE wavze1.interaction TO "wavzedemo@wavzedemodb2";
