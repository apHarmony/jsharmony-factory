pragma foreign_keys = ON;

begin;


/***************AUD_H***************/
CREATE TABLE jsharmony_aud_h (
  aud_seq integer primary key autoincrement NOT NULL,
  table_name text,
  table_id integer NOT NULL,
  aud_op text,
  aud_u text,
  db_k text NOT NULL DEFAULT '0',
  aud_tstmp text NOT NULL,
  c_id integer,
  e_id integer,
  ref_name text,
  ref_id integer,
  subj text
);

/***************AUD_D***************/
CREATE TABLE jsharmony_aud_d
(
  aud_seq integer NOT NULL,
  column_name text NOT NULL,
  column_val text,
  PRIMARY KEY (aud_seq, column_name),
  FOREIGN KEY (aud_seq) REFERENCES jsharmony_aud_h(aud_seq)
);

/*********DUAL*********/
CREATE TABLE jsharmony_dual (
  dual_ident integer primary key NOT NULL,
  dummy text NOT NULL,
  dual_integer integer,
  dual_text text
);

/*********UCOD_AC*********/
jsharmony.create_ucod('jsharmony','ac','');

/*********UCOD_AC1*********/
jsharmony.create_ucod('jsharmony','ac1','');

/*********UCOD_AHC*********/
jsharmony.create_ucod('jsharmony','ahc','');

/*********UCOD_COUNTRY*********/
jsharmony.create_ucod('jsharmony','country','');

/*********UCOD_D_SCOPE*********/
jsharmony.create_ucod('jsharmony','d_scope','');


/*********UCOD_N_SCOPE*********/
jsharmony.create_ucod('jsharmony','n_scope','');

/*********UCOD_N_TYPE*********/
jsharmony.create_ucod('jsharmony','n_type','');

/*********UCOD_PPD_TYPE*********/
jsharmony.create_ucod('jsharmony','ppd_type','');

/*********UCOD_RQST_ATYPE*********/
jsharmony.create_ucod('jsharmony','rqst_atype','');

/*********UCOD_RQST_SOURCE*********/
jsharmony.create_ucod('jsharmony','rqst_source','');

/*********UCOD_TXT_TYPE*********/
jsharmony.create_ucod('jsharmony','txt_type','');

/*********UCOD_V_STS*********/
jsharmony.create_ucod('jsharmony','v_sts','');

/*********UCOD2_COUNTRY_STATE*********/
jsharmony.create_ucod2('jsharmony','country_state','');

/*********GCOD2_D_SCOPE_D_CTGR*********/
jsharmony.create_gcod2('jsharmony','d_scope_d_ctgr','');

/***************CPE***************/
create table jsharmony_cpe (
    pe_id integer primary key autoincrement NOT NULL,
    c_id integer NOT NULL,
    pe_sts text DEFAULT 'ACTIVE' NOT NULL,
    pe_stsdt text,
    pe_fname text NOT NULL,
    pe_mname text,
    pe_lname text NOT NULL,
    pe_jtitle text,
    pe_bphone text,
    pe_cphone text,
    pe_email text NOT NULL,
    pe_etstmp text,
    pe_eu text,
    pe_mtstmp text,
    pe_mu text,
    pe_pw1 text,
    pe_pw2 text,
    pe_hash blob DEFAULT X'00' NOT NULL,
    pe_ll_ip text,
    pe_ll_tstmp text,
    pe_snotes text,
    FOREIGN KEY (pe_sts) REFERENCES jsharmony_ucod_ahc(codeval),
    CHECK (COALESCE(pe_email,'')<>'')
);

create index idx_jsharmony_cpe_c_id on jsharmony_cpe(c_id);

/***************CR***************/
CREATE TABLE jsharmony_cr (
  cr_id integer primary key autoincrement NOT NULL,
  cr_seq integer NOT NULL,
  cr_sts text NOT NULL DEFAULT 'ACTIVE',
  cr_name text NOT NULL,
  cr_desc text NOT NULL,
  cr_snotes text,
  cr_code text,
  cr_attrib text,
  UNIQUE (cr_desc),
  UNIQUE (cr_name),
  FOREIGN KEY (cr_sts) REFERENCES jsharmony_ucod_ahc(codeval)
);

/***************D***************/
CREATE TABLE jsharmony_d (
  d_id integer primary key autoincrement NOT NULL,
  d_scope text NOT NULL DEFAULT 'S',
  d_scope_id integer NOT NULL DEFAULT 0,
  c_id integer,
  e_id integer,
  d_sts text NOT NULL DEFAULT 'A',
  d_ctgr text NOT NULL,
  d_desc text,
  d_ext text,
  d_size integer,
  d_etstmp text,
  d_eu text,
  d_mtstmp text,
  d_mu text,
  d_utstmp text,
  d_uu text,
  d_synctstmp text,
  d_snotes text,
  d_id_main integer,
  FOREIGN KEY (d_scope, d_ctgr) REFERENCES jsharmony_gcod2_d_scope_d_ctgr (codeval1, codeval2),
  FOREIGN KEY (d_scope) REFERENCES jsharmony_ucod_d_scope (codeval)
);

/***************HP***************/
CREATE TABLE jsharmony_hp (
  hp_id integer primary key autoincrement NOT NULL,
  hp_code text NOT NULL,
  hp_desc text NOT NULL,
  UNIQUE (hp_code),
  UNIQUE (hp_desc)
);

/***************H***************/
CREATE TABLE jsharmony_h (
  h_id integer primary key autoincrement NOT NULL,
  hp_code text,
  h_title text NOT NULL,
  h_text text NOT NULL,
  h_etstmp text,
  h_eu text,
  h_mtstmp text,
  h_mu text,
  h_seq integer,
  h_index_a integer NOT NULL DEFAULT 1,
  h_index_p integer NOT NULL DEFAULT 1,
  UNIQUE (h_title),
  FOREIGN KEY (hp_code) REFERENCES jsharmony_hp (hp_code)
);

/***************N***************/
CREATE TABLE jsharmony_n (
  n_id integer primary key autoincrement NOT NULL,
  n_scope text NOT NULL DEFAULT 'S',
  n_scope_id integer NOT NULL DEFAULT 0,
  n_sts text NOT NULL DEFAULT 'A',
  c_id integer,
  e_id integer,
  n_type text,
  n_note text NOT NULL,
  n_etstmp text,
  n_eu text,
  n_mtstmp text,
  n_mu text,
  n_synctstmp text,
  n_snotes text,
  n_id_main integer,
  FOREIGN KEY (n_scope) REFERENCES jsharmony_ucod_n_scope (codeval),
  FOREIGN KEY (n_sts) REFERENCES jsharmony_ucod_ac1 (codeval),
  FOREIGN KEY (n_type) REFERENCES jsharmony_ucod_n_type (codeval) 
);

/***************PE***************/
create table jsharmony_pe (
    pe_id integer primary key autoincrement NOT NULL,
    pe_sts text DEFAULT 'ACTIVE' NOT NULL,
    pe_stsdt text,
    pe_fname text NOT NULL,
    pe_mname text,
    pe_lname text NOT NULL,
    pe_jtitle text,
    pe_bphone text,
    pe_cphone text,
    pe_country text DEFAULT 'USA' NOT NULL,
    pe_addr text,
    pe_city text,
    pe_state text,
    pe_zip text,
    pe_email text NOT NULL,
    pe_startdt text,
    pe_enddt date,
    pe_unotes text,
    pe_etstmp text,
    pe_eu text,
    pe_mtstmp text,
    pe_mu text,
    pe_pw1 text,
    pe_pw2 text,
    pe_hash blob DEFAULT X'00' NOT NULL,
    pe_ll_ip text,
    pe_ll_tstmp text,
    pe_snotes text,
    FOREIGN KEY (pe_sts) REFERENCES jsharmony_ucod_ahc(codeval),
    FOREIGN KEY (pe_country) REFERENCES jsharmony_ucod_country(codeval),
    FOREIGN KEY (pe_country, pe_state) REFERENCES jsharmony_ucod2_country_state(codeval1,codeval2),
    CHECK (COALESCE(pe_email,'')<>'')
);

  /***************PPD***************/
CREATE TABLE jsharmony_ppd (
  ppd_id integer primary key autoincrement NOT NULL,
  ppd_process text NOT NULL,
  ppd_attrib text NOT NULL,
  ppd_desc text NOT NULL,
  ppd_type text NOT NULL,
  codename text,
  ppd_etstmp text,
  ppd_eu text,
  ppd_mtstmp text,
  ppd_mu text,
  ppd_snotes text,
  ppd_gpp integer NOT NULL DEFAULT 0,
  ppd_ppp integer NOT NULL DEFAULT 0,
  ppd_xpp integer NOT NULL DEFAULT 0,
  FOREIGN KEY (ppd_type) REFERENCES jsharmony_ucod_ppd_type(codeval),
  UNIQUE (ppd_process, ppd_attrib)
);

/***************RQ***************/
CREATE TABLE jsharmony_rq (
  rq_id integer primary key autoincrement NOT NULL,
  rq_etstmp text,
  rq_eu text,
  rq_name text NOT NULL,
  rq_message text NOT NULL,
  rq_rslt text,
  rq_rslt_tstmp text,
  rq_rslt_u text,
  rq_snotes text
);

/***************RQST***************/
CREATE TABLE jsharmony_rqst (
  rqst_id integer primary key autoincrement NOT NULL,
  rqst_etstmp text,
  rqst_eu text,
  rqst_source text NOT NULL,
  rqst_atype text NOT NULL,
  rqst_aname text NOT NULL,
  rqst_parms text,
  rqst_ident text,
  rqst_rslt text,
  rqst_rslt_tstmp text,
  rqst_rslt_u text,
  rqst_snotes text,
  FOREIGN KEY (rqst_atype) REFERENCES jsharmony_ucod_rqst_atype (codeval),
  FOREIGN KEY (rqst_source) REFERENCES jsharmony_ucod_rqst_source (codeval)
);

/***************RQST_D***************/
CREATE TABLE jsharmony_rqst_d (
  rqst_d_id integer primary key autoincrement NOT NULL,
  rqst_id integer NOT NULL,
  d_scope text,
  d_scope_id integer,
  d_ctgr text,
  d_desc text,
  FOREIGN KEY (rqst_id) REFERENCES jsharmony_rqst (rqst_id)
);

/***************RQST_EMAIL***************/
CREATE TABLE jsharmony_rqst_email (
  rqst_email_id integer primary key autoincrement NOT NULL,
  rqst_id integer NOT NULL,
  email_txt_attrib text,
  email_to text NOT NULL,
  email_cc text,
  email_bcc text,
  email_attach integer,
  email_subject text,
  email_text text,
  email_html text,
  email_d_id integer,
  FOREIGN KEY (rqst_id) REFERENCES jsharmony_rqst (rqst_id)
);

/***************RQST_N***************/
CREATE TABLE jsharmony_rqst_n (
  rqst_n_id integer primary key autoincrement NOT NULL,
  rqst_id integer NOT NULL,
  n_scope text,
  n_scope_id integer,
  n_type text,
  n_note text,
  FOREIGN KEY (rqst_id) REFERENCES jsharmony_rqst (rqst_id)
);

/***************RQST_RQ***************/
CREATE TABLE jsharmony_rqst_rq (
  rqst_rq_id integer primary key autoincrement NOT NULL,
  rqst_id integer NOT NULL,
  rq_name text NOT NULL,
  rq_message text,
  FOREIGN KEY (rqst_id) REFERENCES jsharmony_rqst (rqst_id)
);

/***************RQST_SMS***************/
CREATE TABLE jsharmony_rqst_sms (
  rqst_sms_id integer primary key autoincrement NOT NULL,
  rqst_id integer NOT NULL,
  sms_txt_attrib text,
  sms_to text NOT NULL,
  sms_body text,
  FOREIGN KEY (rqst_id) REFERENCES jsharmony_rqst (rqst_id)
);

/***************SM***************/
CREATE TABLE jsharmony_sm (
  sm_id_auto integer primary key autoincrement NOT NULL,
  sm_utype text NOT NULL DEFAULT 'S',
  sm_id integert NOT NULL,
  sm_sts text NOT NULL DEFAULT 'ACTIVE',
  sm_id_parent integer,
  sm_name text NOT NULL,
  sm_seq integer,
  sm_desc text NOT NULL,
  sm_descl text,
  sm_descvl text,
  sm_cmd text,
  sm_image text,
  sm_snotes text,
  sm_subcmd text,
  UNIQUE (sm_id),
  UNIQUE (sm_id_parent, sm_desc),
  UNIQUE (sm_id, sm_desc),
  UNIQUE (sm_name),
  CHECK (sm_utype in ('S', 'C')),
  FOREIGN KEY (sm_id_parent) REFERENCES jsharmony_sm(sm_id),
  FOREIGN KEY (sm_sts) REFERENCES jsharmony_ucod_ahc(codeval)
);

/***************SR***************/
CREATE TABLE jsharmony_sr (
  sr_id integer primary key autoincrement NOT NULL,
  sr_seq integer NOT NULL,
  sr_sts text NOT NULL DEFAULT 'ACTIVE',
  sr_name text NOT NULL,
  sr_desc text NOT NULL,
  sr_snotes text,
  sr_code text,
  sr_attrib text,
  UNIQUE (sr_desc),
  UNIQUE (sr_name),
  FOREIGN KEY (sr_sts) REFERENCES jsharmony_ucod_ahc(codeval)
);

/***************SF***************/
CREATE TABLE jsharmony_sf (
  sf_id integer primary key autoincrement NOT NULL,
  sf_seq integer NOT NULL,
  sf_sts text NOT NULL DEFAULT 'ACTIVE',
  sf_name text NOT NULL,
  sf_desc text NOT NULL,
  sf_snotes text,
  sf_code text,
  sf_attrib text,
  UNIQUE (sf_desc),
  UNIQUE (sf_name),
  FOREIGN KEY (sf_sts) REFERENCES jsharmony_ucod_ahc(codeval)
);

/***************TXT***************/
CREATE TABLE jsharmony_txt (
  txt_id integer primary key autoincrement NOT NULL,
  txt_process text NOT NULL,
  txt_attrib text NOT NULL,
  txt_type text NOT NULL DEFAULT 'TEXT',
  txt_tval text,
  txt_val text,
  txt_bcc text,
  txt_desc text,
  txt_etstmp text,
  txt_eu text,
  txt_mtstmp text,
  txt_mu text,
  UNIQUE (txt_process, txt_attrib),
  FOREIGN KEY (txt_type) REFERENCES jsharmony_ucod_txt_type (codeval)
);

/***************CPER***************/
CREATE TABLE jsharmony_cper (
  cper_id integer primary key autoincrement NOT NULL,
  pe_id integer NOT NULL,
  cr_name text NOT NULL,
  cper_snotes text,
  UNIQUE (pe_id, cr_name),
  FOREIGN KEY (pe_id) REFERENCES jsharmony_cpe(pe_id),
  FOREIGN KEY (cr_name) REFERENCES jsharmony_cr(cr_name)
);

/***************CRM***************/
CREATE TABLE jsharmony_crm (
  crm_id integer primary key autoincrement NOT NULL,
  sm_id integer NOT NULL,
  cr_name text NOT NULL,
  crm_snotes text,
  UNIQUE (cr_name, sm_id),
  FOREIGN KEY (sm_id) REFERENCES jsharmony_sm(sm_id),
  FOREIGN KEY (cr_name) REFERENCES jsharmony_cr(cr_name)
);

/***************GCOD_H***************/
CREATE TABLE jsharmony_gcod_h (
    gcod_h_id  integer primary key autoincrement NOT NULL,
    codename text NOT NULL,
    codemean text,
    codecodemean text,
    cod_h_etstmp text,
    cod_h_eu text,
    cod_h_mtstmp text,
    cod_h_mu text,
    cod_snotes text,
    codeattribmean text,
    codeschema text,
    UNIQUE (codeschema, codename)
);

/***************GCOD2_H***************/
CREATE TABLE jsharmony_gcod2_h (
    gcod2_h_id  integer primary key autoincrement NOT NULL,
    codename text NOT NULL,
    codemean text,
    codecodemean text,
    cod_h_etstmp text,
    cod_h_eu text,
    cod_h_mtstmp text,
    cod_h_mu text,
    cod_snotes text,
    codeattribmean text,
    codeschema text,
    UNIQUE (codeschema, codename)
);

/***************GPP***************/
CREATE TABLE jsharmony_gpp (
  gpp_id integer primary key autoincrement NOT NULL,
  gpp_process text NULL,
  gpp_attrib text NOT NULL,
  gpp_val text,
  gpp_etstmp txt,
  gpp_eu text,
  gpp_mtstmp text,
  gpp_mu text,
  UNIQUE (gpp_process, gpp_attrib),
  FOREIGN KEY (gpp_process, gpp_attrib) REFERENCES jsharmony_ppd(ppd_process, ppd_attrib)
);

/***************PPP***************/
CREATE TABLE jsharmony_ppp (
  ppp_id integer primary key autoincrement NOT NULL,
  pe_id integer NOT NULL,
  ppp_process text NULL,
  ppp_attrib text NOT NULL,
  ppp_val text,
  ppp_etstmp txt,
  ppp_eu text,
  ppp_mtstmp text,
  ppp_mu text,
  UNIQUE (ppp_process, ppp_attrib),
  FOREIGN KEY (ppp_process, ppp_attrib) REFERENCES jsharmony_ppd(ppd_process, ppd_attrib)
              ON UPDATE NO ACTION ON DELETE CASCADE,
  FOREIGN KEY (pe_id) REFERENCES jsharmony_pe(pe_id)
              ON UPDATE NO ACTION ON DELETE CASCADE
);

/***************SPEF***************/
CREATE TABLE jsharmony_spef (
  spef_id integer primary key autoincrement NOT NULL,
  pe_id integer NOT NULL,
  sf_name text NOT NULL,
  spef_snotes text,
  UNIQUE (pe_id, sf_name),
  FOREIGN KEY (pe_id) REFERENCES jsharmony_pe(pe_id),
  FOREIGN KEY (sf_name) REFERENCES jsharmony_sf(sf_name)
);

/***************SPER***************/
CREATE TABLE jsharmony_sper (
  sper_id integer primary key autoincrement NOT NULL,
  pe_id integer NOT NULL,
  sr_name text NOT NULL,
  sper_snotes text,
  UNIQUE (pe_id, sr_name),
  FOREIGN KEY (pe_id) REFERENCES jsharmony_pe(pe_id),
  FOREIGN KEY (sr_name) REFERENCES jsharmony_sr(sr_name)
);

/***************SRM***************/
CREATE TABLE jsharmony_srm (
  srm_id integer primary key autoincrement NOT NULL,
  sm_id integer NOT NULL,
  sr_name text NOT NULL,
  srm_snotes text,
  UNIQUE (sr_name, sm_id),
  FOREIGN KEY (sm_id) REFERENCES jsharmony_sm(sm_id),
  FOREIGN KEY (sr_name) REFERENCES jsharmony_sr(sr_name)
);

/***************UCOD_H***************/
CREATE TABLE jsharmony_ucod_h (
    ucod_h_id  integer primary key autoincrement NOT NULL,
    codename text NOT NULL,
    codemean text,
    codecodemean text,
    cod_h_etstmp text,
    cod_h_eu text,
    cod_h_mtstmp text,
    cod_h_mu text,
    cod_snotes text,
    codeattribmean text,
    codeschema text,
    UNIQUE (codeschema, codename)
);

/***************UCOD2_H***************/
CREATE TABLE jsharmony_ucod2_h (
    ucod2_h_id  integer primary key autoincrement NOT NULL,
    codename text NOT NULL,
    codemean text,
    codecodemean text,
    cod_h_etstmp text,
    cod_h_eu text,
    cod_h_mtstmp text,
    cod_h_mu text,
    cod_snotes text,
    codeattribmean text,
    codeschema text,
    UNIQUE (codeschema, codename)
);

/***************V***************/
CREATE TABLE jsharmony_v (
    v_id integer primary key autoincrement NOT NULL,
    v_comp text NOT NULL,
    v_no_major integer DEFAULT 0 NOT NULL,
    v_no_minor integer DEFAULT 0 NOT NULL,
    v_no_build integer DEFAULT 0 NOT NULL,
    v_no_rev integer DEFAULT 0 NOT NULL,
    v_sts text DEFAULT 'OK' NOT NULL,
    v_note text,
    v_etstmp text,
    v_eu text,
    v_mtstmp text,
    v_mu text,
    v_snotes text,
    UNIQUE (v_no_major, v_no_minor, v_no_build, v_no_rev),
    FOREIGN KEY (v_sts) REFERENCES jsharmony_ucod_v_sts(codeval)
);

/***************XPP***************/
CREATE TABLE jsharmony_xpp (
  xpp_id integer primary key autoincrement NOT NULL,
  xpp_process text NULL,
  xpp_attrib text NOT NULL,
  xpp_val text,
  xpp_etstmp txt,
  xpp_eu text,
  xpp_mtstmp text,
  xpp_mu text,
  UNIQUE (xpp_process, xpp_attrib),
  FOREIGN KEY (xpp_process, xpp_attrib) REFERENCES jsharmony_ppd(ppd_process, ppd_attrib)
);

/***************NUMBERS***************/
CREATE TABLE jsharmony_numbers (
  n integr NOT NULL,
  PRIMARY KEY (n)
);

end;