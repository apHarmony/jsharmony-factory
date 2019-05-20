/***************VIEWS***************/

/***************{version}_{param_user}***************/
CREATE VIEW {schema}_{v_param_cur} AS 
 SELECT {param}.{param_process} AS {param_cur_process},
        {param}.{param_attrib} AS {param_cur_attrib},
        CASE
            WHEN {param_user}.{param_user_val} IS NULL OR {param_user}.{param_user_val} = '' THEN
            CASE
                WHEN {param_app}.{param_app_val} IS NULL OR {param_app}.{param_app_val} = '' THEN {param_sys}.{param_sys_val}
                ELSE {param_app}.{param_app_val}
            END
            ELSE {param_user}.{param_user_val}
        END AS {param_cur_val},
    {param_user}.{sys_user_id}
   FROM {schema}_{param} {param}
     LEFT JOIN {schema}_{param_sys} {param_sys} ON {param}.{param_process} = {param_sys}.{param_sys_process} AND {param}.{param_attrib} = {param_sys}.{param_sys_attrib}
     LEFT JOIN {schema}_{param_app} {param_app} ON {param}.{param_process} = {param_app}.{param_app_process} AND {param}.{param_attrib} = {param_app}.{param_app_attrib}
     LEFT JOIN ( SELECT {param_user}_1.{sys_user_id},
                        {param_user}_1.{param_user_process},
                        {param_user}_1.{param_user_attrib},
                        {param_user}_1.{param_user_val}
                   FROM {schema}_{param_user} {param_user}_1
                  UNION
                 SELECT NULL AS {sys_user_id},
                        {param_user}_null.{param_user_process},
                        {param_user}_null.{param_user_attrib},
                        NULL AS {param_user_val}
                   FROM {schema}_{param_user} {param_user}_null) {param_user} ON {param}.{param_process} = {param_user}.{param_user_process} AND {param}.{param_attrib} = {param_user}.{param_user_attrib};

/***************{v_app_info}***************/
CREATE VIEW {schema}_{v_app_info} AS
 SELECT name.{param_cur_val} AS {app_name},
    addr.{param_cur_val} AS {app_addr},
    city.{param_cur_val} AS {app_city},
    state.{param_cur_val} AS {app_state},
    zip.{param_cur_val} AS {app_zip},
    (((((((COALESCE(addr.{param_cur_val}, '')) || ', ') || (COALESCE(city.{param_cur_val}, ''))) || ' ') || (COALESCE(state.{param_cur_val}, ''))) || ' ') || (COALESCE(zip.{param_cur_val}, ''))) AS {app_full_addr},
    bphone.{param_cur_val} AS {app_bphone},
    fax.{param_cur_val} AS {app_fax},
    email.{param_cur_val} AS {app_email},
    contact.{param_cur_val} AS {app_contact}
   FROM ((((((((({schema}_{single}
     LEFT JOIN {schema}_{v_param_cur} name ON ((((name.{param_cur_process}) = 'HOUSE') AND ((name.{param_cur_attrib}) = 'NAME'))))
     LEFT JOIN {schema}_{v_param_cur} addr ON ((((addr.{param_cur_process}) = 'HOUSE') AND ((addr.{param_cur_attrib}) = 'ADDR'))))
     LEFT JOIN {schema}_{v_param_cur} city ON ((((city.{param_cur_process}) = 'HOUSE') AND ((city.{param_cur_attrib}) = 'CITY'))))
     LEFT JOIN {schema}_{v_param_cur} state ON ((((state.{param_cur_process}) = 'HOUSE') AND ((state.{param_cur_attrib}) = 'STATE'))))
     LEFT JOIN {schema}_{v_param_cur} zip ON ((((zip.{param_cur_process}) = 'HOUSE') AND ((zip.{param_cur_attrib}) = 'ZIP'))))
     LEFT JOIN {schema}_{v_param_cur} bphone ON ((((bphone.{param_cur_process}) = 'HOUSE') AND ((bphone.{param_cur_attrib}) = 'BPHONE'))))
     LEFT JOIN {schema}_{v_param_cur} fax ON ((((fax.{param_cur_process}) = 'HOUSE') AND ((fax.{param_cur_attrib}) = 'FAX'))))
     LEFT JOIN {schema}_{v_param_cur} email ON ((((email.{param_cur_process}) = 'HOUSE') AND ((email.{param_cur_attrib}) = 'EMAIL'))))
     LEFT JOIN {schema}_{v_param_cur} contact ON ((((contact.{param_cur_process}) = 'HOUSE') AND ((contact.{param_cur_attrib}) = 'CONTACT'))));


/***************{code2_param_app_attrib}***************/
CREATE VIEW {schema}_{code2_param_app_attrib} AS
 SELECT null AS {code_seq},
    {param}.{param_process} AS {code_val1},
    {param}.{param_attrib} AS {code_va12},
    {param}.{param_desc} AS {code_txt},
    null AS {code_code},
    null {code_end_dt},
    null AS {code_end_reason},
    null AS {code_etstmp},
    null AS {code_euser},
    null AS {code_mtstmp},
    null AS {code_muser},
    null AS {code_snotes},
    null AS {code_notes}
   FROM {schema}_{param} {param}
  WHERE {param}.{is_param_app};

/***************{code2_param_user_attrib}***************/
CREATE VIEW {schema}_{code2_param_user_attrib} AS
 SELECT null AS {code_seq},
    {param}.{param_process} AS {code_val1},
    {param}.{param_attrib} AS {code_va12},
    {param}.{param_desc} AS {code_txt},
    null AS {code_code},
    null AS {code_end_dt},
    null AS {code_end_reason},
    null AS {code_etstmp},
    null AS {code_euser},
    null AS {code_mtstmp},
    null AS {code_muser},
    null AS {code_snotes},
    null AS {code_notes}
   FROM {schema}_{param} {param}
  WHERE {param}.{is_param_user};

/***************{code2_param_sys_attrib}***************/
CREATE VIEW {schema}_{code2_param_sys_attrib} AS
 SELECT null AS {code_seq},
    {param}.{param_process} AS {code_val1},
    {param}.{param_attrib} AS {code_va12},
    {param}.{param_desc} AS {code_txt},
    null AS {code_code},
    null {code_end_dt},
    null AS {code_end_reason},
    null AS {code_etstmp},
    null AS {code_euser},
    null AS {code_mtstmp},
    null AS {code_muser},
    null AS {code_snotes},
    null AS {code_notes}
   FROM {schema}_{param} {param}
  WHERE {param}.{is_param_sys};

/***************{code_param_app_process}***************/
CREATE VIEW {schema}_{code_param_app_process} AS
 SELECT DISTINCT null AS {code_seq},
    {param}.{param_process} AS {code_val},
    {param}.{param_process} AS {code_txt},
    null AS {code_code},
    null AS {code_end_dt},
    null AS {code_end_reason}
   FROM {schema}_{param} {param}
  WHERE {param}.{is_param_app};

/***************{code_param_user_process}***************/
CREATE VIEW {schema}_{code_param_user_process} AS
 SELECT DISTINCT null AS {code_seq},
    {param}.{param_process} AS {code_val},
    {param}.{param_process} AS {code_txt},
    null AS {code_code},
    null AS {code_end_dt},
    null AS {code_end_reason}
   FROM {schema}_{param} {param}
  WHERE {param}.{is_param_user};

/***************{code_param_sys_process}***************/
CREATE VIEW {schema}_{code_param_sys_process} AS
 SELECT DISTINCT null AS {code_seq},
    {param}.{param_process} AS {code_val},
    {param}.{param_process} AS {code_txt},
    null AS {code_code},
    null AS {code_end_dt},
    null AS {code_end_reason}
   FROM {schema}_{param} {param}
  WHERE {param}.{is_param_sys};

/***************{v_audit_detail}***************/
CREATE VIEW {schema}_{v_audit_detail} AS
 SELECT {audit}.{audit_seq},
    {audit}.{cust_id},
    {audit}.{item_id},
    {audit}.{audit_table_name},
    {audit}.{audit_table_id},
    {audit}.{audit_op},
    {audit}.{audit_user},
    {schema}.{my_db_user_fmt}({audit}.{audit_user}) AS {sys_user_name},
    {audit}.{db_id},
    {audit}.{audit_tstmp},
    {audit}.{audit_ref_name},
    {audit}.{audit_ref_id},
    {audit}.{audit_subject},
    {audit_detail}.{audit_column_name},
    {audit_detail}.{audit_column_val}
   FROM ({schema}_{audit} {audit}
     LEFT JOIN {schema}_{audit_detail} {audit_detail} ON (({audit}.{audit_seq} = {audit_detail}.{audit_seq})));

/***************{v_cust_user_nostar}***************/
CREATE VIEW {schema}_{v_cust_user_nostar} AS
 SELECT {cust_user_role}.{sys_user_id},
    {cust_user_role}.{cust_user_role_snotes},
    {cust_user_role}.{cust_user_role_id},
    {cust_user_role}.{cust_role_name},
    {cust_user_role}.rowid rowid
   FROM {schema}_{cust_user_role} {cust_user_role}
  WHERE ({cust_user_role}.{cust_role_name} <> 'C*');

create trigger {schema}_{v_cust_user_nostar}_insert instead of insert on {schema}_{v_cust_user_nostar}
begin
  insert into {schema}_{cust_user_role}({sys_user_id},{cust_user_role_snotes},{cust_role_name}) values (new.{sys_user_id},new.{cust_user_role_snotes},new.{cust_role_name})\;
  update jsharmony_meta set extra_changes=extra_changes+1, last_insert_rowid_override=last_insert_rowid()\;
end;

create trigger {schema}_{v_cust_user_nostar}_update instead of update on {schema}_{v_cust_user_nostar}
begin
  update {schema}_{cust_user_role} set {sys_user_id} = new.{sys_user_id}, {cust_user_role_snotes} = new.{cust_user_role_snotes}, {cust_role_name} = new.{cust_role_name} where {cust_user_role_id}=new.{cust_user_role_id}\;
  update jsharmony_meta set extra_changes=extra_changes+1\;
end;

create trigger {schema}_{v_cust_user_nostar}_delete instead of delete on {schema}_{v_cust_user_nostar}
begin
  delete from {schema}_{cust_user_role} where {cust_user_role_id} = old.{cust_user_role_id}\;
  update jsharmony_meta set extra_changes=extra_changes+1\;
end;

/***************{v_cust_menu_role_selection}***************/
CREATE VIEW {schema}_{v_cust_menu_role_selection} AS
 SELECT {cust_menu_role}.{cust_menu_role_id},
    COALESCE({single}.{single_text}, '') AS {new_cust_role_name},
    {single}.{single_integer} AS {new_menu_id},
        CASE
            WHEN ({cust_menu_role}.{cust_menu_role_id} IS NULL) THEN 0
            ELSE 1
        END AS {cust_menu_role_selection},
    m.{cust_role_name},
    m.{cust_role_seq},
    m.{cust_role_sts},
    m.{cust_role_desc},
    m.{cust_role_id},
    m.{menu_id_auto},
    m.{menu_group},
    m.{menu_id},
    m.{menu_sts},
    m.{menu_id_parent},
    m.{menu_name},
    m.{menu_seq},
    m.{menu_desc},
    m.{menu_desc_ext},
    m.{menu_desc_ext2},
    m.{menu_cmd},
    m.{menu_image},
    m.{menu_snotes},
    m.{menu_subcmd}
   FROM ((( SELECT {cust_role}.{cust_role_name},
            {cust_role}.{cust_role_seq},
            {cust_role}.{cust_role_sts},
            {cust_role}.{cust_role_desc},
            {cust_role}.{cust_role_id},
            {menu}.{menu_id_auto},
            {menu}.{menu_group},
            {menu}.{menu_id},
            {menu}.{menu_sts},
            {menu}.{menu_id_parent},
            {menu}.{menu_name},
            {menu}.{menu_seq},
            {menu}.{menu_desc},
            {menu}.{menu_desc_ext},
            {menu}.{menu_desc_ext2},
            {menu}.{menu_cmd},
            {menu}.{menu_image},
            {menu}.{menu_snotes},
            {menu}.{menu_subcmd}
           FROM ({schema}_{cust_role} {cust_role}
             LEFT JOIN {schema}_{menu} {menu} ON (({menu}.{menu_group} = 'C')))) m
     JOIN {schema}_{single} {single} ON ((1 = 1)))
     LEFT JOIN {schema}_{cust_menu_role} {cust_menu_role} ON ((({cust_menu_role}.{cust_role_name} = m.{cust_role_name}) AND ({cust_menu_role}.{menu_id} = m.{menu_id}))));

create trigger {schema}_{v_cust_menu_role_selection}_update instead of update on {schema}_{v_cust_menu_role_selection}
begin
  delete from {schema}_{cust_menu_role} where {cust_menu_role_id}=new.{cust_menu_role_id} and (%%%{nequal}("NEW.{cust_menu_role_selection}","OLD.{cust_menu_role_selection}")%%%) and coalesce(new.{cust_menu_role_selection},0)=0\;
  insert into {schema}_{cust_menu_role} ({cust_role_name}, {menu_id})
    select new.{new_cust_role_name}, new.{menu_id} where (%%%{nequal}("NEW.{cust_menu_role_selection}","OLD.{cust_menu_role_selection}")%%%) and coalesce(new.{cust_menu_role_selection},0)=1 and coalesce(new.{new_cust_role_name},'')<>''\;
  insert into {schema}_{cust_menu_role} ({cust_role_name}, {menu_id})
    select new.{cust_role_name}, new.{new_menu_id} where (%%%{nequal}("NEW.{cust_menu_role_selection}","OLD.{cust_menu_role_selection}")%%%) and coalesce(new.{cust_menu_role_selection},0)=1 and coalesce(new.{new_cust_role_name},'')=''\;
  update jsharmony_meta set extra_changes=extra_changes+1
    where (%%%{nequal}("NEW.{cust_menu_role_selection}","OLD.{cust_menu_role_selection}")%%%)\;
end;

/***************{v_doc}***************/
CREATE VIEW {schema}_{v_doc} AS
 SELECT {doc}.{doc_id},
    {doc}.{doc_scope},
    {doc}.{doc_scope_id},
    {doc}.{cust_id},
    {doc}.{item_id},
    {doc}.{doc_sts},
    {doc}.{doc_ctgr},
    gdd.{code_txt} AS {doc_ctgr_txt},
    {doc}.{doc_desc},
    {doc}.{doc_ext},
    {doc}.{doc_size},
    ('D' || ({doc}.{doc_id}) || COALESCE({doc}.{doc_ext}, '')) AS {doc_filename},
    {doc}.{doc_etstmp},
    {doc}.{doc_euser},
    {schema}.{my_db_user_fmt}({doc}.{doc_euser}) AS {doc_euser_fmt},
    {doc}.{doc_mtstmp},
    {doc}.{doc_muser},
    {schema}.{my_db_user_fmt}({doc}.{doc_muser}) AS {doc_muser_fmt},
    {doc}.{doc_utstmp},
    {doc}.{doc_uuser},
    {schema}.{my_db_user_fmt}({doc}.{doc_uuser}) AS {doc_uuser}_fmt,
    {doc}.{doc_snotes},
    NULL AS {title_head},
    NULL AS {title_detail}
   FROM ({schema}_{doc} {doc}
     LEFT JOIN {schema}_{code2_doc_ctgr} gdd ON (((gdd.{code_val1} = {doc}.{doc_scope}) AND (gdd.{code_va12} = {doc}.{doc_ctgr}))));

/***************{v_doc_ext}***************/
CREATE VIEW {schema}_{v_doc_ext} AS
 SELECT {doc}.{doc_id},
    {doc}.{doc_scope},
    {doc}.{doc_scope_id},
    {doc}.{cust_id},
    {doc}.{item_id},
    {doc}.{doc_sts},
    {doc}.{doc_ctgr},
    {doc}.{doc_desc},
    {doc}.{doc_ext},
    {doc}.{doc_size},
    ('D' || {doc}.{doc_id} || COALESCE({doc}.{doc_ext}, '')) AS {doc_filename},
    {doc}.{doc_etstmp},
    {doc}.{doc_euser},
    {schema}.{my_db_user_fmt}({doc}.{doc_euser}) AS {doc_euser_fmt},
    {doc}.{doc_mtstmp},
    {doc}.{doc_muser},
    {schema}.{my_db_user_fmt}({doc}.{doc_muser}) AS {doc_muser_fmt},
    {doc}.{doc_utstmp},
    {doc}.{doc_uuser},
    {schema}.{my_db_user_fmt}({doc}.{doc_uuser}) AS {doc_uuser}_fmt,
    {doc}.{doc_snotes},
    null AS {title_head},
    null AS {title_detail},
    {doc}.{doc_scope} AS {doc_datalock},
    null AS {cust_name},
    null AS {cust_name_ext},
    null AS {item_name},
    {doc}.rowid rowid
   FROM {schema}_{doc} {doc};

create trigger {schema}_{v_doc_ext}_insert instead of insert on {schema}_{v_doc_ext}
begin
  insert into {schema}_{doc}({doc_scope}, {doc_scope_id}, {doc_sts}, {cust_id}, {item_id}, {doc_ctgr}, {doc_desc}, {doc_ext}, {doc_size}, {doc_etstmp}, {doc_euser}, {doc_mtstmp}, {doc_muser}, {doc_utstmp}, {doc_uuser}, {doc_snotes})
                    values (coalesce(new.{doc_scope},'S'), coalesce(new.{doc_scope_id},0), coalesce(new.{doc_sts},'A'), new.{cust_id}, new.{item_id}, new.{doc_ctgr}, new.{doc_desc}, new.{doc_ext}, new.{doc_size}, new.{doc_etstmp}, new.{doc_euser}, new.{doc_mtstmp}, new.{doc_muser}, new.{doc_utstmp}, new.{doc_uuser}, new.{doc_snotes})\;
  update jsharmony_meta set extra_changes=extra_changes+1, last_insert_rowid_override=last_insert_rowid()\;
end;

create trigger {schema}_{v_doc_ext}_update instead of update on {schema}_{v_doc_ext}
begin
  update {schema}_{doc} set {doc_scope} = new.{doc_scope}, {doc_scope_id} = new.{doc_scope_id}, {doc_sts} = new.{doc_sts},
                           {cust_id} = new.{cust_id}, {item_id} = new.{item_id}, {doc_ctgr} = new.{doc_ctgr}, {doc_desc} = new.{doc_desc},
                           {doc_ext} = new.{doc_ext}, {doc_size} = new.{doc_size},
                           {doc_etstmp} = new.{doc_etstmp},{doc_euser} = new.{doc_euser}, {doc_mtstmp} = new.{doc_mtstmp}, {doc_muser} = new.{doc_muser},
                           {doc_utstmp} = new.{doc_utstmp}, {doc_uuser} = new.{doc_uuser}, {doc_snotes} =  new.{doc_snotes}
                           where {doc_id}=new.{doc_id}\;
  update jsharmony_meta set extra_changes=extra_changes+1\;
end;

create trigger {schema}_{v_doc_ext}_delete instead of delete on {schema}_{v_doc_ext}
begin
  delete from {schema}_{doc} where {doc_id} = old.{doc_id}\;
  update jsharmony_meta set extra_changes=extra_changes+1\;
end;

/***************{v_doc_filename}***************/
CREATE VIEW {schema}_{v_doc_filename} AS
 SELECT {doc}.{doc_id},
    {doc}.{doc_scope},
    {doc}.{doc_scope_id},
    {doc}.{cust_id},
    {doc}.{item_id},
    {doc}.{doc_sts},
    {doc}.{doc_ctgr},
    {doc}.{doc_desc},
    {doc}.{doc_ext},
    {doc}.{doc_size},
    {doc}.{doc_etstmp},
    {doc}.{doc_euser},
    {doc}.{doc_mtstmp},
    {doc}.{doc_muser},
    {doc}.{doc_utstmp},
    {doc}.{doc_uuser},
    {doc}.{doc_sync_tstmp},
    {doc}.{doc_snotes},
    {doc}.{doc_sync_id},
    ('D' || {doc}.{doc_id} || COALESCE({doc}.{doc_ext}, '')) AS {doc_filename}
   FROM {schema}_{doc} {doc};

/***************{v_param_app}***************/
CREATE VIEW {schema}_{v_param_app} AS
 SELECT {param_app}.{param_app_id},
    {param_app}.{param_app_process},
    {param_app}.{param_app_attrib},
    {param_app}.{param_app_val},
    {param_app}.{param_app_etstmp},
    {param_app}.{param_app_euser},
    {param_app}.{param_app_mtstmp},
    {param_app}.{param_app_muser},
    {schema}.{get_param_desc}({param_app}.{param_app_process}, {param_app}.{param_app_attrib}) AS {param_desc},
    {schema}.{log_audit_info}({param_app}.{param_app_etstmp}, {param_app}.{param_app_euser}, {param_app}.{param_app_mtstmp}, {param_app}.{param_app_muser}) AS {param_app_info},
    {param_app}.rowid rowid
   FROM {schema}_{param_app} {param_app};

create trigger {schema}_{v_param_app}_insert instead of insert on {schema}_{v_param_app}
begin
  insert into {schema}_{param_app}({param_app_process}, {param_app_attrib}, {param_app_val}, {param_app_etstmp}, {param_app_euser}, {param_app_mtstmp}, {param_app_muser})
                    values (new.{param_app_process}, new.{param_app_attrib}, new.{param_app_val}, new.{param_app_etstmp}, new.{param_app_euser}, new.{param_app_mtstmp}, new.{param_app_muser})\;
  update jsharmony_meta set extra_changes=extra_changes+1, last_insert_rowid_override=last_insert_rowid()\;
end;

create trigger {schema}_{v_param_app}_update instead of update on {schema}_{v_param_app}
begin
  update {schema}_{param_app} set {param_app_process} = new.{param_app_process}, {param_app_attrib} = new.{param_app_attrib}, {param_app_val} = new.{param_app_val},
                           {param_app_etstmp} = new.{param_app_etstmp},{param_app_euser} = new.{param_app_euser}, {param_app_mtstmp} = new.{param_app_mtstmp}, {param_app_muser} = new.{param_app_muser}
                           where {param_app_id}=new.{param_app_id}\;
  update jsharmony_meta set extra_changes=extra_changes+1\;
end;

create trigger {schema}_{v_param_app}_delete instead of delete on {schema}_{v_param_app}
begin
  delete from {schema}_{param_app} where {param_app_id} = old.{param_app_id}\;
  update jsharmony_meta set extra_changes=extra_changes+1\;
end;

/***************{v_month}***************/
CREATE VIEW {schema}_{v_month} AS
 SELECT {number}.{number_val} {month_val},
    substr(('0' || {number}.{number_val}), -2, 2) AS {month_txt}
   FROM {schema}_{number} {number}
  WHERE ({number}.{number_val} <= 12);

/***************{v_my_user}***************/
CREATE VIEW {schema}_{v_my_user} AS
 SELECT {schema}.{my_sys_user_id}() AS {my_sys_user_id};

/***************{v_my_roles}***************/
CREATE VIEW {schema}_{v_my_roles} AS
 SELECT {sys_user_role}.{sys_role_name}
   FROM {schema}_{sys_user_role} {sys_user_role}
  WHERE ({sys_user_role}.{sys_user_id} = {schema}.{my_sys_user_id}());

/***************{v_note}***************/
CREATE VIEW {schema}_{v_note} AS
 SELECT {note}.{note_id},
    {note}.{note_scope},
    {note}.{note_scope_id},
    {note}.{note_sts},
    {note}.{cust_id},
    null AS {cust_name},
    null AS {cust_name_ext},
    {note}.{item_id},
    null AS {item_name},
    {note}.{note_type},
    {note}.{note_body},
    {schema}.{my_to_date}({note}.{note_etstmp}) AS {note_dt},
    {note}.{note_etstmp},
    {note}.{note_euser},
    {schema}.{my_db_user_fmt}({note}.{note_euser}) AS {note_euser_fmt},
    {note}.{note_mtstmp},
    {note}.{note_muser},
    {schema}.{my_db_user_fmt}({note}.{note_muser}) AS {note_muser_fmt},
    {note}.{note_snotes},
    null AS {title_head},
    null AS {title_detail}
   FROM {schema}_{note} {note};

/***************{v_note_ext}***************/
CREATE VIEW {schema}_{v_note_ext} AS
 SELECT {note}.{note_id},
    {note}.{note_scope},
    {note}.{note_scope_id},
    {note}.{note_sts},
    {note}.{cust_id},
    {note}.{item_id},
    {note}.{note_type},
    {note}.{note_body},
    {note}.{note_etstmp},
    {note}.{note_euser},
    {schema}.{my_db_user_fmt}({note}.{note_euser}) AS {note_euser_fmt},
    {note}.{note_mtstmp},
    {note}.{note_muser},
    {schema}.{my_db_user_fmt}({note}.{note_muser}) AS {note_muser_fmt},
    {note}.{note_snotes},
    null AS {title_head},
    null AS {title_detail},
    null AS {cust_name},
    null AS {cust_name_ext},
    null AS {item_name},
    {note}.rowid rowid
   FROM {schema}_{note} {note};

create trigger {schema}_{v_note_ext}_insert instead of insert on {schema}_{v_note_ext}
begin
  insert into {schema}_{note}({note_scope}, {note_scope_id}, {note_sts}, {cust_id}, {item_id}, {note_type}, {note_body}, {note_etstmp}, {note_euser}, {note_mtstmp}, {note_muser}, {note_snotes})
                    values (coalesce(new.{note_scope},'S'), coalesce(new.{note_scope_id},0), coalesce(new.{note_sts},'A'), new.{cust_id}, new.{item_id}, new.{note_type}, new.{note_body}, new.{note_etstmp}, new.{note_euser}, new.{note_mtstmp}, new.{note_muser}, new.{note_snotes})\;
  update jsharmony_meta set extra_changes=extra_changes+1, last_insert_rowid_override=last_insert_rowid()\;
end;

create trigger {schema}_{v_note_ext}_update instead of update on {schema}_{v_note_ext}
begin
  update {schema}_{note} set {note_scope} = new.{note_scope}, {note_scope_id} = new.{note_scope_id}, {note_sts} = new.{note_sts},
                           {cust_id} = new.{cust_id}, {item_id} = new.{item_id}, {note_type} = new.{note_type}, {note_body} = new.{note_body},
                           {note_etstmp} = new.{note_etstmp},{note_euser} = new.{note_euser}, {note_mtstmp} = new.{note_mtstmp}, {note_muser} = new.{note_muser},
                           {note_snotes} =  new.{note_snotes}
                           where {note_id}=new.{note_id}\;
  update jsharmony_meta set extra_changes=extra_changes+1\;
end;

create trigger {schema}_{v_note_ext}_delete instead of delete on {schema}_{v_note_ext}
begin
  delete from {schema}_{note} where {note_id} = old.{note_id}\;
  update jsharmony_meta set extra_changes=extra_changes+1\;
end;

/***************{v_param}***************/
CREATE VIEW {schema}_{v_param} AS
 SELECT {param}.{param_id},
    {param}.{param_process},
    {param}.{param_attrib},
    {param}.{param_desc},
    {param}.{param_type},
    {param}.{code_name},
    {param}.{is_param_app},
    {param}.{is_param_user},
    {param}.{is_param_sys},
    {param}.{param_etstmp},
    {param}.{param_euser},
    {param}.{param_mtstmp},
    {param}.{param_muser},
    {param}.{param_snotes},
    {schema}.{log_audit_info}({param}.{param_etstmp}, {param}.{param_euser}, {param}.{param_mtstmp}, {param}.{param_muser}) AS {param_info},
    {param}.rowid rowid
   FROM {schema}_{param} {param};

create trigger {schema}_{v_param}_insert instead of insert on {schema}_{v_param}
begin
  insert into {schema}_{param}({param_process}, {param_attrib}, {param_desc}, {param_type}, {code_name}, {is_param_app}, {is_param_user}, {is_param_sys}, {param_etstmp}, {param_euser}, {param_mtstmp}, {param_muser}, {param_snotes})
                    values (new.{param_process}, new.{param_attrib}, new.{param_desc}, new.{param_type}, new.{code_name}, coalesce(new.{is_param_app},0), coalesce(new.{is_param_user},0), coalesce(new.{is_param_sys},0), new.{param_etstmp}, new.{param_euser}, new.{param_mtstmp}, new.{param_muser}, new.{param_snotes})\;
  update jsharmony_meta set extra_changes=extra_changes+1, last_insert_rowid_override=last_insert_rowid()\;
end;

create trigger {schema}_{v_param}_update instead of update on {schema}_{v_param}
begin
  update {schema}_{param} set {param_process} = new.{param_process}, {param_attrib} = new.{param_attrib}, {param_desc} = new.{param_desc},
                           {param_type} = new.{param_type}, {code_name} = new.{code_name}, 
                           {is_param_app} = new.{is_param_app}, {is_param_user} = new.{is_param_user}, {is_param_sys} = new.{is_param_sys}, 
                           {param_etstmp} = new.{param_etstmp},{param_euser} = new.{param_euser}, {param_mtstmp} = new.{param_mtstmp}, {param_muser} = new.{param_muser},
                           {param_snotes} = new.{param_snotes} where {param_id}=new.{param_id}\;
  update jsharmony_meta set extra_changes=extra_changes+1\;
end;

create trigger {schema}_{v_param}_delete instead of delete on {schema}_{v_param}
begin
  delete from {schema}_{param} where {param_id} = old.{param_id}\;
  update jsharmony_meta set extra_changes=extra_changes+1\;
end;

/***************{v_param_user}***************/
CREATE VIEW {schema}_{v_param_user} AS
 SELECT {param_user}.{param_user_id},
    {param_user}.{sys_user_id},
    {param_user}.{param_user_process},
    {param_user}.{param_user_attrib},
    {param_user}.{param_user_val},
    {param_user}.{param_user_etstmp},
    {param_user}.{param_user_euser},
    {param_user}.{param_user_mtstmp},
    {param_user}.{param_user_muser},
    {schema}.{get_param_desc}({param_user}.{param_user_process}, {param_user}.{param_user_attrib}) AS {param_desc},
    {schema}.{log_audit_info}({param_user}.{param_user_etstmp}, {param_user}.{param_user_euser}, {param_user}.{param_user_mtstmp}, {param_user}.{param_user_muser}) AS {param_user_info},
    {param_user}.rowid rowid
   FROM {schema}_{param_user} {param_user};

create trigger {schema}_{v_param_user}_insert instead of insert on {schema}_{v_param_user}
begin
  insert into {schema}_{param_user}({sys_user_id}, {param_user_process}, {param_user_attrib}, {param_user_val}, {param_user_etstmp}, {param_user_euser}, {param_user_mtstmp}, {param_user_muser})
                    values (new.{sys_user_id}, new.{param_user_process}, new.{param_user_attrib}, new.{param_user_val}, new.{param_user_etstmp}, new.{param_user_euser}, new.{param_user_mtstmp}, new.{param_user_muser})\;
  update jsharmony_meta set extra_changes=extra_changes+1, last_insert_rowid_override=last_insert_rowid()\;
end;

create trigger {schema}_{v_param_user}_update instead of update on {schema}_{v_param_user}
begin
  update {schema}_{param_user} set {sys_user_id} = new.{sys_user_id}, {param_user_process} = new.{param_user_process}, {param_user_attrib} = new.{param_user_attrib}, {param_user_val} = new.{param_user_val},
                           {param_user_etstmp} = new.{param_user_etstmp},{param_user_euser} = new.{param_user_euser}, {param_user_mtstmp} = new.{param_user_mtstmp}, {param_user_muser} = new.{param_user_muser}
                           where {param_user_id}=new.{param_user_id}\;
  update jsharmony_meta set extra_changes=extra_changes+1\;
end;

create trigger {schema}_{v_param_user}_delete instead of delete on {schema}_{v_param_user}
begin
  delete from {schema}_{param_user} where {param_user_id} = old.{param_user_id}\;
  update jsharmony_meta set extra_changes=extra_changes+1\;
end;

/***************{v_sys_menu_role_selection}***************/
CREATE VIEW {schema}_{v_sys_menu_role_selection} AS
 SELECT {sys_menu_role}.{sys_menu_role_id},
    COALESCE({single}.{single_text}, '') AS {new_sys_role_name},
    {single}.{single_integer} AS {new_menu_id},
        CASE
            WHEN ({sys_menu_role}.{sys_menu_role_id} IS NULL) THEN 0
            ELSE 1
        END AS {sys_menu_role_selection},
    m.{sys_role_name},
    m.{sys_role_seq},
    m.{sys_role_sts},
    m.{sys_role_desc},
    m.{sys_role_id},
    m.{menu_id_auto},
    m.{menu_group},
    m.{menu_id},
    m.{menu_sts},
    m.{menu_id_parent},
    m.{menu_name},
    m.{menu_seq},
    m.{menu_desc},
    m.{menu_desc_ext},
    m.{menu_desc_ext2},
    m.{menu_cmd},
    m.{menu_image},
    m.{menu_snotes},
    m.{menu_subcmd}
   FROM ((( SELECT {sys_role}.{sys_role_name},
            {sys_role}.{sys_role_seq},
            {sys_role}.{sys_role_sts},
            {sys_role}.{sys_role_desc},
            {sys_role}.{sys_role_id},
            {menu}.{menu_id_auto},
            {menu}.{menu_group},
            {menu}.{menu_id},
            {menu}.{menu_sts},
            {menu}.{menu_id_parent},
            {menu}.{menu_name},
            {menu}.{menu_seq},
            {menu}.{menu_desc},
            {menu}.{menu_desc_ext},
            {menu}.{menu_desc_ext2},
            {menu}.{menu_cmd},
            {menu}.{menu_image},
            {menu}.{menu_snotes},
            {menu}.{menu_subcmd}
           FROM ({schema}_{sys_role} {sys_role}
             LEFT JOIN {schema}_{menu} {menu} ON ({menu}.{menu_group} = 'S'))) m
     JOIN {schema}_{single} {single} ON (1 = 1))
     LEFT JOIN {schema}_{sys_menu_role} {sys_menu_role} ON ((({sys_menu_role}.{sys_role_name} = m.{sys_role_name}) AND ({sys_menu_role}.{menu_id} = m.{menu_id}))));

create trigger {schema}_{v_sys_menu_role_selection}_update instead of update on {schema}_{v_sys_menu_role_selection}
begin
  delete from {schema}_{sys_menu_role} where {sys_menu_role_id}=new.{sys_menu_role_id} and (%%%{nequal}("NEW.{sys_menu_role_selection}","OLD.{sys_menu_role_selection}")%%%) and coalesce(new.{sys_menu_role_selection},0)=0\;
  insert into {schema}_{sys_menu_role} ({sys_role_name}, {menu_id})
    select new.{new_sys_role_name}, new.{menu_id} where (%%%{nequal}("NEW.{sys_menu_role_selection}","OLD.{sys_menu_role_selection}")%%%) and coalesce(new.{sys_menu_role_selection},0)=1 and coalesce(new.{new_sys_role_name},'')<>''\;
  insert into {schema}_{sys_menu_role} ({sys_role_name}, {menu_id})
    select new.{sys_role_name}, new.{new_menu_id} where (%%%{nequal}("NEW.{sys_menu_role_selection}","OLD.{sys_menu_role_selection}")%%%) and coalesce(new.{sys_menu_role_selection},0)=1 and coalesce(new.{new_sys_role_name},'')=''\;
  update jsharmony_meta set extra_changes=extra_changes+1
    where (%%%{nequal}("NEW.{sys_menu_role_selection}","OLD.{sys_menu_role_selection}")%%%)\;
end;

/***************{v_param_sys}***************/
CREATE VIEW {schema}_{v_param_sys} AS
 SELECT {param_sys}.{param_sys_id},
    {param_sys}.{param_sys_process},
    {param_sys}.{param_sys_attrib},
    {param_sys}.{param_sys_val},
    {param_sys}.{param_sys_etstmp},
    {param_sys}.{param_sys_euser},
    {param_sys}.{param_sys_mtstmp},
    {param_sys}.{param_sys_muser},
    {schema}.{get_param_desc}({param_sys}.{param_sys_process}, {param_sys}.{param_sys_attrib}) AS {param_desc},
    {schema}.{log_audit_info}({param_sys}.{param_sys_etstmp}, {param_sys}.{param_sys_euser}, {param_sys}.{param_sys_mtstmp}, {param_sys}.{param_sys_muser}) AS {param_sys_info},
    {param_sys}.rowid rowid
   FROM {schema}_{param_sys} {param_sys};

create trigger {schema}_{v_param_sys}_insert instead of insert on {schema}_{v_param_sys}
begin
  insert into {schema}_{param_sys}({param_sys_process}, {param_sys_attrib}, {param_sys_val}, {param_sys_etstmp}, {param_sys_euser}, {param_sys_mtstmp}, {param_sys_muser})
                    values (new.{param_sys_process}, new.{param_sys_attrib}, new.{param_sys_val}, new.{param_sys_etstmp}, new.{param_sys_euser}, new.{param_sys_mtstmp}, new.{param_sys_muser})\;
  update jsharmony_meta set extra_changes=extra_changes+1, last_insert_rowid_override=last_insert_rowid()\;
end;

create trigger {schema}_{v_param_sys}_update instead of update on {schema}_{v_param_sys}
begin
  update {schema}_{param_sys} set {param_sys_process} = new.{param_sys_process}, {param_sys_attrib} = new.{param_sys_attrib}, {param_sys_val} = new.{param_sys_val},
                           {param_sys_etstmp} = new.{param_sys_etstmp},{param_sys_euser} = new.{param_sys_euser}, {param_sys_mtstmp} = new.{param_sys_mtstmp}, {param_sys_muser} = new.{param_sys_muser}
                           where {param_sys_id}=new.{param_sys_id}\;
  update jsharmony_meta set extra_changes=extra_changes+1\;
end;

create trigger {schema}_{v_param_sys}_delete instead of delete on {schema}_{v_param_sys}
begin
  delete from {schema}_{param_sys} where {param_sys_id} = old.{param_sys_id}\;
  update jsharmony_meta set extra_changes=extra_changes+1\;
end;

/***************{v_year}***************/
CREATE VIEW {schema}_{v_year} AS
 SELECT ((cast(strftime('%Y',{schema}.{my_now}()) as int) + {number}.{number_val}) - 1) AS {year_val}
   FROM {schema}_{number} {number}
  WHERE ({number}.{number_val} <= 10);
