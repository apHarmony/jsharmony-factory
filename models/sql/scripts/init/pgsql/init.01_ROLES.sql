DO
$body$
begin
if not exists (select oid from pg_roles where rolname = '{{schema}}_%%%INIT_DB_LCASE%%%_role_exec') then
  create role {{schema}}_%%%INIT_DB_LCASE%%%_role_exec;
end if;
if not exists (select oid from pg_roles where rolname = '{{schema}}_%%%INIT_DB_LCASE%%%_role_dev') then
  create role {{schema}}_%%%INIT_DB_LCASE%%%_role_dev;
end if;
if not exists (
select pg_user.usename,
       pg_roles.rolname
from pg_user
join pg_auth_members on (pg_user.usesysid=pg_auth_members.member)
join pg_roles on (pg_roles.oid=pg_auth_members.roleid)
where pg_user.usename = '%%%INIT_DB_USER%%%'
and   pg_roles.rolname = '{{schema}}_%%%INIT_DB_LCASE%%%_role_exec') then
  grant {{schema}}_%%%INIT_DB_LCASE%%%_role_exec to %%%INIT_DB_USER%%%;
end if;
if not exists (
select pg_user.usename,
       pg_roles.rolname
from pg_user
join pg_auth_members on (pg_user.usesysid=pg_auth_members.member)
join pg_roles on (pg_roles.oid=pg_auth_members.roleid)
where pg_user.usename = '%%%INIT_DB_USER%%%'
and   pg_roles.rolname = '{{schema}}_%%%INIT_DB_LCASE%%%_role_dev') then
  grant {{schema}}_%%%INIT_DB_LCASE%%%_role_dev to %%%INIT_DB_USER%%%;
end if;
end
$body$;
