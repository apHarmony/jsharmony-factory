GRANT CREATE TABLE TO {{schema}}_role_dev;
GO

GRANT ALTER ON SCHEMA::[dbo] TO [{{schema}}_role_dev] AS [dbo];
GRANT ALTER ON SCHEMA::[jsharmony] TO [{{schema}}_role_dev] AS [dbo];
GO

if not exists(select principal_id from sys.database_principals where name = '%%%INIT_DB_USER%%%')
begin
  create user %%%INIT_DB_USER%%% for login %%%INIT_DB_USER%%%;
end
GO

alter role {{schema}}_role_dev add member %%%INIT_DB_USER%%%;
alter role {{schema}}_role_exec add member %%%INIT_DB_USER%%%;
GO
