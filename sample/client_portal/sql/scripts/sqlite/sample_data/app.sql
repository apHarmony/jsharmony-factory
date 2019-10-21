/*****SAMPLE DATA*****/
insert into cust(cust_id,cust_sts,cust_name,cust_email,cust_phone,cust_phone_type,cust_notes) values (1,'ACTIVE','ACME Industries','contact@acme.com','234-234-2345','WORK','Sample Customer');
insert into jsharmony.cust_user(sys_user_id,cust_id,sys_user_sts,sys_user_fname,sys_user_lname,sys_user_email,sys_user_pw1,sys_user_pw2) values (1,1,'ACTIVE','John','Smith','john@acme.com','123456','123456');
insert into jsharmony.cust_user_role(sys_user_id,cust_role_name) values (1,'CSYSADMIN');
insert into jsharmony.cust_user_role(sys_user_id,cust_role_name) values (1,'CUSER');