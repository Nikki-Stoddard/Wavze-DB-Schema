-- Table: wavze1.interaction_rltn

-- DROP TABLE IF EXISTS wavze1.interaction_rltn;

CREATE TABLE wavze1.interaction_rltn (
    interaction_rltn_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    interaction_id uuid NOT NULL,
    customer_id uuid,
    user_id uuid,
    bob_id uuid,
    coi_id uuid,
    transaction_id uuid,
    transaction_result character varying(30),
    created_ts timestamp with time zone
);


ALTER TABLE wavze1.interaction_rltn OWNER TO "nikki.stoddard@taranginc.com";

--
-- Name: interaction_rltn interaction_rltn_pkey; Type: CONSTRAINT; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavze1.interaction_rltn
    ADD CONSTRAINT interaction_rltn_pkey PRIMARY KEY (interaction_rltn_id);


--
-- Name: interaction_rltn interaction_rltn_create_ts; Type: TRIGGER; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

CREATE TRIGGER interaction_rltn_create_ts BEFORE INSERT ON wavze1.interaction_rltn FOR EACH ROW EXECUTE FUNCTION wavze1.set_created_ts();

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
-- Name: interaction_rltn interaction_rltn_cust_contact_dt; Type: TRIGGER; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

CREATE TRIGGER interaction_rltn_cust_contact_dt AFTER INSERT ON wavze1.interaction_rltn FOR EACH ROW EXECUTE FUNCTION wavze1.cust_contact_dates();

/*********************************************************************************************************************************************************************
-- FUNCTION: wavze1.cust_contact_dates()

-- DROP FUNCTION IF EXISTS wavze1.cust_contact_dates();

CREATE OR REPLACE FUNCTION wavze1.cust_contact_dates()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE 
	v_min_date DATE;
	v_max_date DATE;
	
BEGIN

	--calculate min and max interaction dates for a customer
	SELECT 
		MIN(created_ts),
		MAX(created_ts)
	INTO 
		v_min_date,
		v_max_date
	FROM wavze1.interaction_rltn 
	WHERE customer_id = NEW.customer_id
	AND created_ts IS NOT NULL;

	--update customer table
	UPDATE wavzedemo_ns.customer
	SET
		first_contact_dt = v_min_date,
		last_contact_dt = v_max_date
	WHERE customer_id = NEW.customer_id;

	--if no interactions exist, set dates to NULL
	IF v_min_date IS NULL AND v_max_date IS NULL THEN
		UPDATE wavze1.customer
		SET
			first_contact_dt = NULL,
			last_contact_dt = NULL
		WHERE customer_id = NEW.customer_id;
		
	END IF;
END;
$BODY$;
*********************************************************************************************************************************************************************/

--
-- Name: TABLE interaction_rltn; Type: ACL; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

GRANT SELECT,INSERT,REFERENCES,TRIGGER,TRUNCATE,UPDATE ON TABLE wavze1.interaction_rltn TO "wavzedemo@wavzedemodb2";
