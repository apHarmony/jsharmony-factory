/* Functions */
if (object_id('check_scope_id', 'FN') is not null) drop function check_scope_id;
go
if (object_id('get_cust_id', 'FN') is not null) drop function get_cust_id;
go
if (object_id('get_item_id', 'FN') is not null) drop function get_item_id;
go



delete from jsharmony.param_sys where param_sys_process='SQL' and param_sys_attrib='check_scope_id';
delete from jsharmony.param_sys where param_sys_process='SQL' and param_sys_attrib='get_cust_id';
delete from jsharmony.param_sys where param_sys_process='SQL' and param_sys_attrib='get_item_id';
go