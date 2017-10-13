if not exists(select principal_id from sys.server_principals where name = '%%%INIT_DB_USER%%%')
begin
  create login %%%INIT_DB_USER%%%
    with password = '%%%INIT_DB_PASS%%%';
end
GO

USE %%%INIT_DB%%%
GO

if not exists(select principal_id from sys.database_principals where name = '%%%INIT_DB_USER%%%')
begin
  create user %%%INIT_DB_USER%%% for login %%%INIT_DB_USER%%%;
end
GO
