/*****SAMPLE DATA*****/
declare @cust_id bigint
declare @sys_user_id bigint
insert into cust(cust_sts,cust_name,cust_email,cust_phone,cust_phone_type,cust_notes) values ('ACTIVE','ACME Industries','contact@acme.com','234-234-2345','WORK','Sample Customer');
set @cust_id = scope_identity();
insert into jsharmony.cust_user(cust_id,sys_user_sts,sys_user_fname,sys_user_lname,sys_user_email,sys_user_pw1,sys_user_pw2) values (@cust_id,'ACTIVE','John','Smith','john@acme.com','123456','123456');
set @sys_user_id = scope_identity();
insert into jsharmony.cust_user_role(sys_user_id,cust_role_name) values (@sys_user_id,'CSYSADMIN');
insert into jsharmony.cust_user_role(sys_user_id,cust_role_name) values (@sys_user_id,'CUSER');