/****** Object:  DatabaseRole [jsharmony_role_dev]    Script Date: 10/25/2017 7:00:06 AM ******/
CREATE ROLE [jsharmony_role_dev]
GO
/****** Object:  DatabaseRole [jsharmony_role_exec]    Script Date: 10/25/2017 7:00:06 AM ******/
CREATE ROLE [jsharmony_role_exec]
GO
ALTER ROLE [db_datareader] ADD MEMBER [jsharmony_role_dev]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [jsharmony_role_dev]
GO
ALTER ROLE [db_datareader] ADD MEMBER [jsharmony_role_exec]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [jsharmony_role_exec]
GO
/****** Object:  Schema [jsharmony]    Script Date: 10/25/2017 7:00:06 AM ******/
CREATE SCHEMA [jsharmony]
GO
GRANT ALTER ON SCHEMA::[jsharmony] TO [jsharmony_role_dev] AS [dbo]
GO
/****** Object:  UserDefinedFunction [jsharmony].[audit_info]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [jsharmony].[audit_info] 
(@ETSTMP datetime2(7),
 @EU     nvarchar(max),
 @MTSTMP datetime2(7),
 @MU     nvarchar(max))
RETURNS VARCHAR(MAX)
AS
BEGIN
  DECLARE @rslt nvarchar(max) = NULL

  SET @rslt =  'INFO'+char(13)+char(10)+ 
               '         Entered:  '+jsharmony.mymmddyyhhmi(@ETSTMP)+'  '+jsharmony.mycuser_fmt(@EU)+
         char(13)+char(10)+ 
               'Last Updated:  '+jsharmony.mymmddyyhhmi(@MTSTMP)+'  '+jsharmony.mycuser_fmt(@MU); 

  RETURN @rslt
END


GO
GRANT EXECUTE ON [jsharmony].[audit_info] TO [jsharmony_role_exec] AS [dbo]
GO
/****** Object:  UserDefinedFunction [jsharmony].[CHECK_PP]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [jsharmony].[CHECK_PP]
(
  @in_table nvarchar(3),
  @in_process nvarchar(32),
  @in_attrib nvarchar(16),
  @in_val nvarchar(256)
) 
RETURNS NVARCHAR(MAX)  
AS 
BEGIN
DECLARE @adv_error INT
DECLARE @c TINYINT
DECLARE @rslt NVARCHAR(MAX)
DECLARE @ppd_type NVARCHAR(8)
DECLARE @codename NVARCHAR(16)
DECLARE @ppd_gpp BIT
DECLARE @ppd_ppp BIT
DECLARE @ppd_xpp BIT


  SELECT @rslt = NULL
  SELECT @ppd_type = NULL
  
  SELECT @ppd_type = ppd.ppd_type,
         @codename = ppd.codename,
         @ppd_gpp = ppd.ppd_gpp,
         @ppd_ppp = ppd.ppd_ppp,
         @ppd_xpp = ppd.ppd_xpp
    FROM jsharmony.PPD
   WHERE ppd.ppd_process = @in_process
     AND ppd.ppd_attrib = @in_attrib      

  IF @ppd_type IS NULL
    RETURN 'Process parameter '+@in_process+'.'+@in_attrib+' is not defined in PPD'
  
  IF @in_table NOT IN ('GPP','PPP','XPP')
    RETURN 'Table '+@in_table + ' is not defined'
 
  IF @in_table='GPP' AND @ppd_gpp=0
    RETURN 'Process parameter '+@in_process+'.'+@in_attrib+' is not assigned to '+@in_table
  ELSE IF @in_table='PPP' AND @ppd_ppp=0
    RETURN 'Process parameter '+@in_process+'.'+@in_attrib+' is not assigned to '+@in_table
  ELSE IF @in_table='XPP' AND @ppd_xpp=0
    RETURN 'Process parameter '+@in_process+'.'+@in_attrib+' is not assigned to '+@in_table

  IF ISNULL(@in_val,'') = ''
    RETURN 'Value has to be present'

  IF @ppd_type='N' AND ISNUMERIC(@in_val)=0
    RETURN 'Value '+@in_val+' is not numeric'

  IF ISNULL(@codename,'') != ''
  BEGIN 
    select @c = count(*)
      from ucod
     where codename = @codename
       and codeval = @in_val 
       
    IF @c=0
      RETURN 'Incorrect value '+@in_val   
       
  END
  
  
  
  return (@rslt)

END






GO
/****** Object:  UserDefinedFunction [jsharmony].[EXISTS_D]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE FUNCTION [jsharmony].[EXISTS_D]
(
  @tbl nvarchar(MAX),
  @id bigint
) 
RETURNS bit  
AS 
BEGIN
DECLARE @rslt BIT = 0

  select top(1) @rslt=1
    from jsharmony.D
   where D_SCOPE = @tbl
     and D_SCOPE_ID = @id;   

return(isnull(@rslt,0))
  
END










GO
/****** Object:  UserDefinedFunction [jsharmony].[EXISTS_N]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE FUNCTION [jsharmony].[EXISTS_N]
(
  @tbl nvarchar(MAX),
  @id bigint
) 
RETURNS bit  
AS 
BEGIN
DECLARE @rslt BIT = 0

  select top(1) @rslt=1
    from jsharmony.N
   where N_SCOPE = @tbl
     and N_SCOPE_ID = @id;   

return(isnull(@rslt,0))
  
END









GO
/****** Object:  UserDefinedFunction [jsharmony].[GET_CPE_NAME]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [jsharmony].[GET_CPE_NAME]
(
  @in_PE_ID BIGINT
) 
RETURNS NVARCHAR(MAX)  
AS 
BEGIN
DECLARE @rslt NVARCHAR(MAX) = NULL

  SELECT @rslt = PE_LName+', '+PE_FName
    FROM jsharmony.CPE
   WHERE PE_ID = @in_PE_ID;

  RETURN (@rslt)

END


GO
GRANT EXECUTE ON [jsharmony].[GET_CPE_NAME] TO [jsharmony_role_exec] AS [dbo]
GO
/****** Object:  UserDefinedFunction [jsharmony].[GET_PE_NAME]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [jsharmony].[GET_PE_NAME]
(
  @in_PE_ID BIGINT
) 
RETURNS NVARCHAR(MAX)  
AS 
BEGIN
DECLARE @rslt NVARCHAR(MAX) = NULL

  SELECT @rslt = PE_LName+', '+PE_FName
    FROM jsharmony.PE
   WHERE PE_ID = @in_PE_ID;

  RETURN (@rslt)

END

GO
GRANT EXECUTE ON [jsharmony].[GET_PE_NAME] TO [jsharmony_role_exec] AS [dbo]
GO
/****** Object:  UserDefinedFunction [jsharmony].[GET_PPD_DESC]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [jsharmony].[GET_PPD_DESC]
(
  @in_PPD_PROCESS NVARCHAR(MAX),
  @in_PPD_ATTRIB NVARCHAR(MAX)
) 
RETURNS NVARCHAR(MAX)  
AS 
BEGIN
DECLARE @rslt NVARCHAR(MAX) = NULL

  SELECT @rslt = PPD_DESC
    FROM jsharmony.PPD
   WHERE PPD_PROCESS = @in_PPD_PROCESS
     AND PPD_ATTRIB = @in_PPD_ATTRIB

  RETURN (@rslt)

END




GO
/****** Object:  UserDefinedFunction [jsharmony].[myCUSER]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE FUNCTION [jsharmony].[myCUSER]
()  
RETURNS varchar(20)   
AS 
BEGIN
DECLARE @rslt varchar(20)

  SET @rslt = jsharmony.myCUSER_DO()

  return (@rslt)

END



GO
GRANT REFERENCES ON [jsharmony].[myCUSER] TO [jsharmony_role_dev] AS [dbo]
GO
GRANT EXECUTE ON [jsharmony].[myCUSER] TO [jsharmony_role_exec] AS [dbo]
GO
/****** Object:  UserDefinedFunction [jsharmony].[myCUSER_DO]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE FUNCTION [jsharmony].[myCUSER_DO]
()  
RETURNS varchar(20)   
AS 
BEGIN
DECLARE @rslt nvarchar(20)
DECLARE @an varchar(255)
DECLARE @pe_id BIGINT=-1;

  SET @rslt = '0'
  SET @an = LTRIM(RTRIM(REPLACE(ISNULL(CONVERT(VARCHAR(128), CONTEXT_INFO()), APP_NAME()),CHAR(0),'')))
  IF ((@an IS NOT NULL) AND (@an <> 'DBAPP')) 
  BEGIN 
    SELECT @pe_id=pe_id
    FROM jsharmony.PE
     WHERE PE_Email = @an;
  
  SET @rslt = CASE WHEN @pe_id=(-1) THEN @an ELSE 'P'+CONVERT(VARCHAR(30),@pe_id) END
  END 
  return (@rslt)
END





GO
/****** Object:  UserDefinedFunction [jsharmony].[myCUSER_FMT]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [jsharmony].[myCUSER_FMT]
(@USER VARCHAR(20)) 
RETURNS nvarchar(120)   
AS 
BEGIN
DECLARE @rslt nvarchar(255)

  SET @rslt = jsharmony.myCUSER_FMT_DO(@USER)
  
  return (@rslt)

END




GO
GRANT REFERENCES ON [jsharmony].[myCUSER_FMT] TO [jsharmony_role_dev] AS [dbo]
GO
GRANT EXECUTE ON [jsharmony].[myCUSER_FMT] TO [jsharmony_role_exec] AS [dbo]
GO
/****** Object:  UserDefinedFunction [jsharmony].[myCUSER_FMT_DO]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE FUNCTION [jsharmony].[myCUSER_FMT_DO]
(@USER VARCHAR(20)) 
RETURNS nvarchar(120)   
AS 
BEGIN
DECLARE @rslt nvarchar(255)

  SET @rslt = case when @USER is null then NULL else 'SYSTEM' end;

  if @USER = 'C'
    set @rslt = @USER
  else if (substring(@USER,1,1)='S' and isnumeric(substring(@USER,2,1024))=1)
  begin
    set @rslt = @USER;
    select @rslt = 'S-'+isnull(PE_Name,'')
   from jsharmony.PE
    where convert(varchar(50),PE_ID)=substring(@USER,2,1024);
  end
  else if (substring(@USER,1,1)='C' and isnumeric(substring(@USER,2,1024))=1)
  begin
    set @rslt = @USER;
    select @rslt = 'C-'+isnull(PE_Name,'')
   from jsharmony.CPE
    where convert(varchar(50),PE_ID)=substring(@USER,2,1024);
  end

  return (@rslt)

END





GO
/****** Object:  UserDefinedFunction [jsharmony].[myHASH]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE FUNCTION [jsharmony].[myHASH]
(@TYPE CHAR(1),
 @PE_ID bigint,
 @PW nvarchar(255)) 
RETURNS varbinary(200)   
AS 
BEGIN
DECLARE @rslt varbinary(200) = NULL
DECLARE @seed nvarchar(255) = NULL
DECLARE @v varchar(255)

  if (@TYPE = 'S')
  BEGIN
    select @seed = PP_VAL
    from jsharmony.V_PP
     where PP_PROCESS = 'USERS'
     and PP_ATTRIB = 'HASH_SEED_S';
  END
  else if (@TYPE = 'C')
  BEGIN
    select @seed = PP_VAL
    from jsharmony.V_PP
     where PP_PROCESS = 'USERS'
     and PP_ATTRIB = 'HASH_SEED_C';
  END

  if (@seed is not null
      and isnull(@PE_ID,0) > 0
    and isnull(@PW,'') <> '')
  begin
    select @v = (convert(varchar(50),@PE_ID)+@PW+@seed)
    select @rslt = hashbytes('sha1',@v)
  end

  return @rslt

END






GO
/****** Object:  UserDefinedFunction [jsharmony].[myMMDDYYHHMI]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE FUNCTION [jsharmony].[myMMDDYYHHMI] (@X DATETIME2(7))
RETURNS varchar(140)
AS
BEGIN
  RETURN convert(varchar(50),@X,1)+' '+substring(convert(varchar(50),@X,14),1,5)
END

GO
/****** Object:  UserDefinedFunction [jsharmony].[myNOW]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE FUNCTION [jsharmony].[myNOW]
()
RETURNS DATETIME2(7)   
AS 
BEGIN
  RETURN (jsharmony.myNOW_DO())
END







GO
GRANT REFERENCES ON [jsharmony].[myNOW] TO [jsharmony_role_dev] AS [dbo]
GO
GRANT EXECUTE ON [jsharmony].[myNOW] TO [jsharmony_role_exec] AS [dbo]
GO
/****** Object:  UserDefinedFunction [jsharmony].[myNOW_DO]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE FUNCTION [jsharmony].[myNOW_DO]
()
RETURNS DATETIME2(7)   
AS 
BEGIN
  RETURN (SYSDATETIME())
END







GO
/****** Object:  UserDefinedFunction [jsharmony].[myPE]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [jsharmony].[myPE]
()  
RETURNS bigint   
AS 
BEGIN
DECLARE @rslt bigint

  SET @rslt = jsharmony.myPE_DO()

  return (@rslt)

END




GO
/****** Object:  UserDefinedFunction [jsharmony].[myPE_DO]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [jsharmony].[myPE_DO]
()  
RETURNS bigint   
AS 
BEGIN
DECLARE @rslt bigint
DECLARE @an varchar(255)
DECLARE @pe_id BIGINT=-1;

  SET @rslt = NULL
  SET @an = LTRIM(RTRIM(REPLACE(ISNULL(CONVERT(VARCHAR(128), CONTEXT_INFO()), APP_NAME()),CHAR(0),'')))
  IF ((@an IS NOT NULL) AND (@an <> 'DBAPP')) 
  BEGIN
    if substring(@an,1,1) = 'S' and isnumeric(substring(@an,2,100))<>0
    set @rslt = convert(bigint,substring(@an,2,100)) 
  END 
  return (@rslt);
END

GO
/****** Object:  UserDefinedFunction [jsharmony].[myTODATE]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE FUNCTION [jsharmony].[myTODATE] (@X DATETIME2(7))
RETURNS date
AS
BEGIN
  
  RETURN DATEADD(day, DATEDIFF(day, 0, @X), 0)


END



GO
/****** Object:  UserDefinedFunction [jsharmony].[myTODAY]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE FUNCTION [jsharmony].[myTODAY] ()
RETURNS date
AS
BEGIN
  RETURN (jsharmony.myTODAY_DO())
END



GO
GRANT EXECUTE ON [jsharmony].[myTODAY] TO [jsharmony_role_exec] AS [dbo]
GO
/****** Object:  UserDefinedFunction [jsharmony].[myTODAY_DO]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE FUNCTION [jsharmony].[myTODAY_DO] ()
RETURNS date
AS
BEGIN
  
  RETURN DATEADD(day, DATEDIFF(day, 0, jsharmony.myNOW()), 0)


END



GO
/****** Object:  UserDefinedFunction [jsharmony].[NONEQUALC]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE FUNCTION [jsharmony].[NONEQUALC]
(
  @in1 nvarchar(MAX),
  @in2 nvarchar(MAX)
) 
RETURNS bit  
AS 
BEGIN
DECLARE @rslt BIT

  if isnull(@in1,'') <> isnull(@in2,'') COLLATE SQL_Latin1_General_CP1_CS_AS 
    select @rslt = 1
  else
    select @rslt = 0

return(@rslt)
  
END







GO
/****** Object:  UserDefinedFunction [jsharmony].[NONEQUALD]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE FUNCTION [jsharmony].[NONEQUALD]
(
  @in1 DATETIME2(7),
  @in2 DATETIME2(7)
) 
RETURNS bit  
AS 
BEGIN
DECLARE @rslt BIT

  if @in1 is null and @in2 is not null
     or @in1 is not null and @in2 is null
    select @rslt = 1
  else
    if @in1 is null and @in2 is null
      select @rslt = 0
    else
      if @in1 <> @in2
        select @rslt = 1
      else
        select @rslt = 0

return(@rslt)
  
END









GO
/****** Object:  UserDefinedFunction [jsharmony].[NONEQUALN]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [jsharmony].[NONEQUALN]
(
  @in1 numeric(30,10),
  @in2 numeric(30,10)
) 
RETURNS bit  
AS 
BEGIN
DECLARE @rslt BIT

  if @in1 is null and @in2 is not null
     or @in1 is not null and @in2 is null
     or isnull(@in1,0) <> isnull(@in2,0)
    select @rslt = 1
  else
    select @rslt = 0

return(@rslt)
  
END






GO
/****** Object:  UserDefinedFunction [jsharmony].[TABLE_TYPE]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE FUNCTION [jsharmony].[TABLE_TYPE]
(
  @in_schema varchar(max),
  @in_name varchar(max)
) 
RETURNS VARCHAR(max)  
AS 
BEGIN
DECLARE @rslt VARCHAR(MAX) = NULL
 
  select @rslt = table_type
    from information_schema.tables
   where table_schema = coalesce(@in_schema,'dbo')
     and table_name = @in_name; 
  
  RETURN (@rslt)

END



GO
GRANT EXECUTE ON [jsharmony].[TABLE_TYPE] TO [jsharmony_role_exec] AS [dbo]
GO
/****** Object:  Table [jsharmony].[PPD]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[PPD](
  [PPD_PROCESS] [nvarchar](32) NOT NULL,
  [PPD_ATTRIB] [nvarchar](16) NOT NULL,
  [PPD_DESC] [nvarchar](255) NOT NULL,
  [PPD_TYPE] [nvarchar](8) NOT NULL,
  [CODENAME] [nvarchar](16) NULL,
  [PPD_GPP] [bit] NOT NULL,
  [PPD_PPP] [bit] NOT NULL,
  [PPD_XPP] [bit] NOT NULL,
  [PPD_ID] [bigint] IDENTITY(1,1) NOT NULL,
  [PPD_ETstmp] [datetime2](7) NOT NULL,
  [PPD_EU] [nvarchar](20) NOT NULL,
  [PPD_MTstmp] [datetime2](7) NOT NULL,
  [PPD_MU] [nvarchar](20) NOT NULL,
  [PPD_SNotes] [nvarchar](max) NULL,
 CONSTRAINT [PK_PPD] PRIMARY KEY CLUSTERED 
(
  [PPD_PROCESS] ASC,
  [PPD_ATTRIB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [jsharmony].[UCOD_PPP_PROCESS_V]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/****** Script for SelectTopNRows command from SSMS  ******/
create view [jsharmony].[UCOD_PPP_PROCESS_V] as
SELECT distinct
       NULL CODSEQ
      ,PPD_PROCESS CODEVAL
      ,PPD_PROCESS CODETXT
      ,NULL CODECODE
      ,NULL CODETDT
      ,NULL CODETCM
  FROM jsharmony.PPD
 where PPD_PPP = 1

GO
/****** Object:  Table [jsharmony].[AUD_H]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[AUD_H](
  [AUD_SEQ] [bigint] IDENTITY(1,1) NOT NULL,
  [TABLE_NAME] [varchar](32) NOT NULL,
  [TABLE_ID] [bigint] NOT NULL,
  [AUD_OP] [char](10) NOT NULL,
  [AUD_U] [nvarchar](20) NOT NULL,
  [DB_K] [char](1) NOT NULL,
  [AUD_Tstmp] [datetime2](7) NOT NULL,
  [C_ID] [bigint] NULL,
  [E_ID] [bigint] NULL,
  [REF_NAME] [varchar](32) NULL,
  [REF_ID] [bigint] NULL,
  [SUBJ] [nvarchar](255) NULL,
 CONSTRAINT [PK_AUD_H] PRIMARY KEY CLUSTERED 
(
  [AUD_SEQ] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [jsharmony].[AUD_D]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[AUD_D](
  [AUD_SEQ] [bigint] NOT NULL,
  [COLUMN_NAME] [varchar](30) NOT NULL,
  [COLUMN_VAL] [nvarchar](max) NULL,
 CONSTRAINT [PK_AUD_D] PRIMARY KEY CLUSTERED 
(
  [AUD_SEQ] ASC,
  [COLUMN_NAME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [jsharmony].[V_AUDL_RAW]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE VIEW [jsharmony].[V_AUDL_RAW]
AS
SELECT        AUD_H.AUD_SEQ,
              AUD_H.C_ID,
              AUD_H.E_ID,
              AUD_H.TABLE_NAME,
              AUD_H.TABLE_ID,
              AUD_H.AUD_OP,
              AUD_H.AUD_U,
        jsharmony.myCUSER_FMT(AUD_H.AUD_U) PE_Name,
        AUD_H.DB_K,
        AUD_H.AUD_Tstmp,
        AUD_H.REF_NAME,
        AUD_H.REF_ID,
        AUD_H.SUBJ,
              AUD_D.COLUMN_NAME, 
        AUD_D.COLUMN_VAL
FROM          jsharmony.AUD_H 
LEFT OUTER JOIN jsharmony.AUD_D ON AUD_H.AUD_SEQ = AUD_D.AUD_SEQ







GO
/****** Object:  View [jsharmony].[UCOD_XPP_PROCESS_V]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/****** Script for SelectTopNRows command from SSMS  ******/
create view [jsharmony].[UCOD_XPP_PROCESS_V] as
SELECT distinct
       NULL CODSEQ
      ,PPD_PROCESS CODEVAL
      ,PPD_PROCESS CODETXT
      ,NULL CODECODE
      ,NULL CODETDT
      ,NULL CODETCM
  FROM jsharmony.PPD
 where PPD_XPP = 1

GO
/****** Object:  View [jsharmony].[UCOD2_GPP_PROCESS_ATTRIB_V]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Script for SelectTopNRows command from SSMS  ******/
create view [jsharmony].[UCOD2_GPP_PROCESS_ATTRIB_V] as
SELECT NULL CODSEQ
      ,PPD_PROCESS CODEVAL1
      ,PPD_ATTRIB CODEVAL2
      ,PPD_DESC CODETXT
      ,NULL CODECODE
      ,NULL CODETDT
      ,NULL CODETCM
      ,NULL COD_ETstmp
      ,NULL COD_EU
      ,NULL COD_MTstmp
      ,NULL COD_MU
      ,NULL COD_SNotes
      ,NULL COD_Notes
  FROM jsharmony.PPD
 WHERE PPD_GPP = 1
GO
/****** Object:  View [jsharmony].[UCOD2_PPP_PROCESS_ATTRIB_V]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/****** Script for SelectTopNRows command from SSMS  ******/
create view [jsharmony].[UCOD2_PPP_PROCESS_ATTRIB_V] as
SELECT NULL CODSEQ
      ,PPD_PROCESS CODEVAL1
      ,PPD_ATTRIB CODEVAL2
      ,PPD_DESC CODETXT
      ,NULL CODECODE
      ,NULL CODETDT
      ,NULL CODETCM
      ,NULL COD_ETstmp
      ,NULL COD_EU
      ,NULL COD_MTstmp
      ,NULL COD_MU
      ,NULL COD_SNotes
      ,NULL COD_Notes
  FROM jsharmony.PPD
 WHERE PPD_PPP = 1

GO
/****** Object:  View [jsharmony].[UCOD2_XPP_PROCESS_ATTRIB_V]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/****** Script for SelectTopNRows command from SSMS  ******/
create view [jsharmony].[UCOD2_XPP_PROCESS_ATTRIB_V] as
SELECT NULL CODSEQ
      ,PPD_PROCESS CODEVAL1
      ,PPD_ATTRIB CODEVAL2
      ,PPD_DESC CODETXT
      ,NULL CODECODE
      ,NULL CODETDT
      ,NULL CODETCM
      ,NULL COD_ETstmp
      ,NULL COD_EU
      ,NULL COD_MTstmp
      ,NULL COD_MU
      ,NULL COD_SNotes
      ,NULL COD_Notes
  FROM jsharmony.PPD
 WHERE PPD_XPP = 1

GO
/****** Object:  Table [jsharmony].[SPER]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[SPER](
  [PE_ID] [bigint] NOT NULL,
  [SPER_SNotes] [nvarchar](255) NULL,
  [SPER_ID] [bigint] IDENTITY(1,1) NOT NULL,
  [SR_NAME] [nvarchar](16) NOT NULL,
 CONSTRAINT [PK_SPER] PRIMARY KEY CLUSTERED 
(
  [PE_ID] ASC,
  [SR_NAME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_SPER] UNIQUE NONCLUSTERED 
(
  [SPER_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [jsharmony].[V_MY_ROLES]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [jsharmony].[V_MY_ROLES] as
select SPER.SR_NAME
  from jsharmony.SPER
 where SPER.PE_ID = jsharmony.myPE()


GO
/****** Object:  Table [jsharmony].[NUMBERS]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[NUMBERS](
  [N] [smallint] NOT NULL,
 CONSTRAINT [PK_NUMBERS] PRIMARY KEY CLUSTERED 
(
  [N] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [jsharmony].[V_MONTHS]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






/****** Script for SelectTopNRows command from SSMS  ******/
CREATE view [jsharmony].[V_MONTHS] as
select N, 
       right('0'+convert(nvarchar(50),N),2) MONTH,
       right('0'+convert(nvarchar(50),N),2) MTH
  from jsharmony.NUMBERS
 where N <=12;





GO
/****** Object:  View [jsharmony].[V_YEARS]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




/****** Script for SelectTopNRows command from SSMS  ******/
CREATE view [jsharmony].[V_YEARS] as
select datepart(year,sysdatetime())+N-1 year,
       datepart(year,sysdatetime())+N-1 yr
  from jsharmony.NUMBERS
 where N <=10;



GO
/****** Object:  Table [jsharmony].[PPP]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[PPP](
  [PE_ID] [bigint] NOT NULL,
  [PPP_PROCESS] [nvarchar](32) NOT NULL,
  [PPP_ATTRIB] [nvarchar](16) NOT NULL,
  [PPP_VAL] [varchar](256) NULL,
  [PPP_ETstmp] [datetime2](7) NOT NULL,
  [PPP_EU] [nvarchar](20) NOT NULL,
  [PPP_MTstmp] [datetime2](7) NOT NULL,
  [PPP_MU] [nvarchar](20) NOT NULL,
  [PPP_ID] [bigint] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_PPP] PRIMARY KEY CLUSTERED 
(
  [PE_ID] ASC,
  [PPP_PROCESS] ASC,
  [PPP_ATTRIB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [jsharmony].[GPP]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[GPP](
  [GPP_PROCESS] [nvarchar](32) NOT NULL,
  [GPP_ATTRIB] [nvarchar](16) NOT NULL,
  [GPP_VAL] [varchar](256) NULL,
  [GPP_ETstmp] [datetime2](7) NOT NULL,
  [GPP_EU] [nvarchar](20) NOT NULL,
  [GPP_MTstmp] [datetime2](7) NOT NULL,
  [GPP_MU] [nvarchar](20) NOT NULL,
  [GPP_ID] [bigint] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_GPP] PRIMARY KEY CLUSTERED 
(
  [GPP_PROCESS] ASC,
  [GPP_ATTRIB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [jsharmony].[XPP]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[XPP](
  [XPP_PROCESS] [nvarchar](32) NOT NULL,
  [XPP_ATTRIB] [nvarchar](16) NOT NULL,
  [XPP_VAL] [varchar](256) NOT NULL,
  [XPP_ETstmp] [datetime2](7) NOT NULL,
  [XPP_EU] [nvarchar](20) NOT NULL,
  [XPP_MTstmp] [datetime2](7) NOT NULL,
  [XPP_MU] [nvarchar](20) NOT NULL,
  [XPP_ID] [bigint] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_XPP] PRIMARY KEY CLUSTERED 
(
  [XPP_PROCESS] ASC,
  [XPP_ATTRIB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [jsharmony].[V_PP]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [jsharmony].[V_PP] AS
 SELECT PPD.PPD_PROCESS AS PP_PROCESS, 
        PPD.PPD_ATTRIB AS PP_ATTRIB, 
    CASE WHEN PPP_VAL IS NULL OR PPP_VAL = '' 
         THEN CASE WHEN GPP_VAL IS NULL OR GPP_VAL = '' 
                 THEN XPP_VAL 
             ELSE GPP_VAL END 
       ELSE PPP_VAL END AS PP_VAL, 
    CASE WHEN PPP_VAL IS NULL OR PPP_VAL = '' 
         THEN CASE WHEN GPP_VAL IS NULL OR GPP_VAL = '' 
                 THEN 'XPP' 
             ELSE 'GPP' END 
       ELSE convert(varchar,PPP.PE_ID) END AS PP_SOURCE 
   FROM jsharmony.PPD 
   LEFT OUTER JOIN jsharmony.XPP ON PPD.PPD_PROCESS = XPP.XPP_PROCESS AND PPD.PPD_ATTRIB = XPP.XPP_ATTRIB 
   LEFT OUTER JOIN jsharmony.GPP ON PPD.PPD_PROCESS = GPP.GPP_PROCESS AND PPD.PPD_ATTRIB = GPP.GPP_ATTRIB 
   LEFT OUTER JOIN jsharmony.PPP ON PPD.PPD_PROCESS = PPP.PPP_PROCESS AND PPD.PPD_ATTRIB = PPP.PPP_ATTRIB AND PPP.PE_ID = jsharmony.myPE();




GO
/****** Object:  Table [jsharmony].[D]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[D](
  [D_ID] [bigint] IDENTITY(1,1) NOT NULL,
  [D_SCOPE] [nvarchar](8) NOT NULL,
  [D_SCOPE_ID] [bigint] NOT NULL,
  [C_ID] [bigint] NULL,
  [E_ID] [bigint] NULL,
  [D_STS] [nvarchar](8) NOT NULL,
  [D_CTGR] [nvarchar](8) NOT NULL,
  [D_Desc] [nvarchar](255) NULL,
  [D_EXT] [nvarchar](16) NULL,
  [D_SIZE] [bigint] NULL,
  [D_FileName]  AS (('D'+CONVERT([varchar](50),[D_ID],(0)))+isnull([D_EXT],'')) PERSISTED,
  [D_ETstmp] [datetime2](7) NOT NULL,
  [D_EU] [nvarchar](20) NOT NULL,
  [D_MTstmp] [datetime2](7) NOT NULL,
  [D_MU] [nvarchar](20) NOT NULL,
  [D_UTstmp] [datetime2](7) NOT NULL,
  [D_UU] [nvarchar](20) NOT NULL,
  [D_SYNCTstmp] [datetime2](7) NULL,
  [D_SNotes] [nvarchar](255) NULL,
  [D_ID_MAIN] [bigint] NULL,
 CONSTRAINT [PK_D] PRIMARY KEY CLUSTERED 
(
  [D_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [jsharmony].[V_D_X]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Script for SelectTopNRows command from SSMS  ******/
create view [jsharmony].[V_D_X] as
SELECT D_ID
      ,D_SCOPE
      ,D_SCOPE_ID
      ,C_ID
      ,E_ID
      ,D_STS
      ,D_CTGR
      ,D_Desc
      ,D_EXT
      ,D_SIZE
      ,D_FileName
      ,D_ETstmp
      ,D_EU
      ,D_MTstmp
      ,D_MU
      ,D_UTstmp
      ,D_UU
      ,D_SYNCTstmp
      ,D_SNotes
      ,D_ID_MAIN
  FROM jsharmony.D
GO
/****** Object:  Table [jsharmony].[DUAL]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[DUAL](
  [DUMMY] [nvarchar](1) NOT NULL,
  [DUAL_IDENT] [bigint] IDENTITY(1,1) NOT NULL,
  [DUAL_BIGINT] [bigint] NULL,
  [DUAL_NVARCHAR50] [nvarchar](50) NULL,
 CONSTRAINT [PK_DUAL] PRIMARY KEY CLUSTERED 
(
  [DUAL_IDENT] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [jsharmony].[V_HOUSE]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





create view [jsharmony].[V_HOUSE] as
select NAME.PP_VAL HOUSE_NAME,
       ADDR.PP_VAL HOUSE_ADDR,
     CITY.PP_VAL HOUSE_CITY,
     [STATE].PP_VAL HOUSE_STATE,
     ZIP.PP_VAL HOUSE_ZIP,
       isnull(ADDR.PP_VAL,'')+', '+isnull(CITY.PP_VAL,'')+' '+isnull([STATE].PP_VAL,'')+' '+isnull(ZIP.PP_VAL,'') HOUSE_FULL_ADDR,
     BPHONE.PP_VAL HOUSE_BPHONE,
     FAX.PP_VAL HOUSE_FAX,
     EMAIL.PP_VAL HOUSE_EMAIL,
     CONTACT.PP_VAL HOUSE_CONTACT
  from dual
 left outer join jsharmony.V_PP NAME on NAME.PP_PROCESS='HOUSE' and NAME.PP_ATTRIB='NAME'
 left outer join jsharmony.V_PP ADDR on ADDR.PP_PROCESS='HOUSE' and ADDR.PP_ATTRIB='ADDR'
 left outer join jsharmony.V_PP CITY on CITY.PP_PROCESS='HOUSE' and CITY.PP_ATTRIB='CITY'
 left outer join jsharmony.V_PP [STATE] on[STATE].PP_PROCESS='HOUSE' and [STATE].PP_ATTRIB='STATE'
 left outer join jsharmony.V_PP ZIP on ZIP.PP_PROCESS='HOUSE' and ZIP.PP_ATTRIB='ZIP'
 left outer join jsharmony.V_PP BPHONE on BPHONE.PP_PROCESS='HOUSE' and BPHONE.PP_ATTRIB='BPHONE'
 left outer join jsharmony.V_PP FAX on FAX.PP_PROCESS='HOUSE' and FAX.PP_ATTRIB='FAX'
 left outer join jsharmony.V_PP EMAIL on EMAIL.PP_PROCESS='HOUSE' and EMAIL.PP_ATTRIB='EMAIL'
 left outer join jsharmony.V_PP CONTACT on CONTACT.PP_PROCESS='HOUSE' and CONTACT.PP_ATTRIB='CONTACT'




GO
/****** Object:  Table [jsharmony].[CRM]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[CRM](
  [SM_ID] [bigint] NOT NULL,
  [CRM_SNotes] [nvarchar](255) NULL,
  [CRM_ID] [bigint] IDENTITY(1,1) NOT NULL,
  [CR_NAME] [nvarchar](16) NOT NULL,
 CONSTRAINT [PK_CRM] PRIMARY KEY CLUSTERED 
(
  [CR_NAME] ASC,
  [SM_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_CRM] UNIQUE NONCLUSTERED 
(
  [CRM_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [jsharmony].[CR]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[CR](
  [CR_ID] [bigint] IDENTITY(1,1) NOT NULL,
  [CR_SEQ] [smallint] NULL,
  [CR_STS] [nvarchar](8) NOT NULL,
  [CR_Name] [nvarchar](16) NOT NULL,
  [CR_Desc] [nvarchar](255) NOT NULL,
  [CR_CODE] [nvarchar](50) NULL,
  [CR_ATTRIB] [nvarchar](50) NULL,
  [CR_SNotes] [nvarchar](255) NULL,
 CONSTRAINT [PK_CR] PRIMARY KEY CLUSTERED 
(
  [CR_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_CR_CR_Desc] UNIQUE NONCLUSTERED 
(
  [CR_Desc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_CR_CR_ID] UNIQUE NONCLUSTERED 
(
  [CR_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [jsharmony].[SM]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[SM](
  [SM_ID_AUTO] [bigint] IDENTITY(1,1) NOT NULL,
  [SM_UTYPE] [char](1) NOT NULL,
  [SM_ID] [bigint] NOT NULL,
  [SM_STS] [nvarchar](8) NOT NULL,
  [SM_ID_Parent] [bigint] NULL,
  [SM_Name] [nvarchar](30) NOT NULL,
  [SM_Seq] [int] NULL,
  [SM_DESC] [nvarchar](255) NOT NULL,
  [SM_DESCL] [nvarchar](max) NULL,
  [SM_DESCVL] [nvarchar](max) NULL,
  [SM_Cmd] [varchar](255) NULL,
  [SM_Image] [nvarchar](255) NULL,
  [SM_SNotes] [nvarchar](255) NULL,
  [SM_SubCmd] [varchar](255) NULL,
 CONSTRAINT [PK_SM] PRIMARY KEY CLUSTERED 
(
  [SM_ID_AUTO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_SM_SM_DESC] UNIQUE NONCLUSTERED 
(
  [SM_ID_Parent] ASC,
  [SM_DESC] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_SM_SM_ID] UNIQUE NONCLUSTERED 
(
  [SM_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_SM_SM_NAME] UNIQUE NONCLUSTERED 
(
  [SM_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [jsharmony].[V_CRMSEL]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [jsharmony].[V_CRMSEL]
AS
SELECT jsharmony.CRM.CRM_ID, 
       ISNULL(jsharmony.DUAL.DUAL_NVARCHAR50, '') AS NEW_CR_NAME, 
     CASE WHEN CRM.CRM_ID IS NULL 
          THEN 0 
      ELSE 1 END AS CRMSEL_SEL, 
     M.CR_Name, 
     M.SM_ID_AUTO, 
     M.SM_UTYPE, 
       M.SM_ID, 
     M.SM_STS, 
     M.SM_ID_Parent, 
     M.SM_Name, 
     M.SM_Seq, 
     M.SM_DESC, 
     M.SM_DESCL, 
     M.SM_DESCVL, 
     M.SM_Cmd, 
     M.SM_Image, 
     M.SM_SNotes,
     M.SM_SubCmd
  FROM (SELECT jsharmony.CR.CR_Name, 
               jsharmony.SM.SM_ID_AUTO, 
         jsharmony.SM.SM_UTYPE, 
         jsharmony.SM.SM_ID, 
         jsharmony.SM.SM_STS, 
         jsharmony.SM.SM_ID_Parent, 
         jsharmony.SM.SM_Name, 
               jsharmony.SM.SM_Seq, 
         jsharmony.SM.SM_DESC, 
         jsharmony.SM.SM_DESCL, 
         jsharmony.SM.SM_DESCVL, 
         jsharmony.SM.SM_Cmd, 
         jsharmony.SM.SM_Image, 
         jsharmony.SM.SM_SNotes, 
               jsharmony.SM.SM_SubCmd
          FROM jsharmony.CR 
      LEFT OUTER JOIN jsharmony.SM ON jsharmony.SM.SM_UTYPE = 'C') AS M 
 INNER JOIN jsharmony.DUAL ON 1 = 1 
  LEFT OUTER JOIN jsharmony.CRM ON jsharmony.CRM.CR_NAME = M.CR_Name AND jsharmony.CRM.SM_ID = M.SM_ID;




GO
/****** Object:  Table [jsharmony].[CPER]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[CPER](
  [PE_ID] [bigint] NOT NULL,
  [CPER_SNotes] [nvarchar](255) NULL,
  [CPER_ID] [bigint] IDENTITY(1,1) NOT NULL,
  [CR_NAME] [nvarchar](16) NOT NULL,
 CONSTRAINT [PK_CPER] PRIMARY KEY CLUSTERED 
(
  [PE_ID] ASC,
  [CR_NAME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_CPER] UNIQUE NONCLUSTERED 
(
  [CPER_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [jsharmony].[V_CPER_NOSTAR]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [jsharmony].[V_CPER_NOSTAR] as
select *
  from jsharmony.CPER
 where CR_NAME <> 'C*';

GO
/****** Object:  Table [jsharmony].[SR]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[SR](
  [SR_ID] [bigint] IDENTITY(1,1) NOT NULL,
  [SR_SEQ] [smallint] NOT NULL,
  [SR_STS] [nvarchar](8) NOT NULL,
  [SR_Name] [nvarchar](16) NOT NULL,
  [SR_Desc] [nvarchar](255) NOT NULL,
  [SR_CODE] [nvarchar](50) NULL,
  [SR_ATTRIB] [nvarchar](50) NULL,
  [SR_SNotes] [nvarchar](255) NULL,
 CONSTRAINT [PK_SR] PRIMARY KEY CLUSTERED 
(
  [SR_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_SR_SR_Desc] UNIQUE NONCLUSTERED 
(
  [SR_Desc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_SR_SR_ID] UNIQUE NONCLUSTERED 
(
  [SR_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [jsharmony].[SRM]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[SRM](
  [SM_ID] [bigint] NOT NULL,
  [SRM_SNotes] [nvarchar](255) NULL,
  [SRM_ID] [bigint] IDENTITY(1,1) NOT NULL,
  [SR_NAME] [nvarchar](16) NOT NULL,
 CONSTRAINT [PK_SRM] PRIMARY KEY CLUSTERED 
(
  [SR_NAME] ASC,
  [SM_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_SRM] UNIQUE NONCLUSTERED 
(
  [SRM_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [jsharmony].[V_SRMSEL]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [jsharmony].[V_SRMSEL]
AS
SELECT jsharmony.SRM.SRM_ID, 
       ISNULL(jsharmony.DUAL.DUAL_NVARCHAR50, '') AS NEW_SR_NAME, 
     CASE WHEN SRM.SRM_ID IS NULL 
          THEN 0 
      ELSE 1 END AS SRMSEL_SEL, 
     M.SR_Name, 
     M.SM_ID_AUTO, 
     M.SM_UTYPE, 
       M.SM_ID, 
     M.SM_STS, 
     M.SM_ID_Parent, 
     M.SM_Name, 
     M.SM_Seq, 
     M.SM_DESC, 
     M.SM_DESCL, 
     M.SM_DESCVL, 
     M.SM_Cmd, 
     M.SM_Image, 
     M.SM_SNotes,
     M.SM_SubCmd
  FROM (SELECT jsharmony.SR.SR_Name, 
               jsharmony.SM.SM_ID_AUTO, 
         jsharmony.SM.SM_UTYPE, 
         jsharmony.SM.SM_ID, 
         jsharmony.SM.SM_STS, 
         jsharmony.SM.SM_ID_Parent, 
         jsharmony.SM.SM_Name, 
               jsharmony.SM.SM_Seq, 
         jsharmony.SM.SM_DESC, 
         jsharmony.SM.SM_DESCL, 
         jsharmony.SM.SM_DESCVL, 
         jsharmony.SM.SM_Cmd, 
         jsharmony.SM.SM_Image, 
         jsharmony.SM.SM_SNotes, 
               jsharmony.SM.SM_SubCmd
          FROM jsharmony.SR 
      LEFT OUTER JOIN jsharmony.SM ON jsharmony.SM.SM_UTYPE = 'S') AS M 
 INNER JOIN jsharmony.DUAL ON 1 = 1 
  LEFT OUTER JOIN jsharmony.SRM ON jsharmony.SRM.SR_NAME = M.SR_Name AND jsharmony.SRM.SM_ID = M.SM_ID;


GO
/****** Object:  View [jsharmony].[V_GPPL]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


































CREATE VIEW [jsharmony].[V_GPPL] AS
SELECT jsharmony.GPP.*,
       jsharmony.get_PPD_DESC(GPP_PROCESS, GPP_ATTRIB) PPD_DESC,
     jsharmony.audit_info(GPP_ETstmp, GPP_EU, GPP_MTstmp, GPP_MU) GPP_INFO







  FROM jsharmony.GPP;


















GO
/****** Object:  View [jsharmony].[V_PPPL]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


































CREATE VIEW [jsharmony].[V_PPPL] AS
SELECT PPP.*,
       jsharmony.get_PPD_DESC(PPP_PROCESS, PPP_ATTRIB) PPD_DESC,
     jsharmony.audit_info(PPP_ETstmp, PPP_EU, PPP_MTstmp, PPP_MU) PPP_INFO
  FROM jsharmony.PPP

















GO
/****** Object:  View [jsharmony].[V_XPPL]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


































CREATE VIEW [jsharmony].[V_XPPL] AS
SELECT XPP.*,
       jsharmony.get_PPD_DESC(XPP_PROCESS, XPP_ATTRIB) PPD_DESC,
     jsharmony.audit_info(XPP_ETstmp, XPP_EU, XPP_MTstmp, XPP_MU) XPP_INFO







  FROM jsharmony.XPP;


















GO
/****** Object:  View [jsharmony].[V_PPDL]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


































CREATE VIEW [jsharmony].[V_PPDL] AS
SELECT PPD.*,
     jsharmony.audit_info(PPD_ETstmp, PPD_EU, PPD_MTstmp, PPD_MU) PPD_INFO







  FROM jsharmony.PPD;


















GO
/****** Object:  View [jsharmony].[UCOD_GPP_PROCESS_V]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Script for SelectTopNRows command from SSMS  ******/
create view [jsharmony].[UCOD_GPP_PROCESS_V] as
SELECT distinct
       NULL CODSEQ
      ,PPD_PROCESS CODEVAL
      ,PPD_PROCESS CODETXT
      ,NULL CODECODE
      ,NULL CODETDT
      ,NULL CODETCM
  FROM jsharmony.PPD
 where PPD_GPP = 1
GO
/****** Object:  View [jsharmony].[V_MYPE]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [jsharmony].[V_MYPE] as
select jsharmony.myPE() MYPE
GO
/****** Object:  Table [jsharmony].[CPE]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ARITHABORT ON
GO
CREATE TABLE [jsharmony].[CPE](
  [PE_ID] [bigint] IDENTITY(200001,1) NOT NULL,
  [C_ID] [bigint] NOT NULL,
  [PE_STS] [nvarchar](8) NOT NULL,
  [PE_STSDt] [date] NOT NULL,
  [PE_FName] [nvarchar](35) NOT NULL,
  [PE_MName] [nvarchar](35) NULL,
  [PE_LName] [nvarchar](35) NOT NULL,
  [PE_JTitle] [nvarchar](35) NULL,
  [PE_BPhone] [nvarchar](30) NULL,
  [PE_CPhone] [nvarchar](30) NULL,
  [PE_Email] [nvarchar](255) NOT NULL,
  [PE_ETstmp] [datetime2](7) NOT NULL,
  [PE_EU] [nvarchar](20) NOT NULL,
  [PE_MTstmp] [datetime2](7) NOT NULL,
  [PE_MU] [nvarchar](20) NOT NULL,
  [PE_PW1] [nvarchar](255) NULL,
  [PE_PW2] [nvarchar](255) NULL,
  [PE_Hash] [varbinary](200) NOT NULL,
  [PE_LL_IP] [nvarchar](255) NULL,
  [PE_LL_Tstmp] [datetime2](7) NULL,
  [PE_SNotes] [nvarchar](255) NULL,
  [PE_Name]  AS (([PE_LName]+', ')+[PE_FName]) PERSISTED NOT NULL,
  [PE_UNQ_PE_Email]  AS (case when [PE_STS]='ACTIVE' then case when isnull([PE_Email],'')='' then 'E'+CONVERT([varchar](50),[PE_ID],(0)) else 'S'+[PE_Email] end else 'E'+CONVERT([varchar](50),[PE_ID],(0)) end) PERSISTED,
 CONSTRAINT [PK_CPE] PRIMARY KEY CLUSTERED 
(
  [PE_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_CPE_PE_Email] UNIQUE NONCLUSTERED 
(
  [PE_UNQ_PE_Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [jsharmony].[GCOD_H]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[GCOD_H](
  [CODENAME] [nvarchar](16) NOT NULL,
  [CODEMEAN] [nvarchar](128) NULL,
  [CODECODEMEAN] [nvarchar](128) NULL,
  [CODEATTRIBMEAN] [nvarchar](128) NULL,
  [COD_H_ETstmp] [datetime2](7) NULL,
  [COD_H_EU] [nvarchar](20) NULL,
  [COD_H_MTstmp] [datetime2](7) NULL,
  [COD_H_MU] [nvarchar](20) NULL,
  [COD_SNotes] [nvarchar](255) NULL,
  [CODESCHEMA] [nvarchar](16) NULL,
 CONSTRAINT [PK_GCOD_H] PRIMARY KEY CLUSTERED 
(
  [CODENAME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [jsharmony].[GCOD2_D_SCOPE_D_CTGR]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[GCOD2_D_SCOPE_D_CTGR](
  [GCOD2_ID] [bigint] IDENTITY(1,1) NOT NULL,
  [CODSEQ] [smallint] NULL,
  [CODEVAL1] [nvarchar](8) NOT NULL,
  [CODEVAL2] [nvarchar](8) NOT NULL,
  [CODETXT] [nvarchar](50) NULL,
  [CODECODE] [nvarchar](50) NULL,
  [CODEATTRIB] [nvarchar](50) NULL,
  [CODETDT] [datetime2](7) NULL,
  [CODETCM] [nvarchar](50) NULL,
  [COD_ETstmp] [datetime2](7) NULL,
  [COD_EU] [nvarchar](20) NULL,
  [COD_MTstmp] [datetime2](7) NULL,
  [COD_MU] [nvarchar](20) NULL,
  [COD_SNotes] [nvarchar](255) NULL,
  [COD_Notes] [nvarchar](255) NULL,
  [COD_EU_FMT]  AS ([jsharmony].[myCUSER_FMT]([COD_EU])),
  [COD_MU_FMT]  AS ([jsharmony].[myCUSER_FMT]([COD_MU])),
 CONSTRAINT [PK_GCOD2_D_SCOPE_D_CTGR] PRIMARY KEY CLUSTERED 
(
  [GCOD2_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_GCOD2_D_SCOPE_D_CTGR] UNIQUE NONCLUSTERED 
(
  [CODEVAL1] ASC,
  [CODEVAL2] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [jsharmony].[GCOD2_H]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[GCOD2_H](
  [CODENAME] [nvarchar](16) NOT NULL,
  [CODEMEAN] [nvarchar](128) NULL,
  [CODECODEMEAN] [nvarchar](128) NULL,
  [CODEATTRIBMEAN] [nvarchar](128) NULL,
  [COD_H_ETstmp] [datetime2](7) NULL,
  [COD_H_EU] [nvarchar](20) NULL,
  [COD_H_MTstmp] [datetime2](7) NULL,
  [COD_H_MU] [nvarchar](20) NULL,
  [COD_SNotes] [nvarchar](255) NULL,
  [CODESCHEMA] [nvarchar](16) NULL,
 CONSTRAINT [PK_GCOD2_H] PRIMARY KEY CLUSTERED 
(
  [CODENAME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [jsharmony].[H]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ARITHABORT ON
GO
CREATE TABLE [jsharmony].[H](
  [H_ID] [bigint] IDENTITY(1,1) NOT NULL,
  [HP_CODE] [varchar](50) NULL,
  [H_Title] [nvarchar](70) NOT NULL,
  [H_Text] [nvarchar](max) NOT NULL,
  [H_ETstmp] [datetime2](7) NOT NULL,
  [H_EU] [nvarchar](20) NOT NULL,
  [H_MTstmp] [datetime2](7) NOT NULL,
  [H_MU] [nvarchar](20) NOT NULL,
  [H_UNIQUE]  AS (case when [HP_CODE] IS NOT NULL then 'X'+[HP_CODE] else 'Y'+CONVERT([varchar](50),[H_ID],(0)) end) PERSISTED,
  [H_SEQ] [int] NULL,
  [H_INDEX_A] [bit] NOT NULL,
  [H_INDEX_P] [bit] NOT NULL,
 CONSTRAINT [PK_H] PRIMARY KEY CLUSTERED 
(
  [H_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_H_H_Title] UNIQUE NONCLUSTERED 
(
  [H_Title] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_H_H_UNIQUE] UNIQUE NONCLUSTERED 
(
  [H_UNIQUE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [jsharmony].[HP]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[HP](
  [HP_CODE] [varchar](50) NOT NULL,
  [HP_Desc] [nvarchar](50) NOT NULL,
  [HP_ID] [bigint] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_HP] PRIMARY KEY CLUSTERED 
(
  [HP_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_HP_HP_Desc] UNIQUE NONCLUSTERED 
(
  [HP_Desc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_HP_HP_ID] UNIQUE NONCLUSTERED 
(
  [HP_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [jsharmony].[N]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[N](
  [N_ID] [bigint] IDENTITY(1,1) NOT NULL,
  [N_SCOPE] [nvarchar](8) NOT NULL,
  [N_SCOPE_ID] [bigint] NOT NULL,
  [N_STS] [nvarchar](8) NOT NULL,
  [C_ID] [bigint] NULL,
  [E_ID] [bigint] NULL,
  [N_TYPE] [nvarchar](8) NULL,
  [N_Note] [nvarchar](max) NOT NULL,
  [N_ETstmp] [datetime2](7) NOT NULL,
  [N_EU] [nvarchar](20) NOT NULL,
  [N_MTstmp] [datetime2](7) NOT NULL,
  [N_MU] [nvarchar](20) NOT NULL,
  [N_SYNCTstmp] [datetime2](7) NULL,
  [N_Snotes] [nvarchar](255) NULL,
  [N_ID_MAIN] [bigint] NULL,
 CONSTRAINT [PK_N] PRIMARY KEY CLUSTERED 
(
  [N_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [jsharmony].[PE]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ARITHABORT ON
GO
CREATE TABLE [jsharmony].[PE](
  [PE_ID] [bigint] IDENTITY(1,1) NOT NULL,
  [PE_STS] [nvarchar](8) NOT NULL,
  [PE_STSDt] [date] NOT NULL,
  [PE_FName] [nvarchar](35) NOT NULL,
  [PE_MName] [nvarchar](35) NULL,
  [PE_LName] [nvarchar](35) NOT NULL,
  [PE_JTitle] [nvarchar](35) NULL,
  [PE_BPhone] [nvarchar](30) NULL,
  [PE_CPhone] [nvarchar](30) NULL,
  [PE_COUNTRY] [nvarchar](8) NOT NULL,
  [PE_ADDR] [nvarchar](200) NULL,
  [PE_CITY] [nvarchar](50) NULL,
  [PE_STATE] [nvarchar](8) NULL,
  [PE_ZIP] [nvarchar](20) NULL,
  [PE_EMAIL] [nvarchar](255) NOT NULL,
  [PE_STARTDT] [date] NOT NULL,
  [PE_ENDDT] [date] NULL,
  [PE_UNOTES] [nvarchar](4000) NULL,
  [PE_ETstmp] [datetime2](7) NOT NULL,
  [PE_EU] [nvarchar](20) NOT NULL,
  [PE_MTstmp] [datetime2](7) NOT NULL,
  [PE_MU] [nvarchar](20) NOT NULL,
  [PE_PW1] [nvarchar](255) NULL,
  [PE_PW2] [nvarchar](255) NULL,
  [PE_Hash] [varbinary](200) NOT NULL,
  [PE_LL_IP] [nvarchar](255) NULL,
  [PE_LL_Tstmp] [datetime2](7) NULL,
  [PE_SNotes] [nvarchar](255) NULL,
  [PE_Name]  AS (([PE_LName]+', ')+[PE_FName]) PERSISTED NOT NULL,
  [PE_Initials]  AS ((isnull(substring([PE_FName],(1),(1)),'')+isnull(substring([PE_MName],(1),(1)),''))+isnull(substring([PE_LName],(1),(1)),'')) PERSISTED NOT NULL,
  [PE_UNQ_PE_Email]  AS (case when [PE_STS]='ACTIVE' then case when isnull([PE_Email],'')='' then 'E'+CONVERT([varchar](50),[PE_ID],(0)) else 'S'+[PE_Email] end else 'E'+CONVERT([varchar](50),[PE_ID],(0)) end) PERSISTED,
 CONSTRAINT [PK_PE] PRIMARY KEY CLUSTERED 
(
  [PE_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_PE_PE_Email] UNIQUE NONCLUSTERED 
(
  [PE_UNQ_PE_Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [jsharmony].[RQ]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[RQ](
  [RQ_ID] [bigint] IDENTITY(1,1) NOT NULL,
  [RQ_ETstmp] [datetime2](7) NOT NULL,
  [RQ_EU] [nvarchar](20) NOT NULL,
  [RQ_NAME] [nvarchar](255) NOT NULL,
  [RQ_MESSAGE] [nvarchar](max) NOT NULL,
  [RQ_RSLT] [nvarchar](8) NULL,
  [RQ_RSLT_TStmp] [datetime2](7) NULL,
  [RQ_RSLT_U] [nvarchar](20) NULL,
  [RQ_SNotes] [nvarchar](max) NULL,
 CONSTRAINT [PK_RQ] PRIMARY KEY CLUSTERED 
(
  [RQ_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [jsharmony].[RQST]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[RQST](
  [RQST_ID] [bigint] IDENTITY(1,1) NOT NULL,
  [RQST_ETstmp] [datetime2](7) NOT NULL,
  [RQST_EU] [nvarchar](20) NOT NULL,
  [RQST_SOURCE] [nvarchar](8) NOT NULL,
  [RQST_ATYPE] [nvarchar](8) NOT NULL,
  [RQST_ANAME] [nvarchar](50) NOT NULL,
  [RQST_PARMS] [nvarchar](max) NULL,
  [RQST_IDENT] [nvarchar](255) NULL,
  [RQST_RSLT] [nvarchar](8) NULL,
  [RQST_RSLT_TStmp] [datetime2](7) NULL,
  [RQST_RSLT_U] [nvarchar](20) NULL,
  [RQST_SNotes] [nvarchar](max) NULL,
 CONSTRAINT [PK_RQST] PRIMARY KEY CLUSTERED 
(
  [RQST_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [jsharmony].[RQST_D]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[RQST_D](
  [RQST_D_ID] [bigint] IDENTITY(1,1) NOT NULL,
  [RQST_ID] [bigint] NOT NULL,
  [D_SCOPE] [nvarchar](8) NULL,
  [D_SCOPE_ID] [bigint] NULL,
  [D_CTGR] [nvarchar](8) NULL,
  [D_Desc] [nvarchar](255) NULL,
 CONSTRAINT [PK_RQST_D] PRIMARY KEY CLUSTERED 
(
  [RQST_D_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [jsharmony].[RQST_EMAIL]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[RQST_EMAIL](
  [RQST_EMAIL_ID] [bigint] IDENTITY(1,1) NOT NULL,
  [RQST_ID] [bigint] NOT NULL,
  [EMAIL_TXT_ATTRIB] [nvarchar](32) NULL,
  [EMAIL_TO] [nvarchar](255) NOT NULL,
  [EMAIL_CC] [nvarchar](255) NULL,
  [EMAIL_BCC] [nvarchar](255) NULL,
  [EMAIL_ATTACH] [smallint] NULL,
  [EMAIL_SUBJECT] [nvarchar](500) NULL,
  [EMAIL_TEXT] [ntext] NULL,
  [EMAIL_HTML] [ntext] NULL,
  [EMAIL_D_ID] [bigint] NULL,
 CONSTRAINT [PK_RQST_EMAIL] PRIMARY KEY CLUSTERED 
(
  [RQST_EMAIL_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [jsharmony].[RQST_N]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[RQST_N](
  [RQST_N_ID] [bigint] IDENTITY(1,1) NOT NULL,
  [RQST_ID] [bigint] NOT NULL,
  [N_SCOPE] [nvarchar](8) NULL,
  [N_SCOPE_ID] [bigint] NULL,
  [N_TYPE] [nvarchar](8) NULL,
  [N_Note] [nvarchar](max) NULL,
 CONSTRAINT [PK_RQST_N] PRIMARY KEY CLUSTERED 
(
  [RQST_N_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [jsharmony].[RQST_RQ]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[RQST_RQ](
  [RQST_RQ_ID] [bigint] IDENTITY(1,1) NOT NULL,
  [RQST_ID] [bigint] NOT NULL,
  [RQ_NAME] [nvarchar](255) NOT NULL,
  [RQ_MESSAGE] [nvarchar](max) NULL,
 CONSTRAINT [PK_RQST_RQ] PRIMARY KEY CLUSTERED 
(
  [RQST_RQ_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [jsharmony].[RQST_SMS]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[RQST_SMS](
  [RQST_SMS_ID] [bigint] IDENTITY(1,1) NOT NULL,
  [RQST_ID] [bigint] NOT NULL,
  [SMS_TXT_ATTRIB] [nvarchar](32) NULL,
  [SMS_TO] [nvarchar](255) NOT NULL,
  [SMS_BODY] [ntext] NULL,
 CONSTRAINT [PK_RQST_SMS] PRIMARY KEY CLUSTERED 
(
  [RQST_SMS_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [jsharmony].[SCRIPT]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[SCRIPT](
  [SCRIPT_NAME] [nvarchar](32) NOT NULL,
  [SCRIPT_TXT] [nvarchar](max) NULL,
 CONSTRAINT [PK_SCRIPT] PRIMARY KEY CLUSTERED 
(
  [SCRIPT_NAME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [jsharmony].[SF]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[SF](
  [SF_ID] [bigint] IDENTITY(1,1) NOT NULL,
  [SF_SEQ] [smallint] NOT NULL,
  [SF_STS] [nvarchar](8) NOT NULL,
  [SF_Name] [nvarchar](16) NOT NULL,
  [SF_Desc] [nvarchar](255) NOT NULL,
  [SF_CODE] [nvarchar](50) NULL,
  [SF_ATTRIB] [nvarchar](50) NULL,
  [SF_SNotes] [nvarchar](255) NULL,
 CONSTRAINT [PK_SF] PRIMARY KEY CLUSTERED 
(
  [SF_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_SF_SF_CODE_SF_NAME] UNIQUE NONCLUSTERED 
(
  [SF_CODE] ASC,
  [SF_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_SF_SF_Desc] UNIQUE NONCLUSTERED 
(
  [SF_Desc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_SF_SF_ID] UNIQUE NONCLUSTERED 
(
  [SF_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [jsharmony].[SPEF]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[SPEF](
  [PE_ID] [bigint] NOT NULL,
  [SPEF_SNotes] [nvarchar](255) NULL,
  [SPEF_ID] [bigint] IDENTITY(1,1) NOT NULL,
  [SF_NAME] [nvarchar](16) NOT NULL,
 CONSTRAINT [PK_SPEF] PRIMARY KEY CLUSTERED 
(
  [PE_ID] ASC,
  [SF_NAME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_SPEF] UNIQUE NONCLUSTERED 
(
  [SPEF_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [jsharmony].[TXT]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[TXT](
  [TXT_PROCESS] [nvarchar](32) NOT NULL,
  [TXT_ATTRIB] [nvarchar](32) NOT NULL,
  [TXT_TYPE] [nvarchar](8) NOT NULL,
  [TXT_TVAL] [nvarchar](max) NULL,
  [TXT_VAL] [nvarchar](max) NULL,
  [TXT_BCC] [nvarchar](255) NULL,
  [TXT_Desc] [nvarchar](255) NULL,
  [TXT_ID] [bigint] IDENTITY(1,1) NOT NULL,
  [TXT_ETstmp] [datetime2](7) NOT NULL,
  [TXT_EU] [varchar](64) NOT NULL,
  [TXT_MTstmp] [datetime2](7) NOT NULL,
  [TXT_MU] [varchar](64) NOT NULL,
 CONSTRAINT [PK_TXT] PRIMARY KEY CLUSTERED 
(
  [TXT_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_TXT] UNIQUE NONCLUSTERED 
(
  [TXT_PROCESS] ASC,
  [TXT_ATTRIB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [jsharmony].[UCOD_AC]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[UCOD_AC](
  [UCOD_ID] [bigint] IDENTITY(1,1) NOT NULL,
  [CODSEQ] [smallint] NULL,
  [CODEVAL] [nvarchar](8) NOT NULL,
  [CODETXT] [nvarchar](50) NULL,
  [CODECODE] [nvarchar](50) NULL,
  [CODETDT] [datetime2](7) NULL,
  [CODETCM] [nvarchar](50) NULL,
  [COD_ETstmp] [datetime2](7) NULL,
  [COD_EU] [nvarchar](20) NULL,
  [COD_MTstmp] [datetime2](7) NULL,
  [COD_MU] [nvarchar](20) NULL,
  [COD_SNotes] [nvarchar](255) NULL,
  [COD_Notes] [nvarchar](255) NULL,
  [CODEATTRIB] [nvarchar](50) NULL,
 CONSTRAINT [PK_UCOD_AC] PRIMARY KEY CLUSTERED 
(
  [CODEVAL] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_UCOD_AC] UNIQUE NONCLUSTERED 
(
  [UCOD_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [jsharmony].[UCOD_AC1]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[UCOD_AC1](
  [UCOD_ID] [bigint] IDENTITY(1,1) NOT NULL,
  [CODSEQ] [smallint] NULL,
  [CODEVAL] [nvarchar](8) NOT NULL,
  [CODETXT] [nvarchar](50) NULL,
  [CODECODE] [nvarchar](50) NULL,
  [CODETDT] [datetime2](7) NULL,
  [CODETCM] [nvarchar](50) NULL,
  [COD_ETstmp] [datetime2](7) NULL,
  [COD_EU] [nvarchar](20) NULL,
  [COD_MTstmp] [datetime2](7) NULL,
  [COD_MU] [nvarchar](20) NULL,
  [COD_SNotes] [nvarchar](255) NULL,
  [COD_Notes] [nvarchar](255) NULL,
  [CODEATTRIB] [nvarchar](50) NULL,
 CONSTRAINT [PK_UCOD_AC1] PRIMARY KEY CLUSTERED 
(
  [CODEVAL] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_UCOD_AC1] UNIQUE NONCLUSTERED 
(
  [UCOD_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [jsharmony].[UCOD_AHC]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[UCOD_AHC](
  [UCOD_ID] [bigint] IDENTITY(1,1) NOT NULL,
  [CODSEQ] [smallint] NULL,
  [CODEVAL] [nvarchar](8) NOT NULL,
  [CODETXT] [nvarchar](50) NULL,
  [CODECODE] [nvarchar](50) NULL,
  [CODETDT] [datetime2](7) NULL,
  [CODETCM] [nvarchar](50) NULL,
  [COD_ETstmp] [datetime2](7) NULL,
  [COD_EU] [nvarchar](20) NULL,
  [COD_MTstmp] [datetime2](7) NULL,
  [COD_MU] [nvarchar](20) NULL,
  [COD_SNotes] [nvarchar](255) NULL,
  [COD_Notes] [nvarchar](255) NULL,
  [CODEATTRIB] [nvarchar](50) NULL,
 CONSTRAINT [PK_UCOD_AHC] PRIMARY KEY CLUSTERED 
(
  [CODEVAL] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_UCOD_AHC] UNIQUE NONCLUSTERED 
(
  [UCOD_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [jsharmony].[UCOD_COUNTRY]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[UCOD_COUNTRY](
  [UCOD_ID] [bigint] IDENTITY(1,1) NOT NULL,
  [CODSEQ] [smallint] NULL,
  [CODEVAL] [nvarchar](8) NOT NULL,
  [CODETXT] [nvarchar](50) NULL,
  [CODECODE] [nvarchar](50) NULL,
  [CODETDT] [datetime2](7) NULL,
  [CODETCM] [nvarchar](50) NULL,
  [COD_ETstmp] [datetime2](7) NULL,
  [COD_EU] [nvarchar](20) NULL,
  [COD_MTstmp] [datetime2](7) NULL,
  [COD_MU] [nvarchar](20) NULL,
  [COD_SNotes] [nvarchar](255) NULL,
  [COD_Notes] [nvarchar](255) NULL,
  [CODEATTRIB] [nvarchar](50) NULL,
 CONSTRAINT [PK_UCOD_COUNTRY] PRIMARY KEY CLUSTERED 
(
  [CODEVAL] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_UCOD_COUNTRY] UNIQUE NONCLUSTERED 
(
  [UCOD_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [jsharmony].[UCOD_D_SCOPE]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[UCOD_D_SCOPE](
  [UCOD_ID] [bigint] IDENTITY(1,1) NOT NULL,
  [CODSEQ] [smallint] NULL,
  [CODEVAL] [nvarchar](8) NOT NULL,
  [CODETXT] [nvarchar](50) NULL,
  [CODECODE] [nvarchar](50) NULL,
  [CODETDT] [datetime2](7) NULL,
  [CODETCM] [nvarchar](50) NULL,
  [COD_ETstmp] [datetime2](7) NULL,
  [COD_EU] [nvarchar](20) NULL,
  [COD_MTstmp] [datetime2](7) NULL,
  [COD_MU] [nvarchar](20) NULL,
  [COD_SNotes] [nvarchar](255) NULL,
  [COD_Notes] [nvarchar](255) NULL,
  [CODEATTRIB] [nvarchar](50) NULL,
 CONSTRAINT [PK_UCOD_SCOPE] PRIMARY KEY CLUSTERED 
(
  [CODEVAL] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_UCOD_SCOPE] UNIQUE NONCLUSTERED 
(
  [UCOD_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [jsharmony].[UCOD_H]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[UCOD_H](
  [CODENAME] [nvarchar](16) NOT NULL,
  [CODEMEAN] [nvarchar](128) NULL,
  [CODECODEMEAN] [nvarchar](128) NULL,
  [CODEATTRIBMEAN] [nvarchar](128) NULL,
  [COD_H_CODECODE_DESC] [nvarchar](150) NULL,
  [COD_H_ETstmp] [datetime2](7) NULL,
  [COD_H_EU] [nvarchar](20) NULL,
  [COD_H_MTstmp] [datetime2](7) NULL,
  [COD_H_MU] [nvarchar](20) NULL,
  [COD_SNotes] [nvarchar](255) NULL,
  [CODESCHEMA] [nvarchar](16) NULL,
  [UCOD_H_ID] [bigint] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_UCOD_H] PRIMARY KEY CLUSTERED 
(
  [UCOD_H_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_UCOD_H] UNIQUE NONCLUSTERED 
(
  [CODESCHEMA] ASC,
  [CODENAME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [jsharmony].[UCOD_N_SCOPE]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[UCOD_N_SCOPE](
  [UCOD_ID] [bigint] IDENTITY(1,1) NOT NULL,
  [CODSEQ] [smallint] NULL,
  [CODEVAL] [nvarchar](8) NOT NULL,
  [CODETXT] [nvarchar](50) NULL,
  [CODECODE] [nvarchar](50) NULL,
  [CODETDT] [datetime2](7) NULL,
  [CODETCM] [nvarchar](50) NULL,
  [COD_ETstmp] [datetime2](7) NULL,
  [COD_EU] [nvarchar](20) NULL,
  [COD_MTstmp] [datetime2](7) NULL,
  [COD_MU] [nvarchar](20) NULL,
  [COD_SNotes] [nvarchar](255) NULL,
  [COD_Notes] [nvarchar](255) NULL,
  [CODEATTRIB] [nvarchar](50) NULL,
 CONSTRAINT [PK_UCON_SCOPE] PRIMARY KEY CLUSTERED 
(
  [CODEVAL] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_UCON_SCOPE] UNIQUE NONCLUSTERED 
(
  [UCOD_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [jsharmony].[UCOD_N_TYPE]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[UCOD_N_TYPE](
  [UCOD_ID] [bigint] IDENTITY(1,1) NOT NULL,
  [CODSEQ] [smallint] NULL,
  [CODEVAL] [nvarchar](8) NOT NULL,
  [CODETXT] [nvarchar](50) NULL,
  [CODECODE] [nvarchar](50) NULL,
  [CODETDT] [datetime2](7) NULL,
  [CODETCM] [nvarchar](50) NULL,
  [COD_ETstmp] [datetime2](7) NULL,
  [COD_EU] [nvarchar](20) NULL,
  [COD_MTstmp] [datetime2](7) NULL,
  [COD_MU] [nvarchar](20) NULL,
  [COD_SNotes] [nvarchar](255) NULL,
  [COD_Notes] [nvarchar](255) NULL,
  [CODEATTRIB] [nvarchar](50) NULL,
 CONSTRAINT [PK_UCOD_N_TYPE] PRIMARY KEY CLUSTERED 
(
  [CODEVAL] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_UCOD_N_TYPE] UNIQUE NONCLUSTERED 
(
  [UCOD_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [jsharmony].[UCOD_PPD_TYPE]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[UCOD_PPD_TYPE](
  [UCOD_ID] [bigint] IDENTITY(1,1) NOT NULL,
  [CODSEQ] [smallint] NULL,
  [CODEVAL] [nvarchar](8) NOT NULL,
  [CODETXT] [nvarchar](50) NULL,
  [CODECODE] [nvarchar](50) NULL,
  [CODETDT] [datetime2](7) NULL,
  [CODETCM] [nvarchar](50) NULL,
  [COD_ETstmp] [datetime2](7) NULL,
  [COD_EU] [nvarchar](20) NULL,
  [COD_MTstmp] [datetime2](7) NULL,
  [COD_MU] [nvarchar](20) NULL,
  [COD_SNotes] [nvarchar](255) NULL,
  [COD_Notes] [nvarchar](255) NULL,
  [CODEATTRIB] [nvarchar](50) NULL,
 CONSTRAINT [PK_UCOD_PPD_TYPE] PRIMARY KEY CLUSTERED 
(
  [CODEVAL] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_UCOD_PPD_TYPE] UNIQUE NONCLUSTERED 
(
  [UCOD_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [jsharmony].[UCOD_RQST_ATYPE]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[UCOD_RQST_ATYPE](
  [UCOD_ID] [bigint] IDENTITY(1,1) NOT NULL,
  [CODSEQ] [smallint] NULL,
  [CODEVAL] [nvarchar](8) NOT NULL,
  [CODETXT] [nvarchar](50) NULL,
  [CODECODE] [nvarchar](50) NULL,
  [CODETDT] [datetime2](7) NULL,
  [CODETCM] [nvarchar](50) NULL,
  [COD_ETstmp] [datetime2](7) NULL,
  [COD_EU] [nvarchar](20) NULL,
  [COD_MTstmp] [datetime2](7) NULL,
  [COD_MU] [nvarchar](20) NULL,
  [COD_SNotes] [nvarchar](255) NULL,
  [COD_Notes] [nvarchar](255) NULL,
  [CODEATTRIB] [nvarchar](50) NULL,
 CONSTRAINT [PK_UCOD_RQST_ATYPE] PRIMARY KEY CLUSTERED 
(
  [CODEVAL] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_UCOD_RQST_ATYPE] UNIQUE NONCLUSTERED 
(
  [UCOD_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [jsharmony].[UCOD_RQST_SOURCE]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[UCOD_RQST_SOURCE](
  [UCOD_ID] [bigint] IDENTITY(1,1) NOT NULL,
  [CODSEQ] [smallint] NULL,
  [CODEVAL] [nvarchar](8) NOT NULL,
  [CODETXT] [nvarchar](50) NULL,
  [CODECODE] [nvarchar](50) NULL,
  [CODETDT] [datetime2](7) NULL,
  [CODETCM] [nvarchar](50) NULL,
  [COD_ETstmp] [datetime2](7) NULL,
  [COD_EU] [nvarchar](20) NULL,
  [COD_MTstmp] [datetime2](7) NULL,
  [COD_MU] [nvarchar](20) NULL,
  [COD_SNotes] [nvarchar](255) NULL,
  [COD_Notes] [nvarchar](255) NULL,
  [CODEATTRIB] [nvarchar](50) NULL,
 CONSTRAINT [PK_UCOD_RQST_SOURCE] PRIMARY KEY CLUSTERED 
(
  [CODEVAL] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_UCOD_RQST_SOURCE] UNIQUE NONCLUSTERED 
(
  [UCOD_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [jsharmony].[UCOD_TXT_TYPE]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[UCOD_TXT_TYPE](
  [UCOD_ID] [bigint] IDENTITY(1,1) NOT NULL,
  [CODSEQ] [smallint] NULL,
  [CODEVAL] [nvarchar](8) NOT NULL,
  [CODETXT] [nvarchar](50) NULL,
  [CODECODE] [nvarchar](50) NULL,
  [CODETDT] [datetime2](7) NULL,
  [CODETCM] [nvarchar](50) NULL,
  [COD_ETstmp] [datetime2](7) NULL,
  [COD_EU] [nvarchar](20) NULL,
  [COD_MTstmp] [datetime2](7) NULL,
  [COD_MU] [nvarchar](20) NULL,
  [COD_SNotes] [nvarchar](255) NULL,
  [COD_Notes] [nvarchar](255) NULL,
  [CODEATTRIB] [nvarchar](50) NULL,
 CONSTRAINT [PK_UCOD_TXT_TYPE] PRIMARY KEY CLUSTERED 
(
  [CODEVAL] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_UCOD_TXT_TYPE] UNIQUE NONCLUSTERED 
(
  [UCOD_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [jsharmony].[UCOD_V_STS]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[UCOD_V_STS](
  [UCOD_ID] [bigint] IDENTITY(1,1) NOT NULL,
  [CODSEQ] [smallint] NULL,
  [CODEVAL] [nvarchar](8) NOT NULL,
  [CODETXT] [nvarchar](50) NULL,
  [CODECODE] [nvarchar](50) NULL,
  [CODETDT] [datetime2](7) NULL,
  [CODETCM] [nvarchar](50) NULL,
  [COD_ETstmp] [datetime2](7) NULL,
  [COD_EU] [nvarchar](20) NULL,
  [COD_MTstmp] [datetime2](7) NULL,
  [COD_MU] [nvarchar](20) NULL,
  [COD_SNotes] [nvarchar](255) NULL,
  [COD_Notes] [nvarchar](255) NULL,
  [CODEATTRIB] [nvarchar](50) NULL,
 CONSTRAINT [PK_UCOD_V_STS] PRIMARY KEY CLUSTERED 
(
  [UCOD_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_UCOD_V_STS_CODETXT] UNIQUE NONCLUSTERED 
(
  [CODETXT] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_UCOD_V_STS_CODEVAL] UNIQUE NONCLUSTERED 
(
  [CODEVAL] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [jsharmony].[UCOD2_COUNTRY_STATE]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[UCOD2_COUNTRY_STATE](
  [UCOD2_ID] [bigint] IDENTITY(1,1) NOT NULL,
  [CODSEQ] [smallint] NULL,
  [CODEVAL1] [nvarchar](8) NOT NULL,
  [CODEVAL2] [nvarchar](8) NOT NULL,
  [CODETXT] [nvarchar](50) NULL,
  [CODECODE] [nvarchar](50) NULL,
  [CODEATTRIB] [nvarchar](50) NULL,
  [CODETDT] [datetime2](7) NULL,
  [CODETCM] [nvarchar](50) NULL,
  [COD_ETstmp] [datetime2](7) NULL,
  [COD_EU] [nvarchar](20) NULL,
  [COD_MTstmp] [datetime2](7) NULL,
  [COD_MU] [nvarchar](20) NULL,
  [COD_SNotes] [nvarchar](255) NULL,
  [COD_Notes] [nvarchar](255) NULL,
 CONSTRAINT [PK_UCOD2_COUNTRY_STATE] PRIMARY KEY CLUSTERED 
(
  [UCOD2_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_UCOD2_COUNTRY_STATE] UNIQUE NONCLUSTERED 
(
  [CODEVAL1] ASC,
  [CODEVAL2] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [jsharmony].[UCOD2_H]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[UCOD2_H](
  [CODENAME] [nvarchar](16) NOT NULL,
  [CODEMEAN] [nvarchar](128) NULL,
  [CODECODEMEAN] [nvarchar](128) NULL,
  [CODEATTRIBMEAN] [nvarchar](128) NULL,
  [COD_H_ETstmp] [datetime2](7) NULL,
  [COD_H_EU] [nvarchar](20) NULL,
  [COD_H_MTstmp] [datetime2](7) NULL,
  [COD_H_MU] [nvarchar](20) NULL,
  [COD_SNotes] [nvarchar](255) NULL,
  [CODESCHEMA] [nvarchar](16) NULL,
  [UCOD2_H_ID] [bigint] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_UCOD2_H] PRIMARY KEY CLUSTERED 
(
  [UCOD2_H_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_UCOD2_H] UNIQUE NONCLUSTERED 
(
  [CODESCHEMA] ASC,
  [CODENAME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [jsharmony].[V]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[V](
  [V_ID] [bigint] IDENTITY(1,1) NOT NULL,
  [V_COMP] [nvarchar](50) NOT NULL,
  [V_NO_MAJOR] [int] NOT NULL,
  [V_NO_MINOR] [int] NOT NULL,
  [V_NO_BUILD] [int] NOT NULL,
  [V_NO_REV] [int] NOT NULL,
  [V_STS] [nvarchar](8) NOT NULL,
  [V_NOTE] [nvarchar](max) NULL,
  [V_ETstmp] [datetime2](7) NOT NULL,
  [V_EU] [nvarchar](20) NOT NULL,
  [V_MTstmp] [datetime2](7) NOT NULL,
  [V_MU] [nvarchar](20) NOT NULL,
  [V_SNotes] [nvarchar](255) NULL,
 CONSTRAINT [UNQ_V] PRIMARY KEY CLUSTERED 
(
  [V_NO_MAJOR] ASC,
  [V_NO_MINOR] ASC,
  [V_NO_BUILD] ASC,
  [V_NO_REV] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [jsharmony].[AUD_H] ADD  CONSTRAINT [DF_AUD_H_DB_K]  DEFAULT ('0') FOR [DB_K]
GO
ALTER TABLE [jsharmony].[CPE] ADD  CONSTRAINT [DF_CPE_PE_STS]  DEFAULT (N'ACTIVE') FOR [PE_STS]
GO
ALTER TABLE [jsharmony].[CPE] ADD  CONSTRAINT [DF_CPE_PE_STS_Dt]  DEFAULT ([jsharmony].[myTODAY]()) FOR [PE_STSDt]
GO
ALTER TABLE [jsharmony].[CPE] ADD  CONSTRAINT [DF_CPE_PE_ETstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [PE_ETstmp]
GO
ALTER TABLE [jsharmony].[CPE] ADD  CONSTRAINT [DF_CPE_PE_EU]  DEFAULT ([jsharmony].[myCUSER]()) FOR [PE_EU]
GO
ALTER TABLE [jsharmony].[CPE] ADD  CONSTRAINT [DF_CPE_PE_MTstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [PE_MTstmp]
GO
ALTER TABLE [jsharmony].[CPE] ADD  CONSTRAINT [DF_CPE_PE_MU]  DEFAULT ([jsharmony].[myCUSER]()) FOR [PE_MU]
GO
ALTER TABLE [jsharmony].[CPE] ADD  CONSTRAINT [DF_CPE_PE_Hash]  DEFAULT ((0)) FOR [PE_Hash]
GO
ALTER TABLE [jsharmony].[CR] ADD  CONSTRAINT [DF_CR_CR_STS]  DEFAULT ('ACTIVE') FOR [CR_STS]
GO
ALTER TABLE [jsharmony].[D] ADD  CONSTRAINT [DF_D_D_SCOPE]  DEFAULT (N'S') FOR [D_SCOPE]
GO
ALTER TABLE [jsharmony].[D] ADD  CONSTRAINT [DF_D_D_SCOPE_ID]  DEFAULT ((0)) FOR [D_SCOPE_ID]
GO
ALTER TABLE [jsharmony].[D] ADD  CONSTRAINT [DF_D_C_ID]  DEFAULT (NULL) FOR [C_ID]
GO
ALTER TABLE [jsharmony].[D] ADD  CONSTRAINT [DF_D_E_ID]  DEFAULT (NULL) FOR [E_ID]
GO
ALTER TABLE [jsharmony].[D] ADD  CONSTRAINT [DF_D_D_STS]  DEFAULT (N'A') FOR [D_STS]
GO
ALTER TABLE [jsharmony].[D] ADD  CONSTRAINT [DF_D_D_ETstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [D_ETstmp]
GO
ALTER TABLE [jsharmony].[D] ADD  CONSTRAINT [DF_D_D_EU]  DEFAULT ([jsharmony].[myCUSER]()) FOR [D_EU]
GO
ALTER TABLE [jsharmony].[D] ADD  CONSTRAINT [DF_D_D_MTstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [D_MTstmp]
GO
ALTER TABLE [jsharmony].[D] ADD  CONSTRAINT [DF_D_D_MU]  DEFAULT ([jsharmony].[myCUSER]()) FOR [D_MU]
GO
ALTER TABLE [jsharmony].[D] ADD  CONSTRAINT [DF_D_D_UTstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [D_UTstmp]
GO
ALTER TABLE [jsharmony].[D] ADD  CONSTRAINT [DF_D_D_UU]  DEFAULT ([jsharmony].[myCUSER]()) FOR [D_UU]
GO
ALTER TABLE [jsharmony].[GCOD_H] ADD  CONSTRAINT [DF_GCOD_H_GCOD_H_Edt]  DEFAULT ([jsharmony].[myNOW]()) FOR [COD_H_ETstmp]
GO
ALTER TABLE [jsharmony].[GCOD_H] ADD  CONSTRAINT [DF_GCOD_H_GCOD_H_EUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [COD_H_EU]
GO
ALTER TABLE [jsharmony].[GCOD_H] ADD  CONSTRAINT [DF_GCOD_H_GCOD_H_MDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [COD_H_MTstmp]
GO
ALTER TABLE [jsharmony].[GCOD_H] ADD  CONSTRAINT [DF_GCOD_H_GCOD_H_MUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [COD_H_MU]
GO
ALTER TABLE [jsharmony].[GCOD2_D_SCOPE_D_CTGR] ADD  CONSTRAINT [DF_GCOD2_D_SCOPE_D_CTGR_COD_EDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [COD_ETstmp]
GO
ALTER TABLE [jsharmony].[GCOD2_D_SCOPE_D_CTGR] ADD  CONSTRAINT [DF_GCOD2_D_SCOPE_D_CTGR_COD_EUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [COD_EU]
GO
ALTER TABLE [jsharmony].[GCOD2_D_SCOPE_D_CTGR] ADD  CONSTRAINT [DF_GCOD2_D_SCOPE_D_CTGR_COD_MDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [COD_MTstmp]
GO
ALTER TABLE [jsharmony].[GCOD2_D_SCOPE_D_CTGR] ADD  CONSTRAINT [DF_GCOD2_D_SCOPE_D_CTGR_COD_MUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [COD_MU]
GO
ALTER TABLE [jsharmony].[GCOD2_H] ADD  CONSTRAINT [DF_GCOD2_H_GCOD2_H_Edt]  DEFAULT ([jsharmony].[myNOW]()) FOR [COD_H_ETstmp]
GO
ALTER TABLE [jsharmony].[GCOD2_H] ADD  CONSTRAINT [DF_GCOD2_H_GCOD2_H_EUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [COD_H_EU]
GO
ALTER TABLE [jsharmony].[GCOD2_H] ADD  CONSTRAINT [DF_GCOD2_H_GCOD2_H_MDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [COD_H_MTstmp]
GO
ALTER TABLE [jsharmony].[GCOD2_H] ADD  CONSTRAINT [DF_GCOD2_H_GCOD2_H_MUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [COD_H_MU]
GO
ALTER TABLE [jsharmony].[GPP] ADD  CONSTRAINT [DF_GPP_GPP_ETstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [GPP_ETstmp]
GO
ALTER TABLE [jsharmony].[GPP] ADD  CONSTRAINT [DF_GPP_GPP_EUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [GPP_EU]
GO
ALTER TABLE [jsharmony].[GPP] ADD  CONSTRAINT [DF_GPP_GPP_MTstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [GPP_MTstmp]
GO
ALTER TABLE [jsharmony].[GPP] ADD  CONSTRAINT [DF_GPP_GPP_MUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [GPP_MU]
GO
ALTER TABLE [jsharmony].[H] ADD  CONSTRAINT [DF_H_H_ETstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [H_ETstmp]
GO
ALTER TABLE [jsharmony].[H] ADD  CONSTRAINT [DF_H_H_EU]  DEFAULT ([jsharmony].[myCUSER]()) FOR [H_EU]
GO
ALTER TABLE [jsharmony].[H] ADD  CONSTRAINT [DF_H_H_MTstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [H_MTstmp]
GO
ALTER TABLE [jsharmony].[H] ADD  CONSTRAINT [DF_H_H_MU]  DEFAULT ([jsharmony].[myCUSER]()) FOR [H_MU]
GO
ALTER TABLE [jsharmony].[H] ADD  CONSTRAINT [DF_H_H_INDEX_A]  DEFAULT ((1)) FOR [H_INDEX_A]
GO
ALTER TABLE [jsharmony].[H] ADD  CONSTRAINT [DF_H_H_INDEX_P]  DEFAULT ((1)) FOR [H_INDEX_P]
GO
ALTER TABLE [jsharmony].[N] ADD  CONSTRAINT [DF_N_N_SCOPE]  DEFAULT (N'S') FOR [N_SCOPE]
GO
ALTER TABLE [jsharmony].[N] ADD  CONSTRAINT [DF_N_N_SCOPE_ID]  DEFAULT ((0)) FOR [N_SCOPE_ID]
GO
ALTER TABLE [jsharmony].[N] ADD  CONSTRAINT [DF_N_N_STS]  DEFAULT ('A') FOR [N_STS]
GO
ALTER TABLE [jsharmony].[N] ADD  CONSTRAINT [DF_N_C_ID]  DEFAULT (NULL) FOR [C_ID]
GO
ALTER TABLE [jsharmony].[N] ADD  CONSTRAINT [DF_N_E_ID]  DEFAULT (NULL) FOR [E_ID]
GO
ALTER TABLE [jsharmony].[N] ADD  CONSTRAINT [DF_N_N_ETstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [N_ETstmp]
GO
ALTER TABLE [jsharmony].[N] ADD  CONSTRAINT [DF_N_N_EU]  DEFAULT ([jsharmony].[myCUSER]()) FOR [N_EU]
GO
ALTER TABLE [jsharmony].[N] ADD  CONSTRAINT [DF_N_N_MTstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [N_MTstmp]
GO
ALTER TABLE [jsharmony].[N] ADD  CONSTRAINT [DF_N_N_MU]  DEFAULT ([jsharmony].[myCUSER]()) FOR [N_MU]
GO
ALTER TABLE [jsharmony].[PE] ADD  CONSTRAINT [DF_PE_PE_STS]  DEFAULT (N'ACTIVE') FOR [PE_STS]
GO
ALTER TABLE [jsharmony].[PE] ADD  CONSTRAINT [DF__PE__PE_STS_Dt__17C286CF]  DEFAULT ([jsharmony].[myTODAY]()) FOR [PE_STSDt]
GO
ALTER TABLE [jsharmony].[PE] ADD  CONSTRAINT [DF_PE_PE_COUNTRY]  DEFAULT ('USA') FOR [PE_COUNTRY]
GO
ALTER TABLE [jsharmony].[PE] ADD  CONSTRAINT [DF_PE_PE_STARTDT]  DEFAULT ([jsharmony].[myNOW]()) FOR [PE_STARTDT]
GO
ALTER TABLE [jsharmony].[PE] ADD  CONSTRAINT [DF_PE_PE_ETstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [PE_ETstmp]
GO
ALTER TABLE [jsharmony].[PE] ADD  CONSTRAINT [DF__PE__PE_EU]  DEFAULT ([jsharmony].[myCUSER]()) FOR [PE_EU]
GO
ALTER TABLE [jsharmony].[PE] ADD  CONSTRAINT [DF__PE__PE_MTstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [PE_MTstmp]
GO
ALTER TABLE [jsharmony].[PE] ADD  CONSTRAINT [DF__PE__PE_MU]  DEFAULT ([jsharmony].[myCUSER]()) FOR [PE_MU]
GO
ALTER TABLE [jsharmony].[PE] ADD  CONSTRAINT [DF__PE__PE_Hash__597119F2]  DEFAULT ((0)) FOR [PE_Hash]
GO
ALTER TABLE [jsharmony].[PPD] ADD  CONSTRAINT [DF_PPD_PPD_GPP]  DEFAULT ((0)) FOR [PPD_GPP]
GO
ALTER TABLE [jsharmony].[PPD] ADD  CONSTRAINT [DF_PPD_PPD_PPP]  DEFAULT ((0)) FOR [PPD_PPP]
GO
ALTER TABLE [jsharmony].[PPD] ADD  CONSTRAINT [DF_PPD_PPD_XPP]  DEFAULT ((0)) FOR [PPD_XPP]
GO
ALTER TABLE [jsharmony].[PPD] ADD  CONSTRAINT [DF_PPD_PPD_ETstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [PPD_ETstmp]
GO
ALTER TABLE [jsharmony].[PPD] ADD  CONSTRAINT [DF_PPD_PPD_EUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [PPD_EU]
GO
ALTER TABLE [jsharmony].[PPD] ADD  CONSTRAINT [DF_PPD_PPD_MTstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [PPD_MTstmp]
GO
ALTER TABLE [jsharmony].[PPD] ADD  CONSTRAINT [DF_PPD_PPD_MUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [PPD_MU]
GO
ALTER TABLE [jsharmony].[PPP] ADD  CONSTRAINT [DF_PPP_PPP_ETstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [PPP_ETstmp]
GO
ALTER TABLE [jsharmony].[PPP] ADD  CONSTRAINT [DF_PPP_PPP_EUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [PPP_EU]
GO
ALTER TABLE [jsharmony].[PPP] ADD  CONSTRAINT [DF_PPP_PPP_MTstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [PPP_MTstmp]
GO
ALTER TABLE [jsharmony].[PPP] ADD  CONSTRAINT [DF_PPP_PPP_MUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [PPP_MU]
GO
ALTER TABLE [jsharmony].[RQ] ADD  CONSTRAINT [DF_RQ_RQ_ETstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [RQ_ETstmp]
GO
ALTER TABLE [jsharmony].[RQ] ADD  CONSTRAINT [DF_RQ_RQ_EU]  DEFAULT ([jsharmony].[myCUSER]()) FOR [RQ_EU]
GO
ALTER TABLE [jsharmony].[RQST] ADD  CONSTRAINT [DF_RQST_RQST_ETstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [RQST_ETstmp]
GO
ALTER TABLE [jsharmony].[RQST] ADD  CONSTRAINT [DF_RQST_RQST_EU]  DEFAULT ([jsharmony].[myCUSER]()) FOR [RQST_EU]
GO
ALTER TABLE [jsharmony].[SF] ADD  CONSTRAINT [DF_SF_SF_STS]  DEFAULT ('ACTIVE') FOR [SF_STS]
GO
ALTER TABLE [jsharmony].[SM] ADD  CONSTRAINT [DF_SM_SM_UTYPE]  DEFAULT ('S') FOR [SM_UTYPE]
GO
ALTER TABLE [jsharmony].[SM] ADD  CONSTRAINT [DF_SM_SM_STS]  DEFAULT ('ACTIVE') FOR [SM_STS]
GO
ALTER TABLE [jsharmony].[SR] ADD  CONSTRAINT [DF_SR_SR_STS]  DEFAULT ('ACTIVE') FOR [SR_STS]
GO
ALTER TABLE [jsharmony].[TXT] ADD  CONSTRAINT [DF_TXT_TXT_TYPE]  DEFAULT ('TEXT') FOR [TXT_TYPE]
GO
ALTER TABLE [jsharmony].[TXT] ADD  CONSTRAINT [DF_TXT_TXT_ETstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [TXT_ETstmp]
GO
ALTER TABLE [jsharmony].[TXT] ADD  CONSTRAINT [DF_TXT_TXT_EUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [TXT_EU]
GO
ALTER TABLE [jsharmony].[TXT] ADD  CONSTRAINT [DF_TXT_TXT_MTstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [TXT_MTstmp]
GO
ALTER TABLE [jsharmony].[TXT] ADD  CONSTRAINT [DF_TXT_TXT_MUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [TXT_MU]
GO
ALTER TABLE [jsharmony].[UCOD_AC] ADD  CONSTRAINT [DF_UCOD_AC_COD_EDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [COD_ETstmp]
GO
ALTER TABLE [jsharmony].[UCOD_AC] ADD  CONSTRAINT [DF_UCOD_AC_COD_EUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [COD_EU]
GO
ALTER TABLE [jsharmony].[UCOD_AC] ADD  CONSTRAINT [DF_UCOD_AC_COD_MDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [COD_MTstmp]
GO
ALTER TABLE [jsharmony].[UCOD_AC] ADD  CONSTRAINT [DF_UCOD_AC_COD_MUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [COD_MU]
GO
ALTER TABLE [jsharmony].[UCOD_AC1] ADD  CONSTRAINT [DF_UCOD_AC1_COD_EDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [COD_ETstmp]
GO
ALTER TABLE [jsharmony].[UCOD_AC1] ADD  CONSTRAINT [DF_UCOD_AC1_COD_EUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [COD_EU]
GO
ALTER TABLE [jsharmony].[UCOD_AC1] ADD  CONSTRAINT [DF_UCOD_AC1_COD_MDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [COD_MTstmp]
GO
ALTER TABLE [jsharmony].[UCOD_AC1] ADD  CONSTRAINT [DF_UCOD_AC1_COD_MUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [COD_MU]
GO
ALTER TABLE [jsharmony].[UCOD_AHC] ADD  CONSTRAINT [DF_UCOD_AHC_COD_EDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [COD_ETstmp]
GO
ALTER TABLE [jsharmony].[UCOD_AHC] ADD  CONSTRAINT [DF_UCOD_AHC_COD_EUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [COD_EU]
GO
ALTER TABLE [jsharmony].[UCOD_AHC] ADD  CONSTRAINT [DF_UCOD_AHC_COD_MDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [COD_MTstmp]
GO
ALTER TABLE [jsharmony].[UCOD_AHC] ADD  CONSTRAINT [DF_UCOD_AHC_COD_MUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [COD_MU]
GO
ALTER TABLE [jsharmony].[UCOD_COUNTRY] ADD  CONSTRAINT [DF_UCOD_COUNTRY_COD_EDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [COD_ETstmp]
GO
ALTER TABLE [jsharmony].[UCOD_COUNTRY] ADD  CONSTRAINT [DF_UCOD_COUNTRY_COD_EUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [COD_EU]
GO
ALTER TABLE [jsharmony].[UCOD_COUNTRY] ADD  CONSTRAINT [DF_UCOD_COUNTRY_COD_MDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [COD_MTstmp]
GO
ALTER TABLE [jsharmony].[UCOD_COUNTRY] ADD  CONSTRAINT [DF_UCOD_COUNTRY_COD_MUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [COD_MU]
GO
ALTER TABLE [jsharmony].[UCOD_D_SCOPE] ADD  CONSTRAINT [DF_UCOD_SCOPE_COD_EDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [COD_ETstmp]
GO
ALTER TABLE [jsharmony].[UCOD_D_SCOPE] ADD  CONSTRAINT [DF_UCOD_SCOPE_COD_EUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [COD_EU]
GO
ALTER TABLE [jsharmony].[UCOD_D_SCOPE] ADD  CONSTRAINT [DF_UCOD_SCOPE_COD_MDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [COD_MTstmp]
GO
ALTER TABLE [jsharmony].[UCOD_D_SCOPE] ADD  CONSTRAINT [DF_UCOD_SCOPE_COD_MUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [COD_MU]
GO
ALTER TABLE [jsharmony].[UCOD_H] ADD  CONSTRAINT [DF_COD_H_COD_H_Edt]  DEFAULT ([jsharmony].[myNOW]()) FOR [COD_H_ETstmp]
GO
ALTER TABLE [jsharmony].[UCOD_H] ADD  CONSTRAINT [DF_COD_H_COD_H_EUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [COD_H_EU]
GO
ALTER TABLE [jsharmony].[UCOD_H] ADD  CONSTRAINT [DF_COD_H_COD_H_MDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [COD_H_MTstmp]
GO
ALTER TABLE [jsharmony].[UCOD_H] ADD  CONSTRAINT [DF_COD_H_COD_H_MUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [COD_H_MU]
GO
ALTER TABLE [jsharmony].[UCOD_N_SCOPE] ADD  CONSTRAINT [DF_UCON_SCOPE_COD_EDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [COD_ETstmp]
GO
ALTER TABLE [jsharmony].[UCOD_N_SCOPE] ADD  CONSTRAINT [DF_UCON_SCOPE_COD_EUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [COD_EU]
GO
ALTER TABLE [jsharmony].[UCOD_N_SCOPE] ADD  CONSTRAINT [DF_UCON_SCOPE_COD_MDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [COD_MTstmp]
GO
ALTER TABLE [jsharmony].[UCOD_N_SCOPE] ADD  CONSTRAINT [DF_UCON_SCOPE_COD_MUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [COD_MU]
GO
ALTER TABLE [jsharmony].[UCOD_N_TYPE] ADD  CONSTRAINT [DF_UCOD_N_TYPE_COD_EDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [COD_ETstmp]
GO
ALTER TABLE [jsharmony].[UCOD_N_TYPE] ADD  CONSTRAINT [DF_UCOD_N_TYPE_COD_EUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [COD_EU]
GO
ALTER TABLE [jsharmony].[UCOD_N_TYPE] ADD  CONSTRAINT [DF_UCOD_N_TYPE_COD_MDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [COD_MTstmp]
GO
ALTER TABLE [jsharmony].[UCOD_N_TYPE] ADD  CONSTRAINT [DF_UCOD_N_TYPE_COD_MUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [COD_MU]
GO
ALTER TABLE [jsharmony].[UCOD_PPD_TYPE] ADD  CONSTRAINT [DF_UCOD_PPD_TYPE_COD_EDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [COD_ETstmp]
GO
ALTER TABLE [jsharmony].[UCOD_PPD_TYPE] ADD  CONSTRAINT [DF_UCOD_PPD_TYPE_COD_EUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [COD_EU]
GO
ALTER TABLE [jsharmony].[UCOD_PPD_TYPE] ADD  CONSTRAINT [DF_UCOD_PPD_TYPE_COD_MDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [COD_MTstmp]
GO
ALTER TABLE [jsharmony].[UCOD_PPD_TYPE] ADD  CONSTRAINT [DF_UCOD_PPD_TYPE_COD_MUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [COD_MU]
GO
ALTER TABLE [jsharmony].[UCOD_RQST_ATYPE] ADD  CONSTRAINT [DF_UCOD_RQST_ATYPE_COD_EDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [COD_ETstmp]
GO
ALTER TABLE [jsharmony].[UCOD_RQST_ATYPE] ADD  CONSTRAINT [DF_UCOD_RQST_ATYPE_COD_EUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [COD_EU]
GO
ALTER TABLE [jsharmony].[UCOD_RQST_ATYPE] ADD  CONSTRAINT [DF_UCOD_RQST_ATYPE_COD_MDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [COD_MTstmp]
GO
ALTER TABLE [jsharmony].[UCOD_RQST_ATYPE] ADD  CONSTRAINT [DF_UCOD_RQST_ATYPE_COD_MUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [COD_MU]
GO
ALTER TABLE [jsharmony].[UCOD_RQST_SOURCE] ADD  CONSTRAINT [DF_UCOD_RQST_SOURCE_COD_EDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [COD_ETstmp]
GO
ALTER TABLE [jsharmony].[UCOD_RQST_SOURCE] ADD  CONSTRAINT [DF_UCOD_RQST_SOURCE_COD_EUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [COD_EU]
GO
ALTER TABLE [jsharmony].[UCOD_RQST_SOURCE] ADD  CONSTRAINT [DF_UCOD_RQST_SOURCE_COD_MDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [COD_MTstmp]
GO
ALTER TABLE [jsharmony].[UCOD_RQST_SOURCE] ADD  CONSTRAINT [DF_UCOD_RQST_SOURCE_COD_MUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [COD_MU]
GO
ALTER TABLE [jsharmony].[UCOD_TXT_TYPE] ADD  CONSTRAINT [DF_UCOD_TXT_TYPE_COD_EDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [COD_ETstmp]
GO
ALTER TABLE [jsharmony].[UCOD_TXT_TYPE] ADD  CONSTRAINT [DF_UCOD_TXT_TYPE_COD_EUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [COD_EU]
GO
ALTER TABLE [jsharmony].[UCOD_TXT_TYPE] ADD  CONSTRAINT [DF_UCOD_TXT_TYPE_COD_MDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [COD_MTstmp]
GO
ALTER TABLE [jsharmony].[UCOD_TXT_TYPE] ADD  CONSTRAINT [DF_UCOD_TXT_TYPE_COD_MUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [COD_MU]
GO
ALTER TABLE [jsharmony].[UCOD_V_STS] ADD  CONSTRAINT [DF_UCOD_V_STS_COD_EDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [COD_ETstmp]
GO
ALTER TABLE [jsharmony].[UCOD_V_STS] ADD  CONSTRAINT [DF_UCOD_V_STS_COD_EUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [COD_EU]
GO
ALTER TABLE [jsharmony].[UCOD_V_STS] ADD  CONSTRAINT [DF_UCOD_V_STS_COD_MDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [COD_MTstmp]
GO
ALTER TABLE [jsharmony].[UCOD_V_STS] ADD  CONSTRAINT [DF_UCOD_V_STS_COD_MUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [COD_MU]
GO
ALTER TABLE [jsharmony].[UCOD2_COUNTRY_STATE] ADD  CONSTRAINT [DF_UCOD2_COUNTRY_STATE_COD_EDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [COD_ETstmp]
GO
ALTER TABLE [jsharmony].[UCOD2_COUNTRY_STATE] ADD  CONSTRAINT [DF_UCOD2_COUNTRY_STATE_COD_EUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [COD_EU]
GO
ALTER TABLE [jsharmony].[UCOD2_COUNTRY_STATE] ADD  CONSTRAINT [DF_UCOD2_COUNTRY_STATE_COD_MDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [COD_MTstmp]
GO
ALTER TABLE [jsharmony].[UCOD2_COUNTRY_STATE] ADD  CONSTRAINT [DF_UCOD2_COUNTRY_STATE_COD_MUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [COD_MU]
GO
ALTER TABLE [jsharmony].[UCOD2_H] ADD  CONSTRAINT [DF_UCOD2_H_UCOD2_H_Edt]  DEFAULT ([jsharmony].[myNOW]()) FOR [COD_H_ETstmp]
GO
ALTER TABLE [jsharmony].[UCOD2_H] ADD  CONSTRAINT [DF_UCOD2_H_UCOD2_H_EUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [COD_H_EU]
GO
ALTER TABLE [jsharmony].[UCOD2_H] ADD  CONSTRAINT [DF_UCOD2_H_UCOD2_H_MDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [COD_H_MTstmp]
GO
ALTER TABLE [jsharmony].[UCOD2_H] ADD  CONSTRAINT [DF_UCOD2_H_UCOD2_H_MUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [COD_H_MU]
GO
ALTER TABLE [jsharmony].[V] ADD  CONSTRAINT [DF_V_V_NO_MAJOR]  DEFAULT ((0)) FOR [V_NO_MAJOR]
GO
ALTER TABLE [jsharmony].[V] ADD  CONSTRAINT [DF_V_V_NO_MINOR]  DEFAULT ((0)) FOR [V_NO_MINOR]
GO
ALTER TABLE [jsharmony].[V] ADD  CONSTRAINT [DF_V_V_NO_BUILD]  DEFAULT ((0)) FOR [V_NO_BUILD]
GO
ALTER TABLE [jsharmony].[V] ADD  CONSTRAINT [DF_V_V_NO_REV]  DEFAULT ((0)) FOR [V_NO_REV]
GO
ALTER TABLE [jsharmony].[V] ADD  CONSTRAINT [DF_V_V_STS]  DEFAULT ('OK') FOR [V_STS]
GO
ALTER TABLE [jsharmony].[V] ADD  CONSTRAINT [DF_V_V_ETstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [V_ETstmp]
GO
ALTER TABLE [jsharmony].[V] ADD  CONSTRAINT [DF_V_V_EU]  DEFAULT ([jsharmony].[myCUSER]()) FOR [V_EU]
GO
ALTER TABLE [jsharmony].[V] ADD  CONSTRAINT [DF_V_V_MTstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [V_MTstmp]
GO
ALTER TABLE [jsharmony].[V] ADD  CONSTRAINT [DF_V_V_MU]  DEFAULT ([jsharmony].[myCUSER]()) FOR [V_MU]
GO
ALTER TABLE [jsharmony].[XPP] ADD  CONSTRAINT [DF_XPP_XPP_ETstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [XPP_ETstmp]
GO
ALTER TABLE [jsharmony].[XPP] ADD  CONSTRAINT [DF_XPP_XPP_EUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [XPP_EU]
GO
ALTER TABLE [jsharmony].[XPP] ADD  CONSTRAINT [DF_XPP_XPP_MTstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [XPP_MTstmp]
GO
ALTER TABLE [jsharmony].[XPP] ADD  CONSTRAINT [DF_XPP_XPP_MUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [XPP_MU]
GO
ALTER TABLE [jsharmony].[AUD_D]  WITH CHECK ADD  CONSTRAINT [FK_AUD_D_AUD_H] FOREIGN KEY([AUD_SEQ])
REFERENCES [jsharmony].[AUD_H] ([AUD_SEQ])
GO
ALTER TABLE [jsharmony].[AUD_D] CHECK CONSTRAINT [FK_AUD_D_AUD_H]
GO
ALTER TABLE [jsharmony].[CPE]  WITH CHECK ADD  CONSTRAINT [FK_CPE_UCOD_AHC] FOREIGN KEY([PE_STS])
REFERENCES [jsharmony].[UCOD_AHC] ([CODEVAL])
GO
ALTER TABLE [jsharmony].[CPE] CHECK CONSTRAINT [FK_CPE_UCOD_AHC]
GO
ALTER TABLE [jsharmony].[CPER]  WITH CHECK ADD  CONSTRAINT [FK_CPER_CPE] FOREIGN KEY([PE_ID])
REFERENCES [jsharmony].[CPE] ([PE_ID])
ON DELETE CASCADE
GO
ALTER TABLE [jsharmony].[CPER] CHECK CONSTRAINT [FK_CPER_CPE]
GO
ALTER TABLE [jsharmony].[CPER]  WITH CHECK ADD  CONSTRAINT [FK_CPER_CR_CR_NAME] FOREIGN KEY([CR_NAME])
REFERENCES [jsharmony].[CR] ([CR_Name])
GO
ALTER TABLE [jsharmony].[CPER] CHECK CONSTRAINT [FK_CPER_CR_CR_NAME]
GO
ALTER TABLE [jsharmony].[CR]  WITH CHECK ADD  CONSTRAINT [FK_CR_UCOD_AHC] FOREIGN KEY([CR_STS])
REFERENCES [jsharmony].[UCOD_AHC] ([CODEVAL])
GO
ALTER TABLE [jsharmony].[CR] CHECK CONSTRAINT [FK_CR_UCOD_AHC]
GO
ALTER TABLE [jsharmony].[CRM]  WITH CHECK ADD  CONSTRAINT [FK_CRM_CR_CR_NAME] FOREIGN KEY([CR_NAME])
REFERENCES [jsharmony].[CR] ([CR_Name])
ON DELETE CASCADE
GO
ALTER TABLE [jsharmony].[CRM] CHECK CONSTRAINT [FK_CRM_CR_CR_NAME]
GO
ALTER TABLE [jsharmony].[CRM]  WITH CHECK ADD  CONSTRAINT [FK_CRM_SM] FOREIGN KEY([SM_ID])
REFERENCES [jsharmony].[SM] ([SM_ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [jsharmony].[CRM] CHECK CONSTRAINT [FK_CRM_SM]
GO
ALTER TABLE [jsharmony].[D]  WITH CHECK ADD  CONSTRAINT [FK_D_GCOD2_D_SCOPE_D_CTGR] FOREIGN KEY([D_SCOPE], [D_CTGR])
REFERENCES [jsharmony].[GCOD2_D_SCOPE_D_CTGR] ([CODEVAL1], [CODEVAL2])
GO
ALTER TABLE [jsharmony].[D] CHECK CONSTRAINT [FK_D_GCOD2_D_SCOPE_D_CTGR]
GO
ALTER TABLE [jsharmony].[D]  WITH CHECK ADD  CONSTRAINT [FK_D_UCOD_D_SCOPE] FOREIGN KEY([D_SCOPE])
REFERENCES [jsharmony].[UCOD_D_SCOPE] ([CODEVAL])
GO
ALTER TABLE [jsharmony].[D] CHECK CONSTRAINT [FK_D_UCOD_D_SCOPE]
GO
ALTER TABLE [jsharmony].[GPP]  WITH CHECK ADD  CONSTRAINT [FK_GPP_PPD] FOREIGN KEY([GPP_PROCESS], [GPP_ATTRIB])
REFERENCES [jsharmony].[PPD] ([PPD_PROCESS], [PPD_ATTRIB])
GO
ALTER TABLE [jsharmony].[GPP] CHECK CONSTRAINT [FK_GPP_PPD]
GO
ALTER TABLE [jsharmony].[H]  WITH CHECK ADD  CONSTRAINT [FK_H_HP] FOREIGN KEY([HP_CODE])
REFERENCES [jsharmony].[HP] ([HP_CODE])
GO
ALTER TABLE [jsharmony].[H] CHECK CONSTRAINT [FK_H_HP]
GO
ALTER TABLE [jsharmony].[N]  WITH CHECK ADD  CONSTRAINT [FK_N_UCOD_AC1] FOREIGN KEY([N_STS])
REFERENCES [jsharmony].[UCOD_AC1] ([CODEVAL])
GO
ALTER TABLE [jsharmony].[N] CHECK CONSTRAINT [FK_N_UCOD_AC1]
GO
ALTER TABLE [jsharmony].[N]  WITH CHECK ADD  CONSTRAINT [FK_N_UCOD_N_SCOPE] FOREIGN KEY([N_SCOPE])
REFERENCES [jsharmony].[UCOD_N_SCOPE] ([CODEVAL])
GO
ALTER TABLE [jsharmony].[N] CHECK CONSTRAINT [FK_N_UCOD_N_SCOPE]
GO
ALTER TABLE [jsharmony].[N]  WITH CHECK ADD  CONSTRAINT [FK_N_UCOD_N_TYPE] FOREIGN KEY([N_TYPE])
REFERENCES [jsharmony].[UCOD_N_TYPE] ([CODEVAL])
GO
ALTER TABLE [jsharmony].[N] CHECK CONSTRAINT [FK_N_UCOD_N_TYPE]
GO
ALTER TABLE [jsharmony].[PE]  WITH CHECK ADD  CONSTRAINT [FK_PE_UCOD_AHC] FOREIGN KEY([PE_STS])
REFERENCES [jsharmony].[UCOD_AHC] ([CODEVAL])
GO
ALTER TABLE [jsharmony].[PE] CHECK CONSTRAINT [FK_PE_UCOD_AHC]
GO
ALTER TABLE [jsharmony].[PE]  WITH CHECK ADD  CONSTRAINT [FK_PE_UCOD_COUNTRY] FOREIGN KEY([PE_COUNTRY])
REFERENCES [jsharmony].[UCOD_COUNTRY] ([CODEVAL])
GO
ALTER TABLE [jsharmony].[PE] CHECK CONSTRAINT [FK_PE_UCOD_COUNTRY]
GO
ALTER TABLE [jsharmony].[PE]  WITH CHECK ADD  CONSTRAINT [FK_PE_UCOD2_COUNTRY_STATE] FOREIGN KEY([PE_COUNTRY], [PE_STATE])
REFERENCES [jsharmony].[UCOD2_COUNTRY_STATE] ([CODEVAL1], [CODEVAL2])
GO
ALTER TABLE [jsharmony].[PE] CHECK CONSTRAINT [FK_PE_UCOD2_COUNTRY_STATE]
GO
ALTER TABLE [jsharmony].[PPD]  WITH CHECK ADD  CONSTRAINT [FK_PPD_UCOD_PPD_TYPE] FOREIGN KEY([PPD_TYPE])
REFERENCES [jsharmony].[UCOD_PPD_TYPE] ([CODEVAL])
GO
ALTER TABLE [jsharmony].[PPD] CHECK CONSTRAINT [FK_PPD_UCOD_PPD_TYPE]
GO
ALTER TABLE [jsharmony].[PPP]  WITH CHECK ADD  CONSTRAINT [FK_PPP_PE] FOREIGN KEY([PE_ID])
REFERENCES [jsharmony].[PE] ([PE_ID])
ON DELETE CASCADE
GO
ALTER TABLE [jsharmony].[PPP] CHECK CONSTRAINT [FK_PPP_PE]
GO
ALTER TABLE [jsharmony].[PPP]  WITH CHECK ADD  CONSTRAINT [FK_PPP_PPD] FOREIGN KEY([PPP_PROCESS], [PPP_ATTRIB])
REFERENCES [jsharmony].[PPD] ([PPD_PROCESS], [PPD_ATTRIB])
ON DELETE CASCADE
GO
ALTER TABLE [jsharmony].[PPP] CHECK CONSTRAINT [FK_PPP_PPD]
GO
ALTER TABLE [jsharmony].[RQST]  WITH CHECK ADD  CONSTRAINT [FK_RQST_UCOD_RQST_ATYPE] FOREIGN KEY([RQST_ATYPE])
REFERENCES [jsharmony].[UCOD_RQST_ATYPE] ([CODEVAL])
GO
ALTER TABLE [jsharmony].[RQST] CHECK CONSTRAINT [FK_RQST_UCOD_RQST_ATYPE]
GO
ALTER TABLE [jsharmony].[RQST]  WITH CHECK ADD  CONSTRAINT [FK_RQST_UCOD_RQST_SOURCE] FOREIGN KEY([RQST_SOURCE])
REFERENCES [jsharmony].[UCOD_RQST_SOURCE] ([CODEVAL])
GO
ALTER TABLE [jsharmony].[RQST] CHECK CONSTRAINT [FK_RQST_UCOD_RQST_SOURCE]
GO
ALTER TABLE [jsharmony].[RQST_D]  WITH CHECK ADD  CONSTRAINT [FK_RQST_D_RQST] FOREIGN KEY([RQST_ID])
REFERENCES [jsharmony].[RQST] ([RQST_ID])
GO
ALTER TABLE [jsharmony].[RQST_D] CHECK CONSTRAINT [FK_RQST_D_RQST]
GO
ALTER TABLE [jsharmony].[RQST_EMAIL]  WITH CHECK ADD  CONSTRAINT [FK_RQST_EMAIL_RQST] FOREIGN KEY([RQST_ID])
REFERENCES [jsharmony].[RQST] ([RQST_ID])
GO
ALTER TABLE [jsharmony].[RQST_EMAIL] CHECK CONSTRAINT [FK_RQST_EMAIL_RQST]
GO
ALTER TABLE [jsharmony].[RQST_N]  WITH CHECK ADD  CONSTRAINT [FK_RQST_N_RQST] FOREIGN KEY([RQST_ID])
REFERENCES [jsharmony].[RQST] ([RQST_ID])
GO
ALTER TABLE [jsharmony].[RQST_N] CHECK CONSTRAINT [FK_RQST_N_RQST]
GO
ALTER TABLE [jsharmony].[RQST_RQ]  WITH CHECK ADD  CONSTRAINT [FK_RQST_RQ_RQST] FOREIGN KEY([RQST_ID])
REFERENCES [jsharmony].[RQST] ([RQST_ID])
GO
ALTER TABLE [jsharmony].[RQST_RQ] CHECK CONSTRAINT [FK_RQST_RQ_RQST]
GO
ALTER TABLE [jsharmony].[RQST_SMS]  WITH CHECK ADD  CONSTRAINT [FK_RQST_SMS_RQST] FOREIGN KEY([RQST_ID])
REFERENCES [jsharmony].[RQST] ([RQST_ID])
GO
ALTER TABLE [jsharmony].[RQST_SMS] CHECK CONSTRAINT [FK_RQST_SMS_RQST]
GO
ALTER TABLE [jsharmony].[SF]  WITH CHECK ADD  CONSTRAINT [FK_SF_UCOD_AHC] FOREIGN KEY([SF_STS])
REFERENCES [jsharmony].[UCOD_AHC] ([CODEVAL])
GO
ALTER TABLE [jsharmony].[SF] CHECK CONSTRAINT [FK_SF_UCOD_AHC]
GO
ALTER TABLE [jsharmony].[SM]  WITH CHECK ADD  CONSTRAINT [FK_SM_SM] FOREIGN KEY([SM_ID_Parent])
REFERENCES [jsharmony].[SM] ([SM_ID])
GO
ALTER TABLE [jsharmony].[SM] CHECK CONSTRAINT [FK_SM_SM]
GO
ALTER TABLE [jsharmony].[SM]  WITH CHECK ADD  CONSTRAINT [FK_SM_UCOD_AHC] FOREIGN KEY([SM_STS])
REFERENCES [jsharmony].[UCOD_AHC] ([CODEVAL])
GO
ALTER TABLE [jsharmony].[SM] CHECK CONSTRAINT [FK_SM_UCOD_AHC]
GO
ALTER TABLE [jsharmony].[SPEF]  WITH CHECK ADD  CONSTRAINT [FK_SPEF_PE] FOREIGN KEY([PE_ID])
REFERENCES [jsharmony].[PE] ([PE_ID])
GO
ALTER TABLE [jsharmony].[SPEF] CHECK CONSTRAINT [FK_SPEF_PE]
GO
ALTER TABLE [jsharmony].[SPEF]  WITH CHECK ADD  CONSTRAINT [FK_SPEF_SF_SF_NAME] FOREIGN KEY([SF_NAME])
REFERENCES [jsharmony].[SF] ([SF_Name])
GO
ALTER TABLE [jsharmony].[SPEF] CHECK CONSTRAINT [FK_SPEF_SF_SF_NAME]
GO
ALTER TABLE [jsharmony].[SPER]  WITH CHECK ADD  CONSTRAINT [FK_SPER_PE] FOREIGN KEY([PE_ID])
REFERENCES [jsharmony].[PE] ([PE_ID])
GO
ALTER TABLE [jsharmony].[SPER] CHECK CONSTRAINT [FK_SPER_PE]
GO
ALTER TABLE [jsharmony].[SPER]  WITH CHECK ADD  CONSTRAINT [FK_SPER_SR_SR_NAME] FOREIGN KEY([SR_NAME])
REFERENCES [jsharmony].[SR] ([SR_Name])
GO
ALTER TABLE [jsharmony].[SPER] CHECK CONSTRAINT [FK_SPER_SR_SR_NAME]
GO
ALTER TABLE [jsharmony].[SR]  WITH CHECK ADD  CONSTRAINT [FK_SR_UCOD_AHC] FOREIGN KEY([SR_STS])
REFERENCES [jsharmony].[UCOD_AHC] ([CODEVAL])
GO
ALTER TABLE [jsharmony].[SR] CHECK CONSTRAINT [FK_SR_UCOD_AHC]
GO
ALTER TABLE [jsharmony].[SRM]  WITH CHECK ADD  CONSTRAINT [FK_SRM_SM] FOREIGN KEY([SM_ID])
REFERENCES [jsharmony].[SM] ([SM_ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [jsharmony].[SRM] CHECK CONSTRAINT [FK_SRM_SM]
GO
ALTER TABLE [jsharmony].[SRM]  WITH CHECK ADD  CONSTRAINT [FK_SRM_SR_SR_NAME] FOREIGN KEY([SR_NAME])
REFERENCES [jsharmony].[SR] ([SR_Name])
ON DELETE CASCADE
GO
ALTER TABLE [jsharmony].[SRM] CHECK CONSTRAINT [FK_SRM_SR_SR_NAME]
GO
ALTER TABLE [jsharmony].[TXT]  WITH CHECK ADD  CONSTRAINT [FK_TXT_UCOD_TXT_TYPE] FOREIGN KEY([TXT_TYPE])
REFERENCES [jsharmony].[UCOD_TXT_TYPE] ([CODEVAL])
GO
ALTER TABLE [jsharmony].[TXT] CHECK CONSTRAINT [FK_TXT_UCOD_TXT_TYPE]
GO
ALTER TABLE [jsharmony].[V]  WITH CHECK ADD  CONSTRAINT [FK_V_UCOD_V_STS] FOREIGN KEY([V_STS])
REFERENCES [jsharmony].[UCOD_V_STS] ([CODEVAL])
GO
ALTER TABLE [jsharmony].[V] CHECK CONSTRAINT [FK_V_UCOD_V_STS]
GO
ALTER TABLE [jsharmony].[XPP]  WITH CHECK ADD  CONSTRAINT [FK_XPP_PPD] FOREIGN KEY([XPP_PROCESS], [XPP_ATTRIB])
REFERENCES [jsharmony].[PPD] ([PPD_PROCESS], [PPD_ATTRIB])
GO
ALTER TABLE [jsharmony].[XPP] CHECK CONSTRAINT [FK_XPP_PPD]
GO
ALTER TABLE [jsharmony].[CPE]  WITH CHECK ADD  CONSTRAINT [CK_CPE_PE_Email] CHECK  ((isnull([PE_Email],'')<>''))
GO
ALTER TABLE [jsharmony].[CPE] CHECK CONSTRAINT [CK_CPE_PE_Email]
GO
ALTER TABLE [jsharmony].[PE]  WITH CHECK ADD  CONSTRAINT [CK_PE_PE_Email] CHECK  ((isnull([PE_Email],'')<>''))
GO
ALTER TABLE [jsharmony].[PE] CHECK CONSTRAINT [CK_PE_PE_Email]
GO
ALTER TABLE [jsharmony].[SM]  WITH CHECK ADD  CONSTRAINT [CK_SM_SM_UTYPE] CHECK  (([SM_UTYPE]='C' OR [SM_UTYPE]='S'))
GO
ALTER TABLE [jsharmony].[SM] CHECK CONSTRAINT [CK_SM_SM_UTYPE]
GO
/****** Object:  StoredProcedure [jsharmony].[AUDH]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE  [jsharmony].[AUDH]
(
  @op           nvarchar(max),
  @tname        NVARCHAR(MAX),
  @tid          bigint,
  @u            NVARCHAR(MAX),
  @tstmp        DATETIME2(7),
  @ref_name     varchar(32) = NULL,
  @ref_id       bigint = NULL,
  @subj         nvarchar(255) = NULL,
  @cid          bigint = NULL, 
  @eid          bigint = NULL 
) 
as
BEGIN
  DECLARE @MY_AUD_SEQ BIGINT=0
  DECLARE @MYUSER NVARCHAR(MAX)
  DECLARE @WK_C_ID bigint = NULL
  DECLARE @WK_E_ID bigint = NULL
  DECLARE @WK_REF_NAME varchar(32) = NULL
  DECLARE @WK_REF_ID bigint = NULL
  DECLARE @WK_SUBJ nvarchar(255) = NULL
 
  DECLARE @SQLCMD nvarchar(max)
  DECLARE @GETCID nvarchar(max)
  DECLARE @GETEID nvarchar(max)
  DECLARE @DSCOPE_DCTGR nvarchar(max)
  DECLARE @MY_C_ID bigint
  DECLARE @MY_E_ID bigint
  DECLARE @C_ID bigint
  DECLARE @E_ID bigint

  BEGIN TRY  

    SELECT @GETCID = PP_VAL
    FROM jsharmony.V_PP
     where PP_PROCESS = 'SQL'
     and PP_ATTRIB = 'GETCID';

    SELECT @GETEID = PP_VAL
    FROM jsharmony.V_PP
     where PP_PROCESS = 'SQL'
     and PP_ATTRIB = 'GETEID';

    SET @MYUSER = CASE WHEN @u IS NULL THEN jsharmony.myCUSER() ELSE @u END

    if (@OP = 'D')
  begin
    select top(1)
         @WK_C_ID = C_ID,
           @WK_E_ID = E_ID,
           @WK_REF_NAME = REF_NAME,
           @WK_REF_ID = REF_ID,
           @WK_SUBJ = SUBJ
      from jsharmony.AUD_H
         where TABLE_NAME = @tname
       and TABLE_ID = @tid
       and AUD_OP = 'I'
         order by AUD_SEQ desc; 
         if @@ROWCOUNT = 0
     begin

           if (@cid is null and @tname <> 'C')
       begin  
           SET @SQLCMD = 'select @my_c_id  = ' + @GETCID + '(''' + @tname + ''',' + convert(varchar,@tid) + ')'
           EXECUTE sp_executesql @SQLCMD, N'@my_c_id bigint OUTPUT', @MY_C_ID=@my_c_id OUTPUT
           SET @C_ID = @MY_C_ID
           end

           if (@eid is null and @tname <> 'E')
       begin  
           SET @SQLCMD = 'select @my_e_id  = ' + @GETEID + '(''' + @tname + ''',' + convert(varchar,@tid) + ')'
           EXECUTE sp_executesql @SQLCMD, N'@my_e_id bigint OUTPUT', @MY_E_ID=@my_e_id OUTPUT
           SET @E_ID = @MY_E_ID
       end

       select @WK_C_ID = case when @cid is not null then @cid
                              when @tname = 'C' then @tid 
                    else @C_ID end,  
              @WK_E_ID = case when @eid is not null then @eid
                              when @tname  = 'E' then @tid 
                  else @E_ID end, 
              @WK_REF_NAME = @ref_name,
              @WK_REF_ID = @ref_id,
              @WK_SUBJ = @subj;
     end
  end
    ELSE
  begin

        if (@cid is null and @tname <> 'C')
    begin 
        SET @SQLCMD = 'select @my_c_id  = ' + @GETCID + '(''' + @tname + ''',' + convert(varchar,@tid) + ')'
        EXECUTE sp_executesql @SQLCMD, N'@my_c_id bigint OUTPUT', @MY_C_ID=@my_c_id OUTPUT
        SET @C_ID = @MY_C_ID
        end

        if (@eid is null and @tname <> 'E')
    begin 
        SET @SQLCMD = 'select @my_e_id  = ' + @GETEID + '(''' + @tname + ''',' + convert(varchar,@tid) + ')'
        EXECUTE sp_executesql @SQLCMD, N'@my_e_id bigint OUTPUT', @MY_E_ID=@my_e_id OUTPUT
        SET @E_ID = @MY_E_ID
    end

    SET @WK_C_ID = case when @cid is not null then @cid
                        when @tname = 'C' then @tid 
              else @C_ID end;  
    SET @WK_E_ID = case when @eid is not null then @eid
                        when @tname = 'E' then @tid 
              else @E_ID end; 
    SET @WK_REF_NAME = @ref_name;
    SET @WK_REF_ID = @ref_id;
    SET @WK_SUBJ = @subj;
  end

    INSERT INTO jsharmony.AUD_H 
                    (TABLE_NAME, TABLE_ID, AUD_OP, AUD_U, AUD_Tstmp, C_ID, E_ID, REF_NAME, REF_ID, SUBJ) 
               VALUES (@tname, 
                 @tid, 
             @op, 
             @MYUSER, 
             @tstmp, 
             isnull(@cid, @WK_C_ID), 
             isnull(@eid, @WK_E_ID),
             @WK_REF_NAME,
             @WK_REF_ID,
             @WK_SUBJ)
    SET @MY_AUD_SEQ = SCOPE_IDENTITY() 
    
  END TRY
  BEGIN CATCH
    RETURN 0
  END CATCH
   
  RETURN @MY_AUD_SEQ
END


















GO
/****** Object:  StoredProcedure [jsharmony].[AUDH_BASE]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE  [jsharmony].[AUDH_BASE]
(
  @op           nvarchar(max),
  @tname        NVARCHAR(MAX),
  @tid          bigint,
  @u            NVARCHAR(MAX),
  @tstmp        DATETIME2(7),
  @ref_name     varchar(32) = NULL,
  @ref_id       bigint = NULL,
  @subj         nvarchar(255) = NULL
) 
as
BEGIN
  DECLARE @MY_AUD_SEQ BIGINT=0
  DECLARE @MYUSER NVARCHAR(MAX)
  DECLARE @WK_REF_NAME varchar(32) = NULL
  DECLARE @WK_REF_ID bigint = NULL
  DECLARE @WK_SUBJ nvarchar(255) = NULL
 
  BEGIN TRY  

    SET @MYUSER = CASE WHEN @u IS NULL THEN jsharmony.myCUSER() ELSE @u END

    if (@OP = 'D')
  begin
    select top(1)
           @WK_REF_NAME = REF_NAME,
           @WK_REF_ID = REF_ID,
           @WK_SUBJ = SUBJ
      from jsharmony.AUD_H
         where TABLE_NAME = @tname
       and TABLE_ID = @tid
       and AUD_OP = 'I'
         order by AUD_SEQ desc; 
         if @@ROWCOUNT = 0
     begin
       select @WK_REF_NAME = @ref_name,
              @WK_REF_ID = @ref_id,
              @WK_SUBJ = @subj;
     end
  end
    ELSE
  begin
    SET @WK_REF_NAME = @ref_name;
    SET @WK_REF_ID = @ref_id;
    SET @WK_SUBJ = @subj;
  end

    INSERT INTO jsharmony.AUD_H 
                    (TABLE_NAME, TABLE_ID, AUD_OP, AUD_U, AUD_Tstmp, REF_NAME, REF_ID, SUBJ) 
               VALUES (@tname, 
                 @tid, 
             @op, 
             @MYUSER, 
             @tstmp, 
             @WK_REF_NAME,
             @WK_REF_ID,
             @WK_SUBJ)
    SET @MY_AUD_SEQ = SCOPE_IDENTITY() 
    
  END TRY
  BEGIN CATCH
    RETURN 0
  END CATCH
   
  RETURN @MY_AUD_SEQ
END


















GO
/****** Object:  StoredProcedure [jsharmony].[CHECK_CODE]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE  [jsharmony].[CHECK_CODE]
(
  @in_tblname nvarchar(255),
  @in_codeval nvarchar(8)
) 
as
BEGIN

DECLARE @return_value int

BEGIN TRY
EXEC  @return_value = [jsharmony].[CHECK_CODE_P]
    @in_tblname = @in_tblname,
    @in_codeval = @in_codeval
END TRY 
BEGIN CATCH 
SELECT @return_value = -1
END CATCH

RETURN( @return_value)

END




GO
/****** Object:  StoredProcedure [jsharmony].[CHECK_CODE_P]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE  [jsharmony].[CHECK_CODE_P]
(
  @in_tblname nvarchar(255),
  @in_codeval nvarchar(8)
) 
as
BEGIN

  DECLARE @rslt INT
  DECLARE @runmesql NVARCHAR(512)

  SELECT @rslt = 0
  SELECT top(1)
         @runmesql = 'select @irslt = count(*) from ['+table_schema+'].[' + table_name + '] where codeval = ''' + 
                 isnull(@in_codeval,'') + ''''
    from information_schema.tables
   where table_name = @in_tblname
   order by (case table_schema when 'jsharmony' then 1 else 2 end),table_schema;

  exec sp_executesql @runmesql, N'@irslt bigint output', @irslt = @rslt output  
      
  return (@rslt)

END







GO
/****** Object:  StoredProcedure [jsharmony].[CHECK_CODE2]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE  [jsharmony].[CHECK_CODE2]
(
  @in_tblname nvarchar(255),
  @in_codeval1 nvarchar(8),
  @in_codeval2 nvarchar(8)
) 
as
BEGIN

DECLARE @return_value int

BEGIN TRY
EXEC  @return_value = [jsharmony].[CHECK_CODE2_P]
    @in_tblname = @in_tblname,
    @in_codeval1 = @in_codeval1,
    @in_codeval2 = @in_codeval2
END TRY 
BEGIN CATCH 
SELECT @return_value = -1
END CATCH

RETURN( @return_value)

END



GO
/****** Object:  StoredProcedure [jsharmony].[CHECK_CODE2_P]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE  [jsharmony].[CHECK_CODE2_P]
(
  @in_tblname nvarchar(255),
  @in_codeval1 nvarchar(8),
  @in_codeval2 nvarchar(8)
) 
as
BEGIN

  DECLARE @rslt INT
  DECLARE @runmesql NVARCHAR(512)

  SELECT @rslt = 0
  SELECT top(1)
         @runmesql = 'select @irslt = count(*) from ['+table_schema+'].[' + table_name + '] where codeval1 = ''' + 
                 isnull(@in_codeval1,'') + ''' and codeval2 = ''' + isnull(@in_codeval2,'') +  ''''
    from information_schema.tables
   where table_name = @in_tblname
   order by (case table_schema when 'jsharmony' then 1 else 2 end),table_schema;

  exec sp_executesql @runmesql, N'@irslt bigint output', @irslt = @rslt output  
      
  return (@rslt)

END






GO
/****** Object:  StoredProcedure [jsharmony].[CHECK_FOREIGN]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE  [jsharmony].[CHECK_FOREIGN]
(
  @in_tblname nvarchar(16),
  @in_tblid bigint
) 
as
BEGIN

DECLARE @return_value int

BEGIN TRY
EXEC  @return_value = [jsharmony].[CHECK_FOREIGN_P]
    @in_tblname = @in_tblname,
    @in_tblid = @in_tblid
END TRY 
BEGIN CATCH 
SELECT @return_value = -1
END CATCH

RETURN( @return_value)

END


GO
/****** Object:  StoredProcedure [jsharmony].[CHECK_FOREIGN_P]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE  [jsharmony].[CHECK_FOREIGN_P]
(
  @in_tblname nvarchar(16),
  @in_tblid bigint
) 
as
BEGIN

  DECLARE @rslt INT
  DECLARE @runmesql NVARCHAR(512)

  SELECT @rslt = 0
  SELECT top(1)
         @runmesql = 'select @irslt = count(*) from ['+table_schema+'].[' + table_name + '] where ' + table_name +
                     '_id = ' + CAST(@in_tblid AS VARCHAR(255)) 
    from information_schema.tables
   where table_name = @in_tblname
   order by (case table_schema when 'jsharmony' then 1 else 2 end),table_schema;

  exec sp_executesql @runmesql, N'@irslt bigint output', @irslt = @rslt output  
      
  return (@rslt)

END





GO
/****** Object:  StoredProcedure [jsharmony].[create_gcod]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [jsharmony].[create_gcod]
(
  @in_codeschema nvarchar(max),
  @in_codename   nvarchar(max),
  @in_codemean   nvarchar(max)
) 
as
BEGIN

  DECLARE @rslt INT = 0
  DECLARE @rrr NVARCHAR(max)
  DECLARE @rrrt NVARCHAR(max)

  select @rrr = SCRIPT_TXT
    from jsharmony.SCRIPT
   where SCRIPT_NAME = 'CREATE_GCOD';

  set @rrr = replace(@rrr, '%%%schema%%%', isnull(@in_codeschema,'dbo'))
  set @rrr = replace(@rrr, '%%%name%%%', @in_codename)
  set @rrr = replace(@rrr, '%%%mean%%%', @in_codemean)

  EXEC (@rrr)      

  select @rrrt = SCRIPT_TXT
    from jsharmony.SCRIPT
   where SCRIPT_NAME = 'CREATE_GCOD_TRIGGER';

  set @rrrt = replace(@rrrt, '%%%schema%%%', isnull(@in_codeschema,'dbo'))
  set @rrrt = replace(@rrrt, '%%%name%%%', @in_codename)
  set @rrrt = replace(@rrrt, '%%%mean%%%', @in_codemean)

  EXEC (@rrrt)      

  return (@rslt)

END






GO
GRANT EXECUTE ON [jsharmony].[create_gcod] TO [jsharmony_role_dev] AS [dbo]
GO
/****** Object:  StoredProcedure [jsharmony].[create_gcod2]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [jsharmony].[create_gcod2]
(
  @in_codeschema nvarchar(max),
  @in_codename   nvarchar(max),
  @in_codemean   nvarchar(max)
) 
as
BEGIN

  DECLARE @rslt INT = 0
  DECLARE @rrr NVARCHAR(max)
  DECLARE @rrrt NVARCHAR(max)

  select @rrr = SCRIPT_TXT
    from jsharmony.SCRIPT
   where SCRIPT_NAME = 'CREATE_GCOD2';

  set @rrr = replace(@rrr, '%%%schema%%%', isnull(@in_codeschema,'dbo'))
  set @rrr = replace(@rrr, '%%%name%%%', @in_codename)
  set @rrr = replace(@rrr, '%%%mean%%%', @in_codemean)

  EXEC (@rrr)      

  select @rrrt = SCRIPT_TXT
    from jsharmony.SCRIPT
   where SCRIPT_NAME = 'CREATE_GCOD2_TRIGGER';

  set @rrrt = replace(@rrrt, '%%%schema%%%', isnull(@in_codeschema,'dbo'))
  set @rrrt = replace(@rrrt, '%%%name%%%', @in_codename)
  set @rrrt = replace(@rrrt, '%%%mean%%%', @in_codemean)

  EXEC (@rrrt)      

  return (@rslt)

END






GO
GRANT EXECUTE ON [jsharmony].[create_gcod2] TO [jsharmony_role_dev] AS [dbo]
GO
/****** Object:  StoredProcedure [jsharmony].[create_ucod]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [jsharmony].[create_ucod]
(
  @in_codeschema nvarchar(max),
  @in_codename   nvarchar(max),
  @in_codemean   nvarchar(max)
) 
as
BEGIN

  DECLARE @rslt INT = 0
  DECLARE @rrr NVARCHAR(max)

  select @rrr = SCRIPT_TXT
    from jsharmony.SCRIPT
   where SCRIPT_NAME = 'CREATE_UCOD';

  set @rrr = replace(@rrr, '%%%schema%%%', isnull(@in_codeschema,'dbo'))
  set @rrr = replace(@rrr, '%%%name%%%', @in_codename)
  set @rrr = replace(@rrr, '%%%mean%%%', @in_codemean)

  EXEC (@rrr)      

  return (@rslt)

END






GO
GRANT EXECUTE ON [jsharmony].[create_ucod] TO [jsharmony_role_dev] AS [dbo]
GO
/****** Object:  StoredProcedure [jsharmony].[create_ucod2]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE  [jsharmony].[create_ucod2]
(
  @in_codeschema nvarchar(max),
  @in_codename   nvarchar(max),
  @in_codemean   nvarchar(max)
) 
as
BEGIN

  DECLARE @rslt INT = 0
  DECLARE @rrr NVARCHAR(max)

  select @rrr = SCRIPT_TXT
    from jsharmony.SCRIPT
   where SCRIPT_NAME = 'CREATE_UCOD2';

  set @rrr = replace(@rrr, '%%%schema%%%', isnull(@in_codeschema,'dbo'))
  set @rrr = replace(@rrr, '%%%name%%%', @in_codename)
  set @rrr = replace(@rrr, '%%%mean%%%', @in_codemean)

  EXEC (@rrr)      

  return (@rslt)

END






GO
GRANT EXECUTE ON [jsharmony].[create_ucod2] TO [jsharmony_role_dev] AS [dbo]
GO
/****** Object:  StoredProcedure [jsharmony].[ZZ-FILEDEBUG]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




/*@ SEND DEBUGGING INFO TO TEXT FILE @*/
CREATE PROCEDURE  [jsharmony].[ZZ-FILEDEBUG]
(
  @in_type nvarchar(MAX),
  @in_object nvarchar(MAX),
  @in_loc nvarchar(MAX),
  @in_txt nvarchar(MAX)
) 
as
BEGIN
  -- SET NOCOUNT ON added to prevent extra result sets from
  -- interfering with SELECT statements.
  SET NOCOUNT ON;

  DECLARE @dttm DATETIME = GETDATE() 
  DECLARE @sdttm VARCHAR(255)
  DECLARE @fname VARCHAR(255)
  DECLARE @mycmd VARCHAR(512)

  /*
  RETURN 0
  */

  SET @sdttm = SUBSTRING(CONVERT(VARCHAR(255), @dttm, 101),1,6) + 
               SUBSTRING(CONVERT(VARCHAR(255), @dttm, 101),9,2) + ' ' +
               SUBSTRING(CONVERT(VARCHAR(255), @dttm, 114),1,11) ; 
  SET @fname = '"c:\DBFILELogs\' + DB_NAME() +' '+ISNULL(APP_NAME(),'SYS')+' '+CONVERT(VARCHAR(255), @dttm,12)+'.log"' ;

  SET @mycmd = SUBSTRING('echo ' + @sdttm + '  ' + 
               ISNULL(@in_type,' ') + ' - ' +
               ISNULL(@in_object,' ') + ' - ' +
               ISNULL(@in_loc,' ') + ' - ' +
               ISNULL(@in_txt,' ') + ' ',1,900) +
               '>>' + @fname;
  
  EXEC xp_cmdshell @mycmd, NO_OUTPUT
  
  RETURN 0
/*
          INSERT INTO ZZ_LOG (LOG_PLACE, LOG_VALUE)
           VALUES('Q_UPDATE',
                 ' TP=' + @TP + 
                 ' D_QT_TNAME=' + @D_QT_TNAME + 
               ' D_Q_ID=' + LTRIM(RTRIM(ISNULL(STR(@D_Q_ID),'null'))) +
               ' D_CT_ID=' + LTRIM(RTRIM(ISNULL(STR(@D_CT_ID),'null'))) );
*/
END
















GO
/****** Object:  Trigger [jsharmony].[CPE_IUD]    Script Date: 10/25/2017 7:00:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [jsharmony].[CPE_IUD] on [jsharmony].[CPE]
for insert, update, delete
AS
BEGIN
  set nocount on
  DECLARE @TP char(1)
  DECLARE @CURDTTM DATETIME2(7)
  DECLARE @CURDTTM_CHAR NVARCHAR(MAX)
  DECLARE @MYUSER NVARCHAR(20)
  DECLARE @ERRTXT NVARCHAR(500)
  DECLARE @MY_AUD_SEQ NUMERIC(20,0)
  DECLARE CUR_CPE_IUD CURSOR LOCAL FOR
     SELECT  d.PE_ID, i.PE_ID,
           d.C_ID, i.C_ID,
           d.PE_STS, i.PE_STS,
           d.PE_FName, i.PE_FName,
       d.PE_MName, i.PE_MName,
       d.PE_LName, i.PE_LName,
             d.PE_JTitle, i.PE_JTitle,
             d.PE_BPhone, i.PE_BPhone,
             d.PE_CPhone, i.PE_CPhone,
             d.PE_Email, i.PE_Email,
             d.PE_PW1, i.PE_PW1,
             d.PE_PW2, i.PE_PW2,
       d.PE_LL_Tstmp, i.PE_LL_Tstmp
       FROM deleted d FULL OUTER JOIN inserted i
                       ON i.PE_ID = d.PE_ID;
  DECLARE @D_PE_ID bigint
  DECLARE @I_PE_ID bigint
  DECLARE @D_C_ID bigint
  DECLARE @I_C_ID bigint
  DECLARE @D_PE_STS NVARCHAR(MAX)
  DECLARE @I_PE_STS NVARCHAR(MAX)
  DECLARE @D_PE_FName NVARCHAR(MAX)
  DECLARE @I_PE_FName NVARCHAR(MAX)
  DECLARE @D_PE_MName NVARCHAR(MAX)
  DECLARE @I_PE_MName NVARCHAR(MAX)
  DECLARE @D_PE_LName NVARCHAR(MAX) 
  DECLARE @I_PE_LName NVARCHAR(MAX)
  DECLARE @D_PE_JTitle NVARCHAR(MAX) 
  DECLARE @I_PE_JTitle NVARCHAR(MAX)
  DECLARE @D_PE_BPhone NVARCHAR(MAX) 
  DECLARE @I_PE_BPhone NVARCHAR(MAX)
  DECLARE @D_PE_CPhone NVARCHAR(MAX) 
  DECLARE @I_PE_CPhone NVARCHAR(MAX)
  DECLARE @D_PE_Email NVARCHAR(MAX) 
  DECLARE @I_PE_Email NVARCHAR(MAX)
  DECLARE @D_PE_PW1 NVARCHAR(MAX) 
  DECLARE @I_PE_PW1 NVARCHAR(MAX)
  DECLARE @D_PE_PW2 NVARCHAR(MAX) 
  DECLARE @I_PE_PW2 NVARCHAR(MAX)
  DECLARE @D_PE_LL_TSTMP datetime2(7) 
  DECLARE @I_PE_LL_TSTMP datetime2(7)

  DECLARE @NEWPW nvarchar(max)

  DECLARE @MYERROR_NO INT = 0
  DECLARE @MYERROR_MSG NVARCHAR(MAX) = NULL

  DECLARE @xloc nvarchar(MAX)
  DECLARE @xtxt nvarchar(MAX)

  DECLARE @DYNSQL NVARCHAR(MAX)
  DECLARE @C BIGINT
  DECLARE @WK_PE_ID BIGINT
  DECLARE @WK_C_ID BIGINT
  DECLARE @WK_SUBJ NVARCHAR(MAX)
  DECLARE @CODEVAL NVARCHAR(MAX)
  DECLARE @UPDATE_PW CHAR(1)

  DECLARE @return_value int,
      @out_msg nvarchar(max),
      @out_rslt nvarchar(255),
      @hash varbinary(200),
      @M nvarchar(max)

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
  
  SET @CURDTTM = jsharmony.myNOW_DO()
  SET @CURDTTM_CHAR = CONVERT(NVARCHAR, @CURDTTM, 120)+'.0000000'
  SET @MYUSER = jsharmony.myCUSER() 

  IF @TP = 'U' AND UPDATE(PE_ID)
  BEGIN
    EXEC [jsharmony].[ZZ-FILEDEBUG] 'TRIGGER','CPE_IUD','ERR', 'Cannot update ID'
    raiserror('Cannot update identity',16,1)
    ROLLBACK TRANSACTION
    return
  END

  IF @TP = 'U' AND UPDATE(C_ID)
  BEGIN
    EXEC [jsharmony].[ZZ-FILEDEBUG] 'TRIGGER','CPE_IUD','ERR', 'Cannot update Customer ID'
    raiserror('Cannot update foreign key C_ID',16,1)
    ROLLBACK TRANSACTION
    return
  END

  
  OPEN CUR_CPE_IUD
  FETCH NEXT FROM CUR_CPE_IUD
        INTO @D_PE_ID, @I_PE_ID,
             @D_C_ID, @I_C_ID,
             @D_PE_STS, @I_PE_STS,
             @D_PE_FName, @I_PE_FName,
       @D_PE_MName, @I_PE_MName,
       @D_PE_LName, @I_PE_LName,
             @D_PE_JTitle, @I_PE_JTitle,
             @D_PE_BPhone, @I_PE_BPhone,
             @D_PE_CPhone, @I_PE_CPhone,
             @D_PE_Email, @I_PE_Email,
             @D_PE_PW1, @I_PE_PW1,
             @D_PE_PW2, @I_PE_PW2,
             @D_PE_LL_TSTMP, @I_PE_LL_TSTMP

  WHILE (@@Fetch_Status = 0)
  BEGIN

    SET @M = NULL
    SET @hash = NULL

  SET @NEWPW = NUll;
    SET @UPDATE_PW = 'N'

  SET @WK_C_ID = ISNULL(@I_C_ID,@D_C_ID)

    IF (@TP='I' or @TP='U')
  BEGIN
    if (jsharmony.NONEQUALC(@I_PE_PW1, @I_PE_PW2) > 0)
        SET @M = 'Application Error - New Password and Repeat Password are different'
    else if ((@TP='I' or isnull(@I_PE_PW1,'')>'') and len(ltrim(rtrim(isnull(@I_PE_PW1,'')))) < 6)
        SET @M = 'Application Error - Password length - at least 6 characters required'

      IF (@M is not null)
    BEGIN
        CLOSE CUR_CPE_IUD
        DEALLOCATE CUR_CPE_IUD
        raiserror(@M,16,1)
        ROLLBACK TRANSACTION
        return
      END
    ELSE
      SET @NEWPW = ltrim(rtrim(@I_PE_PW1))
  END

  /******************************************/
  /****** SPECIAL FRONT ACTION - BEGIN ******/
  /******************************************/


    IF (@TP='I' 
      OR 
    @TP='U' AND jsharmony.NONEQUALN(@D_C_ID, @I_C_ID) > 0)
  BEGIN
    EXEC  @C = [jsharmony].[CHECK_FOREIGN]
        @in_tblname ='C',
        @in_tblid = @I_C_ID
    IF @C <= 0
    BEGIN
      CLOSE CUR_CPE_IUD
      DEALLOCATE CUR_CPE_IUD
      SET @M = 'Table C does not contain record ' + CONVERT(NVARCHAR(MAX),@I_C_ID)
      raiserror(@M ,16,1)
      ROLLBACK TRANSACTION
      return
    END 
  END   

    IF (@TP='I')
  BEGIN

    set @hash = jsharmony.myHASH('C', @I_PE_ID, @NEWPW);

    if (@hash is null)
      BEGIN
        CLOSE CUR_CPE_IUD
        DEALLOCATE CUR_CPE_IUD
        SET @M = 'Application Error - Missing or Incorrect Password'
        raiserror(@M,16,1)
        ROLLBACK TRANSACTION
        return
      END

      UPDATE jsharmony.CPE
       SET PE_STSDt = @CURDTTM,
         PE_ETstmp = @CURDTTM,
       PE_EU = @MYUSER,
         PE_MTstmp = @CURDTTM,
       PE_MU = @MYUSER,
       PE_Hash = @hash,
       PE_PW1 = NULL,
       PE_PW2 = NULL
       WHERE CPE.PE_ID = @I_PE_ID;

      INSERT INTO jsharmony.CPER (PE_ID, CR_NAME)
               VALUES(@I_PE_ID, 'C*');

    END  

    SET @WK_SUBJ = ISNULL(@I_PE_LNAME,'')+', '+ISNULL(@I_PE_FNAME,'') 

  /******************************************/
  /****** SPECIAL FRONT ACTION - END   ******/
  /******************************************/

    SET @MY_AUD_SEQ = 0
  IF (@TP='I' OR @TP='D')
  BEGIN  
    SET @WK_PE_ID = ISNULL(@D_PE_ID,@I_PE_ID)
    EXEC  @MY_AUD_SEQ = jsharmony.AUDH @TP, 'CPE', @WK_PE_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ,@WK_C_ID
  END
 
    IF @TP='U' OR @TP='D'
  BEGIN

      IF (@TP = 'D' AND @D_C_ID IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALC(@D_C_ID, @I_C_ID) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH 'U', 'CPE', @I_PE_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ,@WK_C_ID
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'C_ID', @D_C_ID)
      END

      IF (@TP = 'D' AND @D_PE_STS IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALC(@D_PE_STS, @I_PE_STS) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH 'U', 'CPE', @I_PE_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ,@WK_C_ID
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'PE_STS', @D_PE_STS)
      END

      IF (@TP = 'D' AND @D_PE_FName IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALC(@D_PE_FName, @I_PE_FName) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH 'U', 'CPE', @I_PE_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ,@WK_C_ID
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'PE_FName', @D_PE_FName)
      END

      IF (@TP = 'D' AND @D_PE_MName IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALC(@D_PE_MName, @I_PE_MName) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH 'U', 'CPE', @I_PE_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ,@WK_C_ID
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'PE_MName', @D_PE_MName)
      END

      IF (@TP = 'D' AND @D_PE_LName IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALC(@D_PE_LName, @I_PE_LName) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH 'U', 'CPE', @I_PE_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ,@WK_C_ID
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'PE_LName', @D_PE_LName)
      END

      IF (@TP = 'D' AND @D_PE_JTitle IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALC(@D_PE_JTitle, @I_PE_JTitle) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH 'U', 'CPE', @I_PE_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ,@WK_C_ID
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'PE_JTitle', @D_PE_JTitle)
      END

      IF (@TP = 'D' AND @D_PE_BPhone IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALC(@D_PE_BPhone, @I_PE_BPhone) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH 'U', 'CPE', @I_PE_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ,@WK_C_ID
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'PE_BPhone', @D_PE_BPhone)
      END

      IF (@TP = 'D' AND @D_PE_CPhone IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALC(@D_PE_CPhone, @I_PE_CPhone) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH 'U', 'CPE', @I_PE_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ,@WK_C_ID
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'PE_CPhone', @D_PE_CPhone)
      END

      IF (@TP = 'D' AND @D_PE_Email IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALC(@D_PE_Email, @I_PE_Email) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH 'U', 'CPE', @I_PE_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ,@WK_C_ID
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'PE_Email', @D_PE_Email)
      END

      IF (@TP = 'D' AND @D_PE_LL_TSTMP IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALD(@D_PE_LL_TSTMP, @I_PE_LL_TSTMP) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH 'U', 'CPE', @I_PE_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ,@WK_C_ID
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'PE_LL_TSTMP', @D_PE_LL_TSTMP)
      END

    IF (@TP = 'U' AND isnull(@NEWPW,'') <> '')
    BEGIN
    set @hash = jsharmony.myHASH('C', @I_PE_ID, @NEWPW);

    if (@hash is null)
    BEGIN
      CLOSE CUR_CPE_IUD
      DEALLOCATE CUR_CPE_IUD
      SET @M = 'Application Error - Incorrect Password'
      raiserror(@M,16,1)
      ROLLBACK TRANSACTION
      return
    END

        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH 'U', 'CPE', @I_PE_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ,@WK_C_ID
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'PE_PW', '*')

      SET @UPDATE_PW = 'Y'
    END


    END  /* END OF "IF @TP='U' OR @TP='D'"  */


  /******************************************/
  /****** SPECIAL BACK ACTION - BEGIN  ******/
  /******************************************/

    IF (@TP='U' AND @MY_AUD_SEQ <> 0)
  BEGIN
      UPDATE jsharmony.CPE
       SET PE_STSDt = CASE WHEN jsharmony.NONEQUALC(@D_PE_STS, @I_PE_STS) > 0 THEN @CURDTTM ELSE PE_STSDt END,
         PE_MTstmp = @CURDTTM,
       PE_MU = @MYUSER,
       PE_Hash = case @UPDATE_PW when 'Y' then @hash else PE_Hash end,
       PE_PW1 = NULL,
       PE_PW2 = NULL
       WHERE CPE.PE_ID = @I_PE_ID;
    END  
    ELSE IF (@TP='U' AND (@I_PE_PW1 is not null or @I_PE_PW2 is not null))
  BEGIN
      UPDATE jsharmony.CPE
       SET PE_PW1 = NULL,
       PE_PW2 = NULL
       WHERE CPE.PE_ID = @I_PE_ID;
    END  

  /*****************************************/
  /****** SPECIAL BACK ACTION - END   ******/
  /*****************************************/



            
    FETCH NEXT FROM CUR_CPE_IUD
        INTO @D_PE_ID, @I_PE_ID,
             @D_C_ID, @I_C_ID,
             @D_PE_STS, @I_PE_STS,
             @D_PE_FName, @I_PE_FName,
       @D_PE_MName, @I_PE_MName,
       @D_PE_LName, @I_PE_LName,
             @D_PE_JTitle, @I_PE_JTitle,
             @D_PE_BPhone, @I_PE_BPhone,
             @D_PE_CPhone, @I_PE_CPhone,
             @D_PE_Email, @I_PE_Email,
             @D_PE_PW1, @I_PE_PW1,
             @D_PE_PW2, @I_PE_PW2,
             @D_PE_LL_TSTMP, @I_PE_LL_TSTMP

  END
  CLOSE CUR_CPE_IUD
  DEALLOCATE CUR_CPE_IUD

  /*
  EXEC [jsharmony].[ZZ-FILEDEBUG] 'TRIGGER','CPE_IUD','RETURN', ''
  */

  RETURN

END
GO
ALTER TABLE [jsharmony].[CPE] ENABLE TRIGGER [CPE_IUD]
GO
/****** Object:  Trigger [jsharmony].[CPER_IUD]    Script Date: 10/25/2017 7:00:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [jsharmony].[CPER_IUD] on [jsharmony].[CPER]
for insert, update, delete
AS
BEGIN
  set nocount on
  DECLARE @TP char(1)
  DECLARE @CURDTTM DATETIME2(7)
  DECLARE @CURDTTM_CHAR NVARCHAR(MAX)
  DECLARE @MYUSER NVARCHAR(20)
  DECLARE @ERRTXT NVARCHAR(500)
  DECLARE @MY_AUD_SEQ NUMERIC(20,0)
  DECLARE CUR_CPER_IUD CURSOR LOCAL FOR
     SELECT  d.CPER_ID, i.CPER_ID,
           d.PE_ID, i.PE_ID,
           d.CR_NAME, i.CR_NAME
       FROM deleted d FULL OUTER JOIN inserted i
                       ON i.CPER_ID = d.CPER_ID;
  DECLARE @D_CPER_ID bigint
  DECLARE @I_CPER_ID bigint
  DECLARE @D_PE_ID bigint
  DECLARE @I_PE_ID bigint
  DECLARE @D_CR_NAME nvarchar(max)
  DECLARE @I_CR_NAME nvarchar(max)

  DECLARE @MYERROR_NO INT = 0
  DECLARE @MYERROR_MSG NVARCHAR(MAX) = NULL
  DECLARE @WK_CPER_ID bigint
  DECLARE @WK_SUBJ NVARCHAR(MAX)

  DECLARE @xloc nvarchar(MAX)
  DECLARE @xtxt nvarchar(MAX)

  DECLARE @DYNSQL NVARCHAR(MAX)
  DECLARE @C BIGINT
  DECLARE @CODEVAL NVARCHAR(MAX)

  /*
  EXEC [jsharmony].[ZZ-FILEDEBUG] 'TRIGGER','CPER_IUD','START', ''
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
  
  SET @CURDTTM = jsharmony.myNOW_DO()
  SET @CURDTTM_CHAR = CONVERT(NVARCHAR, @CURDTTM, 120)+'.0000000'
  SET @MYUSER = jsharmony.myCUSER() 

  IF @TP = 'U' AND UPDATE(CPER_ID)
  BEGIN
    EXEC [jsharmony].[ZZ-FILEDEBUG] 'TRIGGER','CPER_IUD','ERR', 'Cannot update ID'
    raiserror('Cannot update identity',16,1)
    ROLLBACK TRANSACTION
    return
  END

  IF @TP = 'U' AND UPDATE(PE_ID)
  BEGIN
    EXEC [jsharmony].[ZZ-FILEDEBUG] 'TRIGGER','CPER_IUD','ERR', 'Cannot update PE_ID'
    raiserror('Cannot update foreign key',16,1)
    ROLLBACK TRANSACTION
    return
  END

  
  OPEN CUR_CPER_IUD
  FETCH NEXT FROM CUR_CPER_IUD
        INTO @D_CPER_ID, @I_CPER_ID,
             @D_PE_ID, @I_PE_ID,
             @D_CR_NAME, @I_CR_NAME

  WHILE (@@Fetch_Status = 0)
  BEGIN
      
    SET @xloc = 'TP=' + ISNULL(@TP,'null')
  SET @xtxt = 'I_CPER_ID=' + LTRIM(ISNULL(STR(@I_CPER_ID),'null')) +
              ' D_CPER_ID=' + LTRIM(ISNULL(STR(@D_CPER_ID),'null')) 
    /*
    EXEC [jsharmony].[ZZ-FILEDEBUG] 'TRIGGER','CPER_IUD',@xloc, @xtxt
  */

  /******************************************/
  /****** SPECIAL FRONT ACTION - BEGIN ******/
  /******************************************/
  
    SELECT @WK_SUBJ = isnull(PE_LNAME,'')+', '+isnull(PE_FNAME,'')
    FROM jsharmony.CPE
     WHERE PE_ID = @I_PE_ID; 


/*
  THIS CODE DOES NOT BELONG IN jsharmony trigger - IT IS REQUIRED FOR BETTER PROTECTION IN ATRAX
  BUT COULD BE SKIPPED

    IF @I_CR_NAME IS NOT NULL
     AND
     @I_PE_ID IS NOT NULL
    BEGIN

    IF EXISTS (select 1
                 from CF
                  inner join jsharmony.CPE on CPE.C_ID = CF.C_ID
                  where CPE.PE_ID = @I_PE_ID
            and CF.CF_TYPE = 'LVL2')
      BEGIN
      IF @I_CR_NAME not in ('C*','CUSER','CMGR','CADMIN')
        BEGIN
          EXEC [jsharmony].[ZZ-FILEDEBUG] 'TRIGGER','CPER_IUD','ERR', 'Invalid Role'
          raiserror('Role not compatible with LVL2',16,1)
          ROLLBACK TRANSACTION
          return
        END
    END
    ELSE
    BEGIN
      IF @I_CR_NAME not in ('C*','CL1')
        BEGIN
          EXEC [jsharmony].[ZZ-FILEDEBUG] 'TRIGGER','CPER_IUD','ERR', 'Invalid Role'
          raiserror('Role not compatible with LVL1',16,1)
          ROLLBACK TRANSACTION
          return
        END
    END

  END
*/


  /******************************************/
  /****** SPECIAL FRONT ACTION - END   ******/
  /******************************************/

    SET @MY_AUD_SEQ = 0
  IF (@TP='I' OR @TP='D')
  BEGIN  
    SET @WK_CPER_ID = ISNULL(@D_CPER_ID,@I_CPER_ID)
    EXEC  @MY_AUD_SEQ = jsharmony.AUDH @TP, 'CPER', @WK_CPER_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ
  END

    IF @TP='U' OR @TP='D'
  BEGIN

      IF (@TP = 'D' AND @D_PE_ID IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALN(@D_PE_ID, @I_PE_ID) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH 'U', 'CPER', @I_CPER_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'PE_ID', @D_PE_ID)
      END

      IF (@TP = 'D' AND @D_CR_NAME IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALC(@D_CR_NAME, @I_CR_NAME) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH 'U', 'CPER', @I_CPER_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'CR_NAME', @D_CR_NAME)
      END

    END  /* END OF "IF @TP='U' OR @TP='D'"  */

  /******************************************/
  /****** SPECIAL BACK ACTION - BEGIN  ******/
  /******************************************/

  /*****************************************/
  /****** SPECIAL BACK ACTION - END   ******/
  /*****************************************/
            
    FETCH NEXT FROM CUR_CPER_IUD
          INTO @D_CPER_ID, @I_CPER_ID,
               @D_PE_ID,  @I_PE_ID,
               @D_CR_NAME,  @I_CR_NAME
  END
  CLOSE CUR_CPER_IUD
  DEALLOCATE CUR_CPER_IUD
  /*
  EXEC [jsharmony].[ZZ-FILEDEBUG] 'TRIGGER','CPER_IUD','RETURN', ''
  */
  RETURN

END
GO
ALTER TABLE [jsharmony].[CPER] ENABLE TRIGGER [CPER_IUD]
GO
/****** Object:  Trigger [jsharmony].[D_IUD]    Script Date: 10/25/2017 7:00:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE trigger [jsharmony].[D_IUD] on [jsharmony].[D]
for insert, update, delete
AS
BEGIN
  set nocount on
  DECLARE @TP char(1)
  DECLARE @CURDTTM DATETIME2(7)
  DECLARE @CURDTTM_CHAR NVARCHAR(MAX)
  DECLARE @MYUSER NVARCHAR(20)
  DECLARE @ERRTXT NVARCHAR(500)
  DECLARE @MY_AUD_SEQ NUMERIC(20,0)
  DECLARE CUR_D_IUD CURSOR LOCAL FOR
     SELECT  d.D_ID, i.D_ID,
           d.D_SCOPE, i.D_SCOPE,
           d.D_SCOPE_ID, i.D_SCOPE_ID,
           d.D_STS, i.D_STS,
       d.D_CTGR, i.D_CTGR,
       d.D_Desc, i.D_Desc,
       d.D_UTSTMP, i.D_UTSTMP,
       d.D_UU, i.D_UU,
       d.D_SYNCTSTMP, i.D_SYNCTSTMP,
       d.C_ID, i.C_ID,
       d.E_ID, i.E_ID
       FROM deleted d FULL OUTER JOIN inserted i
                       ON i.D_ID = d.D_ID;
  DECLARE @D_D_ID bigint
  DECLARE @I_D_ID bigint
  DECLARE @D_D_SCOPE NVARCHAR(MAX)
  DECLARE @I_D_SCOPE NVARCHAR(MAX)
  DECLARE @D_D_SCOPE_ID bigint
  DECLARE @I_D_SCOPE_ID bigint
  DECLARE @D_D_STS NVARCHAR(MAX)
  DECLARE @I_D_STS NVARCHAR(MAX)
  DECLARE @D_D_CTGR NVARCHAR(MAX)
  DECLARE @I_D_CTGR NVARCHAR(MAX)
  DECLARE @D_D_Desc NVARCHAR(MAX) 
  DECLARE @I_D_Desc NVARCHAR(MAX)
  DECLARE @D_D_UTSTMP datetime2(7) 
  DECLARE @I_D_UTSTMP datetime2(7)
  DECLARE @D_D_UU NVARCHAR(MAX) 
  DECLARE @I_D_UU NVARCHAR(MAX)
  DECLARE @D_D_SYNCTSTMP datetime2(7) 
  DECLARE @I_D_SYNCTSTMP datetime2(7)
  DECLARE @D_C_ID bigint 
  DECLARE @I_C_ID bigint
  DECLARE @D_E_ID bigint 
  DECLARE @I_E_ID bigint

  DECLARE @MYERROR_NO INT = 0
  DECLARE @MYERROR_MSG NVARCHAR(MAX) = NULL

  DECLARE @xloc nvarchar(MAX)
  DECLARE @xtxt nvarchar(MAX)

  DECLARE @DYNSQL NVARCHAR(MAX)
  DECLARE @C BIGINT
  DECLARE @WK_D_ID BIGINT
  DECLARE @WK_REF_NAME NVARCHAR(MAX)
  DECLARE @WK_REF_ID BIGINT
  DECLARE @M NVARCHAR(MAX)
  DECLARE @CODEVAL NVARCHAR(MAX)
  DECLARE @CPE_USER BIT
  DECLARE @USER_C_ID BIGINT

  DECLARE @SQLCMD nvarchar(max)
  DECLARE @GETCID nvarchar(max)
  DECLARE @GETEID nvarchar(max)
  DECLARE @DSCOPE_DCTGR nvarchar(max)
  DECLARE @MY_C_ID bigint
  DECLARE @MY_E_ID bigint
  DECLARE @C_ID bigint
  DECLARE @E_ID bigint

  DECLARE @DB_K NVARCHAR(MAX)
  DECLARE @DB_OUT datetime2(7)

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
  
  SET @CURDTTM = jsharmony.myNOW_DO()
  SET @CURDTTM_CHAR = CONVERT(NVARCHAR, @CURDTTM, 120)+'.0000000'
  SET @MYUSER = jsharmony.myCUSER() 

  IF @TP = 'U' AND UPDATE(D_ID)
  BEGIN
    EXEC [jsharmony].[ZZ-FILEDEBUG] 'TRIGGER','D_IUD','ERR', 'Cannot update ID'
    raiserror('Cannot update identity',16,1)
    ROLLBACK TRANSACTION
    return
  END

  IF @TP = 'U' AND UPDATE(D_SCOPE)
  BEGIN
    EXEC [jsharmony].[ZZ-FILEDEBUG] 'TRIGGER','D_IUD','ERR', 'Cannot update D_SCOPE'
    raiserror('Cannot update foreign key D_SCOPE',16,1)
    ROLLBACK TRANSACTION
    return
  END

  IF @TP = 'U' AND UPDATE(D_SCOPE_ID)
  BEGIN
    EXEC [jsharmony].[ZZ-FILEDEBUG] 'TRIGGER','D_IUD','ERR', 'Cannot update D_SCOPE_ID'
    raiserror('Cannot update foreign key D_SCOPE_ID',16,1)
    ROLLBACK TRANSACTION
    return
  END

  SELECT @DSCOPE_DCTGR = PP_VAL
  FROM jsharmony.V_PP
   where PP_PROCESS = 'SQL'
   and PP_ATTRIB = 'DSCOPE_DCTGR';
  IF (@TP='I' OR @TP='U') AND @DSCOPE_DCTGR IS NULL
  BEGIN
    raiserror('DSCOPE_DCTGR parameter not set',16,1)
    ROLLBACK TRANSACTION
    return
  END

  SELECT @GETCID = PP_VAL
  FROM jsharmony.V_PP
   where PP_PROCESS = 'SQL'
   and PP_ATTRIB = 'GETCID';

  SELECT @GETEID = PP_VAL
  FROM jsharmony.V_PP
   where PP_PROCESS = 'SQL'
   and PP_ATTRIB = 'GETEID';

  
  OPEN CUR_D_IUD
  FETCH NEXT FROM CUR_D_IUD
        INTO @D_D_ID, @I_D_ID,
             @D_D_SCOPE, @I_D_SCOPE,
             @D_D_SCOPE_ID, @I_D_SCOPE_ID,
             @D_D_STS, @I_D_STS,
       @D_D_CTGR, @I_D_CTGR,
       @D_D_Desc, @I_D_Desc,
       @D_D_UTstmp, @I_D_UTstmp,
       @D_D_UU, @I_D_UU,
       @D_D_SYNCTstmp, @I_D_SYNCTstmp,
       @D_C_ID, @I_C_ID,
       @D_E_ID, @I_E_ID

  WHILE (@@Fetch_Status = 0)
  BEGIN
    

  /******************************************/
  /****** SPECIAL FRONT ACTION - BEGIN ******/
  /******************************************/

 
    IF (@TP='I' 
      OR 
    @TP='U' AND (jsharmony.nonequalc(@D_D_SCOPE, @I_D_SCOPE)>0
                 OR
           jsharmony.nonequaln(@D_D_SCOPE_ID, @I_D_SCOPE_ID)>0))
  BEGIN
    IF @I_D_SCOPE = 'S' AND @I_D_SCOPE_ID <> 0
       OR
       @I_D_SCOPE <> 'S' AND @I_D_SCOPE_ID is NULL
    BEGIN
      CLOSE CUR_D_IUD
      DEALLOCATE CUR_D_IUD
      SET @M = 'SCOPE ID INCONSISTENT WITH SCOPE'
      raiserror(@M ,16,1)
      ROLLBACK TRANSACTION
      return
    END 
  END   
 
    IF (@TP='I' OR @TP='U')
  BEGIN
    EXEC  @C = [jsharmony].[CHECK_FOREIGN]
        @in_tblname = @I_D_SCOPE,
        @in_tblid = @I_D_SCOPE_ID
    IF @C <= 0
    BEGIN
      CLOSE CUR_D_IUD
      DEALLOCATE CUR_D_IUD
      SET @M = 'Table ' + @I_D_SCOPE + ' does not contain record ' + CONVERT(NVARCHAR(MAX),@I_D_SCOPE_ID)
      raiserror(@M ,16,1)
      ROLLBACK TRANSACTION
      return
    END 
  END   


 
    IF (@TP='I' OR @TP='U')
  BEGIN
      SET @DSCOPE_DCTGR = isnull(@DSCOPE_DCTGR,'')
    EXEC  @C = [jsharmony].[CHECK_CODE2]
        @in_tblname = @DSCOPE_DCTGR,
        @in_codeval1 = @I_D_SCOPE,
        @in_codeval2 = @I_D_CTGR
    IF @C <= 0
    BEGIN
      CLOSE CUR_D_IUD
      DEALLOCATE CUR_D_IUD
      SET @M = 'Document Type not allowed for selected Scope'
      raiserror(@M ,16,1)
      ROLLBACK TRANSACTION
      return
    END 
  END   


    SET @CPE_USER = 0
  SET @USER_C_ID = NULL   
    IF SUBSTRING(@MYUSER,1,1) = 'C'
  BEGIN
    SELECT @USER_C_ID = C_ID
      FROM jsharmony.CPE
       WHERE substring(@MYUSER,2,1024)=convert(varchar, PE_ID);   
    
    IF @USER_C_ID is not null
      SET @CPE_USER = 1
  END

  SET @SQLCMD = 'select @my_c_id  = ' + @GETCID + '(''' + isnull(isnull(@I_D_SCOPE,@D_D_SCOPE),'') + ''',' +
                      isnull(convert(nvarchar,isnull(@I_D_SCOPE_ID,@D_D_SCOPE_ID)),'') + ')'
  EXECUTE sp_executesql @SQLCMD, N'@my_c_id bigint OUTPUT', @MY_C_ID=@my_c_id OUTPUT
  SET @C_ID = @MY_C_ID

  SET @SQLCMD = 'select @my_e_id  = ' + @GETEID + '(''' + isnull(isnull(@I_D_SCOPE,@D_D_SCOPE),'') + ''',' +
                      isnull(convert(nvarchar,isnull(@I_D_SCOPE_ID,@D_D_SCOPE_ID)),'') + ')'
  EXECUTE sp_executesql @SQLCMD, N'@my_e_id bigint OUTPUT', @MY_E_ID=@my_e_id OUTPUT
  SET @E_ID = @MY_E_ID





    IF (@CPE_USER = 1)
  BEGIN

    IF @USER_C_ID <> isnull(@C_ID,0)
       OR
         isnull(@I_D_SCOPE,@D_D_SCOPE) not in 
                  (select CODEVAL
               from jsharmony.UCOD_D_SCOPE
                        where CODECODE = 'Y')
    BEGIN
    CLOSE CUR_D_IUD
    DEALLOCATE CUR_D_IUD
    SET @M = 'Application Error - Client User has no rights to perform this operation'
    raiserror(@M ,16,1)
    ROLLBACK TRANSACTION
      return
    END 

    END

    IF (@TP='I')
  BEGIN

      IF @C_ID is not null
    BEGIN
    EXEC  @C = [jsharmony].[CHECK_FOREIGN]
        @in_tblname ='C',
        @in_tblid = @C_ID
    IF @C <= 0
    BEGIN
      CLOSE CUR_D_IUD
      DEALLOCATE CUR_D_IUD
      SET @M = 'Table C does not contain record ' + CONVERT(NVARCHAR(MAX),@C_ID)
      raiserror(@M ,16,1)
      ROLLBACK TRANSACTION
      return
    END 
    END   

      IF @E_ID is not null
    BEGIN
    EXEC  @C = [jsharmony].[CHECK_FOREIGN]
        @in_tblname ='E',
        @in_tblid = @E_ID
    IF @C <= 0
    BEGIN
      CLOSE CUR_D_IUD
      DEALLOCATE CUR_D_IUD
      SET @M = 'Table E does not contain record ' + CONVERT(NVARCHAR(MAX),@E_ID)
      raiserror(@M ,16,1)
      ROLLBACK TRANSACTION
      return
    END 
    END   

    IF (@I_D_SYNCTSTMP is null)
        UPDATE jsharmony.D
       SET C_ID = @C_ID,
         E_ID = @E_ID,
         D_ETstmp = @CURDTTM,
       D_EU = @MYUSER,
         D_MTstmp = @CURDTTM,
       D_MU = @MYUSER
         WHERE D.D_ID = @I_D_ID;
    END  

    IF (@TP='U')
  BEGIN

      IF @I_C_ID is not null
       and
     jsharmony.NONEQUALN(@D_C_ID, @I_C_ID) > 0
    BEGIN
    EXEC  @C = [jsharmony].[CHECK_FOREIGN]
        @in_tblname ='C',
        @in_tblid = @I_C_ID
    IF @C <= 0
    BEGIN
      CLOSE CUR_D_IUD
      DEALLOCATE CUR_D_IUD
      SET @M = 'Table C does not contain record ' + CONVERT(NVARCHAR(MAX),@I_C_ID)
      raiserror(@M ,16,1)
      ROLLBACK TRANSACTION
      return
    END 
    END   

      IF @I_E_ID is not null
       and
     jsharmony.NONEQUALN(@D_E_ID, @I_E_ID) > 0
    BEGIN
    EXEC  @C = [jsharmony].[CHECK_FOREIGN]
        @in_tblname ='E',
        @in_tblid = @I_E_ID
    IF @C <= 0
    BEGIN
      CLOSE CUR_D_IUD
      DEALLOCATE CUR_D_IUD
      SET @M = 'Table E does not contain record ' + CONVERT(NVARCHAR(MAX),@I_E_ID)
      raiserror(@M ,16,1)
      ROLLBACK TRANSACTION
      return
    END 
    END
       
    END





  /******************************************/
  /****** SPECIAL FRONT ACTION - END   ******/
  /******************************************/


    SET @MY_AUD_SEQ = 0
  IF (@TP='I' OR @TP='D')
  BEGIN  
    SET @WK_D_ID = ISNULL(@D_D_ID,@I_D_ID)
    SET @WK_REF_NAME = ISNULL(@D_D_SCOPE,@I_D_SCOPE)
    SET @WK_REF_ID = ISNULL(@D_D_SCOPE_ID,@I_D_SCOPE_ID)
    EXEC  @MY_AUD_SEQ = jsharmony.AUDH @TP, 'D', @WK_D_ID, @MYUSER, @CURDTTM, @WK_REF_NAME, @WK_REF_ID, default, @C_ID, @E_ID
  END

 
    IF @TP='U' OR @TP='D'
  BEGIN

      IF (@TP = 'D' AND @D_D_SCOPE IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALC(@D_D_SCOPE, @I_D_SCOPE) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH 'U', 'D', @I_D_ID, @MYUSER, @CURDTTM, @I_D_SCOPE, @I_D_SCOPE_ID, default, @C_ID, @E_ID
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'D_SCOPE', @D_D_SCOPE)
      END

      IF (@TP = 'D' AND @D_D_SCOPE_ID IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALN(@D_D_SCOPE_ID, @I_D_SCOPE_ID) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH 'U', 'D', @I_D_ID, @MYUSER, @CURDTTM, @I_D_SCOPE, @I_D_SCOPE_ID, default, @C_ID, @E_ID
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'D_SCOPE_ID', @D_D_SCOPE_ID)
      END

      IF (@TP = 'D' AND @D_D_STS IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALC(@D_D_STS, @I_D_STS) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH 'U', 'D', @I_D_ID, @MYUSER, @CURDTTM, @I_D_SCOPE, @I_D_SCOPE_ID, default, @C_ID, @E_ID
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'D_STS', @D_D_STS)
      END

      IF (@TP = 'D' AND @D_D_CTGR IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALC(@D_D_CTGR, @I_D_CTGR) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH 'U', 'D', @I_D_ID, @MYUSER, @CURDTTM, @I_D_SCOPE, @I_D_SCOPE_ID, default, @C_ID, @E_ID
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'D_CTGR', @D_D_CTGR)
      END

      IF (@TP = 'D' AND @D_D_Desc IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALC(@D_D_Desc, @I_D_Desc) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH 'U', 'D', @I_D_ID, @MYUSER, @CURDTTM, @I_D_SCOPE, @I_D_SCOPE_ID, default, @C_ID, @E_ID
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'D_Desc', @D_D_Desc)
      END

      IF (@TP = 'D' AND @D_D_UTSTMP IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALD(@D_D_UTSTMP, @I_D_UTSTMP) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH 'U', 'D', @I_D_ID, @MYUSER, @CURDTTM, @I_D_SCOPE, @I_D_SCOPE_ID, default, @C_ID, @E_ID
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'D_UTSTMP', @D_D_UTSTMP)
      END

      IF (@TP = 'D' AND @D_D_UU IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALC(@D_D_UU, @I_D_UU) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH 'U', 'D', @I_D_ID, @MYUSER, @CURDTTM, @I_D_SCOPE, @I_D_SCOPE_ID, default, @C_ID, @E_ID
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'D_UU', @D_D_UU)
      END

      IF (@TP = 'D' AND @D_C_ID IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALN(@D_C_ID, @I_C_ID) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH 'U', 'D', @I_D_ID, @MYUSER, @CURDTTM, @I_D_SCOPE, @I_D_SCOPE_ID, default, @C_ID, @E_ID
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'C_ID', @D_C_ID)
      END

      IF (@TP = 'D' AND @D_E_ID IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALN(@D_E_ID, @I_E_ID) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH 'U', 'D', @I_D_ID, @MYUSER, @CURDTTM, @I_D_SCOPE, @I_D_SCOPE_ID, default, @C_ID, @E_ID
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'E_ID', @D_E_ID)
      END


    END  /* END OF "IF @TP='U' OR @TP='D'"  */


  /******************************************/
  /****** SPECIAL BACK ACTION - BEGIN  ******/
  /******************************************/

    IF (@TP='U' AND @MY_AUD_SEQ <> 0)
  BEGIN
    if (jsharmony.NONEQUALD(@D_D_SYNCTstmp, @I_D_SYNCTstmp) <= 0)
        UPDATE jsharmony.D
       SET D_MTstmp = @CURDTTM,
       D_MU = @MYUSER,
       D_SYNCTstmp = NULL
         WHERE D.D_ID = @I_D_ID;
    END  

  /*****************************************/
  /****** SPECIAL BACK ACTION - END   ******/
  /*****************************************/



            
    FETCH NEXT FROM CUR_D_IUD
        INTO @D_D_ID, @I_D_ID,
             @D_D_SCOPE,  @I_D_SCOPE,
             @D_D_SCOPE_ID, @I_D_SCOPE_ID,
             @D_D_STS, @I_D_STS,
       @D_D_CTGR, @I_D_CTGR,
       @D_D_Desc, @I_D_Desc,
       @D_D_UTstmp, @I_D_UTstmp,
       @D_D_UU, @I_D_UU,
       @D_D_SYNCTstmp, @I_D_SYNCTstmp,
       @D_C_ID, @I_C_ID,
       @D_E_ID, @I_E_ID

  END
  CLOSE CUR_D_IUD
  DEALLOCATE CUR_D_IUD

  RETURN

END

GO
ALTER TABLE [jsharmony].[D] ENABLE TRIGGER [D_IUD]
GO
/****** Object:  Trigger [jsharmony].[GCOD2_D_SCOPE_D_CTGR_IUD]    Script Date: 10/25/2017 7:00:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [jsharmony].[GCOD2_D_SCOPE_D_CTGR_IUD] on [jsharmony].[GCOD2_D_SCOPE_D_CTGR]
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
  DECLARE CUR_GCOD2_D_SCOPE_D_CTGR_IUD CURSOR LOCAL FOR
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
  
  SET @CURDTTM = jsharmony.myNOW_DO()
  SET @CURDT = jsharmony.myTODATE(@CURDTTM)
  SET @CURDTTM_CHAR = CONVERT(NVARCHAR, @CURDTTM, 120)+'.0000000'
  SET @MYUSER = jsharmony.myCUSER() 

  IF @TP = 'U' AND UPDATE(GCOD2_ID)
  BEGIN
    EXEC [jsharmony].[ZZ-FILEDEBUG] 'TRIGGER','GCOD2_D_SCOPE_D_CTGR_IUD','ERR', 'Cannot update ID'
    raiserror('Cannot update identity',16,1)
    ROLLBACK TRANSACTION
    return
  END

  IF @TP = 'U' AND UPDATE(CODEVAL1)
  BEGIN
    EXEC [jsharmony].[ZZ-FILEDEBUG] 'TRIGGER','GCOD2_D_SCOPE_D_CTGR_IUD','ERR', 'Cannot update CODEVAL1'
    raiserror('Cannot update foreign key CODEVAL1',16,1)
    ROLLBACK TRANSACTION
    return
  END

  IF @TP = 'U' AND UPDATE(CODEVAL2)
  BEGIN
    EXEC [jsharmony].[ZZ-FILEDEBUG] 'TRIGGER','GCOD2_D_SCOPE_D_CTGR_IUD','ERR', 'Cannot update CODEVAL2'
    raiserror('Cannot update foreign key CODEVAL2',16,1)
    ROLLBACK TRANSACTION
    return
  END

  
  OPEN CUR_GCOD2_D_SCOPE_D_CTGR_IUD
  FETCH NEXT FROM CUR_GCOD2_D_SCOPE_D_CTGR_IUD
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

    IF (@TP='I')
  BEGIN
      UPDATE jsharmony.GCOD2_D_SCOPE_D_CTGR
       SET COD_ETstmp = @CURDTTM,
       COD_EU = @MYUSER,
         COD_MTstmp = @CURDTTM,
       COD_MU = @MYUSER
       WHERE GCOD2_D_SCOPE_D_CTGR.GCOD2_ID = @I_GCOD2_ID;
    END  

  /******************************************/
  /****** SPECIAL FRONT ACTION - END   ******/
  /******************************************/


    SET @MY_AUD_SEQ = 0
  IF (@TP='I' OR @TP='D')
  BEGIN  
    SET @WK_GCOD2_ID = ISNULL(@D_GCOD2_ID,@I_GCOD2_ID)
    EXEC  @MY_AUD_SEQ = jsharmony.AUDH_BASE @TP, 'GCOD2_D_SCOPE_D_CTGR', @WK_GCOD2_ID, @MYUSER, @CURDTTM
  END

 
    IF @TP='U' OR @TP='D'
  BEGIN

      IF (@TP = 'D' AND @D_CODSEQ IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALN(@D_CODSEQ, @I_CODSEQ) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH_BASE 'U', 'GCOD2_D_SCOPE_D_CTGR', @I_GCOD2_ID, @MYUSER, @CURDTTM
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'CODSEQ', @D_CODSEQ)
      END

      IF (@TP = 'D' AND @D_CODETDT IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALD(@D_CODETDT, @I_CODETDT) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH_BASE 'U', 'GCOD2_D_SCOPE_D_CTGR', @I_GCOD2_ID, @MYUSER, @CURDTTM
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'CODETDT', @D_CODETDT)
      END

      IF (@TP = 'D' AND @D_CODEVAL1 IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALC(@D_CODEVAL1, @I_CODEVAL1) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH_BASE 'U', 'GCOD2_D_SCOPE_D_CTGR', @I_GCOD2_ID, @MYUSER, @CURDTTM
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'CODEVAL1', @D_CODEVAL1)
      END

      IF (@TP = 'D' AND @D_CODEVAL2 IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALC(@D_CODEVAL2, @I_CODEVAL2) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH_BASE 'U', 'GCOD2_D_SCOPE_D_CTGR', @I_GCOD2_ID, @MYUSER, @CURDTTM
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'CODEVAL2', @D_CODEVAL2)
      END

      IF (@TP = 'D' AND @D_CODETXT IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALC(@D_CODETXT, @I_CODETXT) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH_BASE 'U', 'GCOD2_D_SCOPE_D_CTGR', @I_GCOD2_ID, @MYUSER, @CURDTTM
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'CODETXT', @D_CODETXT)
      END

      IF (@TP = 'D' AND @D_CODECODE IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALC(@D_CODECODE, @I_CODECODE) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH_BASE 'U', 'GCOD2_D_SCOPE_D_CTGR', @I_GCOD2_ID, @MYUSER, @CURDTTM
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'CODECODE', @D_CODECODE)
      END

      IF (@TP = 'D' AND @D_CODEATTRIB IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALC(@D_CODEATTRIB, @I_CODEATTRIB) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH_BASE 'U', 'GCOD2_D_SCOPE_D_CTGR', @I_GCOD2_ID, @MYUSER, @CURDTTM
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'CODEATTRIB', @D_CODEATTRIB)
      END

      IF (@TP = 'D' AND @D_CODETCM IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALC(@D_CODETCM, @I_CODETCM) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH_BASE 'U', 'GCOD2_D_SCOPE_D_CTGR', @I_GCOD2_ID, @MYUSER, @CURDTTM
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'CODETCM', @D_CODETCM)
      END

    END  /* END OF "IF @TP='U' OR @TP='D'"  */


  /******************************************/
  /****** SPECIAL BACK ACTION - BEGIN  ******/
  /******************************************/

    IF (@TP='U' AND @MY_AUD_SEQ <> 0)
  BEGIN
      UPDATE jsharmony.GCOD2_D_SCOPE_D_CTGR
       SET COD_MTstmp = @CURDTTM,
       COD_MU = @MYUSER
       WHERE GCOD2_D_SCOPE_D_CTGR.GCOD2_ID = @I_GCOD2_ID;
    END  

  /*****************************************/
  /****** SPECIAL BACK ACTION - END   ******/
  /*****************************************/



            
    FETCH NEXT FROM CUR_GCOD2_D_SCOPE_D_CTGR_IUD
        INTO @D_GCOD2_ID, @I_GCOD2_ID,
             @D_CODSEQ,  @I_CODSEQ,
             @D_CODETDT, @I_CODETDT,
             @D_CODEVAL1, @I_CODEVAL1,
             @D_CODEVAL2, @I_CODEVAL2,
             @D_CODETXT, @I_CODETXT,
             @D_CODECODE, @I_CODECODE,
             @D_CODEATTRIB, @I_CODEATTRIB,
             @D_CODETCM, @I_CODETCM


  END
  CLOSE CUR_GCOD2_D_SCOPE_D_CTGR_IUD
  DEALLOCATE CUR_GCOD2_D_SCOPE_D_CTGR_IUD


  RETURN

END
GO
ALTER TABLE [jsharmony].[GCOD2_D_SCOPE_D_CTGR] ENABLE TRIGGER [GCOD2_D_SCOPE_D_CTGR_IUD]
GO
/****** Object:  Trigger [jsharmony].[GPP_IUD]    Script Date: 10/25/2017 7:00:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE trigger [jsharmony].[GPP_IUD] on [jsharmony].[GPP]
for insert, update, delete
AS
BEGIN
  set nocount on
  DECLARE @TP char(1)
  DECLARE @MYGETDATE DATETIME2(7)  
  DECLARE @CURDTTM DATETIME2(7)
  DECLARE @CURDTTM_CHAR NVARCHAR(MAX)
  DECLARE @MYUSER NVARCHAR(20)
  DECLARE @ERRTXT NVARCHAR(MAX)
  DECLARE @MY_AUD_SEQ NUMERIC(20,0)
  DECLARE CUR_GPP_I CURSOR LOCAL FOR SELECT GPP_ID,
                                            GPP_PROCESS, 
                                            GPP_ATTRIB, 
                                            GPP_VAL
                                       FROM INSERTED
  DECLARE CUR_GPP_DU CURSOR LOCAL FOR 
     SELECT  d.GPP_ID, i.GPP_ID,
             d.GPP_PROCESS, i.GPP_PROCESS,
             d.GPP_ATTRIB, i.GPP_ATTRIB,
             d.GPP_VAL, i.GPP_VAL
       FROM deleted d FULL OUTER JOIN inserted i
                       ON i.GPP_ID = d.GPP_ID
  DECLARE @D_GPP_ID bigint
  DECLARE @I_GPP_ID bigint
  DECLARE @D_GPP_PROCESS nvarchar(MAX)
  DECLARE @I_GPP_PROCESS nvarchar(MAX)
  DECLARE @D_GPP_ATTRIB nvarchar(MAX)
  DECLARE @I_GPP_ATTRIB nvarchar(MAX)
  DECLARE @D_GPP_VAL nvarchar(MAX)
  DECLARE @I_GPP_VAL nvarchar(MAX)
  DECLARE @C BIGINT
  DECLARE @M NVARCHAR(MAX)
  DECLARE @WK_ID bigint

  if exists (select * from inserted)
    if exists (select * from deleted)
      set @TP = 'U'
    else
      set @TP = 'I'
  else
    if exists (select * from deleted)
    set @TP = 'D'
    else
      return
  
  SET @MYGETDATE = SYSDATETIME()

  SET @CURDTTM = jsharmony.myNOW_DO()
  SET @CURDTTM_CHAR = CONVERT(NVARCHAR, @CURDTTM, 120)+'.0000000'
  SET @MYUSER = jsharmony.myCUSER() 

  IF @TP = 'U' AND UPDATE(GPP_ID)
  BEGIN
    raiserror('Cannot update identity',16,1)
  ROLLBACK TRANSACTION
    return
  END

  if(@TP = 'I')
  BEGIN
  
    update jsharmony.GPP set
      GPP_ETstmp = @CURDTTM,
      GPP_EU =@MYUSER, 
      GPP_MTstmp = @CURDTTM,
      GPP_MU =@MYUSER 
      from inserted WHERE gpp.gpp_id=INSERTED.gpp_id
  
    OPEN CUR_GPP_I
    FETCH NEXT FROM CUR_GPP_I INTO @I_GPP_ID, 
                                   @I_GPP_PROCESS, 
                                   @I_GPP_ATTRIB,
                                   @I_GPP_VAL
    WHILE (@@Fetch_Status = 0)
    BEGIN
      
      IF (@I_GPP_VAL IS NOT NULL)
      BEGIN
        SET @ERRTXT = jsharmony.CHECK_PP('GPP',@I_GPP_PROCESS,@I_GPP_ATTRIB,@I_GPP_VAL)
        IF @ERRTXT IS NOT null  
        BEGIN
          raiserror(@ERRTXT,16,1)
        ROLLBACK TRANSACTION
          return
        END
      END

    SET @WK_ID = ISNULL(@I_GPP_ID,@D_GPP_ID)
    EXEC  @MY_AUD_SEQ = jsharmony.AUDH_BASE @TP, 'GPP', @WK_ID, @MYUSER, @CURDTTM

      FETCH NEXT FROM CUR_GPP_I INTO @I_GPP_ID, 
                                     @I_GPP_PROCESS, 
                                     @I_GPP_ATTRIB,
                                     @I_GPP_VAL
    END
    CLOSE CUR_GPP_I
    DEALLOCATE CUR_GPP_I
  END
  ELSE 
  BEGIN
  
    if(@TP = 'U')
    BEGIN
      update GPP set
        GPP_MTstmp = @CURDTTM,
        GPP_MU =@MYUSER 
        from inserted WHERE gpp.gpp_id = INSERTED.gpp_id
    END

    OPEN CUR_GPP_DU
    FETCH NEXT FROM CUR_GPP_DU
          INTO @D_GPP_ID, @I_GPP_ID,
               @D_GPP_PROCESS, @I_GPP_PROCESS,
               @D_GPP_ATTRIB, @I_GPP_ATTRIB,
               @D_GPP_VAL, @I_GPP_VAL
    WHILE (@@Fetch_Status = 0)
    BEGIN
      if(@TP = 'U')
      BEGIN
        IF (@I_GPP_VAL IS NOT NULL)
        BEGIN      
          SET @ERRTXT = jsharmony.CHECK_PP('GPP',@I_GPP_PROCESS,@I_GPP_ATTRIB,@I_GPP_VAL)
          IF @ERRTXT IS NOT null  
          BEGIN
            raiserror(@ERRTXT,16,1)
          ROLLBACK TRANSACTION
            return
          END
        END


      END

    SET @WK_ID = ISNULL(@I_GPP_ID,@D_GPP_ID)
    EXEC  @MY_AUD_SEQ = jsharmony.AUDH_BASE @TP, 'GPP', @WK_ID, @MYUSER, @CURDTTM
            
      FETCH NEXT FROM CUR_GPP_DU
            INTO @D_GPP_ID, @I_GPP_ID,
                 @D_GPP_PROCESS, @I_GPP_PROCESS,
                 @D_GPP_ATTRIB, @I_GPP_ATTRIB,
                 @D_GPP_VAL, @I_GPP_VAL
    END
    CLOSE CUR_GPP_DU
    DEALLOCATE CUR_GPP_DU
  END

  RETURN

END

GO
ALTER TABLE [jsharmony].[GPP] ENABLE TRIGGER [GPP_IUD]
GO
/****** Object:  Trigger [jsharmony].[H_IUD]    Script Date: 10/25/2017 7:00:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [jsharmony].[H_IUD] on [jsharmony].[H]
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
  DECLARE CUR_H_IUD CURSOR LOCAL FOR
     SELECT  d.H_ID, i.H_ID,
           d.HP_CODE, i.HP_CODE,
           d.H_TITLE, i.H_TITLE,
           d.H_TEXT, i.H_TEXT,
           d.H_SEQ, i.H_SEQ,
           d.H_INDEX_A, i.H_INDEX_A,
           d.H_INDEX_P, i.H_INDEX_P
       FROM deleted d FULL OUTER JOIN inserted i
                       ON i.H_ID = d.H_ID;
  DECLARE @D_H_ID bigint
  DECLARE @I_H_ID bigint
  DECLARE @D_HP_CODE NVARCHAR(MAX)
  DECLARE @I_HP_CODE NVARCHAR(MAX)
  DECLARE @D_H_TITLE NVARCHAR(MAX)
  DECLARE @I_H_TITLE NVARCHAR(MAX)
  DECLARE @D_H_TEXT NVARCHAR(MAX)
  DECLARE @I_H_TEXT NVARCHAR(MAX)
  DECLARE @D_H_SEQ BIGINT
  DECLARE @I_H_SEQ BIGINT
  DECLARE @D_H_INDEX_A BIGINT
  DECLARE @I_H_INDEX_A BIGINT
  DECLARE @D_H_INDEX_P BIGINT
  DECLARE @I_H_INDEX_P BIGINT

  DECLARE @MYERROR_NO INT = 0
  DECLARE @MYERROR_MSG NVARCHAR(MAX) = NULL

  DECLARE @xloc nvarchar(MAX)
  DECLARE @xtxt nvarchar(MAX)

  DECLARE @DYNSQL NVARCHAR(MAX)
  DECLARE @C BIGINT
  DECLARE @CODEVAL NVARCHAR(MAX)
  DECLARE @WK_H_ID bigint
  DECLARE @M NVARCHAR(MAX)
  DECLARE @CPE_USER BIT

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
  
  SET @CURDTTM = jsharmony.myNOW_DO()
  SET @CURDT = jsharmony.myTODATE(@CURDTTM)
  SET @CURDTTM_CHAR = CONVERT(NVARCHAR, @CURDTTM, 120)+'.0000000'
  SET @MYUSER = jsharmony.myCUSER() 

  IF @TP = 'U' AND UPDATE(H_ID)
  BEGIN
    EXEC [jsharmony].[ZZ-FILEDEBUG] 'TRIGGER','H_IUD','ERR', 'Cannot update ID'
    raiserror('Cannot update identity',16,1)
    ROLLBACK TRANSACTION
    return
  END

  IF @TP = 'U' AND UPDATE(HP_CODE)
  BEGIN
    EXEC [jsharmony].[ZZ-FILEDEBUG] 'TRIGGER','H_IUD','ERR', 'Cannot update HP_CODE'
    raiserror('Cannot update foreign key HP_CODE',16,1)
    ROLLBACK TRANSACTION
    return
  END

  
  OPEN CUR_H_IUD
  FETCH NEXT FROM CUR_H_IUD
        INTO @D_H_ID, @I_H_ID,
             @D_HP_CODE, @I_HP_CODE,
             @D_H_TITLE, @I_H_TITLE,
             @D_H_TEXT, @I_H_TEXT,
             @D_H_SEQ, @I_H_SEQ,
             @D_H_INDEX_A, @I_H_INDEX_A,
             @D_H_INDEX_P, @I_H_INDEX_P

  WHILE (@@Fetch_Status = 0)
  BEGIN

  /******************************************/
  /****** SPECIAL FRONT ACTION - BEGIN ******/
  /******************************************/

    IF (@TP='I')
  BEGIN
      UPDATE jsharmony.H
       SET H_ETstmp = @CURDTTM,
       H_EU = @MYUSER,
         H_MTstmp = @CURDTTM,
       H_MU = @MYUSER
       WHERE H.H_ID = @I_H_ID;
    END  

  /******************************************/
  /****** SPECIAL FRONT ACTION - END   ******/
  /******************************************/


    SET @MY_AUD_SEQ = 0
  IF (@TP='I' OR @TP='D')
  BEGIN  
    SET @WK_H_ID = ISNULL(@D_H_ID,@I_H_ID)
    EXEC  @MY_AUD_SEQ = jsharmony.AUDH_BASE @TP, 'H', @WK_H_ID, @MYUSER, @CURDTTM
  END

 
    IF @TP='U' OR @TP='D'
  BEGIN

      IF (@TP = 'D' AND @D_HP_CODE IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALC(@D_HP_CODE, @I_HP_CODE) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH_BASE 'U', 'H', @I_H_ID, @MYUSER, @CURDTTM
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'HP_CODE', @D_HP_CODE)
      END

      IF (@TP = 'D' AND @D_H_TITLE IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALC(@D_H_TITLE, @I_H_TITLE) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH_BASE 'U', 'H', @I_H_ID, @MYUSER, @CURDTTM
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'H_TITLE', @D_H_TITLE)
      END

      IF (@TP = 'D' AND @D_H_TEXT IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALC(@D_H_TEXT, @I_H_TEXT) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH_BASE 'U', 'H', @I_H_ID, @MYUSER, @CURDTTM
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'H_TEXT', @D_H_TEXT)
      END

      IF (@TP = 'D' AND @D_H_SEQ IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALN(@D_H_SEQ, @I_H_SEQ) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH_BASE 'U', 'H', @I_H_ID, @MYUSER, @CURDTTM
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'H_SEQ', @D_H_SEQ)
      END

      IF (@TP = 'D' AND @D_H_INDEX_A IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALN(@D_H_INDEX_A, @I_H_INDEX_A) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH_BASE 'U', 'H', @I_H_ID, @MYUSER, @CURDTTM
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'H_INDEX_A', @D_H_INDEX_A)
      END

      IF (@TP = 'D' AND @D_H_INDEX_P IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALN(@D_H_INDEX_P, @I_H_INDEX_P) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH_BASE 'U', 'H', @I_H_ID, @MYUSER, @CURDTTM
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'H_INDEX_P', @D_H_INDEX_P)
      END

    END  /* END OF "IF @TP='U' OR @TP='D'"  */


  /******************************************/
  /****** SPECIAL BACK ACTION - BEGIN  ******/
  /******************************************/

    IF (@TP='U' AND @MY_AUD_SEQ <> 0)
  BEGIN
      UPDATE jsharmony.H
       SET H_MTstmp = @CURDTTM,
       H_MU = @MYUSER
       WHERE H.H_ID = @I_H_ID;
    END  

  /*****************************************/
  /****** SPECIAL BACK ACTION - END   ******/
  /*****************************************/



            
    FETCH NEXT FROM CUR_H_IUD
        INTO @D_H_ID, @I_H_ID,
             @D_HP_CODE,  @I_HP_CODE,
             @D_H_TITLE, @I_H_TITLE,
             @D_H_TEXT, @I_H_TEXT,
             @D_H_SEQ, @I_H_SEQ,
             @D_H_INDEX_A, @I_H_INDEX_A,
             @D_H_INDEX_P, @I_H_INDEX_P


  END
  CLOSE CUR_H_IUD
  DEALLOCATE CUR_H_IUD

  RETURN

END
GO
ALTER TABLE [jsharmony].[H] ENABLE TRIGGER [H_IUD]
GO
/****** Object:  Trigger [jsharmony].[N_IUD]    Script Date: 10/25/2017 7:00:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE trigger [jsharmony].[N_IUD] on [jsharmony].[N]
for insert, update, delete
AS
BEGIN
  set nocount on
  DECLARE @TP char(1)
  DECLARE @CURDTTM DATETIME2(7)
  DECLARE @CURDTTM_CHAR NVARCHAR(MAX)
  DECLARE @MYUSER NVARCHAR(20)
  DECLARE @ERRTXT NVARCHAR(500)
  DECLARE @MY_AUD_SEQ NUMERIC(20,0)
  DECLARE CUR_N_IUD CURSOR LOCAL FOR
     SELECT  d.N_ID, i.N_ID,
           d.N_SCOPE, i.N_SCOPE,
           d.N_SCOPE_ID, i.N_SCOPE_ID,
           d.N_STS, i.N_STS,
       d.N_TYPE, i.N_TYPE,
       d.N_Note, i.N_Note,
       d.C_ID, i.C_ID,
       d.E_ID, i.E_ID
       FROM deleted d FULL OUTER JOIN inserted i
                       ON i.N_ID = d.N_ID;
  DECLARE @D_N_ID bigint
  DECLARE @I_N_ID bigint
  DECLARE @D_N_SCOPE NVARCHAR(MAX)
  DECLARE @I_N_SCOPE NVARCHAR(MAX)
  DECLARE @D_N_SCOPE_ID bigint
  DECLARE @I_N_SCOPE_ID bigint
  DECLARE @D_N_STS NVARCHAR(MAX)
  DECLARE @I_N_STS NVARCHAR(MAX)
  DECLARE @D_N_TYPE NVARCHAR(MAX)
  DECLARE @I_N_TYPE NVARCHAR(MAX)
  DECLARE @D_N_Note NVARCHAR(MAX) 
  DECLARE @I_N_Note NVARCHAR(MAX)
  DECLARE @D_C_ID bigint 
  DECLARE @I_C_ID bigint
  DECLARE @D_E_ID bigint 
  DECLARE @I_E_ID bigint

  DECLARE @MYERROR_NO INT = 0
  DECLARE @MYERROR_MSG NVARCHAR(MAX) = NULL

  DECLARE @xloc nvarchar(MAX)
  DECLARE @xtxt nvarchar(MAX)

  DECLARE @DYNSQL NVARCHAR(MAX)
  DECLARE @C BIGINT
  DECLARE @WK_N_ID BIGINT
  DECLARE @WK_REF_NAME NVARCHAR(MAX)
  DECLARE @WK_REF_ID BIGINT
  DECLARE @M NVARCHAR(MAX)
  DECLARE @CODEVAL NVARCHAR(MAX)
  DECLARE @CPE_USER BIT
  DECLARE @USER_C_ID BIGINT

  DECLARE @SQLCMD nvarchar(max)
  DECLARE @GETCID nvarchar(max)
  DECLARE @GETEID nvarchar(max)
  DECLARE @MY_C_ID bigint
  DECLARE @MY_E_ID bigint
  DECLARE @C_ID bigint
  DECLARE @E_ID bigint

  DECLARE @DB_K NVARCHAR(MAX)
  DECLARE @DB_OUT datetime2(7)

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
  
  SET @CURDTTM = jsharmony.myNOW_DO()
  SET @CURDTTM_CHAR = CONVERT(NVARCHAR, @CURDTTM, 120)+'.0000000'
  SET @MYUSER = jsharmony.myCUSER() 

  IF @TP = 'U' AND UPDATE(N_ID)
  BEGIN
    EXEC [jsharmony].[ZZ-FILEDEBUG] 'TRIGGER','N_IUD','ERR', 'Cannot update ID'
    raiserror('Cannot update identity',16,1)
    ROLLBACK TRANSACTION
    return
  END

  IF @TP = 'U' AND UPDATE(N_SCOPE)
  BEGIN
    EXEC [jsharmony].[ZZ-FILEDEBUG] 'TRIGGER','N_IUD','ERR', 'Cannot update N_SCOPE'
    raiserror('Cannot update foreign key N_SCOPE',16,1)
    ROLLBACK TRANSACTION
    return
  END

  IF @TP = 'U' AND UPDATE(N_SCOPE_ID)
  BEGIN
    EXEC [jsharmony].[ZZ-FILEDEBUG] 'TRIGGER','N_IUD','ERR', 'Cannot update N_SCOPE_ID'
    raiserror('Cannot update foreign key N_SCOPE_ID',16,1)
    ROLLBACK TRANSACTION
    return
  END

  IF @TP = 'U' AND UPDATE(N_TYPE)
  BEGIN
    EXEC [jsharmony].[ZZ-FILEDEBUG] 'TRIGGER','N_IUD','ERR', 'Cannot update N_TYPE'
    raiserror('Cannot update foreign key N_TYPE',16,1)
    ROLLBACK TRANSACTION
    return
  END

  SELECT @GETCID = PP_VAL
  FROM jsharmony.V_PP
   where PP_PROCESS = 'SQL'
   and PP_ATTRIB = 'GETCID';

  SELECT @GETEID = PP_VAL
  FROM jsharmony.V_PP
   where PP_PROCESS = 'SQL'
   and PP_ATTRIB = 'GETEID';
  
  OPEN CUR_N_IUD
  FETCH NEXT FROM CUR_N_IUD
        INTO @D_N_ID, @I_N_ID,
             @D_N_SCOPE, @I_N_SCOPE,
             @D_N_SCOPE_ID, @I_N_SCOPE_ID,
             @D_N_STS, @I_N_STS,
       @D_N_TYPE, @I_N_TYPE,
       @D_N_Note, @I_N_Note,
       @D_C_ID, @I_C_ID,
       @D_E_ID, @I_E_ID

  WHILE (@@Fetch_Status = 0)
  BEGIN

  /******************************************/
  /****** SPECIAL FRONT ACTION - BEGIN ******/
  /******************************************/
 
    IF (@TP='I' 
      OR 
    @TP='U' AND (jsharmony.nonequalc(@D_N_SCOPE, @I_N_SCOPE)>0
                 OR
           jsharmony.nonequaln(@D_N_SCOPE_ID, @I_N_SCOPE_ID)>0))
  BEGIN
    IF @I_N_SCOPE = 'S' AND @I_N_SCOPE_ID <> 0
       OR
       @I_N_SCOPE <> 'S' AND @I_N_SCOPE_ID is NULL
    BEGIN
      CLOSE CUR_N_IUD
      DEALLOCATE CUR_N_IUD
      SET @M = 'SCOPE ID INCONSISTENT WITH SCOPE'
      raiserror(@M ,16,1)
      ROLLBACK TRANSACTION
      return
    END 
  END   
 
    IF (@TP='I' OR @TP='U')
  BEGIN
    EXEC @C = [jsharmony].[CHECK_FOREIGN]
         @in_tblname = @I_N_SCOPE,
         @in_tblid = @I_N_SCOPE_ID
    IF @C <= 0
    BEGIN
      CLOSE CUR_N_IUD
      DEALLOCATE CUR_N_IUD
      SET @M = 'Table ' + @I_N_SCOPE + ' does not contain record ' + CONVERT(NVARCHAR(MAX),@I_N_SCOPE_ID)
      raiserror(@M ,16,1)
      ROLLBACK TRANSACTION
      return
    END 
  END   

    SET @CPE_USER = 0
  SET @USER_C_ID = NULL   
    IF SUBSTRING(@MYUSER,1,1) = 'C'
  BEGIN
    SELECT @USER_C_ID = C_ID
      FROM jsharmony.CPE
       WHERE substring(@MYUSER,2,1024)=convert(varchar, PE_ID);   
    
    IF @USER_C_ID is not null
      SET @CPE_USER = 1
  END

  SET @SQLCMD = 'select @my_c_id  = ' + @GETCID + '(''' + isnull(isnull(@I_N_SCOPE,@D_N_SCOPE),'') + ''',' +
                      isnull(convert(nvarchar,isnull(@I_N_SCOPE_ID,@D_N_SCOPE_ID)),'') + ')'
  EXECUTE sp_executesql @SQLCMD, N'@my_c_id bigint OUTPUT', @MY_C_ID=@my_c_id OUTPUT
  SET @C_ID = @MY_C_ID

  SET @SQLCMD = 'select @my_e_id  = ' + @GETEID + '(''' + isnull(isnull(@I_N_SCOPE,@D_N_SCOPE),'') + ''',' +
                      isnull(convert(nvarchar,isnull(@I_N_SCOPE_ID,@D_N_SCOPE_ID)),'') + ')'
  EXECUTE sp_executesql @SQLCMD, N'@my_e_id bigint OUTPUT', @MY_E_ID=@my_e_id OUTPUT
  SET @E_ID = @MY_E_ID


    IF (@CPE_USER = 1)
  BEGIN

    IF @USER_C_ID <> isnull(@C_ID,0)
       OR
         isnull(@I_N_SCOPE, @D_N_SCOPE) not in ('C','CT','E','J','SRV')
     OR
     isnull(@I_N_TYPE, @D_N_TYPE) not in ('C','S')
    BEGIN
    CLOSE CUR_N_IUD
    DEALLOCATE CUR_N_IUD
    SET @M = 'Application Error - Customer User has no rights to perform this operation'
    raiserror(@M ,16,1)
    ROLLBACK TRANSACTION
      return
    END 

    END


    IF (@TP='I')
  BEGIN

      IF @C_ID is not null
    BEGIN
    EXEC  @C = [jsharmony].[CHECK_FOREIGN]
        @in_tblname ='C',
        @in_tblid = @C_ID
    IF @C <= 0
    BEGIN
      CLOSE CUR_N_IUD
      DEALLOCATE CUR_N_IUD
      SET @M = 'Table C does not contain record ' + CONVERT(NVARCHAR(MAX),@C_ID)
      raiserror(@M ,16,1)
      ROLLBACK TRANSACTION
      return
    END 
    END   

      IF @E_ID is not null
    BEGIN
    EXEC  @C = [jsharmony].[CHECK_FOREIGN]
        @in_tblname ='E',
        @in_tblid = @E_ID
    IF @C <= 0
    BEGIN
      CLOSE CUR_N_IUD
      DEALLOCATE CUR_N_IUD
      SET @M = 'Table E does not contain record ' + CONVERT(NVARCHAR(MAX),@E_ID)
      raiserror(@M ,16,1)
      ROLLBACK TRANSACTION
      return
    END 
    END   

        UPDATE jsharmony.N
       SET C_ID = @C_ID,
         E_ID = @E_ID,
         N_ETstmp = @CURDTTM,
       N_EU = @MYUSER,
         N_MTstmp = @CURDTTM,
       N_MU = @MYUSER
         WHERE N.N_ID = @I_N_ID;
    END  

    IF (@TP='U')
  BEGIN

      IF @I_C_ID is not null
       and
     jsharmony.NONEQUALN(@D_C_ID, @I_C_ID) > 0
    BEGIN
    EXEC  @C = [jsharmony].[CHECK_FOREIGN]
        @in_tblname ='C',
        @in_tblid = @I_C_ID
    IF @C <= 0
    BEGIN
      CLOSE CUR_N_IUD
      DEALLOCATE CUR_N_IUD
      SET @M = 'Table C does not contain record ' + CONVERT(NVARCHAR(MAX),@I_C_ID)
      raiserror(@M ,16,1)
      ROLLBACK TRANSACTION
      return
    END 
    END   

      IF @I_E_ID is not null
       and
     jsharmony.NONEQUALN(@D_E_ID, @I_E_ID) > 0
    BEGIN
    EXEC  @C = [jsharmony].[CHECK_FOREIGN]
        @in_tblname ='E',
        @in_tblid = @I_E_ID
    IF @C <= 0
    BEGIN
      CLOSE CUR_N_IUD
      DEALLOCATE CUR_N_IUD
      SET @M = 'Table E does not contain record ' + CONVERT(NVARCHAR(MAX),@I_E_ID)
      raiserror(@M ,16,1)
      ROLLBACK TRANSACTION
      return
    END 
    END
       
    END

  /******************************************/
  /****** SPECIAL FRONT ACTION - END   ******/
  /******************************************/


    SET @MY_AUD_SEQ = 0
  IF (@TP='I' OR @TP='D')
  BEGIN  
    SET @WK_N_ID = ISNULL(@D_N_ID,@I_N_ID)
    SET @WK_REF_NAME = ISNULL(@D_N_SCOPE,@I_N_SCOPE)
    SET @WK_REF_ID = ISNULL(@D_N_SCOPE_ID,@I_N_SCOPE_ID)
    EXEC  @MY_AUD_SEQ = jsharmony.AUDH @TP, 'N', @WK_N_ID, @MYUSER, @CURDTTM, @WK_REF_NAME, @WK_REF_ID, default, @C_ID, @E_ID
  END

 
    IF @TP='U' OR @TP='D'
  BEGIN

      IF (@TP = 'D' AND @D_N_SCOPE IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALC(@D_N_SCOPE, @I_N_SCOPE) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH 'U', 'N', @I_N_ID, @MYUSER, @CURDTTM, @I_N_SCOPE, @I_N_SCOPE_ID, default, @C_ID, @E_ID
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'N_SCOPE', @D_N_SCOPE)
      END

      IF (@TP = 'D' AND @D_N_SCOPE_ID IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALN(@D_N_SCOPE_ID, @I_N_SCOPE_ID) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH 'U', 'N', @I_N_ID, @MYUSER, @CURDTTM, @I_N_SCOPE, @I_N_SCOPE_ID, default, @C_ID, @E_ID
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'N_SCOPE_ID', @D_N_SCOPE_ID)
      END

      IF (@TP = 'D' AND @D_N_STS IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALC(@D_N_STS, @I_N_STS) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH 'U', 'N', @I_N_ID, @MYUSER, @CURDTTM, @I_N_SCOPE, @I_N_SCOPE_ID, default, @C_ID, @E_ID
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'N_STS', @D_N_STS)
      END

      IF (@TP = 'D' AND @D_N_TYPE IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALC(@D_N_TYPE, @I_N_TYPE) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH 'U', 'N', @I_N_ID, @MYUSER, @CURDTTM, @I_N_SCOPE, @I_N_SCOPE_ID, default, @C_ID, @E_ID
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'N_TYPE', @D_N_TYPE)
      END

      IF (@TP = 'D' AND @D_N_Note IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALC(@D_N_Note, @I_N_Note) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH 'U', 'N', @I_N_ID, @MYUSER, @CURDTTM, @I_N_SCOPE, @I_N_SCOPE_ID, default, @C_ID, @E_ID
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'N_Note', @D_N_Note)
      END

    IF (@TP = 'D' AND @D_C_ID IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALN(@D_C_ID, @I_C_ID) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH 'U', 'N', @I_N_ID, @MYUSER, @CURDTTM, @I_N_SCOPE, @I_N_SCOPE_ID, default, @C_ID, @E_ID
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'C_ID', @D_C_ID)
      END

      IF (@TP = 'D' AND @D_E_ID IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALN(@D_E_ID, @I_E_ID) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH 'U', 'N', @I_N_ID, @MYUSER, @CURDTTM, @I_N_SCOPE, @I_N_SCOPE_ID, default, @C_ID, @E_ID
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'E_ID', @D_E_ID)
      END


    END  /* END OF "IF @TP='U' OR @TP='D'"  */


  /******************************************/
  /****** SPECIAL BACK ACTION - BEGIN  ******/
  /******************************************/

    IF (@TP='U' AND @MY_AUD_SEQ <> 0)
  BEGIN
        UPDATE jsharmony.N
       SET N_MTstmp = @CURDTTM,
       N_MU = @MYUSER
         WHERE N.N_ID = @I_N_ID;
    END  

  /*****************************************/
  /****** SPECIAL BACK ACTION - END   ******/
  /*****************************************/



            
    FETCH NEXT FROM CUR_N_IUD
        INTO @D_N_ID, @I_N_ID,
             @D_N_SCOPE,  @I_N_SCOPE,
             @D_N_SCOPE_ID, @I_N_SCOPE_ID,
             @D_N_STS, @I_N_STS,
       @D_N_TYPE, @I_N_TYPE,
       @D_N_Note, @I_N_Note,
       @D_C_ID, @I_C_ID,
       @D_E_ID, @I_E_ID

  END
  CLOSE CUR_N_IUD
  DEALLOCATE CUR_N_IUD

  RETURN

END

GO
ALTER TABLE [jsharmony].[N] ENABLE TRIGGER [N_IUD]
GO
/****** Object:  Trigger [jsharmony].[PE_IUD]    Script Date: 10/25/2017 7:00:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE trigger [jsharmony].[PE_IUD] on [jsharmony].[PE]
for insert, update, delete
AS
BEGIN
  set nocount on
  DECLARE @TP char(1)
  DECLARE @CURDTTM DATETIME2(7)
  DECLARE @CURDTTM_CHAR NVARCHAR(MAX)
  DECLARE @MYUSER NVARCHAR(20)
  DECLARE @ERRTXT NVARCHAR(500)
  DECLARE @MY_AUD_SEQ NUMERIC(20,0)
  DECLARE CUR_PE_IUD CURSOR LOCAL FOR
     SELECT  d.PE_ID, i.PE_ID,
           d.PE_STS, i.PE_STS,
           d.PE_FName, i.PE_FName,
       d.PE_MName, i.PE_MName,
       d.PE_LName, i.PE_LName,
             d.PE_JTitle, i.PE_JTitle,
             d.PE_BPhone, i.PE_BPhone,
             d.PE_CPhone, i.PE_CPhone,
             d.PE_Email, i.PE_Email,
             d.PE_PW1, i.PE_PW1,
             d.PE_PW2, i.PE_PW2,
       d.PE_LL_Tstmp, i.PE_LL_Tstmp
       FROM deleted d FULL OUTER JOIN inserted i
                       ON i.PE_ID = d.PE_ID;
  DECLARE @D_PE_ID bigint
  DECLARE @I_PE_ID bigint
  DECLARE @D_PE_STS NVARCHAR(MAX)
  DECLARE @I_PE_STS NVARCHAR(MAX)
  DECLARE @D_PE_FName NVARCHAR(MAX)
  DECLARE @I_PE_FName NVARCHAR(MAX)
  DECLARE @D_PE_MName NVARCHAR(MAX)
  DECLARE @I_PE_MName NVARCHAR(MAX)
  DECLARE @D_PE_LName NVARCHAR(MAX) 
  DECLARE @I_PE_LName NVARCHAR(MAX)
  DECLARE @D_PE_JTitle NVARCHAR(MAX) 
  DECLARE @I_PE_JTitle NVARCHAR(MAX)
  DECLARE @D_PE_BPhone NVARCHAR(MAX) 
  DECLARE @I_PE_BPhone NVARCHAR(MAX)
  DECLARE @D_PE_CPhone NVARCHAR(MAX) 
  DECLARE @I_PE_CPhone NVARCHAR(MAX)
  DECLARE @D_PE_Email NVARCHAR(MAX) 
  DECLARE @I_PE_Email NVARCHAR(MAX)
  DECLARE @D_PE_PW1 NVARCHAR(MAX) 
  DECLARE @I_PE_PW1 NVARCHAR(MAX)
  DECLARE @D_PE_PW2 NVARCHAR(MAX) 
  DECLARE @I_PE_PW2 NVARCHAR(MAX)
  DECLARE @D_PE_LL_TSTMP datetime2(7) 
  DECLARE @I_PE_LL_TSTMP datetime2(7)

  DECLARE @NEWPW nvarchar(max)

  DECLARE @MYERROR_NO INT = 0
  DECLARE @MYERROR_MSG NVARCHAR(MAX) = NULL

  DECLARE @xloc nvarchar(MAX)
  DECLARE @xtxt nvarchar(MAX)

  DECLARE @DYNSQL NVARCHAR(MAX)
  DECLARE @C BIGINT
  DECLARE @WK_PE_ID BIGINT
  DECLARE @WK_SUBJ NVARCHAR(MAX)
  DECLARE @CODEVAL NVARCHAR(MAX)
  DECLARE @UPDATE_PW CHAR(1)

  DECLARE @return_value int,
      @out_msg nvarchar(max),
      @out_rslt nvarchar(255),
      @hash varbinary(200),
      @M nvarchar(max)

  /*
  EXEC [jsharmony].[ZZ-FILEDEBUG] 'TRIGGER','PE_IUD','START', ''
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
  
  SET @CURDTTM = jsharmony.myNOW_DO()
  SET @CURDTTM_CHAR = CONVERT(NVARCHAR, @CURDTTM, 120)+'.0000000'
  SET @MYUSER = jsharmony.myCUSER() 

  IF @TP = 'U' AND UPDATE(PE_ID)
  BEGIN
    EXEC [jsharmony].[ZZ-FILEDEBUG] 'TRIGGER','PE_IUD','ERR', 'Cannot update ID'
    raiserror('Cannot update identity',16,1)
    ROLLBACK TRANSACTION
    return
  END

  
  OPEN CUR_PE_IUD
  FETCH NEXT FROM CUR_PE_IUD
        INTO @D_PE_ID, @I_PE_ID,
             @D_PE_STS, @I_PE_STS,
             @D_PE_FName, @I_PE_FName,
       @D_PE_MName, @I_PE_MName,
       @D_PE_LName, @I_PE_LName,
             @D_PE_JTitle, @I_PE_JTitle,
             @D_PE_BPhone, @I_PE_BPhone,
             @D_PE_CPhone, @I_PE_CPhone,
             @D_PE_Email, @I_PE_Email,
             @D_PE_PW1, @I_PE_PW1,
             @D_PE_PW2, @I_PE_PW2,
             @D_PE_LL_TSTMP, @I_PE_LL_TSTMP

  WHILE (@@Fetch_Status = 0)
  BEGIN

  IF (@TP = 'D')
  BEGIN
    
    if (jsharmony.EXISTS_D('PE', @D_PE_ID) > 0)
      begin
    CLOSE CUR_PE_IUD
    DEALLOCATE CUR_PE_IUD
    SET @M = 'Application Error - User cannot be deleted if Documents are present.'
    raiserror(@M ,16,1)
    ROLLBACK TRANSACTION
    return
    end

    END

    SET @M = NULL
    SET @hash = NULL

  SET @NEWPW = NUll;
    SET @UPDATE_PW = 'N'

    IF (@TP='I' or @TP='U')
  BEGIN
    if (jsharmony.NONEQUALC(@I_PE_PW1, @I_PE_PW2) > 0)
        SET @M = 'Application Error - New Password and Repeat Password are different'
    else if ((@TP='I' or isnull(@I_PE_PW1,'')>'') and len(ltrim(rtrim(isnull(@I_PE_PW1,'')))) < 6)
        SET @M = 'Application Error - Password length - at least 6 characters required'

     IF (@M is not null)
    BEGIN
        CLOSE CUR_PE_IUD
        DEALLOCATE CUR_PE_IUD
        raiserror(@M,16,1)
        ROLLBACK TRANSACTION
        return
      END
    ELSE
      SET @NEWPW = ltrim(rtrim(@I_PE_PW1))
  END

  /******************************************/
  /****** SPECIAL FRONT ACTION - BEGIN ******/
  /******************************************/

    IF (@TP='I')
  BEGIN

    set @hash = jsharmony.myHASH('S', @I_PE_ID, @NEWPW);

    if (@hash is null)
      BEGIN
        CLOSE CUR_PE_IUD
        DEALLOCATE CUR_PE_IUD
        SET @M = 'Application Error - Missing or Incorrect Password'
        raiserror(@M,16,1)
        ROLLBACK TRANSACTION
        return
      END

      UPDATE jsharmony.PE
       SET PE_STSDt = @CURDTTM,
         PE_ETstmp = @CURDTTM,
       PE_EU = @MYUSER,
         PE_MTstmp = @CURDTTM,
       PE_MU = @MYUSER,
       PE_Hash = @hash,
       PE_PW1 = NULL,
       PE_PW2 = NULL
       WHERE PE.PE_ID = @I_PE_ID;

    END  

    SET @WK_SUBJ = ISNULL(@I_PE_LNAME,'')+', '+ISNULL(@I_PE_FNAME,'') 

  /******************************************/
  /****** SPECIAL FRONT ACTION - END   ******/
  /******************************************/

    SET @MY_AUD_SEQ = 0
  IF (@TP='I' OR @TP='D')
  BEGIN
    SET @WK_PE_ID =  ISNULL(@D_PE_ID,@I_PE_ID) 
    EXEC  @MY_AUD_SEQ = jsharmony.AUDH_BASE @TP, 'PE', @WK_PE_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ
  END
 
    IF @TP='U' OR @TP='D'
  BEGIN

      IF (@TP = 'D' AND @D_PE_STS IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALC(@D_PE_STS, @I_PE_STS) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH_BASE 'U', 'PE', @I_PE_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'PE_STS', @D_PE_STS)
      END

      IF (@TP = 'D' AND @D_PE_FName IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALC(@D_PE_FName, @I_PE_FName) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH_BASE 'U', 'PE', @I_PE_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'PE_FName', @D_PE_FName)
      END

      IF (@TP = 'D' AND @D_PE_MName IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALC(@D_PE_MName, @I_PE_MName) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH_BASE 'U', 'PE', @I_PE_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'PE_MName', @D_PE_MName)
      END

      IF (@TP = 'D' AND @D_PE_LName IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALC(@D_PE_LName, @I_PE_LName) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH_BASE 'U', 'PE', @I_PE_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'PE_LName', @D_PE_LName)
      END

      IF (@TP = 'D' AND @D_PE_JTitle IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALC(@D_PE_JTitle, @I_PE_JTitle) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH_BASE 'U', 'PE', @I_PE_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'PE_JTitle', @D_PE_JTitle)
      END

      IF (@TP = 'D' AND @D_PE_BPhone IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALC(@D_PE_BPhone, @I_PE_BPhone) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH_BASE 'U', 'PE', @I_PE_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'PE_BPhone', @D_PE_BPhone)
      END

      IF (@TP = 'D' AND @D_PE_CPhone IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALC(@D_PE_CPhone, @I_PE_CPhone) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH_BASE 'U', 'PE', @I_PE_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'PE_CPhone', @D_PE_CPhone)
      END

      IF (@TP = 'D' AND @D_PE_Email IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALC(@D_PE_Email, @I_PE_Email) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH_BASE 'U', 'PE', @I_PE_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'PE_Email', @D_PE_Email)
      END

      IF (@TP = 'D' AND @D_PE_LL_TSTMP IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALD(@D_PE_LL_TSTMP, @I_PE_LL_TSTMP) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH_BASE 'U', 'PE', @I_PE_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'PE_LL_TSTMP', @D_PE_LL_TSTMP)
      END

    IF (@TP = 'U' AND isnull(@NEWPW,'') <> '')
    BEGIN
    set @hash = jsharmony.myHASH('S', @I_PE_ID, @NEWPW);

    if (@hash is null)
    BEGIN
      CLOSE CUR_PE_IUD
      DEALLOCATE CUR_PE_IUD
      SET @M = 'Application Error - Incorrect Password'
      raiserror(@M,16,1)
      ROLLBACK TRANSACTION
      return
    END

        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH_BASE 'U', 'PE', @I_PE_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'PE_PW', '*')

      SET @UPDATE_PW = 'Y'
    END


    END  /* END OF "IF @TP='U' OR @TP='D'"  */


  /******************************************/
  /****** SPECIAL BACK ACTION - BEGIN  ******/
  /******************************************/

    IF (@TP='U' AND @MY_AUD_SEQ <> 0)
  BEGIN
      UPDATE jsharmony.PE
       SET PE_STSDt = CASE WHEN jsharmony.NONEQUALC(@D_PE_STS, @I_PE_STS) > 0 THEN @CURDTTM ELSE PE_STSDt END,
         PE_MTstmp = @CURDTTM,
       PE_MU = @MYUSER,
       PE_Hash = case @UPDATE_PW when 'Y' then @hash else PE_Hash end,
       PE_PW1 = NULL,
       PE_PW2 = NULL
       WHERE PE.PE_ID = @I_PE_ID;
    END  
    ELSE IF (@TP='U' AND (@I_PE_PW1 is not null or @I_PE_PW2 is not null))
  BEGIN
      UPDATE jsharmony.PE
       SET PE_PW1 = NULL,
       PE_PW2 = NULL
       WHERE PE.PE_ID = @I_PE_ID;
    END  

  /*****************************************/
  /****** SPECIAL BACK ACTION - END   ******/
  /*****************************************/



            
    FETCH NEXT FROM CUR_PE_IUD
        INTO @D_PE_ID, @I_PE_ID,
             @D_PE_STS, @I_PE_STS,
             @D_PE_FName, @I_PE_FName,
       @D_PE_MName, @I_PE_MName,
       @D_PE_LName, @I_PE_LName,
             @D_PE_JTitle, @I_PE_JTitle,
             @D_PE_BPhone, @I_PE_BPhone,
             @D_PE_CPhone, @I_PE_CPhone,
             @D_PE_Email, @I_PE_Email,
             @D_PE_PW1, @I_PE_PW1,
             @D_PE_PW2, @I_PE_PW2,
             @D_PE_LL_TSTMP, @I_PE_LL_TSTMP

  END
  CLOSE CUR_PE_IUD
  DEALLOCATE CUR_PE_IUD

  /*
  EXEC [jsharmony].[ZZ-FILEDEBUG] 'TRIGGER','PE_IUD','RETURN', ''
  */

  RETURN

END
GO
ALTER TABLE [jsharmony].[PE] ENABLE TRIGGER [PE_IUD]
GO
/****** Object:  Trigger [jsharmony].[PPD_IUD]    Script Date: 10/25/2017 7:00:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE trigger [jsharmony].[PPD_IUD] on [jsharmony].[PPD]
for insert, update, delete
AS
BEGIN
  set nocount on
  DECLARE @TP char(1)
  DECLARE @MYGETDATE DATETIME2(7)
  DECLARE @MYUSER NVARCHAR(20)

  if exists (select * from inserted)
    if exists (select * from deleted)
      set @TP = 'U'
    else
      set @TP = 'I'
  else
    if exists (select * from deleted)
    set @TP = 'D'
    else
      return
  
  SET @MYGETDATE = jsharmony.myNOW()

  SET @MYUSER = jsharmony.myCUSER() 

  if(@TP = 'I')
  BEGIN
  
    update jsharmony.PPD set
      PPD_ETstmp = @MYGETDATE,
      PPD_EU =@MYUSER, 
      PPD_MTstmp = @MYGETDATE,
      PPD_MU =@MYUSER 
      from INSERTED
      WHERE ppd.ppd_id=INSERTED.ppd_id 
  
  END
  ELSE 
  BEGIN
  
    if(@TP = 'U')
    BEGIN
      update jsharmony.PPD set
        PPD_MTstmp = @MYGETDATE,
        PPD_MU =@MYUSER 
      from inserted 
      WHERE ppd.ppd_id=INSERTED.ppd_id 
    END

  END

  RETURN

END



GO
ALTER TABLE [jsharmony].[PPD] ENABLE TRIGGER [PPD_IUD]
GO
/****** Object:  Trigger [jsharmony].[PPP_IUD]    Script Date: 10/25/2017 7:00:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE trigger [jsharmony].[PPP_IUD] on [jsharmony].[PPP]
for insert, update, delete
AS
BEGIN
  set nocount on
  DECLARE @TP char(1)
  DECLARE @MYGETDATE DATETIME2(7)
  DECLARE @CURDTTM DATETIME2(7)
  DECLARE @CURDTTM_CHAR NVARCHAR(MAX)
  DECLARE @MYUSER NVARCHAR(20)
  DECLARE @ERRTXT NVARCHAR(MAX)
  DECLARE @MY_AUD_SEQ NUMERIC(20,0)
  DECLARE CUR_PPP_I CURSOR LOCAL FOR SELECT PPP_ID,
                                      PPP_PROCESS, 
                                      PPP_ATTRIB, 
                                      PPP_VAL
                                 FROM INSERTED
  DECLARE CUR_PPP_DU CURSOR LOCAL FOR 
     SELECT  d.PPP_ID, i.PPP_ID,
             d.PPP_PROCESS, i.PPP_PROCESS,
             d.PPP_ATTRIB, i.PPP_ATTRIB,
             d.PPP_VAL, i.PPP_VAL
       FROM deleted d FULL OUTER JOIN inserted i
                       ON i.PPP_ID = d.PPP_ID
  DECLARE @D_PPP_ID bigint
  DECLARE @I_PPP_ID bigint
  DECLARE @D_PPP_PROCESS nvarchar(MAX)
  DECLARE @I_PPP_PROCESS nvarchar(MAX)
  DECLARE @D_PPP_ATTRIB nvarchar(MAX)
  DECLARE @I_PPP_ATTRIB nvarchar(MAX)
  DECLARE @D_PPP_VAL nvarchar(MAX)
  DECLARE @I_PPP_VAL nvarchar(MAX)
  DECLARE @C BIGINT
  DECLARE @M NVARCHAR(MAX)
  DECLARE @WK_ID bigint

  if exists (select * from inserted)
    if exists (select * from deleted)
      set @TP = 'U'
    else
      set @TP = 'I'
  else
    if exists (select * from deleted)
    set @TP = 'D'
    else
      return
  
  SET @MYGETDATE = SYSDATETIME()

  SET @CURDTTM = jsharmony.myNOW_DO()
  SET @CURDTTM_CHAR = CONVERT(NVARCHAR, @CURDTTM, 120)+'.0000000'
  SET @MYUSER = jsharmony.myCUSER() 

  IF @TP = 'U' AND UPDATE(PPP_ID)
  BEGIN
    raiserror('Cannot update identity',16,1)
  ROLLBACK TRANSACTION
    return
  END

  if(@TP = 'I')
  BEGIN
  
    update jsharmony.PPP set
      PPP_ETstmp = @CURDTTM,
      PPP_EU =@MYUSER, 
      PPP_MTstmp = @CURDTTM,
      PPP_MU =@MYUSER 
      from inserted WHERE PPP.PPP_id=INSERTED.PPP_id
  
    OPEN CUR_PPP_I
    FETCH NEXT FROM CUR_PPP_I INTO @I_PPP_ID, 
                                   @I_PPP_PROCESS, 
                                   @I_PPP_ATTRIB,
                                   @I_PPP_VAL
    WHILE (@@Fetch_Status = 0)
    BEGIN
      
      IF (@I_PPP_VAL IS NOT NULL)
      BEGIN
        SET @ERRTXT = jsharmony.CHECK_PP('PPP',@I_PPP_PROCESS,@I_PPP_ATTRIB,@I_PPP_VAL)
        IF @ERRTXT IS NOT null  
        BEGIN
          CLOSE CUR_PPP_I
          DEALLOCATE CUR_PPP_I
          raiserror(@ERRTXT,16,1)
        ROLLBACK TRANSACTION
          return
        END
      END

    SET @WK_ID = ISNULL(@I_PPP_ID,@D_PPP_ID)
    EXEC  @MY_AUD_SEQ = jsharmony.AUDH_BASE @TP, 'PPP', @WK_ID, @MYUSER, @CURDTTM

      FETCH NEXT FROM CUR_PPP_I INTO @I_PPP_ID, 
                                     @I_PPP_PROCESS, 
                                     @I_PPP_ATTRIB,
                                     @I_PPP_VAL
    END
    CLOSE CUR_PPP_I
    DEALLOCATE CUR_PPP_I
  END
  ELSE 
  BEGIN
  
    if(@TP = 'U')
    BEGIN
      update jsharmony.PPP set
        PPP_MTstmp = @CURDTTM,
        PPP_MU =@MYUSER 
        from inserted WHERE PPP.PPP_id = INSERTED.PPP_id
    END

    OPEN CUR_PPP_DU
    FETCH NEXT FROM CUR_PPP_DU
          INTO @D_PPP_ID, @I_PPP_ID,
               @D_PPP_PROCESS, @I_PPP_PROCESS,
               @D_PPP_ATTRIB, @I_PPP_ATTRIB,
               @D_PPP_VAL, @I_PPP_VAL
    WHILE (@@Fetch_Status = 0)
    BEGIN
      if(@TP = 'U')
      BEGIN
     
        IF (@I_PPP_VAL IS NOT NULL)
        BEGIN
          SET @ERRTXT = jsharmony.CHECK_PP('PPP',@I_PPP_PROCESS,@I_PPP_ATTRIB,@I_PPP_VAL)
          IF @ERRTXT IS NOT null  
          BEGIN
            CLOSE CUR_PPP_DU
            DEALLOCATE CUR_PPP_DU
            raiserror(@ERRTXT,16,1)
          ROLLBACK TRANSACTION
            return
          END
        END
      END

    SET @WK_ID = ISNULL(@I_PPP_ID,@D_PPP_ID)
    EXEC  @MY_AUD_SEQ = jsharmony.AUDH_BASE @TP, 'PPP', @WK_ID, @MYUSER, @CURDTTM
            
      FETCH NEXT FROM CUR_PPP_DU
            INTO @D_PPP_ID, @I_PPP_ID,
                 @D_PPP_PROCESS, @I_PPP_PROCESS,
                 @D_PPP_ATTRIB, @I_PPP_ATTRIB,
                 @D_PPP_VAL, @I_PPP_VAL
    END
    CLOSE CUR_PPP_DU
    DEALLOCATE CUR_PPP_DU
  END

  RETURN

END

GO
ALTER TABLE [jsharmony].[PPP] ENABLE TRIGGER [PPP_IUD]
GO
/****** Object:  Trigger [jsharmony].[SPEF_IUD]    Script Date: 10/25/2017 7:00:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [jsharmony].[SPEF_IUD] on [jsharmony].[SPEF]
for insert, update, delete
AS
BEGIN
  set nocount on
  DECLARE @TP char(1)
  DECLARE @CURDTTM DATETIME2(7)
  DECLARE @CURDTTM_CHAR NVARCHAR(MAX)
  DECLARE @MYUSER NVARCHAR(20)
  DECLARE @ERRTXT NVARCHAR(500)
  DECLARE @MY_AUD_SEQ NUMERIC(20,0)
  DECLARE CUR_SPEF_IUD CURSOR LOCAL FOR
     SELECT  d.SPEF_ID, i.SPEF_ID,
           d.PE_ID, i.PE_ID,
           d.SF_NAME, i.SF_NAME
       FROM deleted d FULL OUTER JOIN inserted i
                       ON i.SPEF_ID = d.SPEF_ID;
  DECLARE @D_SPEF_ID bigint
  DECLARE @I_SPEF_ID bigint
  DECLARE @D_PE_ID bigint
  DECLARE @I_PE_ID bigint
  DECLARE @D_SF_NAME nvarchar(max)
  DECLARE @I_SF_NAME nvarchar(max)

  DECLARE @MYERROR_NO INT = 0
  DECLARE @MYERROR_MSG NVARCHAR(MAX) = NULL

  DECLARE @xloc nvarchar(MAX)
  DECLARE @xtxt nvarchar(MAX)

  DECLARE @DYNSQL NVARCHAR(MAX)
  DECLARE @C BIGINT
  DECLARE @WK_SPEF_ID BIGINT
  DECLARE @WK_SUBJ NVARCHAR(MAX)
  DECLARE @CODEVAL NVARCHAR(MAX)

  /*
  EXEC [jsharmony].[ZZ-FILEDEBUG] 'TRIGGER','SPEF_IUD','START', ''
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
  
  SET @CURDTTM = jsharmony.myNOW_DO()
  SET @CURDTTM_CHAR = CONVERT(NVARCHAR, @CURDTTM, 120)+'.0000000'
  SET @MYUSER = jsharmony.myCUSER() 

  IF @TP = 'U' AND UPDATE(SPEF_ID)
  BEGIN
    EXEC [jsharmony].[ZZ-FILEDEBUG] 'TRIGGER','SPEF_IUD','ERR', 'Cannot update ID'
    raiserror('Cannot update identity',16,1)
    ROLLBACK TRANSACTION
    return
  END

  IF @TP = 'U' AND UPDATE(PE_ID)
  BEGIN
    EXEC [jsharmony].[ZZ-FILEDEBUG] 'TRIGGER','SPEF_IUD','ERR', 'Cannot update PE_ID'
    raiserror('Cannot update foreign key',16,1)
    ROLLBACK TRANSACTION
    return
  END

  
  OPEN CUR_SPEF_IUD
  FETCH NEXT FROM CUR_SPEF_IUD
        INTO @D_SPEF_ID, @I_SPEF_ID,
             @D_PE_ID, @I_PE_ID,
             @D_SF_NAME, @I_SF_NAME

  WHILE (@@Fetch_Status = 0)
  BEGIN
      
    SET @xloc = 'TP=' + ISNULL(@TP,'null')
  SET @xtxt = 'I_SPEF_ID=' + LTRIM(ISNULL(STR(@I_SPEF_ID),'null')) +
              ' D_SPEF_ID=' + LTRIM(ISNULL(STR(@D_SPEF_ID),'null')) 
    /* 
  EXEC [jsharmony].[ZZ-FILEDEBUG] 'TRIGGER','SPEF_IUD',@xloc, @xtxt 
  */

  /******************************************/
  /****** SPECIAL FRONT ACTION - BEGIN ******/
  /******************************************/
  
    SELECT @WK_SUBJ = isnull(PE_LNAME,'')+', '+isnull(PE_FNAME,'')
    FROM jsharmony.PE
     WHERE PE_ID = @I_PE_ID; 

  /******************************************/
  /****** SPECIAL FRONT ACTION - END   ******/
  /******************************************/

    SET @MY_AUD_SEQ = 0
  IF (@TP='I' OR @TP='D')
  BEGIN  
    SET @WK_SPEF_ID = ISNULL(@D_SPEF_ID,@I_SPEF_ID)
    EXEC  @MY_AUD_SEQ = jsharmony.AUDH_BASE @TP, 'SPEF', @WK_SPEF_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ
  END

    IF @TP='U' OR @TP='D'
  BEGIN

      IF (@TP = 'D' AND @D_PE_ID IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALN(@D_PE_ID, @I_PE_ID) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH_BASE 'U', 'SPEF', @I_SPEF_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'PE_ID', @D_PE_ID)
      END

      IF (@TP = 'D' AND @D_SF_NAME IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALC(@D_SF_NAME, @I_SF_NAME) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH_BASE 'U', 'SPEF', @I_SPEF_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'SF_NAME', @D_SF_NAME)
      END

    END  /* END OF "IF @TP='U' OR @TP='D'"  */

  /******************************************/
  /****** SPECIAL BACK ACTION - BEGIN  ******/
  /******************************************/

  /*****************************************/
  /****** SPECIAL BACK ACTION - END   ******/
  /*****************************************/
            
    FETCH NEXT FROM CUR_SPEF_IUD
          INTO @D_SPEF_ID, @I_SPEF_ID,
               @D_PE_ID,  @I_PE_ID,
               @D_SF_NAME,  @I_SF_NAME
  END
  CLOSE CUR_SPEF_IUD
  DEALLOCATE CUR_SPEF_IUD
  /*
  EXEC [jsharmony].[ZZ-FILEDEBUG] 'TRIGGER','SPEF_IUD','RETURN', ''
  */
  RETURN

END
GO
ALTER TABLE [jsharmony].[SPEF] ENABLE TRIGGER [SPEF_IUD]
GO
/****** Object:  Trigger [jsharmony].[SPER_IUD]    Script Date: 10/25/2017 7:00:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [jsharmony].[SPER_IUD] on [jsharmony].[SPER]
for insert, update, delete
AS
BEGIN
  set nocount on
  DECLARE @TP char(1)
  DECLARE @CURDTTM DATETIME2(7)
  DECLARE @CURDTTM_CHAR NVARCHAR(MAX)
  DECLARE @MYUSER NVARCHAR(20)
  DECLARE @ERRTXT NVARCHAR(500)
  DECLARE @MY_AUD_SEQ NUMERIC(20,0)
  DECLARE CUR_SPER_IUD CURSOR LOCAL FOR
     SELECT  d.SPER_ID, i.SPER_ID,
           d.PE_ID, i.PE_ID,
           d.SR_NAME, i.SR_NAME
       FROM deleted d FULL OUTER JOIN inserted i
                       ON i.SPER_ID = d.SPER_ID;
  DECLARE @D_SPER_ID bigint
  DECLARE @I_SPER_ID bigint
  DECLARE @D_PE_ID bigint
  DECLARE @I_PE_ID bigint
  DECLARE @D_SR_NAME nvarchar(max)
  DECLARE @I_SR_NAME nvarchar(max)

  DECLARE @MYERROR_NO INT = 0
  DECLARE @MYERROR_MSG NVARCHAR(MAX) = NULL

  DECLARE @xloc nvarchar(MAX)
  DECLARE @xtxt nvarchar(MAX)

  DECLARE @DYNSQL NVARCHAR(MAX)
  DECLARE @C BIGINT
  DECLARE @WK_SPER_ID BIGINT
  DECLARE @WK_SUBJ NVARCHAR(MAX)
  DECLARE @CODEVAL NVARCHAR(MAX)

  DECLARE @MY_PE_ID BIGINT = jsharmony.mype()

  /*
  EXEC [jsharmony].[ZZ-FILEDEBUG] 'TRIGGER','SPER_IUD','START', ''
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
  
  SET @CURDTTM = jsharmony.myNOW_DO()
  SET @CURDTTM_CHAR = CONVERT(NVARCHAR, @CURDTTM, 120)+'.0000000'
  SET @MYUSER = jsharmony.myCUSER() 

  IF @TP = 'U' AND UPDATE(SPER_ID)
  BEGIN
    EXEC [jsharmony].[ZZ-FILEDEBUG] 'TRIGGER','SPER_IUD','ERR', 'Cannot update ID'
    raiserror('Cannot update identity',16,1)
    ROLLBACK TRANSACTION
    return
  END

  IF @TP = 'U' AND UPDATE(PE_ID)
  BEGIN
    EXEC [jsharmony].[ZZ-FILEDEBUG] 'TRIGGER','SPER_IUD','ERR', 'Cannot update PE_ID'
    raiserror('Cannot update foreign key',16,1)
    ROLLBACK TRANSACTION
    return
  END

  
  OPEN CUR_SPER_IUD
  FETCH NEXT FROM CUR_SPER_IUD
        INTO @D_SPER_ID, @I_SPER_ID,
             @D_PE_ID, @I_PE_ID,
             @D_SR_NAME, @I_SR_NAME

  WHILE (@@Fetch_Status = 0)
  BEGIN
      
    SET @xloc = 'TP=' + ISNULL(@TP,'null')
  SET @xtxt = 'I_SPER_ID=' + LTRIM(ISNULL(STR(@I_SPER_ID),'null')) +
              ' D_SPER_ID=' + LTRIM(ISNULL(STR(@D_SPER_ID),'null')) 
    /*
    EXEC [jsharmony].[ZZ-FILEDEBUG] 'TRIGGER','SPER_IUD',@xloc, @xtxt
  */

  /******************************************/
  /****** SPECIAL FRONT ACTION - BEGIN ******/
  /******************************************/

  IF @MY_PE_ID is not null
  BEGIN
    IF isnull(@I_PE_ID, @D_PE_ID) <> @MY_PE_ID
    BEGIN
      /* NOT ME */
        IF (case when @TP = 'D' then @D_SR_NAME else @I_SR_NAME end) = 'DEV' 
      BEGIN
          IF not exists (select sr_name
                           from jsharmony.V_MY_ROLES
                          where SR_NAME = 'DEV') 
          BEGIN
            EXEC [jsharmony].[ZZ-FILEDEBUG] 'TRIGGER','SPER_IUD','ERR', 'Only Developer can maintain Developer Role(1)'
            raiserror('Application Error - Only Developer can maintain Developer Role(1).',16,1)
            ROLLBACK TRANSACTION
            return
        END
      END
      END
      ELSE 
    BEGIN
      /* ME */
        IF @TP <> 'D' and @I_SR_NAME = 'DEV' 
      BEGIN
          EXEC [jsharmony].[ZZ-FILEDEBUG] 'TRIGGER','SPER_IUD','ERR', 'Only Developer can maintain Developer Role(2)'
          raiserror('Application Error - Only Developer can maintain Developer Role(2).',16,1)
          ROLLBACK TRANSACTION
          return
      END
      END
  END

    SELECT @WK_SUBJ = isnull(PE_LNAME,'')+', '+isnull(PE_FNAME,'')
    FROM jsharmony.PE
     WHERE PE_ID = @I_PE_ID; 

  /******************************************/
  /****** SPECIAL FRONT ACTION - END   ******/
  /******************************************/

    SET @MY_AUD_SEQ = 0
  IF (@TP='I' OR @TP='D')
  BEGIN  
    SET @WK_SPER_ID = ISNULL(@D_SPER_ID,@I_SPER_ID)
    EXEC  @MY_AUD_SEQ = jsharmony.AUDH_BASE @TP, 'SPER', @WK_SPER_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ
  END

    IF @TP='U' OR @TP='D'
  BEGIN

      IF (@TP = 'D' AND @D_PE_ID IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALN(@D_PE_ID, @I_PE_ID) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH_BASE 'U', 'SPER', @I_SPER_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'PE_ID', @D_PE_ID)
      END

      IF (@TP = 'D' AND @D_SR_NAME IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALC(@D_SR_NAME, @I_SR_NAME) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH_BASE 'U', 'SPER', @I_SPER_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'SR_NAME', @D_SR_NAME)
      END

    END  /* END OF "IF @TP='U' OR @TP='D'"  */

  /******************************************/
  /****** SPECIAL BACK ACTION - BEGIN  ******/
  /******************************************/

  /*****************************************/
  /****** SPECIAL BACK ACTION - END   ******/
  /*****************************************/
            
    FETCH NEXT FROM CUR_SPER_IUD
          INTO @D_SPER_ID, @I_SPER_ID,
               @D_PE_ID,  @I_PE_ID,
               @D_SR_NAME,  @I_SR_NAME
  END
  CLOSE CUR_SPER_IUD
  DEALLOCATE CUR_SPER_IUD

  /*
  EXEC [jsharmony].[ZZ-FILEDEBUG] 'TRIGGER','SPER_IUD','RETURN', ''
  */

  RETURN

END
GO
ALTER TABLE [jsharmony].[SPER] ENABLE TRIGGER [SPER_IUD]
GO
/****** Object:  Trigger [jsharmony].[TXT_IUD]    Script Date: 10/25/2017 7:00:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE trigger [jsharmony].[TXT_IUD] on [jsharmony].[TXT]
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
  DECLARE CUR_TXT_IUD CURSOR LOCAL FOR
     SELECT  d.TXT_ID, i.TXT_ID,
           d.TXT_PROCESS, i.TXT_PROCESS,
           d.TXT_ATTRIB, i.TXT_ATTRIB,
           d.TXT_TYPE, i.TXT_TYPE,
       d.TXT_TVAL, i.TXT_TVAL,
       d.TXT_VAL, i.TXT_VAL,
             d.TXT_BCC, i.TXT_BCC,
             d.TXT_DESC, i.TXT_DESC
       FROM deleted d FULL OUTER JOIN inserted i
                       ON i.TXT_ID = d.TXT_ID;
  DECLARE @D_TXT_ID bigint
  DECLARE @I_TXT_ID bigint
  DECLARE @D_TXT_PROCESS NVARCHAR(MAX)
  DECLARE @I_TXT_PROCESS NVARCHAR(MAX)
  DECLARE @D_TXT_ATTRIB NVARCHAR(MAX)
  DECLARE @I_TXT_ATTRIB NVARCHAR(MAX)
  DECLARE @D_TXT_TYPE NVARCHAR(MAX)
  DECLARE @I_TXT_TYPE NVARCHAR(MAX)
  DECLARE @D_TXT_TVAL NVARCHAR(MAX)
  DECLARE @I_TXT_TVAL NVARCHAR(MAX)
  DECLARE @D_TXT_VAL NVARCHAR(MAX) 
  DECLARE @I_TXT_VAL NVARCHAR(MAX)
  DECLARE @D_TXT_BCC NVARCHAR(MAX) 
  DECLARE @I_TXT_BCC NVARCHAR(MAX)
  DECLARE @D_TXT_DESC NVARCHAR(MAX) 
  DECLARE @I_TXT_DESC NVARCHAR(MAX)

  DECLARE @MYERROR_NO INT = 0
  DECLARE @MYERROR_MSG NVARCHAR(MAX) = NULL

  DECLARE @xloc nvarchar(MAX)
  DECLARE @xtxt nvarchar(MAX)

  DECLARE @DYNSQL NVARCHAR(MAX)
  DECLARE @C BIGINT
  DECLARE @CODEVAL NVARCHAR(MAX)
  DECLARE @WK_TXT_ID bigint
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
  
  SET @CURDTTM = jsharmony.myNOW_DO()
  SET @CURDT = jsharmony.myTODATE(@CURDTTM)
  SET @CURDTTM_CHAR = CONVERT(NVARCHAR, @CURDTTM, 120)+'.0000000'
  SET @MYUSER = jsharmony.myCUSER() 

  IF @TP = 'U' AND UPDATE(TXT_ID)
  BEGIN
    EXEC [jsharmony].[ZZ-FILEDEBUG] 'TRIGGER','TXT_IUD','ERR', 'Cannot update ID'
    raiserror('Cannot update identity',16,1)
    ROLLBACK TRANSACTION
    return
  END

  
  OPEN CUR_TXT_IUD
  FETCH NEXT FROM CUR_TXT_IUD
        INTO @D_TXT_ID, @I_TXT_ID,
             @D_TXT_PROCESS, @I_TXT_PROCESS,
             @D_TXT_ATTRIB, @I_TXT_ATTRIB,
             @D_TXT_TYPE, @I_TXT_TYPE,
       @D_TXT_TVAL, @I_TXT_TVAL,
       @D_TXT_VAL, @I_TXT_VAL,
             @D_TXT_BCC, @I_TXT_BCC,
             @D_TXT_DESC, @I_TXT_DESC

  WHILE (@@Fetch_Status = 0)
  BEGIN

  /******************************************/
  /****** SPECIAL FRONT ACTION - BEGIN ******/
  /******************************************/

    IF (@TP='I')
  BEGIN
      UPDATE jsharmony.TXT
       SET TXT_ETstmp = @CURDTTM,
       TXT_EU = @MYUSER,
         TXT_MTstmp = @CURDTTM,
       TXT_MU = @MYUSER
       WHERE TXT.TXT_ID = @I_TXT_ID;
    END  

  /******************************************/
  /****** SPECIAL FRONT ACTION - END   ******/
  /******************************************/


    SET @MY_AUD_SEQ = 0
  IF (@TP='I' OR @TP='D')
  BEGIN  
    SET @WK_TXT_ID = ISNULL(@D_TXT_ID,@I_TXT_ID)
    EXEC  @MY_AUD_SEQ = jsharmony.AUDH_BASE @TP, 'TXT', @WK_TXT_ID, @MYUSER, @CURDTTM
  END

 
    IF @TP='U' OR @TP='D'
  BEGIN

      IF (@TP = 'D' AND @D_TXT_PROCESS IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALC(@D_TXT_PROCESS, @I_TXT_PROCESS) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH_BASE 'U', 'TXT', @I_TXT_ID, @MYUSER, @CURDTTM
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'TXT_PROCESS', @D_TXT_PROCESS)
      END

      IF (@TP = 'D' AND @D_TXT_ATTRIB IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALC(@D_TXT_ATTRIB, @I_TXT_ATTRIB) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH_BASE 'U', 'TXT', @I_TXT_ID, @MYUSER, @CURDTTM
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'TXT_ATTRIB', @D_TXT_ATTRIB)
      END
    
      IF (@TP = 'D' AND @D_TXT_TYPE IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALC(@D_TXT_TYPE, @I_TXT_TYPE) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH_BASE 'U', 'TXT', @I_TXT_ID, @MYUSER, @CURDTTM
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'TXT_TYPE', @D_TXT_TYPE)
      END

      IF (@TP = 'D' AND @D_TXT_TVAL IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALC(@D_TXT_TVAL, @I_TXT_TVAL) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH_BASE 'U', 'TXT', @I_TXT_ID, @MYUSER, @CURDTTM
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'TXT_TVAL', @D_TXT_TVAL)
      END

      IF (@TP = 'D' AND @D_TXT_VAL IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALC(@D_TXT_VAL, @I_TXT_VAL) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH_BASE 'U', 'TXT', @I_TXT_ID, @MYUSER, @CURDTTM
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'TXT_VAL', @D_TXT_VAL)
      END

      IF (@TP = 'D' AND @D_TXT_BCC IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALC(@D_TXT_BCC, @I_TXT_BCC) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH_BASE 'U', 'TXT', @I_TXT_ID, @MYUSER, @CURDTTM
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'TXT_BCC', @D_TXT_BCC)
      END

      IF (@TP = 'D' AND @D_TXT_DESC IS NOT NULL OR
          @TP = 'U' AND jsharmony.NONEQUALC(@D_TXT_DESC, @I_TXT_DESC) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
      EXEC  @MY_AUD_SEQ = jsharmony.AUDH_BASE 'U', 'TXT', @I_TXT_ID, @MYUSER, @CURDTTM
        INSERT INTO jsharmony.AUD_D VALUES (@MY_AUD_SEQ, 'TXT_DESC', @D_TXT_DESC)
      END


    END  /* END OF "IF @TP='U' OR @TP='D'"  */


  /******************************************/
  /****** SPECIAL BACK ACTION - BEGIN  ******/
  /******************************************/

    IF (@TP='U' AND @MY_AUD_SEQ <> 0)
  BEGIN
      UPDATE jsharmony.TXT
       SET TXT_MTstmp = @CURDTTM,
       TXT_MU = @MYUSER
       WHERE TXT.TXT_ID = @I_TXT_ID;
    END  

  /*****************************************/
  /****** SPECIAL BACK ACTION - END   ******/
  /*****************************************/



            
    FETCH NEXT FROM CUR_TXT_IUD
        INTO @D_TXT_ID, @I_TXT_ID,
             @D_TXT_PROCESS,  @I_TXT_PROCESS,
             @D_TXT_ATTRIB, @I_TXT_ATTRIB,
             @D_TXT_TYPE, @I_TXT_TYPE,
       @D_TXT_TVAL, @I_TXT_TVAL,
       @D_TXT_VAL, @I_TXT_VAL,
             @D_TXT_BCC, @I_TXT_BCC,
             @D_TXT_DESC, @I_TXT_DESC

  END
  CLOSE CUR_TXT_IUD
  DEALLOCATE CUR_TXT_IUD

  RETURN

  ERROR_BAD:  

  CLOSE CUR_PL_IUD
  DEALLOCATE CUR_PL_IUD
  raiserror(@M ,16,1)
  ROLLBACK TRANSACTION
  return

END

GO
ALTER TABLE [jsharmony].[TXT] ENABLE TRIGGER [TXT_IUD]
GO
/****** Object:  Trigger [jsharmony].[XPP_IUD]    Script Date: 10/25/2017 7:00:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE trigger [jsharmony].[XPP_IUD] on [jsharmony].[XPP]
for insert, update, delete
AS
BEGIN
  set nocount on
  DECLARE @TP char(1)
  DECLARE @MYGETDATE DATETIME2(7)
  DECLARE @CURDTTM DATETIME2(7)
  DECLARE @CURDTTM_CHAR NVARCHAR(MAX)
  DECLARE @MYUSER NVARCHAR(20)
  DECLARE @ERRTXT NVARCHAR(MAX)
  DECLARE @MY_AUD_SEQ NUMERIC(20,0)
  DECLARE CUR_XPP_I CURSOR LOCAL FOR SELECT XPP_ID,
                                      XPP_PROCESS, 
                                      XPP_ATTRIB, 
                                      XPP_VAL
                                 FROM INSERTED
  DECLARE CUR_XPP_DU CURSOR LOCAL FOR 
     SELECT  d.XPP_ID, i.XPP_ID,
             d.XPP_PROCESS, i.XPP_PROCESS,
             d.XPP_ATTRIB, i.XPP_ATTRIB,
             d.XPP_VAL, i.XPP_VAL
       FROM deleted d FULL OUTER JOIN inserted i
                       ON i.XPP_ID = d.XPP_ID
  DECLARE @D_XPP_ID bigint
  DECLARE @I_XPP_ID bigint
  DECLARE @D_XPP_PROCESS nvarchar(MAX)
  DECLARE @I_XPP_PROCESS nvarchar(MAX)
  DECLARE @D_XPP_ATTRIB nvarchar(MAX)
  DECLARE @I_XPP_ATTRIB nvarchar(MAX)
  DECLARE @D_XPP_VAL nvarchar(MAX)
  DECLARE @I_XPP_VAL nvarchar(MAX)
  DECLARE @C BIGINT
  DECLARE @M NVARCHAR(MAX)
  DECLARE @WK_ID bigint

  if exists (select * from inserted)
    if exists (select * from deleted)
      set @TP = 'U'
    else
      set @TP = 'I'
  else
    if exists (select * from deleted)
    set @TP = 'D'
    else
      return
  
  SET @MYGETDATE = SYSDATETIME()

  SET @CURDTTM = jsharmony.myNOW_DO()
  SET @CURDTTM_CHAR = CONVERT(NVARCHAR, @CURDTTM, 120)+'.0000000'
  SET @MYUSER = jsharmony.myCUSER() 

  IF @TP = 'U' AND UPDATE(XPP_ID)
  BEGIN
    raiserror('Cannot update identity',16,1)
  ROLLBACK TRANSACTION
    return
  END

  if(@TP = 'I')
  BEGIN
  
    update jsharmony.XPP set
      XPP_ETstmp = @CURDTTM,
      XPP_EU =@MYUSER, 
      XPP_MTstmp = @CURDTTM,
      XPP_MU =@MYUSER 
      from inserted WHERE XPP.XPP_id=INSERTED.XPP_id
  
    OPEN CUR_XPP_I
    FETCH NEXT FROM CUR_XPP_I INTO @I_XPP_ID, 
                                   @I_XPP_PROCESS, 
                                   @I_XPP_ATTRIB,
                                   @I_XPP_VAL
    WHILE (@@Fetch_Status = 0)
    BEGIN
      
      SET @ERRTXT = jsharmony.CHECK_PP('XPP',@I_XPP_PROCESS,@I_XPP_ATTRIB,@I_XPP_VAL)
      
      IF @ERRTXT IS NOT null  
      BEGIN
        CLOSE CUR_XPP_I
        DEALLOCATE CUR_XPP_I
        raiserror(@ERRTXT,16,1)
      ROLLBACK TRANSACTION
        return
      END

    SET @WK_ID = ISNULL(@I_XPP_ID,@D_XPP_ID)
    EXEC  @MY_AUD_SEQ = jsharmony.AUDH_BASE @TP, 'XPP', @WK_ID, @MYUSER, @CURDTTM

      FETCH NEXT FROM CUR_XPP_I INTO @I_XPP_ID, 
                                     @I_XPP_PROCESS, 
                                     @I_XPP_ATTRIB,
                                     @I_XPP_VAL
    END
    CLOSE CUR_XPP_I
    DEALLOCATE CUR_XPP_I
  END
  ELSE 
  BEGIN
  
    if(@TP = 'U')
    BEGIN
      update jsharmony.XPP set
        XPP_MTstmp = @CURDTTM,
        XPP_MU =@MYUSER 
        from inserted WHERE XPP.XPP_id = INSERTED.XPP_id
    END

    OPEN CUR_XPP_DU
    FETCH NEXT FROM CUR_XPP_DU
          INTO @D_XPP_ID, @I_XPP_ID,
               @D_XPP_PROCESS, @I_XPP_PROCESS,
               @D_XPP_ATTRIB, @I_XPP_ATTRIB,
               @D_XPP_VAL, @I_XPP_VAL
    WHILE (@@Fetch_Status = 0)
    BEGIN
      if(@TP = 'U')
      BEGIN
      
        SET @ERRTXT = jsharmony.CHECK_PP('XPP',@I_XPP_PROCESS,@I_XPP_ATTRIB,@I_XPP_VAL)
       
        IF @ERRTXT IS NOT null  
        BEGIN
          CLOSE CUR_XPP_DU
          DEALLOCATE CUR_XPP_DU
          raiserror(@ERRTXT,16,1)
        ROLLBACK TRANSACTION
          return
        END
      END

    SET @WK_ID = ISNULL(@I_XPP_ID,@D_XPP_ID)
    EXEC  @MY_AUD_SEQ = jsharmony.AUDH_BASE @TP, 'XPP', @WK_ID, @MYUSER, @CURDTTM
            
      FETCH NEXT FROM CUR_XPP_DU
            INTO @D_XPP_ID, @I_XPP_ID,
                 @D_XPP_PROCESS, @I_XPP_PROCESS,
                 @D_XPP_ATTRIB, @I_XPP_ATTRIB,
                 @D_XPP_VAL, @I_XPP_VAL
    END
    CLOSE CUR_XPP_DU
    DEALLOCATE CUR_XPP_DU
  END

  RETURN

END

GO
ALTER TABLE [jsharmony].[XPP] ENABLE TRIGGER [XPP_IUD]
GO
/****** Object:  Trigger [jsharmony].[V_CRMSEL_IUD_INSTEADOF_UPDATE]    Script Date: 10/25/2017 7:00:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE trigger [jsharmony].[V_CRMSEL_IUD_INSTEADOF_UPDATE] on [jsharmony].[V_CRMSEL]
instead of update
as
begin
  set nocount on
  declare @I int
  IF (UPDATE(CRMSEL_SEL))
  BEGIN
  set @I = 1

    delete from jsharmony.CRM
   where CRM_ID in (
     select i.CRM_ID
       from inserted i
        inner join deleted d on d.SM_ID=i.SM_ID
        where jsharmony.NONEQUALN(d.CRMSEL_SEL, i.CRMSEL_SEL) > 0
      and isnull(i.CRMSEL_SEL,0) = 0);

   
    insert into jsharmony.CRM (CR_NAME, SM_ID)
     select i.NEW_CR_NAME, i.SM_ID
       from inserted i
        inner join deleted d on d.SM_ID=i.SM_ID
        where jsharmony.NONEQUALN(d.CRMSEL_SEL, i.CRMSEL_SEL) > 0
      and isnull(i.CRMSEL_SEL,0) = 1;
   
  END
end



GO
/****** Object:  Trigger [jsharmony].[V_SRMSEL_IUD_INSTEADOF_UPDATE]    Script Date: 10/25/2017 7:00:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE trigger [jsharmony].[V_SRMSEL_IUD_INSTEADOF_UPDATE] on [jsharmony].[V_SRMSEL]
instead of update
as
begin
  set nocount on
  declare @I int
  IF (UPDATE(SRMSEL_SEL))
  BEGIN
  set @I = 1

    delete from jsharmony.SRM
   where SRM_ID in (
     select i.SRM_ID
       from inserted i
        inner join deleted d on d.SM_ID=i.SM_ID
        where jsharmony.NONEQUALN(d.SRMSEL_SEL, i.SRMSEL_SEL) > 0
      and isnull(i.SRMSEL_SEL,0) = 0);

   
    insert into jsharmony.SRM (SR_NAME, SM_ID)
     select i.NEW_SR_NAME, i.SM_ID
       from inserted i
        inner join deleted d on d.SM_ID=i.SM_ID
        where jsharmony.NONEQUALN(d.SRMSEL_SEL, i.SRMSEL_SEL) > 0
      and isnull(i.SRMSEL_SEL,0) = 1;
   
  END
end


GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_D', @level2type=N'COLUMN',@level2name=N'AUD_SEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_D', @level2type=N'COLUMN',@level2name=N'AUD_SEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_D', @level2type=N'COLUMN',@level2name=N'AUD_SEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_D', @level2type=N'COLUMN',@level2name=N'AUD_SEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_D', @level2type=N'COLUMN',@level2name=N'AUD_SEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Audit Trail Sequence - AUD_H' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_D', @level2type=N'COLUMN',@level2name=N'AUD_SEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=0x00 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_D', @level2type=N'COLUMN',@level2name=N'AUD_SEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_D', @level2type=N'COLUMN',@level2name=N'COLUMN_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_D', @level2type=N'COLUMN',@level2name=N'COLUMN_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_D', @level2type=N'COLUMN',@level2name=N'COLUMN_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_D', @level2type=N'COLUMN',@level2name=N'COLUMN_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_D', @level2type=N'COLUMN',@level2name=N'COLUMN_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Audit Trail Detail Column Name' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_D', @level2type=N'COLUMN',@level2name=N'COLUMN_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=0x00 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_D', @level2type=N'COLUMN',@level2name=N'COLUMN_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_D', @level2type=N'COLUMN',@level2name=N'COLUMN_VAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_D', @level2type=N'COLUMN',@level2name=N'COLUMN_VAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_D', @level2type=N'COLUMN',@level2name=N'COLUMN_VAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=4515 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_D', @level2type=N'COLUMN',@level2name=N'COLUMN_VAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_D', @level2type=N'COLUMN',@level2name=N'COLUMN_VAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Audit Trail Detail Previous Value' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_D', @level2type=N'COLUMN',@level2name=N'COLUMN_VAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=0x00 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_D', @level2type=N'COLUMN',@level2name=N'COLUMN_VAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DatasheetForeThemeColorIndex', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_D'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DatasheetGridlinesThemeColorIndex', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_D'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DefaultView', @value=0x02 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_D'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Audit Trail Detail (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_D'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Filter', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_D'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_FilterOnLoad', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_D'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_HideNewField', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_D'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_OrderBy', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_D'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_OrderByOn', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_D'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TableMaxRecords', @value=10000 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_D'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ThemeFontIndex', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_D'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TotalsRow', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_D'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_SEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_SEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_SEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_SEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_SEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Audit Trail Sequence' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_SEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_SEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'TABLE_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'TABLE_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'TABLE_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=960 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'TABLE_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'TABLE_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Audit Trail Header Table Name' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'TABLE_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'TABLE_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'TABLE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'TABLE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'TABLE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'TABLE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'TABLE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Audit Trail Header ID Value' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'TABLE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'TABLE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_OP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_OP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_OP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_OP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_OP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Audit Trail Header Operation - DUI' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_OP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_OP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_U'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_U'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_U'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_U'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_U'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Audit Trail Header User Number' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_U'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_U'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_Tstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_Tstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_Tstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=3690 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_Tstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_Tstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Audit Trail Header Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_Tstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_Tstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Customer ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'C_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Equipment ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'E_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Reference Name' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'REF_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Reference ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'REF_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Subject' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'SUBJ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AlternateBackThemeColorIndex', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DatasheetForeThemeColorIndex', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DatasheetGridlinesThemeColorIndex', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DefaultView', @value=0x02 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Audit Trail Header (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Filter', @value=N'(CT_ID="200011")' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_FilterOnLoad', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_HideNewField', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_LinkChildFields', @value=N'AUD_SEQ' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_LinkMasterFields', @value=N'AUD_SEQ' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_OrderBy', @value=N'[AUD_H].[AUD_SEQ] DESC, [AUD_H].[TABLE_NO], [AUD_H].[AUD_OP], [AUD_H].[TABLE_NAME]' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_OrderByOn', @value=1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_OrderByOnLoad', @value=1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Orientation', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SubdatasheetName', @value=N'dbo.AUD_D' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TableMaxRecords', @value=1000000 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ThemeFontIndex', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TotalsRow', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'AUD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'IMD' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'NT', @value=N'N' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'TRIGGER', @value=N'Referential Integrity back to AC' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'C_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel Status - ACTIVE, HOLD, CLOSED - UCOD_AHC' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'NT', @value=N'N' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_STSDt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_STSDt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_STSDt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_STSDt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_STSDt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel Status Last Change Date' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_STSDt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_STSDt'
GO
EXEC sys.sp_addextendedproperty @name=N'TRIGGER', @value=N'Date' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_STSDt'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_FName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_FName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_FName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_FName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_FName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_FName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel First Name' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_FName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_FName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel Middle Name' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_MName'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_LName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_LName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_LName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_LName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_LName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_LName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel Last Name' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_LName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_LName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel Job Title' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_JTitle'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel Business Phone Number' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_BPhone'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel Cell Phone Number' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_CPhone'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_Email'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_Email'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_Email'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_Email'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_Email'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_Email'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel Email' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_Email'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_Email'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel Entry User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel Last Modification User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel Hash' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_Hash'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel last login IP' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_LL_IP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel last login timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_LL_Tstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel System Notes' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Customer Personnel (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPER', @level2type=N'COLUMN',@level2name=N'PE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel Role System Notes' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPER', @level2type=N'COLUMN',@level2name=N'CPER_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel Role ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPER', @level2type=N'COLUMN',@level2name=N'CPER_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role Name' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPER', @level2type=N'COLUMN',@level2name=N'CR_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Customer - Personnel Roles (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CPER'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'SIMD' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Role ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'NT', @value=N'' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Role Sequence' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_SEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Role Status COD(AHC) - ACTIVE, HOLD, CLOSED' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'NT', @value=N'N' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Role Name' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=4920 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Role Description' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Role System Notes' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AlternateBackThemeColorIndex', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DatasheetForeThemeColorIndex', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DatasheetGridlinesThemeColorIndex', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DefaultView', @value=0x02 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Customer - Roles (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Filter', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_FilterOnLoad', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_HideNewField', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_OrderBy', @value=N'[CR].[CR_Name]' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_OrderByOn', @value=1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_OrderByOnLoad', @value=1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Orientation', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TableMaxRecords', @value=10000 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ThemeFontIndex', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TotalsRow', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Menu Item ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CRM', @level2type=N'COLUMN',@level2name=N'SM_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role Menu Item System Notes' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CRM', @level2type=N'COLUMN',@level2name=N'CRM_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role Menu Item ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CRM', @level2type=N'COLUMN',@level2name=N'CRM_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role Name' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CRM', @level2type=N'COLUMN',@level2name=N'CR_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Customer - Role Menu Items (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'CRM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'D', @level2type=N'COLUMN',@level2name=N'D_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document Scope - UCOD_D_SCOPE' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'D', @level2type=N'COLUMN',@level2name=N'D_SCOPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document Scope ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'D', @level2type=N'COLUMN',@level2name=N'D_SCOPE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client ID - C' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'D', @level2type=N'COLUMN',@level2name=N'C_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Employee ID - E' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'D', @level2type=N'COLUMN',@level2name=N'E_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document Status - UCOD_AC1' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'D', @level2type=N'COLUMN',@level2name=N'D_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document Category - GCOD2_D_SCOPE_D_CTGR' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'D', @level2type=N'COLUMN',@level2name=N'D_CTGR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document Description' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'D', @level2type=N'COLUMN',@level2name=N'D_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document Extension (file suffix)' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'D', @level2type=N'COLUMN',@level2name=N'D_EXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document Size in bytes' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'D', @level2type=N'COLUMN',@level2name=N'D_SIZE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document File Name' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'D', @level2type=N'COLUMN',@level2name=N'D_FileName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'D', @level2type=N'COLUMN',@level2name=N'D_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document Entry User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'D', @level2type=N'COLUMN',@level2name=N'D_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'D', @level2type=N'COLUMN',@level2name=N'D_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document Last Modification User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'D', @level2type=N'COLUMN',@level2name=N'D_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document Last Upload Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'D', @level2type=N'COLUMN',@level2name=N'D_UTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document Last Upload User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'D', @level2type=N'COLUMN',@level2name=N'D_UU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document System Notes' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'D', @level2type=N'COLUMN',@level2name=N'D_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Documents (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'D'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Table (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'DUAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Name' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=2 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=5565 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Description' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Code Description' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'CODECODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Attrib Description' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'CODEATTRIBMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=3 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=4 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Entry User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=5 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=6 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Last Modification User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=7 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header System Notes' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AlternateBackThemeColorIndex', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DatasheetForeThemeColorIndex', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DatasheetGridlinesThemeColorIndex', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DefaultView', @value=0x02 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User Codes Header (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Filter', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_FilterOnLoad', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_HideNewField', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_OrderBy', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_OrderByOn', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_OrderByOnLoad', @value=1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Orientation', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TableMaxRecords', @value=10000 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ThemeFontIndex', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TotalsRow', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_D_SCOPE_D_CTGR', @level2type=N'COLUMN',@level2name=N'GCOD2_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Sequence' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_D_SCOPE_D_CTGR', @level2type=N'COLUMN',@level2name=N'CODSEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_D_SCOPE_D_CTGR', @level2type=N'COLUMN',@level2name=N'CODEVAL1'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Description' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_D_SCOPE_D_CTGR', @level2type=N'COLUMN',@level2name=N'CODETXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Additional Code' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_D_SCOPE_D_CTGR', @level2type=N'COLUMN',@level2name=N'CODECODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Date' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_D_SCOPE_D_CTGR', @level2type=N'COLUMN',@level2name=N'CODETDT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Comment' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_D_SCOPE_D_CTGR', @level2type=N'COLUMN',@level2name=N'CODETCM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_D_SCOPE_D_CTGR', @level2type=N'COLUMN',@level2name=N'COD_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_D_SCOPE_D_CTGR', @level2type=N'COLUMN',@level2name=N'COD_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_D_SCOPE_D_CTGR', @level2type=N'COLUMN',@level2name=N'COD_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_D_SCOPE_D_CTGR', @level2type=N'COLUMN',@level2name=N'COD_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code System Notes' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_D_SCOPE_D_CTGR', @level2type=N'COLUMN',@level2name=N'COD_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User Codes 2 - Document Scope / Category' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_D_SCOPE_D_CTGR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Name' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=2 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=5565 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Description' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Code Description' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'CODECODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Attrib Description' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'CODEATTRIBMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=3 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=4 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Entry User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=5 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=6 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Last Modification User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=7 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header System Notes' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AlternateBackThemeColorIndex', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DatasheetForeThemeColorIndex', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DatasheetGridlinesThemeColorIndex', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DefaultView', @value=0x02 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User Codes 2 Header (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Filter', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_FilterOnLoad', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_HideNewField', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_OrderBy', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_OrderByOn', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_OrderByOnLoad', @value=1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Orientation', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TableMaxRecords', @value=10000 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ThemeFontIndex', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TotalsRow', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GCOD2_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'GPP Process Name' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GPP', @level2type=N'COLUMN',@level2name=N'GPP_PROCESS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'GPP Attribute (Parameter) Name' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GPP', @level2type=N'COLUMN',@level2name=N'GPP_ATTRIB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'GPP Attribute (Parameter) value' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GPP', @level2type=N'COLUMN',@level2name=N'GPP_VAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Process Parameters - Global (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'GPP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'H', @level2type=N'COLUMN',@level2name=N'H_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help Header Code' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'H', @level2type=N'COLUMN',@level2name=N'HP_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help Title' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'H', @level2type=N'COLUMN',@level2name=N'H_Title'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help Text' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'H', @level2type=N'COLUMN',@level2name=N'H_Text'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'H', @level2type=N'COLUMN',@level2name=N'H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help Entry User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'H', @level2type=N'COLUMN',@level2name=N'H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help Last Modification Entry' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'H', @level2type=N'COLUMN',@level2name=N'H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help Last Modification User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'H', @level2type=N'COLUMN',@level2name=N'H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help UNIQUE - not null HP_CODE unique' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'H', @level2type=N'COLUMN',@level2name=N'H_UNIQUE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help Sequence' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'H', @level2type=N'COLUMN',@level2name=N'H_SEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help - Show on Admin Index' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'H', @level2type=N'COLUMN',@level2name=N'H_INDEX_A'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help - Show on Portal Index' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'H', @level2type=N'COLUMN',@level2name=N'H_INDEX_P'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help Panel Code' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'HP', @level2type=N'COLUMN',@level2name=N'HP_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help Panel Description' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'HP', @level2type=N'COLUMN',@level2name=N'HP_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help Panel ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'HP', @level2type=N'COLUMN',@level2name=N'HP_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help Header (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'HP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Note' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'N', @level2type=N'COLUMN',@level2name=N'N_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Note Scope - UCOD_N_SCOPE' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'N', @level2type=N'COLUMN',@level2name=N'N_SCOPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Note Scope ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'N', @level2type=N'COLUMN',@level2name=N'N_SCOPE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Note Status - UCOD_AC1' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'N', @level2type=N'COLUMN',@level2name=N'N_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client ID - C' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'N', @level2type=N'COLUMN',@level2name=N'C_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Employee ID - E' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'N', @level2type=N'COLUMN',@level2name=N'E_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Note Type - UCOD_N_TYPE - C,S,U' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'N', @level2type=N'COLUMN',@level2name=N'N_TYPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Note NOTE' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'N', @level2type=N'COLUMN',@level2name=N'N_Note'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Note Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'N', @level2type=N'COLUMN',@level2name=N'N_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Note Entry User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'N', @level2type=N'COLUMN',@level2name=N'N_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Note Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'N', @level2type=N'COLUMN',@level2name=N'N_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Note Last Modification User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'N', @level2type=N'COLUMN',@level2name=N'N_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Note System Notes' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'N', @level2type=N'COLUMN',@level2name=N'N_Snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Notes (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'N'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Table (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'NUMBERS'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'IMD' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'NT', @value=N'N' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'TRIGGER', @value=N'Referential Integrity back to AC' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Status ACTIVE, HOLD, CLOSED - UCOD_AHC' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'NT', @value=N'N' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_STSDt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_STSDt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_STSDt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_STSDt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_STSDt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Status Last Change Date' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_STSDt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_STSDt'
GO
EXEC sys.sp_addextendedproperty @name=N'TRIGGER', @value=N'Date' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_STSDt'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_FName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_FName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_FName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_FName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_FName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_FName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel First Name' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_FName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_FName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Middle Name' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_MName'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_LName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_LName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_LName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_LName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_LName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_LName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Last Name' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_LName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_LName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Job Title' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_JTitle'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Business Phone Number' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_BPhone'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Cell Phone Number' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_CPhone'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel country - UCOD_COUNTRY' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_COUNTRY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel address' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel city' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_CITY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel state - UCOD2_COUNTRY_STATE' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_STATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel zip code' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_ZIP'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_EMAIL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_EMAIL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_EMAIL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_EMAIL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_EMAIL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_EMAIL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Email' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_EMAIL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_EMAIL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel start date' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_STARTDT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel end date' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_ENDDT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel user notes' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_UNOTES'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Entry User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Last Modification User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Hash' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_Hash'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel last login IP' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_LL_IP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel last login timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_LL_Tstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel System Notes' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'PPD Process Name' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PPD', @level2type=N'COLUMN',@level2name=N'PPD_PROCESS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'PPD Attribute (Parameter) Name' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PPD', @level2type=N'COLUMN',@level2name=N'PPD_ATTRIB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'PPD Attribute (Parameter) Description' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PPD', @level2type=N'COLUMN',@level2name=N'PPD_DESC'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'PPD Attribute (Parameter) Type - UCOD_PPD_TYPE' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PPD', @level2type=N'COLUMN',@level2name=N'PPD_TYPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Process Parameters Dictionary (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PPD'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PPP', @level2type=N'COLUMN',@level2name=N'PE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'XPP Process Name' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PPP', @level2type=N'COLUMN',@level2name=N'PPP_PROCESS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'XPP Attribute (Parameter) Name' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PPP', @level2type=N'COLUMN',@level2name=N'PPP_ATTRIB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'XPP Attribute (Parameter) value' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PPP', @level2type=N'COLUMN',@level2name=N'PPP_VAL'
GO
EXEC sys.sp_addextendedproperty @name=N'ASPA_Title', @value=N'Personal Process Parameters' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PPP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Process Parameters - Personal (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'PPP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Queue Request ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQ', @level2type=N'COLUMN',@level2name=N'RQ_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Queue Request Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQ', @level2type=N'COLUMN',@level2name=N'RQ_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Queue Request Entry User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQ', @level2type=N'COLUMN',@level2name=N'RQ_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Queue Request Queue Name' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQ', @level2type=N'COLUMN',@level2name=N'RQ_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Queue Request Message' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQ', @level2type=N'COLUMN',@level2name=N'RQ_MESSAGE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Queue Request Result - OK, ERROR' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQ', @level2type=N'COLUMN',@level2name=N'RQ_RSLT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Queue Request Result Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQ', @level2type=N'COLUMN',@level2name=N'RQ_RSLT_TStmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Queue Request Result User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQ', @level2type=N'COLUMN',@level2name=N'RQ_RSLT_U'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Queue Request System Notes' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQ', @level2type=N'COLUMN',@level2name=N'RQ_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Queue Request (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQST', @level2type=N'COLUMN',@level2name=N'RQST_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQST', @level2type=N'COLUMN',@level2name=N'RQST_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Entry User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQST', @level2type=N'COLUMN',@level2name=N'RQST_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Source - UCOD_RQST_SOURCE' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQST', @level2type=N'COLUMN',@level2name=N'RQST_SOURCE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Type - UCOD_RQST_ATYPE' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQST', @level2type=N'COLUMN',@level2name=N'RQST_ATYPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Name' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQST', @level2type=N'COLUMN',@level2name=N'RQST_ANAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Parameters' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQST', @level2type=N'COLUMN',@level2name=N'RQST_PARMS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Result - OK, ERROR' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQST', @level2type=N'COLUMN',@level2name=N'RQST_RSLT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Result Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQST', @level2type=N'COLUMN',@level2name=N'RQST_RSLT_TStmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Result User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQST', @level2type=N'COLUMN',@level2name=N'RQST_RSLT_U'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request System Notes' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQST', @level2type=N'COLUMN',@level2name=N'RQST_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQST'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Document ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQST_D', @level2type=N'COLUMN',@level2name=N'RQST_D_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQST_D', @level2type=N'COLUMN',@level2name=N'RQST_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Document Scope' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQST_D', @level2type=N'COLUMN',@level2name=N'D_SCOPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Document Scope ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQST_D', @level2type=N'COLUMN',@level2name=N'D_SCOPE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Document Category' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQST_D', @level2type=N'COLUMN',@level2name=N'D_CTGR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Document Description' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQST_D', @level2type=N'COLUMN',@level2name=N'D_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request - Document (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQST_D'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Email ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQST_EMAIL', @level2type=N'COLUMN',@level2name=N'RQST_EMAIL_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQST_EMAIL', @level2type=N'COLUMN',@level2name=N'RQST_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Email SUBJECT' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQST_EMAIL', @level2type=N'COLUMN',@level2name=N'EMAIL_TXT_ATTRIB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Email TO' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQST_EMAIL', @level2type=N'COLUMN',@level2name=N'EMAIL_TO'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Email CC' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQST_EMAIL', @level2type=N'COLUMN',@level2name=N'EMAIL_CC'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Email BCC' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQST_EMAIL', @level2type=N'COLUMN',@level2name=N'EMAIL_BCC'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request - EMail (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQST_EMAIL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Note ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQST_N', @level2type=N'COLUMN',@level2name=N'RQST_N_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQST_N', @level2type=N'COLUMN',@level2name=N'RQST_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Note Scope' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQST_N', @level2type=N'COLUMN',@level2name=N'N_SCOPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Note Scope ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQST_N', @level2type=N'COLUMN',@level2name=N'N_SCOPE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Note Type' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQST_N', @level2type=N'COLUMN',@level2name=N'N_TYPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Note Note' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQST_N', @level2type=N'COLUMN',@level2name=N'N_Note'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request - Note (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQST_N'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Document ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQST_RQ', @level2type=N'COLUMN',@level2name=N'RQST_RQ_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQST_RQ', @level2type=N'COLUMN',@level2name=N'RQST_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request - RQ (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQST_RQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action SMS ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQST_SMS', @level2type=N'COLUMN',@level2name=N'RQST_SMS_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQST_SMS', @level2type=N'COLUMN',@level2name=N'RQST_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action SMS SUBJECT' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQST_SMS', @level2type=N'COLUMN',@level2name=N'SMS_TXT_ATTRIB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action SMS TO' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQST_SMS', @level2type=N'COLUMN',@level2name=N'SMS_TO'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request - SMS (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'RQST_SMS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Scripts (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SCRIPT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Function ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SF', @level2type=N'COLUMN',@level2name=N'SF_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Function Sequence' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SF', @level2type=N'COLUMN',@level2name=N'SF_SEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Function Status COD(AHC) - ACTIVE, HOLD, CLOSED' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SF', @level2type=N'COLUMN',@level2name=N'SF_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Function Name' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SF', @level2type=N'COLUMN',@level2name=N'SF_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Function Description' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SF', @level2type=N'COLUMN',@level2name=N'SF_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Function Code' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SF', @level2type=N'COLUMN',@level2name=N'SF_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Function Attrib' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SF', @level2type=N'COLUMN',@level2name=N'SF_ATTRIB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Function System Notes' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SF', @level2type=N'COLUMN',@level2name=N'SF_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Security - Functions (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SF'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Menu Item User Type - S-System, C-Customer' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_UTYPE'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'SIMD' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Menu Item ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'NT', @value=N'' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=2 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Menu Item Status COD(AHC) - ACTIVE, HOLD, CLOSED' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'NT', @value=N'N' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=4 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=2550 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Menu Item Name' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=5 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Menu Item Sequence' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Seq'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_DESC'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_DESC'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_DESC'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=6 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_DESC'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=3090 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_DESC'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_DESC'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Menu Item Description' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_DESC'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_DESC'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_DESCL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_DESCL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=7 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_DESCL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=4470 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_DESCL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_DESCL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Menu Item Description Long' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_DESCL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_DESCL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_DESCVL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_DESCVL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=8 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_DESCVL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=8370 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_DESCVL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_DESCVL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Menu Item Description Very Long' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_DESCVL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_DESCVL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Cmd'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Cmd'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=9 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Cmd'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Cmd'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Cmd'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Menu Item Command' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Cmd'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Cmd'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Image'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Image'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=10 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Image'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Image'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Image'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'For buttons as SMs: unique identifier for image' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Image'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Image'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=11 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Menu Item System Notes' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'ASPA_Title', @value=N'Security - Menu Items' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AlternateBackThemeColorIndex', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DatasheetForeThemeColorIndex', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DatasheetGridlinesThemeColorIndex', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DefaultView', @value=0x02 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Security - Menu Items (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Filter', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_FilterOnLoad', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_HideNewField', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_OrderBy', @value=N'[SM].[SMG_Name]' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_OrderByOn', @value=1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_OrderByOnLoad', @value=1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Orientation', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TableMaxRecords', @value=10000 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ThemeFontIndex', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TotalsRow', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SPEF', @level2type=N'COLUMN',@level2name=N'PE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Function System Notes' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SPEF', @level2type=N'COLUMN',@level2name=N'SPEF_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Function ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SPEF', @level2type=N'COLUMN',@level2name=N'SPEF_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Function Name' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SPEF', @level2type=N'COLUMN',@level2name=N'SF_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'ASPA_Title', @value=N'Security - Personnel Functions' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SPEF'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Security - Personnel Functions (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SPEF'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SPER', @level2type=N'COLUMN',@level2name=N'PE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Role System Notes' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SPER', @level2type=N'COLUMN',@level2name=N'SPER_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Role ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SPER', @level2type=N'COLUMN',@level2name=N'SPER_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role Name' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SPER', @level2type=N'COLUMN',@level2name=N'SR_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'ASPA_Title', @value=N'Security - Personnel Roles' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SPER'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Security - Personnel Roles (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SPER'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'SIMD' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'NT', @value=N'' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role Sequence' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_SEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role Status COD(AHC) - ACTIVE, HOLD, CLOSED' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'NT', @value=N'N' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role Name' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=4920 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role Description' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role Code' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role Attrib' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_ATTRIB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role System Notes' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'ASPA_Title', @value=N'Security - Roles' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AlternateBackThemeColorIndex', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DatasheetForeThemeColorIndex', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DatasheetGridlinesThemeColorIndex', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DefaultView', @value=0x02 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Security - Roles (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Filter', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_FilterOnLoad', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_HideNewField', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_OrderBy', @value=N'[SR].[SR_Name]' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_OrderByOn', @value=1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_OrderByOnLoad', @value=1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Orientation', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TableMaxRecords', @value=10000 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ThemeFontIndex', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TotalsRow', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Menu Item ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SRM', @level2type=N'COLUMN',@level2name=N'SM_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role Menu Item System Notes' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SRM', @level2type=N'COLUMN',@level2name=N'SRM_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role Menu Item ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SRM', @level2type=N'COLUMN',@level2name=N'SRM_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role Name' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SRM', @level2type=N'COLUMN',@level2name=N'SR_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Security - Role Menu Items (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'SRM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_PROCESS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_PROCESS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_PROCESS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_PROCESS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_PROCESS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SPP Process Name' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_PROCESS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_PROCESS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_ATTRIB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_ATTRIB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_ATTRIB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_ATTRIB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_ATTRIB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SPP Attribute (Parameter) Name' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_ATTRIB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_ATTRIB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SPP Attribute (Parameter) Type HTML / TAXT - UCOD_TXT_TYPE' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_TYPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_TVAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_TVAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_TVAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=1350 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_TVAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_TVAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SPP Attribute (Parameter) Title' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_TVAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_TVAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_VAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_VAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_VAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=10110 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_VAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_VAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SPP Attribute (Parameter) value' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_VAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_VAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SPP BCC' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_BCC'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=525 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SPP Description' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SPP ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SPP Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SPP Entry User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SPP Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SPP Last Modification User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'ASPA_Title', @value=N'String Process Parameters (EMAILS, etc)' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AlternateBackThemeColorIndex', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DatasheetForeThemeColorIndex', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DatasheetGridlinesThemeColorIndex', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DefaultView', @value=0x02 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'String Process Parameters (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Filter', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_FilterOnLoad', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_HideNewField', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_OrderBy', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_OrderByOn', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_OrderByOnLoad', @value=1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Orientation', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_RowHeight', @value=315 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TableMaxRecords', @value=10000 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ThemeFontIndex', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TotalsRow', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'TXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_AC', @level2type=N'COLUMN',@level2name=N'UCOD_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Sequence' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_AC', @level2type=N'COLUMN',@level2name=N'CODSEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_AC', @level2type=N'COLUMN',@level2name=N'CODEVAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Description' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_AC', @level2type=N'COLUMN',@level2name=N'CODETXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Additional Code' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_AC', @level2type=N'COLUMN',@level2name=N'CODECODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Date' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_AC', @level2type=N'COLUMN',@level2name=N'CODETDT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Comment' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_AC', @level2type=N'COLUMN',@level2name=N'CODETCM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_AC', @level2type=N'COLUMN',@level2name=N'COD_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_AC', @level2type=N'COLUMN',@level2name=N'COD_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_AC', @level2type=N'COLUMN',@level2name=N'COD_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_AC', @level2type=N'COLUMN',@level2name=N'COD_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code System Notes' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_AC', @level2type=N'COLUMN',@level2name=N'COD_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Codes - Active / Closed' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_AC'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_AC1', @level2type=N'COLUMN',@level2name=N'UCOD_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Sequence' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_AC1', @level2type=N'COLUMN',@level2name=N'CODSEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_AC1', @level2type=N'COLUMN',@level2name=N'CODEVAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Description' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_AC1', @level2type=N'COLUMN',@level2name=N'CODETXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Additional Code' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_AC1', @level2type=N'COLUMN',@level2name=N'CODECODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Date' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_AC1', @level2type=N'COLUMN',@level2name=N'CODETDT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Comment' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_AC1', @level2type=N'COLUMN',@level2name=N'CODETCM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_AC1', @level2type=N'COLUMN',@level2name=N'COD_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_AC1', @level2type=N'COLUMN',@level2name=N'COD_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_AC1', @level2type=N'COLUMN',@level2name=N'COD_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_AC1', @level2type=N'COLUMN',@level2name=N'COD_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code System Notes' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_AC1', @level2type=N'COLUMN',@level2name=N'COD_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Codes - A / C' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_AC1'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_AHC', @level2type=N'COLUMN',@level2name=N'UCOD_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Sequence' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_AHC', @level2type=N'COLUMN',@level2name=N'CODSEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_AHC', @level2type=N'COLUMN',@level2name=N'CODEVAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Description' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_AHC', @level2type=N'COLUMN',@level2name=N'CODETXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Additional Code' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_AHC', @level2type=N'COLUMN',@level2name=N'CODECODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Date' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_AHC', @level2type=N'COLUMN',@level2name=N'CODETDT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Comment' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_AHC', @level2type=N'COLUMN',@level2name=N'CODETCM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_AHC', @level2type=N'COLUMN',@level2name=N'COD_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_AHC', @level2type=N'COLUMN',@level2name=N'COD_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_AHC', @level2type=N'COLUMN',@level2name=N'COD_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_AHC', @level2type=N'COLUMN',@level2name=N'COD_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code System Notes' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_AHC', @level2type=N'COLUMN',@level2name=N'COD_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Codes - Active / Hold / Closed' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_AHC'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_COUNTRY', @level2type=N'COLUMN',@level2name=N'UCOD_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Sequence' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_COUNTRY', @level2type=N'COLUMN',@level2name=N'CODSEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_COUNTRY', @level2type=N'COLUMN',@level2name=N'CODEVAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Description' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_COUNTRY', @level2type=N'COLUMN',@level2name=N'CODETXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Additional Code' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_COUNTRY', @level2type=N'COLUMN',@level2name=N'CODECODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Date' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_COUNTRY', @level2type=N'COLUMN',@level2name=N'CODETDT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Comment' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_COUNTRY', @level2type=N'COLUMN',@level2name=N'CODETCM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_COUNTRY', @level2type=N'COLUMN',@level2name=N'COD_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_COUNTRY', @level2type=N'COLUMN',@level2name=N'COD_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_COUNTRY', @level2type=N'COLUMN',@level2name=N'COD_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_COUNTRY', @level2type=N'COLUMN',@level2name=N'COD_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code System Notes' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_COUNTRY', @level2type=N'COLUMN',@level2name=N'COD_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Codes - TOrder Payment Method' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_COUNTRY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_D_SCOPE', @level2type=N'COLUMN',@level2name=N'UCOD_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Sequence' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_D_SCOPE', @level2type=N'COLUMN',@level2name=N'CODSEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_D_SCOPE', @level2type=N'COLUMN',@level2name=N'CODEVAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Description' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_D_SCOPE', @level2type=N'COLUMN',@level2name=N'CODETXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Additional Code' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_D_SCOPE', @level2type=N'COLUMN',@level2name=N'CODECODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Date' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_D_SCOPE', @level2type=N'COLUMN',@level2name=N'CODETDT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Comment' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_D_SCOPE', @level2type=N'COLUMN',@level2name=N'CODETCM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_D_SCOPE', @level2type=N'COLUMN',@level2name=N'COD_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_D_SCOPE', @level2type=N'COLUMN',@level2name=N'COD_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_D_SCOPE', @level2type=N'COLUMN',@level2name=N'COD_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_D_SCOPE', @level2type=N'COLUMN',@level2name=N'COD_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code System Notes' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_D_SCOPE', @level2type=N'COLUMN',@level2name=N'COD_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Codes - Document Scope' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_D_SCOPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Name' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=2 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=5565 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Description' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=3 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=4 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Entry User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=5 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=6 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Last Modification User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=7 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header System Notes' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'ASPA_Title', @value=N'System Codes Header' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AlternateBackThemeColorIndex', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DatasheetForeThemeColorIndex', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DatasheetGridlinesThemeColorIndex', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DefaultView', @value=0x02 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Codes Header (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Filter', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_FilterOnLoad', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_HideNewField', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_OrderBy', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_OrderByOn', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_OrderByOnLoad', @value=1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Orientation', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TableMaxRecords', @value=10000 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ThemeFontIndex', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TotalsRow', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_N_SCOPE', @level2type=N'COLUMN',@level2name=N'UCOD_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Sequence' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_N_SCOPE', @level2type=N'COLUMN',@level2name=N'CODSEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_N_SCOPE', @level2type=N'COLUMN',@level2name=N'CODEVAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Description' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_N_SCOPE', @level2type=N'COLUMN',@level2name=N'CODETXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Additional Code' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_N_SCOPE', @level2type=N'COLUMN',@level2name=N'CODECODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Date' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_N_SCOPE', @level2type=N'COLUMN',@level2name=N'CODETDT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Comment' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_N_SCOPE', @level2type=N'COLUMN',@level2name=N'CODETCM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_N_SCOPE', @level2type=N'COLUMN',@level2name=N'COD_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_N_SCOPE', @level2type=N'COLUMN',@level2name=N'COD_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_N_SCOPE', @level2type=N'COLUMN',@level2name=N'COD_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_N_SCOPE', @level2type=N'COLUMN',@level2name=N'COD_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code System Notes' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_N_SCOPE', @level2type=N'COLUMN',@level2name=N'COD_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Codes - Note Scope' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_N_SCOPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_N_TYPE', @level2type=N'COLUMN',@level2name=N'UCOD_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Sequence' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_N_TYPE', @level2type=N'COLUMN',@level2name=N'CODSEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_N_TYPE', @level2type=N'COLUMN',@level2name=N'CODEVAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Description' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_N_TYPE', @level2type=N'COLUMN',@level2name=N'CODETXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Additional Code' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_N_TYPE', @level2type=N'COLUMN',@level2name=N'CODECODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Date' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_N_TYPE', @level2type=N'COLUMN',@level2name=N'CODETDT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Comment' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_N_TYPE', @level2type=N'COLUMN',@level2name=N'CODETCM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_N_TYPE', @level2type=N'COLUMN',@level2name=N'COD_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_N_TYPE', @level2type=N'COLUMN',@level2name=N'COD_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_N_TYPE', @level2type=N'COLUMN',@level2name=N'COD_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_N_TYPE', @level2type=N'COLUMN',@level2name=N'COD_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code System Notes' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_N_TYPE', @level2type=N'COLUMN',@level2name=N'COD_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Codes - Note Type' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_N_TYPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_PPD_TYPE', @level2type=N'COLUMN',@level2name=N'UCOD_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Sequence' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_PPD_TYPE', @level2type=N'COLUMN',@level2name=N'CODSEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_PPD_TYPE', @level2type=N'COLUMN',@level2name=N'CODEVAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Description' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_PPD_TYPE', @level2type=N'COLUMN',@level2name=N'CODETXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Additional Code' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_PPD_TYPE', @level2type=N'COLUMN',@level2name=N'CODECODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Date' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_PPD_TYPE', @level2type=N'COLUMN',@level2name=N'CODETDT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Comment' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_PPD_TYPE', @level2type=N'COLUMN',@level2name=N'CODETCM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_PPD_TYPE', @level2type=N'COLUMN',@level2name=N'COD_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_PPD_TYPE', @level2type=N'COLUMN',@level2name=N'COD_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_PPD_TYPE', @level2type=N'COLUMN',@level2name=N'COD_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_PPD_TYPE', @level2type=N'COLUMN',@level2name=N'COD_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code System Notes' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_PPD_TYPE', @level2type=N'COLUMN',@level2name=N'COD_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Codes - Process Parameter Type' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_PPD_TYPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_RQST_ATYPE', @level2type=N'COLUMN',@level2name=N'UCOD_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Sequence' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_RQST_ATYPE', @level2type=N'COLUMN',@level2name=N'CODSEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_RQST_ATYPE', @level2type=N'COLUMN',@level2name=N'CODEVAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Description' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_RQST_ATYPE', @level2type=N'COLUMN',@level2name=N'CODETXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Additional Code' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_RQST_ATYPE', @level2type=N'COLUMN',@level2name=N'CODECODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Date' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_RQST_ATYPE', @level2type=N'COLUMN',@level2name=N'CODETDT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Comment' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_RQST_ATYPE', @level2type=N'COLUMN',@level2name=N'CODETCM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_RQST_ATYPE', @level2type=N'COLUMN',@level2name=N'COD_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_RQST_ATYPE', @level2type=N'COLUMN',@level2name=N'COD_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_RQST_ATYPE', @level2type=N'COLUMN',@level2name=N'COD_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_RQST_ATYPE', @level2type=N'COLUMN',@level2name=N'COD_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code System Notes' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_RQST_ATYPE', @level2type=N'COLUMN',@level2name=N'COD_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Codes - Request Type (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_RQST_ATYPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_RQST_SOURCE', @level2type=N'COLUMN',@level2name=N'UCOD_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Sequence' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_RQST_SOURCE', @level2type=N'COLUMN',@level2name=N'CODSEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_RQST_SOURCE', @level2type=N'COLUMN',@level2name=N'CODEVAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Description' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_RQST_SOURCE', @level2type=N'COLUMN',@level2name=N'CODETXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Additional Code' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_RQST_SOURCE', @level2type=N'COLUMN',@level2name=N'CODECODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Date' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_RQST_SOURCE', @level2type=N'COLUMN',@level2name=N'CODETDT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Comment' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_RQST_SOURCE', @level2type=N'COLUMN',@level2name=N'CODETCM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_RQST_SOURCE', @level2type=N'COLUMN',@level2name=N'COD_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_RQST_SOURCE', @level2type=N'COLUMN',@level2name=N'COD_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_RQST_SOURCE', @level2type=N'COLUMN',@level2name=N'COD_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_RQST_SOURCE', @level2type=N'COLUMN',@level2name=N'COD_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code System Notes' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_RQST_SOURCE', @level2type=N'COLUMN',@level2name=N'COD_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Codes - Request Source (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_RQST_SOURCE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_TXT_TYPE', @level2type=N'COLUMN',@level2name=N'UCOD_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Sequence' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_TXT_TYPE', @level2type=N'COLUMN',@level2name=N'CODSEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_TXT_TYPE', @level2type=N'COLUMN',@level2name=N'CODEVAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Description' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_TXT_TYPE', @level2type=N'COLUMN',@level2name=N'CODETXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Additional Code' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_TXT_TYPE', @level2type=N'COLUMN',@level2name=N'CODECODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Date' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_TXT_TYPE', @level2type=N'COLUMN',@level2name=N'CODETDT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Comment' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_TXT_TYPE', @level2type=N'COLUMN',@level2name=N'CODETCM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_TXT_TYPE', @level2type=N'COLUMN',@level2name=N'COD_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_TXT_TYPE', @level2type=N'COLUMN',@level2name=N'COD_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_TXT_TYPE', @level2type=N'COLUMN',@level2name=N'COD_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_TXT_TYPE', @level2type=N'COLUMN',@level2name=N'COD_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code System Notes' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_TXT_TYPE', @level2type=N'COLUMN',@level2name=N'COD_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Codes - Text Type (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_TXT_TYPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_V_STS', @level2type=N'COLUMN',@level2name=N'UCOD_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Sequence' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_V_STS', @level2type=N'COLUMN',@level2name=N'CODSEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_V_STS', @level2type=N'COLUMN',@level2name=N'CODEVAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Description' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_V_STS', @level2type=N'COLUMN',@level2name=N'CODETXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Additional Code' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_V_STS', @level2type=N'COLUMN',@level2name=N'CODECODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Date' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_V_STS', @level2type=N'COLUMN',@level2name=N'CODETDT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Comment' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_V_STS', @level2type=N'COLUMN',@level2name=N'CODETCM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_V_STS', @level2type=N'COLUMN',@level2name=N'COD_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_V_STS', @level2type=N'COLUMN',@level2name=N'COD_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_V_STS', @level2type=N'COLUMN',@level2name=N'COD_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_V_STS', @level2type=N'COLUMN',@level2name=N'COD_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code System Notes' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_V_STS', @level2type=N'COLUMN',@level2name=N'COD_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Codes - Version Status' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD_V_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value ID' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_COUNTRY_STATE', @level2type=N'COLUMN',@level2name=N'UCOD2_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Sequence' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_COUNTRY_STATE', @level2type=N'COLUMN',@level2name=N'CODSEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_COUNTRY_STATE', @level2type=N'COLUMN',@level2name=N'CODEVAL1'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Description' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_COUNTRY_STATE', @level2type=N'COLUMN',@level2name=N'CODETXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Additional Code' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_COUNTRY_STATE', @level2type=N'COLUMN',@level2name=N'CODECODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Date' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_COUNTRY_STATE', @level2type=N'COLUMN',@level2name=N'CODETDT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Comment' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_COUNTRY_STATE', @level2type=N'COLUMN',@level2name=N'CODETCM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_COUNTRY_STATE', @level2type=N'COLUMN',@level2name=N'COD_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_COUNTRY_STATE', @level2type=N'COLUMN',@level2name=N'COD_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_COUNTRY_STATE', @level2type=N'COLUMN',@level2name=N'COD_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_COUNTRY_STATE', @level2type=N'COLUMN',@level2name=N'COD_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code System Notes' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_COUNTRY_STATE', @level2type=N'COLUMN',@level2name=N'COD_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Codes 2 - Country / State' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_COUNTRY_STATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Name' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=2 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=5565 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Description' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Code Description' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'CODECODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Attrib Description' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'CODEATTRIBMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=3 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=4 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Entry User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=5 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=6 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Last Modification User' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=7 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header System Notes' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AlternateBackThemeColorIndex', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DatasheetForeThemeColorIndex', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DatasheetGridlinesThemeColorIndex', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DefaultView', @value=0x02 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Codes 2 Header (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Filter', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_FilterOnLoad', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_HideNewField', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_OrderBy', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_OrderByOn', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_OrderByOnLoad', @value=1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Orientation', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TableMaxRecords', @value=10000 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ThemeFontIndex', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TotalsRow', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'UCOD2_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Version ID (internal)' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'V', @level2type=N'COLUMN',@level2name=N'V_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Version Component Name' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'V', @level2type=N'COLUMN',@level2name=N'V_COMP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Version Number - Major' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'V', @level2type=N'COLUMN',@level2name=N'V_NO_MAJOR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Version Number - Minor' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'V', @level2type=N'COLUMN',@level2name=N'V_NO_MINOR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Version Number - Build' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'V', @level2type=N'COLUMN',@level2name=N'V_NO_BUILD'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Version Number - Revision' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'V', @level2type=N'COLUMN',@level2name=N'V_NO_REV'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Version status - UCOD_V_STS' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'V', @level2type=N'COLUMN',@level2name=N'V_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Version Note' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'V', @level2type=N'COLUMN',@level2name=N'V_NOTE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Version entry date' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'V', @level2type=N'COLUMN',@level2name=N'V_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Version entry user' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'V', @level2type=N'COLUMN',@level2name=N'V_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Version last modification date' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'V', @level2type=N'COLUMN',@level2name=N'V_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Version last modification user' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'V', @level2type=N'COLUMN',@level2name=N'V_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Version System Notes' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'V', @level2type=N'COLUMN',@level2name=N'V_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Versions (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'V'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_PROCESS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_PROCESS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_PROCESS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_PROCESS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_PROCESS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'XPP Process Name' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_PROCESS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=0x00 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_PROCESS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_ATTRIB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_ATTRIB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_ATTRIB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=2460 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_ATTRIB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_ATTRIB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'XPP Attribute (Parameter) Name' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_ATTRIB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=0x00 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_ATTRIB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_VAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_VAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_VAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=3975 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_VAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_VAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'XPP Attribute (Parameter) value' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_VAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=0x00 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_VAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=0x00 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=0x00 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=0x00 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=0x00 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=0x00 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'ASPA_Title', @value=N'Installation Process Parameters' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AlternateBackThemeColorIndex', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DatasheetForeThemeColorIndex', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DatasheetGridlinesThemeColorIndex', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DefaultView', @value=0x02 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Process Parameters - System (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Filter', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_FilterOnLoad', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_HideNewField', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_OrderBy', @value=NULL , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_OrderByOn', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_OrderByOnLoad', @value=1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Orientation', @value=0x00 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TableMaxRecords', @value=10000 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ThemeFontIndex', @value=-1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TotalsRow', @value=0 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'TABLE',@level1name=N'XPP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "M"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "DUAL"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 136
               Right = 445
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SRM (jsharmony)"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 268
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'VIEW',@level1name=N'V_SRMSEL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'jsharmony', @level1type=N'VIEW',@level1name=N'V_SRMSEL'
GO
