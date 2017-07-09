create table a(id int);
drop table a;

DO
$$
BEGIN
IF NOT EXISTS (
      SELECT
      FROM   pg_catalog.pg_roles
      WHERE  rolname = 'jsharmony_%%%INIT_DB_LCASE%%%_role_exec') THEN
      create role jsharmony_%%%INIT_DB_LCASE%%%_role_exec;
   END IF;
END
$$;