--
-- PostgreSQL database dump
-- add trigger functions in separate doc
--

\restrict 4jMFstEAvrFcnFqf87J0ZXT3jUhEWeqPoGYiHAlFBs2W6mMDNSBF07bfffADizh

-- Dumped from database version 17.6
-- Dumped by pg_dump version 18.0

-- Started on 2025-12-11 09:54:27

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
-- TOC entry 257 (class 1259 OID 25614)
-- Name: customer; Type: TABLE; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

CREATE TABLE wavzedemo.customer (
    customer_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    property_id uuid,
    created_ts timestamp with time zone,
    created_by uuid,
    first_name text,
    middle_name text,
    last_name text,
    email text,
    phn1_type character varying(10),
    phn1_nbr numeric(10,0),
    phn2_type character varying(10),
    phn2_nbr numeric(10,0),
    method_pref character varying(20),
    time_zone character varying(20),
    time_window_pref character varying(20),
    language_pref character varying(20),
    language_othr text,
    street_addr1 text,
    street_addr2 text,
    city text,
    state character(2),
    region character varying(20),
    zip_cde character(5),
    country character varying(30),
    birth_date date,
    marital_status character varying(20),
    employer text,
    occupation text,
    annual_income numeric,
    est_credit_range character varying(20),
    modified_ts timestamp with time zone,
    modified_by uuid
);


ALTER TABLE wavzedemo.customer OWNER TO "nikki.stoddard@taranginc.com";

--
-- TOC entry 4413 (class 0 OID 0)
-- Dependencies: 257
-- Name: COLUMN customer.property_id; Type: COMMENT; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

COMMENT ON COLUMN wavzedemo.customer.property_id IS 'primary residence';


--
-- TOC entry 4253 (class 2606 OID 25621)
-- Name: customer customer_pkey; Type: CONSTRAINT; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavzedemo.customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (customer_id);


--
-- TOC entry 4256 (class 2620 OID 25632)
-- Name: customer customer_created_ts; Type: TRIGGER; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

CREATE TRIGGER customer_created_ts BEFORE INSERT ON wavzedemo.customer FOR EACH ROW EXECUTE FUNCTION wavzedemo.set_created_ts();


--
-- TOC entry 4257 (class 2620 OID 26147)
-- Name: customer customer_uuid; Type: TRIGGER; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

CREATE TRIGGER customer_uuid BEFORE INSERT OR UPDATE ON wavzedemo.customer FOR EACH ROW EXECUTE FUNCTION wavzedemo.customer_uuid_dup_check();


--
-- TOC entry 4258 (class 2620 OID 26206)
-- Name: customer track_customer_history; Type: TRIGGER; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

CREATE TRIGGER track_customer_history AFTER INSERT OR DELETE OR UPDATE ON wavzedemo.customer FOR EACH ROW EXECUTE FUNCTION wavzedemo.track_customer_field_changes();


--
-- TOC entry 4254 (class 2606 OID 25622)
-- Name: customer created_by; Type: FK CONSTRAINT; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavzedemo.customer
    ADD CONSTRAINT created_by FOREIGN KEY (created_by) REFERENCES wavzedemo.wavze_user(user_id);


--
-- TOC entry 4255 (class 2606 OID 25627)
-- Name: customer property_id; Type: FK CONSTRAINT; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavzedemo.customer
    ADD CONSTRAINT property_id FOREIGN KEY (property_id) REFERENCES wavzedemo.property(property_id);


--
-- TOC entry 4414 (class 0 OID 0)
-- Dependencies: 257
-- Name: TABLE customer; Type: ACL; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE wavzedemo.customer TO "erik.michaelson@taranginc.com";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE wavzedemo.customer TO "jagadeesh.pasupulati@taranginc.com";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE wavzedemo.customer TO "kevin.soderholm@taranginc.com";
GRANT SELECT,INSERT,REFERENCES,TRIGGER,TRUNCATE,UPDATE ON TABLE wavzedemo.customer TO "wavzedemo@wavzedemodb2";


-- Completed on 2025-12-11 09:54:28

--
-- PostgreSQL database dump complete
--

\unrestrict 4jMFstEAvrFcnFqf87J0ZXT3jUhEWeqPoGYiHAlFBs2W6mMDNSBF07bfffADizh

