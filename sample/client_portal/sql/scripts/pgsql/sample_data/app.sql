SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET search_path = public, pg_catalog;

/*****SAMPLE DATA*****/
do $$
declare
  new_cust_id bigint;
  new_sys_user_id bigint;
begin
  with xrslt as (insert into cust(cust_sts,cust_name,cust_email,cust_phone,cust_phone_type,cust_notes) values ('ACTIVE','ACME Industries','contact@acme.com','234-234-2345','WORK','Sample Customer') returning cust_id)
    select cust_id into new_cust_id from xrslt;
  with xrslt as (insert into jsharmony.cust_user(cust_id,sys_user_sts,sys_user_fname,sys_user_lname,sys_user_email,sys_user_pw1,sys_user_pw2) values (new_cust_id,'ACTIVE','John','Smith','john@acme.com','123456','123456') returning sys_user_id)
    select sys_user_id into new_sys_user_id from xrslt;
  insert into jsharmony.cust_user_role(sys_user_id,cust_role_name) values (new_sys_user_id,'CSYSADMIN');
  insert into jsharmony.cust_user_role(sys_user_id,cust_role_name) values (new_sys_user_id,'CUSER');
end
$$;