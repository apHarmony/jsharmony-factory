DO
$$
BEGIN
IF NOT EXISTS (
      SELECT
      FROM   information_schema.applicable_roles
      WHERE  role_name = 'jsharmony_%%%INIT_DB_LCASE%%%_role_exec') THEN
      GRANT jsharmony_%%%INIT_DB_LCASE%%%_role_exec TO %%%INIT_DB_USER%%%;
   END IF;
END
$$;