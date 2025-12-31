-- Table: wavze1.wavze_user

-- DROP TABLE IF EXISTS wavze1.wavze_user;

CREATE TABLE wavze1.wavze_user (
    user_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    username character varying(10),
    preferred_name text,
    first_name text,
    middle_name text,
    last_name text,
    email text,
    phn1_type character varying(10),
    phn1_nbr numeric(10,0),
    phn2_type character varying(10),
    phn2_nbr numeric(10,0),
    time_zone character varying(20),
    company text,
    street_addr1 text,
    street_addr2 text,
    city text,
    state character(2),
    zip_cde character(5),
    country character varying(30),
    department text,
    job_title text,
    nmls_id character varying(12),
    othr_id_type text,
    othr_id character varying(20),
    signature1 text,
    signature2 text
);


ALTER TABLE wavze1.wavze_user OWNER TO "nikki.stoddard@taranginc.com";

--
-- TOC entry 4253 (class 2606 OID 25105)
-- Name: wavze_user wavze_user_pkey; Type: CONSTRAINT; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

ALTER TABLE ONLY wavze1.wavze_user
    ADD CONSTRAINT wavze_user_pkey PRIMARY KEY (user_id);


--
-- TOC entry 4408 (class 0 OID 0)
-- Dependencies: 244
-- Name: TABLE wavze_user; Type: ACL; Schema: wavze1; Owner: nikki.stoddard@taranginc.com
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE wavze1.wavze_user TO "erik.michaelson@taranginc.com";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE wavze1.wavze_user TO "jagadeesh.pasupulati@taranginc.com";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE wavze1.wavze_user TO "kevin.soderholm@taranginc.com";
GRANT SELECT,INSERT,REFERENCES,TRIGGER,TRUNCATE,UPDATE ON TABLE wavze1.wavze_user TO "wavze1@wavze1db2";

