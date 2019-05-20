/***************TABLE TRIGGERS***************/

/***************{cust_user_role}***************/

create trigger {schema}_{cust_user_role}_insert after insert on {schema}_{cust_user_role}
begin
  %%%{log_audit_insert}("{schema}_{cust_user_role}","new.{cust_user_role_id}","{cust_user_role_id}","null","null","(select coalesce({sys_user_lname},'')||', '||coalesce({sys_user_fname},'') from {schema}_{cust_user} where {schema}_{cust_user}.{sys_user_id} = new.{sys_user_id})","{schema}.{get_cust_id}('{cust_user}',new.{sys_user_id})")%%%
  update jsharmony_meta set {audit_seq} = null\;
end;

create trigger {schema}_{cust_user_role}_update before update on {schema}_{cust_user_role}
begin
  select case when ifnull(old.{cust_user_role_id},'')<>ifnull(NEW.{cust_user_role_id},'') then raise(FAIL,'Application Error - ID cannot be updated.') end\;
  select case when ifnull(old.{sys_user_id},'')<>ifnull(NEW.{sys_user_id},'') then raise(FAIL,'Application Error - Customer User ID cannot be updated.') end\;

  %%%{log_audit_update_mult}("{schema}_{cust_user_role}","old.{cust_user_role_id}",["{sys_user_id}","{cust_role_name}"],"null","null","(select coalesce({sys_user_lname},'')||', '||coalesce({sys_user_fname},'') from {schema}_{cust_user} where {schema}_{cust_user}.{sys_user_id} = new.{sys_user_id})","{schema}.{get_cust_id}('{cust_user}',new.{sys_user_id})")%%%
  update jsharmony_meta set {audit_seq} = null\;
end;

create trigger {schema}_{cust_user_role}_delete before delete on {schema}_{cust_user_role}
begin
  %%%{log_audit_delete_mult}("{schema}_{cust_user_role}","old.{cust_user_role_id}",["{sys_user_id}","{cust_role_name}"],"null","null","null","{schema}.{get_cust_id}('{cust_user}',old.{sys_user_id})")%%%
  update jsharmony_meta set {audit_seq} = null\;
end;


/***************{doc}***************/

create trigger {schema}_{doc}_before_insert before insert on {schema}_{doc}
begin
  select case when new.{doc_scope}='S' and new.{doc_scope_id}<>0 then raise(FAIL,'Application Error - SCOPE_ID inconsistent with SCOPE') end\;
  select case when new.{doc_scope}<>'S' and new.{doc_scope_id} is null then raise(FAIL,'Application Error - SCOPE_ID inconsistent with SCOPE') end\;
  select case when ({schema}.{my_cust_id}() is not null) and 
    (({schema}.{get_cust_id}(new.{doc_scope},new.{doc_scope_id})<>{schema}.{my_cust_id}()) or
     (new.{doc_scope} not in %%%{client_scope}%%%))
    then raise(FAIL,'Application Error - Client User has no rights to perform this operation') end\;
  select case when not exists (select * from {schema}_{code2_doc_ctgr} where {code_val1}=new.{doc_scope} and {code_va12}=new.{doc_ctgr}) then raise(FAIL,'Document type not allowed for selected scope') end\;
end;

create trigger {schema}_{doc}_after_insert after insert on {schema}_{doc}
begin
  update {schema}_{doc} set 
    {cust_id}     = {schema}.{get_cust_id}(new.{doc_scope},new.{doc_scope_id}),
    {item_id}     = {schema}.{get_item_id}(new.{doc_scope},new.{doc_scope_id}),
    {doc_euser}     = (select context from jsharmony_meta limit 1),
    {doc_etstmp} = datetime('now','localtime'),
    {doc_muser}     = (select context from jsharmony_meta limit 1),
    {doc_mtstmp} = datetime('now','localtime')
    where rowid = new.rowid\;

  %%%{log_audit_insert}("{schema}_{doc}","new.{doc_id}","{doc_id}","null","null","null","{schema}.{get_cust_id}(new.{doc_scope},new.{doc_scope_id})","{schema}.{get_item_id}(new.{doc_scope},new.{doc_scope_id})")%%%
  update jsharmony_meta set {audit_seq} = null\;
end;

create trigger {schema}_{doc}_before_update before update on {schema}_{doc}
begin
  select case when ifnull(old.{doc_id},'')<>ifnull(NEW.{doc_id},'') then raise(FAIL,'Application Error - ID cannot be updated.') end\;
  select case when ifnull(old.{doc_scope},'')<>ifnull(NEW.{doc_scope},'') then raise(FAIL,'Application Error - Scope cannot be updated.') end\;
  select case when ifnull(old.{doc_scope_id},'')<>ifnull(NEW.{doc_scope_id},'') then raise(FAIL,'Application Error - Scope ID cannot be updated.') end\;
  select case when ifnull(old.{doc_ctgr},'')<>ifnull(NEW.{doc_ctgr},'') then raise(FAIL,'Application Error - Document Category cannot be updated.') end\;
  select case when not exists (select * from {schema}_{code2_doc_ctgr} where {code_val1}=new.{doc_scope} and {code_va12}=new.{doc_ctgr}) then raise(FAIL,'Document type not allowed for selected scope') end\;
end;

create trigger {schema}_{doc}_after_update after update on {schema}_{doc}
begin
  %%%{log_audit_update_mult}("{schema}_{doc}","old.{doc_id}",["{doc_id}","{cust_id}","{doc_scope}","{doc_scope_id}","{item_id}","{doc_sts}","{doc_ctgr}","{doc_desc}","{doc_utstmp}","{doc_uuser}","{doc_sync_tstmp}"],"null","null","null","{schema}.{get_cust_id}(new.{doc_scope},new.{doc_scope_id})","{schema}.{get_item_id}(new.{doc_scope},new.{doc_scope_id})")%%%

  update {schema}_{doc} set 
    {cust_id}     = {schema}.{get_cust_id}(new.{doc_scope},new.{doc_scope_id}),
    {item_id}     = {schema}.{get_item_id}(new.{doc_scope},new.{doc_scope_id}),
    {doc_muser}     = (select context from jsharmony_meta limit 1),
    {doc_mtstmp} = datetime('now','localtime')
    where {doc_id} = new.{doc_id} and exists(select * from jsharmony_meta where {audit_seq} is not null)\; 

  update jsharmony_meta set {audit_seq} = null\;
end;

create trigger {schema}_{doc}_delete before delete on {schema}_{doc}
begin
  %%%{log_audit_delete_mult}("{schema}_{doc}","old.{doc_id}",["{doc_id}","{cust_id}","{doc_scope}","{doc_scope_id}","{item_id}","{doc_sts}","{doc_ctgr}","{doc_desc}","{doc_utstmp}","{doc_uuser}","{doc_sync_tstmp}"],"null","null","null")%%%
  update jsharmony_meta set {audit_seq} = null\;
end;

/***************{note}***************/

create trigger {schema}_{note}_before_insert before insert on {schema}_{note}
begin
  select case when new.{note_scope}='S' and new.{note_scope_id}<>0 then raise(FAIL,'Application Error - SCOPE_ID inconsistent with SCOPE') end\;
  select case when new.{note_scope}<>'S' and new.{note_scope_id} is null then raise(FAIL,'Application Error - SCOPE_ID inconsistent with SCOPE') end\;
  select case when ({schema}.{my_cust_id}() is not null) and 
    (({schema}.{get_cust_id}(new.{note_scope},new.{note_scope_id})<>{schema}.{my_cust_id}()) or
     (new.{note_scope} not in %%%{client_scope}%%%))
    then raise(FAIL,'Application Error - Client User has no rights to perform this operation') end\;
end;

create trigger {schema}_{note}_after_insert after insert on {schema}_{note}
begin
  update {schema}_{note} set 
    {cust_id}     = {schema}.{get_cust_id}(new.{note_scope},new.{note_scope_id}),
    {item_id}     = {schema}.{get_item_id}(new.{note_scope},new.{note_scope_id}),
    {note_euser}     = (select context from jsharmony_meta limit 1),
    {note_etstmp} = datetime('now','localtime'),
    {note_muser}     = (select context from jsharmony_meta limit 1),
    {note_mtstmp} = datetime('now','localtime')
    where rowid = new.rowid\;

  %%%{log_audit_insert}("{schema}_{note}","new.{note_id}","{note_id}","null","null","null","{schema}.{get_cust_id}(new.{note_scope},new.{note_scope_id})","{schema}.{get_item_id}(new.{note_scope},new.{note_scope_id})")%%%
  update jsharmony_meta set {audit_seq} = null\;
end;

create trigger {schema}_{note}_before_update before update on {schema}_{note}
begin
  select case when ifnull(old.{note_id},'')<>ifnull(NEW.{note_id},'') then raise(FAIL,'Application Error - ID cannot be updated.') end\;
  select case when ifnull(old.{note_scope},'')<>ifnull(NEW.{note_scope},'') then raise(FAIL,'Application Error - Scope cannot be updated.') end\;
  select case when ifnull(old.{note_scope_id},'')<>ifnull(NEW.{note_scope_id},'') then raise(FAIL,'Application Error - Scope ID cannot be updated.') end\;
  select case when ifnull(old.{note_type},'')<>ifnull(NEW.{note_type},'') then raise(FAIL,'Application Error - Note Type cannot be updated.') end\;
end;

create trigger {schema}_{note}_after_update after update on {schema}_{note}
begin
  %%%{log_audit_update_mult}("{schema}_{note}","old.{note_id}",["{note_id}","{cust_id}","{note_scope}","{note_scope_id}","{item_id}","{note_sts}","{note_type}","{note_body}"],"null","null","null","{schema}.{get_cust_id}(new.{note_scope},new.{note_scope_id})","{schema}.{get_item_id}(new.{note_scope},new.{note_scope_id})")%%%

  update {schema}_{note} set 
    {cust_id}     = {schema}.{get_cust_id}(new.{note_scope},new.{note_scope_id}),
    {item_id}     = {schema}.{get_item_id}(new.{note_scope},new.{note_scope_id}),
    {note_muser}     = (select context from jsharmony_meta limit 1),
    {note_mtstmp} = datetime('now','localtime')
    where {note_id} = new.{note_id} and exists(select * from jsharmony_meta where {audit_seq} is not null)\; 

  update jsharmony_meta set {audit_seq} = null\;
end;

create trigger {schema}_{note}_delete before delete on {schema}_{note}
begin
  %%%{log_audit_delete_mult}("{schema}_{note}","old.{note_id}",["{note_id}","{cust_id}","{note_scope}","{note_scope_id}","{item_id}","{note_sts}","{note_type}","{note_body}"],"null","null","null")%%%
  update jsharmony_meta set {audit_seq} = null\;
end;


/***************{sys_user}***************/

create trigger {schema}_{sys_user}_before_insert before insert on {schema}_{sys_user}
begin
  select case when ifnull(NEW.{sys_user_pw1},'')<>ifnull(NEW.{sys_user_pw2},'') then raise(FAIL,'Application Error - New Password and Repeat Password are different') end\;
  select case when length(ifnull(NEW.{sys_user_pw1},''))< 6 then raise(FAIL,'Application Error - Password length - at least 6 characters required') end\;
end;

create trigger {schema}_{sys_user}_after_insert after insert on {schema}_{sys_user}
begin
  update {schema}_{sys_user} set 
    {sys_user_startdt} = ifnull(NEW.{sys_user_startdt},date('now','localtime')),
    {sys_user_stsdt}  = datetime('now','localtime'),
    {sys_user_euser}     = (select context from jsharmony_meta limit 1),
    {sys_user_etstmp} = datetime('now','localtime'),
    {sys_user_muser}     = (select context from jsharmony_meta limit 1),
    {sys_user_mtstmp} = datetime('now','localtime')
    where rowid = new.rowid\;

  update jsharmony_meta set jsexec = '{ "function": "sha1", "table": "{schema}_{sys_user}", "rowid": '||NEW.rowid||', "source":"{sys_user_id}||{sys_user_pw1}||(select {param_cur_val} from {schema}_{v_param_cur} where {param_cur_process}=''USERS'' and {param_cur_attrib}=''HASH_SEED_S'')", "dest":"{sys_user_hash}" }, { "function": "exec", "sql": "update {schema}_{sys_user} set {sys_user_pw1}=null,{sys_user_pw2}=null where rowid='||NEW.rowid||'" }'\;

  %%%{log_audit_insert}("{sys_user}","new.{sys_user_id}","{sys_user_id}","null","null","null")%%%
  update jsharmony_meta set {audit_seq} = null\;
end;

create trigger {schema}_{sys_user}_before_update before update on {schema}_{sys_user}
begin
  select case when NEW.{sys_user_stsdt} is null then raise(FAIL,'{sys_user_stsdt} cannot be null') end\;
  select case when NEW.{sys_user_id} <> OLD.{sys_user_id} then raise(FAIL,'Application Error - ID cannot be updated.') end\;
  select case when ifnull(NEW.{sys_user_pw1},'')<>ifnull(NEW.{sys_user_pw2},'') then raise(FAIL,'Application Error - New Password and Repeat Password are different') end\;
  select case when (NEW.{sys_user_pw1} is not null) and (length(ifnull(NEW.{sys_user_pw1},''))< 6) then raise(FAIL,'Application Error - Password length - at least 6 characters required') end\;
end;

create trigger {schema}_{sys_user}_after_update after update on {schema}_{sys_user}
begin
  update jsharmony_meta set jsexec = '{ "function": "sha1", "table": "{schema}_{sys_user}", "rowid": '||NEW.rowid||', "source":"{sys_user_id}||{sys_user_pw1}||(select {param_cur_val} from {schema}_{v_param_cur} where {param_cur_process}=''USERS'' and {param_cur_attrib}=''HASH_SEED_S'')", "dest":"{sys_user_hash}" }, { "function": "exec", "sql": "update {schema}_{sys_user} set {sys_user_pw1}=null,{sys_user_pw2}=null where rowid='||NEW.rowid||'" }'
    where NEW.{sys_user_pw1} is not null\;

  %%%{log_audit_update_mult}("{sys_user}","old.{sys_user_id}",["{sys_user_id}","{sys_user_sts}","{sys_user_fname}","{sys_user_mname}","{sys_user_lname}","{sys_user_jobtitle}","{sys_user_bphone}","{sys_user_cphone}","{sys_user_country}","{sys_user_addr}","{sys_user_city}","{sys_user_state}","{sys_user_zip}","{sys_user_email}","{sys_user_startdt}","{sys_user_enddt}","{sys_user_unotes}","{sys_user_lastlogin_tstmp}"],"null","null","null")%%%

  %%%{log_audit_update_custom}("{sys_user}","old.{sys_user_id}","coalesce(NEW.{sys_user_pw1},'') <> '' and coalesce(NEW.{sys_user_pw1},'') <> coalesce(OLD.{sys_user_pw1},'')","null","null","null")%%%
  insert into {schema}_{audit_detail}({audit_seq},{audit_column_name},{audit_column_val})
    select (select {audit_seq} from jsharmony_meta),'{sys_user_pw1}','*'
    where (coalesce(NEW.{sys_user_pw1},'') <> '' and coalesce(NEW.{sys_user_pw1},'') <> coalesce(OLD.{sys_user_pw1},''))\;

  update {schema}_{sys_user} set
    {sys_user_stsdt}  = case when (%%%{nequal}("NEW.{sys_user_sts}","OLD.{sys_user_sts}")%%%) then datetime('now','localtime') else NEW.{sys_user_stsdt} end,
    {sys_user_muser}     = (select context from jsharmony_meta limit 1),
    {sys_user_mtstmp} = datetime('now','localtime')
    where rowid = new.rowid and exists(select * from jsharmony_meta where {audit_seq} is not null)\; 

  update jsharmony_meta set {audit_seq} = null\;
end;

create trigger {schema}_{sys_user}_delete before delete on {schema}_{sys_user}
begin
  %%%{log_audit_delete_mult}("{sys_user}","old.{sys_user_id}",["{sys_user_id}","{sys_user_sts}","{sys_user_fname}","{sys_user_mname}","{sys_user_lname}","{sys_user_jobtitle}","{sys_user_bphone}","{sys_user_cphone}","{sys_user_country}","{sys_user_addr}","{sys_user_city}","{sys_user_state}","{sys_user_zip}","{sys_user_email}","{sys_user_startdt}","{sys_user_enddt}","{sys_user_unotes}","{sys_user_lastlogin_tstmp}"],"null","null","null")%%%
  update jsharmony_meta set {audit_seq} = null\;
end;

/***************{cust_user}***************/

create trigger {schema}_{cust_user}_before_insert before insert on {schema}_{cust_user}
begin
  select case when ifnull(NEW.{sys_user_pw1},'')<>ifnull(NEW.{sys_user_pw2},'') then raise(FAIL,'Application Error - New Password and Repeat Password are different') end\;
  select case when length(ifnull(NEW.{sys_user_pw1},''))< 6 then raise(FAIL,'Application Error - Password length - at least 6 characters required') end\;
end;

create trigger {schema}_{cust_user}_after_insert after insert on {schema}_{cust_user}
begin
  update {schema}_{cust_user} set 
    {sys_user_stsdt}  = datetime('now','localtime'),
    {sys_user_euser}     = (select context from jsharmony_meta limit 1),
    {sys_user_etstmp} = datetime('now','localtime'),
    {sys_user_muser}     = (select context from jsharmony_meta limit 1),
    {sys_user_mtstmp} = datetime('now','localtime')
    where rowid = new.rowid\;

  update jsharmony_meta set jsexec = '{ "function": "sha1", "table": "{schema}_{cust_user}", "rowid": '||NEW.rowid||', "source":"{sys_user_id}||{sys_user_pw1}||(select {param_cur_val} from {schema}_{v_param_cur} where {param_cur_process}=''USERS'' and {param_cur_attrib}=''HASH_SEED_C'')", "dest":"{sys_user_hash}" }, { "function": "exec", "sql": "update {schema}_{cust_user} set {sys_user_pw1}=null,{sys_user_pw2}=null where rowid='||NEW.rowid||'" }'\;

  %%%{log_audit_insert}("{cust_user}","new.{sys_user_id}","{sys_user_id}","null","null","(select coalesce(new.{sys_user_lname},'')||', '||coalesce(new.{sys_user_fname},''))","new.{cust_id}")%%%
  update jsharmony_meta set {audit_seq} = null\;

  insert into {schema}_{cust_user_role}({sys_user_id}, {cust_role_name}) values(new.{sys_user_id}, 'C*')\;

end;

create trigger {schema}_{cust_user}_before_update before update on {schema}_{cust_user}
begin
  select case when NEW.{sys_user_stsdt} is null then raise(FAIL,'{sys_user_stsdt} cannot be null') end\;
  select case when NEW.{sys_user_id} <> OLD.{sys_user_id} then raise(FAIL,'Application Error - ID cannot be updated.') end\;
  select case when NEW.{cust_id} <> OLD.{cust_id} then raise(FAIL,'Application Error - Customer ID cannot be updated.') end\;
  select case when ifnull(NEW.{sys_user_pw1},'')<>ifnull(NEW.{sys_user_pw2},'') then raise(FAIL,'Application Error - New Password and Repeat Password are different') end\;
  select case when (NEW.{sys_user_pw1} is not null) and (length(ifnull(NEW.{sys_user_pw1},''))< 6) then raise(FAIL,'Application Error - Password length - at least 6 characters required') end\;
end;

create trigger {schema}_{cust_user}_after_update after update on {schema}_{cust_user}
begin
  %%%{log_audit_update_mult}("{cust_user}","new.{sys_user_id}",["{sys_user_id}","{cust_id}","{sys_user_sts}","{sys_user_fname}","{sys_user_mname}","{sys_user_lname}","{sys_user_jobtitle}","{sys_user_bphone}","{sys_user_cphone}","{sys_user_email}","{sys_user_lastlogin_tstmp}"],"null","null","(select coalesce(new.{sys_user_lname},'')||', '||coalesce(new.{sys_user_fname},''))","new.{cust_id}")%%%

  %%%{log_audit_update_custom}("{cust_user}","new.{sys_user_id}","coalesce(NEW.{sys_user_pw1},'') <> '' and coalesce(NEW.{sys_user_pw1},'') <> coalesce(OLD.{sys_user_pw1},'')","null","null","(select coalesce(new.{sys_user_lname},'')||', '||coalesce(new.{sys_user_fname},''))","new.{cust_id}")%%%
  insert into {schema}_{audit_detail}({audit_seq},{audit_column_name},{audit_column_val})
    select (select {audit_seq} from jsharmony_meta),'{sys_user_pw1}','*'
    where (coalesce(NEW.{sys_user_pw1},'') <> '' and coalesce(NEW.{sys_user_pw1},'') <> coalesce(OLD.{sys_user_pw1},''))\;


  update jsharmony_meta set jsexec = '{ "function": "sha1", "table": "{schema}_{cust_user}", "rowid": '||NEW.rowid||', "source":"{sys_user_id}||{sys_user_pw1}||(select {param_cur_val} from {schema}_{v_param_cur} where {param_cur_process}=''USERS'' and {param_cur_attrib}=''HASH_SEED_C'')", "dest":"{sys_user_hash}" }, { "function": "exec", "sql": "update {schema}_{cust_user} set {sys_user_pw1}=null,{sys_user_pw2}=null where rowid='||NEW.rowid||'" }'
    where NEW.{sys_user_pw1} is not null\;

  update {schema}_{cust_user} set
    {sys_user_stsdt}  = case when (%%%{nequal}("NEW.{sys_user_sts}","OLD.{sys_user_sts}")%%%) then datetime('now','localtime') else NEW.{sys_user_stsdt} end,
    {sys_user_muser}     = (select context from jsharmony_meta limit 1),
    {sys_user_mtstmp} = datetime('now','localtime')
    where rowid = new.rowid and exists(select * from jsharmony_meta where {audit_seq} is not null)\; 

  update jsharmony_meta set {audit_seq} = null\;
end;

create trigger {schema}_{cust_user}_delete before delete on {schema}_{cust_user}
begin
  %%%{log_audit_delete_mult}("{cust_user}","old.{sys_user_id}",["{sys_user_id}","{cust_id}","{sys_user_sts}","{sys_user_fname}","{sys_user_mname}","{sys_user_lname}","{sys_user_jobtitle}","{sys_user_bphone}","{sys_user_cphone}","{sys_user_email}","{sys_user_lastlogin_tstmp}"],"null","null","null","null")%%%
  update jsharmony_meta set {audit_seq} = null\;
end;

/***************{param_app}***************/

create trigger {schema}_{param_app}_before_insert before insert on {schema}_{param_app}
begin
  select case when not exists(select * from {schema}_{param} where {param_process}=new.{param_app_process} and {param_attrib} = new.{param_app_attrib} and {is_param_app}=1) then raise(FAIL,'Application Error - Process parameter is not assigned for {param_app} in {param}') end\;
  select case when new.{param_app_val} = '' then raise(FAIL,'Application Error - Value is required') end\;
  select case when (upper((select {param_type} from {schema}_{param} where {param_process}=new.{param_app_process} and {param_attrib} = new.{param_app_attrib}))='{note}') and (cast(new.{param_app_val} as float)<>new.{param_app_val}) then raise(FAIL,'Application Error - Value is not numeric') end\;
end;

create trigger {schema}_{param_app}_after_insert after insert on {schema}_{param_app}
begin
  update {schema}_{param_app} set 
    {param_app_euser}     = (select context from jsharmony_meta limit 1),
    {param_app_etstmp} = datetime('now','localtime'),
    {param_app_muser}     = (select context from jsharmony_meta limit 1),
    {param_app_mtstmp} = datetime('now','localtime')
    where rowid = new.rowid\;

  %%%{log_audit_insert}("{schema}_{param_app}","new.{param_app_id}","{param_app_id}")%%%
  update jsharmony_meta set {audit_seq} = null\;
end;

create trigger {schema}_{param_app}_before_update before update on {schema}_{param_app}
begin
  select case when ifnull(old.{param_app_id},'')<>ifnull(NEW.{param_app_id},'') then raise(FAIL,'Application Error - ID cannot be updated.') end\;
  select case when ifnull(old.{param_app_process},'')<>ifnull(NEW.{param_app_process},'') then raise(FAIL,'Application Error - Process cannot be updated.') end\;
  select case when ifnull(old.{param_app_attrib},'')<>ifnull(NEW.{param_app_attrib},'') then raise(FAIL,'Application Error - Attribute cannot be updated.') end\;

  select case when not exists(select * from {schema}_{param} where {param_process}=new.{param_app_process} and {param_attrib} = new.{param_app_attrib} and {is_param_app}=1) then raise(FAIL,'Application Error - Process parameter is not assigned for {param_app} in {param}') end\;
  select case when new.{param_app_val} = '' then raise(FAIL,'Application Error - Value is required') end\;
  select case when (upper((select {param_type} from {schema}_{param} where {param_process}=new.{param_app_process} and {param_attrib} = new.{param_app_attrib}))='{note}') and (cast(new.{param_app_val} as float)<>new.{param_app_val}) then raise(FAIL,'Application Error - Value is not numeric') end\;
end;

create trigger {schema}_{param_app}_after_update after update on {schema}_{param_app}
begin
  %%%{log_audit_update_mult}("{schema}_{param_app}","old.{param_app_id}",["{param_app_id}","{param_app_process}","{param_app_attrib}","{param_app_val}"])%%%

  update {schema}_{param_app} set 
    {param_app_muser}     = (select context from jsharmony_meta limit 1),
    {param_app_mtstmp} = datetime('now','localtime')
    where {param_app_id} = new.{param_app_id} and exists(select * from jsharmony_meta where {audit_seq} is not null)\; 

  update jsharmony_meta set {audit_seq} = null\;
end;

create trigger {schema}_{param_app}_delete before delete on {schema}_{param_app}
begin
  %%%{log_audit_delete_mult}("{schema}_{param_app}","old.{param_app_id}",["{param_app_id}","{param_app_process}","{param_app_attrib}","{param_app_val}"])%%%
  update jsharmony_meta set {audit_seq} = null\;
end;

/***************{param_sys}***************/

create trigger {schema}_{param_sys}_before_insert before insert on {schema}_{param_sys}
begin
  select case when not exists(select * from {schema}_{param} where {param_process}=new.{param_sys_process} and {param_attrib} = new.{param_sys_attrib} and {is_param_sys}=1) then raise(FAIL,'Application Error - Process parameter is not assigned for {param_sys} in {param}') end\;
  select case when new.{param_sys_val} = '' then raise(FAIL,'Application Error - Value is required') end\;
  select case when (upper((select {param_type} from {schema}_{param} where {param_process}=new.{param_sys_process} and {param_attrib} = new.{param_sys_attrib}))='{note}') and (cast(new.{param_sys_val} as float)<>new.{param_sys_val}) then raise(FAIL,'Application Error - Value is not numeric') end\;
end;

create trigger {schema}_{param_sys}_after_insert after insert on {schema}_{param_sys}
begin
  update {schema}_{param_sys} set 
    {param_sys_euser}     = (select context from jsharmony_meta limit 1),
    {param_sys_etstmp} = datetime('now','localtime'),
    {param_sys_muser}     = (select context from jsharmony_meta limit 1),
    {param_sys_mtstmp} = datetime('now','localtime')
    where rowid = new.rowid\;

  %%%{log_audit_insert}("{schema}_{param_sys}","new.{param_sys_id}","{param_sys_id}")%%%
  update jsharmony_meta set {audit_seq} = null\;
end;

create trigger {schema}_{param_sys}_before_update before update on {schema}_{param_sys}
begin
  select case when ifnull(old.{param_sys_id},'')<>ifnull(NEW.{param_sys_id},'') then raise(FAIL,'Application Error - ID cannot be updated.') end\;
  select case when ifnull(old.{param_sys_process},'')<>ifnull(NEW.{param_sys_process},'') then raise(FAIL,'Application Error - Process cannot be updated.') end\;
  select case when ifnull(old.{param_sys_attrib},'')<>ifnull(NEW.{param_sys_attrib},'') then raise(FAIL,'Application Error - Attribute cannot be updated.') end\;

  select case when not exists(select * from {schema}_{param} where {param_process}=new.{param_sys_process} and {param_attrib} = new.{param_sys_attrib} and {is_param_sys}=1) then raise(FAIL,'Application Error - Process parameter is not assigned for {param_sys} in {param}') end\;
  select case when new.{param_sys_val} = '' then raise(FAIL,'Application Error - Value is required') end\;
  select case when (upper((select {param_type} from {schema}_{param} where {param_process}=new.{param_sys_process} and {param_attrib} = new.{param_sys_attrib}))='{note}') and (cast(new.{param_sys_val} as float)<>new.{param_sys_val}) then raise(FAIL,'Application Error - Value is not numeric') end\;
end;

create trigger {schema}_{param_sys}_after_update after update on {schema}_{param_sys}
begin
  %%%{log_audit_update_mult}("{schema}_{param_sys}","old.{param_sys_id}",["{param_sys_id}","{param_sys_process}","{param_sys_attrib}","{param_sys_val}"])%%%

  update {schema}_{param_sys} set 
    {param_sys_muser}     = (select context from jsharmony_meta limit 1),
    {param_sys_mtstmp} = datetime('now','localtime')
    where {param_sys_id} = new.{param_sys_id} and exists(select * from jsharmony_meta where {audit_seq} is not null)\; 

  update jsharmony_meta set {audit_seq} = null\;
end;

create trigger {schema}_{param_sys}_delete before delete on {schema}_{param_sys}
begin
  %%%{log_audit_delete_mult}("{schema}_{param_sys}","old.{param_sys_id}",["{param_sys_id}","{param_sys_process}","{param_sys_attrib}","{param_sys_val}"])%%%
  update jsharmony_meta set {audit_seq} = null\;
end;

/***************{param_user}***************/

create trigger {schema}_{param_user}_before_insert before insert on {schema}_{param_user}
begin
  select case when not exists(select * from {schema}_{param} where {param_process}=new.{param_user_process} and {param_attrib} = new.{param_user_attrib} and {is_param_user}=1) then raise(FAIL,'Application Error - Process parameter is not assigned for {param_user} in {param}') end\;
  select case when new.{param_user_val} = '' then raise(FAIL,'Application Error - Value is required') end\;
  select case when (upper((select {param_type} from {schema}_{param} where {param_process}=new.{param_user_process} and {param_attrib} = new.{param_user_attrib}))='{note}') and (cast(new.{param_user_val} as float)<>new.{param_user_val}) then raise(FAIL,'Application Error - Value is not numeric') end\;
end;

create trigger {schema}_{param_user}_after_insert after insert on {schema}_{param_user}
begin
  update {schema}_{param_user} set 
    {param_user_euser}     = (select context from jsharmony_meta limit 1),
    {param_user_etstmp} = datetime('now','localtime'),
    {param_user_muser}     = (select context from jsharmony_meta limit 1),
    {param_user_mtstmp} = datetime('now','localtime')
    where rowid = new.rowid\;

  %%%{log_audit_insert}("{schema}_{param_user}","new.{param_user_id}","{param_user_id}","null","null","(select coalesce({sys_user_lname},'')||', '||coalesce({sys_user_fname},'') from {schema}_{sys_user} where {sys_user_id}=new.{sys_user_id})")%%%
  update jsharmony_meta set {audit_seq} = null\;
end;

create trigger {schema}_{param_user}_before_update before update on {schema}_{param_user}
begin
  select case when ifnull(old.{param_user_id},'')<>ifnull(NEW.{param_user_id},'') then raise(FAIL,'Application Error - ID cannot be updated.') end\;
  select case when ifnull(old.{sys_user_id},'')<>ifnull(NEW.{sys_user_id},'') then raise(FAIL,'Application Error - Personnel cannot be updated.') end\;
  select case when ifnull(old.{param_user_process},'')<>ifnull(NEW.{param_user_process},'') then raise(FAIL,'Application Error - Process cannot be updated.') end\;
  select case when ifnull(old.{param_user_attrib},'')<>ifnull(NEW.{param_user_attrib},'') then raise(FAIL,'Application Error - Attribute cannot be updated.') end\;

  select case when not exists(select * from {schema}_{param} where {param_process}=new.{param_user_process} and {param_attrib} = new.{param_user_attrib} and {is_param_user}=1) then raise(FAIL,'Application Error - Process parameter is not assigned for {param_user} in {param}') end\;
  select case when new.{param_user_val} = '' then raise(FAIL,'Application Error - Value is required') end\;
  select case when (upper((select {param_type} from {schema}_{param} where {param_process}=new.{param_user_process} and {param_attrib} = new.{param_user_attrib}))='{note}') and (cast(new.{param_user_val} as float)<>new.{param_user_val}) then raise(FAIL,'Application Error - Value is not numeric') end\;
end;

create trigger {schema}_{param_user}_after_update after update on {schema}_{param_user}
begin
  %%%{log_audit_update_mult}("{schema}_{param_user}","old.{param_user_id}",["{param_user_id}","{sys_user_id}","{param_user_process}","{param_user_attrib}","{param_user_val}"],"null","null","(select coalesce({sys_user_lname},'')||', '||coalesce({sys_user_fname},'') from {schema}_{sys_user} where {sys_user_id}=new.{sys_user_id})")%%%

  update {schema}_{param_user} set 
    {param_user_muser}     = (select context from jsharmony_meta limit 1),
    {param_user_mtstmp} = datetime('now','localtime')
    where {param_user_id} = new.{param_user_id} and exists(select * from jsharmony_meta where {audit_seq} is not null)\; 

  update jsharmony_meta set {audit_seq} = null\;
end;

create trigger {schema}_{param_user}_delete before delete on {schema}_{param_user}
begin
  %%%{log_audit_delete_mult}("{schema}_{param_user}","old.{param_user_id}",["{param_user_id}","{sys_user_id}","{param_user_process}","{param_user_attrib}","{param_user_val}"])%%%
  update jsharmony_meta set {audit_seq} = null\;
end;

/***************{param}***************/

create trigger {schema}_{param}_after_insert after insert on {schema}_{param}
begin
  update {schema}_{param} set 
    {param_euser}     = (select context from jsharmony_meta limit 1),
    {param_etstmp} = datetime('now','localtime'),
    {param_muser}     = (select context from jsharmony_meta limit 1),
    {param_mtstmp} = datetime('now','localtime')
    where rowid = new.rowid\;

  %%%{log_audit_insert}("{schema}_{param}","new.{param_id}","{param_id}")%%%
  update jsharmony_meta set {audit_seq} = null\;
end;

create trigger {schema}_{param}_before_update before update on {schema}_{param}
begin
  select case when ifnull(old.{param_id},'')<>ifnull(NEW.{param_id},'') then raise(FAIL,'Application Error - ID cannot be updated.') end\;
end;

create trigger {schema}_{param}_after_update after update on {schema}_{param}
begin
  %%%{log_audit_update_mult}("{schema}_{param}","old.{param_id}",["{param_id}","{param_process}","{param_attrib}","{param_desc}","{param_type}","{code_name}","{is_param_app}","{is_param_user}","{is_param_sys}"])%%%
  
  update {schema}_{param} set 
    {param_muser}     = (select context from jsharmony_meta limit 1),
    {param_mtstmp} = datetime('now','localtime')
    where {param_id} = new.{param_id} and exists(select * from jsharmony_meta where {audit_seq} is not null)\; 

  update jsharmony_meta set {audit_seq} = null\;
end;

create trigger {schema}_{param}_delete before delete on {schema}_{param}
begin
  %%%{log_audit_delete_mult}("{schema}_{param}","old.{param_id}",["{param_id}","{param_process}","{param_attrib}","{param_desc}","{param_type}","{code_name}","{is_param_app}","{is_param_user}","{is_param_sys}"])%%%
  update jsharmony_meta set {audit_seq} = null\;
end;

/***************{help}***************/

create trigger {schema}_{help}_after_insert after insert on {schema}_{help}
begin
  update {schema}_{help} set 
    {help_euser}     = (select context from jsharmony_meta limit 1),
    {help_etstmp} = datetime('now','localtime'),
    {help_muser}     = (select context from jsharmony_meta limit 1),
    {help_mtstmp} = datetime('now','localtime')
    where rowid = new.rowid\;

  %%%{log_audit_insert}("{schema}_{help}","new.{help_id}","{help_id}","null","null","(select {help_target_desc} from {schema}_{help_target} where {help_target_code}=new.{help_target_code})")%%%
  update jsharmony_meta set {audit_seq} = null\;
end;

create trigger {schema}_{help}_before_update before update on {schema}_{help}
begin
  select case when ifnull(old.{help_id},'')<>ifnull(NEW.{help_id},'') then raise(FAIL,'Application Error - ID cannot be updated.') end\;
  select case when ifnull(old.{help_target_code},'')<>ifnull(NEW.{help_target_code},'') then raise(FAIL,'Application Error - {help_target} Code cannot be updated.') end\;
end;

create trigger {schema}_{help}_after_update after update on {schema}_{help}
begin
  %%%{log_audit_update_mult}("{schema}_{help}","old.{help_id}",["{help_id}","{help_target_code}","{help_title}","{help_text}","{help_seq}","{help_listing_main}","{help_listing_client}"],"null","null","(select {help_target_desc} from {schema}_{help_target} where {help_target_code}=new.{help_target_code})")%%%

  update {schema}_{help} set 
    {help_muser}     = (select context from jsharmony_meta limit 1),
    {help_mtstmp} = datetime('now','localtime')
    where {help_id} = new.{help_id} and exists(select * from jsharmony_meta where {audit_seq} is not null)\; 

  update jsharmony_meta set {audit_seq} = null\;
end;

create trigger {schema}_{help}_delete before delete on {schema}_{help}
begin
  %%%{log_audit_delete_mult}("{schema}_{help}","old.{help_id}",["{help_id}","{help_target_code}","{help_title}","{help_text}","{help_seq}","{help_listing_main}","{help_listing_client}"],"null","null","(select {help_target_desc} from {schema}_{help_target} where {help_target_code}=old.{help_target_code})")%%%
  update jsharmony_meta set {audit_seq} = null\;
end;

/***************{sys_user_func}***************/

create trigger {schema}_{sys_user_func}_after_insert after insert on {schema}_{sys_user_func}
begin
  %%%{log_audit_insert}("{schema}_{sys_user_func}","new.{sys_user_func_id}","{sys_user_func_id}","null","null","(select coalesce({sys_user_lname},'')||', '||coalesce({sys_user_fname},'') from {schema}_{sys_user} where {sys_user_id}=new.{sys_user_id})")%%%
  update jsharmony_meta set {audit_seq} = null\;
end;

create trigger {schema}_{sys_user_func}_before_update before update on {schema}_{sys_user_func}
begin
  select case when ifnull(old.{sys_user_func_id},'')<>ifnull(NEW.{sys_user_func_id},'') then raise(FAIL,'Application Error - ID cannot be updated.') end\;
  select case when ifnull(old.{sys_user_id},'')<>ifnull(NEW.{sys_user_id},'') then raise(FAIL,'Application Error - User ID cannot be updated.') end\;
end;

create trigger {schema}_{sys_user_func}_after_update after update on {schema}_{sys_user_func}
begin
  %%%{log_audit_update_mult}("{schema}_{sys_user_func}","old.{sys_user_func_id}",["{sys_user_func_id}","{sys_user_id}","{sys_func_name}"],"null","null","(select coalesce({sys_user_lname},'')||', '||coalesce({sys_user_fname},'') from {schema}_{sys_user} where {sys_user_id}=new.{sys_user_id})")%%%
  update jsharmony_meta set {audit_seq} = null\;
end;

create trigger {schema}_{sys_user_func}_delete before delete on {schema}_{sys_user_func}
begin
  %%%{log_audit_delete_mult}("{schema}_{sys_user_func}","old.{sys_user_func_id}",["{sys_user_func_id}","{sys_user_id}","{sys_func_name}"])%%%
  update jsharmony_meta set {audit_seq} = null\;
end;

/***************{sys_user_role}***************/

create trigger {schema}_{sys_user_role}_before_insert before insert on {schema}_{sys_user_role}
begin
  select case when (upper(new.{sys_role_name})='DEV') and ({schema}.{my_sys_user_id}() is not null) and (not exists (select {sys_role_name} from {schema}.{v_my_roles} where {sys_role_name}='DEV')) then raise(FAIL,'Application Error - Only a Developer can maintain the Developer Role.') end\;
end;

create trigger {schema}_{sys_user_role}_after_insert after insert on {schema}_{sys_user_role}
begin
  %%%{log_audit_insert}("{schema}_{sys_user_role}","new.{sys_user_role_id}","{sys_user_role_id}","null","null","(select coalesce({sys_user_lname},'')||', '||coalesce({sys_user_fname},'') from {schema}_{sys_user} where {sys_user_id}=new.{sys_user_id})")%%%
  update jsharmony_meta set {audit_seq} = null\;
end;

create trigger {schema}_{sys_user_role}_before_update before update on {schema}_{sys_user_role}
begin
  select case when ifnull(old.{sys_user_role_id},'')<>ifnull(NEW.{sys_user_role_id},'') then raise(FAIL,'Application Error - ID cannot be updated.') end\;
  select case when ifnull(old.{sys_user_id},'')<>ifnull(NEW.{sys_user_id},'') then raise(FAIL,'Application Error - User ID cannot be updated.') end\;
  select case when (upper(new.{sys_role_name})='DEV') and ({schema}.{my_sys_user_id}() is not null) and (not exists (select {sys_role_name} from {schema}.{v_my_roles} where {sys_role_name}='DEV')) then raise(FAIL,'Application Error - Only a Developer can maintain the Developer Role.') end\;
end;

create trigger {schema}_{sys_user_role}_after_update after update on {schema}_{sys_user_role}
begin
  %%%{log_audit_update_mult}("{schema}_{sys_user_role}","old.{sys_user_role_id}",["{sys_user_role_id}","{sys_user_id}","{sys_role_name}"],"null","null","(select coalesce({sys_user_lname},'')||', '||coalesce({sys_user_fname},'') from {schema}_{sys_user} where {sys_user_id}=new.{sys_user_id})")%%%
  update jsharmony_meta set {audit_seq} = null\;
end;

create trigger {schema}_{sys_user_role}_delete before delete on {schema}_{sys_user_role}
begin
  select case when (upper(old.{sys_role_name})='DEV') and ({schema}.{my_sys_user_id}() is not null) and (not exists (select {sys_role_name} from {schema}.{v_my_roles} where {sys_role_name}='DEV')) then raise(FAIL,'Application Error - Only a Developer can maintain the Developer Role.') end\;
  %%%{log_audit_delete_mult}("{schema}_{sys_user_role}","old.{sys_user_role_id}",["{sys_user_role_id}","{sys_user_id}","{sys_role_name}"])%%%
  update jsharmony_meta set {audit_seq} = null\;
end;

/***************{txt}***************/

create trigger {schema}_{txt}_after_insert after insert on {schema}_{txt}
begin
  update {schema}_{txt} set 
    {txt_euser}     = (select context from jsharmony_meta limit 1),
    {txt_etstmp} = datetime('now','localtime'),
    {txt_muser}     = (select context from jsharmony_meta limit 1),
    {txt_mtstmp} = datetime('now','localtime')
    where rowid = new.rowid\;

  %%%{log_audit_insert}("{schema}_{txt}","new.{txt_id}","{txt_id}")%%%
  update jsharmony_meta set {audit_seq} = null\;
end;

create trigger {schema}_{txt}_before_update before update on {schema}_{txt}
begin
  select case when ifnull(old.{txt_id},'')<>ifnull(NEW.{txt_id},'') then raise(FAIL,'Application Error - ID cannot be updated.') end\;
end;

create trigger {schema}_{txt}_after_update after update on {schema}_{txt}
begin
  %%%{log_audit_update_mult}("{schema}_{txt}","old.{txt_id}",["{txt_id}","{txt_process}","{txt_attrib}","{txt_type}","{txt_title}","{txt_body}","{txt_bcc}","{txt_desc}"])%%%

  update {schema}_{txt} set 
    {txt_muser}     = (select context from jsharmony_meta limit 1),
    {txt_mtstmp} = datetime('now','localtime')
    where {txt_id} = new.{txt_id} and exists(select * from jsharmony_meta where {audit_seq} is not null)\; 

  update jsharmony_meta set {audit_seq} = null\;
end;

create trigger {schema}_{txt}_delete before delete on {schema}_{txt}
begin
  %%%{log_audit_delete_mult}("{schema}_{txt}","old.{txt_id}",["{txt_id}","{txt_process}","{txt_attrib}","{txt_type}","{txt_title}","{txt_body}","{txt_bcc}","{txt_desc}"])%%%
  update jsharmony_meta set {audit_seq} = null\;
end;

























/***************{queue}***************/

create trigger {schema}_{queue}_after_insert after insert on {schema}_{queue}
begin
  update {schema}_{queue} set 
    {queue_euser}     = (select context from jsharmony_meta limit 1),
    {queue_etstmp} = datetime('now','localtime')
    where rowid = new.rowid\;
end;

/***************{job}***************/

create trigger {schema}_{job}_after_insert after insert on {schema}_{job}
begin
  update {schema}_{job} set 
    {job_user}     = (select context from jsharmony_meta limit 1),
    {job_etstmp} = datetime('now','localtime')
    where rowid = new.rowid\;
end;

/***************{code_app}***************/

create trigger {schema}_{code_app}_after_insert after insert on {schema}_{code_app}
begin
  update {schema}_{code_app} set 
    {code_h_euser}     = (select context from jsharmony_meta limit 1),
    {code_h_etstmp} = datetime('now','localtime'),
    {code_h_muser}     = (select context from jsharmony_meta limit 1),
    {code_h_mtstmp} = datetime('now','localtime')
    where rowid = new.rowid\;
end;

create trigger {schema}_{code_app}_after_update after update on {schema}_{code_app}
begin
  update {schema}_{code_app} set 
    {code_h_muser}     = (select context from jsharmony_meta limit 1),
    {code_h_mtstmp} = datetime('now','localtime')
    where rowid = new.rowid\;
end;

/***************{code2_app}***************/

create trigger {schema}_{code2_app}_after_insert after insert on {schema}_{code2_app}
begin
  update {schema}_{code2_app} set 
    {code_h_euser}     = (select context from jsharmony_meta limit 1),
    {code_h_etstmp} = datetime('now','localtime'),
    {code_h_muser}     = (select context from jsharmony_meta limit 1),
    {code_h_mtstmp} = datetime('now','localtime')
    where rowid = new.rowid\;
end;

create trigger {schema}_{code2_app}_after_update after update on {schema}_{code2_app}
begin
  update {schema}_{code2_app} set 
    {code_h_muser}     = (select context from jsharmony_meta limit 1),
    {code_h_mtstmp} = datetime('now','localtime')
    where rowid = new.rowid\;
end;

/***************{code_sys}***************/

create trigger {schema}_{code_sys}_after_insert after insert on {schema}_{code_sys}
begin
  update {schema}_{code_sys} set 
    {code_h_euser}     = (select context from jsharmony_meta limit 1),
    {code_h_etstmp} = datetime('now','localtime'),
    {code_h_muser}     = (select context from jsharmony_meta limit 1),
    {code_h_mtstmp} = datetime('now','localtime')
    where rowid = new.rowid\;
end;

create trigger {schema}_{code_sys}_after_update after update on {schema}_{code_sys}
begin
  update {schema}_{code_sys} set 
    {code_h_muser}     = (select context from jsharmony_meta limit 1),
    {code_h_mtstmp} = datetime('now','localtime')
    where rowid = new.rowid\;
end;

/***************{code2_sys}***************/

create trigger {schema}_{code2_sys}_after_insert after insert on {schema}_{code2_sys}
begin
  update {schema}_{code2_sys} set 
    {code_h_euser}     = (select context from jsharmony_meta limit 1),
    {code_h_etstmp} = datetime('now','localtime'),
    {code_h_muser}     = (select context from jsharmony_meta limit 1),
    {code_h_mtstmp} = datetime('now','localtime')
    where rowid = new.rowid\;
end;

create trigger {schema}_{code2_sys}_after_update after update on {schema}_{code2_sys}
begin
  update {schema}_{code2_sys} set 
    {code_h_muser}     = (select context from jsharmony_meta limit 1),
    {code_h_mtstmp} = datetime('now','localtime')
    where rowid = new.rowid\;
end;

/***************{version}***************/

create trigger {schema}_{version}_after_insert after insert on {schema}_{version}
begin
  update {schema}_{version} set 
    {version_euser}     = (select context from jsharmony_meta limit 1),
    {version_etstmp} = datetime('now','localtime'),
    {version_muser}     = (select context from jsharmony_meta limit 1),
    {version_mtstmp} = datetime('now','localtime')
    where rowid = new.rowid\;
end;

create trigger {schema}_{version}_after_update after update on {schema}_{version}
begin
  update {schema}_{version} set 
    {version_muser}     = (select context from jsharmony_meta limit 1),
    {version_mtstmp} = datetime('now','localtime')
    where rowid = new.rowid\;
end;
