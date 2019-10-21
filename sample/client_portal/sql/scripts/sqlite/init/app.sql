pragma foreign_keys = ON;

begin;

/*********code_cust_sts*********/
create_code('code_cust_sts');
insert into jsharmony.code (code_name, code_desc) values ('cust_sts', 'Customer Status');
insert into code_cust_sts(code_seq,code_val,code_txt,code_code) values (1,'ACTIVE','Active','A');
insert into code_cust_sts(code_seq,code_val,code_txt,code_code) values (2,'CREDITH','Credit Hold','A');
insert into code_cust_sts(code_seq,code_val,code_txt,code_code) values (3,'CLOSED','Closed','C');

/*********code_cust_phone_type*********/
create_code('code_cust_phone_type');
insert into jsharmony.code (code_name, code_desc) values ('cust_phone_type', 'Customer Phone Type');
insert into code_cust_phone_type(code_seq,code_val,code_txt) values (1,'CELL','Cell');
insert into code_cust_phone_type(code_seq,code_val,code_txt) values (2,'WORK','Work');
insert into code_cust_phone_type(code_seq,code_val,code_txt) values (3,'HOME','Home');

/*********cust*********/
create table cust (
  cust_id integer primary key autoincrement not null,
  cust_sts text not null,
  cust_stsdt text,
  cust_name text not null unique,
  cust_email text,
  cust_phone text,
  cust_phone_type text,
  cust_notes text,
  cust_agreement_tstmp text,
  cust_etstmp text,
  cust_euser text,
  cust_mtstmp text,
  cust_muser text,
  foreign key (cust_sts) references code_cust_sts(code_val),
  foreign key (cust_phone_type) references code_cust_phone_type(code_val)
);

create trigger cust_after_insert after insert on cust
begin
  update cust set 
    cust_stsdt  =  datetime('now','localtime'),
    cust_euser  = (select context from jsharmony_meta limit 1),
    cust_etstmp = datetime('now','localtime'),
    cust_muser  = (select context from jsharmony_meta limit 1),
    cust_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;

  %%%log_audit_insert("cust","new.cust_id","cust_id","null","null","null","new.cust_id","null")%%%
  update jsharmony_meta set audit_seq = null\;
end;

create trigger cust_before_update before update on cust
begin
  select case when ifnull(old.cust_id,'')<>ifnull(new.cust_id,'') then raise(FAIL,'Application Error - ID cannot be updated.') end\;
end;

create trigger cust_after_update after update on cust
begin
  %%%log_audit_update_mult("cust","old.cust_id",["cust_id","cust_name","cust_sts","cust_email","cust_phone","cust_phone_type","cust_notes"],"null","null","null","old.cust_id","null")%%%

  update cust set 
    cust_stsdt  = case when (%%%nequal("new.cust_sts","old.cust_sts")%%%) then datetime('now','localtime') else new.cust_sts end,
    cust_muser  = (select context from jsharmony_meta limit 1),
    cust_mtstmp = datetime('now','localtime')
    where cust_id = new.cust_id and exists(select * from jsharmony_meta where audit_seq is not null)\; 

  update jsharmony_meta set audit_seq = null\;
end;

create trigger cust_delete before delete on cust
begin
  %%%log_audit_delete_mult("cust","old.cust_id",["cust_id","cust_name","cust_sts","cust_email","cust_phone","cust_phone_type","cust_notes"],"null","null","null","old.cust_id","null")%%%
  update jsharmony_meta set audit_seq = null\;
end;


/* menu */
insert into jsharmony.menu (menu_group, menu_id, menu_sts, menu_id_parent, menu_name, menu_seq, menu_desc, menu_desc_ext, menu_desc_ext2, menu_cmd, menu_image, menu_snotes, menu_subcmd) values ('S', 300, 'ACTIVE', 1, 'Customer', 300, 'Customers', null, null, 'Cust_Listing', null, null, null);
insert into jsharmony.menu (menu_group, menu_id, menu_sts, menu_id_parent, menu_name, menu_seq, menu_desc, menu_desc_ext, menu_desc_ext2, menu_cmd, menu_image, menu_snotes, menu_subcmd) values ('S', 30001, 'ACTIVE', 300, 'Customer/Cust_Listing', 30001, 'Customer Listing', null, null, 'Cust_Listing', null, null, null);
insert into jsharmony.sys_menu_role (menu_id, sys_role_name) values (300, '*');
insert into jsharmony.sys_menu_role (menu_id, sys_role_name) values (30001, '*');

update jsharmony.menu set menu_cmd='Client/Dashboard' where menu_id=200 and menu_cmd='jsHarmonyFactory/Client/Dashboard';
insert into jsharmony.menu (menu_group, menu_id, menu_sts, menu_id_parent, menu_name, menu_seq, menu_desc, menu_desc_ext, menu_desc_ext2, menu_cmd, menu_image, menu_snotes, menu_subcmd) values ('C', 280001, 'ACTIVE', 2800, 'Client/Admin/Settings', 280001, 'Settings', null, null, 'Client/Admin/Settings', null, null, null);
insert into jsharmony.cust_menu_role (menu_id, cust_role_name) values (280001, 'CSYSADMIN');


end;
