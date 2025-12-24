-- Table: wavzedemo.transaction_hist

-- DROP TABLE IF EXISTS wavzedemo.transaction_hist;

CREATE TABLE wavzedemo.transaction_hist (
    transaction_hist_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    transaction_id uuid NOT NULL,
    operation character varying(10),
    field_name character varying(50),
    field_type character varying(50),
    old_value jsonb,
    new_value jsonb,
    modified_ts timestamp with time zone,
    modified_by uuid
);


ALTER TABLE wavzedemo.transaction_hist OWNER TO "nikki.stoddard@taranginc.com";

--
-- Name: transaction_hist transaction_hist_pkey; Type: CONSTRAINT; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavzedemo.transaction_hist
    ADD CONSTRAINT transaction_hist_pkey PRIMARY KEY (transaction_hist_id);


--
-- Name: transaction_hist last_modified_to_transaction; Type: TRIGGER; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

CREATE TRIGGER last_modified_to_transaction AFTER INSERT ON wavzedemo.transaction_hist FOR EACH ROW EXECUTE FUNCTION wavzedemo.update_transaction_last_modified();

/*********************************************************************************************************************************************************************
-- FUNCTION: wavzedemo.update_transaction_last_modified()

-- DROP FUNCTION IF EXISTS wavzedemo.update_transaction_last_modified();

CREATE OR REPLACE FUNCTION wavzedemo.update_transaction_last_modified()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
	v_latest_hist RECORD;
BEGIN
	-- get the latest history record for transaction_id 
	SELECT
		modified_ts,
		modified_by
	INTO v_latest_hist
	FROM wavzedemo.transaction_hist
	WHERE transaction_id = NEW.transaction_id
	ORDER BY modified_ts DESC, transaction_hist_id DESC
	LIMIT 1;

	-- update transaction table with latest modified 
	UPDATE wavzedemo.transaction
	SET
		modified_ts = COALESCE(v_latest_hist.modified_ts, CURRENT_TIMESTAMP),
		modified_by = v_latest_hist.modified_by
	WHERE transaction_id = NEW.transaction_id;

	RETURN NEW;
END;
$BODY$;
*********************************************************************************************************************************************************************/


--
-- Name: transaction_hist set_kpi_milestone_flags; Type: TRIGGER; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

CREATE TRIGGER set_kpi_milestone_flags AFTER INSERT OR UPDATE ON wavzedemo.transaction_hist FOR EACH ROW EXECUTE FUNCTION wavzedemo.kpi_milestone_flags();

/*********************************************************************************************************************************************************************
-- FUNCTION: wavzedemo.kpi_milestone_flags()

-- DROP FUNCTION IF EXISTS wavzedemo.kpi_milestone_flags();

CREATE OR REPLACE FUNCTION wavzedemo.kpi_milestone_flags()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN

	IF NEW.field_name = 'milestone' AND UPPER(TRIM(CAST(NEW.new_value AS text))) LIKE '%APP SUB%' THEN 
		UPDATE wavzedemo.transaction_milestone_kpi
		SET appl_flag = 1
		WHERE transaction_id = NEW.transaction_id;
		
	ELSIF NEW.field_name = 'milestone' AND UPPER(TRIM(CAST(NEW.new_value AS text))) LIKE ('%CLOSED%') THEN
		UPDATE wavzedemo.transaction_milestone_kpi
		SET outcome_dt = NEW.modified_ts,
			win_flag = 0
		WHERE transaction_id = NEW.transaction_id;
		
	ELSIF NEW.field_name = 'milestone' AND 
		(UPPER(TRIM(CAST(NEW.new_value AS text))) LIKE ('%FUNDED%') 
			OR UPPER(TRIM(CAST(NEW.new_value AS text))) LIKE ('%ACCOUNT OPEN%')) THEN 
		UPDATE wavzedemo.transaction_milestone_kpi
		SET outcome_dt = NEW.modified_ts,
			win_flag = 1
		WHERE transaction_id = NEW.transaction_id;
	
	END IF;

	RETURN NEW;
END;
$BODY$;
*********************************************************************************************************************************************************************/


-- Name: transaction_hist modified_by; Type: FK CONSTRAINT; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavzedemo.transaction_hist
    ADD CONSTRAINT modified_by FOREIGN KEY (modified_by) REFERENCES wavzedemo.wavze_user(user_id);


--
-- Name: transaction_hist transaction_id; Type: FK CONSTRAINT; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavzedemo.transaction_hist
    ADD CONSTRAINT transaction_id FOREIGN KEY (transaction_id) REFERENCES wavzedemo.transaction(transaction_id);

