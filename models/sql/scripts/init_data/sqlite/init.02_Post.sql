
update {schema}_xpp set XPP_VAL = '%%%INIT_DB_HASH_MAIN%%%'
  where xpp_process='USERS' and xpp_attrib='HASH_SEED_S';
update {schema}_xpp set XPP_VAL = '%%%INIT_DB_HASH_CLIENT%%%'
  where xpp_process='USERS' and xpp_attrib='HASH_SEED_C';


insert into {schema}_pe (pe_fname,pe_lname,pe_email,pe_pw1,pe_pw2,
                          pe_startdt, pe_stsdt, pe_eu, pe_etstmp, pe_mu, pe_mtstmp)
  values ('Admin','User','%%%INIT_DB_ADMIN_EMAIL%%%','%%%INIT_DB_ADMIN_PASS%%%','%%%INIT_DB_ADMIN_PASS%%%',
          date('now','localtime'),datetime('now','localtime'),(select context from jsharmony_meta limit 1),datetime('now','localtime'),(select context from jsharmony_meta limit 1),datetime('now','localtime'));

insert into {schema}_sper (pe_id, sr_name) values(1,'*');
insert into {schema}_sper (pe_id, sr_name) values(1,'DEV');
insert into {schema}_sper (pe_id, sr_name) values(1,'SYSADMIN');
insert into {schema}.sper (pe_id, sr_name) values(1,'DADMIN');
insert into {schema}.sper (pe_id, sr_name) values(1,'X_B');
insert into {schema}.sper (pe_id, sr_name) values(1,'X_X');

delete from {schema}_aud_d;
delete from {schema}_aud_h;

insert into {schema}_gcod2_d_scope_d_ctgr(codeval1, codeval2, codetxt) values ('PE','DOCUMENT','DOCUMENT');
insert into {schema}_gcod2_d_scope_d_ctgr(codeval1, codeval2, codetxt) values ('PE','IMAGE','IMAGE');
insert into {schema}_gcod2_d_scope_d_ctgr(codeval1, codeval2, codetxt) values ('PE','OTHER','OTHER');
