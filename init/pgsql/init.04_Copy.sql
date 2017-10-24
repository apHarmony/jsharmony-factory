--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.5
-- Dumped by pg_dump version 9.5.1

-- Started on 2017-10-24 16:36:35

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

SET search_path = jsharmony, pg_catalog;

--
-- TOC entry 2871 (class 0 OID 45574)
-- Dependencies: 249
-- Data for Name: ucod_ahc; Type: TABLE DATA; Schema: jsharmony; Owner: postgres
--

INSERT INTO ucod_ahc (ucod_id, codseq, codeval, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (4, 1, 'ACTIVE', 'Active', NULL, NULL, NULL, '2017-05-07 11:33:38.277997', 'Upostgres', '2017-05-07 11:33:38.277997', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod_ahc (ucod_id, codseq, codeval, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (5, 3, 'CLOSED', 'Closed', NULL, NULL, NULL, '2017-05-07 11:33:38.277997', 'Upostgres', '2017-05-07 11:33:38.277997', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod_ahc (ucod_id, codseq, codeval, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (6, 2, 'HOLD', 'Hold', NULL, NULL, NULL, '2017-05-07 11:33:38.277997', 'Upostgres', '2017-05-07 11:33:38.277997', 'Upostgres', NULL, NULL, NULL);


--
-- TOC entry 2839 (class 0 OID 45250)
-- Dependencies: 190
-- Data for Name: cr; Type: TABLE DATA; Schema: jsharmony; Owner: postgres
--

INSERT INTO cr (cr_id, cr_seq, cr_sts, cr_name, cr_desc, cr_snotes, cr_code, cr_attrib) VALUES (1, 1, 'ACTIVE', 'CSYSADMIN', 'Administrator', NULL, NULL, NULL);
INSERT INTO cr (cr_id, cr_seq, cr_sts, cr_name, cr_desc, cr_snotes, cr_code, cr_attrib) VALUES (2, 2, 'ACTIVE', 'CX_B', 'Browse', NULL, NULL, NULL);
INSERT INTO cr (cr_id, cr_seq, cr_sts, cr_name, cr_desc, cr_snotes, cr_code, cr_attrib) VALUES (3, 3, 'ACTIVE', 'CX_X', 'Entry / Update', NULL, NULL, NULL);
INSERT INTO cr (cr_id, cr_seq, cr_sts, cr_name, cr_desc, cr_snotes, cr_code, cr_attrib) VALUES (10, 1, 'ACTIVE', 'CUSER', 'Client User', NULL, NULL, NULL);
INSERT INTO cr (cr_id, cr_seq, cr_sts, cr_name, cr_desc, cr_snotes, cr_code, cr_attrib) VALUES (5, 0, 'ACTIVE', 'C*', 'All Users', NULL, NULL, NULL);


--
-- TOC entry 2891 (class 0 OID 0)
-- Dependencies: 191
-- Name: cr_cr_id_seq; Type: SEQUENCE SET; Schema: jsharmony; Owner: postgres
--

SELECT pg_catalog.setval('cr_cr_id_seq', 10, true);


--
-- TOC entry 2860 (class 0 OID 45460)
-- Dependencies: 231
-- Data for Name: sm; Type: TABLE DATA; Schema: jsharmony; Owner: postgres
--

INSERT INTO sm (sm_id_auto, sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_snotes, sm_subcmd) VALUES (23, 'S', 1785, 'ACTIVE', 170, 'ADMINISTRATION_TEXTMAINTENANCE', NULL, 'Text Maint', NULL, NULL, 'TXTL', NULL, NULL, NULL);
INSERT INTO sm (sm_id_auto, sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_snotes, sm_subcmd) VALUES (21, 'S', 1783, 'ACTIVE', 170, 'ADMINISTRATION_CODETABLES', NULL, '1D Code Tables', NULL, NULL, 'GCOD_HL', NULL, NULL, NULL);
INSERT INTO sm (sm_id_auto, sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_snotes, sm_subcmd) VALUES (22, 'S', 1784, 'ACTIVE', 170, 'ADMINISTRATION_CODE2TABLES', NULL, '2D Code Tables', NULL, NULL, 'GCOD2_HL', NULL, NULL, NULL);
INSERT INTO sm (sm_id_auto, sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_snotes, sm_subcmd) VALUES (59, 'S', 1781, 'ACTIVE', 170, 'ADMINISTRATION_PPARAMETERS', NULL, 'User Settings', NULL, NULL, 'PPPL', NULL, NULL, NULL);
INSERT INTO sm (sm_id_auto, sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_snotes, sm_subcmd) VALUES (24, 'S', 1782, 'ACTIVE', 170, 'ADMINISTRATION_GPARAMETERS', NULL, 'System Settings', NULL, NULL, 'GPPL', NULL, NULL, NULL);
INSERT INTO sm (sm_id_auto, sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_snotes, sm_subcmd) VALUES (48, 'S', 14, 'ACTIVE', 10, 'DEV_X_GPPL', 22, 'System Settings', NULL, NULL, 'X_GPPL', NULL, NULL, NULL);
INSERT INTO sm (sm_id_auto, sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_snotes, sm_subcmd) VALUES (47, 'S', 13, 'ACTIVE', 10, 'DEV_X_PPDL', 21, 'Settings Definitions', NULL, NULL, 'X_PPDL', NULL, NULL, NULL);
INSERT INTO sm (sm_id_auto, sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_snotes, sm_subcmd) VALUES (62, 'S', 160, 'ACTIVE', 1, 'REPORTS', 2, 'Reports', NULL, NULL, 'REPORTS', NULL, NULL, NULL);
INSERT INTO sm (sm_id_auto, sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_snotes, sm_subcmd) VALUES (8, 'S', 170, 'ACTIVE', 1, 'ADMINISTRATION', 3, 'Administration', NULL, NULL, 'ADMIN_OVERVIEW', NULL, NULL, NULL);
INSERT INTO sm (sm_id_auto, sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_snotes, sm_subcmd) VALUES (44, 'S', 10, 'ACTIVE', 1, 'DEV', 4, 'Developer', NULL, NULL, 'DEV_OVERVIEW', NULL, NULL, NULL);
INSERT INTO sm (sm_id_auto, sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_snotes, sm_subcmd) VALUES (3, 'C', 2, 'ACTIVE', NULL, 'CLIENT', NULL, 'Customer', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO sm (sm_id_auto, sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_snotes, sm_subcmd) VALUES (10, 'C', 200, 'ACTIVE', 2, 'C_DASHBOARD', NULL, 'Dashboard', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO sm (sm_id_auto, sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_snotes, sm_subcmd) VALUES (13, 'C', 270, 'ACTIVE', 2, 'C_ADMINISTRATION', NULL, 'Administration', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO sm (sm_id_auto, sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_snotes, sm_subcmd) VALUES (35, 'C', 2700, 'ACTIVE', 270, 'C_ADMINISTRATION_USERS', NULL, 'Cust Users', NULL, NULL, 'CPEL_CLIENT', NULL, NULL, NULL);
INSERT INTO sm (sm_id_auto, sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_snotes, sm_subcmd) VALUES (36, 'C', 2701, 'ACTIVE', 270, 'C_ADMINISTRATION_CONTACTS', NULL, 'Contacts', NULL, NULL, 'CTL_C_CLIENT', NULL, NULL, NULL);
INSERT INTO sm (sm_id_auto, sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_snotes, sm_subcmd) VALUES (2, 'S', 1, 'ACTIVE', NULL, 'ADMIN', NULL, 'Admin', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO sm (sm_id_auto, sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_snotes, sm_subcmd) VALUES (57, 'S', 1795, 'ACTIVE', 170, 'ADMINISTRATION_LOG', NULL, 'Logs', NULL, NULL, 'LOG', NULL, NULL, NULL);
INSERT INTO sm (sm_id_auto, sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_snotes, sm_subcmd) VALUES (58, 'S', 1796, 'ACTIVE', 170, 'ADMINISTRATION_RESTART_SYSTEM', NULL, 'Restart System', NULL, NULL, 'RESTART_SYSTEM', NULL, NULL, NULL);
INSERT INTO sm (sm_id_auto, sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_snotes, sm_subcmd) VALUES (61, 'S', 3, 'ACTIVE', 1, 'DASHBOARD', 1, 'Dashboard', NULL, NULL, 'DASHBOARD', NULL, NULL, NULL);
INSERT INTO sm (sm_id_auto, sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_snotes, sm_subcmd) VALUES (46, 'S', 12, 'ACTIVE', 10, 'DEV_X_SML', 11, 'Menu Items', NULL, NULL, 'X_SMLW', NULL, NULL, NULL);
INSERT INTO sm (sm_id_auto, sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_snotes, sm_subcmd) VALUES (45, 'S', 11, 'ACTIVE', 10, 'DEV_X_SRL', 12, 'User Roles', NULL, NULL, 'X_SRL', NULL, NULL, NULL);
INSERT INTO sm (sm_id_auto, sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_snotes, sm_subcmd) VALUES (54, 'S', 20, 'ACTIVE', 10, 'DEV_X_CRL', 13, 'Client User Roles', NULL, NULL, 'X_CRL', NULL, NULL, NULL);
INSERT INTO sm (sm_id_auto, sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_snotes, sm_subcmd) VALUES (55, 'S', 21, 'ACTIVE', 10, 'DEV_X_TXTL', 41, 'Text Maint', NULL, NULL, 'X_TXTL', NULL, NULL, NULL);
INSERT INTO sm (sm_id_auto, sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_snotes, sm_subcmd) VALUES (56, 'S', 22, 'ACTIVE', 10, 'DEV_X_HPL', 42, 'Help Panels', NULL, NULL, 'X_HPL', NULL, NULL, NULL);
INSERT INTO sm (sm_id_auto, sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_snotes, sm_subcmd) VALUES (25, 'S', 1786, 'ACTIVE', 170, 'ADMINISTRATION_HELPMAINTENANCE', NULL, 'Help Maint', NULL, NULL, 'HL', NULL, NULL, NULL);
INSERT INTO sm (sm_id_auto, sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_snotes, sm_subcmd) VALUES (52, 'S', 18, 'ACTIVE', 10, 'DEV_X_UCOD_HL', 33, 'System 1D Codes', NULL, NULL, 'X_UCOD_HL', NULL, NULL, NULL);
INSERT INTO sm (sm_id_auto, sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_snotes, sm_subcmd) VALUES (53, 'S', 19, 'ACTIVE', 10, 'DEV_X_UCOD2_HL', 34, 'System 2D Codes', NULL, NULL, 'X_UCOD2_HL', NULL, NULL, NULL);
INSERT INTO sm (sm_id_auto, sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_snotes, sm_subcmd) VALUES (19, 'S', 1700, 'ACTIVE', 170, 'ADMINISTRATION_USERS', NULL, 'System Users', NULL, NULL, 'PEL', NULL, NULL, NULL);
INSERT INTO sm (sm_id_auto, sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_snotes, sm_subcmd) VALUES (20, 'S', 1787, 'ACTIVE', 170, 'ADMINISTRATION_AUDITTRAIL', NULL, 'Audit Trail', NULL, NULL, 'AUDL', NULL, NULL, NULL);
INSERT INTO sm (sm_id_auto, sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_snotes, sm_subcmd) VALUES (49, 'S', 15, 'ACTIVE', 10, 'DEV_X_XPPL', 23, 'Developer Settings', NULL, NULL, 'X_XPPL', NULL, NULL, NULL);
INSERT INTO sm (sm_id_auto, sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_snotes, sm_subcmd) VALUES (50, 'S', 16, 'ACTIVE', 10, 'DEV_X_GCOD_HL', 31, 'Admin 1D Codes', NULL, NULL, 'X_GCOD_HL', NULL, NULL, NULL);
INSERT INTO sm (sm_id_auto, sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_snotes, sm_subcmd) VALUES (51, 'S', 17, 'ACTIVE', 10, 'DEV_X_GCOD2_HL', 32, 'Admin 2D Codes', NULL, NULL, 'X_GCOD2_HL', NULL, NULL, NULL);
INSERT INTO sm (sm_id_auto, sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_snotes, sm_subcmd) VALUES (63, 'S', 1601, 'ACTIVE', 160, 'REPORTS_USERS', NULL, 'User Listing', NULL, NULL, '_report/RPE', NULL, NULL, NULL);


--
-- TOC entry 2841 (class 0 OID 45259)
-- Dependencies: 192
-- Data for Name: crm; Type: TABLE DATA; Schema: jsharmony; Owner: postgres
--

INSERT INTO crm (sm_id, crm_snotes, crm_id, cr_name) VALUES (200, NULL, 22, 'CX_B');
INSERT INTO crm (sm_id, crm_snotes, crm_id, cr_name) VALUES (270, NULL, 24, 'CSYSADMIN');
INSERT INTO crm (sm_id, crm_snotes, crm_id, cr_name) VALUES (2700, NULL, 26, 'CSYSADMIN');
INSERT INTO crm (sm_id, crm_snotes, crm_id, cr_name) VALUES (2701, NULL, 27, 'CSYSADMIN');
INSERT INTO crm (sm_id, crm_snotes, crm_id, cr_name) VALUES (200, NULL, 35, 'CX_X');
INSERT INTO crm (sm_id, crm_snotes, crm_id, cr_name) VALUES (200, NULL, 61, 'CUSER');


--
-- TOC entry 2892 (class 0 OID 0)
-- Dependencies: 193
-- Name: crm_crm_id_seq; Type: SEQUENCE SET; Schema: jsharmony; Owner: postgres
--

SELECT pg_catalog.setval('crm_crm_id_seq', 98, true);


--
-- TOC entry 2843 (class 0 OID 45281)
-- Dependencies: 196
-- Data for Name: dual; Type: TABLE DATA; Schema: jsharmony; Owner: postgres
--

INSERT INTO dual (dummy, dual_ident, dual_bigint, dual_varchar50) VALUES ('X', 1, NULL, NULL);


--
-- TOC entry 2893 (class 0 OID 0)
-- Dependencies: 197
-- Name: dual_dual_ident_seq; Type: SEQUENCE SET; Schema: jsharmony; Owner: postgres
--

SELECT pg_catalog.setval('dual_dual_ident_seq', 1, true);


--
-- TOC entry 2845 (class 0 OID 45286)
-- Dependencies: 198
-- Data for Name: gcod2_h; Type: TABLE DATA; Schema: jsharmony; Owner: postgres
--

INSERT INTO gcod2_h (codename, codemean, codecodemean, cod_h_etstmp, cod_h_eu, cod_h_mtstmp, cod_h_mu, cod_snotes, codeattribmean, codeschema) VALUES ('d_scope_d_ctgr', 'Scope - Documents', NULL, '2017-06-25 17:05:26.57816', 'Upostgres', '2017-06-25 17:05:26.57816', 'Upostgres', NULL, NULL, 'jsharmony');


--
-- TOC entry 2846 (class 0 OID 45296)
-- Dependencies: 199
-- Data for Name: gcod_h; Type: TABLE DATA; Schema: jsharmony; Owner: postgres
--



--
-- TOC entry 2876 (class 0 OID 45628)
-- Dependencies: 254
-- Data for Name: ucod_ppd_type; Type: TABLE DATA; Schema: jsharmony; Owner: postgres
--

INSERT INTO ucod_ppd_type (ucod_id, codseq, codeval, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (10, NULL, 'C', 'Character', NULL, NULL, NULL, '2017-05-07 11:35:39.061553', 'Upostgres', '2017-05-07 11:35:39.061553', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod_ppd_type (ucod_id, codseq, codeval, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (11, NULL, 'N', 'Number', NULL, NULL, NULL, '2017-05-07 11:35:39.061553', 'Upostgres', '2017-05-07 11:35:39.061553', 'Upostgres', NULL, NULL, NULL);


--
-- TOC entry 2854 (class 0 OID 45370)
-- Dependencies: 211
-- Data for Name: ppd; Type: TABLE DATA; Schema: jsharmony; Owner: postgres
--

INSERT INTO ppd (ppd_id, ppd_process, ppd_attrib, ppd_desc, ppd_type, codename, ppd_etstmp, ppd_eu, ppd_mtstmp, ppd_mu, ppd_snotes, ppd_gpp, ppd_ppp, ppd_xpp) VALUES (1, 'EMAIL', 'NOTIF_ADMIN', 'Notifications Email - Administrative', 'C', NULL, '2017-06-18 17:14:20.453481', 'Upostgres', '2017-10-09 13:41:13.745435', 'Upostgres', NULL, true, false, false);
INSERT INTO ppd (ppd_id, ppd_process, ppd_attrib, ppd_desc, ppd_type, codename, ppd_etstmp, ppd_eu, ppd_mtstmp, ppd_mu, ppd_snotes, ppd_gpp, ppd_ppp, ppd_xpp) VALUES (17, 'USERS', 'HASH_SEED_S', 'Hash Seed System Users', 'C', NULL, '2017-06-18 17:14:20.484504', 'Upostgres', '2017-10-09 13:49:17.813327', 'Upostgres', NULL, false, false, true);
INSERT INTO ppd (ppd_id, ppd_process, ppd_attrib, ppd_desc, ppd_type, codename, ppd_etstmp, ppd_eu, ppd_mtstmp, ppd_mu, ppd_snotes, ppd_gpp, ppd_ppp, ppd_xpp) VALUES (5, 'HOUSE', 'ADDR', 'HOUSE Address', 'C', NULL, '2017-06-18 17:14:20.461487', 'Upostgres', '2017-10-09 13:41:26.073551', 'Upostgres', NULL, true, false, false);
INSERT INTO ppd (ppd_id, ppd_process, ppd_attrib, ppd_desc, ppd_type, codename, ppd_etstmp, ppd_eu, ppd_mtstmp, ppd_mu, ppd_snotes, ppd_gpp, ppd_ppp, ppd_xpp) VALUES (6, 'HOUSE', 'BPHONE', 'HOUSE Business Phone', 'C', NULL, '2017-06-18 17:14:20.430415', 'Upostgres', '2017-10-09 13:41:28.289216', 'Upostgres', NULL, true, false, false);
INSERT INTO ppd (ppd_id, ppd_process, ppd_attrib, ppd_desc, ppd_type, codename, ppd_etstmp, ppd_eu, ppd_mtstmp, ppd_mu, ppd_snotes, ppd_gpp, ppd_ppp, ppd_xpp) VALUES (7, 'HOUSE', 'CITY', 'HOUSE City', 'C', NULL, '2017-06-18 17:14:20.366705', 'Upostgres', '2017-10-09 13:41:30.481529', 'Upostgres', NULL, true, false, false);
INSERT INTO ppd (ppd_id, ppd_process, ppd_attrib, ppd_desc, ppd_type, codename, ppd_etstmp, ppd_eu, ppd_mtstmp, ppd_mu, ppd_snotes, ppd_gpp, ppd_ppp, ppd_xpp) VALUES (8, 'HOUSE', 'CONTACT', 'HOUSE Contact', 'C', NULL, '2017-06-18 17:14:20.422437', 'Upostgres', '2017-10-09 13:41:32.536936', 'Upostgres', NULL, true, false, false);
INSERT INTO ppd (ppd_id, ppd_process, ppd_attrib, ppd_desc, ppd_type, codename, ppd_etstmp, ppd_eu, ppd_mtstmp, ppd_mu, ppd_snotes, ppd_gpp, ppd_ppp, ppd_xpp) VALUES (9, 'HOUSE', 'EMAIL', 'HOUSE Email', 'C', NULL, '2017-06-18 17:14:20.374711', 'Upostgres', '2017-10-09 13:41:34.760944', 'Upostgres', NULL, true, false, false);
INSERT INTO ppd (ppd_id, ppd_process, ppd_attrib, ppd_desc, ppd_type, codename, ppd_etstmp, ppd_eu, ppd_mtstmp, ppd_mu, ppd_snotes, ppd_gpp, ppd_ppp, ppd_xpp) VALUES (10, 'HOUSE', 'FAX', 'HOUSE Fax', 'C', NULL, '2017-06-18 17:14:20.414061', 'Upostgres', '2017-10-09 13:41:55.976851', 'Upostgres', NULL, true, false, false);
INSERT INTO ppd (ppd_id, ppd_process, ppd_attrib, ppd_desc, ppd_type, codename, ppd_etstmp, ppd_eu, ppd_mtstmp, ppd_mu, ppd_snotes, ppd_gpp, ppd_ppp, ppd_xpp) VALUES (43, 'SQL', 'DSCOPE_DCTGR', 'Code table - Document Types by Scope', 'C', NULL, '2017-06-18 17:14:20.500515', 'Upostgres', '2017-10-09 13:49:23.301571', 'Upostgres', NULL, false, false, true);
INSERT INTO ppd (ppd_id, ppd_process, ppd_attrib, ppd_desc, ppd_type, codename, ppd_etstmp, ppd_eu, ppd_mtstmp, ppd_mu, ppd_snotes, ppd_gpp, ppd_ppp, ppd_xpp) VALUES (44, 'SQL', 'GETCID', 'SQL Function GET_C_ID', 'C', NULL, '2017-06-18 17:14:20.50852', 'Upostgres', '2017-10-09 13:49:25.004825', 'Upostgres', NULL, false, false, true);
INSERT INTO ppd (ppd_id, ppd_process, ppd_attrib, ppd_desc, ppd_type, codename, ppd_etstmp, ppd_eu, ppd_mtstmp, ppd_mu, ppd_snotes, ppd_gpp, ppd_ppp, ppd_xpp) VALUES (45, 'SQL', 'GETEID', 'SQL Function GET_E_ID', 'C', NULL, '2017-06-18 17:14:20.516526', 'Upostgres', '2017-10-09 13:49:28.061435', 'Upostgres', NULL, false, false, true);
INSERT INTO ppd (ppd_id, ppd_process, ppd_attrib, ppd_desc, ppd_type, codename, ppd_etstmp, ppd_eu, ppd_mtstmp, ppd_mu, ppd_snotes, ppd_gpp, ppd_ppp, ppd_xpp) VALUES (13, 'HOUSE', 'ZIP', 'HOUSE ZIP', 'C', NULL, '2017-06-18 17:14:20.39805', 'Upostgres', '2017-10-09 13:42:44.904335', 'Upostgres', NULL, true, false, false);
INSERT INTO ppd (ppd_id, ppd_process, ppd_attrib, ppd_desc, ppd_type, codename, ppd_etstmp, ppd_eu, ppd_mtstmp, ppd_mu, ppd_snotes, ppd_gpp, ppd_ppp, ppd_xpp) VALUES (12, 'HOUSE', 'STATE', 'HOUSE State', 'C', NULL, '2017-06-18 17:14:20.406056', 'Upostgres', '2017-10-09 13:42:47.344881', 'Upostgres', NULL, true, false, false);
INSERT INTO ppd (ppd_id, ppd_process, ppd_attrib, ppd_desc, ppd_type, codename, ppd_etstmp, ppd_eu, ppd_mtstmp, ppd_mu, ppd_snotes, ppd_gpp, ppd_ppp, ppd_xpp) VALUES (11, 'HOUSE', 'NAME', 'HOUSE Name', 'C', NULL, '2017-06-18 17:14:20.381716', 'Upostgres', '2017-10-09 13:42:49.664742', 'Upostgres', NULL, true, false, false);
INSERT INTO ppd (ppd_id, ppd_process, ppd_attrib, ppd_desc, ppd_type, codename, ppd_etstmp, ppd_eu, ppd_mtstmp, ppd_mu, ppd_snotes, ppd_gpp, ppd_ppp, ppd_xpp) VALUES (18, 'DEVICEURL', 'PRINTBAR', 'Device URL - Bar Code Printer', 'C', NULL, '2017-06-18 17:14:20.492486', 'Upostgres', '2017-10-09 13:43:19.464581', 'Upostgres', NULL, true, true, false);
INSERT INTO ppd (ppd_id, ppd_process, ppd_attrib, ppd_desc, ppd_type, codename, ppd_etstmp, ppd_eu, ppd_mtstmp, ppd_mu, ppd_snotes, ppd_gpp, ppd_ppp, ppd_xpp) VALUES (20, 'DEVICEURL', 'SCAN', 'Device URL - Document Scanner', 'C', NULL, '2017-06-18 17:14:20.476497', 'Upostgres', '2017-10-09 13:43:24.88003', 'Upostgres', NULL, true, true, false);
INSERT INTO ppd (ppd_id, ppd_process, ppd_attrib, ppd_desc, ppd_type, codename, ppd_etstmp, ppd_eu, ppd_mtstmp, ppd_mu, ppd_snotes, ppd_gpp, ppd_ppp, ppd_xpp) VALUES (4, 'EMAIL', 'NOTIF_SYS', 'Notifications Email - System', 'C', NULL, '2017-06-18 17:14:20.446428', 'Upostgres', '2017-10-09 13:49:05.17331', 'Upostgres', NULL, true, false, true);
INSERT INTO ppd (ppd_id, ppd_process, ppd_attrib, ppd_desc, ppd_type, codename, ppd_etstmp, ppd_eu, ppd_mtstmp, ppd_mu, ppd_snotes, ppd_gpp, ppd_ppp, ppd_xpp) VALUES (14, 'SYSTEM', 'CLIENT_SYS_URL', 'Client Portal URL', 'C', NULL, '2017-06-18 17:14:20.523531', 'Upostgres', '2017-10-09 13:49:11.589409', 'Upostgres', NULL, false, false, true);
INSERT INTO ppd (ppd_id, ppd_process, ppd_attrib, ppd_desc, ppd_type, codename, ppd_etstmp, ppd_eu, ppd_mtstmp, ppd_mu, ppd_snotes, ppd_gpp, ppd_ppp, ppd_xpp) VALUES (16, 'USERS', 'HASH_SEED_C', 'Hash Seed Client Users', 'C', NULL, '2017-06-18 17:14:20.340713', 'Upostgres', '2017-10-09 13:49:15.349373', 'Upostgres', NULL, false, false, true);


--
-- TOC entry 2847 (class 0 OID 45306)
-- Dependencies: 200
-- Data for Name: gpp; Type: TABLE DATA; Schema: jsharmony; Owner: postgres
--

INSERT INTO gpp (gpp_id, gpp_process, gpp_attrib, gpp_val, gpp_etstmp, gpp_eu, gpp_mtstmp, gpp_mu) VALUES (11, 'HOUSE', 'STATE', 'IL', '2017-06-18 17:14:20.630721', 'Upostgres', '2017-06-18 17:14:20.630721', 'Upostgres');
INSERT INTO gpp (gpp_id, gpp_process, gpp_attrib, gpp_val, gpp_etstmp, gpp_eu, gpp_mtstmp, gpp_mu) VALUES (6, 'HOUSE', 'CITY', 'Anytown', '2017-06-18 17:14:20.637786', 'Upostgres', '2017-10-17 12:19:19.558109', 'S3');
INSERT INTO gpp (gpp_id, gpp_process, gpp_attrib, gpp_val, gpp_etstmp, gpp_eu, gpp_mtstmp, gpp_mu) VALUES (7, 'HOUSE', 'CONTACT', 'John Contact', '2017-06-18 17:14:20.578569', 'Upostgres', '2017-10-17 12:21:24.106015', 'S3');
INSERT INTO gpp (gpp_id, gpp_process, gpp_attrib, gpp_val, gpp_etstmp, gpp_eu, gpp_mtstmp, gpp_mu) VALUES (4, 'HOUSE', 'ADDR', '111 Main St', '2017-06-18 17:14:20.563563', 'Upostgres', '2017-10-17 12:21:34.45036', 'S3');
INSERT INTO gpp (gpp_id, gpp_process, gpp_attrib, gpp_val, gpp_etstmp, gpp_eu, gpp_mtstmp, gpp_mu) VALUES (5, 'HOUSE', 'BPHONE', '(222) 222-2222', '2017-06-18 17:14:20.570542', 'Upostgres', '2017-10-17 12:21:38.902571', 'S3');
INSERT INTO gpp (gpp_id, gpp_process, gpp_attrib, gpp_val, gpp_etstmp, gpp_eu, gpp_mtstmp, gpp_mu) VALUES (8, 'HOUSE', 'EMAIL', 'user@company.com', '2017-06-18 17:14:20.585575', 'Upostgres', '2017-10-17 12:21:52.189618', 'S3');
INSERT INTO gpp (gpp_id, gpp_process, gpp_attrib, gpp_val, gpp_etstmp, gpp_eu, gpp_mtstmp, gpp_mu) VALUES (9, 'HOUSE', 'FAX', '(333) 333-3333', '2017-06-18 17:14:20.593579', 'Upostgres', '2017-10-17 12:21:57.446541', 'S3');
INSERT INTO gpp (gpp_id, gpp_process, gpp_attrib, gpp_val, gpp_etstmp, gpp_eu, gpp_mtstmp, gpp_mu) VALUES (10, 'HOUSE', 'NAME', 'COMPANY NAME', '2017-06-18 17:14:20.600572', 'Upostgres', '2017-10-17 12:22:03.238268', 'S3');
INSERT INTO gpp (gpp_id, gpp_process, gpp_attrib, gpp_val, gpp_etstmp, gpp_eu, gpp_mtstmp, gpp_mu) VALUES (1, 'EMAIL', 'NOTIF_ADMIN', 'user@company.com', '2017-06-18 17:14:20.623602', 'Upostgres', '2017-10-17 12:24:08.713884', 'S3');
INSERT INTO gpp (gpp_id, gpp_process, gpp_attrib, gpp_val, gpp_etstmp, gpp_eu, gpp_mtstmp, gpp_mu) VALUES (12, 'HOUSE', 'ZIP', '11111', '2017-06-18 17:14:20.609592', 'Upostgres', '2017-10-18 11:52:07.997974', 'S3');


--
-- TOC entry 2894 (class 0 OID 0)
-- Dependencies: 201
-- Name: gpp_gpp_id_seq; Type: SEQUENCE SET; Schema: jsharmony; Owner: postgres
--

SELECT pg_catalog.setval('gpp_gpp_id_seq', 15, true);


--
-- TOC entry 2851 (class 0 OID 45329)
-- Dependencies: 204
-- Data for Name: hp; Type: TABLE DATA; Schema: jsharmony; Owner: postgres
--

INSERT INTO hp (hp_id, hp_code, hp_desc) VALUES (1, 'E_B', 'Item - Charges');
INSERT INTO hp (hp_id, hp_code, hp_desc) VALUES (2, 'E_H', 'Item - History');
INSERT INTO hp (hp_id, hp_code, hp_desc) VALUES (3, 'E_O', 'Item - Overview');
INSERT INTO hp (hp_id, hp_code, hp_desc) VALUES (4, 'EL_C_REL', 'Items - Related');
INSERT INTO hp (hp_id, hp_code, hp_desc) VALUES (5, 'TOLSEL_SEL', 'Items Selector');
INSERT INTO hp (hp_id, hp_code, hp_desc) VALUES (6, 'E_POPUP_E', 'New Item (from E)');
INSERT INTO hp (hp_id, hp_code, hp_desc) VALUES (7, 'E_POPUP_SQ', 'New Item (from SQ)');
INSERT INTO hp (hp_id, hp_code, hp_desc) VALUES (8, 'TO_H', 'Order History');
INSERT INTO hp (hp_id, hp_code, hp_desc) VALUES (9, 'TOL_C_REL', 'Orders - Related');
INSERT INTO hp (hp_id, hp_code, hp_desc) VALUES (10, 'SQ_A', 'Series - Assemblies');
INSERT INTO hp (hp_id, hp_code, hp_desc) VALUES (11, 'SQ_B', 'Series - Charges');
INSERT INTO hp (hp_id, hp_code, hp_desc) VALUES (12, 'SQ_H', 'Series - History');
INSERT INTO hp (hp_id, hp_code, hp_desc) VALUES (13, 'SQ_O', 'Series - Overview');
INSERT INTO hp (hp_id, hp_code, hp_desc) VALUES (14, 'CT', 'Customer Contact');
INSERT INTO hp (hp_id, hp_code, hp_desc) VALUES (15, 'C', 'Customer');


--
-- TOC entry 2849 (class 0 OID 45315)
-- Dependencies: 202
-- Data for Name: h; Type: TABLE DATA; Schema: jsharmony; Owner: postgres
--



--
-- TOC entry 2895 (class 0 OID 0)
-- Dependencies: 203
-- Name: h_h_id_seq; Type: SEQUENCE SET; Schema: jsharmony; Owner: postgres
--

SELECT pg_catalog.setval('h_h_id_seq', 41, true);


--
-- TOC entry 2896 (class 0 OID 0)
-- Dependencies: 205
-- Name: hp_hp_id_seq; Type: SEQUENCE SET; Schema: jsharmony; Owner: postgres
--

SELECT pg_catalog.setval('hp_hp_id_seq', 15, true);


--
-- TOC entry 2853 (class 0 OID 45349)
-- Dependencies: 208
-- Data for Name: numbers; Type: TABLE DATA; Schema: jsharmony; Owner: postgres
--

INSERT INTO numbers (n) VALUES (1);
INSERT INTO numbers (n) VALUES (2);
INSERT INTO numbers (n) VALUES (3);
INSERT INTO numbers (n) VALUES (4);
INSERT INTO numbers (n) VALUES (5);
INSERT INTO numbers (n) VALUES (6);
INSERT INTO numbers (n) VALUES (7);
INSERT INTO numbers (n) VALUES (8);
INSERT INTO numbers (n) VALUES (9);
INSERT INTO numbers (n) VALUES (10);
INSERT INTO numbers (n) VALUES (11);
INSERT INTO numbers (n) VALUES (12);
INSERT INTO numbers (n) VALUES (13);
INSERT INTO numbers (n) VALUES (14);
INSERT INTO numbers (n) VALUES (15);
INSERT INTO numbers (n) VALUES (16);
INSERT INTO numbers (n) VALUES (17);
INSERT INTO numbers (n) VALUES (18);
INSERT INTO numbers (n) VALUES (19);
INSERT INTO numbers (n) VALUES (20);
INSERT INTO numbers (n) VALUES (21);
INSERT INTO numbers (n) VALUES (22);
INSERT INTO numbers (n) VALUES (23);
INSERT INTO numbers (n) VALUES (24);
INSERT INTO numbers (n) VALUES (25);
INSERT INTO numbers (n) VALUES (26);
INSERT INTO numbers (n) VALUES (27);
INSERT INTO numbers (n) VALUES (28);
INSERT INTO numbers (n) VALUES (29);
INSERT INTO numbers (n) VALUES (30);
INSERT INTO numbers (n) VALUES (31);
INSERT INTO numbers (n) VALUES (32);
INSERT INTO numbers (n) VALUES (33);
INSERT INTO numbers (n) VALUES (34);
INSERT INTO numbers (n) VALUES (35);
INSERT INTO numbers (n) VALUES (36);
INSERT INTO numbers (n) VALUES (37);
INSERT INTO numbers (n) VALUES (38);
INSERT INTO numbers (n) VALUES (39);
INSERT INTO numbers (n) VALUES (40);
INSERT INTO numbers (n) VALUES (41);
INSERT INTO numbers (n) VALUES (42);
INSERT INTO numbers (n) VALUES (43);
INSERT INTO numbers (n) VALUES (44);
INSERT INTO numbers (n) VALUES (45);
INSERT INTO numbers (n) VALUES (46);
INSERT INTO numbers (n) VALUES (47);
INSERT INTO numbers (n) VALUES (48);
INSERT INTO numbers (n) VALUES (49);
INSERT INTO numbers (n) VALUES (50);
INSERT INTO numbers (n) VALUES (51);
INSERT INTO numbers (n) VALUES (52);
INSERT INTO numbers (n) VALUES (53);
INSERT INTO numbers (n) VALUES (54);
INSERT INTO numbers (n) VALUES (55);
INSERT INTO numbers (n) VALUES (56);
INSERT INTO numbers (n) VALUES (57);
INSERT INTO numbers (n) VALUES (58);
INSERT INTO numbers (n) VALUES (59);
INSERT INTO numbers (n) VALUES (60);
INSERT INTO numbers (n) VALUES (61);
INSERT INTO numbers (n) VALUES (62);
INSERT INTO numbers (n) VALUES (63);
INSERT INTO numbers (n) VALUES (64);
INSERT INTO numbers (n) VALUES (65);
INSERT INTO numbers (n) VALUES (66);
INSERT INTO numbers (n) VALUES (67);
INSERT INTO numbers (n) VALUES (68);
INSERT INTO numbers (n) VALUES (69);
INSERT INTO numbers (n) VALUES (70);
INSERT INTO numbers (n) VALUES (71);
INSERT INTO numbers (n) VALUES (72);
INSERT INTO numbers (n) VALUES (73);
INSERT INTO numbers (n) VALUES (74);
INSERT INTO numbers (n) VALUES (75);
INSERT INTO numbers (n) VALUES (76);
INSERT INTO numbers (n) VALUES (77);
INSERT INTO numbers (n) VALUES (78);
INSERT INTO numbers (n) VALUES (79);
INSERT INTO numbers (n) VALUES (80);
INSERT INTO numbers (n) VALUES (81);
INSERT INTO numbers (n) VALUES (82);
INSERT INTO numbers (n) VALUES (83);
INSERT INTO numbers (n) VALUES (84);
INSERT INTO numbers (n) VALUES (85);
INSERT INTO numbers (n) VALUES (86);
INSERT INTO numbers (n) VALUES (87);
INSERT INTO numbers (n) VALUES (88);
INSERT INTO numbers (n) VALUES (89);
INSERT INTO numbers (n) VALUES (90);
INSERT INTO numbers (n) VALUES (91);
INSERT INTO numbers (n) VALUES (92);
INSERT INTO numbers (n) VALUES (93);
INSERT INTO numbers (n) VALUES (94);
INSERT INTO numbers (n) VALUES (95);
INSERT INTO numbers (n) VALUES (96);
INSERT INTO numbers (n) VALUES (97);
INSERT INTO numbers (n) VALUES (98);
INSERT INTO numbers (n) VALUES (99);
INSERT INTO numbers (n) VALUES (100);
INSERT INTO numbers (n) VALUES (101);
INSERT INTO numbers (n) VALUES (102);
INSERT INTO numbers (n) VALUES (103);
INSERT INTO numbers (n) VALUES (104);
INSERT INTO numbers (n) VALUES (105);
INSERT INTO numbers (n) VALUES (106);
INSERT INTO numbers (n) VALUES (107);
INSERT INTO numbers (n) VALUES (108);
INSERT INTO numbers (n) VALUES (109);
INSERT INTO numbers (n) VALUES (110);
INSERT INTO numbers (n) VALUES (111);
INSERT INTO numbers (n) VALUES (112);
INSERT INTO numbers (n) VALUES (113);
INSERT INTO numbers (n) VALUES (114);
INSERT INTO numbers (n) VALUES (115);
INSERT INTO numbers (n) VALUES (116);
INSERT INTO numbers (n) VALUES (117);
INSERT INTO numbers (n) VALUES (118);
INSERT INTO numbers (n) VALUES (119);
INSERT INTO numbers (n) VALUES (120);
INSERT INTO numbers (n) VALUES (121);
INSERT INTO numbers (n) VALUES (122);
INSERT INTO numbers (n) VALUES (123);
INSERT INTO numbers (n) VALUES (124);
INSERT INTO numbers (n) VALUES (125);
INSERT INTO numbers (n) VALUES (126);
INSERT INTO numbers (n) VALUES (127);
INSERT INTO numbers (n) VALUES (128);
INSERT INTO numbers (n) VALUES (129);
INSERT INTO numbers (n) VALUES (130);
INSERT INTO numbers (n) VALUES (131);
INSERT INTO numbers (n) VALUES (132);
INSERT INTO numbers (n) VALUES (133);
INSERT INTO numbers (n) VALUES (134);
INSERT INTO numbers (n) VALUES (135);
INSERT INTO numbers (n) VALUES (136);
INSERT INTO numbers (n) VALUES (137);
INSERT INTO numbers (n) VALUES (138);
INSERT INTO numbers (n) VALUES (139);
INSERT INTO numbers (n) VALUES (140);
INSERT INTO numbers (n) VALUES (141);
INSERT INTO numbers (n) VALUES (142);
INSERT INTO numbers (n) VALUES (143);
INSERT INTO numbers (n) VALUES (144);
INSERT INTO numbers (n) VALUES (145);
INSERT INTO numbers (n) VALUES (146);
INSERT INTO numbers (n) VALUES (147);
INSERT INTO numbers (n) VALUES (148);
INSERT INTO numbers (n) VALUES (149);
INSERT INTO numbers (n) VALUES (150);
INSERT INTO numbers (n) VALUES (151);
INSERT INTO numbers (n) VALUES (152);
INSERT INTO numbers (n) VALUES (153);
INSERT INTO numbers (n) VALUES (154);
INSERT INTO numbers (n) VALUES (155);
INSERT INTO numbers (n) VALUES (156);
INSERT INTO numbers (n) VALUES (157);
INSERT INTO numbers (n) VALUES (158);
INSERT INTO numbers (n) VALUES (159);
INSERT INTO numbers (n) VALUES (160);
INSERT INTO numbers (n) VALUES (161);
INSERT INTO numbers (n) VALUES (162);
INSERT INTO numbers (n) VALUES (163);
INSERT INTO numbers (n) VALUES (164);
INSERT INTO numbers (n) VALUES (165);
INSERT INTO numbers (n) VALUES (166);
INSERT INTO numbers (n) VALUES (167);
INSERT INTO numbers (n) VALUES (168);
INSERT INTO numbers (n) VALUES (169);
INSERT INTO numbers (n) VALUES (170);
INSERT INTO numbers (n) VALUES (171);
INSERT INTO numbers (n) VALUES (172);
INSERT INTO numbers (n) VALUES (173);
INSERT INTO numbers (n) VALUES (174);
INSERT INTO numbers (n) VALUES (175);
INSERT INTO numbers (n) VALUES (176);
INSERT INTO numbers (n) VALUES (177);
INSERT INTO numbers (n) VALUES (178);
INSERT INTO numbers (n) VALUES (179);
INSERT INTO numbers (n) VALUES (180);
INSERT INTO numbers (n) VALUES (181);
INSERT INTO numbers (n) VALUES (182);
INSERT INTO numbers (n) VALUES (183);
INSERT INTO numbers (n) VALUES (184);
INSERT INTO numbers (n) VALUES (185);
INSERT INTO numbers (n) VALUES (186);
INSERT INTO numbers (n) VALUES (187);
INSERT INTO numbers (n) VALUES (188);
INSERT INTO numbers (n) VALUES (189);
INSERT INTO numbers (n) VALUES (190);
INSERT INTO numbers (n) VALUES (191);
INSERT INTO numbers (n) VALUES (192);
INSERT INTO numbers (n) VALUES (193);
INSERT INTO numbers (n) VALUES (194);
INSERT INTO numbers (n) VALUES (195);
INSERT INTO numbers (n) VALUES (196);
INSERT INTO numbers (n) VALUES (197);
INSERT INTO numbers (n) VALUES (198);
INSERT INTO numbers (n) VALUES (199);
INSERT INTO numbers (n) VALUES (200);
INSERT INTO numbers (n) VALUES (201);
INSERT INTO numbers (n) VALUES (202);
INSERT INTO numbers (n) VALUES (203);
INSERT INTO numbers (n) VALUES (204);
INSERT INTO numbers (n) VALUES (205);
INSERT INTO numbers (n) VALUES (206);
INSERT INTO numbers (n) VALUES (207);
INSERT INTO numbers (n) VALUES (208);
INSERT INTO numbers (n) VALUES (209);
INSERT INTO numbers (n) VALUES (210);
INSERT INTO numbers (n) VALUES (211);
INSERT INTO numbers (n) VALUES (212);
INSERT INTO numbers (n) VALUES (213);
INSERT INTO numbers (n) VALUES (214);
INSERT INTO numbers (n) VALUES (215);
INSERT INTO numbers (n) VALUES (216);
INSERT INTO numbers (n) VALUES (217);
INSERT INTO numbers (n) VALUES (218);
INSERT INTO numbers (n) VALUES (219);
INSERT INTO numbers (n) VALUES (220);
INSERT INTO numbers (n) VALUES (221);
INSERT INTO numbers (n) VALUES (222);
INSERT INTO numbers (n) VALUES (223);
INSERT INTO numbers (n) VALUES (224);
INSERT INTO numbers (n) VALUES (225);
INSERT INTO numbers (n) VALUES (226);
INSERT INTO numbers (n) VALUES (227);
INSERT INTO numbers (n) VALUES (228);
INSERT INTO numbers (n) VALUES (229);
INSERT INTO numbers (n) VALUES (230);
INSERT INTO numbers (n) VALUES (231);
INSERT INTO numbers (n) VALUES (232);
INSERT INTO numbers (n) VALUES (233);
INSERT INTO numbers (n) VALUES (234);
INSERT INTO numbers (n) VALUES (235);
INSERT INTO numbers (n) VALUES (236);
INSERT INTO numbers (n) VALUES (237);
INSERT INTO numbers (n) VALUES (238);
INSERT INTO numbers (n) VALUES (239);
INSERT INTO numbers (n) VALUES (240);
INSERT INTO numbers (n) VALUES (241);
INSERT INTO numbers (n) VALUES (242);
INSERT INTO numbers (n) VALUES (243);
INSERT INTO numbers (n) VALUES (244);
INSERT INTO numbers (n) VALUES (245);
INSERT INTO numbers (n) VALUES (246);
INSERT INTO numbers (n) VALUES (247);
INSERT INTO numbers (n) VALUES (248);
INSERT INTO numbers (n) VALUES (249);
INSERT INTO numbers (n) VALUES (250);
INSERT INTO numbers (n) VALUES (251);
INSERT INTO numbers (n) VALUES (252);
INSERT INTO numbers (n) VALUES (253);
INSERT INTO numbers (n) VALUES (254);
INSERT INTO numbers (n) VALUES (255);
INSERT INTO numbers (n) VALUES (256);
INSERT INTO numbers (n) VALUES (257);
INSERT INTO numbers (n) VALUES (258);
INSERT INTO numbers (n) VALUES (259);
INSERT INTO numbers (n) VALUES (260);
INSERT INTO numbers (n) VALUES (261);
INSERT INTO numbers (n) VALUES (262);
INSERT INTO numbers (n) VALUES (263);
INSERT INTO numbers (n) VALUES (264);
INSERT INTO numbers (n) VALUES (265);
INSERT INTO numbers (n) VALUES (266);
INSERT INTO numbers (n) VALUES (267);
INSERT INTO numbers (n) VALUES (268);
INSERT INTO numbers (n) VALUES (269);
INSERT INTO numbers (n) VALUES (270);
INSERT INTO numbers (n) VALUES (271);
INSERT INTO numbers (n) VALUES (272);
INSERT INTO numbers (n) VALUES (273);
INSERT INTO numbers (n) VALUES (274);
INSERT INTO numbers (n) VALUES (275);
INSERT INTO numbers (n) VALUES (276);
INSERT INTO numbers (n) VALUES (277);
INSERT INTO numbers (n) VALUES (278);
INSERT INTO numbers (n) VALUES (279);
INSERT INTO numbers (n) VALUES (280);
INSERT INTO numbers (n) VALUES (281);
INSERT INTO numbers (n) VALUES (282);
INSERT INTO numbers (n) VALUES (283);
INSERT INTO numbers (n) VALUES (284);
INSERT INTO numbers (n) VALUES (285);
INSERT INTO numbers (n) VALUES (286);
INSERT INTO numbers (n) VALUES (287);
INSERT INTO numbers (n) VALUES (288);
INSERT INTO numbers (n) VALUES (289);
INSERT INTO numbers (n) VALUES (290);
INSERT INTO numbers (n) VALUES (291);
INSERT INTO numbers (n) VALUES (292);
INSERT INTO numbers (n) VALUES (293);
INSERT INTO numbers (n) VALUES (294);
INSERT INTO numbers (n) VALUES (295);
INSERT INTO numbers (n) VALUES (296);
INSERT INTO numbers (n) VALUES (297);
INSERT INTO numbers (n) VALUES (298);
INSERT INTO numbers (n) VALUES (299);
INSERT INTO numbers (n) VALUES (300);
INSERT INTO numbers (n) VALUES (301);
INSERT INTO numbers (n) VALUES (302);
INSERT INTO numbers (n) VALUES (303);
INSERT INTO numbers (n) VALUES (304);
INSERT INTO numbers (n) VALUES (305);
INSERT INTO numbers (n) VALUES (306);
INSERT INTO numbers (n) VALUES (307);
INSERT INTO numbers (n) VALUES (308);
INSERT INTO numbers (n) VALUES (309);
INSERT INTO numbers (n) VALUES (310);
INSERT INTO numbers (n) VALUES (311);
INSERT INTO numbers (n) VALUES (312);
INSERT INTO numbers (n) VALUES (313);
INSERT INTO numbers (n) VALUES (314);
INSERT INTO numbers (n) VALUES (315);
INSERT INTO numbers (n) VALUES (316);
INSERT INTO numbers (n) VALUES (317);
INSERT INTO numbers (n) VALUES (318);
INSERT INTO numbers (n) VALUES (319);
INSERT INTO numbers (n) VALUES (320);
INSERT INTO numbers (n) VALUES (321);
INSERT INTO numbers (n) VALUES (322);
INSERT INTO numbers (n) VALUES (323);
INSERT INTO numbers (n) VALUES (324);
INSERT INTO numbers (n) VALUES (325);
INSERT INTO numbers (n) VALUES (326);
INSERT INTO numbers (n) VALUES (327);
INSERT INTO numbers (n) VALUES (328);
INSERT INTO numbers (n) VALUES (329);
INSERT INTO numbers (n) VALUES (330);
INSERT INTO numbers (n) VALUES (331);
INSERT INTO numbers (n) VALUES (332);
INSERT INTO numbers (n) VALUES (333);
INSERT INTO numbers (n) VALUES (334);
INSERT INTO numbers (n) VALUES (335);
INSERT INTO numbers (n) VALUES (336);
INSERT INTO numbers (n) VALUES (337);
INSERT INTO numbers (n) VALUES (338);
INSERT INTO numbers (n) VALUES (339);
INSERT INTO numbers (n) VALUES (340);
INSERT INTO numbers (n) VALUES (341);
INSERT INTO numbers (n) VALUES (342);
INSERT INTO numbers (n) VALUES (343);
INSERT INTO numbers (n) VALUES (344);
INSERT INTO numbers (n) VALUES (345);
INSERT INTO numbers (n) VALUES (346);
INSERT INTO numbers (n) VALUES (347);
INSERT INTO numbers (n) VALUES (348);
INSERT INTO numbers (n) VALUES (349);
INSERT INTO numbers (n) VALUES (350);
INSERT INTO numbers (n) VALUES (351);
INSERT INTO numbers (n) VALUES (352);
INSERT INTO numbers (n) VALUES (353);
INSERT INTO numbers (n) VALUES (354);
INSERT INTO numbers (n) VALUES (355);
INSERT INTO numbers (n) VALUES (356);
INSERT INTO numbers (n) VALUES (357);
INSERT INTO numbers (n) VALUES (358);
INSERT INTO numbers (n) VALUES (359);
INSERT INTO numbers (n) VALUES (360);
INSERT INTO numbers (n) VALUES (361);
INSERT INTO numbers (n) VALUES (362);
INSERT INTO numbers (n) VALUES (363);
INSERT INTO numbers (n) VALUES (364);
INSERT INTO numbers (n) VALUES (365);
INSERT INTO numbers (n) VALUES (366);
INSERT INTO numbers (n) VALUES (367);
INSERT INTO numbers (n) VALUES (368);
INSERT INTO numbers (n) VALUES (369);
INSERT INTO numbers (n) VALUES (370);
INSERT INTO numbers (n) VALUES (371);
INSERT INTO numbers (n) VALUES (372);
INSERT INTO numbers (n) VALUES (373);
INSERT INTO numbers (n) VALUES (374);
INSERT INTO numbers (n) VALUES (375);
INSERT INTO numbers (n) VALUES (376);
INSERT INTO numbers (n) VALUES (377);
INSERT INTO numbers (n) VALUES (378);
INSERT INTO numbers (n) VALUES (379);
INSERT INTO numbers (n) VALUES (380);
INSERT INTO numbers (n) VALUES (381);
INSERT INTO numbers (n) VALUES (382);
INSERT INTO numbers (n) VALUES (383);
INSERT INTO numbers (n) VALUES (384);
INSERT INTO numbers (n) VALUES (385);
INSERT INTO numbers (n) VALUES (386);
INSERT INTO numbers (n) VALUES (387);
INSERT INTO numbers (n) VALUES (388);
INSERT INTO numbers (n) VALUES (389);
INSERT INTO numbers (n) VALUES (390);
INSERT INTO numbers (n) VALUES (391);
INSERT INTO numbers (n) VALUES (392);
INSERT INTO numbers (n) VALUES (393);
INSERT INTO numbers (n) VALUES (394);
INSERT INTO numbers (n) VALUES (395);
INSERT INTO numbers (n) VALUES (396);
INSERT INTO numbers (n) VALUES (397);
INSERT INTO numbers (n) VALUES (398);
INSERT INTO numbers (n) VALUES (399);
INSERT INTO numbers (n) VALUES (400);
INSERT INTO numbers (n) VALUES (401);
INSERT INTO numbers (n) VALUES (402);
INSERT INTO numbers (n) VALUES (403);
INSERT INTO numbers (n) VALUES (404);
INSERT INTO numbers (n) VALUES (405);
INSERT INTO numbers (n) VALUES (406);
INSERT INTO numbers (n) VALUES (407);
INSERT INTO numbers (n) VALUES (408);
INSERT INTO numbers (n) VALUES (409);
INSERT INTO numbers (n) VALUES (410);
INSERT INTO numbers (n) VALUES (411);
INSERT INTO numbers (n) VALUES (412);
INSERT INTO numbers (n) VALUES (413);
INSERT INTO numbers (n) VALUES (414);
INSERT INTO numbers (n) VALUES (415);
INSERT INTO numbers (n) VALUES (416);
INSERT INTO numbers (n) VALUES (417);
INSERT INTO numbers (n) VALUES (418);
INSERT INTO numbers (n) VALUES (419);
INSERT INTO numbers (n) VALUES (420);
INSERT INTO numbers (n) VALUES (421);
INSERT INTO numbers (n) VALUES (422);
INSERT INTO numbers (n) VALUES (423);
INSERT INTO numbers (n) VALUES (424);
INSERT INTO numbers (n) VALUES (425);
INSERT INTO numbers (n) VALUES (426);
INSERT INTO numbers (n) VALUES (427);
INSERT INTO numbers (n) VALUES (428);
INSERT INTO numbers (n) VALUES (429);
INSERT INTO numbers (n) VALUES (430);
INSERT INTO numbers (n) VALUES (431);
INSERT INTO numbers (n) VALUES (432);
INSERT INTO numbers (n) VALUES (433);
INSERT INTO numbers (n) VALUES (434);
INSERT INTO numbers (n) VALUES (435);
INSERT INTO numbers (n) VALUES (436);
INSERT INTO numbers (n) VALUES (437);
INSERT INTO numbers (n) VALUES (438);
INSERT INTO numbers (n) VALUES (439);
INSERT INTO numbers (n) VALUES (440);
INSERT INTO numbers (n) VALUES (441);
INSERT INTO numbers (n) VALUES (442);
INSERT INTO numbers (n) VALUES (443);
INSERT INTO numbers (n) VALUES (444);
INSERT INTO numbers (n) VALUES (445);
INSERT INTO numbers (n) VALUES (446);
INSERT INTO numbers (n) VALUES (447);
INSERT INTO numbers (n) VALUES (448);
INSERT INTO numbers (n) VALUES (449);
INSERT INTO numbers (n) VALUES (450);
INSERT INTO numbers (n) VALUES (451);
INSERT INTO numbers (n) VALUES (452);
INSERT INTO numbers (n) VALUES (453);
INSERT INTO numbers (n) VALUES (454);
INSERT INTO numbers (n) VALUES (455);
INSERT INTO numbers (n) VALUES (456);
INSERT INTO numbers (n) VALUES (457);
INSERT INTO numbers (n) VALUES (458);
INSERT INTO numbers (n) VALUES (459);
INSERT INTO numbers (n) VALUES (460);
INSERT INTO numbers (n) VALUES (461);
INSERT INTO numbers (n) VALUES (462);
INSERT INTO numbers (n) VALUES (463);
INSERT INTO numbers (n) VALUES (464);
INSERT INTO numbers (n) VALUES (465);
INSERT INTO numbers (n) VALUES (466);
INSERT INTO numbers (n) VALUES (467);
INSERT INTO numbers (n) VALUES (468);
INSERT INTO numbers (n) VALUES (469);
INSERT INTO numbers (n) VALUES (470);
INSERT INTO numbers (n) VALUES (471);
INSERT INTO numbers (n) VALUES (472);
INSERT INTO numbers (n) VALUES (473);
INSERT INTO numbers (n) VALUES (474);
INSERT INTO numbers (n) VALUES (475);
INSERT INTO numbers (n) VALUES (476);
INSERT INTO numbers (n) VALUES (477);
INSERT INTO numbers (n) VALUES (478);
INSERT INTO numbers (n) VALUES (479);
INSERT INTO numbers (n) VALUES (480);
INSERT INTO numbers (n) VALUES (481);
INSERT INTO numbers (n) VALUES (482);
INSERT INTO numbers (n) VALUES (483);
INSERT INTO numbers (n) VALUES (484);
INSERT INTO numbers (n) VALUES (485);
INSERT INTO numbers (n) VALUES (486);
INSERT INTO numbers (n) VALUES (487);
INSERT INTO numbers (n) VALUES (488);
INSERT INTO numbers (n) VALUES (489);
INSERT INTO numbers (n) VALUES (490);
INSERT INTO numbers (n) VALUES (491);
INSERT INTO numbers (n) VALUES (492);
INSERT INTO numbers (n) VALUES (493);
INSERT INTO numbers (n) VALUES (494);
INSERT INTO numbers (n) VALUES (495);
INSERT INTO numbers (n) VALUES (496);
INSERT INTO numbers (n) VALUES (497);
INSERT INTO numbers (n) VALUES (498);
INSERT INTO numbers (n) VALUES (499);
INSERT INTO numbers (n) VALUES (500);
INSERT INTO numbers (n) VALUES (501);
INSERT INTO numbers (n) VALUES (502);
INSERT INTO numbers (n) VALUES (503);
INSERT INTO numbers (n) VALUES (504);
INSERT INTO numbers (n) VALUES (505);
INSERT INTO numbers (n) VALUES (506);
INSERT INTO numbers (n) VALUES (507);
INSERT INTO numbers (n) VALUES (508);
INSERT INTO numbers (n) VALUES (509);
INSERT INTO numbers (n) VALUES (510);
INSERT INTO numbers (n) VALUES (511);
INSERT INTO numbers (n) VALUES (512);
INSERT INTO numbers (n) VALUES (513);
INSERT INTO numbers (n) VALUES (514);
INSERT INTO numbers (n) VALUES (515);
INSERT INTO numbers (n) VALUES (516);
INSERT INTO numbers (n) VALUES (517);
INSERT INTO numbers (n) VALUES (518);
INSERT INTO numbers (n) VALUES (519);
INSERT INTO numbers (n) VALUES (520);
INSERT INTO numbers (n) VALUES (521);
INSERT INTO numbers (n) VALUES (522);
INSERT INTO numbers (n) VALUES (523);
INSERT INTO numbers (n) VALUES (524);
INSERT INTO numbers (n) VALUES (525);
INSERT INTO numbers (n) VALUES (526);
INSERT INTO numbers (n) VALUES (527);
INSERT INTO numbers (n) VALUES (528);
INSERT INTO numbers (n) VALUES (529);
INSERT INTO numbers (n) VALUES (530);
INSERT INTO numbers (n) VALUES (531);
INSERT INTO numbers (n) VALUES (532);
INSERT INTO numbers (n) VALUES (533);
INSERT INTO numbers (n) VALUES (534);
INSERT INTO numbers (n) VALUES (535);
INSERT INTO numbers (n) VALUES (536);
INSERT INTO numbers (n) VALUES (537);
INSERT INTO numbers (n) VALUES (538);
INSERT INTO numbers (n) VALUES (539);
INSERT INTO numbers (n) VALUES (540);
INSERT INTO numbers (n) VALUES (541);
INSERT INTO numbers (n) VALUES (542);
INSERT INTO numbers (n) VALUES (543);
INSERT INTO numbers (n) VALUES (544);
INSERT INTO numbers (n) VALUES (545);
INSERT INTO numbers (n) VALUES (546);
INSERT INTO numbers (n) VALUES (547);
INSERT INTO numbers (n) VALUES (548);
INSERT INTO numbers (n) VALUES (549);
INSERT INTO numbers (n) VALUES (550);
INSERT INTO numbers (n) VALUES (551);
INSERT INTO numbers (n) VALUES (552);
INSERT INTO numbers (n) VALUES (553);
INSERT INTO numbers (n) VALUES (554);
INSERT INTO numbers (n) VALUES (555);
INSERT INTO numbers (n) VALUES (556);
INSERT INTO numbers (n) VALUES (557);
INSERT INTO numbers (n) VALUES (558);
INSERT INTO numbers (n) VALUES (559);
INSERT INTO numbers (n) VALUES (560);
INSERT INTO numbers (n) VALUES (561);
INSERT INTO numbers (n) VALUES (562);
INSERT INTO numbers (n) VALUES (563);
INSERT INTO numbers (n) VALUES (564);
INSERT INTO numbers (n) VALUES (565);
INSERT INTO numbers (n) VALUES (566);
INSERT INTO numbers (n) VALUES (567);
INSERT INTO numbers (n) VALUES (568);
INSERT INTO numbers (n) VALUES (569);
INSERT INTO numbers (n) VALUES (570);
INSERT INTO numbers (n) VALUES (571);
INSERT INTO numbers (n) VALUES (572);
INSERT INTO numbers (n) VALUES (573);
INSERT INTO numbers (n) VALUES (574);
INSERT INTO numbers (n) VALUES (575);
INSERT INTO numbers (n) VALUES (576);
INSERT INTO numbers (n) VALUES (577);
INSERT INTO numbers (n) VALUES (578);
INSERT INTO numbers (n) VALUES (579);
INSERT INTO numbers (n) VALUES (580);
INSERT INTO numbers (n) VALUES (581);
INSERT INTO numbers (n) VALUES (582);
INSERT INTO numbers (n) VALUES (583);
INSERT INTO numbers (n) VALUES (584);
INSERT INTO numbers (n) VALUES (585);
INSERT INTO numbers (n) VALUES (586);
INSERT INTO numbers (n) VALUES (587);
INSERT INTO numbers (n) VALUES (588);
INSERT INTO numbers (n) VALUES (589);
INSERT INTO numbers (n) VALUES (590);
INSERT INTO numbers (n) VALUES (591);
INSERT INTO numbers (n) VALUES (592);
INSERT INTO numbers (n) VALUES (593);
INSERT INTO numbers (n) VALUES (594);
INSERT INTO numbers (n) VALUES (595);
INSERT INTO numbers (n) VALUES (596);
INSERT INTO numbers (n) VALUES (597);
INSERT INTO numbers (n) VALUES (598);
INSERT INTO numbers (n) VALUES (599);
INSERT INTO numbers (n) VALUES (600);
INSERT INTO numbers (n) VALUES (601);
INSERT INTO numbers (n) VALUES (602);
INSERT INTO numbers (n) VALUES (603);
INSERT INTO numbers (n) VALUES (604);
INSERT INTO numbers (n) VALUES (605);
INSERT INTO numbers (n) VALUES (606);
INSERT INTO numbers (n) VALUES (607);
INSERT INTO numbers (n) VALUES (608);
INSERT INTO numbers (n) VALUES (609);
INSERT INTO numbers (n) VALUES (610);
INSERT INTO numbers (n) VALUES (611);
INSERT INTO numbers (n) VALUES (612);
INSERT INTO numbers (n) VALUES (613);
INSERT INTO numbers (n) VALUES (614);
INSERT INTO numbers (n) VALUES (615);
INSERT INTO numbers (n) VALUES (616);
INSERT INTO numbers (n) VALUES (617);
INSERT INTO numbers (n) VALUES (618);
INSERT INTO numbers (n) VALUES (619);
INSERT INTO numbers (n) VALUES (620);
INSERT INTO numbers (n) VALUES (621);
INSERT INTO numbers (n) VALUES (622);
INSERT INTO numbers (n) VALUES (623);
INSERT INTO numbers (n) VALUES (624);
INSERT INTO numbers (n) VALUES (625);
INSERT INTO numbers (n) VALUES (626);
INSERT INTO numbers (n) VALUES (627);
INSERT INTO numbers (n) VALUES (628);
INSERT INTO numbers (n) VALUES (629);
INSERT INTO numbers (n) VALUES (630);
INSERT INTO numbers (n) VALUES (631);
INSERT INTO numbers (n) VALUES (632);
INSERT INTO numbers (n) VALUES (633);
INSERT INTO numbers (n) VALUES (634);
INSERT INTO numbers (n) VALUES (635);
INSERT INTO numbers (n) VALUES (636);
INSERT INTO numbers (n) VALUES (637);
INSERT INTO numbers (n) VALUES (638);
INSERT INTO numbers (n) VALUES (639);
INSERT INTO numbers (n) VALUES (640);
INSERT INTO numbers (n) VALUES (641);
INSERT INTO numbers (n) VALUES (642);
INSERT INTO numbers (n) VALUES (643);
INSERT INTO numbers (n) VALUES (644);
INSERT INTO numbers (n) VALUES (645);
INSERT INTO numbers (n) VALUES (646);
INSERT INTO numbers (n) VALUES (647);
INSERT INTO numbers (n) VALUES (648);
INSERT INTO numbers (n) VALUES (649);
INSERT INTO numbers (n) VALUES (650);
INSERT INTO numbers (n) VALUES (651);
INSERT INTO numbers (n) VALUES (652);
INSERT INTO numbers (n) VALUES (653);
INSERT INTO numbers (n) VALUES (654);
INSERT INTO numbers (n) VALUES (655);
INSERT INTO numbers (n) VALUES (656);
INSERT INTO numbers (n) VALUES (657);
INSERT INTO numbers (n) VALUES (658);
INSERT INTO numbers (n) VALUES (659);
INSERT INTO numbers (n) VALUES (660);
INSERT INTO numbers (n) VALUES (661);
INSERT INTO numbers (n) VALUES (662);
INSERT INTO numbers (n) VALUES (663);
INSERT INTO numbers (n) VALUES (664);
INSERT INTO numbers (n) VALUES (665);
INSERT INTO numbers (n) VALUES (666);
INSERT INTO numbers (n) VALUES (667);
INSERT INTO numbers (n) VALUES (668);
INSERT INTO numbers (n) VALUES (669);
INSERT INTO numbers (n) VALUES (670);
INSERT INTO numbers (n) VALUES (671);
INSERT INTO numbers (n) VALUES (672);
INSERT INTO numbers (n) VALUES (673);
INSERT INTO numbers (n) VALUES (674);
INSERT INTO numbers (n) VALUES (675);
INSERT INTO numbers (n) VALUES (676);
INSERT INTO numbers (n) VALUES (677);
INSERT INTO numbers (n) VALUES (678);
INSERT INTO numbers (n) VALUES (679);
INSERT INTO numbers (n) VALUES (680);
INSERT INTO numbers (n) VALUES (681);
INSERT INTO numbers (n) VALUES (682);
INSERT INTO numbers (n) VALUES (683);
INSERT INTO numbers (n) VALUES (684);
INSERT INTO numbers (n) VALUES (685);
INSERT INTO numbers (n) VALUES (686);
INSERT INTO numbers (n) VALUES (687);
INSERT INTO numbers (n) VALUES (688);
INSERT INTO numbers (n) VALUES (689);
INSERT INTO numbers (n) VALUES (690);
INSERT INTO numbers (n) VALUES (691);
INSERT INTO numbers (n) VALUES (692);
INSERT INTO numbers (n) VALUES (693);
INSERT INTO numbers (n) VALUES (694);
INSERT INTO numbers (n) VALUES (695);
INSERT INTO numbers (n) VALUES (696);
INSERT INTO numbers (n) VALUES (697);
INSERT INTO numbers (n) VALUES (698);
INSERT INTO numbers (n) VALUES (699);
INSERT INTO numbers (n) VALUES (700);
INSERT INTO numbers (n) VALUES (701);
INSERT INTO numbers (n) VALUES (702);
INSERT INTO numbers (n) VALUES (703);
INSERT INTO numbers (n) VALUES (704);
INSERT INTO numbers (n) VALUES (705);
INSERT INTO numbers (n) VALUES (706);
INSERT INTO numbers (n) VALUES (707);
INSERT INTO numbers (n) VALUES (708);
INSERT INTO numbers (n) VALUES (709);
INSERT INTO numbers (n) VALUES (710);
INSERT INTO numbers (n) VALUES (711);
INSERT INTO numbers (n) VALUES (712);
INSERT INTO numbers (n) VALUES (713);
INSERT INTO numbers (n) VALUES (714);
INSERT INTO numbers (n) VALUES (715);
INSERT INTO numbers (n) VALUES (716);
INSERT INTO numbers (n) VALUES (717);
INSERT INTO numbers (n) VALUES (718);
INSERT INTO numbers (n) VALUES (719);
INSERT INTO numbers (n) VALUES (720);
INSERT INTO numbers (n) VALUES (721);
INSERT INTO numbers (n) VALUES (722);
INSERT INTO numbers (n) VALUES (723);
INSERT INTO numbers (n) VALUES (724);
INSERT INTO numbers (n) VALUES (725);
INSERT INTO numbers (n) VALUES (726);
INSERT INTO numbers (n) VALUES (727);
INSERT INTO numbers (n) VALUES (728);
INSERT INTO numbers (n) VALUES (729);
INSERT INTO numbers (n) VALUES (730);
INSERT INTO numbers (n) VALUES (731);
INSERT INTO numbers (n) VALUES (732);
INSERT INTO numbers (n) VALUES (733);
INSERT INTO numbers (n) VALUES (734);
INSERT INTO numbers (n) VALUES (735);
INSERT INTO numbers (n) VALUES (736);
INSERT INTO numbers (n) VALUES (737);
INSERT INTO numbers (n) VALUES (738);
INSERT INTO numbers (n) VALUES (739);
INSERT INTO numbers (n) VALUES (740);
INSERT INTO numbers (n) VALUES (741);
INSERT INTO numbers (n) VALUES (742);
INSERT INTO numbers (n) VALUES (743);
INSERT INTO numbers (n) VALUES (744);
INSERT INTO numbers (n) VALUES (745);
INSERT INTO numbers (n) VALUES (746);
INSERT INTO numbers (n) VALUES (747);
INSERT INTO numbers (n) VALUES (748);
INSERT INTO numbers (n) VALUES (749);
INSERT INTO numbers (n) VALUES (750);
INSERT INTO numbers (n) VALUES (751);
INSERT INTO numbers (n) VALUES (752);
INSERT INTO numbers (n) VALUES (753);
INSERT INTO numbers (n) VALUES (754);
INSERT INTO numbers (n) VALUES (755);
INSERT INTO numbers (n) VALUES (756);
INSERT INTO numbers (n) VALUES (757);
INSERT INTO numbers (n) VALUES (758);
INSERT INTO numbers (n) VALUES (759);
INSERT INTO numbers (n) VALUES (760);
INSERT INTO numbers (n) VALUES (761);
INSERT INTO numbers (n) VALUES (762);
INSERT INTO numbers (n) VALUES (763);
INSERT INTO numbers (n) VALUES (764);
INSERT INTO numbers (n) VALUES (765);
INSERT INTO numbers (n) VALUES (766);
INSERT INTO numbers (n) VALUES (767);
INSERT INTO numbers (n) VALUES (768);
INSERT INTO numbers (n) VALUES (769);
INSERT INTO numbers (n) VALUES (770);
INSERT INTO numbers (n) VALUES (771);
INSERT INTO numbers (n) VALUES (772);
INSERT INTO numbers (n) VALUES (773);
INSERT INTO numbers (n) VALUES (774);
INSERT INTO numbers (n) VALUES (775);
INSERT INTO numbers (n) VALUES (776);
INSERT INTO numbers (n) VALUES (777);
INSERT INTO numbers (n) VALUES (778);
INSERT INTO numbers (n) VALUES (779);
INSERT INTO numbers (n) VALUES (780);
INSERT INTO numbers (n) VALUES (781);
INSERT INTO numbers (n) VALUES (782);
INSERT INTO numbers (n) VALUES (783);
INSERT INTO numbers (n) VALUES (784);
INSERT INTO numbers (n) VALUES (785);
INSERT INTO numbers (n) VALUES (786);
INSERT INTO numbers (n) VALUES (787);
INSERT INTO numbers (n) VALUES (788);
INSERT INTO numbers (n) VALUES (789);
INSERT INTO numbers (n) VALUES (790);
INSERT INTO numbers (n) VALUES (791);
INSERT INTO numbers (n) VALUES (792);
INSERT INTO numbers (n) VALUES (793);
INSERT INTO numbers (n) VALUES (794);
INSERT INTO numbers (n) VALUES (795);
INSERT INTO numbers (n) VALUES (796);
INSERT INTO numbers (n) VALUES (797);
INSERT INTO numbers (n) VALUES (798);
INSERT INTO numbers (n) VALUES (799);
INSERT INTO numbers (n) VALUES (800);
INSERT INTO numbers (n) VALUES (801);
INSERT INTO numbers (n) VALUES (802);
INSERT INTO numbers (n) VALUES (803);
INSERT INTO numbers (n) VALUES (804);
INSERT INTO numbers (n) VALUES (805);
INSERT INTO numbers (n) VALUES (806);
INSERT INTO numbers (n) VALUES (807);
INSERT INTO numbers (n) VALUES (808);
INSERT INTO numbers (n) VALUES (809);
INSERT INTO numbers (n) VALUES (810);
INSERT INTO numbers (n) VALUES (811);
INSERT INTO numbers (n) VALUES (812);
INSERT INTO numbers (n) VALUES (813);
INSERT INTO numbers (n) VALUES (814);
INSERT INTO numbers (n) VALUES (815);
INSERT INTO numbers (n) VALUES (816);
INSERT INTO numbers (n) VALUES (817);
INSERT INTO numbers (n) VALUES (818);
INSERT INTO numbers (n) VALUES (819);
INSERT INTO numbers (n) VALUES (820);
INSERT INTO numbers (n) VALUES (821);
INSERT INTO numbers (n) VALUES (822);
INSERT INTO numbers (n) VALUES (823);
INSERT INTO numbers (n) VALUES (824);
INSERT INTO numbers (n) VALUES (825);
INSERT INTO numbers (n) VALUES (826);
INSERT INTO numbers (n) VALUES (827);
INSERT INTO numbers (n) VALUES (828);
INSERT INTO numbers (n) VALUES (829);
INSERT INTO numbers (n) VALUES (830);
INSERT INTO numbers (n) VALUES (831);
INSERT INTO numbers (n) VALUES (832);
INSERT INTO numbers (n) VALUES (833);
INSERT INTO numbers (n) VALUES (834);
INSERT INTO numbers (n) VALUES (835);
INSERT INTO numbers (n) VALUES (836);
INSERT INTO numbers (n) VALUES (837);
INSERT INTO numbers (n) VALUES (838);
INSERT INTO numbers (n) VALUES (839);
INSERT INTO numbers (n) VALUES (840);
INSERT INTO numbers (n) VALUES (841);
INSERT INTO numbers (n) VALUES (842);
INSERT INTO numbers (n) VALUES (843);
INSERT INTO numbers (n) VALUES (844);
INSERT INTO numbers (n) VALUES (845);
INSERT INTO numbers (n) VALUES (846);
INSERT INTO numbers (n) VALUES (847);
INSERT INTO numbers (n) VALUES (848);
INSERT INTO numbers (n) VALUES (849);
INSERT INTO numbers (n) VALUES (850);
INSERT INTO numbers (n) VALUES (851);
INSERT INTO numbers (n) VALUES (852);
INSERT INTO numbers (n) VALUES (853);
INSERT INTO numbers (n) VALUES (854);
INSERT INTO numbers (n) VALUES (855);
INSERT INTO numbers (n) VALUES (856);
INSERT INTO numbers (n) VALUES (857);
INSERT INTO numbers (n) VALUES (858);
INSERT INTO numbers (n) VALUES (859);
INSERT INTO numbers (n) VALUES (860);
INSERT INTO numbers (n) VALUES (861);
INSERT INTO numbers (n) VALUES (862);
INSERT INTO numbers (n) VALUES (863);
INSERT INTO numbers (n) VALUES (864);
INSERT INTO numbers (n) VALUES (865);
INSERT INTO numbers (n) VALUES (866);
INSERT INTO numbers (n) VALUES (867);
INSERT INTO numbers (n) VALUES (868);
INSERT INTO numbers (n) VALUES (869);
INSERT INTO numbers (n) VALUES (870);
INSERT INTO numbers (n) VALUES (871);
INSERT INTO numbers (n) VALUES (872);
INSERT INTO numbers (n) VALUES (873);
INSERT INTO numbers (n) VALUES (874);
INSERT INTO numbers (n) VALUES (875);
INSERT INTO numbers (n) VALUES (876);
INSERT INTO numbers (n) VALUES (877);
INSERT INTO numbers (n) VALUES (878);
INSERT INTO numbers (n) VALUES (879);
INSERT INTO numbers (n) VALUES (880);
INSERT INTO numbers (n) VALUES (881);
INSERT INTO numbers (n) VALUES (882);
INSERT INTO numbers (n) VALUES (883);
INSERT INTO numbers (n) VALUES (884);
INSERT INTO numbers (n) VALUES (885);
INSERT INTO numbers (n) VALUES (886);
INSERT INTO numbers (n) VALUES (887);
INSERT INTO numbers (n) VALUES (888);
INSERT INTO numbers (n) VALUES (889);
INSERT INTO numbers (n) VALUES (890);
INSERT INTO numbers (n) VALUES (891);
INSERT INTO numbers (n) VALUES (892);
INSERT INTO numbers (n) VALUES (893);
INSERT INTO numbers (n) VALUES (894);
INSERT INTO numbers (n) VALUES (895);
INSERT INTO numbers (n) VALUES (896);
INSERT INTO numbers (n) VALUES (897);
INSERT INTO numbers (n) VALUES (898);
INSERT INTO numbers (n) VALUES (899);
INSERT INTO numbers (n) VALUES (900);
INSERT INTO numbers (n) VALUES (901);
INSERT INTO numbers (n) VALUES (902);
INSERT INTO numbers (n) VALUES (903);
INSERT INTO numbers (n) VALUES (904);
INSERT INTO numbers (n) VALUES (905);
INSERT INTO numbers (n) VALUES (906);
INSERT INTO numbers (n) VALUES (907);
INSERT INTO numbers (n) VALUES (908);
INSERT INTO numbers (n) VALUES (909);
INSERT INTO numbers (n) VALUES (910);
INSERT INTO numbers (n) VALUES (911);
INSERT INTO numbers (n) VALUES (912);
INSERT INTO numbers (n) VALUES (913);
INSERT INTO numbers (n) VALUES (914);
INSERT INTO numbers (n) VALUES (915);
INSERT INTO numbers (n) VALUES (916);
INSERT INTO numbers (n) VALUES (917);
INSERT INTO numbers (n) VALUES (918);
INSERT INTO numbers (n) VALUES (919);
INSERT INTO numbers (n) VALUES (920);
INSERT INTO numbers (n) VALUES (921);
INSERT INTO numbers (n) VALUES (922);
INSERT INTO numbers (n) VALUES (923);
INSERT INTO numbers (n) VALUES (924);
INSERT INTO numbers (n) VALUES (925);
INSERT INTO numbers (n) VALUES (926);
INSERT INTO numbers (n) VALUES (927);
INSERT INTO numbers (n) VALUES (928);
INSERT INTO numbers (n) VALUES (929);
INSERT INTO numbers (n) VALUES (930);
INSERT INTO numbers (n) VALUES (931);
INSERT INTO numbers (n) VALUES (932);
INSERT INTO numbers (n) VALUES (933);
INSERT INTO numbers (n) VALUES (934);
INSERT INTO numbers (n) VALUES (935);
INSERT INTO numbers (n) VALUES (936);
INSERT INTO numbers (n) VALUES (937);
INSERT INTO numbers (n) VALUES (938);
INSERT INTO numbers (n) VALUES (939);
INSERT INTO numbers (n) VALUES (940);
INSERT INTO numbers (n) VALUES (941);
INSERT INTO numbers (n) VALUES (942);
INSERT INTO numbers (n) VALUES (943);
INSERT INTO numbers (n) VALUES (944);
INSERT INTO numbers (n) VALUES (945);
INSERT INTO numbers (n) VALUES (946);
INSERT INTO numbers (n) VALUES (947);
INSERT INTO numbers (n) VALUES (948);
INSERT INTO numbers (n) VALUES (949);
INSERT INTO numbers (n) VALUES (950);
INSERT INTO numbers (n) VALUES (951);
INSERT INTO numbers (n) VALUES (952);
INSERT INTO numbers (n) VALUES (953);
INSERT INTO numbers (n) VALUES (954);
INSERT INTO numbers (n) VALUES (955);
INSERT INTO numbers (n) VALUES (956);
INSERT INTO numbers (n) VALUES (957);
INSERT INTO numbers (n) VALUES (958);
INSERT INTO numbers (n) VALUES (959);
INSERT INTO numbers (n) VALUES (960);
INSERT INTO numbers (n) VALUES (961);
INSERT INTO numbers (n) VALUES (962);
INSERT INTO numbers (n) VALUES (963);
INSERT INTO numbers (n) VALUES (964);
INSERT INTO numbers (n) VALUES (965);
INSERT INTO numbers (n) VALUES (966);
INSERT INTO numbers (n) VALUES (967);
INSERT INTO numbers (n) VALUES (968);
INSERT INTO numbers (n) VALUES (969);
INSERT INTO numbers (n) VALUES (970);
INSERT INTO numbers (n) VALUES (971);
INSERT INTO numbers (n) VALUES (972);
INSERT INTO numbers (n) VALUES (973);
INSERT INTO numbers (n) VALUES (974);
INSERT INTO numbers (n) VALUES (975);
INSERT INTO numbers (n) VALUES (976);
INSERT INTO numbers (n) VALUES (977);
INSERT INTO numbers (n) VALUES (978);
INSERT INTO numbers (n) VALUES (979);
INSERT INTO numbers (n) VALUES (980);
INSERT INTO numbers (n) VALUES (981);
INSERT INTO numbers (n) VALUES (982);
INSERT INTO numbers (n) VALUES (983);
INSERT INTO numbers (n) VALUES (984);
INSERT INTO numbers (n) VALUES (985);
INSERT INTO numbers (n) VALUES (986);
INSERT INTO numbers (n) VALUES (987);
INSERT INTO numbers (n) VALUES (988);
INSERT INTO numbers (n) VALUES (989);
INSERT INTO numbers (n) VALUES (990);
INSERT INTO numbers (n) VALUES (991);
INSERT INTO numbers (n) VALUES (992);
INSERT INTO numbers (n) VALUES (993);
INSERT INTO numbers (n) VALUES (994);
INSERT INTO numbers (n) VALUES (995);
INSERT INTO numbers (n) VALUES (996);
INSERT INTO numbers (n) VALUES (997);
INSERT INTO numbers (n) VALUES (998);
INSERT INTO numbers (n) VALUES (999);


--
-- TOC entry 2897 (class 0 OID 0)
-- Dependencies: 212
-- Name: ppd_ppd_id_seq; Type: SEQUENCE SET; Schema: jsharmony; Owner: postgres
--

SELECT pg_catalog.setval('ppd_ppd_id_seq', 45, true);


--
-- TOC entry 2856 (class 0 OID 45385)
-- Dependencies: 213
-- Data for Name: ppp; Type: TABLE DATA; Schema: jsharmony; Owner: postgres
--



--
-- TOC entry 2898 (class 0 OID 0)
-- Dependencies: 214
-- Name: ppp_ppp_id_seq; Type: SEQUENCE SET; Schema: jsharmony; Owner: postgres
--

SELECT pg_catalog.setval('ppp_ppp_id_seq', 1, false);


--
-- TOC entry 2858 (class 0 OID 45451)
-- Dependencies: 229
-- Data for Name: sf; Type: TABLE DATA; Schema: jsharmony; Owner: postgres
--

INSERT INTO sf (sf_id, sf_seq, sf_sts, sf_name, sf_desc, sf_snotes, sf_code, sf_attrib) VALUES (1, 1, 'ACTIVE', 'TBD', 'TBD', NULL, NULL, NULL);


--
-- TOC entry 2899 (class 0 OID 0)
-- Dependencies: 230
-- Name: sf_sf_id_seq; Type: SEQUENCE SET; Schema: jsharmony; Owner: postgres
--

SELECT pg_catalog.setval('sf_sf_id_seq', 2, true);


--
-- TOC entry 2900 (class 0 OID 0)
-- Dependencies: 232
-- Name: sm_sm_id_auto_seq; Type: SEQUENCE SET; Schema: jsharmony; Owner: postgres
--

SELECT pg_catalog.setval('sm_sm_id_auto_seq', 63, true);


--
-- TOC entry 2862 (class 0 OID 45481)
-- Dependencies: 237
-- Data for Name: sr; Type: TABLE DATA; Schema: jsharmony; Owner: postgres
--

INSERT INTO sr (sr_id, sr_seq, sr_sts, sr_name, sr_desc, sr_snotes, sr_code, sr_attrib) VALUES (11, 0, 'ACTIVE', '*', 'All Users', NULL, NULL, NULL);
INSERT INTO sr (sr_id, sr_seq, sr_sts, sr_name, sr_desc, sr_snotes, sr_code, sr_attrib) VALUES (4, 97, 'ACTIVE', 'DADMIN', 'Data Administration', NULL, NULL, NULL);
INSERT INTO sr (sr_id, sr_seq, sr_sts, sr_name, sr_desc, sr_snotes, sr_code, sr_attrib) VALUES (1, 98, 'ACTIVE', 'SYSADMIN', 'System Administration', NULL, NULL, NULL);
INSERT INTO sr (sr_id, sr_seq, sr_sts, sr_name, sr_desc, sr_snotes, sr_code, sr_attrib) VALUES (16, 99, 'ACTIVE', 'DEV', 'Developer', NULL, NULL, NULL);
INSERT INTO sr (sr_id, sr_seq, sr_sts, sr_name, sr_desc, sr_snotes, sr_code, sr_attrib) VALUES (7, 91, 'ACTIVE', 'X_B', 'General Browse', NULL, NULL, NULL);
INSERT INTO sr (sr_id, sr_seq, sr_sts, sr_name, sr_desc, sr_snotes, sr_code, sr_attrib) VALUES (10, 92, 'ACTIVE', 'X_X', 'General BIUD', NULL, NULL, NULL);


--
-- TOC entry 2901 (class 0 OID 0)
-- Dependencies: 238
-- Name: sr_sr_id_seq; Type: SEQUENCE SET; Schema: jsharmony; Owner: postgres
--

SELECT pg_catalog.setval('sr_sr_id_seq', 16, true);


--
-- TOC entry 2864 (class 0 OID 45490)
-- Dependencies: 239
-- Data for Name: srm; Type: TABLE DATA; Schema: jsharmony; Owner: postgres
--

INSERT INTO srm (sm_id, srm_snotes, srm_id, sr_name) VALUES (2701, NULL, 74, 'SYSADMIN');
INSERT INTO srm (sm_id, srm_snotes, srm_id, sr_name) VALUES (2700, NULL, 73, 'SYSADMIN');
INSERT INTO srm (sm_id, srm_snotes, srm_id, sr_name) VALUES (10, NULL, 180, 'DEV');
INSERT INTO srm (sm_id, srm_snotes, srm_id, sr_name) VALUES (1700, NULL, 57, 'SYSADMIN');
INSERT INTO srm (sm_id, srm_snotes, srm_id, sr_name) VALUES (270, NULL, 51, 'SYSADMIN');
INSERT INTO srm (sm_id, srm_snotes, srm_id, sr_name) VALUES (200, NULL, 48, 'SYSADMIN');
INSERT INTO srm (sm_id, srm_snotes, srm_id, sr_name) VALUES (170, NULL, 46, 'SYSADMIN');
INSERT INTO srm (sm_id, srm_snotes, srm_id, sr_name) VALUES (2, NULL, 41, 'SYSADMIN');
INSERT INTO srm (sm_id, srm_snotes, srm_id, sr_name) VALUES (11, NULL, 181, 'DEV');
INSERT INTO srm (sm_id, srm_snotes, srm_id, sr_name) VALUES (12, NULL, 182, 'DEV');
INSERT INTO srm (sm_id, srm_snotes, srm_id, sr_name) VALUES (13, NULL, 183, 'DEV');
INSERT INTO srm (sm_id, srm_snotes, srm_id, sr_name) VALUES (14, NULL, 184, 'DEV');
INSERT INTO srm (sm_id, srm_snotes, srm_id, sr_name) VALUES (15, NULL, 185, 'DEV');
INSERT INTO srm (sm_id, srm_snotes, srm_id, sr_name) VALUES (170, NULL, 186, 'DEV');
INSERT INTO srm (sm_id, srm_snotes, srm_id, sr_name) VALUES (1700, NULL, 187, 'DEV');
INSERT INTO srm (sm_id, srm_snotes, srm_id, sr_name) VALUES (16, NULL, 188, 'DEV');
INSERT INTO srm (sm_id, srm_snotes, srm_id, sr_name) VALUES (17, NULL, 189, 'DEV');
INSERT INTO srm (sm_id, srm_snotes, srm_id, sr_name) VALUES (18, NULL, 190, 'DEV');
INSERT INTO srm (sm_id, srm_snotes, srm_id, sr_name) VALUES (19, NULL, 191, 'DEV');
INSERT INTO srm (sm_id, srm_snotes, srm_id, sr_name) VALUES (20, NULL, 192, 'DEV');
INSERT INTO srm (sm_id, srm_snotes, srm_id, sr_name) VALUES (21, NULL, 193, 'DEV');
INSERT INTO srm (sm_id, srm_snotes, srm_id, sr_name) VALUES (22, NULL, 194, 'DEV');
INSERT INTO srm (sm_id, srm_snotes, srm_id, sr_name) VALUES (1786, NULL, 200, 'SYSADMIN');
INSERT INTO srm (sm_id, srm_snotes, srm_id, sr_name) VALUES (1795, NULL, 201, 'SYSADMIN');
INSERT INTO srm (sm_id, srm_snotes, srm_id, sr_name) VALUES (1796, NULL, 202, 'SYSADMIN');
INSERT INTO srm (sm_id, srm_snotes, srm_id, sr_name) VALUES (3, NULL, 204, '*');
INSERT INTO srm (sm_id, srm_snotes, srm_id, sr_name) VALUES (1787, NULL, 58, 'SYSADMIN');
INSERT INTO srm (sm_id, srm_snotes, srm_id, sr_name) VALUES (1785, NULL, 197, 'SYSADMIN');
INSERT INTO srm (sm_id, srm_snotes, srm_id, sr_name) VALUES (1783, NULL, 59, 'SYSADMIN');
INSERT INTO srm (sm_id, srm_snotes, srm_id, sr_name) VALUES (1784, NULL, 81, 'SYSADMIN');
INSERT INTO srm (sm_id, srm_snotes, srm_id, sr_name) VALUES (1781, NULL, 199, 'SYSADMIN');
INSERT INTO srm (sm_id, srm_snotes, srm_id, sr_name) VALUES (1782, NULL, 198, 'SYSADMIN');
INSERT INTO srm (sm_id, srm_snotes, srm_id, sr_name) VALUES (1601, NULL, 205, 'SYSADMIN');
INSERT INTO srm (sm_id, srm_snotes, srm_id, sr_name) VALUES (160, NULL, 206, 'SYSADMIN');


--
-- TOC entry 2902 (class 0 OID 0)
-- Dependencies: 240
-- Name: srm_srm_id_seq; Type: SEQUENCE SET; Schema: jsharmony; Owner: postgres
--

SELECT pg_catalog.setval('srm_srm_id_seq', 206, true);


--
-- TOC entry 2879 (class 0 OID 45662)
-- Dependencies: 257
-- Data for Name: ucod_txt_type; Type: TABLE DATA; Schema: jsharmony; Owner: postgres
--

INSERT INTO ucod_txt_type (ucod_id, codseq, codeval, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (12, 2, 'HTML', 'HTML', NULL, NULL, NULL, '2017-05-09 14:38:25.667012', 'Upostgres', '2017-05-09 14:38:25.667012', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod_txt_type (ucod_id, codseq, codeval, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (13, 1, 'TEXT', 'Text', NULL, NULL, NULL, '2017-05-09 14:38:25.667012', 'Upostgres', '2017-05-09 14:38:25.667012', 'Upostgres', NULL, NULL, NULL);


--
-- TOC entry 2866 (class 0 OID 45495)
-- Dependencies: 241
-- Data for Name: txt; Type: TABLE DATA; Schema: jsharmony; Owner: postgres
--

INSERT INTO txt (txt_id, txt_process, txt_attrib, txt_type, txt_tval, txt_val, txt_bcc, txt_desc, txt_etstmp, txt_eu, txt_mtstmp, txt_mu) VALUES (8, 'EMAIL', 'RESETPASS', 'HTML', 'Password Reset', '<p>Dear <%-data.PE_NAME%>,<br />
<br />
A password reset has been requested on your account. If you did not initiate the request, please contact us at <%-data.SUPPORT_EMAIL%> immediately.<br />
<br />
Please follow the link below to reset your password:<br />
<a href="<%-data.RESET_LINK%>"><%-data.RESET_LINK%></a></p>
', NULL, '<%-data.PE_NAME%> User Name
<%-data.SUPPORT_EMAIL%> Support Email
<%-data.RESET_LINK%> Reset Link', '2017-06-18 17:14:24.03848', 'Upostgres', '2017-10-17 12:43:26.569018', 'S3');
INSERT INTO txt (txt_id, txt_process, txt_attrib, txt_type, txt_tval, txt_val, txt_bcc, txt_desc, txt_etstmp, txt_eu, txt_mtstmp, txt_mu) VALUES (10, 'CMS', 'AGREEMENT', 'HTML', 'Client Agreement', NULL, NULL, 'Client Agreement', '2017-06-18 17:14:24.117928', 'Upostgres', '2017-10-17 12:43:42.879619', 'S3');
INSERT INTO txt (txt_id, txt_process, txt_attrib, txt_type, txt_tval, txt_val, txt_bcc, txt_desc, txt_etstmp, txt_eu, txt_mtstmp, txt_mu) VALUES (11, 'CMS', 'AGREEMENT_DONE', 'HTML', 'Client Agreement Complete', '<p>Thank you for completing sign-up.</p>
', NULL, 'Client Agreement Complete', '2017-06-18 17:14:24.096656', 'Upostgres', '2017-10-18 12:01:03.15238', 'S3');
INSERT INTO txt (txt_id, txt_process, txt_attrib, txt_type, txt_tval, txt_val, txt_bcc, txt_desc, txt_etstmp, txt_eu, txt_mtstmp, txt_mu) VALUES (13, 'SMS', 'WELCOME', 'TEXT', 'Welcome', 'Your account has been initialized.', NULL, 'SMS Welcome Message', '2017-06-18 17:14:24.085617', 'Upostgres', '2017-10-18 12:01:31.046944', 'S3');
INSERT INTO txt (txt_id, txt_process, txt_attrib, txt_type, txt_tval, txt_val, txt_bcc, txt_desc, txt_etstmp, txt_eu, txt_mtstmp, txt_mu) VALUES (14, 'CMS', 'DASHBOARD', 'HTML', 'Dashboard Message of the Day', '<p>Welcome to the jsHarmony System</p>
', NULL, 'Dashboard Message of the Day', '2017-10-18 12:02:05.393644', 'S3', '2017-10-19 12:14:32.861784', 'S3');


--
-- TOC entry 2903 (class 0 OID 0)
-- Dependencies: 242
-- Name: txt_txt_id_seq; Type: SEQUENCE SET; Schema: jsharmony; Owner: postgres
--

SELECT pg_catalog.setval('txt_txt_id_seq', 14, true);


--
-- TOC entry 2868 (class 0 OID 45531)
-- Dependencies: 246
-- Data for Name: ucod2_country_state; Type: TABLE DATA; Schema: jsharmony; Owner: postgres
--

INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (208, NULL, 'CANADA', 'AB', 'Alberta', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (209, NULL, 'CANADA', 'BC', 'British Columbia', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (210, NULL, 'CANADA', 'MB', 'Manitoba', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (211, NULL, 'CANADA', 'NB', 'New Brunswick', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (212, NULL, 'CANADA', 'NL', 'Newfounland and Labrador', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (213, NULL, 'CANADA', 'NS', 'Nova Scotia', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (214, NULL, 'CANADA', 'NT', 'Northwest Territories', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (215, NULL, 'CANADA', 'NU', 'Nunavut', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (216, NULL, 'CANADA', 'ON', 'Ontario', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (217, NULL, 'CANADA', 'PE', 'Prince Edward Island', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (218, NULL, 'CANADA', 'QC', 'Quebec', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (219, NULL, 'CANADA', 'SK', 'Saskatchewan', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (220, NULL, 'CANADA', 'YT', 'Yukon', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (221, NULL, 'MEXICO', 'AG', 'Aguascalientes', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (222, NULL, 'MEXICO', 'BN', 'Baja California', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (223, NULL, 'MEXICO', 'BS', 'Baja California Sur', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (224, NULL, 'MEXICO', 'CA', 'Coahuila', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (225, NULL, 'MEXICO', 'CH', 'Chihuahua', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (226, NULL, 'MEXICO', 'CL', 'Colima', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (227, NULL, 'MEXICO', 'CM', 'Compeche', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (228, NULL, 'MEXICO', 'CP', 'Chiapas', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (229, NULL, 'MEXICO', 'DF', 'Federal District', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (230, NULL, 'MEXICO', 'DU', 'Durango', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (231, NULL, 'MEXICO', 'GR', 'Guerrero', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (232, NULL, 'MEXICO', 'GT', 'Guanajuato', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (233, NULL, 'MEXICO', 'HI', 'Hidalgo', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (234, NULL, 'MEXICO', 'JA', 'Jalisco', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (235, NULL, 'MEXICO', 'MC', 'Michoacan', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (236, NULL, 'MEXICO', 'MR', 'Morelos', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (237, NULL, 'MEXICO', 'MX', 'Mexico', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (238, NULL, 'MEXICO', 'NA', 'Nayarit', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (239, NULL, 'MEXICO', 'NL', 'Nuevo Leon', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (240, NULL, 'MEXICO', 'OA', 'Oaxaca', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (241, NULL, 'MEXICO', 'PU', 'Puebla', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (242, NULL, 'MEXICO', 'QE', 'Queretaro', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (243, NULL, 'MEXICO', 'QR', 'Quintana Roo', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (244, NULL, 'MEXICO', 'SI', 'Sinaloa', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (245, NULL, 'MEXICO', 'SL', 'San Luis Potosí', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (246, NULL, 'MEXICO', 'SO', 'Sonora', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (247, NULL, 'MEXICO', 'TB', 'Tabasco', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (248, NULL, 'MEXICO', 'TL', 'Tlaxcala', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (249, NULL, 'MEXICO', 'TM', 'Tamaulipas', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (250, NULL, 'MEXICO', 'VE', 'Veracruz', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (251, NULL, 'MEXICO', 'YU', 'Yucatán', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (252, NULL, 'MEXICO', 'ZA', 'Zacatecas', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (253, NULL, 'USA', 'AK', 'Alaska', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (254, NULL, 'USA', 'AL', 'Alabama', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (255, NULL, 'USA', 'AR', 'Arkansas', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (256, NULL, 'USA', 'AS', 'American Samoa', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (257, NULL, 'USA', 'AZ', 'Arizona', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (258, NULL, 'USA', 'CA', 'California', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (259, NULL, 'USA', 'CO', 'Colorado', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (260, NULL, 'USA', 'CT', 'Connecticut', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (261, NULL, 'USA', 'DC', 'District of Columbia', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (262, NULL, 'USA', 'DE', 'Delaware', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (263, NULL, 'USA', 'FL', 'Florida', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (264, NULL, 'USA', 'FM', 'Federated States of Micronesia', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (265, NULL, 'USA', 'GA', 'Georgia', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (266, NULL, 'USA', 'GU', 'Guam', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (267, NULL, 'USA', 'HI', 'Hawaii', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (268, NULL, 'USA', 'IA', 'Iowa', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (269, NULL, 'USA', 'ID', 'Idaho', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (270, NULL, 'USA', 'IL', 'Illinois', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (271, NULL, 'USA', 'IN', 'Indiana', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (272, NULL, 'USA', 'KS', 'Kansas', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (273, NULL, 'USA', 'KY', 'Kentucky', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (274, NULL, 'USA', 'LA', 'Louisiana', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (275, NULL, 'USA', 'MA', 'Massachusetts', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (276, NULL, 'USA', 'MD', 'Maryland', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (277, NULL, 'USA', 'ME', 'Maine', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (278, NULL, 'USA', 'MH', 'Marshall Islands', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (279, NULL, 'USA', 'MI', 'Michigan', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (280, NULL, 'USA', 'MN', 'Minnesota', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (281, NULL, 'USA', 'MO', 'Missouri', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (282, NULL, 'USA', 'MP', 'Northern Mariana Islands', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (283, NULL, 'USA', 'MS', 'Mississippi', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (284, NULL, 'USA', 'MT', 'Montana', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (285, NULL, 'USA', 'NC', 'North Carolina', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (286, NULL, 'USA', 'ND', 'North Dakota', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (287, NULL, 'USA', 'NE', 'Nebraska', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (288, NULL, 'USA', 'NH', 'New Hampshire', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (289, NULL, 'USA', 'NJ', 'New Jersey', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (290, NULL, 'USA', 'NM', 'New Mexico', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (291, NULL, 'USA', 'NV', 'Nevada', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (292, NULL, 'USA', 'NY', 'New York', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (293, NULL, 'USA', 'OH', 'Ohio', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (294, NULL, 'USA', 'OK', 'Oklahoma', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (295, NULL, 'USA', 'OR', 'Oregon', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (296, NULL, 'USA', 'PA', 'Pennsylvania', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (297, NULL, 'USA', 'PR', 'Puerto Rico', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (298, NULL, 'USA', 'PW', 'Palau', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (299, NULL, 'USA', 'RI', 'Rhode Island', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (300, NULL, 'USA', 'SC', 'South Carolina', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (301, NULL, 'USA', 'SD', 'South Dakota', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (302, NULL, 'USA', 'TN', 'Tennessee', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (303, NULL, 'USA', 'TX', 'Texas', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (304, NULL, 'USA', 'UT', 'Utah', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (305, NULL, 'USA', 'VA', 'Virginia', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (306, NULL, 'USA', 'VI', 'Virgin Islands', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (307, NULL, 'USA', 'VT', 'Vermont', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (308, NULL, 'USA', 'WA', 'Washington', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (309, NULL, 'USA', 'WI', 'Wisconsin', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (310, NULL, 'USA', 'WV', 'West Virginia', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod2_country_state (ucod2_id, codseq, codeval1, codeval2, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (311, NULL, 'USA', 'WY', 'Wyoming', NULL, NULL, NULL, '2017-06-16 18:29:20.155246', 'Upostgres', '2017-06-16 18:29:20.155246', 'Upostgres', NULL, NULL, NULL);


--
-- TOC entry 2883 (class 0 OID 49401)
-- Dependencies: 279
-- Data for Name: ucod2_h; Type: TABLE DATA; Schema: jsharmony; Owner: postgres
--

INSERT INTO ucod2_h (codename, codemean, codecodemean, cod_h_etstmp, cod_h_eu, cod_h_mtstmp, cod_h_mu, cod_snotes, codeattribmean, codeschema, ucod2_h_id) VALUES ('country_state', 'Country - States', NULL, '2017-06-25 17:04:39.531136', 'Upostgres', '2017-06-25 17:04:39.531136', 'Upostgres', NULL, NULL, 'jsharmony', 1);


--
-- TOC entry 2904 (class 0 OID 0)
-- Dependencies: 281
-- Name: ucod2_h_ucod2_h_id_seq; Type: SEQUENCE SET; Schema: jsharmony; Owner: postgres
--

SELECT pg_catalog.setval('ucod2_h_ucod2_h_id_seq', 6, true);


--
-- TOC entry 2869 (class 0 OID 45554)
-- Dependencies: 247
-- Data for Name: ucod_ac; Type: TABLE DATA; Schema: jsharmony; Owner: postgres
--

INSERT INTO ucod_ac (ucod_id, codseq, codeval, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (1, 1, 'ACTIVE', 'Active', NULL, NULL, NULL, '2017-05-07 11:33:24.301842', 'Upostgres', '2017-05-07 11:33:24.301842', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod_ac (ucod_id, codseq, codeval, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (2, 3, 'CLOSED', 'Closed', NULL, NULL, NULL, '2017-05-07 11:33:24.301842', 'Upostgres', '2017-05-07 11:33:24.301842', 'Upostgres', NULL, NULL, NULL);


--
-- TOC entry 2870 (class 0 OID 45564)
-- Dependencies: 248
-- Data for Name: ucod_ac1; Type: TABLE DATA; Schema: jsharmony; Owner: postgres
--

INSERT INTO ucod_ac1 (ucod_id, codseq, codeval, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (21, 1, 'A', 'Active', NULL, NULL, NULL, '2017-05-28 15:34:21.71573', 'Upostgres', '2017-05-28 15:34:21.71573', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod_ac1 (ucod_id, codseq, codeval, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (22, 2, 'C', 'Closed', NULL, NULL, NULL, '2017-05-28 15:34:21.71573', 'Upostgres', '2017-05-28 15:34:21.71573', 'Upostgres', NULL, NULL, NULL);


--
-- TOC entry 2872 (class 0 OID 45584)
-- Dependencies: 250
-- Data for Name: ucod_country; Type: TABLE DATA; Schema: jsharmony; Owner: postgres
--

INSERT INTO ucod_country (ucod_id, codseq, codeval, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (7, NULL, 'CANADA', 'CANADA', NULL, NULL, NULL, '2017-05-07 11:35:04.926156', 'Upostgres', '2017-05-07 11:35:04.926156', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod_country (ucod_id, codseq, codeval, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (8, NULL, 'MEXICO', 'MEXICO', NULL, NULL, NULL, '2017-05-07 11:35:04.926156', 'Upostgres', '2017-05-07 11:35:04.926156', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod_country (ucod_id, codseq, codeval, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (9, NULL, 'USA', 'USA', NULL, NULL, NULL, '2017-05-07 11:35:04.926156', 'Upostgres', '2017-05-07 11:35:04.926156', 'Upostgres', NULL, NULL, NULL);


--
-- TOC entry 2873 (class 0 OID 45594)
-- Dependencies: 251
-- Data for Name: ucod_d_scope; Type: TABLE DATA; Schema: jsharmony; Owner: postgres
--

INSERT INTO ucod_d_scope (ucod_id, codseq, codeval, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (14, 2, 'C', 'Customer', NULL, NULL, NULL, '2017-05-28 15:33:29.230786', 'Upostgres', '2017-05-28 15:33:29.230786', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod_d_scope (ucod_id, codseq, codeval, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (17, 1, 'S', 'System', NULL, NULL, NULL, '2017-05-28 15:33:29.230786', 'Upostgres', '2017-05-28 15:33:29.230786', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod_d_scope (ucod_id, codseq, codeval, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (16, 3, 'O', 'Order', NULL, NULL, NULL, '2017-05-28 15:33:29.230786', 'Upostgres', '2017-05-28 15:33:29.230786', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod_d_scope (ucod_id, codseq, codeval, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (20, 4, 'VEN', 'Vendor', NULL, NULL, NULL, '2017-05-28 15:33:29.230786', 'Upostgres', '2017-05-28 15:33:29.230786', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod_d_scope (ucod_id, codseq, codeval, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (3, 5, 'PE', 'User', NULL, NULL, NULL, '2017-10-19 17:56:29.139491', 'S3', '2017-10-19 17:56:29.139491', 'S3', NULL, NULL, NULL);


--
-- TOC entry 2882 (class 0 OID 49377)
-- Dependencies: 278
-- Data for Name: ucod_h; Type: TABLE DATA; Schema: jsharmony; Owner: postgres
--

INSERT INTO ucod_h (codename, codemean, codecodemean, cod_h_etstmp, cod_h_eu, cod_h_mtstmp, cod_h_mu, cod_snotes, codeattribmean, codeschema, ucod_h_id) VALUES ('ac', 'ACTIVE-CLOSED', NULL, '2017-06-25 17:04:39.48901', 'Upostgres', '2017-06-25 17:04:39.48901', 'Upostgres', NULL, NULL, 'jsharmony', 1);
INSERT INTO ucod_h (codename, codemean, codecodemean, cod_h_etstmp, cod_h_eu, cod_h_mtstmp, cod_h_mu, cod_snotes, codeattribmean, codeschema, ucod_h_id) VALUES ('ac1', 'ACTIVE-CLOSED 1 Character', NULL, '2017-06-25 17:04:39.48901', 'Upostgres', '2017-06-25 17:04:39.48901', 'Upostgres', NULL, NULL, 'jsharmony', 3);
INSERT INTO ucod_h (codename, codemean, codecodemean, cod_h_etstmp, cod_h_eu, cod_h_mtstmp, cod_h_mu, cod_snotes, codeattribmean, codeschema, ucod_h_id) VALUES ('ahc', 'ACTIVE-HOLD-CLOSED', NULL, '2017-06-25 17:04:39.48901', 'Upostgres', '2017-06-25 17:04:39.48901', 'Upostgres', NULL, NULL, 'jsharmony', 10);
INSERT INTO ucod_h (codename, codemean, codecodemean, cod_h_etstmp, cod_h_eu, cod_h_mtstmp, cod_h_mu, cod_snotes, codeattribmean, codeschema, ucod_h_id) VALUES ('country', 'Country', NULL, '2017-06-25 17:04:39.48901', 'Upostgres', '2017-06-25 17:04:39.48901', 'Upostgres', NULL, NULL, 'jsharmony', 2);
INSERT INTO ucod_h (codename, codemean, codecodemean, cod_h_etstmp, cod_h_eu, cod_h_mtstmp, cod_h_mu, cod_snotes, codeattribmean, codeschema, ucod_h_id) VALUES ('d_scope', 'Document Scope', 'Client User Y/N', '2017-06-25 17:04:39.48901', 'Upostgres', '2017-06-25 17:04:39.48901', 'Upostgres', NULL, NULL, 'jsharmony', 9);
INSERT INTO ucod_h (codename, codemean, codecodemean, cod_h_etstmp, cod_h_eu, cod_h_mtstmp, cod_h_mu, cod_snotes, codeattribmean, codeschema, ucod_h_id) VALUES ('n_scope', 'Note Scope', NULL, '2017-06-25 17:04:39.48901', 'Upostgres', '2017-06-25 17:04:39.48901', 'Upostgres', NULL, NULL, 'jsharmony', 11);
INSERT INTO ucod_h (codename, codemean, codecodemean, cod_h_etstmp, cod_h_eu, cod_h_mtstmp, cod_h_mu, cod_snotes, codeattribmean, codeschema, ucod_h_id) VALUES ('n_type', 'Note Type', NULL, '2017-06-25 17:04:39.48901', 'Upostgres', '2017-06-25 17:04:39.48901', 'Upostgres', NULL, NULL, 'jsharmony', 8);
INSERT INTO ucod_h (codename, codemean, codecodemean, cod_h_etstmp, cod_h_eu, cod_h_mtstmp, cod_h_mu, cod_snotes, codeattribmean, codeschema, ucod_h_id) VALUES ('ppd_type', 'Parameter Type', NULL, '2017-06-25 17:04:39.48901', 'Upostgres', '2017-06-25 17:04:39.48901', 'Upostgres', NULL, NULL, 'jsharmony', 7);
INSERT INTO ucod_h (codename, codemean, codecodemean, cod_h_etstmp, cod_h_eu, cod_h_mtstmp, cod_h_mu, cod_snotes, codeattribmean, codeschema, ucod_h_id) VALUES ('rqst_atype', 'Request Action Type', NULL, '2017-06-25 17:04:39.48901', 'Upostgres', '2017-06-25 17:04:39.48901', 'Upostgres', NULL, NULL, 'jsharmony', 4);
INSERT INTO ucod_h (codename, codemean, codecodemean, cod_h_etstmp, cod_h_eu, cod_h_mtstmp, cod_h_mu, cod_snotes, codeattribmean, codeschema, ucod_h_id) VALUES ('rqst_source', 'Request Source', NULL, '2017-06-25 17:04:39.48901', 'Upostgres', '2017-06-25 17:04:39.48901', 'Upostgres', NULL, NULL, 'jsharmony', 5);
INSERT INTO ucod_h (codename, codemean, codecodemean, cod_h_etstmp, cod_h_eu, cod_h_mtstmp, cod_h_mu, cod_snotes, codeattribmean, codeschema, ucod_h_id) VALUES ('txt_type', 'Text Type', NULL, '2017-06-25 17:04:39.48901', 'Upostgres', '2017-06-25 17:04:39.48901', 'Upostgres', NULL, NULL, 'jsharmony', 6);
INSERT INTO ucod_h (codename, codemean, codecodemean, cod_h_etstmp, cod_h_eu, cod_h_mtstmp, cod_h_mu, cod_snotes, codeattribmean, codeschema, ucod_h_id) VALUES ('v_sts', 'Version Status', NULL, '2017-07-10 19:01:52.825199', 'Upostgres', '2017-07-10 19:01:52.825199', 'Upostgres', NULL, NULL, 'jsharmony', 13);


--
-- TOC entry 2905 (class 0 OID 0)
-- Dependencies: 280
-- Name: ucod_h_ucod_h_id_seq; Type: SEQUENCE SET; Schema: jsharmony; Owner: postgres
--

SELECT pg_catalog.setval('ucod_h_ucod_h_id_seq', 14, true);


--
-- TOC entry 2874 (class 0 OID 45608)
-- Dependencies: 252
-- Data for Name: ucod_n_scope; Type: TABLE DATA; Schema: jsharmony; Owner: postgres
--

INSERT INTO ucod_n_scope (ucod_id, codseq, codeval, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (23, 2, 'C', 'Customer', NULL, NULL, NULL, '2017-05-28 15:36:02.435529', 'Upostgres', '2017-05-28 15:36:02.435529', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod_n_scope (ucod_id, codseq, codeval, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (29, 1, 'S', 'System', NULL, NULL, NULL, '2017-05-28 15:36:02.435529', 'Upostgres', '2017-05-28 15:36:02.435529', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod_n_scope (ucod_id, codseq, codeval, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (24, 3, 'CT', 'Cust Contact', NULL, NULL, NULL, '2017-05-28 15:36:02.435529', 'Upostgres', '2017-05-28 15:36:02.435529', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod_n_scope (ucod_id, codseq, codeval, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (31, 4, 'VEN', 'Vendor', NULL, NULL, NULL, '2017-05-28 15:36:02.435529', 'Upostgres', '2017-05-28 15:36:02.435529', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod_n_scope (ucod_id, codseq, codeval, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (4, 5, 'PE', 'User', NULL, NULL, NULL, '2017-10-19 17:56:55.452087', 'S3', '2017-10-19 17:56:55.452087', 'S3', NULL, NULL, NULL);


--
-- TOC entry 2875 (class 0 OID 45618)
-- Dependencies: 253
-- Data for Name: ucod_n_type; Type: TABLE DATA; Schema: jsharmony; Owner: postgres
--

INSERT INTO ucod_n_type (ucod_id, codseq, codeval, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (33, 2, 'C', 'Client', NULL, NULL, NULL, '2017-05-28 15:36:58.576763', 'Upostgres', '2017-05-28 15:36:58.576763', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod_n_type (ucod_id, codseq, codeval, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (34, 3, 'S', 'System', NULL, NULL, NULL, '2017-05-28 15:36:58.576763', 'Upostgres', '2017-05-28 15:36:58.576763', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod_n_type (ucod_id, codseq, codeval, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (35, 1, 'U', 'User', NULL, NULL, NULL, '2017-05-28 15:36:58.576763', 'Upostgres', '2017-05-28 15:36:58.576763', 'Upostgres', NULL, NULL, NULL);


--
-- TOC entry 2877 (class 0 OID 45642)
-- Dependencies: 255
-- Data for Name: ucod_rqst_atype; Type: TABLE DATA; Schema: jsharmony; Owner: postgres
--

INSERT INTO ucod_rqst_atype (ucod_id, codseq, codeval, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (36, NULL, 'MESSAGE', 'Message', NULL, NULL, NULL, '2017-05-28 15:38:23.35886', 'Upostgres', '2017-05-28 15:38:23.35886', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod_rqst_atype (ucod_id, codseq, codeval, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (37, NULL, 'REPORT', 'Report Program', NULL, NULL, NULL, '2017-05-28 15:38:23.35886', 'Upostgres', '2017-05-28 15:38:23.35886', 'Upostgres', NULL, NULL, NULL);


--
-- TOC entry 2878 (class 0 OID 45652)
-- Dependencies: 256
-- Data for Name: ucod_rqst_source; Type: TABLE DATA; Schema: jsharmony; Owner: postgres
--

INSERT INTO ucod_rqst_source (ucod_id, codseq, codeval, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (38, NULL, 'ADMIN', 'Administrator Interface', NULL, NULL, NULL, '2017-05-28 15:38:41.42154', 'Upostgres', '2017-05-28 15:38:41.42154', 'Upostgres', NULL, NULL, NULL);
INSERT INTO ucod_rqst_source (ucod_id, codseq, codeval, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (39, NULL, 'CLIENT', 'Client Interface', NULL, NULL, NULL, '2017-05-28 15:38:41.42154', 'Upostgres', '2017-05-28 15:38:41.42154', 'Upostgres', NULL, NULL, NULL);


--
-- TOC entry 2886 (class 0 OID 54226)
-- Dependencies: 282
-- Data for Name: ucod_v_sts; Type: TABLE DATA; Schema: jsharmony; Owner: postgres
--

INSERT INTO ucod_v_sts (ucod_id, codseq, codeval, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (1, 2, 'ERROR', 'Error', NULL, NULL, NULL, '2017-07-10 19:03:54.540163', 'S3', '2017-07-10 19:03:54.540163', 'S3', NULL, NULL, NULL);
INSERT INTO ucod_v_sts (ucod_id, codseq, codeval, codetxt, codecode, codetdt, codetcm, cod_etstmp, cod_eu, cod_mtstmp, cod_mu, cod_snotes, cod_notes, codeattrib) VALUES (2, 1, 'OK', 'OK', NULL, NULL, NULL, '2017-07-10 19:04:04.470394', 'S3', '2017-07-10 19:04:04.470394', 'S3', NULL, NULL, NULL);


--
-- TOC entry 2880 (class 0 OID 45707)
-- Dependencies: 266
-- Data for Name: xpp; Type: TABLE DATA; Schema: jsharmony; Owner: postgres
--

INSERT INTO xpp (xpp_id, xpp_process, xpp_attrib, xpp_val, xpp_etstmp, xpp_eu, xpp_mtstmp, xpp_mu) VALUES (2, 'USERS', 'HASH_SEED_C', 'w3vefSQ@aewfa@#V5awdfA@#Rdf2%V235wfAF@#%csdfsfvq235@EFSDFAV2352vswfAW@V#%@', '2017-06-18 17:14:25.282391', 'Upostgres', '2017-06-18 17:14:25.282391', 'Upostgres');
INSERT INTO xpp (xpp_id, xpp_process, xpp_attrib, xpp_val, xpp_etstmp, xpp_eu, xpp_mtstmp, xpp_mu) VALUES (3, 'USERS', 'HASH_SEED_S', 'frtue5 i876h4567h*&IOJK*()9%UHJS$6agfghjdyszwetsbfg5&$&$TFB5763bergereg', '2017-06-18 17:14:25.297538', 'Upostgres', '2017-06-18 17:14:25.297538', 'Upostgres');
INSERT INTO xpp (xpp_id, xpp_process, xpp_attrib, xpp_val, xpp_etstmp, xpp_eu, xpp_mtstmp, xpp_mu) VALUES (13, 'SQL', 'DSCOPE_DCTGR', 'gcod2_d_scope_d_ctgr', '2017-06-18 17:14:25.311607', 'Upostgres', '2017-06-18 17:14:25.311607', 'Upostgres');
INSERT INTO xpp (xpp_id, xpp_process, xpp_attrib, xpp_val, xpp_etstmp, xpp_eu, xpp_mtstmp, xpp_mu) VALUES (14, 'SQL', 'GETCID', 'public.get_c_id', '2017-06-18 17:14:25.317611', 'Upostgres', '2017-06-18 17:14:25.317611', 'Upostgres');
INSERT INTO xpp (xpp_id, xpp_process, xpp_attrib, xpp_val, xpp_etstmp, xpp_eu, xpp_mtstmp, xpp_mu) VALUES (15, 'SQL', 'GETEID', 'public.get_e_id', '2017-06-18 17:14:25.324813', 'Upostgres', '2017-06-18 17:14:25.324813', 'Upostgres');
INSERT INTO xpp (xpp_id, xpp_process, xpp_attrib, xpp_val, xpp_etstmp, xpp_eu, xpp_mtstmp, xpp_mu) VALUES (16, 'SYSTEM', 'CLIENT_SYS_URL', 'https://localhost', '2017-06-18 17:14:25.332819', 'Upostgres', '2017-10-17 12:23:34.708185', 'S3');
INSERT INTO xpp (xpp_id, xpp_process, xpp_attrib, xpp_val, xpp_etstmp, xpp_eu, xpp_mtstmp, xpp_mu) VALUES (1, 'EMAIL', 'NOTIF_SYS', 'user@company.com', '2017-06-18 17:14:25.304602', 'Upostgres', '2017-10-17 12:24:06.270302', 'S3');


--
-- TOC entry 2906 (class 0 OID 0)
-- Dependencies: 272
-- Name: xpp_xpp_id_seq; Type: SEQUENCE SET; Schema: jsharmony; Owner: postgres
--

SELECT pg_catalog.setval('xpp_xpp_id_seq', 16, true);


-- Completed on 2017-10-24 16:36:36

--
-- PostgreSQL database dump complete
--

