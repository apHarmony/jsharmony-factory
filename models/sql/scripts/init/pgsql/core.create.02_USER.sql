DO
$body$
begin
if not exists (select oid from pg_roles where rolname = '%%%INIT_DB_USER%%%') then
  create user %%%INIT_DB_USER%%% with password '%%%INIT_DB_PASS%%%';
end if;
end
$body$;
