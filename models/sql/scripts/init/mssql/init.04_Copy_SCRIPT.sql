SET NUMERIC_ROUNDABORT OFF
GO
SET XACT_ABORT, ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
BEGIN TRANSACTION
EXEC(N'INSERT INTO [jsharmony].[script__tbl] ([script_name], [script_txt]) VALUES (N''create_code_app'', N''CREATE TABLE [%%%schema%%%].[code_app_%%%name%%%](
	[code_app_id] [bigint] IDENTITY(1,1) NOT NULL,
	[code_seq] [smallint] NULL,
	[code_val] [nvarchar](32) NOT NULL,
	[code_txt] [nvarchar](50) NULL,
	[code_code] [nvarchar](50) NULL,
	[code_end_dt] [date] NULL,
	[code_end_reason] [nvarchar](50) NULL,
	[code_etstmp] [datetime2](7) NULL,
	[code_euser] [nvarchar](20) NULL,
	[code_mtstmp] [datetime2](7) NULL,
	[code_muser] [nvarchar](20) NULL,
	[code_snotes] [nvarchar](255) NULL,
	[code_notes] [nvarchar](255) NULL,
	[code_euser_fmt]  AS ([jsharmony].[my_db_user_fmt]([code_euser])),
	[code_muser_fmt]  AS ([jsharmony].[my_db_user_fmt]([code_muser])),
	[code_attrib] [nvarchar](50) NULL,
 CONSTRAINT [pk_code_app_%%%name%%%] PRIMARY KEY CLUSTERED 
(
	[code_app_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_code_app_%%%name%%%_code_txt] UNIQUE NONCLUSTERED 
(
	[code_txt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_code_app_%%%name%%%_code_val] UNIQUE NONCLUSTERED 
(
	[code_val] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

;

ALTER TABLE [%%%schema%%%].[code_app_%%%name%%%] ADD  CONSTRAINT [DF_code_app_%%%name%%%_COD_EDt]  DEFAULT ([jsharmony].[my_now]()) FOR [code_etstmp]
;

ALTER TABLE [%%%schema%%%].[code_app_%%%name%%%] ADD  CONSTRAINT [DF_code_app_%%%name%%%_COD_EUser]  DEFAULT ([jsharmony].[my_db_user]()) FOR [code_euser]
;

ALTER TABLE [%%%schema%%%].[code_app_%%%name%%%] ADD  CONSTRAINT [DF_code_app_%%%name%%%_COD_MDt]  DEFAULT ([jsharmony].[my_now]()) FOR [code_mtstmp]
;

ALTER TABLE [%%%schema%%%].[code_app_%%%name%%%] ADD  CONSTRAINT [DF_code_app_%%%name%%%_COD_MUser]  DEFAULT ([jsharmony].[my_db_user]()) FOR [code_muser]
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value ID'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''code_app_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''code_app_id''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Sequence'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''code_app_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''code_seq''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''code_app_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''code_val''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Description'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''code_app_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''code_txt''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Additional Code'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''code_app_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''code_code''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Termination Date'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''code_app_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''code_end_dt''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Termination Comment'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''code_app_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''code_end_reason''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Entry Timestamp'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''code_app_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''code_etstmp''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Entry User'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema'')')
UPDATE [jsharmony].[script__tbl] SET [script_txt].WRITE(N'%%%'', @level1type=N''TABLE'',@level1name=N''code_app_%%%name%%%'', @level2type=N''COLUMN'',@level2name=N''code_euser''
;

EXEC sys.sp_addextendedproperty @name=N''MS_Description'', @value=N''Code Value Last Modification Timestamp'' , @level0type=N''SCHEMA'',@level0name=N''%%%schema%%%'', @level1type=N''TABLE'',@level1name=N''code_app_%%%name%%%'', @level2type=N''COLUMN'',@level2name=N''code_mtstmp''
;

EXEC sys.sp_addextendedproperty @name=N''MS_Description'', @value=N''Code Value Last Modification User'' , @level0type=N''SCHEMA'',@level0name=N''%%%schema%%%'', @level1type=N''TABLE'',@level1name=N''code_app_%%%name%%%'', @level2type=N''COLUMN'',@level2name=N''code_muser''
;

EXEC sys.sp_addextendedproperty @name=N''MS_Description'', @value=N''Code System Notes'' , @level0type=N''SCHEMA'',@level0name=N''%%%schema%%%'', @level1type=N''TABLE'',@level1name=N''code_app_%%%name%%%'', @level2type=N''COLUMN'',@level2name=N''code_snotes''
;

EXEC sys.sp_addextendedproperty @name=N''MS_Description'', @value=N''User Codes - %%%mean%%%'' , @level0type=N''SCHEMA'',@level0name=N''%%%schema%%%'', @level1type=N''TABLE'',@level1name=N''code_app_%%%name%%%''
;


',NULL,NULL) WHERE [script_name]=N'create_code_app'
EXEC(N'INSERT INTO [jsharmony].[script__tbl] ([script_name], [script_txt]) VALUES (N''create_code_app_TRIGGER'', N''CREATE trigger [%%%schema%%%].[code_app_%%%name%%%_IUD] on [%%%schema%%%].[code_app_%%%name%%%]
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
  DECLARE CUR_code_app_%%%name%%%_IUD CURSOR LOCAL FOR
     SELECT  del.code_app_id, i.code_app_id,
	         del.code_seq, i.code_seq,
	         del.code_end_dt, i.code_end_dt,
	         del.code_val, i.code_val,
	         del.code_txt, i.code_txt,
	         del.code_code, i.code_code,
	         del.code_attrib, i.code_attrib,
	         del.code_end_reason, i.code_end_reason
       FROM deleted del FULL OUTER JOIN inserted i
                       ON i.code_app_id = del.code_app_id;
  DECLARE @D_code_app_id bigint
  DECLARE @I_code_app_id bigint
  DECLARE @D_code_seq bigint
  DECLARE @I_code_seq bigint
  DECLARE @D_code_end_dt DATETIME2(7)
  DECLARE @I_code_end_dt DATETIME2(7)
  DECLARE @D_code_val NVARCHAR(MAX)
  DECLARE @I_code_val NVARCHAR(MAX)
  DECLARE @D_code_txt NVARCHAR(MAX)
  DECLARE @I_code_txt NVARCHAR(MAX)
  DECLARE @D_code_code NVARCHAR(MAX)
  DECLARE @I_code_code NVARCHAR(MAX)
  DECLARE @D_code_attrib NVARCHAR(MAX)
  DECLARE @I_code_attrib NVARCHAR(MAX)
  DECLARE @D_code_end_reason NVARCHAR(MAX)
  DECLARE @I_code_end_reason NVARCHAR(MAX)

  DECLARE @MYERROR_NO INT = 0
  DECLARE @MYERROR_MSG NVARCHAR(MAX) = NULL

  DECLARE @xloc nvarchar(MAX)
  DECLARE @xtxt nvarchar(MAX)

  DECLARE @DYNSQL NVARCHAR(MAX)
  DECLARE @C BIGINT
  DECLARE @code_val NVARCHAR(MAX)
  DECLARE @WK_code_app_id bigint
  DECLARE @M NVARCHAR(MAX)
  DECLARE @cust_user_USER BIT

  DECLARE @return_value int,
		  @out_msg nvarchar(max),
		  @out_rslt nvarchar(255)


  if exists (select * from inserted)
    if exists (select * from deleted)
      set @TP = ''''U''''
    else
      set @TP = ''''I''''
  else
    if exists (select * from deleted)
	  set @TP = ''''D''''
    ELSE
    BEGIN
      RETURN
    END    
  
  SET @CURDTTM = {schema}.my_now_exec()
  SET @CURDT = {schema}.my_to_date(@CURDTTM)
  SET @CURDTTM_CHAR = CONVERT(NVARCHAR, @CURDTTM, 120)+''''.0000000''''
  SET @MYUSER = {schema}.my_db_user() 

  IF @TP = ''''U'''' AND UPDATE(code_app_id)
  BEGIN
    EXEC [jsharmony].[zz-filedebug] ''''TRIGGER'''',''''code_app_%%%name%%%_IUD'''',''''ERR'''', ''''Cannot update ID''''
    raiserror(''''Cannot update identity'''',16,1)
    ROLLBACK TRANSACTION
    return
  END

  IF @TP = ''''U'''' AND UPDATE(code_val)
  BEGIN
    EXEC [jsharmony].[zz-filedebug] ''''TRIGGER'''',''''code_app_%%%name%%%_IUD'''',''''ERR'''', ''''Cannot update code_val''''
    raiserror(''''Cannot update foreign key code_val'''',16,1)
    ROLLBACK TRANSACTION
    return
  END

  
  OPEN CUR_code_app_%%%name%%%_IUD
  FETCH NEXT FROM CUR_code_app_%%%name%%%_IUD
        INTO @D_code_app_id, @I_code_app_id,
             @D_code_seq, @I_code_seq,
             @D_code_end_dt, @I_code_end_dt,
             @D_code_val, @I_code_val,
             @D_code_txt, @I_code_txt,
             @D_code_code, @I_code_code,
             @D_code_attrib, @I_code_attrib,
             @D_code_end_reason, @I_code_end_reason

  WHILE (@@Fetch_Status = 0)
  BEGIN

	/******************************************/
	/****** SPECIAL FRONT ACTION - BEGIN ******/
	/******************************************/

    IF (@TP=''''I'''')
	BEGIN
      UPDATE %%%schema%%%.code_app_%%%name%%%
	     SET code_etstmp = @CURDTTM,
			 code_euser = @MYUSER,
		     code_mtstmp = @CURDTTM,
			 code_muser = @MYUSER
       WHERE code_app_%%%name%%%.code_app_id = @I_code_app_id;
    END  

	/******************************************/
	/****** SPECIAL FRONT ACTION - END   ******/
	/******************************************/


    SET @MY_audit_seq = 0
	IF (@TP=''''I'''' OR @TP=''''D'''')
	BEGIN  
	  SET @WK_code_app_id = ISNULL(@D_code_app_id,@I_code_app_id)
	  EXEC	@MY_audit_seq = {schema}.log_audit_base @TP, ''''code_app_%%%name%%%'''', @WK_code_app_id, @MYUSER, @CURDTTM
	END

 
    IF @TP=''''U'''' OR @TP=''''D''''
	BEGIN

      IF (@TP = ''''D'''' AND @D_code_seq IS NOT NULL OR
          @TP = ''''U'''' AND {schema}.nequal_num(@D_code_seq, @I_'')')
UPDATE [jsharmony].[script__tbl] SET [script_txt].WRITE(N'code_seq) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
		  EXEC	@MY_audit_seq = {schema}.log_audit_base ''U'', ''code_app_%%%name%%%'', @I_code_app_id, @MYUSER, @CURDTTM
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower(''code_seq''), @D_code_seq)
      END

      IF (@TP = ''D'' AND @D_code_end_dt IS NOT NULL OR
          @TP = ''U'' AND {schema}.nequal_date(@D_code_end_dt, @I_code_end_dt) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
		  EXEC	@MY_audit_seq = {schema}.log_audit_base ''U'', ''code_app_%%%name%%%'', @I_code_app_id, @MYUSER, @CURDTTM
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower(''code_end_dt''), @D_code_end_dt)
      END

      IF (@TP = ''D'' AND @D_code_val IS NOT NULL OR
          @TP = ''U'' AND {schema}.nequal_chr(@D_code_val, @I_code_val) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
		  EXEC	@MY_audit_seq = {schema}.log_audit_base ''U'', ''code_app_%%%name%%%'', @I_code_app_id, @MYUSER, @CURDTTM
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower(''code_val''), @D_code_val)
      END

      IF (@TP = ''D'' AND @D_code_txt IS NOT NULL OR
          @TP = ''U'' AND {schema}.nequal_chr(@D_code_txt, @I_code_txt) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
		  EXEC	@MY_audit_seq = {schema}.log_audit_base ''U'', ''code_app_%%%name%%%'', @I_code_app_id, @MYUSER, @CURDTTM
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower(''code_txt''), @D_code_txt)
      END

      IF (@TP = ''D'' AND @D_code_code IS NOT NULL OR
          @TP = ''U'' AND {schema}.nequal_chr(@D_code_code, @I_code_code) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
		  EXEC	@MY_audit_seq = {schema}.log_audit_base ''U'', ''code_app_%%%name%%%'', @I_code_app_id, @MYUSER, @CURDTTM
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower(''code_code''), @D_code_code)
      END

      IF (@TP = ''D'' AND @D_code_attrib IS NOT NULL OR
          @TP = ''U'' AND {schema}.nequal_chr(@D_code_attrib, @I_code_attrib) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
		  EXEC	@MY_audit_seq = {schema}.log_audit_base ''U'', ''code_app_%%%name%%%'', @I_code_app_id, @MYUSER, @CURDTTM
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower(''code_attrib''), @D_code_attrib)
      END

      IF (@TP = ''D'' AND @D_code_end_reason IS NOT NULL OR
          @TP = ''U'' AND {schema}.nequal_chr(@D_code_end_reason, @I_code_end_reason) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
		  EXEC	@MY_audit_seq = {schema}.log_audit_base ''U'', ''code_app_%%%name%%%'', @I_code_app_id, @MYUSER, @CURDTTM
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower(''code_end_reason''), @D_code_end_reason)
      END

    END  /* END OF "IF @TP=''U'' OR @TP=''D''"  */


	/******************************************/
	/****** SPECIAL BACK ACTION - BEGIN  ******/
	/******************************************/

    IF (@TP=''U'' AND @MY_audit_seq <> 0)
	BEGIN
      UPDATE %%%schema%%%.code_app_%%%name%%%
	     SET code_mtstmp = @CURDTTM,
			 code_muser = @MYUSER
       WHERE code_app_%%%name%%%.code_app_id = @I_code_app_id;
    END  

	/*****************************************/
	/****** SPECIAL BACK ACTION - END   ******/
	/*****************************************/



            
    FETCH NEXT FROM CUR_code_app_%%%name%%%_IUD
        INTO @D_code_app_id, @I_code_app_id,
             @D_code_seq,  @I_code_seq,
             @D_code_end_dt, @I_code_end_dt,
             @D_code_val, @I_code_val,
             @D_code_txt, @I_code_txt,
             @D_code_code, @I_code_code,
             @D_code_attrib, @I_code_attrib,
             @D_code_end_reason, @I_code_end_reason


  END
  CLOSE CUR_code_app_%%%name%%%_IUD
  DEALLOCATE CUR_code_app_%%%name%%%_IUD


  RETURN

END



',NULL,NULL) WHERE [script_name]=N'create_code_app_TRIGGER'
EXEC(N'INSERT INTO [jsharmony].[script__tbl] ([script_name], [script_txt]) VALUES (N''create_code2_app'', N''CREATE TABLE [%%%schema%%%].[code2_app_%%%name%%%](
	[code2_app_id] [bigint] IDENTITY(1,1) NOT NULL,
	[code_seq] [smallint] NULL,
	[code_val1] [nvarchar](32) NOT NULL,
	[code_va12] [nvarchar](32) NOT NULL,
	[code_txt] [nvarchar](50) NULL,
	[code_code] [nvarchar](50) NULL,
	[code_attrib] [nvarchar](50) NULL,
	[code_end_dt] [datetime2](7) NULL,
	[code_end_reason] [nvarchar](50) NULL,
	[code_etstmp] [datetime2](7) NULL,
	[code_euser] [nvarchar](20) NULL,
	[code_mtstmp] [datetime2](7) NULL,
	[code_muser] [nvarchar](20) NULL,
	[code_snotes] [nvarchar](255) NULL,
	[code_notes] [nvarchar](255) NULL,
	[code_euser_fmt]  AS ([jsharmony].[my_db_user_fmt]([code_euser])),
	[code_muser_fmt]  AS ([jsharmony].[my_db_user_fmt]([code_muser])),
 CONSTRAINT [pk_code2_app_%%%name%%%] PRIMARY KEY CLUSTERED 
(
	[code2_app_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_code2_app_%%%name%%%_code_val1_code_va12] UNIQUE NONCLUSTERED 
(
	[code_val1] ASC,
	[code_va12] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_code2_app_%%%name%%%_code_val1_code_txt] UNIQUE NONCLUSTERED 
(
	[code_val1] ASC,
	[code_txt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

;

ALTER TABLE [%%%schema%%%].[code2_app_%%%name%%%] ADD  CONSTRAINT [DF_code2_app_%%%name%%%_COD_EDt]  DEFAULT ([jsharmony].[my_now]()) FOR [code_etstmp]
;

ALTER TABLE [%%%schema%%%].[code2_app_%%%name%%%] ADD  CONSTRAINT [DF_code2_app_%%%name%%%_COD_EUser]  DEFAULT ([jsharmony].[my_db_user]()) FOR [code_euser]
;

ALTER TABLE [%%%schema%%%].[code2_app_%%%name%%%] ADD  CONSTRAINT [DF_code2_app_%%%name%%%_COD_MDt]  DEFAULT ([jsharmony].[my_now]()) FOR [code_mtstmp]
;

ALTER TABLE [%%%schema%%%].[code2_app_%%%name%%%] ADD  CONSTRAINT [DF_code2_app_%%%name%%%_COD_MUser]  DEFAULT ([jsharmony].[my_db_user]()) FOR [code_muser]
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value ID'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''code2_app_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''code2_app_id''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Sequence'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''code2_app_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''code_seq''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''code2_app_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''code_val1''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Description'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''code2_app_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''code_txt''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Additional Code'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''code2_app_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''code_code''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Termination Date'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''code2_app_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''code_end_dt''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Termination Comment'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''code2_app_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''code_end_reason''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Entry Timestamp'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''code2_app_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''code_etstmp''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Entry User'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''code2_app_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''code_euser''''
;

EXEC sys.sp_addextendedproper'')')
UPDATE [jsharmony].[script__tbl] SET [script_txt].WRITE(N'ty @name=N''MS_Description'', @value=N''Code Value Last Modification Timestamp'' , @level0type=N''SCHEMA'',@level0name=N''%%%schema%%%'', @level1type=N''TABLE'',@level1name=N''code2_app_%%%name%%%'', @level2type=N''COLUMN'',@level2name=N''code_mtstmp''
;

EXEC sys.sp_addextendedproperty @name=N''MS_Description'', @value=N''Code Value Last Modification User'' , @level0type=N''SCHEMA'',@level0name=N''%%%schema%%%'', @level1type=N''TABLE'',@level1name=N''code2_app_%%%name%%%'', @level2type=N''COLUMN'',@level2name=N''code_muser''
;

EXEC sys.sp_addextendedproperty @name=N''MS_Description'', @value=N''Code System Notes'' , @level0type=N''SCHEMA'',@level0name=N''%%%schema%%%'', @level1type=N''TABLE'',@level1name=N''code2_app_%%%name%%%'', @level2type=N''COLUMN'',@level2name=N''code_snotes''
;

EXEC sys.sp_addextendedproperty @name=N''MS_Description'', @value=N''User Codes 2 - %%%mean%%%'' , @level0type=N''SCHEMA'',@level0name=N''%%%schema%%%'', @level1type=N''TABLE'',@level1name=N''code2_app_%%%name%%%''
;


',NULL,NULL) WHERE [script_name]=N'create_code2_app'
EXEC(N'INSERT INTO [jsharmony].[script__tbl] ([script_name], [script_txt]) VALUES (N''create_code2_app_TRIGGER'', N''CREATE trigger [%%%schema%%%].[code2_app_%%%name%%%_IUD] on [%%%schema%%%].[code2_app_%%%name%%%]
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
  DECLARE CUR_code2_app_%%%name%%%_IUD CURSOR LOCAL FOR
     SELECT  del.code2_app_id, i.code2_app_id,
	         del.code_seq, i.code_seq,
	         del.code_end_dt, i.code_end_dt,
	         del.code_val1, i.code_val1,
	         del.code_va12, i.code_va12,
	         del.code_txt, i.code_txt,
	         del.code_code, i.code_code,
	         del.code_attrib, i.code_attrib,
	         del.code_end_reason, i.code_end_reason
       FROM deleted del FULL OUTER JOIN inserted i
                       ON i.code2_app_id = del.code2_app_id;
  DECLARE @D_code2_app_id bigint
  DECLARE @I_code2_app_id bigint
  DECLARE @D_code_seq bigint
  DECLARE @I_code_seq bigint
  DECLARE @D_code_end_dt DATETIME2(7)
  DECLARE @I_code_end_dt DATETIME2(7)
  DECLARE @D_code_val1 NVARCHAR(MAX)
  DECLARE @I_code_val1 NVARCHAR(MAX)
  DECLARE @D_code_va12 NVARCHAR(MAX)
  DECLARE @I_code_va12 NVARCHAR(MAX)
  DECLARE @D_code_txt NVARCHAR(MAX)
  DECLARE @I_code_txt NVARCHAR(MAX)
  DECLARE @D_code_code NVARCHAR(MAX)
  DECLARE @I_code_code NVARCHAR(MAX)
  DECLARE @D_code_attrib NVARCHAR(MAX)
  DECLARE @I_code_attrib NVARCHAR(MAX)
  DECLARE @D_code_end_reason NVARCHAR(MAX)
  DECLARE @I_code_end_reason NVARCHAR(MAX)

  DECLARE @MYERROR_NO INT = 0
  DECLARE @MYERROR_MSG NVARCHAR(MAX) = NULL

  DECLARE @xloc nvarchar(MAX)
  DECLARE @xtxt nvarchar(MAX)

  DECLARE @DYNSQL NVARCHAR(MAX)
  DECLARE @C BIGINT
  DECLARE @M NVARCHAR(MAX)
  DECLARE @cust_user_USER BIT
  DECLARE @WK_code2_app_id BIGINT

  DECLARE @return_value int,
		  @out_msg nvarchar(max),
		  @out_rslt nvarchar(255)


  if exists (select * from inserted)
    if exists (select * from deleted)
      set @TP = ''''U''''
    else
      set @TP = ''''I''''
  else
    if exists (select * from deleted)
	  set @TP = ''''D''''
    ELSE
    BEGIN
      RETURN
    END    
  
  SET @CURDTTM = {schema}.my_now_exec()
  SET @CURDT = {schema}.my_to_date(@CURDTTM)
  SET @CURDTTM_CHAR = CONVERT(NVARCHAR, @CURDTTM, 120)+''''.0000000''''
  SET @MYUSER = {schema}.my_db_user() 

  IF @TP = ''''U'''' AND UPDATE(code2_app_id)
  BEGIN
    EXEC [jsharmony].[zz-filedebug] ''''TRIGGER'''',''''code2_app_%%%name%%%_IUD'''',''''ERR'''', ''''Cannot update ID''''
    raiserror(''''Cannot update identity'''',16,1)
    ROLLBACK TRANSACTION
    return
  END

  IF @TP = ''''U'''' AND UPDATE(code_val1)
  BEGIN
    EXEC [jsharmony].[zz-filedebug] ''''TRIGGER'''',''''code2_app_%%%name%%%_IUD'''',''''ERR'''', ''''Cannot update code_val1''''
    raiserror(''''Cannot update foreign key code_val1'''',16,1)
    ROLLBACK TRANSACTION
    return
  END

  IF @TP = ''''U'''' AND UPDATE(code_va12)
  BEGIN
    EXEC [jsharmony].[zz-filedebug] ''''TRIGGER'''',''''code2_app_%%%name%%%_IUD'''',''''ERR'''', ''''Cannot update code_va12''''
    raiserror(''''Cannot update foreign key code_va12'''',16,1)
    ROLLBACK TRANSACTION
    return
  END

  
  OPEN CUR_code2_app_%%%name%%%_IUD
  FETCH NEXT FROM CUR_code2_app_%%%name%%%_IUD
        INTO @D_code2_app_id, @I_code2_app_id,
             @D_code_seq, @I_code_seq,
             @D_code_end_dt, @I_code_end_dt,
             @D_code_val1, @I_code_val1,
             @D_code_va12, @I_code_va12,
             @D_code_txt, @I_code_txt,
             @D_code_code, @I_code_code,
             @D_code_attrib, @I_code_attrib,
             @D_code_end_reason, @I_code_end_reason

  WHILE (@@Fetch_Status = 0)
  BEGIN

	/******************************************/
	/****** SPECIAL FRONT ACTION - BEGIN ******/
	/******************************************/

    IF (@TP=''''I'''')
	BEGIN
      UPDATE %%%schema%%%.code2_app_%%%name%%%
	     SET code_etstmp = @CURDTTM,
			 code_euser = @MYUSER,
		     code_mtstmp = @CURDTTM,
			 code_muser = @MYUSER
       WHERE code2_app_%%%name%%%.code2_app_id = @I_code2_app_id;
    END  

	/******************************************/
	/****** SPECIAL FRONT ACTION - END   ******/
	/******************'')')
EXEC(N'DECLARE @pv binary(16)
'+N'UPDATE [jsharmony].[script__tbl] SET [script_txt].WRITE(N''************************/


    SET @MY_audit_seq = 0
	IF (@TP=''''I'''' OR @TP=''''D'''')
	BEGIN  
	  SET @WK_code2_app_id = ISNULL(@D_code2_app_id,@I_code2_app_id)
	  EXEC	@MY_audit_seq = {schema}.log_audit_base @TP, ''''code2_app_%%%name%%%'''', @WK_code2_app_id, @MYUSER, @CURDTTM
	END

 
    IF @TP=''''U'''' OR @TP=''''D''''
	BEGIN

      IF (@TP = ''''D'''' AND @D_code_seq IS NOT NULL OR
          @TP = ''''U'''' AND {schema}.nequal_num(@D_code_seq, @I_code_seq) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
		  EXEC	@MY_audit_seq = {schema}.log_audit_base ''''U'''', ''''code2_app_%%%name%%%'''', @I_code2_app_id, @MYUSER, @CURDTTM
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower(''''code_seq''''), @D_code_seq)
      END

      IF (@TP = ''''D'''' AND @D_code_end_dt IS NOT NULL OR
          @TP = ''''U'''' AND {schema}.nequal_date(@D_code_end_dt, @I_code_end_dt) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
		  EXEC	@MY_audit_seq = {schema}.log_audit_base ''''U'''', ''''code2_app_%%%name%%%'''', @I_code2_app_id, @MYUSER, @CURDTTM
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower(''''code_end_dt''''), @D_code_end_dt)
      END

      IF (@TP = ''''D'''' AND @D_code_val1 IS NOT NULL OR
          @TP = ''''U'''' AND {schema}.nequal_chr(@D_code_val1, @I_code_val1) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
		  EXEC	@MY_audit_seq = {schema}.log_audit_base ''''U'''', ''''code2_app_%%%name%%%'''', @I_code2_app_id, @MYUSER, @CURDTTM
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower(''''code_val1''''), @D_code_val1)
      END

      IF (@TP = ''''D'''' AND @D_code_va12 IS NOT NULL OR
          @TP = ''''U'''' AND {schema}.nequal_chr(@D_code_va12, @I_code_va12) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
		  EXEC	@MY_audit_seq = {schema}.log_audit_base ''''U'''', ''''code2_app_%%%name%%%'''', @I_code2_app_id, @MYUSER, @CURDTTM
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower(''''code_va12''''), @D_code_va12)
      END

      IF (@TP = ''''D'''' AND @D_code_txt IS NOT NULL OR
          @TP = ''''U'''' AND {schema}.nequal_chr(@D_code_txt, @I_code_txt) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
		  EXEC	@MY_audit_seq = {schema}.log_audit_base ''''U'''', ''''code2_app_%%%name%%%'''', @I_code2_app_id, @MYUSER, @CURDTTM
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower(''''code_txt''''), @D_code_txt)
      END

      IF (@TP = ''''D'''' AND @D_code_code IS NOT NULL OR
          @TP = ''''U'''' AND {schema}.nequal_chr(@D_code_code, @I_code_code) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
		  EXEC	@MY_audit_seq = {schema}.log_audit_base ''''U'''', ''''code2_app_%%%name%%%'''', @I_code2_app_id, @MYUSER, @CURDTTM
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower(''''code_code''''), @D_code_code)
      END

      IF (@TP = ''''D'''' AND @D_code_attrib IS NOT NULL OR
          @TP = ''''U'''' AND {schema}.nequal_chr(@D_code_attrib, @I_code_attrib) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
		  EXEC	@MY_audit_seq = {schema}.log_audit_base ''''U'''', ''''code2_app_%%%name%%%'''', @I_code2_app_id, @MYUSER, @CURDTTM
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower(''''code_attrib''''), @D_code_attrib)
      END

      IF (@TP = ''''D'''' AND @D_code_end_reason IS NOT NULL OR
          @TP = ''''U'''' AND {schema}.nequal_chr(@D_code_end_reason, @I_code_end_reason) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
		  EXEC	@MY_audit_seq = {schema}.log_audit_base ''''U'''', ''''code2_app_%%%name%%%'''', @I_code2_app_id, @MYUSER, @CURDTTM
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower(''''code_end_reason''''), @D_code_end_reason)
      END

    END  /* END OF "IF @TP=''''U'''' OR @TP=''''D''''"  */


	/******************************************/
	/****** SPECIAL BACK ACTION - BEGIN  ******/
	/******************************************/

    IF (@TP=''''U'''' AND @MY_audit_seq <> 0)
	BEGIN
      UPDATE %%%schema%%%.code2_app_%%%name%%%
	     SET code_mtstmp = @CURDTTM,
			 code_muser = @MYUSER
       WHERE code2_app_%%%name%%%.code2_app_id = @I_code2_app_id;
    END  

	/*****************************************/
	/****** SPECIAL BACK ACTION - END   ******/
	/*****************************************/



            
    FETCH NEXT FROM CUR_code2_app_%%%name%%%_IUD
        INTO @D_code2_app_id, @I_code2_app_id,
             @D_code_seq,  @I_code_seq,
             @D_code_end_dt, @I_code_end_dt,
             @D_code_val1, @I_code_val1,
             @D_code_va12, @I_CO'',NULL,NULL) WHERE [script_name]=N''create_code2_app_TRIGGER''
UPDATE [jsharmony].[script__tbl] SET [script_txt].WRITE(N''DEVAL2,
             @D_code_txt, @I_code_txt,
             @D_code_code, @I_code_code,
             @D_code_attrib, @I_code_attrib,
             @D_code_end_reason, @I_code_end_reason


  END
  CLOSE CUR_code2_app_%%%name%%%_IUD
  DEALLOCATE CUR_code2_app_%%%name%%%_IUD


  RETURN

END


'',NULL,NULL) WHERE [script_name]=N''create_code2_app_TRIGGER''
')
EXEC(N'INSERT INTO [jsharmony].[script__tbl] ([script_name], [script_txt]) VALUES (N''create_code_sys'', N''CREATE TABLE [%%%schema%%%].[code_sys_%%%name%%%](
	[code_sys_id] [bigint] IDENTITY(1,1) NOT NULL,
	[code_seq] [smallint] NULL,
	[code_val] [nvarchar](32) NOT NULL,
	[code_txt] [nvarchar](50) NULL,
	[code_code] [nvarchar](50) NULL,
	[code_end_dt] [datetime2](7) NULL,
	[code_end_reason] [nvarchar](50) NULL,
	[code_etstmp] [datetime2](7) NULL,
	[code_euser] [nvarchar](20) NULL,
	[code_mtstmp] [datetime2](7) NULL,
	[code_muser] [nvarchar](20) NULL,
	[code_snotes] [nvarchar](255) NULL,
	[code_notes] [nvarchar](255) NULL,
	[code_attrib] [nvarchar](50) NULL,
 CONSTRAINT [pk_code_sys_%%%name%%%] PRIMARY KEY CLUSTERED 
(
	[code_sys_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_code_sys_%%%name%%%_code_txt] UNIQUE NONCLUSTERED 
(
	[code_txt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_code_sys_%%%name%%%_code_val] UNIQUE NONCLUSTERED 
(
	[code_val] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

;

ALTER TABLE [%%%schema%%%].[code_sys_%%%name%%%] ADD  CONSTRAINT [DF_code_sys_%%%name%%%_COD_EDt]  DEFAULT ([jsharmony].[my_now]()) FOR [code_etstmp]
;

ALTER TABLE [%%%schema%%%].[code_sys_%%%name%%%] ADD  CONSTRAINT [DF_code_sys_%%%name%%%_COD_EUser]  DEFAULT ([jsharmony].[my_db_user]()) FOR [code_euser]
;

ALTER TABLE [%%%schema%%%].[code_sys_%%%name%%%] ADD  CONSTRAINT [DF_code_sys_%%%name%%%_COD_MDt]  DEFAULT ([jsharmony].[my_now]()) FOR [code_mtstmp]
;

ALTER TABLE [%%%schema%%%].[code_sys_%%%name%%%] ADD  CONSTRAINT [DF_code_sys_%%%name%%%_COD_MUser]  DEFAULT ([jsharmony].[my_db_user]()) FOR [code_muser]
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value ID'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''code_sys_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''code_sys_id''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Sequence'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''code_sys_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''code_seq''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''code_sys_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''code_val''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Description'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''code_sys_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''code_txt''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Additional Code'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''code_sys_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''code_code''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Termination Date'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''code_sys_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''code_end_dt''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Termination Comment'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''code_sys_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''code_end_reason''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Entry Timestamp'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''code_sys_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''code_etstmp''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Entry User'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''code_sys_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''code_euser''''
;

'')')
UPDATE [jsharmony].[script__tbl] SET [script_txt].WRITE(N'
EXEC sys.sp_addextendedproperty @name=N''MS_Description'', @value=N''Code Value Last Modification Timestamp'' , @level0type=N''SCHEMA'',@level0name=N''%%%schema%%%'', @level1type=N''TABLE'',@level1name=N''code_sys_%%%name%%%'', @level2type=N''COLUMN'',@level2name=N''code_mtstmp''
;

EXEC sys.sp_addextendedproperty @name=N''MS_Description'', @value=N''Code Value Last Modification User'' , @level0type=N''SCHEMA'',@level0name=N''%%%schema%%%'', @level1type=N''TABLE'',@level1name=N''code_sys_%%%name%%%'', @level2type=N''COLUMN'',@level2name=N''code_muser''
;

EXEC sys.sp_addextendedproperty @name=N''MS_Description'', @value=N''Code System Notes'' , @level0type=N''SCHEMA'',@level0name=N''%%%schema%%%'', @level1type=N''TABLE'',@level1name=N''code_sys_%%%name%%%'', @level2type=N''COLUMN'',@level2name=N''code_snotes''
;

EXEC sys.sp_addextendedproperty @name=N''MS_Description'', @value=N''System Codes - %%%mean%%%'' , @level0type=N''SCHEMA'',@level0name=N''%%%schema%%%'', @level1type=N''TABLE'',@level1name=N''code_sys_%%%name%%%''
;


',NULL,NULL) WHERE [script_name]=N'create_code_sys'
EXEC(N'INSERT INTO [jsharmony].[script__tbl] ([script_name], [script_txt]) VALUES (N''create_code2_sys'', N''CREATE TABLE [%%%schema%%%].[code2_sys_%%%name%%%](
	[code2_sys_id] [bigint] IDENTITY(1,1) NOT NULL,
	[code_seq] [smallint] NULL,
	[code_val1] [nvarchar](32) NOT NULL,
	[code_va12] [nvarchar](32) NOT NULL,
	[code_txt] [nvarchar](50) NULL,
	[code_code] [nvarchar](50) NULL,
	[code_attrib] [nvarchar](50) NULL,
	[code_end_dt] [datetime2](7) NULL,
	[code_end_reason] [nvarchar](50) NULL,
	[code_etstmp] [datetime2](7) NULL,
	[code_euser] [nvarchar](20) NULL,
	[code_mtstmp] [datetime2](7) NULL,
	[code_muser] [nvarchar](20) NULL,
	[code_snotes] [nvarchar](255) NULL,
	[code_notes] [nvarchar](255) NULL,
 CONSTRAINT [pk_code2_sys_%%%name%%%] PRIMARY KEY CLUSTERED 
(
	[code2_sys_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_code2_sys_%%%name%%%_code_val1_code_va12] UNIQUE NONCLUSTERED 
(
	[code_val1] ASC,
	[code_va12] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_code2_sys_%%%name%%%_code_val1_code_txt] UNIQUE NONCLUSTERED 
(
	[code_val1] ASC,
	[code_txt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

;

ALTER TABLE [%%%schema%%%].[code2_sys_%%%name%%%] ADD  CONSTRAINT [DF_code2_sys_%%%name%%%_COD_EDt]  DEFAULT ([jsharmony].[my_now]()) FOR [code_etstmp]
;

ALTER TABLE [%%%schema%%%].[code2_sys_%%%name%%%] ADD  CONSTRAINT [DF_code2_sys_%%%name%%%_COD_EUser]  DEFAULT ([jsharmony].[my_db_user]()) FOR [code_euser]
;

ALTER TABLE [%%%schema%%%].[code2_sys_%%%name%%%] ADD  CONSTRAINT [DF_code2_sys_%%%name%%%_COD_MDt]  DEFAULT ([jsharmony].[my_now]()) FOR [code_mtstmp]
;

ALTER TABLE [%%%schema%%%].[code2_sys_%%%name%%%] ADD  CONSTRAINT [DF_code2_sys_%%%name%%%_COD_MUser]  DEFAULT ([jsharmony].[my_db_user]()) FOR [code_muser]
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value ID'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''code2_sys_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''code2_sys_id''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Sequence'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''code2_sys_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''code_seq''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''code2_sys_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''code_val1''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Description'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''code2_sys_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''code_txt''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Additional Code'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''code2_sys_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''code_code''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Termination Date'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''code2_sys_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''code_end_dt''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Termination Comment'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''code2_sys_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''code_end_reason''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Entry Timestamp'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''code2_sys_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''code_etstmp''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Entry User'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''code2_sys_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''code_euser''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Last Modification Timestamp'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%'')')
UPDATE [jsharmony].[script__tbl] SET [script_txt].WRITE(N'%%schema%%%'', @level1type=N''TABLE'',@level1name=N''code2_sys_%%%name%%%'', @level2type=N''COLUMN'',@level2name=N''code_mtstmp''
;

EXEC sys.sp_addextendedproperty @name=N''MS_Description'', @value=N''Code Value Last Modification User'' , @level0type=N''SCHEMA'',@level0name=N''%%%schema%%%'', @level1type=N''TABLE'',@level1name=N''code2_sys_%%%name%%%'', @level2type=N''COLUMN'',@level2name=N''code_muser''
;

EXEC sys.sp_addextendedproperty @name=N''MS_Description'', @value=N''Code System Notes'' , @level0type=N''SCHEMA'',@level0name=N''%%%schema%%%'', @level1type=N''TABLE'',@level1name=N''code2_sys_%%%name%%%'', @level2type=N''COLUMN'',@level2name=N''code_snotes''
;

EXEC sys.sp_addextendedproperty @name=N''MS_Description'', @value=N''System Codes 2 - %%%mean%%%'' , @level0type=N''SCHEMA'',@level0name=N''%%%schema%%%'', @level1type=N''TABLE'',@level1name=N''code2_sys_%%%name%%%''
;


',NULL,NULL) WHERE [script_name]=N'create_code2_sys'
COMMIT TRANSACTION
