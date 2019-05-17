SET NUMERIC_ROUNDABORT OFF
GO
SET XACT_ABORT, ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
BEGIN TRANSACTION
EXEC(N'INSERT INTO [jsharmony].[SCRIPT] ([SCRIPT_NAME], [SCRIPT_TXT]) VALUES (N''CREATE_GCOD'', N''CREATE TABLE [%%%schema%%%].[gcod_%%%name%%%](
	[gcod_id] [bigint] IDENTITY(1,1) NOT NULL,
	[codseq] [smallint] NULL,
	[codeval] [nvarchar](8) NOT NULL,
	[codetxt] [nvarchar](50) NULL,
	[codecode] [nvarchar](50) NULL,
	[codetdt] [date] NULL,
	[codetcm] [nvarchar](50) NULL,
	[cod_etstmp] [datetime2](7) NULL,
	[cod_eu] [nvarchar](20) NULL,
	[cod_mtstmp] [datetime2](7) NULL,
	[cod_mu] [nvarchar](20) NULL,
	[cod_snotes] [nvarchar](255) NULL,
	[cod_notes] [nvarchar](255) NULL,
	[cod_eu_fmt]  AS ([jsharmony].[myCUSER_FMT]([cod_eu])),
	[cod_mu_fmt]  AS ([jsharmony].[myCUSER_FMT]([cod_mu])),
	[codeattrib] [nvarchar](50) NULL,
 CONSTRAINT [PK_GCOD_%%%name%%%] PRIMARY KEY CLUSTERED 
(
	[GCOD_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_GCOD_%%%name%%%_CODETXT] UNIQUE NONCLUSTERED 
(
	[codetxt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_GCOD_%%%name%%%_CODEVAL] UNIQUE NONCLUSTERED 
(
	[codeval] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

;

ALTER TABLE [%%%schema%%%].[GCOD_%%%name%%%] ADD  CONSTRAINT [DF_GCOD_%%%name%%%_COD_EDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [cod_etstmp]
;

ALTER TABLE [%%%schema%%%].[GCOD_%%%name%%%] ADD  CONSTRAINT [DF_GCOD_%%%name%%%_COD_EUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [cod_eu]
;

ALTER TABLE [%%%schema%%%].[GCOD_%%%name%%%] ADD  CONSTRAINT [DF_GCOD_%%%name%%%_COD_MDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [cod_mtstmp]
;

ALTER TABLE [%%%schema%%%].[GCOD_%%%name%%%] ADD  CONSTRAINT [DF_GCOD_%%%name%%%_COD_MUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [cod_mu]
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value ID'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''GCOD_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''GCOD_ID''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Sequence'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''GCOD_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''CODSEQ''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''GCOD_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''CODEVAL''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Description'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''GCOD_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''CODETXT''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Additional Code'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''GCOD_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''CODECODE''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Termination Date'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''GCOD_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''CODETDT''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Termination Comment'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''GCOD_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''CODETCM''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Entry Timestamp'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''GCOD_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''COD_ETstmp''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Entry User'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema'')')
UPDATE [jsharmony].[SCRIPT] SET [SCRIPT_TXT].WRITE(N'%%%'', @level1type=N''TABLE'',@level1name=N''GCOD_%%%name%%%'', @level2type=N''COLUMN'',@level2name=N''COD_EU''
;

EXEC sys.sp_addextendedproperty @name=N''MS_Description'', @value=N''Code Value Last Modification Timestamp'' , @level0type=N''SCHEMA'',@level0name=N''%%%schema%%%'', @level1type=N''TABLE'',@level1name=N''GCOD_%%%name%%%'', @level2type=N''COLUMN'',@level2name=N''COD_MTstmp''
;

EXEC sys.sp_addextendedproperty @name=N''MS_Description'', @value=N''Code Value Last Modification User'' , @level0type=N''SCHEMA'',@level0name=N''%%%schema%%%'', @level1type=N''TABLE'',@level1name=N''GCOD_%%%name%%%'', @level2type=N''COLUMN'',@level2name=N''COD_MU''
;

EXEC sys.sp_addextendedproperty @name=N''MS_Description'', @value=N''Code System Notes'' , @level0type=N''SCHEMA'',@level0name=N''%%%schema%%%'', @level1type=N''TABLE'',@level1name=N''GCOD_%%%name%%%'', @level2type=N''COLUMN'',@level2name=N''COD_SNotes''
;

EXEC sys.sp_addextendedproperty @name=N''MS_Description'', @value=N''User Codes - %%%mean%%%'' , @level0type=N''SCHEMA'',@level0name=N''%%%schema%%%'', @level1type=N''TABLE'',@level1name=N''GCOD_%%%name%%%''
;


',NULL,NULL) WHERE [SCRIPT_NAME]=N'CREATE_GCOD'
EXEC(N'INSERT INTO [jsharmony].[SCRIPT] ([SCRIPT_NAME], [SCRIPT_TXT]) VALUES (N''CREATE_GCOD_TRIGGER'', N''CREATE trigger [%%%schema%%%].[GCOD_%%%name%%%_IUD] on [%%%schema%%%].[GCOD_%%%name%%%]
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
  DECLARE @MY_AUD_SEQ NUMERIC(20,0)
  DECLARE CUR_GCOD_%%%name%%%_IUD CURSOR LOCAL FOR
     SELECT  d.GCOD_ID, i.GCOD_ID,
	         d.CODSEQ, i.CODSEQ,
	         d.CODETDT, i.CODETDT,
	         d.CODEVAL, i.CODEVAL,
	         d.CODETXT, i.CODETXT,
	         d.CODECODE, i.CODECODE,
	         d.CODEATTRIB, i.CODEATTRIB,
	         d.CODETCM, i.CODETCM
       FROM deleted d FULL OUTER JOIN inserted i
                       ON i.GCOD_ID = d.GCOD_ID;
  DECLARE @D_GCOD_ID bigint
  DECLARE @I_GCOD_ID bigint
  DECLARE @D_CODSEQ bigint
  DECLARE @I_CODSEQ bigint
  DECLARE @D_CODETDT DATETIME2(7)
  DECLARE @I_CODETDT DATETIME2(7)
  DECLARE @D_CODEVAL NVARCHAR(MAX)
  DECLARE @I_CODEVAL NVARCHAR(MAX)
  DECLARE @D_CODETXT NVARCHAR(MAX)
  DECLARE @I_CODETXT NVARCHAR(MAX)
  DECLARE @D_CODECODE NVARCHAR(MAX)
  DECLARE @I_CODECODE NVARCHAR(MAX)
  DECLARE @D_CODEATTRIB NVARCHAR(MAX)
  DECLARE @I_CODEATTRIB NVARCHAR(MAX)
  DECLARE @D_CODETCM NVARCHAR(MAX)
  DECLARE @I_CODETCM NVARCHAR(MAX)

  DECLARE @MYERROR_NO INT = 0
  DECLARE @MYERROR_MSG NVARCHAR(MAX) = NULL

  DECLARE @xloc nvarchar(MAX)
  DECLARE @xtxt nvarchar(MAX)

  DECLARE @DYNSQL NVARCHAR(MAX)
  DECLARE @C BIGINT
  DECLARE @CODEVAL NVARCHAR(MAX)
  DECLARE @WK_GCOD_ID bigint
  DECLARE @M NVARCHAR(MAX)
  DECLARE @CPE_USER BIT

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
  
  SET @CURDTTM = {schema}.myNOW_DO()
  SET @CURDT = {schema}.myTODATE(@CURDTTM)
  SET @CURDTTM_CHAR = CONVERT(NVARCHAR, @CURDTTM, 120)+''''.0000000''''
  SET @MYUSER = {schema}.myCUSER() 

  IF @TP = ''''U'''' AND UPDATE(GCOD_ID)
  BEGIN
    EXEC [jsharmony].[ZZ-FILEDEBUG] ''''TRIGGER'''',''''GCOD_%%%name%%%_IUD'''',''''ERR'''', ''''Cannot update ID''''
    raiserror(''''Cannot update identity'''',16,1)
    ROLLBACK TRANSACTION
    return
  END

  IF @TP = ''''U'''' AND UPDATE(CODEVAL)
  BEGIN
    EXEC [jsharmony].[ZZ-FILEDEBUG] ''''TRIGGER'''',''''GCOD_%%%name%%%_IUD'''',''''ERR'''', ''''Cannot update CODEVAL''''
    raiserror(''''Cannot update foreign key CODEVAL'''',16,1)
    ROLLBACK TRANSACTION
    return
  END

  
  OPEN CUR_GCOD_%%%name%%%_IUD
  FETCH NEXT FROM CUR_GCOD_%%%name%%%_IUD
        INTO @D_GCOD_ID, @I_GCOD_ID,
             @D_CODSEQ, @I_CODSEQ,
             @D_CODETDT, @I_CODETDT,
             @D_CODEVAL, @I_CODEVAL,
             @D_CODETXT, @I_CODETXT,
             @D_CODECODE, @I_CODECODE,
             @D_CODEATTRIB, @I_CODEATTRIB,
             @D_CODETCM, @I_CODETCM

  WHILE (@@Fetch_Status = 0)
  BEGIN

	/******************************************/
	/****** SPECIAL FRONT ACTION - BEGIN ******/
	/******************************************/

    IF (@TP=''''I'''')
	BEGIN
      UPDATE %%%schema%%%.GCOD_%%%name%%%
	     SET COD_ETstmp = @CURDTTM,
			 COD_EU = @MYUSER,
		     COD_MTstmp = @CURDTTM,
			 COD_MU = @MYUSER
       WHERE GCOD_%%%name%%%.GCOD_ID = @I_GCOD_ID;
    END  

	/******************************************/
	/****** SPECIAL FRONT ACTION - END   ******/
	/******************************************/


    SET @MY_AUD_SEQ = 0
	IF (@TP=''''I'''' OR @TP=''''D'''')
	BEGIN  
	  SET @WK_GCOD_ID = ISNULL(@D_GCOD_ID,@I_GCOD_ID)
	  EXEC	@MY_AUD_SEQ = {schema}.AUDH_BASE @TP, ''''GCOD_%%%name%%%'''', @WK_GCOD_ID, @MYUSER, @CURDTTM
	END

 
    IF @TP=''''U'''' OR @TP=''''D''''
	BEGIN

      IF (@TP = ''''D'''' AND @D_CODSEQ IS NOT NULL OR
          @TP = ''''U'''' AND {schema}.NONEQUALN(@D_CODSEQ, @I_'')')
UPDATE [jsharmony].[SCRIPT] SET [SCRIPT_TXT].WRITE(N'CODSEQ) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {schema}.AUDH_BASE ''U'', ''GCOD_%%%name%%%'', @I_GCOD_ID, @MYUSER, @CURDTTM
        INSERT INTO {schema}.AUD_D VALUES (@MY_AUD_SEQ, lower(''CODSEQ''), @D_CODSEQ)
      END

      IF (@TP = ''D'' AND @D_CODETDT IS NOT NULL OR
          @TP = ''U'' AND {schema}.NONEQUALD(@D_CODETDT, @I_CODETDT) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {schema}.AUDH_BASE ''U'', ''GCOD_%%%name%%%'', @I_GCOD_ID, @MYUSER, @CURDTTM
        INSERT INTO {schema}.AUD_D VALUES (@MY_AUD_SEQ, lower(''CODETDT''), @D_CODETDT)
      END

      IF (@TP = ''D'' AND @D_CODEVAL IS NOT NULL OR
          @TP = ''U'' AND {schema}.NONEQUALC(@D_CODEVAL, @I_CODEVAL) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {schema}.AUDH_BASE ''U'', ''GCOD_%%%name%%%'', @I_GCOD_ID, @MYUSER, @CURDTTM
        INSERT INTO {schema}.AUD_D VALUES (@MY_AUD_SEQ, lower(''CODEVAL''), @D_CODEVAL)
      END

      IF (@TP = ''D'' AND @D_CODETXT IS NOT NULL OR
          @TP = ''U'' AND {schema}.NONEQUALC(@D_CODETXT, @I_CODETXT) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {schema}.AUDH_BASE ''U'', ''GCOD_%%%name%%%'', @I_GCOD_ID, @MYUSER, @CURDTTM
        INSERT INTO {schema}.AUD_D VALUES (@MY_AUD_SEQ, lower(''CODETXT''), @D_CODETXT)
      END

      IF (@TP = ''D'' AND @D_CODECODE IS NOT NULL OR
          @TP = ''U'' AND {schema}.NONEQUALC(@D_CODECODE, @I_CODECODE) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {schema}.AUDH_BASE ''U'', ''GCOD_%%%name%%%'', @I_GCOD_ID, @MYUSER, @CURDTTM
        INSERT INTO {schema}.AUD_D VALUES (@MY_AUD_SEQ, lower(''CODECODE''), @D_CODECODE)
      END

      IF (@TP = ''D'' AND @D_codeattrib IS NOT NULL OR
          @TP = ''U'' AND {schema}.NONEQUALC(@D_codeattrib, @I_codeattrib) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {schema}.AUDH_BASE ''U'', ''GCOD_%%%name%%%'', @I_GCOD_ID, @MYUSER, @CURDTTM
        INSERT INTO {schema}.AUD_D VALUES (@MY_AUD_SEQ, lower(''CODEATTRIB''), @D_CODEATTRIB)
      END

      IF (@TP = ''D'' AND @D_CODETCM IS NOT NULL OR
          @TP = ''U'' AND {schema}.NONEQUALC(@D_CODETCM, @I_CODETCM) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {schema}.AUDH_BASE ''U'', ''GCOD_%%%name%%%'', @I_GCOD_ID, @MYUSER, @CURDTTM
        INSERT INTO {schema}.AUD_D VALUES (@MY_AUD_SEQ, lower(''CODETCM''), @D_CODETCM)
      END

    END  /* END OF "IF @TP=''U'' OR @TP=''D''"  */


	/******************************************/
	/****** SPECIAL BACK ACTION - BEGIN  ******/
	/******************************************/

    IF (@TP=''U'' AND @MY_AUD_SEQ <> 0)
	BEGIN
      UPDATE %%%schema%%%.GCOD_%%%name%%%
	     SET COD_MTstmp = @CURDTTM,
			 COD_MU = @MYUSER
       WHERE GCOD_%%%name%%%.GCOD_ID = @I_GCOD_ID;
    END  

	/*****************************************/
	/****** SPECIAL BACK ACTION - END   ******/
	/*****************************************/



            
    FETCH NEXT FROM CUR_GCOD_%%%name%%%_IUD
        INTO @D_GCOD_ID, @I_GCOD_ID,
             @D_CODSEQ,  @I_CODSEQ,
             @D_CODETDT, @I_CODETDT,
             @D_CODEVAL, @I_CODEVAL,
             @D_CODETXT, @I_CODETXT,
             @D_CODECODE, @I_CODECODE,
             @D_CODEATTRIB, @I_CODEATTRIB,
             @D_CODETCM, @I_CODETCM


  END
  CLOSE CUR_GCOD_%%%name%%%_IUD
  DEALLOCATE CUR_GCOD_%%%name%%%_IUD


  RETURN

END



',NULL,NULL) WHERE [SCRIPT_NAME]=N'CREATE_GCOD_TRIGGER'
EXEC(N'INSERT INTO [jsharmony].[SCRIPT] ([SCRIPT_NAME], [SCRIPT_TXT]) VALUES (N''CREATE_GCOD2'', N''CREATE TABLE [%%%schema%%%].[gcod2_%%%name%%%](
	[gcod2_id] [bigint] IDENTITY(1,1) NOT NULL,
	[codseq] [smallint] NULL,
	[codeval1] [nvarchar](8) NOT NULL,
	[codeval2] [nvarchar](8) NOT NULL,
	[codetxt] [nvarchar](50) NULL,
	[codecode] [nvarchar](50) NULL,
	[codeattrib] [nvarchar](50) NULL,
	[codetdt] [datetime2](7) NULL,
	[codetcm] [nvarchar](50) NULL,
	[cod_etstmp] [datetime2](7) NULL,
	[cod_eu] [nvarchar](20) NULL,
	[cod_mtstmp] [datetime2](7) NULL,
	[cod_mu] [nvarchar](20) NULL,
	[cod_snotes] [nvarchar](255) NULL,
	[cod_notes] [nvarchar](255) NULL,
	[cod_eu_fmt]  AS ([jsharmony].[myCUSER_FMT]([cod_eu])),
	[cod_mu_fmt]  AS ([jsharmony].[myCUSER_FMT]([cod_mu])),
 CONSTRAINT [PK_GCOD2_%%%name%%%] PRIMARY KEY CLUSTERED 
(
	[GCOD2_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_GCOD2_%%%name%%%_CODEVAL1_CODEVAL2] UNIQUE NONCLUSTERED 
(
	[codeval1] ASC,
	[codeval2] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_GCOD2_%%%name%%%_CODEVAL1_CODETXT] UNIQUE NONCLUSTERED 
(
	[codeval1] ASC,
	[codetxt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

;

ALTER TABLE [%%%schema%%%].[GCOD2_%%%name%%%] ADD  CONSTRAINT [DF_GCOD2_%%%name%%%_COD_EDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [cod_etstmp]
;

ALTER TABLE [%%%schema%%%].[GCOD2_%%%name%%%] ADD  CONSTRAINT [DF_GCOD2_%%%name%%%_COD_EUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [cod_eu]
;

ALTER TABLE [%%%schema%%%].[GCOD2_%%%name%%%] ADD  CONSTRAINT [DF_GCOD2_%%%name%%%_COD_MDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [cod_mtstmp]
;

ALTER TABLE [%%%schema%%%].[GCOD2_%%%name%%%] ADD  CONSTRAINT [DF_GCOD2_%%%name%%%_COD_MUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [cod_mu]
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value ID'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''GCOD2_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''GCOD2_ID''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Sequence'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''GCOD2_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''CODSEQ''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''GCOD2_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''CODEVAL1''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Description'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''GCOD2_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''CODETXT''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Additional Code'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''GCOD2_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''CODECODE''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Termination Date'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''GCOD2_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''CODETDT''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Termination Comment'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''GCOD2_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''CODETCM''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Entry Timestamp'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''GCOD2_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''COD_ETstmp''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Entry User'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''GCOD2_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''COD_EU''''
;

EXEC sys.sp_addextendedproper'')')
UPDATE [jsharmony].[SCRIPT] SET [SCRIPT_TXT].WRITE(N'ty @name=N''MS_Description'', @value=N''Code Value Last Modification Timestamp'' , @level0type=N''SCHEMA'',@level0name=N''%%%schema%%%'', @level1type=N''TABLE'',@level1name=N''GCOD2_%%%name%%%'', @level2type=N''COLUMN'',@level2name=N''COD_MTstmp''
;

EXEC sys.sp_addextendedproperty @name=N''MS_Description'', @value=N''Code Value Last Modification User'' , @level0type=N''SCHEMA'',@level0name=N''%%%schema%%%'', @level1type=N''TABLE'',@level1name=N''GCOD2_%%%name%%%'', @level2type=N''COLUMN'',@level2name=N''COD_MU''
;

EXEC sys.sp_addextendedproperty @name=N''MS_Description'', @value=N''Code System Notes'' , @level0type=N''SCHEMA'',@level0name=N''%%%schema%%%'', @level1type=N''TABLE'',@level1name=N''GCOD2_%%%name%%%'', @level2type=N''COLUMN'',@level2name=N''COD_SNotes''
;

EXEC sys.sp_addextendedproperty @name=N''MS_Description'', @value=N''User Codes 2 - %%%mean%%%'' , @level0type=N''SCHEMA'',@level0name=N''%%%schema%%%'', @level1type=N''TABLE'',@level1name=N''GCOD2_%%%name%%%''
;


',NULL,NULL) WHERE [SCRIPT_NAME]=N'CREATE_GCOD2'
EXEC(N'INSERT INTO [jsharmony].[SCRIPT] ([SCRIPT_NAME], [SCRIPT_TXT]) VALUES (N''CREATE_GCOD2_TRIGGER'', N''CREATE trigger [%%%schema%%%].[GCOD2_%%%name%%%_IUD] on [%%%schema%%%].[GCOD2_%%%name%%%]
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
  DECLARE @MY_AUD_SEQ NUMERIC(20,0)
  DECLARE CUR_GCOD2_%%%name%%%_IUD CURSOR LOCAL FOR
     SELECT  d.GCOD2_ID, i.GCOD2_ID,
	         d.CODSEQ, i.CODSEQ,
	         d.CODETDT, i.CODETDT,
	         d.CODEVAL1, i.CODEVAL1,
	         d.CODEVAL2, i.CODEVAL2,
	         d.CODETXT, i.CODETXT,
	         d.CODECODE, i.CODECODE,
	         d.CODEATTRIB, i.CODEATTRIB,
	         d.CODETCM, i.CODETCM
       FROM deleted d FULL OUTER JOIN inserted i
                       ON i.GCOD2_ID = d.GCOD2_ID;
  DECLARE @D_GCOD2_ID bigint
  DECLARE @I_GCOD2_ID bigint
  DECLARE @D_CODSEQ bigint
  DECLARE @I_CODSEQ bigint
  DECLARE @D_CODETDT DATETIME2(7)
  DECLARE @I_CODETDT DATETIME2(7)
  DECLARE @D_CODEVAL1 NVARCHAR(MAX)
  DECLARE @I_CODEVAL1 NVARCHAR(MAX)
  DECLARE @D_CODEVAL2 NVARCHAR(MAX)
  DECLARE @I_CODEVAL2 NVARCHAR(MAX)
  DECLARE @D_CODETXT NVARCHAR(MAX)
  DECLARE @I_CODETXT NVARCHAR(MAX)
  DECLARE @D_CODECODE NVARCHAR(MAX)
  DECLARE @I_CODECODE NVARCHAR(MAX)
  DECLARE @D_CODEATTRIB NVARCHAR(MAX)
  DECLARE @I_CODEATTRIB NVARCHAR(MAX)
  DECLARE @D_CODETCM NVARCHAR(MAX)
  DECLARE @I_CODETCM NVARCHAR(MAX)

  DECLARE @MYERROR_NO INT = 0
  DECLARE @MYERROR_MSG NVARCHAR(MAX) = NULL

  DECLARE @xloc nvarchar(MAX)
  DECLARE @xtxt nvarchar(MAX)

  DECLARE @DYNSQL NVARCHAR(MAX)
  DECLARE @C BIGINT
  DECLARE @M NVARCHAR(MAX)
  DECLARE @CPE_USER BIT
  DECLARE @WK_GCOD2_ID BIGINT

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
  
  SET @CURDTTM = {schema}.myNOW_DO()
  SET @CURDT = {schema}.myTODATE(@CURDTTM)
  SET @CURDTTM_CHAR = CONVERT(NVARCHAR, @CURDTTM, 120)+''''.0000000''''
  SET @MYUSER = {schema}.myCUSER() 

  IF @TP = ''''U'''' AND UPDATE(GCOD2_ID)
  BEGIN
    EXEC [jsharmony].[ZZ-FILEDEBUG] ''''TRIGGER'''',''''GCOD2_%%%name%%%_IUD'''',''''ERR'''', ''''Cannot update ID''''
    raiserror(''''Cannot update identity'''',16,1)
    ROLLBACK TRANSACTION
    return
  END

  IF @TP = ''''U'''' AND UPDATE(CODEVAL1)
  BEGIN
    EXEC [jsharmony].[ZZ-FILEDEBUG] ''''TRIGGER'''',''''GCOD2_%%%name%%%_IUD'''',''''ERR'''', ''''Cannot update CODEVAL1''''
    raiserror(''''Cannot update foreign key CODEVAL1'''',16,1)
    ROLLBACK TRANSACTION
    return
  END

  IF @TP = ''''U'''' AND UPDATE(CODEVAL2)
  BEGIN
    EXEC [jsharmony].[ZZ-FILEDEBUG] ''''TRIGGER'''',''''GCOD2_%%%name%%%_IUD'''',''''ERR'''', ''''Cannot update CODEVAL2''''
    raiserror(''''Cannot update foreign key CODEVAL2'''',16,1)
    ROLLBACK TRANSACTION
    return
  END

  
  OPEN CUR_GCOD2_%%%name%%%_IUD
  FETCH NEXT FROM CUR_GCOD2_%%%name%%%_IUD
        INTO @D_GCOD2_ID, @I_GCOD2_ID,
             @D_CODSEQ, @I_CODSEQ,
             @D_CODETDT, @I_CODETDT,
             @D_CODEVAL1, @I_CODEVAL1,
             @D_CODEVAL2, @I_CODEVAL2,
             @D_CODETXT, @I_CODETXT,
             @D_CODECODE, @I_CODECODE,
             @D_CODEATTRIB, @I_CODEATTRIB,
             @D_CODETCM, @I_CODETCM

  WHILE (@@Fetch_Status = 0)
  BEGIN

	/******************************************/
	/****** SPECIAL FRONT ACTION - BEGIN ******/
	/******************************************/

    IF (@TP=''''I'''')
	BEGIN
      UPDATE %%%schema%%%.GCOD2_%%%name%%%
	     SET COD_ETstmp = @CURDTTM,
			 COD_EU = @MYUSER,
		     COD_MTstmp = @CURDTTM,
			 COD_MU = @MYUSER
       WHERE GCOD2_%%%name%%%.GCOD2_ID = @I_GCOD2_ID;
    END  

	/******************************************/
	/****** SPECIAL FRONT ACTION - END   ******/
	/******************'')')
EXEC(N'DECLARE @pv binary(16)
'+N'UPDATE [jsharmony].[SCRIPT] SET [SCRIPT_TXT].WRITE(N''************************/


    SET @MY_AUD_SEQ = 0
	IF (@TP=''''I'''' OR @TP=''''D'''')
	BEGIN  
	  SET @WK_GCOD2_ID = ISNULL(@D_GCOD2_ID,@I_GCOD2_ID)
	  EXEC	@MY_AUD_SEQ = {schema}.AUDH_BASE @TP, ''''GCOD2_%%%name%%%'''', @WK_GCOD2_ID, @MYUSER, @CURDTTM
	END

 
    IF @TP=''''U'''' OR @TP=''''D''''
	BEGIN

      IF (@TP = ''''D'''' AND @D_CODSEQ IS NOT NULL OR
          @TP = ''''U'''' AND {schema}.NONEQUALN(@D_CODSEQ, @I_CODSEQ) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {schema}.AUDH_BASE ''''U'''', ''''GCOD2_%%%name%%%'''', @I_GCOD2_ID, @MYUSER, @CURDTTM
        INSERT INTO {schema}.AUD_D VALUES (@MY_AUD_SEQ, lower(''''CODSEQ''''), @D_CODSEQ)
      END

      IF (@TP = ''''D'''' AND @D_CODETDT IS NOT NULL OR
          @TP = ''''U'''' AND {schema}.NONEQUALD(@D_CODETDT, @I_CODETDT) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {schema}.AUDH_BASE ''''U'''', ''''GCOD2_%%%name%%%'''', @I_GCOD2_ID, @MYUSER, @CURDTTM
        INSERT INTO {schema}.AUD_D VALUES (@MY_AUD_SEQ, lower(''''CODETDT''''), @D_CODETDT)
      END

      IF (@TP = ''''D'''' AND @D_CODEVAL1 IS NOT NULL OR
          @TP = ''''U'''' AND {schema}.NONEQUALC(@D_CODEVAL1, @I_CODEVAL1) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {schema}.AUDH_BASE ''''U'''', ''''GCOD2_%%%name%%%'''', @I_GCOD2_ID, @MYUSER, @CURDTTM
        INSERT INTO {schema}.AUD_D VALUES (@MY_AUD_SEQ, lower(''''CODEVAL1''''), @D_CODEVAL1)
      END

      IF (@TP = ''''D'''' AND @D_CODEVAL2 IS NOT NULL OR
          @TP = ''''U'''' AND {schema}.NONEQUALC(@D_CODEVAL2, @I_CODEVAL2) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {schema}.AUDH_BASE ''''U'''', ''''GCOD2_%%%name%%%'''', @I_GCOD2_ID, @MYUSER, @CURDTTM
        INSERT INTO {schema}.AUD_D VALUES (@MY_AUD_SEQ, lower(''''CODEVAL2''''), @D_CODEVAL2)
      END

      IF (@TP = ''''D'''' AND @D_CODETXT IS NOT NULL OR
          @TP = ''''U'''' AND {schema}.NONEQUALC(@D_CODETXT, @I_CODETXT) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {schema}.AUDH_BASE ''''U'''', ''''GCOD2_%%%name%%%'''', @I_GCOD2_ID, @MYUSER, @CURDTTM
        INSERT INTO {schema}.AUD_D VALUES (@MY_AUD_SEQ, lower(''''CODETXT''''), @D_CODETXT)
      END

      IF (@TP = ''''D'''' AND @D_CODECODE IS NOT NULL OR
          @TP = ''''U'''' AND {schema}.NONEQUALC(@D_CODECODE, @I_CODECODE) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {schema}.AUDH_BASE ''''U'''', ''''GCOD2_%%%name%%%'''', @I_GCOD2_ID, @MYUSER, @CURDTTM
        INSERT INTO {schema}.AUD_D VALUES (@MY_AUD_SEQ, lower(''''CODECODE''''), @D_CODECODE)
      END

      IF (@TP = ''''D'''' AND @D_CODEATTRIB IS NOT NULL OR
          @TP = ''''U'''' AND {schema}.NONEQUALC(@D_CODEATTRIB, @I_CODEATTRIB) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {schema}.AUDH_BASE ''''U'''', ''''GCOD2_%%%name%%%'''', @I_GCOD2_ID, @MYUSER, @CURDTTM
        INSERT INTO {schema}.AUD_D VALUES (@MY_AUD_SEQ, lower(''''CODEATTRIB''''), @D_CODEATTRIB)
      END

      IF (@TP = ''''D'''' AND @D_CODETCM IS NOT NULL OR
          @TP = ''''U'''' AND {schema}.NONEQUALC(@D_CODETCM, @I_CODETCM) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {schema}.AUDH_BASE ''''U'''', ''''GCOD2_%%%name%%%'''', @I_GCOD2_ID, @MYUSER, @CURDTTM
        INSERT INTO {schema}.AUD_D VALUES (@MY_AUD_SEQ, lower(''''CODETCM''''), @D_CODETCM)
      END

    END  /* END OF "IF @TP=''''U'''' OR @TP=''''D''''"  */


	/******************************************/
	/****** SPECIAL BACK ACTION - BEGIN  ******/
	/******************************************/

    IF (@TP=''''U'''' AND @MY_AUD_SEQ <> 0)
	BEGIN
      UPDATE %%%schema%%%.GCOD2_%%%name%%%
	     SET COD_MTstmp = @CURDTTM,
			 COD_MU = @MYUSER
       WHERE GCOD2_%%%name%%%.GCOD2_ID = @I_GCOD2_ID;
    END  

	/*****************************************/
	/****** SPECIAL BACK ACTION - END   ******/
	/*****************************************/



            
    FETCH NEXT FROM CUR_GCOD2_%%%name%%%_IUD
        INTO @D_GCOD2_ID, @I_GCOD2_ID,
             @D_CODSEQ,  @I_CODSEQ,
             @D_CODETDT, @I_CODETDT,
             @D_CODEVAL1, @I_CODEVAL1,
             @D_CODEVAL2, @I_CO'',NULL,NULL) WHERE [SCRIPT_NAME]=N''CREATE_GCOD2_TRIGGER''
UPDATE [jsharmony].[SCRIPT] SET [SCRIPT_TXT].WRITE(N''DEVAL2,
             @D_CODETXT, @I_CODETXT,
             @D_CODECODE, @I_CODECODE,
             @D_CODEATTRIB, @I_CODEATTRIB,
             @D_CODETCM, @I_CODETCM


  END
  CLOSE CUR_GCOD2_%%%name%%%_IUD
  DEALLOCATE CUR_GCOD2_%%%name%%%_IUD


  RETURN

END


'',NULL,NULL) WHERE [SCRIPT_NAME]=N''CREATE_GCOD2_TRIGGER''
')
EXEC(N'INSERT INTO [jsharmony].[SCRIPT] ([SCRIPT_NAME], [SCRIPT_TXT]) VALUES (N''CREATE_UCOD'', N''CREATE TABLE [%%%schema%%%].[ucod_%%%name%%%](
	[ucod_id] [bigint] IDENTITY(1,1) NOT NULL,
	[codseq] [smallint] NULL,
	[codeval] [nvarchar](8) NOT NULL,
	[codetxt] [nvarchar](50) NULL,
	[codecode] [nvarchar](50) NULL,
	[codetdt] [datetime2](7) NULL,
	[codetcm] [nvarchar](50) NULL,
	[cod_etstmp] [datetime2](7) NULL,
	[cod_eu] [nvarchar](20) NULL,
	[cod_mtstmp] [datetime2](7) NULL,
	[cod_mu] [nvarchar](20) NULL,
	[cod_snotes] [nvarchar](255) NULL,
	[cod_notes] [nvarchar](255) NULL,
	[codeattrib] [nvarchar](50) NULL,
 CONSTRAINT [PK_UCOD_%%%name%%%] PRIMARY KEY CLUSTERED 
(
	[UCOD_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_UCOD_%%%name%%%_CODETXT] UNIQUE NONCLUSTERED 
(
	[codetxt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_UCOD_%%%name%%%_CODEVAL] UNIQUE NONCLUSTERED 
(
	[codeval] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

;

ALTER TABLE [%%%schema%%%].[UCOD_%%%name%%%] ADD  CONSTRAINT [DF_UCOD_%%%name%%%_COD_EDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [cod_etstmp]
;

ALTER TABLE [%%%schema%%%].[UCOD_%%%name%%%] ADD  CONSTRAINT [DF_UCOD_%%%name%%%_COD_EUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [cod_eu]
;

ALTER TABLE [%%%schema%%%].[UCOD_%%%name%%%] ADD  CONSTRAINT [DF_UCOD_%%%name%%%_COD_MDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [cod_mtstmp]
;

ALTER TABLE [%%%schema%%%].[UCOD_%%%name%%%] ADD  CONSTRAINT [DF_UCOD_%%%name%%%_COD_MUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [cod_mu]
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value ID'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''UCOD_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''UCOD_ID''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Sequence'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''UCOD_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''CODSEQ''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''UCOD_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''CODEVAL''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Description'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''UCOD_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''CODETXT''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Additional Code'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''UCOD_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''CODECODE''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Termination Date'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''UCOD_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''CODETDT''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Termination Comment'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''UCOD_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''CODETCM''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Entry Timestamp'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''UCOD_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''COD_ETstmp''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Entry User'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''UCOD_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''COD_EU''''
;

'')')
UPDATE [jsharmony].[SCRIPT] SET [SCRIPT_TXT].WRITE(N'
EXEC sys.sp_addextendedproperty @name=N''MS_Description'', @value=N''Code Value Last Modification Timestamp'' , @level0type=N''SCHEMA'',@level0name=N''%%%schema%%%'', @level1type=N''TABLE'',@level1name=N''UCOD_%%%name%%%'', @level2type=N''COLUMN'',@level2name=N''COD_MTstmp''
;

EXEC sys.sp_addextendedproperty @name=N''MS_Description'', @value=N''Code Value Last Modification User'' , @level0type=N''SCHEMA'',@level0name=N''%%%schema%%%'', @level1type=N''TABLE'',@level1name=N''UCOD_%%%name%%%'', @level2type=N''COLUMN'',@level2name=N''COD_MU''
;

EXEC sys.sp_addextendedproperty @name=N''MS_Description'', @value=N''Code System Notes'' , @level0type=N''SCHEMA'',@level0name=N''%%%schema%%%'', @level1type=N''TABLE'',@level1name=N''UCOD_%%%name%%%'', @level2type=N''COLUMN'',@level2name=N''COD_SNotes''
;

EXEC sys.sp_addextendedproperty @name=N''MS_Description'', @value=N''System Codes - %%%mean%%%'' , @level0type=N''SCHEMA'',@level0name=N''%%%schema%%%'', @level1type=N''TABLE'',@level1name=N''UCOD_%%%name%%%''
;


',NULL,NULL) WHERE [SCRIPT_NAME]=N'CREATE_UCOD'
EXEC(N'INSERT INTO [jsharmony].[SCRIPT] ([SCRIPT_NAME], [SCRIPT_TXT]) VALUES (N''CREATE_UCOD2'', N''CREATE TABLE [%%%schema%%%].[ucod2_%%%name%%%](
	[ucod2_id] [bigint] IDENTITY(1,1) NOT NULL,
	[codseq] [smallint] NULL,
	[codeval1] [nvarchar](8) NOT NULL,
	[codeval2] [nvarchar](8) NOT NULL,
	[codetxt] [nvarchar](50) NULL,
	[codecode] [nvarchar](50) NULL,
	[codeattrib] [nvarchar](50) NULL,
	[codetdt] [datetime2](7) NULL,
	[codetcm] [nvarchar](50) NULL,
	[cod_etstmp] [datetime2](7) NULL,
	[cod_eu] [nvarchar](20) NULL,
	[cod_mtstmp] [datetime2](7) NULL,
	[cod_mu] [nvarchar](20) NULL,
	[cod_snotes] [nvarchar](255) NULL,
	[cod_notes] [nvarchar](255) NULL,
 CONSTRAINT [PK_UCOD2_%%%name%%%] PRIMARY KEY CLUSTERED 
(
	[UCOD2_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_UCOD2_%%%name%%%_CODEVAL1_CODEVAL2] UNIQUE NONCLUSTERED 
(
	[codeval1] ASC,
	[codeval2] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_UCOD2_%%%name%%%_CODEVAL1_CODETXT] UNIQUE NONCLUSTERED 
(
	[codeval1] ASC,
	[codetxt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

;

ALTER TABLE [%%%schema%%%].[UCOD2_%%%name%%%] ADD  CONSTRAINT [DF_UCOD2_%%%name%%%_COD_EDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [cod_etstmp]
;

ALTER TABLE [%%%schema%%%].[UCOD2_%%%name%%%] ADD  CONSTRAINT [DF_UCOD2_%%%name%%%_COD_EUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [cod_eu]
;

ALTER TABLE [%%%schema%%%].[UCOD2_%%%name%%%] ADD  CONSTRAINT [DF_UCOD2_%%%name%%%_COD_MDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [cod_mtstmp]
;

ALTER TABLE [%%%schema%%%].[UCOD2_%%%name%%%] ADD  CONSTRAINT [DF_UCOD2_%%%name%%%_COD_MUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [cod_mu]
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value ID'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''UCOD2_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''UCOD2_ID''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Sequence'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''UCOD2_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''CODSEQ''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''UCOD2_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''CODEVAL1''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Description'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''UCOD2_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''CODETXT''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Additional Code'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''UCOD2_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''CODECODE''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Termination Date'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''UCOD2_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''CODETDT''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Termination Comment'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''UCOD2_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''CODETCM''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Entry Timestamp'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''UCOD2_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''COD_ETstmp''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Entry User'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%%%schema%%%'''', @level1type=N''''TABLE'''',@level1name=N''''UCOD2_%%%name%%%'''', @level2type=N''''COLUMN'''',@level2name=N''''COD_EU''''
;

EXEC sys.sp_addextendedproperty @name=N''''MS_Description'''', @value=N''''Code Value Last Modification Timestamp'''' , @level0type=N''''SCHEMA'''',@level0name=N''''%'')')
UPDATE [jsharmony].[SCRIPT] SET [SCRIPT_TXT].WRITE(N'%%schema%%%'', @level1type=N''TABLE'',@level1name=N''UCOD2_%%%name%%%'', @level2type=N''COLUMN'',@level2name=N''COD_MTstmp''
;

EXEC sys.sp_addextendedproperty @name=N''MS_Description'', @value=N''Code Value Last Modification User'' , @level0type=N''SCHEMA'',@level0name=N''%%%schema%%%'', @level1type=N''TABLE'',@level1name=N''UCOD2_%%%name%%%'', @level2type=N''COLUMN'',@level2name=N''COD_MU''
;

EXEC sys.sp_addextendedproperty @name=N''MS_Description'', @value=N''Code System Notes'' , @level0type=N''SCHEMA'',@level0name=N''%%%schema%%%'', @level1type=N''TABLE'',@level1name=N''UCOD2_%%%name%%%'', @level2type=N''COLUMN'',@level2name=N''COD_SNotes''
;

EXEC sys.sp_addextendedproperty @name=N''MS_Description'', @value=N''System Codes 2 - %%%mean%%%'' , @level0type=N''SCHEMA'',@level0name=N''%%%schema%%%'', @level1type=N''TABLE'',@level1name=N''UCOD2_%%%name%%%''
;


',NULL,NULL) WHERE [SCRIPT_NAME]=N'CREATE_UCOD2'
COMMIT TRANSACTION
