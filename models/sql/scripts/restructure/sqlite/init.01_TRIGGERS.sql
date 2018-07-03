/***************TABLE TRIGGERS***************/

/***************CPER***************/

create trigger jsharmony_cper_insert after insert on jsharmony_cper
begin
  %%%AUDIT_I("jsharmony_cper","new.cper_id","cper_id","null","null","(select coalesce(pe_lname,'')||', '||coalesce(pe_fname,'') from jsharmony_cpe where jsharmony_cpe.pe_id = new.pe_id)","jsharmony.getcid('CPE',new.pe_id)")%%%
  update jsharmony_meta set aud_seq = null\;
end;

create trigger jsharmony_cper_update before update on jsharmony_cper
begin
  select case when ifnull(old.cper_id,'')<>ifnull(NEW.cper_id,'') then raise(FAIL,'Application Error - ID cannot be updated.') end\;
  select case when ifnull(old.pe_id,'')<>ifnull(NEW.pe_id,'') then raise(FAIL,'Application Error - Customer User ID cannot be updated.') end\;

  %%%AUDIT_U_MULT("jsharmony_cper","old.cper_id",["pe_id","cr_name"],"null","null","(select coalesce(pe_lname,'')||', '||coalesce(pe_fname,'') from jsharmony_cpe where jsharmony_cpe.pe_id = new.pe_id)","jsharmony.getcid('CPE',new.pe_id)")%%%
  update jsharmony_meta set aud_seq = null\;
end;

create trigger jsharmony_cper_delete before delete on jsharmony_cper
begin
  %%%AUDIT_D_MULT("jsharmony_cper","old.cper_id",["pe_id","cr_name"],"null","null","null","jsharmony.getcid('CPE',old.pe_id)")%%%
  update jsharmony_meta set aud_seq = null\;
end;


/***************D***************/

create trigger jsharmony_d_before_insert before insert on jsharmony_d
begin
  select case when new.d_scope='S' and new.d_scope_id<>0 then raise(FAIL,'Application Error - SCOPE_ID inconsistent with SCOPE') end\;
  select case when new.d_scope<>'S' and new.d_scope_id is null then raise(FAIL,'Application Error - SCOPE_ID inconsistent with SCOPE') end\;
  select case when (jsharmony.mycuser_c_id() is not null) and 
    ((jsharmony.getcid(new.d_scope,new.d_scope_id)<>jsharmony.mycuser_c_id()) or
     (new.d_scope_id not in ('C','E')))
    then raise(FAIL,'Application Error - Client User has no rights to perform this operation') end\;
  select case when not exists (select * from jsharmony_gcod2_d_scope_d_ctgr where codeval1=new.d_scope and codeval2=new.d_ctgr) then raise(FAIL,'Document type not allowed for selected scope') end\;
end;

create trigger jsharmony_d_after_insert after insert on jsharmony_d
begin
  update jsharmony_d set 
    c_id     = jsharmony.getcid(new.d_scope,new.d_scope_id),
    e_id     = jsharmony.geteid(new.d_scope,new.d_scope_id),
    d_eu     = (select context from jsharmony_meta limit 1),
    d_etstmp = datetime('now','localtime'),
    d_mu     = (select context from jsharmony_meta limit 1),
    d_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;

  %%%AUDIT_I("jsharmony_d","new.d_id","d_id","null","null","null","jsharmony.getcid(new.d_scope,new.d_scope_id)","jsharmony.geteid(new.d_scope,new.d_scope_id)")%%%
  update jsharmony_meta set aud_seq = null\;
end;

create trigger jsharmony_d_before_update before update on jsharmony_d
begin
  select case when ifnull(old.d_id,'')<>ifnull(NEW.d_id,'') then raise(FAIL,'Application Error - ID cannot be updated.') end\;
  select case when ifnull(old.d_scope,'')<>ifnull(NEW.d_scope,'') then raise(FAIL,'Application Error - Scope cannot be updated.') end\;
  select case when ifnull(old.d_scope_id,'')<>ifnull(NEW.d_scope_id,'') then raise(FAIL,'Application Error - Scope ID cannot be updated.') end\;
  select case when ifnull(old.d_ctgr,'')<>ifnull(NEW.d_ctgr,'') then raise(FAIL,'Application Error - Document Category cannot be updated.') end\;
  select case when not exists (select * from jsharmony_gcod2_d_scope_d_ctgr where codeval1=new.d_scope and codeval2=new.d_ctgr) then raise(FAIL,'Document type not allowed for selected scope') end\;
end;

create trigger jsharmony_d_after_update after update on jsharmony_d
begin
  %%%AUDIT_U_MULT("jsharmony_d","old.d_id",["d_id","c_id","d_scope","d_scope_id","e_id","d_sts","d_ctgr","d_desc","d_utstmp","d_uu","d_synctstmp"],"null","null","null","jsharmony.getcid(new.d_scope,new.d_scope_id)","jsharmony.geteid(new.d_scope,new.d_scope_id)")%%%

  update jsharmony_d set 
    c_id     = jsharmony.getcid(new.d_scope,new.d_scope_id),
    e_id     = jsharmony.geteid(new.d_scope,new.d_scope_id),
    d_mu     = (select context from jsharmony_meta limit 1),
    d_mtstmp = datetime('now','localtime')
    where d_id = new.d_id and exists(select * from jsharmony_meta where aud_seq is not null)\; 

  update jsharmony_meta set aud_seq = null\;
end;

create trigger jsharmony_d_delete before delete on jsharmony_d
begin
  %%%AUDIT_D_MULT("jsharmony_d","old.d_id",["d_id","c_id","d_scope","d_scope_id","e_id","d_sts","d_ctgr","d_desc","d_utstmp","d_uu","d_synctstmp"],"null","null","null")%%%
  update jsharmony_meta set aud_seq = null\;
end;

/***************N***************/

create trigger jsharmony_n_before_insert before insert on jsharmony_n
begin
  select case when new.n_scope='S' and new.n_scope_id<>0 then raise(FAIL,'Application Error - SCOPE_ID inconsistent with SCOPE') end\;
  select case when new.n_scope<>'S' and new.n_scope_id is null then raise(FAIL,'Application Error - SCOPE_ID inconsistent with SCOPE') end\;
  select case when (jsharmony.mycuser_c_id() is not null) and 
    ((jsharmony.getcid(new.n_scope,new.n_scope_id)<>jsharmony.mycuser_c_id()) or
     (new.n_scope_id not in ('C','E')))
    then raise(FAIL,'Application Error - Client User has no rights to perform this operation') end\;
end;

create trigger jsharmony_n_after_insert after insert on jsharmony_n
begin
  update jsharmony_n set 
    c_id     = jsharmony.getcid(new.n_scope,new.n_scope_id),
    e_id     = jsharmony.geteid(new.n_scope,new.n_scope_id),
    n_eu     = (select context from jsharmony_meta limit 1),
    n_etstmp = datetime('now','localtime'),
    n_mu     = (select context from jsharmony_meta limit 1),
    n_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;

  %%%AUDIT_I("jsharmony_n","new.n_id","n_id","null","null","null","jsharmony.getcid(new.n_scope,new.n_scope_id)","jsharmony.geteid(new.n_scope,new.n_scope_id)")%%%
  update jsharmony_meta set aud_seq = null\;
end;

create trigger jsharmony_n_before_update before update on jsharmony_n
begin
  select case when ifnull(old.n_id,'')<>ifnull(NEW.n_id,'') then raise(FAIL,'Application Error - ID cannot be updated.') end\;
  select case when ifnull(old.n_scope,'')<>ifnull(NEW.n_scope,'') then raise(FAIL,'Application Error - Scope cannot be updated.') end\;
  select case when ifnull(old.n_scope_id,'')<>ifnull(NEW.n_scope_id,'') then raise(FAIL,'Application Error - Scope ID cannot be updated.') end\;
  select case when ifnull(old.n_type,'')<>ifnull(NEW.n_type,'') then raise(FAIL,'Application Error - Note Type cannot be updated.') end\;
end;

create trigger jsharmony_n_after_update after update on jsharmony_n
begin
  %%%AUDIT_U_MULT("jsharmony_n","old.n_id",["n_id","c_id","n_scope","n_scope_id","e_id","n_sts","n_type","n_note"],"null","null","null","jsharmony.getcid(new.n_scope,new.n_scope_id)","jsharmony.geteid(new.n_scope,new.n_scope_id)")%%%

  update jsharmony_n set 
    c_id     = jsharmony.getcid(new.n_scope,new.n_scope_id),
    e_id     = jsharmony.geteid(new.n_scope,new.n_scope_id),
    n_mu     = (select context from jsharmony_meta limit 1),
    n_mtstmp = datetime('now','localtime')
    where n_id = new.n_id and exists(select * from jsharmony_meta where aud_seq is not null)\; 

  update jsharmony_meta set aud_seq = null\;
end;

create trigger jsharmony_n_delete before delete on jsharmony_n
begin
  %%%AUDIT_D_MULT("jsharmony_n","old.n_id",["n_id","c_id","n_scope","n_scope_id","e_id","n_sts","n_type","n_note"],"null","null","null")%%%
  update jsharmony_meta set aud_seq = null\;
end;


/***************PE***************/

create trigger jsharmony_pe_before_insert before insert on jsharmony_pe
begin
  select case when ifnull(NEW.pe_pw1,'')<>ifnull(NEW.pe_pw2,'') then raise(FAIL,'Application Error - New Password and Repeat Password are different') end\;
  select case when length(ifnull(NEW.pe_pw1,''))< 6 then raise(FAIL,'Application Error - Password length - at least 6 characters required') end\;
end;

create trigger jsharmony_pe_after_insert after insert on jsharmony_pe
begin
  update jsharmony_pe set 
    pe_startdt = ifnull(NEW.pe_startdt,date('now','localtime')),
    pe_stsdt  = datetime('now','localtime'),
    pe_eu     = (select context from jsharmony_meta limit 1),
    pe_etstmp = datetime('now','localtime'),
    pe_mu     = (select context from jsharmony_meta limit 1),
    pe_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;

  update jsharmony_meta set jsexec = '{ "function": "sha1", "table": "jsharmony_pe", "rowid": '||NEW.rowid||', "source":"pe_id||pe_pw1||(select pp_val from jsharmony_v_pp where PP_PROCESS=''USERS'' and PP_ATTRIB=''HASH_SEED_S'')", "dest":"pe_hash" }, { "function": "exec", "sql": "update jsharmony_pe set pe_pw1=null,pe_pw2=null where rowid='||NEW.rowid||'" }'\;

  %%%AUDIT_I("PE","new.PE_ID","PE_ID","null","null","null")%%%
  update jsharmony_meta set aud_seq = null\;
end;

create trigger jsharmony_pe_before_update before update on jsharmony_pe
begin
  select case when NEW.pe_stsdt is null then raise(FAIL,'pe_stsdt cannot be null') end\;
  select case when NEW.pe_id <> OLD.pe_id then raise(FAIL,'Application Error - ID cannot be updated.') end\;
  select case when ifnull(NEW.pe_pw1,'')<>ifnull(NEW.pe_pw2,'') then raise(FAIL,'Application Error - New Password and Repeat Password are different') end\;
  select case when (NEW.pe_pw1 is not null) and (length(ifnull(NEW.pe_pw1,''))< 6) then raise(FAIL,'Application Error - Password length - at least 6 characters required') end\;
end;

create trigger jsharmony_pe_after_update after update on jsharmony_pe
begin
  update jsharmony_meta set jsexec = '{ "function": "sha1", "table": "jsharmony_pe", "rowid": '||NEW.rowid||', "source":"pe_id||pe_pw1||(select pp_val from jsharmony_v_pp where PP_PROCESS=''USERS'' and PP_ATTRIB=''HASH_SEED_S'')", "dest":"pe_hash" }, { "function": "exec", "sql": "update jsharmony_pe set pe_pw1=null,pe_pw2=null where rowid='||NEW.rowid||'" }'
    where NEW.pe_pw1 is not null\;

  %%%AUDIT_U_MULT("PE","old.PE_ID",["PE_ID","PE_STS","PE_FNAME","PE_MNAME","PE_LNAME","PE_JTITLE","PE_BPHONE","PE_CPHONE","PE_EMAIL","PE_LL_TSTMP"],"null","null","null")%%%

  %%%AUDIT_U_CUSTOM("PE","old.PE_ID","coalesce(NEW.pe_pw1,'') <> '' and coalesce(NEW.pe_pw1,'') <> coalesce(OLD.pe_pw1,'')","null","null","null")%%%
  insert into jsharmony_aud_d(aud_seq,column_name,column_val)
    select (select aud_seq from jsharmony_meta),'PE_PW1','*'
    where (coalesce(NEW.pe_pw1,'') <> '' and coalesce(NEW.pe_pw1,'') <> coalesce(OLD.pe_pw1,''))\;

  update jsharmony_pe set
    pe_stsdt  = case when (%%%NONEQUAL("NEW.pe_sts","OLD.pe_sts")%%%) then datetime('now','localtime') else NEW.pe_stsdt end,
    pe_mu     = (select context from jsharmony_meta limit 1),
    pe_mtstmp = datetime('now','localtime')
    where rowid = new.rowid and exists(select * from jsharmony_meta where aud_seq is not null)\; 

  update jsharmony_meta set aud_seq = null\;
end;

create trigger jsharmony_pe_delete before delete on jsharmony_pe
begin
  %%%AUDIT_D_MULT("PE","old.PE_ID",["PE_ID","PE_STS","PE_FNAME","PE_MNAME","PE_LNAME","PE_JTITLE","PE_BPHONE","PE_CPHONE","PE_EMAIL","PE_LL_TSTMP"],"null","null","null")%%%
  update jsharmony_meta set aud_seq = null\;
end;

/***************CPE***************/

create trigger jsharmony_cpe_before_insert before insert on jsharmony_cpe
begin
  select case when ifnull(NEW.pe_pw1,'')<>ifnull(NEW.pe_pw2,'') then raise(FAIL,'Application Error - New Password and Repeat Password are different') end\;
  select case when length(ifnull(NEW.pe_pw1,''))< 6 then raise(FAIL,'Application Error - Password length - at least 6 characters required') end\;
end;

create trigger jsharmony_cpe_after_insert after insert on jsharmony_cpe
begin
  update jsharmony_cpe set 
    pe_stsdt  = datetime('now','localtime'),
    pe_eu     = (select context from jsharmony_meta limit 1),
    pe_etstmp = datetime('now','localtime'),
    pe_mu     = (select context from jsharmony_meta limit 1),
    pe_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;

  update jsharmony_meta set jsexec = '{ "function": "sha1", "table": "jsharmony_cpe", "rowid": '||NEW.rowid||', "source":"pe_id||pe_pw1||(select pp_val from jsharmony_v_pp where PP_PROCESS=''USERS'' and PP_ATTRIB=''HASH_SEED_C'')", "dest":"pe_hash" }, { "function": "exec", "sql": "update jsharmony_cpe set pe_pw1=null,pe_pw2=null where rowid='||NEW.rowid||'" }'\;

  %%%AUDIT_I("CPE","new.pe_id","pe_id","null","null","(select coalesce(new.pe_lname,'')||', '||coalesce(new.pe_fname,''))","new.c_id")%%%
  update jsharmony_meta set aud_seq = null\;
end;

create trigger jsharmony_cpe_before_update before update on jsharmony_cpe
begin
  select case when NEW.pe_stsdt is null then raise(FAIL,'pe_stsdt cannot be null') end\;
  select case when NEW.pe_id <> OLD.pe_id then raise(FAIL,'Application Error - ID cannot be updated.') end\;
  select case when NEW.c_id <> OLD.c_id then raise(FAIL,'Application Error - Customer ID cannot be updated.') end\;
  select case when ifnull(NEW.pe_pw1,'')<>ifnull(NEW.pe_pw2,'') then raise(FAIL,'Application Error - New Password and Repeat Password are different') end\;
  select case when (NEW.pe_pw1 is not null) and (length(ifnull(NEW.pe_pw1,''))< 6) then raise(FAIL,'Application Error - Password length - at least 6 characters required') end\;
end;

create trigger jsharmony_cpe_after_update after update on jsharmony_cpe
begin
  %%%AUDIT_U_MULT("CPE","new.pe_id",["pe_id","c_id","pe_sts","pe_fname","pe_mname","pe_lname","pe_jtitle","pe_bphone","pe_cphone","pe_email","pe_ll_tstmp"],"null","null","(select coalesce(new.pe_lname,'')||', '||coalesce(new.pe_fname,''))","new.c_id")%%%

  %%%AUDIT_U_CUSTOM("CPE","new.pe_id","coalesce(NEW.pe_pw1,'') <> '' and coalesce(NEW.pe_pw1,'') <> coalesce(OLD.pe_pw1,'')","null","null","(select coalesce(new.pe_lname,'')||', '||coalesce(new.pe_fname,''))","new.c_id")%%%
  insert into jsharmony_aud_d(aud_seq,column_name,column_val)
    select (select aud_seq from jsharmony_meta),'pe_pw1','*'
    where (coalesce(NEW.pe_pw1,'') <> '' and coalesce(NEW.pe_pw1,'') <> coalesce(OLD.pe_pw1,''))\;


  update jsharmony_meta set jsexec = '{ "function": "sha1", "table": "jsharmony_cpe", "rowid": '||NEW.rowid||', "source":"pe_id||pe_pw1||(select pp_val from jsharmony_v_pp where PP_PROCESS=''USERS'' and PP_ATTRIB=''HASH_SEED_C'')", "dest":"pe_hash" }, { "function": "exec", "sql": "update jsharmony_cpe set pe_pw1=null,pe_pw2=null where rowid='||NEW.rowid||'" }'
    where NEW.pe_pw1 is not null\;

  update jsharmony_cpe set
    pe_stsdt  = case when (%%%NONEQUAL("NEW.pe_sts","OLD.pe_sts")%%%) then datetime('now','localtime') else NEW.pe_stsdt end,
    pe_mu     = (select context from jsharmony_meta limit 1),
    pe_mtstmp = datetime('now','localtime')
    where rowid = new.rowid and exists(select * from jsharmony_meta where aud_seq is not null)\; 

  update jsharmony_meta set aud_seq = null\;
end;

create trigger jsharmony_cpe_delete before delete on jsharmony_cpe
begin
  %%%AUDIT_D_MULT("CPE","old.pe_id",["pe_id","c_id","pe_sts","pe_fname","pe_mname","pe_lname","pe_jtitle","pe_bphone","pe_cphone","pe_email","pe_ll_tstmp"],"null","null","null","null")%%%
  update jsharmony_meta set aud_seq = null\;
end;

/***************GPP***************/

create trigger jsharmony_gpp_before_insert before insert on jsharmony_gpp
begin
  select case when not exists(select * from jsharmony_ppd where ppd_process=new.gpp_process and ppd_attrib = new.gpp_attrib and ppd_gpp=1) then raise(FAIL,'Application Error - Process parameter is not assigned for GPP in PPD') end\;
  select case when new.gpp_val = '' then raise(FAIL,'Application Error - Value is required') end\;
  select case when (upper((select ppd_type from jsharmony_ppd where ppd_process=new.gpp_process and ppd_attrib = new.gpp_attrib))='N') and (cast(new.gpp_val as float)<>new.gpp_val) then raise(FAIL,'Application Error - Value is not numeric') end\;
end;

create trigger jsharmony_gpp_after_insert after insert on jsharmony_gpp
begin
  update jsharmony_gpp set 
    gpp_eu     = (select context from jsharmony_meta limit 1),
    gpp_etstmp = datetime('now','localtime'),
    gpp_mu     = (select context from jsharmony_meta limit 1),
    gpp_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;

  %%%AUDIT_I("jsharmony_gpp","new.gpp_id","gpp_id")%%%
  update jsharmony_meta set aud_seq = null\;
end;

create trigger jsharmony_gpp_before_update before update on jsharmony_gpp
begin
  select case when ifnull(old.gpp_id,'')<>ifnull(NEW.gpp_id,'') then raise(FAIL,'Application Error - ID cannot be updated.') end\;
  select case when ifnull(old.gpp_process,'')<>ifnull(NEW.gpp_process,'') then raise(FAIL,'Application Error - Process cannot be updated.') end\;
  select case when ifnull(old.gpp_attrib,'')<>ifnull(NEW.gpp_attrib,'') then raise(FAIL,'Application Error - Attribute cannot be updated.') end\;

  select case when not exists(select * from jsharmony_ppd where ppd_process=new.gpp_process and ppd_attrib = new.gpp_attrib and ppd_gpp=1) then raise(FAIL,'Application Error - Process parameter is not assigned for GPP in PPD') end\;
  select case when new.gpp_val = '' then raise(FAIL,'Application Error - Value is required') end\;
  select case when (upper((select ppd_type from jsharmony_ppd where ppd_process=new.gpp_process and ppd_attrib = new.gpp_attrib))='N') and (cast(new.gpp_val as float)<>new.gpp_val) then raise(FAIL,'Application Error - Value is not numeric') end\;
end;

create trigger jsharmony_gpp_after_update after update on jsharmony_gpp
begin
  %%%AUDIT_U_MULT("jsharmony_gpp","old.gpp_id",["gpp_id","gpp_process","gpp_attrib","gpp_val"])%%%

  update jsharmony_gpp set 
    gpp_mu     = (select context from jsharmony_meta limit 1),
    gpp_mtstmp = datetime('now','localtime')
    where gpp_id = new.gpp_id and exists(select * from jsharmony_meta where aud_seq is not null)\; 

  update jsharmony_meta set aud_seq = null\;
end;

create trigger jsharmony_gpp_delete before delete on jsharmony_gpp
begin
  %%%AUDIT_D_MULT("jsharmony_gpp","old.gpp_id",["gpp_id","gpp_process","gpp_attrib","gpp_val"])%%%
  update jsharmony_meta set aud_seq = null\;
end;

/***************XPP***************/

create trigger jsharmony_xpp_before_insert before insert on jsharmony_xpp
begin
  select case when not exists(select * from jsharmony_ppd where ppd_process=new.xpp_process and ppd_attrib = new.xpp_attrib and ppd_xpp=1) then raise(FAIL,'Application Error - Process parameter is not assigned for XPP in PPD') end\;
  select case when new.xpp_val = '' then raise(FAIL,'Application Error - Value is required') end\;
  select case when (upper((select ppd_type from jsharmony_ppd where ppd_process=new.xpp_process and ppd_attrib = new.xpp_attrib))='N') and (cast(new.xpp_val as float)<>new.xpp_val) then raise(FAIL,'Application Error - Value is not numeric') end\;
end;

create trigger jsharmony_xpp_after_insert after insert on jsharmony_xpp
begin
  update jsharmony_xpp set 
    xpp_eu     = (select context from jsharmony_meta limit 1),
    xpp_etstmp = datetime('now','localtime'),
    xpp_mu     = (select context from jsharmony_meta limit 1),
    xpp_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;

  %%%AUDIT_I("jsharmony_xpp","new.xpp_id","xpp_id")%%%
  update jsharmony_meta set aud_seq = null\;
end;

create trigger jsharmony_xpp_before_update before update on jsharmony_xpp
begin
  select case when ifnull(old.xpp_id,'')<>ifnull(NEW.xpp_id,'') then raise(FAIL,'Application Error - ID cannot be updated.') end\;
  select case when ifnull(old.xpp_process,'')<>ifnull(NEW.xpp_process,'') then raise(FAIL,'Application Error - Process cannot be updated.') end\;
  select case when ifnull(old.xpp_attrib,'')<>ifnull(NEW.xpp_attrib,'') then raise(FAIL,'Application Error - Attribute cannot be updated.') end\;

  select case when not exists(select * from jsharmony_ppd where ppd_process=new.xpp_process and ppd_attrib = new.xpp_attrib and ppd_xpp=1) then raise(FAIL,'Application Error - Process parameter is not assigned for XPP in PPD') end\;
  select case when new.xpp_val = '' then raise(FAIL,'Application Error - Value is required') end\;
  select case when (upper((select ppd_type from jsharmony_ppd where ppd_process=new.xpp_process and ppd_attrib = new.xpp_attrib))='N') and (cast(new.xpp_val as float)<>new.xpp_val) then raise(FAIL,'Application Error - Value is not numeric') end\;
end;

create trigger jsharmony_xpp_after_update after update on jsharmony_xpp
begin
  %%%AUDIT_U_MULT("jsharmony_xpp","old.xpp_id",["xpp_id","xpp_process","xpp_attrib","xpp_val"])%%%

  update jsharmony_xpp set 
    xpp_mu     = (select context from jsharmony_meta limit 1),
    xpp_mtstmp = datetime('now','localtime')
    where xpp_id = new.xpp_id and exists(select * from jsharmony_meta where aud_seq is not null)\; 

  update jsharmony_meta set aud_seq = null\;
end;

create trigger jsharmony_xpp_delete before delete on jsharmony_xpp
begin
  %%%AUDIT_D_MULT("jsharmony_xpp","old.xpp_id",["xpp_id","xpp_process","xpp_attrib","xpp_val"])%%%
  update jsharmony_meta set aud_seq = null\;
end;

/***************PPP***************/

create trigger jsharmony_ppp_before_insert before insert on jsharmony_ppp
begin
  select case when not exists(select * from jsharmony_ppd where ppd_process=new.ppp_process and ppd_attrib = new.ppp_attrib and ppd_ppp=1) then raise(FAIL,'Application Error - Process parameter is not assigned for PPP in PPD') end\;
  select case when new.ppp_val = '' then raise(FAIL,'Application Error - Value is required') end\;
  select case when (upper((select ppd_type from jsharmony_ppd where ppd_process=new.ppp_process and ppd_attrib = new.ppp_attrib))='N') and (cast(new.ppp_val as float)<>new.ppp_val) then raise(FAIL,'Application Error - Value is not numeric') end\;
end;

create trigger jsharmony_ppp_after_insert after insert on jsharmony_ppp
begin
  update jsharmony_ppp set 
    ppp_eu     = (select context from jsharmony_meta limit 1),
    ppp_etstmp = datetime('now','localtime'),
    ppp_mu     = (select context from jsharmony_meta limit 1),
    ppp_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;

  %%%AUDIT_I("jsharmony_ppp","new.ppp_id","ppp_id","null","null","(select coalesce(pe_lname,'')||', '||coalesce(pe_fname,'') from jsharmony_pe where pe_id=new.pe_id)")%%%
  update jsharmony_meta set aud_seq = null\;
end;

create trigger jsharmony_ppp_before_update before update on jsharmony_ppp
begin
  select case when ifnull(old.ppp_id,'')<>ifnull(NEW.ppp_id,'') then raise(FAIL,'Application Error - ID cannot be updated.') end\;
  select case when ifnull(old.pe_id,'')<>ifnull(NEW.pe_id,'') then raise(FAIL,'Application Error - Personnel cannot be updated.') end\;
  select case when ifnull(old.ppp_process,'')<>ifnull(NEW.ppp_process,'') then raise(FAIL,'Application Error - Process cannot be updated.') end\;
  select case when ifnull(old.ppp_attrib,'')<>ifnull(NEW.ppp_attrib,'') then raise(FAIL,'Application Error - Attribute cannot be updated.') end\;

  select case when not exists(select * from jsharmony_ppd where ppd_process=new.ppp_process and ppd_attrib = new.ppp_attrib and ppd_ppp=1) then raise(FAIL,'Application Error - Process parameter is not assigned for PPP in PPD') end\;
  select case when new.ppp_val = '' then raise(FAIL,'Application Error - Value is required') end\;
  select case when (upper((select ppd_type from jsharmony_ppd where ppd_process=new.ppp_process and ppd_attrib = new.ppp_attrib))='N') and (cast(new.ppp_val as float)<>new.ppp_val) then raise(FAIL,'Application Error - Value is not numeric') end\;
end;

create trigger jsharmony_ppp_after_update after update on jsharmony_ppp
begin
  %%%AUDIT_U_MULT("jsharmony_ppp","old.ppp_id",["ppp_id","pe_id","ppp_process","ppp_attrib","ppp_val"],"null","null","(select coalesce(pe_lname,'')||', '||coalesce(pe_fname,'') from jsharmony_pe where pe_id=new.pe_id)")%%%

  update jsharmony_ppp set 
    ppp_mu     = (select context from jsharmony_meta limit 1),
    ppp_mtstmp = datetime('now','localtime')
    where ppp_id = new.ppp_id and exists(select * from jsharmony_meta where aud_seq is not null)\; 

  update jsharmony_meta set aud_seq = null\;
end;

create trigger jsharmony_ppp_delete before delete on jsharmony_ppp
begin
  %%%AUDIT_D_MULT("jsharmony_ppp","old.ppp_id",["ppp_id","pe_id","ppp_process","ppp_attrib","ppp_val"])%%%
  update jsharmony_meta set aud_seq = null\;
end;

/***************PPD***************/

create trigger jsharmony_ppd_after_insert after insert on jsharmony_ppd
begin
  update jsharmony_ppd set 
    ppd_eu     = (select context from jsharmony_meta limit 1),
    ppd_etstmp = datetime('now','localtime'),
    ppd_mu     = (select context from jsharmony_meta limit 1),
    ppd_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;

  %%%AUDIT_I("jsharmony_ppd","new.ppd_id","ppd_id")%%%
  update jsharmony_meta set aud_seq = null\;
end;

create trigger jsharmony_ppd_before_update before update on jsharmony_ppd
begin
  select case when ifnull(old.ppd_id,'')<>ifnull(NEW.ppd_id,'') then raise(FAIL,'Application Error - ID cannot be updated.') end\;
end;

create trigger jsharmony_ppd_after_update after update on jsharmony_ppd
begin
  %%%AUDIT_U_MULT("jsharmony_ppd","old.ppd_id",["ppd_id","ppd_process","ppd_attrib","ppd_desc","ppd_type","codename","ppd_gpp","ppd_ppp","ppd_xpp"])%%%
  
  update jsharmony_ppd set 
    ppd_mu     = (select context from jsharmony_meta limit 1),
    ppd_mtstmp = datetime('now','localtime')
    where ppd_id = new.ppd_id and exists(select * from jsharmony_meta where aud_seq is not null)\; 

  update jsharmony_meta set aud_seq = null\;
end;

create trigger jsharmony_ppd_delete before delete on jsharmony_ppd
begin
  %%%AUDIT_D_MULT("jsharmony_ppd","old.ppd_id",["ppd_id","ppd_process","ppd_attrib","ppd_desc","ppd_type","codename","ppd_gpp","ppd_ppp","ppd_xpp"])%%%
  update jsharmony_meta set aud_seq = null\;
end;

/***************H***************/

create trigger jsharmony_h_after_insert after insert on jsharmony_h
begin
  update jsharmony_h set 
    h_eu     = (select context from jsharmony_meta limit 1),
    h_etstmp = datetime('now','localtime'),
    h_mu     = (select context from jsharmony_meta limit 1),
    h_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;

  %%%AUDIT_I("jsharmony_h","new.h_id","h_id","null","null","(select hp_desc from jsharmony_hp where hp_code=new.hp_code)")%%%
  update jsharmony_meta set aud_seq = null\;
end;

create trigger jsharmony_h_before_update before update on jsharmony_h
begin
  select case when ifnull(old.h_id,'')<>ifnull(NEW.h_id,'') then raise(FAIL,'Application Error - ID cannot be updated.') end\;
  select case when ifnull(old.hp_code,'')<>ifnull(NEW.hp_code,'') then raise(FAIL,'Application Error - HP Code cannot be updated.') end\;
end;

create trigger jsharmony_h_after_update after update on jsharmony_h
begin
  %%%AUDIT_U_MULT("jsharmony_h","old.h_id",["h_id","hp_code","h_title","h_text","h_seq","h_index_a","h_index_p"],"null","null","(select hp_desc from jsharmony_hp where hp_code=new.hp_code)")%%%

  update jsharmony_h set 
    h_mu     = (select context from jsharmony_meta limit 1),
    h_mtstmp = datetime('now','localtime')
    where h_id = new.h_id and exists(select * from jsharmony_meta where aud_seq is not null)\; 

  update jsharmony_meta set aud_seq = null\;
end;

create trigger jsharmony_h_delete before delete on jsharmony_h
begin
  %%%AUDIT_D_MULT("jsharmony_h","old.h_id",["h_id","hp_code","h_title","h_text","h_seq","h_index_a","h_index_p"],"null","null","(select hp_desc from jsharmony_hp where hp_code=old.hp_code)")%%%
  update jsharmony_meta set aud_seq = null\;
end;

/***************SPEF***************/

create trigger jsharmony_spef_after_insert after insert on jsharmony_spef
begin
  %%%AUDIT_I("jsharmony_spef","new.spef_id","spef_id","null","null","(select coalesce(pe_lname,'')||', '||coalesce(pe_fname,'') from jsharmony_pe where pe_id=new.pe_id)")%%%
  update jsharmony_meta set aud_seq = null\;
end;

create trigger jsharmony_spef_before_update before update on jsharmony_spef
begin
  select case when ifnull(old.spef_id,'')<>ifnull(NEW.spef_id,'') then raise(FAIL,'Application Error - ID cannot be updated.') end\;
  select case when ifnull(old.pe_id,'')<>ifnull(NEW.pe_id,'') then raise(FAIL,'Application Error - User ID cannot be updated.') end\;
end;

create trigger jsharmony_spef_after_update after update on jsharmony_spef
begin
  %%%AUDIT_U_MULT("jsharmony_spef","old.spef_id",["spef_id","pe_id","sf_name"],"null","null","(select coalesce(pe_lname,'')||', '||coalesce(pe_fname,'') from jsharmony_pe where pe_id=new.pe_id)")%%%
  update jsharmony_meta set aud_seq = null\;
end;

create trigger jsharmony_spef_delete before delete on jsharmony_spef
begin
  %%%AUDIT_D_MULT("jsharmony_spef","old.spef_id",["spef_id","pe_id","sf_name"])%%%
  update jsharmony_meta set aud_seq = null\;
end;

/***************SPER***************/

create trigger jsharmony_sper_before_insert before insert on jsharmony_sper
begin
  select case when (upper(new.sr_name)='DEV') and (not exists (select sr_name from jsharmony.V_MY_ROLES where SR_NAME='DEV')) then raise(FAIL,'Application Error - Only a Developer can maintain the Developer Role.') end\;
end;

create trigger jsharmony_sper_after_insert after insert on jsharmony_sper
begin
  %%%AUDIT_I("jsharmony_sper","new.sper_id","sper_id","null","null","(select coalesce(pe_lname,'')||', '||coalesce(pe_fname,'') from jsharmony_pe where pe_id=new.pe_id)")%%%
  update jsharmony_meta set aud_seq = null\;
end;

create trigger jsharmony_sper_before_update before update on jsharmony_sper
begin
  select case when ifnull(old.sper_id,'')<>ifnull(NEW.sper_id,'') then raise(FAIL,'Application Error - ID cannot be updated.') end\;
  select case when ifnull(old.pe_id,'')<>ifnull(NEW.pe_id,'') then raise(FAIL,'Application Error - User ID cannot be updated.') end\;
  select case when (upper(new.sr_name)='DEV') and (not exists (select sr_name from jsharmony.V_MY_ROLES where SR_NAME='DEV')) then raise(FAIL,'Application Error - Only a Developer can maintain the Developer Role.') end\;
end;

create trigger jsharmony_sper_after_update after update on jsharmony_sper
begin
  %%%AUDIT_U_MULT("jsharmony_sper","old.sper_id",["sper_id","pe_id","sr_name"],"null","null","(select coalesce(pe_lname,'')||', '||coalesce(pe_fname,'') from jsharmony_pe where pe_id=new.pe_id)")%%%
  update jsharmony_meta set aud_seq = null\;
end;

create trigger jsharmony_sper_delete before delete on jsharmony_sper
begin
  select case when (upper(old.sr_name)='DEV') and (not exists (select sr_name from jsharmony.V_MY_ROLES where SR_NAME='DEV')) then raise(FAIL,'Application Error - Only a Developer can maintain the Developer Role.') end\;
  %%%AUDIT_D_MULT("jsharmony_sper","old.sper_id",["sper_id","pe_id","sr_name"])%%%
  update jsharmony_meta set aud_seq = null\;
end;

/***************TXT***************/

create trigger jsharmony_txt_after_insert after insert on jsharmony_txt
begin
  update jsharmony_txt set 
    txt_eu     = (select context from jsharmony_meta limit 1),
    txt_etstmp = datetime('now','localtime'),
    txt_mu     = (select context from jsharmony_meta limit 1),
    txt_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;

  %%%AUDIT_I("jsharmony_txt","new.txt_id","txt_id")%%%
  update jsharmony_meta set aud_seq = null\;
end;

create trigger jsharmony_txt_before_update before update on jsharmony_txt
begin
  select case when ifnull(old.txt_id,'')<>ifnull(NEW.txt_id,'') then raise(FAIL,'Application Error - ID cannot be updated.') end\;
end;

create trigger jsharmony_txt_after_update after update on jsharmony_txt
begin
  %%%AUDIT_U_MULT("jsharmony_txt","old.txt_id",["txt_id","txt_process","txt_attrib","txt_type","txt_tval","txt_val","txt_bcc","txt_desc"])%%%

  update jsharmony_txt set 
    txt_mu     = (select context from jsharmony_meta limit 1),
    txt_mtstmp = datetime('now','localtime')
    where txt_id = new.txt_id and exists(select * from jsharmony_meta where aud_seq is not null)\; 

  update jsharmony_meta set aud_seq = null\;
end;

create trigger jsharmony_txt_delete before delete on jsharmony_txt
begin
  %%%AUDIT_D_MULT("jsharmony_txt","old.txt_id",["txt_id","txt_process","txt_attrib","txt_type","txt_tval","txt_val","txt_bcc","txt_desc"])%%%
  update jsharmony_meta set aud_seq = null\;
end;

























/***************RQ***************/

create trigger jsharmony_rq_after_insert after insert on jsharmony_rq
begin
  update jsharmony_rq set 
    rq_eu     = (select context from jsharmony_meta limit 1),
    rq_etstmp = datetime('now','localtime')
    where rowid = new.rowid\;
end;

/***************RQST***************/

create trigger jsharmony_rqst_after_insert after insert on jsharmony_rqst
begin
  update jsharmony_rqst set 
    rqst_eu     = (select context from jsharmony_meta limit 1),
    rqst_etstmp = datetime('now','localtime')
    where rowid = new.rowid\;
end;

/***************GCOD_H***************/

create trigger jsharmony_gcod_h_after_insert after insert on jsharmony_gcod_h
begin
  update jsharmony_gcod_h set 
    cod_h_eu     = (select context from jsharmony_meta limit 1),
    cod_h_etstmp = datetime('now','localtime'),
    cod_h_mu     = (select context from jsharmony_meta limit 1),
    cod_h_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;
end;

create trigger jsharmony_gcod_h_after_update after update on jsharmony_gcod_h
begin
  update jsharmony_gcod_h set 
    cod_h_mu     = (select context from jsharmony_meta limit 1),
    cod_h_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;
end;

/***************GCOD2_H***************/

create trigger jsharmony_gcod2_h_after_insert after insert on jsharmony_gcod2_h
begin
  update jsharmony_gcod2_h set 
    cod_h_eu     = (select context from jsharmony_meta limit 1),
    cod_h_etstmp = datetime('now','localtime'),
    cod_h_mu     = (select context from jsharmony_meta limit 1),
    cod_h_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;
end;

create trigger jsharmony_gcod2_h_after_update after update on jsharmony_gcod2_h
begin
  update jsharmony_gcod2_h set 
    cod_h_mu     = (select context from jsharmony_meta limit 1),
    cod_h_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;
end;

/***************UCOD_H***************/

create trigger jsharmony_ucod_h_after_insert after insert on jsharmony_ucod_h
begin
  update jsharmony_ucod_h set 
    cod_h_eu     = (select context from jsharmony_meta limit 1),
    cod_h_etstmp = datetime('now','localtime'),
    cod_h_mu     = (select context from jsharmony_meta limit 1),
    cod_h_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;
end;

create trigger jsharmony_ucod_h_after_update after update on jsharmony_ucod_h
begin
  update jsharmony_ucod_h set 
    cod_h_mu     = (select context from jsharmony_meta limit 1),
    cod_h_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;
end;

/***************UCOD2_H***************/

create trigger jsharmony_ucod2_h_after_insert after insert on jsharmony_ucod2_h
begin
  update jsharmony_ucod2_h set 
    cod_h_eu     = (select context from jsharmony_meta limit 1),
    cod_h_etstmp = datetime('now','localtime'),
    cod_h_mu     = (select context from jsharmony_meta limit 1),
    cod_h_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;
end;

create trigger jsharmony_ucod2_h_after_update after update on jsharmony_ucod2_h
begin
  update jsharmony_ucod2_h set 
    cod_h_mu     = (select context from jsharmony_meta limit 1),
    cod_h_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;
end;

/***************V***************/

create trigger jsharmony_v_after_insert after insert on jsharmony_v
begin
  update jsharmony_v set 
    v_eu     = (select context from jsharmony_meta limit 1),
    v_etstmp = datetime('now','localtime'),
    v_mu     = (select context from jsharmony_meta limit 1),
    v_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;
end;

create trigger jsharmony_v_after_update after update on jsharmony_v
begin
  update jsharmony_v set 
    v_mu     = (select context from jsharmony_meta limit 1),
    v_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;
end;
