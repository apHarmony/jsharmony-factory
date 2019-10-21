SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = {schema}, pg_catalog;

--
-- Name: cust_user_iud(); Type: FUNCTION; Schema: {schema}; Owner: postgres
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
        my_toa.audit_table_name := lower(TG_TABLE_NAME::text);
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
          IF coalesce({schema}.get_cust_id('cust', NEW.cust_id),0) <= 0 THEN
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
            hash = {schema}.my_hash('C', NEW.sys_user_id, newpw);
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
-- Name: cust_user_iud_after_insert(); Type: FUNCTION; Schema: {schema}; Owner: postgres
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
-- Name: cust_user_role_iud(); Type: FUNCTION; Schema: {schema}; Owner: postgres
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
      wk_cust_id    bigint;
      wk_sys_user_id   bigint;
      
    BEGIN

        /**********************************/
        /* INITIALIZE                     */ 
        /**********************************/

        

        wk_sys_user_id := case TG_OP when 'DELETE' then OLD.sys_user_id else NEW.sys_user_id end;  
        wk_cust_id := {schema}.get_cust_id('cust_user', wk_sys_user_id);


        my_toa.op := TG_OP;
        my_toa.audit_table_name := lower(TG_TABLE_NAME::text);
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
-- Name: get_cust_user_name(bigint); Type: FUNCTION; Schema: {schema}; Owner: postgres
--

CREATE OR REPLACE FUNCTION get_cust_user_name(in_sys_user_id bigint) RETURNS character varying
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

--
-- Name: v_cust_menu_role_selection_iud_insteadof_update(); Type: FUNCTION; Schema: {schema}; Owner: postgres
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
-- Name: cust_user; Type: TABLE; Schema: {schema}; Owner: postgres
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
-- Name: TABLE cust_user; Type: COMMENT; Schema: {schema}; Owner: postgres
--

COMMENT ON TABLE cust_user IS '	Customer Personnel (CONTROL)';


--
-- Name: cust_user_sys_user_id_seq; Type: SEQUENCE; Schema: {schema}; Owner: postgres
--

CREATE SEQUENCE cust_user_sys_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE cust_user_sys_user_id_seq OWNER TO postgres;

--
-- Name: cust_user_sys_user_id_seq; Type: SEQUENCE OWNED BY; Schema: {schema}; Owner: postgres
--

ALTER SEQUENCE cust_user_sys_user_id_seq OWNED BY cust_user.sys_user_id;


--
-- Name: cust_user_role; Type: TABLE; Schema: {schema}; Owner: postgres
--

CREATE TABLE cust_user_role (
    sys_user_id bigint NOT NULL,
    cust_user_role_snotes character varying(255),
    cust_user_role_id bigint NOT NULL,
    cust_role_name character varying(16) NOT NULL
);


ALTER TABLE cust_user_role OWNER TO postgres;

--
-- Name: TABLE cust_user_role; Type: COMMENT; Schema: {schema}; Owner: postgres
--

COMMENT ON TABLE cust_user_role IS '	Customer - Personnel Roles (CONTROL)';


--
-- Name: cust_user_role_cust_user_role_id_seq; Type: SEQUENCE; Schema: {schema}; Owner: postgres
--

CREATE SEQUENCE cust_user_role_cust_user_role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE cust_user_role_cust_user_role_id_seq OWNER TO postgres;

--
-- Name: cust_user_role_cust_user_role_id_seq; Type: SEQUENCE OWNED BY; Schema: {schema}; Owner: postgres
--

ALTER SEQUENCE cust_user_role_cust_user_role_id_seq OWNED BY cust_user_role.cust_user_role_id;


--
-- Name: cust_role; Type: TABLE; Schema: {schema}; Owner: postgres
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
-- Name: TABLE cust_role; Type: COMMENT; Schema: {schema}; Owner: postgres
--

COMMENT ON TABLE cust_role IS 'Customer - Roles (CONTROL)';


--
-- Name: cust_role_cust_role_id_seq; Type: SEQUENCE; Schema: {schema}; Owner: postgres
--

CREATE SEQUENCE cust_role_cust_role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE cust_role_cust_role_id_seq OWNER TO postgres;

--
-- Name: cust_role_cust_role_id_seq; Type: SEQUENCE OWNED BY; Schema: {schema}; Owner: postgres
--

ALTER SEQUENCE cust_role_cust_role_id_seq OWNED BY cust_role.cust_role_id;


--
-- Name: cust_menu_role; Type: TABLE; Schema: {schema}; Owner: postgres
--

CREATE TABLE cust_menu_role (
    menu_id bigint NOT NULL,
    cust_menu_role_snotes character varying(255),
    cust_menu_role_id bigint NOT NULL,
    cust_role_name character varying(16) NOT NULL
);


ALTER TABLE cust_menu_role OWNER TO postgres;

--
-- Name: TABLE cust_menu_role; Type: COMMENT; Schema: {schema}; Owner: postgres
--

COMMENT ON TABLE cust_menu_role IS 'Customer - Role Menu Items (CONTROL)';


--
-- Name: cust_menu_role_cust_menu_role_id_seq; Type: SEQUENCE; Schema: {schema}; Owner: postgres
--

CREATE SEQUENCE cust_menu_role_cust_menu_role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE cust_menu_role_cust_menu_role_id_seq OWNER TO postgres;

--
-- Name: cust_menu_role_cust_menu_role_id_seq; Type: SEQUENCE OWNED BY; Schema: {schema}; Owner: postgres
--

ALTER SEQUENCE cust_menu_role_cust_menu_role_id_seq OWNED BY cust_menu_role.cust_menu_role_id;


--
-- Name: v_cust_user_nostar; Type: VIEW; Schema: {schema}; Owner: postgres
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
-- Name: v_cust_menu_role_selection; Type: VIEW; Schema: {schema}; Owner: postgres
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
-- Name: sys_user_id; Type: DEFAULT; Schema: {schema}; Owner: postgres
--

ALTER TABLE ONLY cust_user ALTER COLUMN sys_user_id SET DEFAULT nextval('cust_user_sys_user_id_seq'::regclass);


--
-- Name: cust_user_role_id; Type: DEFAULT; Schema: {schema}; Owner: postgres
--

ALTER TABLE ONLY cust_user_role ALTER COLUMN cust_user_role_id SET DEFAULT nextval('cust_user_role_cust_user_role_id_seq'::regclass);


--
-- Name: cust_role_id; Type: DEFAULT; Schema: {schema}; Owner: postgres
--

ALTER TABLE ONLY cust_role ALTER COLUMN cust_role_id SET DEFAULT nextval('cust_role_cust_role_id_seq'::regclass);


--
-- Name: cust_menu_role_id; Type: DEFAULT; Schema: {schema}; Owner: postgres
--

ALTER TABLE ONLY cust_menu_role ALTER COLUMN cust_menu_role_id SET DEFAULT nextval('cust_menu_role_cust_menu_role_id_seq'::regclass);



--
-- Name: cust_user_pkey; Type: CONSTRAINT; Schema: {schema}; Owner: postgres
--

ALTER TABLE ONLY cust_user
    ADD CONSTRAINT cust_user_pkey PRIMARY KEY (sys_user_id);


--
-- Name: cust_user_role_cust_user_role_id_key; Type: CONSTRAINT; Schema: {schema}; Owner: postgres
--

ALTER TABLE ONLY cust_user_role
    ADD CONSTRAINT cust_user_role_cust_user_role_id_key UNIQUE (cust_user_role_id);


--
-- Name: cust_user_role_pkey; Type: CONSTRAINT; Schema: {schema}; Owner: postgres
--

ALTER TABLE ONLY cust_user_role
    ADD CONSTRAINT cust_user_role_pkey PRIMARY KEY (sys_user_id, cust_role_name);


--
-- Name: cust_role_cust_role_desc_key; Type: CONSTRAINT; Schema: {schema}; Owner: postgres
--

ALTER TABLE ONLY cust_role
    ADD CONSTRAINT cust_role_cust_role_desc_key UNIQUE (cust_role_desc);


--
-- Name: cust_role_cust_role_id_key; Type: CONSTRAINT; Schema: {schema}; Owner: postgres
--

ALTER TABLE ONLY cust_role
    ADD CONSTRAINT cust_role_cust_role_id_key UNIQUE (cust_role_id);


--
-- Name: cust_role_pkey; Type: CONSTRAINT; Schema: {schema}; Owner: postgres
--

ALTER TABLE ONLY cust_role
    ADD CONSTRAINT cust_role_pkey PRIMARY KEY (cust_role_name);


--
-- Name: cust_menu_role_cust_menu_role_id_key; Type: CONSTRAINT; Schema: {schema}; Owner: postgres
--

ALTER TABLE ONLY cust_menu_role
    ADD CONSTRAINT cust_menu_role_cust_menu_role_id_key UNIQUE (cust_menu_role_id);


--
-- Name: cust_menu_role_pkey; Type: CONSTRAINT; Schema: {schema}; Owner: postgres
--

ALTER TABLE ONLY cust_menu_role
    ADD CONSTRAINT cust_menu_role_pkey PRIMARY KEY (cust_role_name, menu_id);



--
-- Name: cust_user_sys_user_email_unique; Type: INDEX; Schema: {schema}; Owner: postgres
--

CREATE UNIQUE INDEX cust_user_sys_user_email_unique ON cust_user USING btree (lower((sys_user_email)::text)) WHERE ((sys_user_sts)::text = 'ACTIVE'::text);


--
-- Name: fki_cust_user_cust_id_cust_Fkey; Type: INDEX; Schema: {schema}; Owner: postgres
--

CREATE INDEX "fki_cust_user_cust_id_cust_Fkey" ON cust_user USING btree (cust_id);



--
-- Name: cust_user_iud; Type: TRIGGER; Schema: {schema}; Owner: postgres
--

CREATE TRIGGER cust_user_iud BEFORE INSERT OR DELETE OR UPDATE ON cust_user FOR EACH ROW EXECUTE PROCEDURE cust_user_iud();


--
-- Name: cust_user_iud_after_insert; Type: TRIGGER; Schema: {schema}; Owner: postgres
--

CREATE TRIGGER cust_user_iud_after_insert AFTER INSERT ON cust_user FOR EACH ROW EXECUTE PROCEDURE cust_user_iud_after_insert();


--
-- Name: cust_user_role_iud; Type: TRIGGER; Schema: {schema}; Owner: postgres
--

CREATE TRIGGER cust_user_role_iud BEFORE INSERT OR DELETE OR UPDATE ON cust_user_role FOR EACH ROW EXECUTE PROCEDURE cust_user_role_iud();


--
-- Name: v_cust_menu_role_selection_iud_insteadof_update; Type: TRIGGER; Schema: {schema}; Owner: postgres
--

CREATE TRIGGER v_cust_menu_role_selection_iud_insteadof_update INSTEAD OF UPDATE ON v_cust_menu_role_selection FOR EACH ROW EXECUTE PROCEDURE v_cust_menu_role_selection_iud_insteadof_update();



--
-- Name: cust_user_sys_user_sts_code_ahc_fkey; Type: FK CONSTRAINT; Schema: {schema}; Owner: postgres
--

ALTER TABLE ONLY cust_user
    ADD CONSTRAINT cust_user_sys_user_sts_code_ahc_fkey FOREIGN KEY (sys_user_sts) REFERENCES code_ahc(code_val);


--
-- Name: cust_user_role_cust_role_name_fkey; Type: FK CONSTRAINT; Schema: {schema}; Owner: postgres
--

ALTER TABLE ONLY cust_user_role
    ADD CONSTRAINT cust_user_role_cust_role_name_fkey FOREIGN KEY (cust_role_name) REFERENCES cust_role(cust_role_name);


--
-- Name: cust_user_role_sys_user_id_fkey; Type: FK CONSTRAINT; Schema: {schema}; Owner: postgres
--

ALTER TABLE ONLY cust_user_role
    ADD CONSTRAINT cust_user_role_sys_user_id_fkey FOREIGN KEY (sys_user_id) REFERENCES cust_user(sys_user_id) ON DELETE CASCADE;


--
-- Name: cust_role_cust_role_sts_code_ahc_fkey; Type: FK CONSTRAINT; Schema: {schema}; Owner: postgres
--

ALTER TABLE ONLY cust_role
    ADD CONSTRAINT cust_role_cust_role_sts_code_ahc_fkey FOREIGN KEY (cust_role_sts) REFERENCES code_ahc(code_val);


--
-- Name: cust_menu_role_cust_role_name_fkey; Type: FK CONSTRAINT; Schema: {schema}; Owner: postgres
--

ALTER TABLE ONLY cust_menu_role
    ADD CONSTRAINT cust_menu_role_cust_role_name_fkey FOREIGN KEY (cust_role_name) REFERENCES cust_role(cust_role_name) ON DELETE CASCADE;


--
-- Name: cust_menu_role_menu_id_fkey; Type: FK CONSTRAINT; Schema: {schema}; Owner: postgres
--

ALTER TABLE ONLY cust_menu_role
    ADD CONSTRAINT cust_menu_role_menu_id_fkey FOREIGN KEY (menu_id) REFERENCES menu__tbl(menu_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cust_user_iud(); Type: ACL; Schema: {schema}; Owner: postgres
--

REVOKE ALL ON FUNCTION cust_user_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION cust_user_iud() FROM postgres;
GRANT ALL ON FUNCTION cust_user_iud() TO postgres;
GRANT ALL ON FUNCTION cust_user_iud() TO PUBLIC;
GRANT ALL ON FUNCTION cust_user_iud() TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION cust_user_iud() TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: cust_user_iud_after_insert(); Type: ACL; Schema: {schema}; Owner: postgres
--

REVOKE ALL ON FUNCTION cust_user_iud_after_insert() FROM PUBLIC;
REVOKE ALL ON FUNCTION cust_user_iud_after_insert() FROM postgres;
GRANT ALL ON FUNCTION cust_user_iud_after_insert() TO postgres;
GRANT ALL ON FUNCTION cust_user_iud_after_insert() TO PUBLIC;
GRANT ALL ON FUNCTION cust_user_iud_after_insert() TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION cust_user_iud_after_insert() TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: cust_user_role_iud(); Type: ACL; Schema: {schema}; Owner: postgres
--

REVOKE ALL ON FUNCTION cust_user_role_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION cust_user_role_iud() FROM postgres;
GRANT ALL ON FUNCTION cust_user_role_iud() TO postgres;
GRANT ALL ON FUNCTION cust_user_role_iud() TO PUBLIC;
GRANT ALL ON FUNCTION cust_user_role_iud() TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION cust_user_role_iud() TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: v_cust_menu_role_selection_iud_insteadof_update(); Type: ACL; Schema: {schema}; Owner: postgres
--

REVOKE ALL ON FUNCTION v_cust_menu_role_selection_iud_insteadof_update() FROM PUBLIC;
REVOKE ALL ON FUNCTION v_cust_menu_role_selection_iud_insteadof_update() FROM postgres;
GRANT ALL ON FUNCTION v_cust_menu_role_selection_iud_insteadof_update() TO postgres;
GRANT ALL ON FUNCTION v_cust_menu_role_selection_iud_insteadof_update() TO PUBLIC;
GRANT ALL ON FUNCTION v_cust_menu_role_selection_iud_insteadof_update() TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION v_cust_menu_role_selection_iud_insteadof_update() TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


--
-- Name: cust_user; Type: ACL; Schema: {schema}; Owner: postgres
--

REVOKE ALL ON TABLE cust_user FROM PUBLIC;
REVOKE ALL ON TABLE cust_user FROM postgres;
GRANT ALL ON TABLE cust_user TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cust_user TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: cust_user_sys_user_id_seq; Type: ACL; Schema: {schema}; Owner: postgres
--

REVOKE ALL ON SEQUENCE cust_user_sys_user_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE cust_user_sys_user_id_seq FROM postgres;
GRANT ALL ON SEQUENCE cust_user_sys_user_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE cust_user_sys_user_id_seq TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: cust_user_role; Type: ACL; Schema: {schema}; Owner: postgres
--

REVOKE ALL ON TABLE cust_user_role FROM PUBLIC;
REVOKE ALL ON TABLE cust_user_role FROM postgres;
GRANT ALL ON TABLE cust_user_role TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cust_user_role TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: cust_user_role_cust_user_role_id_seq; Type: ACL; Schema: {schema}; Owner: postgres
--

REVOKE ALL ON SEQUENCE cust_user_role_cust_user_role_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE cust_user_role_cust_user_role_id_seq FROM postgres;
GRANT ALL ON SEQUENCE cust_user_role_cust_user_role_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE cust_user_role_cust_user_role_id_seq TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: cust_role; Type: ACL; Schema: {schema}; Owner: postgres
--

REVOKE ALL ON TABLE cust_role FROM PUBLIC;
REVOKE ALL ON TABLE cust_role FROM postgres;
GRANT ALL ON TABLE cust_role TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cust_role TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: cust_role_cust_role_id_seq; Type: ACL; Schema: {schema}; Owner: postgres
--

REVOKE ALL ON SEQUENCE cust_role_cust_role_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE cust_role_cust_role_id_seq FROM postgres;
GRANT ALL ON SEQUENCE cust_role_cust_role_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE cust_role_cust_role_id_seq TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: cust_menu_role; Type: ACL; Schema: {schema}; Owner: postgres
--

REVOKE ALL ON TABLE cust_menu_role FROM PUBLIC;
REVOKE ALL ON TABLE cust_menu_role FROM postgres;
GRANT ALL ON TABLE cust_menu_role TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cust_menu_role TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: cust_menu_role_cust_menu_role_id_seq; Type: ACL; Schema: {schema}; Owner: postgres
--

REVOKE ALL ON SEQUENCE cust_menu_role_cust_menu_role_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE cust_menu_role_cust_menu_role_id_seq FROM postgres;
GRANT ALL ON SEQUENCE cust_menu_role_cust_menu_role_id_seq TO postgres;
GRANT SELECT,UPDATE ON SEQUENCE cust_menu_role_cust_menu_role_id_seq TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: v_cust_user_nostar; Type: ACL; Schema: {schema}; Owner: postgres
--

REVOKE ALL ON TABLE v_cust_user_nostar FROM PUBLIC;
REVOKE ALL ON TABLE v_cust_user_nostar FROM postgres;
GRANT ALL ON TABLE v_cust_user_nostar TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_cust_user_nostar TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


--
-- Name: v_cust_menu_role_selection; Type: ACL; Schema: {schema}; Owner: postgres
--

REVOKE ALL ON TABLE v_cust_menu_role_selection FROM PUBLIC;
REVOKE ALL ON TABLE v_cust_menu_role_selection FROM postgres;
GRANT ALL ON TABLE v_cust_menu_role_selection TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE v_cust_menu_role_selection TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;


