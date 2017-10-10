
CREATE ROLE jsharmony_%%%INIT_DB_LCASE%%%_user;
ALTER ROLE jsharmony_%%%INIT_DB_LCASE%%%_user WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS PASSWORD 'md5e756fc2cc4ac65d3378b3edf1eaa98f5' VALID UNTIL 'infinity';

GRANT jsharmony_%%%INIT_DB_LCASE%%%_role_exec TO jsharmony_%%%INIT_DB_LCASE%%%_user GRANTED BY "postgres";
GRANT jsharmony_%%%INIT_DB_LCASE%%%_role_dev TO jsharmony_%%%INIT_DB_LCASE%%%_user GRANTED BY "postgres";