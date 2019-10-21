/*********Drop / delete existing tables / data*********/
delete from jsharmony.menu where menu_id in (300,30001);
delete from jsharmony.sys_menu_role where menu_id in (300,30001);

delete from jsharmony.code where code_name='cust_phone_type' and code_schema is null;
delete from jsharmony.code where code_name='cust_sts' and code_schema is null;

drop table if exists cust;
drop table if exists code_cust_phone_type;
drop table if exists code_cust_sts;

delete from jsharmony.doc;
delete from jsharmony.note;
delete from jsharmony.cust_user_role;
delete from jsharmony.cust_user;