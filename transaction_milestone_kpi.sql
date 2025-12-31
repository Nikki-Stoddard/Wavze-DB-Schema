-- Table: wavze1.transaction_milestone_kpi

CREATE TABLE wavze1.transaction_milestone_kpi (
    transaction_id uuid NOT NULL,
    customer_id uuid,
    generate_dt date,
    appl_flag numeric(1,0) DEFAULT 0,
    outcome_dt date,
    win_flag numeric(1,0)
);


ALTER TABLE wavze1.transaction_milestone_kpi OWNER TO "nikki.stoddard@taranginc.com";

--
-- Name: transaction_milestone_kpi transaction_milestone_kpi_pkey; Type: CONSTRAINT; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavze1.transaction_milestone_kpi
    ADD CONSTRAINT transaction_milestone_kpi_pkey PRIMARY KEY (transaction_id);


--
-- Name: transaction_milestone_kpi customer_id; Type: FK CONSTRAINT; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavze1.transaction_milestone_kpi
    ADD CONSTRAINT customer_id FOREIGN KEY (customer_id) REFERENCES wavze1.customer(customer_id);

