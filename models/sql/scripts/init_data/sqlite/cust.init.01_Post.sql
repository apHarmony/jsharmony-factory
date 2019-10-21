
begin;

update {schema}_param_sys set param_sys_val = '%%%INIT_DB_HASH_CLIENT%%%'
  where param_sys_process='USERS' and param_sys_attrib='HASH_SEED_C';

delete from {schema}_audit_detail;
delete from {schema}_audit__tbl;

insert into {schema}_code2_doc_scope_doc_ctgr(code_val1, code_val2, code_txt) values ('C','agreement_doc_scope','AGREEMENT');

end;