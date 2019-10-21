/***************v_cust_user_nostar***************/
CREATE VIEW {schema}_v_cust_user_nostar AS
 SELECT cust_user_role.sys_user_id,
    cust_user_role.cust_user_role_snotes,
    cust_user_role.cust_user_role_id,
    cust_user_role.cust_role_name,
    cust_user_role.rowid rowid
   FROM {schema}_cust_user_role cust_user_role
  WHERE (cust_user_role.cust_role_name <> 'C*');

create trigger {schema}_v_cust_user_nostar_insert instead of insert on {schema}_v_cust_user_nostar
begin
  insert into {schema}_cust_user_role(sys_user_id,cust_user_role_snotes,cust_role_name) values (new.sys_user_id,new.cust_user_role_snotes,new.cust_role_name)\;
  update jsharmony_meta set extra_changes=extra_changes+1, last_insert_rowid_override=last_insert_rowid()\;
end;

create trigger {schema}_v_cust_user_nostar_update instead of update on {schema}_v_cust_user_nostar
begin
  update {schema}_cust_user_role set sys_user_id = new.sys_user_id, cust_user_role_snotes = new.cust_user_role_snotes, cust_role_name = new.cust_role_name where cust_user_role_id=new.cust_user_role_id\;
  update jsharmony_meta set extra_changes=extra_changes+1\;
end;

create trigger {schema}_v_cust_user_nostar_delete instead of delete on {schema}_v_cust_user_nostar
begin
  delete from {schema}_cust_user_role where cust_user_role_id = old.cust_user_role_id\;
  update jsharmony_meta set extra_changes=extra_changes+1\;
end;

/***************v_cust_menu_role_selection***************/
CREATE VIEW {schema}_v_cust_menu_role_selection AS
 SELECT cust_menu_role.cust_menu_role_id,
    COALESCE(single.single_text, '') AS new_cust_role_name,
    single.single_integer AS new_menu_id,
        CASE
            WHEN (cust_menu_role.cust_menu_role_id IS NULL) THEN 0
            ELSE 1
        END AS cust_menu_role_selection,
    m.cust_role_name,
    m.cust_role_seq,
    m.cust_role_sts,
    m.cust_role_desc,
    m.cust_role_id,
    m.menu_id_auto,
    m.menu_group,
    m.menu_id,
    m.menu_sts,
    m.menu_id_parent,
    m.menu_name,
    m.menu_seq,
    m.menu_desc,
    m.menu_desc_ext,
    m.menu_desc_ext2,
    m.menu_cmd,
    m.menu_image,
    m.menu_snotes,
    m.menu_subcmd
   FROM ((( SELECT cust_role.cust_role_name,
            cust_role.cust_role_seq,
            cust_role.cust_role_sts,
            cust_role.cust_role_desc,
            cust_role.cust_role_id,
            menu__tbl.menu_id_auto,
            menu__tbl.menu_group,
            menu__tbl.menu_id,
            menu__tbl.menu_sts,
            menu__tbl.menu_id_parent,
            menu__tbl.menu_name,
            menu__tbl.menu_seq,
            menu__tbl.menu_desc,
            menu__tbl.menu_desc_ext,
            menu__tbl.menu_desc_ext2,
            menu__tbl.menu_cmd,
            menu__tbl.menu_image,
            menu__tbl.menu_snotes,
            menu__tbl.menu_subcmd
           FROM ({schema}_cust_role cust_role
             LEFT JOIN {schema}_menu__tbl menu__tbl ON ((menu__tbl.menu_group = 'C')))) m
     JOIN {schema}_single single ON ((1 = 1)))
     LEFT JOIN {schema}_cust_menu_role cust_menu_role ON (((cust_menu_role.cust_role_name = m.cust_role_name) AND (cust_menu_role.menu_id = m.menu_id))));

create trigger {schema}_v_cust_menu_role_selection_update instead of update on {schema}_v_cust_menu_role_selection
begin
  delete from {schema}_cust_menu_role where cust_menu_role_id=new.cust_menu_role_id and (%%%nequal("NEW.cust_menu_role_selection","OLD.cust_menu_role_selection")%%%) and coalesce(new.cust_menu_role_selection,0)=0\;
  insert into {schema}_cust_menu_role (cust_role_name, menu_id)
    select new.new_cust_role_name, new.menu_id where (%%%nequal("NEW.cust_menu_role_selection","OLD.cust_menu_role_selection")%%%) and coalesce(new.cust_menu_role_selection,0)=1 and coalesce(new.new_cust_role_name,'')<>''\;
  insert into {schema}_cust_menu_role (cust_role_name, menu_id)
    select new.cust_role_name, new.new_menu_id where (%%%nequal("NEW.cust_menu_role_selection","OLD.cust_menu_role_selection")%%%) and coalesce(new.cust_menu_role_selection,0)=1 and coalesce(new.new_cust_role_name,'')=''\;
  update jsharmony_meta set extra_changes=extra_changes+1
    where (%%%nequal("NEW.cust_menu_role_selection","OLD.cust_menu_role_selection")%%%)\;
end;
