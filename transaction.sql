--
-- PostgreSQL database dump
--

\restrict Jl89qDIhZmnp7prykrbfrHDcMjwMc506AkcykYPKwIu1xXQqACFFqrIWENIG4g1

-- Dumped from database version 17.6
-- Dumped by pg_dump version 18.0

-- Started on 2025-12-11 13:54:34

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
-- TOC entry 234 (class 1259 OID 24873)
-- Name: transaction; Type: TABLE; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

CREATE TABLE wavzedemo.transaction (
    transaction_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    customer_id uuid NOT NULL,
    property_id uuid,
    user_id uuid,
    bob_id uuid,
    coi_id uuid,
    created_ts timestamp with time zone,
    created_by uuid,
    product_id uuid NOT NULL,
    product_category character varying(30) NOT NULL,
    product_name character varying(50),
    source character varying(30),
    milestone character varying(30),
    time_sensitive boolean DEFAULT false,
    sensitive_reason character varying(30),
    active boolean DEFAULT true,
    duplicate boolean DEFAULT false,
    modified_ts timestamp without time zone,
    modified_by uuid
);


ALTER TABLE wavzedemo.transaction OWNER TO "nikki.stoddard@taranginc.com";

--
-- TOC entry 4256 (class 2606 OID 25089)
-- Name: transaction transaction_pkey; Type: CONSTRAINT; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavzedemo.transaction
    ADD CONSTRAINT transaction_pkey PRIMARY KEY (transaction_id);


--
-- TOC entry 4261 (class 2620 OID 26199)
-- Name: transaction inactive_status; Type: TRIGGER; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

CREATE TRIGGER inactive_status BEFORE INSERT OR UPDATE ON wavzedemo.transaction FOR EACH ROW EXECUTE FUNCTION wavzedemo.transaction_active_check();


--
-- TOC entry 4262 (class 2620 OID 26166)
-- Name: transaction set_product_id; Type: TRIGGER; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

CREATE TRIGGER set_product_id BEFORE INSERT OR UPDATE ON wavzedemo.transaction FOR EACH ROW EXECUTE FUNCTION wavzedemo.product_id_lookup();


--
-- TOC entry 4263 (class 2620 OID 24949)
-- Name: transaction transaction_created_ts; Type: TRIGGER; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

CREATE TRIGGER transaction_created_ts BEFORE INSERT ON wavzedemo.transaction FOR EACH ROW EXECUTE FUNCTION wavzedemo.set_created_ts();


--
-- TOC entry 4264 (class 2620 OID 26184)
-- Name: transaction transaction_dup_flag; Type: TRIGGER; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

CREATE TRIGGER transaction_dup_flag AFTER INSERT OR UPDATE ON wavzedemo.transaction FOR EACH ROW EXECUTE FUNCTION wavzedemo.transaction_dup_check();


--
-- TOC entry 4265 (class 2620 OID 26189)
-- Name: transaction transaction_id_detail; Type: TRIGGER; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

CREATE TRIGGER transaction_id_detail BEFORE INSERT ON wavzedemo.transaction FOR EACH ROW EXECUTE FUNCTION wavzedemo.transaction_detail_uui();


--
-- TOC entry 4266 (class 2620 OID 28248)
-- Name: transaction transaction_track_history; Type: TRIGGER; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

CREATE TRIGGER transaction_track_history AFTER INSERT OR DELETE OR UPDATE ON wavzedemo.transaction FOR EACH ROW EXECUTE FUNCTION wavzedemo.track_transaction1_field_changes();


--
-- TOC entry 4257 (class 2606 OID 25666)
-- Name: transaction customer_id; Type: FK CONSTRAINT; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavzedemo.transaction
    ADD CONSTRAINT customer_id FOREIGN KEY (customer_id) REFERENCES wavzedemo.customer(customer_id) NOT VALID;


--
-- TOC entry 4258 (class 2606 OID 25671)
-- Name: transaction product_id; Type: FK CONSTRAINT; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavzedemo.transaction
    ADD CONSTRAINT product_id FOREIGN KEY (product_id) REFERENCES wavzedemo.product(product_id) NOT VALID;


--
-- TOC entry 4259 (class 2606 OID 25138)
-- Name: transaction property_id; Type: FK CONSTRAINT; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavzedemo.transaction
    ADD CONSTRAINT property_id FOREIGN KEY (property_id) REFERENCES wavzedemo.property(property_id) NOT VALID;


--
-- TOC entry 4260 (class 2606 OID 25143)
-- Name: transaction user_id; Type: FK CONSTRAINT; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavzedemo.transaction
    ADD CONSTRAINT user_id FOREIGN KEY (user_id) REFERENCES wavzedemo.wavze_user(user_id) NOT VALID;


--
-- TOC entry 4421 (class 0 OID 0)
-- Dependencies: 234
-- Name: TABLE transaction; Type: ACL; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE wavzedemo.transaction TO "erik.michaelson@taranginc.com";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE wavzedemo.transaction TO "kevin.soderholm@taranginc.com";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE wavzedemo.transaction TO "jagadeesh.pasupulati@taranginc.com";
GRANT SELECT,INSERT,REFERENCES,TRIGGER,TRUNCATE,UPDATE ON TABLE wavzedemo.transaction TO "wavzedemo@wavzedemodb2";


-- Completed on 2025-12-11 13:54:35

--
-- PostgreSQL database dump complete
--

\unrestrict Jl89qDIhZmnp7prykrbfrHDcMjwMc506AkcykYPKwIu1xXQqACFFqrIWENIG4g1

