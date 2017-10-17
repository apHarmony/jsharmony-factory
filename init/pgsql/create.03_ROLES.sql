DO
$body$
begin
if not exists (select oid from pg_roles where rolname = 'jsharmony_%%%INIT_DB_LCASE%%%_role_exec') then
  create role jsharmony_%%%INIT_DB_LCASE%%%_role_exec;
end if;
if not exists (select oid from pg_roles where rolname = 'jsharmony_%%%INIT_DB_LCASE%%%_role_dev') then
  create role jsharmony_%%%INIT_DB_LCASE%%%_role_dev;
end if;
if not exists (
select pg_user.usename,
       pg_roles.rolname
from pg_user
join pg_auth_members on (pg_user.usesysid=pg_auth_members.member)
join pg_roles on (pg_roles.oid=pg_auth_members.roleid)
where pg_user.usename = 'jsharmony_%%%INIT_DB_LCASE%%%_user'
and   pg_roles.rolname = 'jsharmony_%%%INIT_DB_LCASE%%%_role_exec') then
  grant jsharmony_%%%INIT_DB_LCASE%%%_role_exec to jsharmony_%%%INIT_DB_LCASE%%%_user;
end if;
if not exists (
select pg_user.usename,
       pg_roles.rolname
from pg_user
join pg_auth_members on (pg_user.usesysid=pg_auth_members.member)
join pg_roles on (pg_roles.oid=pg_auth_members.roleid)
where pg_user.usename = 'jsharmony_%%%INIT_DB_LCASE%%%_user'
and   pg_roles.rolname = 'jsharmony_%%%INIT_DB_LCASE%%%_role_dev') then
  grant jsharmony_%%%INIT_DB_LCASE%%%_role_dev to jsharmony_%%%INIT_DB_LCASE%%%_user;
end if;
end
$body$;
