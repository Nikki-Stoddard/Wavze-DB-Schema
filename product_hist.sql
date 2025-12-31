-- Table: wavze1.product_hist

-- DROP TABLE IF EXISTS wavze1.product_hist;

CREATE TABLE wavze1.product_hist (
    product_hist_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    product_id uuid,
    operation character varying(10),
    field_name character varying(50),
    field_type character varying(50),
    old_value jsonb,
    new_value jsonb,
    modified_ts timestamp with time zone,
    modified_by uuid
);


ALTER TABLE wavze1.product_hist OWNER TO "nikki.stoddard@taranginc.com";

--
-- TOC entry 4253 (class 2606 OID 28235)
-- Name: product_hist product_hist_pkey; Type: CONSTRAINT; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavze1.product_hist
    ADD CONSTRAINT product_hist_pkey PRIMARY KEY (product_hist_id);


--
-- TOC entry 4255 (class 2620 OID 28245)
-- Name: product_hist last_modified_to_product; Type: TRIGGER; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

CREATE TRIGGER last_modified_to_product AFTER INSERT ON wavze1.product_hist FOR EACH ROW EXECUTE FUNCTION wavze1.update_product_last_modified();

/*********************************************************************************************************************************************************************
-- FUNCTION: wavze1.update_product_last_modified()

-- DROP FUNCTION IF EXISTS wavze1.update_product_last_modified();

CREATE OR REPLACE FUNCTION wavze1.update_product_last_modified()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
	v_latest_hist RECORD;
BEGIN
	-- get the latest history record for product_id
	SELECT
		modified_ts,
		modified_by
	INTO v_latest_hist
	FROM wavze1.product_hist
	WHERE product_id = NEW.product_id
	ORDER BY modified_ts DESC, product_hist_id DESC
	LIMIT 1;

	-- update product table with latest modified
	UPDATE wavze1.product
	SET
		modified_ts = COALESCE(v_latest_hist.modified_ts, CURRENT_TIMESTAMP),
		modified_by = v_latest_hist.modified_by
	WHERE product_id = NEW.product_id;

	RETURN NEW;
END;
$BODY$;
*********************************************************************************************************************************************************************/


-- TOC entry 4254 (class 2606 OID 28236)
-- Name: product_hist product_id; Type: FK CONSTRAINT; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavze1.product_hist
    ADD CONSTRAINT product_id FOREIGN KEY (product_id) REFERENCES wavze1.product(product_id);

