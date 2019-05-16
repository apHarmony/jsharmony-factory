ALTER TABLE {{schema}}.sm
  ADD CONSTRAINT sm_sm_id_parent_fkey FOREIGN KEY (sm_id_parent)
      REFERENCES {{schema}}.sm (sm_id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

update {{schema}}.xpp set XPP_VAL = '%%%INIT_DB_HASH_MAIN%%%'
  where xpp_process='USERS' and xpp_attrib='HASH_SEED_S';

update {{schema}}.xpp set XPP_VAL = '%%%INIT_DB_HASH_CLIENT%%%'
  where xpp_process='USERS' and xpp_attrib='HASH_SEED_C';

insert into {{schema}}.pe (pe_fname,pe_lname,pe_email,pe_pw1,pe_pw2)
  values ('Admin','User','%%%INIT_DB_ADMIN_EMAIL%%%','%%%INIT_DB_ADMIN_PASS%%%','%%%INIT_DB_ADMIN_PASS%%%');

insert into {{schema}}.sper (pe_id, sr_name) values(1,'*');
insert into {{schema}}.sper (pe_id, sr_name) values(1,'DEV');
insert into {{schema}}.sper (pe_id, sr_name) values(1,'SYSADMIN');
insert into {{schema}}.sper (pe_id, sr_name) values(1,'DADMIN');
insert into {{schema}}.sper (pe_id, sr_name) values(1,'X_B');
insert into {{schema}}.sper (pe_id, sr_name) values(1,'X_X');

delete from {{schema}}.aud_d;
delete from {{schema}}.aud_h;

insert into {{schema}}.gcod2_d_scope_d_ctgr(codeval1, codeval2, codetxt) values ('PE','DOCUMENT','DOCUMENT');
insert into {{schema}}.gcod2_d_scope_d_ctgr(codeval1, codeval2, codetxt) values ('PE','IMAGE','IMAGE');
insert into {{schema}}.gcod2_d_scope_d_ctgr(codeval1, codeval2, codetxt) values ('PE','OTHER','OTHER');
