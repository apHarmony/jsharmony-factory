pragma foreign_keys = ON;

begin;


/*********UCOD_AC*********/
%%%create_ucod("ac","jsharmony_")%%%
insert into jsharmony_ucod_ac (codseq, codeval, codetxt, codecode, codeattrib) VALUES (1, 'ACTIVE', 'Active', NULL, NULL);
insert into jsharmony_ucod_ac (codseq, codeval, codetxt, codecode, codeattrib) VALUES (3, 'CLOSED', 'Closed', NULL, NULL);

/*********UCOD_AC1*********/
%%%create_ucod("ac1","jsharmony_")%%%
insert into jsharmony_ucod_ac1 (codseq, codeval, codetxt, codecode, codeattrib) VALUES (1, 'A', 'Active', NULL, NULL);
insert into jsharmony_ucod_ac1 (codseq, codeval, codetxt, codecode, codeattrib) VALUES (2, 'C', 'Closed', NULL, NULL);

/*********UCOD_AHC*********/
%%%create_ucod("ahc","jsharmony_")%%%
insert into jsharmony_ucod_ahc (codseq, codeval, codetxt, codecode, codeattrib) VALUES (1, 'ACTIVE', 'Active', NULL, NULL);
insert into jsharmony_ucod_ahc (codseq, codeval, codetxt, codecode, codeattrib) VALUES (3, 'CLOSED', 'Closed', NULL, NULL);
insert into jsharmony_ucod_ahc (codseq, codeval, codetxt, codecode, codeattrib) VALUES (2, 'HOLD', 'Hold', NULL, NULL);

/*********UCOD_COUNTRY*********/
%%%create_ucod("country","jsharmony_")%%%
insert into jsharmony_ucod_country(codseq,codeval,codetxt,codecode,codeattrib) values (NULL,'USA','United States',NULL,NULL);
insert into jsharmony_ucod_country(codseq,codeval,codetxt,codecode,codeattrib) values (NULL,'CANADA','Canada',NULL,NULL);
insert into jsharmony_ucod_country(codseq,codeval,codetxt,codecode,codeattrib) values (NULL,'MEXICO','Mexico',NULL,NULL);

/*********UCOD_D_SCOPE*********/
%%%create_ucod("d_scope","jsharmony_")%%%
insert into jsharmony_ucod_d_scope (codseq, codeval, codetxt, codecode, codeattrib) VALUES (2, 'C', 'Customer', NULL, NULL);
insert into jsharmony_ucod_d_scope (codseq, codeval, codetxt, codecode, codeattrib) VALUES (1, 'S', 'System', NULL, NULL);
insert into jsharmony_ucod_d_scope (codseq, codeval, codetxt, codecode, codeattrib) VALUES (3, 'O', 'Order', NULL, NULL);
insert into jsharmony_ucod_d_scope (codseq, codeval, codetxt, codecode, codeattrib) VALUES (4, 'VEN', 'Vendor', NULL, NULL);
insert into jsharmony_ucod_d_scope (codseq, codeval, codetxt, codecode, codeattrib) VALUES (5, 'PE', 'User', NULL, NULL);


/*********UCOD_N_SCOPE*********/
%%%create_ucod("n_scope","jsharmony_")%%%
insert into jsharmony_ucod_n_scope (codseq, codeval, codetxt, codecode, codeattrib) VALUES (2, 'C', 'Customer', NULL, NULL);
insert into jsharmony_ucod_n_scope (codseq, codeval, codetxt, codecode, codeattrib) VALUES (1, 'S', 'System', NULL, NULL);
insert into jsharmony_ucod_n_scope (codseq, codeval, codetxt, codecode, codeattrib) VALUES (3, 'CT', 'Cust Contact', NULL, NULL);
insert into jsharmony_ucod_n_scope (codseq, codeval, codetxt, codecode, codeattrib) VALUES (4, 'VEN', 'Vendor', NULL, NULL);
insert into jsharmony_ucod_n_scope (codseq, codeval, codetxt, codecode, codeattrib) VALUES (5, 'PE', 'User', NULL, NULL);

/*********UCOD_N_TYPE*********/
%%%create_ucod("n_type","jsharmony_")%%%
insert into jsharmony_ucod_n_type (codseq, codeval, codetxt, codecode, codeattrib) VALUES (2, 'C', 'Client', NULL, NULL);
insert into jsharmony_ucod_n_type (codseq, codeval, codetxt, codecode, codeattrib) VALUES (3, 'S', 'System', NULL, NULL);
insert into jsharmony_ucod_n_type (codseq, codeval, codetxt, codecode, codeattrib) VALUES (1, 'U', 'User', NULL, NULL);

/*********UCOD_PPD_TYPE*********/
%%%create_ucod("ppd_type","jsharmony_")%%%
insert into jsharmony_ucod_ppd_type (codseq, codeval, codetxt, codecode, codeattrib) VALUES (NULL, 'C', 'Character', NULL, NULL);
insert into jsharmony_ucod_ppd_type (codseq, codeval, codetxt, codecode, codeattrib) VALUES (NULL, 'N', 'Number', NULL, NULL);

/*********UCOD_RQST_ATYPE*********/
%%%create_ucod("rqst_atype","jsharmony_")%%%
insert into jsharmony_ucod_rqst_atype (codseq, codeval, codetxt, codecode, codeattrib) VALUES (NULL, 'MESSAGE', 'Message', NULL, NULL);
insert into jsharmony_ucod_rqst_atype (codseq, codeval, codetxt, codecode, codeattrib) VALUES (NULL, 'REPORT', 'Report Program', NULL, NULL);

/*********UCOD_RQST_SOURCE*********/
%%%create_ucod("rqst_source","jsharmony_")%%%
insert into jsharmony_ucod_rqst_source (codseq, codeval, codetxt, codecode, codeattrib) VALUES (NULL, 'ADMIN', 'Administrator Interface', NULL, NULL);
insert into jsharmony_ucod_rqst_source (codseq, codeval, codetxt, codecode, codeattrib) VALUES (NULL, 'CLIENT', 'Client Interface', NULL, NULL);

/*********UCOD_TXT_TYPE*********/
%%%create_ucod("txt_type","jsharmony_")%%%
insert into jsharmony_ucod_txt_type (codseq, codeval, codetxt, codecode, codeattrib) VALUES (2, 'HTML', 'HTML', NULL, NULL);
insert into jsharmony_ucod_txt_type (codseq, codeval, codetxt, codecode, codeattrib) VALUES (1, 'TEXT', 'Text', NULL, NULL);

/*********UCOD_V_STS*********/
%%%create_ucod("v_sts","jsharmony_")%%%
insert into jsharmony_ucod_v_sts (codseq, codeval, codetxt, codecode, codeattrib) VALUES (2, 'ERROR', 'Error', NULL, NULL);
insert into jsharmony_ucod_v_sts (codseq, codeval, codetxt, codecode, codeattrib) VALUES (1, 'OK', 'OK', NULL, NULL);

/*********UCOD2_COUNTRY_STATE*********/
%%%create_ucod2("country_state","jsharmony_")%%%
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
  update jsharmony_meta set jsexec = '{ "function": "sha1", "table": "jsharmony_pe", "rowid": '||NEW.rowid||', "source":"pe_id||pe_pw1||(select PP_VAL from jsharmony.V_PP where PP_PROCESS=''USERS'' and PP_ATTRIB=''HASH_SEED_S'')", "dest":"pe_hash" }, { "function": "exec", "sql": "update jsharmony_pe set pe_pw1=null,pe_pw2=null where rowid='||NEW.rowid||'" }'\;
end;

create trigger update_jsharmony_pe after update on jsharmony_pe
begin
  select case when NEW.pe_stsdt is null then raise(FAIL,'pe_stsdt cannot be null') end\;
  select case when NEW.pe_id <> OLD.pe_id then raise(FAIL,'Cannot update identity') end\;
  --jsharmony_d exists error
  update jsharmony_pe set
    pe_stsdt  = case when NEW.pe_sts<>OLD.pe_sts then datetime('now','localtime') else NEW.pe_stsdt end,
    pe_mu     = (select context from jsharmony_meta limit 1),
    pe_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\; 
end;

insert into jsharmony_pe (pe_fname,pe_lname,pe_email,pe_pw1,pe_pw2)
  values ('aa','bb','%%%INIT_DB_ADMIN_EMAIL%%%','testtest','testtest');

select pe_pw1,pe_pw2,pe_hash from jsharmony_pe;

insert into jsharmony_pe (pe_fname,pe_lname,pe_email,pe_pw1,pe_pw2)
  values ('First','User','%%%INIT_DB_ADMIN_EMAIL%%%','%%%INIT_DB_ADMIN_PASS%%%','%%%INIT_DB_ADMIN_PASS%%%');

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
  CONSTRAINT ppd_ppd_process_ppd_attrib_key UNIQUE (ppd_process, ppd_attrib)
);
create trigger insert_jsharmony_ppd after insert on jsharmony_ppd
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
    CONSTRAINT unq_ucod_h UNIQUE (codename)
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

/***************V***************/
CREATE TABLE jsharmony_v (
    v_id integer primary key NOT NULL,
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
    FOREIGN KEY (v_sts) REFERENCES jsharmony_ucod_v_sts(codeval),
    CONSTRAINT v_v_no_key UNIQUE (v_no_major, v_no_minor, v_no_build, v_no_rev)
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






end;