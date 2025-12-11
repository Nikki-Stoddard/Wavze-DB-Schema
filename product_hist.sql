--
-- PostgreSQL database dump
--

\restrict cxeOTPIj9juOSNahbM3wJU2ia8wcbVpg2Da0nWZGQbcUlT7qh73RhOuoCKYc5Qz

-- Dumped from database version 17.6
-- Dumped by pg_dump version 18.0

-- Started on 2025-12-11 13:51:41

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
-- TOC entry 299 (class 1259 OID 28228)
-- Name: product_hist; Type: TABLE; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

CREATE TABLE wavzedemo.product_hist (
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


ALTER TABLE wavzedemo.product_hist OWNER TO "nikki.stoddard@taranginc.com";

--
-- TOC entry 4253 (class 2606 OID 28235)
-- Name: product_hist product_hist_pkey; Type: CONSTRAINT; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavzedemo.product_hist
    ADD CONSTRAINT product_hist_pkey PRIMARY KEY (product_hist_id);


--
-- TOC entry 4255 (class 2620 OID 28245)
-- Name: product_hist last_modified_to_product; Type: TRIGGER; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

CREATE TRIGGER last_modified_to_product AFTER INSERT ON wavzedemo.product_hist FOR EACH ROW EXECUTE FUNCTION wavzedemo.update_product_last_modified();


--
-- TOC entry 4254 (class 2606 OID 28236)
-- Name: product_hist product_id; Type: FK CONSTRAINT; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavzedemo.product_hist
    ADD CONSTRAINT product_id FOREIGN KEY (product_id) REFERENCES wavzedemo.product(product_id);


-- Completed on 2025-12-11 13:51:42

--
-- PostgreSQL database dump complete
--

\unrestrict cxeOTPIj9juOSNahbM3wJU2ia8wcbVpg2Da0nWZGQbcUlT7qh73RhOuoCKYc5Qz

