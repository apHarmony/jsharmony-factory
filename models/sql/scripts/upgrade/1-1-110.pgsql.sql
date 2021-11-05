jsharmony.version_increment('jsHarmonyFactory',1,1,110,0);

alter FUNCTION sys_user_iud() RETURNS trigger
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
            INSERT INTO {schema}.sys_user_role (sys_user_id, sys_role_name) VALUES(NEW.sys_user_id, '*');
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