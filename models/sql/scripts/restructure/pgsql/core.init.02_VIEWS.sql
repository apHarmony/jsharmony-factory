SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = {schema}, pg_catalog;

--
-- Name: v_doc_ext; Type: VIEW; Schema: {schema}; Owner: postgres
--

CREATE VIEW v_doc_ext AS
 SELECT doc__tbl.doc_id,
    doc__tbl.doc_scope,
    doc__tbl.doc_scope_id,
    doc__tbl.cust_id,
    doc__tbl.item_id,
    doc__tbl.doc_sts,
    doc__tbl.doc_ctgr,
    doc__tbl.doc_desc,
    doc__tbl.doc_ext,
    doc__tbl.doc_size,
    (('D'::text || ((doc__tbl.doc_id)::character varying)::text) || (COALESCE(doc__tbl.doc_ext, ''::character varying))::text) AS doc_filename,
    doc__tbl.doc_etstmp,
    doc__tbl.doc_euser,
    my_db_user_fmt((doc__tbl.doc_euser)::text) AS doc_euser_fmt,
    doc__tbl.doc_mtstmp,
    doc__tbl.doc_muser,
    my_db_user_fmt((doc__tbl.doc_muser)::text) AS doc_muser_fmt,
    doc__tbl.doc_uptstmp,
    doc__tbl.doc_upuser,
    my_db_user_fmt((doc__tbl.doc_upuser)::text) AS doc_upuser_fmt,
    doc__tbl.doc_snotes,
    NULL::text AS title_head,
    NULL::text AS title_detail,
    doc__tbl.doc_scope AS doc_datalock,
    {schema}.get_cust_name(doc__tbl.cust_id)::text AS cust_name,
    {schema}.get_cust_name_ext(doc__tbl.cust_id)::text AS cust_name_ext,
    {schema}.get_item_name(doc__tbl.item_id)::text AS item_name
   FROM doc__tbl;


ALTER TABLE v_doc_ext OWNER TO postgres;

--
-- Name: v_doc_filename; Type: VIEW; Schema: {schema}; Owner: postgres
--

CREATE VIEW v_doc_filename AS
 SELECT doc__tbl.doc_id,
    doc__tbl.doc_scope,
    doc__tbl.doc_scope_id,
    doc__tbl.cust_id,
    doc__tbl.item_id,
    doc__tbl.doc_sts,
    doc__tbl.doc_ctgr,
    doc__tbl.doc_desc,
    doc__tbl.doc_ext,
    doc__tbl.doc_size,
    doc__tbl.doc_etstmp,
    doc__tbl.doc_euser,
    doc__tbl.doc_mtstmp,
    doc__tbl.doc_muser,
    doc__tbl.doc_uptstmp,
    doc__tbl.doc_upuser,
    doc__tbl.doc_sync_tstmp,
    doc__tbl.doc_snotes,
    doc__tbl.doc_sync_id,
    (('D'::text || ((doc__tbl.doc_id)::character varying)::text) || (COALESCE(doc__tbl.doc_ext, ''::character varying))::text) AS doc_filename
   FROM doc__tbl;


ALTER TABLE v_doc_filename OWNER TO postgres;

--
-- Name: v_doc; Type: VIEW; Schema: {schema}; Owner: postgres
--

CREATE VIEW v_doc AS
 SELECT doc__tbl.doc_id,
    doc__tbl.doc_scope,
    doc__tbl.doc_scope_id,
    doc__tbl.cust_id,
    doc__tbl.item_id,
    doc__tbl.doc_sts,
    doc__tbl.doc_ctgr,
    gdd.code_txt AS doc_ctgr_txt,
    doc__tbl.doc_desc,
    doc__tbl.doc_ext,
    doc__tbl.doc_size,
    (('D'::text || ((doc__tbl.doc_id)::character varying)::text) || (COALESCE(doc__tbl.doc_ext, ''::character varying))::text) AS doc_filename,
    doc__tbl.doc_etstmp,
    doc__tbl.doc_euser,
    my_db_user_fmt((doc__tbl.doc_euser)::text) AS doc_euser_fmt,
    doc__tbl.doc_mtstmp,
    doc__tbl.doc_muser,
    my_db_user_fmt((doc__tbl.doc_muser)::text) AS doc_muser_fmt,
    doc__tbl.doc_uptstmp,
    doc__tbl.doc_upuser,
    my_db_user_fmt((doc__tbl.doc_upuser)::text) AS doc_upuser_fmt,
    doc__tbl.doc_snotes,
    NULL::text AS title_head,
    NULL::text AS title_detail
   FROM (doc__tbl
     LEFT JOIN code2_doc_scope_doc_ctgr gdd ON ((((gdd.code_val1)::text = (doc__tbl.doc_scope)::text) AND ((gdd.code_val2)::text = (doc__tbl.doc_ctgr)::text))));


ALTER TABLE v_doc OWNER TO postgres;


--
-- Name: v_note_ext; Type: VIEW; Schema: {schema}; Owner: postgres
--

CREATE VIEW v_note_ext AS
 SELECT note__tbl.note_id,
    note__tbl.note_scope,
    note__tbl.note_scope_id,
    note__tbl.note_sts,
    note__tbl.cust_id,
    note__tbl.item_id,
    note__tbl.note_type,
    note__tbl.note_body,
    note__tbl.note_etstmp,
    note__tbl.note_euser,
    my_db_user_fmt((note__tbl.note_euser)::text) AS note_euser_fmt,
    note__tbl.note_mtstmp,
    note__tbl.note_muser,
    my_db_user_fmt((note__tbl.note_muser)::text) AS note_muser_fmt,
    note__tbl.note_snotes,
    NULL::text AS title_head,
    NULL::text AS title_detail,
    {schema}.get_cust_name(note__tbl.cust_id)::text AS cust_name,
    {schema}.get_cust_name_ext(note__tbl.cust_id)::text AS cust_name_ext,
    {schema}.get_item_name(note__tbl.item_id)::text AS item_name
   FROM note__tbl;


ALTER TABLE v_note_ext OWNER TO postgres;

--
-- Name: v_note; Type: VIEW; Schema: {schema}; Owner: postgres
--

CREATE VIEW v_note AS
 SELECT note__tbl.note_id,
    note__tbl.note_scope,
    note__tbl.note_scope_id,
    note__tbl.note_sts,
    note__tbl.cust_id,
    note__tbl.item_id,
    note__tbl.note_type,
    note__tbl.note_body,
    my_to_date(note__tbl.note_etstmp) AS note_dt,
    note__tbl.note_etstmp,
    my_mmddyyhhmi(note__tbl.note_etstmp) AS note_etstmp_fmt,
    note__tbl.note_euser,
    my_db_user_fmt((note__tbl.note_euser)::text) AS note_euser_fmt,
    note__tbl.note_mtstmp,
    my_mmddyyhhmi(note__tbl.note_mtstmp) AS note_mtstmp_fmt,
    note__tbl.note_muser,
    my_db_user_fmt((note__tbl.note_muser)::text) AS note_muser_fmt,
    note__tbl.note_snotes,
    NULL::text AS title_head,
    NULL::text AS title_detail,
    {schema}.get_cust_name(note__tbl.cust_id)::text AS cust_name,
    {schema}.get_cust_name_ext(note__tbl.cust_id)::text AS cust_name_ext,
    {schema}.get_item_name(note__tbl.item_id)::text AS item_name
   FROM note__tbl;


ALTER TABLE v_note OWNER TO postgres;



--
-- Name: v_doc_ext; Type: ACL; Schema: {schema}; Owner: postgres
--

REVOKE ALL ON TABLE v_doc_ext FROM PUBLIC;
REVOKE ALL ON TABLE v_doc_ext FROM postgres;
GRANT ALL ON TABLE v_doc_ext TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_doc_ext TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: v_doc_filename; Type: ACL; Schema: {schema}; Owner: postgres
--

REVOKE ALL ON TABLE v_doc_filename FROM PUBLIC;
REVOKE ALL ON TABLE v_doc_filename FROM postgres;
GRANT ALL ON TABLE v_doc_filename TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_doc_filename TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: v_doc; Type: ACL; Schema: {schema}; Owner: postgres
--

REVOKE ALL ON TABLE v_doc FROM PUBLIC;
REVOKE ALL ON TABLE v_doc FROM postgres;
GRANT ALL ON TABLE v_doc TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_doc TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;



--
-- Name: v_note_ext; Type: ACL; Schema: {schema}; Owner: postgres
--

REVOKE ALL ON TABLE v_note_ext FROM PUBLIC;
REVOKE ALL ON TABLE v_note_ext FROM postgres;
GRANT ALL ON TABLE v_note_ext TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_note_ext TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: v_note; Type: ACL; Schema: {schema}; Owner: postgres
--

REVOKE ALL ON TABLE v_note FROM PUBLIC;
REVOKE ALL ON TABLE v_note FROM postgres;
GRANT ALL ON TABLE v_note TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_note TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
