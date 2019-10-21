
update {schema}.param_sys set param_sys_val = '%%%INIT_DB_HASH_CLIENT%%%'
  where param_sys_process='USERS' and param_sys_attrib='HASH_SEED_C';

delete from {schema}.audit_detail;
delete from {schema}.audit__tbl;

insert into {schema}.code2_doc_scope_doc_ctgr(code_val1, code_val2, code_txt) values ('C','agreement_doc_scope','AGREEMENT');
