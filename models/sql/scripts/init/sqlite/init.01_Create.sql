pragma foreign_keys = ON;

begin;


/***************audit__tbl***************/
CREATE TABLE {schema}_audit__tbl (
  audit_seq integer primary key autoincrement NOT NULL,
  audit_table_name text,
  audit_table_id integer NOT NULL,
  audit_op text,
  audit_user text,
  db_id text NOT NULL DEFAULT '0',
  audit_tstmp text NOT NULL,
  cust_id integer,
  item_id integer,
  audit_ref_name text,
  audit_ref_id integer,
  audit_subject text
);

/***************audit_detail***************/
CREATE TABLE {schema}_audit_detail
(
  audit_seq integer NOT NULL,
  audit_column_name text NOT NULL,
  audit_column_val text,
  PRIMARY KEY (audit_seq, audit_column_name),
  FOREIGN KEY (audit_seq) REFERENCES {schema}_audit__tbl(audit_seq)
);

/*********single*********/
CREATE TABLE {schema}_single (
  single_ident integer primary key NOT NULL,
  single_dummy text NOT NULL,
  single_integer integer,
  single_text text
);

/*********code_ac*********/
{schema}.create_code_sys('{schema}','ac','');

/*********code_ac1*********/
{schema}.create_code_sys('{schema}','ac1','');

/*********code_ahc*********/
{schema}.create_code_sys('{schema}','ahc','');

/*********code_country*********/
{schema}.create_code_sys('{schema}','country','');

/*********code_doc_scope*********/
{schema}.create_code_sys('{schema}','doc_scope','');


/*********code_note_scope*********/
{schema}.create_code_sys('{schema}','note_scope','');

/*********code_note_type*********/
{schema}.create_code_sys('{schema}','note_type','');

/*********code_param_type*********/
{schema}.create_code_sys('{schema}','param_type','');

/*********code_job_action*********/
{schema}.create_code_sys('{schema}','job_action','');

/*********code_job_source*********/
{schema}.create_code_sys('{schema}','job_source','');

/*********code_txt_type*********/
{schema}.create_code_sys('{schema}','txt_type','');

/*********code_version_sts*********/
{schema}.create_code_sys('{schema}','version_sts','');

/*********code2_country_state*********/
{schema}.create_code2_sys('{schema}','country_state','');

/*********code2_doc_scope_doc_ctgr*********/
{schema}.create_code2_app('{schema}','doc_scope_doc_ctgr','');

/***************cust_user***************/
create table {schema}_cust_user (
    sys_user_id integer primary key autoincrement NOT NULL,
    cust_id integer NOT NULL,
    sys_user_sts text DEFAULT 'ACTIVE' NOT NULL,
    sys_user_stsdt text,
    sys_user_fname text NOT NULL,
    sys_user_mname text,
    sys_user_lname text NOT NULL,
    sys_user_jobtitle text,
    sys_user_bphone text,
    sys_user_cphone text,
    sys_user_email text NOT NULL,
    sys_user_etstmp text,
    sys_user_euser text,
    sys_user_mtstmp text,
    sys_user_muser text,
    sys_user_pw1 text,
    sys_user_pw2 text,
    sys_user_hash blob DEFAULT X'00' NOT NULL,
    sys_user_lastlogin_ip text,
    sys_user_lastlogin_tstmp text,
    sys_user_snotes text,
    FOREIGN KEY (sys_user_sts) REFERENCES {schema}_code_ahc(code_val),
    CHECK (COALESCE(sys_user_email,'')<>'')
);

create index idx_{schema}_cust_user_cust_id on {schema}_cust_user(cust_id);

/***************cust_role***************/
CREATE TABLE {schema}_cust_role (
  cust_role_id integer primary key autoincrement NOT NULL,
  cust_role_seq integer NOT NULL,
  cust_role_sts text NOT NULL DEFAULT 'ACTIVE',
  cust_role_name text NOT NULL,
  cust_role_desc text NOT NULL,
  cust_role_snotes text,
  cust_role_code text,
  cust_role_attrib text,
  UNIQUE (cust_role_desc),
  UNIQUE (cust_role_name),
  FOREIGN KEY (cust_role_sts) REFERENCES {schema}_code_ahc(code_val)
);

/***************doc__tbl***************/
CREATE TABLE {schema}_doc__tbl (
  doc_id integer primary key autoincrement NOT NULL,
  doc_scope text NOT NULL DEFAULT 'S',
  doc_scope_id integer NOT NULL DEFAULT 0,
  cust_id integer,
  item_id integer,
  doc_sts text NOT NULL DEFAULT 'A',
  doc_ctgr text NOT NULL,
  doc_desc text,
  doc_ext text,
  doc_size integer,
  doc_etstmp text,
  doc_euser text,
  doc_mtstmp text,
  doc_muser text,
  doc_uptstmp text,
  doc_upuser text,
  doc_sync_tstmp text,
  doc_snotes text,
  doc_sync_id integer,
  FOREIGN KEY (doc_scope, doc_ctgr) REFERENCES {schema}_code2_doc_scope_doc_ctgr (code_val1, code_val2),
  FOREIGN KEY (doc_scope) REFERENCES {schema}_code_doc_scope (code_val)
);

/***************help_target***************/
CREATE TABLE {schema}_help_target (
  help_target_id integer primary key autoincrement NOT NULL,
  help_target_code text NOT NULL,
  help_target_desc text NOT NULL,
  UNIQUE (help_target_code),
  UNIQUE (help_target_desc)
);

/***************help__tbl***************/
CREATE TABLE {schema}_help__tbl (
  help_id integer primary key autoincrement NOT NULL,
  help_target_code text,
  help_target_id integer,
  help_title text NOT NULL,
  help_text text NOT NULL,
  help_etstmp text,
  help_euser text,
  help_mtstmp text,
  help_muser text,
  help_seq integer,
  help_listing_main integer NOT NULL DEFAULT 1,
  help_listing_client integer NOT NULL DEFAULT 1,
  UNIQUE (help_title)
);

/***************note__tbl***************/
CREATE TABLE {schema}_note__tbl (
  note_id integer primary key autoincrement NOT NULL,
  note_scope text NOT NULL DEFAULT 'S',
  note_scope_id integer NOT NULL DEFAULT 0,
  note_sts text NOT NULL DEFAULT 'A',
  cust_id integer,
  item_id integer,
  note_type text NOT NULL,
  note_body text NOT NULL,
  note_etstmp text,
  note_euser text,
  note_mtstmp text,
  note_muser text,
  note_sync_tstmp text,
  note_snotes text,
  note_sync_id integer,
  FOREIGN KEY (note_scope) REFERENCES {schema}_code_note_scope (code_val),
  FOREIGN KEY (note_sts) REFERENCES {schema}_code_ac1 (code_val),
  FOREIGN KEY (note_type) REFERENCES {schema}_code_note_type (code_val) 
);

/***************sys_user***************/
create table {schema}_sys_user (
    sys_user_id integer primary key autoincrement NOT NULL,
    sys_user_sts text DEFAULT 'ACTIVE' NOT NULL,
    sys_user_stsdt text,
    sys_user_fname text NOT NULL,
    sys_user_mname text,
    sys_user_lname text NOT NULL,
    sys_user_jobtitle text,
    sys_user_bphone text,
    sys_user_cphone text,
    sys_user_country text DEFAULT 'USA' NOT NULL,
    sys_user_addr text,
    sys_user_city text,
    sys_user_state text,
    sys_user_zip text,
    sys_user_email text NOT NULL,
    sys_user_startdt text,
    sys_user_enddt date,
    sys_user_unotes text,
    sys_user_etstmp text,
    sys_user_euser text,
    sys_user_mtstmp text,
    sys_user_muser text,
    sys_user_pw1 text,
    sys_user_pw2 text,
    sys_user_hash blob DEFAULT X'00' NOT NULL,
    sys_user_lastlogin_ip text,
    sys_user_lastlogin_tstmp text,
    sys_user_snotes text,
    FOREIGN KEY (sys_user_sts) REFERENCES {schema}_code_ahc(code_val),
    FOREIGN KEY (sys_user_country) REFERENCES {schema}_code_country(code_val),
    FOREIGN KEY (sys_user_country, sys_user_state) REFERENCES {schema}_code2_country_state(code_val1,code_val2),
    CHECK (COALESCE(sys_user_email,'')<>'')
);

  /***************param__tbl***************/
CREATE TABLE {schema}_param__tbl (
  param_id integer primary key autoincrement NOT NULL,
  param_process text NOT NULL,
  param_attrib text NOT NULL,
  param_desc text NOT NULL,
  param_type text NOT NULL,
  code_name text,
  param_etstmp text,
  param_euser text,
  param_mtstmp text,
  param_muser text,
  param_snotes text,
  is_param_app integer NOT NULL DEFAULT 0,
  is_param_user integer NOT NULL DEFAULT 0,
  is_param_sys integer NOT NULL DEFAULT 0,
  FOREIGN KEY (param_type) REFERENCES {schema}_code_param_type(code_val),
  UNIQUE (param_process, param_attrib)
);

/***************queue__tbl***************/
CREATE TABLE {schema}_queue__tbl (
  queue_id integer primary key autoincrement NOT NULL,
  queue_etstmp text,
  queue_euser text,
  queue_name text NOT NULL,
  queue_message text NOT NULL,
  queue_rslt text,
  queue_rslt_tstmp text,
  queue_rslt_user text,
  queue_snotes text
);

/***************job__tbl***************/
CREATE TABLE {schema}_job__tbl (
  job_id integer primary key autoincrement NOT NULL,
  job_etstmp text,
  job_user text,
  job_source text NOT NULL,
  job_action text NOT NULL,
  job_action_target text NOT NULL,
  job_params text,
  job_tag text,
  job_rslt text,
  job_rslt_tstmp text,
  job_rslt_user text,
  job_snotes text,
  FOREIGN KEY (job_action) REFERENCES {schema}_code_job_action (code_val),
  FOREIGN KEY (job_source) REFERENCES {schema}_code_job_source (code_val)
);

/***************job_doc***************/
CREATE TABLE {schema}_job_doc (
  job_doc_id integer primary key autoincrement NOT NULL,
  job_id integer NOT NULL,
  doc_scope text,
  doc_scope_id integer,
  doc_ctgr text,
  doc_desc text,
  FOREIGN KEY (job_id) REFERENCES {schema}_job__tbl (job_id)
);

/***************job_email***************/
CREATE TABLE {schema}_job_email (
  job_email_id integer primary key autoincrement NOT NULL,
  job_id integer NOT NULL,
  email_txt_attrib text,
  email_to text NOT NULL,
  email_cc text,
  email_bcc text,
  email_attach text,
  email_subject text,
  email_text text,
  email_html text,
  email_doc_id integer,
  FOREIGN KEY (job_id) REFERENCES {schema}_job__tbl (job_id)
);

/***************job_note***************/
CREATE TABLE {schema}_job_note (
  job_note_id integer primary key autoincrement NOT NULL,
  job_id integer NOT NULL,
  note_scope text,
  note_scope_id integer,
  note_type text,
  note_body text,
  FOREIGN KEY (job_id) REFERENCES {schema}_job__tbl (job_id)
);

/***************job_queue***************/
CREATE TABLE {schema}_job_queue (
  job_queue_id integer primary key autoincrement NOT NULL,
  job_id integer NOT NULL,
  queue_name text NOT NULL,
  queue_message text,
  FOREIGN KEY (job_id) REFERENCES {schema}_job__tbl (job_id)
);

/***************job_sms***************/
CREATE TABLE {schema}_job_sms (
  job_sms_id integer primary key autoincrement NOT NULL,
  job_id integer NOT NULL,
  sms_txt_attrib text,
  sms_to text NOT NULL,
  sms_body text,
  FOREIGN KEY (job_id) REFERENCES {schema}_job__tbl (job_id)
);

/***************menu__tbl***************/
CREATE TABLE {schema}_menu__tbl (
  menu_id_auto integer primary key autoincrement NOT NULL,
  menu_group text NOT NULL DEFAULT 'S',
  menu_id integert NOT NULL,
  menu_sts text NOT NULL DEFAULT 'ACTIVE',
  menu_id_parent integer,
  menu_name text NOT NULL,
  menu_seq integer,
  menu_desc text NOT NULL,
  menu_desc_ext text,
  menu_desc_ext2 text,
  menu_cmd text,
  menu_image text,
  menu_snotes text,
  menu_subcmd text,
  UNIQUE (menu_id),
  UNIQUE (menu_id_parent, menu_desc),
  UNIQUE (menu_id, menu_desc),
  UNIQUE (menu_name),
  CHECK (menu_group in ('S', 'C')),
  FOREIGN KEY (menu_id_parent) REFERENCES {schema}_menu__tbl(menu_id),
  FOREIGN KEY (menu_sts) REFERENCES {schema}_code_ahc(code_val)
);

/***************sys_role***************/
CREATE TABLE {schema}_sys_role (
  sys_role_id integer primary key autoincrement NOT NULL,
  sys_role_seq integer NOT NULL,
  sys_role_sts text NOT NULL DEFAULT 'ACTIVE',
  sys_role_name text NOT NULL,
  sys_role_desc text NOT NULL,
  sys_role_snotes text,
  sys_role_code text,
  sys_role_attrib text,
  UNIQUE (sys_role_desc),
  UNIQUE (sys_role_name),
  FOREIGN KEY (sys_role_sts) REFERENCES {schema}_code_ahc(code_val)
);

/***************sys_func***************/
CREATE TABLE {schema}_sys_func (
  sys_func_id integer primary key autoincrement NOT NULL,
  sys_func_seq integer NOT NULL,
  sys_func_sts text NOT NULL DEFAULT 'ACTIVE',
  sys_func_name text NOT NULL,
  sys_func_desc text NOT NULL,
  sys_func_snotes text,
  sys_func_code text,
  sys_func_attrib text,
  UNIQUE (sys_func_desc),
  UNIQUE (sys_func_name),
  FOREIGN KEY (sys_func_sts) REFERENCES {schema}_code_ahc(code_val)
);

/***************txt__tbl***************/
CREATE TABLE {schema}_txt__tbl (
  txt_id integer primary key autoincrement NOT NULL,
  txt_process text NOT NULL,
  txt_attrib text NOT NULL,
  txt_type text NOT NULL DEFAULT 'TEXT',
  txt_title text,
  txt_body text,
  txt_bcc text,
  txt_desc text,
  txt_etstmp text,
  txt_euser text,
  txt_mtstmp text,
  txt_muser text,
  UNIQUE (txt_process, txt_attrib),
  FOREIGN KEY (txt_type) REFERENCES {schema}_code_txt_type (code_val)
);

/***************cust_user_role***************/
CREATE TABLE {schema}_cust_user_role (
  cust_user_role_id integer primary key autoincrement NOT NULL,
  sys_user_id integer NOT NULL,
  cust_role_name text NOT NULL,
  cust_user_role_snotes text,
  UNIQUE (sys_user_id, cust_role_name),
  FOREIGN KEY (sys_user_id) REFERENCES {schema}_cust_user(sys_user_id),
  FOREIGN KEY (cust_role_name) REFERENCES {schema}_cust_role(cust_role_name)
);

/***************cust_menu_role***************/
CREATE TABLE {schema}_cust_menu_role (
  cust_menu_role_id integer primary key autoincrement NOT NULL,
  menu_id integer NOT NULL,
  cust_role_name text NOT NULL,
  cust_menu_role_snotes text,
  UNIQUE (cust_role_name, menu_id),
  FOREIGN KEY (menu_id) REFERENCES {schema}_menu__tbl(menu_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (cust_role_name) REFERENCES {schema}_cust_role(cust_role_name) ON DELETE CASCADE
);

/***************code_app***************/
CREATE TABLE {schema}_code_app (
    code_app_h_id  integer primary key autoincrement NOT NULL,
    code_name text NOT NULL,
    code_desc text,
    code_code_desc text,
    code_h_etstmp text,
    code_h_euser text,
    code_h_mtstmp text,
    code_h_muser text,
    code_snotes text,
    code_attrib_desc text,
    code_schema text,
    code_type text default 'app',
    UNIQUE (code_schema, code_name)
);

/***************code2_app***************/
CREATE TABLE {schema}_code2_app (
    code2_app_h_id  integer primary key autoincrement NOT NULL,
    code_name text NOT NULL,
    code_desc text,
    code_code_desc text,
    code_h_etstmp text,
    code_h_euser text,
    code_h_mtstmp text,
    code_h_muser text,
    code_snotes text,
    code_attrib_desc text,
    code_schema text,
    code_type text default 'app',
    UNIQUE (code_schema, code_name)
);

/***************param_app***************/
CREATE TABLE {schema}_param_app (
  param_app_id integer primary key autoincrement NOT NULL,
  param_app_process text NULL,
  param_app_attrib text NOT NULL,
  param_app_val text,
  param_app_etstmp txt__tbl,
  param_app_euser text,
  param_app_mtstmp text,
  param_app_muser text,
  UNIQUE (param_app_process, param_app_attrib),
  FOREIGN KEY (param_app_process, param_app_attrib) REFERENCES {schema}_param__tbl(param_process, param_attrib)
);

/***************param_user***************/
CREATE TABLE {schema}_param_user (
  param_user_id integer primary key autoincrement NOT NULL,
  sys_user_id integer NOT NULL,
  param_user_process text NULL,
  param_user_attrib text NOT NULL,
  param_user_val text,
  param_user_etstmp txt__tbl,
  param_user_euser text,
  param_user_mtstmp text,
  param_user_muser text,
  UNIQUE (param_user_process, param_user_attrib),
  FOREIGN KEY (param_user_process, param_user_attrib) REFERENCES {schema}_param__tbl(param_process, param_attrib)
              ON UPDATE NO ACTION ON DELETE CASCADE,
  FOREIGN KEY (sys_user_id) REFERENCES {schema}_sys_user(sys_user_id)
              ON UPDATE NO ACTION ON DELETE CASCADE
);

/***************sys_user_func***************/
CREATE TABLE {schema}_sys_user_func (
  sys_user_func_id integer primary key autoincrement NOT NULL,
  sys_user_id integer NOT NULL,
  sys_func_name text NOT NULL,
  sys_user_func_snotes text,
  UNIQUE (sys_user_id, sys_func_name),
  FOREIGN KEY (sys_user_id) REFERENCES {schema}_sys_user(sys_user_id),
  FOREIGN KEY (sys_func_name) REFERENCES {schema}_sys_func(sys_func_name)
);

/***************sys_user_role***************/
CREATE TABLE {schema}_sys_user_role (
  sys_user_role_id integer primary key autoincrement NOT NULL,
  sys_user_id integer NOT NULL,
  sys_role_name text NOT NULL,
  sys_user_role_snotes text,
  UNIQUE (sys_user_id, sys_role_name),
  FOREIGN KEY (sys_user_id) REFERENCES {schema}_sys_user(sys_user_id),
  FOREIGN KEY (sys_role_name) REFERENCES {schema}_sys_role(sys_role_name)
);

/***************sys_menu_role***************/
CREATE TABLE {schema}_sys_menu_role (
  sys_menu_role_id integer primary key autoincrement NOT NULL,
  menu_id integer NOT NULL,
  sys_role_name text NOT NULL,
  sys_menu_role_snotes text,
  UNIQUE (sys_role_name, menu_id),
  FOREIGN KEY (menu_id) REFERENCES {schema}_menu__tbl(menu_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (sys_role_name) REFERENCES {schema}_sys_role(sys_role_name) ON DELETE CASCADE
);

/***************code_sys***************/
CREATE TABLE if not exists {schema}_code_sys (
    code_sys_h_id  integer primary key autoincrement NOT NULL,
    code_name text NOT NULL,
    code_desc text,
    code_code_desc text,
    code_h_etstmp text,
    code_h_euser text,
    code_h_mtstmp text,
    code_h_muser text,
    code_snotes text,
    code_attrib_desc text,
    code_schema text,
    code_type text default 'sys',
    UNIQUE (code_schema, code_name)
);

/***************code2_sys***************/
CREATE TABLE if not exists {schema}_code2_sys (
    code2_sys_h_id  integer primary key autoincrement NOT NULL,
    code_name text NOT NULL,
    code_desc text,
    code_code_desc text,
    code_h_etstmp text,
    code_h_euser text,
    code_h_mtstmp text,
    code_h_muser text,
    code_snotes text,
    code_attrib_desc text,
    code_schema text,
    code_type text default 'sys',
    UNIQUE (code_schema, code_name)
);

/***************version__tbl***************/
CREATE TABLE {schema}_version__tbl (
    version_id integer primary key autoincrement NOT NULL,
    version_component text NOT NULL,
    version_no_major integer DEFAULT 0 NOT NULL,
    version_no_minor integer DEFAULT 0 NOT NULL,
    version_no_build integer DEFAULT 0 NOT NULL,
    version_no_rev integer DEFAULT 0 NOT NULL,
    version_sts text DEFAULT 'OK' NOT NULL,
    version_note text,
    version_etstmp text,
    version_euser text,
    version_mtstmp text,
    version_muser text,
    version_snotes text,
    UNIQUE (version_no_major, version_no_minor, version_no_build, version_no_rev),
    FOREIGN KEY (version_sts) REFERENCES {schema}_code_version_sts(code_val)
);

/***************param_sys***************/
CREATE TABLE {schema}_param_sys (
  param_sys_id integer primary key autoincrement NOT NULL,
  param_sys_process text NULL,
  param_sys_attrib text NOT NULL,
  param_sys_val text,
  param_sys_etstmp txt__tbl,
  param_sys_euser text,
  param_sys_mtstmp text,
  param_sys_muser text,
  UNIQUE (param_sys_process, param_sys_attrib),
  FOREIGN KEY (param_sys_process, param_sys_attrib) REFERENCES {schema}_param__tbl(param_process, param_attrib)
);

/***************number__tbl***************/
CREATE TABLE {schema}_number__tbl (
  number_val integer NOT NULL,
  PRIMARY KEY (number_val)
);

end;