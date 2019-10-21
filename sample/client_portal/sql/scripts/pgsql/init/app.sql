SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET search_path = public, pg_catalog;

/*********code_cust_sts*********/
insert into jsharmony.code (code_schema, code_name, code_desc) values ('public', 'cust_sts', 'Customer Status');
select jsharmony.create_code('public','cust_sts','');
insert into code_cust_sts(code_seq,code_val,code_txt,code_code) values (1,'ACTIVE','Active','A');
insert into code_cust_sts(code_seq,code_val,code_txt,code_code) values (2,'CREDITH','Credit Hold','A');
insert into code_cust_sts(code_seq,code_val,code_txt,code_code) values (3,'CLOSED','Closed','C');

/*********code_cust_phone_type*********/
insert into jsharmony.code (code_schema, code_name, code_desc) values ('public', 'cust_phone_type', 'Customer Phone Type');
select jsharmony.create_code('public','cust_phone_type','');
insert into code_cust_phone_type(code_seq,code_val,code_txt) values (1,'CELL','Cell');
insert into code_cust_phone_type(code_seq,code_val,code_txt) values (2,'WORK','Work');
insert into code_cust_phone_type(code_seq,code_val,code_txt) values (3,'HOME','Home');

/*********cust*********/
create sequence cust_cust_id_seq;
revoke all on sequence cust_cust_id_seq from PUBLIC;
grant all on sequence cust_cust_id_seq to postgres;
grant select,update on sequence cust_cust_id_seq to jsharmony_%%%INIT_DB_LCASE%%%_role_exec;
create table cust (
  cust_id bigint primary key not null default nextval('cust_cust_id_seq'),
  cust_sts character varying(32) not null,
  cust_stsdt date not null default jsharmony.my_today(),
  cust_name character varying(256) not null unique,
  cust_email character varying(256),
  cust_phone character varying(100),
  cust_phone_type character varying(32),
  cust_notes text,
  cust_agreement_tstmp timestamp without time zone,
  cust_etstmp timestamp without time zone not null default jsharmony.my_now(),
  cust_euser character varying(20) not null default jsharmony.my_db_user(),
  cust_mtstmp timestamp without time zone not null default jsharmony.my_now(),
  cust_muser character varying(20) not null default jsharmony.my_db_user(),
  foreign key (cust_sts) references code_cust_sts(code_val),
  foreign key (cust_phone_type) references code_cust_phone_type(code_val)
);
grant all on table cust to postgres;
revoke all on table cust from public;
grant select,insert,update,delete on table cust TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;

create function cust_insert() returns trigger language plpgsql as $_$
  declare trigger_defaultvars()
  begin
    log_audit_insert(new.cust_id,null,null,null,new.cust_id,null)
    return new;
  end;
$_$;
create trigger cust_insert before insert on cust for each row execute procedure cust_insert();
grant all on function cust_insert() to postgres;
grant all on function cust_insert() to public;
grant all on function cust_insert() to jsharmony_%%%DB_LCASE%%%_role_exec;
grant all on function cust_insert() to jsharmony_%%%DB_LCASE%%%_role_dev;

create function cust_update() returns trigger language plpgsql as $_$
  declare trigger_defaultvars()
  begin
    trigger_errorif(jsharmony.nequal(old.cust_id, new.cust_id),'ID cannot be updated')
    if(jsharmony.nequal(old.cust_sts, new.cust_sts)) then
      new.cust_stsdt = jsharmony.my_today();
    end if;

    log_audit_update_mult(old.cust_id,["cust_id","cust_name","cust_sts","cust_email","cust_phone","cust_phone_type","cust_notes","cust_agreement_tstmp"],null,null,null,old.cust_id,null)

    if audit_seq is not null then
      new.cust_mtstmp = jsharmony.my_now();
      new.cust_muser=jsharmony.my_db_user();
    end if;
    return new;
  end;
$_$;
create trigger cust_update before update on cust for each row execute procedure cust_update();
grant all on function cust_update() to postgres;
grant all on function cust_update() to public;
grant all on function cust_update() to jsharmony_%%%DB_LCASE%%%_role_exec;
grant all on function cust_update() to jsharmony_%%%DB_LCASE%%%_role_dev;

create function cust_delete() returns trigger language plpgsql as $_$
  declare trigger_defaultvars()
  begin
    log_audit_delete_mult(old.cust_id,["cust_id","cust_name","cust_sts","cust_email","cust_phone","cust_phone_type","cust_notes","cust_agreement_tstmp"],null,null,null,old.cust_id,null)
    return old;
  end;
$_$;
create trigger cust_delete before delete on cust for each row execute procedure cust_delete();
grant all on function cust_delete() to postgres;
grant all on function cust_delete() to public;
grant all on function cust_delete() to jsharmony_%%%DB_LCASE%%%_role_exec;
grant all on function cust_delete() to jsharmony_%%%DB_LCASE%%%_role_dev;

/* menu */
insert into jsharmony.menu (menu_group, menu_id, menu_sts, menu_id_parent, menu_name, menu_seq, menu_desc, menu_desc_ext, menu_desc_ext2, menu_cmd, menu_image, menu_snotes, menu_subcmd) values ('S', 300, 'ACTIVE', 1, 'Customer', 300, 'Customers', null, null, 'Cust_Listing', null, null, null);
insert into jsharmony.menu (menu_group, menu_id, menu_sts, menu_id_parent, menu_name, menu_seq, menu_desc, menu_desc_ext, menu_desc_ext2, menu_cmd, menu_image, menu_snotes, menu_subcmd) values ('S', 30001, 'ACTIVE', 300, 'Customer/Cust_Listing', 30001, 'Customer Listing', null, null, 'Cust_Listing', null, null, null);
insert into jsharmony.sys_menu_role (menu_id, sys_role_name) values (300, '*');
insert into jsharmony.sys_menu_role (menu_id, sys_role_name) values (30001, '*');

update jsharmony.menu set menu_cmd='Client/Dashboard' where menu_id=200 and menu_cmd='jsHarmonyFactory/Client/Dashboard';
insert into jsharmony.menu (menu_group, menu_id, menu_sts, menu_id_parent, menu_name, menu_seq, menu_desc, menu_desc_ext, menu_desc_ext2, menu_cmd, menu_image, menu_snotes, menu_subcmd) values ('C', 280001, 'ACTIVE', 2800, 'Client/Admin/Settings', 280001, 'Settings', null, null, 'Client/Admin/Settings', null, null, null);
insert into jsharmony.cust_menu_role (menu_id, cust_role_name) values (280001, 'CSYSADMIN');
