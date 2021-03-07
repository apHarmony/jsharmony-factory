/***************TABLE TRIGGERS***************/

/***************doc__tbl***************/

create trigger {schema}_doc__tbl_before_insert before insert on {schema}_doc__tbl
begin
  select case when new.doc_scope='S' and new.doc_scope_id<>0 then raise(FAIL,'Application Error - SCOPE_ID inconsistent with SCOPE') end\;
  select case when new.doc_scope<>'S' and new.doc_scope_id is null then raise(FAIL,'Application Error - SCOPE_ID inconsistent with SCOPE') end\;
  select case when (ifnull({schema}.check_scope_id(new.doc_scope,new.doc_scope_id,{schema}.my_cust_id()),0)<=0) then raise(FAIL,'Application Error - Invalid scope - user has no rights to perform this operation') end\;
  select case when not exists (select * from {schema}_code2_app_doc_scope_doc_ctgr where code_val1=new.doc_scope and code_val2=new.doc_ctgr) then raise(FAIL,'Document type not allowed for selected scope') end\;
end;

create trigger {schema}_doc__tbl_after_insert after insert on {schema}_doc__tbl
begin
  update {schema}_doc__tbl set 
    cust_id     = {schema}.get_cust_id((select ifnull(code_code, code_val) from {schema}_code_sys_doc_scope where code_val = new.doc_scope),new.doc_scope_id),
    item_id     = {schema}.get_item_id((select ifnull(code_code, code_val) from {schema}_code_sys_doc_scope where code_val = new.doc_scope),new.doc_scope_id),
    doc_euser     = (select context from jsharmony_meta limit 1),
    doc_etstmp = datetime('now','localtime'),
    doc_muser     = (select context from jsharmony_meta limit 1),
    doc_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;

  %%%log_audit_insert("{schema}_doc__tbl","new.doc_id","doc_id","null","null","null","{schema}.get_cust_id(new.doc_scope,new.doc_scope_id)","{schema}.get_item_id(new.doc_scope,new.doc_scope_id)")%%%
  update jsharmony_meta set {{audit_seq}} = null\;
end;

create trigger {schema}_doc__tbl_before_update before update on {schema}_doc__tbl
begin
  select case when ifnull(old.doc_id,'')<>ifnull(NEW.doc_id,'') then raise(FAIL,'Application Error - ID cannot be updated.') end\;
  select case when ifnull(old.doc_scope,'')<>ifnull(NEW.doc_scope,'') then raise(FAIL,'Application Error - Scope cannot be updated.') end\;
  select case when ifnull(old.doc_scope_id,'')<>ifnull(NEW.doc_scope_id,'') then raise(FAIL,'Application Error - Scope ID cannot be updated.') end\;
  select case when ifnull(old.doc_ctgr,'')<>ifnull(NEW.doc_ctgr,'') then raise(FAIL,'Application Error - Document Category cannot be updated.') end\;
  select case when not exists (select * from {schema}_code2_app_doc_scope_doc_ctgr where code_val1=new.doc_scope and code_val2=new.doc_ctgr) then raise(FAIL,'Document type not allowed for selected scope') end\;
end;

create trigger {schema}_doc__tbl_after_update after update on {schema}_doc__tbl
begin
  %%%log_audit_update_mult("{schema}_doc__tbl","old.doc_id",["doc_id","cust_id","doc_scope","doc_scope_id","item_id","doc_sts","doc_ctgr","doc_desc","doc_uptstmp","doc_upuser","doc_sync_tstmp"],"null","null","null","{schema}.get_cust_id(new.doc_scope,new.doc_scope_id)","{schema}.get_item_id(new.doc_scope,new.doc_scope_id)")%%%

  update {schema}_doc__tbl set 
    doc_muser     = (select context from jsharmony_meta limit 1),
    doc_mtstmp = datetime('now','localtime')
    where doc_id = new.doc_id and exists(select * from jsharmony_meta where {{audit_seq}} is not null)\; 

  update jsharmony_meta set {{audit_seq}} = null\;
end;

create trigger {schema}_doc__tbl_delete before delete on {schema}_doc__tbl
begin
  %%%log_audit_delete_mult("{schema}_doc__tbl","old.doc_id",["doc_id","cust_id","doc_scope","doc_scope_id","item_id","doc_sts","doc_ctgr","doc_desc","doc_uptstmp","doc_upuser","doc_sync_tstmp"],"null","null","null")%%%
  update jsharmony_meta set {{audit_seq}} = null\;
end;

/***************note__tbl***************/

create trigger {schema}_note__tbl_before_insert before insert on {schema}_note__tbl
begin
  select case when new.note_scope='S' and new.note_scope_id<>0 then raise(FAIL,'Application Error - SCOPE_ID inconsistent with SCOPE') end\;
  select case when new.note_scope<>'S' and new.note_scope_id is null then raise(FAIL,'Application Error - SCOPE_ID inconsistent with SCOPE') end\;
  select case when (ifnull({schema}.check_scope_id(new.note_scope,new.note_scope_id,{schema}.my_cust_id()),0)<=0) then raise(FAIL,'Application Error - Invalid scope - user has no rights to perform this operation') end\;
end;

create trigger {schema}_note__tbl_after_insert after insert on {schema}_note__tbl
begin
  update {schema}_note__tbl set 
    cust_id     = {schema}.get_cust_id((select ifnull(code_code, code_val) from {schema}_code_sys_note_scope where code_val = new.note_scope),new.note_scope_id),
    item_id     = {schema}.get_item_id((select ifnull(code_code, code_val) from {schema}_code_sys_note_scope where code_val = new.note_scope),new.note_scope_id),
    note_euser     = (select context from jsharmony_meta limit 1),
    note_etstmp = datetime('now','localtime'),
    note_muser     = (select context from jsharmony_meta limit 1),
    note_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;

  %%%log_audit_insert("{schema}_note__tbl","new.note_id","note_id","null","null","null","{schema}.get_cust_id(new.note_scope,new.note_scope_id)","{schema}.get_item_id(new.note_scope,new.note_scope_id)")%%%
  update jsharmony_meta set {{audit_seq}} = null\;
end;

create trigger {schema}_note__tbl_before_update before update on {schema}_note__tbl
begin
  select case when ifnull(old.note_id,'')<>ifnull(NEW.note_id,'') then raise(FAIL,'Application Error - ID cannot be updated.') end\;
  select case when ifnull(old.note_scope,'')<>ifnull(NEW.note_scope,'') then raise(FAIL,'Application Error - Scope cannot be updated.') end\;
  select case when ifnull(old.note_scope_id,'')<>ifnull(NEW.note_scope_id,'') then raise(FAIL,'Application Error - Scope ID cannot be updated.') end\;
  select case when ifnull(old.note_type,'')<>ifnull(NEW.note_type,'') then raise(FAIL,'Application Error - Note Type cannot be updated.') end\;
end;

create trigger {schema}_note__tbl_after_update after update on {schema}_note__tbl
begin
  %%%log_audit_update_mult("{schema}_note__tbl","old.note_id",["note_id","cust_id","note_scope","note_scope_id","item_id","note_sts","note_type","note_body"],"null","null","null","{schema}.get_cust_id(new.note_scope,new.note_scope_id)","{schema}.get_item_id(new.note_scope,new.note_scope_id)")%%%

  update {schema}_note__tbl set 
    note_muser     = (select context from jsharmony_meta limit 1),
    note_mtstmp = datetime('now','localtime')
    where note_id = new.note_id and exists(select * from jsharmony_meta where {{audit_seq}} is not null)\; 

  update jsharmony_meta set {{audit_seq}} = null\;
end;

create trigger {schema}_note__tbl_delete before delete on {schema}_note__tbl
begin
  %%%log_audit_delete_mult("{schema}_note__tbl","old.note_id",["note_id","cust_id","note_scope","note_scope_id","item_id","note_sts","note_type","note_body"],"null","null","null")%%%
  update jsharmony_meta set {{audit_seq}} = null\;
end;


/***************sys_user***************/

create trigger {schema}_sys_user_before_insert before insert on {schema}_sys_user
begin
  select case when (NEW.sys_user_sts='ACTIVE') and exists(select sys_user_id from {schema}_sys_user where lower(sys_user_email) = lower(NEW.sys_user_email) and sys_user_sts = 'ACTIVE') then raise(FAIL,'Application Error - Another active user with the same email address already exists in the system') end\;
  select case when ifnull(NEW.sys_user_pw1,'')<>ifnull(NEW.sys_user_pw2,'') then raise(FAIL,'Application Error - New Password and Repeat Password are different') end\;
  select case when length(ifnull(NEW.sys_user_pw1,''))< 6 then raise(FAIL,'Application Error - Password length - at least 6 characters required') end\;
end;

create trigger {schema}_sys_user_after_insert after insert on {schema}_sys_user
begin
  update {schema}_sys_user set 
    sys_user_startdt = ifnull(NEW.sys_user_startdt,date('now','localtime')),
    sys_user_stsdt  = datetime('now','localtime'),
    sys_user_euser     = (select context from jsharmony_meta limit 1),
    sys_user_etstmp = datetime('now','localtime'),
    sys_user_muser     = (select context from jsharmony_meta limit 1),
    sys_user_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;

  insert into {schema}_sys_user_role(sys_user_id, sys_role_name) values(NEW.sys_user_id, '*')\;

  update jsharmony_meta set jsexec = '{ "function": "sha1", "table": "{schema}_sys_user", "rowid": '||NEW.rowid||', "source":"sys_user_id||sys_user_pw1||(select param_cur_val from {schema}_v_param_cur where param_cur_process=''USERS'' and param_cur_attrib=''HASH_SEED_S'')", "dest":"sys_user_hash" }, { "function": "exec", "sql": "update {schema}_sys_user set sys_user_pw1=null,sys_user_pw2=null where rowid='||NEW.rowid||'" }'\;

  %%%log_audit_insert("sys_user","new.sys_user_id","sys_user_id","null","null","null")%%%
  update jsharmony_meta set {{audit_seq}} = null\;
end;

create trigger {schema}_sys_user_before_update before update on {schema}_sys_user
begin
  select case when NEW.sys_user_stsdt is null then raise(FAIL,'sys_user_stsdt cannot be null') end\;
  select case when NEW.sys_user_id <> OLD.sys_user_id then raise(FAIL,'Application Error - ID cannot be updated.') end\;
  select case when (NEW.sys_user_sts='ACTIVE') and exists(select sys_user_id from {schema}_sys_user where lower(sys_user_email) = lower(NEW.sys_user_email) and sys_user_id <> NEW.sys_user_id and sys_user_sts = 'ACTIVE') then raise(FAIL,'Application Error - Another active user with the same email address already exists in the system') end\;
  select case when ifnull(NEW.sys_user_pw1,'')<>ifnull(NEW.sys_user_pw2,'') then raise(FAIL,'Application Error - New Password and Repeat Password are different') end\;
  select case when (NEW.sys_user_pw1 is not null) and (length(ifnull(NEW.sys_user_pw1,''))< 6) then raise(FAIL,'Application Error - Password length - at least 6 characters required') end\;
end;

create trigger {schema}_sys_user_after_update after update on {schema}_sys_user
begin
  update jsharmony_meta set jsexec = '{ "function": "sha1", "table": "{schema}_sys_user", "rowid": '||NEW.rowid||', "source":"sys_user_id||sys_user_pw1||(select param_cur_val from {schema}_v_param_cur where param_cur_process=''USERS'' and param_cur_attrib=''HASH_SEED_S'')", "dest":"sys_user_hash" }, { "function": "exec", "sql": "update {schema}_sys_user set sys_user_pw1=null,sys_user_pw2=null where rowid='||NEW.rowid||'" }'
    where NEW.sys_user_pw1 is not null\;

  %%%log_audit_update_mult("sys_user","old.sys_user_id",["sys_user_id","sys_user_sts","sys_user_fname","sys_user_mname","sys_user_lname","sys_user_jobtitle","sys_user_bphone","sys_user_cphone","sys_user_country","sys_user_addr","sys_user_city","sys_user_state","sys_user_zip","sys_user_email","sys_user_startdt","sys_user_enddt","sys_user_unotes","sys_user_lastlogin_tstmp"],"null","null","null")%%%

  %%%log_audit_update_custom("sys_user","old.sys_user_id","coalesce(NEW.sys_user_pw1,'') <> '' and coalesce(NEW.sys_user_pw1,'') <> coalesce(OLD.sys_user_pw1,'')","null","null","null")%%%
  insert into {schema}_audit_detail(audit_seq,audit_column_name,audit_column_val)
    select (select {{audit_seq}} from jsharmony_meta),'sys_user_pw1','*'
    where (coalesce(NEW.sys_user_pw1,'') <> '' and coalesce(NEW.sys_user_pw1,'') <> coalesce(OLD.sys_user_pw1,''))\;

  update {schema}_sys_user set
    sys_user_stsdt  = case when (%%%nequal("NEW.sys_user_sts","OLD.sys_user_sts")%%%) then datetime('now','localtime') else NEW.sys_user_stsdt end,
    sys_user_muser     = (select context from jsharmony_meta limit 1),
    sys_user_mtstmp = datetime('now','localtime')
    where rowid = new.rowid and exists(select * from jsharmony_meta where {{audit_seq}} is not null)\; 

  update jsharmony_meta set {{audit_seq}} = null\;
end;

create trigger {schema}_sys_user_delete before delete on {schema}_sys_user
begin
  %%%log_audit_delete_mult("sys_user","old.sys_user_id",["sys_user_id","sys_user_sts","sys_user_fname","sys_user_mname","sys_user_lname","sys_user_jobtitle","sys_user_bphone","sys_user_cphone","sys_user_country","sys_user_addr","sys_user_city","sys_user_state","sys_user_zip","sys_user_email","sys_user_startdt","sys_user_enddt","sys_user_unotes","sys_user_lastlogin_tstmp"],"null","null","null")%%%
  update jsharmony_meta set {{audit_seq}} = null\;
end;


/***************param_app***************/

create trigger {schema}_param_app_before_insert before insert on {schema}_param_app
begin
  select case when not exists(select * from {schema}_param__tbl where param_process=new.param_app_process and param_attrib = new.param_app_attrib and is_param_app=1) then raise(FAIL,'Application Error - Process parameter is not assigned for param_app in param__tbl') end\;
  select case when new.param_app_val = '' then raise(FAIL,'Application Error - Value is required') end\;
  select case when (lower((select param_type from {schema}_param__tbl where param_process=new.param_app_process and param_attrib = new.param_app_attrib))='n') and (cast(new.param_app_val as float)<>new.param_app_val) then raise(FAIL,'Application Error - Value is not numeric') end\;
end;

create trigger {schema}_param_app_after_insert after insert on {schema}_param_app
begin
  update {schema}_param_app set 
    param_app_euser     = (select context from jsharmony_meta limit 1),
    param_app_etstmp = datetime('now','localtime'),
    param_app_muser     = (select context from jsharmony_meta limit 1),
    param_app_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;

  %%%log_audit_insert("{schema}_param_app","new.param_app_id","param_app_id")%%%
  update jsharmony_meta set {{audit_seq}} = null\;
end;

create trigger {schema}_param_app_before_update before update on {schema}_param_app
begin
  select case when ifnull(old.param_app_id,'')<>ifnull(NEW.param_app_id,'') then raise(FAIL,'Application Error - ID cannot be updated.') end\;
  select case when ifnull(old.param_app_process,'')<>ifnull(NEW.param_app_process,'') then raise(FAIL,'Application Error - Process cannot be updated.') end\;
  select case when ifnull(old.param_app_attrib,'')<>ifnull(NEW.param_app_attrib,'') then raise(FAIL,'Application Error - Attribute cannot be updated.') end\;

  select case when not exists(select * from {schema}_param__tbl where param_process=new.param_app_process and param_attrib = new.param_app_attrib and is_param_app=1) then raise(FAIL,'Application Error - Process parameter is not assigned for param_app in param__tbl') end\;
  select case when new.param_app_val = '' then raise(FAIL,'Application Error - Value is required') end\;
  select case when (lower((select param_type from {schema}_param__tbl where param_process=new.param_app_process and param_attrib = new.param_app_attrib))='n') and (cast(new.param_app_val as float)<>new.param_app_val) then raise(FAIL,'Application Error - Value is not numeric') end\;
end;

create trigger {schema}_param_app_after_update after update on {schema}_param_app
begin
  %%%log_audit_update_mult("{schema}_param_app","old.param_app_id",["param_app_id","param_app_process","param_app_attrib","param_app_val"])%%%

  update {schema}_param_app set 
    param_app_muser     = (select context from jsharmony_meta limit 1),
    param_app_mtstmp = datetime('now','localtime')
    where param_app_id = new.param_app_id and exists(select * from jsharmony_meta where {{audit_seq}} is not null)\; 

  update jsharmony_meta set {{audit_seq}} = null\;
end;

create trigger {schema}_param_app_delete before delete on {schema}_param_app
begin
  %%%log_audit_delete_mult("{schema}_param_app","old.param_app_id",["param_app_id","param_app_process","param_app_attrib","param_app_val"])%%%
  update jsharmony_meta set {{audit_seq}} = null\;
end;

/***************param_sys***************/

create trigger {schema}_param_sys_before_insert before insert on {schema}_param_sys
begin
  select case when not exists(select * from {schema}_param__tbl where param_process=new.param_sys_process and param_attrib = new.param_sys_attrib and is_param_sys=1) then raise(FAIL,'Application Error - Process parameter is not assigned for param_sys in param__tbl') end\;
  select case when new.param_sys_val = '' then raise(FAIL,'Application Error - Value is required') end\;
  select case when (lower((select param_type from {schema}_param__tbl where param_process=new.param_sys_process and param_attrib = new.param_sys_attrib))='n') and (cast(new.param_sys_val as float)<>new.param_sys_val) then raise(FAIL,'Application Error - Value is not numeric') end\;
end;

create trigger {schema}_param_sys_after_insert after insert on {schema}_param_sys
begin
  update {schema}_param_sys set 
    param_sys_euser     = (select context from jsharmony_meta limit 1),
    param_sys_etstmp = datetime('now','localtime'),
    param_sys_muser     = (select context from jsharmony_meta limit 1),
    param_sys_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;

  %%%log_audit_insert("{schema}_param_sys","new.param_sys_id","param_sys_id")%%%
  update jsharmony_meta set {{audit_seq}} = null\;
end;

create trigger {schema}_param_sys_before_update before update on {schema}_param_sys
begin
  select case when ifnull(old.param_sys_id,'')<>ifnull(NEW.param_sys_id,'') then raise(FAIL,'Application Error - ID cannot be updated.') end\;
  select case when ifnull(old.param_sys_process,'')<>ifnull(NEW.param_sys_process,'') then raise(FAIL,'Application Error - Process cannot be updated.') end\;
  select case when ifnull(old.param_sys_attrib,'')<>ifnull(NEW.param_sys_attrib,'') then raise(FAIL,'Application Error - Attribute cannot be updated.') end\;

  select case when not exists(select * from {schema}_param__tbl where param_process=new.param_sys_process and param_attrib = new.param_sys_attrib and is_param_sys=1) then raise(FAIL,'Application Error - Process parameter is not assigned for param_sys in param__tbl') end\;
  select case when new.param_sys_val = '' then raise(FAIL,'Application Error - Value is required') end\;
  select case when (lower((select param_type from {schema}_param__tbl where param_process=new.param_sys_process and param_attrib = new.param_sys_attrib))='n') and (cast(new.param_sys_val as float)<>new.param_sys_val) then raise(FAIL,'Application Error - Value is not numeric') end\;
end;

create trigger {schema}_param_sys_after_update after update on {schema}_param_sys
begin
  %%%log_audit_update_mult("{schema}_param_sys","old.param_sys_id",["param_sys_id","param_sys_process","param_sys_attrib","param_sys_val"])%%%

  update {schema}_param_sys set 
    param_sys_muser     = (select context from jsharmony_meta limit 1),
    param_sys_mtstmp = datetime('now','localtime')
    where param_sys_id = new.param_sys_id and exists(select * from jsharmony_meta where {{audit_seq}} is not null)\; 

  update jsharmony_meta set {{audit_seq}} = null\;
end;

create trigger {schema}_param_sys_delete before delete on {schema}_param_sys
begin
  %%%log_audit_delete_mult("{schema}_param_sys","old.param_sys_id",["param_sys_id","param_sys_process","param_sys_attrib","param_sys_val"])%%%
  update jsharmony_meta set {{audit_seq}} = null\;
end;

/***************param_user***************/

create trigger {schema}_param_user_before_insert before insert on {schema}_param_user
begin
  select case when not exists(select * from {schema}_param__tbl where param_process=new.param_user_process and param_attrib = new.param_user_attrib and is_param_user=1) then raise(FAIL,'Application Error - Process parameter is not assigned for param_user in param__tbl') end\;
  select case when new.param_user_val = '' then raise(FAIL,'Application Error - Value is required') end\;
  select case when (lower((select param_type from {schema}_param__tbl where param_process=new.param_user_process and param_attrib = new.param_user_attrib))='n') and (cast(new.param_user_val as float)<>new.param_user_val) then raise(FAIL,'Application Error - Value is not numeric') end\;
end;

create trigger {schema}_param_user_after_insert after insert on {schema}_param_user
begin
  update {schema}_param_user set 
    param_user_euser     = (select context from jsharmony_meta limit 1),
    param_user_etstmp = datetime('now','localtime'),
    param_user_muser     = (select context from jsharmony_meta limit 1),
    param_user_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;

  %%%log_audit_insert("{schema}_param_user","new.param_user_id","param_user_id","null","null","(select coalesce(sys_user_lname,'')||', '||coalesce(sys_user_fname,'') from {schema}_sys_user where sys_user_id=new.sys_user_id)")%%%
  update jsharmony_meta set {{audit_seq}} = null\;
end;

create trigger {schema}_param_user_before_update before update on {schema}_param_user
begin
  select case when ifnull(old.param_user_id,'')<>ifnull(NEW.param_user_id,'') then raise(FAIL,'Application Error - ID cannot be updated.') end\;
  select case when ifnull(old.sys_user_id,'')<>ifnull(NEW.sys_user_id,'') then raise(FAIL,'Application Error - Personnel cannot be updated.') end\;
  select case when ifnull(old.param_user_process,'')<>ifnull(NEW.param_user_process,'') then raise(FAIL,'Application Error - Process cannot be updated.') end\;
  select case when ifnull(old.param_user_attrib,'')<>ifnull(NEW.param_user_attrib,'') then raise(FAIL,'Application Error - Attribute cannot be updated.') end\;

  select case when not exists(select * from {schema}_param__tbl where param_process=new.param_user_process and param_attrib = new.param_user_attrib and is_param_user=1) then raise(FAIL,'Application Error - Process parameter is not assigned for param_user in param__tbl') end\;
  select case when new.param_user_val = '' then raise(FAIL,'Application Error - Value is required') end\;
  select case when (lower((select param_type from {schema}_param__tbl where param_process=new.param_user_process and param_attrib = new.param_user_attrib))='n') and (cast(new.param_user_val as float)<>new.param_user_val) then raise(FAIL,'Application Error - Value is not numeric') end\;
end;

create trigger {schema}_param_user_after_update after update on {schema}_param_user
begin
  %%%log_audit_update_mult("{schema}_param_user","old.param_user_id",["param_user_id","sys_user_id","param_user_process","param_user_attrib","param_user_val"],"null","null","(select coalesce(sys_user_lname,'')||', '||coalesce(sys_user_fname,'') from {schema}_sys_user where sys_user_id=new.sys_user_id)")%%%

  update {schema}_param_user set 
    param_user_muser     = (select context from jsharmony_meta limit 1),
    param_user_mtstmp = datetime('now','localtime')
    where param_user_id = new.param_user_id and exists(select * from jsharmony_meta where {{audit_seq}} is not null)\; 

  update jsharmony_meta set {{audit_seq}} = null\;
end;

create trigger {schema}_param_user_delete before delete on {schema}_param_user
begin
  %%%log_audit_delete_mult("{schema}_param_user","old.param_user_id",["param_user_id","sys_user_id","param_user_process","param_user_attrib","param_user_val"])%%%
  update jsharmony_meta set {{audit_seq}} = null\;
end;

/***************param__tbl***************/

create trigger {schema}_param__tbl_after_insert after insert on {schema}_param__tbl
begin
  update {schema}_param__tbl set 
    param_euser     = (select context from jsharmony_meta limit 1),
    param_etstmp = datetime('now','localtime'),
    param_muser     = (select context from jsharmony_meta limit 1),
    param_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;

  %%%log_audit_insert("{schema}_param__tbl","new.param_id","param_id")%%%
  update jsharmony_meta set {{audit_seq}} = null\;
end;

create trigger {schema}_param__tbl_before_update before update on {schema}_param__tbl
begin
  select case when ifnull(old.param_id,'')<>ifnull(NEW.param_id,'') then raise(FAIL,'Application Error - ID cannot be updated.') end\;
end;

create trigger {schema}_param__tbl_after_update after update on {schema}_param__tbl
begin
  %%%log_audit_update_mult("{schema}_param__tbl","old.param_id",["param_id","param_process","param_attrib","param_desc","param_type","code_name","is_param_app","is_param_user","is_param_sys"])%%%
  
  update {schema}_param__tbl set 
    param_muser     = (select context from jsharmony_meta limit 1),
    param_mtstmp = datetime('now','localtime')
    where param_id = new.param_id and exists(select * from jsharmony_meta where {{audit_seq}} is not null)\; 

  update jsharmony_meta set {{audit_seq}} = null\;
end;

create trigger {schema}_param__tbl_delete before delete on {schema}_param__tbl
begin
  %%%log_audit_delete_mult("{schema}_param__tbl","old.param_id",["param_id","param_process","param_attrib","param_desc","param_type","code_name","is_param_app","is_param_user","is_param_sys"])%%%
  update jsharmony_meta set {{audit_seq}} = null\;
end;

/***************help__tbl***************/

create trigger {schema}_help__tbl_after_insert after insert on {schema}_help__tbl
begin
  update {schema}_help__tbl set 
    help_euser     = (select context from jsharmony_meta limit 1),
    help_etstmp = datetime('now','localtime'),
    help_muser     = (select context from jsharmony_meta limit 1),
    help_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;

  %%%log_audit_insert("{schema}_help__tbl","new.help_id","help_id","null","null","(select help_target_desc from {schema}_help_target where help_target_code=new.help_target_code)")%%%
  update jsharmony_meta set {{audit_seq}} = null\;
end;

create trigger {schema}_help__tbl_before_update before update on {schema}_help__tbl
begin
  select case when ifnull(old.help_id,'')<>ifnull(NEW.help_id,'') then raise(FAIL,'Application Error - ID cannot be updated.') end\;
end;

create trigger {schema}_help__tbl_after_update after update on {schema}_help__tbl
begin
  %%%log_audit_update_mult("{schema}_help__tbl","old.help_id",["help_id","help_target_code","help_title","help_text","help_seq","help_listing_main","help_listing_client"],"null","null","(select help_target_desc from {schema}_help_target where help_target_code=new.help_target_code)")%%%

  update {schema}_help__tbl set 
    help_muser     = (select context from jsharmony_meta limit 1),
    help_mtstmp = datetime('now','localtime')
    where help_id = new.help_id and exists(select * from jsharmony_meta where {{audit_seq}} is not null)\; 

  update jsharmony_meta set {{audit_seq}} = null\;
end;

create trigger {schema}_help__tbl_delete before delete on {schema}_help__tbl
begin
  %%%log_audit_delete_mult("{schema}_help__tbl","old.help_id",["help_id","help_target_code","help_title","help_text","help_seq","help_listing_main","help_listing_client"],"null","null","(select help_target_desc from {schema}_help_target where help_target_code=old.help_target_code)")%%%
  update jsharmony_meta set {{audit_seq}} = null\;
end;

/***************help_target***************/

create trigger {schema}_help_target_after_update after update on {schema}_help_target
begin
  update {schema}_help__tbl set 
    help_target_code = new.help_target_code
    where {schema}_help__tbl.help_target_id = new.help_target_id\;
end;

/***************sys_user_func***************/

create trigger {schema}_sys_user_func_after_insert after insert on {schema}_sys_user_func
begin
  %%%log_audit_insert("{schema}_sys_user_func","new.sys_user_func_id","sys_user_func_id","null","null","(select coalesce(sys_user_lname,'')||', '||coalesce(sys_user_fname,'') from {schema}_sys_user where sys_user_id=new.sys_user_id)")%%%
  update jsharmony_meta set {{audit_seq}} = null\;
end;

create trigger {schema}_sys_user_func_before_update before update on {schema}_sys_user_func
begin
  select case when ifnull(old.sys_user_func_id,'')<>ifnull(NEW.sys_user_func_id,'') then raise(FAIL,'Application Error - ID cannot be updated.') end\;
  select case when ifnull(old.sys_user_id,'')<>ifnull(NEW.sys_user_id,'') then raise(FAIL,'Application Error - User ID cannot be updated.') end\;
end;

create trigger {schema}_sys_user_func_after_update after update on {schema}_sys_user_func
begin
  %%%log_audit_update_mult("{schema}_sys_user_func","old.sys_user_func_id",["sys_user_func_id","sys_user_id","sys_func_name"],"null","null","(select coalesce(sys_user_lname,'')||', '||coalesce(sys_user_fname,'') from {schema}_sys_user where sys_user_id=new.sys_user_id)")%%%
  update jsharmony_meta set {{audit_seq}} = null\;
end;

create trigger {schema}_sys_user_func_delete before delete on {schema}_sys_user_func
begin
  %%%log_audit_delete_mult("{schema}_sys_user_func","old.sys_user_func_id",["sys_user_func_id","sys_user_id","sys_func_name"])%%%
  update jsharmony_meta set {{audit_seq}} = null\;
end;

/***************sys_user_role***************/

create trigger {schema}_sys_user_role_before_insert before insert on {schema}_sys_user_role
begin
  select case when (upper(new.sys_role_name)='DEV') and ({schema}.my_sys_user_id() is not null) and (not exists (select sys_role_name from {schema}.v_my_roles where sys_role_name='DEV')) then raise(FAIL,'Application Error - Only a System Developer can maintain the System Developer Role.') end\;
end;

create trigger {schema}_sys_user_role_after_insert after insert on {schema}_sys_user_role
begin
  %%%log_audit_insert("{schema}_sys_user_role","new.sys_user_role_id","sys_user_role_id","null","null","(select coalesce(sys_user_lname,'')||', '||coalesce(sys_user_fname,'') from {schema}_sys_user where sys_user_id=new.sys_user_id)")%%%
  update jsharmony_meta set {{audit_seq}} = null\;
end;

create trigger {schema}_sys_user_role_before_update before update on {schema}_sys_user_role
begin
  select case when ifnull(old.sys_user_role_id,'')<>ifnull(NEW.sys_user_role_id,'') then raise(FAIL,'Application Error - ID cannot be updated.') end\;
  select case when ifnull(old.sys_user_id,'')<>ifnull(NEW.sys_user_id,'') then raise(FAIL,'Application Error - User ID cannot be updated.') end\;
  select case when (upper(new.sys_role_name)='DEV') and ({schema}.my_sys_user_id() is not null) and (not exists (select sys_role_name from {schema}.v_my_roles where sys_role_name='DEV')) then raise(FAIL,'Application Error - Only a System Developer can maintain the System Developer Role.') end\;
end;

create trigger {schema}_sys_user_role_after_update after update on {schema}_sys_user_role
begin
  %%%log_audit_update_mult("{schema}_sys_user_role","old.sys_user_role_id",["sys_user_role_id","sys_user_id","sys_role_name"],"null","null","(select coalesce(sys_user_lname,'')||', '||coalesce(sys_user_fname,'') from {schema}_sys_user where sys_user_id=new.sys_user_id)")%%%
  update jsharmony_meta set {{audit_seq}} = null\;
end;

create trigger {schema}_sys_user_role_delete before delete on {schema}_sys_user_role
begin
  select case when (upper(old.sys_role_name)='DEV') and ({schema}.my_sys_user_id() is not null) and (not exists (select sys_role_name from {schema}.v_my_roles where sys_role_name='DEV')) then raise(FAIL,'Application Error - Only a System Developer can maintain the System Developer Role.') end\;
  %%%log_audit_delete_mult("{schema}_sys_user_role","old.sys_user_role_id",["sys_user_role_id","sys_user_id","sys_role_name"])%%%
  update jsharmony_meta set {{audit_seq}} = null\;
end;

/***************txt__tbl***************/

create trigger {schema}_txt__tbl_after_insert after insert on {schema}_txt__tbl
begin
  update {schema}_txt__tbl set 
    txt_euser     = (select context from jsharmony_meta limit 1),
    txt_etstmp = datetime('now','localtime'),
    txt_muser     = (select context from jsharmony_meta limit 1),
    txt_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;

  %%%log_audit_insert("{schema}_txt__tbl","new.txt_id","txt_id")%%%
  update jsharmony_meta set {{audit_seq}} = null\;
end;

create trigger {schema}_txt__tbl_before_update before update on {schema}_txt__tbl
begin
  select case when ifnull(old.txt_id,'')<>ifnull(NEW.txt_id,'') then raise(FAIL,'Application Error - ID cannot be updated.') end\;
end;

create trigger {schema}_txt__tbl_after_update after update on {schema}_txt__tbl
begin
  %%%log_audit_update_mult("{schema}_txt__tbl","old.txt_id",["txt_id","txt_process","txt_attrib","txt_type","txt_title","txt_body","txt_bcc","txt_desc"])%%%

  update {schema}_txt__tbl set 
    txt_muser     = (select context from jsharmony_meta limit 1),
    txt_mtstmp = datetime('now','localtime')
    where txt_id = new.txt_id and exists(select * from jsharmony_meta where {{audit_seq}} is not null)\; 

  update jsharmony_meta set {{audit_seq}} = null\;
end;

create trigger {schema}_txt__tbl_delete before delete on {schema}_txt__tbl
begin
  %%%log_audit_delete_mult("{schema}_txt__tbl","old.txt_id",["txt_id","txt_process","txt_attrib","txt_type","txt_title","txt_body","txt_bcc","txt_desc"])%%%
  update jsharmony_meta set {{audit_seq}} = null\;
end;

























/***************queue__tbl***************/

create trigger {schema}_queue__tbl_after_insert after insert on {schema}_queue__tbl
begin
  update {schema}_queue__tbl set 
    queue_euser     = (select context from jsharmony_meta limit 1),
    queue_etstmp = datetime('now','localtime')
    where rowid = new.rowid\;
end;

/***************job__tbl***************/

create trigger {schema}_job__tbl_after_insert after insert on {schema}_job__tbl
begin
  update {schema}_job__tbl set 
    job_user     = (select context from jsharmony_meta limit 1),
    job_etstmp = datetime('now','localtime')
    where rowid = new.rowid\;
end;

/***************code_app***************/

create trigger {schema}_code_app_after_insert after insert on {schema}_code_app
begin
  update {schema}_code_app set 
    code_h_euser     = (select context from jsharmony_meta limit 1),
    code_h_etstmp = datetime('now','localtime'),
    code_h_muser     = (select context from jsharmony_meta limit 1),
    code_h_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;
end;

create trigger {schema}_code_app_after_update after update on {schema}_code_app
begin
  update {schema}_code_app set 
    code_h_muser     = (select context from jsharmony_meta limit 1),
    code_h_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;
end;

/***************code2_app***************/

create trigger {schema}_code2_app_after_insert after insert on {schema}_code2_app
begin
  update {schema}_code2_app set 
    code_h_euser     = (select context from jsharmony_meta limit 1),
    code_h_etstmp = datetime('now','localtime'),
    code_h_muser     = (select context from jsharmony_meta limit 1),
    code_h_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;
end;

create trigger {schema}_code2_app_after_update after update on {schema}_code2_app
begin
  update {schema}_code2_app set 
    code_h_muser     = (select context from jsharmony_meta limit 1),
    code_h_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;
end;

/***************code_sys***************/

create trigger if not exists {schema}_code_sys_after_insert after insert on {schema}_code_sys
begin
  update {schema}_code_sys set 
    code_h_euser     = (select context from jsharmony_meta limit 1),
    code_h_etstmp = datetime('now','localtime'),
    code_h_muser     = (select context from jsharmony_meta limit 1),
    code_h_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;
end;

create trigger  if not exists {schema}_code_sys_after_update after update on {schema}_code_sys
begin
  update {schema}_code_sys set 
    code_h_muser     = (select context from jsharmony_meta limit 1),
    code_h_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;
end;

/***************code2_sys***************/

create trigger  if not exists {schema}_code2_sys_after_insert after insert on {schema}_code2_sys
begin
  update {schema}_code2_sys set 
    code_h_euser     = (select context from jsharmony_meta limit 1),
    code_h_etstmp = datetime('now','localtime'),
    code_h_muser     = (select context from jsharmony_meta limit 1),
    code_h_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;
end;

create trigger  if not exists {schema}_code2_sys_after_update after update on {schema}_code2_sys
begin
  update {schema}_code2_sys set 
    code_h_muser     = (select context from jsharmony_meta limit 1),
    code_h_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;
end;

/***************version__tbl***************/

create trigger {schema}_version__tbl_after_insert after insert on {schema}_version__tbl
begin
  update {schema}_version__tbl set 
    version_euser     = (select context from jsharmony_meta limit 1),
    version_etstmp = datetime('now','localtime'),
    version_muser     = (select context from jsharmony_meta limit 1),
    version_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;
end;

create trigger {schema}_version__tbl_after_update after update on {schema}_version__tbl
begin
  update {schema}_version__tbl set 
    version_muser     = (select context from jsharmony_meta limit 1),
    version_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;
end;
