/*********Drop / delete existing tables / data*********/
delete from jsharmony.menu where menu_id in (300,30001,280001);
delete from jsharmony.sys_menu_role where menu_id in (300,30001,280001);

delete from jsharmony.code where code_name='cust_phone_type' and code_schema is null;
delete from jsharmony.code where code_name='cust_sts' and code_schema is null;
go

if (object_id('cust', 'U') is not null) drop table cust;
go
if (object_id('code_cust_phone_type', 'U') is not null) drop table code_cust_phone_type;
go
if (object_id('code_cust_sts', 'U') is not null) drop table code_cust_sts;
go

delete from jsharmony.doc;
delete from jsharmony.note;
delete from jsharmony.cust_user_role;
delete from jsharmony.cust_user;
go