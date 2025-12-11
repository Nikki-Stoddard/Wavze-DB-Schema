--
-- PostgreSQL database dump
--

\restrict MWmPejBPp5AdZBpxPj0u9TAC46r4w7m6JC6EWj50r7iKfwNhG9ARhrkIGWwRa6f

-- Dumped from database version 17.6
-- Dumped by pg_dump version 18.0

-- Started on 2025-12-11 13:45:53

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
-- TOC entry 258 (class 1259 OID 26128)
-- Name: customer_hist; Type: TABLE; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

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


--
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


-- Completed on 2025-12-11 13:45:54

--
-- PostgreSQL database dump complete
--

\unrestrict MWmPejBPp5AdZBpxPj0u9TAC46r4w7m6JC6EWj50r7iKfwNhG9ARhrkIGWwRa6f

