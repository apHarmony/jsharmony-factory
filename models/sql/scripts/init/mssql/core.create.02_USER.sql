if ('%%%INIT_DB_USER%%%' <> '') and not exists(select principal_id from sys.server_principals where name = '%%%INIT_DB_USER%%%')
begin
  exec('create login %%%INIT_DB_USER%%% with password = ''%%%INIT_DB_PASS%%%''');
end
GO
