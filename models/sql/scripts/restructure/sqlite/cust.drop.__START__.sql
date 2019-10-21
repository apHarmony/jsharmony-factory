/***************TABLE TRIGGERS***************/

drop trigger if exists {schema}_cust_user_role_insert;
drop trigger if exists {schema}_cust_user_role_update;
drop trigger if exists {schema}_cust_user_role_delete;

drop trigger if exists {schema}_cust_user_before_insert;
drop trigger if exists {schema}_cust_user_after_insert;
drop trigger if exists {schema}_cust_user_before_update;
drop trigger if exists {schema}_cust_user_after_update;
drop trigger if exists {schema}_cust_user_delete;

/***************VIEWS***************/
drop view if exists {schema}_v_cust_user_nostar;
drop view if exists {schema}_v_cust_menu_role_selection;
