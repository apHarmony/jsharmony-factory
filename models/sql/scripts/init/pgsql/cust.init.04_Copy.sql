SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = {schema}, pg_catalog;

INSERT INTO code_doc_scope (code_seq, code_val, code_txt, code_code, code_end_dt, code_end_reason, code_snotes, code_notes, code_attrib) VALUES (2, 'C', 'Customer', 'cust', NULL, NULL, NULL, NULL, NULL);
INSERT INTO code_note_scope (code_seq, code_val, code_txt, code_code, code_end_dt, code_end_reason, code_snotes, code_notes, code_attrib) VALUES (2, 'C', 'Customer', 'cust', NULL, NULL, NULL, NULL, NULL);

INSERT INTO cust_role (cust_role_seq, cust_role_sts, cust_role_name, cust_role_desc, cust_role_snotes, cust_role_code, cust_role_attrib) VALUES (0, 'ACTIVE', 'C*', 'All Users', NULL, NULL, NULL);
INSERT INTO cust_role (cust_role_seq, cust_role_sts, cust_role_name, cust_role_desc, cust_role_snotes, cust_role_code, cust_role_attrib) VALUES (1, 'ACTIVE', 'CUSER', 'Client User', NULL, NULL, NULL);
INSERT INTO cust_role (cust_role_seq, cust_role_sts, cust_role_name, cust_role_desc, cust_role_snotes, cust_role_code, cust_role_attrib) VALUES (2, 'ACTIVE', 'CSYSADMIN', 'Administrator', NULL, NULL, NULL);
INSERT INTO cust_role (cust_role_seq, cust_role_sts, cust_role_name, cust_role_desc, cust_role_snotes, cust_role_code, cust_role_attrib) VALUES (3, 'ACTIVE', 'CX_B', 'Browse', NULL, NULL, NULL);
INSERT INTO cust_role (cust_role_seq, cust_role_sts, cust_role_name, cust_role_desc, cust_role_snotes, cust_role_code, cust_role_attrib) VALUES (4, 'ACTIVE', 'CX_X', 'Entry / Update', NULL, NULL, NULL);

INSERT INTO menu__tbl (menu_group, menu_id, menu_sts, menu_id_parent, menu_name, menu_seq, menu_desc, menu_desc_ext, menu_desc_ext2, menu_cmd, menu_image, menu_snotes, menu_subcmd) VALUES ('S', 90020, 'ACTIVE', 900, 'Dev/CustRole_Listing', 90013, 'Client User Roles', NULL, NULL, '%%%NAMESPACE%%%Dev/CustRole_Listing', NULL, NULL, NULL);

INSERT INTO menu__tbl (menu_group, menu_id, menu_sts, menu_id_parent, menu_name, menu_seq, menu_desc, menu_desc_ext, menu_desc_ext2, menu_cmd, menu_image, menu_snotes, menu_subcmd) VALUES ('C', 2, 'ACTIVE', NULL, 'CLIENT', NULL, 'Customer', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO menu__tbl (menu_group, menu_id, menu_sts, menu_id_parent, menu_name, menu_seq, menu_desc, menu_desc_ext, menu_desc_ext2, menu_cmd, menu_image, menu_snotes, menu_subcmd) VALUES ('C', 200, 'ACTIVE', 2, 'Client/Dashboard', NULL, 'Dashboard', NULL, NULL, '%%%NAMESPACE%%%Client/Dashboard', NULL, NULL, NULL);
INSERT INTO menu__tbl (menu_group, menu_id, menu_sts, menu_id_parent, menu_name, menu_seq, menu_desc, menu_desc_ext, menu_desc_ext2, menu_cmd, menu_image, menu_snotes, menu_subcmd) VALUES ('C', 2800, 'ACTIVE', 2, 'Client/Admin', 280000, 'Administration', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO menu__tbl (menu_group, menu_id, menu_sts, menu_id_parent, menu_name, menu_seq, menu_desc, menu_desc_ext, menu_desc_ext2, menu_cmd, menu_image, menu_snotes, menu_subcmd) VALUES ('C', 280000, 'ACTIVE', 2800, 'Client/Admin/CustUser_Listing', NULL, 'Users', NULL, NULL, '%%%NAMESPACE%%%Client/Admin/CustUser_Listing', NULL, NULL, NULL);

INSERT INTO cust_menu_role (menu_id, cust_menu_role_snotes, cust_role_name) VALUES (200, NULL, 'CX_B');
INSERT INTO cust_menu_role (menu_id, cust_menu_role_snotes, cust_role_name) VALUES (2800, NULL, 'CSYSADMIN');
INSERT INTO cust_menu_role (menu_id, cust_menu_role_snotes, cust_role_name) VALUES (280000, NULL, 'CSYSADMIN');
INSERT INTO cust_menu_role (menu_id, cust_menu_role_snotes, cust_role_name) VALUES (200, NULL, 'CX_X');
INSERT INTO cust_menu_role (menu_id, cust_menu_role_snotes, cust_role_name) VALUES (200, NULL, 'CUSER');

INSERT INTO sys_menu_role (menu_id, sys_menu_role_snotes, sys_role_name) VALUES (90020, NULL, 'DEV');

INSERT INTO sys_menu_role (menu_id, sys_menu_role_snotes, sys_role_name) VALUES (2, NULL, 'SYSADMIN');
INSERT INTO sys_menu_role (menu_id, sys_menu_role_snotes, sys_role_name) VALUES (200, NULL, 'SYSADMIN');
INSERT INTO sys_menu_role (menu_id, sys_menu_role_snotes, sys_role_name) VALUES (2800, NULL, 'SYSADMIN');
INSERT INTO sys_menu_role (menu_id, sys_menu_role_snotes, sys_role_name) VALUES (280000, NULL, 'SYSADMIN');

INSERT INTO param__tbl (param_process, param_attrib, param_desc, param_type, code_name, param_snotes, is_param_app, is_param_user, is_param_sys) VALUES ('USERS', 'HASH_SEED_C', 'Hash Seed Client Users', 'C', NULL, NULL, false, false, true);
INSERT INTO param_sys (param_sys_process, param_sys_attrib, param_sys_val) VALUES ('USERS', 'HASH_SEED_C', 'NOT CONFIGURED');

INSERT INTO txt__tbl (txt_process, txt_attrib, txt_type, txt_title, txt_body, txt_bcc, txt_desc) VALUES ('CMS', 'Client/Agreement', 'HTML', 'Client Agreement', NULL, NULL, 'Client Agreement');
INSERT INTO txt__tbl (txt_process, txt_attrib, txt_type, txt_title, txt_body, txt_bcc, txt_desc) VALUES ('CMS', 'Client/Agreement_Complete', 'HTML', 'Client Agreement Complete', '<p>Thank you for completing sign-up.</p>
', NULL, 'Client Agreement Complete');
INSERT INTO txt__tbl (txt_process, txt_attrib, txt_type, txt_title, txt_body, txt_bcc, txt_desc) VALUES ('CMS', 'Client/Dashboard', 'HTML', 'Client Dashboard Message of the Day', '<p>Welcome to the jsHarmony Client Portal</p>
', NULL, 'Client Dashboard Message of the Day');
