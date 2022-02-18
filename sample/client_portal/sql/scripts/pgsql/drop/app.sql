SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET search_path = public, pg_catalog;

/*********Drop / delete existing tables / data*********/
delete from jsharmony.menu where menu_id in (300,30001,280001);
delete from jsharmony.sys_menu_role where menu_id in (300,30001,280001);

delete from jsharmony.code where code_name='cust_phone_type' and code_schema is null;
delete from jsharmony.code where code_name='cust_sts' and code_schema is null;

drop table if exists cust;
drop table if exists code_cust_phone_type;
drop table if exists code_cust_sts;

delete from jsharmony.doc;
delete from jsharmony.note;
delete from jsharmony.cust_user_role;
delete from jsharmony.cust_user;