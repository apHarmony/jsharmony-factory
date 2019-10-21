/*********code_cust_sts*********/
exec jsharmony.create_code 'dbo','cust_sts','';
go
insert into code_cust_sts(code_seq,code_val,code_txt,code_code) values (1,'ACTIVE','Active','A');
insert into code_cust_sts(code_seq,code_val,code_txt,code_code) values (2,'CREDITH','Credit Hold','A');
insert into code_cust_sts(code_seq,code_val,code_txt,code_code) values (3,'CLOSED','Closed','C');
go

/*********code_cust_phone_type*********/
exec jsharmony.create_code 'dbo','cust_phone_type','';
go
insert into code_cust_phone_type(code_seq,code_val,code_txt) values (1,'CELL','Cell');
insert into code_cust_phone_type(code_seq,code_val,code_txt) values (2,'WORK','Work');
insert into code_cust_phone_type(code_seq,code_val,code_txt) values (3,'HOME','Home');
go

/*********cust*********/
create table cust (
  cust_id bigint primary key identity not null,
  cust_sts nvarchar(32) not null,
  cust_stsdt date not null default jsharmony.my_today(),
  cust_name nvarchar(256) not null unique,
  cust_email nvarchar(256),
  cust_phone nvarchar(100),
  cust_phone_type nvarchar(32),
  cust_notes nvarchar(max),
  cust_agreement_tstmp datetime2(7),
  cust_etstmp datetime2(7) not null default jsharmony.my_now(),
  cust_euser nvarchar(20) not null default jsharmony.my_db_user(),
  cust_mtstmp datetime2(7) not null default jsharmony.my_now(),
  cust_muser nvarchar(20) not null default jsharmony.my_db_user(),
  foreign key (cust_sts) references code_cust_sts(code_val),
  foreign key (cust_phone_type) references code_cust_phone_type(code_val)
);
go

create trigger cust_insert on cust for insert as
begin
  begin_trigger_cursor(cust_id, 
    cust_id bigint, cust_sts nvarchar(32), cust_name nvarchar(512), cust_email nvarchar(256), cust_phone nvarchar(100),
    cust_phone_type nvarchar(32), cust_notes nvarchar(max), cust_agreement_tstmp datetime2(7)
  )
  log_audit_insert('cust',@inserted_cust_id,'cust_id',null,null,null,@inserted_cust_id,null)
  end_trigger_cursor(cust_id, cust_sts, cust_name, cust_email, cust_phone, cust_phone_type, cust_notes, cust_agreement_tstmp)
end
go

create trigger cust_update on cust for update as
begin
  begin_trigger_cursor(cust_id, 
    cust_id bigint, cust_sts nvarchar(32), cust_name nvarchar(512), cust_email nvarchar(256), cust_phone nvarchar(100),
    cust_phone_type nvarchar(32), cust_notes nvarchar(max), cust_agreement_tstmp datetime2(7)
  )
  trigger_errorif(isnull(@inserted_cust_id,-1) <> isnull(@deleted_cust_id,-1),'ID cannot be updated')
  if(@inserted_cust_sts <> @deleted_cust_sts) update cust set cust_stsdt = jsharmony.my_today() where cust_id=@inserted_cust_id;

  log_audit_update_mult('cust',@deleted_cust_id,["cust_id","cust_name","cust_sts","cust_email","cust_phone","cust_phone_type","cust_notes","cust_agreement_tstmp"],null,null,null,@deleted_cust_id,null)

  if(@MY_audit_seq <> 0)
    update cust set cust_mtstmp = jsharmony.my_now(), cust_muser=jsharmony.my_db_user() where cust_id=@inserted_cust_id;

  end_trigger_cursor(cust_id, cust_sts, cust_name, cust_email, cust_phone, cust_phone_type, cust_notes, cust_agreement_tstmp)
end
go

create trigger cust_delete on cust for delete as
begin
  begin_trigger_cursor(cust_id, 
    cust_id bigint, cust_sts nvarchar(32), cust_name nvarchar(512), cust_email nvarchar(256), cust_phone nvarchar(100),
    cust_phone_type nvarchar(32), cust_notes nvarchar(max), cust_agreement_tstmp datetime2(7)
  )
  log_audit_delete_mult('cust',@deleted_cust_id,["cust_id","cust_name","cust_sts","cust_email","cust_phone","cust_phone_type","cust_notes","cust_agreement_tstmp"],null,null,null,@deleted_cust_id,null)
  end_trigger_cursor(cust_id, cust_sts, cust_name, cust_email, cust_phone, cust_phone_type, cust_notes, cust_agreement_tstmp)
end
go


/* menu */
insert into jsharmony.menu (menu_group, menu_id, menu_sts, menu_id_parent, menu_name, menu_seq, menu_desc, menu_desc_ext, menu_desc_ext2, menu_cmd, menu_image, menu_snotes, menu_subcmd) values ('S', 300, 'ACTIVE', 1, 'Customer', 300, 'Customers', null, null, 'Cust_Listing', null, null, null);
insert into jsharmony.menu (menu_group, menu_id, menu_sts, menu_id_parent, menu_name, menu_seq, menu_desc, menu_desc_ext, menu_desc_ext2, menu_cmd, menu_image, menu_snotes, menu_subcmd) values ('S', 30001, 'ACTIVE', 300, 'Customer/Cust_Listing', 30001, 'Customer Listing', null, null, 'Cust_Listing', null, null, null);
insert into jsharmony.sys_menu_role (menu_id, sys_role_name) values (300, '*');
insert into jsharmony.sys_menu_role (menu_id, sys_role_name) values (30001, '*');

update jsharmony.menu set menu_cmd='Client/Dashboard' where menu_id=200 and menu_cmd='jsHarmonyFactory/Client/Dashboard';
insert into jsharmony.menu (menu_group, menu_id, menu_sts, menu_id_parent, menu_name, menu_seq, menu_desc, menu_desc_ext, menu_desc_ext2, menu_cmd, menu_image, menu_snotes, menu_subcmd) values ('C', 280001, 'ACTIVE', 2800, 'Client/Admin/Settings', 280001, 'Settings', null, null, 'Client/Admin/Settings', null, null, null);
insert into jsharmony.cust_menu_role (menu_id, cust_role_name) values (280001, 'CSYSADMIN');
go
