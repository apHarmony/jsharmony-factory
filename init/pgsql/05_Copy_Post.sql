ALTER TABLE jsharmony.sm
  ADD CONSTRAINT sm_sm_id_parent_fkey FOREIGN KEY (sm_id_parent)
      REFERENCES jsharmony.sm (sm_id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;
insert into jsharmony.pe (pe_fname,pe_lname,pe_email,pe_pw1,pe_pw2)
values ('First','User','first.user@noemail.com','changeme','changeme');
insert into jsharmony.sper (pe_id, sr_name) values(1,'DEV');
insert into jsharmony.sper (pe_id, sr_name) values(1,'SYSADMIN');