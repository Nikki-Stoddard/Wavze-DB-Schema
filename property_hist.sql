-- Table: wavzedemo.property_hist

-- DROP TABLE IF EXISTS wavzedemo.property_hist;

CREATE TABLE wavzedemo.property_hist (
    property_hist_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    property_id uuid NOT NULL,
    operation character varying(10),
    field_name character varying(50),
    field_type character varying(50),
    old_value jsonb,
    new_value jsonb,
    modified_ts timestamp with time zone,
    modified_by uuid
);


ALTER TABLE wavzedemo.property_hist OWNER TO "nikki.stoddard@taranginc.com";

--
-- TOC entry 4253 (class 2606 OID 26254)
-- Name: property_hist property_hist_pkey; Type: CONSTRAINT; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavzedemo.property_hist
    ADD CONSTRAINT property_hist_pkey PRIMARY KEY (property_hist_id);


--
-- TOC entry 4256 (class 2620 OID 26274)
-- Name: property_hist last_modified_to_property; Type: TRIGGER; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

CREATE TRIGGER last_modified_to_property AFTER INSERT ON wavzedemo.property_hist FOR EACH ROW EXECUTE FUNCTION wavzedemo.update_property_last_modified();

/*********************************************************************************************************************************************************************
-- FUNCTION: wavzedemo.update_property_last_modified()

-- DROP FUNCTION IF EXISTS wavzedemo.update_property_last_modified();

CREATE OR REPLACE FUNCTION wavzedemo.update_property_last_modified()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
	v_latest_hist RECORD;
BEGIN
	-- get the latest history record for property_id
	SELECT
		modified_ts,
		modified_by
	INTO v_latest_hist
	FROM wavzedemo.property_hist
	WHERE property_id = NEW.property_id
	ORDER BY modified_ts DESC, property_hist_id DESC
	LIMIT 1;

	-- update property table with latest modified
	UPDATE wavzedemo.property
	SET
		modified_ts = COALESCE(v_latest_hist.modified_ts, CURRENT_TIMESTAMP),
		modified_by = v_latest_hist.modified_by
	WHERE property_id = NEW.property_id;

	RETURN NEW;
END;
$BODY$;
*********************************************************************************************************************************************************************/


-- TOC entry 4254 (class 2606 OID 26260)
-- Name: property_hist modified_by; Type: FK CONSTRAINT; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavzedemo.property_hist
    ADD CONSTRAINT modified_by FOREIGN KEY (modified_by) REFERENCES wavzedemo.wavze_user(user_id);


--
-- TOC entry 4255 (class 2606 OID 26255)
-- Name: property_hist property_id; Type: FK CONSTRAINT; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavzedemo.property_hist
    ADD CONSTRAINT property_id FOREIGN KEY (property_id) REFERENCES wavzedemo.property(property_id);

