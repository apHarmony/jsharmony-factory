update jsharmony.xpp set XPP_VAL = '%%%INIT_DB_HASH_ADMIN%%%'
where xpp_process='USERS' and xpp_attrib='HASH_SEED_S';
update jsharmony.xpp set XPP_VAL = '%%%INIT_DB_HASH_CLIENT%%%'
where xpp_process='USERS' and xpp_attrib='HASH_SEED_C';
GO
insert into jsharmony.pe (pe_fname,pe_lname,pe_email,pe_pw1,pe_pw2)
values ('First','User','first.user@noemail.com','%%%INIT_DB_ADMIN_PASS%%%','%%%INIT_DB_ADMIN_PASS%%%');
insert into jsharmony.sper (pe_id, sr_name) values(1,'DEV');
insert into jsharmony.sper (pe_id, sr_name) values(1,'SYSADMIN');
GO

      
