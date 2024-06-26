/*
Copyright 2017 apHarmony

This file is part of jsHarmony.

jsHarmony is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

jsHarmony is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this package.  If not, see <http://www.gnu.org/licenses/>.
*/

var transform = { };

transform.tables = {
  'audit__tbl': 'aud_h',
  'audit_detail': 'aud_d',
  'sys_user': 'pe',
  'sys_role': 'sr',
  'sys_func': 'sf',
  'sys_user_role': 'sper',
  'sys_user_func': 'spef',
  'menu__tbl': 'sm',
  'sys_menu_role': 'srm',
  'cust_user': 'cpe',
  'cust_role': 'cr',
  'cust_user_role': 'cper',
  'cust_menu_role': 'crm',
  'doc__tbl': 'd',
  'single': 'dual',
  'number__tbl': 'numbers',
  'note__tbl': 'n',
  'txt__tbl': 'txt',
  'version__tbl': 'v',
  'help__tbl': 'h',
  'help_target': 'hp',
  'code_app': 'gcod_h',
  'code_sys': 'ucod_h',
  'code_app_': 'gcod_',
  'code_sys_': 'ucod_',
  'code_app_base': 'gcod',
  'code_sys_base': 'ucod',
  'code_app_prefix': 'gcod',
  'code_sys_prefix': 'ucod',
  'code_ac': 'ucod_ac',
  'code_ac1': 'ucod_ac1',
  'code_ahc': 'ucod_ahc',
  'code_country': 'ucod_country',
  'code_doc_scope': 'ucod_d_scope',
  'code_param_user_process': 'ucod_ppp_process_v',
  'code_param_app_process': 'ucod_gpp_process_v',
  'code_param_sys_process': 'ucod_xpp_process_v',
  'code2_app': 'gcod2_h',
  'code2_sys': 'ucod2_h',
  'code2_app_': 'gcod2_',
  'code2_sys_': 'ucod2_',
  'code2_app_base': 'gcod2',
  'code2_sys_base': 'ucod2',
  'code2_app_prefix': 'gcod2',
  'code2_sys_prefix': 'ucod2',
  'code2_doc_scope_doc_ctgr': 'gcod2_d_scope_d_ctgr',
  'code2_country_state': 'ucod2_country_state',
  'code2_param_user_attrib': 'ucod2_ppp_process_attrib_v',
  'code2_param_app_attrib': 'ucod2_gpp_process_attrib_v',
  'code2_param_sys_attrib': 'ucod2_xpp_process_attrib_v',
  'code_note_scope': 'ucod_n_scope',
  'code_note_type': 'ucod_n_type',
  'code_param_type': 'ucod_ppd_type',
  'code_job_action': 'ucod_rqst_atype',
  'code_job_source': 'ucod_rqst_source',
  'code_txt_type': 'ucod_txt_type',
  'code_version_sts': 'ucod_v_sts',
  'queue__tbl': 'rq',
  'job__tbl': 'rqst',
  'job_doc': 'rqst_d',
  'job_email': 'rqst_email',
  'job_note': 'rqst_n',
  'job_queue': 'rqst_rq',
  'job_sms': 'rqst_sms',
  'param__tbl': 'ppd',
  'param_user': 'ppp',
  'param_app': 'gpp',
  'param_sys': 'xpp',
  'v_audit_detail': 'v_audl_raw',
  'v_cust_user_nostar': 'v_cper_nostar',
  'v_sys_menu_role_selection': 'v_srmsel',
  'v_cust_menu_role_selection': 'v_crmsel',
  'v_param': 'v_ppdl',
  'v_param_cur': 'v_pp',
  'v_param_user': 'v_pppl',
  'v_param_app': 'v_gppl',
  'v_param_sys': 'v_xppl',
  'v_app_info': 'v_house',
  'v_month': 'v_months',
  'v_year': 'v_years',
  'v_my_roles': 'v_my_roles',
  'v_my_user': 'v_mype',
  'v_doc': 'v_dl',
  'v_doc_ext': 'v_d_ext',
  'v_doc_filename': 'v_d_x',
  'v_note': 'v_nl',
  'v_note_ext': 'v_n_ext'
};

transform.fields = {
  'audit_op': 'aud_op',
  'audit_seq': 'aud_seq',
  'audit_tstmp': 'aud_tstmp',
  'audit_user': 'aud_u',
  'cust_id': 'c_id',
  'cust_name': 'c_name',
  'cust_name_ext': 'c_name_ext',
  'code_etstmp': 'cod_etstmp',
  'code_euser': 'cod_eu',
  'code_euser_fmt': 'cod_eu_fmt',
  'code_h_etstmp': 'cod_h_etstmp',
  'code_h_euser': 'cod_h_eu',
  'code_h_mtstmp': 'cod_h_mtstmp',
  'code_h_muser': 'cod_h_mu',
  'code_type': 'codetype',
  'code_mtstmp': 'cod_mtstmp',
  'code_muser': 'cod_mu',
  'code_muser_fmt': 'cod_mu_fmt',
  'code_notes': 'cod_notes',
  'code_snotes': 'cod_snotes',
  'code_attrib': 'codeattrib',
  'code_attrib_desc': 'codeattribmean',
  'code_code': 'codecode',
  'code_code_desc': 'codecodemean',
  'code_desc': 'codemean',
  'code_name': 'codename',
  'code_schema': 'codeschema',
  'code_end_reason': 'codetcm',
  'code_end_dt': 'codetdt',
  'code_txt': 'codetxt',
  'code_val': 'codeval',
  'code_val1': 'codeval1',
  'code_val2': 'codeval2',
  'code_seq': 'codseq',
  'code_icon': 'codeicon',
  'code_id': 'codeid',
  'code_parent': 'codeparent',
  'code_parent_id': 'codeparentid',
  'audit_column_name': 'column_name',
  'audit_column_val': 'column_val',
  'cust_user_role_id': 'cper_id',
  'cust_user_role_snotes': 'cper_snotes',
  'cust_role_attrib': 'cr_attrib',
  'cust_role_code': 'cr_code',
  'cust_role_desc': 'cr_desc',
  'cust_role_id': 'cr_id',
  'cust_role_name': 'cr_name',
  'cust_role_seq': 'cr_seq',
  'cust_role_snotes': 'cr_snotes',
  'cust_role_sts': 'cr_sts',
  'cust_menu_role_id': 'crm_id',
  'cust_menu_role_snotes': 'crm_snotes',
  'cust_menu_role_selection': 'crmsel_sel',
  'doc_ctgr': 'd_ctgr',
  'doc_ctgr_txt': 'd_ctgr_txt',
  'doc_desc': 'd_desc',
  'doc_etstmp': 'd_etstmp',
  'doc_euser': 'd_eu',
  'doc_euser_fmt': 'd_eu_fmt',
  'doc_ext': 'd_ext',
  'doc_filename': 'd_filename',
  'doc_id': 'd_id',
  'doc_sync_id': 'd_id_main',
  'doc_datalock': 'd_lock',
  'doc_mtstmp': 'd_mtstmp',
  'doc_muser': 'd_mu',
  'doc_muser_fmt': 'd_mu_fmt',
  'doc_scope': 'd_scope',
  'doc_scope_id': 'd_scope_id',
  'doc_size': 'd_size',
  'doc_snotes': 'd_snotes',
  'doc_sts': 'd_sts',
  'doc_sync_tstmp': 'd_synctstmp',
  'doc_uptstmp': 'd_utstmp',
  'doc_upuser': 'd_uu',
  'doc_img': 'D_IMG',
  'doc_file': 'd_file',
  'db_id': 'db_k',
  'dual_bigint': 'dual_bigint',
  'single_ident': 'dual_ident',
  'single_integer': 'dual_integer',
  'dual_nvarchar50': 'dual_nvarchar50',
  'single_text': 'dual_text',
  'single_dummy': 'dummy',
  'item_id': 'e_id',
  'item_name': 'e_name',
  'email_attach': 'email_attach',
  'email_bcc': 'email_bcc',
  'email_cc': 'email_cc',
  'email_doc_id': 'email_d_id',
  'email_doc_filename': 'email_d_filename',
  'email_html': 'email_html',
  'email_subject': 'email_subject',
  'email_text': 'email_text',
  'email_to': 'email_to',
  'email_txt_attrib': 'email_txt_attrib',
  'code_app_h_id': 'gcod_h_id',
  'code_app_id': 'gcod_id',
  'code2_app_h_id': 'gcod2_h_id',
  'code2_app_id': 'gcod2_id',
  'param_app_attrib': 'gpp_attrib',
  'param_app_etstmp': 'gpp_etstmp',
  'param_app_euser': 'gpp_eu',
  'param_app_id': 'gpp_id',
  'param_app_info': 'gpp_info',
  'param_app_mtstmp': 'gpp_mtstmp',
  'param_app_muser': 'gpp_mu',
  'param_app_process': 'gpp_process',
  'param_app_val': 'gpp_val',
  'help_etstmp': 'h_etstmp',
  'help_euser': 'h_eu',
  'help_id': 'h_id',
  'help_listing_main': 'h_index_a',
  'help_listing_client': 'h_index_p',
  'help_mtstmp': 'h_mtstmp',
  'help_muser': 'h_mu',
  'help_seq': 'h_seq',
  'help_text': 'h_text',
  'help_title': 'h_title',
  'help_unq_code': 'h_unique',
  'app_addr': 'house_addr',
  'app_bphone': 'house_bphone',
  'app_city': 'house_city',
  'app_contact': 'house_contact',
  'app_email': 'house_email',
  'app_fax': 'house_fax',
  'app_full_addr': 'house_full_addr',
  'app_title': 'house_name',
  'app_state': 'house_state',
  'app_zip': 'house_zip',
  'help_target_code': 'hp_code',
  'help_target_desc': 'hp_desc',
  'help_target_id': 'hp_id',
  'month_txt2': 'month',
  'month_txt': 'mth',
  'my_sys_user_id': 'mype',
  'number_val': 'n',
  'month_val': 'n',
  'note_dt': 'n_dt',
  'note_etstmp': 'n_etstmp',
  'note_etstmp_fmt': 'n_etstmp_fmt',
  'note_euser': 'n_eu',
  'note_euser_fmt': 'n_eu_fmt',
  'note_id': 'n_id',
  'note_sync_id': 'n_id_main',
  'note_mtstmp': 'n_mtstmp',
  'note_mtstmp_fmt': 'n_mtstmp_fmt',
  'note_muser': 'n_mu',
  'note_muser_fmt': 'n_mu_fmt',
  'note_body': 'n_note',
  'note_scope': 'n_scope',
  'note_scope_id': 'n_scope_id',
  'note_snotes': 'n_snotes',
  'note_sts': 'n_sts',
  'note_sync_tstmp': 'n_synctstmp',
  'note_type': 'n_type',
  'new_cust_role_name': 'new_cr_name',
  'new_menu_id': 'new_sm_id',
  'new_sys_role_name': 'new_sr_name',
  'sys_user_addr': 'pe_addr',
  'sys_user_bphone': 'pe_bphone',
  'sys_user_city': 'pe_city',
  'sys_user_country': 'pe_country',
  'sys_user_cphone': 'pe_cphone',
  'sys_user_email': 'pe_email',
  'sys_user_enddt': 'pe_enddt',
  'sys_user_etstmp': 'pe_etstmp',
  'sys_user_euser': 'pe_eu',
  'sys_user_fname': 'pe_fname',
  'sys_user_hash': 'pe_hash',
  'sys_user_id': 'pe_id',
  'sys_user_initials': 'pe_initials',
  'sys_user_jobtitle': 'pe_jtitle',
  'sys_user_lastlogin_ip': 'pe_ll_ip',
  'sys_user_lastlogin_tstmp': 'pe_ll_tstmp',
  'sys_user_lname': 'pe_lname',
  'sys_user_mname': 'pe_mname',
  'sys_user_mtstmp': 'pe_mtstmp',
  'sys_user_muser': 'pe_mu',
  'sys_user_name': 'pe_name',
  'SYS_USER_NAME': 'PE_NAME',
  'sys_user_pw1': 'pe_pw1',
  'sys_user_pw2': 'pe_pw2',
  'sys_user_snotes': 'pe_snotes',
  'sys_user_startdt': 'pe_startdt',
  'sys_user_state': 'pe_state',
  'sys_user_sts': 'pe_sts',
  'sys_user_stsdt': 'pe_stsdt',
  'sys_user_unotes': 'pe_unotes',
  'sys_user_unq_email': 'pe_unq_pe_email',
  'sys_user_zip': 'pe_zip',
  'param_cur_attrib': 'pp_attrib',
  'param_cur_process': 'pp_process',
  'param_cur_source': 'pp_source',
  'param_cur_val': 'pp_val',
  'param_attrib': 'ppd_attrib',
  'param_desc': 'ppd_desc',
  'param_etstmp': 'ppd_etstmp',
  'param_euser': 'ppd_eu',
  'is_param_app': 'ppd_gpp',
  'param_id': 'ppd_id',
  'param_info': 'ppd_info',
  'param_mtstmp': 'ppd_mtstmp',
  'param_muser': 'ppd_mu',
  'is_param_user': 'ppd_ppp',
  'param_process': 'ppd_process',
  'param_snotes': 'ppd_snotes',
  'param_type': 'ppd_type',
  'is_param_sys': 'ppd_xpp',
  'param_user_attrib': 'ppp_attrib',
  'param_user_etstmp': 'ppp_etstmp',
  'param_user_euser': 'ppp_eu',
  'param_user_id': 'ppp_id',
  'param_user_info': 'ppp_info',
  'param_user_mtstmp': 'ppp_mtstmp',
  'param_user_muser': 'ppp_mu',
  'param_user_process': 'ppp_process',
  'param_user_val': 'ppp_val',
  'audit_ref_id': 'ref_id',
  'audit_ref_name': 'ref_name',
  'queue_etstmp': 'rq_etstmp',
  'queue_euser': 'rq_eu',
  'queue_id': 'rq_id',
  'queue_message': 'rq_message',
  'queue_name': 'rq_name',
  'queue_rslt': 'rq_rslt',
  'queue_rslt_tstmp': 'rq_rslt_tstmp',
  'queue_rslt_user': 'rq_rslt_u',
  'queue_snotes': 'rq_snotes',
  'job_action_target': 'rqst_aname',
  'job_action': 'rqst_atype',
  'job_doc_id': 'rqst_d_id',
  'job_email_id': 'rqst_email_id',
  'job_etstmp': 'rqst_etstmp',
  'job_user': 'rqst_eu',
  'job_id': 'rqst_id',
  'job_prty': 'rqst_prty',
  'job_tag': 'rqst_ident',
  'job_note_id': 'rqst_n_id',
  'job_params': 'rqst_parms',
  'job_queue_id': 'rqst_rq_id',
  'job_rslt': 'rqst_rslt',
  'job_rslt_tstmp': 'rqst_rslt_tstmp',
  'job_rslt_user': 'rqst_rslt_u',
  'job_sms_id': 'rqst_sms_id',
  'job_snotes': 'rqst_snotes',
  'job_source': 'rqst_source',
  'script_name': 'script_name',
  'script_txt': 'script_txt',
  'sys_func_attrib': 'sf_attrib',
  'sys_func_code': 'sf_code',
  'sys_func_desc': 'sf_desc',
  'sys_func_id': 'sf_id',
  'sys_func_name': 'sf_name',
  'sys_func_seq': 'sf_seq',
  'sys_func_snotes': 'sf_snotes',
  'sys_func_sts': 'sf_sts',
  'menu_cmd': 'sm_cmd',
  'menu_desc': 'sm_desc',
  'menu_desc_ext': 'sm_descl',
  'menu_desc_ext2': 'sm_descvl',
  'menu_id': 'sm_id',
  'menu_id_auto': 'sm_id_auto',
  'menu_id_parent': 'sm_id_parent',
  'menu_image': 'sm_image',
  'menu_name': 'sm_name',
  'menu_seq': 'sm_seq',
  'menu_snotes': 'sm_snotes',
  'menu_sts': 'sm_sts',
  'menu_subcmd': 'sm_subcmd',
  'menu_group': 'sm_utype',
  'menu_parent_name': 'sm_parent_name',
  'sms_body': 'sms_body',
  'sms_to': 'sms_to',
  'sms_txt_attrib': 'sms_txt_attrib',
  'sys_user_func_id': 'spef_id',
  'sys_user_func_snotes': 'spef_snotes',
  'sys_user_role_id': 'sper_id',
  'sys_user_role_snotes': 'sper_snotes',
  'sys_role_attrib': 'sr_attrib',
  'sys_role_code': 'sr_code',
  'sys_role_desc': 'sr_desc',
  'sys_role_id': 'sr_id',
  'sys_role_name': 'sr_name',
  'sys_role_seq': 'sr_seq',
  'sys_role_snotes': 'sr_snotes',
  'sys_role_sts': 'sr_sts',
  'sys_menu_role_id': 'srm_id',
  'sys_menu_role_snotes': 'srm_snotes',
  'sys_menu_role_selection': 'srmsel_sel',
  'audit_subject': 'subj',
  'audit_table_id': 'table_id',
  'audit_table_name': 'table_name',
  'title_detail': 'title_b',
  'title_head': 'title_h',
  'txt_attrib': 'txt_attrib',
  'txt_bcc': 'txt_bcc',
  'txt_desc': 'txt_desc',
  'txt_etstmp': 'txt_etstmp',
  'txt_euser': 'txt_eu',
  'txt_id': 'txt_id',
  'txt_mtstmp': 'txt_mtstmp',
  'txt_muser': 'txt_mu',
  'txt_process': 'txt_process',
  'txt_title': 'txt_tval',
  'txt_type': 'txt_type',
  'txt_body': 'txt_val',
  'code_sys_h_id': 'ucod_h_id',
  'code_sys_id': 'ucod_id',
  'code2_sys_h_id': 'ucod2_h_id',
  'code2_sys_id': 'ucod2_id',
  'version_component': 'v_comp',
  'version_etstmp': 'v_etstmp',
  'version_euser': 'v_eu',
  'version_id': 'v_id',
  'version_mtstmp': 'v_mtstmp',
  'version_muser': 'v_mu',
  'version_no_build': 'v_no_build',
  'version_no_major': 'v_no_major',
  'version_no_minor': 'v_no_minor',
  'version_no_rev': 'v_no_rev',
  'version_note': 'v_note',
  'version_snotes': 'v_snotes',
  'version_sts': 'v_sts',
  'param_sys_attrib': 'xpp_attrib',
  'param_sys_etstmp': 'xpp_etstmp',
  'param_sys_euser': 'xpp_eu',
  'param_sys_id': 'xpp_id',
  'param_sys_info': 'xpp_info',
  'param_sys_mtstmp': 'xpp_mtstmp',
  'param_sys_muser': 'xpp_mu',
  'param_sys_process': 'xpp_process',
  'param_sys_val': 'xpp_val',
  'year_txt': 'year',
  'year_val': 'yr'
};

transform.models = {
  'Admin/Overview': 'ADMIN_OVERVIEW',
  'Admin/AuditTrail': 'AUDL',
  'Base/Admin/AuditTrail': 'AUDL_BASE',
  'CustUser': 'CPE',
  'CustUser_Listing': 'CPEL',
  'Base/CustUser_Listing': 'CPEL_BASE',
  'Client/Admin/CustUser_Listing': 'CPEL_CLIENT',
  'Base/CustUser': 'CPE_BASE',
  'CustUser_Role': 'CPE_CPER',
  'Base/CustUser_Role': 'CPE_CPER_BASE',
  'Dev/CustMenuRole_Listing': 'CRMSELR_SEL',
  'Dev/CustRoleMenu_Listing': 'CRMSEL_SEL',
  'Client/Dashboard': 'C_DASHBOARD',
  'Client/Help': 'C_HSHOW',
  'Client/Help_Listing': 'C_HSHOWL',
  'Client/Help_Code': 'C_HSHOW_SINGLE',
  'Client/Dashboard_Note_Listing': 'C_QNCSL',
  'Doc__model': 'D',
  'Dashboard__model': 'DASHBOARD',
  'Doc_Browse': 'DB',
  'Dev/DBSQL': 'DEV_DB',
  'Dev/DBSchema': 'DEV_DB_SCHEMA',
  'Dev/DBScripts': 'DEV_DB_SCRIPTS',
  'Dev/DBObjects': 'DEV_DB_OBJECTS',
  'Dev/DBUpgrade': 'DEV_DB_UPGRADE',
  'Dev/DBDiff': 'DEV_DB_DIFF',
  'Dev/JSShell': 'DEV_JS_SHELL',
  'Dev/Models': 'DEV_MODELS',
  'Dev/Overview': 'DEV_OVERVIEW',
  'Doc_Listing': 'DL',
  'Base/Doc_Listing': 'DL_BASE',
  'Base/Doc': 'D_BASE',
  'Admin/Code2_App_Value_Listing': 'GCOD2L',
  'Admin/Code2_App_Listing': 'GCOD2_HL',
  'Admin/Code_App_Value_Listing': 'GCODL',
  'Admin/Code_App_Listing': 'GCOD_HL',
  'Admin/Code_Listing': 'GCOD_HL',
  'Admin/Code2_Listing': 'GCOD2_HL',
  'Admin/SysUser_Doc': 'GPE_D',
  'Admin/SysUser_Doc_Listing': 'GPE_DL',
  'Admin/SysUser_Note': 'GPE_N',
  'Admin/SysUser_Note_Browse': 'GPE_NB',
  'Admin/SysUser_Note_Sys_Listing': 'GPE_NL_S',
  'Admin/SysUser_Note_User_Listing': 'GPE_NL_U',
  'Admin/SysUser_Note_UserSys_Tabs': 'GPE_NWUS',
  'Admin/Param_App_Listing': 'GPPL',
  'Admin/Help': 'H',
  'Admin/Help_Listing': 'HL',
  'Help__model': 'HSHOW',
  'Help_Listing': 'HSHOWL',
  'Help_Code': 'HSHOW_SINGLE',
  'Admin/Log_Listing': 'LOG',
  'Note__model': 'N',
  'Note_Browse': 'NB',
  'Note_Listing': 'NL',
  'Base/Note_Listing': 'NL_BASE',
  'Note_Cust_Listing': 'NL_C',
  'Note_Cust_Listing_Browse': 'NL_CB',
  'Base/Note_Cust_Listing_Browse': 'NL_CB_BASE',
  'Client/Note_Listing': 'NL_CC',
  'Base/Client/Note_Listing': 'NL_CC_BASE',
  'Base/Note_Cust_Listing': 'NL_C_BASE',
  'Note_Sys_Listing': 'NL_S',
  'Base/Note_Sys_Listing': 'NL_S_BASE',
  'Note_User_Listing': 'NL_U',
  'Base/Note_User_Listing': 'NL_U_BASE',
  'Note_CustSys_Tabs': 'NWCS',
  'Client/Note_CustSys_Tabs': 'NWCSC',
  'Note_CustSys_Tabs_Browse': 'NWCSCB',
  'Base/Note_CustSys_Tabs_Browse': 'NWCSC_BASE',
  'Note_UserCustSys_Tabs': 'NWUCS',
  'Base/Note_UserCustSys_Tabs': 'NWUCS_BASE',
  'Note_UserSys_Tabs': 'NWUS',
  'Base/Note': 'N_BASE',
  'Admin/SysUser': 'PE',
  'Admin/SysUser_Listing': 'PEL',
  'Base/Admin/SysUser_Listing': 'PEL_BASE',
  'Admin/SysUser_Tabs': 'PEW',
  'Base/Admin/SysUser': 'PE_BASE',
  'Admin/SysUser_Insert': 'PE_NEW',
  'Admin/SysUser_Func': 'PE_SPEF',
  'Admin/SysUser_Role': 'PE_SPER',
  'Dev/PopupExec': 'POPUP_EXEC',
  'Dev/CreateCode_App': 'POPUP_EXEC_CREATE_GCOD',
  'Dev/CreateCode2_App': 'POPUP_EXEC_CREATE_GCOD2',
  'Dev/CreateCode_Base': 'POPUP_EXEC_CREATE_TABLE',
  'Dev/CreateCode_Sys': 'POPUP_EXEC_CREATE_UCOD',
  'Dev/CreateCode2_Sys': 'POPUP_EXEC_CREATE_UCOD2',
  'Admin/Param_User_Listing': 'PPPL',
  'Dashboard_Note_Listing': 'QNSSL',
  'Reports/Overview': 'REPORTS',
  'Client/Reports/Overview': 'REPORTS_CLIENT',
  'Admin/Restart': 'RESTART',
  'Queue__model': 'RQ',
  'Dev/SysMenuRole_Listing': 'SRMSELR_SEL',
  'Dev/SysRoleMenu_Listing': 'SRMSEL_SEL',
  'Admin/Txt': 'TXT',
  'Admin/Txt_Listing': 'TXTL',
  'Dev/Code2_Sys_Value_Listing': 'UCOD2L',
  'Dev/Code2_Sys_Listing_Browse': 'UCOD2_HL',
  'Dev/Code_Sys_Value_Listing': 'UCODL',
  'Dev/Code_Sys_Listing_Browse': 'UCOD_HL',
  'Dev/CustRole_Listing': 'X_CRL',
  'Dev/CustMenuRole': 'X_CRMSELR_HW',
  'Dev/CustRoleMenu': 'X_CRMSEL_HW',
  'Dev/Code2_App_Value_Listing': 'X_GCOD2L',
  'Dev/Code2_App_Listing': 'X_GCOD2_HL',
  'Dev/Code_App_Value_Listing': 'X_GCODL',
  'Dev/Code_App_Listing': 'X_GCOD_HL',
  'Dev/Param_App_Listing': 'X_GPPL',
  'Dev/HelpTarget_Listing': 'X_HPL',
  'Admin/Model_Popup_Listing': 'X_MODELS',
  'Admin/HelpTarget_Popup_Listing': 'HELP_TARGETS',
  'Dev/Param_Listing': 'X_PPDL',
  'Dev/SysFunc_Listing': 'X_SFL',
  'Dev/Menu_Listing': 'X_SML',
  'Dev/Menu_Tree_Editor': 'X_SMLW',
  'Dev/Menu_Exec_Delete': 'X_SMLW_DELETE',
  'Dev/Menu_Exec_Insert': 'X_SMLW_INSERT',
  'Dev/Menu': 'X_SML_EDIT',
  'Dev/SysRole_Listing': 'X_SRL',
  'Dev/SysMenuRole': 'X_SRMSELR_HW',
  'Dev/SysRoleMenu': 'X_SRMSEL_HW',
  'Dev/Txt': 'X_TXT',
  'Dev/Txt_Listing': 'X_TXTL',
  'Dev/Code2_Sys_Listing': 'X_UCOD2_HL',
  'Dev/Code_Sys_Listing': 'X_UCOD_HL',
  'Dev/Param_Sys_Listing': 'X_XPPL',
  'Reports/Agreement': 'reports/AGREEMENT',
  'Dev/Code_Listing': 'X_GCOD_HL',
  'Dev/Code2_Listing': 'X_GCOD2_HL',
};

transform.sql = {
  '@custid': '@cid',
  '@itemid': '@eid',
  '@etstmp': '@etstmp',
  '@euser': '@eu',
  '@id': '@id',
  '@in1': '@in1',
  '@in2': '@in2',
  '@in_attrib': '@in_attrib',
  '@in_code_desc': '@in_codemean',
  '@in_code_name': '@in_codename',
  '@in_code_schema': '@in_codeschema',
  '@in_code_val': '@in_codeval',
  '@in_code_val1': '@in_codeval1',
  '@in_code_val2': '@in_codeval2',
  '@in_doc_ext': '@in_d_ext',
  '@in_doc_id': '@in_d_id',
  '@in_loc': '@in_loc',
  '@in_name': '@in_name',
  '@in_object': '@in_object',
  '@in_sys_user_id': '@in_pe_id',
  '@in_param_attrib': '@in_ppd_attrib',
  '@in_param_process': '@in_ppd_process',
  '@in_process': '@in_process',
  '@in_schema': '@in_schema',
  '@in_table': '@in_table',
  '@in_tblid': '@in_tblid',
  '@in_tblname': '@in_tblname',
  '@in_txt': '@in_txt',
  '@in_type': '@in_type',
  '@in_val': '@in_val',
  '@mtstmp': '@mtstmp',
  '@muser': '@mu',
  '@op': '@op',
  '@sys_user_id': '@pe_id',
  '@pw': '@pw',
  '@audit_ref_id': '@ref_id',
  '@audit_ref_name': '@ref_name',
  '@audit_subject': '@subj',
  '@tbl': '@tbl',
  '@tid': '@tid',
  '@tname': '@tname',
  '@tstmp': '@tstmp',
  '@TYPE': '@type',
  '@u': '@u',
  '@USER': '@user',
  '@X': '@x',
  'agreement_code_cust_id': 'agreement_COD_C_ID',
  'agreement_code_month': 'agreement_COD_MONTH',
  'agreement_code_state': 'agreement_COD_STATE',
  'agreement_code_year': 'agreement_COD_YEAR',
  'agreement_paymentresult': 'agreement_paymentresult',
  'agreement_report_note': 'agreement_report_N',
  'agreement_sign': 'agreement_sign',
  'log_audit': 'audh',
  'log_audit_base': 'audh_base',
  'log_audit_delete': 'audit_d',
  'log_audit_delete_mult': 'audit_d_mult',
  'log_audit_insert': 'audit_i',
  'log_audit_info': 'audit_info',
  'log_audit_insert_ext': 'audit_i_ext',
  'log_audit_update': 'audit_u',
  'log_audit_update_custom': 'audit_u_custom',
  'log_audit_update_mult': 'audit_u_mult',
  'check_code': 'check_code',
  'check_code2': 'check_code2',
  'check_code2_exec': 'check_code2_p',
  'check_code_exec': 'check_code_p',
  'check_foreign_key': 'check_foreign',
  'check_foreign_key_exec': 'check_foreign_p',
  'check_param': 'check_pp',
  'client_scope': 'client_scope',
  'client_sql_auth': 'client_sql_auth',
  'client_sql_login': 'client_sql_login',
  'client_sql_loginsuccess': 'client_sql_loginsuccess',
  'client_sql_passwordreset': 'client_sql_passwordreset',
  'client_sql_superlogin': 'client_sql_superlogin',
  'create_code_app': 'create_gcod',
  'create_code2_app': 'create_gcod2',
  'create_code_sys': 'create_ucod',
  'create_code2_sys': 'create_ucod2',
  'context_user': 'CUSER',
  'doc_ctgr_table': 'dscope_dctgr',
  'doc_filename': 'd_filename',
  'exists_doc': 'exists_d',
  'exists_note': 'exists_n',
  'func_prefix': 'FUN_PREFIX',
  'get_cust_id': 'getcid',
  'get_item_id': 'geteid',
  'get_cust_user_name': 'get_cpe_name',
  'get_sys_user_name': 'get_pe_name',
  'get_param_desc': 'get_ppd_desc',
  'init_db_user_exists': 'init_db_user_exists',
  'init_sysadmin_access': 'init_sysadmin_access',
  'jobproc_add_BEGIN': 'jobproc_add_BEGIN',
  'jobproc_add_END': 'jobproc_add_END',
  'jobproc_add_doc': 'jobproc_add_RQST_D',
  'jobproc_add_email': 'jobproc_add_RQST_EMAIL',
  'jobproc_add_note': 'jobproc_add_RQST_N',
  'jobproc_add_queue': 'jobproc_add_RQST_RQ',
  'jobproc_add_sms': 'jobproc_add_RQST_SMS',
  'jobproc_jobcheck': 'jobproc_jobcheck',
  'jobproc_jobresult': 'jobproc_jobresult',
  'jobproc_getresult': 'jobproc_getresult',
  'jobproc_queuecheck': 'jobproc_queuecheck',
  'jobproc_queuepop': 'jobproc_queuepop',
  'jobproc_queueresult': 'jobproc_queueresult',
  'jobproc_queuesubscribers': 'jobproc_queuesubscribers',
  'jobproc_save_doc': 'jobproc_saveD',
  'jobproc_save_note': 'jobproc_saveN',
  'jobproc_save_queue': 'jobproc_saveRQ',
  'jobproc_save_queue_message': 'jobproc_saveRQ_message',
  'JSEXEC_STR': 'JSEXEC_STR',
  'JSHARMONY_FACTORY_INSTALLED': 'JSHARMONY_FACTORY_INSTALLED',
  'main_sql_auth': 'main_sql_auth',
  'main_sql_check_email': 'main_sql_check_email',
  'main_sql_login': 'main_sql_login',
  'main_sql_loginsuccess': 'main_sql_loginsuccess',
  'main_sql_passwordreset': 'main_sql_passwordreset',
  'main_sql_superlogin': 'main_sql_superlogin',
  'menu_client': 'menu_client',
  'menu_main': 'menu_main',
  'menu_main_noauth': 'menu_main_noauth',
  'my_cust_user': 'mycpe',
  'my_db_user': 'mycuser',
  'my_cust_id': 'mycuser_c_id',
  'my_db_user_exec': 'mycuser_do',
  'my_db_user_fmt': 'mycuser_fmt',
  'my_db_user_fmt_exec': 'mycuser_fmt_do',
  'my_hash': 'myhash',
  'my_mmddyyhhmi': 'mymmddyyhhmi',
  'my_now': 'mynow',
  'my_now_exec': 'mynow_do',
  'my_sys_user_id': 'mype',
  'my_cust_user_id': 'mypec',
  'my_cust_user_id_exec': 'mypec_do',
  'my_user_do': 'mype_do',
  'my_to_date': 'mytodate',
  'my_today': 'mytoday',
  'my_today_exec': 'mytoday_do',
  'nequal': 'nonequal',
  'nequal_chr': 'nonequalc',
  'nequal_date': 'nonequald',
  'nequal_num': 'nonequaln',
  'par_list_beg': 'PAR_LIST_BEG',
  'par_list_end': 'PAR_LIST_END',
  'proc_run': 'PROC_RUN',
  'sms_send_txt': 'SMS_SendTXTSMS',
  'menu_group_lov': 'SM_UTYPE_LOV',
  'table_type': 'table_type',
  'get_tstmp': 'TSTMP',
  'menu_editor_insert': 'X_SMLW_INSERT',
  'menu_editor_lov': 'X_SMLW_LOV',
  'menu_editor_top': 'X_SMLW_TOP',
  'zz-filedebug': 'zz-filedebug',
  'cust_staging_id': 'c_pre_id',
  'cust_staging': 'c_pre',
  'payment_cc_fp_hash': 'pacc_fp_hash',
  'payment_cc_sts': 'pacc_sts',
  'payment_cc_result': 'pacc_pp_result',
  'new_client_result': 'new_client_result',
  'agreement_doc_scope': 'AGREEMNT',
  'cust_agreement_tstmp': 'c_atstmp',
  'cust': 'c',
  'code_sys_cust_sts': 'ucod_c_sts',
  'cust_sts': 'c_sts',
  'item__tbl': 'e',
  'sys_user_code': 'PE',
  '@cust_id': '@c_id',
  '@job_id': '@rqst_id',
  '@txt_attrib': '@txt_attrib',
  '@menu_id_parent': '@sm_id_parent',
  '@menu_name': '@sm_name',
  '@menu_desc': '@sm_desc',
  '@job_params': '@rqst_parms',
  '@sys_user_email': '@pe_email',
  '@sys_user_lastlogin_ip': '@pe_ll_ip',
  '@sys_user_lastlogin_tstmp': '@pe_ll_tstmp',
  '@sys_user_hash': '@pe_hash',
  '@doc_scope': '@d_scope',
  '@doc_scope_id': '@d_scope_id',
  '@doc_ctgr': '@d_ctgr',
  '@doc_desc': '@d_desc',
  '@doc_size': '@d_size',
  '@queue_name': '@rq_name',
  '@queue_message': '@rq_message',
  '@queue_id': '@rq_id',
  '@queue_rslt': '@rq_rslt',
  '@queue_snotes': '@rq_snotes',
  '@note_scope': '@n_scope',
  '@note_scope_id': '@n_scope_id',
  '@note_type': '@n_type',
  '@note_body': '@n_note',
  '@job_rslt': '@rqst_rslt',
  '@job_snotes': '@rqst_snotes',
  '@job_source': '@rqst_source',
  '@job_action': '@rqst_atype',
  '@job_action_target': '@rqst_aname',
  '@job_prty': '@rqst_prty',
  '@email_txt_attrib': '@email_txt_attrib',
  '@email_to': '@email_to',
  '@email_cc': '@email_cc',
  '@email_bcc': '@email_bcc',
  '@email_attach': '@email_attach',
  '@email_subject': '@email_subject',
  '@email_text': '@email_text',
  '@email_html': '@email_html',
  '@email_doc_id': '@email_d_id',
  '@sms_txt_attrib': '@sms_txt_attrib',
  '@sms_to': '@sms_to',
  '@sms_body': '@sms_body',
  'separate_code_type_tables': '1',
  'help_target_required': '1',
};

transform.ignore_errors = {
  value: {
    'n': true,
    'ucod': true,
    'gcod': true,
    'ucod2': true,
    'gcod2': true,
  }
};

exports = module.exports = transform;