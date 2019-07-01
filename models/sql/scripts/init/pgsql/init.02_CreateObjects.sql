--
--

-- Dumped from database version 9.5.5


SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: jsharmony; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA jsharmony;


ALTER SCHEMA jsharmony OWNER TO postgres;

SET search_path = jsharmony, pg_catalog;

--
-- Name: toaudit; Type: TYPE; Schema: jsharmony; Owner: postgres
--

CREATE TYPE toaudit AS (
	op text,
	audit_table_name text,
	cust_id bigint,
	item_id bigint,
	audit_ref_name text,
	audit_ref_id bigint,
	audit_subject text
);


ALTER TYPE toaudit OWNER TO postgres;

--
-- Name: audit(toaudit, bigint, bigint, character varying, text); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION audit(toa toaudit, INOUT par_audit_seq bigint, par_audit_table_id bigint, par_audit_column_name character varying DEFAULT NULL::character varying, par_audit_column_val text DEFAULT NULL::text) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
    DECLARE
      curdttm     timestamp default {schema}.my_now();
      myuser      text default {schema}.my_db_user();
      my_cust_id     bigint default null;
      my_item_id     bigint default null;
      my_audit_ref_name text default null;
      my_audit_ref_id   bigint default null;
      my_audit_subject     text default null;
      doc__tbl_audit_seq   bigint default null;
    BEGIN
        IF par_audit_seq is null THEN

          if (toa.op = 'DELETE') then
		select audit_seq,
		       cust_id,
		       item_id,
		       audit_ref_name,
		       audit_ref_id,
		       audit_subject
		  into doc__tbl_audit_seq,
		       my_cust_id,
		       my_item_id,
		       my_audit_ref_name,
		       my_audit_ref_id,
		       my_audit_subject
		  from {schema}.audit__tbl
                 where audit_table_name = toa.audit_table_name
		   and audit_table_id = par_audit_table_id
		   and audit_op = 'I'
                 order by audit_seq desc
		 fetch first 1 rows only;
          ELSE
            my_cust_id = toa.cust_id;
            my_item_id = toa.item_id;
            my_audit_ref_name = toa.audit_ref_name;
            my_audit_ref_id = toa.audit_ref_id;
            my_audit_subject = toa.audit_subject;
          END if;
        
          insert into {schema}.audit__tbl 
                            (audit_table_name, audit_table_id, audit_op, audit_user, audit_tstmp, cust_id, item_id, audit_ref_name, audit_ref_id, audit_subject)
                     values (toa.audit_table_name,
                             par_audit_table_id,
                             case toa.op when 'INSERT' then 'I'
                                         when 'UPDATE' then 'U'
                                         when 'DELETE' then 'D'
                                         else NULL end,
                             myuser,
                             curdttm,
                             my_cust_id,
                             my_item_id,
                             my_audit_ref_name,
                             my_audit_ref_id,
                             my_audit_subject)
                     returning audit_seq into par_audit_seq; 
        END IF;
        IF toa.op in ('UPDATE','DELETE') THEN
          insert into {schema}.audit_detail 
                            (audit_seq, audit_column_name, audit_column_val)
                     values (par_audit_seq, upper(par_audit_column_name), par_audit_column_val);
        END IF;           
    END;
$$;


ALTER FUNCTION {schema}.audit(toa toaudit, INOUT par_audit_seq bigint, par_audit_table_id bigint, par_audit_column_name character varying, par_audit_column_val text) OWNER TO postgres;

--
-- Name: audit_base(toaudit, bigint, bigint, character varying, text); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION audit_base(toa toaudit, INOUT par_audit_seq bigint, par_audit_table_id bigint, par_audit_column_name character varying DEFAULT NULL::character varying, par_audit_column_val text DEFAULT NULL::text) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
    DECLARE
      curdttm     timestamp default {schema}.my_now();
      myuser      text default {schema}.my_db_user();
      my_audit_ref_name text default null;
      my_audit_ref_id   bigint default null;
      my_audit_subject     text default null;
      doc__tbl_audit_seq   bigint default null;
    BEGIN
        IF par_audit_seq is null THEN

          if (toa.op = 'DELETE') then
		select audit_seq,
		       audit_ref_name,
		       audit_ref_id,
		       audit_subject
		  into doc__tbl_audit_seq,
		       my_audit_ref_name,
		       my_audit_ref_id,
		       my_audit_subject
		  from {schema}.audit__tbl
                 where audit_table_name = toa.audit_table_name
		   and audit_table_id = par_audit_table_id
		   and audit_op = 'I'
                 order by audit_seq desc
		 fetch first 1 rows only;
          ELSE
            my_audit_ref_name = toa.audit_ref_name;
            my_audit_ref_id = toa.audit_ref_id;
            my_audit_subject = toa.audit_subject;
          END if;
        
          insert into {schema}.audit__tbl 
                            (audit_table_name, audit_table_id, audit_op, audit_user, audit_tstmp, audit_ref_name, audit_ref_id, audit_subject)
                     values (toa.audit_table_name,
                             par_audit_table_id,
                             case toa.op when 'INSERT' then 'I'
                                         when 'UPDATE' then 'U'
                                         when 'DELETE' then 'D'
                                         else NULL end,
                             myuser,
                             curdttm,
                             my_audit_ref_name,
                             my_audit_ref_id,
                             my_audit_subject)
                     returning audit_seq into par_audit_seq; 
        END IF;
        IF toa.op in ('UPDATE','DELETE') THEN
          insert into {schema}.audit_detail 
                             (audit_seq, audit_column_name, audit_column_val)
                     values (par_audit_seq, upper(par_audit_column_name), par_audit_column_val);
        END IF;           
    END;
$$;


ALTER FUNCTION {schema}.audit_base(toa toaudit, INOUT par_audit_seq bigint, par_audit_table_id bigint, par_audit_column_name character varying, par_audit_column_val text) OWNER TO postgres;

--
-- Name: log_audit_info(timestamp without time zone, character varying, timestamp without time zone, character varying); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION log_audit_info(timestamp without time zone, character varying, timestamp without time zone, character varying) RETURNS character varying
    LANGUAGE sql
    AS $_$select 'INFO'||chr(13)||chr(10)|| 
               '     Entered:  '||{schema}.my_mmddyyhhmi($1)||'  '||{schema}.my_db_user_fmt($2)||
			   chr(13)||chr(10)|| 
               'Last Updated:  '||{schema}.my_mmddyyhhmi($3)||'  '||{schema}.my_db_user_fmt($4);$_$;


ALTER FUNCTION {schema}.log_audit_info(timestamp without time zone, character varying, timestamp without time zone, character varying) OWNER TO postgres;

--
-- Name: check_code(character varying, character varying); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION check_code(in_tblname character varying, in_code_val character varying) RETURNS bigint
    LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER COST 10
    AS $$
DECLARE
    rslt     bigint;
    runmesql text;
BEGIN

  rslt := {schema}.check_code_exec(in_tblname, in_code_val);

  RETURN rslt;

EXCEPTION WHEN OTHERS THEN

  RETURN -1;

END;
$$;


ALTER FUNCTION {schema}.check_code(in_tblname character varying, in_code_val character varying) OWNER TO postgres;

--
-- Name: check_code2(character varying, character varying, character varying); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION check_code2(in_tblname character varying, in_code_val1 character varying, in_code_va12 character varying) RETURNS bigint
    LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER COST 10
    AS $$
DECLARE
    rslt     bigint;
    runmesql text;
BEGIN

  rslt := {schema}.check_code2_exec(in_tblname, in_code_val1, in_code_va12);

  RETURN rslt;

EXCEPTION WHEN OTHERS THEN

  RETURN -1;

END;
$$;


ALTER FUNCTION {schema}.check_code2(in_tblname character varying, in_code_val1 character varying, in_code_va12 character varying) OWNER TO postgres;

--
-- Name: check_code2_exec(character varying, character varying, character varying); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION check_code2_exec(in_tblname character varying, in_code_val1 character varying, in_code_va12 character varying) RETURNS bigint
    LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER COST 10
    AS $_$
DECLARE
    rslt     bigint;
    runmesql text;
BEGIN

  rslt := 0;

  select 'select count(*) from ' || schemaname || '.' || tablename ||
           ' where code_val1 = $1 and code_va12 = $2;'
    into runmesql
    from pg_tables
   where tablename = lower(in_tblname) 
   order by (case schemaname when '{schema}' then 1 else 2 end), schemaname
   limit 1;

  EXECUTE runmesql INTO rslt USING in_code_val1, in_code_va12;
  
  RETURN rslt;
END;
$_$;


ALTER FUNCTION {schema}.check_code2_exec(in_tblname character varying, in_code_val1 character varying, in_code_va12 character varying) OWNER TO postgres;

--
-- Name: check_code_exec(character varying, character varying); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION check_code_exec(in_tblname character varying, in_code_val character varying) RETURNS bigint
    LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER COST 10
    AS $_$
DECLARE
    rslt     bigint;
    runmesql text;
BEGIN

  rslt := 0;

  select 'select count(*) from ' || schemaname || '.' || tablename || ' where code_val = $1 ;'
    into runmesql
    from pg_tables
   where tablename = lower(in_tblname) 
   order by (case schemaname when '{schema}' then 1 else 2 end), schemaname
   limit 1;

  EXECUTE runmesql INTO rslt USING in_code_val;
  
  RETURN rslt;
END;
$_$;


ALTER FUNCTION {schema}.check_code_exec(in_tblname character varying, in_code_val character varying) OWNER TO postgres;

--
-- Name: check_foreign_key(character varying, bigint); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION check_foreign_key(in_tblname character varying, in_tblid bigint) RETURNS bigint
    LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER COST 10
    AS $$
DECLARE
    rslt     bigint;
    runmesql text;
BEGIN

  rslt := {schema}.check_foreign_key_exec(in_tblname, in_tblid);

  RETURN rslt;

EXCEPTION WHEN OTHERS THEN

  RETURN -1;

END;
$$;


ALTER FUNCTION {schema}.check_foreign_key(in_tblname character varying, in_tblid bigint) OWNER TO postgres;

--
-- Name: check_foreign_key_exec(character varying, bigint); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION check_foreign_key_exec(in_tblname character varying, in_tblid bigint) RETURNS bigint
    LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER COST 10
    AS $_$
DECLARE
    rslt     bigint;
    runmesql text;
BEGIN

  rslt := 0;

  select 'select count(*) from ' || schemaname || '.' || tablename || 
           ' where ' || tablename || '_id = $1 ;'
    into runmesql
    from pg_tables
   where tablename = lower(in_tblname) 
   order by (case schemaname when '{schema}' then 1 else 2 end), schemaname
   limit 1;

  EXECUTE runmesql INTO rslt USING in_tblid;
  
  RETURN rslt;
END;
$_$;


ALTER FUNCTION {schema}.check_foreign_key_exec(in_tblname character varying, in_tblid bigint) OWNER TO postgres;

--
-- Name: check_param(character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION check_param(in_table character varying, in_process character varying, in_attrib character varying, in_val character varying) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE 
  cust bigint = 0;
  param_type VARCHAR(32) = NULL;
  code_name VARCHAR(128);
  is_param_app boolean;
  is_param_user boolean;
  is_param_sys boolean;
BEGIN

  SELECT param__tbl.param_type,
         param__tbl.code_name,
         param__tbl.is_param_app,
         param__tbl.is_param_user,
         param__tbl.is_param_sys
    INTO param_type,
         code_name,
         is_param_app,
         is_param_user,
         is_param_sys
    FROM {schema}.param__tbl
   WHERE param__tbl.param_process = in_process
     AND param__tbl.param_attrib = in_attrib;      

  IF param_type IS NULL THEN
    RETURN 'Process parameter '||in_process||'.'||in_attrib||' is not defined in param__tbl';
  END IF;  
  
  IF upper(in_table) NOT IN ('param_app','param_user','param_sys') THEN
    RETURN 'Table '||upper(in_table) || ' is not defined';
  END IF;  
 
  IF upper(in_table)='param_app' AND is_param_app=false THEN
    RETURN 'Process parameter '||in_process||'.'||in_attrib||' is not assigned to '||upper(in_table);
  ELSIF upper(in_table)='param_user' AND is_param_user=false THEN
    RETURN 'Process parameter '||in_process||'.'||in_attrib||' is not assigned to '||upper(in_table);
  ELSIF upper(in_table)='param_sys' AND is_param_sys=false THEN
    RETURN 'Process parameter '||in_process||'.'||in_attrib||' is not assigned to '||upper(in_table);
  END IF;  

  IF coalesce(in_val,'') = '' THEN
    RETURN 'Value has to be present';
  END IF;  

  IF param_type='note__tbl' AND not {schema}.myISNUMERIC(in_val) THEN
    RETURN 'Value '||in_val||' is not numeric';
  END IF;  

  IF coalesce(code_name,'') != '' THEN

    select count(*)
      into cust
      from {schema}.code_sys_base
     where code_name = code_name
       and code_val = in_val; 
       
    IF cust=0 THEN
      RETURN 'Incorrect value '||in_val;
    END IF;     
       
  END IF;
  
  return NULL;
/*   
EXCEPTION
  when others then
    return 'unrecognized error';  
*/    
END;
$$;


ALTER FUNCTION {schema}.check_param(in_table character varying, in_process character varying, in_attrib character varying, in_val character varying) OWNER TO postgres;

--
-- Name: cust_user_iud(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION cust_user_iud() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
      curdttm   timestamp default {schema}.my_now();
      myuser    text default {schema}.my_db_user();
      audit_seq   bigint default NULL;
      my_id     bigint default case TG_OP when 'DELETE' then OLD.sys_user_id else NEW.sys_user_id end;
      newpw     text default NULL;
      hash      bytea default NULL;
      my_toa    {schema}.toaudit;
    BEGIN

        /**********************************/
        /* INITIALIZE                     */ 
        /**********************************/

        my_toa.op := TG_OP;
        my_toa.audit_table_name := upper(TG_audit_table_name::text);
        my_toa.cust_id := case when TG_OP = 'DELETE' then NULL else NEW.cust_id end;
        my_toa.item_id := NULL;
        my_toa.audit_ref_name := NULL;
        my_toa.audit_ref_id := NULL;
        my_toa.audit_subject := case when TG_OP = 'DELETE' then NULL else coalesce(NEW.sys_user_lname,'')||', '||coalesce(NEW.sys_user_fname,'') end;
         

        /**********************************/
        /* PERFORM CHECKS                 */ 
        /**********************************/

        IF TG_OP = 'UPDATE'
           and
           {schema}.nequal(NEW.sys_user_id, OLD.sys_user_id) THEN
          RAISE EXCEPTION  'Application Error - ID cannot be updated.';
        END IF;

        IF TG_OP = 'UPDATE'
           and
           {schema}.nequal(NEW.cust_id, OLD.cust_id) THEN
          RAISE EXCEPTION  'Application Error - Customer ID cannot be updated.';
        END IF;

        IF TG_OP = 'INSERT' or TG_OP = 'UPDATE' THEN
	  IF {schema}.nequal(NEW.sys_user_pw1, NEW.sys_user_pw2) THEN
            RAISE EXCEPTION  'Application Error - New Password and Repeat Password are different.';
          ELSIF (TG_OP='INSERT' or NEW.sys_user_pw1 is not null)  AND length(btrim(NEW.sys_user_pw1::text)) < 6  THEN
            RAISE EXCEPTION  'Application Error - Password length - at least 6 characters required.';
          END IF;            
        END IF;


        IF (TG_OP='INSERT' 
            OR 
            TG_OP='UPDATE' AND {schema}.nequal(NEW.cust_id, OLD.cust_id)) THEN
          IF {schema}.check_foreign_key('C', NEW.cust_id) <= 0THEN
            RAISE EXCEPTION  'Table cust does not contain record % .', NEW.cust_id::text ;
	  END IF;
	END IF;   


        /**********************************/
        /* AUDIT TRAIL                    */ 
        /**********************************/

        IF TG_OP = 'INSERT' THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id);  
        END IF;


        IF (case when TG_OP = 'DELETE' then OLD.sys_user_id is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.sys_user_id, OLD.sys_user_id) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'sys_user_id', OLD.sys_user_id::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.cust_id is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.cust_id, OLD.cust_id) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'cust_id', OLD.cust_id::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.sys_user_sts is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.sys_user_sts, OLD.sys_user_sts) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'sys_user_sts', OLD.sys_user_sts::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.sys_user_fname is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.sys_user_fname, OLD.sys_user_fname) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'sys_user_fname', OLD.sys_user_fname::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.sys_user_mname is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.sys_user_mname, OLD.sys_user_mname) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'sys_user_mname', OLD.sys_user_mname::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.sys_user_lname is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.sys_user_lname, OLD.sys_user_lname) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'sys_user_lname', OLD.sys_user_lname::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.sys_user_jobtitle is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.sys_user_jobtitle, OLD.sys_user_jobtitle) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'sys_user_jobtitle', OLD.sys_user_jobtitle::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.sys_user_bphone is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.sys_user_bphone, OLD.sys_user_bphone) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'sys_user_bphone', OLD.sys_user_bphone::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.sys_user_cphone is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.sys_user_cphone, OLD.sys_user_cphone) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'sys_user_cphone', OLD.sys_user_cphone::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.sys_user_email is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.sys_user_email, OLD.sys_user_email) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'sys_user_email', OLD.sys_user_email::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.sys_user_lastlogin_tstmp is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.sys_user_lastlogin_tstmp, OLD.sys_user_lastlogin_tstmp) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'sys_user_lastlogin_tstmp', OLD.sys_user_lastlogin_tstmp::text);  
        END IF;

      
        IF TG_OP = 'UPDATE' and coalesce(NEW.sys_user_pw1,'') <> '' THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'sys_user_PW','*');  
        END IF;


        /**********************************/
        /* UPDATES AND OTHER TABLES       */ 
        /**********************************/

        IF TG_OP in ('INSERT', 'UPDATE') THEN
        
          newpw = btrim(NEW.sys_user_pw1);
          if newpw is not null then
            hash = my_hash('C', NEW.sys_user_id, newpw);
            if (hash is null) then
              RAISE EXCEPTION  'Application Error - Missing or Incorrect Password.';
            end if;
	    NEW.sys_user_hash := hash;
	    NEW.sys_user_pw1 = NULL;
	    NEW.sys_user_pw2 = NULL;
          else
            hash = NULL;
          end if;
            
          IF TG_OP = 'INSERT' THEN
            NEW.sys_user_stsdt := curdttm;
	    NEW.sys_user_etstmp := curdttm;
	    NEW.sys_user_euser := myuser;
	    NEW.sys_user_mtstmp := curdttm;
	    NEW.sys_user_muser := myuser;
          ELSIF TG_OP = 'UPDATE' THEN
            IF audit_seq is not NULL THEN
              if {schema}.nequal(OLD.sys_user_sts, NEW.sys_user_sts) then
                NEW.sys_user_stsdt := curdttm;
              end if;
	      NEW.sys_user_mtstmp := curdttm;
	      NEW.sys_user_muser := myuser;
	    END IF;  
          END IF;
        END IF;


        /**********************************/
        /* RETURN                         */ 
        /**********************************/
    
        IF TG_OP = 'INSERT' THEN
          RETURN NEW;
        ELSIF TG_OP = 'UPDATE' THEN
          RETURN NEW;
        ELSIF TG_OP = 'DELETE' THEN
          RETURN OLD;
        END IF;

    END;
$$;


ALTER FUNCTION {schema}.cust_user_iud() OWNER TO postgres;

--
-- Name: cust_user_iud_after_insert(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION cust_user_iud_after_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        IF TG_OP = 'INSERT' THEN
          insert into {schema}.cust_user_role (sys_user_id, cust_role_name) values(NEW.sys_user_id, 'C*');
        END IF;

        RETURN NEW;   

    END;
$$;


ALTER FUNCTION {schema}.cust_user_iud_after_insert() OWNER TO postgres;

--
-- Name: cust_user_role_iud(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION cust_user_role_iud() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
    DECLARE
      curdttm    timestamp default {schema}.my_now();
      myuser     text default {schema}.my_db_user();
      audit_seq    bigint default NULL;
      my_id      bigint default case TG_OP when 'DELETE' then OLD.cust_user_role_id else NEW.cust_user_role_id end;
      my_toa     {schema}.toaudit;

      sqlcmd     text;
      get_cust_id     text;
      wk_cust_id    bigint;
      wk_sys_user_id   bigint;
      
    BEGIN

        /**********************************/
        /* INITIALIZE                     */ 
        /**********************************/

        select param_cur_val
          into get_cust_id
          from {schema}.v_param_cur 
         where param_cur_process = 'SQL'
           and param_cur_attrib = 'get_cust_id'; 
        wk_sys_user_id := case TG_OP when 'DELETE' then OLD.sys_user_id else NEW.sys_user_id end;  
        sqlcmd := 'select '||get_cust_id||'(''cust_user'',$1);';
        EXECUTE sqlcmd INTO wk_cust_id USING wk_sys_user_id;


        my_toa.op := TG_OP;
        my_toa.audit_table_name := upper(TG_audit_table_name::text);
        my_toa.cust_id := wk_cust_id;
        my_toa.item_id := NULL;
        my_toa.audit_ref_name := NULL;
        my_toa.audit_ref_id := NULL;
        my_toa.audit_subject := case when TG_OP = 'DELETE' then NULL else (select coalesce(sys_user_lname,'')||', '||coalesce(sys_user_fname,'') 
                                                                    from {schema}.cust_user 
                                                                   where sys_user_id = NEW.sys_user_id) end;
         

        /**********************************/
        /* PERFORM CHECKS                 */ 
        /**********************************/

        IF TG_OP = 'UPDATE'
           and
           {schema}.nequal(NEW.cust_user_role_id, OLD.cust_user_role_id) THEN
          RAISE EXCEPTION  'Application Error - ID cannot be updated.';
        END IF;

        IF TG_OP = 'UPDATE'
           and
           {schema}.nequal(NEW.sys_user_id, OLD.sys_user_id) THEN
          RAISE EXCEPTION  'Application Error - Customer User ID cannot be updated.';
        END IF;

/*
  THIS CODE DOES NOT BELONG IN jsharmony trigger - IT IS REQUIRED FOR BETTER PROTECTION IN ATRAX
  BUT COULD BE SKIPPED


        IF TG_OP = 'INSERT'
           OR
           TG_OP = 'UPDATE' THEN

	  IF EXISTS (select 1
	               from CF
                      inner join cust_user on cust_user.cust_id = CF.cust_id
                      where cust_user.sys_user_id = NEW.sys_user_id
		        and CF.CF_TYPE = 'LVL2') THEN
	    IF NEW.cust_role_name not in ('C*','CUSER','CMGR','CADMIN') THEN
              RAISE EXCEPTION  'Role % not compatible with LVL2', coalesce(NEW.cust_role_name,'');
            END IF;
            
	  ELSE
	  
	    IF NEW.cust_role_name not in ('C*','CL1') THEN
              RAISE EXCEPTION  'Role % not compatible with LVL1', coalesce(NEW.cust_role_name,'');
            END IF;

	  END IF;

	END IF;

*/


        /**********************************/
        /* AUDIT TRAIL                    */ 
        /**********************************/
        IF TG_OP = 'INSERT' THEN
          SELECT par_audit_seq INTO audit_seq from {schema}.audit(my_toa, audit_seq, my_id);  
        END IF;


        IF (case when TG_OP = 'DELETE' then OLD.cust_user_role_id is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.cust_user_role_id, OLD.cust_user_role_id) end) THEN
          SELECT par_audit_seq INTO audit_seq from {schema}.audit(my_toa, audit_seq, my_id, 'cust_user_role_id', OLD.cust_user_role_id::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.sys_user_id is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.sys_user_id, OLD.sys_user_id) end) THEN
          SELECT par_audit_seq INTO audit_seq from {schema}.audit(my_toa, audit_seq, my_id, 'sys_user_id', OLD.sys_user_id::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.cust_role_name is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.cust_role_name, OLD.cust_role_name) end) THEN
          SELECT par_audit_seq INTO audit_seq from {schema}.audit(my_toa, audit_seq, my_id, 'cust_role_name', OLD.cust_role_name::text);  
        END IF;


        /**********************************/
        /* UPDATES AND OTHER TABLES       */ 
        /**********************************/

        /**********************************/
        /* RETURN                         */ 
        /**********************************/
    
        IF TG_OP = 'INSERT' THEN
          RETURN NEW;
        ELSIF TG_OP = 'UPDATE' THEN
          RETURN NEW;
        ELSIF TG_OP = 'DELETE' THEN
          RETURN OLD;
        END IF;

    END;
$_$;


ALTER FUNCTION {schema}.cust_user_role_iud() OWNER TO postgres;

--
-- Name: create_code_app(character varying, character varying, character varying); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION create_code_app(in_code_schema character varying, in_code_name character varying, in_code_desc character varying) RETURNS bigint
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE
    rslt          bigint;
    wk_code_schema text;
    runmesql      text;
BEGIN

  rslt := 0;

  wk_code_schema = coalesce(in_code_schema, 'public');

  SET client_min_messages to ERROR;

  runmesql := 'CREATE TABLE '||wk_code_schema||'.code_app_'||in_code_name||' '
            ||'( '
            ||'  CONSTRAINT code_app_'||in_code_name||'_pkey PRIMARY KEY (code_app_id), '
            ||'  CONSTRAINT code_app_'||in_code_name||'_code_val_key UNIQUE (code_val), '
            ||'  CONSTRAINT code_app_'||in_code_name||'_code_txt_key UNIQUE (code_txt) '
            ||') '
            ||'INHERITS ('||'{schema}'||'.code_app_base) '
            ||'WITH ( '
            ||'  OIDS=FALSE '
            ||');';
  EXECUTE runmesql ; 

  runmesql := 'CREATE TRIGGER code_app_'||in_code_name||' '
            ||'BEFORE INSERT OR UPDATE OR DELETE '
            ||'ON '||wk_code_schema||'.code_app_'||in_code_name||' ' 
            ||'FOR EACH ROW '
            ||'EXECUTE PROCEDURE '||'{schema}'||'.code_app_base_iud();';
  EXECUTE runmesql ; 

  runmesql := 'COMMENT ON TABLE '||wk_code_schema||'.code_app_'||in_code_name||' IS ''User Codes - '||coalesce(in_code_desc,'')||''';';
  EXECUTE runmesql ; 

  runmesql := 'GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE '||wk_code_schema||'.code_app_'||in_code_name||' TO {schema}_'||lower(current_database())||'_role_exec;';
  EXECUTE runmesql ; 

  runmesql := 'GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE '||wk_code_schema||'.code_app_'||in_code_name||' TO {schema}_'||lower(current_database())||'_role_dev;';
  EXECUTE runmesql ; 

  RETURN rslt;

EXCEPTION WHEN OTHERS THEN

  raise notice '% %', SQLERRM, SQLSTATE;

END;
$$;


ALTER FUNCTION {schema}.create_code_app(in_code_schema character varying, in_code_name character varying, in_code_desc character varying) OWNER TO postgres;

--
-- Name: create_code2_app(character varying, character varying, character varying); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION create_code2_app(in_code_schema character varying, in_code_name character varying, in_code_desc character varying) RETURNS bigint
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE
    rslt          bigint;
    wk_code_schema text;
    runmesql      text;
BEGIN

  rslt := 0;

  wk_code_schema = coalesce(in_code_schema, 'public');

  SET client_min_messages to ERROR;

  runmesql := 'CREATE TABLE '||wk_code_schema||'.code2_app_'||in_code_name||' '
            ||'( '
            ||'  CONSTRAINT code2_app_'||in_code_name||'_pkey PRIMARY KEY (code2_app_id), '
            ||'  CONSTRAINT code2_app_'||in_code_name||'_code_val1_code_va12_key UNIQUE (code_val1,code_va12), '
            ||'  CONSTRAINT code2_app_'||in_code_name||'_code_val1_code_txt_key UNIQUE (code_val1,code_txt) '
            ||') '
            ||'INHERITS ('||'{schema}'||'.code2_app_base) '
            ||'WITH ( '
            ||'  OIDS=FALSE '
            ||');';

  EXECUTE runmesql ; 

  runmesql := 'CREATE TRIGGER code2_app_'||in_code_name||' '
            ||'BEFORE INSERT OR UPDATE OR DELETE '
            ||'ON '||wk_code_schema||'.code2_app_'||in_code_name||' ' 
            ||'FOR EACH ROW '
            ||'EXECUTE PROCEDURE '||'{schema}'||'.code2_app_base_iud();';
  EXECUTE runmesql ; 

  runmesql := 'COMMENT ON TABLE '||wk_code_schema||'.code2_app_'||in_code_name||' IS ''User Codes 2 - '||coalesce(in_code_desc,'')||''';';
  EXECUTE runmesql ; 

  runmesql := 'GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE '||wk_code_schema||'.code2_app_'||in_code_name||' TO {schema}_'||lower(current_database())||'_role_exec;';
  EXECUTE runmesql ; 

  runmesql := 'GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE '||wk_code_schema||'.code2_app_'||in_code_name||' TO {schema}_'||lower(current_database())||'_role_dev;';
  EXECUTE runmesql ; 

  RETURN rslt;

EXCEPTION WHEN OTHERS THEN

  raise notice '% %', SQLERRM, SQLSTATE;

END;
$$;


ALTER FUNCTION {schema}.create_code2_app(in_code_schema character varying, in_code_name character varying, in_code_desc character varying) OWNER TO postgres;

--
-- Name: create_code_sys(character varying, character varying, character varying); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION create_code_sys(in_code_schema character varying, in_code_name character varying, in_code_desc character varying) RETURNS bigint
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE
    rslt          bigint;
    wk_code_schema text;
    runmesql      text;
BEGIN

  rslt := 0;

  wk_code_schema = coalesce(in_code_schema, 'public');

  SET client_min_messages to ERROR;

  runmesql := 'CREATE TABLE '||wk_code_schema||'.code_sys_'||in_code_name||' '
            ||'( '
            ||'  CONSTRAINT code_sys_'||in_code_name||'_pkey PRIMARY KEY (code_sys_id), '
            ||'  CONSTRAINT code_sys_'||in_code_name||'_code_val_key UNIQUE (code_val), '
            ||'  CONSTRAINT code_sys_'||in_code_name||'_code_txt_key UNIQUE (code_txt) '
            ||') '
            ||'INHERITS ('||'{schema}'||'.code_sys_base) '
            ||'WITH ( '
            ||'  OIDS=FALSE '
            ||');';

  EXECUTE runmesql ; 

  runmesql := 'COMMENT ON TABLE '||wk_code_schema||'.code_sys_'||in_code_name||' IS ''System Codes - '||coalesce(in_code_desc,'')||''';';
  EXECUTE runmesql ; 

  runmesql := 'GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE '||wk_code_schema||'.code_sys_'||in_code_name||' TO {schema}_'||lower(current_database())||'_role_exec;';
  EXECUTE runmesql ; 

  runmesql := 'GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE '||wk_code_schema||'.code_sys_'||in_code_name||' TO {schema}_'||lower(current_database())||'_role_dev;';
  EXECUTE runmesql ; 

  RETURN rslt;

EXCEPTION WHEN OTHERS THEN

  raise notice '% %', SQLERRM, SQLSTATE;

END;
$$;


ALTER FUNCTION {schema}.create_code_sys(in_code_schema character varying, in_code_name character varying, in_code_desc character varying) OWNER TO postgres;

--
-- Name: create_code2_sys(character varying, character varying, character varying); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION create_code2_sys(in_code_schema character varying, in_code_name character varying, in_code_desc character varying) RETURNS bigint
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE
    rslt          bigint;
    wk_code_schema text;
    runmesql      text;
BEGIN

  rslt := 0;

  wk_code_schema = coalesce(in_code_schema, 'public');

  SET client_min_messages to ERROR;

  runmesql := 'CREATE TABLE '||wk_code_schema||'.code2_sys_'||in_code_name||' '
            ||'( '
            ||'  CONSTRAINT code2_sys_'||in_code_name||'_pkey PRIMARY KEY (code2_sys_id), '
            ||'  CONSTRAINT code2_sys_'||in_code_name||'_code_val1_code_va12_key UNIQUE (code_val1, code_va12), '
            ||'  CONSTRAINT code2_sys_'||in_code_name||'_code_val1_code_txt_key UNIQUE (code_val1, code_txt) '
            ||') '
            ||'INHERITS ('||'{schema}'||'.code2_sys_base) '
            ||'WITH ( '
            ||'  OIDS=FALSE '
            ||');';

  EXECUTE runmesql ; 

  runmesql := 'COMMENT ON TABLE '||wk_code_schema||'.code2_sys_'||in_code_name||' IS ''System Codes 2 - '||coalesce(in_code_desc,'')||''';';
  EXECUTE runmesql ; 

  runmesql := 'GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE '||wk_code_schema||'.code2_sys_'||in_code_name||' TO {schema}_'||lower(current_database())||'_role_exec;';
  EXECUTE runmesql ; 

  runmesql := 'GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE '||wk_code_schema||'.code2_sys_'||in_code_name||' TO {schema}_'||lower(current_database())||'_role_dev;';
  EXECUTE runmesql ; 

  RETURN rslt;

EXCEPTION WHEN OTHERS THEN

  raise notice '% %', SQLERRM, SQLSTATE;

END;
$$;


ALTER FUNCTION {schema}.create_code2_sys(in_code_schema character varying, in_code_name character varying, in_code_desc character varying) OWNER TO postgres;

--
-- Name: doc__tbl_iud(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION doc__tbl_iud() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
    DECLARE
      curdttm    timestamp default {schema}.my_now();
      myuser     text default {schema}.my_db_user();
      audit_seq    bigint default NULL;
      my_id      bigint default case TG_OP when 'DELETE' then OLD.doc_id else NEW.doc_id end;
      my_toa     {schema}.toaudit;

      sqlcmd     text;
      get_cust_id     text = NULL;
      get_item_id     text = NULL;
      doc_ctgr_table text = NULL;

      my_cust_id    bigint = NULL;
      my_item_id    bigint = NULL;
      user_cust_id  bigint = NULL;
      my_doc_scope text = NULL;
      my_doc_scope_id bigint = NULL;
      cust_user_user   boolean;
    BEGIN

        /**********************************/
        /* INITIALIZE                     */ 
        /**********************************/
        select param_cur_val
          into get_cust_id
          from {schema}.v_param_cur 
         where param_cur_process = 'SQL'
           and param_cur_attrib = 'get_cust_id'; 

        select param_cur_val
          into get_item_id
          from {schema}.v_param_cur 
         where param_cur_process = 'SQL'
           and param_cur_attrib = 'get_item_id'; 

        select param_cur_val
          into doc_ctgr_table
          from {schema}.v_param_cur 
         where param_cur_process = 'SQL'
           and param_cur_attrib = 'doc_ctgr_table'; 

        my_doc_scope = case TG_OP when 'DELETE' then OLD.doc_scope else NEW.doc_scope end;
        my_doc_scope_id = case TG_OP when 'DELETE' then OLD.doc_scope_id else NEW.doc_scope_id end;

        if get_cust_id is not null and my_doc_scope not in ('sys_user_code') then
          sqlcmd := 'select '||get_cust_id||'($1,$2);';
          EXECUTE sqlcmd INTO my_cust_id USING my_doc_scope, my_doc_scope_id;
        end if;

        if get_item_id is not null and my_doc_scope not in ('sys_user_code') then
          sqlcmd := 'select '||get_item_id||'($1,$2);';
          EXECUTE sqlcmd INTO my_item_id USING my_doc_scope, my_doc_scope_id;
        end if;

        my_toa.op := TG_OP;
        my_toa.audit_table_name := upper(TG_audit_table_name::text);
        my_toa.cust_id := case when TG_OP = 'DELETE' then NULL else my_cust_id end;
        my_toa.item_id := case when TG_OP = 'DELETE' then NULL else my_item_id end;
        my_toa.audit_ref_name := NULL;
        my_toa.audit_ref_id := NULL;
        my_toa.audit_subject := NULL;

        /* RECOGNIZE IF CLIENT USER */
        IF SUBSTRING(MYUSER,1,1) = 'C' THEN
          select cust_id
	    into user_cust_id
	    from {schema}.cust_user
           where substring(MYUSER,2,1024)=sys_user_id::text
	     and cust_id = my_cust_id;
          IF user_cust_id is not null THEN		  
            cust_user_USER = TRUE;
          ELSE
	    cust_user_USER = FALSE;
	  END IF;
        END IF; 

        /**********************************/
        /* PERFORM CHECKS                 */ 
        /**********************************/
            
        IF TG_OP = 'UPDATE' THEN
          IF {schema}.nequal(NEW.doc_id, OLD.doc_id) THEN
            RAISE EXCEPTION  'Application Error - ID cannot be updated.';
          END IF;
          IF {schema}.nequal(NEW.doc_scope, OLD.doc_scope) THEN
            RAISE EXCEPTION  'Application Error - Scope cannot be updated..';
          END IF;
          IF {schema}.nequal(NEW.doc_scope_id, OLD.doc_scope_id) THEN
            RAISE EXCEPTION  'Application Error - Scope ID cannot be updated..';
          END IF;
          IF {schema}.nequal(NEW.doc_ctgr, OLD.doc_ctgr) THEN
            RAISE EXCEPTION  'Application Error - Document Category cannot be updated..';
          END IF;
        END IF;

        IF (TG_OP = 'INSERT' 
	    OR 
	    TG_OP = 'UPDATE' AND ({schema}.nequal(OLD.doc_scope, NEW.doc_scope)
		                  OR
				  {schema}.nequal(OLD.doc_scope_id, NEW.doc_scope_id))) THEN
	  IF NEW.doc_scope = 'S' AND NEW.doc_scope_id <> 0
	     OR
	     NEW.doc_scope <> 'S' AND NEW.doc_scope_id is NULL THEN
            RAISE EXCEPTION  'Application Error - SCOPE_ID inconsistent with SCOPE';
          END IF; 
	END IF;   

        IF (cust_user_user) THEN
	  IF coalesce(USER_cust_id,0) <> coalesce(my_cust_id,0)
	     OR
             my_doc_scope not in ('C','E','J','O') THEN
            RAISE EXCEPTION  'Application Error - Client User has no rights to perform this operation';
	  END IF; 
        END IF;

        IF (TG_OP='INSERT' OR TG_OP='UPDATE') THEN
          IF NOT {schema}.check_foreign_key(NEW.doc_scope, NEW.doc_scope_id)>0 THEN
            RAISE EXCEPTION  'Table % does not contain record % .', NEW.doc_scope, NEW.doc_scope_id::text ;
	  END IF;
	END IF;   

        IF (TG_OP='INSERT' OR TG_OP='UPDATE') THEN
          IF NOT {schema}.check_code2(doc_ctgr_table, NEW.doc_scope, NEW.doc_ctgr)>0 THEN
            RAISE EXCEPTION  'Document type % not allowed for selected scope: % .', NEW.doc_ctgr, NEW.doc_scope ;
	  END IF;
	END IF;   

        /**********************************/
        /* AUDIT TRAIL                    */ 
        /**********************************/

        IF TG_OP = 'INSERT' THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.doc_id is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.doc_id, OLD.doc_id) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'doc_id',OLD.doc_id::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.cust_id is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.cust_id, OLD.cust_id) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'cust_id',OLD.cust_id::text);  
        END IF;
     
        IF (case when TG_OP = 'DELETE' then OLD.doc_scope is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.doc_scope, OLD.doc_scope) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'doc_scope',OLD.doc_scope::text);  
        END IF;
     
        IF (case when TG_OP = 'DELETE' then OLD.doc_scope_id is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.doc_scope_id, OLD.doc_scope_id) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'doc_scope_id',OLD.doc_scope_id::text);  
        END IF;
     
        IF (case when TG_OP = 'DELETE' then OLD.item_id is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.item_id, OLD.item_id) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'item_id',OLD.item_id::text);  
        END IF;
     
        IF (case when TG_OP = 'DELETE' then OLD.doc_sts is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.doc_sts, OLD.doc_sts) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'doc_sts',OLD.doc_sts::text);  
        END IF;
     
        IF (case when TG_OP = 'DELETE' then OLD.doc_ctgr is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.doc_ctgr, OLD.doc_ctgr) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'doc_ctgr',OLD.doc_ctgr::text);  
        END IF;
     
        IF (case when TG_OP = 'DELETE' then OLD.doc_desc is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.doc_desc, OLD.doc_desc) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'doc_desc',OLD.doc_desc::text);  
        END IF;
     
        IF (case when TG_OP = 'DELETE' then OLD.doc_uptstmp is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.doc_uptstmp, OLD.doc_uptstmp) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'doc_uptstmp',OLD.doc_uptstmp::text);  
        END IF;
     
        IF (case when TG_OP = 'DELETE' then OLD.doc_upuser is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.doc_upuser, OLD.doc_upuser) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'doc_upuser',OLD.doc_upuser::text);  
        END IF;
     
        IF (case when TG_OP = 'DELETE' then OLD.doc_sync_tstmp is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.doc_sync_tstmp, OLD.doc_sync_tstmp) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'doc_sync_tstmp',OLD.doc_sync_tstmp::text);  
        END IF;

 
        /**********************************/
        /* UPDATES AND OTHER TABLES       */ 
        /**********************************/
     
        IF TG_OP = 'INSERT' THEN
          NEW.cust_id = my_cust_id;
          NEW.item_id = my_item_id;
	  NEW.doc_etstmp := curdttm;
	  NEW.doc_euser := myuser;
	  NEW.doc_mtstmp := curdttm;
	  NEW.doc_muser := myuser;
        ELSIF TG_OP = 'UPDATE' THEN
          IF audit_seq is not NULL THEN
            NEW.cust_id = my_cust_id;
            NEW.item_id = my_item_id;
	    NEW.doc_mtstmp := curdttm;
	    NEW.doc_muser := myuser;
	  END IF;  
        END IF;


        /**********************************/
        /* RETURN                         */ 
        /**********************************/
    
        IF TG_OP = 'INSERT' THEN
          RETURN NEW;
        ELSIF TG_OP = 'UPDATE' THEN
          RETURN NEW;
        ELSIF TG_OP = 'DELETE' THEN
          RETURN OLD;
        END IF;

    END;
$_$;


ALTER FUNCTION {schema}.doc__tbl_iud() OWNER TO postgres;


-- Function: {schema}.doc_filename(bigint, text)

CREATE OR REPLACE FUNCTION {schema}.doc_filename(
    doc_id bigint,
    doc_ext text)
  RETURNS text AS
$BODY$
DECLARE
    rslt    text = NULL;
BEGIN
  rslt = 'D'::text || doc_id::character varying::text || COALESCE(doc_ext, ''::character varying);
  
  RETURN rslt;
END;$BODY$
  LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER
  COST 10;

ALTER FUNCTION {schema}.doc_filename(bigint, text) OWNER TO postgres;


--
-- Name: digest(bytea, text); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION digest(bytea, text) RETURNS bytea
    LANGUAGE cust IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_digest';


ALTER FUNCTION {schema}.digest(bytea, text) OWNER TO postgres;

--
-- Name: digest(text, text); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION digest(text, text) RETURNS bytea
    LANGUAGE cust IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_digest';


ALTER FUNCTION {schema}.digest(text, text) OWNER TO postgres;

--
-- Name: code2_app_base_iud(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION code2_app_base_iud() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
      curdttm    timestamp default {schema}.my_now();
      myuser     text default {schema}.my_db_user();
      audit_seq    bigint default NULL;
      my_id      bigint default case TG_OP when 'DELETE' then OLD.code2_app_id else NEW.code2_app_id end;
      my_toa     {schema}.toaudit;
    BEGIN

        /**********************************/
        /* INITIALIZE                     */ 
        /**********************************/

        my_toa.op := TG_OP;
        my_toa.audit_table_name := upper(TG_audit_table_name::text);
        my_toa.cust_id := NULL;
        my_toa.item_id := NULL;
        my_toa.audit_ref_name := NULL;
        my_toa.audit_ref_id := NULL;
        my_toa.audit_subject := NULL;


        /**********************************/
        /* PERFORM CHECKS                 */ 
        /**********************************/
            
        IF TG_OP = 'UPDATE' THEN
          IF {schema}.nequal(NEW.code2_app_id, OLD.code2_app_id) THEN
            RAISE EXCEPTION  'Application Error - ID cannot be updated.';
          END IF;
          IF {schema}.nequal(NEW.code_val1, OLD.code_val1) THEN
            RAISE EXCEPTION  'Application Error - Code Value 1 cannot be updated..';
          END IF;
          IF {schema}.nequal(NEW.code_va12, OLD.code_va12) THEN
            RAISE EXCEPTION  'Application Error - Code Value 2 cannot be updated..';
          END IF;
        END IF;
          

        /**********************************/
        /* AUDIT TRAIL                    */ 
        /**********************************/

        IF TG_OP = 'INSERT' THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.code2_app_id is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.code2_app_id, OLD.code2_app_id) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'code2_app_id',OLD.code2_app_id::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.code_seq is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.code_seq, OLD.code_seq) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'code_seq',OLD.code_seq::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.code_val1 is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.code_val1, OLD.code_val1) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'code_val1',OLD.code_val1::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.code_va12 is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.code_va12, OLD.code_va12) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'code_va12',OLD.code_va12::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.code_txt is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.code_txt, OLD.code_txt) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'code_txt',OLD.code_txt::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.code_code is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.code_code, OLD.code_code) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'code_code',OLD.code_code::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.code_end_dt is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.code_end_dt, OLD.code_end_dt) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'code_end_dt',OLD.code_end_dt::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.code_end_reason is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.code_end_reason, OLD.code_end_reason) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'code_end_reason',OLD.code_end_reason::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.code_notes is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.code_notes, OLD.code_notes) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'code_notes',OLD.code_notes::text);  
        END IF;

 
        /**********************************/
        /* UPDATES AND OTHER TABLES       */ 
        /**********************************/
     
        IF TG_OP = 'INSERT' THEN
	  NEW.code_etstmp := curdttm;
	  NEW.code_euser := myuser;
	  NEW.code_mtstmp := curdttm;
	  NEW.code_muser := myuser;
        ELSIF TG_OP = 'UPDATE' THEN
          IF audit_seq is not NULL THEN
	    NEW.code_mtstmp := curdttm;
	    NEW.code_muser := myuser;
	  END IF;  
        END IF;


        /**********************************/
        /* RETURN                         */ 
        /**********************************/
    
        IF TG_OP = 'INSERT' THEN
          RETURN NEW;
        ELSIF TG_OP = 'UPDATE' THEN
          RETURN NEW;
        ELSIF TG_OP = 'DELETE' THEN
          RETURN OLD;
        END IF;

    END;
$$;


ALTER FUNCTION {schema}.code2_app_base_iud() OWNER TO postgres;

--
-- Name: code_app_base_iud(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION code_app_base_iud() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
      curdttm    timestamp default {schema}.my_now();
      myuser     text default {schema}.my_db_user();
      audit_seq    bigint default NULL;
      my_id      bigint default case TG_OP when 'DELETE' then OLD.code_app_id else NEW.code_app_id end;
      my_toa     {schema}.toaudit;
    BEGIN

        /**********************************/
        /* INITIALIZE                     */ 
        /**********************************/

        my_toa.op := TG_OP;
        my_toa.audit_table_name := upper(TG_audit_table_name::text);
        my_toa.cust_id := NULL;
        my_toa.item_id := NULL;
        my_toa.audit_ref_name := NULL;
        my_toa.audit_ref_id := NULL;
        my_toa.audit_subject := NULL;


        /**********************************/
        /* PERFORM CHECKS                 */ 
        /**********************************/
            
        IF TG_OP = 'UPDATE' THEN
          IF {schema}.nequal(NEW.code_app_id, OLD.code_app_id) THEN
            RAISE EXCEPTION  'Application Error - ID cannot be updated.';
          END IF;
          IF {schema}.nequal(NEW.code_val, OLD.code_val) THEN
            RAISE EXCEPTION  'Application Error - Code Value 1 cannot be updated..';
          END IF;
        END IF;
          

        /**********************************/
        /* AUDIT TRAIL                    */ 
        /**********************************/

        IF TG_OP = 'INSERT' THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.code_app_id is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.code_app_id, OLD.code_app_id) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'code_app_id',OLD.code_app_id::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.code_seq is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.code_seq, OLD.code_seq) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'code_seq',OLD.code_seq::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.code_val is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.code_val, OLD.code_val) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'code_val',OLD.code_val::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.code_txt is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.code_txt, OLD.code_txt) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'code_txt',OLD.code_txt::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.code_code is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.code_code, OLD.code_code) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'code_code',OLD.code_code::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.code_end_dt is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.code_end_dt, OLD.code_end_dt) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'code_end_dt',OLD.code_end_dt::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.code_end_reason is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.code_end_reason, OLD.code_end_reason) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'code_end_reason',OLD.code_end_reason::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.code_notes is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.code_notes, OLD.code_notes) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'code_notes',OLD.code_notes::text);  
        END IF;

 
        /**********************************/
        /* UPDATES AND OTHER TABLES       */ 
        /**********************************/
     
        IF TG_OP = 'INSERT' THEN
	  NEW.code_etstmp := curdttm;
	  NEW.code_euser := myuser;
	  NEW.code_mtstmp := curdttm;
	  NEW.code_muser := myuser;
        ELSIF TG_OP = 'UPDATE' THEN
          IF audit_seq is not NULL THEN
	    NEW.code_mtstmp := curdttm;
	    NEW.code_muser := myuser;
	  END IF;  
        END IF;


        /**********************************/
        /* RETURN                         */ 
        /**********************************/
    
        IF TG_OP = 'INSERT' THEN
          RETURN NEW;
        ELSIF TG_OP = 'UPDATE' THEN
          RETURN NEW;
        ELSIF TG_OP = 'DELETE' THEN
          RETURN OLD;
        END IF;

    END;
$$;


ALTER FUNCTION {schema}.code_app_base_iud() OWNER TO postgres;

--
-- Name: get_cust_user_name(bigint); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION get_cust_user_name(in_sys_user_id bigint) RETURNS character varying
    LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER COST 10
    AS $$
DECLARE
    rslt    text = NULL;
BEGIN

  select cust_user.sys_user_lname::text || ', '::text || cust_user.sys_user_fname::text
    into rslt
    from {schema}.cust_user
   where cust_user.sys_user_id = in_sys_user_id; 
  
  RETURN rslt;
END;
$$;


ALTER FUNCTION {schema}.get_cust_user_name(in_sys_user_id bigint) OWNER TO postgres;

--
-- Name: get_sys_user_name(bigint); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION get_sys_user_name(in_sys_user_id bigint) RETURNS character varying
    LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER COST 10
    AS $$
DECLARE
    rslt    text = NULL;
BEGIN

  select sys_user.sys_user_lname::text || ', '::text || sys_user.sys_user_fname::text
    into rslt
    from {schema}.sys_user
   where sys_user_id = in_sys_user_id; 
  
  RETURN rslt;
END;
$$;


ALTER FUNCTION {schema}.get_sys_user_name(in_sys_user_id bigint) OWNER TO postgres;

--
-- Name: get_param_desc(character varying, character varying); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION get_param_desc(in_param_process character varying, in_param_attrib character varying) RETURNS character varying
    LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER COST 10
    AS $$
DECLARE
    rslt    text = NULL;
BEGIN

  select param_desc
    into rslt
    from {schema}.param__tbl
   where param__tbl.param_process = in_param_process
     and param__tbl.param_attrib = in_param_attrib;
  
  RETURN rslt;
END;
$$;


ALTER FUNCTION {schema}.get_param_desc(in_param_process character varying, in_param_attrib character varying) OWNER TO postgres;

--
-- Name: good_email(text); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION good_email(x text) RETURNS boolean
    LANGUAGE sql
    AS $_$select x ~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$';$_$;


ALTER FUNCTION {schema}.good_email(x text) OWNER TO postgres;

--
-- Name: param_app_iud(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION param_app_iud() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
      curdttm    timestamp default {schema}.my_now();
      myuser     text default {schema}.my_db_user();
      audit_seq    bigint default NULL;
      my_id      bigint default case TG_OP when 'DELETE' then OLD.param_app_id else NEW.param_app_id end;
      my_toa     {schema}.toaudit;
      m          text;
    BEGIN

        /**********************************/
        /* INITIALIZE                     */ 
        /**********************************/

        my_toa.op := TG_OP;
        my_toa.audit_table_name := upper(TG_audit_table_name::text);
        my_toa.cust_id := NULL;
        my_toa.item_id := NULL;
        my_toa.audit_ref_name := NULL;
        my_toa.audit_ref_id := NULL;
        my_toa.audit_subject := NULL;


        /**********************************/
        /* PERFORM CHECKS                 */ 
        /**********************************/
            
        IF TG_OP = 'UPDATE' THEN
          IF {schema}.nequal(NEW.param_app_id, OLD.param_app_id) THEN
            RAISE EXCEPTION  'Application Error - ID cannot be updated.';
          END IF;
          IF {schema}.nequal(NEW.param_app_process, OLD.param_app_process) THEN
            RAISE EXCEPTION  'Application Error - Process cannot be updated..';
          END IF;
          IF {schema}.nequal(NEW.param_app_attrib, OLD.param_app_attrib) THEN
            RAISE EXCEPTION  'Application Error - Attribute cannot be updated..';
          END IF;
        END IF;
          

        IF (TG_OP = 'INSERT' or TG_OP = 'UPDATE') THEN
          m := {schema}.check_param('param_app', NEW.param_app_process, NEW.param_app_attrib, NEW.param_app_val);
          IF m IS NOT null THEN 
            RAISE EXCEPTION '%', m;
          END IF;
        END IF;



        /**********************************/
        /* AUDIT TRAIL                    */ 
        /**********************************/

        IF TG_OP = 'INSERT' THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.param_app_id is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.param_app_id, OLD.param_app_id) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'param_app_id',OLD.param_app_id::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.param_app_process is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.param_app_process, OLD.param_app_process) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'param_app_process',OLD.param_app_process::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.param_app_attrib is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.param_app_attrib, OLD.param_app_attrib) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'param_app_attrib',OLD.param_app_attrib::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.param_app_val is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.param_app_val, OLD.param_app_val) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'param_app_val',OLD.param_app_val::text);  
        END IF;

 
        /**********************************/
        /* UPDATES AND OTHER TABLES       */ 
        /**********************************/
     
        IF TG_OP = 'INSERT' THEN
	  NEW.param_app_etstmp := curdttm;
	  NEW.param_app_euser := myuser;
	  NEW.param_app_mtstmp := curdttm;
	  NEW.param_app_muser := myuser;
        ELSIF TG_OP = 'UPDATE' THEN
          IF audit_seq is not NULL THEN
	    NEW.param_app_mtstmp := curdttm;
	    NEW.param_app_muser := myuser;
	  END IF;  
        END IF;


        /**********************************/
        /* RETURN                         */ 
        /**********************************/
    
        IF TG_OP = 'INSERT' THEN
          RETURN NEW;
        ELSIF TG_OP = 'UPDATE' THEN
          RETURN NEW;
        ELSIF TG_OP = 'DELETE' THEN
          RETURN OLD;
        END IF;

    END;
$$;


ALTER FUNCTION {schema}.param_app_iud() OWNER TO postgres;

--
-- Name: help__tbl_iud(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION help__tbl_iud() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
      curdttm    timestamp default {schema}.my_now();
      myuser     text default {schema}.my_db_user();
      audit_seq    bigint default NULL;
      my_id      bigint default case TG_OP when 'DELETE' then OLD.help_id else NEW.help_id end;
      my_toa     {schema}.toaudit;
      my_help_target_code text = NULL;
      my_help_target_desc text = NULL;
    BEGIN

        /**********************************/
        /* INITIALIZE                     */ 
        /**********************************/

        IF TG_OP = 'DELETE' THEN
          my_help_target_code = OLD.help_target_code;
        ELSE
          my_help_target_code = NEW.help_target_code;
        END IF;

        select help_target.help_target_desc
          into my_help_target_desc
          from {schema}.help_target
         where help_target.help_target_code = help_target_code;           

        my_toa.op := TG_OP;
        my_toa.audit_table_name := upper(TG_audit_table_name::text);
        my_toa.cust_id := NULL;
        my_toa.item_id := NULL;
        my_toa.audit_ref_name := NULL;
        my_toa.audit_ref_id := NULL;
        my_toa.audit_subject := my_help_target_desc;

        /**********************************/
        /* PERFORM CHECKS                 */ 
        /**********************************/
            
        IF TG_OP = 'UPDATE' THEN
          IF {schema}.nequal(NEW.help_id, OLD.help_id) THEN
            RAISE EXCEPTION  'Application Error - ID cannot be updated.';
          END IF;
          IF {schema}.nequal(NEW.help_target_code, OLD.help_target_code) THEN
            RAISE EXCEPTION  'Application Error - help_target Code cannot be updated..';
          END IF;
        END IF;
          

        /**********************************/
        /* AUDIT TRAIL                    */ 
        /**********************************/

        IF TG_OP = 'INSERT' THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.help_id is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.help_id, OLD.help_id) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'help_id',OLD.help_id::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.help_target_code is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.help_target_code, OLD.help_target_code) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'help_target_code',OLD.help_target_code::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.help_title is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.help_title, OLD.help_title) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'help_title',OLD.help_title::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.help_text is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.help_text, OLD.help_text) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'help_text',OLD.help_text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.help_seq is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.help_seq, OLD.help_seq) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'help_seq',OLD.help_seq::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.help_listing_main is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.help_listing_main, OLD.help_listing_main) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'help_listing_main',OLD.help_listing_main::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.help_listing_client is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.help_listing_client, OLD.help_listing_client) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'help_listing_client',OLD.help_listing_client::text);  
        END IF;

 
        /**********************************/
        /* UPDATES AND OTHER TABLES       */ 
        /**********************************/
     
        IF TG_OP = 'INSERT' THEN
	  NEW.help_etstmp := curdttm;
	  NEW.help_euser := myuser;
	  NEW.help_mtstmp := curdttm;
	  NEW.help_muser := myuser;
        ELSIF TG_OP = 'UPDATE' THEN
          IF audit_seq is not NULL THEN
	    NEW.help_mtstmp := curdttm;
	    NEW.help_muser := myuser;
	  END IF;  
        END IF;


        /**********************************/
        /* RETURN                         */ 
        /**********************************/
    
        IF TG_OP = 'INSERT' THEN
          RETURN NEW;
        ELSIF TG_OP = 'UPDATE' THEN
          RETURN NEW;
        ELSIF TG_OP = 'DELETE' THEN
          RETURN OLD;
        END IF;

    END;
$$;


ALTER FUNCTION {schema}.help__tbl_iud() OWNER TO postgres;

--
-- Name: my_db_user(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION {schema}.my_db_user() RETURNS text
    LANGUAGE plpgsql
    AS $$
BEGIN 
  case 
    when current_setting('sessionvars.appuser')='unknown' then return 'U'||current_user::text;
    else return current_setting('sessionvars.appuser');
  end case;
EXCEPTION
  WHEN others then
    return 'U'||current_user::text;
END;$$;

ALTER FUNCTION {schema}.my_db_user() OWNER TO postgres;

--
-- Name: my_db_user_email(text); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION my_db_user_email(u text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER COST 10
    AS $$
DECLARE
    rslt    text = u;
    wk      text = NULL;
BEGIN
  case substring(u,1,1)
    when 'S' then
      select sys_user_email
        into wk
        from {schema}.sys_user
       where sys_user_id::text = substring(u,2,1024);  
      rslt = wk;
    when 'C' then
      select sys_user_email
        into wk
        from {schema}.cust_user
       where sys_user_id::text = substring(u,2,1024);  
      rslt = wk;
    else
      rslt = NULL;
  end case;    
  
  RETURN rslt;
END;$$;


ALTER FUNCTION {schema}.my_db_user_email(u text) OWNER TO postgres;

--
-- Name: my_db_user_fmt(text); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION my_db_user_fmt(u text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER COST 10
    AS $$
DECLARE
    rslt    text = u;
    wk      text = NULL;
BEGIN
  case substring(u,1,1)
    when 'S' then
      select 'S-'||sys_user_lname||', '||sys_user_fname
        into wk
        from {schema}.sys_user
       where sys_user_id::text = substring(u,2,1024);  
      rslt = coalesce(wk, u);
    when 'C' then
      select 'C-'||sys_user_lname||', '||sys_user_fname
        into wk
        from {schema}.cust_user
       where sys_user_id::text = substring(u,2,1024);  
      rslt = coalesce(wk, u);
    when 'U' then
      rslt = coalesce(substring(u,2,1024), u);
    else
      rslt = coalesce(u, 'unknown');
  end case;    
  
  RETURN rslt;
END;$$;


ALTER FUNCTION {schema}.my_db_user_fmt(u text) OWNER TO postgres;

--
-- Name: my_hash(character, bigint, character varying); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION my_hash(par_type character, par_sys_user_id bigint, par_pw character varying) RETURNS bytea
    LANGUAGE plpgsql
    AS $$
DECLARE 
  rslt bytea default NULL;
  seed varchar(255) default NULL;
  val    varchar(255);
BEGIN

  if (par_type = 'S') THEN
    select param_cur_val into seed
      from {schema}.v_param_cur
     where param_cur_process = 'USERS'
       and param_cur_attrib = 'HASH_SEED_S';
  elsif (par_type = 'C') THEN
    select param_cur_val into seed
      from {schema}.v_param_cur
     where param_cur_process = 'USERS'
       and param_cur_attrib = 'HASH_SEED_C';
  END IF;
  
  if (seed is not null
      and coalesce(par_sys_user_id,0) > 0
      and coalesce(par_pw,'') <> '') THEN
    val = par_sys_user_id::text||par_pw||seed;
    /* rslt = hashbytes('sha1',val); */
    rslt = {schema}.digest(val, 'sha1'::text);
  end if;

  return rslt;

END;
$$;


ALTER FUNCTION {schema}.my_hash(par_type character, par_sys_user_id bigint, par_pw character varying) OWNER TO postgres;

--
-- Name: myisnumeric(text); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION myisnumeric(text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $_$
DECLARE x NUMERIC;
BEGIN
    x = $1::NUMERIC;
    RETURN TRUE;
EXCEPTION WHEN others THEN
    RETURN FALSE;
END;
$_$;


ALTER FUNCTION {schema}.myisnumeric(text) OWNER TO postgres;

--
-- Name: mymmddyy(timestamp without time zone); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION mymmddyy(timestamp without time zone) RETURNS character varying
    LANGUAGE sql
    AS $_$select to_char($1, 'MM/DD/YY');$_$;


ALTER FUNCTION {schema}.mymmddyy(timestamp without time zone) OWNER TO postgres;

--
-- Name: my_mmddyyhhmi(timestamp without time zone); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION my_mmddyyhhmi(timestamp without time zone) RETURNS character varying
    LANGUAGE sql
    AS $_$select to_char($1, 'MM/DD/YY HH24:MI');$_$;


ALTER FUNCTION {schema}.my_mmddyyhhmi(timestamp without time zone) OWNER TO postgres;

--
-- Name: mymmddyyyyhhmi(timestamp without time zone); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION mymmddyyyyhhmi(timestamp without time zone) RETURNS character varying
    LANGUAGE sql
    AS $_$select to_char($1, 'MM/DD/YYYY HH24:MI');$_$;


ALTER FUNCTION {schema}.mymmddyyyyhhmi(timestamp without time zone) OWNER TO postgres;

--
-- Name: my_now(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION my_now() RETURNS timestamp without time zone
    LANGUAGE sql
    AS $$select localtimestamp;$$;


ALTER FUNCTION {schema}.my_now() OWNER TO postgres;

--
-- Name: my_sys_user_id(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION my_sys_user_id() RETURNS bigint
    LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER COST 10
    AS $$
DECLARE
    u       text = {schema}.my_db_user();
    rslt    bigint = NULL;
    wk      text = NULL;
BEGIN
  case substring(u,1,1)
    when 'S' then
      wk = substring(u,2,1024);
      rslt = wk::bigint;
    else
      rslt = NULL;
  end case;    
  
  RETURN rslt;
END;$$;


ALTER FUNCTION {schema}.my_sys_user_id() OWNER TO postgres;

--
-- Name: my_cust_user_id(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION my_cust_user_id() RETURNS bigint
    LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER COST 10
    AS $$
DECLARE
    u       text = {schema}.my_db_user();
    rslt    bigint = NULL;
    wk      text = NULL;
BEGIN
  case substring(u,1,1)
    when 'C' then
      wk = substring(u,2,1024);
      rslt = wk::bigint;
    else
      rslt = NULL;
  end case;    
  
  RETURN rslt;
END;$$;


ALTER FUNCTION {schema}.my_cust_user_id() OWNER TO postgres;

--
-- Name: my_to_date(timestamp without time zone); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION my_to_date(timestamp without time zone) RETURNS date
    LANGUAGE sql
    AS $_$select date_trunc('day',$1)::date;$_$;


ALTER FUNCTION {schema}.my_to_date(timestamp without time zone) OWNER TO postgres;

--
-- Name: my_today(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION my_today() RETURNS date
    LANGUAGE sql
    AS $$select current_date;$$;


ALTER FUNCTION {schema}.my_today() OWNER TO postgres;

--
-- Name: note__tbl_iud(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION note__tbl_iud() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
      curdttm    timestamp default {schema}.my_now();
      myuser     text default {schema}.my_db_user();
      audit_seq    bigint default NULL;
      my_id      bigint default case TG_OP when 'DELETE' then OLD.note_id else NEW.note_id end;
      my_toa     {schema}.toaudit;

      my_cust_id    bigint = NULL;
      user_cust_id  bigint = NULL;
      my_note_scope text = NULL;
      cust_user_user   boolean;
    BEGIN

        /**********************************/
        /* INITIALIZE                     */ 
        /**********************************/

        my_toa.op := TG_OP;
        my_toa.audit_table_name := upper(TG_audit_table_name::text);

        if TG_OP = 'DELETE' then
          my_toa.cust_id := NULL;
        else
          if NEW.note_scope in ('sys_user_code')
          then 
            my_toa.cust_id := NULL;
          else  
            my_toa.cust_id := get_cust_id(NEW.note_scope, NEW.note_scope_id);
          end if;  
        end if; 
        
        my_toa.item_id := NULL;
        my_toa.audit_ref_name := NULL;
        my_toa.audit_ref_id := NULL;
        my_toa.audit_subject := NULL;

        if TG_OP = 'DELETE' then
          if OLD.note_scope in ('sys_user_code')
          then 
            my_cust_id := NULL;
          else  
            my_cust_id := get_cust_id(OLD.note_scope, OLD.note_scope_id);
          end if;  
          my_note_scope := OLD.note_scope;
        else
          if NEW.note_scope in ('sys_user_code')
          then 
            my_cust_id := NULL;
          else  
            my_cust_id := get_cust_id(NEW.note_scope, NEW.note_scope_id);
          end if;  
          my_note_scope := NEW.note_scope;
        end if; 

        /* RECOGNIZE IF CLIENT USER */
        IF SUBSTRING(MYUSER,1,1) = 'C' THEN
          select cust_id
	    into user_cust_id
	    from {schema}.cust_user
           where substring(MYUSER,2,1024)=sys_user_id::text
	     and cust_id = my_cust_id;
          IF user_cust_id is not null THEN		  
            cust_user_USER = TRUE;
          ELSE
	    cust_user_USER = FALSE;
	  END IF;
        END IF; 

        /**********************************/
        /* PERFORM CHECKS                 */ 
        /**********************************/

        IF (cust_user_user) THEN
	  IF coalesce(USER_cust_id,0) <> coalesce(my_cust_id,0)
	     OR
             my_note_scope not in ('C','E','J','O') THEN
            RAISE EXCEPTION  'Application Error - Client User has no rights to perform this operation';
	  END IF; 
        END IF;

            
        IF TG_OP = 'UPDATE' THEN
          IF {schema}.nequal(NEW.note_id, OLD.note_id) THEN
            RAISE EXCEPTION  'Application Error - ID cannot be updated.';
          END IF;
          IF {schema}.nequal(NEW.note_scope, OLD.note_scope) THEN
            RAISE EXCEPTION  'Application Error - Scope cannot be updated..';
          END IF;
          IF {schema}.nequal(NEW.note_scope_id, OLD.note_scope_id) THEN
            RAISE EXCEPTION  'Application Error - Scope ID cannot be updated..';
          END IF;
          IF {schema}.nequal(NEW.note_type, OLD.note_type) THEN
            RAISE EXCEPTION  'Application Error - Note Type cannot be updated..';
          END IF;
        END IF;
          

        IF (TG_OP='INSERT' OR TG_OP='UPDATE') THEN
          IF NOT {schema}.check_foreign_key(NEW.note_scope, NEW.note_scope_id)>0 THEN
            RAISE EXCEPTION  'Table % does not contain record % .', NEW.note_scope, NEW.note_scope_id::text ;
	  END IF;
	END IF;   





        /**********************************/
        /* AUDIT TRAIL                    */ 
        /**********************************/

        IF TG_OP = 'INSERT' THEN
          SELECT par_audit_seq INTO audit_seq from {schema}.audit(my_toa, audit_seq, my_id);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.note_id is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.note_id, OLD.note_id) end) THEN
          SELECT par_audit_seq INTO audit_seq from {schema}.audit(my_toa, audit_seq, my_id, 'note_id',OLD.note_id::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.cust_id is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.cust_id, OLD.cust_id) end) THEN
          SELECT par_audit_seq INTO audit_seq from {schema}.audit(my_toa, audit_seq, my_id, 'cust_id',OLD.cust_id::text);  
        END IF;
     
        IF (case when TG_OP = 'DELETE' then OLD.note_scope is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.note_scope, OLD.note_scope) end) THEN
          SELECT par_audit_seq INTO audit_seq from {schema}.audit(my_toa, audit_seq, my_id, 'note_scope',OLD.note_scope::text);  
        END IF;
     
        IF (case when TG_OP = 'DELETE' then OLD.note_scope_id is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.note_scope_id, OLD.note_scope_id) end) THEN
          SELECT par_audit_seq INTO audit_seq from {schema}.audit(my_toa, audit_seq, my_id, 'note_scope_id',OLD.note_scope_id::text);  
        END IF;
     
        IF (case when TG_OP = 'DELETE' then OLD.item_id is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.item_id, OLD.item_id) end) THEN
          SELECT par_audit_seq INTO audit_seq from {schema}.audit(my_toa, audit_seq, my_id, 'item_id',OLD.item_id::text);  
        END IF;
     
        IF (case when TG_OP = 'DELETE' then OLD.note_sts is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.note_sts, OLD.note_sts) end) THEN
          SELECT par_audit_seq INTO audit_seq from {schema}.audit(my_toa, audit_seq, my_id, 'note_sts',OLD.note_sts::text);  
        END IF;
     
        IF (case when TG_OP = 'DELETE' then OLD.note_type is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.note_type, OLD.note_type) end) THEN
          SELECT par_audit_seq INTO audit_seq from {schema}.audit(my_toa, audit_seq, my_id, 'note_type',OLD.note_type::text);  
        END IF;
     
        IF (case when TG_OP = 'DELETE' then OLD.note_body is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.note_body, OLD.note_body) end) THEN
          SELECT par_audit_seq INTO audit_seq from {schema}.audit(my_toa, audit_seq, my_id, 'note_body',OLD.note_body::text);  
        END IF;

 
        /**********************************/
        /* UPDATES AND OTHER TABLES       */ 
        /**********************************/
     
        IF TG_OP = 'INSERT' THEN
          NEW.cust_id = my_cust_id;
          NEW.item_id = NULL::text;
	  NEW.note_etstmp := curdttm;
	  NEW.note_euser := myuser;
	  NEW.note_mtstmp := curdttm;
	  NEW.note_muser := myuser;
        ELSIF TG_OP = 'UPDATE' THEN
          IF audit_seq is not NULL THEN
            NEW.cust_id = my_cust_id;
            NEW.item_id = NULL::text;
	    NEW.note_mtstmp := curdttm;
	    NEW.note_muser := myuser;
	  END IF;  
        END IF;


        /**********************************/
        /* RETURN                         */ 
        /**********************************/
    
        IF TG_OP = 'INSERT' THEN
          RETURN NEW;
        ELSIF TG_OP = 'UPDATE' THEN
          RETURN NEW;
        ELSIF TG_OP = 'DELETE' THEN
          RETURN OLD;
        END IF;

    END;
$$;


ALTER FUNCTION {schema}.note__tbl_iud() OWNER TO postgres;

--
-- Name: nequal(bit, bit); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION nequal(x1 bit, x2 bit) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
    BEGIN
        If x1 is null and x2 is null THEN
          RETURN FALSE;
        ELSIF x1 is null and x2 is not null
           or
           x1 is not null and x2 is null THEN
          RETURN TRUE;     
        ELSE
          RETURN x1 <> x2;
        END IF;    
    END;
$$;


ALTER FUNCTION {schema}.nequal(x1 bit, x2 bit) OWNER TO postgres;

--
-- Name: nequal(boolean, boolean); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION nequal(x1 boolean, x2 boolean) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
    BEGIN
        If x1 is null and x2 is null THEN
          RETURN FALSE;
        ELSIF x1 is null and x2 is not null
           or
           x1 is not null and x2 is null THEN
          RETURN TRUE;     
        ELSE
          RETURN x1 <> x2;
        END IF;    
    END;
$$;


ALTER FUNCTION {schema}.nequal(x1 boolean, x2 boolean) OWNER TO postgres;

--
-- Name: nequal(smallint, smallint); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION nequal(x1 smallint, x2 smallint) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
    BEGIN
        If x1 is null and x2 is null THEN
          RETURN FALSE;
        ELSIF x1 is null and x2 is not null
           or
           x1 is not null and x2 is null THEN
          RETURN TRUE;     
        ELSE
          RETURN x1 <> x2;
        END IF;    
    END;
$$;


ALTER FUNCTION {schema}.nequal(x1 smallint, x2 smallint) OWNER TO postgres;

--
-- Name: nequal(integer, integer); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION nequal(x1 integer, x2 integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
    BEGIN
        If x1 is null and x2 is null THEN
          RETURN FALSE;
        ELSIF x1 is null and x2 is not null
           or
           x1 is not null and x2 is null THEN
          RETURN TRUE;     
        ELSE
          RETURN x1 <> x2;
        END IF;    
    END;
$$;


ALTER FUNCTION {schema}.nequal(x1 integer, x2 integer) OWNER TO postgres;

--
-- Name: nequal(bigint, bigint); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION nequal(x1 bigint, x2 bigint) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
    BEGIN
        If x1 is null and x2 is null THEN
          RETURN FALSE;
        ELSIF x1 is null and x2 is not null
           or
           x1 is not null and x2 is null THEN
          RETURN TRUE;     
        ELSE
          RETURN x1 <> x2;
        END IF;    
    END;
$$;


ALTER FUNCTION {schema}.nequal(x1 bigint, x2 bigint) OWNER TO postgres;

--
-- Name: nequal(numeric, numeric); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION nequal(x1 numeric, x2 numeric) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
    BEGIN
        If x1 is null and x2 is null THEN
          RETURN FALSE;
        ELSIF x1 is null and x2 is not null
           or
           x1 is not null and x2 is null THEN
          RETURN TRUE;     
        ELSE
          RETURN x1 <> x2;
        END IF;    
    END;
$$;


ALTER FUNCTION {schema}.nequal(x1 numeric, x2 numeric) OWNER TO postgres;

--
-- Name: nequal(text, text); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION nequal(x1 text, x2 text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
    BEGIN
        If x1 is null and x2 is null THEN
          RETURN FALSE;
        ELSIF x1 is null and x2 is not null
           or
           x1 is not null and x2 is null THEN
          RETURN TRUE;     
        ELSE
          RETURN x1 <> x2;
        END IF;    
    END;
$$;


ALTER FUNCTION {schema}.nequal(x1 text, x2 text) OWNER TO postgres;

--
-- Name: nequal(timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION nequal(x1 timestamp without time zone, x2 timestamp without time zone) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
    BEGIN
        If x1 is null and x2 is null THEN
          RETURN FALSE;
        ELSIF x1 is null and x2 is not null
           or
           x1 is not null and x2 is null THEN
          RETURN TRUE;     
        ELSE
          RETURN x1 <> x2;
        END IF;    
    END;
$$;


ALTER FUNCTION {schema}.nequal(x1 timestamp without time zone, x2 timestamp without time zone) OWNER TO postgres;

--
-- Name: sys_user_iud(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION sys_user_iud() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
      curdttm   timestamp default {schema}.my_now();
      myuser    text default {schema}.my_db_user();
      audit_seq   bigint default NULL;
      my_id     bigint default case TG_OP when 'DELETE' then OLD.sys_user_id else NEW.sys_user_id end;
      newpw     text default NULL;
      hash      bytea default NULL;
      my_toa    {schema}.toaudit;
    BEGIN

        /**********************************/
        /* INITIALIZE                     */ 
        /**********************************/

        my_toa.op := TG_OP;
        my_toa.audit_table_name := upper(TG_audit_table_name::text);
        my_toa.cust_id := NULL;
        my_toa.item_id := NULL;
        my_toa.audit_ref_name := NULL;
        my_toa.audit_ref_id := NULL;
        my_toa.audit_subject := case when TG_OP = 'DELETE' then NULL else coalesce(NEW.sys_user_lname,'')||', '||coalesce(NEW.sys_user_fname,'') end;
         

        /**********************************/
        /* PERFORM CHECKS                 */ 
        /**********************************/

        IF TG_OP = 'UPDATE'
           and
           {schema}.nequal(NEW.sys_user_id, OLD.sys_user_id) THEN
          RAISE EXCEPTION  'Application Error - ID cannot be updated.';
        END IF;

        IF TG_OP = 'INSERT' or TG_OP = 'UPDATE' THEN
	  IF {schema}.nequal(NEW.sys_user_pw1, NEW.sys_user_pw2) THEN
            RAISE EXCEPTION  'Application Error - New Password and Repeat Password are different.';
          ELSIF (TG_OP='INSERT' or NEW.sys_user_pw1 is not null)  AND length(btrim(NEW.sys_user_pw1::text)) < 6  THEN
            RAISE EXCEPTION  'Application Error - Password length - at least 6 characters required.';
          END IF;            
        END IF;


        /**********************************/
        /* AUDIT TRAIL                    */ 
        /**********************************/

        IF TG_OP = 'INSERT' THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id);  
        END IF;


        IF (case when TG_OP = 'DELETE' then OLD.sys_user_id is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.sys_user_id, OLD.sys_user_id) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'sys_user_id', OLD.sys_user_id::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.sys_user_sts is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.sys_user_sts, OLD.sys_user_sts) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'sys_user_sts', OLD.sys_user_sts::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.sys_user_fname is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.sys_user_fname, OLD.sys_user_fname) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'sys_user_fname', OLD.sys_user_fname::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.sys_user_mname is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.sys_user_mname, OLD.sys_user_mname) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'sys_user_mname', OLD.sys_user_mname::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.sys_user_lname is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.sys_user_lname, OLD.sys_user_lname) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'sys_user_lname', OLD.sys_user_lname::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.sys_user_jobtitle is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.sys_user_jobtitle, OLD.sys_user_jobtitle) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'sys_user_jobtitle', OLD.sys_user_jobtitle::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.sys_user_bphone is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.sys_user_bphone, OLD.sys_user_bphone) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'sys_user_bphone', OLD.sys_user_bphone::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.sys_user_cphone is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.sys_user_cphone, OLD.sys_user_cphone) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'sys_user_cphone', OLD.sys_user_cphone::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.sys_user_country is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.sys_user_country, OLD.sys_user_country) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'sys_user_country', OLD.sys_user_country::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.sys_user_addr is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.sys_user_addr, OLD.sys_user_addr) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'sys_user_addr', OLD.sys_user_addr::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.sys_user_city is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.sys_user_city, OLD.sys_user_city) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'sys_user_city', OLD.sys_user_city::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.sys_user_state is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.sys_user_state, OLD.sys_user_state) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'sys_user_state', OLD.sys_user_state::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.sys_user_zip is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.sys_user_zip, OLD.sys_user_zip) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'sys_user_zip', OLD.sys_user_zip::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.sys_user_email is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.sys_user_email, OLD.sys_user_email) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'sys_user_email', OLD.sys_user_email::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.sys_user_startdt is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.sys_user_startdt, OLD.sys_user_startdt) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'sys_user_startdt', OLD.sys_user_startdt::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.sys_user_enddt is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.sys_user_enddt, OLD.sys_user_enddt) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'sys_user_enddt', OLD.sys_user_enddt::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.sys_user_unotes is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.sys_user_unotes, OLD.sys_user_unotes) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'sys_user_unotes', OLD.sys_user_unotes::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.sys_user_lastlogin_tstmp is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.sys_user_lastlogin_tstmp, OLD.sys_user_lastlogin_tstmp) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'sys_user_lastlogin_tstmp', OLD.sys_user_lastlogin_tstmp::text);  
        END IF;

      
        IF TG_OP = 'UPDATE' and coalesce(NEW.sys_user_pw1,'') <> '' THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'sys_user_PW','*');  
        END IF;


        /**********************************/
        /* UPDATES AND OTHER TABLES       */ 
        /**********************************/

        IF TG_OP in ('INSERT', 'UPDATE') THEN
        
          newpw = btrim(NEW.sys_user_pw1);
          if newpw is not null then
            hash = {schema}.my_hash('S', NEW.sys_user_id, newpw);
            if (hash is null) then
              RAISE EXCEPTION  'Application Error - Missing or Incorrect Password.';
            end if;
	    NEW.sys_user_hash := hash;
	    NEW.sys_user_pw1 = NULL;
	    NEW.sys_user_pw2 = NULL;
          else
            hash = NULL;
          end if;
            
          IF TG_OP = 'INSERT' THEN
            NEW.sys_user_stsdt := curdttm;
	    NEW.sys_user_etstmp := curdttm;
	    NEW.sys_user_euser := myuser;
	    NEW.sys_user_mtstmp := curdttm;
	    NEW.sys_user_muser := myuser;
          ELSIF TG_OP = 'UPDATE' THEN
            IF audit_seq is not NULL THEN
              if {schema}.nequal(OLD.sys_user_sts, NEW.sys_user_sts) then
                NEW.sys_user_stsdt := curdttm;
              end if;
	      NEW.sys_user_mtstmp := curdttm;
	      NEW.sys_user_muser := myuser;
	    END IF;  
          END IF;
        END IF;


        /**********************************/
        /* RETURN                         */ 
        /**********************************/
    
        IF TG_OP = 'INSERT' THEN
          RETURN NEW;
        ELSIF TG_OP = 'UPDATE' THEN
          RETURN NEW;
        ELSIF TG_OP = 'DELETE' THEN
          RETURN OLD;
        END IF;

    END;
$$;


ALTER FUNCTION {schema}.sys_user_iud() OWNER TO postgres;

--
-- Name: param__tbl_iud(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION param__tbl_iud() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
      curdttm    timestamp default {schema}.my_now();
      myuser     text default {schema}.my_db_user();
      audit_seq    bigint default NULL;
      my_id      bigint default case TG_OP when 'DELETE' then OLD.param_id else NEW.param_id end;
      my_toa     {schema}.toaudit;
    BEGIN

        /**********************************/
        /* INITIALIZE                     */ 
        /**********************************/

        my_toa.op := TG_OP;
        my_toa.audit_table_name := upper(TG_audit_table_name::text);
        my_toa.cust_id := NULL;
        my_toa.item_id := NULL;
        my_toa.audit_ref_name := NULL;
        my_toa.audit_ref_id := NULL;
        my_toa.audit_subject := NULL;


        /**********************************/
        /* PERFORM CHECKS                 */ 
        /**********************************/
            
        IF TG_OP = 'UPDATE' THEN
          IF {schema}.nequal(NEW.param_id, OLD.param_id) THEN
            RAISE EXCEPTION  'Application Error - ID cannot be updated.';
          END IF;
        END IF;
          

        /**********************************/
        /* AUDIT TRAIL                    */ 
        /**********************************/

        IF TG_OP = 'INSERT' THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.param_id is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.param_id, OLD.param_id) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'param_id',OLD.param_id::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.param_process is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.param_process, OLD.param_process) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'param_process',OLD.param_process::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.param_attrib is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.param_attrib, OLD.param_attrib) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'param_attrib',OLD.param_attrib::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.param_desc is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.param_desc, OLD.param_desc) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'param_desc',OLD.param_desc::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.param_type is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.param_type, OLD.param_type) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'param_type',OLD.param_type::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.code_name is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.code_name, OLD.code_name) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'code_name',OLD.code_name::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.is_param_app is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.is_param_app, OLD.is_param_app) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'is_param_app',OLD.is_param_app::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.is_param_user is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.is_param_user, OLD.is_param_user) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'is_param_user',OLD.is_param_user::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.is_param_sys is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.is_param_sys, OLD.is_param_sys) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'is_param_sys',OLD.is_param_sys::text);  
        END IF;

 
        /**********************************/
        /* UPDATES AND OTHER TABLES       */ 
        /**********************************/
     
        IF TG_OP = 'INSERT' THEN
	  NEW.param_etstmp := curdttm;
	  NEW.param_euser := myuser;
	  NEW.param_mtstmp := curdttm;
	  NEW.param_muser := myuser;
        ELSIF TG_OP = 'UPDATE' THEN
          IF audit_seq is not NULL THEN
	    NEW.param_mtstmp := curdttm;
	    NEW.param_muser := myuser;
	  END IF;  
        END IF;


        /**********************************/
        /* RETURN                         */ 
        /**********************************/
    
        IF TG_OP = 'INSERT' THEN
          RETURN NEW;
        ELSIF TG_OP = 'UPDATE' THEN
          RETURN NEW;
        ELSIF TG_OP = 'DELETE' THEN
          RETURN OLD;
        END IF;

    END;
$$;


ALTER FUNCTION {schema}.param__tbl_iud() OWNER TO postgres;

--
-- Name: param_user_iud(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION param_user_iud() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
      curdttm    timestamp default {schema}.my_now();
      myuser     text default {schema}.my_db_user();
      audit_seq    bigint default NULL;
      my_id      bigint default case TG_OP when 'DELETE' then OLD.param_user_id else NEW.param_user_id end;
      my_toa     {schema}.toaudit;
      m          text;
    BEGIN

        /**********************************/
        /* INITIALIZE                     */ 
        /**********************************/

        my_toa.op := TG_OP;
        my_toa.audit_table_name := upper(TG_audit_table_name::text);
        my_toa.audit_ref_name := NULL;
        my_toa.audit_ref_id := NULL;
        my_toa.audit_subject := case when TG_OP = 'DELETE' then NULL else (select coalesce(sys_user_lname,'')||', '||coalesce(sys_user_fname,'') from {schema}.sys_user where sys_user_id = NEW.sys_user_id) end;


        /**********************************/
        /* PERFORM CHECKS                 */ 
        /**********************************/
            
        IF TG_OP = 'UPDATE' THEN
          IF {schema}.nequal(NEW.param_user_id, OLD.param_user_id) THEN
            RAISE EXCEPTION  'Application Error - ID cannot be updated.';
          END IF;
          IF {schema}.nequal(NEW.sys_user_id, OLD.sys_user_id) THEN
            RAISE EXCEPTION  'Application Error - Personnel cannot be updated.';
          END IF;
          IF {schema}.nequal(NEW.param_user_process, OLD.param_user_process) THEN
            RAISE EXCEPTION  'Application Error - Process cannot be updated..';
          END IF;
          IF {schema}.nequal(NEW.param_user_attrib, OLD.param_user_attrib) THEN
            RAISE EXCEPTION  'Application Error - Attribute cannot be updated..';
          END IF;
        END IF;
          

        IF (TG_OP = 'INSERT' or TG_OP = 'UPDATE') THEN
          m := {schema}.check_param('param_user', NEW.param_user_process, NEW.param_user_attrib, NEW.param_user_val);
          IF m IS NOT null THEN 
            RAISE EXCEPTION '%', m;
          END IF;
        END IF;



        /**********************************/
        /* AUDIT TRAIL                    */ 
        /**********************************/

        IF TG_OP = 'INSERT' THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.param_user_id is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.param_user_id, OLD.param_user_id) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'param_user_id',OLD.param_user_id::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.sys_user_id is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.sys_user_id, OLD.sys_user_id) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'sys_user_id',OLD.sys_user_id::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.param_user_process is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.param_user_process, OLD.param_user_process) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'param_user_process',OLD.param_user_process::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.param_user_attrib is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.param_user_attrib, OLD.param_user_attrib) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'param_user_attrib',OLD.param_user_attrib::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.param_user_val is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.param_user_val, OLD.param_user_val) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'param_user_val',OLD.param_user_val::text);  
        END IF;

 
        /**********************************/
        /* UPDATES AND OTHER TABLES       */ 
        /**********************************/
     
        IF TG_OP = 'INSERT' THEN
	  NEW.param_user_etstmp := curdttm;
	  NEW.param_user_euser := myuser;
	  NEW.param_user_mtstmp := curdttm;
	  NEW.param_user_muser := myuser;
        ELSIF TG_OP = 'UPDATE' THEN
          IF audit_seq is not NULL THEN
	    NEW.param_user_mtstmp := curdttm;
	    NEW.param_user_muser := myuser;
	  END IF;  
        END IF;


        /**********************************/
        /* RETURN                         */ 
        /**********************************/
    
        IF TG_OP = 'INSERT' THEN
          RETURN NEW;
        ELSIF TG_OP = 'UPDATE' THEN
          RETURN NEW;
        ELSIF TG_OP = 'DELETE' THEN
          RETURN OLD;
        END IF;

    END;
$$;


ALTER FUNCTION {schema}.param_user_iud() OWNER TO postgres;

--
-- Name: sanit(text); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION sanit(x text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER COST 10
    AS $$
DECLARE
  y text =  NULL;
BEGIN

  y := replace(replace(replace(x,'"',' '),'''',' '),E'\n',' ');
  

  RETURN y;
END;
$$;


ALTER FUNCTION {schema}.sanit(x text) OWNER TO postgres;

--
-- Name: sanit_json(text); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION sanit_json(x text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER COST 10
    AS $$
DECLARE
  y text =  NULL;
BEGIN

  y := x;

  y := replace(y, chr(x'5C'::int), '\'); /* Back Slash */

  y := replace(y, chr(x'08'::int), '\b'); /* Backspace */
  y := replace(y, chr(x'0C'::int), '\f'); /* Form Feed */
  y := replace(y, chr(x'0A'::int), '\n'); /* New Line */
  y := replace(y, chr(x'0D'::int), '\r'); /* Carriage Return */
  y := replace(y, chr(x'09'::int), '\t'); /* Tab */
  y := replace(y, chr(x'22'::int), '\"'); /* Double Quote */
/*
  y := replace(y, chr(x'27'::int), ' '); /* Single Quote */
*/  
  y := replace(y, chr(x'2F'::int), '\/'); /* Forward Slash */

/*  
  y := replace(replace(replace(x,'"',' '),'''',' '),E'\n',' ');
*/  

  RETURN y;
END;
$$;


ALTER FUNCTION {schema}.sanit_json(x text) OWNER TO postgres;

--
-- Name: sys_user_func_iud(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION sys_user_func_iud() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
      curdttm    timestamp default {schema}.my_now();
      myuser     text default {schema}.my_db_user();
      audit_seq    bigint default NULL;
      my_id      bigint default case TG_OP when 'DELETE' then OLD.sys_user_func_id else NEW.sys_user_func_id end;
      my_toa     {schema}.toaudit;
    BEGIN

        /**********************************/
        /* INITIALIZE                     */ 
        /**********************************/

        my_toa.op := TG_OP;
        my_toa.audit_table_name := upper(TG_audit_table_name::text);
        my_toa.cust_id := NULL;
        my_toa.item_id := NULL;
        my_toa.audit_ref_name := NULL;
        my_toa.audit_ref_id := NULL;
        my_toa.audit_subject := case when TG_OP = 'DELETE' then NULL else (select coalesce(sys_user_lname,'')||', '||coalesce(sys_user_fname,'') 
                                                                    from {schema}.cust_user 
                                                                   where sys_user_id = NEW.sys_user_id) end;
         

        /**********************************/
        /* PERFORM CHECKS                 */ 
        /**********************************/

        IF TG_OP = 'UPDATE'
           and
           {schema}.nequal(NEW.sys_user_func_id, OLD.sys_user_func_id) THEN
          RAISE EXCEPTION  'Application Error - ID cannot be updated.';
        END IF;

        IF TG_OP = 'UPDATE'
           and
           {schema}.nequal(NEW.sys_user_id, OLD.sys_user_id) THEN
          RAISE EXCEPTION  'Application Error - User ID cannot be updated.';
        END IF;




        /**********************************/
        /* AUDIT TRAIL                    */ 
        /**********************************/

        IF TG_OP = 'INSERT' THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id);  
        END IF;


        IF (case when TG_OP = 'DELETE' then OLD.sys_user_func_id is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.sys_user_func_id, OLD.sys_user_func_id) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'sys_user_func_id', OLD.sys_user_func_id::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.sys_user_id is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.sys_user_id, OLD.sys_user_id) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'sys_user_id', OLD.sys_user_id::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.sys_func_name is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.sys_func_name, OLD.sys_func_name) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'sys_func_name', OLD.sys_func_name::text);  
        END IF;


        /**********************************/
        /* UPDATES AND OTHER TABLES       */ 
        /**********************************/

        /**********************************/
        /* RETURN                         */ 
        /**********************************/
    
        IF TG_OP = 'INSERT' THEN
          RETURN NEW;
        ELSIF TG_OP = 'UPDATE' THEN
          RETURN NEW;
        ELSIF TG_OP = 'DELETE' THEN
          RETURN OLD;
        END IF;

    END;
$$;


ALTER FUNCTION {schema}.sys_user_func_iud() OWNER TO postgres;

--
-- Name: sys_user_role_iud(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION sys_user_role_iud() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
      curdttm    timestamp default {schema}.my_now();
      myuser     text default {schema}.my_db_user();
      audit_seq    bigint default NULL;
      my_id      bigint default case TG_OP when 'DELETE' then OLD.sys_user_role_id else NEW.sys_user_role_id end;
      my_toa     {schema}.toaudit;
    BEGIN

        /**********************************/
        /* INITIALIZE                     */ 
        /**********************************/

        my_toa.op := TG_OP;
        my_toa.audit_table_name := upper(TG_audit_table_name::text);
        my_toa.cust_id := NULL;
        my_toa.item_id := NULL;
        my_toa.audit_ref_name := NULL;
        my_toa.audit_ref_id := NULL;
        my_toa.audit_subject := case when TG_OP = 'DELETE' then NULL else (select coalesce(sys_user_lname,'')||', '||coalesce(sys_user_fname,'') 
                                                                    from {schema}.cust_user 
                                                                   where sys_user_id = NEW.sys_user_id) end;
         

        /**********************************/
        /* PERFORM CHECKS                 */ 
        /**********************************/

        IF TG_OP = 'UPDATE'
           and
           {schema}.nequal(NEW.sys_user_role_id, OLD.sys_user_role_id) THEN
          RAISE EXCEPTION  'Application Error - ID cannot be updated.';
        END IF;

        IF TG_OP = 'UPDATE'
           and
           {schema}.nequal(NEW.sys_user_id, OLD.sys_user_id) THEN
          RAISE EXCEPTION  'Application Error - User ID cannot be updated.';
        END IF;

        IF {schema}.my_sys_user_id() is not null
           and 
           (case when TG_OP = 'DELETE' then OLD.sys_role_name else NEW.sys_role_name end) = 'DEV' THEN
          
          IF not exists (select sys_role_name
                           from {schema}.v_my_roles
                          where sys_role_name = 'DEV') THEN
            RAISE EXCEPTION  'Application Error - Only Developer can maintain Developer Role.';
          END IF;                 
           
        END IF;   

        /**********************************/
        /* AUDIT TRAIL                    */ 
        /**********************************/

        IF TG_OP = 'INSERT' THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id);  
        END IF;


        IF (case when TG_OP = 'DELETE' then OLD.sys_user_role_id is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.sys_user_role_id, OLD.sys_user_role_id) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'sys_user_role_id', OLD.sys_user_role_id::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.sys_user_id is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.sys_user_id, OLD.sys_user_id) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'sys_user_id', OLD.sys_user_id::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.sys_role_name is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.sys_role_name, OLD.sys_role_name) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'sys_role_name', OLD.sys_role_name::text);  
        END IF;


        /**********************************/
        /* UPDATES AND OTHER TABLES       */ 
        /**********************************/

        /**********************************/
        /* RETURN                         */ 
        /**********************************/
    
        IF TG_OP = 'INSERT' THEN
          RETURN NEW;
        ELSIF TG_OP = 'UPDATE' THEN
          RETURN NEW;
        ELSIF TG_OP = 'DELETE' THEN
          RETURN OLD;
        END IF;

    END;
$$;


ALTER FUNCTION {schema}.sys_user_role_iud() OWNER TO postgres;

--
-- Name: table_type(character varying, character varying); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION table_type(in_schema character varying, in_name character varying) RETURNS character varying
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE
    rslt          text;
BEGIN

  rslt := NULL;

  select table_type
    into rslt
    from information_schema.tables
   where table_schema = lower(coalesce(in_schema,'public'))
     and audit_table_name = lower(in_name); 

  RETURN rslt;

EXCEPTION WHEN OTHERS THEN

  raise notice '% %', SQLERRM, SQLSTATE;

END;
$$;


ALTER FUNCTION {schema}.table_type(in_schema character varying, in_name character varying) OWNER TO postgres;

--
-- Name: txt__tbl_iud(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION txt__tbl_iud() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
      curdttm    timestamp default {schema}.my_now();
      myuser     text default {schema}.my_db_user();
      audit_seq    bigint default NULL;
      my_id      bigint default case TG_OP when 'DELETE' then OLD.txt_id else NEW.txt_id end;
      my_toa     {schema}.toaudit;
    BEGIN

        /**********************************/
        /* INITIALIZE                     */ 
        /**********************************/

        my_toa.op := TG_OP;
        my_toa.audit_table_name := upper(TG_audit_table_name::text);
        my_toa.cust_id := NULL;
        my_toa.item_id := NULL;
        my_toa.audit_ref_name := NULL;
        my_toa.audit_ref_id := NULL;
        my_toa.audit_subject := NULL;


        /**********************************/
        /* PERFORM CHECKS                 */ 
        /**********************************/
            
        IF TG_OP = 'UPDATE' THEN
          IF {schema}.nequal(NEW.txt_id, OLD.txt_id) THEN
            RAISE EXCEPTION  'Application Error - ID cannot be updated.';
          END IF;
        END IF;
          

        /**********************************/
        /* AUDIT TRAIL                    */ 
        /**********************************/

        IF TG_OP = 'INSERT' THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.txt_id is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.txt_id, OLD.txt_id) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'txt_id',OLD.txt_id::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.txt_process is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.txt_process, OLD.txt_process) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'txt_process',OLD.txt_process::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.txt_attrib is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.txt_attrib, OLD.txt_attrib) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'txt_attrib',OLD.txt_attrib::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.txt_type is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.txt_type, OLD.txt_type) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'txt_type',OLD.txt_type::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.txt_title is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.txt_title, OLD.txt_title) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'txt_title',OLD.txt_title::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.txt_body is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.txt_body, OLD.txt_body) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'txt_body',OLD.txt_body::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.txt_bcc is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.txt_bcc, OLD.txt_bcc) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'txt_bcc',OLD.txt_bcc::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.txt_desc is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.txt_desc, OLD.txt_desc) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'txt_desc',OLD.txt_desc::text);  
        END IF;
 
        /**********************************/
        /* UPDATES AND OTHER TABLES       */ 
        /**********************************/
     
        IF TG_OP = 'INSERT' THEN
	  NEW.txt_etstmp := curdttm;
	  NEW.txt_euser := myuser;
	  NEW.txt_mtstmp := curdttm;
	  NEW.txt_muser := myuser;
        ELSIF TG_OP = 'UPDATE' THEN
          IF audit_seq is not NULL THEN
	    NEW.txt_mtstmp := curdttm;
	    NEW.txt_muser := myuser;
	  END IF;  
        END IF;


        /**********************************/
        /* RETURN                         */ 
        /**********************************/
    
        IF TG_OP = 'INSERT' THEN
          RETURN NEW;
        ELSIF TG_OP = 'UPDATE' THEN
          RETURN NEW;
        ELSIF TG_OP = 'DELETE' THEN
          RETURN OLD;
        END IF;

    END;
$$;


ALTER FUNCTION {schema}.txt__tbl_iud() OWNER TO postgres;

--
-- Name: v_cust_menu_role_selection_iud_insteadof_update(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION v_cust_menu_role_selection_iud_insteadof_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
      curdttm   timestamp default {schema}.my_now();
      myuser    text default {schema}.my_db_user();
      M         text; 
    BEGIN

        IF ({schema}.nequal(NEW.cust_menu_role_selection, OLD.cust_menu_role_selection)
            and
            coalesce(NEW.cust_menu_role_selection,0) = 0) THEN

          delete from {schema}.cust_menu_role
                where cust_menu_role_id = NEW.cust_menu_role_id;
            
        END IF;    

        IF ({schema}.nequal(NEW.cust_menu_role_selection, OLD.cust_menu_role_selection)
            and
            coalesce(NEW.cust_menu_role_selection,0) = 1) THEN

          IF coalesce(NEW.new_cust_role_name,'')<>'' THEN
            insert into {schema}.cust_menu_role (cust_role_name, menu_id)
                             values (NEW.new_cust_role_name, NEW.menu_id);
	  ELSE
            insert into {schema}.cust_menu_role (cust_role_name, menu_id)
                             values (NEW.cust_role_name, NEW.new_menu_id);
          END IF;                     
            
        END IF;    


        RETURN NEW;

    END;
$$;


ALTER FUNCTION {schema}.v_cust_menu_role_selection_iud_insteadof_update() OWNER TO postgres;

--
-- Name: v_sys_menu_role_selection_iud_insteadof_update(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION v_sys_menu_role_selection_iud_insteadof_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
      curdttm   timestamp default {schema}.my_now();
      myuser    text default {schema}.my_db_user();
      M         text; 
    BEGIN

        IF ({schema}.nequal(NEW.sys_menu_role_selection, OLD.sys_menu_role_selection)
            and
            coalesce(NEW.sys_menu_role_selection,0) = 0) THEN

          delete from {schema}.sys_menu_role 
                where sys_menu_role_id = NEW.sys_menu_role_id;
            
        END IF;    

        IF ({schema}.nequal(NEW.sys_menu_role_selection, OLD.sys_menu_role_selection)
            and
            coalesce(NEW.sys_menu_role_selection,0) = 1) THEN
          IF coalesce(NEW.new_sys_role_name,'')<>'' THEN
            insert into {schema}.sys_menu_role (sys_role_name, menu_id)
                             values (NEW.new_sys_role_name, NEW.menu_id);
	  ELSE
            insert into {schema}.sys_menu_role (sys_role_name, menu_id)
                             values (NEW.sys_role_name, NEW.new_menu_id);
          END IF;                     
            
        END IF;    


        RETURN NEW;

    END;
$$;


ALTER FUNCTION {schema}.v_sys_menu_role_selection_iud_insteadof_update() OWNER TO postgres;

--
-- Name: param_sys_iud(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION param_sys_iud() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
      curdttm    timestamp default {schema}.my_now();
      myuser     text default {schema}.my_db_user();
      audit_seq    bigint default NULL;
      my_id      bigint default case TG_OP when 'DELETE' then OLD.param_sys_id else NEW.param_sys_id end;
      my_toa     {schema}.toaudit;
      m          text;
    BEGIN

        /**********************************/
        /* INITIALIZE                     */ 
        /**********************************/

        my_toa.op := TG_OP;
        my_toa.audit_table_name := upper(TG_audit_table_name::text);
        my_toa.cust_id := NULL;
        my_toa.item_id := NULL;
        my_toa.audit_ref_name := NULL;
        my_toa.audit_ref_id := NULL;
        my_toa.audit_subject := NULL;


        /**********************************/
        /* PERFORM CHECKS                 */ 
        /**********************************/
            
        IF TG_OP = 'UPDATE' THEN
          IF {schema}.nequal(NEW.param_sys_id, OLD.param_sys_id) THEN
            RAISE EXCEPTION  'Application Error - ID cannot be updated.';
          END IF;
          IF {schema}.nequal(NEW.param_sys_process, OLD.param_sys_process) THEN
            RAISE EXCEPTION  'Application Error - Process cannot be updated..';
          END IF;
          IF {schema}.nequal(NEW.param_sys_attrib, OLD.param_sys_attrib) THEN
            RAISE EXCEPTION  'Application Error - Attribute cannot be updated..';
          END IF;
        END IF;
          

        IF (TG_OP = 'INSERT' or TG_OP = 'UPDATE') THEN
          m := {schema}.check_param('param_sys', NEW.param_sys_process, NEW.param_sys_attrib, NEW.param_sys_val);
          IF m IS NOT null THEN 
            RAISE EXCEPTION '%', m;
          END IF;
        END IF;



        /**********************************/
        /* AUDIT TRAIL                    */ 
        /**********************************/

        IF TG_OP = 'INSERT' THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.param_sys_id is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.param_sys_id, OLD.param_sys_id) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'param_sys_id',OLD.param_sys_id::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.param_sys_process is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.param_sys_process, OLD.param_sys_process) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'param_sys_process',OLD.param_sys_process::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.param_sys_attrib is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.param_sys_attrib, OLD.param_sys_attrib) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'param_sys_attrib',OLD.param_sys_attrib::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.param_sys_val is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.param_sys_val, OLD.param_sys_val) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'param_sys_val',OLD.param_sys_val::text);  
        END IF;

 
        /**********************************/
        /* UPDATES AND OTHER TABLES       */ 
        /**********************************/
     
        IF TG_OP = 'INSERT' THEN
	  NEW.param_sys_etstmp := curdttm;
	  NEW.param_sys_euser := myuser;
	  NEW.param_sys_mtstmp := curdttm;
	  NEW.param_sys_muser := myuser;
        ELSIF TG_OP = 'UPDATE' THEN
          IF audit_seq is not NULL THEN
	    NEW.param_sys_mtstmp := curdttm;
	    NEW.param_sys_muser := myuser;
	  END IF;  
        END IF;


        /**********************************/
        /* RETURN                         */ 
        /**********************************/
    
        IF TG_OP = 'INSERT' THEN
          RETURN NEW;
        ELSIF TG_OP = 'UPDATE' THEN
          RETURN NEW;
        ELSIF TG_OP = 'DELETE' THEN
          RETURN OLD;
        END IF;

    END;
$$;


ALTER FUNCTION {schema}.param_sys_iud() OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: audit_detail; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE audit_detail (
    audit_seq bigint NOT NULL,
    audit_column_name character varying(30) NOT NULL,
    audit_column_val text
);


ALTER TABLE audit_detail OWNER TO postgres;

--
-- Name: TABLE audit_detail; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE audit_detail IS 'Audit Trail Detail (CONTROL)';


--
-- Name: COLUMN audit_detail.audit_seq; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN audit_detail.audit_seq IS 'Audit Sequence';


--
-- Name: COLUMN audit_detail.audit_column_name; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN audit_detail.audit_column_name IS 'Audit Detail Column Name';


--
-- Name: COLUMN audit_detail.audit_column_val; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN audit_detail.audit_column_val IS 'Audit Detail Column Value';


--
-- Name: audit__tbl; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE audit__tbl (
    audit_seq bigint NOT NULL,
    audit_table_name character varying(32) NOT NULL,
    audit_table_id bigint NOT NULL,
    audit_op character(10) NOT NULL,
    audit_user character varying(20) NOT NULL,
    db_id character(1) DEFAULT 0 NOT NULL,
    audit_tstmp timestamp without time zone NOT NULL,
    cust_id bigint,
    item_id bigint,
    audit_ref_name character varying(32),
    audit_ref_id bigint,
    audit_subject character varying(255)
);


ALTER TABLE audit__tbl OWNER TO postgres;

--
-- Name: TABLE audit__tbl; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE audit__tbl IS 'Audit Trail Header (CONTROL)';


--
-- Name: COLUMN audit__tbl.audit_seq; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN audit__tbl.audit_seq IS 'Audit Sequence';


--
-- Name: COLUMN audit__tbl.audit_table_name; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN audit__tbl.audit_table_name IS 'Audit Header Table Name';


--
-- Name: COLUMN audit__tbl.audit_table_id; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN audit__tbl.audit_table_id IS 'Audit Header Table ID Value';


--
-- Name: COLUMN audit__tbl.audit_op; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN audit__tbl.audit_op IS 'Audit Header Operation (I, U or doc__tbl)';


--
-- Name: COLUMN audit__tbl.audit_user; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN audit__tbl.audit_user IS 'Audit Header User';


--
-- Name: COLUMN audit__tbl.db_id; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN audit__tbl.db_id IS 'Audit Header ???';


--
-- Name: COLUMN audit__tbl.audit_tstmp; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN audit__tbl.audit_tstmp IS 'Audit Header Timestamp';


--
-- Name: COLUMN audit__tbl.cust_id; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN audit__tbl.cust_id IS 'Audit Header Customer ID';


--
-- Name: COLUMN audit__tbl.item_id; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN audit__tbl.item_id IS 'Audit Header item__tbl ID';


--
-- Name: COLUMN audit__tbl.audit_ref_name; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN audit__tbl.audit_ref_name IS 'Audit Header Reference Name';


--
-- Name: COLUMN audit__tbl.audit_ref_id; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN audit__tbl.audit_ref_id IS 'Audit Header Reference ID';


--
-- Name: COLUMN audit__tbl.audit_subject; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN audit__tbl.audit_subject IS 'Audit Header Subject';


--
-- Name: audit__tbl_audit_seq_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE audit__tbl_audit_seq_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE audit__tbl_audit_seq_seq OWNER TO postgres;

--
-- Name: audit__tbl_audit_seq_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE audit__tbl_audit_seq_seq OWNED BY audit__tbl.audit_seq;


--
-- Name: cust_user; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE cust_user (
    sys_user_id bigint NOT NULL,
    cust_id bigint NOT NULL,
    sys_user_sts character varying(32) NOT NULL,
    sys_user_stsdt date DEFAULT my_now() NOT NULL,
    sys_user_fname character varying(35) NOT NULL,
    sys_user_mname character varying(35),
    sys_user_lname character varying(35) NOT NULL,
    sys_user_jobtitle character varying(35),
    sys_user_bphone character varying(30),
    sys_user_cphone character varying(30),
    sys_user_email character varying(255) NOT NULL,
    sys_user_etstmp timestamp without time zone DEFAULT my_now() NOT NULL,
    sys_user_euser character varying(20) DEFAULT my_db_user() NOT NULL,
    sys_user_mtstmp timestamp without time zone DEFAULT my_now() NOT NULL,
    sys_user_muser character varying(20) DEFAULT my_db_user() NOT NULL,
    sys_user_pw1 character varying(255),
    sys_user_pw2 character varying(255),
    sys_user_hash bytea DEFAULT '\x00'::bytea NOT NULL,
    sys_user_lastlogin_ip character varying(255),
    sys_user_lastlogin_tstmp timestamp without time zone,
    sys_user_snotes character varying(255),
    CONSTRAINT cust_user_sys_user_email_check CHECK (((COALESCE(sys_user_email, ''::character varying))::text <> ''::text))
);


ALTER TABLE cust_user OWNER TO postgres;

--
-- Name: TABLE cust_user; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE cust_user IS '	Customer Personnel (CONTROL)';


--
-- Name: cust_user_sys_user_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE cust_user_sys_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE cust_user_sys_user_id_seq OWNER TO postgres;

--
-- Name: cust_user_sys_user_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE cust_user_sys_user_id_seq OWNED BY cust_user.sys_user_id;


--
-- Name: cust_user_role; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE cust_user_role (
    sys_user_id bigint NOT NULL,
    cust_user_role_snotes character varying(255),
    cust_user_role_id bigint NOT NULL,
    cust_role_name character varying(16) NOT NULL
);


ALTER TABLE cust_user_role OWNER TO postgres;

--
-- Name: TABLE cust_user_role; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE cust_user_role IS '	Customer - Personnel Roles (CONTROL)';


--
-- Name: cust_user_role_cust_user_role_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE cust_user_role_cust_user_role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE cust_user_role_cust_user_role_id_seq OWNER TO postgres;

--
-- Name: cust_user_role_cust_user_role_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE cust_user_role_cust_user_role_id_seq OWNED BY cust_user_role.cust_user_role_id;


--
-- Name: cust_role; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE cust_role (
    cust_role_id bigint NOT NULL,
    cust_role_seq smallint NOT NULL,
    cust_role_sts character varying(32) DEFAULT 'ACTIVE'::character varying NOT NULL,
    cust_role_name character varying(16) NOT NULL,
    cust_role_desc character varying(255) NOT NULL,
    cust_role_snotes character varying(255),
    cust_role_code character varying(50),
    cust_role_attrib character varying(50)
);


ALTER TABLE cust_role OWNER TO postgres;

--
-- Name: TABLE cust_role; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE cust_role IS 'Customer - Roles (CONTROL)';


--
-- Name: cust_role_cust_role_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE cust_role_cust_role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE cust_role_cust_role_id_seq OWNER TO postgres;

--
-- Name: cust_role_cust_role_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE cust_role_cust_role_id_seq OWNED BY cust_role.cust_role_id;


--
-- Name: cust_menu_role; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE cust_menu_role (
    menu_id bigint NOT NULL,
    cust_menu_role_snotes character varying(255),
    cust_menu_role_id bigint NOT NULL,
    cust_role_name character varying(16) NOT NULL
);


ALTER TABLE cust_menu_role OWNER TO postgres;

--
-- Name: TABLE cust_menu_role; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE cust_menu_role IS 'Customer - Role Menu Items (CONTROL)';


--
-- Name: cust_menu_role_cust_menu_role_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE cust_menu_role_cust_menu_role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE cust_menu_role_cust_menu_role_id_seq OWNER TO postgres;

--
-- Name: cust_menu_role_cust_menu_role_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE cust_menu_role_cust_menu_role_id_seq OWNED BY cust_menu_role.cust_menu_role_id;


--
-- Name: doc__tbl; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE doc__tbl (
    doc_id bigint NOT NULL,
    doc_scope character varying(32) DEFAULT 'S'::character varying NOT NULL,
    doc_scope_id bigint DEFAULT 0 NOT NULL,
    cust_id bigint,
    item_id bigint,
    doc_sts character varying(32) DEFAULT 'A'::character varying NOT NULL,
    doc_ctgr character varying(32) NOT NULL,
    doc_desc character varying(255),
    doc_ext character varying(16),
    doc_size bigint,
    doc_etstmp timestamp without time zone DEFAULT my_now() NOT NULL,
    doc_euser character varying(20) DEFAULT my_db_user() NOT NULL,
    doc_mtstmp timestamp without time zone DEFAULT my_now() NOT NULL,
    doc_muser character varying(20) DEFAULT my_db_user() NOT NULL,
    doc_uptstmp timestamp without time zone DEFAULT my_now() NOT NULL,
    doc_upuser character varying(20) DEFAULT my_db_user() NOT NULL,
    doc_sync_tstmp timestamp without time zone,
    doc_snotes character varying(255),
    doc_sync_id bigint
);


ALTER TABLE doc__tbl OWNER TO postgres;

--
-- Name: TABLE doc__tbl; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE doc__tbl IS 'Documents (CONTROL)';


--
-- Name: COLUMN doc__tbl.doc_id; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN doc__tbl.doc_id IS 'Document ID';


--
-- Name: COLUMN doc__tbl.doc_scope; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN doc__tbl.doc_scope IS 'Document Scope - code_doc_scope';


--
-- Name: COLUMN doc__tbl.doc_scope_id; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN doc__tbl.doc_scope_id IS 'Document Scope ID';


--
-- Name: COLUMN doc__tbl.cust_id; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN doc__tbl.cust_id IS 'Customer ID - C';


--
-- Name: COLUMN doc__tbl.item_id; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN doc__tbl.item_id IS 'E ID - E';


--
-- Name: COLUMN doc__tbl.doc_sts; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN doc__tbl.doc_sts IS 'Document Status - code_ac1';


--
-- Name: COLUMN doc__tbl.doc_ctgr; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN doc__tbl.doc_ctgr IS 'Document Category - code2_doc_scope_doc_ctgr';


--
-- Name: COLUMN doc__tbl.doc_desc; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN doc__tbl.doc_desc IS 'Document Description';


--
-- Name: COLUMN doc__tbl.doc_ext; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN doc__tbl.doc_ext IS 'Document Extension (file suffix)';


--
-- Name: COLUMN doc__tbl.doc_size; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN doc__tbl.doc_size IS 'Document Size in bytes';


--
-- Name: COLUMN doc__tbl.doc_etstmp; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN doc__tbl.doc_etstmp IS 'Document Entry Timestamp';


--
-- Name: COLUMN doc__tbl.doc_euser; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN doc__tbl.doc_euser IS 'Document Entry User';


--
-- Name: COLUMN doc__tbl.doc_mtstmp; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN doc__tbl.doc_mtstmp IS 'Document Last Modification Timestamp';


--
-- Name: COLUMN doc__tbl.doc_muser; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN doc__tbl.doc_muser IS 'Document Last Modification User';


--
-- Name: COLUMN doc__tbl.doc_uptstmp; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN doc__tbl.doc_uptstmp IS 'Document Last Upload Timestamp';


--
-- Name: COLUMN doc__tbl.doc_upuser; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN doc__tbl.doc_upuser IS 'Document Last Upload User';


--
-- Name: COLUMN doc__tbl.doc_sync_tstmp; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN doc__tbl.doc_sync_tstmp IS 'Document Synchronization Timestamp';


--
-- Name: COLUMN doc__tbl.doc_snotes; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN doc__tbl.doc_snotes IS 'Document System Notes';


--
-- Name: COLUMN doc__tbl.doc_sync_id; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN doc__tbl.doc_sync_id IS 'Document Main ID (Synchronization)';


--
-- Name: doc__tbl_doc_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE doc__tbl_doc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE doc__tbl_doc_id_seq OWNER TO postgres;

--
-- Name: doc__tbl_doc_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE doc__tbl_doc_id_seq OWNED BY doc__tbl.doc_id;


--
-- Name: single; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE single (
    single_dummy character varying(1) NOT NULL,
    single_ident bigint NOT NULL,
    dual_bigint bigint,
    single_varchar50 character varying(50)
);


ALTER TABLE single OWNER TO postgres;

--
-- Name: TABLE single; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE single IS 'System Table (CONTROL)';


--
-- Name: single_single_ident_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE single_single_ident_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE single_single_ident_seq OWNER TO postgres;

--
-- Name: single_single_ident_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE single_single_ident_seq OWNED BY single.single_ident;


--
-- Name: code_app_base_code_app_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE code_app_base_code_app_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE code_app_base_code_app_id_seq OWNER TO postgres;

--
-- Name: code_app_base; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE code_app_base (
    code_app_id bigint DEFAULT nextval('code_app_base_code_app_id_seq'::regclass) NOT NULL,
    code_seq smallint,
    code_val character varying(32) NOT NULL,
    code_txt character varying(50) NOT NULL,
    code_code character varying(50),
    code_end_dt date,
    code_end_reason character varying(50),
    code_etstmp timestamp without time zone DEFAULT my_now() NOT NULL,
    code_euser character varying(20) DEFAULT my_db_user() NOT NULL,
    code_mtstmp timestamp without time zone DEFAULT my_now() NOT NULL,
    code_muser character varying(20) DEFAULT my_db_user() NOT NULL,
    code_snotes character varying(255),
    code_notes character varying(255),
    code_attrib character varying(50)
);


ALTER TABLE code_app_base OWNER TO postgres;

--
-- Name: TABLE code_app_base; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE code_app_base IS 'User Codes - TEMPLATE';


--
-- Name: code2_app_base_code2_app_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE code2_app_base_code2_app_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE code2_app_base_code2_app_id_seq OWNER TO postgres;

--
-- Name: code2_app; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE code2_app_base (
    code2_app_id bigint DEFAULT nextval('code2_app_base_code2_app_id_seq'::regclass) NOT NULL,
    code_seq smallint,
    code_val1 character varying(32) NOT NULL,
    code_va12 character varying(32) NOT NULL,
    code_txt character varying(50),
    code_code character varying(50),
    code_end_dt date,
    code_end_reason character varying(50),
    code_etstmp timestamp without time zone DEFAULT my_now(),
    code_euser character varying(20) DEFAULT my_db_user(),
    code_mtstmp timestamp without time zone DEFAULT my_now(),
    code_muser character varying(20) DEFAULT my_db_user(),
    code_snotes character varying(255),
    code_notes character varying(255),
    code_attrib character varying(50)
);


ALTER TABLE code2_app_base OWNER TO postgres;

--
-- Name: TABLE code2_app_base; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE code2_app_base IS 'User Codes 2 - TEMPLATE';


--
-- Name: code2_doc_scope_doc_ctgr; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE code2_doc_scope_doc_ctgr (
)
INHERITS (code2_app_base);


ALTER TABLE code2_doc_scope_doc_ctgr OWNER TO postgres;

--
-- Name: TABLE code2_doc_scope_doc_ctgr; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE code2_doc_scope_doc_ctgr IS 'User Codes 2 - Document Scope / Category';


--
-- Name: code2_app; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE code2_app (
    code_name character varying(128) NOT NULL,
    code_desc character varying(128),
    code_code_desc character varying(128),
    code_h_etstmp timestamp without time zone DEFAULT my_now() NOT NULL,
    code_h_euser character varying(20) DEFAULT my_db_user() NOT NULL,
    code_h_mtstmp timestamp without time zone DEFAULT my_now() NOT NULL,
    code_h_muser character varying(20) DEFAULT my_db_user() NOT NULL,
    code_snotes character varying(255),
    code_attrib_desc character varying(128),
    code_schema character varying(128)
);


ALTER TABLE code2_app OWNER TO postgres;

--
-- Name: TABLE code2_app; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE code2_app IS 'User Codes 2 Header (CONTROL)';


--
-- Name: code_app; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE code_app (
    code_name character varying(128) NOT NULL,
    code_desc character varying(128),
    code_code_desc character varying(128),
    code_h_etstmp timestamp without time zone DEFAULT my_now() NOT NULL,
    code_h_euser character varying(20) DEFAULT my_db_user() NOT NULL,
    code_h_mtstmp timestamp without time zone DEFAULT my_now() NOT NULL,
    code_h_muser character varying(20) DEFAULT my_db_user() NOT NULL,
    code_snotes character varying(255),
    code_attrib_desc character varying(128),
    code_schema character varying(128)
);


ALTER TABLE code_app OWNER TO postgres;

--
-- Name: TABLE code_app; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE code_app IS 'User Codes Header (CONTROL)';


--
-- Name: param_app; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE param_app (
    param_app_id bigint NOT NULL,
    param_app_process character varying(32) NOT NULL,
    param_app_attrib character varying(16) NOT NULL,
    param_app_val character varying(256),
    param_app_etstmp timestamp without time zone DEFAULT my_now() NOT NULL,
    param_app_euser character varying(20) DEFAULT my_db_user() NOT NULL,
    param_app_mtstmp timestamp without time zone DEFAULT my_now() NOT NULL,
    param_app_muser character varying(20) DEFAULT my_db_user() NOT NULL
);


ALTER TABLE param_app OWNER TO postgres;

--
-- Name: TABLE param_app; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE param_app IS 'Process Parameters - Global (CONTROL)';


--
-- Name: param_app_param_app_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE param_app_param_app_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE param_app_param_app_id_seq OWNER TO postgres;

--
-- Name: param_app_param_app_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE param_app_param_app_id_seq OWNED BY param_app.param_app_id;


--
-- Name: help__tbl; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE help__tbl (
    help_id bigint NOT NULL,
    help_target_code character varying(50),
    help_title character varying(70) NOT NULL,
    help_text text NOT NULL,
    help_etstmp timestamp without time zone DEFAULT my_now() NOT NULL,
    help_euser character varying(20) DEFAULT my_db_user() NOT NULL,
    help_mtstmp timestamp without time zone DEFAULT my_now() NOT NULL,
    help_muser character varying(20) DEFAULT my_db_user() NOT NULL,
    help_seq integer,
    help_listing_main boolean DEFAULT true NOT NULL,
    help_listing_client boolean DEFAULT true NOT NULL
);


ALTER TABLE help__tbl OWNER TO postgres;

--
-- Name: TABLE help__tbl; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE help__tbl IS 'Help (CONTROL)';


--
-- Name: help__tbl_help_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE help__tbl_help_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE help__tbl_help_id_seq OWNER TO postgres;

--
-- Name: help__tbl_help_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE help__tbl_help_id_seq OWNED BY help__tbl.help_id;


--
-- Name: help_target; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE help_target (
    help_target_id bigint NOT NULL,
    help_target_code character varying(50) NOT NULL,
    help_target_desc character varying(50) NOT NULL
);


ALTER TABLE help_target OWNER TO postgres;

--
-- Name: TABLE help_target; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE help_target IS 'Help Header (CONTROL)';


--
-- Name: help_target_help_target_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE help_target_help_target_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE help_target_help_target_id_seq OWNER TO postgres;

--
-- Name: help_target_help_target_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE help_target_help_target_id_seq OWNED BY help_target.help_target_id;


--
-- Name: note__tbl; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE note__tbl (
    note_id bigint NOT NULL,
    note_scope character varying(32) DEFAULT 'S'::character varying NOT NULL,
    note_scope_id bigint DEFAULT 0 NOT NULL,
    note_sts character varying(32) DEFAULT 'A'::character varying NOT NULL,
    cust_id bigint,
    item_id bigint,
    note_type character varying(32) NOT NULL,
    note_body text NOT NULL,
    note_etstmp timestamp without time zone DEFAULT my_now() NOT NULL,
    note_euser character varying(20) DEFAULT my_db_user() NOT NULL,
    note_mtstmp timestamp without time zone DEFAULT my_now() NOT NULL,
    note_muser character varying(20) DEFAULT my_db_user() NOT NULL,
    note_sync_tstmp timestamp without time zone,
    note_snotes character varying(255),
    note_sync_id bigint
);


ALTER TABLE note__tbl OWNER TO postgres;

--
-- Name: TABLE note__tbl; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE note__tbl IS 'Notes (CONTROL)';


--
-- Name: COLUMN note__tbl.note_id; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN note__tbl.note_id IS 'Note ID';


--
-- Name: COLUMN note__tbl.note_scope; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN note__tbl.note_scope IS 'Note Scope - code_note_scope';


--
-- Name: COLUMN note__tbl.note_scope_id; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN note__tbl.note_scope_id IS 'Note Scope ID';


--
-- Name: COLUMN note__tbl.note_sts; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN note__tbl.note_sts IS 'Note Status - code_ac1';


--
-- Name: COLUMN note__tbl.cust_id; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN note__tbl.cust_id IS 'Customer ID - C';


--
-- Name: COLUMN note__tbl.item_id; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN note__tbl.item_id IS 'E ID - E';


--
-- Name: COLUMN note__tbl.note_type; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN note__tbl.note_type IS 'Note Type - code_note_type - C, S, U';


--
-- Name: COLUMN note__tbl.note_body; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN note__tbl.note_body IS 'Note NOTE';


--
-- Name: COLUMN note__tbl.note_etstmp; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN note__tbl.note_etstmp IS 'Note Entry Timestamp';


--
-- Name: COLUMN note__tbl.note_euser; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN note__tbl.note_euser IS 'Note Entry User';


--
-- Name: COLUMN note__tbl.note_mtstmp; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN note__tbl.note_mtstmp IS 'Note Last Modification Timestamp';


--
-- Name: COLUMN note__tbl.note_muser; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN note__tbl.note_muser IS 'Note Last Modification User';


--
-- Name: COLUMN note__tbl.note_sync_tstmp; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN note__tbl.note_sync_tstmp IS 'Note Synchronization Timestamp';


--
-- Name: COLUMN note__tbl.note_snotes; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN note__tbl.note_snotes IS 'Note System Notes';


--
-- Name: COLUMN note__tbl.note_sync_id; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN note__tbl.note_sync_id IS 'Note Main ID (Synchronization)';


--
-- Name: note__tbl_note_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE note__tbl_note_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE note__tbl_note_id_seq OWNER TO postgres;

--
-- Name: note__tbl_note_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE note__tbl_note_id_seq OWNED BY note__tbl.note_id;


--
-- Name: number__tbl; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE number__tbl (
    number_val smallint NOT NULL
);


ALTER TABLE number__tbl OWNER TO postgres;

--
-- Name: TABLE number__tbl; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE number__tbl IS 'System Table (CONTROL)';


--
-- Name: sys_user; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE sys_user (
    sys_user_id bigint NOT NULL,
    sys_user_sts character varying(32) DEFAULT 'ACTIVE'::character varying NOT NULL,
    sys_user_stsdt date DEFAULT my_now() NOT NULL,
    sys_user_fname character varying(35) NOT NULL,
    sys_user_mname character varying(35),
    sys_user_lname character varying(35) NOT NULL,
    sys_user_jobtitle character varying(35),
    sys_user_bphone character varying(30),
    sys_user_cphone character varying(30),
    sys_user_country character varying(32) DEFAULT 'USA'::character varying NOT NULL,
    sys_user_addr character varying(200),
    sys_user_city character varying(50),
    sys_user_state character varying(32),
    sys_user_zip character varying(20),
    sys_user_email character varying(255) NOT NULL,
    sys_user_startdt date DEFAULT my_now() NOT NULL,
    sys_user_enddt date,
    sys_user_unotes character varying(4000),
    sys_user_etstmp timestamp without time zone DEFAULT my_now() NOT NULL,
    sys_user_euser character varying(20) DEFAULT my_db_user() NOT NULL,
    sys_user_mtstmp timestamp without time zone DEFAULT my_now() NOT NULL,
    sys_user_muser character varying(20) DEFAULT my_db_user() NOT NULL,
    sys_user_pw1 character varying(255),
    sys_user_pw2 character varying(255),
    sys_user_hash bytea DEFAULT '\x00'::bytea NOT NULL,
    sys_user_lastlogin_ip character varying(255),
    sys_user_lastlogin_tstmp timestamp without time zone,
    sys_user_snotes character varying(255),
    CONSTRAINT sys_user_sys_user_email_check CHECK (((COALESCE(sys_user_email, ''::character varying))::text <> ''::text))
);


ALTER TABLE sys_user OWNER TO postgres;

--
-- Name: TABLE sys_user; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE sys_user IS 'Personnel (CONTROL)';


--
-- Name: COLUMN sys_user.sys_user_id; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN sys_user.sys_user_id IS 'Personnel ID';


--
-- Name: COLUMN sys_user.sys_user_sts; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN sys_user.sys_user_sts IS 'Personnel Status';


--
-- Name: COLUMN sys_user.sys_user_stsdt; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN sys_user.sys_user_stsdt IS 'Personnel Status Date';


--
-- Name: sys_user_sys_user_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE sys_user_sys_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sys_user_sys_user_id_seq OWNER TO postgres;

--
-- Name: sys_user_sys_user_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE sys_user_sys_user_id_seq OWNED BY sys_user.sys_user_id;


--
-- Name: param__tbl; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE param__tbl (
    param_id bigint NOT NULL,
    param_process character varying(32) NOT NULL,
    param_attrib character varying(16) NOT NULL,
    param_desc character varying(255) NOT NULL,
    param_type character varying(32) NOT NULL,
    code_name character varying(128),
    param_etstmp timestamp without time zone DEFAULT my_now() NOT NULL,
    param_euser character varying(20) DEFAULT my_db_user() NOT NULL,
    param_mtstmp timestamp without time zone DEFAULT my_now() NOT NULL,
    param_muser character varying(20) DEFAULT my_db_user() NOT NULL,
    param_snotes text,
    is_param_app boolean DEFAULT false NOT NULL,
    is_param_user boolean DEFAULT false NOT NULL,
    is_param_sys boolean DEFAULT false NOT NULL
);


ALTER TABLE param__tbl OWNER TO postgres;

--
-- Name: TABLE param__tbl; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE param__tbl IS 'Process Parameters Dictionary (CONTROL)';


--
-- Name: param__tbl_param_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE param__tbl_param_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE param__tbl_param_id_seq OWNER TO postgres;

--
-- Name: param__tbl_param_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE param__tbl_param_id_seq OWNED BY param__tbl.param_id;


--
-- Name: param_user; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE param_user (
    param_user_id bigint NOT NULL,
    sys_user_id bigint NOT NULL,
    param_user_process character varying(32) NOT NULL,
    param_user_attrib character varying(16) NOT NULL,
    param_user_val character varying(256),
    param_user_etstmp timestamp without time zone DEFAULT my_now() NOT NULL,
    param_user_euser character varying(20) DEFAULT my_db_user() NOT NULL,
    param_user_mtstmp timestamp without time zone DEFAULT my_now() NOT NULL,
    param_user_muser character varying(20) DEFAULT my_db_user() NOT NULL
);


ALTER TABLE param_user OWNER TO postgres;

--
-- Name: TABLE param_user; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE param_user IS 'Process Parameters - Personal (CONTROL)';


--
-- Name: param_user_param_user_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE param_user_param_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE param_user_param_user_id_seq OWNER TO postgres;

--
-- Name: param_user_param_user_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE param_user_param_user_id_seq OWNED BY param_user.param_user_id;


--
-- Name: queue__tbl; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE queue__tbl (
    queue_id bigint NOT NULL,
    queue_etstmp timestamp without time zone DEFAULT my_now() NOT NULL,
    queue_euser character varying(20) DEFAULT my_db_user() NOT NULL,
    queue_name character varying(255) NOT NULL,
    queue_message text NOT NULL,
    queue_rslt character varying(32),
    queue_rslt_tstmp timestamp without time zone,
    queue_rslt_user character varying(20),
    queue_snotes text
);


ALTER TABLE queue__tbl OWNER TO postgres;

--
-- Name: TABLE queue__tbl; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE queue__tbl IS 'Queue Request (CONTROL)';


--
-- Name: queue__tbl_queue_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE queue__tbl_queue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE queue__tbl_queue_id_seq OWNER TO postgres;

--
-- Name: queue__tbl_queue_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE queue__tbl_queue_id_seq OWNED BY queue__tbl.queue_id;


--
-- Name: job__tbl; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE job__tbl (
    job_id bigint NOT NULL,
    job_etstmp timestamp without time zone DEFAULT my_now() NOT NULL,
    job_user character varying(20) DEFAULT my_db_user() NOT NULL,
    job_source character varying(32) NOT NULL,
    job_action character varying(32) NOT NULL,
    job_action_target character varying(50) NOT NULL,
    job_params text,
    job_tag character varying(255),
    job_rslt character varying(32),
    job_rslt_tstmp timestamp without time zone,
    job_rslt_user character varying(20),
    job_snotes text
);


ALTER TABLE job__tbl OWNER TO postgres;

--
-- Name: TABLE job__tbl; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE job__tbl IS 'Request (CONTROL)';


--
-- Name: job_doc; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE job_doc (
    job_doc_id bigint NOT NULL,
    job_id bigint NOT NULL,
    doc_scope character varying(32),
    doc_scope_id bigint,
    doc_ctgr character varying(32),
    doc_desc character varying(255)
);


ALTER TABLE job_doc OWNER TO postgres;

--
-- Name: TABLE job_doc; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE job_doc IS 'Request - Document (CONTROL)';


--
-- Name: job_doc_job_doc_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE job_doc_job_doc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE job_doc_job_doc_id_seq OWNER TO postgres;

--
-- Name: job_doc_job_doc_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE job_doc_job_doc_id_seq OWNED BY job_doc.job_doc_id;


--
-- Name: job_email; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE job_email (
    job_email_id bigint NOT NULL,
    job_id bigint NOT NULL,
    email_txt_attrib character varying(32),
    email_to character varying(255) NOT NULL,
    email_cc character varying(255),
    email_bcc character varying(255),
    email_attach text,
    email_subject character varying(500),
    email_text text,
    email_html text,
    email_doc_id bigint
);


ALTER TABLE job_email OWNER TO postgres;

--
-- Name: TABLE job_email; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE job_email IS 'Request - EMail (CONTROL)';


--
-- Name: job_email_job_email_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE job_email_job_email_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE job_email_job_email_id_seq OWNER TO postgres;

--
-- Name: job_email_job_email_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE job_email_job_email_id_seq OWNED BY job_email.job_email_id;


--
-- Name: job_note; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE job_note (
    job_note_id bigint NOT NULL,
    job_id bigint NOT NULL,
    note_scope character varying(32),
    note_scope_id bigint,
    note_type character varying(32),
    note_body text
);


ALTER TABLE job_note OWNER TO postgres;

--
-- Name: TABLE job_note; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE job_note IS 'Request - Note (CONTROL)';


--
-- Name: job_note_job_note_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE job_note_job_note_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE job_note_job_note_id_seq OWNER TO postgres;

--
-- Name: job_note_job_note_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE job_note_job_note_id_seq OWNED BY job_note.job_note_id;


--
-- Name: job_queue; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE job_queue (
    job_queue_id bigint NOT NULL,
    job_id bigint NOT NULL,
    queue_name character varying(255) NOT NULL,
    queue_message text
);


ALTER TABLE job_queue OWNER TO postgres;

--
-- Name: TABLE job_queue; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE job_queue IS 'Request - queue__tbl (CONTROL)';


--
-- Name: job_queue_job_queue_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE job_queue_job_queue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE job_queue_job_queue_id_seq OWNER TO postgres;

--
-- Name: job_queue_job_queue_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE job_queue_job_queue_id_seq OWNED BY job_queue.job_queue_id;


--
-- Name: job__tbl_job_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE job__tbl_job_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE job__tbl_job_id_seq OWNER TO postgres;

--
-- Name: job__tbl_job_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE job__tbl_job_id_seq OWNED BY job__tbl.job_id;


--
-- Name: job_sms; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE job_sms (
    job_sms_id bigint NOT NULL,
    job_id bigint NOT NULL,
    sms_txt_attrib character varying(32),
    sms_to character varying(255) NOT NULL,
    sms_body text
);


ALTER TABLE job_sms OWNER TO postgres;

--
-- Name: TABLE job_sms; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE job_sms IS 'Request - SMS (CONTROL)';


--
-- Name: job_sms_job_sms_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE job_sms_job_sms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE job_sms_job_sms_id_seq OWNER TO postgres;

--
-- Name: job_sms_job_sms_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE job_sms_job_sms_id_seq OWNED BY job_sms.job_sms_id;


--
-- Name: sys_func; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE sys_func (
    sys_func_id bigint NOT NULL,
    sys_func_seq smallint NOT NULL,
    sys_func_sts character varying(32) DEFAULT 'ACTIVE'::character varying NOT NULL,
    sys_func_name character varying(16) NOT NULL,
    sys_func_desc character varying(255) NOT NULL,
    sys_func_snotes character varying(255),
    sys_func_code character varying(50),
    sys_func_attrib character varying(50)
);


ALTER TABLE sys_func OWNER TO postgres;

--
-- Name: TABLE sys_func; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE sys_func IS 'Security - Functions (CONTROL)';


--
-- Name: COLUMN sys_func.sys_func_id; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN sys_func.sys_func_id IS 'Function ID';


--
-- Name: COLUMN sys_func.sys_func_name; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN sys_func.sys_func_name IS 'Function Name';


--
-- Name: sys_func_sys_func_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE sys_func_sys_func_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sys_func_sys_func_id_seq OWNER TO postgres;

--
-- Name: sys_func_sys_func_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE sys_func_sys_func_id_seq OWNED BY sys_func.sys_func_id;


--
-- Name: menu__tbl; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE menu__tbl (
    menu_id_auto bigint NOT NULL,
    menu_group character(1) DEFAULT 'S'::bpchar NOT NULL,
    menu_id bigint NOT NULL,
    menu_sts character varying(32) DEFAULT 'ACTIVE'::character varying NOT NULL,
    menu_id_parent bigint,
    menu_name character varying(255) NOT NULL,
    menu_seq integer,
    menu_desc character varying(255) NOT NULL,
    menu_desc_ext text,
    menu_desc_ext2 text,
    menu_cmd character varying(255),
    menu_image character varying(255),
    menu_snotes character varying(255),
    menu_subcmd character varying(255),
    CONSTRAINT ck_menu__tbl_menu_group CHECK ((menu_group = ANY (ARRAY['S'::bpchar, 'C'::bpchar])))
);


ALTER TABLE menu__tbl OWNER TO postgres;

--
-- Name: TABLE menu__tbl; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE menu__tbl IS 'Security - Menu Items (CONTROL)';


--
-- Name: menu__tbl_menu_id_auto_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE menu__tbl_menu_id_auto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE menu__tbl_menu_id_auto_seq OWNER TO postgres;

--
-- Name: menu__tbl_menu_id_auto_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE menu__tbl_menu_id_auto_seq OWNED BY menu__tbl.menu_id_auto;


--
-- Name: sys_user_func; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE sys_user_func (
    sys_user_id bigint NOT NULL,
    sys_user_func_snotes character varying(255),
    sys_user_func_id bigint NOT NULL,
    sys_func_name character varying(16) NOT NULL
);


ALTER TABLE sys_user_func OWNER TO postgres;

--
-- Name: TABLE sys_user_func; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE sys_user_func IS 'Security - Personnel Functions (CONTROL)';


--
-- Name: sys_user_func_sys_user_func_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE sys_user_func_sys_user_func_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sys_user_func_sys_user_func_id_seq OWNER TO postgres;

--
-- Name: sys_user_func_sys_user_func_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE sys_user_func_sys_user_func_id_seq OWNED BY sys_user_func.sys_user_func_id;


--
-- Name: sys_user_role; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE sys_user_role (
    sys_user_id bigint NOT NULL,
    sys_user_role_snotes character varying(255),
    sys_user_role_id bigint NOT NULL,
    sys_role_name character varying(16) NOT NULL
);


ALTER TABLE sys_user_role OWNER TO postgres;

--
-- Name: TABLE sys_user_role; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE sys_user_role IS 'Security - Personnel Roles (CONTROL)';


--
-- Name: sys_user_role_sys_user_role_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE sys_user_role_sys_user_role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sys_user_role_sys_user_role_id_seq OWNER TO postgres;

--
-- Name: sys_user_role_sys_user_role_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE sys_user_role_sys_user_role_id_seq OWNED BY sys_user_role.sys_user_role_id;


--
-- Name: sys_role; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE sys_role (
    sys_role_id bigint NOT NULL,
    sys_role_seq smallint NOT NULL,
    sys_role_sts character varying(32) DEFAULT 'ACTIVE'::character varying NOT NULL,
    sys_role_name character varying(16) NOT NULL,
    sys_role_desc character varying(255) NOT NULL,
    sys_role_snotes character varying(255),
    sys_role_code character varying(50),
    sys_role_attrib character varying(50)
);


ALTER TABLE sys_role OWNER TO postgres;

--
-- Name: TABLE sys_role; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE sys_role IS 'Security - Roles (CONTROL)';


--
-- Name: sys_role_sys_role_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE sys_role_sys_role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sys_role_sys_role_id_seq OWNER TO postgres;

--
-- Name: sys_role_sys_role_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE sys_role_sys_role_id_seq OWNED BY sys_role.sys_role_id;


--
-- Name: sys_menu_role; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE sys_menu_role (
    menu_id bigint NOT NULL,
    sys_menu_role_snotes character varying(255),
    sys_menu_role_id bigint NOT NULL,
    sys_role_name character varying(16) NOT NULL
);


ALTER TABLE sys_menu_role OWNER TO postgres;

--
-- Name: TABLE sys_menu_role; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE sys_menu_role IS 'Security - Role Menu Items (CONTROL)';


--
-- Name: sys_menu_role_sys_menu_role_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE sys_menu_role_sys_menu_role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sys_menu_role_sys_menu_role_id_seq OWNER TO postgres;

--
-- Name: sys_menu_role_sys_menu_role_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE sys_menu_role_sys_menu_role_id_seq OWNED BY sys_menu_role.sys_menu_role_id;


--
-- Name: txt__tbl; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE txt__tbl (
    txt_id bigint NOT NULL,
    txt_process character varying(32) NOT NULL,
    txt_attrib character varying(32) NOT NULL,
    txt_type character varying(32) DEFAULT 'TEXT'::character varying NOT NULL,
    txt_title text,
    txt_body text,
    txt_bcc character varying(255),
    txt_desc character varying(255),
    txt_etstmp timestamp without time zone DEFAULT my_now() NOT NULL,
    txt_euser character varying(20) DEFAULT my_db_user() NOT NULL,
    txt_mtstmp timestamp without time zone DEFAULT my_now() NOT NULL,
    txt_muser character varying(20) DEFAULT my_db_user() NOT NULL
);


ALTER TABLE txt__tbl OWNER TO postgres;

--
-- Name: TABLE txt__tbl; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE txt__tbl IS 'String Process Parameters (CONTROL)';


--
-- Name: txt__tbl_txt_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE txt__tbl_txt_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE txt__tbl_txt_id_seq OWNER TO postgres;

--
-- Name: txt__tbl_txt_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE txt__tbl_txt_id_seq OWNED BY txt__tbl.txt_id;


--
-- Name: code_sys_base; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE code_sys_base (
    code_sys_id bigint NOT NULL,
    code_seq smallint,
    code_val character varying(32) NOT NULL,
    code_txt character varying(50),
    code_code character varying(50),
    code_end_dt date,
    code_end_reason character varying(50),
    code_etstmp timestamp without time zone DEFAULT my_now(),
    code_euser character varying(20) DEFAULT my_db_user(),
    code_mtstmp timestamp without time zone DEFAULT my_now(),
    code_muser character varying(20) DEFAULT my_db_user(),
    code_snotes character varying(255),
    code_notes character varying(255),
    code_attrib character varying(50)
);


ALTER TABLE code_sys_base OWNER TO postgres;

--
-- Name: TABLE code_sys_base; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE code_sys_base IS 'System Codes - TEMPLATE';


--
-- Name: COLUMN code_sys_base.code_sys_id; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN code_sys_base.code_sys_id IS 'Code Value ID';


--
-- Name: COLUMN code_sys_base.code_seq; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN code_sys_base.code_seq IS 'Code Value Sequence';


--
-- Name: COLUMN code_sys_base.code_val; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN code_sys_base.code_val IS 'Code Value';


--
-- Name: COLUMN code_sys_base.code_txt; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN code_sys_base.code_txt IS 'Code Value Description';


--
-- Name: COLUMN code_sys_base.code_code; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN code_sys_base.code_code IS 'Code Value Additional Code';


--
-- Name: COLUMN code_sys_base.code_end_dt; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN code_sys_base.code_end_dt IS 'Code Value Termination Date';


--
-- Name: COLUMN code_sys_base.code_end_reason; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN code_sys_base.code_end_reason IS 'Code Value Termination Comment';


--
-- Name: COLUMN code_sys_base.code_etstmp; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN code_sys_base.code_etstmp IS 'Code Value Entry Timestamp';


--
-- Name: COLUMN code_sys_base.code_euser; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN code_sys_base.code_euser IS 'Code Value Entry User';


--
-- Name: COLUMN code_sys_base.code_mtstmp; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN code_sys_base.code_mtstmp IS 'Code Value Last Modification Timestamp';


--
-- Name: COLUMN code_sys_base.code_muser; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN code_sys_base.code_muser IS 'Code Value Last Modification User';


--
-- Name: COLUMN code_sys_base.code_snotes; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN code_sys_base.code_snotes IS 'Code Value System Notes';


--
-- Name: COLUMN code_sys_base.code_notes; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN code_sys_base.code_notes IS 'Code Value Notes';


--
-- Name: COLUMN code_sys_base.code_attrib; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN code_sys_base.code_attrib IS 'Code Value Additional Attribute';


--
-- Name: code2_sys_base_code2_sys_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE code2_sys_base_code2_sys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE code2_sys_base_code2_sys_id_seq OWNER TO postgres;

--
-- Name: code2_sys_base; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE code2_sys_base (
    code2_sys_id bigint DEFAULT nextval('code2_sys_base_code2_sys_id_seq'::regclass) NOT NULL,
    code_seq smallint,
    code_val1 character varying(32) NOT NULL,
    code_va12 character varying(32) NOT NULL,
    code_txt character varying(50),
    code_code character varying(50),
    code_end_dt date,
    code_end_reason character varying(50),
    code_etstmp timestamp without time zone DEFAULT my_now(),
    code_euser character varying(20) DEFAULT my_db_user(),
    code_mtstmp timestamp without time zone DEFAULT my_now(),
    code_muser character varying(20) DEFAULT my_db_user(),
    code_snotes character varying(255),
    code_notes character varying(255),
    code_attrib character varying(50)
);


ALTER TABLE code2_sys_base OWNER TO postgres;

--
-- Name: TABLE code2_sys_base; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE code2_sys_base IS 'System Codes 2 - TEMPLATE';


--
-- Name: COLUMN code2_sys_base.code2_sys_id; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN code2_sys_base.code2_sys_id IS 'Code Value ID';


--
-- Name: COLUMN code2_sys_base.code_seq; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN code2_sys_base.code_seq IS 'Code Value Sequence';


--
-- Name: COLUMN code2_sys_base.code_val1; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN code2_sys_base.code_val1 IS 'Code Value 1';


--
-- Name: COLUMN code2_sys_base.code_va12; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN code2_sys_base.code_va12 IS 'Code Value 2';


--
-- Name: COLUMN code2_sys_base.code_txt; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN code2_sys_base.code_txt IS 'Code Value Description';


--
-- Name: COLUMN code2_sys_base.code_code; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN code2_sys_base.code_code IS 'Code Value Additional Code';


--
-- Name: COLUMN code2_sys_base.code_end_dt; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN code2_sys_base.code_end_dt IS 'Code Value Termination Date';


--
-- Name: COLUMN code2_sys_base.code_end_reason; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN code2_sys_base.code_end_reason IS 'Code Value Termination Comment';


--
-- Name: COLUMN code2_sys_base.code_etstmp; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN code2_sys_base.code_etstmp IS 'Code Value Entry Timestamp';


--
-- Name: COLUMN code2_sys_base.code_euser; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN code2_sys_base.code_euser IS 'Code Value Entry User';


--
-- Name: COLUMN code2_sys_base.code_mtstmp; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN code2_sys_base.code_mtstmp IS 'Code Value Last Modification Timestamp';


--
-- Name: COLUMN code2_sys_base.code_muser; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN code2_sys_base.code_muser IS 'Code Value Last Modification User';


--
-- Name: COLUMN code2_sys_base.code_snotes; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN code2_sys_base.code_snotes IS 'Code Value System Notes';


--
-- Name: COLUMN code2_sys_base.code_notes; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN code2_sys_base.code_notes IS 'Code Value Notes';


--
-- Name: COLUMN code2_sys_base.code_attrib; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN code2_sys_base.code_attrib IS 'Code Value Additional Attribute';


--
-- Name: code2_country_state; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE code2_country_state (
)
INHERITS (code2_sys_base);


ALTER TABLE code2_country_state OWNER TO postgres;

--
-- Name: TABLE code2_country_state; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE code2_country_state IS 'System Codes 2 - Country / State';


--
-- Name: code2_param_app_attrib; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW code2_param_app_attrib AS
 SELECT NULL::smallint AS code_seq,
    param__tbl.param_process AS code_val1,
    param__tbl.param_attrib AS code_va12,
    param__tbl.param_desc AS code_txt,
    NULL::character varying(50) AS code_code,
    NULL::date AS code_end_dt,
    NULL::character varying(50) AS code_end_reason,
    NULL::timestamp without time zone AS code_etstmp,
    NULL::character varying(20) AS code_euser,
    NULL::timestamp without time zone AS code_mtstmp,
    NULL::character varying(20) AS code_muser,
    NULL::character varying(255) AS code_snotes,
    NULL::character varying(255) AS code_notes
   FROM param__tbl
  WHERE param__tbl.is_param_app;


ALTER TABLE code2_param_app_attrib OWNER TO postgres;

--
-- Name: code2_sys; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE code2_sys (
    code_name character varying(128) NOT NULL,
    code_desc character varying(128),
    code_code_desc character varying(128),
    code_h_etstmp timestamp without time zone DEFAULT my_now() NOT NULL,
    code_h_euser character varying(20) DEFAULT my_db_user() NOT NULL,
    code_h_mtstmp timestamp without time zone DEFAULT my_now() NOT NULL,
    code_h_muser character varying(20) DEFAULT my_db_user() NOT NULL,
    code_snotes character varying(255),
    code_attrib_desc character varying(128),
    code_schema character varying(128),
    code2_sys_h_id bigint NOT NULL
);


ALTER TABLE code2_sys OWNER TO postgres;

--
-- Name: TABLE code2_sys; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE code2_sys IS 'System Codes 2 Header (CONTROL)';


--
-- Name: code2_sys_code2_sys_h_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE code2_sys_code2_sys_h_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE code2_sys_code2_sys_h_id_seq OWNER TO postgres;

--
-- Name: code2_sys_code2_sys_h_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE code2_sys_code2_sys_h_id_seq OWNED BY code2_sys.code2_sys_h_id;


--
-- Name: code2_param_user_attrib; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW code2_param_user_attrib AS
 SELECT NULL::smallint AS code_seq,
    param__tbl.param_process AS code_val1,
    param__tbl.param_attrib AS code_va12,
    param__tbl.param_desc AS code_txt,
    NULL::character varying(50) AS code_code,
    NULL::date AS code_end_dt,
    NULL::character varying(50) AS code_end_reason,
    NULL::timestamp without time zone AS code_etstmp,
    NULL::character varying(20) AS code_euser,
    NULL::timestamp without time zone AS code_mtstmp,
    NULL::character varying(20) AS code_muser,
    NULL::character varying(255) AS code_snotes,
    NULL::character varying(255) AS code_notes
   FROM param__tbl
  WHERE param__tbl.is_param_user;


ALTER TABLE code2_param_user_attrib OWNER TO postgres;

--
-- Name: code2_param_sys_attrib; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW code2_param_sys_attrib AS
 SELECT NULL::smallint AS code_seq,
    param__tbl.param_process AS code_val1,
    param__tbl.param_attrib AS code_va12,
    param__tbl.param_desc AS code_txt,
    NULL::character varying(50) AS code_code,
    NULL::date AS code_end_dt,
    NULL::character varying(50) AS code_end_reason,
    NULL::timestamp without time zone AS code_etstmp,
    NULL::character varying(20) AS code_euser,
    NULL::timestamp without time zone AS code_mtstmp,
    NULL::character varying(20) AS code_muser,
    NULL::character varying(255) AS code_snotes,
    NULL::character varying(255) AS code_notes
   FROM param__tbl
  WHERE param__tbl.is_param_sys;


ALTER TABLE code2_param_sys_attrib OWNER TO postgres;

--
-- Name: code_ac; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE code_ac (
)
INHERITS (code_sys_base);


ALTER TABLE code_ac OWNER TO postgres;

--
-- Name: TABLE code_ac; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE code_ac IS 'System Codes - Active / Closed';


--
-- Name: code_ac1; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE code_ac1 (
)
INHERITS (code_sys_base);


ALTER TABLE code_ac1 OWNER TO postgres;

--
-- Name: TABLE code_ac1; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE code_ac1 IS 'System Codes - A / C';


--
-- Name: code_ahc; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE code_ahc (
)
INHERITS (code_sys_base);


ALTER TABLE code_ahc OWNER TO postgres;

--
-- Name: TABLE code_ahc; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE code_ahc IS 'System Codes - Active / Hold / Closed';


--
-- Name: code_country; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE code_country (
)
INHERITS (code_sys_base);


ALTER TABLE code_country OWNER TO postgres;

--
-- Name: TABLE code_country; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE code_country IS 'System Codes - Countries';


--
-- Name: code_doc_scope; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE code_doc_scope (
)
INHERITS (code_sys_base);


ALTER TABLE code_doc_scope OWNER TO postgres;

--
-- Name: TABLE code_doc_scope; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE code_doc_scope IS 'System Codes - Document Scope';


--
-- Name: code_param_app_process; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW code_param_app_process AS
 SELECT DISTINCT NULL::smallint AS code_seq,
    param__tbl.param_process AS code_val,
    param__tbl.param_process AS code_txt,
    NULL::text AS code_code,
    NULL::date AS code_end_dt,
    NULL::text AS code_end_reason
   FROM param__tbl
  WHERE param__tbl.is_param_app;


ALTER TABLE code_param_app_process OWNER TO postgres;

--
-- Name: code_sys; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE code_sys (
    code_name character varying(128) NOT NULL,
    code_desc character varying(128),
    code_code_desc character varying(128),
    code_h_etstmp timestamp without time zone DEFAULT my_now() NOT NULL,
    code_h_euser character varying(20) DEFAULT my_db_user() NOT NULL,
    code_h_mtstmp timestamp without time zone DEFAULT my_now() NOT NULL,
    code_h_muser character varying(20) DEFAULT my_db_user() NOT NULL,
    code_snotes character varying(255),
    code_attrib_desc character varying(128),
    code_schema character varying(128),
    code_sys_h_id bigint NOT NULL
);


ALTER TABLE code_sys OWNER TO postgres;

--
-- Name: TABLE code_sys; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE code_sys IS 'System Codes Header (CONTROL)';


--
-- Name: code_sys_code_sys_h_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE code_sys_code_sys_h_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE code_sys_code_sys_h_id_seq OWNER TO postgres;

--
-- Name: code_sys_code_sys_h_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE code_sys_code_sys_h_id_seq OWNED BY code_sys.code_sys_h_id;


--
-- Name: code_note_scope; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE code_note_scope (
)
INHERITS (code_sys_base);


ALTER TABLE code_note_scope OWNER TO postgres;

--
-- Name: TABLE code_note_scope; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE code_note_scope IS 'System Codes - Note Scope';


--
-- Name: code_note_type; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE code_note_type (
)
INHERITS (code_sys_base);


ALTER TABLE code_note_type OWNER TO postgres;

--
-- Name: TABLE code_note_type; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE code_note_type IS 'System Codes - Note Type';


--
-- Name: code_param_type; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE code_param_type (
)
INHERITS (code_sys_base);


ALTER TABLE code_param_type OWNER TO postgres;

--
-- Name: TABLE code_param_type; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE code_param_type IS 'System Codes - Process Parameter Type';


--
-- Name: code_param_user_process; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW code_param_user_process AS
 SELECT DISTINCT NULL::smallint AS code_seq,
    param__tbl.param_process AS code_val,
    param__tbl.param_process AS code_txt,
    NULL::text AS code_code,
    NULL::date AS code_end_dt,
    NULL::text AS code_end_reason
   FROM param__tbl
  WHERE param__tbl.is_param_user;


ALTER TABLE code_param_user_process OWNER TO postgres;

--
-- Name: code_job_action; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE code_job_action (
)
INHERITS (code_sys_base);


ALTER TABLE code_job_action OWNER TO postgres;

--
-- Name: TABLE code_job_action; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE code_job_action IS 'System Codes - Request Type (CONTROL)';


--
-- Name: code_job_source; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE code_job_source (
)
INHERITS (code_sys_base);


ALTER TABLE code_job_source OWNER TO postgres;

--
-- Name: TABLE code_job_source; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE code_job_source IS 'System Codes - Request Source (CONTROL)';


--
-- Name: code_txt_type; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE code_txt_type (
)
INHERITS (code_sys_base);


ALTER TABLE code_txt_type OWNER TO postgres;

--
-- Name: TABLE code_txt_type; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE code_txt_type IS 'System Codes - Text Type (Control)';


--
-- Name: code_sys_base_code_sys_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE code_sys_base_code_sys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE code_sys_base_code_sys_id_seq OWNER TO postgres;

--
-- Name: code_sys_base_code_sys_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE code_sys_base_code_sys_id_seq OWNED BY code_sys_base.code_sys_id;


--
-- Name: code_version_sts; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE code_version_sts (
)
INHERITS (code_sys_base);


ALTER TABLE code_version_sts OWNER TO postgres;

--
-- Name: TABLE code_version_sts; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE code_version_sts IS 'System Codes - Version Status';


--
-- Name: code_param_sys_process; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW code_param_sys_process AS
 SELECT DISTINCT NULL::smallint AS code_seq,
    param__tbl.param_process AS code_val,
    param__tbl.param_process AS code_txt,
    NULL::text AS code_code,
    NULL::date AS code_end_dt,
    NULL::text AS code_end_reason
   FROM param__tbl
  WHERE param__tbl.is_param_sys;


ALTER TABLE code_param_sys_process OWNER TO postgres;

--
-- Name: version__tbl; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE version__tbl (
    version_id bigint NOT NULL,
    version_component character varying(50) NOT NULL,
    version_no_major integer DEFAULT 0 NOT NULL,
    version_no_minor integer DEFAULT 0 NOT NULL,
    version_no_build integer DEFAULT 0 NOT NULL,
    version_no_rev integer DEFAULT 0 NOT NULL,
    version_sts character varying(32) DEFAULT 'OK'::character varying NOT NULL,
    version_note text,
    version_etstmp timestamp without time zone DEFAULT my_now() NOT NULL,
    version_euser character varying(20) DEFAULT my_db_user() NOT NULL,
    version_mtstmp timestamp without time zone DEFAULT my_now() NOT NULL,
    version_muser character varying(20) DEFAULT my_db_user() NOT NULL,
    version_snotes character varying(255)
);


ALTER TABLE version__tbl OWNER TO postgres;

--
-- Name: TABLE version__tbl; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE version__tbl IS 'Versions (CONTROL)';


--
-- Name: v_audit_detail; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW v_audit_detail AS
 SELECT audit__tbl.audit_seq,
    audit__tbl.cust_id,
    audit__tbl.item_id,
    audit__tbl.audit_table_name,
    audit__tbl.audit_table_id,
    audit__tbl.audit_op,
    audit__tbl.audit_user,
    my_db_user_fmt((audit__tbl.audit_user)::text) AS sys_user_name,
    audit__tbl.db_id,
    audit__tbl.audit_tstmp,
    audit__tbl.audit_ref_name,
    audit__tbl.audit_ref_id,
    audit__tbl.audit_subject,
    audit_detail.audit_column_name,
    audit_detail.audit_column_val
   FROM (audit__tbl
     LEFT JOIN audit_detail ON ((audit__tbl.audit_seq = audit_detail.audit_seq)));


ALTER TABLE v_audit_detail OWNER TO postgres;

--
-- Name: v_cust_user_nostar; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW v_cust_user_nostar AS
 SELECT cust_user_role.sys_user_id,
    cust_user_role.cust_user_role_snotes,
    cust_user_role.cust_user_role_id,
    cust_user_role.cust_role_name
   FROM cust_user_role
  WHERE ((cust_user_role.cust_role_name)::text <> 'C*'::text);


ALTER TABLE v_cust_user_nostar OWNER TO postgres;

-- Rule: v_cust_user_nostar_delete ON {schema}.v_cust_user_nostar

CREATE OR REPLACE RULE v_cust_user_nostar_delete AS
    ON DELETE TO {schema}.v_cust_user_nostar DO INSTEAD  DELETE FROM {schema}.cust_user_role
  WHERE cust_user_role.cust_user_role_id = old.cust_user_role_id
  RETURNING cust_user_role.sys_user_id,
    cust_user_role.cust_user_role_snotes,
    cust_user_role.cust_user_role_id,
    cust_user_role.cust_role_name;

-- Rule: v_cust_user_nostar_insert ON {schema}.v_cust_user_nostar

CREATE OR REPLACE RULE v_cust_user_nostar_insert AS
    ON INSERT TO {schema}.v_cust_user_nostar DO INSTEAD  INSERT INTO {schema}.cust_user_role (sys_user_id, cust_user_role_snotes, cust_role_name)
  VALUES (new.sys_user_id, new.cust_user_role_snotes, new.cust_role_name)
  RETURNING cust_user_role.sys_user_id,
    cust_user_role.cust_user_role_snotes,
    cust_user_role.cust_user_role_id,
    cust_user_role.cust_role_name;

-- Rule: v_cust_user_nostar_update ON {schema}.v_cust_user_nostar

CREATE OR REPLACE RULE v_cust_user_nostar_update AS
    ON UPDATE TO {schema}.v_cust_user_nostar DO INSTEAD  UPDATE {schema}.cust_user_role SET sys_user_id = new.sys_user_id, cust_user_role_snotes = new.cust_user_role_snotes, cust_role_name = new.cust_role_name
  WHERE cust_user_role.cust_user_role_id = old.cust_user_role_id
  RETURNING cust_user_role.sys_user_id,
    cust_user_role.cust_user_role_snotes,
    cust_user_role.cust_user_role_id,
    cust_user_role.cust_role_name;


--
-- Name: v_cust_menu_role_selection; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW v_cust_menu_role_selection AS
 SELECT cust_menu_role.cust_menu_role_id,
    COALESCE(single.single_varchar50, ''::character varying) AS new_cust_role_name,
    single.dual_bigint AS new_menu_id,
        CASE
            WHEN (cust_menu_role.cust_menu_role_id IS NULL) THEN 0
            ELSE 1
        END AS cust_menu_role_selection,
    m.cust_role_id,
    m.cust_role_seq,
    m.cust_role_sts,
    m.cust_role_name,
    m.cust_role_desc,
    m.menu_id_auto,
    m.menu_group,
    m.menu_id,
    m.menu_sts,
    m.menu_id_parent,
    m.menu_name,
    m.menu_seq,
    m.menu_desc,
    m.menu_desc_ext,
    m.menu_desc_ext2,
    m.menu_cmd,
    m.menu_image,
    m.menu_snotes,
    m.menu_subcmd
   FROM ((( SELECT cust_role.cust_role_id,
            cust_role.cust_role_seq,
            cust_role.cust_role_sts,
            cust_role.cust_role_name,
            cust_role.cust_role_desc,
            menu__tbl.menu_id_auto,
            menu__tbl.menu_group,
            menu__tbl.menu_id,
            menu__tbl.menu_sts,
            menu__tbl.menu_id_parent,
            menu__tbl.menu_name,
            menu__tbl.menu_seq,
            menu__tbl.menu_desc,
            menu__tbl.menu_desc_ext,
            menu__tbl.menu_desc_ext2,
            menu__tbl.menu_cmd,
            menu__tbl.menu_image,
            menu__tbl.menu_snotes,
            menu__tbl.menu_subcmd
           FROM (cust_role
             LEFT JOIN menu__tbl ON ((menu__tbl.menu_group = 'C'::bpchar)))) m
     JOIN single ON ((1 = 1)))
     LEFT JOIN cust_menu_role ON ((((cust_menu_role.cust_role_name)::text = (m.cust_role_name)::text) AND (cust_menu_role.menu_id = m.menu_id))));


ALTER TABLE v_cust_menu_role_selection OWNER TO postgres;

--
-- Name: v_doc_ext; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW v_doc_ext AS
 SELECT doc__tbl.doc_id,
    doc__tbl.doc_scope,
    doc__tbl.doc_scope_id,
    doc__tbl.cust_id,
    doc__tbl.item_id,
    doc__tbl.doc_sts,
    doc__tbl.doc_ctgr,
    doc__tbl.doc_desc,
    doc__tbl.doc_ext,
    doc__tbl.doc_size,
    (('D'::text || ((doc__tbl.doc_id)::character varying)::text) || (COALESCE(doc__tbl.doc_ext, ''::character varying))::text) AS doc_filename,
    doc__tbl.doc_etstmp,
    doc__tbl.doc_euser,
    my_db_user_fmt((doc__tbl.doc_euser)::text) AS doc_euser_fmt,
    doc__tbl.doc_mtstmp,
    doc__tbl.doc_muser,
    my_db_user_fmt((doc__tbl.doc_muser)::text) AS doc_muser_fmt,
    doc__tbl.doc_uptstmp,
    doc__tbl.doc_upuser,
    my_db_user_fmt((doc__tbl.doc_upuser)::text) AS doc_upuser_fmt,
    doc__tbl.doc_snotes,
    NULL::text AS title_head,
    NULL::text AS title_detail,
    doc__tbl.doc_scope AS doc_datalock,
    NULL::text AS cust_name,
    NULL::text AS cust_name_ext,
    NULL::text AS item_name
   FROM doc__tbl;


ALTER TABLE v_doc_ext OWNER TO postgres;

--
-- Name: v_doc_filename; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW v_doc_filename AS
 SELECT doc__tbl.doc_id,
    doc__tbl.doc_scope,
    doc__tbl.doc_scope_id,
    doc__tbl.cust_id,
    doc__tbl.item_id,
    doc__tbl.doc_sts,
    doc__tbl.doc_ctgr,
    doc__tbl.doc_desc,
    doc__tbl.doc_ext,
    doc__tbl.doc_size,
    doc__tbl.doc_etstmp,
    doc__tbl.doc_euser,
    doc__tbl.doc_mtstmp,
    doc__tbl.doc_muser,
    doc__tbl.doc_uptstmp,
    doc__tbl.doc_upuser,
    doc__tbl.doc_sync_tstmp,
    doc__tbl.doc_snotes,
    doc__tbl.doc_sync_id,
    (('D'::text || ((doc__tbl.doc_id)::character varying)::text) || (COALESCE(doc__tbl.doc_ext, ''::character varying))::text) AS doc_filename
   FROM doc__tbl;


ALTER TABLE v_doc_filename OWNER TO postgres;

--
-- Name: v_doc; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW v_doc AS
 SELECT doc__tbl.doc_id,
    doc__tbl.doc_scope,
    doc__tbl.doc_scope_id,
    doc__tbl.cust_id,
    doc__tbl.item_id,
    doc__tbl.doc_sts,
    doc__tbl.doc_ctgr,
    gdd.code_txt AS doc_ctgr_txt,
    doc__tbl.doc_desc,
    doc__tbl.doc_ext,
    doc__tbl.doc_size,
    (('D'::text || ((doc__tbl.doc_id)::character varying)::text) || (COALESCE(doc__tbl.doc_ext, ''::character varying))::text) AS doc_filename,
    doc__tbl.doc_etstmp,
    doc__tbl.doc_euser,
    my_db_user_fmt((doc__tbl.doc_euser)::text) AS doc_euser_fmt,
    doc__tbl.doc_mtstmp,
    doc__tbl.doc_muser,
    my_db_user_fmt((doc__tbl.doc_muser)::text) AS doc_muser_fmt,
    doc__tbl.doc_uptstmp,
    doc__tbl.doc_upuser,
    my_db_user_fmt((doc__tbl.doc_upuser)::text) AS doc_upuser_fmt,
    doc__tbl.doc_snotes,
    NULL::text AS title_head,
    NULL::text AS title_detail
   FROM (doc__tbl
     LEFT JOIN code2_doc_scope_doc_ctgr gdd ON ((((gdd.code_val1)::text = (doc__tbl.doc_scope)::text) AND ((gdd.code_va12)::text = (doc__tbl.doc_ctgr)::text))));


ALTER TABLE v_doc OWNER TO postgres;

--
-- Name: v_param_app; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW v_param_app AS
 SELECT param_app.param_app_id,
    param_app.param_app_process,
    param_app.param_app_attrib,
    param_app.param_app_val,
    param_app.param_app_etstmp,
    param_app.param_app_euser,
    param_app.param_app_mtstmp,
    param_app.param_app_muser,
    get_param_desc(param_app.param_app_process, param_app.param_app_attrib) AS param_desc,
    log_audit_info(param_app.param_app_etstmp, param_app.param_app_euser, param_app.param_app_mtstmp, param_app.param_app_muser) AS param_app_info
   FROM param_app;


ALTER TABLE v_param_app OWNER TO postgres;

--
-- Name: param_sys; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE param_sys (
    param_sys_id bigint NOT NULL,
    param_sys_process character varying(32) NOT NULL,
    param_sys_attrib character varying(16) NOT NULL,
    param_sys_val character varying(256),
    param_sys_etstmp timestamp without time zone DEFAULT my_now() NOT NULL,
    param_sys_euser character varying(20) DEFAULT my_db_user() NOT NULL,
    param_sys_mtstmp timestamp without time zone DEFAULT my_now() NOT NULL,
    param_sys_muser character varying(20) DEFAULT my_db_user() NOT NULL
);


ALTER TABLE param_sys OWNER TO postgres;

--
-- Name: TABLE param_sys; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE param_sys IS 'Process Parameters - System (CONTROL)';


--
-- Name: v_param_cur; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW v_param_cur AS
 SELECT param__tbl.param_process AS param_cur_process,
    param__tbl.param_attrib AS param_cur_attrib,
        CASE
            WHEN ((param_user.param_user_val IS NULL) OR ((param_user.param_user_val)::text = ''::text)) THEN
            CASE
                WHEN ((param_app.param_app_val IS NULL) OR ((param_app.param_app_val)::text = ''::text)) THEN param_sys.param_sys_val
                ELSE param_app.param_app_val
            END
            ELSE param_user.param_user_val
        END AS param_cur_val,
    param_user.sys_user_id
   FROM (((param__tbl
     LEFT JOIN param_sys ON ((((param__tbl.param_process)::text = (param_sys.param_sys_process)::text) AND ((param__tbl.param_attrib)::text = (param_sys.param_sys_attrib)::text))))
     LEFT JOIN param_app ON ((((param__tbl.param_process)::text = (param_app.param_app_process)::text) AND ((param__tbl.param_attrib)::text = (param_app.param_app_attrib)::text))))
     LEFT JOIN ( SELECT param_user_1.sys_user_id,
            param_user_1.param_user_process,
            param_user_1.param_user_attrib,
            param_user_1.param_user_val
           FROM param_user param_user_1
        UNION
         SELECT NULL::bigint AS sys_user_id,
            param_user_null.param_user_process,
            param_user_null.param_user_attrib,
            NULL::character varying AS param_user_val
           FROM param_user param_user_null) param_user ON ((((param__tbl.param_process)::text = (param_user.param_user_process)::text) AND ((param__tbl.param_attrib)::text = (param_user.param_user_attrib)::text))));


ALTER TABLE v_param_cur OWNER TO postgres;

--
-- Name: v_app_info; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW v_app_info AS
 SELECT name.param_cur_val AS app_title,
    addr.param_cur_val AS app_addr,
    city.param_cur_val AS app_city,
    state.param_cur_val AS app_state,
    zip.param_cur_val AS app_zip,
    (((((((COALESCE(addr.param_cur_val, ''::character varying))::text || ', '::text) || (COALESCE(city.param_cur_val, ''::character varying))::text) || ' '::text) || (COALESCE(state.param_cur_val, ''::character varying))::text) || ' '::text) || (COALESCE(zip.param_cur_val, ''::character varying))::text) AS app_full_addr,
    bphone.param_cur_val AS app_bphone,
    fax.param_cur_val AS app_fax,
    email.param_cur_val AS app_email,
    contact.param_cur_val AS app_contact
   FROM (((((((((single
     LEFT JOIN v_param_cur name ON ((((name.param_cur_process)::text = 'HOUSE'::text) AND ((name.param_cur_attrib)::text = 'NAME'::text))))
     LEFT JOIN v_param_cur addr ON ((((addr.param_cur_process)::text = 'HOUSE'::text) AND ((addr.param_cur_attrib)::text = 'ADDR'::text))))
     LEFT JOIN v_param_cur city ON ((((city.param_cur_process)::text = 'HOUSE'::text) AND ((city.param_cur_attrib)::text = 'CITY'::text))))
     LEFT JOIN v_param_cur state ON ((((state.param_cur_process)::text = 'HOUSE'::text) AND ((state.param_cur_attrib)::text = 'STATE'::text))))
     LEFT JOIN v_param_cur zip ON ((((zip.param_cur_process)::text = 'HOUSE'::text) AND ((zip.param_cur_attrib)::text = 'ZIP'::text))))
     LEFT JOIN v_param_cur bphone ON ((((bphone.param_cur_process)::text = 'HOUSE'::text) AND ((bphone.param_cur_attrib)::text = 'BPHONE'::text))))
     LEFT JOIN v_param_cur fax ON ((((fax.param_cur_process)::text = 'HOUSE'::text) AND ((fax.param_cur_attrib)::text = 'FAX'::text))))
     LEFT JOIN v_param_cur email ON ((((email.param_cur_process)::text = 'HOUSE'::text) AND ((email.param_cur_attrib)::text = 'EMAIL'::text))))
     LEFT JOIN v_param_cur contact ON ((((contact.param_cur_process)::text = 'HOUSE'::text) AND ((contact.param_cur_attrib)::text = 'CONTACT'::text))));


ALTER TABLE v_app_info OWNER TO postgres;

--
-- Name: v_month; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW v_month AS
 SELECT number__tbl.number_val as month_val,
    "right"(('0'::text || ((number__tbl.number_val)::character varying)::text), 2) AS month_txt
   FROM number__tbl
  WHERE (number__tbl.number_val <= 12);


ALTER TABLE v_month OWNER TO postgres;

--
-- Name: v_my_roles; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW v_my_roles AS
 SELECT sys_user_role.sys_role_name
   FROM sys_user_role
  WHERE (sys_user_role.sys_user_id = my_sys_user_id());


ALTER TABLE v_my_roles OWNER TO postgres;

--
-- Name: v_my_user; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW v_my_user AS
 SELECT my_sys_user_id() AS my_sys_user_id;


ALTER TABLE v_my_user OWNER TO postgres;

--
-- Name: v_note_ext; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW v_note_ext AS
 SELECT note__tbl.note_id,
    note__tbl.note_scope,
    note__tbl.note_scope_id,
    note__tbl.note_sts,
    note__tbl.cust_id,
    note__tbl.item_id,
    note__tbl.note_type,
    note__tbl.note_body,
    note__tbl.note_etstmp,
    note__tbl.note_euser,
    my_db_user_fmt((note__tbl.note_euser)::text) AS note_euser_fmt,
    note__tbl.note_mtstmp,
    note__tbl.note_muser,
    my_db_user_fmt((note__tbl.note_muser)::text) AS note_muser_fmt,
    note__tbl.note_snotes,
    NULL::text AS title_head,
    NULL::text AS title_detail,
    NULL::text AS cust_name,
    NULL::text AS cust_name_ext,
    NULL::text AS item_name
   FROM note__tbl;


ALTER TABLE v_note_ext OWNER TO postgres;

--
-- Name: v_note; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW v_note AS
 SELECT note__tbl.note_id,
    note__tbl.note_scope,
    note__tbl.note_scope_id,
    note__tbl.note_sts,
    note__tbl.cust_id,
    NULL::text AS cust_name,
    NULL::text AS cust_name_ext,
    note__tbl.item_id,
    NULL::text AS item_name,
    note__tbl.note_type,
    note__tbl.note_body,
    my_to_date(note__tbl.note_etstmp) AS note_dt,
    note__tbl.note_etstmp,
    my_mmddyyhhmi(note__tbl.note_etstmp) AS note_etstmp_fmt,
    note__tbl.note_euser,
    my_db_user_fmt((note__tbl.note_euser)::text) AS note_euser_fmt,
    note__tbl.note_mtstmp,
    my_mmddyyhhmi(note__tbl.note_mtstmp) AS note_mtstmp_fmt,
    note__tbl.note_muser,
    my_db_user_fmt((note__tbl.note_muser)::text) AS note_muser_fmt,
    note__tbl.note_snotes,
    NULL::text AS title_head,
    NULL::text AS title_detail
   FROM note__tbl;


ALTER TABLE v_note OWNER TO postgres;

--
-- Name: v_param; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW v_param AS
 SELECT param__tbl.param_id,
    param__tbl.param_process,
    param__tbl.param_attrib,
    param__tbl.param_desc,
    param__tbl.param_type,
    param__tbl.code_name,
    param__tbl.is_param_app,
    param__tbl.is_param_user,
    param__tbl.is_param_sys,
    param__tbl.param_etstmp,
    param__tbl.param_euser,
    param__tbl.param_mtstmp,
    param__tbl.param_muser,
    param__tbl.param_snotes,
    log_audit_info(param__tbl.param_etstmp, param__tbl.param_euser, param__tbl.param_mtstmp, param__tbl.param_muser) AS param_info
   FROM param__tbl;


ALTER TABLE v_param OWNER TO postgres;

--
-- Name: v_param_user; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW v_param_user AS
 SELECT param_user.param_user_id,
    param_user.sys_user_id,
    param_user.param_user_process,
    param_user.param_user_attrib,
    param_user.param_user_val,
    param_user.param_user_etstmp,
    param_user.param_user_euser,
    param_user.param_user_mtstmp,
    param_user.param_user_muser,
    get_param_desc(param_user.param_user_process, param_user.param_user_attrib) AS param_desc,
    log_audit_info(param_user.param_user_etstmp, param_user.param_user_euser, param_user.param_user_mtstmp, param_user.param_user_muser) AS param_user_info
   FROM param_user;


ALTER TABLE v_param_user OWNER TO postgres;

--
-- Name: v_sys_menu_role_selection; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW v_sys_menu_role_selection AS
 SELECT sys_menu_role.sys_menu_role_id,
    COALESCE(single.single_varchar50, ''::character varying) AS new_sys_role_name,
    single.dual_bigint AS new_menu_id,
        CASE
            WHEN (sys_menu_role.sys_menu_role_id IS NULL) THEN 0
            ELSE 1
        END AS sys_menu_role_selection,
    m.sys_role_id,
    m.sys_role_seq,
    m.sys_role_sts,
    m.sys_role_name,
    m.sys_role_desc,
    m.menu_id_auto,
    m.menu_group,
    m.menu_id,
    m.menu_sts,
    m.menu_id_parent,
    m.menu_name,
    m.menu_seq,
    m.menu_desc,
    m.menu_desc_ext,
    m.menu_desc_ext2,
    m.menu_cmd,
    m.menu_image,
    m.menu_snotes,
    m.menu_subcmd
   FROM ((( SELECT sys_role.sys_role_id,
            sys_role.sys_role_seq,
            sys_role.sys_role_sts,
            sys_role.sys_role_name,
            sys_role.sys_role_desc,
            menu__tbl.menu_id_auto,
            menu__tbl.menu_group,
            menu__tbl.menu_id,
            menu__tbl.menu_sts,
            menu__tbl.menu_id_parent,
            menu__tbl.menu_name,
            menu__tbl.menu_seq,
            menu__tbl.menu_desc,
            menu__tbl.menu_desc_ext,
            menu__tbl.menu_desc_ext2,
            menu__tbl.menu_cmd,
            menu__tbl.menu_image,
            menu__tbl.menu_snotes,
            menu__tbl.menu_subcmd
           FROM (sys_role
             LEFT JOIN menu__tbl ON ((menu__tbl.menu_group = 'S'::bpchar)))) m
     JOIN single ON ((1 = 1)))
     LEFT JOIN sys_menu_role ON ((((sys_menu_role.sys_role_name)::text = (m.sys_role_name)::text) AND (sys_menu_role.menu_id = m.menu_id))));


ALTER TABLE v_sys_menu_role_selection OWNER TO postgres;

--
-- Name: version__tbl_version_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE version__tbl_version_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE version__tbl_version_id_seq OWNER TO postgres;

--
-- Name: version__tbl_version_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE version__tbl_version_id_seq OWNED BY version__tbl.version_id;


--
-- Name: v_param_sys; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW v_param_sys AS
 SELECT param_sys.param_sys_id,
    param_sys.param_sys_process,
    param_sys.param_sys_attrib,
    param_sys.param_sys_val,
    param_sys.param_sys_etstmp,
    param_sys.param_sys_euser,
    param_sys.param_sys_mtstmp,
    param_sys.param_sys_muser,
    get_param_desc(param_sys.param_sys_process, param_sys.param_sys_attrib) AS param_desc,
    log_audit_info(param_sys.param_sys_etstmp, param_sys.param_sys_euser, param_sys.param_sys_mtstmp, param_sys.param_sys_muser) AS param_sys_info
   FROM param_sys;


ALTER TABLE v_param_sys OWNER TO postgres;

--
-- Name: v_year; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW v_year AS
 SELECT ((date_part('year_txt'::text, my_now()) + (number__tbl.number_val)::double precision) - (1)::double precision) AS year_val
   FROM number__tbl
  WHERE (number__tbl.number_val <= 10);


ALTER TABLE v_year OWNER TO postgres;

--
-- Name: param_sys_param_sys_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE param_sys_param_sys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE param_sys_param_sys_id_seq OWNER TO postgres;

--
-- Name: param_sys_param_sys_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE param_sys_param_sys_id_seq OWNED BY param_sys.param_sys_id;


--
-- Name: audit_seq; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY audit__tbl ALTER COLUMN audit_seq SET DEFAULT nextval('audit__tbl_audit_seq_seq'::regclass);


--
-- Name: sys_user_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY cust_user ALTER COLUMN sys_user_id SET DEFAULT nextval('cust_user_sys_user_id_seq'::regclass);


--
-- Name: cust_user_role_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY cust_user_role ALTER COLUMN cust_user_role_id SET DEFAULT nextval('cust_user_role_cust_user_role_id_seq'::regclass);


--
-- Name: cust_role_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY cust_role ALTER COLUMN cust_role_id SET DEFAULT nextval('cust_role_cust_role_id_seq'::regclass);


--
-- Name: cust_menu_role_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY cust_menu_role ALTER COLUMN cust_menu_role_id SET DEFAULT nextval('cust_menu_role_cust_menu_role_id_seq'::regclass);


--
-- Name: doc_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY doc__tbl ALTER COLUMN doc_id SET DEFAULT nextval('doc__tbl_doc_id_seq'::regclass);


--
-- Name: single_ident; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY single ALTER COLUMN single_ident SET DEFAULT nextval('single_single_ident_seq'::regclass);


--
-- Name: code2_app_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code2_doc_scope_doc_ctgr ALTER COLUMN code2_app_id SET DEFAULT nextval('code2_app_base_code2_app_id_seq'::regclass);


--
-- Name: code_etstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code2_doc_scope_doc_ctgr ALTER COLUMN code_etstmp SET DEFAULT my_now();


--
-- Name: code_euser; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code2_doc_scope_doc_ctgr ALTER COLUMN code_euser SET DEFAULT my_db_user();


--
-- Name: code_mtstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code2_doc_scope_doc_ctgr ALTER COLUMN code_mtstmp SET DEFAULT my_now();


--
-- Name: code_muser; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code2_doc_scope_doc_ctgr ALTER COLUMN code_muser SET DEFAULT my_db_user();


--
-- Name: param_app_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY param_app ALTER COLUMN param_app_id SET DEFAULT nextval('param_app_param_app_id_seq'::regclass);


--
-- Name: help_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY help__tbl ALTER COLUMN help_id SET DEFAULT nextval('help__tbl_help_id_seq'::regclass);


--
-- Name: help_target_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY help_target ALTER COLUMN help_target_id SET DEFAULT nextval('help_target_help_target_id_seq'::regclass);


--
-- Name: note_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY note__tbl ALTER COLUMN note_id SET DEFAULT nextval('note__tbl_note_id_seq'::regclass);


--
-- Name: sys_user_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sys_user ALTER COLUMN sys_user_id SET DEFAULT nextval('sys_user_sys_user_id_seq'::regclass);


--
-- Name: param_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY param__tbl ALTER COLUMN param_id SET DEFAULT nextval('param__tbl_param_id_seq'::regclass);


--
-- Name: param_user_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY param_user ALTER COLUMN param_user_id SET DEFAULT nextval('param_user_param_user_id_seq'::regclass);


--
-- Name: queue_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY queue__tbl ALTER COLUMN queue_id SET DEFAULT nextval('queue__tbl_queue_id_seq'::regclass);


--
-- Name: job_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY job__tbl ALTER COLUMN job_id SET DEFAULT nextval('job__tbl_job_id_seq'::regclass);


--
-- Name: job_doc_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY job_doc ALTER COLUMN job_doc_id SET DEFAULT nextval('job_doc_job_doc_id_seq'::regclass);


--
-- Name: job_email_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY job_email ALTER COLUMN job_email_id SET DEFAULT nextval('job_email_job_email_id_seq'::regclass);


--
-- Name: job_note_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY job_note ALTER COLUMN job_note_id SET DEFAULT nextval('job_note_job_note_id_seq'::regclass);


--
-- Name: job_queue_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY job_queue ALTER COLUMN job_queue_id SET DEFAULT nextval('job_queue_job_queue_id_seq'::regclass);


--
-- Name: job_sms_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY job_sms ALTER COLUMN job_sms_id SET DEFAULT nextval('job_sms_job_sms_id_seq'::regclass);


--
-- Name: sys_func_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sys_func ALTER COLUMN sys_func_id SET DEFAULT nextval('sys_func_sys_func_id_seq'::regclass);


--
-- Name: menu_id_auto; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY menu__tbl ALTER COLUMN menu_id_auto SET DEFAULT nextval('menu__tbl_menu_id_auto_seq'::regclass);


--
-- Name: sys_user_func_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sys_user_func ALTER COLUMN sys_user_func_id SET DEFAULT nextval('sys_user_func_sys_user_func_id_seq'::regclass);


--
-- Name: sys_user_role_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sys_user_role ALTER COLUMN sys_user_role_id SET DEFAULT nextval('sys_user_role_sys_user_role_id_seq'::regclass);


--
-- Name: sys_role_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sys_role ALTER COLUMN sys_role_id SET DEFAULT nextval('sys_role_sys_role_id_seq'::regclass);


--
-- Name: sys_menu_role_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sys_menu_role ALTER COLUMN sys_menu_role_id SET DEFAULT nextval('sys_menu_role_sys_menu_role_id_seq'::regclass);


--
-- Name: txt_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY txt__tbl ALTER COLUMN txt_id SET DEFAULT nextval('txt__tbl_txt_id_seq'::regclass);


--
-- Name: code_sys_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_sys_base ALTER COLUMN code_sys_id SET DEFAULT nextval('code_sys_base_code_sys_id_seq'::regclass);


--
-- Name: code2_sys_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code2_country_state ALTER COLUMN code2_sys_id SET DEFAULT nextval('code2_sys_base_code2_sys_id_seq'::regclass);


--
-- Name: code_etstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code2_country_state ALTER COLUMN code_etstmp SET DEFAULT my_now();


--
-- Name: code_euser; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code2_country_state ALTER COLUMN code_euser SET DEFAULT my_db_user();


--
-- Name: code_mtstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code2_country_state ALTER COLUMN code_mtstmp SET DEFAULT my_now();


--
-- Name: code_muser; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code2_country_state ALTER COLUMN code_muser SET DEFAULT my_db_user();


--
-- Name: code2_sys_h_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code2_sys ALTER COLUMN code2_sys_h_id SET DEFAULT nextval('code2_sys_code2_sys_h_id_seq'::regclass);


--
-- Name: code_sys_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_ac ALTER COLUMN code_sys_id SET DEFAULT nextval('code_sys_base_code_sys_id_seq'::regclass);


--
-- Name: code_etstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_ac ALTER COLUMN code_etstmp SET DEFAULT my_now();


--
-- Name: code_euser; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_ac ALTER COLUMN code_euser SET DEFAULT my_db_user();


--
-- Name: code_mtstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_ac ALTER COLUMN code_mtstmp SET DEFAULT my_now();


--
-- Name: code_muser; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_ac ALTER COLUMN code_muser SET DEFAULT my_db_user();


--
-- Name: code_sys_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_ac1 ALTER COLUMN code_sys_id SET DEFAULT nextval('code_sys_base_code_sys_id_seq'::regclass);


--
-- Name: code_etstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_ac1 ALTER COLUMN code_etstmp SET DEFAULT my_now();


--
-- Name: code_euser; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_ac1 ALTER COLUMN code_euser SET DEFAULT my_db_user();


--
-- Name: code_mtstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_ac1 ALTER COLUMN code_mtstmp SET DEFAULT my_now();


--
-- Name: code_muser; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_ac1 ALTER COLUMN code_muser SET DEFAULT my_db_user();


--
-- Name: code_sys_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_ahc ALTER COLUMN code_sys_id SET DEFAULT nextval('code_sys_base_code_sys_id_seq'::regclass);


--
-- Name: code_etstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_ahc ALTER COLUMN code_etstmp SET DEFAULT my_now();


--
-- Name: code_euser; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_ahc ALTER COLUMN code_euser SET DEFAULT my_db_user();


--
-- Name: code_mtstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_ahc ALTER COLUMN code_mtstmp SET DEFAULT my_now();


--
-- Name: code_muser; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_ahc ALTER COLUMN code_muser SET DEFAULT my_db_user();


--
-- Name: code_sys_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_country ALTER COLUMN code_sys_id SET DEFAULT nextval('code_sys_base_code_sys_id_seq'::regclass);


--
-- Name: code_etstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_country ALTER COLUMN code_etstmp SET DEFAULT my_now();


--
-- Name: code_euser; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_country ALTER COLUMN code_euser SET DEFAULT my_db_user();


--
-- Name: code_mtstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_country ALTER COLUMN code_mtstmp SET DEFAULT my_now();


--
-- Name: code_muser; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_country ALTER COLUMN code_muser SET DEFAULT my_db_user();


--
-- Name: code_sys_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_doc_scope ALTER COLUMN code_sys_id SET DEFAULT nextval('code_sys_base_code_sys_id_seq'::regclass);


--
-- Name: code_etstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_doc_scope ALTER COLUMN code_etstmp SET DEFAULT my_now();


--
-- Name: code_euser; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_doc_scope ALTER COLUMN code_euser SET DEFAULT my_db_user();


--
-- Name: code_mtstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_doc_scope ALTER COLUMN code_mtstmp SET DEFAULT my_now();


--
-- Name: code_muser; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_doc_scope ALTER COLUMN code_muser SET DEFAULT my_db_user();


--
-- Name: code_sys_h_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_sys ALTER COLUMN code_sys_h_id SET DEFAULT nextval('code_sys_code_sys_h_id_seq'::regclass);


--
-- Name: code_sys_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_note_scope ALTER COLUMN code_sys_id SET DEFAULT nextval('code_sys_base_code_sys_id_seq'::regclass);


--
-- Name: code_etstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_note_scope ALTER COLUMN code_etstmp SET DEFAULT my_now();


--
-- Name: code_euser; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_note_scope ALTER COLUMN code_euser SET DEFAULT my_db_user();


--
-- Name: code_mtstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_note_scope ALTER COLUMN code_mtstmp SET DEFAULT my_now();


--
-- Name: code_muser; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_note_scope ALTER COLUMN code_muser SET DEFAULT my_db_user();


--
-- Name: code_sys_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_note_type ALTER COLUMN code_sys_id SET DEFAULT nextval('code_sys_base_code_sys_id_seq'::regclass);


--
-- Name: code_etstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_note_type ALTER COLUMN code_etstmp SET DEFAULT my_now();


--
-- Name: code_euser; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_note_type ALTER COLUMN code_euser SET DEFAULT my_db_user();


--
-- Name: code_mtstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_note_type ALTER COLUMN code_mtstmp SET DEFAULT my_now();


--
-- Name: code_muser; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_note_type ALTER COLUMN code_muser SET DEFAULT my_db_user();


--
-- Name: code_sys_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_param_type ALTER COLUMN code_sys_id SET DEFAULT nextval('code_sys_base_code_sys_id_seq'::regclass);


--
-- Name: code_etstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_param_type ALTER COLUMN code_etstmp SET DEFAULT my_now();


--
-- Name: code_euser; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_param_type ALTER COLUMN code_euser SET DEFAULT my_db_user();


--
-- Name: code_mtstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_param_type ALTER COLUMN code_mtstmp SET DEFAULT my_now();


--
-- Name: code_muser; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_param_type ALTER COLUMN code_muser SET DEFAULT my_db_user();


--
-- Name: code_sys_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_job_action ALTER COLUMN code_sys_id SET DEFAULT nextval('code_sys_base_code_sys_id_seq'::regclass);


--
-- Name: code_etstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_job_action ALTER COLUMN code_etstmp SET DEFAULT my_now();


--
-- Name: code_euser; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_job_action ALTER COLUMN code_euser SET DEFAULT my_db_user();


--
-- Name: code_mtstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_job_action ALTER COLUMN code_mtstmp SET DEFAULT my_now();


--
-- Name: code_muser; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_job_action ALTER COLUMN code_muser SET DEFAULT my_db_user();


--
-- Name: code_sys_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_job_source ALTER COLUMN code_sys_id SET DEFAULT nextval('code_sys_base_code_sys_id_seq'::regclass);


--
-- Name: code_etstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_job_source ALTER COLUMN code_etstmp SET DEFAULT my_now();


--
-- Name: code_euser; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_job_source ALTER COLUMN code_euser SET DEFAULT my_db_user();


--
-- Name: code_mtstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_job_source ALTER COLUMN code_mtstmp SET DEFAULT my_now();


--
-- Name: code_muser; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_job_source ALTER COLUMN code_muser SET DEFAULT my_db_user();


--
-- Name: code_sys_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_txt_type ALTER COLUMN code_sys_id SET DEFAULT nextval('code_sys_base_code_sys_id_seq'::regclass);


--
-- Name: code_etstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_txt_type ALTER COLUMN code_etstmp SET DEFAULT my_now();


--
-- Name: code_euser; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_txt_type ALTER COLUMN code_euser SET DEFAULT my_db_user();


--
-- Name: code_mtstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_txt_type ALTER COLUMN code_mtstmp SET DEFAULT my_now();


--
-- Name: code_muser; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_txt_type ALTER COLUMN code_muser SET DEFAULT my_db_user();


--
-- Name: code_sys_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_version_sts ALTER COLUMN code_sys_id SET DEFAULT nextval('code_sys_base_code_sys_id_seq'::regclass);


--
-- Name: code_etstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_version_sts ALTER COLUMN code_etstmp SET DEFAULT my_now();


--
-- Name: code_euser; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_version_sts ALTER COLUMN code_euser SET DEFAULT my_db_user();


--
-- Name: code_mtstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_version_sts ALTER COLUMN code_mtstmp SET DEFAULT my_now();


--
-- Name: code_muser; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_version_sts ALTER COLUMN code_muser SET DEFAULT my_db_user();


--
-- Name: version_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY version__tbl ALTER COLUMN version_id SET DEFAULT nextval('version__tbl_version_id_seq'::regclass);


--
-- Name: param_sys_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY param_sys ALTER COLUMN param_sys_id SET DEFAULT nextval('param_sys_param_sys_id_seq'::regclass);


--
-- Name: audit_detail_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY audit_detail
    ADD CONSTRAINT audit_detail_pkey PRIMARY KEY (audit_seq, audit_column_name);


--
-- Name: audit__tbl_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY audit__tbl
    ADD CONSTRAINT audit__tbl_pkey PRIMARY KEY (audit_seq);


--
-- Name: cust_user_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY cust_user
    ADD CONSTRAINT cust_user_pkey PRIMARY KEY (sys_user_id);


--
-- Name: cust_user_role_cust_user_role_id_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY cust_user_role
    ADD CONSTRAINT cust_user_role_cust_user_role_id_key UNIQUE (cust_user_role_id);


--
-- Name: cust_user_role_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY cust_user_role
    ADD CONSTRAINT cust_user_role_pkey PRIMARY KEY (sys_user_id, cust_role_name);


--
-- Name: cust_role_cust_role_desc_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY cust_role
    ADD CONSTRAINT cust_role_cust_role_desc_key UNIQUE (cust_role_desc);


--
-- Name: cust_role_cust_role_id_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY cust_role
    ADD CONSTRAINT cust_role_cust_role_id_key UNIQUE (cust_role_id);


--
-- Name: cust_role_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY cust_role
    ADD CONSTRAINT cust_role_pkey PRIMARY KEY (cust_role_name);


--
-- Name: cust_menu_role_cust_menu_role_id_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY cust_menu_role
    ADD CONSTRAINT cust_menu_role_cust_menu_role_id_key UNIQUE (cust_menu_role_id);


--
-- Name: cust_menu_role_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY cust_menu_role
    ADD CONSTRAINT cust_menu_role_pkey PRIMARY KEY (cust_role_name, menu_id);


--
-- Name: doc__tbl_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY doc__tbl
    ADD CONSTRAINT doc__tbl_pkey PRIMARY KEY (doc_id);


--
-- Name: single_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY single
    ADD CONSTRAINT single_pkey PRIMARY KEY (single_ident);


--
-- Name: code2_app_base_code_val1_code_txt_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code2_app_base
    ADD CONSTRAINT code2_app_base_code_val1_code_txt_key UNIQUE (code_val1, code_txt);


--
-- Name: code2_app_base_code_val1_code_va12_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code2_app_base
    ADD CONSTRAINT code2_app_base_code_val1_code_va12_key UNIQUE (code_val1, code_va12);


--
-- Name: code2_doc_scope_doc_ctgr_code_val1_code_txt_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code2_doc_scope_doc_ctgr
    ADD CONSTRAINT code2_doc_scope_doc_ctgr_code_val1_code_txt_key UNIQUE (code_val1, code_txt);


--
-- Name: code2_doc_scope_doc_ctgr_code_val1_code_va12_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code2_doc_scope_doc_ctgr
    ADD CONSTRAINT code2_doc_scope_doc_ctgr_code_val1_code_va12_key UNIQUE (code_val1, code_va12);


--
-- Name: code2_doc_scope_doc_ctgr_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code2_doc_scope_doc_ctgr
    ADD CONSTRAINT code2_doc_scope_doc_ctgr_pkey PRIMARY KEY (code2_app_id);


--
-- Name: code2_app_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code2_app
    ADD CONSTRAINT code2_app_pkey PRIMARY KEY (code_name);


--
-- Name: code2_app_base_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code2_app_base
    ADD CONSTRAINT code2_app_base_pkey PRIMARY KEY (code2_app_id);


--
-- Name: code_app_base_code_txt_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_app_base
    ADD CONSTRAINT code_app_base_code_txt_key UNIQUE (code_txt);


--
-- Name: code_app_base_code_val_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_app_base
    ADD CONSTRAINT code_app_base_code_val_key UNIQUE (code_val);


--
-- Name: code_app_base_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_app_base
    ADD CONSTRAINT code_app_base_pkey PRIMARY KEY (code_name);


--
-- Name: code_app_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_app
    ADD CONSTRAINT code_app_pkey PRIMARY KEY (code_app_id);


--
-- Name: param_app_param_app_process_param_app_attrib_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY param_app
    ADD CONSTRAINT param_app_param_app_process_param_app_attrib_key UNIQUE (param_app_process, param_app_attrib);


--
-- Name: param_app_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY param_app
    ADD CONSTRAINT param_app_pkey PRIMARY KEY (param_app_id);


--
-- Name: help__tbl_help_title_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY help__tbl
    ADD CONSTRAINT help__tbl_help_title_key UNIQUE (help_title);


--
-- Name: help__tbl_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY help__tbl
    ADD CONSTRAINT help__tbl_pkey PRIMARY KEY (help_id);


--
-- Name: help_target_help_target_code_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY help_target
    ADD CONSTRAINT help_target_help_target_code_key UNIQUE (help_target_code);


--
-- Name: help_target_help_target_desc_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY help_target
    ADD CONSTRAINT help_target_help_target_desc_key UNIQUE (help_target_desc);


--
-- Name: help_target_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY help_target
    ADD CONSTRAINT help_target_pkey PRIMARY KEY (help_target_id);


--
-- Name: note__tbl_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY note__tbl
    ADD CONSTRAINT note__tbl_pkey PRIMARY KEY (note_id);


--
-- Name: number__tbl_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY number__tbl
    ADD CONSTRAINT number__tbl_pkey PRIMARY KEY (number_val);


--
-- Name: sys_user_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sys_user
    ADD CONSTRAINT sys_user_pkey PRIMARY KEY (sys_user_id);


--
-- Name: param__tbl_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY param__tbl
    ADD CONSTRAINT param__tbl_pkey PRIMARY KEY (param_id);


--
-- Name: param__tbl_param_process_param_attrib_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY param__tbl
    ADD CONSTRAINT param__tbl_param_process_param_attrib_key UNIQUE (param_process, param_attrib);


--
-- Name: param_user_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY param_user
    ADD CONSTRAINT param_user_pkey PRIMARY KEY (param_user_id);


--
-- Name: param_user_param_user_process_param_user_attrib_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY param_user
    ADD CONSTRAINT param_user_param_user_process_param_user_attrib_key UNIQUE (sys_user_id, param_user_process, param_user_attrib);


--
-- Name: queue__tbl_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY queue__tbl
    ADD CONSTRAINT queue__tbl_pkey PRIMARY KEY (queue_id);


--
-- Name: job_doc_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY job_doc
    ADD CONSTRAINT job_doc_pkey PRIMARY KEY (job_doc_id);


--
-- Name: job_email_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY job_email
    ADD CONSTRAINT job_email_pkey PRIMARY KEY (job_email_id);


--
-- Name: job_note_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY job_note
    ADD CONSTRAINT job_note_pkey PRIMARY KEY (job_note_id);


--
-- Name: job__tbl_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY job__tbl
    ADD CONSTRAINT job__tbl_pkey PRIMARY KEY (job_id);


--
-- Name: job_queue_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY job_queue
    ADD CONSTRAINT job_queue_pkey PRIMARY KEY (job_queue_id);


--
-- Name: job_sms_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY job_sms
    ADD CONSTRAINT job_sms_pkey PRIMARY KEY (job_sms_id);


--
-- Name: sys_func_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sys_func
    ADD CONSTRAINT sys_func_pkey PRIMARY KEY (sys_func_name);


--
-- Name: sys_func_sys_func_desc_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sys_func
    ADD CONSTRAINT sys_func_sys_func_desc_key UNIQUE (sys_func_desc);


--
-- Name: sys_func_sys_func_id_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sys_func
    ADD CONSTRAINT sys_func_sys_func_id_key UNIQUE (sys_func_id);


--
-- Name: menu__tbl_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY menu__tbl
    ADD CONSTRAINT menu__tbl_pkey PRIMARY KEY (menu_id_auto);


--
-- Name: menu__tbl_menu_id_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY menu__tbl
    ADD CONSTRAINT menu__tbl_menu_id_key UNIQUE (menu_id);


--
-- Name: menu__tbl_menu_id_parent_menu_desc_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY menu__tbl
    ADD CONSTRAINT menu__tbl_menu_id_parent_menu_desc_key UNIQUE (menu_id_parent, menu_desc);


--
-- Name: menu__tbl_menu_id_menu_desc_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY menu__tbl
    ADD CONSTRAINT menu__tbl_menu_id_menu_desc_key UNIQUE (menu_id, menu_desc);


--
-- Name: menu__tbl_menu_name_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY menu__tbl
    ADD CONSTRAINT menu__tbl_menu_name_key UNIQUE (menu_name);


--
-- Name: sys_user_func_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sys_user_func
    ADD CONSTRAINT sys_user_func_pkey PRIMARY KEY (sys_user_id, sys_func_name);


--
-- Name: sys_user_func_sys_user_func_id_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sys_user_func
    ADD CONSTRAINT sys_user_func_sys_user_func_id_key UNIQUE (sys_user_func_id);


--
-- Name: sys_user_role_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sys_user_role
    ADD CONSTRAINT sys_user_role_pkey PRIMARY KEY (sys_user_id, sys_role_name);


--
-- Name: sys_user_role_sys_user_role_id_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sys_user_role
    ADD CONSTRAINT sys_user_role_sys_user_role_id_key UNIQUE (sys_user_role_id);


--
-- Name: sys_role_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sys_role
    ADD CONSTRAINT sys_role_pkey PRIMARY KEY (sys_role_name);


--
-- Name: sys_role_sys_role_desc_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sys_role
    ADD CONSTRAINT sys_role_sys_role_desc_key UNIQUE (sys_role_desc);


--
-- Name: sys_role_sys_role_id_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sys_role
    ADD CONSTRAINT sys_role_sys_role_id_key UNIQUE (sys_role_id);


--
-- Name: sys_menu_role_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sys_menu_role
    ADD CONSTRAINT sys_menu_role_pkey PRIMARY KEY (sys_role_name, menu_id);


--
-- Name: sys_menu_role_sys_menu_role_id_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sys_menu_role
    ADD CONSTRAINT sys_menu_role_sys_menu_role_id_key UNIQUE (sys_menu_role_id);


--
-- Name: txt__tbl_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY txt__tbl
    ADD CONSTRAINT txt__tbl_pkey PRIMARY KEY (txt_id);


--
-- Name: txt__tbl_txt_process_txt_attrib_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY txt__tbl
    ADD CONSTRAINT txt__tbl_txt_process_txt_attrib_key UNIQUE (txt_process, txt_attrib);


--
-- Name: code2_sys_base_code_val1_code_va12_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code2_sys_base
    ADD CONSTRAINT code2_sys_base_code_val1_code_va12_key UNIQUE (code_val1, code_va12);




--
-- Name: code2_sys_base_code_val1_code_txt_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code2_sys_base
    ADD CONSTRAINT code2_sys_base_code_val1_code_txt_key UNIQUE (code_val1, code_txt);


--
-- Name: code2_country_state_code_val1_code_va12_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code2_country_state
    ADD CONSTRAINT code2_country_state_code_val1_code_va12_key UNIQUE (code_val1, code_va12);




--
-- Name: code2_country_state_code_val1_code_txt_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code2_country_state
    ADD CONSTRAINT code2_country_state_code_val1_code_txt_key UNIQUE (code_val1, code_txt);


--
-- Name: code2_country_state_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code2_country_state
    ADD CONSTRAINT code2_country_state_pkey PRIMARY KEY (code2_sys_id);


--
-- Name: code2_sys_code_schema_code_name_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code2_sys
    ADD CONSTRAINT code2_sys_code_schema_code_name_key UNIQUE (code_schema, code_name);


--
-- Name: code2_sys_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code2_sys
    ADD CONSTRAINT code2_sys_pkey PRIMARY KEY (code2_sys_h_id);


--
-- Name: code2_sys_base_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code2_sys_base
    ADD CONSTRAINT code2_sys_base_pkey PRIMARY KEY (code2_sys_id);


ALTER TABLE ONLY code_ac1
    ADD CONSTRAINT code_ac1_pkey PRIMARY KEY (code_sys_id);
ALTER TABLE ONLY code_ac1
    ADD CONSTRAINT code_ac1_code_txt_key UNIQUE (code_txt);
ALTER TABLE ONLY code_ac1
    ADD CONSTRAINT code_ac1_code_val_key UNIQUE (code_val);

ALTER TABLE ONLY code_ac
    ADD CONSTRAINT code_ac_pkey PRIMARY KEY (code_sys_id);
ALTER TABLE ONLY code_ac
    ADD CONSTRAINT code_ac_code_txt_key UNIQUE (code_txt);
ALTER TABLE ONLY code_ac
    ADD CONSTRAINT code_ac_code_val_key UNIQUE (code_val);

ALTER TABLE ONLY code_ahc
    ADD CONSTRAINT code_ahc_pkey PRIMARY KEY (code_sys_id);
ALTER TABLE ONLY code_ahc
    ADD CONSTRAINT code_ahc_code_txt_key UNIQUE (code_txt);
ALTER TABLE ONLY code_ahc
    ADD CONSTRAINT code_ahc_code_val_key UNIQUE (code_val);

ALTER TABLE ONLY code_sys_base
    ADD CONSTRAINT code_sys_base_pkey PRIMARY KEY (code_sys_id);
ALTER TABLE ONLY code_sys_base
    ADD CONSTRAINT code_sys_base_code_txt_key UNIQUE (code_txt);
ALTER TABLE ONLY code_sys_base
    ADD CONSTRAINT code_sys_base_code_val_key UNIQUE (code_val);

ALTER TABLE ONLY code_country
    ADD CONSTRAINT code_country_pkey PRIMARY KEY (code_sys_id);
ALTER TABLE ONLY code_country
    ADD CONSTRAINT code_country_code_txt_key UNIQUE (code_txt);
ALTER TABLE ONLY code_country
    ADD CONSTRAINT code_country_code_val_key UNIQUE (code_val);

ALTER TABLE ONLY code_doc_scope
    ADD CONSTRAINT code_doc_scope_pkey PRIMARY KEY (code_sys_id);
ALTER TABLE ONLY code_doc_scope
    ADD CONSTRAINT code_doc_scope_code_txt_key UNIQUE (code_txt);
ALTER TABLE ONLY code_doc_scope
    ADD CONSTRAINT code_doc_scope_code_val_key UNIQUE (code_val);


--
-- Name: code_sys_code_schema_code_name_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_sys
    ADD CONSTRAINT code_sys_code_schema_code_name_key UNIQUE (code_schema, code_name);


--
-- Name: code_sys_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_sys
    ADD CONSTRAINT code_sys_pkey PRIMARY KEY (code_sys_h_id);


ALTER TABLE ONLY code_note_scope
    ADD CONSTRAINT code_note_scope_pkey PRIMARY KEY (code_sys_id);
ALTER TABLE ONLY code_note_scope
    ADD CONSTRAINT code_note_scope_code_txt_key UNIQUE (code_txt);
ALTER TABLE ONLY code_note_scope
    ADD CONSTRAINT code_note_scope_code_val_key UNIQUE (code_val);

ALTER TABLE ONLY code_note_type
    ADD CONSTRAINT code_note_type_pkey PRIMARY KEY (code_sys_id);
ALTER TABLE ONLY code_note_type
    ADD CONSTRAINT code_note_type_code_txt_key UNIQUE (code_txt);
ALTER TABLE ONLY code_note_type
    ADD CONSTRAINT code_note_type_code_val_key UNIQUE (code_val);

ALTER TABLE ONLY code_param_type
    ADD CONSTRAINT code_param_type_pkey PRIMARY KEY (code_sys_id);
ALTER TABLE ONLY code_param_type
    ADD CONSTRAINT code_param_type_code_txt_key UNIQUE (code_txt);
ALTER TABLE ONLY code_param_type
    ADD CONSTRAINT code_param_type_code_val_key UNIQUE (code_val);

ALTER TABLE ONLY code_job_action
    ADD CONSTRAINT code_job_action_pkey PRIMARY KEY (code_sys_id);
ALTER TABLE ONLY code_job_action
    ADD CONSTRAINT code_job_action_code_txt_key UNIQUE (code_txt);
ALTER TABLE ONLY code_job_action
    ADD CONSTRAINT code_job_action_code_val_key UNIQUE (code_val);

ALTER TABLE ONLY code_job_source
    ADD CONSTRAINT code_job_source_pkey PRIMARY KEY (code_sys_id);
ALTER TABLE ONLY code_job_source
    ADD CONSTRAINT code_job_source_code_txt_key UNIQUE (code_txt);
ALTER TABLE ONLY code_job_source
    ADD CONSTRAINT code_job_source_code_val_key UNIQUE (code_val);

ALTER TABLE ONLY code_txt_type
    ADD CONSTRAINT code_txt_type_pkey PRIMARY KEY (code_sys_id);
ALTER TABLE ONLY code_txt_type
    ADD CONSTRAINT code_txt_type_code_txt_key UNIQUE (code_txt);
ALTER TABLE ONLY code_txt_type
    ADD CONSTRAINT code_txt_type_code_val_key UNIQUE (code_val);


--
-- Name: code_version_sts_code_txt_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_version_sts
    ADD CONSTRAINT code_version_sts_code_txt_key UNIQUE (code_txt);


--
-- Name: code_version_sts_code_val_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_version_sts
    ADD CONSTRAINT code_version_sts_code_val_key UNIQUE (code_val);


--
-- Name: code_version_sts_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY code_version_sts
    ADD CONSTRAINT code_version_sts_pkey PRIMARY KEY (code_sys_id);


--
-- Name: version__tbl_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY version__tbl
    ADD CONSTRAINT version__tbl_pkey PRIMARY KEY (version_id);


--
-- Name: version__tbl_version__tbl_no_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY version__tbl
    ADD CONSTRAINT version__tbl_version__tbl_no_key UNIQUE (version_no_major, version_no_minor, version_no_build, version_no_rev);


--
-- Name: param_sys_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY param_sys
    ADD CONSTRAINT param_sys_pkey PRIMARY KEY (param_sys_id);


--
-- Name: param_sys_param_sys_process_param_sys_attrib_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY param_sys
    ADD CONSTRAINT param_sys_param_sys_process_param_sys_attrib_key UNIQUE (param_sys_process, param_sys_attrib);


--
-- Name: cust_user_sys_user_email_unique; Type: INDEX; Schema: jsharmony; Owner: postgres
--

CREATE UNIQUE INDEX cust_user_sys_user_email_unique ON cust_user USING btree (lower((sys_user_email)::text)) WHERE ((sys_user_sts)::text = 'ACTIVE'::text);


--
-- Name: fki_cust_user_cust_id_cust_Fkey; Type: INDEX; Schema: jsharmony; Owner: postgres
--

CREATE INDEX "fki_cust_user_cust_id_cust_Fkey" ON cust_user USING btree (cust_id);


--
-- Name: fki_doc__tbl_doc_scope_doc_ctgr; Type: INDEX; Schema: jsharmony; Owner: postgres
--

CREATE INDEX fki_doc__tbl_doc_scope_doc_ctgr ON doc__tbl USING btree (doc_scope, doc_ctgr);


--
-- Name: help__tbl_help_target_code_unique; Type: INDEX; Schema: jsharmony; Owner: postgres
--

CREATE UNIQUE INDEX help__tbl_help_target_code_unique ON help__tbl USING btree (help_target_code) WHERE (help_target_code IS NOT NULL);


--
-- Name: sys_user_sys_user_email_unique; Type: INDEX; Schema: jsharmony; Owner: postgres
--

CREATE UNIQUE INDEX sys_user_sys_user_email_unique ON sys_user USING btree (lower((sys_user_email)::text)) WHERE ((sys_user_sts)::text = 'ACTIVE'::text);


--
-- Name: code2_sys_coalesce_code_name_idx; Type: INDEX; Schema: jsharmony; Owner: postgres
--

CREATE UNIQUE INDEX code2_sys_coalesce_code_name_idx ON code2_sys USING btree ((COALESCE(code_schema, '*** NULL IS HERE ***'::character varying)), code_name);


--
-- Name: code_sys_coalesce_code_name_idx; Type: INDEX; Schema: jsharmony; Owner: postgres
--

CREATE UNIQUE INDEX code_sys_coalesce_code_name_idx ON code_sys USING btree ((COALESCE(code_schema, '*** NULL IS HERE ***'::character varying)), code_name);


--
-- Name: cust_user_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER cust_user_iud BEFORE INSERT OR DELETE OR UPDATE ON cust_user FOR EACH ROW EXECUTE PROCEDURE cust_user_iud();


--
-- Name: cust_user_iud_after_insert; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER cust_user_iud_after_insert AFTER INSERT ON cust_user FOR EACH ROW EXECUTE PROCEDURE cust_user_iud_after_insert();


--
-- Name: cust_user_role_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER cust_user_role_iud BEFORE INSERT OR DELETE OR UPDATE ON cust_user_role FOR EACH ROW EXECUTE PROCEDURE cust_user_role_iud();


--
-- Name: doc__tbl_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER doc__tbl_iud BEFORE INSERT OR DELETE OR UPDATE ON doc__tbl FOR EACH ROW EXECUTE PROCEDURE doc__tbl_iud();


--
-- Name: code2_doc_scope_doc_ctgr_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER code2_doc_scope_doc_ctgr_iud BEFORE INSERT OR DELETE OR UPDATE ON code2_doc_scope_doc_ctgr FOR EACH ROW EXECUTE PROCEDURE code2_app_base_iud();


--
-- Name: code2_app_base_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER code2_app_base_iud BEFORE INSERT OR DELETE OR UPDATE ON code2_app_base FOR EACH ROW EXECUTE PROCEDURE code2_app_base_iud();


--
-- Name: code_app_base_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER code_app_base_iud BEFORE INSERT OR DELETE OR UPDATE ON code_app_base FOR EACH ROW EXECUTE PROCEDURE code_app_base_iud();


--
-- Name: param_app_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER param_app_iud BEFORE INSERT OR DELETE OR UPDATE ON param_app FOR EACH ROW EXECUTE PROCEDURE param_app_iud();


--
-- Name: help__tbl_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER help__tbl_iud BEFORE INSERT OR DELETE OR UPDATE ON help__tbl FOR EACH ROW EXECUTE PROCEDURE help__tbl_iud();


--
-- Name: note__tbl_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER note__tbl_iud BEFORE INSERT OR DELETE OR UPDATE ON note__tbl FOR EACH ROW EXECUTE PROCEDURE note__tbl_iud();


--
-- Name: sys_user_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER sys_user_iud BEFORE INSERT OR DELETE OR UPDATE ON sys_user FOR EACH ROW EXECUTE PROCEDURE sys_user_iud();


--
-- Name: param__tbl_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER param__tbl_iud BEFORE INSERT OR DELETE OR UPDATE ON param__tbl FOR EACH ROW EXECUTE PROCEDURE param__tbl_iud();


--
-- Name: param_user_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER param_user_iud BEFORE INSERT OR DELETE OR UPDATE ON param_user FOR EACH ROW EXECUTE PROCEDURE param_user_iud();


--
-- Name: sys_user_func_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER sys_user_func_iud BEFORE INSERT OR DELETE OR UPDATE ON sys_user_func FOR EACH ROW EXECUTE PROCEDURE sys_user_func_iud();


--
-- Name: sys_user_role_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER sys_user_role_iud BEFORE INSERT OR DELETE OR UPDATE ON sys_user_role FOR EACH ROW EXECUTE PROCEDURE sys_user_role_iud();


--
-- Name: txt__tbl_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER txt__tbl_iud BEFORE INSERT OR DELETE OR UPDATE ON txt__tbl FOR EACH ROW EXECUTE PROCEDURE txt__tbl_iud();


--
-- Name: v_cust_menu_role_selection_iud_insteadof_update; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER v_cust_menu_role_selection_iud_insteadof_update INSTEAD OF UPDATE ON v_cust_menu_role_selection FOR EACH ROW EXECUTE PROCEDURE v_cust_menu_role_selection_iud_insteadof_update();


--
-- Name: v_sys_menu_role_selection_iud_insteadof_update; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER v_sys_menu_role_selection_iud_insteadof_update INSTEAD OF UPDATE ON v_sys_menu_role_selection FOR EACH ROW EXECUTE PROCEDURE v_sys_menu_role_selection_iud_insteadof_update();


--
-- Name: param_sys_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER param_sys_iud BEFORE INSERT OR DELETE OR UPDATE ON param_sys FOR EACH ROW EXECUTE PROCEDURE param_sys_iud();


--
-- Name: audit_detail_audit_seq_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY audit_detail
    ADD CONSTRAINT audit_detail_audit_seq_fkey FOREIGN KEY (audit_seq) REFERENCES audit__tbl(audit_seq);


--
-- Name: cust_user_sys_user_sts_code_ahc_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY cust_user
    ADD CONSTRAINT cust_user_sys_user_sts_code_ahc_fkey FOREIGN KEY (sys_user_sts) REFERENCES code_ahc(code_val);


--
-- Name: cust_user_role_cust_role_name_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY cust_user_role
    ADD CONSTRAINT cust_user_role_cust_role_name_fkey FOREIGN KEY (cust_role_name) REFERENCES cust_role(cust_role_name);


--
-- Name: cust_user_role_sys_user_id_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY cust_user_role
    ADD CONSTRAINT cust_user_role_sys_user_id_fkey FOREIGN KEY (sys_user_id) REFERENCES cust_user(sys_user_id) ON DELETE CASCADE;


--
-- Name: cust_role_cust_role_sts_code_ahc_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY cust_role
    ADD CONSTRAINT cust_role_cust_role_sts_code_ahc_fkey FOREIGN KEY (cust_role_sts) REFERENCES code_ahc(code_val);


--
-- Name: cust_menu_role_cust_role_name_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY cust_menu_role
    ADD CONSTRAINT cust_menu_role_cust_role_name_fkey FOREIGN KEY (cust_role_name) REFERENCES cust_role(cust_role_name) ON DELETE CASCADE;


--
-- Name: cust_menu_role_menu_id_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY cust_menu_role
    ADD CONSTRAINT cust_menu_role_menu_id_fkey FOREIGN KEY (menu_id) REFERENCES menu__tbl(menu_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: doc__tbl_doc_scope_doc_ctgr; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY doc__tbl
    ADD CONSTRAINT doc__tbl_doc_scope_doc_ctgr FOREIGN KEY (doc_scope, doc_ctgr) REFERENCES code2_doc_scope_doc_ctgr(code_val1, code_va12);


--
-- Name: doc__tbl_doc_scope_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY doc__tbl
    ADD CONSTRAINT doc__tbl_doc_scope_fkey FOREIGN KEY (doc_scope) REFERENCES code_doc_scope(code_val);


--
-- Name: param_app_param__tbl_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY param_app
    ADD CONSTRAINT param_app_param__tbl_fkey FOREIGN KEY (param_app_process, param_app_attrib) REFERENCES param__tbl(param_process, param_attrib);


--
-- Name: help__tbl_help_target_code_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY help__tbl
    ADD CONSTRAINT help__tbl_help_target_code_fkey FOREIGN KEY (help_target_code) REFERENCES help_target(help_target_code);


--
-- Name: note__tbl_note_scope_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY note__tbl
    ADD CONSTRAINT note__tbl_note_scope_fkey FOREIGN KEY (note_scope) REFERENCES code_note_scope(code_val);


--
-- Name: note__tbl_note_sts_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY note__tbl
    ADD CONSTRAINT note__tbl_note_sts_fkey FOREIGN KEY (note_sts) REFERENCES code_ac1(code_val);


--
-- Name: note__tbl_note_type_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY note__tbl
    ADD CONSTRAINT note__tbl_note_type_fkey FOREIGN KEY (note_type) REFERENCES code_note_type(code_val);


--
-- Name: sys_user_sys_user_sts_code_ahc_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sys_user
    ADD CONSTRAINT sys_user_sys_user_sts_code_ahc_fkey FOREIGN KEY (sys_user_sts) REFERENCES code_ahc(code_val);


--
-- Name: sys_user_code2_country_state_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sys_user
    ADD CONSTRAINT sys_user_code2_country_state_fkey FOREIGN KEY (sys_user_country, sys_user_state) REFERENCES code2_country_state(code_val1, code_va12);


--
-- Name: sys_user_code_country_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sys_user
    ADD CONSTRAINT sys_user_code_country_fkey FOREIGN KEY (sys_user_country) REFERENCES code_country(code_val);


--
-- Name: param__tbl_code_param_type_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY param__tbl
    ADD CONSTRAINT param__tbl_code_param_type_fkey FOREIGN KEY (param_type) REFERENCES code_param_type(code_val);


--
-- Name: param_user_sys_user_id_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY param_user
    ADD CONSTRAINT param_user_sys_user_id_fkey FOREIGN KEY (sys_user_id) REFERENCES sys_user(sys_user_id) ON DELETE CASCADE;


--
-- Name: param_user_param__tbl_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY param_user
    ADD CONSTRAINT param_user_param__tbl_fkey FOREIGN KEY (param_user_process, param_user_attrib) REFERENCES param__tbl(param_process, param_attrib) ON DELETE CASCADE;


--
-- Name: job_doc_job_id_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY job_doc
    ADD CONSTRAINT job_doc_job_id_fkey FOREIGN KEY (job_id) REFERENCES job__tbl(job_id);


--
-- Name: job_email_job_id_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY job_email
    ADD CONSTRAINT job_email_job_id_fkey FOREIGN KEY (job_id) REFERENCES job__tbl(job_id);


--
-- Name: job_note_job_id_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY job_note
    ADD CONSTRAINT job_note_job_id_fkey FOREIGN KEY (job_id) REFERENCES job__tbl(job_id);


--
-- Name: job_queue_job_id_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY job_queue
    ADD CONSTRAINT job_queue_job_id_fkey FOREIGN KEY (job_id) REFERENCES job__tbl(job_id);


--
-- Name: job_sms_job_id_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY job_sms
    ADD CONSTRAINT job_sms_job_id_fkey FOREIGN KEY (job_id) REFERENCES job__tbl(job_id);


--
-- Name: job__tbl_code_job_action_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY job__tbl
    ADD CONSTRAINT job__tbl_code_job_action_fkey FOREIGN KEY (job_action) REFERENCES code_job_action(code_val);


--
-- Name: job__tbl_code_job_source_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY job__tbl
    ADD CONSTRAINT job__tbl_code_job_source_fkey FOREIGN KEY (job_source) REFERENCES code_job_source(code_val);


--
-- Name: sys_func_sys_func_sts_code_ahc_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sys_func
    ADD CONSTRAINT sys_func_sys_func_sts_code_ahc_fkey FOREIGN KEY (sys_func_sts) REFERENCES code_ahc(code_val);


--
-- Name: menu__tbl_menu_id_parent_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY menu__tbl
    ADD CONSTRAINT menu__tbl_menu_id_parent_fkey FOREIGN KEY (menu_id_parent) REFERENCES menu__tbl(menu_id);


--
-- Name: menu__tbl_menu_sts_code_ahc_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY menu__tbl
    ADD CONSTRAINT menu__tbl_menu_sts_code_ahc_fkey FOREIGN KEY (menu_sts) REFERENCES code_ahc(code_val);


--
-- Name: sys_user_func_sys_user_id_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sys_user_func
    ADD CONSTRAINT sys_user_func_sys_user_id_fkey FOREIGN KEY (sys_user_id) REFERENCES sys_user(sys_user_id);


--
-- Name: sys_user_func_sys_func_name_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sys_user_func
    ADD CONSTRAINT sys_user_func_sys_func_name_fkey FOREIGN KEY (sys_func_name) REFERENCES sys_func(sys_func_name);


--
-- Name: sys_user_role_sys_user_id_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sys_user_role
    ADD CONSTRAINT sys_user_role_sys_user_id_fkey FOREIGN KEY (sys_user_id) REFERENCES sys_user(sys_user_id);


--
-- Name: sys_user_role_sys_role_name_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sys_user_role
    ADD CONSTRAINT sys_user_role_sys_role_name_fkey FOREIGN KEY (sys_role_name) REFERENCES sys_role(sys_role_name);


--
-- Name: sys_role_sys_role_sts_code_ahc_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sys_role
    ADD CONSTRAINT sys_role_sys_role_sts_code_ahc_fkey FOREIGN KEY (sys_role_sts) REFERENCES code_ahc(code_val);


--
-- Name: sys_menu_role_menu_id_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sys_menu_role
    ADD CONSTRAINT sys_menu_role_menu_id_fkey FOREIGN KEY (menu_id) REFERENCES menu__tbl(menu_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sys_menu_role_sys_role_name_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sys_menu_role
    ADD CONSTRAINT sys_menu_role_sys_role_name_fkey FOREIGN KEY (sys_role_name) REFERENCES sys_role(sys_role_name) ON DELETE CASCADE;


--
-- Name: txt__tbl_code_txt_type_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY txt__tbl
    ADD CONSTRAINT txt__tbl_code_txt_type_fkey FOREIGN KEY (txt_type) REFERENCES code_txt_type(code_val);


--
-- Name: version__tbl_version_sts_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY version__tbl
    ADD CONSTRAINT version__tbl_version_sts_fkey FOREIGN KEY (version_sts) REFERENCES code_version_sts(code_val);


--
-- Name: param_sys_param__tbl_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY param_sys
    ADD CONSTRAINT param_sys_param__tbl_fkey FOREIGN KEY (param_sys_process, param_sys_attrib) REFERENCES param__tbl(param_process, param_attrib);


--
-- Name: jsharmony; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA jsharmony FROM PUBLIC;
REVOKE ALL ON SCHEMA jsharmony FROM postgres;
GRANT ALL ON SCHEMA jsharmony TO postgres;
GRANT USAGE ON SCHEMA jsharmony TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT USAGE ON SCHEMA jsharmony TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: audit(toaudit, bigint, bigint, character varying, text); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION audit(toa toaudit, INOUT par_audit_seq bigint, par_audit_table_id bigint, par_audit_column_name character varying, par_audit_column_val text) FROM PUBLIC;
REVOKE ALL ON FUNCTION audit(toa toaudit, INOUT par_audit_seq bigint, par_audit_table_id bigint, par_audit_column_name character varying, par_audit_column_val text) FROM postgres;
GRANT ALL ON FUNCTION audit(toa toaudit, INOUT par_audit_seq bigint, par_audit_table_id bigint, par_audit_column_name character varying, par_audit_column_val text) TO postgres;
GRANT ALL ON FUNCTION audit(toa toaudit, INOUT par_audit_seq bigint, par_audit_table_id bigint, par_audit_column_name character varying, par_audit_column_val text) TO PUBLIC;
GRANT ALL ON FUNCTION audit(toa toaudit, INOUT par_audit_seq bigint, par_audit_table_id bigint, par_audit_column_name character varying, par_audit_column_val text) TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION audit(toa toaudit, INOUT par_audit_seq bigint, par_audit_table_id bigint, par_audit_column_name character varying, par_audit_column_val text) TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: audit_base(toaudit, bigint, bigint, character varying, text); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION audit_base(toa toaudit, INOUT par_audit_seq bigint, par_audit_table_id bigint, par_audit_column_name character varying, par_audit_column_val text) FROM PUBLIC;
REVOKE ALL ON FUNCTION audit_base(toa toaudit, INOUT par_audit_seq bigint, par_audit_table_id bigint, par_audit_column_name character varying, par_audit_column_val text) FROM postgres;
GRANT ALL ON FUNCTION audit_base(toa toaudit, INOUT par_audit_seq bigint, par_audit_table_id bigint, par_audit_column_name character varying, par_audit_column_val text) TO postgres;
GRANT ALL ON FUNCTION audit_base(toa toaudit, INOUT par_audit_seq bigint, par_audit_table_id bigint, par_audit_column_name character varying, par_audit_column_val text) TO PUBLIC;
GRANT ALL ON FUNCTION audit_base(toa toaudit, INOUT par_audit_seq bigint, par_audit_table_id bigint, par_audit_column_name character varying, par_audit_column_val text) TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION audit_base(toa toaudit, INOUT par_audit_seq bigint, par_audit_table_id bigint, par_audit_column_name character varying, par_audit_column_val text) TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: log_audit_info(timestamp without time zone, character varying, timestamp without time zone, character varying); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION log_audit_info(timestamp without time zone, character varying, timestamp without time zone, character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION log_audit_info(timestamp without time zone, character varying, timestamp without time zone, character varying) FROM postgres;
GRANT ALL ON FUNCTION log_audit_info(timestamp without time zone, character varying, timestamp without time zone, character varying) TO postgres;
GRANT ALL ON FUNCTION log_audit_info(timestamp without time zone, character varying, timestamp without time zone, character varying) TO PUBLIC;
GRANT ALL ON FUNCTION log_audit_info(timestamp without time zone, character varying, timestamp without time zone, character varying) TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION log_audit_info(timestamp without time zone, character varying, timestamp without time zone, character varying) TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: check_code(character varying, character varying); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION check_code(in_tblname character varying, in_code_val character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION check_code(in_tblname character varying, in_code_val character varying) FROM postgres;
GRANT ALL ON FUNCTION check_code(in_tblname character varying, in_code_val character varying) TO postgres;
GRANT ALL ON FUNCTION check_code(in_tblname character varying, in_code_val character varying) TO PUBLIC;
GRANT ALL ON FUNCTION check_code(in_tblname character varying, in_code_val character varying) TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION check_code(in_tblname character varying, in_code_val character varying) TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: check_code2(character varying, character varying, character varying); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION check_code2(in_tblname character varying, in_code_val1 character varying, in_code_va12 character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION check_code2(in_tblname character varying, in_code_val1 character varying, in_code_va12 character varying) FROM postgres;
GRANT ALL ON FUNCTION check_code2(in_tblname character varying, in_code_val1 character varying, in_code_va12 character varying) TO postgres;
GRANT ALL ON FUNCTION check_code2(in_tblname character varying, in_code_val1 character varying, in_code_va12 character varying) TO PUBLIC;
GRANT ALL ON FUNCTION check_code2(in_tblname character varying, in_code_val1 character varying, in_code_va12 character varying) TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION check_code2(in_tblname character varying, in_code_val1 character varying, in_code_va12 character varying) TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: check_code2_exec(character varying, character varying, character varying); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION check_code2_exec(in_tblname character varying, in_code_val1 character varying, in_code_va12 character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION check_code2_exec(in_tblname character varying, in_code_val1 character varying, in_code_va12 character varying) FROM postgres;
GRANT ALL ON FUNCTION check_code2_exec(in_tblname character varying, in_code_val1 character varying, in_code_va12 character varying) TO postgres;
GRANT ALL ON FUNCTION check_code2_exec(in_tblname character varying, in_code_val1 character varying, in_code_va12 character varying) TO PUBLIC;
GRANT ALL ON FUNCTION check_code2_exec(in_tblname character varying, in_code_val1 character varying, in_code_va12 character varying) TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION check_code2_exec(in_tblname character varying, in_code_val1 character varying, in_code_va12 character varying) TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: check_code_exec(character varying, character varying); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION check_code_exec(in_tblname character varying, in_code_val character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION check_code_exec(in_tblname character varying, in_code_val character varying) FROM postgres;
GRANT ALL ON FUNCTION check_code_exec(in_tblname character varying, in_code_val character varying) TO postgres;
GRANT ALL ON FUNCTION check_code_exec(in_tblname character varying, in_code_val character varying) TO PUBLIC;
GRANT ALL ON FUNCTION check_code_exec(in_tblname character varying, in_code_val character varying) TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION check_code_exec(in_tblname character varying, in_code_val character varying) TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: check_foreign_key(character varying, bigint); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION check_foreign_key(in_tblname character varying, in_tblid bigint) FROM PUBLIC;
REVOKE ALL ON FUNCTION check_foreign_key(in_tblname character varying, in_tblid bigint) FROM postgres;
GRANT ALL ON FUNCTION check_foreign_key(in_tblname character varying, in_tblid bigint) TO postgres;
GRANT ALL ON FUNCTION check_foreign_key(in_tblname character varying, in_tblid bigint) TO PUBLIC;
GRANT ALL ON FUNCTION check_foreign_key(in_tblname character varying, in_tblid bigint) TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION check_foreign_key(in_tblname character varying, in_tblid bigint) TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: check_foreign_key_exec(character varying, bigint); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION check_foreign_key_exec(in_tblname character varying, in_tblid bigint) FROM PUBLIC;
REVOKE ALL ON FUNCTION check_foreign_key_exec(in_tblname character varying, in_tblid bigint) FROM postgres;
GRANT ALL ON FUNCTION check_foreign_key_exec(in_tblname character varying, in_tblid bigint) TO postgres;
GRANT ALL ON FUNCTION check_foreign_key_exec(in_tblname character varying, in_tblid bigint) TO PUBLIC;
GRANT ALL ON FUNCTION check_foreign_key_exec(in_tblname character varying, in_tblid bigint) TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION check_foreign_key_exec(in_tblname character varying, in_tblid bigint) TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: check_param(character varying, character varying, character varying, character varying); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION check_param(in_table character varying, in_process character varying, in_attrib character varying, in_val character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION check_param(in_table character varying, in_process character varying, in_attrib character varying, in_val character varying) FROM postgres;
GRANT ALL ON FUNCTION check_param(in_table character varying, in_process character varying, in_attrib character varying, in_val character varying) TO postgres;
GRANT ALL ON FUNCTION check_param(in_table character varying, in_process character varying, in_attrib character varying, in_val character varying) TO PUBLIC;
GRANT ALL ON FUNCTION check_param(in_table character varying, in_process character varying, in_attrib character varying, in_val character varying) TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION check_param(in_table character varying, in_process character varying, in_attrib character varying, in_val character varying) TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: cust_user_iud(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION cust_user_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION cust_user_iud() FROM postgres;
GRANT ALL ON FUNCTION cust_user_iud() TO postgres;
GRANT ALL ON FUNCTION cust_user_iud() TO PUBLIC;
GRANT ALL ON FUNCTION cust_user_iud() TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION cust_user_iud() TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: cust_user_iud_after_insert(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION cust_user_iud_after_insert() FROM PUBLIC;
REVOKE ALL ON FUNCTION cust_user_iud_after_insert() FROM postgres;
GRANT ALL ON FUNCTION cust_user_iud_after_insert() TO postgres;
GRANT ALL ON FUNCTION cust_user_iud_after_insert() TO PUBLIC;
GRANT ALL ON FUNCTION cust_user_iud_after_insert() TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION cust_user_iud_after_insert() TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: cust_user_role_iud(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION cust_user_role_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION cust_user_role_iud() FROM postgres;
GRANT ALL ON FUNCTION cust_user_role_iud() TO postgres;
GRANT ALL ON FUNCTION cust_user_role_iud() TO PUBLIC;
GRANT ALL ON FUNCTION cust_user_role_iud() TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION cust_user_role_iud() TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: create_code_app(character varying, character varying, character varying); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION create_code_app(in_code_schema character varying, in_code_name character varying, in_code_desc character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION create_code_app(in_code_schema character varying, in_code_name character varying, in_code_desc character varying) FROM postgres;
GRANT ALL ON FUNCTION create_code_app(in_code_schema character varying, in_code_name character varying, in_code_desc character varying) TO postgres;
GRANT ALL ON FUNCTION create_code_app(in_code_schema character varying, in_code_name character varying, in_code_desc character varying) TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: create_code2_app(character varying, character varying, character varying); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION create_code2_app(in_code_schema character varying, in_code_name character varying, in_code_desc character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION create_code2_app(in_code_schema character varying, in_code_name character varying, in_code_desc character varying) FROM postgres;
GRANT ALL ON FUNCTION create_code2_app(in_code_schema character varying, in_code_name character varying, in_code_desc character varying) TO postgres;
GRANT ALL ON FUNCTION create_code2_app(in_code_schema character varying, in_code_name character varying, in_code_desc character varying) TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: create_code_sys(character varying, character varying, character varying); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION create_code_sys(in_code_schema character varying, in_code_name character varying, in_code_desc character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION create_code_sys(in_code_schema character varying, in_code_name character varying, in_code_desc character varying) FROM postgres;
GRANT ALL ON FUNCTION create_code_sys(in_code_schema character varying, in_code_name character varying, in_code_desc character varying) TO postgres;
GRANT ALL ON FUNCTION create_code_sys(in_code_schema character varying, in_code_name character varying, in_code_desc character varying) TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: create_code2_sys(character varying, character varying, character varying); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION create_code2_sys(in_code_schema character varying, in_code_name character varying, in_code_desc character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION create_code2_sys(in_code_schema character varying, in_code_name character varying, in_code_desc character varying) FROM postgres;
GRANT ALL ON FUNCTION create_code2_sys(in_code_schema character varying, in_code_name character varying, in_code_desc character varying) TO postgres;
GRANT ALL ON FUNCTION create_code2_sys(in_code_schema character varying, in_code_name character varying, in_code_desc character varying) TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: doc__tbl_iud(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION doc__tbl_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION doc__tbl_iud() FROM postgres;
GRANT ALL ON FUNCTION doc__tbl_iud() TO postgres;
GRANT ALL ON FUNCTION doc__tbl_iud() TO PUBLIC;
GRANT ALL ON FUNCTION doc__tbl_iud() TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION doc__tbl_iud() TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;



REVOKE ALL ON FUNCTION {schema}.doc_filename(bigint, text) FROM PUBLIC;
REVOKE ALL ON FUNCTION {schema}.doc_filename(bigint, text) FROM postgres;
GRANT ALL ON FUNCTION {schema}.doc_filename(bigint, text) TO postgres;
GRANT ALL ON FUNCTION {schema}.doc_filename(bigint, text) TO PUBLIC;
GRANT ALL ON FUNCTION {schema}.doc_filename(bigint, text) TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION {schema}.doc_filename(bigint, text) TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: digest(bytea, text); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION digest(bytea, text) FROM PUBLIC;
REVOKE ALL ON FUNCTION digest(bytea, text) FROM postgres;
GRANT ALL ON FUNCTION digest(bytea, text) TO postgres;
GRANT ALL ON FUNCTION digest(bytea, text) TO PUBLIC;
GRANT ALL ON FUNCTION digest(bytea, text) TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION digest(bytea, text) TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: digest(text, text); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION digest(text, text) FROM PUBLIC;
REVOKE ALL ON FUNCTION digest(text, text) FROM postgres;
GRANT ALL ON FUNCTION digest(text, text) TO postgres;
GRANT ALL ON FUNCTION digest(text, text) TO PUBLIC;
GRANT ALL ON FUNCTION digest(text, text) TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION digest(text, text) TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: code2_app_base_iud(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION code2_app_base_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION code2_app_base_iud() FROM postgres;
GRANT ALL ON FUNCTION code2_app_base_iud() TO postgres;
GRANT ALL ON FUNCTION code2_app_base_iud() TO PUBLIC;
GRANT ALL ON FUNCTION code2_app_base_iud() TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION code2_app_base_iud() TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: code_app_base_iud(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION code_app_base_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION code_app_base_iud() FROM postgres;
GRANT ALL ON FUNCTION code_app_base_iud() TO postgres;
GRANT ALL ON FUNCTION code_app_base_iud() TO PUBLIC;
GRANT ALL ON FUNCTION code_app_base_iud() TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION code_app_base_iud() TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: get_cust_user_name(bigint); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION get_cust_user_name(in_sys_user_id bigint) FROM PUBLIC;
REVOKE ALL ON FUNCTION get_cust_user_name(in_sys_user_id bigint) FROM postgres;
GRANT ALL ON FUNCTION get_cust_user_name(in_sys_user_id bigint) TO postgres;
GRANT ALL ON FUNCTION get_cust_user_name(in_sys_user_id bigint) TO PUBLIC;
GRANT ALL ON FUNCTION get_cust_user_name(in_sys_user_id bigint) TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION get_cust_user_name(in_sys_user_id bigint) TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: get_sys_user_name(bigint); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION get_sys_user_name(in_sys_user_id bigint) FROM PUBLIC;
REVOKE ALL ON FUNCTION get_sys_user_name(in_sys_user_id bigint) FROM postgres;
GRANT ALL ON FUNCTION get_sys_user_name(in_sys_user_id bigint) TO postgres;
GRANT ALL ON FUNCTION get_sys_user_name(in_sys_user_id bigint) TO PUBLIC;
GRANT ALL ON FUNCTION get_sys_user_name(in_sys_user_id bigint) TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION get_sys_user_name(in_sys_user_id bigint) TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: get_param_desc(character varying, character varying); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION get_param_desc(in_param_process character varying, in_param_attrib character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION get_param_desc(in_param_process character varying, in_param_attrib character varying) FROM postgres;
GRANT ALL ON FUNCTION get_param_desc(in_param_process character varying, in_param_attrib character varying) TO postgres;
GRANT ALL ON FUNCTION get_param_desc(in_param_process character varying, in_param_attrib character varying) TO PUBLIC;
GRANT ALL ON FUNCTION get_param_desc(in_param_process character varying, in_param_attrib character varying) TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION get_param_desc(in_param_process character varying, in_param_attrib character varying) TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: good_email(text); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION good_email(x text) FROM PUBLIC;
REVOKE ALL ON FUNCTION good_email(x text) FROM postgres;
GRANT ALL ON FUNCTION good_email(x text) TO postgres;
GRANT ALL ON FUNCTION good_email(x text) TO PUBLIC;
GRANT ALL ON FUNCTION good_email(x text) TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION good_email(x text) TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: param_app_iud(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION param_app_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION param_app_iud() FROM postgres;
GRANT ALL ON FUNCTION param_app_iud() TO postgres;
GRANT ALL ON FUNCTION param_app_iud() TO PUBLIC;
GRANT ALL ON FUNCTION param_app_iud() TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION param_app_iud() TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: help__tbl_iud(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION help__tbl_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION help__tbl_iud() FROM postgres;
GRANT ALL ON FUNCTION help__tbl_iud() TO postgres;
GRANT ALL ON FUNCTION help__tbl_iud() TO PUBLIC;
GRANT ALL ON FUNCTION help__tbl_iud() TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION help__tbl_iud() TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: my_db_user(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION my_db_user() FROM PUBLIC;
REVOKE ALL ON FUNCTION my_db_user() FROM postgres;
GRANT ALL ON FUNCTION my_db_user() TO postgres;
GRANT ALL ON FUNCTION my_db_user() TO PUBLIC;
GRANT ALL ON FUNCTION my_db_user() TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION my_db_user() TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: my_db_user_email(text); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION my_db_user_email(u text) FROM PUBLIC;
REVOKE ALL ON FUNCTION my_db_user_email(u text) FROM postgres;
GRANT ALL ON FUNCTION my_db_user_email(u text) TO postgres;
GRANT ALL ON FUNCTION my_db_user_email(u text) TO PUBLIC;
GRANT ALL ON FUNCTION my_db_user_email(u text) TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION my_db_user_email(u text) TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: my_db_user_fmt(text); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION my_db_user_fmt(u text) FROM PUBLIC;
REVOKE ALL ON FUNCTION my_db_user_fmt(u text) FROM postgres;
GRANT ALL ON FUNCTION my_db_user_fmt(u text) TO postgres;
GRANT ALL ON FUNCTION my_db_user_fmt(u text) TO PUBLIC;
GRANT ALL ON FUNCTION my_db_user_fmt(u text) TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION my_db_user_fmt(u text) TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: my_hash(character, bigint, character varying); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION my_hash(par_type character, par_sys_user_id bigint, par_pw character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION my_hash(par_type character, par_sys_user_id bigint, par_pw character varying) FROM postgres;
GRANT ALL ON FUNCTION my_hash(par_type character, par_sys_user_id bigint, par_pw character varying) TO postgres;
GRANT ALL ON FUNCTION my_hash(par_type character, par_sys_user_id bigint, par_pw character varying) TO PUBLIC;
GRANT ALL ON FUNCTION my_hash(par_type character, par_sys_user_id bigint, par_pw character varying) TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION my_hash(par_type character, par_sys_user_id bigint, par_pw character varying) TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: myisnumeric(text); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION myisnumeric(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION myisnumeric(text) FROM postgres;
GRANT ALL ON FUNCTION myisnumeric(text) TO postgres;
GRANT ALL ON FUNCTION myisnumeric(text) TO PUBLIC;
GRANT ALL ON FUNCTION myisnumeric(text) TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION myisnumeric(text) TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: mymmddyy(timestamp without time zone); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION mymmddyy(timestamp without time zone) FROM PUBLIC;
REVOKE ALL ON FUNCTION mymmddyy(timestamp without time zone) FROM postgres;
GRANT ALL ON FUNCTION mymmddyy(timestamp without time zone) TO postgres;
GRANT ALL ON FUNCTION mymmddyy(timestamp without time zone) TO PUBLIC;
GRANT ALL ON FUNCTION mymmddyy(timestamp without time zone) TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION mymmddyy(timestamp without time zone) TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: my_mmddyyhhmi(timestamp without time zone); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION my_mmddyyhhmi(timestamp without time zone) FROM PUBLIC;
REVOKE ALL ON FUNCTION my_mmddyyhhmi(timestamp without time zone) FROM postgres;
GRANT ALL ON FUNCTION my_mmddyyhhmi(timestamp without time zone) TO postgres;
GRANT ALL ON FUNCTION my_mmddyyhhmi(timestamp without time zone) TO PUBLIC;
GRANT ALL ON FUNCTION my_mmddyyhhmi(timestamp without time zone) TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION my_mmddyyhhmi(timestamp without time zone) TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: mymmddyyyyhhmi(timestamp without time zone); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION mymmddyyyyhhmi(timestamp without time zone) FROM PUBLIC;
REVOKE ALL ON FUNCTION mymmddyyyyhhmi(timestamp without time zone) FROM postgres;
GRANT ALL ON FUNCTION mymmddyyyyhhmi(timestamp without time zone) TO postgres;
GRANT ALL ON FUNCTION mymmddyyyyhhmi(timestamp without time zone) TO PUBLIC;
GRANT ALL ON FUNCTION mymmddyyyyhhmi(timestamp without time zone) TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION mymmddyyyyhhmi(timestamp without time zone) TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: my_now(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION my_now() FROM PUBLIC;
REVOKE ALL ON FUNCTION my_now() FROM postgres;
GRANT ALL ON FUNCTION my_now() TO postgres;
GRANT ALL ON FUNCTION my_now() TO PUBLIC;
GRANT ALL ON FUNCTION my_now() TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION my_now() TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: my_sys_user_id(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION my_sys_user_id() FROM PUBLIC;
REVOKE ALL ON FUNCTION my_sys_user_id() FROM postgres;
GRANT ALL ON FUNCTION my_sys_user_id() TO postgres;
GRANT ALL ON FUNCTION my_sys_user_id() TO PUBLIC;
GRANT ALL ON FUNCTION my_sys_user_id() TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION my_sys_user_id() TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: my_cust_user_id(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION my_cust_user_id() FROM PUBLIC;
REVOKE ALL ON FUNCTION my_cust_user_id() FROM postgres;
GRANT ALL ON FUNCTION my_cust_user_id() TO postgres;
GRANT ALL ON FUNCTION my_cust_user_id() TO PUBLIC;
GRANT ALL ON FUNCTION my_cust_user_id() TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION my_cust_user_id() TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: my_to_date(timestamp without time zone); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION my_to_date(timestamp without time zone) FROM PUBLIC;
REVOKE ALL ON FUNCTION my_to_date(timestamp without time zone) FROM postgres;
GRANT ALL ON FUNCTION my_to_date(timestamp without time zone) TO postgres;
GRANT ALL ON FUNCTION my_to_date(timestamp without time zone) TO PUBLIC;
GRANT ALL ON FUNCTION my_to_date(timestamp without time zone) TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION my_to_date(timestamp without time zone) TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: my_today(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION my_today() FROM PUBLIC;
REVOKE ALL ON FUNCTION my_today() FROM postgres;
GRANT ALL ON FUNCTION my_today() TO postgres;
GRANT ALL ON FUNCTION my_today() TO PUBLIC;
GRANT ALL ON FUNCTION my_today() TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION my_today() TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: note__tbl_iud(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION note__tbl_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION note__tbl_iud() FROM postgres;
GRANT ALL ON FUNCTION note__tbl_iud() TO postgres;
GRANT ALL ON FUNCTION note__tbl_iud() TO PUBLIC;
GRANT ALL ON FUNCTION note__tbl_iud() TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION note__tbl_iud() TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: nequal(bit, bit); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION nequal(x1 bit, x2 bit) FROM PUBLIC;
REVOKE ALL ON FUNCTION nequal(x1 bit, x2 bit) FROM postgres;
GRANT ALL ON FUNCTION nequal(x1 bit, x2 bit) TO postgres;
GRANT ALL ON FUNCTION nequal(x1 bit, x2 bit) TO PUBLIC;
GRANT ALL ON FUNCTION nequal(x1 bit, x2 bit) TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION nequal(x1 bit, x2 bit) TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: nequal(boolean, boolean); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION nequal(x1 boolean, x2 boolean) FROM PUBLIC;
REVOKE ALL ON FUNCTION nequal(x1 boolean, x2 boolean) FROM postgres;
GRANT ALL ON FUNCTION nequal(x1 boolean, x2 boolean) TO postgres;
GRANT ALL ON FUNCTION nequal(x1 boolean, x2 boolean) TO PUBLIC;
GRANT ALL ON FUNCTION nequal(x1 boolean, x2 boolean) TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION nequal(x1 boolean, x2 boolean) TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: nequal(smallint, smallint); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION nequal(x1 smallint, x2 smallint) FROM PUBLIC;
REVOKE ALL ON FUNCTION nequal(x1 smallint, x2 smallint) FROM postgres;
GRANT ALL ON FUNCTION nequal(x1 smallint, x2 smallint) TO postgres;
GRANT ALL ON FUNCTION nequal(x1 smallint, x2 smallint) TO PUBLIC;
GRANT ALL ON FUNCTION nequal(x1 smallint, x2 smallint) TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION nequal(x1 smallint, x2 smallint) TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: nequal(integer, integer); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION nequal(x1 integer, x2 integer) FROM PUBLIC;
REVOKE ALL ON FUNCTION nequal(x1 integer, x2 integer) FROM postgres;
GRANT ALL ON FUNCTION nequal(x1 integer, x2 integer) TO postgres;
GRANT ALL ON FUNCTION nequal(x1 integer, x2 integer) TO PUBLIC;
GRANT ALL ON FUNCTION nequal(x1 integer, x2 integer) TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION nequal(x1 integer, x2 integer) TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: nequal(bigint, bigint); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION nequal(x1 bigint, x2 bigint) FROM PUBLIC;
REVOKE ALL ON FUNCTION nequal(x1 bigint, x2 bigint) FROM postgres;
GRANT ALL ON FUNCTION nequal(x1 bigint, x2 bigint) TO postgres;
GRANT ALL ON FUNCTION nequal(x1 bigint, x2 bigint) TO PUBLIC;
GRANT ALL ON FUNCTION nequal(x1 bigint, x2 bigint) TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION nequal(x1 bigint, x2 bigint) TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: nequal(numeric, numeric); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION nequal(x1 numeric, x2 numeric) FROM PUBLIC;
REVOKE ALL ON FUNCTION nequal(x1 numeric, x2 numeric) FROM postgres;
GRANT ALL ON FUNCTION nequal(x1 numeric, x2 numeric) TO postgres;
GRANT ALL ON FUNCTION nequal(x1 numeric, x2 numeric) TO PUBLIC;
GRANT ALL ON FUNCTION nequal(x1 numeric, x2 numeric) TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION nequal(x1 numeric, x2 numeric) TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: nequal(text, text); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION nequal(x1 text, x2 text) FROM PUBLIC;
REVOKE ALL ON FUNCTION nequal(x1 text, x2 text) FROM postgres;
GRANT ALL ON FUNCTION nequal(x1 text, x2 text) TO postgres;
GRANT ALL ON FUNCTION nequal(x1 text, x2 text) TO PUBLIC;
GRANT ALL ON FUNCTION nequal(x1 text, x2 text) TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION nequal(x1 text, x2 text) TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: nequal(timestamp without time zone, timestamp without time zone); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION nequal(x1 timestamp without time zone, x2 timestamp without time zone) FROM PUBLIC;
REVOKE ALL ON FUNCTION nequal(x1 timestamp without time zone, x2 timestamp without time zone) FROM postgres;
GRANT ALL ON FUNCTION nequal(x1 timestamp without time zone, x2 timestamp without time zone) TO postgres;
GRANT ALL ON FUNCTION nequal(x1 timestamp without time zone, x2 timestamp without time zone) TO PUBLIC;
GRANT ALL ON FUNCTION nequal(x1 timestamp without time zone, x2 timestamp without time zone) TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION nequal(x1 timestamp without time zone, x2 timestamp without time zone) TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: sys_user_iud(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION sys_user_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION sys_user_iud() FROM postgres;
GRANT ALL ON FUNCTION sys_user_iud() TO postgres;
GRANT ALL ON FUNCTION sys_user_iud() TO PUBLIC;
GRANT ALL ON FUNCTION sys_user_iud() TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION sys_user_iud() TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: param__tbl_iud(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION param__tbl_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION param__tbl_iud() FROM postgres;
GRANT ALL ON FUNCTION param__tbl_iud() TO postgres;
GRANT ALL ON FUNCTION param__tbl_iud() TO PUBLIC;
GRANT ALL ON FUNCTION param__tbl_iud() TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION param__tbl_iud() TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: param_user_iud(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION param_user_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION param_user_iud() FROM postgres;
GRANT ALL ON FUNCTION param_user_iud() TO postgres;
GRANT ALL ON FUNCTION param_user_iud() TO PUBLIC;
GRANT ALL ON FUNCTION param_user_iud() TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION param_user_iud() TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: sanit(text); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION sanit(x text) FROM PUBLIC;
REVOKE ALL ON FUNCTION sanit(x text) FROM postgres;
GRANT ALL ON FUNCTION sanit(x text) TO postgres;
GRANT ALL ON FUNCTION sanit(x text) TO PUBLIC;
GRANT ALL ON FUNCTION sanit(x text) TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION sanit(x text) TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: sanit_json(text); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION sanit_json(x text) FROM PUBLIC;
REVOKE ALL ON FUNCTION sanit_json(x text) FROM postgres;
GRANT ALL ON FUNCTION sanit_json(x text) TO postgres;
GRANT ALL ON FUNCTION sanit_json(x text) TO PUBLIC;
GRANT ALL ON FUNCTION sanit_json(x text) TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION sanit_json(x text) TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: sys_user_func_iud(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION sys_user_func_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION sys_user_func_iud() FROM postgres;
GRANT ALL ON FUNCTION sys_user_func_iud() TO postgres;
GRANT ALL ON FUNCTION sys_user_func_iud() TO PUBLIC;
GRANT ALL ON FUNCTION sys_user_func_iud() TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION sys_user_func_iud() TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: sys_user_role_iud(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION sys_user_role_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION sys_user_role_iud() FROM postgres;
GRANT ALL ON FUNCTION sys_user_role_iud() TO postgres;
GRANT ALL ON FUNCTION sys_user_role_iud() TO PUBLIC;
GRANT ALL ON FUNCTION sys_user_role_iud() TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION sys_user_role_iud() TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: table_type(character varying, character varying); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION table_type(in_schema character varying, in_name character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION table_type(in_schema character varying, in_name character varying) FROM postgres;
GRANT ALL ON FUNCTION table_type(in_schema character varying, in_name character varying) TO postgres;
GRANT ALL ON FUNCTION table_type(in_schema character varying, in_name character varying) TO PUBLIC;
GRANT ALL ON FUNCTION table_type(in_schema character varying, in_name character varying) TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION table_type(in_schema character varying, in_name character varying) TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: txt__tbl_iud(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION txt__tbl_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION txt__tbl_iud() FROM postgres;
GRANT ALL ON FUNCTION txt__tbl_iud() TO postgres;
GRANT ALL ON FUNCTION txt__tbl_iud() TO PUBLIC;
GRANT ALL ON FUNCTION txt__tbl_iud() TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION txt__tbl_iud() TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: v_cust_menu_role_selection_iud_insteadof_update(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION v_cust_menu_role_selection_iud_insteadof_update() FROM PUBLIC;
REVOKE ALL ON FUNCTION v_cust_menu_role_selection_iud_insteadof_update() FROM postgres;
GRANT ALL ON FUNCTION v_cust_menu_role_selection_iud_insteadof_update() TO postgres;
GRANT ALL ON FUNCTION v_cust_menu_role_selection_iud_insteadof_update() TO PUBLIC;
GRANT ALL ON FUNCTION v_cust_menu_role_selection_iud_insteadof_update() TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION v_cust_menu_role_selection_iud_insteadof_update() TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: v_sys_menu_role_selection_iud_insteadof_update(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION v_sys_menu_role_selection_iud_insteadof_update() FROM PUBLIC;
REVOKE ALL ON FUNCTION v_sys_menu_role_selection_iud_insteadof_update() FROM postgres;
GRANT ALL ON FUNCTION v_sys_menu_role_selection_iud_insteadof_update() TO postgres;
GRANT ALL ON FUNCTION v_sys_menu_role_selection_iud_insteadof_update() TO PUBLIC;
GRANT ALL ON FUNCTION v_sys_menu_role_selection_iud_insteadof_update() TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION v_sys_menu_role_selection_iud_insteadof_update() TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: param_sys_iud(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION param_sys_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION param_sys_iud() FROM postgres;
GRANT ALL ON FUNCTION param_sys_iud() TO postgres;
GRANT ALL ON FUNCTION param_sys_iud() TO PUBLIC;
GRANT ALL ON FUNCTION param_sys_iud() TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION param_sys_iud() TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: audit_detail; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE audit_detail FROM PUBLIC;
REVOKE ALL ON TABLE audit_detail FROM postgres;
GRANT ALL ON TABLE audit_detail TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE audit_detail TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: audit__tbl; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE audit__tbl FROM PUBLIC;
REVOKE ALL ON TABLE audit__tbl FROM postgres;
GRANT ALL ON TABLE audit__tbl TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE audit__tbl TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: audit__tbl_audit_seq_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE audit__tbl_audit_seq_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE audit__tbl_audit_seq_seq FROM postgres;
GRANT ALL ON SEQUENCE audit__tbl_audit_seq_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE audit__tbl_audit_seq_seq TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: cust_user; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE cust_user FROM PUBLIC;
REVOKE ALL ON TABLE cust_user FROM postgres;
GRANT ALL ON TABLE cust_user TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cust_user TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: cust_user_sys_user_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE cust_user_sys_user_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE cust_user_sys_user_id_seq FROM postgres;
GRANT ALL ON SEQUENCE cust_user_sys_user_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE cust_user_sys_user_id_seq TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: cust_user_role; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE cust_user_role FROM PUBLIC;
REVOKE ALL ON TABLE cust_user_role FROM postgres;
GRANT ALL ON TABLE cust_user_role TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cust_user_role TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: cust_user_role_cust_user_role_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE cust_user_role_cust_user_role_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE cust_user_role_cust_user_role_id_seq FROM postgres;
GRANT ALL ON SEQUENCE cust_user_role_cust_user_role_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE cust_user_role_cust_user_role_id_seq TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: cust_role; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE cust_role FROM PUBLIC;
REVOKE ALL ON TABLE cust_role FROM postgres;
GRANT ALL ON TABLE cust_role TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cust_role TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: cust_role_cust_role_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE cust_role_cust_role_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE cust_role_cust_role_id_seq FROM postgres;
GRANT ALL ON SEQUENCE cust_role_cust_role_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE cust_role_cust_role_id_seq TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: cust_menu_role; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE cust_menu_role FROM PUBLIC;
REVOKE ALL ON TABLE cust_menu_role FROM postgres;
GRANT ALL ON TABLE cust_menu_role TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cust_menu_role TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: cust_menu_role_cust_menu_role_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE cust_menu_role_cust_menu_role_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE cust_menu_role_cust_menu_role_id_seq FROM postgres;
GRANT ALL ON SEQUENCE cust_menu_role_cust_menu_role_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE cust_menu_role_cust_menu_role_id_seq TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: doc__tbl; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE doc__tbl FROM PUBLIC;
REVOKE ALL ON TABLE doc__tbl FROM postgres;
GRANT ALL ON TABLE doc__tbl TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE doc__tbl TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: doc__tbl_doc_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE doc__tbl_doc_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE doc__tbl_doc_id_seq FROM postgres;
GRANT ALL ON SEQUENCE doc__tbl_doc_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE doc__tbl_doc_id_seq TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: single; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE single FROM PUBLIC;
REVOKE ALL ON TABLE single FROM postgres;
GRANT ALL ON TABLE single TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE single TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: single_single_ident_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE single_single_ident_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE single_single_ident_seq FROM postgres;
GRANT ALL ON SEQUENCE single_single_ident_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE single_single_ident_seq TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: code_app_base_code_app_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE code_app_base_code_app_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE code_app_base_code_app_id_seq FROM postgres;
GRANT ALL ON SEQUENCE code_app_base_code_app_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE code_app_base_code_app_id_seq TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: code_app_base; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE code_app_base FROM PUBLIC;
REVOKE ALL ON TABLE code_app_base FROM postgres;
GRANT ALL ON TABLE code_app_base TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE code_app_base TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: code2_app_base_code2_app_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE code2_app_base_code2_app_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE code2_app_base_code2_app_id_seq FROM postgres;
GRANT ALL ON SEQUENCE code2_app_base_code2_app_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE code2_app_base_code2_app_id_seq TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: code2_app_base; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE code2_app_base FROM PUBLIC;
REVOKE ALL ON TABLE code2_app_base FROM postgres;
GRANT ALL ON TABLE code2_app_base TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE code2_app_base TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: code2_doc_scope_doc_ctgr; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE code2_doc_scope_doc_ctgr FROM PUBLIC;
REVOKE ALL ON TABLE code2_doc_scope_doc_ctgr FROM postgres;
GRANT ALL ON TABLE code2_doc_scope_doc_ctgr TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE code2_doc_scope_doc_ctgr TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: code2_app; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE code2_app FROM PUBLIC;
REVOKE ALL ON TABLE code2_app FROM postgres;
GRANT ALL ON TABLE code2_app TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE code2_app TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: code_app; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE code_app FROM PUBLIC;
REVOKE ALL ON TABLE code_app FROM postgres;
GRANT ALL ON TABLE code_app TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE code_app TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: param_app; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE param_app FROM PUBLIC;
REVOKE ALL ON TABLE param_app FROM postgres;
GRANT ALL ON TABLE param_app TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE param_app TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: param_app_param_app_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE param_app_param_app_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE param_app_param_app_id_seq FROM postgres;
GRANT ALL ON SEQUENCE param_app_param_app_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE param_app_param_app_id_seq TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: help__tbl; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE help__tbl FROM PUBLIC;
REVOKE ALL ON TABLE help__tbl FROM postgres;
GRANT ALL ON TABLE help__tbl TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE help__tbl TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: help__tbl_help_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE help__tbl_help_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE help__tbl_help_id_seq FROM postgres;
GRANT ALL ON SEQUENCE help__tbl_help_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE help__tbl_help_id_seq TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: help_target; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE help_target FROM PUBLIC;
REVOKE ALL ON TABLE help_target FROM postgres;
GRANT ALL ON TABLE help_target TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE help_target TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: help_target_help_target_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE help_target_help_target_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE help_target_help_target_id_seq FROM postgres;
GRANT ALL ON SEQUENCE help_target_help_target_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE help_target_help_target_id_seq TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: note__tbl; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE note__tbl FROM PUBLIC;
REVOKE ALL ON TABLE note__tbl FROM postgres;
GRANT ALL ON TABLE note__tbl TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE note__tbl TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: note__tbl_note_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE note__tbl_note_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE note__tbl_note_id_seq FROM postgres;
GRANT ALL ON SEQUENCE note__tbl_note_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE note__tbl_note_id_seq TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: number__tbl; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE number__tbl FROM PUBLIC;
REVOKE ALL ON TABLE number__tbl FROM postgres;
GRANT ALL ON TABLE number__tbl TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE number__tbl TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: sys_user; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE sys_user FROM PUBLIC;
REVOKE ALL ON TABLE sys_user FROM postgres;
GRANT ALL ON TABLE sys_user TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sys_user TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: sys_user_sys_user_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE sys_user_sys_user_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE sys_user_sys_user_id_seq FROM postgres;
GRANT ALL ON SEQUENCE sys_user_sys_user_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE sys_user_sys_user_id_seq TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: param__tbl; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE param__tbl FROM PUBLIC;
REVOKE ALL ON TABLE param__tbl FROM postgres;
GRANT ALL ON TABLE param__tbl TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE param__tbl TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: param__tbl_param_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE param__tbl_param_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE param__tbl_param_id_seq FROM postgres;
GRANT ALL ON SEQUENCE param__tbl_param_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE param__tbl_param_id_seq TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: param_user; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE param_user FROM PUBLIC;
REVOKE ALL ON TABLE param_user FROM postgres;
GRANT ALL ON TABLE param_user TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE param_user TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: param_user_param_user_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE param_user_param_user_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE param_user_param_user_id_seq FROM postgres;
GRANT ALL ON SEQUENCE param_user_param_user_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE param_user_param_user_id_seq TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: queue__tbl; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE queue__tbl FROM PUBLIC;
REVOKE ALL ON TABLE queue__tbl FROM postgres;
GRANT ALL ON TABLE queue__tbl TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE queue__tbl TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: queue__tbl_queue_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE queue__tbl_queue_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE queue__tbl_queue_id_seq FROM postgres;
GRANT ALL ON SEQUENCE queue__tbl_queue_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE queue__tbl_queue_id_seq TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: job__tbl; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE job__tbl FROM PUBLIC;
REVOKE ALL ON TABLE job__tbl FROM postgres;
GRANT ALL ON TABLE job__tbl TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE job__tbl TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: job_doc; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE job_doc FROM PUBLIC;
REVOKE ALL ON TABLE job_doc FROM postgres;
GRANT ALL ON TABLE job_doc TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE job_doc TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: job_doc_job_doc_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE job_doc_job_doc_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE job_doc_job_doc_id_seq FROM postgres;
GRANT ALL ON SEQUENCE job_doc_job_doc_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE job_doc_job_doc_id_seq TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: job_email; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE job_email FROM PUBLIC;
REVOKE ALL ON TABLE job_email FROM postgres;
GRANT ALL ON TABLE job_email TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE job_email TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: job_email_job_email_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE job_email_job_email_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE job_email_job_email_id_seq FROM postgres;
GRANT ALL ON SEQUENCE job_email_job_email_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE job_email_job_email_id_seq TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: job_note; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE job_note FROM PUBLIC;
REVOKE ALL ON TABLE job_note FROM postgres;
GRANT ALL ON TABLE job_note TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE job_note TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: job_note_job_note_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE job_note_job_note_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE job_note_job_note_id_seq FROM postgres;
GRANT ALL ON SEQUENCE job_note_job_note_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE job_note_job_note_id_seq TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: job_queue; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE job_queue FROM PUBLIC;
REVOKE ALL ON TABLE job_queue FROM postgres;
GRANT ALL ON TABLE job_queue TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE job_queue TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: job_queue_job_queue_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE job_queue_job_queue_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE job_queue_job_queue_id_seq FROM postgres;
GRANT ALL ON SEQUENCE job_queue_job_queue_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE job_queue_job_queue_id_seq TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: job__tbl_job_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE job__tbl_job_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE job__tbl_job_id_seq FROM postgres;
GRANT ALL ON SEQUENCE job__tbl_job_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE job__tbl_job_id_seq TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: job_sms; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE job_sms FROM PUBLIC;
REVOKE ALL ON TABLE job_sms FROM postgres;
GRANT ALL ON TABLE job_sms TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE job_sms TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: job_sms_job_sms_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE job_sms_job_sms_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE job_sms_job_sms_id_seq FROM postgres;
GRANT ALL ON SEQUENCE job_sms_job_sms_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE job_sms_job_sms_id_seq TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: sys_func; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE sys_func FROM PUBLIC;
REVOKE ALL ON TABLE sys_func FROM postgres;
GRANT ALL ON TABLE sys_func TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sys_func TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: sys_func_sys_func_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE sys_func_sys_func_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE sys_func_sys_func_id_seq FROM postgres;
GRANT ALL ON SEQUENCE sys_func_sys_func_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE sys_func_sys_func_id_seq TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: menu__tbl; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE menu__tbl FROM PUBLIC;
REVOKE ALL ON TABLE menu__tbl FROM postgres;
GRANT ALL ON TABLE menu__tbl TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE menu__tbl TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: menu__tbl_menu_id_auto_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE menu__tbl_menu_id_auto_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE menu__tbl_menu_id_auto_seq FROM postgres;
GRANT ALL ON SEQUENCE menu__tbl_menu_id_auto_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE menu__tbl_menu_id_auto_seq TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: sys_user_func; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE sys_user_func FROM PUBLIC;
REVOKE ALL ON TABLE sys_user_func FROM postgres;
GRANT ALL ON TABLE sys_user_func TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sys_user_func TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: sys_user_func_sys_user_func_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE sys_user_func_sys_user_func_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE sys_user_func_sys_user_func_id_seq FROM postgres;
GRANT ALL ON SEQUENCE sys_user_func_sys_user_func_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE sys_user_func_sys_user_func_id_seq TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: sys_user_role; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE sys_user_role FROM PUBLIC;
REVOKE ALL ON TABLE sys_user_role FROM postgres;
GRANT ALL ON TABLE sys_user_role TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sys_user_role TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: sys_user_role_sys_user_role_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE sys_user_role_sys_user_role_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE sys_user_role_sys_user_role_id_seq FROM postgres;
GRANT ALL ON SEQUENCE sys_user_role_sys_user_role_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE sys_user_role_sys_user_role_id_seq TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: sys_role; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE sys_role FROM PUBLIC;
REVOKE ALL ON TABLE sys_role FROM postgres;
GRANT ALL ON TABLE sys_role TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sys_role TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: sys_role_sys_role_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE sys_role_sys_role_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE sys_role_sys_role_id_seq FROM postgres;
GRANT ALL ON SEQUENCE sys_role_sys_role_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE sys_role_sys_role_id_seq TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: sys_menu_role; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE sys_menu_role FROM PUBLIC;
REVOKE ALL ON TABLE sys_menu_role FROM postgres;
GRANT ALL ON TABLE sys_menu_role TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sys_menu_role TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: sys_menu_role_sys_menu_role_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE sys_menu_role_sys_menu_role_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE sys_menu_role_sys_menu_role_id_seq FROM postgres;
GRANT ALL ON SEQUENCE sys_menu_role_sys_menu_role_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE sys_menu_role_sys_menu_role_id_seq TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: txt__tbl; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE txt__tbl FROM PUBLIC;
REVOKE ALL ON TABLE txt__tbl FROM postgres;
GRANT ALL ON TABLE txt__tbl TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE txt__tbl TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: txt__tbl_txt_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE txt__tbl_txt_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE txt__tbl_txt_id_seq FROM postgres;
GRANT ALL ON SEQUENCE txt__tbl_txt_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE txt__tbl_txt_id_seq TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: code_sys_base; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE code_sys_base FROM PUBLIC;
REVOKE ALL ON TABLE code_sys_base FROM postgres;
GRANT ALL ON TABLE code_sys_base TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE code_sys_base TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: code2_sys_base_code2_sys_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE code2_sys_base_code2_sys_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE code2_sys_base_code2_sys_id_seq FROM postgres;
GRANT ALL ON SEQUENCE code2_sys_base_code2_sys_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE code2_sys_base_code2_sys_id_seq TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: code2_sys_base; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE code2_sys_base FROM PUBLIC;
REVOKE ALL ON TABLE code2_sys_base FROM postgres;
GRANT ALL ON TABLE code2_sys_base TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE code2_sys_base TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: code2_country_state; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE code2_country_state FROM PUBLIC;
REVOKE ALL ON TABLE code2_country_state FROM postgres;
GRANT ALL ON TABLE code2_country_state TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE code2_country_state TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: code2_param_app_attrib; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE code2_param_app_attrib FROM PUBLIC;
REVOKE ALL ON TABLE code2_param_app_attrib FROM postgres;
GRANT ALL ON TABLE code2_param_app_attrib TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE code2_param_app_attrib TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: code2_sys; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE code2_sys FROM PUBLIC;
REVOKE ALL ON TABLE code2_sys FROM postgres;
GRANT ALL ON TABLE code2_sys TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE code2_sys TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: code2_sys_code2_sys_h_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE code2_sys_code2_sys_h_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE code2_sys_code2_sys_h_id_seq FROM postgres;
GRANT ALL ON SEQUENCE code2_sys_code2_sys_h_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE code2_sys_code2_sys_h_id_seq TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: code2_param_user_attrib; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE code2_param_user_attrib FROM PUBLIC;
REVOKE ALL ON TABLE code2_param_user_attrib FROM postgres;
GRANT ALL ON TABLE code2_param_user_attrib TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE code2_param_user_attrib TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: code2_param_sys_attrib; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE code2_param_sys_attrib FROM PUBLIC;
REVOKE ALL ON TABLE code2_param_sys_attrib FROM postgres;
GRANT ALL ON TABLE code2_param_sys_attrib TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE code2_param_sys_attrib TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: code_ac; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE code_ac FROM PUBLIC;
REVOKE ALL ON TABLE code_ac FROM postgres;
GRANT ALL ON TABLE code_ac TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE code_ac TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: code_ac1; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE code_ac1 FROM PUBLIC;
REVOKE ALL ON TABLE code_ac1 FROM postgres;
GRANT ALL ON TABLE code_ac1 TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE code_ac1 TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: code_ahc; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE code_ahc FROM PUBLIC;
REVOKE ALL ON TABLE code_ahc FROM postgres;
GRANT ALL ON TABLE code_ahc TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE code_ahc TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: code_country; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE code_country FROM PUBLIC;
REVOKE ALL ON TABLE code_country FROM postgres;
GRANT ALL ON TABLE code_country TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE code_country TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: code_doc_scope; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE code_doc_scope FROM PUBLIC;
REVOKE ALL ON TABLE code_doc_scope FROM postgres;
GRANT ALL ON TABLE code_doc_scope TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE code_doc_scope TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: code_param_app_process; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE code_param_app_process FROM PUBLIC;
REVOKE ALL ON TABLE code_param_app_process FROM postgres;
GRANT ALL ON TABLE code_param_app_process TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE code_param_app_process TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: code_sys; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE code_sys FROM PUBLIC;
REVOKE ALL ON TABLE code_sys FROM postgres;
GRANT ALL ON TABLE code_sys TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE code_sys TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: code_sys_code_sys_h_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE code_sys_code_sys_h_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE code_sys_code_sys_h_id_seq FROM postgres;
GRANT ALL ON SEQUENCE code_sys_code_sys_h_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE code_sys_code_sys_h_id_seq TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: code_note_scope; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE code_note_scope FROM PUBLIC;
REVOKE ALL ON TABLE code_note_scope FROM postgres;
GRANT ALL ON TABLE code_note_scope TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE code_note_scope TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: code_note_type; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE code_note_type FROM PUBLIC;
REVOKE ALL ON TABLE code_note_type FROM postgres;
GRANT ALL ON TABLE code_note_type TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE code_note_type TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: code_param_type; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE code_param_type FROM PUBLIC;
REVOKE ALL ON TABLE code_param_type FROM postgres;
GRANT ALL ON TABLE code_param_type TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE code_param_type TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: code_param_user_process; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE code_param_user_process FROM PUBLIC;
REVOKE ALL ON TABLE code_param_user_process FROM postgres;
GRANT ALL ON TABLE code_param_user_process TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE code_param_user_process TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: code_job_action; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE code_job_action FROM PUBLIC;
REVOKE ALL ON TABLE code_job_action FROM postgres;
GRANT ALL ON TABLE code_job_action TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE code_job_action TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: code_job_source; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE code_job_source FROM PUBLIC;
REVOKE ALL ON TABLE code_job_source FROM postgres;
GRANT ALL ON TABLE code_job_source TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE code_job_source TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: code_txt_type; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE code_txt_type FROM PUBLIC;
REVOKE ALL ON TABLE code_txt_type FROM postgres;
GRANT ALL ON TABLE code_txt_type TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE code_txt_type TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: code_sys_base_code_sys_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE code_sys_base_code_sys_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE code_sys_base_code_sys_id_seq FROM postgres;
GRANT ALL ON SEQUENCE code_sys_base_code_sys_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE code_sys_base_code_sys_id_seq TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: code_version_sts; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE code_version_sts FROM PUBLIC;
REVOKE ALL ON TABLE code_version_sts FROM postgres;
GRANT ALL ON TABLE code_version_sts TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE code_version_sts TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: code_param_sys_process; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE code_param_sys_process FROM PUBLIC;
REVOKE ALL ON TABLE code_param_sys_process FROM postgres;
GRANT ALL ON TABLE code_param_sys_process TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE code_param_sys_process TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: version__tbl; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE version__tbl FROM PUBLIC;
REVOKE ALL ON TABLE version__tbl FROM postgres;
GRANT ALL ON TABLE version__tbl TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE version__tbl TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: v_audit_detail; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_audit_detail FROM PUBLIC;
REVOKE ALL ON TABLE v_audit_detail FROM postgres;
GRANT ALL ON TABLE v_audit_detail TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_audit_detail TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: v_cust_user_nostar; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_cust_user_nostar FROM PUBLIC;
REVOKE ALL ON TABLE v_cust_user_nostar FROM postgres;
GRANT ALL ON TABLE v_cust_user_nostar TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_cust_user_nostar TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: v_cust_menu_role_selection; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_cust_menu_role_selection FROM PUBLIC;
REVOKE ALL ON TABLE v_cust_menu_role_selection FROM postgres;
GRANT ALL ON TABLE v_cust_menu_role_selection TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_cust_menu_role_selection TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: v_doc_ext; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_doc_ext FROM PUBLIC;
REVOKE ALL ON TABLE v_doc_ext FROM postgres;
GRANT ALL ON TABLE v_doc_ext TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_doc_ext TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: v_doc_filename; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_doc_filename FROM PUBLIC;
REVOKE ALL ON TABLE v_doc_filename FROM postgres;
GRANT ALL ON TABLE v_doc_filename TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_doc_filename TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: v_doc; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_doc FROM PUBLIC;
REVOKE ALL ON TABLE v_doc FROM postgres;
GRANT ALL ON TABLE v_doc TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_doc TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: v_param_app; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_param_app FROM PUBLIC;
REVOKE ALL ON TABLE v_param_app FROM postgres;
GRANT ALL ON TABLE v_param_app TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_param_app TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: param_sys; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE param_sys FROM PUBLIC;
REVOKE ALL ON TABLE param_sys FROM postgres;
GRANT ALL ON TABLE param_sys TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE param_sys TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: v_param_cur; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_param_cur FROM PUBLIC;
REVOKE ALL ON TABLE v_param_cur FROM postgres;
GRANT ALL ON TABLE v_param_cur TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_param_cur TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: v_app_info; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_app_info FROM PUBLIC;
REVOKE ALL ON TABLE v_app_info FROM postgres;
GRANT ALL ON TABLE v_app_info TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_app_info TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: v_month; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_month FROM PUBLIC;
REVOKE ALL ON TABLE v_month FROM postgres;
GRANT ALL ON TABLE v_month TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_month TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: v_my_roles; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_my_roles FROM PUBLIC;
REVOKE ALL ON TABLE v_my_roles FROM postgres;
GRANT ALL ON TABLE v_my_roles TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_my_roles TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: v_my_user; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_my_user FROM PUBLIC;
REVOKE ALL ON TABLE v_my_user FROM postgres;
GRANT ALL ON TABLE v_my_user TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_my_user TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: v_note_ext; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_note_ext FROM PUBLIC;
REVOKE ALL ON TABLE v_note_ext FROM postgres;
GRANT ALL ON TABLE v_note_ext TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_note_ext TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: v_note; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_note FROM PUBLIC;
REVOKE ALL ON TABLE v_note FROM postgres;
GRANT ALL ON TABLE v_note TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_note TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: v_param; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_param FROM PUBLIC;
REVOKE ALL ON TABLE v_param FROM postgres;
GRANT ALL ON TABLE v_param TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_param TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: v_param_user; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_param_user FROM PUBLIC;
REVOKE ALL ON TABLE v_param_user FROM postgres;
GRANT ALL ON TABLE v_param_user TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_param_user TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: v_sys_menu_role_selection; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_sys_menu_role_selection FROM PUBLIC;
REVOKE ALL ON TABLE v_sys_menu_role_selection FROM postgres;
GRANT ALL ON TABLE v_sys_menu_role_selection TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_sys_menu_role_selection TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: version__tbl_version_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE version__tbl_version_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE version__tbl_version_id_seq FROM postgres;
GRANT ALL ON SEQUENCE version__tbl_version_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE version__tbl_version_id_seq TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: v_param_sys; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_param_sys FROM PUBLIC;
REVOKE ALL ON TABLE v_param_sys FROM postgres;
GRANT ALL ON TABLE v_param_sys TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_param_sys TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: v_year; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_year FROM PUBLIC;
REVOKE ALL ON TABLE v_year FROM postgres;
GRANT ALL ON TABLE v_year TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_year TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: param_sys_param_sys_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE param_sys_param_sys_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE param_sys_param_sys_id_seq FROM postgres;
GRANT ALL ON SEQUENCE param_sys_param_sys_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE param_sys_param_sys_id_seq TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: jsharmony; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA jsharmony REVOKE ALL ON SEQUENCES  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA jsharmony REVOKE ALL ON SEQUENCES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA jsharmony GRANT SELECT,UPDATE ON SEQUENCES  TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: jsharmony; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA jsharmony REVOKE ALL ON FUNCTIONS  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA jsharmony REVOKE ALL ON FUNCTIONS  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA jsharmony GRANT ALL ON FUNCTIONS  TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA jsharmony GRANT ALL ON FUNCTIONS  TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: jsharmony; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA jsharmony REVOKE ALL ON TABLES  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA jsharmony REVOKE ALL ON TABLES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA jsharmony GRANT SELECT,INSERT,DELETE,UPDATE ON TABLES  TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;



--
--

