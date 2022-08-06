IF EXISTS (SELECT * FROM sys.objects inner join sys.schemas on objects.schema_id=schemas.schema_id WHERE objects.name = N'version__tbl_iud' and schemas.name='{schema}' AND objects.type = 'TR')
BEGIN
      DROP TRIGGER [{schema}].[version__tbl_iud];
END;
go

CREATE trigger [{schema}].[version__tbl_iud] on [{schema}].[version__tbl]
for insert, update, delete
AS
BEGIN
  set nocount on
  DECLARE @TP char(1)
  DECLARE @CURDTTM DATETIME2(7)
  DECLARE @CURDT DATE
  DECLARE @CURDTTM_CHAR NVARCHAR(MAX)
  DECLARE @MYUSER NVARCHAR(20)
  DECLARE @ERRTXT NVARCHAR(500)
  DECLARE @MY_audit_seq NUMERIC(20,0)
  DECLARE CUR_version_iud CURSOR LOCAL FOR
     SELECT  del.version_id, i.version_id,
             del.version_component, i.version_component,
             del.version_no_major, i.version_no_major,
             del.version_no_minor, i.version_no_minor,
             del.version_no_build, i.version_no_build,
             del.version_no_rev, i.version_no_rev,
             del.version_sts, i.version_sts,
             del.version_note, i.version_note
       FROM deleted del FULL OUTER JOIN inserted i
                       ON i.version_id = del.version_id;
  DECLARE @D_version_id bigint
  DECLARE @I_version_id bigint
  DECLARE @D_version_component NVARCHAR(50)
  DECLARE @I_version_component NVARCHAR(50)
  DECLARE @D_version_no_major int
  DECLARE @I_version_no_major int
  DECLARE @D_version_no_minor int
  DECLARE @I_version_no_minor int
  DECLARE @D_version_no_build int
  DECLARE @I_version_no_build int
  DECLARE @D_version_no_rev int
  DECLARE @I_version_no_rev int
  DECLARE @D_version_sts NVARCHAR(32) 
  DECLARE @I_version_sts NVARCHAR(32)
  DECLARE @D_version_note NVARCHAR(MAX) 
  DECLARE @I_version_note NVARCHAR(MAX)

  DECLARE @MYERROR_NO INT = 0
  DECLARE @MYERROR_MSG NVARCHAR(MAX) = NULL

  DECLARE @xloc nvarchar(MAX)
  DECLARE @xtxt nvarchar(MAX)

  DECLARE @DYNSQL NVARCHAR(MAX)
  DECLARE @C BIGINT
  DECLARE @code_val NVARCHAR(MAX)
  DECLARE @WK_version_id bigint
  DECLARE @M NVARCHAR(MAX)

  DECLARE @return_value int,
          @out_msg nvarchar(max),
          @out_rslt nvarchar(255)

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
  SET @CURDT = {schema}.my_to_date(@CURDTTM)
  SET @CURDTTM_CHAR = CONVERT(NVARCHAR, @CURDTTM, 120)+'.0000000'
  SET @MYUSER = {schema}.my_db_user() 

  IF @TP = 'U' AND UPDATE(version_id)
  BEGIN
    EXEC [{schema}].[zz-filedebug] 'TRIGGER','version__tbl_iud','ERR', 'Cannot update ID'
    raiserror('Cannot update identity',16,1)
    ROLLBACK TRANSACTION
    return
  END

  
  OPEN CUR_version_iud
  FETCH NEXT FROM CUR_version_iud
        INTO @D_version_id, @I_version_id,
             @D_version_component, @I_version_component,
             @D_version_no_major, @I_version_no_major,
             @D_version_no_minor, @I_version_no_minor,
             @D_version_no_build, @I_version_no_build,
             @D_version_no_rev, @I_version_no_rev,
             @D_version_sts, @I_version_sts,
             @D_version_note, @I_version_note

  WHILE (@@Fetch_Status = 0)
  BEGIN

    /******************************************/
    /****** SPECIAL FRONT ACTION - BEGIN ******/
    /******************************************/

    IF (@TP='I')
    BEGIN
      UPDATE {schema}.version__tbl
         SET version_etstmp = @CURDTTM,
             version_euser = @MYUSER,
             version_mtstmp = @CURDTTM,
             version_muser = @MYUSER
       WHERE version__tbl.version_id = @I_version_id;
    END  

    /******************************************/
    /****** SPECIAL FRONT ACTION - END   ******/
    /******************************************/


    SET @MY_audit_seq = 0
    IF (@TP='I' OR @TP='D')
    BEGIN  
      SET @WK_version_id = ISNULL(@D_version_id,@I_version_id)
      EXEC    @MY_audit_seq = {schema}.log_audit_base @TP, '{schema}_version__tbl', @WK_version_id, @MYUSER, @CURDTTM
    END

 
    IF @TP='U' OR @TP='D'
    BEGIN

      IF (@TP = 'D' AND @D_version_component IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_version_component, @I_version_component) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base 'U', '{schema}_version__tbl', @I_version_id, @MYUSER, @CURDTTM
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('version_component'), @D_version_component)
      END

      IF (@TP = 'D' AND @D_version_no_major IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_num(@D_version_no_major, @I_version_no_major) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base 'U', '{schema}_version__tbl', @I_version_id, @MYUSER, @CURDTTM
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('version_no_major'), @D_version_no_major)
      END
      
      IF (@TP = 'D' AND @D_version_no_minor IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_num(@D_version_no_minor, @I_version_no_minor) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base 'U', '{schema}_version__tbl', @I_version_id, @MYUSER, @CURDTTM
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('version_no_minor'), @D_version_no_minor)
      END

      IF (@TP = 'D' AND @D_version_no_build IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_num(@D_version_no_build, @I_version_no_build) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base 'U', '{schema}_version__tbl', @I_version_id, @MYUSER, @CURDTTM
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('version_no_build'), @D_version_no_build)
      END

      IF (@TP = 'D' AND @D_version_no_rev IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_num(@D_version_no_rev, @I_version_no_rev) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base 'U', '{schema}_version__tbl', @I_version_id, @MYUSER, @CURDTTM
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('version_no_rev'), @D_version_no_rev)
      END

      IF (@TP = 'D' AND @D_version_sts IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_version_sts, @I_version_sts) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base 'U', '{schema}_version__tbl', @I_version_id, @MYUSER, @CURDTTM
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('version_sts'), @D_version_sts)
      END

      IF (@TP = 'D' AND @D_version_note IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_version_note, @I_version_note) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base 'U', '{schema}_version__tbl', @I_version_id, @MYUSER, @CURDTTM
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('version_note'), @D_version_note)
      END


    END  /* END OF "IF @TP='U' OR @TP='D'"  */


    /******************************************/
    /****** SPECIAL BACK ACTION - BEGIN  ******/
    /******************************************/

    IF (@TP='U' AND @MY_audit_seq <> 0)
    BEGIN
      UPDATE {schema}.version__tbl
         SET version_mtstmp = @CURDTTM,
             version_muser = @MYUSER
       WHERE version__tbl.version_id = @I_version_id;
    END  

    /*****************************************/
    /****** SPECIAL BACK ACTION - END   ******/
    /*****************************************/



            
    FETCH NEXT FROM CUR_version_iud
        INTO @D_version_id, @I_version_id,
             @D_version_component,  @I_version_component,
             @D_version_no_major, @I_version_no_major,
             @D_version_no_minor, @I_version_no_minor,
             @D_version_no_build, @I_version_no_build,
             @D_version_no_rev, @I_version_no_rev,
             @D_version_sts, @I_version_sts,
             @D_version_note, @I_version_note

  END
  CLOSE CUR_version_iud
  DEALLOCATE CUR_version_iud

  RETURN

  ERROR_BAD:  

  CLOSE CUR_PL_iud
  DEALLOCATE CUR_PL_iud
  raiserror(@M ,16,1)
  ROLLBACK TRANSACTION
  return

END

GO
ALTER TABLE [{schema}].[version__tbl] ENABLE TRIGGER [version__tbl_iud]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

jsharmony.version_increment('jsHarmonyFactory',1,12,0,0);
go
