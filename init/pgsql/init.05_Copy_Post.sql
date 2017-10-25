ALTER TABLE jsharmony.sm
  ADD CONSTRAINT sm_sm_id_parent_fkey FOREIGN KEY (sm_id_parent)
      REFERENCES jsharmony.sm (sm_id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;
update jsharmony.xpp set XPP_VAL = '%%%INIT_DB_HASH_ADMIN%%%'
where xpp_process='USERS' and xpp_attrib='HASH_SEED_S';
update jsharmony.xpp set XPP_VAL = '%%%INIT_DB_HASH_CLIENT%%%'
where xpp_process='USERS' and xpp_attrib='HASH_SEED_C';
insert into jsharmony.pe (pe_fname,pe_lname,pe_email,pe_pw1,pe_pw2)
values ('First','User','%%%INIT_DB_ADMIN_EMAIL%%%','%%%INIT_DB_ADMIN_PASS%%%','%%%INIT_DB_ADMIN_PASS%%%');
insert into jsharmony.sper (pe_id, sr_name) values(1,'*');
insert into jsharmony.sper (pe_id, sr_name) values(1,'DEV');
insert into jsharmony.sper (pe_id, sr_name) values(1,'SYSADMIN');
delete from jsharmony.aud_d;
delete from jsharmony.aud_h;