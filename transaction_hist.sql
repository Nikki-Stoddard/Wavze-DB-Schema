--
-- PostgreSQL database dump
--

\restrict I2OPse1h2ezMPQTarpP0rjr4ubagBh3foTpBQr21GLQ0sgGylLyVrnzeHcXQ1A8

-- Dumped from database version 17.6
-- Dumped by pg_dump version 18.0

-- Started on 2025-12-11 13:55:31

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 300 (class 1259 OID 28250)
-- Name: transaction_hist; Type: TABLE; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

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
-- TOC entry 4253 (class 2606 OID 28257)
-- Name: transaction_hist transaction_hist_pkey; Type: CONSTRAINT; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavzedemo.transaction_hist
    ADD CONSTRAINT transaction_hist_pkey PRIMARY KEY (transaction_hist_id);


--
-- TOC entry 4256 (class 2620 OID 28269)
-- Name: transaction_hist last_modified_to_transaction; Type: TRIGGER; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

CREATE TRIGGER last_modified_to_transaction AFTER INSERT ON wavzedemo.transaction_hist FOR EACH ROW EXECUTE FUNCTION wavzedemo.update_transaction_last_modified();


--
-- TOC entry 4254 (class 2606 OID 28258)
-- Name: transaction_hist modified_by; Type: FK CONSTRAINT; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavzedemo.transaction_hist
    ADD CONSTRAINT modified_by FOREIGN KEY (modified_by) REFERENCES wavzedemo.wavze_user(user_id);


--
-- TOC entry 4255 (class 2606 OID 28263)
-- Name: transaction_hist transaction_id; Type: FK CONSTRAINT; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavzedemo.transaction_hist
    ADD CONSTRAINT transaction_id FOREIGN KEY (transaction_id) REFERENCES wavzedemo.transaction(transaction_id);


-- Completed on 2025-12-11 13:55:32

--
-- PostgreSQL database dump complete
--

\unrestrict I2OPse1h2ezMPQTarpP0rjr4ubagBh3foTpBQr21GLQ0sgGylLyVrnzeHcXQ1A8

