-- Table: wavzedemo.customer_hist

-- DROP TABLE IF EXISTS wavzedemo.customer_hist;

CREATE TABLE wavzedemo.customer_hist (
    customer_hist_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    customer_id uuid NOT NULL,
    operation character varying(10),
    field_name character varying(50),
    field_type character varying(50),
    old_value jsonb,
    new_value jsonb,
    modified_ts timestamp with time zone,
    modified_by uuid
);


ALTER TABLE wavzedemo.customer_hist OWNER TO "nikki.stoddard@taranginc.com";

--
-- TOC entry 4253 (class 2606 OID 26134)
-- Name: customer_hist customer_hist_pkey; Type: CONSTRAINT; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavzedemo.customer_hist
    ADD CONSTRAINT customer_hist_pkey PRIMARY KEY (customer_hist_id);


--
-- TOC entry 4256 (class 2620 OID 26146)
-- Name: customer_hist last_modified_to_customer; Type: TRIGGER; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

CREATE TRIGGER last_modified_to_customer AFTER INSERT ON wavzedemo.customer_hist FOR EACH ROW EXECUTE FUNCTION wavzedemo.update_customer_last_modified();

/*********************************************************************************************************************************************************************
-- FUNCTION: wavzedemo.update_customer_last_modified()

-- DROP FUNCTION IF EXISTS wavzedemo.update_customer_last_modified();

CREATE OR REPLACE FUNCTION wavzedemo.update_customer_last_modified()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
	v_latest_hist RECORD;
BEGIN
	-- get the latest history record for customer_id
	SELECT
		modified_ts,
		modified_by
	INTO v_latest_hist
	FROM wavzedemo.customer_hist
	WHERE customer_id = NEW.customer_id
	ORDER BY modified_ts DESC, customer_hist_id DESC
	LIMIT 1;

	-- update customer ttable with latest modified
	UPDATE wavzedemo.customer
	SET
		modified_ts = COALESCE(v_latest_hist.modified_ts, CURRENT_TIMESTAMP),
		modified_by = v_latest_hist.modified_by
	WHERE customer_id = NEW.customer_id;

	RETURN NEW;
END;
$BODY$;
*********************************************************************************************************************************************************************/


-- TOC entry 4254 (class 2606 OID 26135)
-- Name: customer_hist customer_id; Type: FK CONSTRAINT; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavzedemo.customer_hist
    ADD CONSTRAINT customer_id FOREIGN KEY (customer_id) REFERENCES wavzedemo.customer(customer_id);


--
-- TOC entry 4255 (class 2606 OID 26266)
-- Name: customer_hist modified_by; Type: FK CONSTRAINT; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavzedemo.customer_hist
    ADD CONSTRAINT modified_by FOREIGN KEY (modified_by) REFERENCES wavzedemo.wavze_user(user_id) NOT VALID;


--
-- TOC entry 4411 (class 0 OID 0)
-- Dependencies: 258
-- Name: TABLE customer_hist; Type: ACL; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

GRANT SELECT,INSERT,REFERENCES,TRIGGER,TRUNCATE,UPDATE ON TABLE wavzedemo.customer_hist TO "wavzedemo@wavzedemodb2";

