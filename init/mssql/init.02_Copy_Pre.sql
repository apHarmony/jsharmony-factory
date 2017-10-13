GRANT CREATE TABLE TO jsharmony_role_dev;
GO

GRANT ALTER ON SCHEMA::[dbo] TO [jsharmony_role_dev] AS [dbo];
GRANT ALTER ON SCHEMA::[jsharmony] TO [jsharmony_role_dev] AS [dbo];
GO

EXEC sp_addrolemember N'jsharmony_role_dev', N'%%%INIT_DB_USER%%%';
GO

EXEC sp_addrolemember N'jsharmony_role_exec', N'%%%INIT_DB_USER%%%';
GO