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
INSERT INTO jsharmony_dual (dummy, dual_ident, dual_integer, dual_text) VALUES ('X', 1, NULL, NULL);

/*********UCOD_AC*********/
jsharmony.create_ucod('jsharmony','ac','');
insert into jsharmony_ucod_ac (codseq, codeval, codetxt, codecode, codeattrib) VALUES (1, 'ACTIVE', 'Active', NULL, NULL);
insert into jsharmony_ucod_ac (codseq, codeval, codetxt, codecode, codeattrib) VALUES (3, 'CLOSED', 'Closed', NULL, NULL);

/*********UCOD_AC1*********/
jsharmony.create_ucod('jsharmony','ac1','');
insert into jsharmony_ucod_ac1 (codseq, codeval, codetxt, codecode, codeattrib) VALUES (1, 'A', 'Active', NULL, NULL);
insert into jsharmony_ucod_ac1 (codseq, codeval, codetxt, codecode, codeattrib) VALUES (2, 'C', 'Closed', NULL, NULL);

/*********UCOD_AHC*********/
jsharmony.create_ucod('jsharmony','ahc','');
insert into jsharmony_ucod_ahc (codseq, codeval, codetxt, codecode, codeattrib) VALUES (1, 'ACTIVE', 'Active', NULL, NULL);
insert into jsharmony_ucod_ahc (codseq, codeval, codetxt, codecode, codeattrib) VALUES (3, 'CLOSED', 'Closed', NULL, NULL);
insert into jsharmony_ucod_ahc (codseq, codeval, codetxt, codecode, codeattrib) VALUES (2, 'HOLD', 'Hold', NULL, NULL);

/*********UCOD_COUNTRY*********/
jsharmony.create_ucod('jsharmony','country','');
insert into jsharmony_ucod_country(codseq,codeval,codetxt,codecode,codeattrib) values (NULL,'USA','United States',NULL,NULL);
insert into jsharmony_ucod_country(codseq,codeval,codetxt,codecode,codeattrib) values (NULL,'CANADA','Canada',NULL,NULL);
insert into jsharmony_ucod_country(codseq,codeval,codetxt,codecode,codeattrib) values (NULL,'MEXICO','Mexico',NULL,NULL);

/*********UCOD_D_SCOPE*********/
jsharmony.create_ucod('jsharmony','d_scope','');
insert into jsharmony_ucod_d_scope (codseq, codeval, codetxt, codecode, codeattrib) VALUES (2, 'C', 'Customer', NULL, NULL);
insert into jsharmony_ucod_d_scope (codseq, codeval, codetxt, codecode, codeattrib) VALUES (1, 'S', 'System', NULL, NULL);
insert into jsharmony_ucod_d_scope (codseq, codeval, codetxt, codecode, codeattrib) VALUES (3, 'O', 'Order', NULL, NULL);
insert into jsharmony_ucod_d_scope (codseq, codeval, codetxt, codecode, codeattrib) VALUES (4, 'VEN', 'Vendor', NULL, NULL);
insert into jsharmony_ucod_d_scope (codseq, codeval, codetxt, codecode, codeattrib) VALUES (5, 'PE', 'User', NULL, NULL);


/*********UCOD_N_SCOPE*********/
jsharmony.create_ucod('jsharmony','n_scope','');
insert into jsharmony_ucod_n_scope (codseq, codeval, codetxt, codecode, codeattrib) VALUES (2, 'C', 'Customer', NULL, NULL);
insert into jsharmony_ucod_n_scope (codseq, codeval, codetxt, codecode, codeattrib) VALUES (1, 'S', 'System', NULL, NULL);
insert into jsharmony_ucod_n_scope (codseq, codeval, codetxt, codecode, codeattrib) VALUES (3, 'CT', 'Cust Contact', NULL, NULL);
insert into jsharmony_ucod_n_scope (codseq, codeval, codetxt, codecode, codeattrib) VALUES (4, 'VEN', 'Vendor', NULL, NULL);
insert into jsharmony_ucod_n_scope (codseq, codeval, codetxt, codecode, codeattrib) VALUES (5, 'PE', 'User', NULL, NULL);

/*********UCOD_N_TYPE*********/
jsharmony.create_ucod('jsharmony','n_type','');
insert into jsharmony_ucod_n_type (codseq, codeval, codetxt, codecode, codeattrib) VALUES (2, 'C', 'Client', NULL, NULL);
insert into jsharmony_ucod_n_type (codseq, codeval, codetxt, codecode, codeattrib) VALUES (3, 'S', 'System', NULL, NULL);
insert into jsharmony_ucod_n_type (codseq, codeval, codetxt, codecode, codeattrib) VALUES (1, 'U', 'User', NULL, NULL);

/*********UCOD_PPD_TYPE*********/
jsharmony.create_ucod('jsharmony','ppd_type','');
insert into jsharmony_ucod_ppd_type (codseq, codeval, codetxt, codecode, codeattrib) VALUES (NULL, 'C', 'Character', NULL, NULL);
insert into jsharmony_ucod_ppd_type (codseq, codeval, codetxt, codecode, codeattrib) VALUES (NULL, 'N', 'Number', NULL, NULL);

/*********UCOD_RQST_ATYPE*********/
jsharmony.create_ucod('jsharmony','rqst_atype','');
insert into jsharmony_ucod_rqst_atype (codseq, codeval, codetxt, codecode, codeattrib) VALUES (NULL, 'MESSAGE', 'Message', NULL, NULL);
insert into jsharmony_ucod_rqst_atype (codseq, codeval, codetxt, codecode, codeattrib) VALUES (NULL, 'REPORT', 'Report Program', NULL, NULL);

/*********UCOD_RQST_SOURCE*********/
jsharmony.create_ucod('jsharmony','rqst_source','');
insert into jsharmony_ucod_rqst_source (codseq, codeval, codetxt, codecode, codeattrib) VALUES (NULL, 'ADMIN', 'Administrator Interface', NULL, NULL);
insert into jsharmony_ucod_rqst_source (codseq, codeval, codetxt, codecode, codeattrib) VALUES (NULL, 'CLIENT', 'Client Interface', NULL, NULL);

/*********UCOD_TXT_TYPE*********/
jsharmony.create_ucod('jsharmony','txt_type','');
insert into jsharmony_ucod_txt_type (codseq, codeval, codetxt, codecode, codeattrib) VALUES (2, 'HTML', 'HTML', NULL, NULL);
insert into jsharmony_ucod_txt_type (codseq, codeval, codetxt, codecode, codeattrib) VALUES (1, 'TEXT', 'Text', NULL, NULL);

/*********UCOD_V_STS*********/
jsharmony.create_ucod('jsharmony','v_sts','');
insert into jsharmony_ucod_v_sts (codseq, codeval, codetxt, codecode, codeattrib) VALUES (2, 'ERROR', 'Error', NULL, NULL);
insert into jsharmony_ucod_v_sts (codseq, codeval, codetxt, codecode, codeattrib) VALUES (1, 'OK', 'OK', NULL, NULL);

/*********UCOD2_COUNTRY_STATE*********/
jsharmony.create_ucod2('jsharmony','country_state','');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('CANADA','AB','Alberta');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('CANADA','BC','British Columbia');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('CANADA','MB','Manitoba');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('CANADA','NB','New Brunswick');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('CANADA','NL','Newfoundland and Labrador');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('CANADA','NS','Nova Scotia');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('CANADA','NT','Northwest Territories');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('CANADA','NU','Nunavut');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('CANADA','ON','Ontario');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('CANADA','PE','Prince Edward Island');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('CANADA','QC','Quebec');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('CANADA','SK','Saskatchewan');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('CANADA','YT','Yukon');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','AG','Aguascalientes');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','BN','Baja California');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','BS','Baja California Sur');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','CA','Coahuila');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','CH','Chihuahua');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','CL','Colima');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','CM','Compeche');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','CP','Chiapas');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','DF','Federal District');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','DU','Durango');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','GR','Guerrero');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','GT','Guanajuato');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','HI','Hidalgo');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','JA','Jalisco');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','MC','Michoacan');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','MR','Morelos');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','MX','Mexico');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','NA','Nayarit');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','NL','Nuevo Leon');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','OA','Oaxaca');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','PU','Puebla');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','QE','Queretaro');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','QR','Quintana Roo');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','SI','Sinaloa');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','SL','San Luis Potosí');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','SO','Sonora');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','TB','Tabasco');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','TL','Tlaxcala');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','TM','Tamaulipas');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','VE','Veracruz');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','YU','Yucatán');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','ZA','Zacatecas');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','AK','Alaska');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','AL','Alabama');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','AR','Arkansas');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','AS','American Samoa');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','AZ','Arizona');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','CA','California');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','CO','Colorado');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','CT','Connecticut');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','DC','District of Columbia');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','DE','Delaware');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','FL','Florida');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','FM','Federated States of Micronesia');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','GA','Georgia');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','GU','Guam');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','HI','Hawaii');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','IA','Iowa');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','ID','Idaho');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','IL','Illinois');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','IN','Indiana');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','KS','Kansas');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','KY','Kentucky');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','LA','Louisiana');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','MA','Massachusetts');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','MD','Maryland');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','ME','Maine');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','MH','Marshall Islands');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','MI','Michigan');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','MN','Minnesota');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','MO','Missouri');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','MP','Northern Mariana Islands');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','MS','Mississippi');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','MT','Montana');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','NC','North Carolina');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','ND','North Dakota');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','NE','Nebraska');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','NH','New Hampshire');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','NJ','New Jersey');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','NM','New Mexico');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','NV','Nevada');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','NY','New York');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','OH','Ohio');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','OK','Oklahoma');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','OR','Oregon');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','PA','Pennsylvania');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','PR','Puerto Rico');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','PW','Palau');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','RI','Rhode Island');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','SC','South Carolina');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','SD','South Dakota');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','TN','Tennessee');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','TX','Texas');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','UT','Utah');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','VA','Virginia');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','VI','Virgin Islands');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','VT','Vermont');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','WA','Washington');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','WI','Wisconsin');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','WV','West Virginia');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','WY','Wyoming');

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
create trigger insert_jsharmony_cpe after insert on jsharmony_cpe
begin
  update jsharmony_cpe set 
    pe_stsdt  = datetime('now','localtime'),
    pe_eu     = (select context from jsharmony_meta limit 1),
    pe_etstmp = datetime('now','localtime'),
    pe_mu     = (select context from jsharmony_meta limit 1),
    pe_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;
end;

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
INSERT INTO jsharmony_cr (cr_seq, cr_sts, cr_name, cr_desc, cr_code, cr_attrib) VALUES (1, 'ACTIVE', 'CSYSADMIN', 'Administrator', NULL,NULL);
INSERT INTO jsharmony_cr (cr_seq, cr_sts, cr_name, cr_desc, cr_code, cr_attrib) VALUES (2, 'ACTIVE', 'CX_B', 'Browse', NULL, NULL);
INSERT INTO jsharmony_cr (cr_seq, cr_sts, cr_name, cr_desc, cr_code, cr_attrib) VALUES (3, 'ACTIVE', 'CX_X', 'Entry / Update', NULL, NULL);
INSERT INTO jsharmony_cr (cr_seq, cr_sts, cr_name, cr_desc, cr_code, cr_attrib) VALUES (1, 'ACTIVE', 'CUSER', 'Client User', NULL, NULL);
INSERT INTO jsharmony_cr (cr_seq, cr_sts, cr_name, cr_desc, cr_code, cr_attrib) VALUES (0, 'ACTIVE', 'C*', 'All Users', NULL, NULL);

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
create trigger insert_jsharmony_d after insert on jsharmony_d
begin
  update jsharmony_d set 
    d_eu     = (select context from jsharmony_meta limit 1),
    d_etstmp = datetime('now','localtime'),
    d_mu     = (select context from jsharmony_meta limit 1),
    d_mtstmp = datetime('now','localtime'),
    d_uu     = (select context from jsharmony_meta limit 1),
    d_utstmp = datetime('now','localtime')
    where rowid = new.rowid\;
end;

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
create trigger insert_jsharmony_h after insert on jsharmony_h
begin
  update jsharmony_h set 
    h_eu     = (select context from jsharmony_meta limit 1),
    h_etstmp = datetime('now','localtime'),
    h_mu     = (select context from jsharmony_meta limit 1),
    h_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;
end;

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
create trigger insert_jsharmony_n after insert on jsharmony_n
begin
  update jsharmony_n set 
    n_eu     = (select context from jsharmony_meta limit 1),
    n_etstmp = datetime('now','localtime'),
    n_mu     = (select context from jsharmony_meta limit 1),
    n_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;
end;

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
create trigger insert_jsharmony_pe after insert on jsharmony_pe
begin
  update jsharmony_pe set 
    pe_startdt = ifnull(NEW.pe_startdt,date('now','localtime')),
    pe_stsdt  = datetime('now','localtime'),
    pe_eu     = (select context from jsharmony_meta limit 1),
    pe_etstmp = datetime('now','localtime'),
    pe_mu     = (select context from jsharmony_meta limit 1),
    pe_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;

  select case when ifnull(NEW.pe_pw1,'')<>ifnull(NEW.pe_pw2,'') then raise(FAIL,'Application Error - New Password and Repeat Password are different') end\;
  select case when length(ifnull(NEW.pe_pw1,''))< 6 then raise(FAIL,'Application Error - Password length - at least 6 characters required') end\;
  update jsharmony_meta set jsexec = '{ "function": "sha1", "table": "jsharmony_pe", "rowid": '||NEW.rowid||', "source":"pe_id||pe_pw1||(select pp_val from jsharmony_v_pp where PP_PROCESS=''USERS'' and PP_ATTRIB=''HASH_SEED_S'')", "dest":"pe_hash" }, { "function": "exec", "sql": "update jsharmony_pe set pe_pw1=null,pe_pw2=null where rowid='||NEW.rowid||'" }'\;

  %%%AUDIT_I("PE","new.PE_ID","PE_ID","null","null","null")%%%
  update jsharmony_meta set aud_seq = null\;
end;

create trigger delete_jsharmony_pe before delete on jsharmony_pe
begin
  %%%AUDIT_D_MULT("PE","old.PE_ID",["PE_ID","PE_STS","PE_FNAME","PE_MNAME","PE_LNAME","PE_JTITLE","PE_BPHONE","PE_CPHONE","PE_EMAIL","PE_LL_TSTMP"],"null","null","null")%%%
  update jsharmony_meta set aud_seq = null\;
end;

create trigger update_jsharmony_pe before update on jsharmony_pe
begin
  select case when NEW.pe_stsdt is null then raise(FAIL,'pe_stsdt cannot be null') end\;
  select case when NEW.pe_id <> OLD.pe_id then raise(FAIL,'Application Error - ID cannot be updated.') end\;

  select case when ifnull(NEW.pe_pw1,'')<>ifnull(NEW.pe_pw2,'') then raise(FAIL,'Application Error - New Password and Repeat Password are different') end\;
  select case when (NEW.pe_pw1 is not null) and (length(ifnull(NEW.pe_pw1,''))< 6) then raise(FAIL,'Application Error - Password length - at least 6 characters required') end\;

  %%%AUDIT_U_MULT("PE","old.PE_ID",["PE_ID","PE_STS","PE_FNAME","PE_MNAME","PE_LNAME","PE_JTITLE","PE_BPHONE","PE_CPHONE","PE_EMAIL","PE_LL_TSTMP"],"null","null","null")%%%

  %%%AUDIT_U_CUSTOM("PE","old.PE_ID","coalesce(NEW.pe_pw1,'') <> '' and coalesce(NEW.pe_pw1,'') <> coalesce(OLD.pe_pw1,'')","null","null","null")%%%
  insert into jsharmony_aud_d(aud_seq,column_name,column_val)
    select (select aud_seq from jsharmony_meta),'PE_PW1','*'
    where (coalesce(NEW.pe_pw1,'') <> '' and coalesce(NEW.pe_pw1,'') <> coalesce(OLD.pe_pw1,''))\;


  update jsharmony_meta set jsexec = '{ "function": "sha1", "table": "jsharmony_pe", "rowid": '||NEW.rowid||', "source":"pe_id||pe_pw1||(select pp_val from jsharmony_v_pp where PP_PROCESS=''USERS'' and PP_ATTRIB=''HASH_SEED_S'')", "dest":"pe_hash" }, { "function": "exec", "sql": "update jsharmony_pe set pe_pw1=null,pe_pw2=null where rowid='||NEW.rowid||'" }'
    where NEW.pe_pw1 is not null\;

  --jsharmony_d exists error
  update jsharmony_pe set
    pe_stsdt  = case when (%%%NONEQUAL("NEW.pe_sts","OLD.pe_sts")%%%) then datetime('now','localtime') else NEW.pe_stsdt end,
    pe_mu     = (select context from jsharmony_meta limit 1),
    pe_mtstmp = datetime('now','localtime')
    where rowid = new.rowid and exists(select * from jsharmony_meta where aud_seq is not null)\; 

  update jsharmony_meta set aud_seq = null\;
end;

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
create trigger insert_jsharmony_ppd before insert on jsharmony_ppd
begin
  update jsharmony_ppd set 
    ppd_eu     = (select context from jsharmony_meta limit 1),
    ppd_etstmp = datetime('now','localtime'),
    ppd_mu     = (select context from jsharmony_meta limit 1),
    ppd_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;
end;
INSERT INTO jsharmony_ppd (ppd_process, ppd_attrib, ppd_desc, ppd_type, codename, ppd_gpp, ppd_ppp, ppd_xpp) VALUES ('EMAIL', 'NOTIF_ADMIN', 'Notifications Email - Administrative', 'C', NULL,  1, 0, 0);
INSERT INTO jsharmony_ppd (ppd_process, ppd_attrib, ppd_desc, ppd_type, codename, ppd_gpp, ppd_ppp, ppd_xpp) VALUES ('USERS', 'HASH_SEED_S', 'Hash Seed System Users', 'C', NULL,  0, 0, 1);
INSERT INTO jsharmony_ppd (ppd_process, ppd_attrib, ppd_desc, ppd_type, codename, ppd_gpp, ppd_ppp, ppd_xpp) VALUES ('HOUSE', 'ADDR', 'HOUSE Address', 'C', NULL,  1, 0, 0);
INSERT INTO jsharmony_ppd (ppd_process, ppd_attrib, ppd_desc, ppd_type, codename, ppd_gpp, ppd_ppp, ppd_xpp) VALUES ('HOUSE', 'BPHONE', 'HOUSE Business Phone', 'C', NULL,  1, 0, 0);
INSERT INTO jsharmony_ppd (ppd_process, ppd_attrib, ppd_desc, ppd_type, codename, ppd_gpp, ppd_ppp, ppd_xpp) VALUES ('HOUSE', 'CITY', 'HOUSE City', 'C', NULL,  1, 0, 0);
INSERT INTO jsharmony_ppd (ppd_process, ppd_attrib, ppd_desc, ppd_type, codename, ppd_gpp, ppd_ppp, ppd_xpp) VALUES ('HOUSE', 'CONTACT', 'HOUSE Contact', 'C', NULL,  1, 0, 0);
INSERT INTO jsharmony_ppd (ppd_process, ppd_attrib, ppd_desc, ppd_type, codename, ppd_gpp, ppd_ppp, ppd_xpp) VALUES ('HOUSE', 'EMAIL', 'HOUSE Email', 'C', NULL,  1, 0, 0);
INSERT INTO jsharmony_ppd (ppd_process, ppd_attrib, ppd_desc, ppd_type, codename, ppd_gpp, ppd_ppp, ppd_xpp) VALUES ('HOUSE', 'FAX', 'HOUSE Fax', 'C', NULL,  1, 0, 0);
INSERT INTO jsharmony_ppd (ppd_process, ppd_attrib, ppd_desc, ppd_type, codename, ppd_gpp, ppd_ppp, ppd_xpp) VALUES ('SQL', 'DSCOPE_DCTGR', 'Code table - Document Types by Scope', 'C', NULL,  0, 0, 1);
INSERT INTO jsharmony_ppd (ppd_process, ppd_attrib, ppd_desc, ppd_type, codename, ppd_gpp, ppd_ppp, ppd_xpp) VALUES ('SQL', 'GETCID', 'SQL Function GET_C_ID', 'C', NULL,  0, 0, 1);
INSERT INTO jsharmony_ppd (ppd_process, ppd_attrib, ppd_desc, ppd_type, codename, ppd_gpp, ppd_ppp, ppd_xpp) VALUES ('SQL', 'GETEID', 'SQL Function GET_E_ID', 'C', NULL,  0, 0, 1);
INSERT INTO jsharmony_ppd (ppd_process, ppd_attrib, ppd_desc, ppd_type, codename, ppd_gpp, ppd_ppp, ppd_xpp) VALUES ('HOUSE', 'ZIP', 'HOUSE ZIP', 'C', NULL,  1, 0, 0);
INSERT INTO jsharmony_ppd (ppd_process, ppd_attrib, ppd_desc, ppd_type, codename, ppd_gpp, ppd_ppp, ppd_xpp) VALUES ('HOUSE', 'STATE', 'HOUSE State', 'C', NULL,  1, 0, 0);
INSERT INTO jsharmony_ppd (ppd_process, ppd_attrib, ppd_desc, ppd_type, codename, ppd_gpp, ppd_ppp, ppd_xpp) VALUES ('HOUSE', 'NAME', 'HOUSE Name', 'C', NULL,  1, 0, 0);
INSERT INTO jsharmony_ppd (ppd_process, ppd_attrib, ppd_desc, ppd_type, codename, ppd_gpp, ppd_ppp, ppd_xpp) VALUES ('DEVICEURL', 'PRINTBAR', 'Device URL - Bar Code Printer', 'C', NULL,  1, 1, 0);
INSERT INTO jsharmony_ppd (ppd_process, ppd_attrib, ppd_desc, ppd_type, codename, ppd_gpp, ppd_ppp, ppd_xpp) VALUES ('DEVICEURL', 'SCAN', 'Device URL - Document Scanner', 'C', NULL,  1, 1, 0);
INSERT INTO jsharmony_ppd (ppd_process, ppd_attrib, ppd_desc, ppd_type, codename, ppd_gpp, ppd_ppp, ppd_xpp) VALUES ('EMAIL', 'NOTIF_SYS', 'Notifications Email - System', 'C', NULL,  1, 0, 1);
INSERT INTO jsharmony_ppd (ppd_process, ppd_attrib, ppd_desc, ppd_type, codename, ppd_gpp, ppd_ppp, ppd_xpp) VALUES ('SYSTEM', 'CLIENT_SYS_URL', 'Client Portal URL', 'C', NULL,  0, 0, 1);
INSERT INTO jsharmony_ppd (ppd_process, ppd_attrib, ppd_desc, ppd_type, codename, ppd_gpp, ppd_ppp, ppd_xpp) VALUES ('USERS', 'HASH_SEED_C', 'Hash Seed Client Users', 'C', NULL,  0, 0, 1);

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
create trigger insert_jsharmony_rq after insert on jsharmony_rq
begin
  update jsharmony_rq set 
    rq_eu     = (select context from jsharmony_meta limit 1),
    rq_etstmp = datetime('now','localtime')
    where rowid = new.rowid\;
end;

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
create trigger insert_jsharmony_rqst after insert on jsharmony_rqst
begin
  update jsharmony_rqst set 
    rqst_eu     = (select context from jsharmony_meta limit 1),
    rqst_etstmp = datetime('now','localtime')
    where rowid = new.rowid\;
end;

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
INSERT INTO jsharmony_sm (sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_subcmd) VALUES ('S', 1, 'ACTIVE', NULL, 'ADMIN', NULL, 'Admin', NULL, NULL, NULL, NULL, NULL);
INSERT INTO jsharmony_sm (sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_subcmd) VALUES ('C', 2, 'ACTIVE', NULL, 'CLIENT', NULL, 'Customer', NULL, NULL, NULL, NULL, NULL);
INSERT INTO jsharmony_sm (sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_subcmd) VALUES ('S', 3, 'ACTIVE', 1, 'DASHBOARD', 1, 'Dashboard', NULL, NULL, 'DASHBOARD', NULL, NULL);
INSERT INTO jsharmony_sm (sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_subcmd) VALUES ('S', 160, 'ACTIVE', 1, 'REPORTS', 2, 'Reports', NULL, NULL, 'REPORTS', NULL, NULL);
INSERT INTO jsharmony_sm (sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_subcmd) VALUES ('S', 170, 'ACTIVE', 1, 'ADMINISTRATION', 3, 'Administration', NULL, NULL, 'ADMIN_OVERVIEW', NULL, NULL);
INSERT INTO jsharmony_sm (sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_subcmd) VALUES ('S', 10, 'ACTIVE', 1, 'DEV', 4, 'Developer', NULL, NULL, 'DEV_OVERVIEW', NULL, NULL);
INSERT INTO jsharmony_sm (sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_subcmd) VALUES ('C', 200, 'ACTIVE', 2, 'C_DASHBOARD', NULL, 'Dashboard', NULL, NULL, NULL, NULL, NULL);
INSERT INTO jsharmony_sm (sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_subcmd) VALUES ('C', 270, 'ACTIVE', 2, 'C_ADMINISTRATION', NULL, 'Administration', NULL, NULL, NULL, NULL, NULL);
INSERT INTO jsharmony_sm (sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_subcmd) VALUES ('S', 1785, 'ACTIVE', 170, 'ADMINISTRATION_TEXTMAINTENANCE', NULL, 'Text Maint', NULL, NULL, 'TXTL', NULL, NULL);
INSERT INTO jsharmony_sm (sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_subcmd) VALUES ('S', 1783, 'ACTIVE', 170, 'ADMINISTRATION_CODETABLES', NULL, '1D Code Tables', NULL, NULL, 'GCOD_HL', NULL, NULL);
INSERT INTO jsharmony_sm (sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_subcmd) VALUES ('S', 1784, 'ACTIVE', 170, 'ADMINISTRATION_CODE2TABLES', NULL, '2D Code Tables', NULL, NULL, 'GCOD2_HL', NULL, NULL);
INSERT INTO jsharmony_sm (sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_subcmd) VALUES ('S', 1781, 'ACTIVE', 170, 'ADMINISTRATION_PPARAMETERS', NULL, 'User Settings', NULL, NULL, 'PPPL', NULL, NULL);
INSERT INTO jsharmony_sm (sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_subcmd) VALUES ('S', 1782, 'ACTIVE', 170, 'ADMINISTRATION_GPARAMETERS', NULL, 'System Settings', NULL, NULL, 'GPPL', NULL, NULL);
INSERT INTO jsharmony_sm (sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_subcmd) VALUES ('S', 14, 'ACTIVE', 10, 'DEV_X_GPPL', 22, 'System Settings', NULL, NULL, 'X_GPPL', NULL, NULL);
INSERT INTO jsharmony_sm (sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_subcmd) VALUES ('S', 13, 'ACTIVE', 10, 'DEV_X_PPDL', 21, 'Settings Definitions', NULL, NULL, 'X_PPDL', NULL, NULL);
INSERT INTO jsharmony_sm (sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_subcmd) VALUES ('C', 2700, 'ACTIVE', 270, 'C_ADMINISTRATION_USERS', NULL, 'Cust Users', NULL, NULL, 'CPEL_CLIENT', NULL, NULL);
INSERT INTO jsharmony_sm (sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_subcmd) VALUES ('C', 2701, 'ACTIVE', 270, 'C_ADMINISTRATION_CONTACTS', NULL, 'Contacts', NULL, NULL, 'CTL_C_CLIENT', NULL, NULL);
INSERT INTO jsharmony_sm (sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_subcmd) VALUES ('S', 1795, 'ACTIVE', 170, 'ADMINISTRATION_LOG', NULL, 'Logs', NULL, NULL, 'LOG', NULL, NULL);
INSERT INTO jsharmony_sm (sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_subcmd) VALUES ('S', 1796, 'ACTIVE', 170, 'ADMINISTRATION_RESTART_SYSTEM', NULL, 'Restart System', NULL, NULL, 'RESTART_SYSTEM', NULL, NULL);
INSERT INTO jsharmony_sm (sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_subcmd) VALUES ('S', 12, 'ACTIVE', 10, 'DEV_X_SML', 11, 'Menu Items', NULL, NULL, 'X_SMLW', NULL, NULL);
INSERT INTO jsharmony_sm (sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_subcmd) VALUES ('S', 11, 'ACTIVE', 10, 'DEV_X_SRL', 12, 'User Roles', NULL, NULL, 'X_SRL', NULL, NULL);
INSERT INTO jsharmony_sm (sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_subcmd) VALUES ('S', 20, 'ACTIVE', 10, 'DEV_X_CRL', 13, 'Client User Roles', NULL, NULL, 'X_CRL', NULL, NULL);
INSERT INTO jsharmony_sm (sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_subcmd) VALUES ('S', 21, 'ACTIVE', 10, 'DEV_X_TXTL', 41, 'Text Maint', NULL, NULL, 'X_TXTL', NULL, NULL);
INSERT INTO jsharmony_sm (sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_subcmd) VALUES ('S', 22, 'ACTIVE', 10, 'DEV_X_HPL', 42, 'Help Panels', NULL, NULL, 'X_HPL', NULL, NULL);
INSERT INTO jsharmony_sm (sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_subcmd) VALUES ('S', 1786, 'ACTIVE', 170, 'ADMINISTRATION_HELPMAINTENANCE', NULL, 'Help Maint', NULL, NULL, 'HL', NULL, NULL);
INSERT INTO jsharmony_sm (sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_subcmd) VALUES ('S', 18, 'ACTIVE', 10, 'DEV_X_UCOD_HL', 33, 'System 1D Codes', NULL, NULL, 'X_UCOD_HL', NULL, NULL);
INSERT INTO jsharmony_sm (sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_subcmd) VALUES ('S', 19, 'ACTIVE', 10, 'DEV_X_UCOD2_HL', 34, 'System 2D Codes', NULL, NULL, 'X_UCOD2_HL', NULL, NULL);
INSERT INTO jsharmony_sm (sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_subcmd) VALUES ('S', 1700, 'ACTIVE', 170, 'ADMINISTRATION_USERS', NULL, 'System Users', NULL, NULL, 'PEL', NULL, NULL);
INSERT INTO jsharmony_sm (sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_subcmd) VALUES ('S', 1787, 'ACTIVE', 170, 'ADMINISTRATION_AUDITTRAIL', NULL, 'Audit Trail', NULL, NULL, 'AUDL', NULL, NULL);
INSERT INTO jsharmony_sm (sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_subcmd) VALUES ('S', 15, 'ACTIVE', 10, 'DEV_X_XPPL', 23, 'Developer Settings', NULL, NULL, 'X_XPPL', NULL, NULL);
INSERT INTO jsharmony_sm (sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_subcmd) VALUES ('S', 16, 'ACTIVE', 10, 'DEV_X_GCOD_HL', 31, 'Admin 1D Codes', NULL, NULL, 'X_GCOD_HL', NULL, NULL);
INSERT INTO jsharmony_sm (sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_subcmd) VALUES ('S', 17, 'ACTIVE', 10, 'DEV_X_GCOD2_HL', 32, 'Admin 2D Codes', NULL, NULL, 'X_GCOD2_HL', NULL, NULL);
INSERT INTO jsharmony_sm (sm_utype, sm_id, sm_sts, sm_id_parent, sm_name, sm_seq, sm_desc, sm_descl, sm_descvl, sm_cmd, sm_image, sm_subcmd) VALUES ('S', 1601, 'ACTIVE', 160, 'REPORTS_USERS', NULL, 'User Listing', NULL, NULL, '_report/RPE', NULL, NULL);

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
INSERT INTO jsharmony_sr (sr_seq, sr_sts, sr_name, sr_desc, sr_code, sr_attrib) VALUES (0, 'ACTIVE', '*', 'All Users', NULL, NULL);
INSERT INTO jsharmony_sr (sr_seq, sr_sts, sr_name, sr_desc, sr_code, sr_attrib) VALUES (97, 'ACTIVE', 'DADMIN', 'Data Administration', NULL, NULL);
INSERT INTO jsharmony_sr (sr_seq, sr_sts, sr_name, sr_desc, sr_code, sr_attrib) VALUES (98, 'ACTIVE', 'SYSADMIN', 'System Administration', NULL, NULL);
INSERT INTO jsharmony_sr (sr_seq, sr_sts, sr_name, sr_desc, sr_code, sr_attrib) VALUES (99, 'ACTIVE', 'DEV', 'Developer', NULL, NULL);
INSERT INTO jsharmony_sr (sr_seq, sr_sts, sr_name, sr_desc, sr_code, sr_attrib) VALUES (91, 'ACTIVE', 'X_B', 'General Browse', NULL, NULL);
INSERT INTO jsharmony_sr (sr_seq, sr_sts, sr_name, sr_desc, sr_code, sr_attrib) VALUES (92, 'ACTIVE', 'X_X', 'General BIUD', NULL, NULL);

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
INSERT INTO jsharmony_sf (sf_seq, sf_sts, sf_name, sf_desc, sf_code, sf_attrib) VALUES (1, 'ACTIVE', 'TBD', 'TBD', NULL, NULL);

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
create trigger insert_jsharmony_txt after insert on jsharmony_txt
begin
  update jsharmony_txt set 
    txt_eu     = (select context from jsharmony_meta limit 1),
    txt_etstmp = datetime('now','localtime'),
    txt_mu     = (select context from jsharmony_meta limit 1),
    txt_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;
end;
INSERT INTO jsharmony_txt (txt_process, txt_attrib, txt_type, txt_tval, txt_val, txt_bcc, txt_desc) VALUES ('EMAIL', 'RESETPASS', 'HTML', 'Password Reset', '<p>Dear <%-data.PE_NAME%>,<br />
<br />
A password reset has been requested on your account. If you did not initiate the request, please contact us at <%-data.SUPPORT_EMAIL%> immediately.<br />
<br />
Please follow the link below to reset your password:<br />
<a href="<%-data.RESET_LINK%>"><%-data.RESET_LINK%></a></p>
', NULL, '<%-data.PE_NAME%> User Name
<%-data.SUPPORT_EMAIL%> Support Email
<%-data.RESET_LINK%> Reset Link');
INSERT INTO jsharmony_txt (txt_process, txt_attrib, txt_type, txt_tval, txt_val, txt_bcc, txt_desc) VALUES ('CMS', 'AGREEMENT', 'HTML', 'Client Agreement', NULL, NULL, 'Client Agreement');
INSERT INTO jsharmony_txt (txt_process, txt_attrib, txt_type, txt_tval, txt_val, txt_bcc, txt_desc) VALUES ('CMS', 'AGREEMENT_DONE', 'HTML', 'Client Agreement Complete', '<p>Thank you for completing sign-up.</p>
', NULL, 'Client Agreement Complete');
INSERT INTO jsharmony_txt (txt_process, txt_attrib, txt_type, txt_tval, txt_val, txt_bcc, txt_desc) VALUES ('SMS', 'WELCOME', 'TEXT', 'Welcome', 'Your account has been initialized.', NULL, 'SMS Welcome Message');
INSERT INTO jsharmony_txt (txt_process, txt_attrib, txt_type, txt_tval, txt_val, txt_bcc, txt_desc) VALUES ('CMS', 'DASHBOARD', 'HTML', 'Dashboard Message of the Day', '<p>Welcome to the jsHarmony System</p>
', NULL, 'Dashboard Message of the Day');


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
INSERT INTO jsharmony_crm (sm_id, crm_snotes, cr_name) VALUES (200, NULL, 'CX_B');
INSERT INTO jsharmony_crm (sm_id, crm_snotes, cr_name) VALUES (270, NULL, 'CSYSADMIN');
INSERT INTO jsharmony_crm (sm_id, crm_snotes, cr_name) VALUES (2700, NULL, 'CSYSADMIN');
INSERT INTO jsharmony_crm (sm_id, crm_snotes, cr_name) VALUES (2701, NULL, 'CSYSADMIN');
INSERT INTO jsharmony_crm (sm_id, crm_snotes, cr_name) VALUES (200, NULL, 'CX_X');
INSERT INTO jsharmony_crm (sm_id, crm_snotes, cr_name) VALUES (200, NULL, 'CUSER');

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
create trigger insert_jsharmony_gcod_h after insert on jsharmony_gcod_h
begin
  update jsharmony_gcod_h set 
    cod_h_eu     = (select context from jsharmony_meta limit 1),
    cod_h_etstmp = datetime('now','localtime'),
    cod_h_mu     = (select context from jsharmony_meta limit 1),
    cod_h_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;
end;


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
create trigger insert_jsharmony_gcod2_h after insert on jsharmony_gcod2_h
begin
  update jsharmony_gcod2_h set 
    cod_h_eu     = (select context from jsharmony_meta limit 1),
    cod_h_etstmp = datetime('now','localtime'),
    cod_h_mu     = (select context from jsharmony_meta limit 1),
    cod_h_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;
end;
INSERT INTO jsharmony_gcod2_h (codename, codemean, codecodemean, codeattribmean, codeschema) VALUES ('d_scope_d_ctgr', 'Scope - Documents', NULL, NULL, 'jsharmony');

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
create trigger insert_jsharmony_gpp after insert on jsharmony_gpp
begin
  update jsharmony_gpp set 
    gpp_eu     = (select context from jsharmony_meta limit 1),
    gpp_etstmp = datetime('now','localtime'),
    gpp_mu     = (select context from jsharmony_meta limit 1),
    gpp_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;
end;
INSERT INTO jsharmony_gpp (gpp_process, gpp_attrib, gpp_val) VALUES ('HOUSE', 'STATE', 'IL');
INSERT INTO jsharmony_gpp (gpp_process, gpp_attrib, gpp_val) VALUES ('HOUSE', 'CITY', 'Anytown');
INSERT INTO jsharmony_gpp (gpp_process, gpp_attrib, gpp_val) VALUES ('HOUSE', 'CONTACT', 'John Contact');
INSERT INTO jsharmony_gpp (gpp_process, gpp_attrib, gpp_val) VALUES ('HOUSE', 'ADDR', '111 Main St');
INSERT INTO jsharmony_gpp (gpp_process, gpp_attrib, gpp_val) VALUES ('HOUSE', 'BPHONE', '(222) 222-2222');
INSERT INTO jsharmony_gpp (gpp_process, gpp_attrib, gpp_val) VALUES ('HOUSE', 'EMAIL', 'user@company.com');
INSERT INTO jsharmony_gpp (gpp_process, gpp_attrib, gpp_val) VALUES ('HOUSE', 'FAX', '(333) 333-3333');
INSERT INTO jsharmony_gpp (gpp_process, gpp_attrib, gpp_val) VALUES ('HOUSE', 'NAME', 'COMPANY NAME');
INSERT INTO jsharmony_gpp (gpp_process, gpp_attrib, gpp_val) VALUES ('EMAIL', 'NOTIF_ADMIN', 'user@company.com');
INSERT INTO jsharmony_gpp (gpp_process, gpp_attrib, gpp_val) VALUES ('HOUSE', 'ZIP', '11111');


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
create trigger insert_jsharmony_ppp after insert on jsharmony_ppp
begin
  update jsharmony_ppp set 
    ppp_eu     = (select context from jsharmony_meta limit 1),
    ppp_etstmp = datetime('now','localtime'),
    ppp_mu     = (select context from jsharmony_meta limit 1),
    ppp_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;
end;

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
INSERT INTO jsharmony_srm (sm_id, sr_name) VALUES (2701, 'SYSADMIN');
INSERT INTO jsharmony_srm (sm_id, sr_name) VALUES (2700, 'SYSADMIN');
INSERT INTO jsharmony_srm (sm_id, sr_name) VALUES (10, 'DEV');
INSERT INTO jsharmony_srm (sm_id, sr_name) VALUES (1700, 'SYSADMIN');
INSERT INTO jsharmony_srm (sm_id, sr_name) VALUES (270, 'SYSADMIN');
INSERT INTO jsharmony_srm (sm_id, sr_name) VALUES (200, 'SYSADMIN');
INSERT INTO jsharmony_srm (sm_id, sr_name) VALUES (170, 'SYSADMIN');
INSERT INTO jsharmony_srm (sm_id, sr_name) VALUES (2, 'SYSADMIN');
INSERT INTO jsharmony_srm (sm_id, sr_name) VALUES (11, 'DEV');
INSERT INTO jsharmony_srm (sm_id, sr_name) VALUES (12, 'DEV');
INSERT INTO jsharmony_srm (sm_id, sr_name) VALUES (13, 'DEV');
INSERT INTO jsharmony_srm (sm_id, sr_name) VALUES (14, 'DEV');
INSERT INTO jsharmony_srm (sm_id, sr_name) VALUES (15, 'DEV');
INSERT INTO jsharmony_srm (sm_id, sr_name) VALUES (170, 'DEV');
INSERT INTO jsharmony_srm (sm_id, sr_name) VALUES (1700, 'DEV');
INSERT INTO jsharmony_srm (sm_id, sr_name) VALUES (16, 'DEV');
INSERT INTO jsharmony_srm (sm_id, sr_name) VALUES (17, 'DEV');
INSERT INTO jsharmony_srm (sm_id, sr_name) VALUES (18, 'DEV');
INSERT INTO jsharmony_srm (sm_id, sr_name) VALUES (19, 'DEV');
INSERT INTO jsharmony_srm (sm_id, sr_name) VALUES (20, 'DEV');
INSERT INTO jsharmony_srm (sm_id, sr_name) VALUES (21, 'DEV');
INSERT INTO jsharmony_srm (sm_id, sr_name) VALUES (22, 'DEV');
INSERT INTO jsharmony_srm (sm_id, sr_name) VALUES (1786, 'SYSADMIN');
INSERT INTO jsharmony_srm (sm_id, sr_name) VALUES (1795, 'SYSADMIN');
INSERT INTO jsharmony_srm (sm_id, sr_name) VALUES (1796, 'SYSADMIN');
INSERT INTO jsharmony_srm (sm_id, sr_name) VALUES (3, '*');
INSERT INTO jsharmony_srm (sm_id, sr_name) VALUES (1787, 'SYSADMIN');
INSERT INTO jsharmony_srm (sm_id, sr_name) VALUES (1785,  'SYSADMIN');
INSERT INTO jsharmony_srm (sm_id, sr_name) VALUES (1783, 'SYSADMIN');
INSERT INTO jsharmony_srm (sm_id, sr_name) VALUES (1784, 'SYSADMIN');
INSERT INTO jsharmony_srm (sm_id, sr_name) VALUES (1781, 'SYSADMIN');
INSERT INTO jsharmony_srm (sm_id, sr_name) VALUES (1782, 'SYSADMIN');
INSERT INTO jsharmony_srm (sm_id, sr_name) VALUES (1601, 'SYSADMIN');
INSERT INTO jsharmony_srm (sm_id, sr_name) VALUES (160, 'SYSADMIN');

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
create trigger insert_jsharmony_ucod_h after insert on jsharmony_ucod_h
begin
  update jsharmony_ucod_h set 
    cod_h_eu     = (select context from jsharmony_meta limit 1),
    cod_h_etstmp = datetime('now','localtime'),
    cod_h_mu     = (select context from jsharmony_meta limit 1),
    cod_h_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;
end;
INSERT INTO jsharmony_ucod_h (codename, codemean, codecodemean, codeattribmean, codeschema) VALUES ('ac', 'ACTIVE-CLOSED', NULL, NULL, 'jsharmony');
INSERT INTO jsharmony_ucod_h (codename, codemean, codecodemean, codeattribmean, codeschema) VALUES ('ac1', 'ACTIVE-CLOSED 1 Character', NULL, NULL, 'jsharmony');
INSERT INTO jsharmony_ucod_h (codename, codemean, codecodemean, codeattribmean, codeschema) VALUES ('ahc', 'ACTIVE-HOLD-CLOSED', NULL, NULL, 'jsharmony');
INSERT INTO jsharmony_ucod_h (codename, codemean, codecodemean, codeattribmean, codeschema) VALUES ('country', 'Country', NULL, NULL, 'jsharmony');
INSERT INTO jsharmony_ucod_h (codename, codemean, codecodemean, codeattribmean, codeschema) VALUES ('d_scope', 'Document Scope', 'Client User Y/N', NULL, 'jsharmony');
INSERT INTO jsharmony_ucod_h (codename, codemean, codecodemean, codeattribmean, codeschema) VALUES ('n_scope', 'Note Scope', NULL, NULL, 'jsharmony');
INSERT INTO jsharmony_ucod_h (codename, codemean, codecodemean, codeattribmean, codeschema) VALUES ('n_type', 'Note Type', NULL, NULL, 'jsharmony');
INSERT INTO jsharmony_ucod_h (codename, codemean, codecodemean, codeattribmean, codeschema) VALUES ('ppd_type', 'Parameter Type', NULL, NULL, 'jsharmony');
INSERT INTO jsharmony_ucod_h (codename, codemean, codecodemean, codeattribmean, codeschema) VALUES ('rqst_atype', 'Request Action Type', NULL, NULL, 'jsharmony');
INSERT INTO jsharmony_ucod_h (codename, codemean, codecodemean, codeattribmean, codeschema) VALUES ('rqst_source', 'Request Source', NULL, NULL, 'jsharmony');
INSERT INTO jsharmony_ucod_h (codename, codemean, codecodemean, codeattribmean, codeschema) VALUES ('txt_type', 'Text Type', NULL, NULL, 'jsharmony');
INSERT INTO jsharmony_ucod_h (codename, codemean, codecodemean, codeattribmean, codeschema) VALUES ('v_sts', 'Version Status', NULL, NULL, 'jsharmony');


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
create trigger insert_jsharmony_ucod2_h after insert on jsharmony_ucod2_h
begin
  update jsharmony_ucod2_h set 
    cod_h_eu     = (select context from jsharmony_meta limit 1),
    cod_h_etstmp = datetime('now','localtime'),
    cod_h_mu     = (select context from jsharmony_meta limit 1),
    cod_h_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;
end;
INSERT INTO jsharmony_ucod2_h (codename, codemean, codecodemean, codeattribmean, codeschema) VALUES ('country_state', 'Country - States', NULL, NULL, 'jsharmony');

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
create trigger insert_jsharmony_v after insert on jsharmony_v
begin
  update jsharmony_v set 
    v_eu     = (select context from jsharmony_meta limit 1),
    v_etstmp = datetime('now','localtime'),
    v_mu     = (select context from jsharmony_meta limit 1),
    v_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;
end;

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
create trigger insert_jsharmony_xpp after insert on jsharmony_xpp
begin
  update jsharmony_xpp set 
    xpp_eu     = (select context from jsharmony_meta limit 1),
    xpp_etstmp = datetime('now','localtime'),
    xpp_mu     = (select context from jsharmony_meta limit 1),
    xpp_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;
end;
INSERT INTO jsharmony_xpp (xpp_process, xpp_attrib, xpp_val) VALUES ('USERS', 'HASH_SEED_C', '');
INSERT INTO jsharmony_xpp (xpp_process, xpp_attrib, xpp_val) VALUES ('USERS', 'HASH_SEED_S', '');
INSERT INTO jsharmony_xpp (xpp_process, xpp_attrib, xpp_val) VALUES ('SQL', 'DSCOPE_DCTGR', 'gcod2_d_scope_d_ctgr');
INSERT INTO jsharmony_xpp (xpp_process, xpp_attrib, xpp_val) VALUES ('SQL', 'GETCID', 'get_c_id');
INSERT INTO jsharmony_xpp (xpp_process, xpp_attrib, xpp_val) VALUES ('SQL', 'GETEID', 'get_e_id');
INSERT INTO jsharmony_xpp (xpp_process, xpp_attrib, xpp_val) VALUES ('SYSTEM', 'CLIENT_SYS_URL', 'https://localhost');
INSERT INTO jsharmony_xpp (xpp_process, xpp_attrib, xpp_val) VALUES ('EMAIL', 'NOTIF_SYS', 'user@company.com');

/***************NUMBERS***************/
CREATE TABLE jsharmony_numbers (
  n integr NOT NULL,
  PRIMARY KEY (n)
);
INSERT INTO jsharmony_numbers (n) VALUES (1);
INSERT INTO jsharmony_numbers (n) VALUES (2);
INSERT INTO jsharmony_numbers (n) VALUES (3);
INSERT INTO jsharmony_numbers (n) VALUES (4);
INSERT INTO jsharmony_numbers (n) VALUES (5);
INSERT INTO jsharmony_numbers (n) VALUES (6);
INSERT INTO jsharmony_numbers (n) VALUES (7);
INSERT INTO jsharmony_numbers (n) VALUES (8);
INSERT INTO jsharmony_numbers (n) VALUES (9);
INSERT INTO jsharmony_numbers (n) VALUES (10);
INSERT INTO jsharmony_numbers (n) VALUES (11);
INSERT INTO jsharmony_numbers (n) VALUES (12);
INSERT INTO jsharmony_numbers (n) VALUES (13);
INSERT INTO jsharmony_numbers (n) VALUES (14);
INSERT INTO jsharmony_numbers (n) VALUES (15);
INSERT INTO jsharmony_numbers (n) VALUES (16);
INSERT INTO jsharmony_numbers (n) VALUES (17);
INSERT INTO jsharmony_numbers (n) VALUES (18);
INSERT INTO jsharmony_numbers (n) VALUES (19);
INSERT INTO jsharmony_numbers (n) VALUES (20);
INSERT INTO jsharmony_numbers (n) VALUES (21);
INSERT INTO jsharmony_numbers (n) VALUES (22);
INSERT INTO jsharmony_numbers (n) VALUES (23);
INSERT INTO jsharmony_numbers (n) VALUES (24);
INSERT INTO jsharmony_numbers (n) VALUES (25);
INSERT INTO jsharmony_numbers (n) VALUES (26);
INSERT INTO jsharmony_numbers (n) VALUES (27);
INSERT INTO jsharmony_numbers (n) VALUES (28);
INSERT INTO jsharmony_numbers (n) VALUES (29);
INSERT INTO jsharmony_numbers (n) VALUES (30);
INSERT INTO jsharmony_numbers (n) VALUES (31);
INSERT INTO jsharmony_numbers (n) VALUES (32);
INSERT INTO jsharmony_numbers (n) VALUES (33);
INSERT INTO jsharmony_numbers (n) VALUES (34);
INSERT INTO jsharmony_numbers (n) VALUES (35);
INSERT INTO jsharmony_numbers (n) VALUES (36);
INSERT INTO jsharmony_numbers (n) VALUES (37);
INSERT INTO jsharmony_numbers (n) VALUES (38);
INSERT INTO jsharmony_numbers (n) VALUES (39);
INSERT INTO jsharmony_numbers (n) VALUES (40);
INSERT INTO jsharmony_numbers (n) VALUES (41);
INSERT INTO jsharmony_numbers (n) VALUES (42);
INSERT INTO jsharmony_numbers (n) VALUES (43);
INSERT INTO jsharmony_numbers (n) VALUES (44);
INSERT INTO jsharmony_numbers (n) VALUES (45);
INSERT INTO jsharmony_numbers (n) VALUES (46);
INSERT INTO jsharmony_numbers (n) VALUES (47);
INSERT INTO jsharmony_numbers (n) VALUES (48);
INSERT INTO jsharmony_numbers (n) VALUES (49);
INSERT INTO jsharmony_numbers (n) VALUES (50);
INSERT INTO jsharmony_numbers (n) VALUES (51);
INSERT INTO jsharmony_numbers (n) VALUES (52);
INSERT INTO jsharmony_numbers (n) VALUES (53);
INSERT INTO jsharmony_numbers (n) VALUES (54);
INSERT INTO jsharmony_numbers (n) VALUES (55);
INSERT INTO jsharmony_numbers (n) VALUES (56);
INSERT INTO jsharmony_numbers (n) VALUES (57);
INSERT INTO jsharmony_numbers (n) VALUES (58);
INSERT INTO jsharmony_numbers (n) VALUES (59);
INSERT INTO jsharmony_numbers (n) VALUES (60);
INSERT INTO jsharmony_numbers (n) VALUES (61);
INSERT INTO jsharmony_numbers (n) VALUES (62);
INSERT INTO jsharmony_numbers (n) VALUES (63);
INSERT INTO jsharmony_numbers (n) VALUES (64);
INSERT INTO jsharmony_numbers (n) VALUES (65);
INSERT INTO jsharmony_numbers (n) VALUES (66);
INSERT INTO jsharmony_numbers (n) VALUES (67);
INSERT INTO jsharmony_numbers (n) VALUES (68);
INSERT INTO jsharmony_numbers (n) VALUES (69);
INSERT INTO jsharmony_numbers (n) VALUES (70);
INSERT INTO jsharmony_numbers (n) VALUES (71);
INSERT INTO jsharmony_numbers (n) VALUES (72);
INSERT INTO jsharmony_numbers (n) VALUES (73);
INSERT INTO jsharmony_numbers (n) VALUES (74);
INSERT INTO jsharmony_numbers (n) VALUES (75);
INSERT INTO jsharmony_numbers (n) VALUES (76);
INSERT INTO jsharmony_numbers (n) VALUES (77);
INSERT INTO jsharmony_numbers (n) VALUES (78);
INSERT INTO jsharmony_numbers (n) VALUES (79);
INSERT INTO jsharmony_numbers (n) VALUES (80);
INSERT INTO jsharmony_numbers (n) VALUES (81);
INSERT INTO jsharmony_numbers (n) VALUES (82);
INSERT INTO jsharmony_numbers (n) VALUES (83);
INSERT INTO jsharmony_numbers (n) VALUES (84);
INSERT INTO jsharmony_numbers (n) VALUES (85);
INSERT INTO jsharmony_numbers (n) VALUES (86);
INSERT INTO jsharmony_numbers (n) VALUES (87);
INSERT INTO jsharmony_numbers (n) VALUES (88);
INSERT INTO jsharmony_numbers (n) VALUES (89);
INSERT INTO jsharmony_numbers (n) VALUES (90);
INSERT INTO jsharmony_numbers (n) VALUES (91);
INSERT INTO jsharmony_numbers (n) VALUES (92);
INSERT INTO jsharmony_numbers (n) VALUES (93);
INSERT INTO jsharmony_numbers (n) VALUES (94);
INSERT INTO jsharmony_numbers (n) VALUES (95);
INSERT INTO jsharmony_numbers (n) VALUES (96);
INSERT INTO jsharmony_numbers (n) VALUES (97);
INSERT INTO jsharmony_numbers (n) VALUES (98);
INSERT INTO jsharmony_numbers (n) VALUES (99);
INSERT INTO jsharmony_numbers (n) VALUES (100);
INSERT INTO jsharmony_numbers (n) VALUES (101);
INSERT INTO jsharmony_numbers (n) VALUES (102);
INSERT INTO jsharmony_numbers (n) VALUES (103);
INSERT INTO jsharmony_numbers (n) VALUES (104);
INSERT INTO jsharmony_numbers (n) VALUES (105);
INSERT INTO jsharmony_numbers (n) VALUES (106);
INSERT INTO jsharmony_numbers (n) VALUES (107);
INSERT INTO jsharmony_numbers (n) VALUES (108);
INSERT INTO jsharmony_numbers (n) VALUES (109);
INSERT INTO jsharmony_numbers (n) VALUES (110);
INSERT INTO jsharmony_numbers (n) VALUES (111);
INSERT INTO jsharmony_numbers (n) VALUES (112);
INSERT INTO jsharmony_numbers (n) VALUES (113);
INSERT INTO jsharmony_numbers (n) VALUES (114);
INSERT INTO jsharmony_numbers (n) VALUES (115);
INSERT INTO jsharmony_numbers (n) VALUES (116);
INSERT INTO jsharmony_numbers (n) VALUES (117);
INSERT INTO jsharmony_numbers (n) VALUES (118);
INSERT INTO jsharmony_numbers (n) VALUES (119);
INSERT INTO jsharmony_numbers (n) VALUES (120);
INSERT INTO jsharmony_numbers (n) VALUES (121);
INSERT INTO jsharmony_numbers (n) VALUES (122);
INSERT INTO jsharmony_numbers (n) VALUES (123);
INSERT INTO jsharmony_numbers (n) VALUES (124);
INSERT INTO jsharmony_numbers (n) VALUES (125);
INSERT INTO jsharmony_numbers (n) VALUES (126);
INSERT INTO jsharmony_numbers (n) VALUES (127);
INSERT INTO jsharmony_numbers (n) VALUES (128);
INSERT INTO jsharmony_numbers (n) VALUES (129);
INSERT INTO jsharmony_numbers (n) VALUES (130);
INSERT INTO jsharmony_numbers (n) VALUES (131);
INSERT INTO jsharmony_numbers (n) VALUES (132);
INSERT INTO jsharmony_numbers (n) VALUES (133);
INSERT INTO jsharmony_numbers (n) VALUES (134);
INSERT INTO jsharmony_numbers (n) VALUES (135);
INSERT INTO jsharmony_numbers (n) VALUES (136);
INSERT INTO jsharmony_numbers (n) VALUES (137);
INSERT INTO jsharmony_numbers (n) VALUES (138);
INSERT INTO jsharmony_numbers (n) VALUES (139);
INSERT INTO jsharmony_numbers (n) VALUES (140);
INSERT INTO jsharmony_numbers (n) VALUES (141);
INSERT INTO jsharmony_numbers (n) VALUES (142);
INSERT INTO jsharmony_numbers (n) VALUES (143);
INSERT INTO jsharmony_numbers (n) VALUES (144);
INSERT INTO jsharmony_numbers (n) VALUES (145);
INSERT INTO jsharmony_numbers (n) VALUES (146);
INSERT INTO jsharmony_numbers (n) VALUES (147);
INSERT INTO jsharmony_numbers (n) VALUES (148);
INSERT INTO jsharmony_numbers (n) VALUES (149);
INSERT INTO jsharmony_numbers (n) VALUES (150);
INSERT INTO jsharmony_numbers (n) VALUES (151);
INSERT INTO jsharmony_numbers (n) VALUES (152);
INSERT INTO jsharmony_numbers (n) VALUES (153);
INSERT INTO jsharmony_numbers (n) VALUES (154);
INSERT INTO jsharmony_numbers (n) VALUES (155);
INSERT INTO jsharmony_numbers (n) VALUES (156);
INSERT INTO jsharmony_numbers (n) VALUES (157);
INSERT INTO jsharmony_numbers (n) VALUES (158);
INSERT INTO jsharmony_numbers (n) VALUES (159);
INSERT INTO jsharmony_numbers (n) VALUES (160);
INSERT INTO jsharmony_numbers (n) VALUES (161);
INSERT INTO jsharmony_numbers (n) VALUES (162);
INSERT INTO jsharmony_numbers (n) VALUES (163);
INSERT INTO jsharmony_numbers (n) VALUES (164);
INSERT INTO jsharmony_numbers (n) VALUES (165);
INSERT INTO jsharmony_numbers (n) VALUES (166);
INSERT INTO jsharmony_numbers (n) VALUES (167);
INSERT INTO jsharmony_numbers (n) VALUES (168);
INSERT INTO jsharmony_numbers (n) VALUES (169);
INSERT INTO jsharmony_numbers (n) VALUES (170);
INSERT INTO jsharmony_numbers (n) VALUES (171);
INSERT INTO jsharmony_numbers (n) VALUES (172);
INSERT INTO jsharmony_numbers (n) VALUES (173);
INSERT INTO jsharmony_numbers (n) VALUES (174);
INSERT INTO jsharmony_numbers (n) VALUES (175);
INSERT INTO jsharmony_numbers (n) VALUES (176);
INSERT INTO jsharmony_numbers (n) VALUES (177);
INSERT INTO jsharmony_numbers (n) VALUES (178);
INSERT INTO jsharmony_numbers (n) VALUES (179);
INSERT INTO jsharmony_numbers (n) VALUES (180);
INSERT INTO jsharmony_numbers (n) VALUES (181);
INSERT INTO jsharmony_numbers (n) VALUES (182);
INSERT INTO jsharmony_numbers (n) VALUES (183);
INSERT INTO jsharmony_numbers (n) VALUES (184);
INSERT INTO jsharmony_numbers (n) VALUES (185);
INSERT INTO jsharmony_numbers (n) VALUES (186);
INSERT INTO jsharmony_numbers (n) VALUES (187);
INSERT INTO jsharmony_numbers (n) VALUES (188);
INSERT INTO jsharmony_numbers (n) VALUES (189);
INSERT INTO jsharmony_numbers (n) VALUES (190);
INSERT INTO jsharmony_numbers (n) VALUES (191);
INSERT INTO jsharmony_numbers (n) VALUES (192);
INSERT INTO jsharmony_numbers (n) VALUES (193);
INSERT INTO jsharmony_numbers (n) VALUES (194);
INSERT INTO jsharmony_numbers (n) VALUES (195);
INSERT INTO jsharmony_numbers (n) VALUES (196);
INSERT INTO jsharmony_numbers (n) VALUES (197);
INSERT INTO jsharmony_numbers (n) VALUES (198);
INSERT INTO jsharmony_numbers (n) VALUES (199);
INSERT INTO jsharmony_numbers (n) VALUES (200);
INSERT INTO jsharmony_numbers (n) VALUES (201);
INSERT INTO jsharmony_numbers (n) VALUES (202);
INSERT INTO jsharmony_numbers (n) VALUES (203);
INSERT INTO jsharmony_numbers (n) VALUES (204);
INSERT INTO jsharmony_numbers (n) VALUES (205);
INSERT INTO jsharmony_numbers (n) VALUES (206);
INSERT INTO jsharmony_numbers (n) VALUES (207);
INSERT INTO jsharmony_numbers (n) VALUES (208);
INSERT INTO jsharmony_numbers (n) VALUES (209);
INSERT INTO jsharmony_numbers (n) VALUES (210);
INSERT INTO jsharmony_numbers (n) VALUES (211);
INSERT INTO jsharmony_numbers (n) VALUES (212);
INSERT INTO jsharmony_numbers (n) VALUES (213);
INSERT INTO jsharmony_numbers (n) VALUES (214);
INSERT INTO jsharmony_numbers (n) VALUES (215);
INSERT INTO jsharmony_numbers (n) VALUES (216);
INSERT INTO jsharmony_numbers (n) VALUES (217);
INSERT INTO jsharmony_numbers (n) VALUES (218);
INSERT INTO jsharmony_numbers (n) VALUES (219);
INSERT INTO jsharmony_numbers (n) VALUES (220);
INSERT INTO jsharmony_numbers (n) VALUES (221);
INSERT INTO jsharmony_numbers (n) VALUES (222);
INSERT INTO jsharmony_numbers (n) VALUES (223);
INSERT INTO jsharmony_numbers (n) VALUES (224);
INSERT INTO jsharmony_numbers (n) VALUES (225);
INSERT INTO jsharmony_numbers (n) VALUES (226);
INSERT INTO jsharmony_numbers (n) VALUES (227);
INSERT INTO jsharmony_numbers (n) VALUES (228);
INSERT INTO jsharmony_numbers (n) VALUES (229);
INSERT INTO jsharmony_numbers (n) VALUES (230);
INSERT INTO jsharmony_numbers (n) VALUES (231);
INSERT INTO jsharmony_numbers (n) VALUES (232);
INSERT INTO jsharmony_numbers (n) VALUES (233);
INSERT INTO jsharmony_numbers (n) VALUES (234);
INSERT INTO jsharmony_numbers (n) VALUES (235);
INSERT INTO jsharmony_numbers (n) VALUES (236);
INSERT INTO jsharmony_numbers (n) VALUES (237);
INSERT INTO jsharmony_numbers (n) VALUES (238);
INSERT INTO jsharmony_numbers (n) VALUES (239);
INSERT INTO jsharmony_numbers (n) VALUES (240);
INSERT INTO jsharmony_numbers (n) VALUES (241);
INSERT INTO jsharmony_numbers (n) VALUES (242);
INSERT INTO jsharmony_numbers (n) VALUES (243);
INSERT INTO jsharmony_numbers (n) VALUES (244);
INSERT INTO jsharmony_numbers (n) VALUES (245);
INSERT INTO jsharmony_numbers (n) VALUES (246);
INSERT INTO jsharmony_numbers (n) VALUES (247);
INSERT INTO jsharmony_numbers (n) VALUES (248);
INSERT INTO jsharmony_numbers (n) VALUES (249);
INSERT INTO jsharmony_numbers (n) VALUES (250);
INSERT INTO jsharmony_numbers (n) VALUES (251);
INSERT INTO jsharmony_numbers (n) VALUES (252);
INSERT INTO jsharmony_numbers (n) VALUES (253);
INSERT INTO jsharmony_numbers (n) VALUES (254);
INSERT INTO jsharmony_numbers (n) VALUES (255);
INSERT INTO jsharmony_numbers (n) VALUES (256);
INSERT INTO jsharmony_numbers (n) VALUES (257);
INSERT INTO jsharmony_numbers (n) VALUES (258);
INSERT INTO jsharmony_numbers (n) VALUES (259);
INSERT INTO jsharmony_numbers (n) VALUES (260);
INSERT INTO jsharmony_numbers (n) VALUES (261);
INSERT INTO jsharmony_numbers (n) VALUES (262);
INSERT INTO jsharmony_numbers (n) VALUES (263);
INSERT INTO jsharmony_numbers (n) VALUES (264);
INSERT INTO jsharmony_numbers (n) VALUES (265);
INSERT INTO jsharmony_numbers (n) VALUES (266);
INSERT INTO jsharmony_numbers (n) VALUES (267);
INSERT INTO jsharmony_numbers (n) VALUES (268);
INSERT INTO jsharmony_numbers (n) VALUES (269);
INSERT INTO jsharmony_numbers (n) VALUES (270);
INSERT INTO jsharmony_numbers (n) VALUES (271);
INSERT INTO jsharmony_numbers (n) VALUES (272);
INSERT INTO jsharmony_numbers (n) VALUES (273);
INSERT INTO jsharmony_numbers (n) VALUES (274);
INSERT INTO jsharmony_numbers (n) VALUES (275);
INSERT INTO jsharmony_numbers (n) VALUES (276);
INSERT INTO jsharmony_numbers (n) VALUES (277);
INSERT INTO jsharmony_numbers (n) VALUES (278);
INSERT INTO jsharmony_numbers (n) VALUES (279);
INSERT INTO jsharmony_numbers (n) VALUES (280);
INSERT INTO jsharmony_numbers (n) VALUES (281);
INSERT INTO jsharmony_numbers (n) VALUES (282);
INSERT INTO jsharmony_numbers (n) VALUES (283);
INSERT INTO jsharmony_numbers (n) VALUES (284);
INSERT INTO jsharmony_numbers (n) VALUES (285);
INSERT INTO jsharmony_numbers (n) VALUES (286);
INSERT INTO jsharmony_numbers (n) VALUES (287);
INSERT INTO jsharmony_numbers (n) VALUES (288);
INSERT INTO jsharmony_numbers (n) VALUES (289);
INSERT INTO jsharmony_numbers (n) VALUES (290);
INSERT INTO jsharmony_numbers (n) VALUES (291);
INSERT INTO jsharmony_numbers (n) VALUES (292);
INSERT INTO jsharmony_numbers (n) VALUES (293);
INSERT INTO jsharmony_numbers (n) VALUES (294);
INSERT INTO jsharmony_numbers (n) VALUES (295);
INSERT INTO jsharmony_numbers (n) VALUES (296);
INSERT INTO jsharmony_numbers (n) VALUES (297);
INSERT INTO jsharmony_numbers (n) VALUES (298);
INSERT INTO jsharmony_numbers (n) VALUES (299);
INSERT INTO jsharmony_numbers (n) VALUES (300);
INSERT INTO jsharmony_numbers (n) VALUES (301);
INSERT INTO jsharmony_numbers (n) VALUES (302);
INSERT INTO jsharmony_numbers (n) VALUES (303);
INSERT INTO jsharmony_numbers (n) VALUES (304);
INSERT INTO jsharmony_numbers (n) VALUES (305);
INSERT INTO jsharmony_numbers (n) VALUES (306);
INSERT INTO jsharmony_numbers (n) VALUES (307);
INSERT INTO jsharmony_numbers (n) VALUES (308);
INSERT INTO jsharmony_numbers (n) VALUES (309);
INSERT INTO jsharmony_numbers (n) VALUES (310);
INSERT INTO jsharmony_numbers (n) VALUES (311);
INSERT INTO jsharmony_numbers (n) VALUES (312);
INSERT INTO jsharmony_numbers (n) VALUES (313);
INSERT INTO jsharmony_numbers (n) VALUES (314);
INSERT INTO jsharmony_numbers (n) VALUES (315);
INSERT INTO jsharmony_numbers (n) VALUES (316);
INSERT INTO jsharmony_numbers (n) VALUES (317);
INSERT INTO jsharmony_numbers (n) VALUES (318);
INSERT INTO jsharmony_numbers (n) VALUES (319);
INSERT INTO jsharmony_numbers (n) VALUES (320);
INSERT INTO jsharmony_numbers (n) VALUES (321);
INSERT INTO jsharmony_numbers (n) VALUES (322);
INSERT INTO jsharmony_numbers (n) VALUES (323);
INSERT INTO jsharmony_numbers (n) VALUES (324);
INSERT INTO jsharmony_numbers (n) VALUES (325);
INSERT INTO jsharmony_numbers (n) VALUES (326);
INSERT INTO jsharmony_numbers (n) VALUES (327);
INSERT INTO jsharmony_numbers (n) VALUES (328);
INSERT INTO jsharmony_numbers (n) VALUES (329);
INSERT INTO jsharmony_numbers (n) VALUES (330);
INSERT INTO jsharmony_numbers (n) VALUES (331);
INSERT INTO jsharmony_numbers (n) VALUES (332);
INSERT INTO jsharmony_numbers (n) VALUES (333);
INSERT INTO jsharmony_numbers (n) VALUES (334);
INSERT INTO jsharmony_numbers (n) VALUES (335);
INSERT INTO jsharmony_numbers (n) VALUES (336);
INSERT INTO jsharmony_numbers (n) VALUES (337);
INSERT INTO jsharmony_numbers (n) VALUES (338);
INSERT INTO jsharmony_numbers (n) VALUES (339);
INSERT INTO jsharmony_numbers (n) VALUES (340);
INSERT INTO jsharmony_numbers (n) VALUES (341);
INSERT INTO jsharmony_numbers (n) VALUES (342);
INSERT INTO jsharmony_numbers (n) VALUES (343);
INSERT INTO jsharmony_numbers (n) VALUES (344);
INSERT INTO jsharmony_numbers (n) VALUES (345);
INSERT INTO jsharmony_numbers (n) VALUES (346);
INSERT INTO jsharmony_numbers (n) VALUES (347);
INSERT INTO jsharmony_numbers (n) VALUES (348);
INSERT INTO jsharmony_numbers (n) VALUES (349);
INSERT INTO jsharmony_numbers (n) VALUES (350);
INSERT INTO jsharmony_numbers (n) VALUES (351);
INSERT INTO jsharmony_numbers (n) VALUES (352);
INSERT INTO jsharmony_numbers (n) VALUES (353);
INSERT INTO jsharmony_numbers (n) VALUES (354);
INSERT INTO jsharmony_numbers (n) VALUES (355);
INSERT INTO jsharmony_numbers (n) VALUES (356);
INSERT INTO jsharmony_numbers (n) VALUES (357);
INSERT INTO jsharmony_numbers (n) VALUES (358);
INSERT INTO jsharmony_numbers (n) VALUES (359);
INSERT INTO jsharmony_numbers (n) VALUES (360);
INSERT INTO jsharmony_numbers (n) VALUES (361);
INSERT INTO jsharmony_numbers (n) VALUES (362);
INSERT INTO jsharmony_numbers (n) VALUES (363);
INSERT INTO jsharmony_numbers (n) VALUES (364);
INSERT INTO jsharmony_numbers (n) VALUES (365);
INSERT INTO jsharmony_numbers (n) VALUES (366);
INSERT INTO jsharmony_numbers (n) VALUES (367);
INSERT INTO jsharmony_numbers (n) VALUES (368);
INSERT INTO jsharmony_numbers (n) VALUES (369);
INSERT INTO jsharmony_numbers (n) VALUES (370);
INSERT INTO jsharmony_numbers (n) VALUES (371);
INSERT INTO jsharmony_numbers (n) VALUES (372);
INSERT INTO jsharmony_numbers (n) VALUES (373);
INSERT INTO jsharmony_numbers (n) VALUES (374);
INSERT INTO jsharmony_numbers (n) VALUES (375);
INSERT INTO jsharmony_numbers (n) VALUES (376);
INSERT INTO jsharmony_numbers (n) VALUES (377);
INSERT INTO jsharmony_numbers (n) VALUES (378);
INSERT INTO jsharmony_numbers (n) VALUES (379);
INSERT INTO jsharmony_numbers (n) VALUES (380);
INSERT INTO jsharmony_numbers (n) VALUES (381);
INSERT INTO jsharmony_numbers (n) VALUES (382);
INSERT INTO jsharmony_numbers (n) VALUES (383);
INSERT INTO jsharmony_numbers (n) VALUES (384);
INSERT INTO jsharmony_numbers (n) VALUES (385);
INSERT INTO jsharmony_numbers (n) VALUES (386);
INSERT INTO jsharmony_numbers (n) VALUES (387);
INSERT INTO jsharmony_numbers (n) VALUES (388);
INSERT INTO jsharmony_numbers (n) VALUES (389);
INSERT INTO jsharmony_numbers (n) VALUES (390);
INSERT INTO jsharmony_numbers (n) VALUES (391);
INSERT INTO jsharmony_numbers (n) VALUES (392);
INSERT INTO jsharmony_numbers (n) VALUES (393);
INSERT INTO jsharmony_numbers (n) VALUES (394);
INSERT INTO jsharmony_numbers (n) VALUES (395);
INSERT INTO jsharmony_numbers (n) VALUES (396);
INSERT INTO jsharmony_numbers (n) VALUES (397);
INSERT INTO jsharmony_numbers (n) VALUES (398);
INSERT INTO jsharmony_numbers (n) VALUES (399);
INSERT INTO jsharmony_numbers (n) VALUES (400);
INSERT INTO jsharmony_numbers (n) VALUES (401);
INSERT INTO jsharmony_numbers (n) VALUES (402);
INSERT INTO jsharmony_numbers (n) VALUES (403);
INSERT INTO jsharmony_numbers (n) VALUES (404);
INSERT INTO jsharmony_numbers (n) VALUES (405);
INSERT INTO jsharmony_numbers (n) VALUES (406);
INSERT INTO jsharmony_numbers (n) VALUES (407);
INSERT INTO jsharmony_numbers (n) VALUES (408);
INSERT INTO jsharmony_numbers (n) VALUES (409);
INSERT INTO jsharmony_numbers (n) VALUES (410);
INSERT INTO jsharmony_numbers (n) VALUES (411);
INSERT INTO jsharmony_numbers (n) VALUES (412);
INSERT INTO jsharmony_numbers (n) VALUES (413);
INSERT INTO jsharmony_numbers (n) VALUES (414);
INSERT INTO jsharmony_numbers (n) VALUES (415);
INSERT INTO jsharmony_numbers (n) VALUES (416);
INSERT INTO jsharmony_numbers (n) VALUES (417);
INSERT INTO jsharmony_numbers (n) VALUES (418);
INSERT INTO jsharmony_numbers (n) VALUES (419);
INSERT INTO jsharmony_numbers (n) VALUES (420);
INSERT INTO jsharmony_numbers (n) VALUES (421);
INSERT INTO jsharmony_numbers (n) VALUES (422);
INSERT INTO jsharmony_numbers (n) VALUES (423);
INSERT INTO jsharmony_numbers (n) VALUES (424);
INSERT INTO jsharmony_numbers (n) VALUES (425);
INSERT INTO jsharmony_numbers (n) VALUES (426);
INSERT INTO jsharmony_numbers (n) VALUES (427);
INSERT INTO jsharmony_numbers (n) VALUES (428);
INSERT INTO jsharmony_numbers (n) VALUES (429);
INSERT INTO jsharmony_numbers (n) VALUES (430);
INSERT INTO jsharmony_numbers (n) VALUES (431);
INSERT INTO jsharmony_numbers (n) VALUES (432);
INSERT INTO jsharmony_numbers (n) VALUES (433);
INSERT INTO jsharmony_numbers (n) VALUES (434);
INSERT INTO jsharmony_numbers (n) VALUES (435);
INSERT INTO jsharmony_numbers (n) VALUES (436);
INSERT INTO jsharmony_numbers (n) VALUES (437);
INSERT INTO jsharmony_numbers (n) VALUES (438);
INSERT INTO jsharmony_numbers (n) VALUES (439);
INSERT INTO jsharmony_numbers (n) VALUES (440);
INSERT INTO jsharmony_numbers (n) VALUES (441);
INSERT INTO jsharmony_numbers (n) VALUES (442);
INSERT INTO jsharmony_numbers (n) VALUES (443);
INSERT INTO jsharmony_numbers (n) VALUES (444);
INSERT INTO jsharmony_numbers (n) VALUES (445);
INSERT INTO jsharmony_numbers (n) VALUES (446);
INSERT INTO jsharmony_numbers (n) VALUES (447);
INSERT INTO jsharmony_numbers (n) VALUES (448);
INSERT INTO jsharmony_numbers (n) VALUES (449);
INSERT INTO jsharmony_numbers (n) VALUES (450);
INSERT INTO jsharmony_numbers (n) VALUES (451);
INSERT INTO jsharmony_numbers (n) VALUES (452);
INSERT INTO jsharmony_numbers (n) VALUES (453);
INSERT INTO jsharmony_numbers (n) VALUES (454);
INSERT INTO jsharmony_numbers (n) VALUES (455);
INSERT INTO jsharmony_numbers (n) VALUES (456);
INSERT INTO jsharmony_numbers (n) VALUES (457);
INSERT INTO jsharmony_numbers (n) VALUES (458);
INSERT INTO jsharmony_numbers (n) VALUES (459);
INSERT INTO jsharmony_numbers (n) VALUES (460);
INSERT INTO jsharmony_numbers (n) VALUES (461);
INSERT INTO jsharmony_numbers (n) VALUES (462);
INSERT INTO jsharmony_numbers (n) VALUES (463);
INSERT INTO jsharmony_numbers (n) VALUES (464);
INSERT INTO jsharmony_numbers (n) VALUES (465);
INSERT INTO jsharmony_numbers (n) VALUES (466);
INSERT INTO jsharmony_numbers (n) VALUES (467);
INSERT INTO jsharmony_numbers (n) VALUES (468);
INSERT INTO jsharmony_numbers (n) VALUES (469);
INSERT INTO jsharmony_numbers (n) VALUES (470);
INSERT INTO jsharmony_numbers (n) VALUES (471);
INSERT INTO jsharmony_numbers (n) VALUES (472);
INSERT INTO jsharmony_numbers (n) VALUES (473);
INSERT INTO jsharmony_numbers (n) VALUES (474);
INSERT INTO jsharmony_numbers (n) VALUES (475);
INSERT INTO jsharmony_numbers (n) VALUES (476);
INSERT INTO jsharmony_numbers (n) VALUES (477);
INSERT INTO jsharmony_numbers (n) VALUES (478);
INSERT INTO jsharmony_numbers (n) VALUES (479);
INSERT INTO jsharmony_numbers (n) VALUES (480);
INSERT INTO jsharmony_numbers (n) VALUES (481);
INSERT INTO jsharmony_numbers (n) VALUES (482);
INSERT INTO jsharmony_numbers (n) VALUES (483);
INSERT INTO jsharmony_numbers (n) VALUES (484);
INSERT INTO jsharmony_numbers (n) VALUES (485);
INSERT INTO jsharmony_numbers (n) VALUES (486);
INSERT INTO jsharmony_numbers (n) VALUES (487);
INSERT INTO jsharmony_numbers (n) VALUES (488);
INSERT INTO jsharmony_numbers (n) VALUES (489);
INSERT INTO jsharmony_numbers (n) VALUES (490);
INSERT INTO jsharmony_numbers (n) VALUES (491);
INSERT INTO jsharmony_numbers (n) VALUES (492);
INSERT INTO jsharmony_numbers (n) VALUES (493);
INSERT INTO jsharmony_numbers (n) VALUES (494);
INSERT INTO jsharmony_numbers (n) VALUES (495);
INSERT INTO jsharmony_numbers (n) VALUES (496);
INSERT INTO jsharmony_numbers (n) VALUES (497);
INSERT INTO jsharmony_numbers (n) VALUES (498);
INSERT INTO jsharmony_numbers (n) VALUES (499);
INSERT INTO jsharmony_numbers (n) VALUES (500);
INSERT INTO jsharmony_numbers (n) VALUES (501);
INSERT INTO jsharmony_numbers (n) VALUES (502);
INSERT INTO jsharmony_numbers (n) VALUES (503);
INSERT INTO jsharmony_numbers (n) VALUES (504);
INSERT INTO jsharmony_numbers (n) VALUES (505);
INSERT INTO jsharmony_numbers (n) VALUES (506);
INSERT INTO jsharmony_numbers (n) VALUES (507);
INSERT INTO jsharmony_numbers (n) VALUES (508);
INSERT INTO jsharmony_numbers (n) VALUES (509);
INSERT INTO jsharmony_numbers (n) VALUES (510);
INSERT INTO jsharmony_numbers (n) VALUES (511);
INSERT INTO jsharmony_numbers (n) VALUES (512);
INSERT INTO jsharmony_numbers (n) VALUES (513);
INSERT INTO jsharmony_numbers (n) VALUES (514);
INSERT INTO jsharmony_numbers (n) VALUES (515);
INSERT INTO jsharmony_numbers (n) VALUES (516);
INSERT INTO jsharmony_numbers (n) VALUES (517);
INSERT INTO jsharmony_numbers (n) VALUES (518);
INSERT INTO jsharmony_numbers (n) VALUES (519);
INSERT INTO jsharmony_numbers (n) VALUES (520);
INSERT INTO jsharmony_numbers (n) VALUES (521);
INSERT INTO jsharmony_numbers (n) VALUES (522);
INSERT INTO jsharmony_numbers (n) VALUES (523);
INSERT INTO jsharmony_numbers (n) VALUES (524);
INSERT INTO jsharmony_numbers (n) VALUES (525);
INSERT INTO jsharmony_numbers (n) VALUES (526);
INSERT INTO jsharmony_numbers (n) VALUES (527);
INSERT INTO jsharmony_numbers (n) VALUES (528);
INSERT INTO jsharmony_numbers (n) VALUES (529);
INSERT INTO jsharmony_numbers (n) VALUES (530);
INSERT INTO jsharmony_numbers (n) VALUES (531);
INSERT INTO jsharmony_numbers (n) VALUES (532);
INSERT INTO jsharmony_numbers (n) VALUES (533);
INSERT INTO jsharmony_numbers (n) VALUES (534);
INSERT INTO jsharmony_numbers (n) VALUES (535);
INSERT INTO jsharmony_numbers (n) VALUES (536);
INSERT INTO jsharmony_numbers (n) VALUES (537);
INSERT INTO jsharmony_numbers (n) VALUES (538);
INSERT INTO jsharmony_numbers (n) VALUES (539);
INSERT INTO jsharmony_numbers (n) VALUES (540);
INSERT INTO jsharmony_numbers (n) VALUES (541);
INSERT INTO jsharmony_numbers (n) VALUES (542);
INSERT INTO jsharmony_numbers (n) VALUES (543);
INSERT INTO jsharmony_numbers (n) VALUES (544);
INSERT INTO jsharmony_numbers (n) VALUES (545);
INSERT INTO jsharmony_numbers (n) VALUES (546);
INSERT INTO jsharmony_numbers (n) VALUES (547);
INSERT INTO jsharmony_numbers (n) VALUES (548);
INSERT INTO jsharmony_numbers (n) VALUES (549);
INSERT INTO jsharmony_numbers (n) VALUES (550);
INSERT INTO jsharmony_numbers (n) VALUES (551);
INSERT INTO jsharmony_numbers (n) VALUES (552);
INSERT INTO jsharmony_numbers (n) VALUES (553);
INSERT INTO jsharmony_numbers (n) VALUES (554);
INSERT INTO jsharmony_numbers (n) VALUES (555);
INSERT INTO jsharmony_numbers (n) VALUES (556);
INSERT INTO jsharmony_numbers (n) VALUES (557);
INSERT INTO jsharmony_numbers (n) VALUES (558);
INSERT INTO jsharmony_numbers (n) VALUES (559);
INSERT INTO jsharmony_numbers (n) VALUES (560);
INSERT INTO jsharmony_numbers (n) VALUES (561);
INSERT INTO jsharmony_numbers (n) VALUES (562);
INSERT INTO jsharmony_numbers (n) VALUES (563);
INSERT INTO jsharmony_numbers (n) VALUES (564);
INSERT INTO jsharmony_numbers (n) VALUES (565);
INSERT INTO jsharmony_numbers (n) VALUES (566);
INSERT INTO jsharmony_numbers (n) VALUES (567);
INSERT INTO jsharmony_numbers (n) VALUES (568);
INSERT INTO jsharmony_numbers (n) VALUES (569);
INSERT INTO jsharmony_numbers (n) VALUES (570);
INSERT INTO jsharmony_numbers (n) VALUES (571);
INSERT INTO jsharmony_numbers (n) VALUES (572);
INSERT INTO jsharmony_numbers (n) VALUES (573);
INSERT INTO jsharmony_numbers (n) VALUES (574);
INSERT INTO jsharmony_numbers (n) VALUES (575);
INSERT INTO jsharmony_numbers (n) VALUES (576);
INSERT INTO jsharmony_numbers (n) VALUES (577);
INSERT INTO jsharmony_numbers (n) VALUES (578);
INSERT INTO jsharmony_numbers (n) VALUES (579);
INSERT INTO jsharmony_numbers (n) VALUES (580);
INSERT INTO jsharmony_numbers (n) VALUES (581);
INSERT INTO jsharmony_numbers (n) VALUES (582);
INSERT INTO jsharmony_numbers (n) VALUES (583);
INSERT INTO jsharmony_numbers (n) VALUES (584);
INSERT INTO jsharmony_numbers (n) VALUES (585);
INSERT INTO jsharmony_numbers (n) VALUES (586);
INSERT INTO jsharmony_numbers (n) VALUES (587);
INSERT INTO jsharmony_numbers (n) VALUES (588);
INSERT INTO jsharmony_numbers (n) VALUES (589);
INSERT INTO jsharmony_numbers (n) VALUES (590);
INSERT INTO jsharmony_numbers (n) VALUES (591);
INSERT INTO jsharmony_numbers (n) VALUES (592);
INSERT INTO jsharmony_numbers (n) VALUES (593);
INSERT INTO jsharmony_numbers (n) VALUES (594);
INSERT INTO jsharmony_numbers (n) VALUES (595);
INSERT INTO jsharmony_numbers (n) VALUES (596);
INSERT INTO jsharmony_numbers (n) VALUES (597);
INSERT INTO jsharmony_numbers (n) VALUES (598);
INSERT INTO jsharmony_numbers (n) VALUES (599);
INSERT INTO jsharmony_numbers (n) VALUES (600);
INSERT INTO jsharmony_numbers (n) VALUES (601);
INSERT INTO jsharmony_numbers (n) VALUES (602);
INSERT INTO jsharmony_numbers (n) VALUES (603);
INSERT INTO jsharmony_numbers (n) VALUES (604);
INSERT INTO jsharmony_numbers (n) VALUES (605);
INSERT INTO jsharmony_numbers (n) VALUES (606);
INSERT INTO jsharmony_numbers (n) VALUES (607);
INSERT INTO jsharmony_numbers (n) VALUES (608);
INSERT INTO jsharmony_numbers (n) VALUES (609);
INSERT INTO jsharmony_numbers (n) VALUES (610);
INSERT INTO jsharmony_numbers (n) VALUES (611);
INSERT INTO jsharmony_numbers (n) VALUES (612);
INSERT INTO jsharmony_numbers (n) VALUES (613);
INSERT INTO jsharmony_numbers (n) VALUES (614);
INSERT INTO jsharmony_numbers (n) VALUES (615);
INSERT INTO jsharmony_numbers (n) VALUES (616);
INSERT INTO jsharmony_numbers (n) VALUES (617);
INSERT INTO jsharmony_numbers (n) VALUES (618);
INSERT INTO jsharmony_numbers (n) VALUES (619);
INSERT INTO jsharmony_numbers (n) VALUES (620);
INSERT INTO jsharmony_numbers (n) VALUES (621);
INSERT INTO jsharmony_numbers (n) VALUES (622);
INSERT INTO jsharmony_numbers (n) VALUES (623);
INSERT INTO jsharmony_numbers (n) VALUES (624);
INSERT INTO jsharmony_numbers (n) VALUES (625);
INSERT INTO jsharmony_numbers (n) VALUES (626);
INSERT INTO jsharmony_numbers (n) VALUES (627);
INSERT INTO jsharmony_numbers (n) VALUES (628);
INSERT INTO jsharmony_numbers (n) VALUES (629);
INSERT INTO jsharmony_numbers (n) VALUES (630);
INSERT INTO jsharmony_numbers (n) VALUES (631);
INSERT INTO jsharmony_numbers (n) VALUES (632);
INSERT INTO jsharmony_numbers (n) VALUES (633);
INSERT INTO jsharmony_numbers (n) VALUES (634);
INSERT INTO jsharmony_numbers (n) VALUES (635);
INSERT INTO jsharmony_numbers (n) VALUES (636);
INSERT INTO jsharmony_numbers (n) VALUES (637);
INSERT INTO jsharmony_numbers (n) VALUES (638);
INSERT INTO jsharmony_numbers (n) VALUES (639);
INSERT INTO jsharmony_numbers (n) VALUES (640);
INSERT INTO jsharmony_numbers (n) VALUES (641);
INSERT INTO jsharmony_numbers (n) VALUES (642);
INSERT INTO jsharmony_numbers (n) VALUES (643);
INSERT INTO jsharmony_numbers (n) VALUES (644);
INSERT INTO jsharmony_numbers (n) VALUES (645);
INSERT INTO jsharmony_numbers (n) VALUES (646);
INSERT INTO jsharmony_numbers (n) VALUES (647);
INSERT INTO jsharmony_numbers (n) VALUES (648);
INSERT INTO jsharmony_numbers (n) VALUES (649);
INSERT INTO jsharmony_numbers (n) VALUES (650);
INSERT INTO jsharmony_numbers (n) VALUES (651);
INSERT INTO jsharmony_numbers (n) VALUES (652);
INSERT INTO jsharmony_numbers (n) VALUES (653);
INSERT INTO jsharmony_numbers (n) VALUES (654);
INSERT INTO jsharmony_numbers (n) VALUES (655);
INSERT INTO jsharmony_numbers (n) VALUES (656);
INSERT INTO jsharmony_numbers (n) VALUES (657);
INSERT INTO jsharmony_numbers (n) VALUES (658);
INSERT INTO jsharmony_numbers (n) VALUES (659);
INSERT INTO jsharmony_numbers (n) VALUES (660);
INSERT INTO jsharmony_numbers (n) VALUES (661);
INSERT INTO jsharmony_numbers (n) VALUES (662);
INSERT INTO jsharmony_numbers (n) VALUES (663);
INSERT INTO jsharmony_numbers (n) VALUES (664);
INSERT INTO jsharmony_numbers (n) VALUES (665);
INSERT INTO jsharmony_numbers (n) VALUES (666);
INSERT INTO jsharmony_numbers (n) VALUES (667);
INSERT INTO jsharmony_numbers (n) VALUES (668);
INSERT INTO jsharmony_numbers (n) VALUES (669);
INSERT INTO jsharmony_numbers (n) VALUES (670);
INSERT INTO jsharmony_numbers (n) VALUES (671);
INSERT INTO jsharmony_numbers (n) VALUES (672);
INSERT INTO jsharmony_numbers (n) VALUES (673);
INSERT INTO jsharmony_numbers (n) VALUES (674);
INSERT INTO jsharmony_numbers (n) VALUES (675);
INSERT INTO jsharmony_numbers (n) VALUES (676);
INSERT INTO jsharmony_numbers (n) VALUES (677);
INSERT INTO jsharmony_numbers (n) VALUES (678);
INSERT INTO jsharmony_numbers (n) VALUES (679);
INSERT INTO jsharmony_numbers (n) VALUES (680);
INSERT INTO jsharmony_numbers (n) VALUES (681);
INSERT INTO jsharmony_numbers (n) VALUES (682);
INSERT INTO jsharmony_numbers (n) VALUES (683);
INSERT INTO jsharmony_numbers (n) VALUES (684);
INSERT INTO jsharmony_numbers (n) VALUES (685);
INSERT INTO jsharmony_numbers (n) VALUES (686);
INSERT INTO jsharmony_numbers (n) VALUES (687);
INSERT INTO jsharmony_numbers (n) VALUES (688);
INSERT INTO jsharmony_numbers (n) VALUES (689);
INSERT INTO jsharmony_numbers (n) VALUES (690);
INSERT INTO jsharmony_numbers (n) VALUES (691);
INSERT INTO jsharmony_numbers (n) VALUES (692);
INSERT INTO jsharmony_numbers (n) VALUES (693);
INSERT INTO jsharmony_numbers (n) VALUES (694);
INSERT INTO jsharmony_numbers (n) VALUES (695);
INSERT INTO jsharmony_numbers (n) VALUES (696);
INSERT INTO jsharmony_numbers (n) VALUES (697);
INSERT INTO jsharmony_numbers (n) VALUES (698);
INSERT INTO jsharmony_numbers (n) VALUES (699);
INSERT INTO jsharmony_numbers (n) VALUES (700);
INSERT INTO jsharmony_numbers (n) VALUES (701);
INSERT INTO jsharmony_numbers (n) VALUES (702);
INSERT INTO jsharmony_numbers (n) VALUES (703);
INSERT INTO jsharmony_numbers (n) VALUES (704);
INSERT INTO jsharmony_numbers (n) VALUES (705);
INSERT INTO jsharmony_numbers (n) VALUES (706);
INSERT INTO jsharmony_numbers (n) VALUES (707);
INSERT INTO jsharmony_numbers (n) VALUES (708);
INSERT INTO jsharmony_numbers (n) VALUES (709);
INSERT INTO jsharmony_numbers (n) VALUES (710);
INSERT INTO jsharmony_numbers (n) VALUES (711);
INSERT INTO jsharmony_numbers (n) VALUES (712);
INSERT INTO jsharmony_numbers (n) VALUES (713);
INSERT INTO jsharmony_numbers (n) VALUES (714);
INSERT INTO jsharmony_numbers (n) VALUES (715);
INSERT INTO jsharmony_numbers (n) VALUES (716);
INSERT INTO jsharmony_numbers (n) VALUES (717);
INSERT INTO jsharmony_numbers (n) VALUES (718);
INSERT INTO jsharmony_numbers (n) VALUES (719);
INSERT INTO jsharmony_numbers (n) VALUES (720);
INSERT INTO jsharmony_numbers (n) VALUES (721);
INSERT INTO jsharmony_numbers (n) VALUES (722);
INSERT INTO jsharmony_numbers (n) VALUES (723);
INSERT INTO jsharmony_numbers (n) VALUES (724);
INSERT INTO jsharmony_numbers (n) VALUES (725);
INSERT INTO jsharmony_numbers (n) VALUES (726);
INSERT INTO jsharmony_numbers (n) VALUES (727);
INSERT INTO jsharmony_numbers (n) VALUES (728);
INSERT INTO jsharmony_numbers (n) VALUES (729);
INSERT INTO jsharmony_numbers (n) VALUES (730);
INSERT INTO jsharmony_numbers (n) VALUES (731);
INSERT INTO jsharmony_numbers (n) VALUES (732);
INSERT INTO jsharmony_numbers (n) VALUES (733);
INSERT INTO jsharmony_numbers (n) VALUES (734);
INSERT INTO jsharmony_numbers (n) VALUES (735);
INSERT INTO jsharmony_numbers (n) VALUES (736);
INSERT INTO jsharmony_numbers (n) VALUES (737);
INSERT INTO jsharmony_numbers (n) VALUES (738);
INSERT INTO jsharmony_numbers (n) VALUES (739);
INSERT INTO jsharmony_numbers (n) VALUES (740);
INSERT INTO jsharmony_numbers (n) VALUES (741);
INSERT INTO jsharmony_numbers (n) VALUES (742);
INSERT INTO jsharmony_numbers (n) VALUES (743);
INSERT INTO jsharmony_numbers (n) VALUES (744);
INSERT INTO jsharmony_numbers (n) VALUES (745);
INSERT INTO jsharmony_numbers (n) VALUES (746);
INSERT INTO jsharmony_numbers (n) VALUES (747);
INSERT INTO jsharmony_numbers (n) VALUES (748);
INSERT INTO jsharmony_numbers (n) VALUES (749);
INSERT INTO jsharmony_numbers (n) VALUES (750);
INSERT INTO jsharmony_numbers (n) VALUES (751);
INSERT INTO jsharmony_numbers (n) VALUES (752);
INSERT INTO jsharmony_numbers (n) VALUES (753);
INSERT INTO jsharmony_numbers (n) VALUES (754);
INSERT INTO jsharmony_numbers (n) VALUES (755);
INSERT INTO jsharmony_numbers (n) VALUES (756);
INSERT INTO jsharmony_numbers (n) VALUES (757);
INSERT INTO jsharmony_numbers (n) VALUES (758);
INSERT INTO jsharmony_numbers (n) VALUES (759);
INSERT INTO jsharmony_numbers (n) VALUES (760);
INSERT INTO jsharmony_numbers (n) VALUES (761);
INSERT INTO jsharmony_numbers (n) VALUES (762);
INSERT INTO jsharmony_numbers (n) VALUES (763);
INSERT INTO jsharmony_numbers (n) VALUES (764);
INSERT INTO jsharmony_numbers (n) VALUES (765);
INSERT INTO jsharmony_numbers (n) VALUES (766);
INSERT INTO jsharmony_numbers (n) VALUES (767);
INSERT INTO jsharmony_numbers (n) VALUES (768);
INSERT INTO jsharmony_numbers (n) VALUES (769);
INSERT INTO jsharmony_numbers (n) VALUES (770);
INSERT INTO jsharmony_numbers (n) VALUES (771);
INSERT INTO jsharmony_numbers (n) VALUES (772);
INSERT INTO jsharmony_numbers (n) VALUES (773);
INSERT INTO jsharmony_numbers (n) VALUES (774);
INSERT INTO jsharmony_numbers (n) VALUES (775);
INSERT INTO jsharmony_numbers (n) VALUES (776);
INSERT INTO jsharmony_numbers (n) VALUES (777);
INSERT INTO jsharmony_numbers (n) VALUES (778);
INSERT INTO jsharmony_numbers (n) VALUES (779);
INSERT INTO jsharmony_numbers (n) VALUES (780);
INSERT INTO jsharmony_numbers (n) VALUES (781);
INSERT INTO jsharmony_numbers (n) VALUES (782);
INSERT INTO jsharmony_numbers (n) VALUES (783);
INSERT INTO jsharmony_numbers (n) VALUES (784);
INSERT INTO jsharmony_numbers (n) VALUES (785);
INSERT INTO jsharmony_numbers (n) VALUES (786);
INSERT INTO jsharmony_numbers (n) VALUES (787);
INSERT INTO jsharmony_numbers (n) VALUES (788);
INSERT INTO jsharmony_numbers (n) VALUES (789);
INSERT INTO jsharmony_numbers (n) VALUES (790);
INSERT INTO jsharmony_numbers (n) VALUES (791);
INSERT INTO jsharmony_numbers (n) VALUES (792);
INSERT INTO jsharmony_numbers (n) VALUES (793);
INSERT INTO jsharmony_numbers (n) VALUES (794);
INSERT INTO jsharmony_numbers (n) VALUES (795);
INSERT INTO jsharmony_numbers (n) VALUES (796);
INSERT INTO jsharmony_numbers (n) VALUES (797);
INSERT INTO jsharmony_numbers (n) VALUES (798);
INSERT INTO jsharmony_numbers (n) VALUES (799);
INSERT INTO jsharmony_numbers (n) VALUES (800);
INSERT INTO jsharmony_numbers (n) VALUES (801);
INSERT INTO jsharmony_numbers (n) VALUES (802);
INSERT INTO jsharmony_numbers (n) VALUES (803);
INSERT INTO jsharmony_numbers (n) VALUES (804);
INSERT INTO jsharmony_numbers (n) VALUES (805);
INSERT INTO jsharmony_numbers (n) VALUES (806);
INSERT INTO jsharmony_numbers (n) VALUES (807);
INSERT INTO jsharmony_numbers (n) VALUES (808);
INSERT INTO jsharmony_numbers (n) VALUES (809);
INSERT INTO jsharmony_numbers (n) VALUES (810);
INSERT INTO jsharmony_numbers (n) VALUES (811);
INSERT INTO jsharmony_numbers (n) VALUES (812);
INSERT INTO jsharmony_numbers (n) VALUES (813);
INSERT INTO jsharmony_numbers (n) VALUES (814);
INSERT INTO jsharmony_numbers (n) VALUES (815);
INSERT INTO jsharmony_numbers (n) VALUES (816);
INSERT INTO jsharmony_numbers (n) VALUES (817);
INSERT INTO jsharmony_numbers (n) VALUES (818);
INSERT INTO jsharmony_numbers (n) VALUES (819);
INSERT INTO jsharmony_numbers (n) VALUES (820);
INSERT INTO jsharmony_numbers (n) VALUES (821);
INSERT INTO jsharmony_numbers (n) VALUES (822);
INSERT INTO jsharmony_numbers (n) VALUES (823);
INSERT INTO jsharmony_numbers (n) VALUES (824);
INSERT INTO jsharmony_numbers (n) VALUES (825);
INSERT INTO jsharmony_numbers (n) VALUES (826);
INSERT INTO jsharmony_numbers (n) VALUES (827);
INSERT INTO jsharmony_numbers (n) VALUES (828);
INSERT INTO jsharmony_numbers (n) VALUES (829);
INSERT INTO jsharmony_numbers (n) VALUES (830);
INSERT INTO jsharmony_numbers (n) VALUES (831);
INSERT INTO jsharmony_numbers (n) VALUES (832);
INSERT INTO jsharmony_numbers (n) VALUES (833);
INSERT INTO jsharmony_numbers (n) VALUES (834);
INSERT INTO jsharmony_numbers (n) VALUES (835);
INSERT INTO jsharmony_numbers (n) VALUES (836);
INSERT INTO jsharmony_numbers (n) VALUES (837);
INSERT INTO jsharmony_numbers (n) VALUES (838);
INSERT INTO jsharmony_numbers (n) VALUES (839);
INSERT INTO jsharmony_numbers (n) VALUES (840);
INSERT INTO jsharmony_numbers (n) VALUES (841);
INSERT INTO jsharmony_numbers (n) VALUES (842);
INSERT INTO jsharmony_numbers (n) VALUES (843);
INSERT INTO jsharmony_numbers (n) VALUES (844);
INSERT INTO jsharmony_numbers (n) VALUES (845);
INSERT INTO jsharmony_numbers (n) VALUES (846);
INSERT INTO jsharmony_numbers (n) VALUES (847);
INSERT INTO jsharmony_numbers (n) VALUES (848);
INSERT INTO jsharmony_numbers (n) VALUES (849);
INSERT INTO jsharmony_numbers (n) VALUES (850);
INSERT INTO jsharmony_numbers (n) VALUES (851);
INSERT INTO jsharmony_numbers (n) VALUES (852);
INSERT INTO jsharmony_numbers (n) VALUES (853);
INSERT INTO jsharmony_numbers (n) VALUES (854);
INSERT INTO jsharmony_numbers (n) VALUES (855);
INSERT INTO jsharmony_numbers (n) VALUES (856);
INSERT INTO jsharmony_numbers (n) VALUES (857);
INSERT INTO jsharmony_numbers (n) VALUES (858);
INSERT INTO jsharmony_numbers (n) VALUES (859);
INSERT INTO jsharmony_numbers (n) VALUES (860);
INSERT INTO jsharmony_numbers (n) VALUES (861);
INSERT INTO jsharmony_numbers (n) VALUES (862);
INSERT INTO jsharmony_numbers (n) VALUES (863);
INSERT INTO jsharmony_numbers (n) VALUES (864);
INSERT INTO jsharmony_numbers (n) VALUES (865);
INSERT INTO jsharmony_numbers (n) VALUES (866);
INSERT INTO jsharmony_numbers (n) VALUES (867);
INSERT INTO jsharmony_numbers (n) VALUES (868);
INSERT INTO jsharmony_numbers (n) VALUES (869);
INSERT INTO jsharmony_numbers (n) VALUES (870);
INSERT INTO jsharmony_numbers (n) VALUES (871);
INSERT INTO jsharmony_numbers (n) VALUES (872);
INSERT INTO jsharmony_numbers (n) VALUES (873);
INSERT INTO jsharmony_numbers (n) VALUES (874);
INSERT INTO jsharmony_numbers (n) VALUES (875);
INSERT INTO jsharmony_numbers (n) VALUES (876);
INSERT INTO jsharmony_numbers (n) VALUES (877);
INSERT INTO jsharmony_numbers (n) VALUES (878);
INSERT INTO jsharmony_numbers (n) VALUES (879);
INSERT INTO jsharmony_numbers (n) VALUES (880);
INSERT INTO jsharmony_numbers (n) VALUES (881);
INSERT INTO jsharmony_numbers (n) VALUES (882);
INSERT INTO jsharmony_numbers (n) VALUES (883);
INSERT INTO jsharmony_numbers (n) VALUES (884);
INSERT INTO jsharmony_numbers (n) VALUES (885);
INSERT INTO jsharmony_numbers (n) VALUES (886);
INSERT INTO jsharmony_numbers (n) VALUES (887);
INSERT INTO jsharmony_numbers (n) VALUES (888);
INSERT INTO jsharmony_numbers (n) VALUES (889);
INSERT INTO jsharmony_numbers (n) VALUES (890);
INSERT INTO jsharmony_numbers (n) VALUES (891);
INSERT INTO jsharmony_numbers (n) VALUES (892);
INSERT INTO jsharmony_numbers (n) VALUES (893);
INSERT INTO jsharmony_numbers (n) VALUES (894);
INSERT INTO jsharmony_numbers (n) VALUES (895);
INSERT INTO jsharmony_numbers (n) VALUES (896);
INSERT INTO jsharmony_numbers (n) VALUES (897);
INSERT INTO jsharmony_numbers (n) VALUES (898);
INSERT INTO jsharmony_numbers (n) VALUES (899);
INSERT INTO jsharmony_numbers (n) VALUES (900);
INSERT INTO jsharmony_numbers (n) VALUES (901);
INSERT INTO jsharmony_numbers (n) VALUES (902);
INSERT INTO jsharmony_numbers (n) VALUES (903);
INSERT INTO jsharmony_numbers (n) VALUES (904);
INSERT INTO jsharmony_numbers (n) VALUES (905);
INSERT INTO jsharmony_numbers (n) VALUES (906);
INSERT INTO jsharmony_numbers (n) VALUES (907);
INSERT INTO jsharmony_numbers (n) VALUES (908);
INSERT INTO jsharmony_numbers (n) VALUES (909);
INSERT INTO jsharmony_numbers (n) VALUES (910);
INSERT INTO jsharmony_numbers (n) VALUES (911);
INSERT INTO jsharmony_numbers (n) VALUES (912);
INSERT INTO jsharmony_numbers (n) VALUES (913);
INSERT INTO jsharmony_numbers (n) VALUES (914);
INSERT INTO jsharmony_numbers (n) VALUES (915);
INSERT INTO jsharmony_numbers (n) VALUES (916);
INSERT INTO jsharmony_numbers (n) VALUES (917);
INSERT INTO jsharmony_numbers (n) VALUES (918);
INSERT INTO jsharmony_numbers (n) VALUES (919);
INSERT INTO jsharmony_numbers (n) VALUES (920);
INSERT INTO jsharmony_numbers (n) VALUES (921);
INSERT INTO jsharmony_numbers (n) VALUES (922);
INSERT INTO jsharmony_numbers (n) VALUES (923);
INSERT INTO jsharmony_numbers (n) VALUES (924);
INSERT INTO jsharmony_numbers (n) VALUES (925);
INSERT INTO jsharmony_numbers (n) VALUES (926);
INSERT INTO jsharmony_numbers (n) VALUES (927);
INSERT INTO jsharmony_numbers (n) VALUES (928);
INSERT INTO jsharmony_numbers (n) VALUES (929);
INSERT INTO jsharmony_numbers (n) VALUES (930);
INSERT INTO jsharmony_numbers (n) VALUES (931);
INSERT INTO jsharmony_numbers (n) VALUES (932);
INSERT INTO jsharmony_numbers (n) VALUES (933);
INSERT INTO jsharmony_numbers (n) VALUES (934);
INSERT INTO jsharmony_numbers (n) VALUES (935);
INSERT INTO jsharmony_numbers (n) VALUES (936);
INSERT INTO jsharmony_numbers (n) VALUES (937);
INSERT INTO jsharmony_numbers (n) VALUES (938);
INSERT INTO jsharmony_numbers (n) VALUES (939);
INSERT INTO jsharmony_numbers (n) VALUES (940);
INSERT INTO jsharmony_numbers (n) VALUES (941);
INSERT INTO jsharmony_numbers (n) VALUES (942);
INSERT INTO jsharmony_numbers (n) VALUES (943);
INSERT INTO jsharmony_numbers (n) VALUES (944);
INSERT INTO jsharmony_numbers (n) VALUES (945);
INSERT INTO jsharmony_numbers (n) VALUES (946);
INSERT INTO jsharmony_numbers (n) VALUES (947);
INSERT INTO jsharmony_numbers (n) VALUES (948);
INSERT INTO jsharmony_numbers (n) VALUES (949);
INSERT INTO jsharmony_numbers (n) VALUES (950);
INSERT INTO jsharmony_numbers (n) VALUES (951);
INSERT INTO jsharmony_numbers (n) VALUES (952);
INSERT INTO jsharmony_numbers (n) VALUES (953);
INSERT INTO jsharmony_numbers (n) VALUES (954);
INSERT INTO jsharmony_numbers (n) VALUES (955);
INSERT INTO jsharmony_numbers (n) VALUES (956);
INSERT INTO jsharmony_numbers (n) VALUES (957);
INSERT INTO jsharmony_numbers (n) VALUES (958);
INSERT INTO jsharmony_numbers (n) VALUES (959);
INSERT INTO jsharmony_numbers (n) VALUES (960);
INSERT INTO jsharmony_numbers (n) VALUES (961);
INSERT INTO jsharmony_numbers (n) VALUES (962);
INSERT INTO jsharmony_numbers (n) VALUES (963);
INSERT INTO jsharmony_numbers (n) VALUES (964);
INSERT INTO jsharmony_numbers (n) VALUES (965);
INSERT INTO jsharmony_numbers (n) VALUES (966);
INSERT INTO jsharmony_numbers (n) VALUES (967);
INSERT INTO jsharmony_numbers (n) VALUES (968);
INSERT INTO jsharmony_numbers (n) VALUES (969);
INSERT INTO jsharmony_numbers (n) VALUES (970);
INSERT INTO jsharmony_numbers (n) VALUES (971);
INSERT INTO jsharmony_numbers (n) VALUES (972);
INSERT INTO jsharmony_numbers (n) VALUES (973);
INSERT INTO jsharmony_numbers (n) VALUES (974);
INSERT INTO jsharmony_numbers (n) VALUES (975);
INSERT INTO jsharmony_numbers (n) VALUES (976);
INSERT INTO jsharmony_numbers (n) VALUES (977);
INSERT INTO jsharmony_numbers (n) VALUES (978);
INSERT INTO jsharmony_numbers (n) VALUES (979);
INSERT INTO jsharmony_numbers (n) VALUES (980);
INSERT INTO jsharmony_numbers (n) VALUES (981);
INSERT INTO jsharmony_numbers (n) VALUES (982);
INSERT INTO jsharmony_numbers (n) VALUES (983);
INSERT INTO jsharmony_numbers (n) VALUES (984);
INSERT INTO jsharmony_numbers (n) VALUES (985);
INSERT INTO jsharmony_numbers (n) VALUES (986);
INSERT INTO jsharmony_numbers (n) VALUES (987);
INSERT INTO jsharmony_numbers (n) VALUES (988);
INSERT INTO jsharmony_numbers (n) VALUES (989);
INSERT INTO jsharmony_numbers (n) VALUES (990);
INSERT INTO jsharmony_numbers (n) VALUES (991);
INSERT INTO jsharmony_numbers (n) VALUES (992);
INSERT INTO jsharmony_numbers (n) VALUES (993);
INSERT INTO jsharmony_numbers (n) VALUES (994);
INSERT INTO jsharmony_numbers (n) VALUES (995);
INSERT INTO jsharmony_numbers (n) VALUES (996);
INSERT INTO jsharmony_numbers (n) VALUES (997);
INSERT INTO jsharmony_numbers (n) VALUES (998);
INSERT INTO jsharmony_numbers (n) VALUES (999);

/***************VIEWS***************/

/***************V_PPP***************/
CREATE VIEW jsharmony_v_pp AS 
 SELECT ppd.ppd_process AS pp_process,
        ppd.ppd_attrib AS pp_attrib,
        CASE
            WHEN ppp.ppp_val IS NULL OR ppp.ppp_val = '' THEN
            CASE
                WHEN gpp.gpp_val IS NULL OR gpp.gpp_val = '' THEN xpp.xpp_val
                ELSE gpp.gpp_val
            END
            ELSE ppp.ppp_val
        END AS pp_val,
    ppp.pe_id
   FROM jsharmony_ppd ppd
     LEFT JOIN jsharmony_xpp xpp ON ppd.ppd_process = xpp.xpp_process AND ppd.ppd_attrib = xpp.xpp_attrib
     LEFT JOIN jsharmony_gpp gpp ON ppd.ppd_process = gpp.gpp_process AND ppd.ppd_attrib = gpp.gpp_attrib
     LEFT JOIN ( SELECT ppp_1.pe_id,
                        ppp_1.ppp_process,
                        ppp_1.ppp_attrib,
                        ppp_1.ppp_val
                   FROM jsharmony_ppp ppp_1
                  UNION
                 SELECT NULL AS pe_id,
                        ppp_null.ppp_process,
                        ppp_null.ppp_attrib,
                        NULL AS ppp_val
                   FROM jsharmony_ppp ppp_null) ppp ON ppd.ppd_process = ppp.ppp_process AND ppd.ppd_attrib = ppp.ppp_attrib;






end;