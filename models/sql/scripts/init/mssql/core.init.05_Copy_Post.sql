update {schema}.param_sys set param_sys_val = '%%%INIT_DB_HASH_MAIN%%%'
where param_sys_process='USERS' and param_sys_attrib='HASH_SEED_S';
GO
insert into {schema}.sys_user (sys_user_fname,sys_user_lname,sys_user_email,sys_user_pw1,sys_user_pw2)
values ('Admin','User','%%%INIT_DB_ADMIN_EMAIL%%%','%%%INIT_DB_ADMIN_PASS%%%','%%%INIT_DB_ADMIN_PASS%%%');
insert into {schema}.sys_user_role (sys_user_id, sys_role_name) values(1,'DEV');
insert into {schema}.sys_user_role (sys_user_id, sys_role_name) values(1,'SYSADMIN');
insert into {schema}.sys_user_role (sys_user_id, sys_role_name) values(1,'DADMIN');
insert into {schema}.sys_user_role (sys_user_id, sys_role_name) values(1,'X_B');
insert into {schema}.sys_user_role (sys_user_id, sys_role_name) values(1,'X_X');
GO
delete from {schema}.audit_detail;
delete from {schema}.audit__tbl;
GO
      
insert into {schema}.code2_doc_scope_doc_ctgr(code_val1, code_val2, code_txt) values ('sys_user_code','DOCUMENT','DOCUMENT');
insert into {schema}.code2_doc_scope_doc_ctgr(code_val1, code_val2, code_txt) values ('sys_user_code','IMAGE','IMAGE');
insert into {schema}.code2_doc_scope_doc_ctgr(code_val1, code_val2, code_txt) values ('sys_user_code','OTHER','OTHER');
GO