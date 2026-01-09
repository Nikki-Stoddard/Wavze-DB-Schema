-- Table: wavze1.ai_assistant

-- DROP TABLE IF EXISTS wavze1.ai_assistant;

CREATE TABLE wavze1.ai_assistant (
    prompt_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    user_prompt text,
    ai_response text,
    prompt_ts timestamp with time zone,
    response_ts timestamp with time zone,
    created_ts timestamp with time zone
);


ALTER TABLE wavze1.ai_assistant OWNER TO "nikki.stoddard@taranginc.com";

--
-- Name: ai_assistant ai_assistant_pkey; Type: CONSTRAINT; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavze1.ai_assistant
    ADD CONSTRAINT ai_assistant_pkey PRIMARY KEY (prompt_id);


--
-- Name: ai_assistant ai_prompt_created_ts; Type: TRIGGER; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

CREATE TRIGGER ai_prompt_created_ts BEFORE INSERT ON wavze1.ai_assistant FOR EACH ROW EXECUTE FUNCTION wavze1.set_created_ts();

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
-- Name: ai_assistant user_id; Type: FK CONSTRAINT; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavze1.ai_assistant
    ADD CONSTRAINT user_id FOREIGN KEY (user_id) REFERENCES wavze1.wavze_user(user_id) NOT VALID;


