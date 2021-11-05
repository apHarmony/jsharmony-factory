jsharmony.version_increment('jsHarmonyFactory',1,1,102,0);

delete from {schema}.sys_menu_role where menu_id in (select menu_id from {schema}.menu__tbl where menu_cmd='%%%NAMESPACE%%%Reports/SysUser_Listing');
delete from {schema}.menu__tbl where menu_id in (select menu_id from {schema}.menu__tbl where menu_cmd='%%%NAMESPACE%%%Reports/SysUser_Listing');