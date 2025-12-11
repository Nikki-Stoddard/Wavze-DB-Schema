--
-- PostgreSQL database dump
--

\restrict 18RRENDUKFW6eGBCtnVWkqxSYgIPq6iru3H2TMn8ekm7Uafr8r6udeLL43ATi2Q

-- Dumped from database version 17.6
-- Dumped by pg_dump version 18.0

-- Started on 2025-12-11 13:51:19

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
-- TOC entry 235 (class 1259 OID 24890)
-- Name: product; Type: TABLE; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

CREATE TABLE wavzedemo.product (
    product_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    product_category character varying(30) NOT NULL,
    product_name character varying(50) NOT NULL,
    created_ts timestamp with time zone,
    created_by uuid,
    product_active boolean DEFAULT true,
    modified_ts timestamp with time zone,
    modified_by uuid
);


ALTER TABLE wavzedemo.product OWNER TO "nikki.stoddard@taranginc.com";

--
-- TOC entry 4254 (class 2606 OID 25117)
-- Name: product product_pkey; Type: CONSTRAINT; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavzedemo.product
    ADD CONSTRAINT product_pkey PRIMARY KEY (product_id);


--
-- TOC entry 4255 (class 2620 OID 28209)
-- Name: product product_created_ts; Type: TRIGGER; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

CREATE TRIGGER product_created_ts BEFORE INSERT ON wavzedemo.product FOR EACH ROW EXECUTE FUNCTION wavzedemo.set_created_ts();


--
-- TOC entry 4256 (class 2620 OID 28243)
-- Name: product track_product_active; Type: TRIGGER; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

CREATE TRIGGER track_product_active AFTER UPDATE ON wavzedemo.product FOR EACH ROW EXECUTE FUNCTION wavzedemo.track_product_field_changes();


--
-- TOC entry 4411 (class 0 OID 0)
-- Dependencies: 235
-- Name: TABLE product; Type: ACL; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE wavzedemo.product TO "erik.michaelson@taranginc.com";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE wavzedemo.product TO "kevin.soderholm@taranginc.com";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE wavzedemo.product TO "jagadeesh.pasupulati@taranginc.com";
GRANT SELECT,INSERT,REFERENCES,TRIGGER,TRUNCATE,UPDATE ON TABLE wavzedemo.product TO "wavzedemo@wavzedemodb2";


-- Completed on 2025-12-11 13:51:20

--
-- PostgreSQL database dump complete
--

\unrestrict 18RRENDUKFW6eGBCtnVWkqxSYgIPq6iru3H2TMn8ekm7Uafr8r6udeLL43ATi2Q

