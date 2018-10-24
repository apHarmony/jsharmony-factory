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
	table_name text,
	c_id bigint,
	e_id bigint,
	ref_name text,
	ref_id bigint,
	subj text
);


ALTER TYPE toaudit OWNER TO postgres;

--
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
-- Name: cpe_iud_after_insert(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION cpe_iud_after_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        IF TG_OP = 'INSERT' THEN
          insert into jsharmony.cper (pe_id, cr_name) values(NEW.pe_id, 'C*');
        END IF;

        RETURN NEW;   

    END;
$$;


ALTER FUNCTION jsharmony.cpe_iud_after_insert() OWNER TO postgres;

--
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

        if getcid is not null and my_d_scope not in ('PE') then
          sqlcmd := 'select '||getcid||'($1,$2);';
          EXECUTE sqlcmd INTO my_c_id USING my_d_scope, my_d_scope_id;
        end if;

        if geteid is not null and my_d_scope not in ('PE') then
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
-- Name: digest(bytea, text); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION digest(bytea, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_digest';


ALTER FUNCTION jsharmony.digest(bytea, text) OWNER TO postgres;

--
-- Name: digest(text, text); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION digest(text, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_digest';


ALTER FUNCTION jsharmony.digest(text, text) OWNER TO postgres;

--
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
-- Name: good_email(text); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION good_email(x text) RETURNS boolean
    LANGUAGE sql
    AS $_$select x ~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$';$_$;


ALTER FUNCTION jsharmony.good_email(x text) OWNER TO postgres;

--
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
-- Name: mycuser(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION jsharmony.mycuser() RETURNS text
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

ALTER FUNCTION jsharmony.mycuser() OWNER TO postgres;

--
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
-- Name: mymmddyy(timestamp without time zone); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION mymmddyy(timestamp without time zone) RETURNS character varying
    LANGUAGE sql
    AS $_$select to_char($1, 'MM/DD/YY');$_$;


ALTER FUNCTION jsharmony.mymmddyy(timestamp without time zone) OWNER TO postgres;

--
-- Name: mymmddyyhhmi(timestamp without time zone); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION mymmddyyhhmi(timestamp without time zone) RETURNS character varying
    LANGUAGE sql
    AS $_$select to_char($1, 'MM/DD/YY HH24:MI');$_$;


ALTER FUNCTION jsharmony.mymmddyyhhmi(timestamp without time zone) OWNER TO postgres;

--
-- Name: mymmddyyyyhhmi(timestamp without time zone); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION mymmddyyyyhhmi(timestamp without time zone) RETURNS character varying
    LANGUAGE sql
    AS $_$select to_char($1, 'MM/DD/YYYY HH24:MI');$_$;


ALTER FUNCTION jsharmony.mymmddyyyyhhmi(timestamp without time zone) OWNER TO postgres;

--
-- Name: mynow(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION mynow() RETURNS timestamp without time zone
    LANGUAGE sql
    AS $$select localtimestamp;$$;


ALTER FUNCTION jsharmony.mynow() OWNER TO postgres;

--
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
-- Name: mypec(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION mypec() RETURNS bigint
    LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER COST 10
    AS $$
DECLARE
    u       text = jsharmony.mycuser();
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


ALTER FUNCTION jsharmony.mypec() OWNER TO postgres;

--
-- Name: mytodate(timestamp without time zone); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION mytodate(timestamp without time zone) RETURNS date
    LANGUAGE sql
    AS $_$select date_trunc('day',$1)::date;$_$;


ALTER FUNCTION jsharmony.mytodate(timestamp without time zone) OWNER TO postgres;

--
-- Name: mytoday(); Type: FUNCTION; Schema: jsharmony; Owner: postgres
--

CREATE FUNCTION mytoday() RETURNS date
    LANGUAGE sql
    AS $$select current_date;$$;


ALTER FUNCTION jsharmony.mytoday() OWNER TO postgres;

--
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

        if TG_OP = 'DELETE' then
          my_toa.c_id := NULL;
        else
          if NEW.n_scope in ('PE')
          then 
            my_toa.c_id := NULL;
          else  
            my_toa.c_id := get_c_id(NEW.n_scope, NEW.n_scope_ID);
          end if;  
        end if; 
        
        my_toa.e_id := NULL;
        my_toa.ref_name := NULL;
        my_toa.ref_id := NULL;
        my_toa.subj := NULL;

        if TG_OP = 'DELETE' then
          if OLD.n_scope in ('PE')
          then 
            my_C_ID := NULL;
          else  
            my_c_id := get_c_id(OLD.n_scope, OLD.n_scope_ID);
          end if;  
          my_n_scope := OLD.n_scope;
        else
          if NEW.n_scope in ('PE')
          then 
            my_C_ID := NULL;
          else  
            my_c_id := get_c_id(NEW.n_scope, NEW.n_scope_ID);
          end if;  
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
          IF NOT jsharmony.check_foreign(NEW.n_scope, NEW.n_scope_ID)>0 THEN
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


ALTER FUNCTION jsharmony.sanit_json(x text) OWNER TO postgres;

--
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

          IF coalesce(NEW.new_cr_name,'')<>'' THEN
            insert into jsharmony.crm (cr_name, sm_id)
                             values (NEW.new_cr_name, NEW.sm_id);
	  ELSE
            insert into jsharmony.crm (cr_name, sm_id)
                             values (NEW.cr_name, NEW.new_sm_id);
          END IF;                     
            
        END IF;    


        RETURN NEW;

    END;
$$;


ALTER FUNCTION jsharmony.v_crmsel_iud_insteadof_update() OWNER TO postgres;

--
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
          IF coalesce(NEW.new_sr_name,'')<>'' THEN
            insert into jsharmony.SRM (SR_NAME, SM_ID)
                             values (NEW.new_sr_name, NEW.sm_id);
	  ELSE
            insert into jsharmony.SRM (SR_NAME, SM_ID)
                             values (NEW.sr_name, NEW.new_sm_id);
          END IF;                     
            
        END IF;    


        RETURN NEW;

    END;
$$;


ALTER FUNCTION jsharmony.v_srmsel_iud_insteadof_update() OWNER TO postgres;

--
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
-- Name: aud_d; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE aud_d (
    aud_seq bigint NOT NULL,
    column_name character varying(30) NOT NULL,
    column_val text
);


ALTER TABLE aud_d OWNER TO postgres;

--
-- Name: TABLE aud_d; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE aud_d IS 'Audit Trail Detail (CONTROL)';


--
-- Name: COLUMN aud_d.aud_seq; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN aud_d.aud_seq IS 'Audit Sequence';


--
-- Name: COLUMN aud_d.column_name; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN aud_d.column_name IS 'Audit Detail Column Name';


--
-- Name: COLUMN aud_d.column_val; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN aud_d.column_val IS 'Audit Detail Column Value';


--
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
-- Name: TABLE aud_h; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE aud_h IS 'Audit Trail Header (CONTROL)';


--
-- Name: COLUMN aud_h.aud_seq; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN aud_h.aud_seq IS 'Audit Sequence';


--
-- Name: COLUMN aud_h.table_name; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN aud_h.table_name IS 'Audit Header Table Name';


--
-- Name: COLUMN aud_h.table_id; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN aud_h.table_id IS 'Audit Header Table ID Value';


--
-- Name: COLUMN aud_h.aud_op; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN aud_h.aud_op IS 'Audit Header Operation (I, U or D)';


--
-- Name: COLUMN aud_h.aud_u; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN aud_h.aud_u IS 'Audit Header User';


--
-- Name: COLUMN aud_h.db_k; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN aud_h.db_k IS 'Audit Header ???';


--
-- Name: COLUMN aud_h.aud_tstmp; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN aud_h.aud_tstmp IS 'Audit Header Timestamp';


--
-- Name: COLUMN aud_h.c_id; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN aud_h.c_id IS 'Audit Header Customer ID';


--
-- Name: COLUMN aud_h.e_id; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN aud_h.e_id IS 'Audit Header E ID';


--
-- Name: COLUMN aud_h.ref_name; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN aud_h.ref_name IS 'Audit Header Reference Name';


--
-- Name: COLUMN aud_h.ref_id; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN aud_h.ref_id IS 'Audit Header Reference ID';


--
-- Name: COLUMN aud_h.subj; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN aud_h.subj IS 'Audit Header Subject';


--
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
-- Name: aud_h_aud_seq_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE aud_h_aud_seq_seq OWNED BY aud_h.aud_seq;


--
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
-- Name: TABLE cpe; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE cpe IS '	Customer Personnel (CONTROL)';


--
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
-- Name: cpe_pe_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE cpe_pe_id_seq OWNED BY cpe.pe_id;


--
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
-- Name: TABLE cper; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE cper IS '	Customer - Personnel Roles (CONTROL)';


--
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
-- Name: cper_cper_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE cper_cper_id_seq OWNED BY cper.cper_id;


--
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
-- Name: TABLE cr; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE cr IS 'Customer - Roles (CONTROL)';


--
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
-- Name: cr_cr_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE cr_cr_id_seq OWNED BY cr.cr_id;


--
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
-- Name: TABLE crm; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE crm IS 'Customer - Role Menu Items (CONTROL)';


--
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
-- Name: crm_crm_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE crm_crm_id_seq OWNED BY crm.crm_id;


--
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
-- Name: TABLE d; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE d IS 'Documents (CONTROL)';


--
-- Name: COLUMN d.d_id; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN d.d_id IS 'Document ID';


--
-- Name: COLUMN d.d_scope; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN d.d_scope IS 'Document Scope - UCOD_D_SCOPE';


--
-- Name: COLUMN d.d_scope_id; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN d.d_scope_id IS 'Document Scope ID';


--
-- Name: COLUMN d.c_id; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN d.c_id IS 'Customer ID - C';


--
-- Name: COLUMN d.e_id; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN d.e_id IS 'E ID - E';


--
-- Name: COLUMN d.d_sts; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN d.d_sts IS 'Document Status - UCOD_AC1';


--
-- Name: COLUMN d.d_ctgr; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN d.d_ctgr IS 'Document Category - GCOD2_D_SCOPE_D_CTGR';


--
-- Name: COLUMN d.d_desc; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN d.d_desc IS 'Document Description';


--
-- Name: COLUMN d.d_ext; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN d.d_ext IS 'Document Extension (file suffix)';


--
-- Name: COLUMN d.d_size; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN d.d_size IS 'Document Size in bytes';


--
-- Name: COLUMN d.d_etstmp; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN d.d_etstmp IS 'Document Entry Timestamp';


--
-- Name: COLUMN d.d_eu; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN d.d_eu IS 'Document Entry User';


--
-- Name: COLUMN d.d_mtstmp; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN d.d_mtstmp IS 'Document Last Modification Timestamp';


--
-- Name: COLUMN d.d_mu; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN d.d_mu IS 'Document Last Modification User';


--
-- Name: COLUMN d.d_utstmp; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN d.d_utstmp IS 'Document Last Upload Timestamp';


--
-- Name: COLUMN d.d_uu; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN d.d_uu IS 'Document Last Upload User';


--
-- Name: COLUMN d.d_synctstmp; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN d.d_synctstmp IS 'Document Synchronization Timestamp';


--
-- Name: COLUMN d.d_snotes; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN d.d_snotes IS 'Document System Notes';


--
-- Name: COLUMN d.d_id_main; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN d.d_id_main IS 'Document Main ID (Synchronization)';


--
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
-- Name: d_d_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE d_d_id_seq OWNED BY d.d_id;


--
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
-- Name: TABLE dual; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE dual IS 'System Table (CONTROL)';


--
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
-- Name: dual_dual_ident_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE dual_dual_ident_seq OWNED BY dual.dual_ident;


--
-- Name: gcod_gcod_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE gcod_gcod_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gcod_gcod_id_seq OWNER TO postgres;

--
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
-- Name: TABLE gcod; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE gcod IS 'User Codes - TEMPLATE';


--
-- Name: gcod2_gcod2_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE gcod2_gcod2_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gcod2_gcod2_id_seq OWNER TO postgres;

--
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
-- Name: TABLE gcod2; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE gcod2 IS 'User Codes 2 - TEMPLATE';


--
-- Name: gcod2_d_scope_d_ctgr; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE gcod2_d_scope_d_ctgr (
)
INHERITS (gcod2);


ALTER TABLE gcod2_d_scope_d_ctgr OWNER TO postgres;

--
-- Name: TABLE gcod2_d_scope_d_ctgr; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE gcod2_d_scope_d_ctgr IS 'User Codes 2 - Document Scope / Category';


--
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
-- Name: TABLE gcod2_h; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE gcod2_h IS 'User Codes 2 Header (CONTROL)';


--
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
-- Name: TABLE gcod_h; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE gcod_h IS 'User Codes Header (CONTROL)';


--
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
-- Name: TABLE gpp; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE gpp IS 'Process Parameters - Global (CONTROL)';


--
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
-- Name: gpp_gpp_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE gpp_gpp_id_seq OWNED BY gpp.gpp_id;


--
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
-- Name: TABLE h; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE h IS 'Help (CONTROL)';


--
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
-- Name: h_h_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE h_h_id_seq OWNED BY h.h_id;


--
-- Name: hp; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE hp (
    hp_id bigint NOT NULL,
    hp_code character varying(50) NOT NULL,
    hp_desc character varying(50) NOT NULL
);


ALTER TABLE hp OWNER TO postgres;

--
-- Name: TABLE hp; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE hp IS 'Help Header (CONTROL)';


--
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
-- Name: hp_hp_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE hp_hp_id_seq OWNED BY hp.hp_id;


--
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
-- Name: TABLE n; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE n IS 'Notes (CONTROL)';


--
-- Name: COLUMN n.n_id; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN n.n_id IS 'Note ID';


--
-- Name: COLUMN n.n_scope; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN n.n_scope IS 'Note Scope - UCOD_N_SCOPE';


--
-- Name: COLUMN n.n_scope_id; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN n.n_scope_id IS 'Note Scope ID';


--
-- Name: COLUMN n.n_sts; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN n.n_sts IS 'Note Status - UCOD_AC1';


--
-- Name: COLUMN n.c_id; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN n.c_id IS 'Customer ID - C';


--
-- Name: COLUMN n.e_id; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN n.e_id IS 'E ID - E';


--
-- Name: COLUMN n.n_type; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN n.n_type IS 'Note Type - UCOD_N_TYPE - C, S, U';


--
-- Name: COLUMN n.n_note; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN n.n_note IS 'Note NOTE';


--
-- Name: COLUMN n.n_etstmp; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN n.n_etstmp IS 'Note Entry Timestamp';


--
-- Name: COLUMN n.n_eu; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN n.n_eu IS 'Note Entry User';


--
-- Name: COLUMN n.n_mtstmp; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN n.n_mtstmp IS 'Note Last Modification Timestamp';


--
-- Name: COLUMN n.n_mu; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN n.n_mu IS 'Note Last Modification User';


--
-- Name: COLUMN n.n_synctstmp; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN n.n_synctstmp IS 'Note Synchronization Timestamp';


--
-- Name: COLUMN n.n_snotes; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN n.n_snotes IS 'Note System Notes';


--
-- Name: COLUMN n.n_id_main; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN n.n_id_main IS 'Note Main ID (Synchronization)';


--
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
-- Name: n_n_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE n_n_id_seq OWNED BY n.n_id;


--
-- Name: numbers; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE numbers (
    n smallint NOT NULL
);


ALTER TABLE numbers OWNER TO postgres;

--
-- Name: TABLE numbers; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE numbers IS 'System Table (CONTROL)';


--
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
-- Name: TABLE pe; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE pe IS 'Personnel (CONTROL)';


--
-- Name: COLUMN pe.pe_id; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN pe.pe_id IS 'Personnel ID';


--
-- Name: COLUMN pe.pe_sts; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN pe.pe_sts IS 'Personnel Status';


--
-- Name: COLUMN pe.pe_stsdt; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN pe.pe_stsdt IS 'Personnel Status Date';


--
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
-- Name: pe_pe_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE pe_pe_id_seq OWNED BY pe.pe_id;


--
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
-- Name: TABLE ppd; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE ppd IS 'Process Parameters Dictionary (CONTROL)';


--
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
-- Name: ppd_ppd_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE ppd_ppd_id_seq OWNED BY ppd.ppd_id;


--
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
-- Name: TABLE ppp; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE ppp IS 'Process Parameters - Personal (CONTROL)';


--
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
-- Name: ppp_ppp_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE ppp_ppp_id_seq OWNED BY ppp.ppp_id;


--
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
-- Name: TABLE rq; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE rq IS 'Queue Request (CONTROL)';


--
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
-- Name: rq_rq_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE rq_rq_id_seq OWNED BY rq.rq_id;


--
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
-- Name: TABLE rqst; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE rqst IS 'Request (CONTROL)';


--
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
-- Name: TABLE rqst_d; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE rqst_d IS 'Request - Document (CONTROL)';


--
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
-- Name: rqst_d_rqst_d_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE rqst_d_rqst_d_id_seq OWNED BY rqst_d.rqst_d_id;


--
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
-- Name: TABLE rqst_email; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE rqst_email IS 'Request - EMail (CONTROL)';


--
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
-- Name: rqst_email_rqst_email_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE rqst_email_rqst_email_id_seq OWNED BY rqst_email.rqst_email_id;


--
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
-- Name: TABLE rqst_n; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE rqst_n IS 'Request - Note (CONTROL)';


--
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
-- Name: rqst_n_rqst_n_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE rqst_n_rqst_n_id_seq OWNED BY rqst_n.rqst_n_id;


--
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
-- Name: TABLE rqst_rq; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE rqst_rq IS 'Request - RQ (CONTROL)';


--
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
-- Name: rqst_rq_rqst_rq_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE rqst_rq_rqst_rq_id_seq OWNED BY rqst_rq.rqst_rq_id;


--
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
-- Name: rqst_rqst_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE rqst_rqst_id_seq OWNED BY rqst.rqst_id;


--
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
-- Name: TABLE rqst_sms; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE rqst_sms IS 'Request - SMS (CONTROL)';


--
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
-- Name: rqst_sms_rqst_sms_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE rqst_sms_rqst_sms_id_seq OWNED BY rqst_sms.rqst_sms_id;


--
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
-- Name: TABLE sf; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE sf IS 'Security - Functions (CONTROL)';


--
-- Name: COLUMN sf.sf_id; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN sf.sf_id IS 'Function ID';


--
-- Name: COLUMN sf.sf_name; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN sf.sf_name IS 'Function Name';


--
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
-- Name: sf_sf_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE sf_sf_id_seq OWNED BY sf.sf_id;


--
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
-- Name: TABLE sm; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE sm IS 'Security - Menu Items (CONTROL)';


--
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
-- Name: sm_sm_id_auto_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE sm_sm_id_auto_seq OWNED BY sm.sm_id_auto;


--
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
-- Name: TABLE spef; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE spef IS 'Security - Personnel Functions (CONTROL)';


--
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
-- Name: spef_spef_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE spef_spef_id_seq OWNED BY spef.spef_id;


--
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
-- Name: TABLE sper; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE sper IS 'Security - Personnel Roles (CONTROL)';


--
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
-- Name: sper_sper_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE sper_sper_id_seq OWNED BY sper.sper_id;


--
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
-- Name: TABLE sr; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE sr IS 'Security - Roles (CONTROL)';


--
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
-- Name: sr_sr_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE sr_sr_id_seq OWNED BY sr.sr_id;


--
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
-- Name: TABLE srm; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE srm IS 'Security - Role Menu Items (CONTROL)';


--
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
-- Name: srm_srm_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE srm_srm_id_seq OWNED BY srm.srm_id;


--
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
-- Name: TABLE txt; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE txt IS 'String Process Parameters (CONTROL)';


--
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
-- Name: txt_txt_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE txt_txt_id_seq OWNED BY txt.txt_id;


--
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
-- Name: TABLE ucod; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE ucod IS 'System Codes - TEMPLATE';


--
-- Name: COLUMN ucod.ucod_id; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN ucod.ucod_id IS 'Code Value ID';


--
-- Name: COLUMN ucod.codseq; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN ucod.codseq IS 'Code Value Sequence';


--
-- Name: COLUMN ucod.codeval; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN ucod.codeval IS 'Code Value';


--
-- Name: COLUMN ucod.codetxt; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN ucod.codetxt IS 'Code Value Description';


--
-- Name: COLUMN ucod.codecode; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN ucod.codecode IS 'Code Value Additional Code';


--
-- Name: COLUMN ucod.codetdt; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN ucod.codetdt IS 'Code Value Termination Date';


--
-- Name: COLUMN ucod.codetcm; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN ucod.codetcm IS 'Code Value Termination Comment';


--
-- Name: COLUMN ucod.cod_etstmp; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN ucod.cod_etstmp IS 'Code Value Entry Timestamp';


--
-- Name: COLUMN ucod.cod_eu; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN ucod.cod_eu IS 'Code Value Entry User';


--
-- Name: COLUMN ucod.cod_mtstmp; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN ucod.cod_mtstmp IS 'Code Value Last Modification Timestamp';


--
-- Name: COLUMN ucod.cod_mu; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN ucod.cod_mu IS 'Code Value Last Modification User';


--
-- Name: COLUMN ucod.cod_snotes; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN ucod.cod_snotes IS 'Code Value System Notes';


--
-- Name: COLUMN ucod.cod_notes; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN ucod.cod_notes IS 'Code Value Notes';


--
-- Name: COLUMN ucod.codeattrib; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN ucod.codeattrib IS 'Code Value Additional Attribute';


--
-- Name: ucod2_ucod2_id_seq; Type: SEQUENCE; Schema: jsharmony; Owner: postgres
--

CREATE SEQUENCE ucod2_ucod2_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ucod2_ucod2_id_seq OWNER TO postgres;

--
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
-- Name: TABLE ucod2; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE ucod2 IS 'System Codes 2 - TEMPLATE';


--
-- Name: COLUMN ucod2.ucod2_id; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN ucod2.ucod2_id IS 'Code Value ID';


--
-- Name: COLUMN ucod2.codseq; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN ucod2.codseq IS 'Code Value Sequence';


--
-- Name: COLUMN ucod2.codeval1; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN ucod2.codeval1 IS 'Code Value 1';


--
-- Name: COLUMN ucod2.codeval2; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN ucod2.codeval2 IS 'Code Value 2';


--
-- Name: COLUMN ucod2.codetxt; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN ucod2.codetxt IS 'Code Value Description';


--
-- Name: COLUMN ucod2.codecode; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN ucod2.codecode IS 'Code Value Additional Code';


--
-- Name: COLUMN ucod2.codetdt; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN ucod2.codetdt IS 'Code Value Termination Date';


--
-- Name: COLUMN ucod2.codetcm; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN ucod2.codetcm IS 'Code Value Termination Comment';


--
-- Name: COLUMN ucod2.cod_etstmp; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN ucod2.cod_etstmp IS 'Code Value Entry Timestamp';


--
-- Name: COLUMN ucod2.cod_eu; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN ucod2.cod_eu IS 'Code Value Entry User';


--
-- Name: COLUMN ucod2.cod_mtstmp; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN ucod2.cod_mtstmp IS 'Code Value Last Modification Timestamp';


--
-- Name: COLUMN ucod2.cod_mu; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN ucod2.cod_mu IS 'Code Value Last Modification User';


--
-- Name: COLUMN ucod2.cod_snotes; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN ucod2.cod_snotes IS 'Code Value System Notes';


--
-- Name: COLUMN ucod2.cod_notes; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN ucod2.cod_notes IS 'Code Value Notes';


--
-- Name: COLUMN ucod2.codeattrib; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON COLUMN ucod2.codeattrib IS 'Code Value Additional Attribute';


--
-- Name: ucod2_country_state; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE ucod2_country_state (
)
INHERITS (ucod2);


ALTER TABLE ucod2_country_state OWNER TO postgres;

--
-- Name: TABLE ucod2_country_state; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE ucod2_country_state IS 'System Codes 2 - Country / State';


--
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
-- Name: TABLE ucod2_h; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE ucod2_h IS 'System Codes 2 Header (CONTROL)';


--
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
-- Name: ucod2_h_ucod2_h_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE ucod2_h_ucod2_h_id_seq OWNED BY ucod2_h.ucod2_h_id;


--
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
-- Name: ucod_ac; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE ucod_ac (
)
INHERITS (ucod);


ALTER TABLE ucod_ac OWNER TO postgres;

--
-- Name: TABLE ucod_ac; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE ucod_ac IS 'System Codes - Active / Closed';


--
-- Name: ucod_ac1; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE ucod_ac1 (
)
INHERITS (ucod);


ALTER TABLE ucod_ac1 OWNER TO postgres;

--
-- Name: TABLE ucod_ac1; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE ucod_ac1 IS 'System Codes - A / C';


--
-- Name: ucod_ahc; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE ucod_ahc (
)
INHERITS (ucod);


ALTER TABLE ucod_ahc OWNER TO postgres;

--
-- Name: TABLE ucod_ahc; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE ucod_ahc IS 'System Codes - Active / Hold / Closed';


--
-- Name: ucod_country; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE ucod_country (
)
INHERITS (ucod);


ALTER TABLE ucod_country OWNER TO postgres;

--
-- Name: TABLE ucod_country; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE ucod_country IS 'System Codes - Countries';


--
-- Name: ucod_d_scope; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE ucod_d_scope (
)
INHERITS (ucod);


ALTER TABLE ucod_d_scope OWNER TO postgres;

--
-- Name: TABLE ucod_d_scope; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE ucod_d_scope IS 'System Codes - Document Scope';


--
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
-- Name: TABLE ucod_h; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE ucod_h IS 'System Codes Header (CONTROL)';


--
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
-- Name: ucod_h_ucod_h_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE ucod_h_ucod_h_id_seq OWNED BY ucod_h.ucod_h_id;


--
-- Name: ucod_n_scope; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE ucod_n_scope (
)
INHERITS (ucod);


ALTER TABLE ucod_n_scope OWNER TO postgres;

--
-- Name: TABLE ucod_n_scope; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE ucod_n_scope IS 'System Codes - Note Scope';


--
-- Name: ucod_n_type; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE ucod_n_type (
)
INHERITS (ucod);


ALTER TABLE ucod_n_type OWNER TO postgres;

--
-- Name: TABLE ucod_n_type; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE ucod_n_type IS 'System Codes - Note Type';


--
-- Name: ucod_ppd_type; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE ucod_ppd_type (
)
INHERITS (ucod);


ALTER TABLE ucod_ppd_type OWNER TO postgres;

--
-- Name: TABLE ucod_ppd_type; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE ucod_ppd_type IS 'System Codes - Process Parameter Type';


--
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
-- Name: ucod_rqst_atype; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE ucod_rqst_atype (
)
INHERITS (ucod);


ALTER TABLE ucod_rqst_atype OWNER TO postgres;

--
-- Name: TABLE ucod_rqst_atype; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE ucod_rqst_atype IS 'System Codes - Request Type (CONTROL)';


--
-- Name: ucod_rqst_source; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE ucod_rqst_source (
)
INHERITS (ucod);


ALTER TABLE ucod_rqst_source OWNER TO postgres;

--
-- Name: TABLE ucod_rqst_source; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE ucod_rqst_source IS 'System Codes - Request Source (CONTROL)';


--
-- Name: ucod_txt_type; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE ucod_txt_type (
)
INHERITS (ucod);


ALTER TABLE ucod_txt_type OWNER TO postgres;

--
-- Name: TABLE ucod_txt_type; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE ucod_txt_type IS 'System Codes - Text Type (Control)';


--
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
-- Name: ucod_ucod_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE ucod_ucod_id_seq OWNED BY ucod.ucod_id;


--
-- Name: ucod_v_sts; Type: TABLE; Schema: jsharmony; Owner: postgres
--

CREATE TABLE ucod_v_sts (
)
INHERITS (ucod);


ALTER TABLE ucod_v_sts OWNER TO postgres;

--
-- Name: TABLE ucod_v_sts; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE ucod_v_sts IS 'System Codes - Version Status';


--
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
-- Name: TABLE v; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE v IS 'Versions (CONTROL)';


--
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

-- Rule: v_cper_nostar_delete ON jsharmony.v_cper_nostar

CREATE OR REPLACE RULE v_cper_nostar_delete AS
    ON DELETE TO jsharmony.v_cper_nostar DO INSTEAD  DELETE FROM jsharmony.cper
  WHERE cper.cper_id = old.cper_id
  RETURNING cper.pe_id,
    cper.cper_snotes,
    cper.cper_id,
    cper.cr_name;

-- Rule: v_cper_nostar_insert ON jsharmony.v_cper_nostar

CREATE OR REPLACE RULE v_cper_nostar_insert AS
    ON INSERT TO jsharmony.v_cper_nostar DO INSTEAD  INSERT INTO jsharmony.cper (pe_id, cper_snotes, cr_name)
  VALUES (new.pe_id, new.cper_snotes, new.cr_name)
  RETURNING cper.pe_id,
    cper.cper_snotes,
    cper.cper_id,
    cper.cr_name;

-- Rule: v_cper_nostar_update ON jsharmony.v_cper_nostar

CREATE OR REPLACE RULE v_cper_nostar_update AS
    ON UPDATE TO jsharmony.v_cper_nostar DO INSTEAD  UPDATE jsharmony.cper SET pe_id = new.pe_id, cper_snotes = new.cper_snotes, cr_name = new.cr_name
  WHERE cper.cper_id = old.cper_id
  RETURNING cper.pe_id,
    cper.cper_snotes,
    cper.cper_id,
    cper.cr_name;


--
-- Name: v_crmsel; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW v_crmsel AS
 SELECT crm.crm_id,
    COALESCE(dual.dual_varchar50, ''::character varying) AS new_cr_name,
    dual.dual_bigint AS new_sm_id,
        CASE
            WHEN (crm.crm_id IS NULL) THEN 0
            ELSE 1
        END AS crmsel_sel,
    m.cr_id,
    m.cr_seq,
    m.cr_sts,
    m.cr_name,
    m.cr_desc,
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
   FROM ((( SELECT cr.cr_id,
            cr.cr_seq,
            cr.cr_sts,
            cr.cr_name,
            cr.cr_desc,
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
-- Name: v_d_ext; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW v_d_ext AS
 SELECT d.d_id,
    d.d_scope,
    d.d_scope_id,
    d.c_id,
    d.e_id,
    d.d_sts,
    d.d_ctgr,
    d.d_desc,
    d.d_ext,
    d.d_size,
    (('D'::text || ((d.d_id)::character varying)::text) || (COALESCE(d.d_ext, ''::character varying))::text) AS d_filename,
    d.d_etstmp,
    d.d_eu,
    mycuser_fmt((d.d_eu)::text) AS d_eu_fmt,
    d.d_mtstmp,
    d.d_mu,
    mycuser_fmt((d.d_mu)::text) AS d_mu_fmt,
    d.d_utstmp,
    d.d_uu,
    mycuser_fmt((d.d_uu)::text) AS d_uu_fmt,
    d.d_snotes,
    NULL::text AS title_h,
    NULL::text AS title_b,
    d.d_scope AS d_lock,
    NULL::text AS c_name,
    NULL::text AS c_name_ext,
    NULL::text AS e_name
   FROM d;


ALTER TABLE v_d_ext OWNER TO postgres;

--
-- Name: v_d_x; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW v_d_x AS
 SELECT d.d_id,
    d.d_scope,
    d.d_scope_id,
    d.c_id,
    d.e_id,
    d.d_sts,
    d.d_ctgr,
    d.d_desc,
    d.d_ext,
    d.d_size,
    d.d_etstmp,
    d.d_eu,
    d.d_mtstmp,
    d.d_mu,
    d.d_utstmp,
    d.d_uu,
    d.d_synctstmp,
    d.d_snotes,
    d.d_id_main,
    (('D'::text || ((d.d_id)::character varying)::text) || (COALESCE(d.d_ext, ''::character varying))::text) AS d_filename
   FROM d;


ALTER TABLE v_d_x OWNER TO postgres;

--
-- Name: v_dl; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW v_dl AS
 SELECT d.d_id,
    d.d_scope,
    d.d_scope_id,
    d.c_id,
    d.e_id,
    d.d_sts,
    d.d_ctgr,
    gdd.codetxt AS d_ctgr_txt,
    d.d_desc,
    d.d_ext,
    d.d_size,
    (('D'::text || ((d.d_id)::character varying)::text) || (COALESCE(d.d_ext, ''::character varying))::text) AS d_filename,
    d.d_etstmp,
    d.d_eu,
    mycuser_fmt((d.d_eu)::text) AS d_eu_fmt,
    d.d_mtstmp,
    d.d_mu,
    mycuser_fmt((d.d_mu)::text) AS d_mu_fmt,
    d.d_utstmp,
    d.d_uu,
    mycuser_fmt((d.d_uu)::text) AS d_uu_fmt,
    d.d_snotes,
    NULL::text AS title_h,
    NULL::text AS title_b
   FROM (d
     LEFT JOIN gcod2_d_scope_d_ctgr gdd ON ((((gdd.codeval1)::text = (d.d_scope)::text) AND ((gdd.codeval2)::text = (d.d_ctgr)::text))));


ALTER TABLE v_dl OWNER TO postgres;

--
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
-- Name: TABLE xpp; Type: COMMENT; Schema: jsharmony; Owner: postgres
--

COMMENT ON TABLE xpp IS 'Process Parameters - System (CONTROL)';


--
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
-- Name: v_house; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW v_house AS
 SELECT name.pp_val AS house_name,
    addr.pp_val AS house_addr,
    city.pp_val AS house_city,
    state.pp_val AS house_state,
    zip.pp_val AS house_zip,
    (((((((COALESCE(addr.pp_val, ''::character varying))::text || ', '::text) || (COALESCE(city.pp_val, ''::character varying))::text) || ' '::text) || (COALESCE(state.pp_val, ''::character varying))::text) || ' '::text) || (COALESCE(zip.pp_val, ''::character varying))::text) AS house_full_addr,
    bphone.pp_val AS house_bphone,
    fax.pp_val AS house_fax,
    email.pp_val AS house_email,
    contact.pp_val AS house_contact
   FROM (((((((((dual
     LEFT JOIN v_pp name ON ((((name.pp_process)::text = 'HOUSE'::text) AND ((name.pp_attrib)::text = 'NAME'::text))))
     LEFT JOIN v_pp addr ON ((((addr.pp_process)::text = 'HOUSE'::text) AND ((addr.pp_attrib)::text = 'ADDR'::text))))
     LEFT JOIN v_pp city ON ((((city.pp_process)::text = 'HOUSE'::text) AND ((city.pp_attrib)::text = 'CITY'::text))))
     LEFT JOIN v_pp state ON ((((state.pp_process)::text = 'HOUSE'::text) AND ((state.pp_attrib)::text = 'STATE'::text))))
     LEFT JOIN v_pp zip ON ((((zip.pp_process)::text = 'HOUSE'::text) AND ((zip.pp_attrib)::text = 'ZIP'::text))))
     LEFT JOIN v_pp bphone ON ((((bphone.pp_process)::text = 'HOUSE'::text) AND ((bphone.pp_attrib)::text = 'BPHONE'::text))))
     LEFT JOIN v_pp fax ON ((((fax.pp_process)::text = 'HOUSE'::text) AND ((fax.pp_attrib)::text = 'FAX'::text))))
     LEFT JOIN v_pp email ON ((((email.pp_process)::text = 'HOUSE'::text) AND ((email.pp_attrib)::text = 'EMAIL'::text))))
     LEFT JOIN v_pp contact ON ((((contact.pp_process)::text = 'HOUSE'::text) AND ((contact.pp_attrib)::text = 'CONTACT'::text))));


ALTER TABLE v_house OWNER TO postgres;

--
-- Name: v_months; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW v_months AS
 SELECT numbers.n,
    "right"(('0'::text || ((numbers.n)::character varying)::text), 2) AS mth
   FROM numbers
  WHERE (numbers.n <= 12);


ALTER TABLE v_months OWNER TO postgres;

--
-- Name: v_my_roles; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW v_my_roles AS
 SELECT sper.sr_name
   FROM sper
  WHERE (sper.pe_id = mype());


ALTER TABLE v_my_roles OWNER TO postgres;

--
-- Name: v_mype; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW v_mype AS
 SELECT mype() AS mype;


ALTER TABLE v_mype OWNER TO postgres;

--
-- Name: v_n_ext; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW v_n_ext AS
 SELECT n.n_id,
    n.n_scope,
    n.n_scope_id,
    n.n_sts,
    n.c_id,
    n.e_id,
    n.n_type,
    n.n_note,
    n.n_etstmp,
    n.n_eu,
    mycuser_fmt((n.n_eu)::text) AS n_eu_fmt,
    n.n_mtstmp,
    n.n_mu,
    mycuser_fmt((n.n_mu)::text) AS n_mu_fmt,
    n.n_snotes,
    NULL::text AS title_h,
    NULL::text AS title_b,
    NULL::text AS c_name,
    NULL::text AS c_name_ext,
    NULL::text AS e_name
   FROM n;


ALTER TABLE v_n_ext OWNER TO postgres;

--
-- Name: v_nl; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW v_nl AS
 SELECT n.n_id,
    n.n_scope,
    n.n_scope_id,
    n.n_sts,
    n.c_id,
    NULL::text AS c_name,
    NULL::text AS c_name_ext,
    n.e_id,
    NULL::text AS e_name,
    n.n_type,
    n.n_note,
    mytodate(n.n_etstmp) AS n_dt,
    n.n_etstmp,
    mymmddyyhhmi(n.n_etstmp) AS n_etstmp_fmt,
    n.n_eu,
    mycuser_fmt((n.n_eu)::text) AS n_eu_fmt,
    n.n_mtstmp,
    mymmddyyhhmi(n.n_mtstmp) AS n_mtstmp_fmt,
    n.n_mu,
    mycuser_fmt((n.n_mu)::text) AS n_mu_fmt,
    n.n_snotes,
    NULL::text AS title_h,
    NULL::text AS title_b
   FROM n;


ALTER TABLE v_nl OWNER TO postgres;

--
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
-- Name: v_srmsel; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW v_srmsel AS
 SELECT srm.srm_id,
    COALESCE(dual.dual_varchar50, ''::character varying) AS new_sr_name,
    dual.dual_bigint AS new_sm_id,
        CASE
            WHEN (srm.srm_id IS NULL) THEN 0
            ELSE 1
        END AS srmsel_sel,
    m.sr_id,
    m.sr_seq,
    m.sr_sts,
    m.sr_name,
    m.sr_desc,
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
   FROM ((( SELECT sr.sr_id,
            sr.sr_seq,
            sr.sr_sts,
            sr.sr_name,
            sr.sr_desc,
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
-- Name: v_v_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE v_v_id_seq OWNED BY v.v_id;


--
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
-- Name: v_years; Type: VIEW; Schema: jsharmony; Owner: postgres
--

CREATE VIEW v_years AS
 SELECT ((date_part('year'::text, mynow()) + (numbers.n)::double precision) - (1)::double precision) AS yr
   FROM numbers
  WHERE (numbers.n <= 10);


ALTER TABLE v_years OWNER TO postgres;

--
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
-- Name: xpp_xpp_id_seq; Type: SEQUENCE OWNED BY; Schema: jsharmony; Owner: postgres
--

ALTER SEQUENCE xpp_xpp_id_seq OWNED BY xpp.xpp_id;


--
-- Name: aud_seq; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY aud_h ALTER COLUMN aud_seq SET DEFAULT nextval('aud_h_aud_seq_seq'::regclass);


--
-- Name: pe_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY cpe ALTER COLUMN pe_id SET DEFAULT nextval('cpe_pe_id_seq'::regclass);


--
-- Name: cper_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY cper ALTER COLUMN cper_id SET DEFAULT nextval('cper_cper_id_seq'::regclass);


--
-- Name: cr_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY cr ALTER COLUMN cr_id SET DEFAULT nextval('cr_cr_id_seq'::regclass);


--
-- Name: crm_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY crm ALTER COLUMN crm_id SET DEFAULT nextval('crm_crm_id_seq'::regclass);


--
-- Name: d_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY d ALTER COLUMN d_id SET DEFAULT nextval('d_d_id_seq'::regclass);


--
-- Name: dual_ident; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY dual ALTER COLUMN dual_ident SET DEFAULT nextval('dual_dual_ident_seq'::regclass);


--
-- Name: gcod2_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY gcod2_d_scope_d_ctgr ALTER COLUMN gcod2_id SET DEFAULT nextval('gcod2_gcod2_id_seq'::regclass);


--
-- Name: cod_etstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY gcod2_d_scope_d_ctgr ALTER COLUMN cod_etstmp SET DEFAULT mynow();


--
-- Name: cod_eu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY gcod2_d_scope_d_ctgr ALTER COLUMN cod_eu SET DEFAULT mycuser();


--
-- Name: cod_mtstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY gcod2_d_scope_d_ctgr ALTER COLUMN cod_mtstmp SET DEFAULT mynow();


--
-- Name: cod_mu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY gcod2_d_scope_d_ctgr ALTER COLUMN cod_mu SET DEFAULT mycuser();


--
-- Name: gpp_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY gpp ALTER COLUMN gpp_id SET DEFAULT nextval('gpp_gpp_id_seq'::regclass);


--
-- Name: h_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY h ALTER COLUMN h_id SET DEFAULT nextval('h_h_id_seq'::regclass);


--
-- Name: hp_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY hp ALTER COLUMN hp_id SET DEFAULT nextval('hp_hp_id_seq'::regclass);


--
-- Name: n_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY n ALTER COLUMN n_id SET DEFAULT nextval('n_n_id_seq'::regclass);


--
-- Name: pe_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY pe ALTER COLUMN pe_id SET DEFAULT nextval('pe_pe_id_seq'::regclass);


--
-- Name: ppd_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ppd ALTER COLUMN ppd_id SET DEFAULT nextval('ppd_ppd_id_seq'::regclass);


--
-- Name: ppp_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ppp ALTER COLUMN ppp_id SET DEFAULT nextval('ppp_ppp_id_seq'::regclass);


--
-- Name: rq_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY rq ALTER COLUMN rq_id SET DEFAULT nextval('rq_rq_id_seq'::regclass);


--
-- Name: rqst_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY rqst ALTER COLUMN rqst_id SET DEFAULT nextval('rqst_rqst_id_seq'::regclass);


--
-- Name: rqst_d_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY rqst_d ALTER COLUMN rqst_d_id SET DEFAULT nextval('rqst_d_rqst_d_id_seq'::regclass);


--
-- Name: rqst_email_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY rqst_email ALTER COLUMN rqst_email_id SET DEFAULT nextval('rqst_email_rqst_email_id_seq'::regclass);


--
-- Name: rqst_n_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY rqst_n ALTER COLUMN rqst_n_id SET DEFAULT nextval('rqst_n_rqst_n_id_seq'::regclass);


--
-- Name: rqst_rq_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY rqst_rq ALTER COLUMN rqst_rq_id SET DEFAULT nextval('rqst_rq_rqst_rq_id_seq'::regclass);


--
-- Name: rqst_sms_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY rqst_sms ALTER COLUMN rqst_sms_id SET DEFAULT nextval('rqst_sms_rqst_sms_id_seq'::regclass);


--
-- Name: sf_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sf ALTER COLUMN sf_id SET DEFAULT nextval('sf_sf_id_seq'::regclass);


--
-- Name: sm_id_auto; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sm ALTER COLUMN sm_id_auto SET DEFAULT nextval('sm_sm_id_auto_seq'::regclass);


--
-- Name: spef_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY spef ALTER COLUMN spef_id SET DEFAULT nextval('spef_spef_id_seq'::regclass);


--
-- Name: sper_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sper ALTER COLUMN sper_id SET DEFAULT nextval('sper_sper_id_seq'::regclass);


--
-- Name: sr_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sr ALTER COLUMN sr_id SET DEFAULT nextval('sr_sr_id_seq'::regclass);


--
-- Name: srm_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY srm ALTER COLUMN srm_id SET DEFAULT nextval('srm_srm_id_seq'::regclass);


--
-- Name: txt_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY txt ALTER COLUMN txt_id SET DEFAULT nextval('txt_txt_id_seq'::regclass);


--
-- Name: ucod_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod ALTER COLUMN ucod_id SET DEFAULT nextval('ucod_ucod_id_seq'::regclass);


--
-- Name: ucod2_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod2_country_state ALTER COLUMN ucod2_id SET DEFAULT nextval('ucod2_ucod2_id_seq'::regclass);


--
-- Name: cod_etstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod2_country_state ALTER COLUMN cod_etstmp SET DEFAULT mynow();


--
-- Name: cod_eu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod2_country_state ALTER COLUMN cod_eu SET DEFAULT mycuser();


--
-- Name: cod_mtstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod2_country_state ALTER COLUMN cod_mtstmp SET DEFAULT mynow();


--
-- Name: cod_mu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod2_country_state ALTER COLUMN cod_mu SET DEFAULT mycuser();


--
-- Name: ucod2_h_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod2_h ALTER COLUMN ucod2_h_id SET DEFAULT nextval('ucod2_h_ucod2_h_id_seq'::regclass);


--
-- Name: ucod_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ac ALTER COLUMN ucod_id SET DEFAULT nextval('ucod_ucod_id_seq'::regclass);


--
-- Name: cod_etstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ac ALTER COLUMN cod_etstmp SET DEFAULT mynow();


--
-- Name: cod_eu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ac ALTER COLUMN cod_eu SET DEFAULT mycuser();


--
-- Name: cod_mtstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ac ALTER COLUMN cod_mtstmp SET DEFAULT mynow();


--
-- Name: cod_mu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ac ALTER COLUMN cod_mu SET DEFAULT mycuser();


--
-- Name: ucod_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ac1 ALTER COLUMN ucod_id SET DEFAULT nextval('ucod_ucod_id_seq'::regclass);


--
-- Name: cod_etstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ac1 ALTER COLUMN cod_etstmp SET DEFAULT mynow();


--
-- Name: cod_eu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ac1 ALTER COLUMN cod_eu SET DEFAULT mycuser();


--
-- Name: cod_mtstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ac1 ALTER COLUMN cod_mtstmp SET DEFAULT mynow();


--
-- Name: cod_mu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ac1 ALTER COLUMN cod_mu SET DEFAULT mycuser();


--
-- Name: ucod_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ahc ALTER COLUMN ucod_id SET DEFAULT nextval('ucod_ucod_id_seq'::regclass);


--
-- Name: cod_etstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ahc ALTER COLUMN cod_etstmp SET DEFAULT mynow();


--
-- Name: cod_eu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ahc ALTER COLUMN cod_eu SET DEFAULT mycuser();


--
-- Name: cod_mtstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ahc ALTER COLUMN cod_mtstmp SET DEFAULT mynow();


--
-- Name: cod_mu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ahc ALTER COLUMN cod_mu SET DEFAULT mycuser();


--
-- Name: ucod_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_country ALTER COLUMN ucod_id SET DEFAULT nextval('ucod_ucod_id_seq'::regclass);


--
-- Name: cod_etstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_country ALTER COLUMN cod_etstmp SET DEFAULT mynow();


--
-- Name: cod_eu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_country ALTER COLUMN cod_eu SET DEFAULT mycuser();


--
-- Name: cod_mtstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_country ALTER COLUMN cod_mtstmp SET DEFAULT mynow();


--
-- Name: cod_mu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_country ALTER COLUMN cod_mu SET DEFAULT mycuser();


--
-- Name: ucod_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_d_scope ALTER COLUMN ucod_id SET DEFAULT nextval('ucod_ucod_id_seq'::regclass);


--
-- Name: cod_etstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_d_scope ALTER COLUMN cod_etstmp SET DEFAULT mynow();


--
-- Name: cod_eu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_d_scope ALTER COLUMN cod_eu SET DEFAULT mycuser();


--
-- Name: cod_mtstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_d_scope ALTER COLUMN cod_mtstmp SET DEFAULT mynow();


--
-- Name: cod_mu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_d_scope ALTER COLUMN cod_mu SET DEFAULT mycuser();


--
-- Name: ucod_h_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_h ALTER COLUMN ucod_h_id SET DEFAULT nextval('ucod_h_ucod_h_id_seq'::regclass);


--
-- Name: ucod_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_n_scope ALTER COLUMN ucod_id SET DEFAULT nextval('ucod_ucod_id_seq'::regclass);


--
-- Name: cod_etstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_n_scope ALTER COLUMN cod_etstmp SET DEFAULT mynow();


--
-- Name: cod_eu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_n_scope ALTER COLUMN cod_eu SET DEFAULT mycuser();


--
-- Name: cod_mtstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_n_scope ALTER COLUMN cod_mtstmp SET DEFAULT mynow();


--
-- Name: cod_mu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_n_scope ALTER COLUMN cod_mu SET DEFAULT mycuser();


--
-- Name: ucod_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_n_type ALTER COLUMN ucod_id SET DEFAULT nextval('ucod_ucod_id_seq'::regclass);


--
-- Name: cod_etstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_n_type ALTER COLUMN cod_etstmp SET DEFAULT mynow();


--
-- Name: cod_eu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_n_type ALTER COLUMN cod_eu SET DEFAULT mycuser();


--
-- Name: cod_mtstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_n_type ALTER COLUMN cod_mtstmp SET DEFAULT mynow();


--
-- Name: cod_mu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_n_type ALTER COLUMN cod_mu SET DEFAULT mycuser();


--
-- Name: ucod_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ppd_type ALTER COLUMN ucod_id SET DEFAULT nextval('ucod_ucod_id_seq'::regclass);


--
-- Name: cod_etstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ppd_type ALTER COLUMN cod_etstmp SET DEFAULT mynow();


--
-- Name: cod_eu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ppd_type ALTER COLUMN cod_eu SET DEFAULT mycuser();


--
-- Name: cod_mtstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ppd_type ALTER COLUMN cod_mtstmp SET DEFAULT mynow();


--
-- Name: cod_mu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ppd_type ALTER COLUMN cod_mu SET DEFAULT mycuser();


--
-- Name: ucod_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_rqst_atype ALTER COLUMN ucod_id SET DEFAULT nextval('ucod_ucod_id_seq'::regclass);


--
-- Name: cod_etstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_rqst_atype ALTER COLUMN cod_etstmp SET DEFAULT mynow();


--
-- Name: cod_eu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_rqst_atype ALTER COLUMN cod_eu SET DEFAULT mycuser();


--
-- Name: cod_mtstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_rqst_atype ALTER COLUMN cod_mtstmp SET DEFAULT mynow();


--
-- Name: cod_mu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_rqst_atype ALTER COLUMN cod_mu SET DEFAULT mycuser();


--
-- Name: ucod_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_rqst_source ALTER COLUMN ucod_id SET DEFAULT nextval('ucod_ucod_id_seq'::regclass);


--
-- Name: cod_etstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_rqst_source ALTER COLUMN cod_etstmp SET DEFAULT mynow();


--
-- Name: cod_eu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_rqst_source ALTER COLUMN cod_eu SET DEFAULT mycuser();


--
-- Name: cod_mtstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_rqst_source ALTER COLUMN cod_mtstmp SET DEFAULT mynow();


--
-- Name: cod_mu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_rqst_source ALTER COLUMN cod_mu SET DEFAULT mycuser();


--
-- Name: ucod_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_txt_type ALTER COLUMN ucod_id SET DEFAULT nextval('ucod_ucod_id_seq'::regclass);


--
-- Name: cod_etstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_txt_type ALTER COLUMN cod_etstmp SET DEFAULT mynow();


--
-- Name: cod_eu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_txt_type ALTER COLUMN cod_eu SET DEFAULT mycuser();


--
-- Name: cod_mtstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_txt_type ALTER COLUMN cod_mtstmp SET DEFAULT mynow();


--
-- Name: cod_mu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_txt_type ALTER COLUMN cod_mu SET DEFAULT mycuser();


--
-- Name: ucod_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_v_sts ALTER COLUMN ucod_id SET DEFAULT nextval('ucod_ucod_id_seq'::regclass);


--
-- Name: cod_etstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_v_sts ALTER COLUMN cod_etstmp SET DEFAULT mynow();


--
-- Name: cod_eu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_v_sts ALTER COLUMN cod_eu SET DEFAULT mycuser();


--
-- Name: cod_mtstmp; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_v_sts ALTER COLUMN cod_mtstmp SET DEFAULT mynow();


--
-- Name: cod_mu; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_v_sts ALTER COLUMN cod_mu SET DEFAULT mycuser();


--
-- Name: v_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY v ALTER COLUMN v_id SET DEFAULT nextval('v_v_id_seq'::regclass);


--
-- Name: xpp_id; Type: DEFAULT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY xpp ALTER COLUMN xpp_id SET DEFAULT nextval('xpp_xpp_id_seq'::regclass);


--
-- Name: aud_d_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY aud_d
    ADD CONSTRAINT aud_d_pkey PRIMARY KEY (aud_seq, column_name);


--
-- Name: aud_h_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY aud_h
    ADD CONSTRAINT aud_h_pkey PRIMARY KEY (aud_seq);


--
-- Name: cpe_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY cpe
    ADD CONSTRAINT cpe_pkey PRIMARY KEY (pe_id);


--
-- Name: cper_cper_id_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY cper
    ADD CONSTRAINT cper_cper_id_key UNIQUE (cper_id);


--
-- Name: cper_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY cper
    ADD CONSTRAINT cper_pkey PRIMARY KEY (pe_id, cr_name);


--
-- Name: cr_cr_desc_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY cr
    ADD CONSTRAINT cr_cr_desc_key UNIQUE (cr_desc);


--
-- Name: cr_cr_id_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY cr
    ADD CONSTRAINT cr_cr_id_key UNIQUE (cr_id);


--
-- Name: cr_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY cr
    ADD CONSTRAINT cr_pkey PRIMARY KEY (cr_name);


--
-- Name: crm_crm_id_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY crm
    ADD CONSTRAINT crm_crm_id_key UNIQUE (crm_id);


--
-- Name: crm_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY crm
    ADD CONSTRAINT crm_pkey PRIMARY KEY (cr_name, sm_id);


--
-- Name: d_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY d
    ADD CONSTRAINT d_pkey PRIMARY KEY (d_id);


--
-- Name: dual_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY dual
    ADD CONSTRAINT dual_pkey PRIMARY KEY (dual_ident);


--
-- Name: gcod2_codeval1_codetxt_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY gcod2
    ADD CONSTRAINT gcod2_codeval1_codetxt_key UNIQUE (codeval1, codetxt);


--
-- Name: gcod2_codeval1_codeval2_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY gcod2
    ADD CONSTRAINT gcod2_codeval1_codeval2_key UNIQUE (codeval1, codeval2);


--
-- Name: gcod2_d_scope_d_ctgr_codeval1_codetxt_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY gcod2_d_scope_d_ctgr
    ADD CONSTRAINT gcod2_d_scope_d_ctgr_codeval1_codetxt_key UNIQUE (codeval1, codetxt);


--
-- Name: gcod2_d_scope_d_ctgr_codeval1_codeval2_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY gcod2_d_scope_d_ctgr
    ADD CONSTRAINT gcod2_d_scope_d_ctgr_codeval1_codeval2_key UNIQUE (codeval1, codeval2);


--
-- Name: gcod2_d_scope_d_ctgr_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY gcod2_d_scope_d_ctgr
    ADD CONSTRAINT gcod2_d_scope_d_ctgr_pkey PRIMARY KEY (gcod2_id);


--
-- Name: gcod2_h_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY gcod2_h
    ADD CONSTRAINT gcod2_h_pkey PRIMARY KEY (codename);


--
-- Name: gcod2_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY gcod2
    ADD CONSTRAINT gcod2_pkey PRIMARY KEY (gcod2_id);


--
-- Name: gcod_codetxt_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY gcod
    ADD CONSTRAINT gcod_codetxt_key UNIQUE (codetxt);


--
-- Name: gcod_codeval_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY gcod
    ADD CONSTRAINT gcod_codeval_key UNIQUE (codeval);


--
-- Name: gcod_h_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY gcod_h
    ADD CONSTRAINT gcod_h_pkey PRIMARY KEY (codename);


--
-- Name: gcod_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY gcod
    ADD CONSTRAINT gcod_pkey PRIMARY KEY (gcod_id);


--
-- Name: gpp_gpp_process_gpp_attrib_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY gpp
    ADD CONSTRAINT gpp_gpp_process_gpp_attrib_key UNIQUE (gpp_process, gpp_attrib);


--
-- Name: gpp_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY gpp
    ADD CONSTRAINT gpp_pkey PRIMARY KEY (gpp_id);


--
-- Name: h_h_title_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY h
    ADD CONSTRAINT h_h_title_key UNIQUE (h_title);


--
-- Name: h_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY h
    ADD CONSTRAINT h_pkey PRIMARY KEY (h_id);


--
-- Name: hp_hp_code_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY hp
    ADD CONSTRAINT hp_hp_code_key UNIQUE (hp_code);


--
-- Name: hp_hp_desc_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY hp
    ADD CONSTRAINT hp_hp_desc_key UNIQUE (hp_desc);


--
-- Name: hp_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY hp
    ADD CONSTRAINT hp_pkey PRIMARY KEY (hp_id);


--
-- Name: n_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY n
    ADD CONSTRAINT n_pkey PRIMARY KEY (n_id);


--
-- Name: numbers_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY numbers
    ADD CONSTRAINT numbers_pkey PRIMARY KEY (n);


--
-- Name: pe_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY pe
    ADD CONSTRAINT pe_pkey PRIMARY KEY (pe_id);


--
-- Name: ppd_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ppd
    ADD CONSTRAINT ppd_pkey PRIMARY KEY (ppd_id);


--
-- Name: ppd_ppd_process_ppd_attrib_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ppd
    ADD CONSTRAINT ppd_ppd_process_ppd_attrib_key UNIQUE (ppd_process, ppd_attrib);


--
-- Name: ppp_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ppp
    ADD CONSTRAINT ppp_pkey PRIMARY KEY (ppp_id);


--
-- Name: ppp_ppp_process_ppp_attrib_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ppp
    ADD CONSTRAINT ppp_ppp_process_ppp_attrib_key UNIQUE (pe_id, ppp_process, ppp_attrib);


--
-- Name: rq_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY rq
    ADD CONSTRAINT rq_pkey PRIMARY KEY (rq_id);


--
-- Name: rqst_d_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY rqst_d
    ADD CONSTRAINT rqst_d_pkey PRIMARY KEY (rqst_d_id);


--
-- Name: rqst_email_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY rqst_email
    ADD CONSTRAINT rqst_email_pkey PRIMARY KEY (rqst_email_id);


--
-- Name: rqst_n_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY rqst_n
    ADD CONSTRAINT rqst_n_pkey PRIMARY KEY (rqst_n_id);


--
-- Name: rqst_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY rqst
    ADD CONSTRAINT rqst_pkey PRIMARY KEY (rqst_id);


--
-- Name: rqst_rq_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY rqst_rq
    ADD CONSTRAINT rqst_rq_pkey PRIMARY KEY (rqst_rq_id);


--
-- Name: rqst_sms_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY rqst_sms
    ADD CONSTRAINT rqst_sms_pkey PRIMARY KEY (rqst_sms_id);


--
-- Name: sf_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sf
    ADD CONSTRAINT sf_pkey PRIMARY KEY (sf_name);


--
-- Name: sf_sf_desc_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sf
    ADD CONSTRAINT sf_sf_desc_key UNIQUE (sf_desc);


--
-- Name: sf_sf_id_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sf
    ADD CONSTRAINT sf_sf_id_key UNIQUE (sf_id);


--
-- Name: sm_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sm
    ADD CONSTRAINT sm_pkey PRIMARY KEY (sm_id_auto);


--
-- Name: sm_sm_id_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sm
    ADD CONSTRAINT sm_sm_id_key UNIQUE (sm_id);


--
-- Name: sm_sm_id_parent_sm_desc_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sm
    ADD CONSTRAINT sm_sm_id_parent_sm_desc_key UNIQUE (sm_id_parent, sm_desc);


--
-- Name: sm_sm_id_sm_desc_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sm
    ADD CONSTRAINT sm_sm_id_sm_desc_key UNIQUE (sm_id, sm_desc);


--
-- Name: sm_sm_name_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sm
    ADD CONSTRAINT sm_sm_name_key UNIQUE (sm_name);


--
-- Name: spef_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY spef
    ADD CONSTRAINT spef_pkey PRIMARY KEY (pe_id, sf_name);


--
-- Name: spef_spef_id_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY spef
    ADD CONSTRAINT spef_spef_id_key UNIQUE (spef_id);


--
-- Name: sper_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sper
    ADD CONSTRAINT sper_pkey PRIMARY KEY (pe_id, sr_name);


--
-- Name: sper_sper_id_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sper
    ADD CONSTRAINT sper_sper_id_key UNIQUE (sper_id);


--
-- Name: sr_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sr
    ADD CONSTRAINT sr_pkey PRIMARY KEY (sr_name);


--
-- Name: sr_sr_desc_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sr
    ADD CONSTRAINT sr_sr_desc_key UNIQUE (sr_desc);


--
-- Name: sr_sr_id_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sr
    ADD CONSTRAINT sr_sr_id_key UNIQUE (sr_id);


--
-- Name: srm_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY srm
    ADD CONSTRAINT srm_pkey PRIMARY KEY (sr_name, sm_id);


--
-- Name: srm_srm_id_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY srm
    ADD CONSTRAINT srm_srm_id_key UNIQUE (srm_id);


--
-- Name: txt_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY txt
    ADD CONSTRAINT txt_pkey PRIMARY KEY (txt_id);


--
-- Name: txt_txt_process_txt_attrib_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY txt
    ADD CONSTRAINT txt_txt_process_txt_attrib_key UNIQUE (txt_process, txt_attrib);


--
-- Name: ucod2_codetxt_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod2
    ADD CONSTRAINT ucod2_codetxt_key UNIQUE (codetxt);


--
-- Name: ucod2_codeval1_codeval2_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod2
    ADD CONSTRAINT ucod2_codeval1_codeval2_key UNIQUE (codeval1, codeval2);


--
-- Name: ucod2_country_state_codetxt_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod2_country_state
    ADD CONSTRAINT ucod2_country_state_codetxt_key UNIQUE (codetxt);


--
-- Name: ucod2_country_state_codeval1_codeval2_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod2_country_state
    ADD CONSTRAINT ucod2_country_state_codeval1_codeval2_key UNIQUE (codeval1, codeval2);


--
-- Name: ucod2_country_state_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod2_country_state
    ADD CONSTRAINT ucod2_country_state_pkey PRIMARY KEY (ucod2_id);


--
-- Name: ucod2_h_codeschema_codename_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod2_h
    ADD CONSTRAINT ucod2_h_codeschema_codename_key UNIQUE (codeschema, codename);


--
-- Name: ucod2_h_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod2_h
    ADD CONSTRAINT ucod2_h_pkey PRIMARY KEY (ucod2_h_id);


--
-- Name: ucod2_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod2
    ADD CONSTRAINT ucod2_pkey PRIMARY KEY (ucod2_id);


--
-- Name: ucod_ac1_codeval_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ac1
    ADD CONSTRAINT ucod_ac1_codeval_key UNIQUE (codeval);


--
-- Name: ucod_ac1_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ac1
    ADD CONSTRAINT ucod_ac1_pkey PRIMARY KEY (ucod_id);


--
-- Name: ucod_ac_codeval_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ac
    ADD CONSTRAINT ucod_ac_codeval_key UNIQUE (codeval);


--
-- Name: ucod_ac_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ac
    ADD CONSTRAINT ucod_ac_pkey PRIMARY KEY (ucod_id);


--
-- Name: ucod_ahc_codeval_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ahc
    ADD CONSTRAINT ucod_ahc_codeval_key UNIQUE (codeval);


--
-- Name: ucod_ahc_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ahc
    ADD CONSTRAINT ucod_ahc_pkey PRIMARY KEY (ucod_id);


--
-- Name: ucod_codeval_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod
    ADD CONSTRAINT ucod_codeval_key UNIQUE (codeval);


--
-- Name: ucod_country_codeval_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_country
    ADD CONSTRAINT ucod_country_codeval_key UNIQUE (codeval);


--
-- Name: ucod_country_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_country
    ADD CONSTRAINT ucod_country_pkey PRIMARY KEY (ucod_id);


--
-- Name: ucod_d_scope_codeval_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_d_scope
    ADD CONSTRAINT ucod_d_scope_codeval_key UNIQUE (codeval);


--
-- Name: ucod_d_scope_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_d_scope
    ADD CONSTRAINT ucod_d_scope_pkey PRIMARY KEY (ucod_id);


--
-- Name: ucod_h_codeschema_codename_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_h
    ADD CONSTRAINT ucod_h_codeschema_codename_key UNIQUE (codeschema, codename);


--
-- Name: ucod_h_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_h
    ADD CONSTRAINT ucod_h_pkey PRIMARY KEY (ucod_h_id);


--
-- Name: ucod_n_scope_codeval_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_n_scope
    ADD CONSTRAINT ucod_n_scope_codeval_key UNIQUE (codeval);


--
-- Name: ucod_n_scope_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_n_scope
    ADD CONSTRAINT ucod_n_scope_pkey PRIMARY KEY (ucod_id);


--
-- Name: ucod_n_type_codeval_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_n_type
    ADD CONSTRAINT ucod_n_type_codeval_key UNIQUE (codeval);


--
-- Name: ucod_n_type_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_n_type
    ADD CONSTRAINT ucod_n_type_pkey PRIMARY KEY (ucod_id);


--
-- Name: ucod_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod
    ADD CONSTRAINT ucod_pkey PRIMARY KEY (ucod_id);


--
-- Name: ucod_ppd_type_codeval_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ppd_type
    ADD CONSTRAINT ucod_ppd_type_codeval_key UNIQUE (codeval);


--
-- Name: ucod_ppd_type_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_ppd_type
    ADD CONSTRAINT ucod_ppd_type_pkey PRIMARY KEY (ucod_id);


--
-- Name: ucod_rqst_atype_codeval_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_rqst_atype
    ADD CONSTRAINT ucod_rqst_atype_codeval_key UNIQUE (codeval);


--
-- Name: ucod_rqst_atype_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_rqst_atype
    ADD CONSTRAINT ucod_rqst_atype_pkey PRIMARY KEY (ucod_id);


--
-- Name: ucod_rqst_source_codeval_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_rqst_source
    ADD CONSTRAINT ucod_rqst_source_codeval_key UNIQUE (codeval);


--
-- Name: ucod_rqst_source_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_rqst_source
    ADD CONSTRAINT ucod_rqst_source_pkey PRIMARY KEY (ucod_id);


--
-- Name: ucod_txt_type_codeval_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_txt_type
    ADD CONSTRAINT ucod_txt_type_codeval_key UNIQUE (codeval);


--
-- Name: ucod_txt_type_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_txt_type
    ADD CONSTRAINT ucod_txt_type_pkey PRIMARY KEY (ucod_id);


--
-- Name: ucod_v_sts_codetxt_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_v_sts
    ADD CONSTRAINT ucod_v_sts_codetxt_key UNIQUE (codetxt);


--
-- Name: ucod_v_sts_codeval_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_v_sts
    ADD CONSTRAINT ucod_v_sts_codeval_key UNIQUE (codeval);


--
-- Name: ucod_v_sts_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ucod_v_sts
    ADD CONSTRAINT ucod_v_sts_pkey PRIMARY KEY (ucod_id);


--
-- Name: v_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY v
    ADD CONSTRAINT v_pkey PRIMARY KEY (v_id);


--
-- Name: v_v_no_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY v
    ADD CONSTRAINT v_v_no_key UNIQUE (v_no_major, v_no_minor, v_no_build, v_no_rev);


--
-- Name: xpp_pkey; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY xpp
    ADD CONSTRAINT xpp_pkey PRIMARY KEY (xpp_id);


--
-- Name: xpp_xpp_process_xpp_attrib_key; Type: CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY xpp
    ADD CONSTRAINT xpp_xpp_process_xpp_attrib_key UNIQUE (xpp_process, xpp_attrib);


--
-- Name: cpe_pe_email_unique; Type: INDEX; Schema: jsharmony; Owner: postgres
--

CREATE UNIQUE INDEX cpe_pe_email_unique ON cpe USING btree (lower((pe_email)::text)) WHERE ((pe_sts)::text = 'ACTIVE'::text);


--
-- Name: fki_cpe_c_id_c_Fkey; Type: INDEX; Schema: jsharmony; Owner: postgres
--

CREATE INDEX "fki_cpe_c_id_c_Fkey" ON cpe USING btree (c_id);


--
-- Name: fki_d_d_scope_d_ctgr; Type: INDEX; Schema: jsharmony; Owner: postgres
--

CREATE INDEX fki_d_d_scope_d_ctgr ON d USING btree (d_scope, d_ctgr);


--
-- Name: h_hp_code_unique; Type: INDEX; Schema: jsharmony; Owner: postgres
--

CREATE UNIQUE INDEX h_hp_code_unique ON h USING btree (hp_code) WHERE (hp_code IS NOT NULL);


--
-- Name: pe_pe_email_unique; Type: INDEX; Schema: jsharmony; Owner: postgres
--

CREATE UNIQUE INDEX pe_pe_email_unique ON pe USING btree (lower((pe_email)::text)) WHERE ((pe_sts)::text = 'ACTIVE'::text);


--
-- Name: ucod2_h_coalesce_codename_idx; Type: INDEX; Schema: jsharmony; Owner: postgres
--

CREATE UNIQUE INDEX ucod2_h_coalesce_codename_idx ON ucod2_h USING btree ((COALESCE(codeschema, '*** NULL IS HERE ***'::character varying)), codename);


--
-- Name: ucod_h_coalesce_codename_idx; Type: INDEX; Schema: jsharmony; Owner: postgres
--

CREATE UNIQUE INDEX ucod_h_coalesce_codename_idx ON ucod_h USING btree ((COALESCE(codeschema, '*** NULL IS HERE ***'::character varying)), codename);


--
-- Name: cpe_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER cpe_iud BEFORE INSERT OR DELETE OR UPDATE ON cpe FOR EACH ROW EXECUTE PROCEDURE cpe_iud();


--
-- Name: cpe_iud_after_insert; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER cpe_iud_after_insert AFTER INSERT ON cpe FOR EACH ROW EXECUTE PROCEDURE cpe_iud_after_insert();


--
-- Name: cper_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER cper_iud BEFORE INSERT OR DELETE OR UPDATE ON cper FOR EACH ROW EXECUTE PROCEDURE cper_iud();


--
-- Name: d_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER d_iud BEFORE INSERT OR DELETE OR UPDATE ON d FOR EACH ROW EXECUTE PROCEDURE d_iud();


--
-- Name: gcod2_d_scope_d_ctgr_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER gcod2_d_scope_d_ctgr_iud BEFORE INSERT OR DELETE OR UPDATE ON gcod2_d_scope_d_ctgr FOR EACH ROW EXECUTE PROCEDURE gcod2_iud();


--
-- Name: gcod2_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER gcod2_iud BEFORE INSERT OR DELETE OR UPDATE ON gcod2 FOR EACH ROW EXECUTE PROCEDURE gcod2_iud();


--
-- Name: gcod_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER gcod_iud BEFORE INSERT OR DELETE OR UPDATE ON gcod FOR EACH ROW EXECUTE PROCEDURE gcod_iud();


--
-- Name: gpp_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER gpp_iud BEFORE INSERT OR DELETE OR UPDATE ON gpp FOR EACH ROW EXECUTE PROCEDURE gpp_iud();


--
-- Name: h_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER h_iud BEFORE INSERT OR DELETE OR UPDATE ON h FOR EACH ROW EXECUTE PROCEDURE h_iud();


--
-- Name: n_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER n_iud BEFORE INSERT OR DELETE OR UPDATE ON n FOR EACH ROW EXECUTE PROCEDURE n_iud();


--
-- Name: pe_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER pe_iud BEFORE INSERT OR DELETE OR UPDATE ON pe FOR EACH ROW EXECUTE PROCEDURE pe_iud();


--
-- Name: ppd_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER ppd_iud BEFORE INSERT OR DELETE OR UPDATE ON ppd FOR EACH ROW EXECUTE PROCEDURE ppd_iud();


--
-- Name: ppp_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER ppp_iud BEFORE INSERT OR DELETE OR UPDATE ON ppp FOR EACH ROW EXECUTE PROCEDURE ppp_iud();


--
-- Name: spef_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER spef_iud BEFORE INSERT OR DELETE OR UPDATE ON spef FOR EACH ROW EXECUTE PROCEDURE spef_iud();


--
-- Name: sper_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER sper_iud BEFORE INSERT OR DELETE OR UPDATE ON sper FOR EACH ROW EXECUTE PROCEDURE sper_iud();


--
-- Name: txt_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER txt_iud BEFORE INSERT OR DELETE OR UPDATE ON txt FOR EACH ROW EXECUTE PROCEDURE txt_iud();


--
-- Name: v_crmsel_iud_insteadof_update; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER v_crmsel_iud_insteadof_update INSTEAD OF UPDATE ON v_crmsel FOR EACH ROW EXECUTE PROCEDURE v_crmsel_iud_insteadof_update();


--
-- Name: v_srmsel_iud_insteadof_update; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER v_srmsel_iud_insteadof_update INSTEAD OF UPDATE ON v_srmsel FOR EACH ROW EXECUTE PROCEDURE v_srmsel_iud_insteadof_update();


--
-- Name: xpp_iud; Type: TRIGGER; Schema: jsharmony; Owner: postgres
--

CREATE TRIGGER xpp_iud BEFORE INSERT OR DELETE OR UPDATE ON xpp FOR EACH ROW EXECUTE PROCEDURE xpp_iud();


--
-- Name: aud_d_aud_seq_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY aud_d
    ADD CONSTRAINT aud_d_aud_seq_fkey FOREIGN KEY (aud_seq) REFERENCES aud_h(aud_seq);


--
-- Name: cpe_pe_sts_ucod_ahc_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY cpe
    ADD CONSTRAINT cpe_pe_sts_ucod_ahc_fkey FOREIGN KEY (pe_sts) REFERENCES ucod_ahc(codeval);


--
-- Name: cper_cr_name_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY cper
    ADD CONSTRAINT cper_cr_name_fkey FOREIGN KEY (cr_name) REFERENCES cr(cr_name);


--
-- Name: cper_pe_id_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY cper
    ADD CONSTRAINT cper_pe_id_fkey FOREIGN KEY (pe_id) REFERENCES cpe(pe_id) ON DELETE CASCADE;


--
-- Name: cr_cr_sts_ucod_ahc_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY cr
    ADD CONSTRAINT cr_cr_sts_ucod_ahc_fkey FOREIGN KEY (cr_sts) REFERENCES ucod_ahc(codeval);


--
-- Name: crm_cr_name_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY crm
    ADD CONSTRAINT crm_cr_name_fkey FOREIGN KEY (cr_name) REFERENCES cr(cr_name) ON DELETE CASCADE;


--
-- Name: crm_sm_id_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY crm
    ADD CONSTRAINT crm_sm_id_fkey FOREIGN KEY (sm_id) REFERENCES sm(sm_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: d_d_scope_d_ctgr; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY d
    ADD CONSTRAINT d_d_scope_d_ctgr FOREIGN KEY (d_scope, d_ctgr) REFERENCES gcod2_d_scope_d_ctgr(codeval1, codeval2);


--
-- Name: d_d_scope_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY d
    ADD CONSTRAINT d_d_scope_fkey FOREIGN KEY (d_scope) REFERENCES ucod_d_scope(codeval);


--
-- Name: gpp_ppd_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY gpp
    ADD CONSTRAINT gpp_ppd_fkey FOREIGN KEY (gpp_process, gpp_attrib) REFERENCES ppd(ppd_process, ppd_attrib);


--
-- Name: h_hp_code_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY h
    ADD CONSTRAINT h_hp_code_fkey FOREIGN KEY (hp_code) REFERENCES hp(hp_code);


--
-- Name: n_n_scope_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY n
    ADD CONSTRAINT n_n_scope_fkey FOREIGN KEY (n_scope) REFERENCES ucod_n_scope(codeval);


--
-- Name: n_n_sts_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY n
    ADD CONSTRAINT n_n_sts_fkey FOREIGN KEY (n_sts) REFERENCES ucod_ac1(codeval);


--
-- Name: n_n_type_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY n
    ADD CONSTRAINT n_n_type_fkey FOREIGN KEY (n_type) REFERENCES ucod_n_type(codeval);


--
-- Name: pe_pe_sts_ucod_ahc_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY pe
    ADD CONSTRAINT pe_pe_sts_ucod_ahc_fkey FOREIGN KEY (pe_sts) REFERENCES ucod_ahc(codeval);


--
-- Name: pe_ucod2_country_state_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY pe
    ADD CONSTRAINT pe_ucod2_country_state_fkey FOREIGN KEY (pe_country, pe_state) REFERENCES ucod2_country_state(codeval1, codeval2);


--
-- Name: pe_ucod_country_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY pe
    ADD CONSTRAINT pe_ucod_country_fkey FOREIGN KEY (pe_country) REFERENCES ucod_country(codeval);


--
-- Name: ppd_ucod_ppd_type_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ppd
    ADD CONSTRAINT ppd_ucod_ppd_type_fkey FOREIGN KEY (ppd_type) REFERENCES ucod_ppd_type(codeval);


--
-- Name: ppp_pe_id_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ppp
    ADD CONSTRAINT ppp_pe_id_fkey FOREIGN KEY (pe_id) REFERENCES pe(pe_id) ON DELETE CASCADE;


--
-- Name: ppp_ppd_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY ppp
    ADD CONSTRAINT ppp_ppd_fkey FOREIGN KEY (ppp_process, ppp_attrib) REFERENCES ppd(ppd_process, ppd_attrib) ON DELETE CASCADE;


--
-- Name: rqst_d_rqst_id_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY rqst_d
    ADD CONSTRAINT rqst_d_rqst_id_fkey FOREIGN KEY (rqst_id) REFERENCES rqst(rqst_id);


--
-- Name: rqst_email_rqst_id_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY rqst_email
    ADD CONSTRAINT rqst_email_rqst_id_fkey FOREIGN KEY (rqst_id) REFERENCES rqst(rqst_id);


--
-- Name: rqst_n_rqst_id_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY rqst_n
    ADD CONSTRAINT rqst_n_rqst_id_fkey FOREIGN KEY (rqst_id) REFERENCES rqst(rqst_id);


--
-- Name: rqst_rq_rqst_id_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY rqst_rq
    ADD CONSTRAINT rqst_rq_rqst_id_fkey FOREIGN KEY (rqst_id) REFERENCES rqst(rqst_id);


--
-- Name: rqst_sms_rqst_id_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY rqst_sms
    ADD CONSTRAINT rqst_sms_rqst_id_fkey FOREIGN KEY (rqst_id) REFERENCES rqst(rqst_id);


--
-- Name: rqst_ucod_rqst_atype_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY rqst
    ADD CONSTRAINT rqst_ucod_rqst_atype_fkey FOREIGN KEY (rqst_atype) REFERENCES ucod_rqst_atype(codeval);


--
-- Name: rqst_ucod_rqst_source_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY rqst
    ADD CONSTRAINT rqst_ucod_rqst_source_fkey FOREIGN KEY (rqst_source) REFERENCES ucod_rqst_source(codeval);


--
-- Name: sf_sf_sts_ucod_ahc_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sf
    ADD CONSTRAINT sf_sf_sts_ucod_ahc_fkey FOREIGN KEY (sf_sts) REFERENCES ucod_ahc(codeval);


--
-- Name: sm_sm_id_parent_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sm
    ADD CONSTRAINT sm_sm_id_parent_fkey FOREIGN KEY (sm_id_parent) REFERENCES sm(sm_id);


--
-- Name: sm_sm_sts_ucod_ahc_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sm
    ADD CONSTRAINT sm_sm_sts_ucod_ahc_fkey FOREIGN KEY (sm_sts) REFERENCES ucod_ahc(codeval);


--
-- Name: spef_pe_id_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY spef
    ADD CONSTRAINT spef_pe_id_fkey FOREIGN KEY (pe_id) REFERENCES pe(pe_id);


--
-- Name: spef_sf_name_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY spef
    ADD CONSTRAINT spef_sf_name_fkey FOREIGN KEY (sf_name) REFERENCES sf(sf_name);


--
-- Name: sper_pe_id_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sper
    ADD CONSTRAINT sper_pe_id_fkey FOREIGN KEY (pe_id) REFERENCES pe(pe_id);


--
-- Name: sper_sr_name_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sper
    ADD CONSTRAINT sper_sr_name_fkey FOREIGN KEY (sr_name) REFERENCES sr(sr_name);


--
-- Name: sr_sr_sts_ucod_ahc_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY sr
    ADD CONSTRAINT sr_sr_sts_ucod_ahc_fkey FOREIGN KEY (sr_sts) REFERENCES ucod_ahc(codeval);


--
-- Name: srm_sm_id_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY srm
    ADD CONSTRAINT srm_sm_id_fkey FOREIGN KEY (sm_id) REFERENCES sm(sm_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: srm_sr_name_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY srm
    ADD CONSTRAINT srm_sr_name_fkey FOREIGN KEY (sr_name) REFERENCES sr(sr_name) ON DELETE CASCADE;


--
-- Name: txt_ucod_txt_type_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY txt
    ADD CONSTRAINT txt_ucod_txt_type_fkey FOREIGN KEY (txt_type) REFERENCES ucod_txt_type(codeval);


--
-- Name: v_v_sts_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY v
    ADD CONSTRAINT v_v_sts_fkey FOREIGN KEY (v_sts) REFERENCES ucod_v_sts(codeval);


--
-- Name: xpp_ppd_fkey; Type: FK CONSTRAINT; Schema: jsharmony; Owner: postgres
--

ALTER TABLE ONLY xpp
    ADD CONSTRAINT xpp_ppd_fkey FOREIGN KEY (xpp_process, xpp_attrib) REFERENCES ppd(ppd_process, ppd_attrib);


--
-- Name: jsharmony; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA jsharmony FROM PUBLIC;
REVOKE ALL ON SCHEMA jsharmony FROM postgres;
GRANT ALL ON SCHEMA jsharmony TO postgres;
GRANT USAGE ON SCHEMA jsharmony TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;
GRANT USAGE ON SCHEMA jsharmony TO jsharmony_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: audit(toaudit, bigint, bigint, character varying, text); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION audit(toa toaudit, INOUT par_aud_seq bigint, par_table_id bigint, par_column_name character varying, par_column_val text) FROM PUBLIC;
REVOKE ALL ON FUNCTION audit(toa toaudit, INOUT par_aud_seq bigint, par_table_id bigint, par_column_name character varying, par_column_val text) FROM postgres;
GRANT ALL ON FUNCTION audit(toa toaudit, INOUT par_aud_seq bigint, par_table_id bigint, par_column_name character varying, par_column_val text) TO postgres;
GRANT ALL ON FUNCTION audit(toa toaudit, INOUT par_aud_seq bigint, par_table_id bigint, par_column_name character varying, par_column_val text) TO PUBLIC;
GRANT ALL ON FUNCTION audit(toa toaudit, INOUT par_aud_seq bigint, par_table_id bigint, par_column_name character varying, par_column_val text) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: audit_base(toaudit, bigint, bigint, character varying, text); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION audit_base(toa toaudit, INOUT par_aud_seq bigint, par_table_id bigint, par_column_name character varying, par_column_val text) FROM PUBLIC;
REVOKE ALL ON FUNCTION audit_base(toa toaudit, INOUT par_aud_seq bigint, par_table_id bigint, par_column_name character varying, par_column_val text) FROM postgres;
GRANT ALL ON FUNCTION audit_base(toa toaudit, INOUT par_aud_seq bigint, par_table_id bigint, par_column_name character varying, par_column_val text) TO postgres;
GRANT ALL ON FUNCTION audit_base(toa toaudit, INOUT par_aud_seq bigint, par_table_id bigint, par_column_name character varying, par_column_val text) TO PUBLIC;
GRANT ALL ON FUNCTION audit_base(toa toaudit, INOUT par_aud_seq bigint, par_table_id bigint, par_column_name character varying, par_column_val text) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: audit_info(timestamp without time zone, character varying, timestamp without time zone, character varying); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION audit_info(timestamp without time zone, character varying, timestamp without time zone, character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION audit_info(timestamp without time zone, character varying, timestamp without time zone, character varying) FROM postgres;
GRANT ALL ON FUNCTION audit_info(timestamp without time zone, character varying, timestamp without time zone, character varying) TO postgres;
GRANT ALL ON FUNCTION audit_info(timestamp without time zone, character varying, timestamp without time zone, character varying) TO PUBLIC;
GRANT ALL ON FUNCTION audit_info(timestamp without time zone, character varying, timestamp without time zone, character varying) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: check_code(character varying, character varying); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION check_code(in_tblname character varying, in_codeval character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION check_code(in_tblname character varying, in_codeval character varying) FROM postgres;
GRANT ALL ON FUNCTION check_code(in_tblname character varying, in_codeval character varying) TO postgres;
GRANT ALL ON FUNCTION check_code(in_tblname character varying, in_codeval character varying) TO PUBLIC;
GRANT ALL ON FUNCTION check_code(in_tblname character varying, in_codeval character varying) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: check_code2(character varying, character varying, character varying); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION check_code2(in_tblname character varying, in_codeval1 character varying, in_codeval2 character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION check_code2(in_tblname character varying, in_codeval1 character varying, in_codeval2 character varying) FROM postgres;
GRANT ALL ON FUNCTION check_code2(in_tblname character varying, in_codeval1 character varying, in_codeval2 character varying) TO postgres;
GRANT ALL ON FUNCTION check_code2(in_tblname character varying, in_codeval1 character varying, in_codeval2 character varying) TO PUBLIC;
GRANT ALL ON FUNCTION check_code2(in_tblname character varying, in_codeval1 character varying, in_codeval2 character varying) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: check_code2_p(character varying, character varying, character varying); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION check_code2_p(in_tblname character varying, in_codeval1 character varying, in_codeval2 character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION check_code2_p(in_tblname character varying, in_codeval1 character varying, in_codeval2 character varying) FROM postgres;
GRANT ALL ON FUNCTION check_code2_p(in_tblname character varying, in_codeval1 character varying, in_codeval2 character varying) TO postgres;
GRANT ALL ON FUNCTION check_code2_p(in_tblname character varying, in_codeval1 character varying, in_codeval2 character varying) TO PUBLIC;
GRANT ALL ON FUNCTION check_code2_p(in_tblname character varying, in_codeval1 character varying, in_codeval2 character varying) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: check_code_p(character varying, character varying); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION check_code_p(in_tblname character varying, in_codeval character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION check_code_p(in_tblname character varying, in_codeval character varying) FROM postgres;
GRANT ALL ON FUNCTION check_code_p(in_tblname character varying, in_codeval character varying) TO postgres;
GRANT ALL ON FUNCTION check_code_p(in_tblname character varying, in_codeval character varying) TO PUBLIC;
GRANT ALL ON FUNCTION check_code_p(in_tblname character varying, in_codeval character varying) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: check_foreign(character varying, bigint); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION check_foreign(in_tblname character varying, in_tblid bigint) FROM PUBLIC;
REVOKE ALL ON FUNCTION check_foreign(in_tblname character varying, in_tblid bigint) FROM postgres;
GRANT ALL ON FUNCTION check_foreign(in_tblname character varying, in_tblid bigint) TO postgres;
GRANT ALL ON FUNCTION check_foreign(in_tblname character varying, in_tblid bigint) TO PUBLIC;
GRANT ALL ON FUNCTION check_foreign(in_tblname character varying, in_tblid bigint) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: check_foreign_p(character varying, bigint); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION check_foreign_p(in_tblname character varying, in_tblid bigint) FROM PUBLIC;
REVOKE ALL ON FUNCTION check_foreign_p(in_tblname character varying, in_tblid bigint) FROM postgres;
GRANT ALL ON FUNCTION check_foreign_p(in_tblname character varying, in_tblid bigint) TO postgres;
GRANT ALL ON FUNCTION check_foreign_p(in_tblname character varying, in_tblid bigint) TO PUBLIC;
GRANT ALL ON FUNCTION check_foreign_p(in_tblname character varying, in_tblid bigint) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: check_pp(character varying, character varying, character varying, character varying); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION check_pp(in_table character varying, in_process character varying, in_attrib character varying, in_val character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION check_pp(in_table character varying, in_process character varying, in_attrib character varying, in_val character varying) FROM postgres;
GRANT ALL ON FUNCTION check_pp(in_table character varying, in_process character varying, in_attrib character varying, in_val character varying) TO postgres;
GRANT ALL ON FUNCTION check_pp(in_table character varying, in_process character varying, in_attrib character varying, in_val character varying) TO PUBLIC;
GRANT ALL ON FUNCTION check_pp(in_table character varying, in_process character varying, in_attrib character varying, in_val character varying) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: cpe_iud(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION cpe_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION cpe_iud() FROM postgres;
GRANT ALL ON FUNCTION cpe_iud() TO postgres;
GRANT ALL ON FUNCTION cpe_iud() TO PUBLIC;
GRANT ALL ON FUNCTION cpe_iud() TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: cpe_iud_after_insert(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION cpe_iud_after_insert() FROM PUBLIC;
REVOKE ALL ON FUNCTION cpe_iud_after_insert() FROM postgres;
GRANT ALL ON FUNCTION cpe_iud_after_insert() TO postgres;
GRANT ALL ON FUNCTION cpe_iud_after_insert() TO PUBLIC;
GRANT ALL ON FUNCTION cpe_iud_after_insert() TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: cper_iud(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION cper_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION cper_iud() FROM postgres;
GRANT ALL ON FUNCTION cper_iud() TO postgres;
GRANT ALL ON FUNCTION cper_iud() TO PUBLIC;
GRANT ALL ON FUNCTION cper_iud() TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: create_gcod(character varying, character varying, character varying); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION create_gcod(in_codeschema character varying, in_codename character varying, in_codemean character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION create_gcod(in_codeschema character varying, in_codename character varying, in_codemean character varying) FROM postgres;
GRANT ALL ON FUNCTION create_gcod(in_codeschema character varying, in_codename character varying, in_codemean character varying) TO postgres;
GRANT ALL ON FUNCTION create_gcod(in_codeschema character varying, in_codename character varying, in_codemean character varying) TO jsharmony_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: create_gcod2(character varying, character varying, character varying); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION create_gcod2(in_codeschema character varying, in_codename character varying, in_codemean character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION create_gcod2(in_codeschema character varying, in_codename character varying, in_codemean character varying) FROM postgres;
GRANT ALL ON FUNCTION create_gcod2(in_codeschema character varying, in_codename character varying, in_codemean character varying) TO postgres;
GRANT ALL ON FUNCTION create_gcod2(in_codeschema character varying, in_codename character varying, in_codemean character varying) TO jsharmony_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: create_ucod(character varying, character varying, character varying); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION create_ucod(in_codeschema character varying, in_codename character varying, in_codemean character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION create_ucod(in_codeschema character varying, in_codename character varying, in_codemean character varying) FROM postgres;
GRANT ALL ON FUNCTION create_ucod(in_codeschema character varying, in_codename character varying, in_codemean character varying) TO postgres;
GRANT ALL ON FUNCTION create_ucod(in_codeschema character varying, in_codename character varying, in_codemean character varying) TO jsharmony_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: create_ucod2(character varying, character varying, character varying); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION create_ucod2(in_codeschema character varying, in_codename character varying, in_codemean character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION create_ucod2(in_codeschema character varying, in_codename character varying, in_codemean character varying) FROM postgres;
GRANT ALL ON FUNCTION create_ucod2(in_codeschema character varying, in_codename character varying, in_codemean character varying) TO postgres;
GRANT ALL ON FUNCTION create_ucod2(in_codeschema character varying, in_codename character varying, in_codemean character varying) TO jsharmony_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: d_iud(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION d_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION d_iud() FROM postgres;
GRANT ALL ON FUNCTION d_iud() TO postgres;
GRANT ALL ON FUNCTION d_iud() TO PUBLIC;
GRANT ALL ON FUNCTION d_iud() TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: digest(bytea, text); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION digest(bytea, text) FROM PUBLIC;
REVOKE ALL ON FUNCTION digest(bytea, text) FROM postgres;
GRANT ALL ON FUNCTION digest(bytea, text) TO postgres;
GRANT ALL ON FUNCTION digest(bytea, text) TO PUBLIC;
GRANT ALL ON FUNCTION digest(bytea, text) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: digest(text, text); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION digest(text, text) FROM PUBLIC;
REVOKE ALL ON FUNCTION digest(text, text) FROM postgres;
GRANT ALL ON FUNCTION digest(text, text) TO postgres;
GRANT ALL ON FUNCTION digest(text, text) TO PUBLIC;
GRANT ALL ON FUNCTION digest(text, text) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: gcod2_iud(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION gcod2_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION gcod2_iud() FROM postgres;
GRANT ALL ON FUNCTION gcod2_iud() TO postgres;
GRANT ALL ON FUNCTION gcod2_iud() TO PUBLIC;
GRANT ALL ON FUNCTION gcod2_iud() TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: gcod_iud(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION gcod_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION gcod_iud() FROM postgres;
GRANT ALL ON FUNCTION gcod_iud() TO postgres;
GRANT ALL ON FUNCTION gcod_iud() TO PUBLIC;
GRANT ALL ON FUNCTION gcod_iud() TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: get_cpe_name(bigint); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION get_cpe_name(in_pe_id bigint) FROM PUBLIC;
REVOKE ALL ON FUNCTION get_cpe_name(in_pe_id bigint) FROM postgres;
GRANT ALL ON FUNCTION get_cpe_name(in_pe_id bigint) TO postgres;
GRANT ALL ON FUNCTION get_cpe_name(in_pe_id bigint) TO PUBLIC;
GRANT ALL ON FUNCTION get_cpe_name(in_pe_id bigint) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: get_pe_name(bigint); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION get_pe_name(in_pe_id bigint) FROM PUBLIC;
REVOKE ALL ON FUNCTION get_pe_name(in_pe_id bigint) FROM postgres;
GRANT ALL ON FUNCTION get_pe_name(in_pe_id bigint) TO postgres;
GRANT ALL ON FUNCTION get_pe_name(in_pe_id bigint) TO PUBLIC;
GRANT ALL ON FUNCTION get_pe_name(in_pe_id bigint) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: get_ppd_desc(character varying, character varying); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION get_ppd_desc(in_ppd_process character varying, in_ppd_attrib character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION get_ppd_desc(in_ppd_process character varying, in_ppd_attrib character varying) FROM postgres;
GRANT ALL ON FUNCTION get_ppd_desc(in_ppd_process character varying, in_ppd_attrib character varying) TO postgres;
GRANT ALL ON FUNCTION get_ppd_desc(in_ppd_process character varying, in_ppd_attrib character varying) TO PUBLIC;
GRANT ALL ON FUNCTION get_ppd_desc(in_ppd_process character varying, in_ppd_attrib character varying) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: good_email(text); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION good_email(x text) FROM PUBLIC;
REVOKE ALL ON FUNCTION good_email(x text) FROM postgres;
GRANT ALL ON FUNCTION good_email(x text) TO postgres;
GRANT ALL ON FUNCTION good_email(x text) TO PUBLIC;
GRANT ALL ON FUNCTION good_email(x text) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: gpp_iud(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION gpp_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION gpp_iud() FROM postgres;
GRANT ALL ON FUNCTION gpp_iud() TO postgres;
GRANT ALL ON FUNCTION gpp_iud() TO PUBLIC;
GRANT ALL ON FUNCTION gpp_iud() TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: h_iud(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION h_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION h_iud() FROM postgres;
GRANT ALL ON FUNCTION h_iud() TO postgres;
GRANT ALL ON FUNCTION h_iud() TO PUBLIC;
GRANT ALL ON FUNCTION h_iud() TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: mycuser(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION mycuser() FROM PUBLIC;
REVOKE ALL ON FUNCTION mycuser() FROM postgres;
GRANT ALL ON FUNCTION mycuser() TO postgres;
GRANT ALL ON FUNCTION mycuser() TO PUBLIC;
GRANT ALL ON FUNCTION mycuser() TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: mycuser_email(text); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION mycuser_email(u text) FROM PUBLIC;
REVOKE ALL ON FUNCTION mycuser_email(u text) FROM postgres;
GRANT ALL ON FUNCTION mycuser_email(u text) TO postgres;
GRANT ALL ON FUNCTION mycuser_email(u text) TO PUBLIC;
GRANT ALL ON FUNCTION mycuser_email(u text) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: mycuser_fmt(text); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION mycuser_fmt(u text) FROM PUBLIC;
REVOKE ALL ON FUNCTION mycuser_fmt(u text) FROM postgres;
GRANT ALL ON FUNCTION mycuser_fmt(u text) TO postgres;
GRANT ALL ON FUNCTION mycuser_fmt(u text) TO PUBLIC;
GRANT ALL ON FUNCTION mycuser_fmt(u text) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: myhash(character, bigint, character varying); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION myhash(par_type character, par_pe_id bigint, par_pw character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION myhash(par_type character, par_pe_id bigint, par_pw character varying) FROM postgres;
GRANT ALL ON FUNCTION myhash(par_type character, par_pe_id bigint, par_pw character varying) TO postgres;
GRANT ALL ON FUNCTION myhash(par_type character, par_pe_id bigint, par_pw character varying) TO PUBLIC;
GRANT ALL ON FUNCTION myhash(par_type character, par_pe_id bigint, par_pw character varying) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: myisnumeric(text); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION myisnumeric(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION myisnumeric(text) FROM postgres;
GRANT ALL ON FUNCTION myisnumeric(text) TO postgres;
GRANT ALL ON FUNCTION myisnumeric(text) TO PUBLIC;
GRANT ALL ON FUNCTION myisnumeric(text) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: mymmddyy(timestamp without time zone); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION mymmddyy(timestamp without time zone) FROM PUBLIC;
REVOKE ALL ON FUNCTION mymmddyy(timestamp without time zone) FROM postgres;
GRANT ALL ON FUNCTION mymmddyy(timestamp without time zone) TO postgres;
GRANT ALL ON FUNCTION mymmddyy(timestamp without time zone) TO PUBLIC;
GRANT ALL ON FUNCTION mymmddyy(timestamp without time zone) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: mymmddyyhhmi(timestamp without time zone); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION mymmddyyhhmi(timestamp without time zone) FROM PUBLIC;
REVOKE ALL ON FUNCTION mymmddyyhhmi(timestamp without time zone) FROM postgres;
GRANT ALL ON FUNCTION mymmddyyhhmi(timestamp without time zone) TO postgres;
GRANT ALL ON FUNCTION mymmddyyhhmi(timestamp without time zone) TO PUBLIC;
GRANT ALL ON FUNCTION mymmddyyhhmi(timestamp without time zone) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: mymmddyyyyhhmi(timestamp without time zone); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION mymmddyyyyhhmi(timestamp without time zone) FROM PUBLIC;
REVOKE ALL ON FUNCTION mymmddyyyyhhmi(timestamp without time zone) FROM postgres;
GRANT ALL ON FUNCTION mymmddyyyyhhmi(timestamp without time zone) TO postgres;
GRANT ALL ON FUNCTION mymmddyyyyhhmi(timestamp without time zone) TO PUBLIC;
GRANT ALL ON FUNCTION mymmddyyyyhhmi(timestamp without time zone) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: mynow(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION mynow() FROM PUBLIC;
REVOKE ALL ON FUNCTION mynow() FROM postgres;
GRANT ALL ON FUNCTION mynow() TO postgres;
GRANT ALL ON FUNCTION mynow() TO PUBLIC;
GRANT ALL ON FUNCTION mynow() TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: mype(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION mype() FROM PUBLIC;
REVOKE ALL ON FUNCTION mype() FROM postgres;
GRANT ALL ON FUNCTION mype() TO postgres;
GRANT ALL ON FUNCTION mype() TO PUBLIC;
GRANT ALL ON FUNCTION mype() TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: mypec(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION mypec() FROM PUBLIC;
REVOKE ALL ON FUNCTION mypec() FROM postgres;
GRANT ALL ON FUNCTION mypec() TO postgres;
GRANT ALL ON FUNCTION mypec() TO PUBLIC;
GRANT ALL ON FUNCTION mypec() TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: mytodate(timestamp without time zone); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION mytodate(timestamp without time zone) FROM PUBLIC;
REVOKE ALL ON FUNCTION mytodate(timestamp without time zone) FROM postgres;
GRANT ALL ON FUNCTION mytodate(timestamp without time zone) TO postgres;
GRANT ALL ON FUNCTION mytodate(timestamp without time zone) TO PUBLIC;
GRANT ALL ON FUNCTION mytodate(timestamp without time zone) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: mytoday(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION mytoday() FROM PUBLIC;
REVOKE ALL ON FUNCTION mytoday() FROM postgres;
GRANT ALL ON FUNCTION mytoday() TO postgres;
GRANT ALL ON FUNCTION mytoday() TO PUBLIC;
GRANT ALL ON FUNCTION mytoday() TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: n_iud(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION n_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION n_iud() FROM postgres;
GRANT ALL ON FUNCTION n_iud() TO postgres;
GRANT ALL ON FUNCTION n_iud() TO PUBLIC;
GRANT ALL ON FUNCTION n_iud() TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: nonequal(bit, bit); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION nonequal(x1 bit, x2 bit) FROM PUBLIC;
REVOKE ALL ON FUNCTION nonequal(x1 bit, x2 bit) FROM postgres;
GRANT ALL ON FUNCTION nonequal(x1 bit, x2 bit) TO postgres;
GRANT ALL ON FUNCTION nonequal(x1 bit, x2 bit) TO PUBLIC;
GRANT ALL ON FUNCTION nonequal(x1 bit, x2 bit) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: nonequal(boolean, boolean); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION nonequal(x1 boolean, x2 boolean) FROM PUBLIC;
REVOKE ALL ON FUNCTION nonequal(x1 boolean, x2 boolean) FROM postgres;
GRANT ALL ON FUNCTION nonequal(x1 boolean, x2 boolean) TO postgres;
GRANT ALL ON FUNCTION nonequal(x1 boolean, x2 boolean) TO PUBLIC;
GRANT ALL ON FUNCTION nonequal(x1 boolean, x2 boolean) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: nonequal(smallint, smallint); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION nonequal(x1 smallint, x2 smallint) FROM PUBLIC;
REVOKE ALL ON FUNCTION nonequal(x1 smallint, x2 smallint) FROM postgres;
GRANT ALL ON FUNCTION nonequal(x1 smallint, x2 smallint) TO postgres;
GRANT ALL ON FUNCTION nonequal(x1 smallint, x2 smallint) TO PUBLIC;
GRANT ALL ON FUNCTION nonequal(x1 smallint, x2 smallint) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: nonequal(integer, integer); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION nonequal(x1 integer, x2 integer) FROM PUBLIC;
REVOKE ALL ON FUNCTION nonequal(x1 integer, x2 integer) FROM postgres;
GRANT ALL ON FUNCTION nonequal(x1 integer, x2 integer) TO postgres;
GRANT ALL ON FUNCTION nonequal(x1 integer, x2 integer) TO PUBLIC;
GRANT ALL ON FUNCTION nonequal(x1 integer, x2 integer) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: nonequal(bigint, bigint); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION nonequal(x1 bigint, x2 bigint) FROM PUBLIC;
REVOKE ALL ON FUNCTION nonequal(x1 bigint, x2 bigint) FROM postgres;
GRANT ALL ON FUNCTION nonequal(x1 bigint, x2 bigint) TO postgres;
GRANT ALL ON FUNCTION nonequal(x1 bigint, x2 bigint) TO PUBLIC;
GRANT ALL ON FUNCTION nonequal(x1 bigint, x2 bigint) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: nonequal(numeric, numeric); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION nonequal(x1 numeric, x2 numeric) FROM PUBLIC;
REVOKE ALL ON FUNCTION nonequal(x1 numeric, x2 numeric) FROM postgres;
GRANT ALL ON FUNCTION nonequal(x1 numeric, x2 numeric) TO postgres;
GRANT ALL ON FUNCTION nonequal(x1 numeric, x2 numeric) TO PUBLIC;
GRANT ALL ON FUNCTION nonequal(x1 numeric, x2 numeric) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: nonequal(text, text); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION nonequal(x1 text, x2 text) FROM PUBLIC;
REVOKE ALL ON FUNCTION nonequal(x1 text, x2 text) FROM postgres;
GRANT ALL ON FUNCTION nonequal(x1 text, x2 text) TO postgres;
GRANT ALL ON FUNCTION nonequal(x1 text, x2 text) TO PUBLIC;
GRANT ALL ON FUNCTION nonequal(x1 text, x2 text) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: nonequal(timestamp without time zone, timestamp without time zone); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION nonequal(x1 timestamp without time zone, x2 timestamp without time zone) FROM PUBLIC;
REVOKE ALL ON FUNCTION nonequal(x1 timestamp without time zone, x2 timestamp without time zone) FROM postgres;
GRANT ALL ON FUNCTION nonequal(x1 timestamp without time zone, x2 timestamp without time zone) TO postgres;
GRANT ALL ON FUNCTION nonequal(x1 timestamp without time zone, x2 timestamp without time zone) TO PUBLIC;
GRANT ALL ON FUNCTION nonequal(x1 timestamp without time zone, x2 timestamp without time zone) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: pe_iud(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION pe_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION pe_iud() FROM postgres;
GRANT ALL ON FUNCTION pe_iud() TO postgres;
GRANT ALL ON FUNCTION pe_iud() TO PUBLIC;
GRANT ALL ON FUNCTION pe_iud() TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: ppd_iud(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION ppd_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION ppd_iud() FROM postgres;
GRANT ALL ON FUNCTION ppd_iud() TO postgres;
GRANT ALL ON FUNCTION ppd_iud() TO PUBLIC;
GRANT ALL ON FUNCTION ppd_iud() TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: ppp_iud(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION ppp_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION ppp_iud() FROM postgres;
GRANT ALL ON FUNCTION ppp_iud() TO postgres;
GRANT ALL ON FUNCTION ppp_iud() TO PUBLIC;
GRANT ALL ON FUNCTION ppp_iud() TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: sanit(text); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION sanit(x text) FROM PUBLIC;
REVOKE ALL ON FUNCTION sanit(x text) FROM postgres;
GRANT ALL ON FUNCTION sanit(x text) TO postgres;
GRANT ALL ON FUNCTION sanit(x text) TO PUBLIC;
GRANT ALL ON FUNCTION sanit(x text) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: sanit_json(text); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION sanit_json(x text) FROM PUBLIC;
REVOKE ALL ON FUNCTION sanit_json(x text) FROM postgres;
GRANT ALL ON FUNCTION sanit_json(x text) TO postgres;
GRANT ALL ON FUNCTION sanit_json(x text) TO PUBLIC;
GRANT ALL ON FUNCTION sanit_json(x text) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: spef_iud(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION spef_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION spef_iud() FROM postgres;
GRANT ALL ON FUNCTION spef_iud() TO postgres;
GRANT ALL ON FUNCTION spef_iud() TO PUBLIC;
GRANT ALL ON FUNCTION spef_iud() TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: sper_iud(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION sper_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION sper_iud() FROM postgres;
GRANT ALL ON FUNCTION sper_iud() TO postgres;
GRANT ALL ON FUNCTION sper_iud() TO PUBLIC;
GRANT ALL ON FUNCTION sper_iud() TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: table_type(character varying, character varying); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION table_type(in_schema character varying, in_name character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION table_type(in_schema character varying, in_name character varying) FROM postgres;
GRANT ALL ON FUNCTION table_type(in_schema character varying, in_name character varying) TO postgres;
GRANT ALL ON FUNCTION table_type(in_schema character varying, in_name character varying) TO PUBLIC;
GRANT ALL ON FUNCTION table_type(in_schema character varying, in_name character varying) TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: txt_iud(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION txt_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION txt_iud() FROM postgres;
GRANT ALL ON FUNCTION txt_iud() TO postgres;
GRANT ALL ON FUNCTION txt_iud() TO PUBLIC;
GRANT ALL ON FUNCTION txt_iud() TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: v_crmsel_iud_insteadof_update(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION v_crmsel_iud_insteadof_update() FROM PUBLIC;
REVOKE ALL ON FUNCTION v_crmsel_iud_insteadof_update() FROM postgres;
GRANT ALL ON FUNCTION v_crmsel_iud_insteadof_update() TO postgres;
GRANT ALL ON FUNCTION v_crmsel_iud_insteadof_update() TO PUBLIC;
GRANT ALL ON FUNCTION v_crmsel_iud_insteadof_update() TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: v_srmsel_iud_insteadof_update(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION v_srmsel_iud_insteadof_update() FROM PUBLIC;
REVOKE ALL ON FUNCTION v_srmsel_iud_insteadof_update() FROM postgres;
GRANT ALL ON FUNCTION v_srmsel_iud_insteadof_update() TO postgres;
GRANT ALL ON FUNCTION v_srmsel_iud_insteadof_update() TO PUBLIC;
GRANT ALL ON FUNCTION v_srmsel_iud_insteadof_update() TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: xpp_iud(); Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON FUNCTION xpp_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION xpp_iud() FROM postgres;
GRANT ALL ON FUNCTION xpp_iud() TO postgres;
GRANT ALL ON FUNCTION xpp_iud() TO PUBLIC;
GRANT ALL ON FUNCTION xpp_iud() TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: aud_d; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE aud_d FROM PUBLIC;
REVOKE ALL ON TABLE aud_d FROM postgres;
GRANT ALL ON TABLE aud_d TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE aud_d TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: aud_h; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE aud_h FROM PUBLIC;
REVOKE ALL ON TABLE aud_h FROM postgres;
GRANT ALL ON TABLE aud_h TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE aud_h TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: aud_h_aud_seq_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE aud_h_aud_seq_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE aud_h_aud_seq_seq FROM postgres;
GRANT ALL ON SEQUENCE aud_h_aud_seq_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE aud_h_aud_seq_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: cpe; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE cpe FROM PUBLIC;
REVOKE ALL ON TABLE cpe FROM postgres;
GRANT ALL ON TABLE cpe TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cpe TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: cpe_pe_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE cpe_pe_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE cpe_pe_id_seq FROM postgres;
GRANT ALL ON SEQUENCE cpe_pe_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE cpe_pe_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: cper; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE cper FROM PUBLIC;
REVOKE ALL ON TABLE cper FROM postgres;
GRANT ALL ON TABLE cper TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cper TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: cper_cper_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE cper_cper_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE cper_cper_id_seq FROM postgres;
GRANT ALL ON SEQUENCE cper_cper_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE cper_cper_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: cr; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE cr FROM PUBLIC;
REVOKE ALL ON TABLE cr FROM postgres;
GRANT ALL ON TABLE cr TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cr TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: cr_cr_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE cr_cr_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE cr_cr_id_seq FROM postgres;
GRANT ALL ON SEQUENCE cr_cr_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE cr_cr_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: crm; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE crm FROM PUBLIC;
REVOKE ALL ON TABLE crm FROM postgres;
GRANT ALL ON TABLE crm TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE crm TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: crm_crm_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE crm_crm_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE crm_crm_id_seq FROM postgres;
GRANT ALL ON SEQUENCE crm_crm_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE crm_crm_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: d; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE d FROM PUBLIC;
REVOKE ALL ON TABLE d FROM postgres;
GRANT ALL ON TABLE d TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE d TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: d_d_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE d_d_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE d_d_id_seq FROM postgres;
GRANT ALL ON SEQUENCE d_d_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE d_d_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: dual; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE dual FROM PUBLIC;
REVOKE ALL ON TABLE dual FROM postgres;
GRANT ALL ON TABLE dual TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE dual TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: dual_dual_ident_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE dual_dual_ident_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE dual_dual_ident_seq FROM postgres;
GRANT ALL ON SEQUENCE dual_dual_ident_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE dual_dual_ident_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: gcod_gcod_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE gcod_gcod_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE gcod_gcod_id_seq FROM postgres;
GRANT ALL ON SEQUENCE gcod_gcod_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE gcod_gcod_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: gcod; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE gcod FROM PUBLIC;
REVOKE ALL ON TABLE gcod FROM postgres;
GRANT ALL ON TABLE gcod TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE gcod TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: gcod2_gcod2_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE gcod2_gcod2_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE gcod2_gcod2_id_seq FROM postgres;
GRANT ALL ON SEQUENCE gcod2_gcod2_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE gcod2_gcod2_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: gcod2; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE gcod2 FROM PUBLIC;
REVOKE ALL ON TABLE gcod2 FROM postgres;
GRANT ALL ON TABLE gcod2 TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE gcod2 TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: gcod2_d_scope_d_ctgr; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE gcod2_d_scope_d_ctgr FROM PUBLIC;
REVOKE ALL ON TABLE gcod2_d_scope_d_ctgr FROM postgres;
GRANT ALL ON TABLE gcod2_d_scope_d_ctgr TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE gcod2_d_scope_d_ctgr TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: gcod2_h; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE gcod2_h FROM PUBLIC;
REVOKE ALL ON TABLE gcod2_h FROM postgres;
GRANT ALL ON TABLE gcod2_h TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE gcod2_h TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: gcod_h; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE gcod_h FROM PUBLIC;
REVOKE ALL ON TABLE gcod_h FROM postgres;
GRANT ALL ON TABLE gcod_h TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE gcod_h TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: gpp; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE gpp FROM PUBLIC;
REVOKE ALL ON TABLE gpp FROM postgres;
GRANT ALL ON TABLE gpp TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE gpp TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: gpp_gpp_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE gpp_gpp_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE gpp_gpp_id_seq FROM postgres;
GRANT ALL ON SEQUENCE gpp_gpp_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE gpp_gpp_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: h; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE h FROM PUBLIC;
REVOKE ALL ON TABLE h FROM postgres;
GRANT ALL ON TABLE h TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE h TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: h_h_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE h_h_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE h_h_id_seq FROM postgres;
GRANT ALL ON SEQUENCE h_h_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE h_h_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: hp; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE hp FROM PUBLIC;
REVOKE ALL ON TABLE hp FROM postgres;
GRANT ALL ON TABLE hp TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE hp TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: hp_hp_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE hp_hp_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE hp_hp_id_seq FROM postgres;
GRANT ALL ON SEQUENCE hp_hp_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE hp_hp_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: n; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE n FROM PUBLIC;
REVOKE ALL ON TABLE n FROM postgres;
GRANT ALL ON TABLE n TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE n TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: n_n_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE n_n_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE n_n_id_seq FROM postgres;
GRANT ALL ON SEQUENCE n_n_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE n_n_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: numbers; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE numbers FROM PUBLIC;
REVOKE ALL ON TABLE numbers FROM postgres;
GRANT ALL ON TABLE numbers TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE numbers TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: pe; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE pe FROM PUBLIC;
REVOKE ALL ON TABLE pe FROM postgres;
GRANT ALL ON TABLE pe TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE pe TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: pe_pe_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE pe_pe_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE pe_pe_id_seq FROM postgres;
GRANT ALL ON SEQUENCE pe_pe_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE pe_pe_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: ppd; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ppd FROM PUBLIC;
REVOKE ALL ON TABLE ppd FROM postgres;
GRANT ALL ON TABLE ppd TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ppd TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: ppd_ppd_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE ppd_ppd_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE ppd_ppd_id_seq FROM postgres;
GRANT ALL ON SEQUENCE ppd_ppd_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE ppd_ppd_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: ppp; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ppp FROM PUBLIC;
REVOKE ALL ON TABLE ppp FROM postgres;
GRANT ALL ON TABLE ppp TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ppp TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: ppp_ppp_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE ppp_ppp_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE ppp_ppp_id_seq FROM postgres;
GRANT ALL ON SEQUENCE ppp_ppp_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE ppp_ppp_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: rq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE rq FROM PUBLIC;
REVOKE ALL ON TABLE rq FROM postgres;
GRANT ALL ON TABLE rq TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE rq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: rq_rq_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE rq_rq_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE rq_rq_id_seq FROM postgres;
GRANT ALL ON SEQUENCE rq_rq_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE rq_rq_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: rqst; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE rqst FROM PUBLIC;
REVOKE ALL ON TABLE rqst FROM postgres;
GRANT ALL ON TABLE rqst TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE rqst TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: rqst_d; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE rqst_d FROM PUBLIC;
REVOKE ALL ON TABLE rqst_d FROM postgres;
GRANT ALL ON TABLE rqst_d TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE rqst_d TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: rqst_d_rqst_d_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE rqst_d_rqst_d_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE rqst_d_rqst_d_id_seq FROM postgres;
GRANT ALL ON SEQUENCE rqst_d_rqst_d_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE rqst_d_rqst_d_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: rqst_email; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE rqst_email FROM PUBLIC;
REVOKE ALL ON TABLE rqst_email FROM postgres;
GRANT ALL ON TABLE rqst_email TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE rqst_email TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: rqst_email_rqst_email_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE rqst_email_rqst_email_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE rqst_email_rqst_email_id_seq FROM postgres;
GRANT ALL ON SEQUENCE rqst_email_rqst_email_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE rqst_email_rqst_email_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: rqst_n; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE rqst_n FROM PUBLIC;
REVOKE ALL ON TABLE rqst_n FROM postgres;
GRANT ALL ON TABLE rqst_n TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE rqst_n TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: rqst_n_rqst_n_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE rqst_n_rqst_n_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE rqst_n_rqst_n_id_seq FROM postgres;
GRANT ALL ON SEQUENCE rqst_n_rqst_n_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE rqst_n_rqst_n_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: rqst_rq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE rqst_rq FROM PUBLIC;
REVOKE ALL ON TABLE rqst_rq FROM postgres;
GRANT ALL ON TABLE rqst_rq TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE rqst_rq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: rqst_rq_rqst_rq_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE rqst_rq_rqst_rq_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE rqst_rq_rqst_rq_id_seq FROM postgres;
GRANT ALL ON SEQUENCE rqst_rq_rqst_rq_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE rqst_rq_rqst_rq_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: rqst_rqst_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE rqst_rqst_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE rqst_rqst_id_seq FROM postgres;
GRANT ALL ON SEQUENCE rqst_rqst_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE rqst_rqst_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: rqst_sms; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE rqst_sms FROM PUBLIC;
REVOKE ALL ON TABLE rqst_sms FROM postgres;
GRANT ALL ON TABLE rqst_sms TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE rqst_sms TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: rqst_sms_rqst_sms_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE rqst_sms_rqst_sms_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE rqst_sms_rqst_sms_id_seq FROM postgres;
GRANT ALL ON SEQUENCE rqst_sms_rqst_sms_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE rqst_sms_rqst_sms_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: sf; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE sf FROM PUBLIC;
REVOKE ALL ON TABLE sf FROM postgres;
GRANT ALL ON TABLE sf TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sf TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: sf_sf_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE sf_sf_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE sf_sf_id_seq FROM postgres;
GRANT ALL ON SEQUENCE sf_sf_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE sf_sf_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: sm; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE sm FROM PUBLIC;
REVOKE ALL ON TABLE sm FROM postgres;
GRANT ALL ON TABLE sm TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sm TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: sm_sm_id_auto_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE sm_sm_id_auto_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE sm_sm_id_auto_seq FROM postgres;
GRANT ALL ON SEQUENCE sm_sm_id_auto_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE sm_sm_id_auto_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: spef; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE spef FROM PUBLIC;
REVOKE ALL ON TABLE spef FROM postgres;
GRANT ALL ON TABLE spef TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE spef TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: spef_spef_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE spef_spef_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE spef_spef_id_seq FROM postgres;
GRANT ALL ON SEQUENCE spef_spef_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE spef_spef_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: sper; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE sper FROM PUBLIC;
REVOKE ALL ON TABLE sper FROM postgres;
GRANT ALL ON TABLE sper TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sper TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: sper_sper_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE sper_sper_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE sper_sper_id_seq FROM postgres;
GRANT ALL ON SEQUENCE sper_sper_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE sper_sper_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: sr; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE sr FROM PUBLIC;
REVOKE ALL ON TABLE sr FROM postgres;
GRANT ALL ON TABLE sr TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE sr TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: sr_sr_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE sr_sr_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE sr_sr_id_seq FROM postgres;
GRANT ALL ON SEQUENCE sr_sr_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE sr_sr_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: srm; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE srm FROM PUBLIC;
REVOKE ALL ON TABLE srm FROM postgres;
GRANT ALL ON TABLE srm TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE srm TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: srm_srm_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE srm_srm_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE srm_srm_id_seq FROM postgres;
GRANT ALL ON SEQUENCE srm_srm_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE srm_srm_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: txt; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE txt FROM PUBLIC;
REVOKE ALL ON TABLE txt FROM postgres;
GRANT ALL ON TABLE txt TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE txt TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: txt_txt_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE txt_txt_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE txt_txt_id_seq FROM postgres;
GRANT ALL ON SEQUENCE txt_txt_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE txt_txt_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: ucod; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ucod FROM PUBLIC;
REVOKE ALL ON TABLE ucod FROM postgres;
GRANT ALL ON TABLE ucod TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: ucod2_ucod2_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE ucod2_ucod2_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE ucod2_ucod2_id_seq FROM postgres;
GRANT ALL ON SEQUENCE ucod2_ucod2_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE ucod2_ucod2_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: ucod2; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ucod2 FROM PUBLIC;
REVOKE ALL ON TABLE ucod2 FROM postgres;
GRANT ALL ON TABLE ucod2 TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod2 TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: ucod2_country_state; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ucod2_country_state FROM PUBLIC;
REVOKE ALL ON TABLE ucod2_country_state FROM postgres;
GRANT ALL ON TABLE ucod2_country_state TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod2_country_state TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: ucod2_gpp_process_attrib_v; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ucod2_gpp_process_attrib_v FROM PUBLIC;
REVOKE ALL ON TABLE ucod2_gpp_process_attrib_v FROM postgres;
GRANT ALL ON TABLE ucod2_gpp_process_attrib_v TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod2_gpp_process_attrib_v TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: ucod2_h; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ucod2_h FROM PUBLIC;
REVOKE ALL ON TABLE ucod2_h FROM postgres;
GRANT ALL ON TABLE ucod2_h TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod2_h TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: ucod2_h_ucod2_h_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE ucod2_h_ucod2_h_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE ucod2_h_ucod2_h_id_seq FROM postgres;
GRANT ALL ON SEQUENCE ucod2_h_ucod2_h_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE ucod2_h_ucod2_h_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: ucod2_ppp_process_attrib_v; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ucod2_ppp_process_attrib_v FROM PUBLIC;
REVOKE ALL ON TABLE ucod2_ppp_process_attrib_v FROM postgres;
GRANT ALL ON TABLE ucod2_ppp_process_attrib_v TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod2_ppp_process_attrib_v TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: ucod2_xpp_process_attrib_v; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ucod2_xpp_process_attrib_v FROM PUBLIC;
REVOKE ALL ON TABLE ucod2_xpp_process_attrib_v FROM postgres;
GRANT ALL ON TABLE ucod2_xpp_process_attrib_v TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod2_xpp_process_attrib_v TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: ucod_ac; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ucod_ac FROM PUBLIC;
REVOKE ALL ON TABLE ucod_ac FROM postgres;
GRANT ALL ON TABLE ucod_ac TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod_ac TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: ucod_ac1; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ucod_ac1 FROM PUBLIC;
REVOKE ALL ON TABLE ucod_ac1 FROM postgres;
GRANT ALL ON TABLE ucod_ac1 TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod_ac1 TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: ucod_ahc; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ucod_ahc FROM PUBLIC;
REVOKE ALL ON TABLE ucod_ahc FROM postgres;
GRANT ALL ON TABLE ucod_ahc TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod_ahc TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: ucod_country; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ucod_country FROM PUBLIC;
REVOKE ALL ON TABLE ucod_country FROM postgres;
GRANT ALL ON TABLE ucod_country TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod_country TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: ucod_d_scope; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ucod_d_scope FROM PUBLIC;
REVOKE ALL ON TABLE ucod_d_scope FROM postgres;
GRANT ALL ON TABLE ucod_d_scope TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod_d_scope TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: ucod_gpp_process_v; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ucod_gpp_process_v FROM PUBLIC;
REVOKE ALL ON TABLE ucod_gpp_process_v FROM postgres;
GRANT ALL ON TABLE ucod_gpp_process_v TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod_gpp_process_v TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: ucod_h; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ucod_h FROM PUBLIC;
REVOKE ALL ON TABLE ucod_h FROM postgres;
GRANT ALL ON TABLE ucod_h TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod_h TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: ucod_h_ucod_h_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE ucod_h_ucod_h_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE ucod_h_ucod_h_id_seq FROM postgres;
GRANT ALL ON SEQUENCE ucod_h_ucod_h_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE ucod_h_ucod_h_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: ucod_n_scope; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ucod_n_scope FROM PUBLIC;
REVOKE ALL ON TABLE ucod_n_scope FROM postgres;
GRANT ALL ON TABLE ucod_n_scope TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod_n_scope TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: ucod_n_type; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ucod_n_type FROM PUBLIC;
REVOKE ALL ON TABLE ucod_n_type FROM postgres;
GRANT ALL ON TABLE ucod_n_type TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod_n_type TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: ucod_ppd_type; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ucod_ppd_type FROM PUBLIC;
REVOKE ALL ON TABLE ucod_ppd_type FROM postgres;
GRANT ALL ON TABLE ucod_ppd_type TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod_ppd_type TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: ucod_ppp_process_v; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ucod_ppp_process_v FROM PUBLIC;
REVOKE ALL ON TABLE ucod_ppp_process_v FROM postgres;
GRANT ALL ON TABLE ucod_ppp_process_v TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod_ppp_process_v TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: ucod_rqst_atype; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ucod_rqst_atype FROM PUBLIC;
REVOKE ALL ON TABLE ucod_rqst_atype FROM postgres;
GRANT ALL ON TABLE ucod_rqst_atype TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod_rqst_atype TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: ucod_rqst_source; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ucod_rqst_source FROM PUBLIC;
REVOKE ALL ON TABLE ucod_rqst_source FROM postgres;
GRANT ALL ON TABLE ucod_rqst_source TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod_rqst_source TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: ucod_txt_type; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ucod_txt_type FROM PUBLIC;
REVOKE ALL ON TABLE ucod_txt_type FROM postgres;
GRANT ALL ON TABLE ucod_txt_type TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod_txt_type TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: ucod_ucod_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE ucod_ucod_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE ucod_ucod_id_seq FROM postgres;
GRANT ALL ON SEQUENCE ucod_ucod_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE ucod_ucod_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: ucod_v_sts; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ucod_v_sts FROM PUBLIC;
REVOKE ALL ON TABLE ucod_v_sts FROM postgres;
GRANT ALL ON TABLE ucod_v_sts TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod_v_sts TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: ucod_xpp_process_v; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE ucod_xpp_process_v FROM PUBLIC;
REVOKE ALL ON TABLE ucod_xpp_process_v FROM postgres;
GRANT ALL ON TABLE ucod_xpp_process_v TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ucod_xpp_process_v TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: v; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v FROM PUBLIC;
REVOKE ALL ON TABLE v FROM postgres;
GRANT ALL ON TABLE v TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: v_audl_raw; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_audl_raw FROM PUBLIC;
REVOKE ALL ON TABLE v_audl_raw FROM postgres;
GRANT ALL ON TABLE v_audl_raw TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_audl_raw TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: v_cper_nostar; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_cper_nostar FROM PUBLIC;
REVOKE ALL ON TABLE v_cper_nostar FROM postgres;
GRANT ALL ON TABLE v_cper_nostar TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_cper_nostar TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: v_crmsel; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_crmsel FROM PUBLIC;
REVOKE ALL ON TABLE v_crmsel FROM postgres;
GRANT ALL ON TABLE v_crmsel TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_crmsel TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: v_d_ext; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_d_ext FROM PUBLIC;
REVOKE ALL ON TABLE v_d_ext FROM postgres;
GRANT ALL ON TABLE v_d_ext TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_d_ext TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: v_d_x; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_d_x FROM PUBLIC;
REVOKE ALL ON TABLE v_d_x FROM postgres;
GRANT ALL ON TABLE v_d_x TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_d_x TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: v_dl; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_dl FROM PUBLIC;
REVOKE ALL ON TABLE v_dl FROM postgres;
GRANT ALL ON TABLE v_dl TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_dl TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: v_gppl; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_gppl FROM PUBLIC;
REVOKE ALL ON TABLE v_gppl FROM postgres;
GRANT ALL ON TABLE v_gppl TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_gppl TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: xpp; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE xpp FROM PUBLIC;
REVOKE ALL ON TABLE xpp FROM postgres;
GRANT ALL ON TABLE xpp TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE xpp TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: v_pp; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_pp FROM PUBLIC;
REVOKE ALL ON TABLE v_pp FROM postgres;
GRANT ALL ON TABLE v_pp TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_pp TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: v_house; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_house FROM PUBLIC;
REVOKE ALL ON TABLE v_house FROM postgres;
GRANT ALL ON TABLE v_house TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_house TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: v_months; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_months FROM PUBLIC;
REVOKE ALL ON TABLE v_months FROM postgres;
GRANT ALL ON TABLE v_months TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_months TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: v_my_roles; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_my_roles FROM PUBLIC;
REVOKE ALL ON TABLE v_my_roles FROM postgres;
GRANT ALL ON TABLE v_my_roles TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_my_roles TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: v_mype; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_mype FROM PUBLIC;
REVOKE ALL ON TABLE v_mype FROM postgres;
GRANT ALL ON TABLE v_mype TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_mype TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: v_n_ext; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_n_ext FROM PUBLIC;
REVOKE ALL ON TABLE v_n_ext FROM postgres;
GRANT ALL ON TABLE v_n_ext TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_n_ext TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: v_nl; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_nl FROM PUBLIC;
REVOKE ALL ON TABLE v_nl FROM postgres;
GRANT ALL ON TABLE v_nl TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_nl TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: v_ppdl; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_ppdl FROM PUBLIC;
REVOKE ALL ON TABLE v_ppdl FROM postgres;
GRANT ALL ON TABLE v_ppdl TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_ppdl TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: v_pppl; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_pppl FROM PUBLIC;
REVOKE ALL ON TABLE v_pppl FROM postgres;
GRANT ALL ON TABLE v_pppl TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_pppl TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: v_srmsel; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_srmsel FROM PUBLIC;
REVOKE ALL ON TABLE v_srmsel FROM postgres;
GRANT ALL ON TABLE v_srmsel TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_srmsel TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: v_v_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE v_v_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE v_v_id_seq FROM postgres;
GRANT ALL ON SEQUENCE v_v_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE v_v_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: v_xppl; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_xppl FROM PUBLIC;
REVOKE ALL ON TABLE v_xppl FROM postgres;
GRANT ALL ON TABLE v_xppl TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_xppl TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: v_years; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON TABLE v_years FROM PUBLIC;
REVOKE ALL ON TABLE v_years FROM postgres;
GRANT ALL ON TABLE v_years TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_years TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: xpp_xpp_id_seq; Type: ACL; Schema: jsharmony; Owner: postgres
--

REVOKE ALL ON SEQUENCE xpp_xpp_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE xpp_xpp_id_seq FROM postgres;
GRANT ALL ON SEQUENCE xpp_xpp_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE xpp_xpp_id_seq TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: jsharmony; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA jsharmony REVOKE ALL ON SEQUENCES  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA jsharmony REVOKE ALL ON SEQUENCES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA jsharmony GRANT SELECT,UPDATE ON SEQUENCES  TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: jsharmony; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA jsharmony REVOKE ALL ON FUNCTIONS  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA jsharmony REVOKE ALL ON FUNCTIONS  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA jsharmony GRANT ALL ON FUNCTIONS  TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: jsharmony; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA jsharmony REVOKE ALL ON TABLES  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA jsharmony REVOKE ALL ON TABLES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA jsharmony GRANT SELECT,INSERT,DELETE,UPDATE ON TABLES  TO jsharmony_%%%INIT_DB_LCASE%%%_role_exec;



--
--

