--
-- PostgreSQL database dump
--

\restrict IKvArES4xSMGA2LaxzfTJLYjTtgyxwNAiI6Hmez17S0rdGwtXdxmpxOAb3AFJm8

-- Dumped from database version 17.6
-- Dumped by pg_dump version 18.0

-- Started on 2025-12-11 13:55:04

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
-- TOC entry 245 (class 1259 OID 25159)
-- Name: transaction_detail; Type: TABLE; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

CREATE TABLE wavzedemo.transaction_detail (
    transaction_id uuid NOT NULL,
    created_ts timestamp with time zone,
    created_by uuid,
    customer_id uuid,
    co_appl1 uuid,
    co_appl1_type character varying(20),
    co_appl2 uuid,
    co_appl2_type character varying(20),
    purchase_price numeric,
    down_payment numeric,
    loan_amount numeric,
    loan_term_type character varying(10),
    loan_term numeric,
    cash_out numeric,
    draw_amount numeric,
    pmi boolean,
    lien_position numeric(1,0),
    rate_type character varying(20),
    interest_rate numeric(7,4),
    apr numeric(7,4),
    cash_advance numeric,
    credit_limit numeric,
    deposit_amount numeric,
    funding_method character varying(30),
    ownership_type character varying(30),
    modified_ts timestamp with time zone,
    modified_by uuid
);


ALTER TABLE wavzedemo.transaction_detail OWNER TO "nikki.stoddard@taranginc.com";

--
-- TOC entry 4411 (class 0 OID 0)
-- Dependencies: 245
-- Name: TABLE transaction_detail; Type: COMMENT; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

COMMENT ON TABLE wavzedemo.transaction_detail IS 'banking industry product details';


--
-- TOC entry 4252 (class 2606 OID 25163)
-- Name: transaction_detail transaction_detail_pkey; Type: CONSTRAINT; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavzedemo.transaction_detail
    ADD CONSTRAINT transaction_detail_pkey PRIMARY KEY (transaction_id);


--
-- TOC entry 4255 (class 2620 OID 26001)
-- Name: transaction_detail transaction_dtl_created_ts; Type: TRIGGER; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

CREATE TRIGGER transaction_dtl_created_ts BEFORE INSERT ON wavzedemo.transaction_detail FOR EACH ROW EXECUTE FUNCTION wavzedemo.set_created_ts();


--
-- TOC entry 4256 (class 2620 OID 28249)
-- Name: transaction_detail transaction_track_history; Type: TRIGGER; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

CREATE TRIGGER transaction_track_history AFTER INSERT OR DELETE OR UPDATE ON wavzedemo.transaction_detail FOR EACH ROW EXECUTE FUNCTION wavzedemo.track_transaction2_field_changes();


--
-- TOC entry 4253 (class 2606 OID 25976)
-- Name: transaction_detail created_by; Type: FK CONSTRAINT; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavzedemo.transaction_detail
    ADD CONSTRAINT created_by FOREIGN KEY (created_by) REFERENCES wavzedemo.wavze_user(user_id) NOT VALID;


--
-- TOC entry 4254 (class 2606 OID 25981)
-- Name: transaction_detail customer_id; Type: FK CONSTRAINT; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavzedemo.transaction_detail
    ADD CONSTRAINT customer_id FOREIGN KEY (customer_id) REFERENCES wavzedemo.customer(customer_id) NOT VALID;


--
-- TOC entry 4412 (class 0 OID 0)
-- Dependencies: 245
-- Name: TABLE transaction_detail; Type: ACL; Schema: wavzedemo; Owner: nikki.stoddard@taranginc.com
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE wavzedemo.transaction_detail TO "erik.michaelson@taranginc.com";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE wavzedemo.transaction_detail TO "jagadeesh.pasupulati@taranginc.com";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE wavzedemo.transaction_detail TO "kevin.soderholm@taranginc.com";
GRANT SELECT,INSERT,REFERENCES,TRIGGER,TRUNCATE,UPDATE ON TABLE wavzedemo.transaction_detail TO "wavzedemo@wavzedemodb2";


-- Completed on 2025-12-11 13:55:05

--
-- PostgreSQL database dump complete
--

\unrestrict IKvArES4xSMGA2LaxzfTJLYjTtgyxwNAiI6Hmez17S0rdGwtXdxmpxOAb3AFJm8

