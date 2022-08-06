SET search_path = {schema}, pg_catalog;

drop trigger if exists version__tbl_iud on version__tbl;
drop function if exists version__tbl_iud();

CREATE FUNCTION version__tbl_iud() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
      curdttm    timestamp default {schema}.my_now();
      myuser     text default {schema}.my_db_user();
      audit_seq    bigint default NULL;
      my_id      bigint default case TG_OP when 'DELETE' then OLD.version_id else NEW.version_id end;
      my_toa     {schema}.toaudit;
    BEGIN

        /**********************************/
        /* INITIALIZE                     */ 
        /**********************************/

        my_toa.op := TG_OP;
        my_toa.audit_table_name := '{schema}_' || lower(TG_TABLE_NAME::text);
        my_toa.cust_id := NULL;
        my_toa.item_id := NULL;
        my_toa.audit_ref_name := NULL;
        my_toa.audit_ref_id := NULL;
        my_toa.audit_subject := NULL;


        /**********************************/
        /* PERFORM CHECKS                 */ 
        /**********************************/
            
        IF TG_OP = 'UPDATE' THEN
          IF {schema}.nequal(NEW.version_id, OLD.version_id) THEN
            RAISE EXCEPTION  'Application Error - ID cannot be updated.';
          END IF;
        END IF;
          

        /**********************************/
        /* AUDIT TRAIL                    */ 
        /**********************************/

        IF TG_OP = 'INSERT' THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.version_id is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.version_id, OLD.version_id) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'version_id',OLD.version_id::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.version_component is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.version_component, OLD.version_component) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'version_component',OLD.version_component::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.version_no_major is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.version_no_major, OLD.version_no_major) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'version_no_major',OLD.version_no_major::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.version_no_minor is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.version_no_minor, OLD.version_no_minor) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'version_no_minor',OLD.version_no_minor::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.version_no_build is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.version_no_build, OLD.version_no_build) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'version_no_build',OLD.version_no_build::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.version_no_rev is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.version_no_rev, OLD.version_no_rev) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'version_no_rev',OLD.version_no_rev::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.version_sts is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.version_sts, OLD.version_sts) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'version_sts',OLD.version_sts::text);  
        END IF;
      
        IF (case when TG_OP = 'DELETE' then OLD.version_note is not null 
                 else TG_OP = 'UPDATE' and {schema}.nequal(NEW.version_note, OLD.version_note) end) THEN
          SELECT par_audit_seq INTO audit_seq FROM {schema}.audit(my_toa, audit_seq, my_id, 'version_note',OLD.version_note::text);  
        END IF;
 
        /**********************************/
        /* UPDATES AND OTHER TABLES       */ 
        /**********************************/
     
        IF TG_OP = 'INSERT' THEN
	  NEW.version_etstmp := curdttm;
	  NEW.version_euser := myuser;
	  NEW.version_mtstmp := curdttm;
	  NEW.version_muser := myuser;
        ELSIF TG_OP = 'UPDATE' THEN
          IF audit_seq is not NULL THEN
	    NEW.version_mtstmp := curdttm;
	    NEW.version_muser := myuser;
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


ALTER FUNCTION {schema}.version__tbl_iud() OWNER TO postgres;


CREATE TRIGGER version__tbl_iud BEFORE INSERT OR DELETE OR UPDATE ON version__tbl FOR EACH ROW EXECUTE PROCEDURE version__tbl_iud();


REVOKE ALL ON FUNCTION version__tbl_iud() FROM PUBLIC;
REVOKE ALL ON FUNCTION version__tbl_iud() FROM postgres;
GRANT ALL ON FUNCTION version__tbl_iud() TO postgres;
GRANT ALL ON FUNCTION version__tbl_iud() TO PUBLIC;
GRANT ALL ON FUNCTION version__tbl_iud() TO {schema}_%%%INIT_DB_LCASE%%%_role_exec;
GRANT ALL ON FUNCTION version__tbl_iud() TO {schema}_%%%INIT_DB_LCASE%%%_role_dev;


jsharmony.version_increment('jsHarmonyFactory',1,12,0,0);