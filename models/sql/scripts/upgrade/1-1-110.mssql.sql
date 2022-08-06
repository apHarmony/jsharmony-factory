alter trigger [{schema}].[sys_user_iud] on [{schema}].[sys_user]
for insert, update, delete
AS
BEGIN
  set nocount on
  DECLARE @TP char(1)
  DECLARE @CURDTTM DATETIME2(7)
  DECLARE @CURDTTM_CHAR NVARCHAR(MAX)
  DECLARE @MYUSER NVARCHAR(20)
  DECLARE @ERRTXT NVARCHAR(500)
  DECLARE @MY_audit_seq NUMERIC(20,0)
  DECLARE CUR_sys_user_iud CURSOR LOCAL FOR
     SELECT  del.sys_user_id, i.sys_user_id,
             del.sys_user_sts, i.sys_user_sts,
             del.sys_user_fname, i.sys_user_fname,
             del.sys_user_mname, i.sys_user_mname,
             del.sys_user_lname, i.sys_user_lname,
             del.sys_user_jobtitle, i.sys_user_jobtitle,
             del.sys_user_bphone, i.sys_user_bphone,
             del.sys_user_cphone, i.sys_user_cphone,
             del.sys_user_email, i.sys_user_email,
             del.sys_user_pw1, i.sys_user_pw1,
             del.sys_user_pw2, i.sys_user_pw2,
             del.sys_user_lastlogin_tstmp, i.sys_user_lastlogin_tstmp
       FROM deleted del FULL OUTER JOIN inserted i
                       ON i.sys_user_id = del.sys_user_id;
  DECLARE @D_sys_user_id bigint
  DECLARE @I_sys_user_id bigint
  DECLARE @D_sys_user_sts NVARCHAR(MAX)
  DECLARE @I_sys_user_sts NVARCHAR(MAX)
  DECLARE @D_sys_user_fname NVARCHAR(MAX)
  DECLARE @I_sys_user_fname NVARCHAR(MAX)
  DECLARE @D_sys_user_mname NVARCHAR(MAX)
  DECLARE @I_sys_user_mname NVARCHAR(MAX)
  DECLARE @D_sys_user_lname NVARCHAR(MAX) 
  DECLARE @I_sys_user_lname NVARCHAR(MAX)
  DECLARE @D_sys_user_jobtitle NVARCHAR(MAX) 
  DECLARE @I_sys_user_jobtitle NVARCHAR(MAX)
  DECLARE @D_sys_user_bphone NVARCHAR(MAX) 
  DECLARE @I_sys_user_bphone NVARCHAR(MAX)
  DECLARE @D_sys_user_cphone NVARCHAR(MAX) 
  DECLARE @I_sys_user_cphone NVARCHAR(MAX)
  DECLARE @D_sys_user_email NVARCHAR(MAX) 
  DECLARE @I_sys_user_email NVARCHAR(MAX)
  DECLARE @D_sys_user_pw1 NVARCHAR(MAX) 
  DECLARE @I_sys_user_pw1 NVARCHAR(MAX)
  DECLARE @D_sys_user_pw2 NVARCHAR(MAX) 
  DECLARE @I_sys_user_pw2 NVARCHAR(MAX)
  DECLARE @D_sys_user_lastlogin_tstmp datetime2(7) 
  DECLARE @I_sys_user_lastlogin_tstmp datetime2(7)

  DECLARE @NEWPW nvarchar(max)

  DECLARE @MYERROR_NO INT = 0
  DECLARE @MYERROR_MSG NVARCHAR(MAX) = NULL

  DECLARE @xloc nvarchar(MAX)
  DECLARE @xtxt nvarchar(MAX)

  DECLARE @DYNSQL NVARCHAR(MAX)
  DECLARE @C BIGINT
  DECLARE @WK_sys_user_id BIGINT
  DECLARE @WK_audit_subject NVARCHAR(MAX)
  DECLARE @code_val NVARCHAR(MAX)
  DECLARE @UPDATE_PW CHAR(1)

  DECLARE @return_value int,
          @out_msg nvarchar(max),
          @out_rslt nvarchar(255),
          @hash varbinary(200),
          @M nvarchar(max)

  /*
  EXEC [{schema}].[zz-filedebug] 'TRIGGER','sys_user_iud','START', ''
  */

  if exists (select * from inserted)
    if exists (select * from deleted)
      set @TP = 'U'
    else
      set @TP = 'I'
  else
    if exists (select * from deleted)
      set @TP = 'D'
    ELSE
    BEGIN
      RETURN
    END    
  
  SET @CURDTTM = {schema}.my_now_exec()
  SET @CURDTTM_CHAR = CONVERT(NVARCHAR, @CURDTTM, 120)+'.0000000'
  SET @MYUSER = {schema}.my_db_user() 

  IF @TP = 'U' AND UPDATE(sys_user_id)
  BEGIN
    EXEC [{schema}].[zz-filedebug] 'TRIGGER','sys_user_iud','ERR', 'Cannot update ID'
    raiserror('Cannot update identity',16,1)
    ROLLBACK TRANSACTION
    return
  END

  
  OPEN CUR_sys_user_iud
  FETCH NEXT FROM CUR_sys_user_iud
        INTO @D_sys_user_id, @I_sys_user_id,
             @D_sys_user_sts, @I_sys_user_sts,
             @D_sys_user_fname, @I_sys_user_fname,
             @D_sys_user_mname, @I_sys_user_mname,
             @D_sys_user_lname, @I_sys_user_lname,
             @D_sys_user_jobtitle, @I_sys_user_jobtitle,
             @D_sys_user_bphone, @I_sys_user_bphone,
             @D_sys_user_cphone, @I_sys_user_cphone,
             @D_sys_user_email, @I_sys_user_email,
             @D_sys_user_pw1, @I_sys_user_pw1,
             @D_sys_user_pw2, @I_sys_user_pw2,
             @D_sys_user_lastlogin_tstmp, @I_sys_user_lastlogin_tstmp

  WHILE (@@Fetch_Status = 0)
  BEGIN

    IF (@TP = 'D')
    BEGIN
      
      if ({schema}.exists_doc('sys_user_code', @D_sys_user_id) > 0)
      begin
        CLOSE CUR_sys_user_iud
        DEALLOCATE CUR_sys_user_iud
        SET @M = 'Application Error - User cannot be deleted if Documents are present.'
        raiserror(@M ,16,1)
        ROLLBACK TRANSACTION
        return
      end

    END

    SET @M = NULL
    SET @hash = NULL

    SET @NEWPW = NUll;
    SET @UPDATE_PW = 'note__tbl'

    IF (@TP='I' or @TP='U')
    BEGIN
      if ({schema}.nequal_chr(@I_sys_user_pw1, @I_sys_user_pw2) > 0)
        SET @M = 'Application Error - New Password and Repeat Password are different'
      else if ((@TP='I' or isnull(@I_sys_user_pw1,'')>'') and len(ltrim(rtrim(isnull(@I_sys_user_pw1,'')))) < 6)
        SET @M = 'Application Error - Password length - at least 6 characters required'

     IF (@M is not null)
      BEGIN
        CLOSE CUR_sys_user_iud
        DEALLOCATE CUR_sys_user_iud
        raiserror(@M,16,1)
        ROLLBACK TRANSACTION
        return
      END
      ELSE
        SET @NEWPW = ltrim(rtrim(@I_sys_user_pw1))
    END

    /******************************************/
    /****** SPECIAL FRONT ACTION - BEGIN ******/
    /******************************************/

    IF (@TP='I')
    BEGIN

      set @hash = {schema}.my_hash('S', @I_sys_user_id, @NEWPW);

      if (@hash is null)
      BEGIN
        CLOSE CUR_sys_user_iud
        DEALLOCATE CUR_sys_user_iud
        SET @M = 'Application Error - Missing or Incorrect Password'
        raiserror(@M,16,1)
        ROLLBACK TRANSACTION
        return
      END

      UPDATE {schema}.sys_user
         SET sys_user_stsdt = @CURDTTM,
             sys_user_etstmp = @CURDTTM,
             sys_user_euser = @MYUSER,
             sys_user_mtstmp = @CURDTTM,
             sys_user_muser = @MYUSER,
             sys_user_hash = @hash,
             sys_user_pw1 = NULL,
             sys_user_pw2 = NULL
       WHERE sys_user.sys_user_id = @I_sys_user_id;


      INSERT INTO {schema}.sys_user_role (sys_user_id, sys_role_name)
                 VALUES(@I_sys_user_id, '*');

    END  

    SET @WK_audit_subject = ISNULL(@I_sys_user_lname,'')+', '+ISNULL(@I_sys_user_fname,'') 

    /******************************************/
    /****** SPECIAL FRONT ACTION - END   ******/
    /******************************************/

    SET @MY_audit_seq = 0
    IF (@TP='I' OR @TP='D')
    BEGIN
      SET @WK_sys_user_id =  ISNULL(@D_sys_user_id,@I_sys_user_id) 
      EXEC    @MY_audit_seq = {schema}.log_audit_base @TP, 'sys_user', @WK_sys_user_id, @MYUSER, @CURDTTM,default,default,@WK_audit_subject
    END
 
    IF @TP='U' OR @TP='D'
    BEGIN

      IF (@TP = 'D' AND @D_sys_user_sts IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_sys_user_sts, @I_sys_user_sts) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base 'U', 'sys_user', @I_sys_user_id, @MYUSER, @CURDTTM,default,default,@WK_audit_subject
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('sys_user_sts'), @D_sys_user_sts)
      END

      IF (@TP = 'D' AND @D_sys_user_fname IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_sys_user_fname, @I_sys_user_fname) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base 'U', 'sys_user', @I_sys_user_id, @MYUSER, @CURDTTM,default,default,@WK_audit_subject
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('sys_user_fname'), @D_sys_user_fname)
      END

      IF (@TP = 'D' AND @D_sys_user_mname IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_sys_user_mname, @I_sys_user_mname) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base 'U', 'sys_user', @I_sys_user_id, @MYUSER, @CURDTTM,default,default,@WK_audit_subject
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('sys_user_mname'), @D_sys_user_mname)
      END

      IF (@TP = 'D' AND @D_sys_user_lname IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_sys_user_lname, @I_sys_user_lname) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base 'U', 'sys_user', @I_sys_user_id, @MYUSER, @CURDTTM,default,default,@WK_audit_subject
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('sys_user_lname'), @D_sys_user_lname)
      END

      IF (@TP = 'D' AND @D_sys_user_jobtitle IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_sys_user_jobtitle, @I_sys_user_jobtitle) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base 'U', 'sys_user', @I_sys_user_id, @MYUSER, @CURDTTM,default,default,@WK_audit_subject
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('sys_user_jobtitle'), @D_sys_user_jobtitle)
      END

      IF (@TP = 'D' AND @D_sys_user_bphone IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_sys_user_bphone, @I_sys_user_bphone) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base 'U', 'sys_user', @I_sys_user_id, @MYUSER, @CURDTTM,default,default,@WK_audit_subject
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('sys_user_bphone'), @D_sys_user_bphone)
      END

      IF (@TP = 'D' AND @D_sys_user_cphone IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_sys_user_cphone, @I_sys_user_cphone) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base 'U', 'sys_user', @I_sys_user_id, @MYUSER, @CURDTTM,default,default,@WK_audit_subject
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('sys_user_cphone'), @D_sys_user_cphone)
      END

      IF (@TP = 'D' AND @D_sys_user_email IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_sys_user_email, @I_sys_user_email) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base 'U', 'sys_user', @I_sys_user_id, @MYUSER, @CURDTTM,default,default,@WK_audit_subject
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('sys_user_email'), @D_sys_user_email)
      END

      IF (@TP = 'D' AND @D_sys_user_lastlogin_tstmp IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_date(@D_sys_user_lastlogin_tstmp, @I_sys_user_lastlogin_tstmp) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base 'U', 'sys_user', @I_sys_user_id, @MYUSER, @CURDTTM,default,default,@WK_audit_subject
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('sys_user_lastlogin_tstmp'), @D_sys_user_lastlogin_tstmp)
      END

      IF (@TP = 'U' AND isnull(@NEWPW,'') <> '')
      BEGIN
        set @hash = {schema}.my_hash('S', @I_sys_user_id, @NEWPW);

        if (@hash is null)
        BEGIN
            CLOSE CUR_sys_user_iud
            DEALLOCATE CUR_sys_user_iud
            SET @M = 'Application Error - Incorrect Password'
            raiserror(@M,16,1)
            ROLLBACK TRANSACTION
            return
        END

        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base 'U', 'sys_user', @I_sys_user_id, @MYUSER, @CURDTTM,default,default,@WK_audit_subject
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('sys_user_PW'), '*')

        SET @UPDATE_PW = 'Y'
      END


    END  /* END OF "IF @TP='U' OR @TP='D'"  */


    /******************************************/
    /****** SPECIAL BACK ACTION - BEGIN  ******/
    /******************************************/

    IF (@TP='U' AND @MY_audit_seq <> 0)
    BEGIN
      UPDATE {schema}.sys_user
         SET sys_user_stsdt = CASE WHEN {schema}.nequal_chr(@D_sys_user_sts, @I_sys_user_sts) > 0 THEN @CURDTTM ELSE sys_user_stsdt END,
             sys_user_mtstmp = @CURDTTM,
             sys_user_muser = @MYUSER,
             sys_user_hash = case @UPDATE_PW when 'Y' then @hash else sys_user_hash end,
             sys_user_pw1 = NULL,
             sys_user_pw2 = NULL
       WHERE sys_user.sys_user_id = @I_sys_user_id;
    END  
    ELSE IF (@TP='U' AND (@I_sys_user_pw1 is not null or @I_sys_user_pw2 is not null))
    BEGIN
      UPDATE {schema}.sys_user
         SET sys_user_pw1 = NULL,
             sys_user_pw2 = NULL
       WHERE sys_user.sys_user_id = @I_sys_user_id;
    END  

    /*****************************************/
    /****** SPECIAL BACK ACTION - END   ******/
    /*****************************************/



            
    FETCH NEXT FROM CUR_sys_user_iud
        INTO @D_sys_user_id, @I_sys_user_id,
             @D_sys_user_sts, @I_sys_user_sts,
             @D_sys_user_fname, @I_sys_user_fname,
             @D_sys_user_mname, @I_sys_user_mname,
             @D_sys_user_lname, @I_sys_user_lname,
             @D_sys_user_jobtitle, @I_sys_user_jobtitle,
             @D_sys_user_bphone, @I_sys_user_bphone,
             @D_sys_user_cphone, @I_sys_user_cphone,
             @D_sys_user_email, @I_sys_user_email,
             @D_sys_user_pw1, @I_sys_user_pw1,
             @D_sys_user_pw2, @I_sys_user_pw2,
             @D_sys_user_lastlogin_tstmp, @I_sys_user_lastlogin_tstmp

  END
  CLOSE CUR_sys_user_iud
  DEALLOCATE CUR_sys_user_iud

  /*
  EXEC [{schema}].[zz-filedebug] 'TRIGGER','sys_user_iud','RETURN', ''
  */

  RETURN

END
go

jsharmony.version_increment('jsHarmonyFactory',1,1,110,0);
go
