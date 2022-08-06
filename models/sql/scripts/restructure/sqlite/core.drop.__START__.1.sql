/***************TABLE TRIGGERS***************/

drop trigger if exists {schema}_doc__tbl_before_insert;
drop trigger if exists {schema}_doc__tbl_after_insert;
drop trigger if exists {schema}_doc__tbl_before_update;
drop trigger if exists {schema}_doc__tbl_after_update;
drop trigger if exists {schema}_doc__tbl_delete;

drop trigger if exists {schema}_note__tbl_before_insert;
drop trigger if exists {schema}_note__tbl_after_insert;
drop trigger if exists {schema}_note__tbl_before_update;
drop trigger if exists {schema}_note__tbl_after_update;
drop trigger if exists {schema}_note__tbl_delete;

drop trigger if exists {schema}_sys_user_before_insert;
drop trigger if exists {schema}_sys_user_after_insert;
drop trigger if exists {schema}_sys_user_before_update;
drop trigger if exists {schema}_sys_user_after_update;
drop trigger if exists {schema}_sys_user_delete;

drop trigger if exists {schema}_param_app_before_insert;
drop trigger if exists {schema}_param_app_after_insert;
drop trigger if exists {schema}_param_app_before_update;
drop trigger if exists {schema}_param_app_after_update;
drop trigger if exists {schema}_param_app_delete;

drop trigger if exists {schema}_param_sys_before_insert;
drop trigger if exists {schema}_param_sys_after_insert;
drop trigger if exists {schema}_param_sys_before_update;
drop trigger if exists {schema}_param_sys_after_update;
drop trigger if exists {schema}_param_sys_delete;

drop trigger if exists {schema}_param_user_before_insert;
drop trigger if exists {schema}_param_user_after_insert;
drop trigger if exists {schema}_param_user_before_update;
drop trigger if exists {schema}_param_user_after_update;
drop trigger if exists {schema}_param_user_delete;

drop trigger if exists {schema}_param__tbl_after_insert;
drop trigger if exists {schema}_param__tbl_before_update;
drop trigger if exists {schema}_param__tbl_after_update;
drop trigger if exists {schema}_param__tbl_delete;

drop trigger if exists {schema}_help__tbl_after_insert;
drop trigger if exists {schema}_help__tbl_before_update;
drop trigger if exists {schema}_help__tbl_after_update;
drop trigger if exists {schema}_help__tbl_delete;

drop trigger if exists {schema}_help_target_after_update;

drop trigger if exists {schema}_sys_user_func_after_insert;
drop trigger if exists {schema}_sys_user_func_before_update;
drop trigger if exists {schema}_sys_user_func_after_update;
drop trigger if exists {schema}_sys_user_func_delete;

drop trigger if exists {schema}_sys_user_role_before_insert;
drop trigger if exists {schema}_sys_user_role_after_insert;
drop trigger if exists {schema}_sys_user_role_before_update;
drop trigger if exists {schema}_sys_user_role_after_update;
drop trigger if exists {schema}_sys_user_role_delete;

drop trigger if exists {schema}_txt__tbl_after_insert;
drop trigger if exists {schema}_txt__tbl_before_update;
drop trigger if exists {schema}_txt__tbl_after_update;
drop trigger if exists {schema}_txt__tbl_delete;

drop trigger if exists {schema}_queue__tbl_after_insert;

drop trigger if exists {schema}_job__tbl_after_insert;

drop trigger if exists {schema}_code_app_after_insert;
drop trigger if exists {schema}_code_app_after_update;

drop trigger if exists {schema}_code2_app_after_insert;
drop trigger if exists {schema}_code2_app_after_update;

drop trigger if exists {schema}_code_sys_after_insert;
drop trigger if exists {schema}_code_sys_after_update;

drop trigger if exists {schema}_code2_sys_after_insert;
drop trigger if exists {schema}_code2_sys_after_update;

drop trigger if exists {schema}_version__tbl_after_insert;
drop trigger if exists {schema}_version__tbl_after_update;
drop trigger if exists {schema}_version__tbl_delete;

/***************VIEWS***************/
drop view if exists {schema}_v_param_cur;
drop view if exists {schema}_v_app_info;
drop view if exists {schema}_code2_param_app_attrib;
drop view if exists {schema}_code2_param_user_attrib;
drop view if exists {schema}_code2_param_sys_attrib;
drop view if exists {schema}_code_param_app_process;
drop view if exists {schema}_code_param_user_process;
drop view if exists {schema}_code_param_sys_process;
drop view if exists {schema}_v_audit_detail;
drop view if exists {schema}_v_doc;
drop view if exists {schema}_v_doc_ext;
drop view if exists {schema}_v_doc_filename;
drop view if exists {schema}_v_param_app;
drop view if exists {schema}_v_month;
drop view if exists {schema}_v_my_user;
drop view if exists {schema}_v_my_roles;
drop view if exists {schema}_v_note;
drop view if exists {schema}_v_note_ext;
drop view if exists {schema}_v_param;
drop view if exists {schema}_v_param_user;
drop view if exists {schema}_v_sys_menu_role_selection;
drop view if exists {schema}_v_param_sys;
drop view if exists {schema}_v_year;
