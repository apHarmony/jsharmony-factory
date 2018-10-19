
update jsharmony_xpp set XPP_VAL = '%%%INIT_DB_HASH_MAIN%%%'
  where xpp_process='USERS' and xpp_attrib='HASH_SEED_S';
update jsharmony_xpp set XPP_VAL = '%%%INIT_DB_HASH_CLIENT%%%'
  where xpp_process='USERS' and xpp_attrib='HASH_SEED_C';


insert into jsharmony_pe (pe_fname,pe_lname,pe_email,pe_pw1,pe_pw2,
                          pe_startdt, pe_stsdt, pe_eu, pe_etstmp, pe_mu, pe_mtstmp)
  values ('First','User','%%%INIT_DB_ADMIN_EMAIL%%%','%%%INIT_DB_ADMIN_PASS%%%','%%%INIT_DB_ADMIN_PASS%%%',
          date('now','localtime'),datetime('now','localtime'),(select context from jsharmony_meta limit 1),datetime('now','localtime'),(select context from jsharmony_meta limit 1),datetime('now','localtime'));

insert into jsharmony_sper (pe_id, sr_name) values(1,'*');
insert into jsharmony_sper (pe_id, sr_name) values(1,'DEV');
insert into jsharmony_sper (pe_id, sr_name) values(1,'SYSADMIN');
insert into jsharmony.sper (pe_id, sr_name) values(1,'DADMIN');
insert into jsharmony.sper (pe_id, sr_name) values(1,'X_B');
insert into jsharmony.sper (pe_id, sr_name) values(1,'X_X');

delete from jsharmony_aud_d;
delete from jsharmony_aud_h;

insert into jsharmony_gcod2_d_scope_d_ctgr(codeval1, codeval2, codetxt) values ('PE','DOCUMENT','DOCUMENT');
insert into jsharmony_gcod2_d_scope_d_ctgr(codeval1, codeval2, codetxt) values ('PE','IMAGE','IMAGE');
insert into jsharmony_gcod2_d_scope_d_ctgr(codeval1, codeval2, codetxt) values ('PE','OTHER','OTHER');
