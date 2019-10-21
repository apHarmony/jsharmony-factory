/***************cust_user_role***************/

create trigger {schema}_cust_user_role_insert after insert on {schema}_cust_user_role
begin
  %%%log_audit_insert("{schema}_cust_user_role","new.cust_user_role_id","cust_user_role_id","null","null","(select coalesce(sys_user_lname,'')||', '||coalesce(sys_user_fname,'') from {schema}_cust_user where {schema}_cust_user.sys_user_id = new.sys_user_id)","{schema}.get_cust_id('cust_user',new.sys_user_id)")%%%
  update jsharmony_meta set {{audit_seq}} = null\;
end;

create trigger {schema}_cust_user_role_update before update on {schema}_cust_user_role
begin
  select case when ifnull(old.cust_user_role_id,'')<>ifnull(NEW.cust_user_role_id,'') then raise(FAIL,'Application Error - ID cannot be updated.') end\;
  select case when ifnull(old.sys_user_id,'')<>ifnull(NEW.sys_user_id,'') then raise(FAIL,'Application Error - Customer User ID cannot be updated.') end\;

  %%%log_audit_update_mult("{schema}_cust_user_role","old.cust_user_role_id",["sys_user_id","cust_role_name"],"null","null","(select coalesce(sys_user_lname,'')||', '||coalesce(sys_user_fname,'') from {schema}_cust_user where {schema}_cust_user.sys_user_id = new.sys_user_id)","{schema}.get_cust_id('cust_user',new.sys_user_id)")%%%
  update jsharmony_meta set {{audit_seq}} = null\;
end;

create trigger {schema}_cust_user_role_delete before delete on {schema}_cust_user_role
begin
  %%%log_audit_delete_mult("{schema}_cust_user_role","old.cust_user_role_id",["sys_user_id","cust_role_name"],"null","null","null","{schema}.get_cust_id('cust_user',old.sys_user_id)")%%%
  update jsharmony_meta set {{audit_seq}} = null\;
end;


/***************cust_user***************/

create trigger {schema}_cust_user_before_insert before insert on {schema}_cust_user
begin
  select case when ifnull(NEW.sys_user_pw1,'')<>ifnull(NEW.sys_user_pw2,'') then raise(FAIL,'Application Error - New Password and Repeat Password are different') end\;
  select case when length(ifnull(NEW.sys_user_pw1,''))< 6 then raise(FAIL,'Application Error - Password length - at least 6 characters required') end\;
end;

create trigger {schema}_cust_user_after_insert after insert on {schema}_cust_user
begin
  update {schema}_cust_user set 
    sys_user_stsdt  = datetime('now','localtime'),
    sys_user_euser     = (select context from jsharmony_meta limit 1),
    sys_user_etstmp = datetime('now','localtime'),
    sys_user_muser     = (select context from jsharmony_meta limit 1),
    sys_user_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;

  update jsharmony_meta set jsexec = '{ "function": "sha1", "table": "{schema}_cust_user", "rowid": '||NEW.rowid||', "source":"sys_user_id||sys_user_pw1||(select param_cur_val from {schema}_v_param_cur where param_cur_process=''USERS'' and param_cur_attrib=''HASH_SEED_C'')", "dest":"sys_user_hash" }, { "function": "exec", "sql": "update {schema}_cust_user set sys_user_pw1=null,sys_user_pw2=null where rowid='||NEW.rowid||'" }'\;

  %%%log_audit_insert("cust_user","new.sys_user_id","sys_user_id","null","null","(select coalesce(new.sys_user_lname,'')||', '||coalesce(new.sys_user_fname,''))","new.cust_id")%%%
  update jsharmony_meta set {{audit_seq}} = null\;

  insert into {schema}_cust_user_role(sys_user_id, cust_role_name) values(new.sys_user_id, 'C*')\;

end;

create trigger {schema}_cust_user_before_update before update on {schema}_cust_user
begin
  select case when NEW.sys_user_stsdt is null then raise(FAIL,'sys_user_stsdt cannot be null') end\;
  select case when NEW.sys_user_id <> OLD.sys_user_id then raise(FAIL,'Application Error - ID cannot be updated.') end\;
  select case when NEW.cust_id <> OLD.cust_id then raise(FAIL,'Application Error - Customer ID cannot be updated.') end\;
  select case when ifnull(NEW.sys_user_pw1,'')<>ifnull(NEW.sys_user_pw2,'') then raise(FAIL,'Application Error - New Password and Repeat Password are different') end\;
  select case when (NEW.sys_user_pw1 is not null) and (length(ifnull(NEW.sys_user_pw1,''))< 6) then raise(FAIL,'Application Error - Password length - at least 6 characters required') end\;
end;

create trigger {schema}_cust_user_after_update after update on {schema}_cust_user
begin
  %%%log_audit_update_mult("cust_user","new.sys_user_id",["sys_user_id","cust_id","sys_user_sts","sys_user_fname","sys_user_mname","sys_user_lname","sys_user_jobtitle","sys_user_bphone","sys_user_cphone","sys_user_email","sys_user_lastlogin_tstmp"],"null","null","(select coalesce(new.sys_user_lname,'')||', '||coalesce(new.sys_user_fname,''))","new.cust_id")%%%

  %%%log_audit_update_custom("cust_user","new.sys_user_id","coalesce(NEW.sys_user_pw1,'') <> '' and coalesce(NEW.sys_user_pw1,'') <> coalesce(OLD.sys_user_pw1,'')","null","null","(select coalesce(new.sys_user_lname,'')||', '||coalesce(new.sys_user_fname,''))","new.cust_id")%%%
  insert into {schema}_audit_detail(audit_seq,audit_column_name,audit_column_val)
    select (select {{audit_seq}} from jsharmony_meta),'sys_user_pw1','*'
    where (coalesce(NEW.sys_user_pw1,'') <> '' and coalesce(NEW.sys_user_pw1,'') <> coalesce(OLD.sys_user_pw1,''))\;


  update jsharmony_meta set jsexec = '{ "function": "sha1", "table": "{schema}_cust_user", "rowid": '||NEW.rowid||', "source":"sys_user_id||sys_user_pw1||(select param_cur_val from {schema}_v_param_cur where param_cur_process=''USERS'' and param_cur_attrib=''HASH_SEED_C'')", "dest":"sys_user_hash" }, { "function": "exec", "sql": "update {schema}_cust_user set sys_user_pw1=null,sys_user_pw2=null where rowid='||NEW.rowid||'" }'
    where NEW.sys_user_pw1 is not null\;

  update {schema}_cust_user set
    sys_user_stsdt  = case when (%%%nequal("NEW.sys_user_sts","OLD.sys_user_sts")%%%) then datetime('now','localtime') else NEW.sys_user_stsdt end,
    sys_user_muser     = (select context from jsharmony_meta limit 1),
    sys_user_mtstmp = datetime('now','localtime')
    where rowid = new.rowid and exists(select * from jsharmony_meta where {{audit_seq}} is not null)\; 

  update jsharmony_meta set {{audit_seq}} = null\;
end;

create trigger {schema}_cust_user_delete before delete on {schema}_cust_user
begin
  %%%log_audit_delete_mult("cust_user","old.sys_user_id",["sys_user_id","cust_id","sys_user_sts","sys_user_fname","sys_user_mname","sys_user_lname","sys_user_jobtitle","sys_user_bphone","sys_user_cphone","sys_user_email","sys_user_lastlogin_tstmp"],"null","null","null","null")%%%
  update jsharmony_meta set {{audit_seq}} = null\;
end;
