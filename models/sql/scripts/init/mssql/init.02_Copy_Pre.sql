GRANT CREATE TABLE TO jsharmony_role_dev;
GO

GRANT ALTER ON SCHEMA::[dbo] TO [jsharmony_role_dev] AS [dbo];
GRANT ALTER ON SCHEMA::[jsharmony] TO [jsharmony_role_dev] AS [dbo];
GO

if not exists(select principal_id from sys.database_principals where name = '%%%INIT_DB_USER%%%')
begin
  create user %%%INIT_DB_USER%%% for login %%%INIT_DB_USER%%%;
end
GO

alter role jsharmony_role_dev add member %%%INIT_DB_USER%%%;
alter role jsharmony_role_exec add member %%%INIT_DB_USER%%%;
GO
