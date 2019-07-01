
update {schema}_param_sys set param_sys_val = '%%%INIT_DB_HASH_MAIN%%%'
  where param_sys_process='USERS' and param_sys_attrib='HASH_SEED_S';
update {schema}_param_sys set param_sys_val = '%%%INIT_DB_HASH_CLIENT%%%'
  where param_sys_process='USERS' and param_sys_attrib='HASH_SEED_C';


insert into {schema}_sys_user (sys_user_fname,sys_user_lname,sys_user_email,sys_user_pw1,sys_user_pw2,
                          sys_user_startdt, sys_user_stsdt, sys_user_euser, sys_user_etstmp, sys_user_muser, sys_user_mtstmp)
  values ('Admin','User','%%%INIT_DB_ADMIN_EMAIL%%%','%%%INIT_DB_ADMIN_PASS%%%','%%%INIT_DB_ADMIN_PASS%%%',
          date('now','localtime'),datetime('now','localtime'),(select context from jsharmony_meta limit 1),datetime('now','localtime'),(select context from jsharmony_meta limit 1),datetime('now','localtime'));

insert into {schema}_sys_user_role (sys_user_id, sys_role_name) values(1,'*');
insert into {schema}_sys_user_role (sys_user_id, sys_role_name) values(1,'DEV');
insert into {schema}_sys_user_role (sys_user_id, sys_role_name) values(1,'SYSADMIN');
insert into {schema}.sys_user_role (sys_user_id, sys_role_name) values(1,'DADMIN');
insert into {schema}.sys_user_role (sys_user_id, sys_role_name) values(1,'X_B');
insert into {schema}.sys_user_role (sys_user_id, sys_role_name) values(1,'X_X');

delete from {schema}_audit_detail;
delete from {schema}_audit__tbl;

insert into {schema}_code2_doc_scope_doc_ctgr(code_val1, code_val2, code_txt) values ('sys_user_code','DOCUMENT','DOCUMENT');
insert into {schema}_code2_doc_scope_doc_ctgr(code_val1, code_val2, code_txt) values ('sys_user_code','IMAGE','IMAGE');
insert into {schema}_code2_doc_scope_doc_ctgr(code_val1, code_val2, code_txt) values ('sys_user_code','OTHER','OTHER');
insert into {schema}_code2_doc_scope_doc_ctgr(code_val1, code_val2, code_txt) values ('C','agreement_doc_scope','AGREEMENT');

