/***************TABLE TRIGGERS***************/

drop trigger if exists {schema}_{cust_user_role}_insert;
drop trigger if exists {schema}_{cust_user_role}_update;
drop trigger if exists {schema}_{cust_user_role}_delete;

drop trigger if exists {schema}_{doc}_before_insert;
drop trigger if exists {schema}_{doc}_after_insert;
drop trigger if exists {schema}_{doc}_before_update;
drop trigger if exists {schema}_{doc}_after_update;
drop trigger if exists {schema}_{doc}_delete;

drop trigger if exists {schema}_{note}_before_insert;
drop trigger if exists {schema}_{note}_after_insert;
drop trigger if exists {schema}_{note}_before_update;
drop trigger if exists {schema}_{note}_after_update;
drop trigger if exists {schema}_{note}_delete;

drop trigger if exists {schema}_{sys_user}_before_insert;
drop trigger if exists {schema}_{sys_user}_after_insert;
drop trigger if exists {schema}_{sys_user}_before_update;
drop trigger if exists {schema}_{sys_user}_after_update;
drop trigger if exists {schema}_{sys_user}_delete;

drop trigger if exists {schema}_{cust_user}_before_insert;
drop trigger if exists {schema}_{cust_user}_after_insert;
drop trigger if exists {schema}_{cust_user}_before_update;
drop trigger if exists {schema}_{cust_user}_after_update;
drop trigger if exists {schema}_{cust_user}_delete;

drop trigger if exists {schema}_{param_app}_before_insert;
drop trigger if exists {schema}_{param_app}_after_insert;
drop trigger if exists {schema}_{param_app}_before_update;
drop trigger if exists {schema}_{param_app}_after_update;
drop trigger if exists {schema}_{param_app}_delete;

drop trigger if exists {schema}_{param_sys}_before_insert;
drop trigger if exists {schema}_{param_sys}_after_insert;
drop trigger if exists {schema}_{param_sys}_before_update;
drop trigger if exists {schema}_{param_sys}_after_update;
drop trigger if exists {schema}_{param_sys}_delete;

drop trigger if exists {schema}_{param_user}_before_insert;
drop trigger if exists {schema}_{param_user}_after_insert;
drop trigger if exists {schema}_{param_user}_before_update;
drop trigger if exists {schema}_{param_user}_after_update;
drop trigger if exists {schema}_{param_user}_delete;

drop trigger if exists {schema}_{param}_after_insert;
drop trigger if exists {schema}_{param}_before_update;
drop trigger if exists {schema}_{param}_after_update;
drop trigger if exists {schema}_{param}_delete;

drop trigger if exists {schema}_{help}_after_insert;
drop trigger if exists {schema}_{help}_before_update;
drop trigger if exists {schema}_{help}_after_update;
drop trigger if exists {schema}_{help}_delete;

drop trigger if exists {schema}_{sys_user_func}_after_insert;
drop trigger if exists {schema}_{sys_user_func}_before_update;
drop trigger if exists {schema}_{sys_user_func}_after_update;
drop trigger if exists {schema}_{sys_user_func}_delete;

drop trigger if exists {schema}_{sys_user_role}_before_insert;
drop trigger if exists {schema}_{sys_user_role}_after_insert;
drop trigger if exists {schema}_{sys_user_role}_before_update;
drop trigger if exists {schema}_{sys_user_role}_after_update;
drop trigger if exists {schema}_{sys_user_role}_delete;

drop trigger if exists {schema}_{txt}_after_insert;
drop trigger if exists {schema}_{txt}_before_update;
drop trigger if exists {schema}_{txt}_after_update;
drop trigger if exists {schema}_{txt}_delete;

drop trigger if exists {schema}_{queue}_after_insert;

drop trigger if exists {schema}_{job}_after_insert;

drop trigger if exists {schema}_{code_app}_after_insert;
drop trigger if exists {schema}_{code_app}_after_update;

drop trigger if exists {schema}_{code2_app}_after_insert;
drop trigger if exists {schema}_{code2_app}_after_update;

drop trigger if exists {schema}_{code_sys}_after_insert;
drop trigger if exists {schema}_{code_sys}_after_update;

drop trigger if exists {schema}_{code2_sys}_after_insert;
drop trigger if exists {schema}_{code2_sys}_after_update;

drop trigger if exists {schema}_{version}_after_insert;
drop trigger if exists {schema}_{version}_after_update;

/***************VIEWS***************/
drop view if exists {schema}_{v_param_cur};
drop view if exists {schema}_{v_app_info};
drop view if exists {schema}_{code2_param_app_attrib};
drop view if exists {schema}_{code2_param_user_attrib};
drop view if exists {schema}_{code2_param_sys_attrib};
drop view if exists {schema}_{code_param_app_process};
drop view if exists {schema}_{code_param_user_process};
drop view if exists {schema}_{code_param_sys_process};
drop view if exists {schema}_{v_audit_detail};
drop view if exists {schema}_{v_cust_user_nostar};
drop view if exists {schema}_{v_cust_menu_role_selection};
drop view if exists {schema}_{v_doc};
drop view if exists {schema}_{v_doc_ext};
drop view if exists {schema}_{v_doc_filename};
drop view if exists {schema}_{v_param_app};
drop view if exists {schema}_{v_month};
drop view if exists {schema}_{v_my_user};
drop view if exists {schema}_{v_my_roles};
drop view if exists {schema}_{v_note};
drop view if exists {schema}_{v_note_ext};
drop view if exists {schema}_{v_param};
drop view if exists {schema}_{v_param_user};
drop view if exists {schema}_{v_sys_menu_role_selection};
drop view if exists {schema}_{v_param_sys};
drop view if exists {schema}_{v_year};
