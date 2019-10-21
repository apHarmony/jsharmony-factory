SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET search_path = public, pg_catalog;

/* check_scope_id */
create function check_scope_id(in_scope character varying, in_scope_id bigint, in_cust_id bigint) returns bigint language plpgsql as $_$
  declare
    rslt bigint;
  begin

    rslt := null;

    if(in_cust_id is null) then
      if (in_scope = 'C') then select cust_id into rslt from cust where cust_id=in_scope_id;
      elsif (in_scope='U') then select sys_user_id into rslt from jsharmony.sys_user where sys_user_id=in_scope_id;
      elsif (in_scope='S') then select 1 into rslt;
      end if;
    else
      if (in_scope='C') then
        if (coalesce(public.get_cust_id('cust', in_scope_id),0) = in_cust_id) then select in_cust_id into rslt;
        end if;
      end if;
    end if;

    return(rslt);
  end;
$_$;
alter function check_scope_id(in_scope character varying, in_scope_id bigint, in_cust_id bigint) owner to postgres;
grant all on function check_scope_id(in_scope character varying, in_scope_id bigint, in_cust_id bigint) to postgres;
grant all on function check_scope_id(in_scope character varying, in_scope_id bigint, in_cust_id bigint) to public;
grant all on function check_scope_id(in_scope character varying, in_scope_id bigint, in_cust_id bigint) to jsharmony_%%%DB_LCASE%%%_role_exec;
grant all on function check_scope_id(in_scope character varying, in_scope_id bigint, in_cust_id bigint) to jsharmony_%%%DB_LCASE%%%_role_dev;

/* get_cust_id */
create function get_cust_id(in_tabn character varying, in_tabid bigint) returns bigint language plpgsql as $_$
  declare
    rslt bigint;
    next_tabid bigint;
    next_tabn character varying(32);
  begin
  
    rslt := null;

    if (in_tabn='cust') then
      select cust_id into rslt from cust where cust_id = in_tabid;
      return(in_tabid);
    end if;

    if (in_tabn='cust_user') then
      select cust_id into rslt from jsharmony.cust_user where sys_user_id = in_tabid;
      return(rslt);
    end if;

    if (in_tabn='cust_user_role') then
      select cust_id into rslt from jsharmony.cust_user_role inner join jsharmony.cust_user on jsharmony.cust_user.sys_user_id = jsharmony.cust_user_role.sys_user_id where cust_user_role_id = in_tabid;
      return(rslt);
    end if;

    if (in_tabn='doc') then
      select coalesce(code_code, code_val), doc_scope_id into next_tabn, next_tabid from jsharmony.code_doc_scope inner join jsharmony.doc on doc.doc_scope = code_doc_scope.code_val where doc_id = in_tabid;
      return(public.get_cust_id(next_tabn, next_tabid));
    end if;

    if (in_tabn='note') then
      select coalesce(code_code, code_val), note_scope_id into next_tabn, next_tabid from jsharmony.code_note_scope inner join jsharmony.note on note.note_scope = code_note_scope.code_val where note_id = in_tabid;
      return(public.get_cust_id(next_tabn, next_tabid));
    end if;

    return(null);
  end;
$_$;
alter function get_cust_id(in_tabn character varying, in_tabid bigint) owner to postgres;
grant all on function get_cust_id(in_tabn character varying, in_tabid bigint) to postgres;
grant all on function get_cust_id(in_tabn character varying, in_tabid bigint) to public;
grant all on function get_cust_id(in_tabn character varying, in_tabid bigint) to jsharmony_%%%DB_LCASE%%%_role_exec;
grant all on function get_cust_id(in_tabn character varying, in_tabid bigint) to jsharmony_%%%DB_LCASE%%%_role_dev;

/* get_item_id */
create function get_item_id(in_tabn character varying, in_tabid bigint) returns bigint language plpgsql as $_$
  declare
    rslt bigint;
    next_tabid bigint;
    next_tabn character varying(32);
  begin
  
    rslt := null;

    if (in_tabn='doc') then
      select coalesce(code_code, code_val), doc_scope_id into next_tabn, next_tabid from jsharmony.code_doc_scope inner join jsharmony.doc on doc.doc_scope = code_doc_scope.code_val where doc_id = in_tabid;
      return(public.get_item_id(next_tabn, next_tabid));
    end if;

    if (in_tabn='note') then
      select coalesce(code_code, code_val), note_scope_id into next_tabn, next_tabid from jsharmony.code_note_scope inner join jsharmony.note on note.note_scope = code_note_scope.code_val where note_id = in_tabid;
      return(public.get_item_id(next_tabn, next_tabid));
    end if;

    return(null);
  end;
$_$;
alter function get_item_id(in_tabn character varying, in_tabid bigint) owner to postgres;
grant all on function get_item_id(in_tabn character varying, in_tabid bigint) to postgres;
grant all on function get_item_id(in_tabn character varying, in_tabid bigint) to public;
grant all on function get_item_id(in_tabn character varying, in_tabid bigint) to jsharmony_%%%DB_LCASE%%%_role_exec;
grant all on function get_item_id(in_tabn character varying, in_tabid bigint) to jsharmony_%%%DB_LCASE%%%_role_dev;

/* Update param reference */
insert into jsharmony.param_sys (param_sys_process, param_sys_attrib, param_sys_val) VALUES ('SQL', 'check_scope_id', 'public.check_scope_id');
insert into jsharmony.param_sys (param_sys_process, param_sys_attrib, param_sys_val) VALUES ('SQL', 'get_cust_id', 'public.get_cust_id');
insert into jsharmony.param_sys (param_sys_process, param_sys_attrib, param_sys_val) VALUES ('SQL', 'get_item_id', 'public.get_item_id');
