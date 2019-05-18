/***************VIEWS***************/

/***************V_PPP***************/
CREATE VIEW {schema}_v_pp AS 
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
   FROM {schema}_ppd ppd
     LEFT JOIN {schema}_xpp xpp ON ppd.ppd_process = xpp.xpp_process AND ppd.ppd_attrib = xpp.xpp_attrib
     LEFT JOIN {schema}_gpp gpp ON ppd.ppd_process = gpp.gpp_process AND ppd.ppd_attrib = gpp.gpp_attrib
     LEFT JOIN ( SELECT ppp_1.pe_id,
                        ppp_1.ppp_process,
                        ppp_1.ppp_attrib,
                        ppp_1.ppp_val
                   FROM {schema}_ppp ppp_1
                  UNION
                 SELECT NULL AS pe_id,
                        ppp_null.ppp_process,
                        ppp_null.ppp_attrib,
                        NULL AS ppp_val
                   FROM {schema}_ppp ppp_null) ppp ON ppd.ppd_process = ppp.ppp_process AND ppd.ppd_attrib = ppp.ppp_attrib;

/***************V_HOUSE***************/
CREATE VIEW {schema}_v_house AS
 SELECT name.pp_val AS house_name,
    addr.pp_val AS house_addr,
    city.pp_val AS house_city,
    state.pp_val AS house_state,
    zip.pp_val AS house_zip,
    (((((((COALESCE(addr.pp_val, '')) || ', ') || (COALESCE(city.pp_val, ''))) || ' ') || (COALESCE(state.pp_val, ''))) || ' ') || (COALESCE(zip.pp_val, ''))) AS house_full_addr,
    bphone.pp_val AS house_bphone,
    fax.pp_val AS house_fax,
    email.pp_val AS house_email,
    contact.pp_val AS house_contact
   FROM ((((((((({schema}_dual
     LEFT JOIN {schema}_v_pp name ON ((((name.pp_process) = 'HOUSE') AND ((name.pp_attrib) = 'NAME'))))
     LEFT JOIN {schema}_v_pp addr ON ((((addr.pp_process) = 'HOUSE') AND ((addr.pp_attrib) = 'ADDR'))))
     LEFT JOIN {schema}_v_pp city ON ((((city.pp_process) = 'HOUSE') AND ((city.pp_attrib) = 'CITY'))))
     LEFT JOIN {schema}_v_pp state ON ((((state.pp_process) = 'HOUSE') AND ((state.pp_attrib) = 'STATE'))))
     LEFT JOIN {schema}_v_pp zip ON ((((zip.pp_process) = 'HOUSE') AND ((zip.pp_attrib) = 'ZIP'))))
     LEFT JOIN {schema}_v_pp bphone ON ((((bphone.pp_process) = 'HOUSE') AND ((bphone.pp_attrib) = 'BPHONE'))))
     LEFT JOIN {schema}_v_pp fax ON ((((fax.pp_process) = 'HOUSE') AND ((fax.pp_attrib) = 'FAX'))))
     LEFT JOIN {schema}_v_pp email ON ((((email.pp_process) = 'HOUSE') AND ((email.pp_attrib) = 'EMAIL'))))
     LEFT JOIN {schema}_v_pp contact ON ((((contact.pp_process) = 'HOUSE') AND ((contact.pp_attrib) = 'CONTACT'))));


/***************ucod2_gpp_process_attrib_v***************/
CREATE VIEW {schema}_ucod2_gpp_process_attrib_v AS
 SELECT null AS codseq,
    ppd.ppd_process AS codeval1,
    ppd.ppd_attrib AS codeval2,
    ppd.ppd_desc AS codetxt,
    null AS codecode,
    null codetdt,
    null AS codetcm,
    null AS cod_etstmp,
    null AS cod_eu,
    null AS cod_mtstmp,
    null AS cod_mu,
    null AS cod_snotes,
    null AS cod_notes
   FROM {schema}_ppd ppd
  WHERE ppd.ppd_gpp;

/***************ucod2_ppp_process_attrib_v***************/
CREATE VIEW {schema}_ucod2_ppp_process_attrib_v AS
 SELECT null AS codseq,
    ppd.ppd_process AS codeval1,
    ppd.ppd_attrib AS codeval2,
    ppd.ppd_desc AS codetxt,
    null AS codecode,
    null AS codetdt,
    null AS codetcm,
    null AS cod_etstmp,
    null AS cod_eu,
    null AS cod_mtstmp,
    null AS cod_mu,
    null AS cod_snotes,
    null AS cod_notes
   FROM {schema}_ppd ppd
  WHERE ppd.ppd_ppp;

/***************ucod2_xpp_process_attrib_v***************/
CREATE VIEW {schema}_ucod2_xpp_process_attrib_v AS
 SELECT null AS codseq,
    ppd.ppd_process AS codeval1,
    ppd.ppd_attrib AS codeval2,
    ppd.ppd_desc AS codetxt,
    null AS codecode,
    null codetdt,
    null AS codetcm,
    null AS cod_etstmp,
    null AS cod_eu,
    null AS cod_mtstmp,
    null AS cod_mu,
    null AS cod_snotes,
    null AS cod_notes
   FROM {schema}_ppd ppd
  WHERE ppd.ppd_xpp;

/***************ucod_gpp_process_v***************/
CREATE VIEW {schema}_ucod_gpp_process_v AS
 SELECT DISTINCT null AS codseq,
    ppd.ppd_process AS codeval,
    ppd.ppd_process AS codetxt,
    null AS codecode,
    null AS codetdt,
    null AS codetcm
   FROM {schema}_ppd ppd
  WHERE ppd.ppd_gpp;

/***************ucod_ppp_process_v***************/
CREATE VIEW {schema}_ucod_ppp_process_v AS
 SELECT DISTINCT null AS codseq,
    ppd.ppd_process AS codeval,
    ppd.ppd_process AS codetxt,
    null AS codecode,
    null AS codetdt,
    null AS codetcm
   FROM {schema}_ppd ppd
  WHERE ppd.ppd_ppp;

/***************ucod_xpp_process_v***************/
CREATE VIEW {schema}_ucod_xpp_process_v AS
 SELECT DISTINCT null AS codseq,
    ppd.ppd_process AS codeval,
    ppd.ppd_process AS codetxt,
    null AS codecode,
    null AS codetdt,
    null AS codetcm
   FROM {schema}_ppd ppd
  WHERE ppd.ppd_xpp;

/***************v_audl_raw***************/
CREATE VIEW {schema}_v_audl_raw AS
 SELECT aud_h.aud_seq,
    aud_h.c_id,
    aud_h.e_id,
    aud_h.table_name,
    aud_h.table_id,
    aud_h.aud_op,
    aud_h.aud_u,
    {schema}.mycuser_fmt(aud_h.aud_u) AS pe_name,
    aud_h.db_k,
    aud_h.aud_tstmp,
    aud_h.ref_name,
    aud_h.ref_id,
    aud_h.subj,
    aud_d.column_name,
    aud_d.column_val
   FROM ({schema}_aud_h aud_h
     LEFT JOIN {schema}_aud_d aud_d ON ((aud_h.aud_seq = aud_d.aud_seq)));

/***************v_cper_nostar***************/
CREATE VIEW {schema}_v_cper_nostar AS
 SELECT cper.pe_id,
    cper.cper_snotes,
    cper.cper_id,
    cper.cr_name,
    cper.rowid rowid
   FROM {schema}_cper cper
  WHERE (cper.cr_name <> 'C*');

create trigger {schema}_v_cper_nostar_insert instead of insert on {schema}_v_cper_nostar
begin
  insert into {schema}_cper(pe_id,cper_snotes,cr_name) values (new.pe_id,new.cper_snotes,new.cr_name)\;
  update jsharmony_meta set extra_changes=extra_changes+1, last_insert_rowid_override=last_insert_rowid()\;
end;

create trigger {schema}_v_cper_nostar_update instead of update on {schema}_v_cper_nostar
begin
  update {schema}_cper set pe_id = new.pe_id, cper_snotes = new.cper_snotes, cr_name = new.cr_name where cper_id=new.cper_id\;
  update jsharmony_meta set extra_changes=extra_changes+1\;
end;

create trigger {schema}_v_cper_nostar_delete instead of delete on {schema}_v_cper_nostar
begin
  delete from {schema}_cper where cper_id = old.cper_id\;
  update jsharmony_meta set extra_changes=extra_changes+1\;
end;

/***************v_crmsel***************/
CREATE VIEW {schema}_v_crmsel AS
 SELECT crm.crm_id,
    COALESCE(dual.dual_text, '') AS new_cr_name,
    dual.dual_integer AS new_sm_id,
        CASE
            WHEN (crm.crm_id IS NULL) THEN 0
            ELSE 1
        END AS crmsel_sel,
    m.cr_name,
    m.cr_seq,
    m.cr_sts,
    m.cr_desc,
    m.cr_id,
    m.sm_id_auto,
    m.sm_utype,
    m.sm_id,
    m.sm_sts,
    m.sm_id_parent,
    m.sm_name,
    m.sm_seq,
    m.sm_desc,
    m.sm_descl,
    m.sm_descvl,
    m.sm_cmd,
    m.sm_image,
    m.sm_snotes,
    m.sm_subcmd
   FROM ((( SELECT cr.cr_name,
            cr.cr_seq,
            cr.cr_sts,
            cr.cr_desc,
            cr.cr_id,
            sm.sm_id_auto,
            sm.sm_utype,
            sm.sm_id,
            sm.sm_sts,
            sm.sm_id_parent,
            sm.sm_name,
            sm.sm_seq,
            sm.sm_desc,
            sm.sm_descl,
            sm.sm_descvl,
            sm.sm_cmd,
            sm.sm_image,
            sm.sm_snotes,
            sm.sm_subcmd
           FROM ({schema}_cr cr
             LEFT JOIN {schema}_sm sm ON ((sm.sm_utype = 'C')))) m
     JOIN {schema}_dual dual ON ((1 = 1)))
     LEFT JOIN {schema}_crm crm ON (((crm.cr_name = m.cr_name) AND (crm.sm_id = m.sm_id))));

create trigger {schema}_v_crmsel_update instead of update on {schema}_v_crmsel
begin
  delete from {schema}_crm where crm_id=new.crm_id and (%%%NONEQUAL("NEW.crmsel_sel","OLD.crmsel_sel")%%%) and coalesce(new.crmsel_sel,0)=0\;
  insert into {schema}_crm (cr_name, sm_id)
    select new.new_cr_name, new.sm_id where (%%%NONEQUAL("NEW.crmsel_sel","OLD.crmsel_sel")%%%) and coalesce(new.crmsel_sel,0)=1 and coalesce(new.new_cr_name,'')<>''\;
  insert into {schema}_crm (cr_name, sm_id)
    select new.cr_name, new.new_sm_id where (%%%NONEQUAL("NEW.crmsel_sel","OLD.crmsel_sel")%%%) and coalesce(new.crmsel_sel,0)=1 and coalesce(new.new_cr_name,'')=''\;
  update jsharmony_meta set extra_changes=extra_changes+1
    where (%%%NONEQUAL("NEW.crmsel_sel","OLD.crmsel_sel")%%%)\;
end;

/***************v_dl***************/
CREATE VIEW {schema}_v_dl AS
 SELECT d.d_id,
    d.d_scope,
    d.d_scope_id,
    d.c_id,
    d.e_id,
    d.d_sts,
    d.d_ctgr,
    gdd.codetxt AS d_ctgr_txt,
    d.d_desc,
    d.d_ext,
    d.d_size,
    ('D' || (d.d_id) || COALESCE(d.d_ext, '')) AS d_filename,
    d.d_etstmp,
    d.d_eu,
    {schema}.mycuser_fmt(d.d_eu) AS d_eu_fmt,
    d.d_mtstmp,
    d.d_mu,
    {schema}.mycuser_fmt(d.d_mu) AS d_mu_fmt,
    d.d_utstmp,
    d.d_uu,
    {schema}.mycuser_fmt(d.d_uu) AS d_uu_fmt,
    d.d_snotes,
    NULL AS title_h,
    NULL AS title_b
   FROM ({schema}_d d
     LEFT JOIN {schema}_gcod2_d_scope_d_ctgr gdd ON (((gdd.codeval1 = d.d_scope) AND (gdd.codeval2 = d.d_ctgr))));

/***************v_d_ext***************/
CREATE VIEW {schema}_v_d_ext AS
 SELECT d.d_id,
    d.d_scope,
    d.d_scope_id,
    d.c_id,
    d.e_id,
    d.d_sts,
    d.d_ctgr,
    d.d_desc,
    d.d_ext,
    d.d_size,
    ('D' || d.d_id || COALESCE(d.d_ext, '')) AS d_filename,
    d.d_etstmp,
    d.d_eu,
    {schema}.mycuser_fmt(d.d_eu) AS d_eu_fmt,
    d.d_mtstmp,
    d.d_mu,
    {schema}.mycuser_fmt(d.d_mu) AS d_mu_fmt,
    d.d_utstmp,
    d.d_uu,
    {schema}.mycuser_fmt(d.d_uu) AS d_uu_fmt,
    d.d_snotes,
    null AS title_h,
    null AS title_b,
    d.d_scope AS d_lock,
    null AS c_name,
    null AS c_name_ext,
    null AS e_name,
    d.rowid rowid
   FROM {schema}_d d;

create trigger {schema}_v_d_ext_insert instead of insert on {schema}_v_d_ext
begin
  insert into {schema}_d(d_scope, d_scope_id, d_sts, c_id, e_id, d_ctgr, d_desc, d_ext, d_size, d_etstmp, d_eu, d_mtstmp, d_mu, d_utstmp, d_uu, d_snotes)
                    values (coalesce(new.d_scope,'S'), coalesce(new.d_scope_id,0), coalesce(new.d_sts,'A'), new.c_id, new.e_id, new.d_ctgr, new.d_desc, new.d_ext, new.d_size, new.d_etstmp, new.d_eu, new.d_mtstmp, new.d_mu, new.d_utstmp, new.d_uu, new.d_snotes)\;
  update jsharmony_meta set extra_changes=extra_changes+1, last_insert_rowid_override=last_insert_rowid()\;
end;

create trigger {schema}_v_d_ext_update instead of update on {schema}_v_d_ext
begin
  update {schema}_d set d_scope = new.d_scope, d_scope_id = new.d_scope_id, d_sts = new.d_sts,
                           c_id = new.c_id, e_id = new.e_id, d_ctgr = new.d_ctgr, d_desc = new.d_desc,
                           d_ext = new.d_ext, d_size = new.d_size,
                           d_etstmp = new.d_etstmp,d_eu = new.d_eu, d_mtstmp = new.d_mtstmp, d_mu = new.d_mu,
                           d_utstmp = new.d_utstmp, d_uu = new.d_uu, d_snotes =  new.d_snotes
                           where d_id=new.d_id\;
  update jsharmony_meta set extra_changes=extra_changes+1\;
end;

create trigger {schema}_v_d_ext_delete instead of delete on {schema}_v_d_ext
begin
  delete from {schema}_d where d_id = old.d_id\;
  update jsharmony_meta set extra_changes=extra_changes+1\;
end;

/***************v_d_x***************/
CREATE VIEW {schema}_v_d_x AS
 SELECT d.d_id,
    d.d_scope,
    d.d_scope_id,
    d.c_id,
    d.e_id,
    d.d_sts,
    d.d_ctgr,
    d.d_desc,
    d.d_ext,
    d.d_size,
    d.d_etstmp,
    d.d_eu,
    d.d_mtstmp,
    d.d_mu,
    d.d_utstmp,
    d.d_uu,
    d.d_synctstmp,
    d.d_snotes,
    d.d_id_main,
    ('D' || d.d_id || COALESCE(d.d_ext, '')) AS d_filename
   FROM {schema}_d d;

/***************v_gppl***************/
CREATE VIEW {schema}_v_gppl AS
 SELECT gpp.gpp_id,
    gpp.gpp_process,
    gpp.gpp_attrib,
    gpp.gpp_val,
    gpp.gpp_etstmp,
    gpp.gpp_eu,
    gpp.gpp_mtstmp,
    gpp.gpp_mu,
    {schema}.get_ppd_desc(gpp.gpp_process, gpp.gpp_attrib) AS ppd_desc,
    {schema}.audit_info(gpp.gpp_etstmp, gpp.gpp_eu, gpp.gpp_mtstmp, gpp.gpp_mu) AS gpp_info,
    gpp.rowid rowid
   FROM {schema}_gpp gpp;

create trigger {schema}_v_gppl_insert instead of insert on {schema}_v_gppl
begin
  insert into {schema}_gpp(gpp_process, gpp_attrib, gpp_val, gpp_etstmp, gpp_eu, gpp_mtstmp, gpp_mu)
                    values (new.gpp_process, new.gpp_attrib, new.gpp_val, new.gpp_etstmp, new.gpp_eu, new.gpp_mtstmp, new.gpp_mu)\;
  update jsharmony_meta set extra_changes=extra_changes+1, last_insert_rowid_override=last_insert_rowid()\;
end;

create trigger {schema}_v_gppl_update instead of update on {schema}_v_gppl
begin
  update {schema}_gpp set gpp_process = new.gpp_process, gpp_attrib = new.gpp_attrib, gpp_val = new.gpp_val,
                           gpp_etstmp = new.gpp_etstmp,gpp_eu = new.gpp_eu, gpp_mtstmp = new.gpp_mtstmp, gpp_mu = new.gpp_mu
                           where gpp_id=new.gpp_id\;
  update jsharmony_meta set extra_changes=extra_changes+1\;
end;

create trigger {schema}_v_gppl_delete instead of delete on {schema}_v_gppl
begin
  delete from {schema}_gpp where gpp_id = old.gpp_id\;
  update jsharmony_meta set extra_changes=extra_changes+1\;
end;

/***************v_months***************/
CREATE VIEW {schema}_v_months AS
 SELECT numbers.{number_val} {month_val},
    substr(('0' || numbers.{number_val}), -2, 2) AS {month_txt}
   FROM {schema}_numbers numbers
  WHERE (numbers.{number_val} <= 12);

/***************v_mype***************/
CREATE VIEW {schema}_v_mype AS
 SELECT {schema}.mype() AS mype;

/***************v_my_roles***************/
CREATE VIEW {schema}_v_my_roles AS
 SELECT sper.sr_name
   FROM {schema}_sper sper
  WHERE (sper.pe_id = {schema}.mype());

/***************v_nl***************/
CREATE VIEW {schema}_v_nl AS
 SELECT n.n_id,
    n.n_scope,
    n.n_scope_id,
    n.n_sts,
    n.c_id,
    null AS c_name,
    null AS c_name_ext,
    n.e_id,
    null AS e_name,
    n.n_type,
    n.n_note,
    {schema}.mytodate(n.n_etstmp) AS n_dt,
    n.n_etstmp,
    n.n_eu,
    {schema}.mycuser_fmt(n.n_eu) AS n_eu_fmt,
    n.n_mtstmp,
    n.n_mu,
    {schema}.mycuser_fmt(n.n_mu) AS n_mu_fmt,
    n.n_snotes,
    null AS title_h,
    null AS title_b
   FROM {schema}_n n;

/***************v_n_ext***************/
CREATE VIEW {schema}_v_n_ext AS
 SELECT n.n_id,
    n.n_scope,
    n.n_scope_id,
    n.n_sts,
    n.c_id,
    n.e_id,
    n.n_type,
    n.n_note,
    n.n_etstmp,
    n.n_eu,
    {schema}.mycuser_fmt(n.n_eu) AS n_eu_fmt,
    n.n_mtstmp,
    n.n_mu,
    {schema}.mycuser_fmt(n.n_mu) AS n_mu_fmt,
    n.n_snotes,
    null AS title_h,
    null AS title_b,
    null AS c_name,
    null AS c_name_ext,
    null AS e_name,
    n.rowid rowid
   FROM {schema}_n n;

create trigger {schema}_v_n_ext_insert instead of insert on {schema}_v_n_ext
begin
  insert into {schema}_n(n_scope, n_scope_id, n_sts, c_id, e_id, n_type, n_note, n_etstmp, n_eu, n_mtstmp, n_mu, n_snotes)
                    values (coalesce(new.n_scope,'S'), coalesce(new.n_scope_id,0), coalesce(new.n_sts,'A'), new.c_id, new.e_id, new.n_type, new.n_note, new.n_etstmp, new.n_eu, new.n_mtstmp, new.n_mu, new.n_snotes)\;
  update jsharmony_meta set extra_changes=extra_changes+1, last_insert_rowid_override=last_insert_rowid()\;
end;

create trigger {schema}_v_n_ext_update instead of update on {schema}_v_n_ext
begin
  update {schema}_n set n_scope = new.n_scope, n_scope_id = new.n_scope_id, n_sts = new.n_sts,
                           c_id = new.c_id, e_id = new.e_id, n_type = new.n_type, n_note = new.n_note,
                           n_etstmp = new.n_etstmp,n_eu = new.n_eu, n_mtstmp = new.n_mtstmp, n_mu = new.n_mu,
                           n_snotes =  new.n_snotes
                           where n_id=new.n_id\;
  update jsharmony_meta set extra_changes=extra_changes+1\;
end;

create trigger {schema}_v_n_ext_delete instead of delete on {schema}_v_n_ext
begin
  delete from {schema}_n where n_id = old.n_id\;
  update jsharmony_meta set extra_changes=extra_changes+1\;
end;

/***************v_ppdl***************/
CREATE VIEW {schema}_v_ppdl AS
 SELECT ppd.ppd_id,
    ppd.ppd_process,
    ppd.ppd_attrib,
    ppd.ppd_desc,
    ppd.ppd_type,
    ppd.codename,
    ppd.ppd_gpp,
    ppd.ppd_ppp,
    ppd.ppd_xpp,
    ppd.ppd_etstmp,
    ppd.ppd_eu,
    ppd.ppd_mtstmp,
    ppd.ppd_mu,
    ppd.ppd_snotes,
    {schema}.audit_info(ppd.ppd_etstmp, ppd.ppd_eu, ppd.ppd_mtstmp, ppd.ppd_mu) AS ppd_info,
    ppd.rowid rowid
   FROM {schema}_ppd ppd;

create trigger {schema}_v_ppdl_insert instead of insert on {schema}_v_ppdl
begin
  insert into {schema}_ppd(ppd_process, ppd_attrib, ppd_desc, ppd_type, codename, ppd_gpp, ppd_ppp, ppd_xpp, ppd_etstmp, ppd_eu, ppd_mtstmp, ppd_mu, ppd_snotes)
                    values (new.ppd_process, new.ppd_attrib, new.ppd_desc, new.ppd_type, new.codename, coalesce(new.ppd_gpp,0), coalesce(new.ppd_ppp,0), coalesce(new.ppd_xpp,0), new.ppd_etstmp, new.ppd_eu, new.ppd_mtstmp, new.ppd_mu, new.ppd_snotes)\;
  update jsharmony_meta set extra_changes=extra_changes+1, last_insert_rowid_override=last_insert_rowid()\;
end;

create trigger {schema}_v_ppdl_update instead of update on {schema}_v_ppdl
begin
  update {schema}_ppd set ppd_process = new.ppd_process, ppd_attrib = new.ppd_attrib, ppd_desc = new.ppd_desc,
                           ppd_type = new.ppd_type, codename = new.codename, 
                           ppd_gpp = new.ppd_gpp, ppd_ppp = new.ppd_ppp, ppd_xpp = new.ppd_xpp, 
                           ppd_etstmp = new.ppd_etstmp,ppd_eu = new.ppd_eu, ppd_mtstmp = new.ppd_mtstmp, ppd_mu = new.ppd_mu,
                           ppd_snotes = new.ppd_snotes where ppd_id=new.ppd_id\;
  update jsharmony_meta set extra_changes=extra_changes+1\;
end;

create trigger {schema}_v_ppdl_delete instead of delete on {schema}_v_ppdl
begin
  delete from {schema}_ppd where ppd_id = old.ppd_id\;
  update jsharmony_meta set extra_changes=extra_changes+1\;
end;

/***************v_pppl***************/
CREATE VIEW {schema}_v_pppl AS
 SELECT ppp.ppp_id,
    ppp.pe_id,
    ppp.ppp_process,
    ppp.ppp_attrib,
    ppp.ppp_val,
    ppp.ppp_etstmp,
    ppp.ppp_eu,
    ppp.ppp_mtstmp,
    ppp.ppp_mu,
    {schema}.get_ppd_desc(ppp.ppp_process, ppp.ppp_attrib) AS ppd_desc,
    {schema}.audit_info(ppp.ppp_etstmp, ppp.ppp_eu, ppp.ppp_mtstmp, ppp.ppp_mu) AS ppp_info,
    ppp.rowid rowid
   FROM {schema}_ppp ppp;

create trigger {schema}_v_pppl_insert instead of insert on {schema}_v_pppl
begin
  insert into {schema}_ppp(pe_id, ppp_process, ppp_attrib, ppp_val, ppp_etstmp, ppp_eu, ppp_mtstmp, ppp_mu)
                    values (new.pe_id, new.ppp_process, new.ppp_attrib, new.ppp_val, new.ppp_etstmp, new.ppp_eu, new.ppp_mtstmp, new.ppp_mu)\;
  update jsharmony_meta set extra_changes=extra_changes+1, last_insert_rowid_override=last_insert_rowid()\;
end;

create trigger {schema}_v_pppl_update instead of update on {schema}_v_pppl
begin
  update {schema}_ppp set pe_id = new.pe_id, ppp_process = new.ppp_process, ppp_attrib = new.ppp_attrib, ppp_val = new.ppp_val,
                           ppp_etstmp = new.ppp_etstmp,ppp_eu = new.ppp_eu, ppp_mtstmp = new.ppp_mtstmp, ppp_mu = new.ppp_mu
                           where ppp_id=new.ppp_id\;
  update jsharmony_meta set extra_changes=extra_changes+1\;
end;

create trigger {schema}_v_pppl_delete instead of delete on {schema}_v_pppl
begin
  delete from {schema}_ppp where ppp_id = old.ppp_id\;
  update jsharmony_meta set extra_changes=extra_changes+1\;
end;

/***************v_srmsel***************/
CREATE VIEW {schema}_v_srmsel AS
 SELECT srm.srm_id,
    COALESCE(dual.dual_text, '') AS new_sr_name,
    dual.dual_integer AS new_sm_id,
        CASE
            WHEN (srm.srm_id IS NULL) THEN 0
            ELSE 1
        END AS srmsel_sel,
    m.sr_name,
    m.sr_seq,
    m.sr_sts,
    m.sr_desc,
    m.sr_id,
    m.sm_id_auto,
    m.sm_utype,
    m.sm_id,
    m.sm_sts,
    m.sm_id_parent,
    m.sm_name,
    m.sm_seq,
    m.sm_desc,
    m.sm_descl,
    m.sm_descvl,
    m.sm_cmd,
    m.sm_image,
    m.sm_snotes,
    m.sm_subcmd
   FROM ((( SELECT sr.sr_name,
            sr.sr_seq,
            sr.sr_sts,
            sr.sr_desc,
            sr.sr_id,
            sm.sm_id_auto,
            sm.sm_utype,
            sm.sm_id,
            sm.sm_sts,
            sm.sm_id_parent,
            sm.sm_name,
            sm.sm_seq,
            sm.sm_desc,
            sm.sm_descl,
            sm.sm_descvl,
            sm.sm_cmd,
            sm.sm_image,
            sm.sm_snotes,
            sm.sm_subcmd
           FROM ({schema}_sr sr
             LEFT JOIN {schema}_sm sm ON (sm.sm_utype = 'S'))) m
     JOIN {schema}_dual dual ON (1 = 1))
     LEFT JOIN {schema}_srm srm ON (((srm.sr_name = m.sr_name) AND (srm.sm_id = m.sm_id))));

create trigger {schema}_v_srmsel_update instead of update on {schema}_v_srmsel
begin
  delete from {schema}_srm where srm_id=new.srm_id and (%%%NONEQUAL("NEW.srmsel_sel","OLD.srmsel_sel")%%%) and coalesce(new.srmsel_sel,0)=0\;
  insert into {schema}_srm (sr_name, sm_id)
    select new.new_sr_name, new.sm_id where (%%%NONEQUAL("NEW.srmsel_sel","OLD.srmsel_sel")%%%) and coalesce(new.srmsel_sel,0)=1 and coalesce(new.new_sr_name,'')<>''\;
  insert into {schema}_srm (sr_name, sm_id)
    select new.sr_name, new.new_sm_id where (%%%NONEQUAL("NEW.srmsel_sel","OLD.srmsel_sel")%%%) and coalesce(new.srmsel_sel,0)=1 and coalesce(new.new_sr_name,'')=''\;
  update jsharmony_meta set extra_changes=extra_changes+1
    where (%%%NONEQUAL("NEW.srmsel_sel","OLD.srmsel_sel")%%%)\;
end;

/***************v_xppl***************/
CREATE VIEW {schema}_v_xppl AS
 SELECT xpp.xpp_id,
    xpp.xpp_process,
    xpp.xpp_attrib,
    xpp.xpp_val,
    xpp.xpp_etstmp,
    xpp.xpp_eu,
    xpp.xpp_mtstmp,
    xpp.xpp_mu,
    {schema}.get_ppd_desc(xpp.xpp_process, xpp.xpp_attrib) AS ppd_desc,
    {schema}.audit_info(xpp.xpp_etstmp, xpp.xpp_eu, xpp.xpp_mtstmp, xpp.xpp_mu) AS xpp_info,
    xpp.rowid rowid
   FROM {schema}_xpp xpp;

create trigger {schema}_v_xppl_insert instead of insert on {schema}_v_xppl
begin
  insert into {schema}_xpp(xpp_process, xpp_attrib, xpp_val, xpp_etstmp, xpp_eu, xpp_mtstmp, xpp_mu)
                    values (new.xpp_process, new.xpp_attrib, new.xpp_val, new.xpp_etstmp, new.xpp_eu, new.xpp_mtstmp, new.xpp_mu)\;
  update jsharmony_meta set extra_changes=extra_changes+1, last_insert_rowid_override=last_insert_rowid()\;
end;

create trigger {schema}_v_xppl_update instead of update on {schema}_v_xppl
begin
  update {schema}_xpp set xpp_process = new.xpp_process, xpp_attrib = new.xpp_attrib, xpp_val = new.xpp_val,
                           xpp_etstmp = new.xpp_etstmp,xpp_eu = new.xpp_eu, xpp_mtstmp = new.xpp_mtstmp, xpp_mu = new.xpp_mu
                           where xpp_id=new.xpp_id\;
  update jsharmony_meta set extra_changes=extra_changes+1\;
end;

create trigger {schema}_v_xppl_delete instead of delete on {schema}_v_xppl
begin
  delete from {schema}_xpp where xpp_id = old.xpp_id\;
  update jsharmony_meta set extra_changes=extra_changes+1\;
end;

/***************v_years***************/
CREATE VIEW {schema}_v_years AS
 SELECT ((cast(strftime('%Y',{schema}.mynow()) as int) + numbers.{number_val}) - 1) AS {year_val}
   FROM {schema}_numbers numbers
  WHERE (numbers.{number_val} <= 10);
