--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.5
-- Dumped by pg_dump version 9.5.1

-- Started on 2017-10-10 11:14:01

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 8 (class 2615 OID 45168)
-- Name: jsharmony; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA jsharmony;


ALTER SCHEMA jsharmony OWNER TO postgres;

SET search_path = jsharmony, pg_catalog;

--
-- TOC entry 717 (class 1247 OID 45171)
-- Name: toaudit; Type: TYPE; Schema: jsharmony; Owner: postgres
--

CREATE TYPE toaudit AS (
  op text,
  table_name text,
  c_id bigint,
  e_id bigint,
  ref_name text,
  ref_id bigint,
  subj text
);


ALTER TYPE toaudit OWNER TO postgres;

--
-- TOC entry 348 (class 1255 OID 45172)
-- Name: audit(toaudit, bigint, bigint, character varying, text); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION audit(toa toaudit, INOUT par_aud_seq bigint, par_table_id bigint, par_column_name character varying DEFAULT NULL::character varying, par_column_val text DEFAULT NULL::text) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
    DECLARE
      curdttm     timestamp default jsharmony.mynow();
      myuser      text default jsharmony.mycuser();
      my_c_id     bigint default null;
      my_e_id     bigint default null;
      my_ref_name text default null;
      my_ref_id   bigint default null;
      my_subj     text default null;
      d_aud_seq   bigint default null;
    BEGIN
        IF par_aud_seq is null THEN

          if (toa.op = 'DELETE') then
    select aud_seq,
           C_ID,
           E_ID,
           REF_NAME,
           REF_ID,
           SUBJ
      into d_aud_seq,
           my_C_ID,
           my_E_ID,
           my_REF_NAME,
           my_REF_ID,
           my_SUBJ
      from jsharmony.aud_h
                 where TABLE_NAME = toa.table_name
       and TABLE_ID = par_table_id
       and AUD_OP = 'I'
                 order by AUD_SEQ desc
     fetch first 1 rows only;
          ELSE
            my_c_id = toa.c_id;
            my_e_id = toa.e_id;
            my_ref_name = toa.ref_name;
            my_ref_id = toa.ref_id;
            my_subj = toa.subj;
          END if;
        
          insert into jsharmony.aud_h 
                            (table_name, table_id, aud_op, aud_u, aud_tstmp, c_id, e_id, ref_name, ref_id, subj)
                     values (toa.table_name,
                             par_table_id,
                             case toa.op when 'INSERT' then 'I'
                                         when 'UPDATE' then 'U'
                                         when 'DELETE' then 'D'
                                         else NULL end,
                             myuser,
                             curdttm,
                             my_c_id,
                             my_e_id,
                             my_ref_name,
                             my_ref_id,
                             my_subj)
                     returning aud_seq into par_aud_seq; 
        END IF;
        IF toa.op in ('UPDATE','DELETE') THEN
          insert into jsharmony.aud_d 
                            (aud_seq, column_name, column_val)
                     values (par_aud_seq, upper(par_column_name), par_column_val);
        END IF;           
    END;
$$;


ALTER FUNCTION jsharmony.audit(toa toaudit, INOUT par_aud_seq bigint, par_table_id bigint, par_column_name character varying, par_column_val text) OWNER TO postgres;

--
-- TOC entry 344 (class 1255 OID 45173)
-- Name: audit_base(toaudit, bigint, bigint, character varying, text); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION audit_base(toa toaudit, INOUT par_aud_seq bigint, par_table_id bigint, par_column_name character varying DEFAULT NULL::character varying, par_column_val text DEFAULT NULL::text) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
    DECLARE
      curdttm     timestamp default jsharmony.mynow();
      myuser      text default jsharmony.mycuser();
      my_ref_name text default null;
      my_ref_id   bigint default null;
      my_subj     text default null;
      d_aud_seq   bigint default null;
    BEGIN
        IF par_aud_seq is null THEN

          if (toa.op = 'DELETE') then
    select aud_seq,
           REF_NAME,
           REF_ID,
           SUBJ
      into d_aud_seq,
           my_REF_NAME,
           my_REF_ID,
           my_SUBJ
      from jsharmony.AUD_H
                 where TABLE_NAME = toa.table_name
       and TABLE_ID = par_table_id
       and AUD_OP = 'I'
                 order by AUD_SEQ desc
     fetch first 1 rows only;
          ELSE
            my_ref_name = toa.ref_name;
            my_ref_id = toa.ref_id;
            my_subj = toa.subj;
          END if;
        
          insert into jsharmony.AUD_H 
                            (table_name, table_id, aud_op, aud_u, aud_tstmp, ref_name, ref_id, subj)
                     values (toa.table_name,
                             par_table_id,
                             case toa.op when 'INSERT' then 'I'
                                         when 'UPDATE' then 'U'
                                         when 'DELETE' then 'D'
                                         else NULL end,
                             myuser,
                             curdttm,
                             my_ref_name,
                             my_ref_id,
                             my_subj)
                     returning aud_seq into par_aud_seq; 
        END IF;
        IF toa.op in ('UPDATE','DELETE') THEN
          insert into jsharmony.aud_d 
                             (aud_seq, column_name, column_val)
                     values (par_aud_seq, upper(par_column_name), par_column_val);
        END IF;           
    END;
$$;


ALTER FUNCTION jsharmony.audit_base(toa toaudit, INOUT par_aud_seq bigint, par_table_id bigint, par_column_name character varying, par_column_val text) OWNER TO postgres;

--
-- TOC entry 315 (class 1255 OID 45174)
-- Name: audit_info(timestamp without time zone, character varying, timestamp without time zone, character varying); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION audit_info(timestamp without time zone, character varying, timestamp without time zone, character varying) RETURNS character varying
    LANGUAGE sql
    AS $_$select 'INFO'||chr(13)||chr(10)|| 
               '     Entered:  '||jsharmony.mymmddyyhhmi($1)||'  '||jsharmony.mycuser_fmt($2)||
         chr(13)||chr(10)|| 
               'Last Updated:  '||jsharmony.mymmddyyhhmi($3)||'  '||jsharmony.mycuser_fmt($4);$_$;


ALTER FUNCTION jsharmony.audit_info(timestamp without time zone, character varying, timestamp without time zone, character varying) OWNER TO postgres;

--
-- TOC entry 306 (class 1255 OID 45175)
-- Name: check_code(character varying, character varying); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION check_code(in_tblname character varying, in_codeval character varying) RETURNS bigint
    LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER COST 10
    AS $$
DECLARE
    rslt     bigint;
    runmesql text;
BEGIN

  rslt := jsharmony.check_code_p(in_tblname, in_codeval);

  RETURN rslt;

EXCEPTION WHEN OTHERS THEN

  RETURN -1;

END;
$$;


ALTER FUNCTION jsharmony.check_code(in_tblname character varying, in_codeval character varying) OWNER TO postgres;

--
-- TOC entry 305 (class 1255 OID 45176)
-- Name: check_code2(character varying, character varying, character varying); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION check_code2(in_tblname character varying, in_codeval1 character varying, in_codeval2 character varying) RETURNS bigint
    LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER COST 10
    AS $$
DECLARE
    rslt     bigint;
    runmesql text;
BEGIN

  rslt := jsharmony.check_code2_p(in_tblname, in_codeval1, in_codeval2);

  RETURN rslt;

EXCEPTION WHEN OTHERS THEN

  RETURN -1;

END;
$$;


ALTER FUNCTION jsharmony.check_code2(in_tblname character varying, in_codeval1 character varying, in_codeval2 character varying) OWNER TO postgres;

--
-- TOC entry 342 (class 1255 OID 45177)
-- Name: check_code2_p(character varying, character varying, character varying); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION check_code2_p(in_tblname character varying, in_codeval1 character varying, in_codeval2 character varying) RETURNS bigint
    LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER COST 10
    AS $_$
DECLARE
    rslt     bigint;
    runmesql text;
BEGIN

  rslt := 0;

  select 'select count(*) from ' || schemaname || '.' || tablename ||
           ' where codeval1 = $1 and codeval2 = $2;'
    into runmesql
    from pg_tables
   where tablename = lower(in_tblname) 
   order by (case schemaname when 'jsharmony' then 1 else 2 end), schemaname
   limit 1;

  EXECUTE runmesql INTO rslt USING in_codeval1, in_codeval2;
  
  RETURN rslt;
END;
$_$;


ALTER FUNCTION jsharmony.check_code2_p(in_tblname character varying, in_codeval1 character varying, in_codeval2 character varying) OWNER TO postgres;

--
-- TOC entry 334 (class 1255 OID 45178)
-- Name: check_code_p(character varying, character varying); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION check_code_p(in_tblname character varying, in_codeval character varying) RETURNS bigint
    LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER COST 10
    AS $_$
DECLARE
    rslt     bigint;
    runmesql text;
BEGIN

  rslt := 0;

  select 'select count(*) from ' || schemaname || '.' || tablename || ' where codeval = $1 ;'
    into runmesql
    from pg_tables
   where tablename = lower(in_tblname) 
   order by (case schemaname when 'jsharmony' then 1 else 2 end), schemaname
   limit 1;

  EXECUTE runmesql INTO rslt USING in_codeval;
  
  RETURN rslt;
END;
$_$;


ALTER FUNCTION jsharmony.check_code_p(in_tblname character varying, in_codeval character varying) OWNER TO postgres;

--
-- TOC entry 336 (class 1255 OID 45179)
-- Name: check_foreign(character varying, bigint); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION check_foreign(in_tblname character varying, in_tblid bigint) RETURNS bigint
    LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER COST 10
    AS $$
DECLARE
    rslt     bigint;
    runmesql text;
BEGIN

  rslt := jsharmony.check_foreign_p(in_tblname, in_tblid);

  RETURN rslt;

EXCEPTION WHEN OTHERS THEN

  RETURN -1;

END;
$$;


ALTER FUNCTION jsharmony.check_foreign(in_tblname character varying, in_tblid bigint) OWNER TO postgres;

--
-- TOC entry 337 (class 1255 OID 45180)
-- Name: check_foreign_p(character varying, bigint); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION check_foreign_p(in_tblname character varying, in_tblid bigint) RETURNS bigint
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
   order by (case schemaname when 'jsharmony' then 1 else 2 end), schemaname
   limit 1;

  EXECUTE runmesql INTO rslt USING in_tblid;
  
  RETURN rslt;
END;
$_$;


ALTER FUNCTION jsharmony.check_foreign_p(in_tblname character varying, in_tblid bigint) OWNER TO postgres;

--
-- TOC entry 361 (class 1255 OID 45181)
-- Name: check_pp(character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION check_pp(in_table character varying, in_process character varying, in_attrib character varying, in_val character varying) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE 
  C bigint = 0;
  ppd_type VARCHAR(8) = NULL;
  codename VARCHAR(16);
  ppd_gpp boolean;
  ppd_ppp boolean;
  ppd_xpp boolean;
BEGIN

  SELECT ppd.ppd_type,
         ppd.codename,
         ppd.ppd_gpp,
         ppd.ppd_ppp,
         ppd.ppd_xpp
    INTO ppd_type,
         codename,
         ppd_gpp,
         ppd_ppp,
         ppd_xpp
    FROM jsharmony.PPD
   WHERE ppd.ppd_process = in_process
     AND ppd.ppd_attrib = in_attrib;      

  IF ppd_type IS NULL THEN
    RETURN 'Process parameter '||in_process||'.'||in_attrib||' is not defined in PPD';
  END IF;  
  
  IF upper(in_table) NOT IN ('GPP','PPP','XPP') THEN
    RETURN 'Table '||upper(in_table) || ' is not defined';
  END IF;  
 
  IF upper(in_table)='GPP' AND ppd_gpp=false THEN
    RETURN 'Process parameter '||in_process||'.'||in_attrib||' is not assigned to '||upper(in_table);
  ELSIF upper(in_table)='PPP' AND ppd_ppp=false THEN
    RETURN 'Process parameter '||in_process||'.'||in_attrib||' is not assigned to '||upper(in_table);
  ELSIF upper(in_table)='XPP' AND ppd_xpp=false THEN
    RETURN 'Process parameter '||in_process||'.'||in_attrib||' is not assigned to '||upper(in_table);
  END IF;  

  IF coalesce(in_val,'') = '' THEN
    RETURN 'Value has to be present';
  END IF;  

  IF ppd_type='N' AND not jsharmony.myISNUMERIC(in_val) THEN
    RETURN 'Value '||in_val||' is not numeric';
  END IF;  

  IF coalesce(codename,'') != '' THEN

    select count(*)
      into c
      from jsharmony.ucod
     where codename = codename
       and codeval = in_val; 
       
    IF c=0 THEN
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


ALTER FUNCTION jsharmony.check_pp(in_table character varying, in_process character varying, in_attrib character varying, in_val character varying) OWNER TO postgres;

--
-- TOC entry 356 (class 1255 OID 45182)
-- Name: cpe_iud(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION cpe_iud() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
      curdttm   timestamp default jsharmony.mynow();
      myuser    text default jsharmony.mycuser();
      aud_seq   bigint default NULL;
      my_id     bigint default case TG_OP when 'DELETE' then OLD.PE_ID else NEW.PE_ID end;
      newpw     text default NULL;
      hash      bytea default NULL;
      my_toa    jsharmony.toaudit;
    BEGIN

        /**********************************/
        /* INITIALIZE                     */ 
        /**********************************/

        my_toa.op := TG_OP;
        my_toa.table_name := upper(TG_TABLE_NAME::text);
        my_toa.c_id := case when TG_OP = 'DELETE' then NULL else NEW.c_id end;
        my_toa.e_id := NULL;
        my_toa.ref_name := NULL;
        my_toa.ref_id := NULL;
        my_toa.subj := case when TG_OP = 'DELETE' then NULL else coalesce(NEW.PE_LNAME,'')||', '||coalesce(NEW.PE_FNAME,'') end;
         

        /**********************************/
        /* PERFORM CHECKS                 */ 
        /**********************************/

        IF TG_OP = 'UPDATE'
           and
           jsharmony.nonequal(NEW.pe_id, OLD.pe_id) THEN
          RAISE EXCEPTION  'Application Error - ID cannot be updated.';
        END IF;

        IF TG_OP = 'UPDATE'
           and
           jsharmony.nonequal(NEW.c_id, OLD.c_id) THEN
          RAISE EXCEPTION  'Application Error - Customer ID cannot be updated.';
        END IF;

        IF TG_OP = 'INSERT' or TG_OP = 'UPDATE' THEN
    IF jsharmony.nonequal(NEW.PE_PW1, NEW.PE_PW2) THEN
            RAISE EXCEPTION  'Application Error - New Password and Repeat Password are different.';
          ELSIF (TG_OP='INSERT' or NEW.pe_pw1 is not null)  AND length(btrim(NEW.pe_pw1::text)) < 6  THEN
            RAISE EXCEPTION  'Application Error - Password length - at least 6 characters required.';
          END IF;            
        END IF;


        IF (TG_OP='INSERT' 
            OR 
            TG_OP='UPDATE' AND jsharmony.nonequal(NEW.C_ID, OLD.C_ID)) THEN
          IF jsharmony.check_foreign('C', NEW.C_ID) <= 0THEN
            RAISE EXCEPTION  'Table C does not contain record % .', NEW.C_ID::text ;
    END IF;
  END IF;   


        /**********************************/
        /* AUDIT TRAIL                    */ 
        /**********************************/

        IF TG_OP = 'INSERT' THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id);  
        END IF;


        IF (case when TG_OP = 'DELETE' then OLD.PE_ID is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.PE_ID, OLD.PE_ID) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'PE_ID', OLD.PE_ID::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.C_ID is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.C_ID, OLD.C_ID) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'C_ID', OLD.C_ID::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.PE_STS is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.PE_STS, OLD.PE_STS) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'PE_STS', OLD.PE_STS::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.PE_FNAME is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.PE_FNAME, OLD.PE_FNAME) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'PE_FNAME', OLD.PE_FNAME::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.PE_MNAME is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.PE_MNAME, OLD.PE_MNAME) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'PE_MNAME', OLD.PE_MNAME::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.PE_LNAME is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.PE_LNAME, OLD.PE_LNAME) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'PE_LNAME', OLD.PE_LNAME::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.PE_JTITLE is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.PE_JTITLE, OLD.PE_JTITLE) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'PE_JTITLE', OLD.PE_JTITLE::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.PE_BPHONE is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.PE_BPHONE, OLD.PE_BPHONE) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'PE_BPHONE', OLD.PE_BPHONE::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.PE_CPHONE is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.PE_CPHONE, OLD.PE_CPHONE) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'PE_CPHONE', OLD.PE_CPHONE::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.PE_EMAIL is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.PE_EMAIL, OLD.PE_EMAIL) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'PE_EMAIL', OLD.PE_EMAIL::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.PE_LL_TSTMP is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.PE_LL_TSTMP, OLD.PE_LL_TSTMP) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'PE_LL_TSTMP', OLD.PE_LL_TSTMP::text);  
        END IF;

      
        IF TG_OP = 'UPDATE' and coalesce(NEW.pe_pw1,'') <> '' THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'PE_PW','*');  
        END IF;


        /**********************************/
        /* UPDATES AND OTHER TABLES       */ 
        /**********************************/

        IF TG_OP in ('INSERT', 'UPDATE') THEN
        
          newpw = btrim(NEW.pe_pw1);
          if newpw is not null then
            hash = myhash('C', NEW.pe_id, newpw);
            if (hash is null) then
              RAISE EXCEPTION  'Application Error - Missing or Incorrect Password.';
            end if;
      NEW.pe_hash := hash;
      NEW.pe_pw1 = NULL;
      NEW.pe_pw2 = NULL;
          else
            hash = NULL;
          end if;
            
          IF TG_OP = 'INSERT' THEN
            NEW.pe_stsdt := curdttm;
      NEW.pe_etstmp := curdttm;
      NEW.pe_eu := myuser;
      NEW.pe_mtstmp := curdttm;
      NEW.pe_mu := myuser;
          ELSIF TG_OP = 'UPDATE' THEN
            IF aud_seq is not NULL THEN
              if jsharmony.nonequal(OLD.PE_STS, NEW.PE_STS) then
                NEW.pe_stsdt := curdttm;
              end if;
        NEW.pe_mtstmp := curdttm;
        NEW.pe_mu := myuser;
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


ALTER FUNCTION jsharmony.cpe_iud() OWNER TO postgres;

--
-- TOC entry 357 (class 1255 OID 45183)
-- Name: cper_iud(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION cper_iud() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
    DECLARE
      curdttm    timestamp default jsharmony.mynow();
      myuser     text default jsharmony.mycuser();
      aud_seq    bigint default NULL;
      my_id      bigint default case TG_OP when 'DELETE' then OLD.cper_id else NEW.cper_id end;
      my_toa     jsharmony.toaudit;

      sqlcmd     text;
      getcid     text;
      wk_c_id    bigint;
      wk_pe_id   bigint;
      
    BEGIN

        /**********************************/
        /* INITIALIZE                     */ 
        /**********************************/

        select pp_val
          into getcid
          from jsharmony.v_pp 
         where pp_process = 'SQL'
           and pp_attrib = 'GETCID'; 
        wk_pe_id := case TG_OP when 'DELETE' then OLD.pe_id else NEW.pe_id end;  
        sqlcmd := 'select '||getcid||'(''CPE'',$1);';
        EXECUTE sqlcmd INTO wk_c_id USING wk_pe_id;


        my_toa.op := TG_OP;
        my_toa.table_name := upper(TG_TABLE_NAME::text);
        my_toa.c_id := wk_c_id;
        my_toa.e_id := NULL;
        my_toa.ref_name := NULL;
        my_toa.ref_id := NULL;
        my_toa.subj := case when TG_OP = 'DELETE' then NULL else (select coalesce(PE_LNAME,'')||', '||coalesce(PE_FNAME,'') 
                                                                    from jsharmony.CPE 
                                                                   where pe_id = NEW.PE_ID) end;
         

        /**********************************/
        /* PERFORM CHECKS                 */ 
        /**********************************/

        IF TG_OP = 'UPDATE'
           and
           jsharmony.nonequal(NEW.cper_id, OLD.cper_id) THEN
          RAISE EXCEPTION  'Application Error - ID cannot be updated.';
        END IF;

        IF TG_OP = 'UPDATE'
           and
           jsharmony.nonequal(NEW.pe_id, OLD.pe_id) THEN
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
                      inner join CPE on CPE.C_ID = CF.C_ID
                      where CPE.PE_ID = NEW.PE_ID
            and CF.CF_TYPE = 'LVL2') THEN
      IF NEW.CR_NAME not in ('C*','CUSER','CMGR','CADMIN') THEN
              RAISE EXCEPTION  'Role % not compatible with LVL2', coalesce(NEW.cr_name,'');
            END IF;
            
    ELSE
    
      IF NEW.CR_NAME not in ('C*','CL1') THEN
              RAISE EXCEPTION  'Role % not compatible with LVL1', coalesce(NEW.cr_name,'');
            END IF;

    END IF;

  END IF;

*/


        /**********************************/
        /* AUDIT TRAIL                    */ 
        /**********************************/
        IF TG_OP = 'INSERT' THEN
          SELECT par_aud_seq INTO aud_seq from jsharmony.audit(my_toa, aud_seq, my_id);  
        END IF;


        IF (case when TG_OP = 'DELETE' then OLD.CPER_ID is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.CPER_ID, OLD.CPER_ID) end) THEN
          SELECT par_aud_seq INTO aud_seq from jsharmony.audit(my_toa, aud_seq, my_id, 'CPER_ID', OLD.CPER_ID::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.PE_ID is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.PE_ID, OLD.PE_ID) end) THEN
          SELECT par_aud_seq INTO aud_seq from jsharmony.audit(my_toa, aud_seq, my_id, 'PE_ID', OLD.PE_ID::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.CR_NAME is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.CR_NAME, OLD.CR_NAME) end) THEN
          SELECT par_aud_seq INTO aud_seq from jsharmony.audit(my_toa, aud_seq, my_id, 'CR_NAME', OLD.CR_NAME::text);  
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


ALTER FUNCTION jsharmony.cper_iud() OWNER TO postgres;

--
-- TOC entry 347 (class 1255 OID 49881)
-- Name: create_gcod(character varying, character varying, character varying); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION create_gcod(in_codeschema character varying, in_codename character varying, in_codemean character varying) RETURNS bigint
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE
    rslt          bigint;
    wk_codeschema text;
    runmesql      text;
BEGIN

  rslt := 0;

  wk_codeschema = coalesce(in_codeschema, 'public');

  runmesql := 'CREATE TABLE '||wk_codeschema||'.gcod_'||in_codename||' '
            ||'( '
            ||'  CONSTRAINT gcod_'||in_codename||'_pkey PRIMARY KEY (gcod_id), '
            ||'  CONSTRAINT gcod_'||in_codename||'_codeval_key UNIQUE (codeval), '
            ||'  CONSTRAINT gcod_'||in_codename||'_codetxt_key UNIQUE (codetxt) '
            ||') '
            ||'INHERITS ('||'jsharmony'||'.gcod) '
            ||'WITH ( '
            ||'  OIDS=FALSE '
            ||');';
  EXECUTE runmesql ; 

  runmesql := 'CREATE TRIGGER gcod_'||in_codename||' '
            ||'BEFORE INSERT OR UPDATE OR DELETE '
            ||'ON '||wk_codeschema||'.gcod_'||in_codename||' ' 
            ||'FOR EACH ROW '
            ||'EXECUTE PROCEDURE '||'jsharmony'||'.gcod_iud();';
  EXECUTE runmesql ; 

  runmesql := 'COMMENT ON TABLE '||wk_codeschema||'.gcod_'||in_codename||' IS ''User Codes - '||coalesce(in_codemean,'')||''';';
  EXECUTE runmesql ; 

  RETURN rslt;

EXCEPTION WHEN OTHERS THEN

  raise notice '% %', SQLERRM, SQLSTATE;

END;
$$;


ALTER FUNCTION jsharmony.create_gcod(in_codeschema character varying, in_codename character varying, in_codemean character varying) OWNER TO postgres;

--
-- TOC entry 339 (class 1255 OID 49884)
-- Name: create_gcod2(character varying, character varying, character varying); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION create_gcod2(in_codeschema character varying, in_codename character varying, in_codemean character varying) RETURNS bigint
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE
    rslt          bigint;
    wk_codeschema text;
    runmesql      text;
BEGIN

  rslt := 0;

  wk_codeschema = coalesce(in_codeschema, 'public');

  runmesql := 'CREATE TABLE '||wk_codeschema||'.gcod2_'||in_codename||' '
            ||'( '
            ||'  CONSTRAINT gcod2_'||in_codename||'_pkey PRIMARY KEY (gcod2_id), '
            ||'  CONSTRAINT gcod2_'||in_codename||'_codeval1_codeval2_key UNIQUE (codeval1,codeval2) '
            ||') '
            ||'INHERITS ('||'jsharmony'||'.gcod2) '
            ||'WITH ( '
            ||'  OIDS=FALSE '
            ||');';

  EXECUTE runmesql ; 

  runmesql := 'CREATE TRIGGER gcod2_'||in_codename||' '
            ||'BEFORE INSERT OR UPDATE OR DELETE '
            ||'ON '||wk_codeschema||'.gcod2_'||in_codename||' ' 
            ||'FOR EACH ROW '
            ||'EXECUTE PROCEDURE '||'jsharmony'||'.gcod2_iud();';
  EXECUTE runmesql ; 

  runmesql := 'COMMENT ON TABLE '||wk_codeschema||'.gcod2_'||in_codename||' IS ''User Codes 2 - '||coalesce(in_codemean,'')||''';';
  EXECUTE runmesql ; 

  RETURN rslt;

EXCEPTION WHEN OTHERS THEN

  raise notice '% %', SQLERRM, SQLSTATE;

END;
$$;


ALTER FUNCTION jsharmony.create_gcod2(in_codeschema character varying, in_codename character varying, in_codemean character varying) OWNER TO postgres;

--
-- TOC entry 332 (class 1255 OID 49886)
-- Name: create_ucod(character varying, character varying, character varying); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION create_ucod(in_codeschema character varying, in_codename character varying, in_codemean character varying) RETURNS bigint
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE
    rslt          bigint;
    wk_codeschema text;
    runmesql      text;
BEGIN

  rslt := 0;

  wk_codeschema = coalesce(in_codeschema, 'public');

  runmesql := 'CREATE TABLE '||wk_codeschema||'.ucod_'||in_codename||' '
            ||'( '
            ||'  CONSTRAINT ucod_'||in_codename||'_pkey PRIMARY KEY (ucod_id), '
            ||'  CONSTRAINT ucod_'||in_codename||'_codeval_key UNIQUE (codeval), '
            ||'  CONSTRAINT ucod_'||in_codename||'_codetxt_key UNIQUE (codetxt) '
            ||') '
            ||'INHERITS ('||'jsharmony'||'.ucod) '
            ||'WITH ( '
            ||'  OIDS=FALSE '
            ||');';

  EXECUTE runmesql ; 

  runmesql := 'COMMENT ON TABLE '||wk_codeschema||'.ucod_'||in_codename||' IS ''System Codes - '||coalesce(in_codemean,'')||''';';
  EXECUTE runmesql ; 

  RETURN rslt;

EXCEPTION WHEN OTHERS THEN

  raise notice '% %', SQLERRM, SQLSTATE;

END;
$$;


ALTER FUNCTION jsharmony.create_ucod(in_codeschema character varying, in_codename character varying, in_codemean character varying) OWNER TO postgres;

--
-- TOC entry 345 (class 1255 OID 49888)
-- Name: create_ucod2(character varying, character varying, character varying); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION create_ucod2(in_codeschema character varying, in_codename character varying, in_codemean character varying) RETURNS bigint
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE
    rslt          bigint;
    wk_codeschema text;
    runmesql      text;
BEGIN

  rslt := 0;

  wk_codeschema = coalesce(in_codeschema, 'public');

  runmesql := 'CREATE TABLE '||wk_codeschema||'.ucod2_'||in_codename||' '
            ||'( '
            ||'  CONSTRAINT ucod2_'||in_codename||'_pkey PRIMARY KEY (ucod2_id), '
            ||'  CONSTRAINT ucod2_'||in_codename||'_codeval1_codeval2_key UNIQUE (codeval1, codeval2) '
            ||') '
            ||'INHERITS ('||'jsharmony'||'.ucod2) '
            ||'WITH ( '
            ||'  OIDS=FALSE '
            ||');';

  EXECUTE runmesql ; 

  runmesql := 'COMMENT ON TABLE '||wk_codeschema||'.ucod2_'||in_codename||' IS ''System Codes 2 - '||coalesce(in_codemean,'')||''';';
  EXECUTE runmesql ; 

  RETURN rslt;

EXCEPTION WHEN OTHERS THEN

  raise notice '% %', SQLERRM, SQLSTATE;

END;
$$;


ALTER FUNCTION jsharmony.create_ucod2(in_codeschema character varying, in_codename character varying, in_codemean character varying) OWNER TO postgres;

--
-- TOC entry 323 (class 1255 OID 45184)
-- Name: d_iud(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION d_iud() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
    DECLARE
      curdttm    timestamp default jsharmony.mynow();
      myuser     text default jsharmony.mycuser();
      aud_seq    bigint default NULL;
      my_id      bigint default case TG_OP when 'DELETE' then OLD.d_id else NEW.d_id end;
      my_toa     jsharmony.toaudit;

      sqlcmd     text;
      getcid     text = NULL;
      geteid     text = NULL;
      dscope_dctgr text = NULL;

      my_c_id    bigint = NULL;
      my_e_id    bigint = NULL;
      user_c_id  bigint = NULL;
      my_d_scope text = NULL;
      my_d_scope_id bigint = NULL;
      cpe_user   boolean;
    BEGIN

        /**********************************/
        /* INITIALIZE                     */ 
        /**********************************/
        select pp_val
          into getcid
          from jsharmony.v_pp 
         where pp_process = 'SQL'
           and pp_attrib = 'GETCID'; 

        select pp_val
          into geteid
          from jsharmony.v_pp 
         where pp_process = 'SQL'
           and pp_attrib = 'GETEID'; 

        select pp_val
          into dscope_dctgr
          from jsharmony.v_pp 
         where pp_process = 'SQL'
           and pp_attrib = 'DSCOPE_DCTGR'; 

        my_d_scope = case TG_OP when 'DELETE' then OLD.D_SCOPE else NEW.D_SCOPE end;
        my_d_scope_id = case TG_OP when 'DELETE' then OLD.D_SCOPE_ID else NEW.D_SCOPE_ID end;

        if getcid is not null then
          sqlcmd := 'select '||getcid||'($1,$2);';
          EXECUTE sqlcmd INTO my_c_id USING my_d_scope, my_d_scope_id;
        end if;

        if geteid is not null then
          sqlcmd := 'select '||geteid||'($1,$2);';
          EXECUTE sqlcmd INTO my_e_id USING my_d_scope, my_d_scope_id;
        end if;

        my_toa.op := TG_OP;
        my_toa.table_name := upper(TG_TABLE_NAME::text);
        my_toa.c_id := case when TG_OP = 'DELETE' then NULL else my_c_id end;
        my_toa.e_id := case when TG_OP = 'DELETE' then NULL else my_e_id end;
        my_toa.ref_name := NULL;
        my_toa.ref_id := NULL;
        my_toa.subj := NULL;

        /* RECOGNIZE IF CLIENT USER */
        IF SUBSTRING(MYUSER,1,1) = 'C' THEN
          select c_id
      into user_c_id
      from jsharmony.CPE
           where substring(MYUSER,2,1024)=PE_ID::text
       and C_ID = my_c_id;
          IF user_c_id is not null THEN     
            CPE_USER = TRUE;
          ELSE
      CPE_USER = FALSE;
    END IF;
        END IF; 

        /**********************************/
        /* PERFORM CHECKS                 */ 
        /**********************************/
            
        IF TG_OP = 'UPDATE' THEN
          IF jsharmony.nonequal(NEW.d_id, OLD.d_id) THEN
            RAISE EXCEPTION  'Application Error - ID cannot be updated.';
          END IF;
          IF jsharmony.nonequal(NEW.d_scope, OLD.d_scope) THEN
            RAISE EXCEPTION  'Application Error - Scope cannot be updated..';
          END IF;
          IF jsharmony.nonequal(NEW.d_scope_id, OLD.d_scope_id) THEN
            RAISE EXCEPTION  'Application Error - Scope ID cannot be updated..';
          END IF;
          IF jsharmony.nonequal(NEW.d_ctgr, OLD.d_ctgr) THEN
            RAISE EXCEPTION  'Application Error - Document Category cannot be updated..';
          END IF;
        END IF;

        IF (TG_OP = 'INSERT' 
      OR 
      TG_OP = 'UPDATE' AND (jsharmony.nonequal(OLD.D_SCOPE, NEW.D_SCOPE)
                      OR
          jsharmony.nonequal(OLD.D_SCOPE_ID, NEW.D_SCOPE_ID))) THEN
    IF NEW.D_SCOPE = 'S' AND NEW.D_SCOPE_ID <> 0
       OR
       NEW.D_SCOPE <> 'S' AND NEW.D_SCOPE_ID is NULL THEN
            RAISE EXCEPTION  'Application Error - SCOPE_ID inconsistent with SCOPE';
          END IF; 
  END IF;   

        IF (cpe_user) THEN
    IF coalesce(USER_C_ID,0) <> coalesce(my_c_id,0)
       OR
             my_d_scope not in ('C','E','J','O') THEN
            RAISE EXCEPTION  'Application Error - Client User has no rights to perform this operation';
    END IF; 
        END IF;

        IF (TG_OP='INSERT' OR TG_OP='UPDATE') THEN
          IF NOT jsharmony.check_foreign(NEW.D_SCOPE, NEW.D_SCOPE_ID)>0 THEN
            RAISE EXCEPTION  'Table % does not contain record % .', NEW.D_SCOPE, NEW.D_SCOPE_ID::text ;
    END IF;
  END IF;   

        IF (TG_OP='INSERT' OR TG_OP='UPDATE') THEN
          IF NOT jsharmony.check_code2(dscope_dctgr, NEW.D_SCOPE, NEW.D_CTGR)>0 THEN
            RAISE EXCEPTION  'Document type % not allowed for selected scope: % .', NEW.D_ctgr, NEW.D_SCOPE ;
    END IF;
  END IF;   

        /**********************************/
        /* AUDIT TRAIL                    */ 
        /**********************************/

        IF TG_OP = 'INSERT' THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.d_id is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.d_id, OLD.d_id) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'd_id',OLD.d_id::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.C_ID is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.C_ID, OLD.C_ID) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'C_ID',OLD.C_ID::text);  
        END IF;
     
        IF (case when TG_OP = 'DELETE' then OLD.d_scope is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.d_scope, OLD.d_scope) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'd_scope',OLD.d_scope::text);  
        END IF;
     
        IF (case when TG_OP = 'DELETE' then OLD.d_scope_id is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.d_scope_id, OLD.d_scope_id) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'd_scope_id',OLD.d_scope_id::text);  
        END IF;
     
        IF (case when TG_OP = 'DELETE' then OLD.e_id is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.e_id, OLD.e_id) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'e_id',OLD.e_id::text);  
        END IF;
     
        IF (case when TG_OP = 'DELETE' then OLD.d_sts is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.d_sts, OLD.d_sts) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'd_sts',OLD.d_sts::text);  
        END IF;
     
        IF (case when TG_OP = 'DELETE' then OLD.d_ctgr is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.d_ctgr, OLD.d_ctgr) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'd_ctgr',OLD.d_ctgr::text);  
        END IF;
     
        IF (case when TG_OP = 'DELETE' then OLD.d_desc is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.d_desc, OLD.d_desc) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'd_desc',OLD.d_desc::text);  
        END IF;
     
        IF (case when TG_OP = 'DELETE' then OLD.d_utstmp is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.d_utstmp, OLD.d_utstmp) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'd_utstmp',OLD.d_utstmp::text);  
        END IF;
     
        IF (case when TG_OP = 'DELETE' then OLD.d_uu is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.d_uu, OLD.d_uu) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'd_uu',OLD.d_uu::text);  
        END IF;
     
        IF (case when TG_OP = 'DELETE' then OLD.d_synctstmp is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.d_synctstmp, OLD.d_synctstmp) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'd_synctstmp',OLD.d_synctstmp::text);  
        END IF;

 
        /**********************************/
        /* UPDATES AND OTHER TABLES       */ 
        /**********************************/
     
        IF TG_OP = 'INSERT' THEN
          NEW.C_ID = my_c_id;
          NEW.E_ID = my_e_id;
    NEW.d_etstmp := curdttm;
    NEW.d_eu := myuser;
    NEW.d_mtstmp := curdttm;
    NEW.d_mu := myuser;
        ELSIF TG_OP = 'UPDATE' THEN
          IF aud_seq is not NULL THEN
            NEW.C_ID = my_c_id;
            NEW.E_ID = my_e_id;
      NEW.d_mtstmp := curdttm;
      NEW.d_mu := myuser;
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


ALTER FUNCTION jsharmony.d_iud() OWNER TO postgres;

--
-- TOC entry 333 (class 1255 OID 46224)
-- Name: digest(bytea, text); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION digest(bytea, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_digest';


ALTER FUNCTION jsharmony.digest(bytea, text) OWNER TO postgres;

--
-- TOC entry 304 (class 1255 OID 46225)
-- Name: digest(text, text); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION digest(text, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_digest';


ALTER FUNCTION jsharmony.digest(text, text) OWNER TO postgres;

--
-- TOC entry 318 (class 1255 OID 46300)
-- Name: gcod2_iud(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION gcod2_iud() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
      curdttm    timestamp default jsharmony.mynow();
      myuser     text default jsharmony.mycuser();
      aud_seq    bigint default NULL;
      my_id      bigint default case TG_OP when 'DELETE' then OLD.gcod2_id else NEW.gcod2_id end;
      my_toa     jsharmony.toaudit;
    BEGIN

        /**********************************/
        /* INITIALIZE                     */ 
        /**********************************/

        my_toa.op := TG_OP;
        my_toa.table_name := upper(TG_TABLE_NAME::text);
        my_toa.c_id := NULL;
        my_toa.e_id := NULL;
        my_toa.ref_name := NULL;
        my_toa.ref_id := NULL;
        my_toa.subj := NULL;


        /**********************************/
        /* PERFORM CHECKS                 */ 
        /**********************************/
            
        IF TG_OP = 'UPDATE' THEN
          IF jsharmony.nonequal(NEW.gcod2_id, OLD.gcod2_id) THEN
            RAISE EXCEPTION  'Application Error - ID cannot be updated.';
          END IF;
          IF jsharmony.nonequal(NEW.codeval1, OLD.codeval1) THEN
            RAISE EXCEPTION  'Application Error - Code Value 1 cannot be updated..';
          END IF;
          IF jsharmony.nonequal(NEW.codeval2, OLD.codeval2) THEN
            RAISE EXCEPTION  'Application Error - Code Value 2 cannot be updated..';
          END IF;
        END IF;
          

        /**********************************/
        /* AUDIT TRAIL                    */ 
        /**********************************/

        IF TG_OP = 'INSERT' THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.gcod2_id is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.gcod2_id, OLD.gcod2_id) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'gcod2_id',OLD.gcod2_id::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.codseq is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.codseq, OLD.codseq) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'codseq',OLD.codseq::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.codeval1 is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.codeval1, OLD.codeval1) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'codeval1',OLD.codeval1::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.codeval2 is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.codeval2, OLD.codeval2) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'codeval2',OLD.codeval2::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.codetxt is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.codetxt, OLD.codetxt) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'codetxt',OLD.codetxt::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.codecode is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.codecode, OLD.codecode) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'codecode',OLD.codecode::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.codetdt is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.codetdt, OLD.codetdt) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'codetdt',OLD.codetdt::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.codetcm is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.codetcm, OLD.codetcm) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'codetcm',OLD.codetcm::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.COD_NOTES is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.COD_NOTES, OLD.COD_NOTES) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'COD_NOTES',OLD.COD_NOTES::text);  
        END IF;

 
        /**********************************/
        /* UPDATES AND OTHER TABLES       */ 
        /**********************************/
     
        IF TG_OP = 'INSERT' THEN
    NEW.cod_etstmp := curdttm;
    NEW.cod_eu := myuser;
    NEW.cod_mtstmp := curdttm;
    NEW.cod_mu := myuser;
        ELSIF TG_OP = 'UPDATE' THEN
          IF aud_seq is not NULL THEN
      NEW.cod_mtstmp := curdttm;
      NEW.cod_mu := myuser;
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


ALTER FUNCTION jsharmony.gcod2_iud() OWNER TO postgres;

--
-- TOC entry 354 (class 1255 OID 46301)
-- Name: gcod_iud(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION gcod_iud() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
      curdttm    timestamp default jsharmony.mynow();
      myuser     text default jsharmony.mycuser();
      aud_seq    bigint default NULL;
      my_id      bigint default case TG_OP when 'DELETE' then OLD.gcod_id else NEW.gcod_id end;
      my_toa     jsharmony.toaudit;
    BEGIN

        /**********************************/
        /* INITIALIZE                     */ 
        /**********************************/

        my_toa.op := TG_OP;
        my_toa.table_name := upper(TG_TABLE_NAME::text);
        my_toa.c_id := NULL;
        my_toa.e_id := NULL;
        my_toa.ref_name := NULL;
        my_toa.ref_id := NULL;
        my_toa.subj := NULL;


        /**********************************/
        /* PERFORM CHECKS                 */ 
        /**********************************/
            
        IF TG_OP = 'UPDATE' THEN
          IF jsharmony.nonequal(NEW.gcod_id, OLD.gcod_id) THEN
            RAISE EXCEPTION  'Application Error - ID cannot be updated.';
          END IF;
          IF jsharmony.nonequal(NEW.codeval, OLD.codeval) THEN
            RAISE EXCEPTION  'Application Error - Code Value 1 cannot be updated..';
          END IF;
        END IF;
          

        /**********************************/
        /* AUDIT TRAIL                    */ 
        /**********************************/

        IF TG_OP = 'INSERT' THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.gcod_id is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.gcod_id, OLD.gcod_id) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'gcod_id',OLD.gcod_id::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.codseq is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.codseq, OLD.codseq) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'codseq',OLD.codseq::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.codeval is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.codeval, OLD.codeval) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'codeval',OLD.codeval::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.codetxt is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.codetxt, OLD.codetxt) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'codetxt',OLD.codetxt::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.codecode is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.codecode, OLD.codecode) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'codecode',OLD.codecode::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.codetdt is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.codetdt, OLD.codetdt) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'codetdt',OLD.codetdt::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.codetcm is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.codetcm, OLD.codetcm) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'codetcm',OLD.codetcm::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.COD_NOTES is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.COD_NOTES, OLD.COD_NOTES) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'COD_NOTES',OLD.COD_NOTES::text);  
        END IF;

 
        /**********************************/
        /* UPDATES AND OTHER TABLES       */ 
        /**********************************/
     
        IF TG_OP = 'INSERT' THEN
    NEW.cod_etstmp := curdttm;
    NEW.cod_eu := myuser;
    NEW.cod_mtstmp := curdttm;
    NEW.cod_mu := myuser;
        ELSIF TG_OP = 'UPDATE' THEN
          IF aud_seq is not NULL THEN
      NEW.cod_mtstmp := curdttm;
      NEW.cod_mu := myuser;
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


ALTER FUNCTION jsharmony.gcod_iud() OWNER TO postgres;

--
-- TOC entry 309 (class 1255 OID 45186)
-- Name: get_cpe_name(bigint); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION get_cpe_name(in_pe_id bigint) RETURNS character varying
    LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER COST 10
    AS $$
DECLARE
    rslt    text = NULL;
BEGIN

  select cpe.pe_lname::text || ', '::text || cpe.pe_fname::text
    into rslt
    from jsharmony.cpe
   where cpe.pe_id = in_pe_id; 
  
  RETURN rslt;
END;
$$;


ALTER FUNCTION jsharmony.get_cpe_name(in_pe_id bigint) OWNER TO postgres;

--
-- TOC entry 307 (class 1255 OID 45187)
-- Name: get_pe_name(bigint); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION get_pe_name(in_pe_id bigint) RETURNS character varying
    LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER COST 10
    AS $$
DECLARE
    rslt    text = NULL;
BEGIN

  select pe.pe_lname::text || ', '::text || pe.pe_fname::text
    into rslt
    from jsharmony.pe
   where pe_id = in_pe_id; 
  
  RETURN rslt;
END;
$$;


ALTER FUNCTION jsharmony.get_pe_name(in_pe_id bigint) OWNER TO postgres;

--
-- TOC entry 308 (class 1255 OID 45188)
-- Name: get_ppd_desc(character varying, character varying); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION get_ppd_desc(in_ppd_process character varying, in_ppd_attrib character varying) RETURNS character varying
    LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER COST 10
    AS $$
DECLARE
    rslt    text = NULL;
BEGIN

  select ppd_desc
    into rslt
    from jsharmony.ppd
   where ppd.ppd_process = in_ppd_process
     and ppd.ppd_attrib = in_ppd_attrib;
  
  RETURN rslt;
END;
$$;


ALTER FUNCTION jsharmony.get_ppd_desc(in_ppd_process character varying, in_ppd_attrib character varying) OWNER TO postgres;

--
-- TOC entry 355 (class 1255 OID 63142)
-- Name: good_email(text); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION good_email(x text) RETURNS boolean
    LANGUAGE sql
    AS $_$select x ~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$';$_$;


ALTER FUNCTION jsharmony.good_email(x text) OWNER TO postgres;

--
-- TOC entry 320 (class 1255 OID 45189)
-- Name: gpp_iud(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION gpp_iud() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
      curdttm    timestamp default jsharmony.mynow();
      myuser     text default jsharmony.mycuser();
      aud_seq    bigint default NULL;
      my_id      bigint default case TG_OP when 'DELETE' then OLD.gpp_id else NEW.gpp_id end;
      my_toa     jsharmony.toaudit;
      m          text;
    BEGIN

        /**********************************/
        /* INITIALIZE                     */ 
        /**********************************/

        my_toa.op := TG_OP;
        my_toa.table_name := upper(TG_TABLE_NAME::text);
        my_toa.c_id := NULL;
        my_toa.e_id := NULL;
        my_toa.ref_name := NULL;
        my_toa.ref_id := NULL;
        my_toa.subj := NULL;


        /**********************************/
        /* PERFORM CHECKS                 */ 
        /**********************************/
            
        IF TG_OP = 'UPDATE' THEN
          IF jsharmony.nonequal(NEW.gpp_id, OLD.gpp_id) THEN
            RAISE EXCEPTION  'Application Error - ID cannot be updated.';
          END IF;
          IF jsharmony.nonequal(NEW.gpp_process, OLD.gpp_process) THEN
            RAISE EXCEPTION  'Application Error - Process cannot be updated..';
          END IF;
          IF jsharmony.nonequal(NEW.gpp_attrib, OLD.gpp_attrib) THEN
            RAISE EXCEPTION  'Application Error - Attribute cannot be updated..';
          END IF;
        END IF;
          

        IF (TG_OP = 'INSERT' or TG_OP = 'UPDATE') THEN
          m := jsharmony.CHECK_PP('GPP', NEW.GPP_PROCESS, NEW.GPP_ATTRIB, NEW.GPP_VAL);
          IF m IS NOT null THEN 
            RAISE EXCEPTION '%', m;
          END IF;
        END IF;



        /**********************************/
        /* AUDIT TRAIL                    */ 
        /**********************************/

        IF TG_OP = 'INSERT' THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.gpp_id is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.gpp_id, OLD.gpp_id) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'gpp_id',OLD.gpp_id::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.gpp_process is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.gpp_process, OLD.gpp_process) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'gpp_process',OLD.gpp_process::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.gpp_attrib is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.gpp_attrib, OLD.gpp_attrib) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'gpp_attrib',OLD.gpp_attrib::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.gpp_val is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.gpp_val, OLD.gpp_val) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'gpp_val',OLD.gpp_val::text);  
        END IF;

 
        /**********************************/
        /* UPDATES AND OTHER TABLES       */ 
        /**********************************/
     
        IF TG_OP = 'INSERT' THEN
    NEW.gpp_etstmp := curdttm;
    NEW.gpp_eu := myuser;
    NEW.gpp_mtstmp := curdttm;
    NEW.gpp_mu := myuser;
        ELSIF TG_OP = 'UPDATE' THEN
          IF aud_seq is not NULL THEN
      NEW.gpp_mtstmp := curdttm;
      NEW.gpp_mu := myuser;
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


ALTER FUNCTION jsharmony.gpp_iud() OWNER TO postgres;

--
-- TOC entry 362 (class 1255 OID 45190)
-- Name: h_iud(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION h_iud() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
      curdttm    timestamp default jsharmony.mynow();
      myuser     text default jsharmony.mycuser();
      aud_seq    bigint default NULL;
      my_id      bigint default case TG_OP when 'DELETE' then OLD.h_id else NEW.h_id end;
      my_toa     jsharmony.toaudit;
      my_hp_code text = NULL;
      my_hp_desc text = NULL;
    BEGIN

        /**********************************/
        /* INITIALIZE                     */ 
        /**********************************/

        IF TG_OP = 'DELETE' THEN
          my_hp_code = OLD.hp_code;
        ELSE
          my_hp_code = NEW.hp_code;
        END IF;

        select HP.hp_desc
          into my_hp_desc
          from jsharmony.HP
         where HP.hp_code = hp_code;           

        my_toa.op := TG_OP;
        my_toa.table_name := upper(TG_TABLE_NAME::text);
        my_toa.c_id := NULL;
        my_toa.e_id := NULL;
        my_toa.ref_name := NULL;
        my_toa.ref_id := NULL;
        my_toa.subj := my_hp_desc;

        /**********************************/
        /* PERFORM CHECKS                 */ 
        /**********************************/
            
        IF TG_OP = 'UPDATE' THEN
          IF jsharmony.nonequal(NEW.h_id, OLD.h_id) THEN
            RAISE EXCEPTION  'Application Error - ID cannot be updated.';
          END IF;
          IF jsharmony.nonequal(NEW.hp_code, OLD.hp_code) THEN
            RAISE EXCEPTION  'Application Error - HP Code cannot be updated..';
          END IF;
        END IF;
          

        /**********************************/
        /* AUDIT TRAIL                    */ 
        /**********************************/

        IF TG_OP = 'INSERT' THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.h_id is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.h_id, OLD.h_id) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'h_id',OLD.h_id::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.hp_code is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.hp_code, OLD.hp_code) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'hp_code',OLD.hp_code::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.h_title is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.h_title, OLD.h_title) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'h_title',OLD.h_title::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.h_text is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.h_text, OLD.h_text) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'h_text',OLD.h_text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.h_seq is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.h_seq, OLD.h_seq) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'h_seq',OLD.h_seq::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.h_index_a is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.h_index_a, OLD.h_index_a) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'h_index_a',OLD.h_index_a::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.h_index_p is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.h_index_p, OLD.h_index_p) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'h_index_p',OLD.h_index_p::text);  
        END IF;

 
        /**********************************/
        /* UPDATES AND OTHER TABLES       */ 
        /**********************************/
     
        IF TG_OP = 'INSERT' THEN
    NEW.h_etstmp := curdttm;
    NEW.h_eu := myuser;
    NEW.h_mtstmp := curdttm;
    NEW.h_mu := myuser;
        ELSIF TG_OP = 'UPDATE' THEN
          IF aud_seq is not NULL THEN
      NEW.h_mtstmp := curdttm;
      NEW.h_mu := myuser;
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


ALTER FUNCTION jsharmony.h_iud() OWNER TO postgres;

--
-- TOC entry 310 (class 1255 OID 45191)
-- Name: mycuser(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION mycuser() RETURNS text
    LANGUAGE sql
    AS $$select case when current_setting('sessionvars.appuser')='unknown' then 'U'||current_user::text else current_setting('sessionvars.appuser') end;$$;


ALTER FUNCTION jsharmony.mycuser() OWNER TO postgres;

--
-- TOC entry 358 (class 1255 OID 63143)
-- Name: mycuser_email(text); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION mycuser_email(u text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER COST 10
    AS $$
DECLARE
    rslt    text = u;
    wk      text = NULL;
BEGIN
  case substring(u,1,1)
    when 'S' then
      select pe_email
        into wk
        from jsharmony.pe
       where pe_id::text = substring(u,2,1024);  
      rslt = wk;
    when 'C' then
      select pe_email
        into wk
        from jsharmony.cpe
       where pe_id::text = substring(u,2,1024);  
      rslt = wk;
    else
      rslt = NULL;
  end case;    
  
  RETURN rslt;
END;$$;


ALTER FUNCTION jsharmony.mycuser_email(u text) OWNER TO postgres;

--
-- TOC entry 338 (class 1255 OID 45192)
-- Name: mycuser_fmt(text); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION mycuser_fmt(u text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER COST 10
    AS $$
DECLARE
    rslt    text = u;
    wk      text = NULL;
BEGIN
  case substring(u,1,1)
    when 'S' then
      select 'S-'||pe_lname||', '||pe_fname
        into wk
        from jsharmony.pe
       where pe_id::text = substring(u,2,1024);  
      rslt = coalesce(wk, u);
    when 'C' then
      select 'C-'||pe_lname||', '||pe_fname
        into wk
        from jsharmony.cpe
       where pe_id::text = substring(u,2,1024);  
      rslt = coalesce(wk, u);
    when 'U' then
      rslt = coalesce(substring(u,2,1024), u);
    else
      rslt = coalesce(u, 'unknown');
  end case;    
  
  RETURN rslt;
END;$$;


ALTER FUNCTION jsharmony.mycuser_fmt(u text) OWNER TO postgres;

--
-- TOC entry 351 (class 1255 OID 45193)
-- Name: myhash(character, bigint, character varying); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION myhash(par_type character, par_pe_id bigint, par_pw character varying) RETURNS bytea
    LANGUAGE plpgsql
    AS $$
DECLARE 
  rslt bytea default NULL;
  seed varchar(255) default NULL;
  v    varchar(255);
BEGIN

  if (par_type = 'S') THEN
    select PP_VAL into seed
      from jsharmony.V_PP
     where PP_PROCESS = 'USERS'
       and PP_ATTRIB = 'HASH_SEED_S';
  elsif (par_type = 'C') THEN
    select PP_VAL into seed
      from jsharmony.V_PP
     where PP_PROCESS = 'USERS'
       and PP_ATTRIB = 'HASH_SEED_C';
  END IF;
  
  if (seed is not null
      and coalesce(par_pe_id,0) > 0
      and coalesce(par_pw,'') <> '') THEN
    v = par_pe_id::text||par_pw||seed;
    /* rslt = hashbytes('sha1',v); */
    rslt = jsharmony.digest(v, 'sha1'::text);
  end if;

  return rslt;

END;
$$;


ALTER FUNCTION jsharmony.myhash(par_type character, par_pe_id bigint, par_pw character varying) OWNER TO postgres;

--
-- TOC entry 319 (class 1255 OID 45194)
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


ALTER FUNCTION jsharmony.myisnumeric(text) OWNER TO postgres;

--
-- TOC entry 326 (class 1255 OID 46454)
-- Name: mymmddyy(timestamp without time zone); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION mymmddyy(timestamp without time zone) RETURNS character varying
    LANGUAGE sql
    AS $_$select to_char($1, 'MM/DD/YY');$_$;


ALTER FUNCTION jsharmony.mymmddyy(timestamp without time zone) OWNER TO postgres;

--
-- TOC entry 341 (class 1255 OID 45195)
-- Name: mymmddyyhhmi(timestamp without time zone); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION mymmddyyhhmi(timestamp without time zone) RETURNS character varying
    LANGUAGE sql
    AS $_$select to_char($1, 'MM/DD/YY HH24:MI');$_$;


ALTER FUNCTION jsharmony.mymmddyyhhmi(timestamp without time zone) OWNER TO postgres;

--
-- TOC entry 314 (class 1255 OID 46456)
-- Name: mymmddyyyyhhmi(timestamp without time zone); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION mymmddyyyyhhmi(timestamp without time zone) RETURNS character varying
    LANGUAGE sql
    AS $_$select to_char($1, 'MM/DD/YYYY HH24:MI');$_$;


ALTER FUNCTION jsharmony.mymmddyyyyhhmi(timestamp without time zone) OWNER TO postgres;

--
-- TOC entry 335 (class 1255 OID 45196)
-- Name: mynow(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION mynow() RETURNS timestamp without time zone
    LANGUAGE sql
    AS $$select localtimestamp;$$;


ALTER FUNCTION jsharmony.mynow() OWNER TO postgres;

--
-- TOC entry 330 (class 1255 OID 45197)
-- Name: mype(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION mype() RETURNS bigint
    LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER COST 10
    AS $$
DECLARE
    u       text = jsharmony.mycuser();
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


ALTER FUNCTION jsharmony.mype() OWNER TO postgres;

--
-- TOC entry 331 (class 1255 OID 45198)
-- Name: mytodate(timestamp without time zone); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION mytodate(timestamp without time zone) RETURNS date
    LANGUAGE sql
    AS $_$select date_trunc('day',$1)::date;$_$;


ALTER FUNCTION jsharmony.mytodate(timestamp without time zone) OWNER TO postgres;

--
-- TOC entry 329 (class 1255 OID 45199)
-- Name: mytoday(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION mytoday() RETURNS date
    LANGUAGE sql
    AS $$select current_date;$$;


ALTER FUNCTION jsharmony.mytoday() OWNER TO postgres;

--
-- TOC entry 349 (class 1255 OID 45200)
-- Name: n_iud(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION n_iud() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
      curdttm    timestamp default jsharmony.mynow();
      myuser     text default jsharmony.mycuser();
      aud_seq    bigint default NULL;
      my_id      bigint default case TG_OP when 'DELETE' then OLD.n_id else NEW.n_id end;
      my_toa     jsharmony.toaudit;

      my_c_id    bigint = NULL;
      user_c_id  bigint = NULL;
      my_n_scope text = NULL;
      cpe_user   boolean;
    BEGIN

        /**********************************/
        /* INITIALIZE                     */ 
        /**********************************/

        my_toa.op := TG_OP;
        my_toa.table_name := upper(TG_TABLE_NAME::text);
        my_toa.c_id := case when TG_OP = 'DELETE' then NULL else get_c_id(NEW.n_scope, NEW.n_scope_ID) end;
        my_toa.e_id := NULL;
        my_toa.ref_name := NULL;
        my_toa.ref_id := NULL;
        my_toa.subj := NULL;

        if TG_OP = 'DELETE' THEN
          my_c_id := get_c_id(OLD.n_scope, OLD.n_scope_ID);
          my_n_scope := OLD.n_scope;
        else
          my_c_id := get_c_id(NEW.n_scope, NEW.n_scope_ID);
          my_n_scope := NEW.n_scope;
        end if; 

        /* RECOGNIZE IF CLIENT USER */
        IF SUBSTRING(MYUSER,1,1) = 'C' THEN
          select c_id
      into user_c_id
      from jsharmony.CPE
           where substring(MYUSER,2,1024)=PE_ID::text
       and C_ID = my_c_id;
          IF user_c_id is not null THEN     
            CPE_USER = TRUE;
          ELSE
      CPE_USER = FALSE;
    END IF;
        END IF; 

        /**********************************/
        /* PERFORM CHECKS                 */ 
        /**********************************/

        IF (cpe_user) THEN
    IF coalesce(USER_C_ID,0) <> coalesce(my_c_id,0)
       OR
             my_n_scope not in ('C','E','J','O') THEN
            RAISE EXCEPTION  'Application Error - Client User has no rights to perform this operation';
    END IF; 
        END IF;

            
        IF TG_OP = 'UPDATE' THEN
          IF jsharmony.nonequal(NEW.n_id, OLD.n_id) THEN
            RAISE EXCEPTION  'Application Error - ID cannot be updated.';
          END IF;
          IF jsharmony.nonequal(NEW.n_scope, OLD.n_scope) THEN
            RAISE EXCEPTION  'Application Error - Scope cannot be updated..';
          END IF;
          IF jsharmony.nonequal(NEW.n_scope_id, OLD.n_scope_id) THEN
            RAISE EXCEPTION  'Application Error - Scope ID cannot be updated..';
          END IF;
          IF jsharmony.nonequal(NEW.n_type, OLD.n_type) THEN
            RAISE EXCEPTION  'Application Error - Note Type cannot be updated..';
          END IF;
        END IF;
          

        IF (TG_OP='INSERT' OR TG_OP='UPDATE') THEN
          IF NOT check_foreign(NEW.n_scope, NEW.n_scope_ID) THEN
            RAISE EXCEPTION  'Table % does not contain record % .', NEW.n_scope, NEW.n_scope_ID::text ;
    END IF;
  END IF;   





        /**********************************/
        /* AUDIT TRAIL                    */ 
        /**********************************/

        IF TG_OP = 'INSERT' THEN
          SELECT par_aud_seq INTO aud_seq from jsharmony.audit(my_toa, aud_seq, my_id);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.n_id is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.n_id, OLD.n_id) end) THEN
          SELECT par_aud_seq INTO aud_seq from jsharmony.audit(my_toa, aud_seq, my_id, 'n_id',OLD.n_id::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.c_id is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.c_id, OLD.c_id) end) THEN
          SELECT par_aud_seq INTO aud_seq from jsharmony.audit(my_toa, aud_seq, my_id, 'c_id',OLD.c_id::text);  
        END IF;
     
        IF (case when TG_OP = 'DELETE' then OLD.n_scope is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.n_scope, OLD.n_scope) end) THEN
          SELECT par_aud_seq INTO aud_seq from jsharmony.audit(my_toa, aud_seq, my_id, 'n_scope',OLD.n_scope::text);  
        END IF;
     
        IF (case when TG_OP = 'DELETE' then OLD.n_scope_id is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.n_scope_id, OLD.n_scope_id) end) THEN
          SELECT par_aud_seq INTO aud_seq from jsharmony.audit(my_toa, aud_seq, my_id, 'n_scope_id',OLD.n_scope_id::text);  
        END IF;
     
        IF (case when TG_OP = 'DELETE' then OLD.e_id is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.e_id, OLD.e_id) end) THEN
          SELECT par_aud_seq INTO aud_seq from jsharmony.audit(my_toa, aud_seq, my_id, 'e_id',OLD.e_id::text);  
        END IF;
     
        IF (case when TG_OP = 'DELETE' then OLD.n_sts is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.n_sts, OLD.n_sts) end) THEN
          SELECT par_aud_seq INTO aud_seq from jsharmony.audit(my_toa, aud_seq, my_id, 'n_sts',OLD.n_sts::text);  
        END IF;
     
        IF (case when TG_OP = 'DELETE' then OLD.n_type is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.n_type, OLD.n_type) end) THEN
          SELECT par_aud_seq INTO aud_seq from jsharmony.audit(my_toa, aud_seq, my_id, 'n_type',OLD.n_type::text);  
        END IF;
     
        IF (case when TG_OP = 'DELETE' then OLD.n_note is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.n_note, OLD.n_note) end) THEN
          SELECT par_aud_seq INTO aud_seq from jsharmony.audit(my_toa, aud_seq, my_id, 'n_note',OLD.n_note::text);  
        END IF;

 
        /**********************************/
        /* UPDATES AND OTHER TABLES       */ 
        /**********************************/
     
        IF TG_OP = 'INSERT' THEN
          NEW.C_ID = my_c_id;
          NEW.E_ID = NULL::text;
    NEW.n_etstmp := curdttm;
    NEW.n_eu := myuser;
    NEW.n_mtstmp := curdttm;
    NEW.n_mu := myuser;
        ELSIF TG_OP = 'UPDATE' THEN
          IF aud_seq is not NULL THEN
            NEW.C_ID = my_c_id;
            NEW.E_ID = NULL::text;
      NEW.n_mtstmp := curdttm;
      NEW.n_mu := myuser;
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


ALTER FUNCTION jsharmony.n_iud() OWNER TO postgres;

--
-- TOC entry 311 (class 1255 OID 45201)
-- Name: nonequal(bit, bit); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION nonequal(x1 bit, x2 bit) RETURNS boolean
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


ALTER FUNCTION jsharmony.nonequal(x1 bit, x2 bit) OWNER TO postgres;

--
-- TOC entry 350 (class 1255 OID 63113)
-- Name: nonequal(boolean, boolean); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION nonequal(x1 boolean, x2 boolean) RETURNS boolean
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


ALTER FUNCTION jsharmony.nonequal(x1 boolean, x2 boolean) OWNER TO postgres;

--
-- TOC entry 312 (class 1255 OID 45202)
-- Name: nonequal(smallint, smallint); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION nonequal(x1 smallint, x2 smallint) RETURNS boolean
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


ALTER FUNCTION jsharmony.nonequal(x1 smallint, x2 smallint) OWNER TO postgres;

--
-- TOC entry 313 (class 1255 OID 45203)
-- Name: nonequal(integer, integer); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION nonequal(x1 integer, x2 integer) RETURNS boolean
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


ALTER FUNCTION jsharmony.nonequal(x1 integer, x2 integer) OWNER TO postgres;

--
-- TOC entry 324 (class 1255 OID 45204)
-- Name: nonequal(bigint, bigint); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION nonequal(x1 bigint, x2 bigint) RETURNS boolean
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


ALTER FUNCTION jsharmony.nonequal(x1 bigint, x2 bigint) OWNER TO postgres;

--
-- TOC entry 322 (class 1255 OID 45205)
-- Name: nonequal(numeric, numeric); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION nonequal(x1 numeric, x2 numeric) RETURNS boolean
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


ALTER FUNCTION jsharmony.nonequal(x1 numeric, x2 numeric) OWNER TO postgres;

--
-- TOC entry 325 (class 1255 OID 45206)
-- Name: nonequal(text, text); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION nonequal(x1 text, x2 text) RETURNS boolean
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


ALTER FUNCTION jsharmony.nonequal(x1 text, x2 text) OWNER TO postgres;

--
-- TOC entry 327 (class 1255 OID 45207)
-- Name: nonequal(timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION nonequal(x1 timestamp without time zone, x2 timestamp without time zone) RETURNS boolean
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


ALTER FUNCTION jsharmony.nonequal(x1 timestamp without time zone, x2 timestamp without time zone) OWNER TO postgres;

--
-- TOC entry 321 (class 1255 OID 45208)
-- Name: pe_iud(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION pe_iud() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
      curdttm   timestamp default jsharmony.mynow();
      myuser    text default jsharmony.mycuser();
      aud_seq   bigint default NULL;
      my_id     bigint default case TG_OP when 'DELETE' then OLD.pe_id else NEW.pe_id end;
      newpw     text default NULL;
      hash      bytea default NULL;
      my_toa    jsharmony.toaudit;
    BEGIN

        /**********************************/
        /* INITIALIZE                     */ 
        /**********************************/

        my_toa.op := TG_OP;
        my_toa.table_name := upper(TG_TABLE_NAME::text);
        my_toa.c_id := NULL;
        my_toa.e_id := NULL;
        my_toa.ref_name := NULL;
        my_toa.ref_id := NULL;
        my_toa.subj := case when TG_OP = 'DELETE' then NULL else coalesce(NEW.PE_LNAME,'')||', '||coalesce(NEW.PE_FNAME,'') end;
         

        /**********************************/
        /* PERFORM CHECKS                 */ 
        /**********************************/

        IF TG_OP = 'UPDATE'
           and
           jsharmony.nonequal(NEW.pe_id, OLD.pe_id) THEN
          RAISE EXCEPTION  'Application Error - ID cannot be updated.';
        END IF;

        IF TG_OP = 'INSERT' or TG_OP = 'UPDATE' THEN
    IF jsharmony.nonequal(NEW.PE_PW1, NEW.PE_PW2) THEN
            RAISE EXCEPTION  'Application Error - New Password and Repeat Password are different.';
          ELSIF (TG_OP='INSERT' or NEW.pe_pw1 is not null)  AND length(btrim(NEW.pe_pw1::text)) < 6  THEN
            RAISE EXCEPTION  'Application Error - Password length - at least 6 characters required.';
          END IF;            
        END IF;


        /**********************************/
        /* AUDIT TRAIL                    */ 
        /**********************************/

        IF TG_OP = 'INSERT' THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id);  
        END IF;


        IF (case when TG_OP = 'DELETE' then OLD.PE_ID is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.PE_ID, OLD.PE_ID) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'PE_ID', OLD.PE_ID::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.PE_STS is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.PE_STS, OLD.PE_STS) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'PE_STS', OLD.PE_STS::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.PE_FNAME is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.PE_FNAME, OLD.PE_FNAME) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'PE_FNAME', OLD.PE_FNAME::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.PE_MNAME is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.PE_MNAME, OLD.PE_MNAME) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'PE_MNAME', OLD.PE_MNAME::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.PE_LNAME is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.PE_LNAME, OLD.PE_LNAME) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'PE_LNAME', OLD.PE_LNAME::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.PE_JTITLE is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.PE_JTITLE, OLD.PE_JTITLE) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'PE_JTITLE', OLD.PE_JTITLE::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.PE_BPHONE is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.PE_BPHONE, OLD.PE_BPHONE) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'PE_BPHONE', OLD.PE_BPHONE::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.PE_CPHONE is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.PE_CPHONE, OLD.PE_CPHONE) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'PE_CPHONE', OLD.PE_CPHONE::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.PE_COUNTRY is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.PE_COUNTRY, OLD.PE_COUNTRY) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'PE_COUNTRY', OLD.PE_COUNTRY::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.PE_ADDR is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.PE_ADDR, OLD.PE_ADDR) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'PE_ADDR', OLD.PE_ADDR::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.PE_CITY is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.PE_CITY, OLD.PE_CITY) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'PE_CITY', OLD.PE_CITY::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.PE_STATE is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.PE_STATE, OLD.PE_STATE) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'PE_STATE', OLD.PE_STATE::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.PE_ZIP is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.PE_ZIP, OLD.PE_ZIP) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'PE_ZIP', OLD.PE_ZIP::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.PE_EMAIL is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.PE_EMAIL, OLD.PE_EMAIL) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'PE_EMAIL', OLD.PE_EMAIL::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.PE_STARTDT is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.PE_STARTDT, OLD.PE_STARTDT) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'PE_STARTDT', OLD.PE_STARTDT::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.PE_ENDDT is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.PE_ENDDT, OLD.PE_ENDDT) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'PE_ENDDT', OLD.PE_ENDDT::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.PE_UNOTES is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.PE_UNOTES, OLD.PE_UNOTES) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'PE_UNOTES', OLD.PE_UNOTES::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.PE_LL_TSTMP is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.PE_LL_TSTMP, OLD.PE_LL_TSTMP) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'PE_LL_TSTMP', OLD.PE_LL_TSTMP::text);  
        END IF;

      
        IF TG_OP = 'UPDATE' and coalesce(NEW.pe_pw1,'') <> '' THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'PE_PW','*');  
        END IF;


        /**********************************/
        /* UPDATES AND OTHER TABLES       */ 
        /**********************************/

        IF TG_OP in ('INSERT', 'UPDATE') THEN
        
          newpw = btrim(NEW.pe_pw1);
          if newpw is not null then
            hash = jsharmony.myhash('S', NEW.pe_id, newpw);
            if (hash is null) then
              RAISE EXCEPTION  'Application Error - Missing or Incorrect Password.';
            end if;
      NEW.pe_hash := hash;
      NEW.pe_pw1 = NULL;
      NEW.pe_pw2 = NULL;
          else
            hash = NULL;
          end if;
            
          IF TG_OP = 'INSERT' THEN
            NEW.pe_stsdt := curdttm;
      NEW.pe_etstmp := curdttm;
      NEW.pe_eu := myuser;
      NEW.pe_mtstmp := curdttm;
      NEW.pe_mu := myuser;
          ELSIF TG_OP = 'UPDATE' THEN
            IF aud_seq is not NULL THEN
              if jsharmony.nonequal(OLD.PE_STS, NEW.PE_STS) then
                NEW.pe_stsdt := curdttm;
              end if;
        NEW.pe_mtstmp := curdttm;
        NEW.pe_mu := myuser;
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


ALTER FUNCTION jsharmony.pe_iud() OWNER TO postgres;

--
-- TOC entry 359 (class 1255 OID 45210)
-- Name: ppd_iud(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION ppd_iud() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
      curdttm    timestamp default jsharmony.mynow();
      myuser     text default jsharmony.mycuser();
      aud_seq    bigint default NULL;
      my_id      bigint default case TG_OP when 'DELETE' then OLD.ppd_id else NEW.ppd_id end;
      my_toa     jsharmony.toaudit;
    BEGIN

        /**********************************/
        /* INITIALIZE                     */ 
        /**********************************/

        my_toa.op := TG_OP;
        my_toa.table_name := upper(TG_TABLE_NAME::text);
        my_toa.c_id := NULL;
        my_toa.e_id := NULL;
        my_toa.ref_name := NULL;
        my_toa.ref_id := NULL;
        my_toa.subj := NULL;


        /**********************************/
        /* PERFORM CHECKS                 */ 
        /**********************************/
            
        IF TG_OP = 'UPDATE' THEN
          IF jsharmony.nonequal(NEW.ppd_id, OLD.ppd_id) THEN
            RAISE EXCEPTION  'Application Error - ID cannot be updated.';
          END IF;
        END IF;
          

        /**********************************/
        /* AUDIT TRAIL                    */ 
        /**********************************/

        IF TG_OP = 'INSERT' THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.ppd_id is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.ppd_id, OLD.ppd_id) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'ppd_id',OLD.ppd_id::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.ppd_process is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.ppd_process, OLD.ppd_process) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'ppd_process',OLD.ppd_process::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.ppd_attrib is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.ppd_attrib, OLD.ppd_attrib) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'ppd_attrib',OLD.ppd_attrib::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.ppd_desc is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.ppd_desc, OLD.ppd_desc) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'ppd_desc',OLD.ppd_desc::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.ppd_type is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.ppd_type, OLD.ppd_type) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'ppd_type',OLD.ppd_type::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.codename is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.codename, OLD.codename) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'codename',OLD.codename::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.ppd_gpp is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.ppd_gpp, OLD.ppd_gpp) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'ppd_gpp',OLD.ppd_gpp::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.ppd_ppp is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.ppd_ppp, OLD.ppd_ppp) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'ppd_ppp',OLD.ppd_ppp::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.ppd_xpp is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.ppd_xpp, OLD.ppd_xpp) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'ppd_xpp',OLD.ppd_xpp::text);  
        END IF;

 
        /**********************************/
        /* UPDATES AND OTHER TABLES       */ 
        /**********************************/
     
        IF TG_OP = 'INSERT' THEN
    NEW.ppd_etstmp := curdttm;
    NEW.ppd_eu := myuser;
    NEW.ppd_mtstmp := curdttm;
    NEW.ppd_mu := myuser;
        ELSIF TG_OP = 'UPDATE' THEN
          IF aud_seq is not NULL THEN
      NEW.ppd_mtstmp := curdttm;
      NEW.ppd_mu := myuser;
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


ALTER FUNCTION jsharmony.ppd_iud() OWNER TO postgres;

--
-- TOC entry 343 (class 1255 OID 45211)
-- Name: ppp_iud(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION ppp_iud() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
      curdttm    timestamp default jsharmony.mynow();
      myuser     text default jsharmony.mycuser();
      aud_seq    bigint default NULL;
      my_id      bigint default case TG_OP when 'DELETE' then OLD.ppp_id else NEW.ppp_id end;
      my_toa     jsharmony.toaudit;
      m          text;
    BEGIN

        /**********************************/
        /* INITIALIZE                     */ 
        /**********************************/

        my_toa.op := TG_OP;
        my_toa.table_name := upper(TG_TABLE_NAME::text);
        my_toa.ref_name := NULL;
        my_toa.ref_id := NULL;
        my_toa.subj := case when TG_OP = 'DELETE' then NULL else (select coalesce(PE_LNAME,'')||', '||coalesce(PE_FNAME,'') from jsharmony.PE where pe_id = NEW.PE_ID) end;


        /**********************************/
        /* PERFORM CHECKS                 */ 
        /**********************************/
            
        IF TG_OP = 'UPDATE' THEN
          IF jsharmony.nonequal(NEW.ppp_id, OLD.ppp_id) THEN
            RAISE EXCEPTION  'Application Error - ID cannot be updated.';
          END IF;
          IF jsharmony.nonequal(NEW.pe_id, OLD.pe_id) THEN
            RAISE EXCEPTION  'Application Error - Personnel cannot be updated.';
          END IF;
          IF jsharmony.nonequal(NEW.ppp_process, OLD.ppp_process) THEN
            RAISE EXCEPTION  'Application Error - Process cannot be updated..';
          END IF;
          IF jsharmony.nonequal(NEW.ppp_attrib, OLD.ppp_attrib) THEN
            RAISE EXCEPTION  'Application Error - Attribute cannot be updated..';
          END IF;
        END IF;
          

        IF (TG_OP = 'INSERT' or TG_OP = 'UPDATE') THEN
          m := jsharmony.CHECK_PP('PPP', NEW.PPP_PROCESS, NEW.PPP_ATTRIB, NEW.PPP_VAL);
          IF m IS NOT null THEN 
            RAISE EXCEPTION '%', m;
          END IF;
        END IF;



        /**********************************/
        /* AUDIT TRAIL                    */ 
        /**********************************/

        IF TG_OP = 'INSERT' THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.ppp_id is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.ppp_id, OLD.ppp_id) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'ppp_id',OLD.ppp_id::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.pe_id is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.pe_id, OLD.pe_id) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'pe_id',OLD.pe_id::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.ppp_process is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.ppp_process, OLD.ppp_process) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'ppp_process',OLD.ppp_process::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.ppp_attrib is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.ppp_attrib, OLD.ppp_attrib) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'ppp_attrib',OLD.ppp_attrib::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.ppp_val is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.ppp_val, OLD.ppp_val) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'ppp_val',OLD.ppp_val::text);  
        END IF;

 
        /**********************************/
        /* UPDATES AND OTHER TABLES       */ 
        /**********************************/
     
        IF TG_OP = 'INSERT' THEN
    NEW.ppp_etstmp := curdttm;
    NEW.ppp_eu := myuser;
    NEW.ppp_mtstmp := curdttm;
    NEW.ppp_mu := myuser;
        ELSIF TG_OP = 'UPDATE' THEN
          IF aud_seq is not NULL THEN
      NEW.ppp_mtstmp := curdttm;
      NEW.ppp_mu := myuser;
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


ALTER FUNCTION jsharmony.ppp_iud() OWNER TO postgres;

--
-- TOC entry 360 (class 1255 OID 63144)
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


ALTER FUNCTION jsharmony.sanit(x text) OWNER TO postgres;

--
-- TOC entry 346 (class 1255 OID 45212)
-- Name: spef_iud(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION spef_iud() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
      curdttm    timestamp default jsharmony.mynow();
      myuser     text default jsharmony.mycuser();
      aud_seq    bigint default NULL;
      my_id      bigint default case TG_OP when 'DELETE' then OLD.spef_id else NEW.spef_id end;
      my_toa     jsharmony.toaudit;
    BEGIN

        /**********************************/
        /* INITIALIZE                     */ 
        /**********************************/

        my_toa.op := TG_OP;
        my_toa.table_name := upper(TG_TABLE_NAME::text);
        my_toa.c_id := NULL;
        my_toa.e_id := NULL;
        my_toa.ref_name := NULL;
        my_toa.ref_id := NULL;
        my_toa.subj := case when TG_OP = 'DELETE' then NULL else (select coalesce(PE_LNAME,'')||', '||coalesce(PE_FNAME,'') 
                                                                    from jsharmony.CPE 
                                                                   where pe_id = NEW.PE_ID) end;
         

        /**********************************/
        /* PERFORM CHECKS                 */ 
        /**********************************/

        IF TG_OP = 'UPDATE'
           and
           jsharmony.nonequal(NEW.spef_id, OLD.spef_id) THEN
          RAISE EXCEPTION  'Application Error - ID cannot be updated.';
        END IF;

        IF TG_OP = 'UPDATE'
           and
           jsharmony.nonequal(NEW.pe_id, OLD.pe_id) THEN
          RAISE EXCEPTION  'Application Error - User ID cannot be updated.';
        END IF;




        /**********************************/
        /* AUDIT TRAIL                    */ 
        /**********************************/

        IF TG_OP = 'INSERT' THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id);  
        END IF;


        IF (case when TG_OP = 'DELETE' then OLD.spef_ID is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.spef_ID, OLD.spef_ID) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'spef_ID', OLD.spef_ID::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.pe_id is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.pe_id, OLD.pe_id) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'pe_id', OLD.pe_id::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.sf_name is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.sf_name, OLD.sf_name) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'sf_name', OLD.sf_name::text);  
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


ALTER FUNCTION jsharmony.spef_iud() OWNER TO postgres;

--
-- TOC entry 353 (class 1255 OID 45213)
-- Name: sper_iud(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION sper_iud() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
      curdttm    timestamp default jsharmony.mynow();
      myuser     text default jsharmony.mycuser();
      aud_seq    bigint default NULL;
      my_id      bigint default case TG_OP when 'DELETE' then OLD.sper_id else NEW.sper_id end;
      my_toa     jsharmony.toaudit;
    BEGIN

        /**********************************/
        /* INITIALIZE                     */ 
        /**********************************/

        my_toa.op := TG_OP;
        my_toa.table_name := upper(TG_TABLE_NAME::text);
        my_toa.c_id := NULL;
        my_toa.e_id := NULL;
        my_toa.ref_name := NULL;
        my_toa.ref_id := NULL;
        my_toa.subj := case when TG_OP = 'DELETE' then NULL else (select coalesce(PE_LNAME,'')||', '||coalesce(PE_FNAME,'') 
                                                                    from jsharmony.CPE 
                                                                   where pe_id = NEW.PE_ID) end;
         

        /**********************************/
        /* PERFORM CHECKS                 */ 
        /**********************************/

        IF TG_OP = 'UPDATE'
           and
           jsharmony.nonequal(NEW.sper_id, OLD.sper_id) THEN
          RAISE EXCEPTION  'Application Error - ID cannot be updated.';
        END IF;

        IF TG_OP = 'UPDATE'
           and
           jsharmony.nonequal(NEW.pe_id, OLD.pe_id) THEN
          RAISE EXCEPTION  'Application Error - User ID cannot be updated.';
        END IF;

        IF jsharmony.mype() is not null
           and 
           (case when TG_OP = 'DELETE' then OLD.sr_name else NEW.sr_name end) = 'DEV' THEN
          
          IF not exists (select sr_name
                           from jsharmony.V_MY_ROLES
                          where SR_NAME = 'DEV') THEN
            RAISE EXCEPTION  'Application Error - Only Developer can maintain Developer Role.';
          END IF;                 
           
        END IF;   

        /**********************************/
        /* AUDIT TRAIL                    */ 
        /**********************************/

        IF TG_OP = 'INSERT' THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id);  
        END IF;


        IF (case when TG_OP = 'DELETE' then OLD.sper_ID is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.sper_ID, OLD.sper_ID) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'sper_ID', OLD.sper_ID::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.pe_id is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.pe_id, OLD.pe_id) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'pe_id', OLD.pe_id::text);  
        END IF;

        IF (case when TG_OP = 'DELETE' then OLD.sr_name is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.sr_name, OLD.sr_name) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'sr_name', OLD.sr_name::text);  
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


ALTER FUNCTION jsharmony.sper_iud() OWNER TO postgres;

--
-- TOC entry 317 (class 1255 OID 49879)
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
     and table_name = lower(in_name); 

  RETURN rslt;

EXCEPTION WHEN OTHERS THEN

  raise notice '% %', SQLERRM, SQLSTATE;

END;
$$;


ALTER FUNCTION jsharmony.table_type(in_schema character varying, in_name character varying) OWNER TO postgres;

--
-- TOC entry 316 (class 1255 OID 45214)
-- Name: txt_iud(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION txt_iud() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
      curdttm    timestamp default jsharmony.mynow();
      myuser     text default jsharmony.mycuser();
      aud_seq    bigint default NULL;
      my_id      bigint default case TG_OP when 'DELETE' then OLD.txt_id else NEW.txt_id end;
      my_toa     jsharmony.toaudit;
    BEGIN

        /**********************************/
        /* INITIALIZE                     */ 
        /**********************************/

        my_toa.op := TG_OP;
        my_toa.table_name := upper(TG_TABLE_NAME::text);
        my_toa.c_id := NULL;
        my_toa.e_id := NULL;
        my_toa.ref_name := NULL;
        my_toa.ref_id := NULL;
        my_toa.subj := NULL;


        /**********************************/
        /* PERFORM CHECKS                 */ 
        /**********************************/
            
        IF TG_OP = 'UPDATE' THEN
          IF jsharmony.nonequal(NEW.txt_id, OLD.txt_id) THEN
            RAISE EXCEPTION  'Application Error - ID cannot be updated.';
          END IF;
        END IF;
          

        /**********************************/
        /* AUDIT TRAIL                    */ 
        /**********************************/

        IF TG_OP = 'INSERT' THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.txt_id is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.txt_id, OLD.txt_id) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'txt_id',OLD.txt_id::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.txt_process is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.txt_process, OLD.txt_process) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'txt_process',OLD.txt_process::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.txt_attrib is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.txt_attrib, OLD.txt_attrib) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'txt_attrib',OLD.txt_attrib::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.txt_type is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.txt_type, OLD.txt_type) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'txt_type',OLD.txt_type::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.txt_tval is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.txt_tval, OLD.txt_tval) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'txt_tval',OLD.txt_tval::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.txt_val is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.txt_val, OLD.txt_val) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'txt_val',OLD.txt_val::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.txt_bcc is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.txt_bcc, OLD.txt_bcc) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'txt_bcc',OLD.txt_bcc::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.txt_desc is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.txt_desc, OLD.txt_desc) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'txt_desc',OLD.txt_desc::text);  
        END IF;
 
        /**********************************/
        /* UPDATES AND OTHER TABLES       */ 
        /**********************************/
     
        IF TG_OP = 'INSERT' THEN
    NEW.txt_etstmp := curdttm;
    NEW.txt_eu := myuser;
    NEW.txt_mtstmp := curdttm;
    NEW.txt_mu := myuser;
        ELSIF TG_OP = 'UPDATE' THEN
          IF aud_seq is not NULL THEN
      NEW.txt_mtstmp := curdttm;
      NEW.txt_mu := myuser;
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


ALTER FUNCTION jsharmony.txt_iud() OWNER TO postgres;

--
-- TOC entry 328 (class 1255 OID 45215)
-- Name: v_crmsel_iud_insteadof_update(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION v_crmsel_iud_insteadof_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
      curdttm   timestamp default jsharmony.mynow();
      myuser    text default jsharmony.mycuser();
      M         text; 
    BEGIN

        IF (jsharmony.nonequal(NEW.crmsel_sel, OLD.crmsel_sel)
            and
            coalesce(NEW.crmsel_sel,0) = 0) THEN

          delete from jsharmony.crm
                where crm_id = NEW.crm_id;
            
        END IF;    

        IF (jsharmony.nonequal(NEW.crmsel_sel, OLD.crmsel_sel)
            and
            coalesce(NEW.crmsel_sel,0) = 1) THEN

          insert into jsharmony.crm (cr_name, sm_id)
                             values (NEW.new_cr_name, NEW.sm_id);
            
        END IF;    


        RETURN NEW;

    END;
$$;


ALTER FUNCTION jsharmony.v_crmsel_iud_insteadof_update() OWNER TO postgres;

--
-- TOC entry 340 (class 1255 OID 45216)
-- Name: v_srmsel_iud_insteadof_update(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION v_srmsel_iud_insteadof_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
      curdttm   timestamp default jsharmony.mynow();
      myuser    text default jsharmony.mycuser();
      M         text; 
    BEGIN

        IF (jsharmony.nonequal(NEW.srmsel_sel, OLD.srmsel_sel)
            and
            coalesce(NEW.srmsel_sel,0) = 0) THEN

          delete from jsharmony.SRM 
                where SRM_ID = NEW.srm_id;
            
        END IF;    

        IF (jsharmony.nonequal(NEW.srmsel_sel, OLD.srmsel_sel)
            and
            coalesce(NEW.srmsel_sel,0) = 1) THEN

          insert into jsharmony.SRM (SR_NAME, SM_ID)
                             values (NEW.new_sr_name, NEW.sm_id);
            
        END IF;    


        RETURN NEW;

    END;
$$;


ALTER FUNCTION jsharmony.v_srmsel_iud_insteadof_update() OWNER TO postgres;

--
-- TOC entry 352 (class 1255 OID 45217)
-- Name: xpp_iud(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION xpp_iud() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
      curdttm    timestamp default jsharmony.mynow();
      myuser     text default jsharmony.mycuser();
      aud_seq    bigint default NULL;
      my_id      bigint default case TG_OP when 'DELETE' then OLD.xpp_id else NEW.xpp_id end;
      my_toa     jsharmony.toaudit;
      m          text;
    BEGIN

        /**********************************/
        /* INITIALIZE                     */ 
        /**********************************/

        my_toa.op := TG_OP;
        my_toa.table_name := upper(TG_TABLE_NAME::text);
        my_toa.c_id := NULL;
        my_toa.e_id := NULL;
        my_toa.ref_name := NULL;
        my_toa.ref_id := NULL;
        my_toa.subj := NULL;


        /**********************************/
        /* PERFORM CHECKS                 */ 
        /**********************************/
            
        IF TG_OP = 'UPDATE' THEN
          IF jsharmony.nonequal(NEW.xpp_id, OLD.xpp_id) THEN
            RAISE EXCEPTION  'Application Error - ID cannot be updated.';
          END IF;
          IF jsharmony.nonequal(NEW.xpp_process, OLD.xpp_process) THEN
            RAISE EXCEPTION  'Application Error - Process cannot be updated..';
          END IF;
          IF jsharmony.nonequal(NEW.xpp_attrib, OLD.xpp_attrib) THEN
            RAISE EXCEPTION  'Application Error - Attribute cannot be updated..';
          END IF;
        END IF;
          

        IF (TG_OP = 'INSERT' or TG_OP = 'UPDATE') THEN
          m := jsharmony.CHECK_PP('XPP', NEW.xpp_PROCESS, NEW.xpp_ATTRIB, NEW.xpp_VAL);
          IF m IS NOT null THEN 
            RAISE EXCEPTION '%', m;
          END IF;
        END IF;



        /**********************************/
        /* AUDIT TRAIL                    */ 
        /**********************************/

        IF TG_OP = 'INSERT' THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.xpp_id is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.xpp_id, OLD.xpp_id) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'xpp_id',OLD.xpp_id::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.xpp_process is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.xpp_process, OLD.xpp_process) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'xpp_process',OLD.xpp_process::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.xpp_attrib is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.xpp_attrib, OLD.xpp_attrib) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'xpp_attrib',OLD.xpp_attrib::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.xpp_val is not null 
                 else TG_OP = 'UPDATE' and jsharmony.nonequal(NEW.xpp_val, OLD.xpp_val) end) THEN
          SELECT par_aud_seq INTO aud_seq FROM jsharmony.audit(my_toa, aud_seq, my_id, 'xpp_val',OLD.xpp_val::text);  
        END IF;

 
        /**********************************/
        /* UPDATES AND OTHER TABLES       */ 
        /**********************************/
     
        IF TG_OP = 'INSERT' THEN
    NEW.xpp_etstmp := curdttm;
    NEW.xpp_eu := myuser;
    NEW.xpp_mtstmp := curdttm;
    NEW.xpp_mu := myuser;
        ELSIF TG_OP = 'UPDATE' THEN
          IF aud_seq is not NULL THEN
      NEW.xpp_mtstmp := curdttm;
      NEW.xpp_mu := myuser;
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


ALTER FUNCTION jsharmony.xpp_iud() OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 183 (class 1259 OID 45218)
-- Name: aud_d; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE aud_d (
    aud_seq bigint NOT NULL,
    column_name character varying(30) NOT NULL,
    column_val text
);


ALTER TABLE aud_d OWNER TO postgres;

--
-- TOC entry 184 (class 1259 OID 45224)
-- Name: aud_h; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE aud_h (
    aud_seq bigint NOT NULL,
    table_name character varying(32) NOT NULL,
    table_id bigint NOT NULL,
    aud_op character(10) NOT NULL,
    aud_u character varying(20) NOT NULL,
    db_k character(1) DEFAULT 0 NOT NULL,
    aud_tstmp timestamp without time zone NOT NULL,
    c_id bigint,
    e_id bigint,
    ref_name character varying(32),
    ref_id bigint,
    subj character varying(255)
);


ALTER TABLE aud_h OWNER TO postgres;

--
-- TOC entry 185 (class 1259 OID 45228)
-- Name: aud_h_aud_seq_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE aud_h_aud_seq_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aud_h_aud_seq_seq OWNER TO postgres;

--
-- TOC entry 3143 (class 0 OID 0)
-- Dependencies: 185
-- Name: aud_h_aud_seq_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE aud_h_aud_seq_seq OWNED BY aud_h.aud_seq;


--
-- TOC entry 186 (class 1259 OID 45230)
-- Name: cpe; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE cpe (
    pe_id bigint NOT NULL,
    c_id bigint NOT NULL,
    pe_sts character varying(8) NOT NULL,
    pe_stsdt date DEFAULT mynow() NOT NULL,
    pe_fname character varying(35) NOT NULL,
    pe_mname character varying(35),
    pe_lname character varying(35) NOT NULL,
    pe_jtitle character varying(35),
    pe_bphone character varying(30),
    pe_cphone character varying(30),
    pe_email character varying(255) NOT NULL,
    pe_etstmp timestamp without time zone DEFAULT mynow() NOT NULL,
    pe_eu character varying(20) DEFAULT mycuser() NOT NULL,
    pe_mtstmp timestamp without time zone DEFAULT mynow() NOT NULL,
    pe_mu character varying(20) DEFAULT mycuser() NOT NULL,
    pe_pw1 character varying(255),
    pe_pw2 character varying(255),
    pe_hash bytea DEFAULT '\x00'::bytea NOT NULL,
    pe_ll_ip character varying(255),
    pe_ll_tstmp timestamp without time zone,
    pe_snotes character varying(255),
    CONSTRAINT cpe_pe_email_check CHECK (((COALESCE(pe_email, ''::character varying))::text <> ''::text))
);


ALTER TABLE cpe OWNER TO postgres;

--
-- TOC entry 187 (class 1259 OID 45243)
-- Name: cpe_pe_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE cpe_pe_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE cpe_pe_id_seq OWNER TO postgres;

--
-- TOC entry 3146 (class 0 OID 0)
-- Dependencies: 187
-- Name: cpe_pe_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE cpe_pe_id_seq OWNED BY cpe.pe_id;


--
-- TOC entry 188 (class 1259 OID 45245)
-- Name: cper; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE cper (
    pe_id bigint NOT NULL,
    cper_snotes character varying(255),
    cper_id bigint NOT NULL,
    cr_name character varying(16) NOT NULL
);


ALTER TABLE cper OWNER TO postgres;

--
-- TOC entry 189 (class 1259 OID 45248)
-- Name: cper_cper_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE cper_cper_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE cper_cper_id_seq OWNER TO postgres;

--
-- TOC entry 3149 (class 0 OID 0)
-- Dependencies: 189
-- Name: cper_cper_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE cper_cper_id_seq OWNED BY cper.cper_id;


--
-- TOC entry 190 (class 1259 OID 45250)
-- Name: cr; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE cr (
    cr_id bigint NOT NULL,
    cr_seq smallint NOT NULL,
    cr_sts character varying(8) DEFAULT 'ACTIVE'::character varying NOT NULL,
    cr_name character varying(16) NOT NULL,
    cr_desc character varying(255) NOT NULL,
    cr_snotes character varying(255),
    cr_code character varying(50),
    cr_attrib character varying(50)
);


ALTER TABLE cr OWNER TO postgres;

--
-- TOC entry 191 (class 1259 OID 45257)
-- Name: cr_cr_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE cr_cr_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE cr_cr_id_seq OWNER TO postgres;

--
-- TOC entry 3152 (class 0 OID 0)
-- Dependencies: 191
-- Name: cr_cr_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE cr_cr_id_seq OWNED BY cr.cr_id;


--
-- TOC entry 192 (class 1259 OID 45259)
-- Name: crm; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE crm (
    sm_id bigint NOT NULL,
    crm_snotes character varying(255),
    crm_id bigint NOT NULL,
    cr_name character varying(16) NOT NULL
);


ALTER TABLE crm OWNER TO postgres;

--
-- TOC entry 193 (class 1259 OID 45262)
-- Name: crm_crm_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE crm_crm_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE crm_crm_id_seq OWNER TO postgres;

--
-- TOC entry 3155 (class 0 OID 0)
-- Dependencies: 193
-- Name: crm_crm_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE crm_crm_id_seq OWNED BY crm.crm_id;


--
-- TOC entry 194 (class 1259 OID 45264)
-- Name: d; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE d (
    d_id bigint NOT NULL,
    d_scope character varying(8) DEFAULT 'S'::character varying NOT NULL,
    d_scope_id bigint DEFAULT 0 NOT NULL,
    c_id bigint,
    e_id bigint,
    d_sts character varying(8) DEFAULT 'A'::character varying NOT NULL,
    d_ctgr character varying(8) NOT NULL,
    d_desc character varying(255),
    d_ext character varying(16),
    d_size bigint,
    d_etstmp timestamp without time zone DEFAULT mynow() NOT NULL,
    d_eu character varying(20) DEFAULT mycuser() NOT NULL,
    d_mtstmp timestamp without time zone DEFAULT mynow() NOT NULL,
    d_mu character varying(20) DEFAULT mycuser() NOT NULL,
    d_utstmp timestamp without time zone DEFAULT mynow() NOT NULL,
    d_uu character varying(20) DEFAULT mycuser() NOT NULL,
    d_synctstmp timestamp without time zone,
    d_snotes character varying(255),
    d_id_main bigint
);


ALTER TABLE d OWNER TO postgres;

--
-- TOC entry 195 (class 1259 OID 45279)
-- Name: d_d_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE d_d_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE d_d_id_seq OWNER TO postgres;

--
-- TOC entry 3158 (class 0 OID 0)
-- Dependencies: 195
-- Name: d_d_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE d_d_id_seq OWNED BY d.d_id;


--
-- TOC entry 196 (class 1259 OID 45281)
-- Name: dual; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE dual (
    dummy character varying(1) NOT NULL,
    dual_ident bigint NOT NULL,
    dual_bigint bigint,
    dual_varchar50 character varying(50)
);


ALTER TABLE dual OWNER TO postgres;

--
-- TOC entry 3160 (class 0 OID 0)
-- Dependencies: 196
-- Name: TABLE dual; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE dual IS 'System Table';


--
-- TOC entry 197 (class 1259 OID 45284)
-- Name: dual_dual_ident_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE dual_dual_ident_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dual_dual_ident_seq OWNER TO postgres;

--
-- TOC entry 3162 (class 0 OID 0)
-- Dependencies: 197
-- Name: dual_dual_ident_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE dual_dual_ident_seq OWNED BY dual.dual_ident;


--
-- TOC entry 274 (class 1259 OID 46318)
-- Name: gcod_gcod_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE gcod_gcod_id_seq
    START WITH 114
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gcod_gcod_id_seq OWNER TO postgres;

--
-- TOC entry 275 (class 1259 OID 46345)
-- Name: gcod; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE gcod (
    gcod_id bigint DEFAULT nextval('gcod_gcod_id_seq'::regclass) NOT NULL,
    codseq smallint,
    codeval character varying(8) NOT NULL,
    codetxt character varying(50) NOT NULL,
    codecode character varying(50),
    codetdt date,
    codetcm character varying(50),
    cod_etstmp timestamp without time zone DEFAULT mynow() NOT NULL,
    cod_eu character varying(20) DEFAULT mycuser() NOT NULL,
    cod_mtstmp timestamp without time zone DEFAULT mynow() NOT NULL,
    cod_mu character varying(20) DEFAULT mycuser() NOT NULL,
    cod_snotes character varying(255),
    cod_notes character varying(255),
    codeattrib character varying(50)
);


ALTER TABLE gcod OWNER TO postgres;

--
-- TOC entry 273 (class 1259 OID 46314)
-- Name: gcod2_gcod2_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE gcod2_gcod2_id_seq
    START WITH 27
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gcod2_gcod2_id_seq OWNER TO postgres;

--
-- TOC entry 276 (class 1259 OID 46399)
-- Name: gcod2; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE gcod2 (
    gcod2_id bigint DEFAULT nextval('gcod2_gcod2_id_seq'::regclass) NOT NULL,
    codseq smallint,
    codeval1 character varying(8) NOT NULL,
    codeval2 character varying(8) NOT NULL,
    codetxt character varying(50),
    codecode character varying(50),
    codetdt date,
    codetcm character varying(50),
    cod_etstmp timestamp without time zone DEFAULT mynow(),
    cod_eu character varying(20) DEFAULT mycuser(),
    cod_mtstmp timestamp without time zone DEFAULT mynow(),
    cod_mu character varying(20) DEFAULT mycuser(),
    cod_snotes character varying(255),
    cod_notes character varying(255),
    codeattrib character varying(50)
);


ALTER TABLE gcod2 OWNER TO postgres;

--
-- TOC entry 277 (class 1259 OID 46458)
-- Name: gcod2_d_scope_d_ctgr; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE gcod2_d_scope_d_ctgr (
)
INHERITS (gcod2);


ALTER TABLE gcod2_d_scope_d_ctgr OWNER TO postgres;

--
-- TOC entry 198 (class 1259 OID 45286)
-- Name: gcod2_h; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE gcod2_h (
    codename character varying(16) NOT NULL,
    codemean character varying(128),
    codecodemean character varying(128),
    cod_h_etstmp timestamp without time zone DEFAULT mynow() NOT NULL,
    cod_h_eu character varying(20) DEFAULT mycuser() NOT NULL,
    cod_h_mtstmp timestamp without time zone DEFAULT mynow() NOT NULL,
    cod_h_mu character varying(20) DEFAULT mycuser() NOT NULL,
    cod_snotes character varying(255),
    codeattribmean character varying(128),
    codeschema character varying(16)
);


ALTER TABLE gcod2_h OWNER TO postgres;

--
-- TOC entry 199 (class 1259 OID 45296)
-- Name: gcod_h; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE gcod_h (
    codename character varying(16) NOT NULL,
    codemean character varying(128),
    codecodemean character varying(128),
    cod_h_etstmp timestamp without time zone DEFAULT mynow() NOT NULL,
    cod_h_eu character varying(20) DEFAULT mycuser() NOT NULL,
    cod_h_mtstmp timestamp without time zone DEFAULT mynow() NOT NULL,
    cod_h_mu character varying(20) DEFAULT mycuser() NOT NULL,
    cod_snotes character varying(255),
    codeattribmean character varying(128),
    codeschema character varying(16)
);


ALTER TABLE gcod_h OWNER TO postgres;

--
-- TOC entry 200 (class 1259 OID 45306)
-- Name: gpp; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE gpp (
    gpp_id bigint NOT NULL,
    gpp_process character varying(32) NOT NULL,
    gpp_attrib character varying(16) NOT NULL,
    gpp_val character varying(256),
    gpp_etstmp timestamp without time zone DEFAULT mynow() NOT NULL,
    gpp_eu character varying(20) DEFAULT mycuser() NOT NULL,
    gpp_mtstmp timestamp without time zone DEFAULT mynow() NOT NULL,
    gpp_mu character varying(20) DEFAULT mycuser() NOT NULL
);


ALTER TABLE gpp OWNER TO postgres;

--
-- TOC entry 201 (class 1259 OID 45313)
-- Name: gpp_gpp_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE gpp_gpp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gpp_gpp_id_seq OWNER TO postgres;

--
-- TOC entry 3172 (class 0 OID 0)
-- Dependencies: 201
-- Name: gpp_gpp_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE gpp_gpp_id_seq OWNED BY gpp.gpp_id;


--
-- TOC entry 202 (class 1259 OID 45315)
-- Name: h; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE h (
    h_id bigint NOT NULL,
    hp_code character varying(50),
    h_title character varying(70) NOT NULL,
    h_text text NOT NULL,
    h_etstmp timestamp without time zone DEFAULT mynow() NOT NULL,
    h_eu character varying(20) DEFAULT mycuser() NOT NULL,
    h_mtstmp timestamp without time zone DEFAULT mynow() NOT NULL,
    h_mu character varying(20) DEFAULT mycuser() NOT NULL,
    h_seq integer,
    h_index_a boolean DEFAULT true NOT NULL,
    h_index_p boolean DEFAULT true NOT NULL
);


ALTER TABLE h OWNER TO postgres;

--
-- TOC entry 203 (class 1259 OID 45327)
-- Name: h_h_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE h_h_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE h_h_id_seq OWNER TO postgres;

--
-- TOC entry 3175 (class 0 OID 0)
-- Dependencies: 203
-- Name: h_h_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE h_h_id_seq OWNED BY h.h_id;


--
-- TOC entry 204 (class 1259 OID 45329)
-- Name: hp; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE hp (
    hp_id bigint NOT NULL,
    hp_code character varying(50) NOT NULL,
    hp_desc character varying(50) NOT NULL
);


ALTER TABLE hp OWNER TO postgres;

--
-- TOC entry 205 (class 1259 OID 45332)
-- Name: hp_hp_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE hp_hp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE hp_hp_id_seq OWNER TO postgres;

--
-- TOC entry 3178 (class 0 OID 0)
-- Dependencies: 205
-- Name: hp_hp_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE hp_hp_id_seq OWNED BY hp.hp_id;


--
-- TOC entry 206 (class 1259 OID 45334)
-- Name: n; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE n (
    n_id bigint NOT NULL,
    n_scope character varying(8) DEFAULT 'S'::character varying NOT NULL,
    n_scope_id bigint DEFAULT 0 NOT NULL,
    n_sts character varying(8) DEFAULT 'A'::character varying NOT NULL,
    c_id bigint,
    e_id bigint,
    n_type character varying(8),
    n_note text NOT NULL,
    n_etstmp timestamp without time zone DEFAULT mynow() NOT NULL,
    n_eu character varying(20) DEFAULT mycuser() NOT NULL,
    n_mtstmp timestamp without time zone DEFAULT mynow() NOT NULL,
    n_mu character varying(20) DEFAULT mycuser() NOT NULL,
    n_synctstmp timestamp without time zone,
    n_snotes character varying(255),
    n_id_main bigint
);


ALTER TABLE n OWNER TO postgres;

--
-- TOC entry 207 (class 1259 OID 45347)
-- Name: n_n_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE n_n_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE n_n_id_seq OWNER TO postgres;

--
-- TOC entry 3181 (class 0 OID 0)
-- Dependencies: 207
-- Name: n_n_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE n_n_id_seq OWNED BY n.n_id;


--
-- TOC entry 208 (class 1259 OID 45349)
-- Name: numbers; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE numbers (
    n smallint NOT NULL
);


ALTER TABLE numbers OWNER TO postgres;

--
-- TOC entry 209 (class 1259 OID 45352)
-- Name: pe; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE pe (
    pe_id bigint NOT NULL,
    pe_sts character varying(8) DEFAULT 'ACTIVE'::character varying NOT NULL,
    pe_stsdt date DEFAULT mynow() NOT NULL,
    pe_fname character varying(35) NOT NULL,
    pe_mname character varying(35),
    pe_lname character varying(35) NOT NULL,
    pe_jtitle character varying(35),
    pe_bphone character varying(30),
    pe_cphone character varying(30),
    pe_country character varying(8) DEFAULT 'USA'::character varying NOT NULL,
    pe_addr character varying(200),
    pe_city character varying(50),
    pe_state character varying(8),
    pe_zip character varying(20),
    pe_email character varying(255) NOT NULL,
    pe_startdt date DEFAULT mynow() NOT NULL,
    pe_enddt date,
    pe_unotes character varying(4000),
    pe_etstmp timestamp without time zone DEFAULT mynow() NOT NULL,
    pe_eu character varying(20) DEFAULT mycuser() NOT NULL,
    pe_mtstmp timestamp without time zone DEFAULT mynow() NOT NULL,
    pe_mu character varying(20) DEFAULT mycuser() NOT NULL,
    pe_pw1 character varying(255),
    pe_pw2 character varying(255),
    pe_hash bytea DEFAULT '\x00'::bytea NOT NULL,
    pe_ll_ip character varying(255),
    pe_ll_tstmp timestamp without time zone,
    pe_snotes character varying(255),
    CONSTRAINT pe_pe_email_check CHECK (((COALESCE(pe_email, ''::character varying))::text <> ''::text))
);


ALTER TABLE pe OWNER TO postgres;

--
-- TOC entry 210 (class 1259 OID 45368)
-- Name: pe_pe_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE pe_pe_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pe_pe_id_seq OWNER TO postgres;

--
-- TOC entry 3185 (class 0 OID 0)
-- Dependencies: 210
-- Name: pe_pe_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE pe_pe_id_seq OWNED BY pe.pe_id;


--
-- TOC entry 211 (class 1259 OID 45370)
-- Name: ppd; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE ppd (
    ppd_id bigint NOT NULL,
    ppd_process character varying(32) NOT NULL,
    ppd_attrib character varying(16) NOT NULL,
    ppd_desc character varying(255) NOT NULL,
    ppd_type character varying(8) NOT NULL,
    codename character varying(16),
    ppd_etstmp timestamp without time zone DEFAULT mynow() NOT NULL,
    ppd_eu character varying(20) DEFAULT mycuser() NOT NULL,
    ppd_mtstmp timestamp without time zone DEFAULT mynow() NOT NULL,
    ppd_mu character varying(20) DEFAULT mycuser() NOT NULL,
    ppd_snotes text,
    ppd_gpp boolean DEFAULT false NOT NULL,
    ppd_ppp boolean DEFAULT false NOT NULL,
    ppd_xpp boolean DEFAULT false NOT NULL
);


ALTER TABLE ppd OWNER TO postgres;

--
-- TOC entry 212 (class 1259 OID 45383)
-- Name: ppd_ppd_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE ppd_ppd_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ppd_ppd_id_seq OWNER TO postgres;

--
-- TOC entry 3188 (class 0 OID 0)
-- Dependencies: 212
-- Name: ppd_ppd_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE ppd_ppd_id_seq OWNED BY ppd.ppd_id;


--
-- TOC entry 213 (class 1259 OID 45385)
-- Name: ppp; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE ppp (
    ppp_id bigint NOT NULL,
    pe_id bigint NOT NULL,
    ppp_process character varying(32) NOT NULL,
    ppp_attrib character varying(16) NOT NULL,
    ppp_val character varying(256),
    ppp_etstmp timestamp without time zone DEFAULT mynow() NOT NULL,
    ppp_eu character varying(20) DEFAULT mycuser() NOT NULL,
    ppp_mtstmp timestamp without time zone DEFAULT mynow() NOT NULL,
    ppp_mu character varying(20) DEFAULT mycuser() NOT NULL
);


ALTER TABLE ppp OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 45392)
-- Name: ppp_ppp_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE ppp_ppp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ppp_ppp_id_seq OWNER TO postgres;

--
-- TOC entry 3191 (class 0 OID 0)
-- Dependencies: 214
-- Name: ppp_ppp_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE ppp_ppp_id_seq OWNED BY ppp.ppp_id;


--
-- TOC entry 215 (class 1259 OID 45394)
-- Name: rq; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE rq (
    rq_id bigint NOT NULL,
    rq_etstmp timestamp without time zone DEFAULT mynow() NOT NULL,
    rq_eu character varying(20) DEFAULT mycuser() NOT NULL,
    rq_name character varying(255) NOT NULL,
    rq_message text NOT NULL,
    rq_rslt character varying(8),
    rq_rslt_tstmp timestamp without time zone,
    rq_rslt_u character varying(20),
    rq_snotes text
);


ALTER TABLE rq OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 45402)
-- Name: rq_rq_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE rq_rq_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE rq_rq_id_seq OWNER TO postgres;

--
-- TOC entry 3194 (class 0 OID 0)
-- Dependencies: 216
-- Name: rq_rq_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE rq_rq_id_seq OWNED BY rq.rq_id;


--
-- TOC entry 217 (class 1259 OID 45404)
-- Name: rqst; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE rqst (
    rqst_id bigint NOT NULL,
    rqst_etstmp timestamp without time zone DEFAULT mynow() NOT NULL,
    rqst_eu character varying(20) DEFAULT mycuser() NOT NULL,
    rqst_source character varying(8) NOT NULL,
    rqst_atype character varying(8) NOT NULL,
    rqst_aname character varying(50) NOT NULL,
    rqst_parms text,
    rqst_ident character varying(255),
    rqst_rslt character varying(8),
    rqst_rslt_tstmp timestamp without time zone,
    rqst_rslt_u character varying(20),
    rqst_snotes text
);


ALTER TABLE rqst OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 45412)
-- Name: rqst_d; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE rqst_d (
    rqst_d_id bigint NOT NULL,
    rqst_id bigint NOT NULL,
    d_scope character varying(8),
    d_scope_id bigint,
    d_ctgr character varying(8),
    d_desc character varying(255)
);


ALTER TABLE rqst_d OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 45415)
-- Name: rqst_d_rqst_d_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE rqst_d_rqst_d_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE rqst_d_rqst_d_id_seq OWNER TO postgres;

--
-- TOC entry 3198 (class 0 OID 0)
-- Dependencies: 219
-- Name: rqst_d_rqst_d_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE rqst_d_rqst_d_id_seq OWNED BY rqst_d.rqst_d_id;


--
-- TOC entry 220 (class 1259 OID 45417)
-- Name: rqst_email; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE rqst_email (
    rqst_email_id bigint NOT NULL,
    rqst_id bigint NOT NULL,
    email_txt_attrib character varying(32),
    email_to character varying(255) NOT NULL,
    email_cc character varying(255),
    email_bcc character varying(255),
    email_attach smallint,
    email_subject character varying(500),
    email_text text,
    email_html text,
    email_d_id bigint
);


ALTER TABLE rqst_email OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 45423)
-- Name: rqst_email_rqst_email_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE rqst_email_rqst_email_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE rqst_email_rqst_email_id_seq OWNER TO postgres;

--
-- TOC entry 3201 (class 0 OID 0)
-- Dependencies: 221
-- Name: rqst_email_rqst_email_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE rqst_email_rqst_email_id_seq OWNED BY rqst_email.rqst_email_id;


--
-- TOC entry 222 (class 1259 OID 45425)
-- Name: rqst_n; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE rqst_n (
    rqst_n_id bigint NOT NULL,
    rqst_id bigint NOT NULL,
    n_scope character varying(8),
    n_scope_id bigint,
    n_type character varying(8),
    n_note text
);


ALTER TABLE rqst_n OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 45431)
-- Name: rqst_n_rqst_n_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE rqst_n_rqst_n_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE rqst_n_rqst_n_id_seq OWNER TO postgres;

--
-- TOC entry 3204 (class 0 OID 0)
-- Dependencies: 223
-- Name: rqst_n_rqst_n_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE rqst_n_rqst_n_id_seq OWNED BY rqst_n.rqst_n_id;


--
-- TOC entry 224 (class 1259 OID 45433)
-- Name: rqst_rq; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE rqst_rq (
    rqst_rq_id bigint NOT NULL,
    rqst_id bigint NOT NULL,
    rq_name character varying(255) NOT NULL,
    rq_message text
);


ALTER TABLE rqst_rq OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 45439)
-- Name: rqst_rq_rqst_rq_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE rqst_rq_rqst_rq_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE rqst_rq_rqst_rq_id_seq OWNER TO postgres;

--
-- TOC entry 3207 (class 0 OID 0)
-- Dependencies: 225
-- Name: rqst_rq_rqst_rq_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE rqst_rq_rqst_rq_id_seq OWNED BY rqst_rq.rqst_rq_id;


--
-- TOC entry 226 (class 1259 OID 45441)
-- Name: rqst_rqst_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE rqst_rqst_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE rqst_rqst_id_seq OWNER TO postgres;

--
-- TOC entry 3209 (class 0 OID 0)
-- Dependencies: 226
-- Name: rqst_rqst_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE rqst_rqst_id_seq OWNED BY rqst.rqst_id;


--
-- TOC entry 227 (class 1259 OID 45443)
-- Name: rqst_sms; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE rqst_sms (
    rqst_sms_id bigint NOT NULL,
    rqst_id bigint NOT NULL,
    sms_txt_attrib character varying(32),
    sms_to character varying(255) NOT NULL,
    sms_body text
);


ALTER TABLE rqst_sms OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 45449)
-- Name: rqst_sms_rqst_sms_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE rqst_sms_rqst_sms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE rqst_sms_rqst_sms_id_seq OWNER TO postgres;

--
-- TOC entry 3212 (class 0 OID 0)
-- Dependencies: 228
-- Name: rqst_sms_rqst_sms_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE rqst_sms_rqst_sms_id_seq OWNED BY rqst_sms.rqst_sms_id;


--
-- TOC entry 229 (class 1259 OID 45451)
-- Name: sf; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE sf (
    sf_id bigint NOT NULL,
    sf_seq smallint NOT NULL,
    sf_sts character varying(8) DEFAULT 'ACTIVE'::character varying NOT NULL,
    sf_name character varying(16) NOT NULL,
    sf_desc character varying(255) NOT NULL,
    sf_snotes character varying(255),
    sf_code character varying(50),
    sf_attrib character varying(50)
);


ALTER TABLE sf OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 45458)
-- Name: sf_sf_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE sf_sf_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sf_sf_id_seq OWNER TO postgres;

--
-- TOC entry 3215 (class 0 OID 0)
-- Dependencies: 230
-- Name: sf_sf_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE sf_sf_id_seq OWNED BY sf.sf_id;


--
-- TOC entry 231 (class 1259 OID 45460)
-- Name: sm; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE sm (
    sm_id_auto bigint NOT NULL,
    sm_utype character(1) DEFAULT 'S'::bpchar NOT NULL,
    sm_id bigint NOT NULL,
    sm_sts character varying(8) DEFAULT 'ACTIVE'::character varying NOT NULL,
    sm_id_parent bigint,
    sm_name character varying(30) NOT NULL,
    sm_seq integer,
    sm_desc character varying(255) NOT NULL,
    sm_descl text,
    sm_descvl text,
    sm_cmd character varying(255),
    sm_image character varying(255),
    sm_snotes character varying(255),
    sm_subcmd character varying(255),
    CONSTRAINT ck_sm_sm_utype CHECK ((sm_utype = ANY (ARRAY['S'::bpchar, 'C'::bpchar])))
);


ALTER TABLE sm OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 45469)
-- Name: sm_sm_id_auto_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE sm_sm_id_auto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sm_sm_id_auto_seq OWNER TO postgres;

--
-- TOC entry 3218 (class 0 OID 0)
-- Dependencies: 232
-- Name: sm_sm_id_auto_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE sm_sm_id_auto_seq OWNED BY sm.sm_id_auto;


--
-- TOC entry 233 (class 1259 OID 45471)
-- Name: spef; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE spef (
    pe_id bigint NOT NULL,
    spef_snotes character varying(255),
    spef_id bigint NOT NULL,
    sf_name character varying(16) NOT NULL
);


ALTER TABLE spef OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 45474)
-- Name: spef_spef_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE spef_spef_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE spef_spef_id_seq OWNER TO postgres;

--
-- TOC entry 3221 (class 0 OID 0)
-- Dependencies: 234
-- Name: spef_spef_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE spef_spef_id_seq OWNED BY spef.spef_id;


--
-- TOC entry 235 (class 1259 OID 45476)
-- Name: sper; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE sper (
    pe_id bigint NOT NULL,
    sper_snotes character varying(255),
    sper_id bigint NOT NULL,
    sr_name character varying(16) NOT NULL
);


ALTER TABLE sper OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 45479)
-- Name: sper_sper_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE sper_sper_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sper_sper_id_seq OWNER TO postgres;

--
-- TOC entry 3224 (class 0 OID 0)
-- Dependencies: 236
-- Name: sper_sper_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE sper_sper_id_seq OWNED BY sper.sper_id;


--
-- TOC entry 237 (class 1259 OID 45481)
-- Name: sr; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE sr (
    sr_id bigint NOT NULL,
    sr_seq smallint NOT NULL,
    sr_sts character varying(8) DEFAULT 'ACTIVE'::character varying NOT NULL,
    sr_name character varying(16) NOT NULL,
    sr_desc character varying(255) NOT NULL,
    sr_snotes character varying(255),
    sr_code character varying(50),
    sr_attrib character varying(50)
);


ALTER TABLE sr OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 45488)
-- Name: sr_sr_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE sr_sr_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sr_sr_id_seq OWNER TO postgres;

--
-- TOC entry 3227 (class 0 OID 0)
-- Dependencies: 238
-- Name: sr_sr_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE sr_sr_id_seq OWNED BY sr.sr_id;


--
-- TOC entry 239 (class 1259 OID 45490)
-- Name: srm; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE srm (
    sm_id bigint NOT NULL,
    srm_snotes character varying(255),
    srm_id bigint NOT NULL,
    sr_name character varying(16) NOT NULL
);


ALTER TABLE srm OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 45493)
-- Name: srm_srm_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE srm_srm_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE srm_srm_id_seq OWNER TO postgres;

--
-- TOC entry 3230 (class 0 OID 0)
-- Dependencies: 240
-- Name: srm_srm_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE srm_srm_id_seq OWNED BY srm.srm_id;


--
-- TOC entry 241 (class 1259 OID 45495)
-- Name: txt; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE txt (
    txt_id bigint NOT NULL,
    txt_process character varying(32) NOT NULL,
    txt_attrib character varying(32) NOT NULL,
    txt_type character varying(8) DEFAULT 'TEXT'::character varying NOT NULL,
    txt_tval text,
    txt_val text,
    txt_bcc character varying(255),
    txt_desc character varying(255),
    txt_etstmp timestamp without time zone DEFAULT mynow() NOT NULL,
    txt_eu character varying(20) DEFAULT mycuser() NOT NULL,
    txt_mtstmp timestamp without time zone DEFAULT mynow() NOT NULL,
    txt_mu character varying(20) DEFAULT mycuser() NOT NULL
);


ALTER TABLE txt OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 45506)
-- Name: txt_txt_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE txt_txt_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE txt_txt_id_seq OWNER TO postgres;

--
-- TOC entry 3233 (class 0 OID 0)
-- Dependencies: 242
-- Name: txt_txt_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE txt_txt_id_seq OWNED BY txt.txt_id;


--
-- TOC entry 243 (class 1259 OID 45508)
-- Name: ucod; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE ucod (
    ucod_id bigint NOT NULL,
    codseq smallint,
    codeval character varying(8) NOT NULL,
    codetxt character varying(50),
    codecode character varying(50),
    codetdt date,
    codetcm character varying(50),
    cod_etstmp timestamp without time zone DEFAULT mynow(),
    cod_eu character varying(20) DEFAULT mycuser(),
    cod_mtstmp timestamp without time zone DEFAULT mynow(),
    cod_mu character varying(20) DEFAULT mycuser(),
    cod_snotes character varying(255),
    cod_notes character varying(255),
    codeattrib character varying(50)
);


ALTER TABLE ucod OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 45518)
-- Name: ucod2_ucod2_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE ucod2_ucod2_id_seq
    START WITH 208
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ucod2_ucod2_id_seq OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 45520)
-- Name: ucod2; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE ucod2 (
    ucod2_id bigint DEFAULT nextval('ucod2_ucod2_id_seq'::regclass) NOT NULL,
    codseq smallint,
    codeval1 character varying(8) NOT NULL,
    codeval2 character varying(8) NOT NULL,
    codetxt character varying(50),
    codecode character varying(50),
    codetdt date,
    codetcm character varying(50),
    cod_etstmp timestamp without time zone DEFAULT mynow(),
    cod_eu character varying(20) DEFAULT mycuser(),
    cod_mtstmp timestamp without time zone DEFAULT mynow(),
    cod_mu character varying(20) DEFAULT mycuser(),
    cod_snotes character varying(255),
    cod_notes character varying(255),
    codeattrib character varying(50)
);


ALTER TABLE ucod2 OWNER TO postgres;

--
-- TOC entry 246 (class 1259 OID 45531)
-- Name: ucod2_country_state; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE ucod2_country_state (
)
INHERITS (ucod2);


ALTER TABLE ucod2_country_state OWNER TO postgres;

--
-- TOC entry 291 (class 1259 OID 63138)
-- Name: ucod2_gpp_process_attrib_v; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW ucod2_gpp_process_attrib_v AS
 SELECT NULL::smallint AS codseq,
    ppd.ppd_process AS codeval1,
    ppd.ppd_attrib AS codeval2,
    ppd.ppd_desc AS codetxt,
    NULL::character varying(50) AS codecode,
    NULL::date AS codetdt,
    NULL::character varying(50) AS codetcm,
    NULL::timestamp without time zone AS cod_etstmp,
    NULL::character varying(20) AS cod_eu,
    NULL::timestamp without time zone AS cod_mtstmp,
    NULL::character varying(20) AS cod_mu,
    NULL::character varying(255) AS cod_snotes,
    NULL::character varying(255) AS cod_notes
   FROM ppd
  WHERE ppd.ppd_gpp;


ALTER TABLE ucod2_gpp_process_attrib_v OWNER TO postgres;

--
-- TOC entry 279 (class 1259 OID 49401)
-- Name: ucod2_h; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE ucod2_h (
    codename character varying(16) NOT NULL,
    codemean character varying(128),
    codecodemean character varying(128),
    cod_h_etstmp timestamp without time zone DEFAULT mynow() NOT NULL,
    cod_h_eu character varying(20) DEFAULT mycuser() NOT NULL,
    cod_h_mtstmp timestamp without time zone DEFAULT mynow() NOT NULL,
    cod_h_mu character varying(20) DEFAULT mycuser() NOT NULL,
    cod_snotes character varying(255),
    codeattribmean character varying(128),
    codeschema character varying(16),
    ucod2_h_id bigint NOT NULL
);


ALTER TABLE ucod2_h OWNER TO postgres;

--
-- TOC entry 281 (class 1259 OID 49501)
-- Name: ucod2_h_ucod2_h_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE ucod2_h_ucod2_h_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ucod2_h_ucod2_h_id_seq OWNER TO postgres;

--
-- TOC entry 3241 (class 0 OID 0)
-- Dependencies: 281
-- Name: ucod2_h_ucod2_h_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE ucod2_h_ucod2_h_id_seq OWNED BY ucod2_h.ucod2_h_id;


--
-- TOC entry 290 (class 1259 OID 63134)
-- Name: ucod2_ppp_process_attrib_v; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW ucod2_ppp_process_attrib_v AS
 SELECT NULL::smallint AS codseq,
    ppd.ppd_process AS codeval1,
    ppd.ppd_attrib AS codeval2,
    ppd.ppd_desc AS codetxt,
    NULL::character varying(50) AS codecode,
    NULL::date AS codetdt,
    NULL::character varying(50) AS codetcm,
    NULL::timestamp without time zone AS cod_etstmp,
    NULL::character varying(20) AS cod_eu,
    NULL::timestamp without time zone AS cod_mtstmp,
    NULL::character varying(20) AS cod_mu,
    NULL::character varying(255) AS cod_snotes,
    NULL::character varying(255) AS cod_notes
   FROM ppd
  WHERE ppd.ppd_ppp;


ALTER TABLE ucod2_ppp_process_attrib_v OWNER TO postgres;

--
-- TOC entry 289 (class 1259 OID 63130)
-- Name: ucod2_xpp_process_attrib_v; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW ucod2_xpp_process_attrib_v AS
 SELECT NULL::smallint AS codseq,
    ppd.ppd_process AS codeval1,
    ppd.ppd_attrib AS codeval2,
    ppd.ppd_desc AS codetxt,
    NULL::character varying(50) AS codecode,
    NULL::date AS codetdt,
    NULL::character varying(50) AS codetcm,
    NULL::timestamp without time zone AS cod_etstmp,
    NULL::character varying(20) AS cod_eu,
    NULL::timestamp without time zone AS cod_mtstmp,
    NULL::character varying(20) AS cod_mu,
    NULL::character varying(255) AS cod_snotes,
    NULL::character varying(255) AS cod_notes
   FROM ppd
  WHERE ppd.ppd_xpp;


ALTER TABLE ucod2_xpp_process_attrib_v OWNER TO postgres;

--
-- TOC entry 247 (class 1259 OID 45554)
-- Name: ucod_ac; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE ucod_ac (
)
INHERITS (ucod);


ALTER TABLE ucod_ac OWNER TO postgres;

--
-- TOC entry 248 (class 1259 OID 45564)
-- Name: ucod_ac1; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE ucod_ac1 (
)
INHERITS (ucod);


ALTER TABLE ucod_ac1 OWNER TO postgres;

--
-- TOC entry 249 (class 1259 OID 45574)
-- Name: ucod_ahc; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE ucod_ahc (
)
INHERITS (ucod);


ALTER TABLE ucod_ahc OWNER TO postgres;

--
-- TOC entry 250 (class 1259 OID 45584)
-- Name: ucod_country; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE ucod_country (
)
INHERITS (ucod);


ALTER TABLE ucod_country OWNER TO postgres;

--
-- TOC entry 251 (class 1259 OID 45594)
-- Name: ucod_d_scope; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE ucod_d_scope (
)
INHERITS (ucod);


ALTER TABLE ucod_d_scope OWNER TO postgres;

--
-- TOC entry 288 (class 1259 OID 63126)
-- Name: ucod_gpp_process_v; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW ucod_gpp_process_v AS
 SELECT DISTINCT NULL::smallint AS codseq,
    ppd.ppd_process AS codeval,
    ppd.ppd_process AS codetxt,
    NULL::text AS codecode,
    NULL::date AS codetdt,
    NULL::text AS codetcm
   FROM ppd
  WHERE ppd.ppd_gpp;


ALTER TABLE ucod_gpp_process_v OWNER TO postgres;

--
-- TOC entry 278 (class 1259 OID 49377)
-- Name: ucod_h; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE ucod_h (
    codename character varying(16) NOT NULL,
    codemean character varying(128),
    codecodemean character varying(128),
    cod_h_etstmp timestamp without time zone DEFAULT mynow() NOT NULL,
    cod_h_eu character varying(20) DEFAULT mycuser() NOT NULL,
    cod_h_mtstmp timestamp without time zone DEFAULT mynow() NOT NULL,
    cod_h_mu character varying(20) DEFAULT mycuser() NOT NULL,
    cod_snotes character varying(255),
    codeattribmean character varying(128),
    codeschema character varying(16),
    ucod_h_id bigint NOT NULL
);


ALTER TABLE ucod_h OWNER TO postgres;

--
-- TOC entry 280 (class 1259 OID 49486)
-- Name: ucod_h_ucod_h_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE ucod_h_ucod_h_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ucod_h_ucod_h_id_seq OWNER TO postgres;

--
-- TOC entry 3252 (class 0 OID 0)
-- Dependencies: 280
-- Name: ucod_h_ucod_h_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE ucod_h_ucod_h_id_seq OWNED BY ucod_h.ucod_h_id;


--
-- TOC entry 252 (class 1259 OID 45608)
-- Name: ucod_n_scope; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE ucod_n_scope (
)
INHERITS (ucod);


ALTER TABLE ucod_n_scope OWNER TO postgres;

--
-- TOC entry 253 (class 1259 OID 45618)
-- Name: ucod_n_type; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE ucod_n_type (
)
INHERITS (ucod);


ALTER TABLE ucod_n_type OWNER TO postgres;

--
-- TOC entry 254 (class 1259 OID 45628)
-- Name: ucod_ppd_type; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE ucod_ppd_type (
)
INHERITS (ucod);


ALTER TABLE ucod_ppd_type OWNER TO postgres;

--
-- TOC entry 287 (class 1259 OID 63122)
-- Name: ucod_ppp_process_v; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW ucod_ppp_process_v AS
 SELECT DISTINCT NULL::smallint AS codseq,
    ppd.ppd_process AS codeval,
    ppd.ppd_process AS codetxt,
    NULL::text AS codecode,
    NULL::date AS codetdt,
    NULL::text AS codetcm
   FROM ppd
  WHERE ppd.ppd_ppp;


ALTER TABLE ucod_ppp_process_v OWNER TO postgres;

--
-- TOC entry 255 (class 1259 OID 45642)
-- Name: ucod_rqst_atype; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE ucod_rqst_atype (
)
INHERITS (ucod);


ALTER TABLE ucod_rqst_atype OWNER TO postgres;

--
-- TOC entry 256 (class 1259 OID 45652)
-- Name: ucod_rqst_source; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE ucod_rqst_source (
)
INHERITS (ucod);


ALTER TABLE ucod_rqst_source OWNER TO postgres;

--
-- TOC entry 257 (class 1259 OID 45662)
-- Name: ucod_txt_type; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE ucod_txt_type (
)
INHERITS (ucod);


ALTER TABLE ucod_txt_type OWNER TO postgres;

--
-- TOC entry 258 (class 1259 OID 45672)
-- Name: ucod_ucod_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE ucod_ucod_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ucod_ucod_id_seq OWNER TO postgres;

--
-- TOC entry 3261 (class 0 OID 0)
-- Dependencies: 258
-- Name: ucod_ucod_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE ucod_ucod_id_seq OWNED BY ucod.ucod_id;


--
-- TOC entry 282 (class 1259 OID 54226)
-- Name: ucod_v_sts; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE ucod_v_sts (
)
INHERITS (ucod);


ALTER TABLE ucod_v_sts OWNER TO postgres;

--
-- TOC entry 3263 (class 0 OID 0)
-- Dependencies: 282
-- Name: TABLE ucod_v_sts; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE ucod_v_sts IS 'System Codes - Version Status';


--
-- TOC entry 286 (class 1259 OID 63118)
-- Name: ucod_xpp_process_v; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW ucod_xpp_process_v AS
 SELECT DISTINCT NULL::smallint AS codseq,
    ppd.ppd_process AS codeval,
    ppd.ppd_process AS codetxt,
    NULL::text AS codecode,
    NULL::date AS codetdt,
    NULL::text AS codetcm
   FROM ppd
  WHERE ppd.ppd_xpp;


ALTER TABLE ucod_xpp_process_v OWNER TO postgres;

--
-- TOC entry 283 (class 1259 OID 54237)
-- Name: v; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE v (
    v_id bigint NOT NULL,
    v_comp character varying(50) NOT NULL,
    v_no_major integer DEFAULT 0 NOT NULL,
    v_no_minor integer DEFAULT 0 NOT NULL,
    v_no_build integer DEFAULT 0 NOT NULL,
    v_no_rev integer DEFAULT 0 NOT NULL,
    v_sts character varying(8) DEFAULT 'OK'::character varying NOT NULL,
    v_note text,
    v_etstmp timestamp without time zone DEFAULT mynow() NOT NULL,
    v_eu character varying(20) DEFAULT mycuser() NOT NULL,
    v_mtstmp timestamp without time zone DEFAULT mynow() NOT NULL,
    v_mu character varying(20) DEFAULT mycuser() NOT NULL,
    v_snotes character varying(255)
);


ALTER TABLE v OWNER TO postgres;

--
-- TOC entry 259 (class 1259 OID 45678)
-- Name: v_audl_raw; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW v_audl_raw AS
 SELECT aud_h.aud_seq,
    aud_h.c_id,
    aud_h.e_id,
    aud_h.table_name,
    aud_h.table_id,
    aud_h.aud_op,
    aud_h.aud_u,
    mycuser_fmt((aud_h.aud_u)::text) AS pe_name,
    aud_h.db_k,
    aud_h.aud_tstmp,
    aud_h.ref_name,
    aud_h.ref_id,
    aud_h.subj,
    aud_d.column_name,
    aud_d.column_val
   FROM (aud_h
     LEFT JOIN aud_d ON ((aud_h.aud_seq = aud_d.aud_seq)));


ALTER TABLE v_audl_raw OWNER TO postgres;

--
-- TOC entry 260 (class 1259 OID 45682)
-- Name: v_cper_nostar; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW v_cper_nostar AS
 SELECT cper.pe_id,
    cper.cper_snotes,
    cper.cper_id,
    cper.cr_name
   FROM cper
  WHERE ((cper.cr_name)::text <> 'C*'::text);


ALTER TABLE v_cper_nostar OWNER TO postgres;

--
-- TOC entry 261 (class 1259 OID 45686)
-- Name: v_crmsel; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW v_crmsel AS
 SELECT crm.crm_id,
    COALESCE(dual.dual_varchar50, ''::character varying) AS new_cr_name,
        CASE
            WHEN (crm.crm_id IS NULL) THEN 0
            ELSE 1
        END AS crmsel_sel,
    m.cr_name,
    m.sm_id_auto,
    m.sm_utype,
    m.sm_id,
    m.sm_sts,
    m.sm_id_parent,
    m.sm_name,
    m.sm_seq,
    m.sm_desc,
    m.sm_descl,
    m.sm_descvl,
    m.sm_cmd,
    m.sm_image,
    m.sm_snotes,
    m.sm_subcmd
   FROM ((( SELECT cr.cr_name,
            sm.sm_id_auto,
            sm.sm_utype,
            sm.sm_id,
            sm.sm_sts,
            sm.sm_id_parent,
            sm.sm_name,
            sm.sm_seq,
            sm.sm_desc,
            sm.sm_descl,
            sm.sm_descvl,
            sm.sm_cmd,
            sm.sm_image,
            sm.sm_snotes,
            sm.sm_subcmd
           FROM (cr
             LEFT JOIN sm ON ((sm.sm_utype = 'C'::bpchar)))) m
     JOIN dual ON ((1 = 1)))
     LEFT JOIN crm ON ((((crm.cr_name)::text = (m.cr_name)::text) AND (crm.sm_id = m.sm_id))));


ALTER TABLE v_crmsel OWNER TO postgres;

--
-- TOC entry 262 (class 1259 OID 45691)
-- Name: v_gppl; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW v_gppl AS
 SELECT gpp.gpp_id,
    gpp.gpp_process,
    gpp.gpp_attrib,
    gpp.gpp_val,
    gpp.gpp_etstmp,
    gpp.gpp_eu,
    gpp.gpp_mtstmp,
    gpp.gpp_mu,
    get_ppd_desc(gpp.gpp_process, gpp.gpp_attrib) AS ppd_desc,
    audit_info(gpp.gpp_etstmp, gpp.gpp_eu, gpp.gpp_mtstmp, gpp.gpp_mu) AS gpp_info
   FROM gpp;


ALTER TABLE v_gppl OWNER TO postgres;

--
-- TOC entry 263 (class 1259 OID 45695)
-- Name: v_months; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW v_months AS
 SELECT numbers.n,
    "right"(('0'::text || ((numbers.n)::character varying)::text), 2) AS mth
   FROM numbers
  WHERE (numbers.n <= 12);


ALTER TABLE v_months OWNER TO postgres;

--
-- TOC entry 264 (class 1259 OID 45699)
-- Name: v_my_roles; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW v_my_roles AS
 SELECT sper.sr_name
   FROM sper
  WHERE (sper.pe_id = mype());


ALTER TABLE v_my_roles OWNER TO postgres;

--
-- TOC entry 265 (class 1259 OID 45703)
-- Name: v_mype; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW v_mype AS
 SELECT mype() AS mype;


ALTER TABLE v_mype OWNER TO postgres;

--
-- TOC entry 266 (class 1259 OID 45707)
-- Name: xpp; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE xpp (
    xpp_id bigint NOT NULL,
    xpp_process character varying(32) NOT NULL,
    xpp_attrib character varying(16) NOT NULL,
    xpp_val character varying(256),
    xpp_etstmp timestamp without time zone DEFAULT mynow() NOT NULL,
    xpp_eu character varying(20) DEFAULT mycuser() NOT NULL,
    xpp_mtstmp timestamp without time zone DEFAULT mynow() NOT NULL,
    xpp_mu character varying(20) DEFAULT mycuser() NOT NULL
);


ALTER TABLE xpp OWNER TO postgres;

--
-- TOC entry 267 (class 1259 OID 45714)
-- Name: v_pp; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW v_pp AS
 SELECT ppd.ppd_process AS pp_process,
    ppd.ppd_attrib AS pp_attrib,
        CASE
            WHEN ((ppp.ppp_val IS NULL) OR ((ppp.ppp_val)::text = ''::text)) THEN
            CASE
                WHEN ((gpp.gpp_val IS NULL) OR ((gpp.gpp_val)::text = ''::text)) THEN xpp.xpp_val
                ELSE gpp.gpp_val
            END
            ELSE ppp.ppp_val
        END AS pp_val,
    ppp.pe_id
   FROM (((ppd
     LEFT JOIN xpp ON ((((ppd.ppd_process)::text = (xpp.xpp_process)::text) AND ((ppd.ppd_attrib)::text = (xpp.xpp_attrib)::text))))
     LEFT JOIN gpp ON ((((ppd.ppd_process)::text = (gpp.gpp_process)::text) AND ((ppd.ppd_attrib)::text = (gpp.gpp_attrib)::text))))
     LEFT JOIN ( SELECT ppp_1.pe_id,
            ppp_1.ppp_process,
            ppp_1.ppp_attrib,
            ppp_1.ppp_val
           FROM ppp ppp_1
        UNION
         SELECT NULL::bigint AS pe_id,
            ppp_null.ppp_process,
            ppp_null.ppp_attrib,
            NULL::character varying AS ppp_val
           FROM ppp ppp_null) ppp ON ((((ppd.ppd_process)::text = (ppp.ppp_process)::text) AND ((ppd.ppd_attrib)::text = (ppp.ppp_attrib)::text))));


ALTER TABLE v_pp OWNER TO postgres;

--
-- TOC entry 285 (class 1259 OID 63114)
-- Name: v_ppdl; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW v_ppdl AS
 SELECT ppd.ppd_id,
    ppd.ppd_process,
    ppd.ppd_attrib,
    ppd.ppd_desc,
    ppd.ppd_type,
    ppd.codename,
    ppd.ppd_gpp,
    ppd.ppd_ppp,
    ppd.ppd_xpp,
    ppd.ppd_etstmp,
    ppd.ppd_eu,
    ppd.ppd_mtstmp,
    ppd.ppd_mu,
    ppd.ppd_snotes,
    audit_info(ppd.ppd_etstmp, ppd.ppd_eu, ppd.ppd_mtstmp, ppd.ppd_mu) AS ppd_info
   FROM ppd;


ALTER TABLE v_ppdl OWNER TO postgres;

--
-- TOC entry 268 (class 1259 OID 45723)
-- Name: v_pppl; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW v_pppl AS
 SELECT ppp.ppp_id,
    ppp.pe_id,
    ppp.ppp_process,
    ppp.ppp_attrib,
    ppp.ppp_val,
    ppp.ppp_etstmp,
    ppp.ppp_eu,
    ppp.ppp_mtstmp,
    ppp.ppp_mu,
    get_ppd_desc(ppp.ppp_process, ppp.ppp_attrib) AS ppd_desc,
    audit_info(ppp.ppp_etstmp, ppp.ppp_eu, ppp.ppp_mtstmp, ppp.ppp_mu) AS ppp_info
   FROM ppp;


ALTER TABLE v_pppl OWNER TO postgres;

--
-- TOC entry 269 (class 1259 OID 45727)
-- Name: v_srmsel; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW v_srmsel AS
 SELECT srm.srm_id,
    COALESCE(dual.dual_varchar50, ''::character varying) AS new_sr_name,
        CASE
            WHEN (srm.srm_id IS NULL) THEN 0
            ELSE 1
        END AS srmsel_sel,
    m.sr_name,
    m.sm_id_auto,
    m.sm_utype,
    m.sm_id,
    m.sm_sts,
    m.sm_id_parent,
    m.sm_name,
    m.sm_seq,
    m.sm_desc,
    m.sm_descl,
    m.sm_descvl,
    m.sm_cmd,
    m.sm_image,
    m.sm_snotes,
    m.sm_subcmd
   FROM ((( SELECT sr.sr_name,
            sm.sm_id_auto,
            sm.sm_utype,
            sm.sm_id,
            sm.sm_sts,
            sm.sm_id_parent,
            sm.sm_name,
            sm.sm_seq,
            sm.sm_desc,
            sm.sm_descl,
            sm.sm_descvl,
            sm.sm_cmd,
            sm.sm_image,
            sm.sm_snotes,
            sm.sm_subcmd
           FROM (sr
             LEFT JOIN sm ON ((sm.sm_utype = 'S'::bpchar)))) m
     JOIN dual ON ((1 = 1)))
     LEFT JOIN srm ON ((((srm.sr_name)::text = (m.sr_name)::text) AND (srm.sm_id = m.sm_id))));


ALTER TABLE v_srmsel OWNER TO postgres;

--
-- TOC entry 284 (class 1259 OID 54252)
-- Name: v_v_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE v_v_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE v_v_id_seq OWNER TO postgres;

--
-- TOC entry 3279 (class 0 OID 0)
-- Dependencies: 284
-- Name: v_v_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE v_v_id_seq OWNED BY v.v_id;


--
-- TOC entry 270 (class 1259 OID 45732)
-- Name: v_xppl; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW v_xppl AS
 SELECT xpp.xpp_id,
    xpp.xpp_process,
    xpp.xpp_attrib,
    xpp.xpp_val,
    xpp.xpp_etstmp,
    xpp.xpp_eu,
    xpp.xpp_mtstmp,
    xpp.xpp_mu,
    get_ppd_desc(xpp.xpp_process, xpp.xpp_attrib) AS ppd_desc,
    audit_info(xpp.xpp_etstmp, xpp.xpp_eu, xpp.xpp_mtstmp, xpp.xpp_mu) AS xpp_info
   FROM xpp;


ALTER TABLE v_xppl OWNER TO postgres;

--
-- TOC entry 271 (class 1259 OID 45736)
-- Name: v_years; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW v_years AS
 SELECT ((date_part('year'::text, mynow()) + (numbers.n)::double precision) - (1)::double precision) AS yr
   FROM numbers
  WHERE (numbers.n <= 10);


ALTER TABLE v_years OWNER TO postgres;

--
-- TOC entry 272 (class 1259 OID 45740)
-- Name: xpp_xpp_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE xpp_xpp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE xpp_xpp_id_seq OWNER TO postgres;

--
-- TOC entry 3283 (class 0 OID 0)
-- Dependencies: 272
-- Name: xpp_xpp_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE xpp_xpp_id_seq OWNED BY xpp.xpp_id;


--
-- TOC entry 2450 (class 2604 OID 45742)
-- Name: aud_seq; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY aud_h ALTER COLUMN aud_seq SET DEFAULT nextval('aud_h_aud_seq_seq'::regclass);


--
-- TOC entry 2458 (class 2604 OID 45743)
-- Name: pe_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY cpe ALTER COLUMN pe_id SET DEFAULT nextval('cpe_pe_id_seq'::regclass);


--
-- TOC entry 2460 (class 2604 OID 45744)
-- Name: cper_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY cper ALTER COLUMN cper_id SET DEFAULT nextval('cper_cper_id_seq'::regclass);


--
-- TOC entry 2461 (class 2604 OID 45745)
-- Name: cr_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY cr ALTER COLUMN cr_id SET DEFAULT nextval('cr_cr_id_seq'::regclass);


--
-- TOC entry 2463 (class 2604 OID 45746)
-- Name: crm_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY crm ALTER COLUMN crm_id SET DEFAULT nextval('crm_crm_id_seq'::regclass);


--
-- TOC entry 2473 (class 2604 OID 45747)
-- Name: d_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY d ALTER COLUMN d_id SET DEFAULT nextval('d_d_id_seq'::regclass);


--
-- TOC entry 2474 (class 2604 OID 45748)
-- Name: dual_ident; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY dual ALTER COLUMN dual_ident SET DEFAULT nextval('dual_dual_ident_seq'::regclass);


--
-- TOC entry 2641 (class 2604 OID 46461)
-- Name: gcod2_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY gcod2_d_scope_d_ctgr ALTER COLUMN gcod2_id SET DEFAULT nextval('gcod2_gcod2_id_seq'::regclass);


--
-- TOC entry 2642 (class 2604 OID 46462)
-- Name: cod_etstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY gcod2_d_scope_d_ctgr ALTER COLUMN cod_etstmp SET DEFAULT mynow();


--
-- TOC entry 2643 (class 2604 OID 46463)
-- Name: cod_eu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY gcod2_d_scope_d_ctgr ALTER COLUMN cod_eu SET DEFAULT mycuser();


--
-- TOC entry 2644 (class 2604 OID 46464)
-- Name: cod_mtstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY gcod2_d_scope_d_ctgr ALTER COLUMN cod_mtstmp SET DEFAULT mynow();


--
-- TOC entry 2645 (class 2604 OID 46465)
-- Name: cod_mu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY gcod2_d_scope_d_ctgr ALTER COLUMN cod_mu SET DEFAULT mycuser();


--
-- TOC entry 2487 (class 2604 OID 45749)
-- Name: gpp_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY gpp ALTER COLUMN gpp_id SET DEFAULT nextval('gpp_gpp_id_seq'::regclass);


--
-- TOC entry 2494 (class 2604 OID 45750)
-- Name: h_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY h ALTER COLUMN h_id SET DEFAULT nextval('h_h_id_seq'::regclass);


--
-- TOC entry 2495 (class 2604 OID 45751)
-- Name: hp_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY hp ALTER COLUMN hp_id SET DEFAULT nextval('hp_hp_id_seq'::regclass);


--
-- TOC entry 2503 (class 2604 OID 45752)
-- Name: n_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY n ALTER COLUMN n_id SET DEFAULT nextval('n_n_id_seq'::regclass);


--
-- TOC entry 2513 (class 2604 OID 45753)
-- Name: pe_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY pe ALTER COLUMN pe_id SET DEFAULT nextval('pe_pe_id_seq'::regclass);


--
-- TOC entry 2522 (class 2604 OID 45754)
-- Name: ppd_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ppd ALTER COLUMN ppd_id SET DEFAULT nextval('ppd_ppd_id_seq'::regclass);


--
-- TOC entry 2527 (class 2604 OID 45755)
-- Name: ppp_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ppp ALTER COLUMN ppp_id SET DEFAULT nextval('ppp_ppp_id_seq'::regclass);


--
-- TOC entry 2530 (class 2604 OID 45756)
-- Name: rq_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY rq ALTER COLUMN rq_id SET DEFAULT nextval('rq_rq_id_seq'::regclass);


--
-- TOC entry 2533 (class 2604 OID 45757)
-- Name: rqst_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY rqst ALTER COLUMN rqst_id SET DEFAULT nextval('rqst_rqst_id_seq'::regclass);


--
-- TOC entry 2534 (class 2604 OID 45758)
-- Name: rqst_d_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY rqst_d ALTER COLUMN rqst_d_id SET DEFAULT nextval('rqst_d_rqst_d_id_seq'::regclass);


--
-- TOC entry 2535 (class 2604 OID 45759)
-- Name: rqst_email_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY rqst_email ALTER COLUMN rqst_email_id SET DEFAULT nextval('rqst_email_rqst_email_id_seq'::regclass);


--
-- TOC entry 2536 (class 2604 OID 45760)
-- Name: rqst_n_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY rqst_n ALTER COLUMN rqst_n_id SET DEFAULT nextval('rqst_n_rqst_n_id_seq'::regclass);


--
-- TOC entry 2537 (class 2604 OID 45761)
-- Name: rqst_rq_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY rqst_rq ALTER COLUMN rqst_rq_id SET DEFAULT nextval('rqst_rq_rqst_rq_id_seq'::regclass);


--
-- TOC entry 2538 (class 2604 OID 45762)
-- Name: rqst_sms_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY rqst_sms ALTER COLUMN rqst_sms_id SET DEFAULT nextval('rqst_sms_rqst_sms_id_seq'::regclass);


--
-- TOC entry 2539 (class 2604 OID 45763)
-- Name: sf_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sf ALTER COLUMN sf_id SET DEFAULT nextval('sf_sf_id_seq'::regclass);


--
-- TOC entry 2543 (class 2604 OID 45764)
-- Name: sm_id_auto; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sm ALTER COLUMN sm_id_auto SET DEFAULT nextval('sm_sm_id_auto_seq'::regclass);


--
-- TOC entry 2545 (class 2604 OID 45765)
-- Name: spef_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY spef ALTER COLUMN spef_id SET DEFAULT nextval('spef_spef_id_seq'::regclass);


--
-- TOC entry 2546 (class 2604 OID 45766)
-- Name: sper_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sper ALTER COLUMN sper_id SET DEFAULT nextval('sper_sper_id_seq'::regclass);


--
-- TOC entry 2547 (class 2604 OID 45767)
-- Name: sr_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sr ALTER COLUMN sr_id SET DEFAULT nextval('sr_sr_id_seq'::regclass);


--
-- TOC entry 2549 (class 2604 OID 45768)
-- Name: srm_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY srm ALTER COLUMN srm_id SET DEFAULT nextval('srm_srm_id_seq'::regclass);


--
-- TOC entry 2555 (class 2604 OID 45769)
-- Name: txt_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY txt ALTER COLUMN txt_id SET DEFAULT nextval('txt_txt_id_seq'::regclass);


--
-- TOC entry 2560 (class 2604 OID 45770)
-- Name: ucod_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod ALTER COLUMN ucod_id SET DEFAULT nextval('ucod_ucod_id_seq'::regclass);


--
-- TOC entry 2566 (class 2604 OID 45771)
-- Name: ucod2_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod2_country_state ALTER COLUMN ucod2_id SET DEFAULT nextval('ucod2_ucod2_id_seq'::regclass);


--
-- TOC entry 2567 (class 2604 OID 45772)
-- Name: cod_etstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod2_country_state ALTER COLUMN cod_etstmp SET DEFAULT mynow();


--
-- TOC entry 2568 (class 2604 OID 45773)
-- Name: cod_eu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod2_country_state ALTER COLUMN cod_eu SET DEFAULT mycuser();


--
-- TOC entry 2569 (class 2604 OID 45774)
-- Name: cod_mtstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod2_country_state ALTER COLUMN cod_mtstmp SET DEFAULT mynow();


--
-- TOC entry 2570 (class 2604 OID 45775)
-- Name: cod_mu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod2_country_state ALTER COLUMN cod_mu SET DEFAULT mycuser();


--
-- TOC entry 2655 (class 2604 OID 49503)
-- Name: ucod2_h_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod2_h ALTER COLUMN ucod2_h_id SET DEFAULT nextval('ucod2_h_ucod2_h_id_seq'::regclass);


--
-- TOC entry 2571 (class 2604 OID 45776)
-- Name: ucod_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ac ALTER COLUMN ucod_id SET DEFAULT nextval('ucod_ucod_id_seq'::regclass);


--
-- TOC entry 2572 (class 2604 OID 45777)
-- Name: cod_etstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ac ALTER COLUMN cod_etstmp SET DEFAULT mynow();


--
-- TOC entry 2573 (class 2604 OID 45778)
-- Name: cod_eu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ac ALTER COLUMN cod_eu SET DEFAULT mycuser();


--
-- TOC entry 2574 (class 2604 OID 45779)
-- Name: cod_mtstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ac ALTER COLUMN cod_mtstmp SET DEFAULT mynow();


--
-- TOC entry 2575 (class 2604 OID 45780)
-- Name: cod_mu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ac ALTER COLUMN cod_mu SET DEFAULT mycuser();


--
-- TOC entry 2576 (class 2604 OID 45781)
-- Name: ucod_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ac1 ALTER COLUMN ucod_id SET DEFAULT nextval('ucod_ucod_id_seq'::regclass);


--
-- TOC entry 2577 (class 2604 OID 45782)
-- Name: cod_etstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ac1 ALTER COLUMN cod_etstmp SET DEFAULT mynow();


--
-- TOC entry 2578 (class 2604 OID 45783)
-- Name: cod_eu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ac1 ALTER COLUMN cod_eu SET DEFAULT mycuser();


--
-- TOC entry 2579 (class 2604 OID 45784)
-- Name: cod_mtstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ac1 ALTER COLUMN cod_mtstmp SET DEFAULT mynow();


--
-- TOC entry 2580 (class 2604 OID 45785)
-- Name: cod_mu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ac1 ALTER COLUMN cod_mu SET DEFAULT mycuser();


--
-- TOC entry 2581 (class 2604 OID 45786)
-- Name: ucod_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ahc ALTER COLUMN ucod_id SET DEFAULT nextval('ucod_ucod_id_seq'::regclass);


--
-- TOC entry 2582 (class 2604 OID 45787)
-- Name: cod_etstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ahc ALTER COLUMN cod_etstmp SET DEFAULT mynow();


--
-- TOC entry 2583 (class 2604 OID 45788)
-- Name: cod_eu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ahc ALTER COLUMN cod_eu SET DEFAULT mycuser();


--
-- TOC entry 2584 (class 2604 OID 45789)
-- Name: cod_mtstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ahc ALTER COLUMN cod_mtstmp SET DEFAULT mynow();


--
-- TOC entry 2585 (class 2604 OID 45790)
-- Name: cod_mu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ahc ALTER COLUMN cod_mu SET DEFAULT mycuser();


--
-- TOC entry 2586 (class 2604 OID 45791)
-- Name: ucod_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_country ALTER COLUMN ucod_id SET DEFAULT nextval('ucod_ucod_id_seq'::regclass);


--
-- TOC entry 2587 (class 2604 OID 45792)
-- Name: cod_etstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_country ALTER COLUMN cod_etstmp SET DEFAULT mynow();


--
-- TOC entry 2588 (class 2604 OID 45793)
-- Name: cod_eu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_country ALTER COLUMN cod_eu SET DEFAULT mycuser();


--
-- TOC entry 2589 (class 2604 OID 45794)
-- Name: cod_mtstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_country ALTER COLUMN cod_mtstmp SET DEFAULT mynow();


--
-- TOC entry 2590 (class 2604 OID 45795)
-- Name: cod_mu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_country ALTER COLUMN cod_mu SET DEFAULT mycuser();


--
-- TOC entry 2591 (class 2604 OID 45796)
-- Name: ucod_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_d_scope ALTER COLUMN ucod_id SET DEFAULT nextval('ucod_ucod_id_seq'::regclass);


--
-- TOC entry 2592 (class 2604 OID 45797)
-- Name: cod_etstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_d_scope ALTER COLUMN cod_etstmp SET DEFAULT mynow();


--
-- TOC entry 2593 (class 2604 OID 45798)
-- Name: cod_eu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_d_scope ALTER COLUMN cod_eu SET DEFAULT mycuser();


--
-- TOC entry 2594 (class 2604 OID 45799)
-- Name: cod_mtstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_d_scope ALTER COLUMN cod_mtstmp SET DEFAULT mynow();


--
-- TOC entry 2595 (class 2604 OID 45800)
-- Name: cod_mu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_d_scope ALTER COLUMN cod_mu SET DEFAULT mycuser();


--
-- TOC entry 2650 (class 2604 OID 49488)
-- Name: ucod_h_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_h ALTER COLUMN ucod_h_id SET DEFAULT nextval('ucod_h_ucod_h_id_seq'::regclass);


--
-- TOC entry 2596 (class 2604 OID 45801)
-- Name: ucod_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_n_scope ALTER COLUMN ucod_id SET DEFAULT nextval('ucod_ucod_id_seq'::regclass);


--
-- TOC entry 2597 (class 2604 OID 45802)
-- Name: cod_etstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_n_scope ALTER COLUMN cod_etstmp SET DEFAULT mynow();


--
-- TOC entry 2598 (class 2604 OID 45803)
-- Name: cod_eu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_n_scope ALTER COLUMN cod_eu SET DEFAULT mycuser();


--
-- TOC entry 2599 (class 2604 OID 45804)
-- Name: cod_mtstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_n_scope ALTER COLUMN cod_mtstmp SET DEFAULT mynow();


--
-- TOC entry 2600 (class 2604 OID 45805)
-- Name: cod_mu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_n_scope ALTER COLUMN cod_mu SET DEFAULT mycuser();


--
-- TOC entry 2602 (class 2604 OID 45806)
-- Name: ucod_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_n_type ALTER COLUMN ucod_id SET DEFAULT nextval('ucod_ucod_id_seq'::regclass);


--
-- TOC entry 2601 (class 2604 OID 45807)
-- Name: cod_etstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_n_type ALTER COLUMN cod_etstmp SET DEFAULT mynow();


--
-- TOC entry 2603 (class 2604 OID 45808)
-- Name: cod_eu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_n_type ALTER COLUMN cod_eu SET DEFAULT mycuser();


--
-- TOC entry 2604 (class 2604 OID 45809)
-- Name: cod_mtstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_n_type ALTER COLUMN cod_mtstmp SET DEFAULT mynow();


--
-- TOC entry 2605 (class 2604 OID 45810)
-- Name: cod_mu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_n_type ALTER COLUMN cod_mu SET DEFAULT mycuser();


--
-- TOC entry 2606 (class 2604 OID 45811)
-- Name: ucod_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ppd_type ALTER COLUMN ucod_id SET DEFAULT nextval('ucod_ucod_id_seq'::regclass);


--
-- TOC entry 2607 (class 2604 OID 45812)
-- Name: cod_etstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ppd_type ALTER COLUMN cod_etstmp SET DEFAULT mynow();


--
-- TOC entry 2608 (class 2604 OID 45813)
-- Name: cod_eu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ppd_type ALTER COLUMN cod_eu SET DEFAULT mycuser();


--
-- TOC entry 2609 (class 2604 OID 45814)
-- Name: cod_mtstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ppd_type ALTER COLUMN cod_mtstmp SET DEFAULT mynow();


--
-- TOC entry 2610 (class 2604 OID 45815)
-- Name: cod_mu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ppd_type ALTER COLUMN cod_mu SET DEFAULT mycuser();


--
-- TOC entry 2611 (class 2604 OID 45816)
-- Name: ucod_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_rqst_atype ALTER COLUMN ucod_id SET DEFAULT nextval('ucod_ucod_id_seq'::regclass);


--
-- TOC entry 2612 (class 2604 OID 45817)
-- Name: cod_etstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_rqst_atype ALTER COLUMN cod_etstmp SET DEFAULT mynow();


--
-- TOC entry 2613 (class 2604 OID 45818)
-- Name: cod_eu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_rqst_atype ALTER COLUMN cod_eu SET DEFAULT mycuser();


--
-- TOC entry 2614 (class 2604 OID 45819)
-- Name: cod_mtstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_rqst_atype ALTER COLUMN cod_mtstmp SET DEFAULT mynow();


--
-- TOC entry 2615 (class 2604 OID 45820)
-- Name: cod_mu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_rqst_atype ALTER COLUMN cod_mu SET DEFAULT mycuser();


--
-- TOC entry 2616 (class 2604 OID 45821)
-- Name: ucod_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_rqst_source ALTER COLUMN ucod_id SET DEFAULT nextval('ucod_ucod_id_seq'::regclass);


--
-- TOC entry 2617 (class 2604 OID 45822)
-- Name: cod_etstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_rqst_source ALTER COLUMN cod_etstmp SET DEFAULT mynow();


--
-- TOC entry 2618 (class 2604 OID 45823)
-- Name: cod_eu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_rqst_source ALTER COLUMN cod_eu SET DEFAULT mycuser();


--
-- TOC entry 2619 (class 2604 OID 45824)
-- Name: cod_mtstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_rqst_source ALTER COLUMN cod_mtstmp SET DEFAULT mynow();


--
-- TOC entry 2620 (class 2604 OID 45825)
-- Name: cod_mu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_rqst_source ALTER COLUMN cod_mu SET DEFAULT mycuser();


--
-- TOC entry 2621 (class 2604 OID 45826)
-- Name: ucod_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_txt_type ALTER COLUMN ucod_id SET DEFAULT nextval('ucod_ucod_id_seq'::regclass);


--
-- TOC entry 2622 (class 2604 OID 45827)
-- Name: cod_etstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_txt_type ALTER COLUMN cod_etstmp SET DEFAULT mynow();


--
-- TOC entry 2623 (class 2604 OID 45828)
-- Name: cod_eu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_txt_type ALTER COLUMN cod_eu SET DEFAULT mycuser();


--
-- TOC entry 2624 (class 2604 OID 45829)
-- Name: cod_mtstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_txt_type ALTER COLUMN cod_mtstmp SET DEFAULT mynow();


--
-- TOC entry 2625 (class 2604 OID 45830)
-- Name: cod_mu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_txt_type ALTER COLUMN cod_mu SET DEFAULT mycuser();


--
-- TOC entry 2656 (class 2604 OID 54254)
-- Name: ucod_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_v_sts ALTER COLUMN ucod_id SET DEFAULT nextval('ucod_ucod_id_seq'::regclass);


--
-- TOC entry 2657 (class 2604 OID 54255)
-- Name: cod_etstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_v_sts ALTER COLUMN cod_etstmp SET DEFAULT mynow();


--
-- TOC entry 2658 (class 2604 OID 54256)
-- Name: cod_eu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_v_sts ALTER COLUMN cod_eu SET DEFAULT mycuser();


--
-- TOC entry 2659 (class 2604 OID 54257)
-- Name: cod_mtstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_v_sts ALTER COLUMN cod_mtstmp SET DEFAULT mynow();


--
-- TOC entry 2660 (class 2604 OID 54258)
-- Name: cod_mu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_v_sts ALTER COLUMN cod_mu SET DEFAULT mycuser();


--
-- TOC entry 2661 (class 2604 OID 54259)
-- Name: v_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY v ALTER COLUMN v_id SET DEFAULT nextval('v_v_id_seq'::regclass);


--
-- TOC entry 2630 (class 2604 OID 45831)
-- Name: xpp_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY xpp ALTER COLUMN xpp_id SET DEFAULT nextval('xpp_xpp_id_seq'::regclass);


--
-- TOC entry 2672 (class 2606 OID 45833)
-- Name: aud_d_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY aud_d
    ADD CONSTRAINT aud_d_pkey PRIMARY KEY (aud_seq, column_name);


--
-- TOC entry 2674 (class 2606 OID 45835)
-- Name: aud_h_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY aud_h
    ADD CONSTRAINT aud_h_pkey PRIMARY KEY (aud_seq);


--
-- TOC entry 2677 (class 2606 OID 45837)
-- Name: cpe_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY cpe
    ADD CONSTRAINT cpe_pkey PRIMARY KEY (pe_id);


--
-- TOC entry 2679 (class 2606 OID 45839)
-- Name: cper_cper_id_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY cper
    ADD CONSTRAINT cper_cper_id_key UNIQUE (cper_id);


--
-- TOC entry 2681 (class 2606 OID 45841)
-- Name: cper_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY cper
    ADD CONSTRAINT cper_pkey PRIMARY KEY (pe_id, cr_name);


--
-- TOC entry 2683 (class 2606 OID 45843)
-- Name: cr_cr_desc_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY cr
    ADD CONSTRAINT cr_cr_desc_key UNIQUE (cr_desc);


--
-- TOC entry 2685 (class 2606 OID 45845)
-- Name: cr_cr_id_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY cr
    ADD CONSTRAINT cr_cr_id_key UNIQUE (cr_id);


--
-- TOC entry 2687 (class 2606 OID 45847)
-- Name: cr_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY cr
    ADD CONSTRAINT cr_pkey PRIMARY KEY (cr_name);


--
-- TOC entry 2689 (class 2606 OID 45849)
-- Name: crm_crm_id_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY crm
    ADD CONSTRAINT crm_crm_id_key UNIQUE (crm_id);


--
-- TOC entry 2691 (class 2606 OID 45851)
-- Name: crm_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY crm
    ADD CONSTRAINT crm_pkey PRIMARY KEY (cr_name, sm_id);


--
-- TOC entry 2693 (class 2606 OID 45853)
-- Name: d_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY d
    ADD CONSTRAINT d_pkey PRIMARY KEY (d_id);


--
-- TOC entry 2696 (class 2606 OID 45855)
-- Name: dual_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY dual
    ADD CONSTRAINT dual_pkey PRIMARY KEY (dual_ident);


--
-- TOC entry 2854 (class 2606 OID 46498)
-- Name: gcod2_codeval1_codetxt_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY gcod2
    ADD CONSTRAINT gcod2_codeval1_codetxt_key UNIQUE (codeval1, codetxt);


--
-- TOC entry 2856 (class 2606 OID 46415)
-- Name: gcod2_codeval1_codeval2_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY gcod2
    ADD CONSTRAINT gcod2_codeval1_codeval2_key UNIQUE (codeval1, codeval2);


--
-- TOC entry 2860 (class 2606 OID 46502)
-- Name: gcod2_d_scope_d_ctgr_codeval1_codetxt_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY gcod2_d_scope_d_ctgr
    ADD CONSTRAINT gcod2_d_scope_d_ctgr_codeval1_codetxt_key UNIQUE (codeval1, codetxt);


--
-- TOC entry 2862 (class 2606 OID 46472)
-- Name: gcod2_d_scope_d_ctgr_codeval1_codeval2_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY gcod2_d_scope_d_ctgr
    ADD CONSTRAINT gcod2_d_scope_d_ctgr_codeval1_codeval2_key UNIQUE (codeval1, codeval2);


--
-- TOC entry 2864 (class 2606 OID 46470)
-- Name: gcod2_d_scope_d_ctgr_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY gcod2_d_scope_d_ctgr
    ADD CONSTRAINT gcod2_d_scope_d_ctgr_pkey PRIMARY KEY (gcod2_id);


--
-- TOC entry 2698 (class 2606 OID 45857)
-- Name: gcod2_h_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY gcod2_h
    ADD CONSTRAINT gcod2_h_pkey PRIMARY KEY (codename);


--
-- TOC entry 2858 (class 2606 OID 46411)
-- Name: gcod2_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY gcod2
    ADD CONSTRAINT gcod2_pkey PRIMARY KEY (gcod2_id);


--
-- TOC entry 2848 (class 2606 OID 46359)
-- Name: gcod_codetxt_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY gcod
    ADD CONSTRAINT gcod_codetxt_key UNIQUE (codetxt);


--
-- TOC entry 2850 (class 2606 OID 46361)
-- Name: gcod_codeval_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY gcod
    ADD CONSTRAINT gcod_codeval_key UNIQUE (codeval);


--
-- TOC entry 2700 (class 2606 OID 45859)
-- Name: gcod_h_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY gcod_h
    ADD CONSTRAINT gcod_h_pkey PRIMARY KEY (codename);


--
-- TOC entry 2852 (class 2606 OID 46357)
-- Name: gcod_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY gcod
    ADD CONSTRAINT gcod_pkey PRIMARY KEY (gcod_id);


--
-- TOC entry 2702 (class 2606 OID 45861)
-- Name: gpp_gpp_process_gpp_attrib_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY gpp
    ADD CONSTRAINT gpp_gpp_process_gpp_attrib_key UNIQUE (gpp_process, gpp_attrib);


--
-- TOC entry 2704 (class 2606 OID 45863)
-- Name: gpp_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY gpp
    ADD CONSTRAINT gpp_pkey PRIMARY KEY (gpp_id);


--
-- TOC entry 2706 (class 2606 OID 45865)
-- Name: h_h_title_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY h
    ADD CONSTRAINT h_h_title_key UNIQUE (h_title);


--
-- TOC entry 2709 (class 2606 OID 45867)
-- Name: h_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY h
    ADD CONSTRAINT h_pkey PRIMARY KEY (h_id);


--
-- TOC entry 2711 (class 2606 OID 45869)
-- Name: hp_hp_code_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY hp
    ADD CONSTRAINT hp_hp_code_key UNIQUE (hp_code);


--
-- TOC entry 2713 (class 2606 OID 45871)
-- Name: hp_hp_desc_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY hp
    ADD CONSTRAINT hp_hp_desc_key UNIQUE (hp_desc);


--
-- TOC entry 2715 (class 2606 OID 45873)
-- Name: hp_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY hp
    ADD CONSTRAINT hp_pkey PRIMARY KEY (hp_id);


--
-- TOC entry 2717 (class 2606 OID 45875)
-- Name: n_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY n
    ADD CONSTRAINT n_pkey PRIMARY KEY (n_id);


--
-- TOC entry 2719 (class 2606 OID 45877)
-- Name: numbers_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY numbers
    ADD CONSTRAINT numbers_pkey PRIMARY KEY (n);


--
-- TOC entry 2722 (class 2606 OID 45879)
-- Name: pe_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY pe
    ADD CONSTRAINT pe_pkey PRIMARY KEY (pe_id);


--
-- TOC entry 2724 (class 2606 OID 45881)
-- Name: ppd_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ppd
    ADD CONSTRAINT ppd_pkey PRIMARY KEY (ppd_id);


--
-- TOC entry 2726 (class 2606 OID 45883)
-- Name: ppd_ppd_process_ppd_attrib_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ppd
    ADD CONSTRAINT ppd_ppd_process_ppd_attrib_key UNIQUE (ppd_process, ppd_attrib);


--
-- TOC entry 2728 (class 2606 OID 45885)
-- Name: ppp_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ppp
    ADD CONSTRAINT ppp_pkey PRIMARY KEY (ppp_id);


--
-- TOC entry 2730 (class 2606 OID 45887)
-- Name: ppp_ppp_process_ppp_attrib_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ppp
    ADD CONSTRAINT ppp_ppp_process_ppp_attrib_key UNIQUE (pe_id, ppp_process, ppp_attrib);


--
-- TOC entry 2732 (class 2606 OID 45889)
-- Name: rq_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY rq
    ADD CONSTRAINT rq_pkey PRIMARY KEY (rq_id);


--
-- TOC entry 2736 (class 2606 OID 45891)
-- Name: rqst_d_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY rqst_d
    ADD CONSTRAINT rqst_d_pkey PRIMARY KEY (rqst_d_id);


--
-- TOC entry 2738 (class 2606 OID 45893)
-- Name: rqst_email_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY rqst_email
    ADD CONSTRAINT rqst_email_pkey PRIMARY KEY (rqst_email_id);


--
-- TOC entry 2740 (class 2606 OID 45895)
-- Name: rqst_n_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY rqst_n
    ADD CONSTRAINT rqst_n_pkey PRIMARY KEY (rqst_n_id);


--
-- TOC entry 2734 (class 2606 OID 45897)
-- Name: rqst_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY rqst
    ADD CONSTRAINT rqst_pkey PRIMARY KEY (rqst_id);


--
-- TOC entry 2742 (class 2606 OID 45899)
-- Name: rqst_rq_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY rqst_rq
    ADD CONSTRAINT rqst_rq_pkey PRIMARY KEY (rqst_rq_id);


--
-- TOC entry 2744 (class 2606 OID 45901)
-- Name: rqst_sms_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY rqst_sms
    ADD CONSTRAINT rqst_sms_pkey PRIMARY KEY (rqst_sms_id);


--
-- TOC entry 2746 (class 2606 OID 45903)
-- Name: sf_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sf
    ADD CONSTRAINT sf_pkey PRIMARY KEY (sf_name);


--
-- TOC entry 2748 (class 2606 OID 45905)
-- Name: sf_sf_desc_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sf
    ADD CONSTRAINT sf_sf_desc_key UNIQUE (sf_desc);


--
-- TOC entry 2750 (class 2606 OID 45907)
-- Name: sf_sf_id_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sf
    ADD CONSTRAINT sf_sf_id_key UNIQUE (sf_id);


--
-- TOC entry 2752 (class 2606 OID 45909)
-- Name: sm_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sm
    ADD CONSTRAINT sm_pkey PRIMARY KEY (sm_id_auto);


--
-- TOC entry 2754 (class 2606 OID 45911)
-- Name: sm_sm_id_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sm
    ADD CONSTRAINT sm_sm_id_key UNIQUE (sm_id);


--
-- TOC entry 2756 (class 2606 OID 45913)
-- Name: sm_sm_id_parent_sm_desc_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sm
    ADD CONSTRAINT sm_sm_id_parent_sm_desc_key UNIQUE (sm_id_parent, sm_desc);


--
-- TOC entry 2758 (class 2606 OID 45915)
-- Name: sm_sm_id_sm_desc_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sm
    ADD CONSTRAINT sm_sm_id_sm_desc_key UNIQUE (sm_id, sm_desc);


--
-- TOC entry 2760 (class 2606 OID 45917)
-- Name: sm_sm_name_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sm
    ADD CONSTRAINT sm_sm_name_key UNIQUE (sm_name);


--
-- TOC entry 2762 (class 2606 OID 45919)
-- Name: spef_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY spef
    ADD CONSTRAINT spef_pkey PRIMARY KEY (pe_id, sf_name);


--
-- TOC entry 2764 (class 2606 OID 45921)
-- Name: spef_spef_id_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY spef
    ADD CONSTRAINT spef_spef_id_key UNIQUE (spef_id);


--
-- TOC entry 2766 (class 2606 OID 45923)
-- Name: sper_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sper
    ADD CONSTRAINT sper_pkey PRIMARY KEY (pe_id, sr_name);


--
-- TOC entry 2768 (class 2606 OID 45925)
-- Name: sper_sper_id_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sper
    ADD CONSTRAINT sper_sper_id_key UNIQUE (sper_id);


--
-- TOC entry 2770 (class 2606 OID 45927)
-- Name: sr_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sr
    ADD CONSTRAINT sr_pkey PRIMARY KEY (sr_name);


--
-- TOC entry 2772 (class 2606 OID 45929)
-- Name: sr_sr_desc_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sr
    ADD CONSTRAINT sr_sr_desc_key UNIQUE (sr_desc);


--
-- TOC entry 2774 (class 2606 OID 45931)
-- Name: sr_sr_id_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sr
    ADD CONSTRAINT sr_sr_id_key UNIQUE (sr_id);


--
-- TOC entry 2776 (class 2606 OID 45933)
-- Name: srm_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY srm
    ADD CONSTRAINT srm_pkey PRIMARY KEY (sr_name, sm_id);


--
-- TOC entry 2778 (class 2606 OID 45935)
-- Name: srm_srm_id_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY srm
    ADD CONSTRAINT srm_srm_id_key UNIQUE (srm_id);


--
-- TOC entry 2780 (class 2606 OID 45937)
-- Name: txt_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY txt
    ADD CONSTRAINT txt_pkey PRIMARY KEY (txt_id);


--
-- TOC entry 2782 (class 2606 OID 45939)
-- Name: txt_txt_process_txt_attrib_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY txt
    ADD CONSTRAINT txt_txt_process_txt_attrib_key UNIQUE (txt_process, txt_attrib);


--
-- TOC entry 2788 (class 2606 OID 45941)
-- Name: ucod2_codetxt_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod2
    ADD CONSTRAINT ucod2_codetxt_key UNIQUE (codetxt);


--
-- TOC entry 2790 (class 2606 OID 45943)
-- Name: ucod2_codeval1_codeval2_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod2
    ADD CONSTRAINT ucod2_codeval1_codeval2_key UNIQUE (codeval1, codeval2);


--
-- TOC entry 2794 (class 2606 OID 45945)
-- Name: ucod2_country_state_codetxt_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod2_country_state
    ADD CONSTRAINT ucod2_country_state_codetxt_key UNIQUE (codetxt);


--
-- TOC entry 2796 (class 2606 OID 45947)
-- Name: ucod2_country_state_codeval1_codeval2_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod2_country_state
    ADD CONSTRAINT ucod2_country_state_codeval1_codeval2_key UNIQUE (codeval1, codeval2);


--
-- TOC entry 2798 (class 2606 OID 45949)
-- Name: ucod2_country_state_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod2_country_state
    ADD CONSTRAINT ucod2_country_state_pkey PRIMARY KEY (ucod2_id);


--
-- TOC entry 2872 (class 2606 OID 49514)
-- Name: ucod2_h_codeschema_codename_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod2_h
    ADD CONSTRAINT ucod2_h_codeschema_codename_key UNIQUE (codeschema, codename);


--
-- TOC entry 2874 (class 2606 OID 49512)
-- Name: ucod2_h_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod2_h
    ADD CONSTRAINT ucod2_h_pkey PRIMARY KEY (ucod2_h_id);


--
-- TOC entry 2792 (class 2606 OID 45951)
-- Name: ucod2_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod2
    ADD CONSTRAINT ucod2_pkey PRIMARY KEY (ucod2_id);


--
-- TOC entry 2804 (class 2606 OID 45953)
-- Name: ucod_ac1_codeval_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ac1
    ADD CONSTRAINT ucod_ac1_codeval_key UNIQUE (codeval);


--
-- TOC entry 2806 (class 2606 OID 45955)
-- Name: ucod_ac1_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ac1
    ADD CONSTRAINT ucod_ac1_pkey PRIMARY KEY (ucod_id);


--
-- TOC entry 2800 (class 2606 OID 45957)
-- Name: ucod_ac_codeval_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ac
    ADD CONSTRAINT ucod_ac_codeval_key UNIQUE (codeval);


--
-- TOC entry 2802 (class 2606 OID 45959)
-- Name: ucod_ac_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ac
    ADD CONSTRAINT ucod_ac_pkey PRIMARY KEY (ucod_id);


--
-- TOC entry 2808 (class 2606 OID 45961)
-- Name: ucod_ahc_codeval_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ahc
    ADD CONSTRAINT ucod_ahc_codeval_key UNIQUE (codeval);


--
-- TOC entry 2810 (class 2606 OID 45963)
-- Name: ucod_ahc_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ahc
    ADD CONSTRAINT ucod_ahc_pkey PRIMARY KEY (ucod_id);


--
-- TOC entry 2784 (class 2606 OID 45965)
-- Name: ucod_codeval_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod
    ADD CONSTRAINT ucod_codeval_key UNIQUE (codeval);


--
-- TOC entry 2812 (class 2606 OID 45967)
-- Name: ucod_country_codeval_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_country
    ADD CONSTRAINT ucod_country_codeval_key UNIQUE (codeval);


--
-- TOC entry 2814 (class 2606 OID 45969)
-- Name: ucod_country_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_country
    ADD CONSTRAINT ucod_country_pkey PRIMARY KEY (ucod_id);


--
-- TOC entry 2816 (class 2606 OID 45971)
-- Name: ucod_d_scope_codeval_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_d_scope
    ADD CONSTRAINT ucod_d_scope_codeval_key UNIQUE (codeval);


--
-- TOC entry 2818 (class 2606 OID 45973)
-- Name: ucod_d_scope_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_d_scope
    ADD CONSTRAINT ucod_d_scope_pkey PRIMARY KEY (ucod_id);


--
-- TOC entry 2867 (class 2606 OID 49499)
-- Name: ucod_h_codeschema_codename_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_h
    ADD CONSTRAINT ucod_h_codeschema_codename_key UNIQUE (codeschema, codename);


--
-- TOC entry 2869 (class 2606 OID 49497)
-- Name: ucod_h_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_h
    ADD CONSTRAINT ucod_h_pkey PRIMARY KEY (ucod_h_id);


--
-- TOC entry 2820 (class 2606 OID 45975)
-- Name: ucod_n_scope_codeval_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_n_scope
    ADD CONSTRAINT ucod_n_scope_codeval_key UNIQUE (codeval);


--
-- TOC entry 2822 (class 2606 OID 45977)
-- Name: ucod_n_scope_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_n_scope
    ADD CONSTRAINT ucod_n_scope_pkey PRIMARY KEY (ucod_id);


--
-- TOC entry 2824 (class 2606 OID 45979)
-- Name: ucod_n_type_codeval_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_n_type
    ADD CONSTRAINT ucod_n_type_codeval_key UNIQUE (codeval);


--
-- TOC entry 2826 (class 2606 OID 45981)
-- Name: ucod_n_type_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_n_type
    ADD CONSTRAINT ucod_n_type_pkey PRIMARY KEY (ucod_id);


--
-- TOC entry 2786 (class 2606 OID 45983)
-- Name: ucod_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod
    ADD CONSTRAINT ucod_pkey PRIMARY KEY (ucod_id);


--
-- TOC entry 2828 (class 2606 OID 45985)
-- Name: ucod_ppd_type_codeval_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ppd_type
    ADD CONSTRAINT ucod_ppd_type_codeval_key UNIQUE (codeval);


--
-- TOC entry 2830 (class 2606 OID 45987)
-- Name: ucod_ppd_type_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ppd_type
    ADD CONSTRAINT ucod_ppd_type_pkey PRIMARY KEY (ucod_id);


--
-- TOC entry 2832 (class 2606 OID 45989)
-- Name: ucod_rqst_atype_codeval_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_rqst_atype
    ADD CONSTRAINT ucod_rqst_atype_codeval_key UNIQUE (codeval);


--
-- TOC entry 2834 (class 2606 OID 45991)
-- Name: ucod_rqst_atype_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_rqst_atype
    ADD CONSTRAINT ucod_rqst_atype_pkey PRIMARY KEY (ucod_id);


--
-- TOC entry 2836 (class 2606 OID 45993)
-- Name: ucod_rqst_source_codeval_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_rqst_source
    ADD CONSTRAINT ucod_rqst_source_codeval_key UNIQUE (codeval);


--
-- TOC entry 2838 (class 2606 OID 45995)
-- Name: ucod_rqst_source_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_rqst_source
    ADD CONSTRAINT ucod_rqst_source_pkey PRIMARY KEY (ucod_id);


--
-- TOC entry 2840 (class 2606 OID 45997)
-- Name: ucod_txt_type_codeval_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_txt_type
    ADD CONSTRAINT ucod_txt_type_codeval_key UNIQUE (codeval);


--
-- TOC entry 2842 (class 2606 OID 45999)
-- Name: ucod_txt_type_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_txt_type
    ADD CONSTRAINT ucod_txt_type_pkey PRIMARY KEY (ucod_id);


--
-- TOC entry 2876 (class 2606 OID 54261)
-- Name: ucod_v_sts_codetxt_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_v_sts
    ADD CONSTRAINT ucod_v_sts_codetxt_key UNIQUE (codetxt);


--
-- TOC entry 2878 (class 2606 OID 54263)
-- Name: ucod_v_sts_codeval_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_v_sts
    ADD CONSTRAINT ucod_v_sts_codeval_key UNIQUE (codeval);


--
-- TOC entry 2880 (class 2606 OID 54265)
-- Name: ucod_v_sts_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_v_sts
    ADD CONSTRAINT ucod_v_sts_pkey PRIMARY KEY (ucod_id);


--
-- TOC entry 2882 (class 2606 OID 54267)
-- Name: v_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY v
    ADD CONSTRAINT v_pkey PRIMARY KEY (v_id);


--
-- TOC entry 2884 (class 2606 OID 54269)
-- Name: v_v_no_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY v
    ADD CONSTRAINT v_v_no_key UNIQUE (v_no_major, v_no_minor, v_no_build, v_no_rev);


--
-- TOC entry 2844 (class 2606 OID 46001)
-- Name: xpp_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY xpp
    ADD CONSTRAINT xpp_pkey PRIMARY KEY (xpp_id);


--
-- TOC entry 2846 (class 2606 OID 46003)
-- Name: xpp_xpp_process_xpp_attrib_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY xpp
    ADD CONSTRAINT xpp_xpp_process_xpp_attrib_key UNIQUE (xpp_process, xpp_attrib);


--
-- TOC entry 2675 (class 1259 OID 46004)
-- Name: cpe_pe_email_unique; Type: INDEX; Schema: jsharmony; Owner: postgres
--

CREATE UNIQUE INDEX cpe_pe_email_unique ON cpe USING btree (lower((pe_email)::text)) WHERE ((pe_sts)::text = 'ACTIVE'::text);


--
-- TOC entry 2694 (class 1259 OID 46508)
-- Name: fki_d_d_scope_d_ctgr; Type: INDEX; Schema: jsharmony; Owner: postgres
--

CREATE INDEX fki_d_d_scope_d_ctgr ON d USING btree (d_scope, d_ctgr);


--
-- TOC entry 2707 (class 1259 OID 46005)
-- Name: h_hp_code_unique; Type: INDEX; Schema: jsharmony; Owner: postgres
--

CREATE UNIQUE INDEX h_hp_code_unique ON h USING btree (hp_code) WHERE (hp_code IS NOT NULL);


--
-- TOC entry 2720 (class 1259 OID 46006)
-- Name: pe_pe_email_unique; Type: INDEX; Schema: jsharmony; Owner: postgres
--

CREATE UNIQUE INDEX pe_pe_email_unique ON pe USING btree (lower((pe_email)::text)) WHERE ((pe_sts)::text = 'ACTIVE'::text);


--
-- TOC entry 2870 (class 1259 OID 49515)
-- Name: ucod2_h_coalesce_codename_idx; Type: INDEX; Schema: jsharmony; Owner: postgres
--

CREATE UNIQUE INDEX ucod2_h_coalesce_codename_idx ON ucod2_h USING btree ((COALESCE(codeschema, '*** NULL IS HERE ***'::character varying)), codename);


--
-- TOC entry 2865 (class 1259 OID 49500)
-- Name: ucod_h_coalesce_codename_idx; Type: INDEX; Schema: jsharmony; Owner: postgres
--

CREATE UNIQUE INDEX ucod_h_coalesce_codename_idx ON ucod_h USING btree ((COALESCE(codeschema, '*** NULL IS HERE ***'::character varying)), codename);


--
-- TOC entry 2926 (class 2620 OID 46007)
-- Name: cpe_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER cpe_iud BEFORE INSERT OR DELETE OR UPDATE ON cpe FOR EACH ROW EXECUTE PROCEDURE cpe_iud();


--
-- TOC entry 2927 (class 2620 OID 46008)
-- Name: cper_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER cper_iud BEFORE INSERT OR DELETE OR UPDATE ON cper FOR EACH ROW EXECUTE PROCEDURE cper_iud();


--
-- TOC entry 2928 (class 2620 OID 46009)
-- Name: d_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER d_iud BEFORE INSERT OR DELETE OR UPDATE ON d FOR EACH ROW EXECUTE PROCEDURE d_iud();


--
-- TOC entry 2943 (class 2620 OID 46475)
-- Name: gcod2_d_scope_d_ctgr_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER gcod2_d_scope_d_ctgr_iud BEFORE INSERT OR DELETE OR UPDATE ON gcod2_d_scope_d_ctgr FOR EACH ROW EXECUTE PROCEDURE gcod2_iud();


--
-- TOC entry 2942 (class 2620 OID 46416)
-- Name: gcod2_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER gcod2_iud BEFORE INSERT OR DELETE OR UPDATE ON gcod2 FOR EACH ROW EXECUTE PROCEDURE gcod2_iud();


--
-- TOC entry 2941 (class 2620 OID 46362)
-- Name: gcod_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER gcod_iud BEFORE INSERT OR DELETE OR UPDATE ON gcod FOR EACH ROW EXECUTE PROCEDURE gcod_iud();


--
-- TOC entry 2929 (class 2620 OID 46010)
-- Name: gpp_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER gpp_iud BEFORE INSERT OR DELETE OR UPDATE ON gpp FOR EACH ROW EXECUTE PROCEDURE gpp_iud();


--
-- TOC entry 2930 (class 2620 OID 46011)
-- Name: h_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER h_iud BEFORE INSERT OR DELETE OR UPDATE ON h FOR EACH ROW EXECUTE PROCEDURE h_iud();


--
-- TOC entry 2931 (class 2620 OID 46012)
-- Name: n_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER n_iud BEFORE INSERT OR DELETE OR UPDATE ON n FOR EACH ROW EXECUTE PROCEDURE n_iud();


--
-- TOC entry 2932 (class 2620 OID 46013)
-- Name: pe_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER pe_iud BEFORE INSERT OR DELETE OR UPDATE ON pe FOR EACH ROW EXECUTE PROCEDURE pe_iud();


--
-- TOC entry 2933 (class 2620 OID 46014)
-- Name: ppd_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER ppd_iud BEFORE INSERT OR DELETE OR UPDATE ON ppd FOR EACH ROW EXECUTE PROCEDURE ppd_iud();


--
-- TOC entry 2934 (class 2620 OID 46015)
-- Name: ppp_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER ppp_iud BEFORE INSERT OR DELETE OR UPDATE ON ppp FOR EACH ROW EXECUTE PROCEDURE ppp_iud();


--
-- TOC entry 2935 (class 2620 OID 46016)
-- Name: spef_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER spef_iud BEFORE INSERT OR DELETE OR UPDATE ON spef FOR EACH ROW EXECUTE PROCEDURE spef_iud();


--
-- TOC entry 2936 (class 2620 OID 46017)
-- Name: sper_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER sper_iud BEFORE INSERT OR DELETE OR UPDATE ON sper FOR EACH ROW EXECUTE PROCEDURE sper_iud();


--
-- TOC entry 2937 (class 2620 OID 46018)
-- Name: txt_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER txt_iud BEFORE INSERT OR DELETE OR UPDATE ON txt FOR EACH ROW EXECUTE PROCEDURE txt_iud();


--
-- TOC entry 2938 (class 2620 OID 46019)
-- Name: v_crmsel_iud_insteadof_update; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER v_crmsel_iud_insteadof_update INSTEAD OF UPDATE ON v_crmsel FOR EACH ROW EXECUTE PROCEDURE v_crmsel_iud_insteadof_update();


--
-- TOC entry 2940 (class 2620 OID 46020)
-- Name: v_srmsel_iud_insteadof_update; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER v_srmsel_iud_insteadof_update INSTEAD OF UPDATE ON v_srmsel FOR EACH ROW EXECUTE PROCEDURE v_srmsel_iud_insteadof_update();


--
-- TOC entry 2939 (class 2620 OID 46021)
-- Name: xpp_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER xpp_iud BEFORE INSERT OR DELETE OR UPDATE ON xpp FOR EACH ROW EXECUTE PROCEDURE xpp_iud();


--
-- TOC entry 2885 (class 2606 OID 46022)
-- Name: aud_d_aud_seq_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY aud_d
    ADD CONSTRAINT aud_d_aud_seq_fkey FOREIGN KEY (aud_seq) REFERENCES aud_h(aud_seq);


--
-- TOC entry 2886 (class 2606 OID 46027)
-- Name: cpe_pe_sts_ucod_ahc_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY cpe
    ADD CONSTRAINT cpe_pe_sts_ucod_ahc_fkey FOREIGN KEY (pe_sts) REFERENCES ucod_ahc(codeval);


--
-- TOC entry 2887 (class 2606 OID 46032)
-- Name: cper_cr_name_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY cper
    ADD CONSTRAINT cper_cr_name_fkey FOREIGN KEY (cr_name) REFERENCES cr(cr_name);


--
-- TOC entry 2888 (class 2606 OID 46037)
-- Name: cper_pe_id_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY cper
    ADD CONSTRAINT cper_pe_id_fkey FOREIGN KEY (pe_id) REFERENCES cpe(pe_id) ON DELETE CASCADE;


--
-- TOC entry 2889 (class 2606 OID 46042)
-- Name: cr_cr_sts_ucod_ahc_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY cr
    ADD CONSTRAINT cr_cr_sts_ucod_ahc_fkey FOREIGN KEY (cr_sts) REFERENCES ucod_ahc(codeval);


--
-- TOC entry 2890 (class 2606 OID 46047)
-- Name: crm_cr_name_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY crm
    ADD CONSTRAINT crm_cr_name_fkey FOREIGN KEY (cr_name) REFERENCES cr(cr_name);


--
-- TOC entry 2891 (class 2606 OID 46052)
-- Name: crm_sm_id_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY crm
    ADD CONSTRAINT crm_sm_id_fkey FOREIGN KEY (sm_id) REFERENCES sm(sm_id);


--
-- TOC entry 2893 (class 2606 OID 46503)
-- Name: d_d_scope_d_ctgr; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY d
    ADD CONSTRAINT d_d_scope_d_ctgr FOREIGN KEY (d_scope, d_ctgr) REFERENCES gcod2_d_scope_d_ctgr(codeval1, codeval2);


--
-- TOC entry 2892 (class 2606 OID 46057)
-- Name: d_d_scope_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY d
    ADD CONSTRAINT d_d_scope_fkey FOREIGN KEY (d_scope) REFERENCES ucod_d_scope(codeval);


--
-- TOC entry 2894 (class 2606 OID 46062)
-- Name: gpp_ppd_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY gpp
    ADD CONSTRAINT gpp_ppd_fkey FOREIGN KEY (gpp_process, gpp_attrib) REFERENCES ppd(ppd_process, ppd_attrib);


--
-- TOC entry 2895 (class 2606 OID 46067)
-- Name: h_hp_code_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY h
    ADD CONSTRAINT h_hp_code_fkey FOREIGN KEY (hp_code) REFERENCES hp(hp_code);


--
-- TOC entry 2896 (class 2606 OID 46072)
-- Name: n_n_scope_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY n
    ADD CONSTRAINT n_n_scope_fkey FOREIGN KEY (n_scope) REFERENCES ucod_n_scope(codeval);


--
-- TOC entry 2897 (class 2606 OID 46077)
-- Name: n_n_sts_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY n
    ADD CONSTRAINT n_n_sts_fkey FOREIGN KEY (n_sts) REFERENCES ucod_ac1(codeval);


--
-- TOC entry 2898 (class 2606 OID 46082)
-- Name: n_n_type_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY n
    ADD CONSTRAINT n_n_type_fkey FOREIGN KEY (n_type) REFERENCES ucod_n_type(codeval);


--
-- TOC entry 2899 (class 2606 OID 46087)
-- Name: pe_pe_sts_ucod_ahc_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY pe
    ADD CONSTRAINT pe_pe_sts_ucod_ahc_fkey FOREIGN KEY (pe_sts) REFERENCES ucod_ahc(codeval);


--
-- TOC entry 2900 (class 2606 OID 46092)
-- Name: pe_ucod2_country_state_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY pe
    ADD CONSTRAINT pe_ucod2_country_state_fkey FOREIGN KEY (pe_country, pe_state) REFERENCES ucod2_country_state(codeval1, codeval2);


--
-- TOC entry 2901 (class 2606 OID 46097)
-- Name: pe_ucod_country_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY pe
    ADD CONSTRAINT pe_ucod_country_fkey FOREIGN KEY (pe_country) REFERENCES ucod_country(codeval);


--
-- TOC entry 2902 (class 2606 OID 46102)
-- Name: ppd_ucod_ppd_type_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ppd
    ADD CONSTRAINT ppd_ucod_ppd_type_fkey FOREIGN KEY (ppd_type) REFERENCES ucod_ppd_type(codeval);


--
-- TOC entry 2903 (class 2606 OID 46107)
-- Name: ppp_pe_id_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ppp
    ADD CONSTRAINT ppp_pe_id_fkey FOREIGN KEY (pe_id) REFERENCES pe(pe_id);


--
-- TOC entry 2904 (class 2606 OID 46112)
-- Name: ppp_ppd_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ppp
    ADD CONSTRAINT ppp_ppd_fkey FOREIGN KEY (ppp_process, ppp_attrib) REFERENCES ppd(ppd_process, ppd_attrib);


--
-- TOC entry 2907 (class 2606 OID 46117)
-- Name: rqst_d_rqst_id_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY rqst_d
    ADD CONSTRAINT rqst_d_rqst_id_fkey FOREIGN KEY (rqst_id) REFERENCES rqst(rqst_id);


--
-- TOC entry 2908 (class 2606 OID 46122)
-- Name: rqst_email_d_id_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY rqst_email
    ADD CONSTRAINT rqst_email_d_id_fkey FOREIGN KEY (email_d_id) REFERENCES d(d_id);


--
-- TOC entry 2909 (class 2606 OID 46127)
-- Name: rqst_email_rqst_id_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY rqst_email
    ADD CONSTRAINT rqst_email_rqst_id_fkey FOREIGN KEY (rqst_id) REFERENCES rqst(rqst_id);


--
-- TOC entry 2910 (class 2606 OID 46132)
-- Name: rqst_n_rqst_id_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY rqst_n
    ADD CONSTRAINT rqst_n_rqst_id_fkey FOREIGN KEY (rqst_id) REFERENCES rqst(rqst_id);


--
-- TOC entry 2911 (class 2606 OID 46137)
-- Name: rqst_rq_rqst_id_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY rqst_rq
    ADD CONSTRAINT rqst_rq_rqst_id_fkey FOREIGN KEY (rqst_id) REFERENCES rqst(rqst_id);


--
-- TOC entry 2912 (class 2606 OID 46142)
-- Name: rqst_sms_rqst_id_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY rqst_sms
    ADD CONSTRAINT rqst_sms_rqst_id_fkey FOREIGN KEY (rqst_id) REFERENCES rqst(rqst_id);


--
-- TOC entry 2905 (class 2606 OID 46147)
-- Name: rqst_ucod_rqst_atype_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY rqst
    ADD CONSTRAINT rqst_ucod_rqst_atype_fkey FOREIGN KEY (rqst_atype) REFERENCES ucod_rqst_atype(codeval);


--
-- TOC entry 2906 (class 2606 OID 46152)
-- Name: rqst_ucod_rqst_source_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY rqst
    ADD CONSTRAINT rqst_ucod_rqst_source_fkey FOREIGN KEY (rqst_source) REFERENCES ucod_rqst_source(codeval);


--
-- TOC entry 2913 (class 2606 OID 46157)
-- Name: sf_sf_sts_ucod_ahc_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sf
    ADD CONSTRAINT sf_sf_sts_ucod_ahc_fkey FOREIGN KEY (sf_sts) REFERENCES ucod_ahc(codeval);


--
-- TOC entry 2915 (class 2606 OID 46219)
-- Name: sm_sm_id_parent_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sm
    ADD CONSTRAINT sm_sm_id_parent_fkey FOREIGN KEY (sm_id_parent) REFERENCES sm(sm_id);


--
-- TOC entry 2914 (class 2606 OID 46167)
-- Name: sm_sm_sts_ucod_ahc_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sm
    ADD CONSTRAINT sm_sm_sts_ucod_ahc_fkey FOREIGN KEY (sm_sts) REFERENCES ucod_ahc(codeval);


--
-- TOC entry 2916 (class 2606 OID 46172)
-- Name: spef_pe_id_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY spef
    ADD CONSTRAINT spef_pe_id_fkey FOREIGN KEY (pe_id) REFERENCES pe(pe_id);


--
-- TOC entry 2917 (class 2606 OID 46177)
-- Name: spef_sf_name_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY spef
    ADD CONSTRAINT spef_sf_name_fkey FOREIGN KEY (sf_name) REFERENCES sf(sf_name);


--
-- TOC entry 2918 (class 2606 OID 46182)
-- Name: sper_pe_id_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sper
    ADD CONSTRAINT sper_pe_id_fkey FOREIGN KEY (pe_id) REFERENCES pe(pe_id);


--
-- TOC entry 2919 (class 2606 OID 46187)
-- Name: sper_sr_name_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sper
    ADD CONSTRAINT sper_sr_name_fkey FOREIGN KEY (sr_name) REFERENCES sr(sr_name);


--
-- TOC entry 2920 (class 2606 OID 46192)
-- Name: sr_sr_sts_ucod_ahc_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sr
    ADD CONSTRAINT sr_sr_sts_ucod_ahc_fkey FOREIGN KEY (sr_sts) REFERENCES ucod_ahc(codeval);


--
-- TOC entry 2922 (class 2606 OID 46236)
-- Name: srm_sm_id_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY srm
    ADD CONSTRAINT srm_sm_id_fkey FOREIGN KEY (sm_id) REFERENCES sm(sm_id) ON DELETE CASCADE;


--
-- TOC entry 2921 (class 2606 OID 46202)
-- Name: srm_sr_name_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY srm
    ADD CONSTRAINT srm_sr_name_fkey FOREIGN KEY (sr_name) REFERENCES sr(sr_name);


--
-- TOC entry 2923 (class 2606 OID 46207)
-- Name: txt_ucod_txt_type_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY txt
    ADD CONSTRAINT txt_ucod_txt_type_fkey FOREIGN KEY (txt_type) REFERENCES ucod_txt_type(codeval);


--
-- TOC entry 2925 (class 2606 OID 54270)
-- Name: v_v_sts_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY v
    ADD CONSTRAINT v_v_sts_fkey FOREIGN KEY (v_sts) REFERENCES ucod_v_sts(codeval);


--
-- TOC entry 2924 (class 2606 OID 46212)
-- Name: xpp_ppd_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY xpp
    ADD CONSTRAINT xpp_ppd_fkey FOREIGN KEY (xpp_process, xpp_attrib) REFERENCES ppd(ppd_process, ppd_attrib);


--
-- TOC entry 3081 (class 0 OID 0)
-- Dependencies: 8
-- Name: jsharmony; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA jsharmony FROM PUBLIC;
REVOKE ALL ON SCHEMA jsharmony FROM postgres;
GRANT ALL ON SCHEMA jsharmony TO postgres;
GRANT USAGE ON SCHEMA jsharmony TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;
GRANT USAGE ON SCHEMA jsharmony TO jsharmony_%%%INIT_DB_LCASE%%%_role_dev;


--
-- TOC entry 3082 (class 0 OID 0)
-- Dependencies: 348
-- Name: audit(toaudit, bigint, bigint, character varying, text); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION audit(toa toaudit, INOUT par_aud_seq bigint, par_table_id bigint, par_column_name character varying, par_column_val text) FROM PUBLIC;
REVOKE ALL ON FUNCTION audit(toa toaudit, INOUT par_aud_seq bigint, par_table_id bigint, par_column_name character varying, par_column_val text) FROM postgres;
GRANT ALL ON FUNCTION audit(toa toaudit, INOUT par_aud_seq bigint, par_table_id bigint, par_column_name character varying, par_column_val text) TO postgres;
GRANT ALL ON FUNCTION audit(toa toaudit, INOUT par_aud_seq bigint, par_table_id bigint, par_column_name character varying, par_column_val text) TO PUBLIC;
GRANT ALL ON FUNCTION audit(toa toaudit, INOUT par_aud_seq bigint, par_table_id bigint, par_column_name character varying, par_column_val text) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3083 (class 0 OID 0)
-- Dependencies: 344
-- Name: audit_base(toaudit, bigint, bigint, character varying, text); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION audit_base(toa toaudit, INOUT par_aud_seq bigint, par_table_id bigint, par_column_name character varying, par_column_val text) FROM PUBLIC;
REVOKE ALL ON FUNCTION audit_base(toa toaudit, INOUT par_aud_seq bigint, par_table_id bigint, par_column_name character varying, par_column_val text) FROM postgres;
GRANT ALL ON FUNCTION audit_base(toa toaudit, INOUT par_aud_seq bigint, par_table_id bigint, par_column_name character varying, par_column_val text) TO postgres;
GRANT ALL ON FUNCTION audit_base(toa toaudit, INOUT par_aud_seq bigint, par_table_id bigint, par_column_name character varying, par_column_val text) TO PUBLIC;
GRANT ALL ON FUNCTION audit_base(toa toaudit, INOUT par_aud_seq bigint, par_table_id bigint, par_column_name character varying, par_column_val text) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3084 (class 0 OID 0)
-- Dependencies: 315
-- Name: audit_info(timestamp without time zone, character varying, timestamp without time zone, character varying); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION audit_info(timestamp without time zone, character varying, timestamp without time zone, character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION audit_info(timestamp without time zone, character varying, timestamp without time zone, character varying) FROM postgres;
GRANT ALL ON FUNCTION audit_info(timestamp without time zone, character varying, timestamp without time zone, character varying) TO postgres;
GRANT ALL ON FUNCTION audit_info(timestamp without time zone, character varying, timestamp without time zone, character varying) TO PUBLIC;
GRANT ALL ON FUNCTION audit_info(timestamp without time zone, character varying, timestamp without time zone, character varying) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3085 (class 0 OID 0)
-- Dependencies: 306
-- Name: check_code(character varying, character varying); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION check_code(in_tblname character varying, in_codeval character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION check_code(in_tblname character varying, in_codeval character varying) FROM postgres;
GRANT ALL ON FUNCTION check_code(in_tblname character varying, in_codeval character varying) TO postgres;
GRANT ALL ON FUNCTION check_code(in_tblname character varying, in_codeval character varying) TO PUBLIC;
GRANT ALL ON FUNCTION check_code(in_tblname character varying, in_codeval character varying) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3086 (class 0 OID 0)
-- Dependencies: 305
-- Name: check_code2(character varying, character varying, character varying); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION check_code2(in_tblname character varying, in_codeval1 character varying, in_codeval2 character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION check_code2(in_tblname character varying, in_codeval1 character varying, in_codeval2 character varying) FROM postgres;
GRANT ALL ON FUNCTION check_code2(in_tblname character varying, in_codeval1 character varying, in_codeval2 character varying) TO postgres;
GRANT ALL ON FUNCTION check_code2(in_tblname character varying, in_codeval1 character varying, in_codeval2 character varying) TO PUBLIC;
GRANT ALL ON FUNCTION check_code2(in_tblname character varying, in_codeval1 character varying, in_codeval2 character varying) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3087 (class 0 OID 0)
-- Dependencies: 342
-- Name: check_code2_p(character varying, character varying, character varying); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION check_code2_p(in_tblname character varying, in_codeval1 character varying, in_codeval2 character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION check_code2_p(in_tblname character varying, in_codeval1 character varying, in_codeval2 character varying) FROM postgres;
GRANT ALL ON FUNCTION check_code2_p(in_tblname character varying, in_codeval1 character varying, in_codeval2 character varying) TO postgres;
GRANT ALL ON FUNCTION check_code2_p(in_tblname character varying, in_codeval1 character varying, in_codeval2 character varying) TO PUBLIC;
GRANT ALL ON FUNCTION check_code2_p(in_tblname character varying, in_codeval1 character varying, in_codeval2 character varying) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3088 (class 0 OID 0)
-- Dependencies: 334
-- Name: check_code_p(character varying, character varying); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION check_code_p(in_tblname character varying, in_codeval character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION check_code_p(in_tblname character varying, in_codeval character varying) FROM postgres;
GRANT ALL ON FUNCTION check_code_p(in_tblname character varying, in_codeval character varying) TO postgres;
GRANT ALL ON FUNCTION check_code_p(in_tblname character varying, in_codeval character varying) TO PUBLIC;
GRANT ALL ON FUNCTION check_code_p(in_tblname character varying, in_codeval character varying) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3089 (class 0 OID 0)
-- Dependencies: 336
-- Name: check_foreign(character varying, bigint); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION check_foreign(in_tblname character varying, in_tblid bigint) FROM PUBLIC;
REVOKE ALL ON FUNCTION check_foreign(in_tblname character varying, in_tblid bigint) FROM postgres;
GRANT ALL ON FUNCTION check_foreign(in_tblname character varying, in_tblid bigint) TO postgres;
GRANT ALL ON FUNCTION check_foreign(in_tblname character varying, in_tblid bigint) TO PUBLIC;
GRANT ALL ON FUNCTION check_foreign(in_tblname character varying, in_tblid bigint) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3090 (class 0 OID 0)
-- Dependencies: 337
-- Name: check_foreign_p(character varying, bigint); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION check_foreign_p(in_tblname character varying, in_tblid bigint) FROM PUBLIC;
REVOKE ALL ON FUNCTION check_foreign_p(in_tblname character varying, in_tblid bigint) FROM postgres;
GRANT ALL ON FUNCTION check_foreign_p(in_tblname character varying, in_tblid bigint) TO postgres;
GRANT ALL ON FUNCTION check_foreign_p(in_tblname character varying, in_tblid bigint) TO PUBLIC;
GRANT ALL ON FUNCTION check_foreign_p(in_tblname character varying, in_tblid bigint) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3091 (class 0 OID 0)
-- Dependencies: 361
-- Name: check_pp(character varying, character varying, character varying, character varying); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION check_pp(in_table character varying, in_process character varying, in_attrib character varying, in_val character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION check_pp(in_table character varying, in_process character varying, in_attrib character varying, in_val character varying) FROM postgres;
GRANT ALL ON FUNCTION check_pp(in_table character varying, in_process character varying, in_attrib character varying, in_val character varying) TO postgres;
GRANT ALL ON FUNCTION check_pp(in_table character varying, in_process character varying, in_attrib character varying, in_val character varying) TO PUBLIC;
GRANT ALL ON FUNCTION check_pp(in_table character varying, in_process character varying, in_attrib character varying, in_val character varying) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION check_pp(in_table character varying, in_process character varying, in_attrib character varying, in_val character varying) TO jsharmony_harp_role_exec;


--
-- TOC entry 3092 (class 0 OID 0)
-- Dependencies: 356
-- Name: cpe_iud(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION cpe_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION cpe_iud() FROM postgres;
GRANT ALL ON FUNCTION cpe_iud() TO postgres;
GRANT ALL ON FUNCTION cpe_iud() TO PUBLIC;
GRANT ALL ON FUNCTION cpe_iud() TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3093 (class 0 OID 0)
-- Dependencies: 357
-- Name: cper_iud(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION cper_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION cper_iud() FROM postgres;
GRANT ALL ON FUNCTION cper_iud() TO postgres;
GRANT ALL ON FUNCTION cper_iud() TO PUBLIC;
GRANT ALL ON FUNCTION cper_iud() TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3094 (class 0 OID 0)
-- Dependencies: 347
-- Name: create_gcod(character varying, character varying, character varying); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION create_gcod(in_codeschema character varying, in_codename character varying, in_codemean character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION create_gcod(in_codeschema character varying, in_codename character varying, in_codemean character varying) FROM postgres;
GRANT ALL ON FUNCTION create_gcod(in_codeschema character varying, in_codename character varying, in_codemean character varying) TO postgres;
GRANT ALL ON FUNCTION create_gcod(in_codeschema character varying, in_codename character varying, in_codemean character varying) TO jsharmony_%%%INIT_DB_LCASE%%%_role_dev;


--
-- TOC entry 3095 (class 0 OID 0)
-- Dependencies: 339
-- Name: create_gcod2(character varying, character varying, character varying); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION create_gcod2(in_codeschema character varying, in_codename character varying, in_codemean character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION create_gcod2(in_codeschema character varying, in_codename character varying, in_codemean character varying) FROM postgres;
GRANT ALL ON FUNCTION create_gcod2(in_codeschema character varying, in_codename character varying, in_codemean character varying) TO postgres;
GRANT ALL ON FUNCTION create_gcod2(in_codeschema character varying, in_codename character varying, in_codemean character varying) TO jsharmony_%%%INIT_DB_LCASE%%%_role_dev;


--
-- TOC entry 3096 (class 0 OID 0)
-- Dependencies: 332
-- Name: create_ucod(character varying, character varying, character varying); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION create_ucod(in_codeschema character varying, in_codename character varying, in_codemean character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION create_ucod(in_codeschema character varying, in_codename character varying, in_codemean character varying) FROM postgres;
GRANT ALL ON FUNCTION create_ucod(in_codeschema character varying, in_codename character varying, in_codemean character varying) TO postgres;
GRANT ALL ON FUNCTION create_ucod(in_codeschema character varying, in_codename character varying, in_codemean character varying) TO jsharmony_%%%INIT_DB_LCASE%%%_role_dev;


--
-- TOC entry 3097 (class 0 OID 0)
-- Dependencies: 345
-- Name: create_ucod2(character varying, character varying, character varying); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION create_ucod2(in_codeschema character varying, in_codename character varying, in_codemean character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION create_ucod2(in_codeschema character varying, in_codename character varying, in_codemean character varying) FROM postgres;
GRANT ALL ON FUNCTION create_ucod2(in_codeschema character varying, in_codename character varying, in_codemean character varying) TO postgres;
GRANT ALL ON FUNCTION create_ucod2(in_codeschema character varying, in_codename character varying, in_codemean character varying) TO jsharmony_%%%INIT_DB_LCASE%%%_role_dev;


--
-- TOC entry 3098 (class 0 OID 0)
-- Dependencies: 323
-- Name: d_iud(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION d_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION d_iud() FROM postgres;
GRANT ALL ON FUNCTION d_iud() TO postgres;
GRANT ALL ON FUNCTION d_iud() TO PUBLIC;
GRANT ALL ON FUNCTION d_iud() TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3099 (class 0 OID 0)
-- Dependencies: 333
-- Name: digest(bytea, text); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION digest(bytea, text) FROM PUBLIC;
REVOKE ALL ON FUNCTION digest(bytea, text) FROM postgres;
GRANT ALL ON FUNCTION digest(bytea, text) TO postgres;
GRANT ALL ON FUNCTION digest(bytea, text) TO PUBLIC;
GRANT ALL ON FUNCTION digest(bytea, text) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3100 (class 0 OID 0)
-- Dependencies: 304
-- Name: digest(text, text); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION digest(text, text) FROM PUBLIC;
REVOKE ALL ON FUNCTION digest(text, text) FROM postgres;
GRANT ALL ON FUNCTION digest(text, text) TO postgres;
GRANT ALL ON FUNCTION digest(text, text) TO PUBLIC;
GRANT ALL ON FUNCTION digest(text, text) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3101 (class 0 OID 0)
-- Dependencies: 318
-- Name: gcod2_iud(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION gcod2_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION gcod2_iud() FROM postgres;
GRANT ALL ON FUNCTION gcod2_iud() TO postgres;
GRANT ALL ON FUNCTION gcod2_iud() TO PUBLIC;
GRANT ALL ON FUNCTION gcod2_iud() TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3102 (class 0 OID 0)
-- Dependencies: 354
-- Name: gcod_iud(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION gcod_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION gcod_iud() FROM postgres;
GRANT ALL ON FUNCTION gcod_iud() TO postgres;
GRANT ALL ON FUNCTION gcod_iud() TO PUBLIC;
GRANT ALL ON FUNCTION gcod_iud() TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3103 (class 0 OID 0)
-- Dependencies: 309
-- Name: get_cpe_name(bigint); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION get_cpe_name(in_pe_id bigint) FROM PUBLIC;
REVOKE ALL ON FUNCTION get_cpe_name(in_pe_id bigint) FROM postgres;
GRANT ALL ON FUNCTION get_cpe_name(in_pe_id bigint) TO postgres;
GRANT ALL ON FUNCTION get_cpe_name(in_pe_id bigint) TO PUBLIC;
GRANT ALL ON FUNCTION get_cpe_name(in_pe_id bigint) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3104 (class 0 OID 0)
-- Dependencies: 307
-- Name: get_pe_name(bigint); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION get_pe_name(in_pe_id bigint) FROM PUBLIC;
REVOKE ALL ON FUNCTION get_pe_name(in_pe_id bigint) FROM postgres;
GRANT ALL ON FUNCTION get_pe_name(in_pe_id bigint) TO postgres;
GRANT ALL ON FUNCTION get_pe_name(in_pe_id bigint) TO PUBLIC;
GRANT ALL ON FUNCTION get_pe_name(in_pe_id bigint) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3105 (class 0 OID 0)
-- Dependencies: 308
-- Name: get_ppd_desc(character varying, character varying); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION get_ppd_desc(in_ppd_process character varying, in_ppd_attrib character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION get_ppd_desc(in_ppd_process character varying, in_ppd_attrib character varying) FROM postgres;
GRANT ALL ON FUNCTION get_ppd_desc(in_ppd_process character varying, in_ppd_attrib character varying) TO postgres;
GRANT ALL ON FUNCTION get_ppd_desc(in_ppd_process character varying, in_ppd_attrib character varying) TO PUBLIC;
GRANT ALL ON FUNCTION get_ppd_desc(in_ppd_process character varying, in_ppd_attrib character varying) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3106 (class 0 OID 0)
-- Dependencies: 355
-- Name: good_email(text); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION good_email(x text) FROM PUBLIC;
REVOKE ALL ON FUNCTION good_email(x text) FROM postgres;
GRANT ALL ON FUNCTION good_email(x text) TO postgres;
GRANT ALL ON FUNCTION good_email(x text) TO PUBLIC;
GRANT ALL ON FUNCTION good_email(x text) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION good_email(x text) TO jsharmony_harp_role_exec;


--
-- TOC entry 3107 (class 0 OID 0)
-- Dependencies: 320
-- Name: gpp_iud(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION gpp_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION gpp_iud() FROM postgres;
GRANT ALL ON FUNCTION gpp_iud() TO postgres;
GRANT ALL ON FUNCTION gpp_iud() TO PUBLIC;
GRANT ALL ON FUNCTION gpp_iud() TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3108 (class 0 OID 0)
-- Dependencies: 362
-- Name: h_iud(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION h_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION h_iud() FROM postgres;
GRANT ALL ON FUNCTION h_iud() TO postgres;
GRANT ALL ON FUNCTION h_iud() TO PUBLIC;
GRANT ALL ON FUNCTION h_iud() TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION h_iud() TO jsharmony_harp_role_exec;


--
-- TOC entry 3109 (class 0 OID 0)
-- Dependencies: 310
-- Name: mycuser(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION mycuser() FROM PUBLIC;
REVOKE ALL ON FUNCTION mycuser() FROM postgres;
GRANT ALL ON FUNCTION mycuser() TO postgres;
GRANT ALL ON FUNCTION mycuser() TO PUBLIC;
GRANT ALL ON FUNCTION mycuser() TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3110 (class 0 OID 0)
-- Dependencies: 358
-- Name: mycuser_email(text); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION mycuser_email(u text) FROM PUBLIC;
REVOKE ALL ON FUNCTION mycuser_email(u text) FROM postgres;
GRANT ALL ON FUNCTION mycuser_email(u text) TO postgres;
GRANT ALL ON FUNCTION mycuser_email(u text) TO PUBLIC;
GRANT ALL ON FUNCTION mycuser_email(u text) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION mycuser_email(u text) TO jsharmony_harp_role_exec;


--
-- TOC entry 3111 (class 0 OID 0)
-- Dependencies: 338
-- Name: mycuser_fmt(text); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION mycuser_fmt(u text) FROM PUBLIC;
REVOKE ALL ON FUNCTION mycuser_fmt(u text) FROM postgres;
GRANT ALL ON FUNCTION mycuser_fmt(u text) TO postgres;
GRANT ALL ON FUNCTION mycuser_fmt(u text) TO PUBLIC;
GRANT ALL ON FUNCTION mycuser_fmt(u text) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3112 (class 0 OID 0)
-- Dependencies: 351
-- Name: myhash(character, bigint, character varying); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION myhash(par_type character, par_pe_id bigint, par_pw character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION myhash(par_type character, par_pe_id bigint, par_pw character varying) FROM postgres;
GRANT ALL ON FUNCTION myhash(par_type character, par_pe_id bigint, par_pw character varying) TO postgres;
GRANT ALL ON FUNCTION myhash(par_type character, par_pe_id bigint, par_pw character varying) TO PUBLIC;
GRANT ALL ON FUNCTION myhash(par_type character, par_pe_id bigint, par_pw character varying) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3113 (class 0 OID 0)
-- Dependencies: 319
-- Name: myisnumeric(text); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION myisnumeric(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION myisnumeric(text) FROM postgres;
GRANT ALL ON FUNCTION myisnumeric(text) TO postgres;
GRANT ALL ON FUNCTION myisnumeric(text) TO PUBLIC;
GRANT ALL ON FUNCTION myisnumeric(text) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3114 (class 0 OID 0)
-- Dependencies: 326
-- Name: mymmddyy(timestamp without time zone); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION mymmddyy(timestamp without time zone) FROM PUBLIC;
REVOKE ALL ON FUNCTION mymmddyy(timestamp without time zone) FROM postgres;
GRANT ALL ON FUNCTION mymmddyy(timestamp without time zone) TO postgres;
GRANT ALL ON FUNCTION mymmddyy(timestamp without time zone) TO PUBLIC;
GRANT ALL ON FUNCTION mymmddyy(timestamp without time zone) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3115 (class 0 OID 0)
-- Dependencies: 341
-- Name: mymmddyyhhmi(timestamp without time zone); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION mymmddyyhhmi(timestamp without time zone) FROM PUBLIC;
REVOKE ALL ON FUNCTION mymmddyyhhmi(timestamp without time zone) FROM postgres;
GRANT ALL ON FUNCTION mymmddyyhhmi(timestamp without time zone) TO postgres;
GRANT ALL ON FUNCTION mymmddyyhhmi(timestamp without time zone) TO PUBLIC;
GRANT ALL ON FUNCTION mymmddyyhhmi(timestamp without time zone) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3116 (class 0 OID 0)
-- Dependencies: 314
-- Name: mymmddyyyyhhmi(timestamp without time zone); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION mymmddyyyyhhmi(timestamp without time zone) FROM PUBLIC;
REVOKE ALL ON FUNCTION mymmddyyyyhhmi(timestamp without time zone) FROM postgres;
GRANT ALL ON FUNCTION mymmddyyyyhhmi(timestamp without time zone) TO postgres;
GRANT ALL ON FUNCTION mymmddyyyyhhmi(timestamp without time zone) TO PUBLIC;
GRANT ALL ON FUNCTION mymmddyyyyhhmi(timestamp without time zone) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3117 (class 0 OID 0)
-- Dependencies: 335
-- Name: mynow(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION mynow() FROM PUBLIC;
REVOKE ALL ON FUNCTION mynow() FROM postgres;
GRANT ALL ON FUNCTION mynow() TO postgres;
GRANT ALL ON FUNCTION mynow() TO PUBLIC;
GRANT ALL ON FUNCTION mynow() TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3118 (class 0 OID 0)
-- Dependencies: 330
-- Name: mype(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION mype() FROM PUBLIC;
REVOKE ALL ON FUNCTION mype() FROM postgres;
GRANT ALL ON FUNCTION mype() TO postgres;
GRANT ALL ON FUNCTION mype() TO PUBLIC;
GRANT ALL ON FUNCTION mype() TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3119 (class 0 OID 0)
-- Dependencies: 331
-- Name: mytodate(timestamp without time zone); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION mytodate(timestamp without time zone) FROM PUBLIC;
REVOKE ALL ON FUNCTION mytodate(timestamp without time zone) FROM postgres;
GRANT ALL ON FUNCTION mytodate(timestamp without time zone) TO postgres;
GRANT ALL ON FUNCTION mytodate(timestamp without time zone) TO PUBLIC;
GRANT ALL ON FUNCTION mytodate(timestamp without time zone) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3120 (class 0 OID 0)
-- Dependencies: 329
-- Name: mytoday(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION mytoday() FROM PUBLIC;
REVOKE ALL ON FUNCTION mytoday() FROM postgres;
GRANT ALL ON FUNCTION mytoday() TO postgres;
GRANT ALL ON FUNCTION mytoday() TO PUBLIC;
GRANT ALL ON FUNCTION mytoday() TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3121 (class 0 OID 0)
-- Dependencies: 349
-- Name: n_iud(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION n_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION n_iud() FROM postgres;
GRANT ALL ON FUNCTION n_iud() TO postgres;
GRANT ALL ON FUNCTION n_iud() TO PUBLIC;
GRANT ALL ON FUNCTION n_iud() TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3122 (class 0 OID 0)
-- Dependencies: 311
-- Name: nonequal(bit, bit); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION nonequal(x1 bit, x2 bit) FROM PUBLIC;
REVOKE ALL ON FUNCTION nonequal(x1 bit, x2 bit) FROM postgres;
GRANT ALL ON FUNCTION nonequal(x1 bit, x2 bit) TO postgres;
GRANT ALL ON FUNCTION nonequal(x1 bit, x2 bit) TO PUBLIC;
GRANT ALL ON FUNCTION nonequal(x1 bit, x2 bit) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3123 (class 0 OID 0)
-- Dependencies: 350
-- Name: nonequal(boolean, boolean); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION nonequal(x1 boolean, x2 boolean) FROM PUBLIC;
REVOKE ALL ON FUNCTION nonequal(x1 boolean, x2 boolean) FROM postgres;
GRANT ALL ON FUNCTION nonequal(x1 boolean, x2 boolean) TO postgres;
GRANT ALL ON FUNCTION nonequal(x1 boolean, x2 boolean) TO PUBLIC;
GRANT ALL ON FUNCTION nonequal(x1 boolean, x2 boolean) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION nonequal(x1 boolean, x2 boolean) TO jsharmony_harp_role_exec;


--
-- TOC entry 3124 (class 0 OID 0)
-- Dependencies: 312
-- Name: nonequal(smallint, smallint); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION nonequal(x1 smallint, x2 smallint) FROM PUBLIC;
REVOKE ALL ON FUNCTION nonequal(x1 smallint, x2 smallint) FROM postgres;
GRANT ALL ON FUNCTION nonequal(x1 smallint, x2 smallint) TO postgres;
GRANT ALL ON FUNCTION nonequal(x1 smallint, x2 smallint) TO PUBLIC;
GRANT ALL ON FUNCTION nonequal(x1 smallint, x2 smallint) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3125 (class 0 OID 0)
-- Dependencies: 313
-- Name: nonequal(integer, integer); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION nonequal(x1 integer, x2 integer) FROM PUBLIC;
REVOKE ALL ON FUNCTION nonequal(x1 integer, x2 integer) FROM postgres;
GRANT ALL ON FUNCTION nonequal(x1 integer, x2 integer) TO postgres;
GRANT ALL ON FUNCTION nonequal(x1 integer, x2 integer) TO PUBLIC;
GRANT ALL ON FUNCTION nonequal(x1 integer, x2 integer) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3126 (class 0 OID 0)
-- Dependencies: 324
-- Name: nonequal(bigint, bigint); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION nonequal(x1 bigint, x2 bigint) FROM PUBLIC;
REVOKE ALL ON FUNCTION nonequal(x1 bigint, x2 bigint) FROM postgres;
GRANT ALL ON FUNCTION nonequal(x1 bigint, x2 bigint) TO postgres;
GRANT ALL ON FUNCTION nonequal(x1 bigint, x2 bigint) TO PUBLIC;
GRANT ALL ON FUNCTION nonequal(x1 bigint, x2 bigint) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3127 (class 0 OID 0)
-- Dependencies: 322
-- Name: nonequal(numeric, numeric); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION nonequal(x1 numeric, x2 numeric) FROM PUBLIC;
REVOKE ALL ON FUNCTION nonequal(x1 numeric, x2 numeric) FROM postgres;
GRANT ALL ON FUNCTION nonequal(x1 numeric, x2 numeric) TO postgres;
GRANT ALL ON FUNCTION nonequal(x1 numeric, x2 numeric) TO PUBLIC;
GRANT ALL ON FUNCTION nonequal(x1 numeric, x2 numeric) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3128 (class 0 OID 0)
-- Dependencies: 325
-- Name: nonequal(text, text); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION nonequal(x1 text, x2 text) FROM PUBLIC;
REVOKE ALL ON FUNCTION nonequal(x1 text, x2 text) FROM postgres;
GRANT ALL ON FUNCTION nonequal(x1 text, x2 text) TO postgres;
GRANT ALL ON FUNCTION nonequal(x1 text, x2 text) TO PUBLIC;
GRANT ALL ON FUNCTION nonequal(x1 text, x2 text) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3129 (class 0 OID 0)
-- Dependencies: 327
-- Name: nonequal(timestamp without time zone, timestamp without time zone); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION nonequal(x1 timestamp without time zone, x2 timestamp without time zone) FROM PUBLIC;
REVOKE ALL ON FUNCTION nonequal(x1 timestamp without time zone, x2 timestamp without time zone) FROM postgres;
GRANT ALL ON FUNCTION nonequal(x1 timestamp without time zone, x2 timestamp without time zone) TO postgres;
GRANT ALL ON FUNCTION nonequal(x1 timestamp without time zone, x2 timestamp without time zone) TO PUBLIC;
GRANT ALL ON FUNCTION nonequal(x1 timestamp without time zone, x2 timestamp without time zone) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3130 (class 0 OID 0)
-- Dependencies: 321
-- Name: pe_iud(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION pe_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION pe_iud() FROM postgres;
GRANT ALL ON FUNCTION pe_iud() TO postgres;
GRANT ALL ON FUNCTION pe_iud() TO PUBLIC;
GRANT ALL ON FUNCTION pe_iud() TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3131 (class 0 OID 0)
-- Dependencies: 359
-- Name: ppd_iud(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION ppd_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION ppd_iud() FROM postgres;
GRANT ALL ON FUNCTION ppd_iud() TO postgres;
GRANT ALL ON FUNCTION ppd_iud() TO PUBLIC;
GRANT ALL ON FUNCTION ppd_iud() TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION ppd_iud() TO jsharmony_harp_role_exec;


--
-- TOC entry 3132 (class 0 OID 0)
-- Dependencies: 343
-- Name: ppp_iud(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION ppp_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION ppp_iud() FROM postgres;
GRANT ALL ON FUNCTION ppp_iud() TO postgres;
GRANT ALL ON FUNCTION ppp_iud() TO PUBLIC;
GRANT ALL ON FUNCTION ppp_iud() TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3133 (class 0 OID 0)
-- Dependencies: 360
-- Name: sanit(text); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION sanit(x text) FROM PUBLIC;
REVOKE ALL ON FUNCTION sanit(x text) FROM postgres;
GRANT ALL ON FUNCTION sanit(x text) TO postgres;
GRANT ALL ON FUNCTION sanit(x text) TO PUBLIC;
GRANT ALL ON FUNCTION sanit(x text) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION sanit(x text) TO jsharmony_harp_role_exec;


--
-- TOC entry 3134 (class 0 OID 0)
-- Dependencies: 346
-- Name: spef_iud(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION spef_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION spef_iud() FROM postgres;
GRANT ALL ON FUNCTION spef_iud() TO postgres;
GRANT ALL ON FUNCTION spef_iud() TO PUBLIC;
GRANT ALL ON FUNCTION spef_iud() TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3135 (class 0 OID 0)
-- Dependencies: 353
-- Name: sper_iud(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION sper_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION sper_iud() FROM postgres;
GRANT ALL ON FUNCTION sper_iud() TO postgres;
GRANT ALL ON FUNCTION sper_iud() TO PUBLIC;
GRANT ALL ON FUNCTION sper_iud() TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3136 (class 0 OID 0)
-- Dependencies: 317
-- Name: table_type(character varying, character varying); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION table_type(in_schema character varying, in_name character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION table_type(in_schema character varying, in_name character varying) FROM postgres;
GRANT ALL ON FUNCTION table_type(in_schema character varying, in_name character varying) TO postgres;
GRANT ALL ON FUNCTION table_type(in_schema character varying, in_name character varying) TO PUBLIC;
GRANT ALL ON FUNCTION table_type(in_schema character varying, in_name character varying) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3137 (class 0 OID 0)
-- Dependencies: 316
-- Name: txt_iud(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION txt_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION txt_iud() FROM postgres;
GRANT ALL ON FUNCTION txt_iud() TO postgres;
GRANT ALL ON FUNCTION txt_iud() TO PUBLIC;
GRANT ALL ON FUNCTION txt_iud() TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3138 (class 0 OID 0)
-- Dependencies: 328
-- Name: v_crmsel_iud_insteadof_update(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION v_crmsel_iud_insteadof_update() FROM PUBLIC;
REVOKE ALL ON FUNCTION v_crmsel_iud_insteadof_update() FROM postgres;
GRANT ALL ON FUNCTION v_crmsel_iud_insteadof_update() TO postgres;
GRANT ALL ON FUNCTION v_crmsel_iud_insteadof_update() TO PUBLIC;
GRANT ALL ON FUNCTION v_crmsel_iud_insteadof_update() TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3139 (class 0 OID 0)
-- Dependencies: 340
-- Name: v_srmsel_iud_insteadof_update(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION v_srmsel_iud_insteadof_update() FROM PUBLIC;
REVOKE ALL ON FUNCTION v_srmsel_iud_insteadof_update() FROM postgres;
GRANT ALL ON FUNCTION v_srmsel_iud_insteadof_update() TO postgres;
GRANT ALL ON FUNCTION v_srmsel_iud_insteadof_update() TO PUBLIC;
GRANT ALL ON FUNCTION v_srmsel_iud_insteadof_update() TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3140 (class 0 OID 0)
-- Dependencies: 352
-- Name: xpp_iud(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION xpp_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION xpp_iud() FROM postgres;
GRANT ALL ON FUNCTION xpp_iud() TO postgres;
GRANT ALL ON FUNCTION xpp_iud() TO PUBLIC;
GRANT ALL ON FUNCTION xpp_iud() TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3141 (class 0 OID 0)
-- Dependencies: 183
-- Name: aud_d; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE aud_d FROM PUBLIC;
REVOKE ALL ON TABLE aud_d FROM postgres;
GRANT ALL ON TABLE aud_d TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE aud_d TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3142 (class 0 OID 0)
-- Dependencies: 184
-- Name: aud_h; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE aud_h FROM PUBLIC;
REVOKE ALL ON TABLE aud_h FROM postgres;
GRANT ALL ON TABLE aud_h TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE aud_h TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3144 (class 0 OID 0)
-- Dependencies: 185
-- Name: aud_h_aud_seq_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE aud_h_aud_seq_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE aud_h_aud_seq_seq FROM postgres;
GRANT ALL ON SEQUENCE aud_h_aud_seq_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE aud_h_aud_seq_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3145 (class 0 OID 0)
-- Dependencies: 186
-- Name: cpe; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE cpe FROM PUBLIC;
REVOKE ALL ON TABLE cpe FROM postgres;
GRANT ALL ON TABLE cpe TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cpe TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3147 (class 0 OID 0)
-- Dependencies: 187
-- Name: cpe_pe_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE cpe_pe_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE cpe_pe_id_seq FROM postgres;
GRANT ALL ON SEQUENCE cpe_pe_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE cpe_pe_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3148 (class 0 OID 0)
-- Dependencies: 188
-- Name: cper; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE cper FROM PUBLIC;
REVOKE ALL ON TABLE cper FROM postgres;
GRANT ALL ON TABLE cper TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cper TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3150 (class 0 OID 0)
-- Dependencies: 189
-- Name: cper_cper_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE cper_cper_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE cper_cper_id_seq FROM postgres;
GRANT ALL ON SEQUENCE cper_cper_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE cper_cper_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3151 (class 0 OID 0)
-- Dependencies: 190
-- Name: cr; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE cr FROM PUBLIC;
REVOKE ALL ON TABLE cr FROM postgres;
GRANT ALL ON TABLE cr TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cr TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3153 (class 0 OID 0)
-- Dependencies: 191
-- Name: cr_cr_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE cr_cr_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE cr_cr_id_seq FROM postgres;
GRANT ALL ON SEQUENCE cr_cr_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE cr_cr_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3154 (class 0 OID 0)
-- Dependencies: 192
-- Name: crm; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE crm FROM PUBLIC;
REVOKE ALL ON TABLE crm FROM postgres;
GRANT ALL ON TABLE crm TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE crm TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3156 (class 0 OID 0)
-- Dependencies: 193
-- Name: crm_crm_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE crm_crm_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE crm_crm_id_seq FROM postgres;
GRANT ALL ON SEQUENCE crm_crm_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE crm_crm_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3157 (class 0 OID 0)
-- Dependencies: 194
-- Name: d; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE d FROM PUBLIC;
REVOKE ALL ON TABLE d FROM postgres;
GRANT ALL ON TABLE d TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE d TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3159 (class 0 OID 0)
-- Dependencies: 195
-- Name: d_d_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE d_d_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE d_d_id_seq FROM postgres;
GRANT ALL ON SEQUENCE d_d_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE d_d_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3161 (class 0 OID 0)
-- Dependencies: 196
-- Name: dual; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE dual FROM PUBLIC;
REVOKE ALL ON TABLE dual FROM postgres;
GRANT ALL ON TABLE dual TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE dual TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3163 (class 0 OID 0)
-- Dependencies: 197
-- Name: dual_dual_ident_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE dual_dual_ident_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE dual_dual_ident_seq FROM postgres;
GRANT ALL ON SEQUENCE dual_dual_ident_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE dual_dual_ident_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3164 (class 0 OID 0)
-- Dependencies: 274
-- Name: gcod_gcod_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE gcod_gcod_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE gcod_gcod_id_seq FROM postgres;
GRANT ALL ON SEQUENCE gcod_gcod_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE gcod_gcod_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3165 (class 0 OID 0)
-- Dependencies: 275
-- Name: gcod; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE gcod FROM PUBLIC;
REVOKE ALL ON TABLE gcod FROM postgres;
GRANT ALL ON TABLE gcod TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE gcod TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3166 (class 0 OID 0)
-- Dependencies: 273
-- Name: gcod2_gcod2_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE gcod2_gcod2_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE gcod2_gcod2_id_seq FROM postgres;
GRANT ALL ON SEQUENCE gcod2_gcod2_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE gcod2_gcod2_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3167 (class 0 OID 0)
-- Dependencies: 276
-- Name: gcod2; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE gcod2 FROM PUBLIC;
REVOKE ALL ON TABLE gcod2 FROM postgres;
GRANT ALL ON TABLE gcod2 TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE gcod2 TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3168 (class 0 OID 0)
-- Dependencies: 277
-- Name: gcod2_d_scope_d_ctgr; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE gcod2_d_scope_d_ctgr FROM PUBLIC;
REVOKE ALL ON TABLE gcod2_d_scope_d_ctgr FROM postgres;
GRANT ALL ON TABLE gcod2_d_scope_d_ctgr TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE gcod2_d_scope_d_ctgr TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3169 (class 0 OID 0)
-- Dependencies: 198
-- Name: gcod2_h; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE gcod2_h FROM PUBLIC;
REVOKE ALL ON TABLE gcod2_h FROM postgres;
GRANT ALL ON TABLE gcod2_h TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE gcod2_h TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3170 (class 0 OID 0)
-- Dependencies: 199
-- Name: gcod_h; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE gcod_h FROM PUBLIC;
REVOKE ALL ON TABLE gcod_h FROM postgres;
GRANT ALL ON TABLE gcod_h TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE gcod_h TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3171 (class 0 OID 0)
-- Dependencies: 200
-- Name: gpp; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE gpp FROM PUBLIC;
REVOKE ALL ON TABLE gpp FROM postgres;
GRANT ALL ON TABLE gpp TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE gpp TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3173 (class 0 OID 0)
-- Dependencies: 201
-- Name: gpp_gpp_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE gpp_gpp_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE gpp_gpp_id_seq FROM postgres;
GRANT ALL ON SEQUENCE gpp_gpp_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE gpp_gpp_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3174 (class 0 OID 0)
-- Dependencies: 202
-- Name: h; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE h FROM PUBLIC;
REVOKE ALL ON TABLE h FROM postgres;
GRANT ALL ON TABLE h TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE h TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3176 (class 0 OID 0)
-- Dependencies: 203
-- Name: h_h_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE h_h_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE h_h_id_seq FROM postgres;
GRANT ALL ON SEQUENCE h_h_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE h_h_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3177 (class 0 OID 0)
-- Dependencies: 204
-- Name: hp; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE hp FROM PUBLIC;
REVOKE ALL ON TABLE hp FROM postgres;
GRANT ALL ON TABLE hp TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE hp TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3179 (class 0 OID 0)
-- Dependencies: 205
-- Name: hp_hp_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE hp_hp_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE hp_hp_id_seq FROM postgres;
GRANT ALL ON SEQUENCE hp_hp_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE hp_hp_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3180 (class 0 OID 0)
-- Dependencies: 206
-- Name: n; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE n FROM PUBLIC;
REVOKE ALL ON TABLE n FROM postgres;
GRANT ALL ON TABLE n TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE n TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3182 (class 0 OID 0)
-- Dependencies: 207
-- Name: n_n_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE n_n_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE n_n_id_seq FROM postgres;
GRANT ALL ON SEQUENCE n_n_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE n_n_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3183 (class 0 OID 0)
-- Dependencies: 208
-- Name: numbers; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE numbers FROM PUBLIC;
REVOKE ALL ON TABLE numbers FROM postgres;
GRANT ALL ON TABLE numbers TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE numbers TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3184 (class 0 OID 0)
-- Dependencies: 209
-- Name: pe; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE pe FROM PUBLIC;
REVOKE ALL ON TABLE pe FROM postgres;
GRANT ALL ON TABLE pe TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE pe TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3186 (class 0 OID 0)
-- Dependencies: 210
-- Name: pe_pe_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE pe_pe_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE pe_pe_id_seq FROM postgres;
GRANT ALL ON SEQUENCE pe_pe_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE pe_pe_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3187 (class 0 OID 0)
-- Dependencies: 211
-- Name: ppd; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ppd FROM PUBLIC;
REVOKE ALL ON TABLE ppd FROM postgres;
GRANT ALL ON TABLE ppd TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ppd TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3189 (class 0 OID 0)
-- Dependencies: 212
-- Name: ppd_ppd_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE ppd_ppd_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE ppd_ppd_id_seq FROM postgres;
GRANT ALL ON SEQUENCE ppd_ppd_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE ppd_ppd_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3190 (class 0 OID 0)
-- Dependencies: 213
-- Name: ppp; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ppp FROM PUBLIC;
REVOKE ALL ON TABLE ppp FROM postgres;
GRANT ALL ON TABLE ppp TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ppp TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3192 (class 0 OID 0)
-- Dependencies: 214
-- Name: ppp_ppp_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE ppp_ppp_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE ppp_ppp_id_seq FROM postgres;
GRANT ALL ON SEQUENCE ppp_ppp_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE ppp_ppp_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3193 (class 0 OID 0)
-- Dependencies: 215
-- Name: rq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE rq FROM PUBLIC;
REVOKE ALL ON TABLE rq FROM postgres;
GRANT ALL ON TABLE rq TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE rq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3195 (class 0 OID 0)
-- Dependencies: 216
-- Name: rq_rq_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE rq_rq_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE rq_rq_id_seq FROM postgres;
GRANT ALL ON SEQUENCE rq_rq_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE rq_rq_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3196 (class 0 OID 0)
-- Dependencies: 217
-- Name: rqst; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE rqst FROM PUBLIC;
REVOKE ALL ON TABLE rqst FROM postgres;
GRANT ALL ON TABLE rqst TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE rqst TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3197 (class 0 OID 0)
-- Dependencies: 218
-- Name: rqst_d; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE rqst_d FROM PUBLIC;
REVOKE ALL ON TABLE rqst_d FROM postgres;
GRANT ALL ON TABLE rqst_d TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE rqst_d TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3199 (class 0 OID 0)
-- Dependencies: 219
-- Name: rqst_d_rqst_d_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE rqst_d_rqst_d_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE rqst_d_rqst_d_id_seq FROM postgres;
GRANT ALL ON SEQUENCE rqst_d_rqst_d_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE rqst_d_rqst_d_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3200 (class 0 OID 0)
-- Dependencies: 220
-- Name: rqst_email; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE rqst_email FROM PUBLIC;
REVOKE ALL ON TABLE rqst_email FROM postgres;
GRANT ALL ON TABLE rqst_email TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE rqst_email TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3202 (class 0 OID 0)
-- Dependencies: 221
-- Name: rqst_email_rqst_email_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE rqst_email_rqst_email_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE rqst_email_rqst_email_id_seq FROM postgres;
GRANT ALL ON SEQUENCE rqst_email_rqst_email_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE rqst_email_rqst_email_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3203 (class 0 OID 0)
-- Dependencies: 222
-- Name: rqst_n; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE rqst_n FROM PUBLIC;
REVOKE ALL ON TABLE rqst_n FROM postgres;
GRANT ALL ON TABLE rqst_n TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE rqst_n TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3205 (class 0 OID 0)
-- Dependencies: 223
-- Name: rqst_n_rqst_n_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE rqst_n_rqst_n_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE rqst_n_rqst_n_id_seq FROM postgres;
GRANT ALL ON SEQUENCE rqst_n_rqst_n_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE rqst_n_rqst_n_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3206 (class 0 OID 0)
-- Dependencies: 224
-- Name: rqst_rq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE rqst_rq FROM PUBLIC;
REVOKE ALL ON TABLE rqst_rq FROM postgres;
GRANT ALL ON TABLE rqst_rq TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE rqst_rq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3208 (class 0 OID 0)
-- Dependencies: 225
-- Name: rqst_rq_rqst_rq_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE rqst_rq_rqst_rq_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE rqst_rq_rqst_rq_id_seq FROM postgres;
GRANT ALL ON SEQUENCE rqst_rq_rqst_rq_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE rqst_rq_rqst_rq_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3210 (class 0 OID 0)
-- Dependencies: 226
-- Name: rqst_rqst_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE rqst_rqst_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE rqst_rqst_id_seq FROM postgres;
GRANT ALL ON SEQUENCE rqst_rqst_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE rqst_rqst_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3211 (class 0 OID 0)
-- Dependencies: 227
-- Name: rqst_sms; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE rqst_sms FROM PUBLIC;
REVOKE ALL ON TABLE rqst_sms FROM postgres;
GRANT ALL ON TABLE rqst_sms TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE rqst_sms TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3213 (class 0 OID 0)
-- Dependencies: 228
-- Name: rqst_sms_rqst_sms_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE rqst_sms_rqst_sms_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE rqst_sms_rqst_sms_id_seq FROM postgres;
GRANT ALL ON SEQUENCE rqst_sms_rqst_sms_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE rqst_sms_rqst_sms_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3214 (class 0 OID 0)
-- Dependencies: 229
-- Name: sf; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE sf FROM PUBLIC;
REVOKE ALL ON TABLE sf FROM postgres;
GRANT ALL ON TABLE sf TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sf TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3216 (class 0 OID 0)
-- Dependencies: 230
-- Name: sf_sf_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE sf_sf_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE sf_sf_id_seq FROM postgres;
GRANT ALL ON SEQUENCE sf_sf_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE sf_sf_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3217 (class 0 OID 0)
-- Dependencies: 231
-- Name: sm; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE sm FROM PUBLIC;
REVOKE ALL ON TABLE sm FROM postgres;
GRANT ALL ON TABLE sm TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sm TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3219 (class 0 OID 0)
-- Dependencies: 232
-- Name: sm_sm_id_auto_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE sm_sm_id_auto_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE sm_sm_id_auto_seq FROM postgres;
GRANT ALL ON SEQUENCE sm_sm_id_auto_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE sm_sm_id_auto_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3220 (class 0 OID 0)
-- Dependencies: 233
-- Name: spef; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE spef FROM PUBLIC;
REVOKE ALL ON TABLE spef FROM postgres;
GRANT ALL ON TABLE spef TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE spef TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3222 (class 0 OID 0)
-- Dependencies: 234
-- Name: spef_spef_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE spef_spef_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE spef_spef_id_seq FROM postgres;
GRANT ALL ON SEQUENCE spef_spef_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE spef_spef_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3223 (class 0 OID 0)
-- Dependencies: 235
-- Name: sper; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE sper FROM PUBLIC;
REVOKE ALL ON TABLE sper FROM postgres;
GRANT ALL ON TABLE sper TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sper TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3225 (class 0 OID 0)
-- Dependencies: 236
-- Name: sper_sper_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE sper_sper_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE sper_sper_id_seq FROM postgres;
GRANT ALL ON SEQUENCE sper_sper_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE sper_sper_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3226 (class 0 OID 0)
-- Dependencies: 237
-- Name: sr; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE sr FROM PUBLIC;
REVOKE ALL ON TABLE sr FROM postgres;
GRANT ALL ON TABLE sr TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sr TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3228 (class 0 OID 0)
-- Dependencies: 238
-- Name: sr_sr_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE sr_sr_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE sr_sr_id_seq FROM postgres;
GRANT ALL ON SEQUENCE sr_sr_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE sr_sr_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3229 (class 0 OID 0)
-- Dependencies: 239
-- Name: srm; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE srm FROM PUBLIC;
REVOKE ALL ON TABLE srm FROM postgres;
GRANT ALL ON TABLE srm TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE srm TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3231 (class 0 OID 0)
-- Dependencies: 240
-- Name: srm_srm_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE srm_srm_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE srm_srm_id_seq FROM postgres;
GRANT ALL ON SEQUENCE srm_srm_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE srm_srm_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3232 (class 0 OID 0)
-- Dependencies: 241
-- Name: txt; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE txt FROM PUBLIC;
REVOKE ALL ON TABLE txt FROM postgres;
GRANT ALL ON TABLE txt TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE txt TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3234 (class 0 OID 0)
-- Dependencies: 242
-- Name: txt_txt_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE txt_txt_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE txt_txt_id_seq FROM postgres;
GRANT ALL ON SEQUENCE txt_txt_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE txt_txt_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3235 (class 0 OID 0)
-- Dependencies: 243
-- Name: ucod; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ucod FROM PUBLIC;
REVOKE ALL ON TABLE ucod FROM postgres;
GRANT ALL ON TABLE ucod TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3236 (class 0 OID 0)
-- Dependencies: 244
-- Name: ucod2_ucod2_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE ucod2_ucod2_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE ucod2_ucod2_id_seq FROM postgres;
GRANT ALL ON SEQUENCE ucod2_ucod2_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE ucod2_ucod2_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3237 (class 0 OID 0)
-- Dependencies: 245
-- Name: ucod2; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ucod2 FROM PUBLIC;
REVOKE ALL ON TABLE ucod2 FROM postgres;
GRANT ALL ON TABLE ucod2 TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod2 TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3238 (class 0 OID 0)
-- Dependencies: 246
-- Name: ucod2_country_state; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ucod2_country_state FROM PUBLIC;
REVOKE ALL ON TABLE ucod2_country_state FROM postgres;
GRANT ALL ON TABLE ucod2_country_state TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod2_country_state TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3239 (class 0 OID 0)
-- Dependencies: 291
-- Name: ucod2_gpp_process_attrib_v; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ucod2_gpp_process_attrib_v FROM PUBLIC;
REVOKE ALL ON TABLE ucod2_gpp_process_attrib_v FROM postgres;
GRANT ALL ON TABLE ucod2_gpp_process_attrib_v TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod2_gpp_process_attrib_v TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod2_gpp_process_attrib_v TO jsharmony_harp_role_exec;


--
-- TOC entry 3240 (class 0 OID 0)
-- Dependencies: 279
-- Name: ucod2_h; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ucod2_h FROM PUBLIC;
REVOKE ALL ON TABLE ucod2_h FROM postgres;
GRANT ALL ON TABLE ucod2_h TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod2_h TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3242 (class 0 OID 0)
-- Dependencies: 281
-- Name: ucod2_h_ucod2_h_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE ucod2_h_ucod2_h_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE ucod2_h_ucod2_h_id_seq FROM postgres;
GRANT ALL ON SEQUENCE ucod2_h_ucod2_h_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE ucod2_h_ucod2_h_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3243 (class 0 OID 0)
-- Dependencies: 290
-- Name: ucod2_ppp_process_attrib_v; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ucod2_ppp_process_attrib_v FROM PUBLIC;
REVOKE ALL ON TABLE ucod2_ppp_process_attrib_v FROM postgres;
GRANT ALL ON TABLE ucod2_ppp_process_attrib_v TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod2_ppp_process_attrib_v TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod2_ppp_process_attrib_v TO jsharmony_harp_role_exec;


--
-- TOC entry 3244 (class 0 OID 0)
-- Dependencies: 289
-- Name: ucod2_xpp_process_attrib_v; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ucod2_xpp_process_attrib_v FROM PUBLIC;
REVOKE ALL ON TABLE ucod2_xpp_process_attrib_v FROM postgres;
GRANT ALL ON TABLE ucod2_xpp_process_attrib_v TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod2_xpp_process_attrib_v TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod2_xpp_process_attrib_v TO jsharmony_harp_role_exec;


--
-- TOC entry 3245 (class 0 OID 0)
-- Dependencies: 247
-- Name: ucod_ac; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ucod_ac FROM PUBLIC;
REVOKE ALL ON TABLE ucod_ac FROM postgres;
GRANT ALL ON TABLE ucod_ac TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod_ac TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3246 (class 0 OID 0)
-- Dependencies: 248
-- Name: ucod_ac1; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ucod_ac1 FROM PUBLIC;
REVOKE ALL ON TABLE ucod_ac1 FROM postgres;
GRANT ALL ON TABLE ucod_ac1 TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod_ac1 TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3247 (class 0 OID 0)
-- Dependencies: 249
-- Name: ucod_ahc; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ucod_ahc FROM PUBLIC;
REVOKE ALL ON TABLE ucod_ahc FROM postgres;
GRANT ALL ON TABLE ucod_ahc TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod_ahc TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3248 (class 0 OID 0)
-- Dependencies: 250
-- Name: ucod_country; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ucod_country FROM PUBLIC;
REVOKE ALL ON TABLE ucod_country FROM postgres;
GRANT ALL ON TABLE ucod_country TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod_country TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3249 (class 0 OID 0)
-- Dependencies: 251
-- Name: ucod_d_scope; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ucod_d_scope FROM PUBLIC;
REVOKE ALL ON TABLE ucod_d_scope FROM postgres;
GRANT ALL ON TABLE ucod_d_scope TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod_d_scope TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3250 (class 0 OID 0)
-- Dependencies: 288
-- Name: ucod_gpp_process_v; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ucod_gpp_process_v FROM PUBLIC;
REVOKE ALL ON TABLE ucod_gpp_process_v FROM postgres;
GRANT ALL ON TABLE ucod_gpp_process_v TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod_gpp_process_v TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod_gpp_process_v TO jsharmony_harp_role_exec;


--
-- TOC entry 3251 (class 0 OID 0)
-- Dependencies: 278
-- Name: ucod_h; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ucod_h FROM PUBLIC;
REVOKE ALL ON TABLE ucod_h FROM postgres;
GRANT ALL ON TABLE ucod_h TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod_h TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3253 (class 0 OID 0)
-- Dependencies: 280
-- Name: ucod_h_ucod_h_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE ucod_h_ucod_h_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE ucod_h_ucod_h_id_seq FROM postgres;
GRANT ALL ON SEQUENCE ucod_h_ucod_h_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE ucod_h_ucod_h_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3254 (class 0 OID 0)
-- Dependencies: 252
-- Name: ucod_n_scope; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ucod_n_scope FROM PUBLIC;
REVOKE ALL ON TABLE ucod_n_scope FROM postgres;
GRANT ALL ON TABLE ucod_n_scope TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod_n_scope TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3255 (class 0 OID 0)
-- Dependencies: 253
-- Name: ucod_n_type; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ucod_n_type FROM PUBLIC;
REVOKE ALL ON TABLE ucod_n_type FROM postgres;
GRANT ALL ON TABLE ucod_n_type TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod_n_type TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3256 (class 0 OID 0)
-- Dependencies: 254
-- Name: ucod_ppd_type; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ucod_ppd_type FROM PUBLIC;
REVOKE ALL ON TABLE ucod_ppd_type FROM postgres;
GRANT ALL ON TABLE ucod_ppd_type TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod_ppd_type TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3257 (class 0 OID 0)
-- Dependencies: 287
-- Name: ucod_ppp_process_v; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ucod_ppp_process_v FROM PUBLIC;
REVOKE ALL ON TABLE ucod_ppp_process_v FROM postgres;
GRANT ALL ON TABLE ucod_ppp_process_v TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod_ppp_process_v TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod_ppp_process_v TO jsharmony_harp_role_exec;


--
-- TOC entry 3258 (class 0 OID 0)
-- Dependencies: 255
-- Name: ucod_rqst_atype; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ucod_rqst_atype FROM PUBLIC;
REVOKE ALL ON TABLE ucod_rqst_atype FROM postgres;
GRANT ALL ON TABLE ucod_rqst_atype TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod_rqst_atype TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3259 (class 0 OID 0)
-- Dependencies: 256
-- Name: ucod_rqst_source; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ucod_rqst_source FROM PUBLIC;
REVOKE ALL ON TABLE ucod_rqst_source FROM postgres;
GRANT ALL ON TABLE ucod_rqst_source TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod_rqst_source TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3260 (class 0 OID 0)
-- Dependencies: 257
-- Name: ucod_txt_type; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ucod_txt_type FROM PUBLIC;
REVOKE ALL ON TABLE ucod_txt_type FROM postgres;
GRANT ALL ON TABLE ucod_txt_type TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod_txt_type TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3262 (class 0 OID 0)
-- Dependencies: 258
-- Name: ucod_ucod_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE ucod_ucod_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE ucod_ucod_id_seq FROM postgres;
GRANT ALL ON SEQUENCE ucod_ucod_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE ucod_ucod_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3264 (class 0 OID 0)
-- Dependencies: 282
-- Name: ucod_v_sts; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ucod_v_sts FROM PUBLIC;
REVOKE ALL ON TABLE ucod_v_sts FROM postgres;
GRANT ALL ON TABLE ucod_v_sts TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod_v_sts TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3265 (class 0 OID 0)
-- Dependencies: 286
-- Name: ucod_xpp_process_v; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ucod_xpp_process_v FROM PUBLIC;
REVOKE ALL ON TABLE ucod_xpp_process_v FROM postgres;
GRANT ALL ON TABLE ucod_xpp_process_v TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod_xpp_process_v TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod_xpp_process_v TO jsharmony_harp_role_exec;


--
-- TOC entry 3266 (class 0 OID 0)
-- Dependencies: 283
-- Name: v; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v FROM PUBLIC;
REVOKE ALL ON TABLE v FROM postgres;
GRANT ALL ON TABLE v TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3267 (class 0 OID 0)
-- Dependencies: 259
-- Name: v_audl_raw; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_audl_raw FROM PUBLIC;
REVOKE ALL ON TABLE v_audl_raw FROM postgres;
GRANT ALL ON TABLE v_audl_raw TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_audl_raw TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3268 (class 0 OID 0)
-- Dependencies: 260
-- Name: v_cper_nostar; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_cper_nostar FROM PUBLIC;
REVOKE ALL ON TABLE v_cper_nostar FROM postgres;
GRANT ALL ON TABLE v_cper_nostar TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_cper_nostar TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3269 (class 0 OID 0)
-- Dependencies: 261
-- Name: v_crmsel; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_crmsel FROM PUBLIC;
REVOKE ALL ON TABLE v_crmsel FROM postgres;
GRANT ALL ON TABLE v_crmsel TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_crmsel TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3270 (class 0 OID 0)
-- Dependencies: 262
-- Name: v_gppl; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_gppl FROM PUBLIC;
REVOKE ALL ON TABLE v_gppl FROM postgres;
GRANT ALL ON TABLE v_gppl TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_gppl TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3271 (class 0 OID 0)
-- Dependencies: 263
-- Name: v_months; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_months FROM PUBLIC;
REVOKE ALL ON TABLE v_months FROM postgres;
GRANT ALL ON TABLE v_months TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_months TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3272 (class 0 OID 0)
-- Dependencies: 264
-- Name: v_my_roles; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_my_roles FROM PUBLIC;
REVOKE ALL ON TABLE v_my_roles FROM postgres;
GRANT ALL ON TABLE v_my_roles TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_my_roles TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3273 (class 0 OID 0)
-- Dependencies: 265
-- Name: v_mype; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_mype FROM PUBLIC;
REVOKE ALL ON TABLE v_mype FROM postgres;
GRANT ALL ON TABLE v_mype TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_mype TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3274 (class 0 OID 0)
-- Dependencies: 266
-- Name: xpp; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE xpp FROM PUBLIC;
REVOKE ALL ON TABLE xpp FROM postgres;
GRANT ALL ON TABLE xpp TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE xpp TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3275 (class 0 OID 0)
-- Dependencies: 267
-- Name: v_pp; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_pp FROM PUBLIC;
REVOKE ALL ON TABLE v_pp FROM postgres;
GRANT ALL ON TABLE v_pp TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_pp TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3276 (class 0 OID 0)
-- Dependencies: 285
-- Name: v_ppdl; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_ppdl FROM PUBLIC;
REVOKE ALL ON TABLE v_ppdl FROM postgres;
GRANT ALL ON TABLE v_ppdl TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_ppdl TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_ppdl TO jsharmony_harp_role_exec;


--
-- TOC entry 3277 (class 0 OID 0)
-- Dependencies: 268
-- Name: v_pppl; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_pppl FROM PUBLIC;
REVOKE ALL ON TABLE v_pppl FROM postgres;
GRANT ALL ON TABLE v_pppl TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_pppl TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_pppl TO jsharmony_harp_role_exec;


--
-- TOC entry 3278 (class 0 OID 0)
-- Dependencies: 269
-- Name: v_srmsel; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_srmsel FROM PUBLIC;
REVOKE ALL ON TABLE v_srmsel FROM postgres;
GRANT ALL ON TABLE v_srmsel TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_srmsel TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3280 (class 0 OID 0)
-- Dependencies: 284
-- Name: v_v_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE v_v_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE v_v_id_seq FROM postgres;
GRANT ALL ON SEQUENCE v_v_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE v_v_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3281 (class 0 OID 0)
-- Dependencies: 270
-- Name: v_xppl; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_xppl FROM PUBLIC;
REVOKE ALL ON TABLE v_xppl FROM postgres;
GRANT ALL ON TABLE v_xppl TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_xppl TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_xppl TO jsharmony_harp_role_exec;


--
-- TOC entry 3282 (class 0 OID 0)
-- Dependencies: 271
-- Name: v_years; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_years FROM PUBLIC;
REVOKE ALL ON TABLE v_years FROM postgres;
GRANT ALL ON TABLE v_years TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_years TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 3284 (class 0 OID 0)
-- Dependencies: 272
-- Name: xpp_xpp_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE xpp_xpp_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE xpp_xpp_id_seq FROM postgres;
GRANT ALL ON SEQUENCE xpp_xpp_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE xpp_xpp_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 2098 (class 826 OID 50147)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: jsharmony; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA jsharmony REVOKE ALL ON SEQUENCES  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA jsharmony REVOKE ALL ON SEQUENCES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA jsharmony GRANT SELECT,UPDATE ON SEQUENCES  TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 2100 (class 826 OID 50148)
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: jsharmony; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA jsharmony REVOKE ALL ON FUNCTIONS  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA jsharmony REVOKE ALL ON FUNCTIONS  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA jsharmony GRANT ALL ON FUNCTIONS  TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- TOC entry 2096 (class 826 OID 50144)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: jsharmony; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA jsharmony REVOKE ALL ON TABLES  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA jsharmony REVOKE ALL ON TABLES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA jsharmony GRANT SELECT,INSERT,DELETE,UPDATE ON TABLES  TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


-- Completed on 2017-10-10 11:14:05

--
-- PostgreSQL database dump complete
--

