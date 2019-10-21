SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET search_path = public, pg_catalog;

/* Functions */
drop function if exists check_scope_id(in_scope character varying, in_scope_id bigint, in_cust_id bigint);
drop function if exists get_cust_id(in_tabn character varying, in_tabid bigint);
drop function if exists get_item_id(in_tabn character varying, in_tabid bigint);



delete from jsharmony.param_sys where param_sys_process='SQL' and param_sys_attrib='check_scope_id';
delete from jsharmony.param_sys where param_sys_process='SQL' and param_sys_attrib='get_cust_id';
delete from jsharmony.param_sys where param_sys_process='SQL' and param_sys_attrib='get_item_id';
