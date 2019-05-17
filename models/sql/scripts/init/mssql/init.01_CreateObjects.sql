CREATE ROLE [{{schema}}_role_exec]
GO
CREATE ROLE [{{schema}}_role_dev]
GO
ALTER ROLE [db_datareader] ADD MEMBER [{{schema}}_role_exec]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [{{schema}}_role_exec]
GO
ALTER ROLE [db_datareader] ADD MEMBER [{{schema}}_role_dev]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [{{schema}}_role_dev]
GO
GRANT CREATE TABLE TO [{{schema}}_role_dev] AS [dbo]
GO
/*
GRANT VIEW ANY COLUMN ENCRYPTION KEY DEFINITION TO [public] AS [dbo]
GRANT VIEW ANY COLUMN MASTER KEY DEFINITION TO [public] AS [dbo]
*/
CREATE SCHEMA [jsharmony]
GO
GRANT ALTER ON SCHEMA::[jsharmony] TO [{{schema}}_role_dev] AS [dbo]
GO
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
               '         Entered:  '+{{schema}}.mymmddyyhhmi(@ETSTMP)+'  '+{{schema}}.mycuser_fmt(@EU)+
			   char(13)+char(10)+ 
               'Last Updated:  '+{{schema}}.mymmddyyhhmi(@MTSTMP)+'  '+{{schema}}.mycuser_fmt(@MU); 

  RETURN @rslt
END


GO
GRANT EXECUTE ON [jsharmony].[audit_info] TO [{{schema}}_role_exec] AS [dbo]
GRANT EXECUTE ON [jsharmony].[audit_info] TO [{{schema}}_role_dev] AS [dbo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE FUNCTION [jsharmony].[check_pp]
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
    FROM {{schema}}.PPD
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




SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [jsharmony].[d_filename]
(
	@in_D_ID bigint,
	@in_D_EXT NVARCHAR(MAX)
)	
RETURNS NVARCHAR(MAX)  
AS 
BEGIN
DECLARE @rslt NVARCHAR(MAX) = NULL

  SELECT @rslt = ('D'+CONVERT([varchar](50),@in_D_ID,(0)))+isnull(@in_D_EXT,'');

  RETURN (@rslt)

END

GO

GRANT EXECUTE ON {{schema}}.D_FILENAME TO {{schema}}_role_exec;
GO
GRANT EXECUTE ON {{schema}}.D_FILENAME TO {{schema}}_role_dev;
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [jsharmony].[exists_d]
(
	@tbl nvarchar(MAX),
	@id bigint
)	
RETURNS bit  
AS 
BEGIN
DECLARE @rslt BIT = 0

  select top(1) @rslt=1
    from {{schema}}.D
   where D_SCOPE = @tbl
     and D_SCOPE_ID = @id;	 

return(isnull(@rslt,0))
  
END










GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE FUNCTION [jsharmony].[exists_n]
(
	@tbl nvarchar(MAX),
	@id bigint
)	
RETURNS bit  
AS 
BEGIN
DECLARE @rslt BIT = 0

  select top(1) @rslt=1
    from {{schema}}.N
   where N_SCOPE = @tbl
     and N_SCOPE_ID = @id;	 

return(isnull(@rslt,0))
  
END









GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE FUNCTION [jsharmony].[get_cpe_name]
(
	@in_PE_ID BIGINT
)	
RETURNS NVARCHAR(MAX)  
AS 
BEGIN
DECLARE @rslt NVARCHAR(MAX) = NULL

  SELECT @rslt = PE_LName+', '+PE_FName
    FROM {{schema}}.CPE
   WHERE PE_ID = @in_PE_ID;

  RETURN (@rslt)

END


GO
GRANT EXECUTE ON [jsharmony].[GET_CPE_NAME] TO [{{schema}}_role_exec] AS [dbo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [jsharmony].[get_pe_name]
(
	@in_PE_ID BIGINT
)	
RETURNS NVARCHAR(MAX)  
AS 
BEGIN
DECLARE @rslt NVARCHAR(MAX) = NULL

  SELECT @rslt = PE_LName+', '+PE_FName
    FROM {{schema}}.PE
   WHERE PE_ID = @in_PE_ID;

  RETURN (@rslt)

END

GO
GRANT EXECUTE ON [jsharmony].[GET_PE_NAME] TO [{{schema}}_role_exec] AS [dbo]
GO
GRANT EXECUTE ON [jsharmony].[GET_PE_NAME] TO [{{schema}}_role_dev] AS [dbo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE FUNCTION [jsharmony].[get_ppd_desc]
(
	@in_PPD_PROCESS NVARCHAR(MAX),
	@in_PPD_ATTRIB NVARCHAR(MAX)
)	
RETURNS NVARCHAR(MAX)  
AS 
BEGIN
DECLARE @rslt NVARCHAR(MAX) = NULL

  SELECT @rslt = PPD_DESC
    FROM {{schema}}.PPD
   WHERE PPD_PROCESS = @in_PPD_PROCESS
     AND PPD_ATTRIB = @in_PPD_ATTRIB

  RETURN (@rslt)

END
GO
GRANT EXECUTE ON [jsharmony].[GET_PPD_DESC] TO [{{schema}}_role_exec] AS [dbo]
GO
GRANT EXECUTE ON [jsharmony].[GET_PPD_DESC] TO [{{schema}}_role_dev] AS [dbo]
GO




GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [jsharmony].[mycuser]
()	
RETURNS varchar(20)   
AS 
BEGIN
DECLARE @rslt varchar(20)

  SET @rslt = {{schema}}.myCUSER_DO()

  return (@rslt)

END



GO
GRANT REFERENCES ON [jsharmony].[myCUSER] TO [{{schema}}_role_dev] AS [dbo]
GO
GRANT EXECUTE ON [jsharmony].[myCUSER] TO [{{schema}}_role_exec] AS [dbo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE FUNCTION [jsharmony].[mycuser_do]
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
	  FROM {{schema}}.PE
     WHERE PE_Email = @an;
	
	SET @rslt = CASE WHEN @pe_id=(-1) THEN @an ELSE 'P'+CONVERT(VARCHAR(30),@pe_id) END
  END 
  return (@rslt)
END





GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE FUNCTION [jsharmony].[mycuser_fmt]
(@USER VARCHAR(20))	
RETURNS nvarchar(120)   
AS 
BEGIN
DECLARE @rslt nvarchar(255)

  SET @rslt = {{schema}}.myCUSER_FMT_DO(@USER)
  
  return (@rslt)

END




GO
GRANT REFERENCES ON [jsharmony].[myCUSER_FMT] TO [{{schema}}_role_dev] AS [dbo]
GO
GRANT EXECUTE ON [jsharmony].[myCUSER_FMT] TO [{{schema}}_role_exec] AS [dbo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE FUNCTION [jsharmony].[mycuser_fmt_do]
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
	 from {{schema}}.PE
    where convert(varchar(50),PE_ID)=substring(@USER,2,1024);
  end
  else if (substring(@USER,1,1)='C' and isnumeric(substring(@USER,2,1024))=1)
  begin
    set @rslt = @USER;
    select @rslt = 'C-'+isnull(PE_Name,'')
	 from {{schema}}.CPE
    where convert(varchar(50),PE_ID)=substring(@USER,2,1024);
  end

  return (@rslt)

END





GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE FUNCTION [jsharmony].[myhash]
(@TYPE CHAR(1),
 @PE_ID bigint,
 @PW nvarchar(255))	
RETURNS varbinary(200)   
AS 
BEGIN
DECLARE @rslt varbinary(200) = NULL
DECLARE @seed nvarchar(255) = NULL
DECLARE @val varchar(255)

  if (@TYPE = 'S')
  BEGIN
    select @seed = PP_VAL
	  from {{schema}}.V_PP
     where PP_PROCESS = 'USERS'
	   and PP_ATTRIB = 'HASH_SEED_S';
  END
  else if (@TYPE = 'C')
  BEGIN
    select @seed = PP_VAL
	  from {{schema}}.V_PP
     where PP_PROCESS = 'USERS'
	   and PP_ATTRIB = 'HASH_SEED_C';
  END

  if (@seed is not null
      and isnull(@PE_ID,0) > 0
	  and isnull(@PW,'') <> '')
  begin
    select @val = (convert(varchar(50),@PE_ID)+@PW+@seed)
    select @rslt = hashbytes('sha1',@val)
  end

  return @rslt

END






GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [jsharmony].[mymmddyyhhmi] (@X DATETIME2(7))
RETURNS varchar(140)
AS
BEGIN
	RETURN convert(varchar(50),@X,1)+' '+substring(convert(varchar(50),@X,14),1,5)
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE FUNCTION [jsharmony].[mynow]
()
RETURNS DATETIME2(7)   
AS 
BEGIN
  RETURN ({{schema}}.myNOW_DO())
END







GO
GRANT REFERENCES ON [jsharmony].[myNOW] TO [{{schema}}_role_dev] AS [dbo]
GO
GRANT EXECUTE ON [jsharmony].[myNOW] TO [{{schema}}_role_exec] AS [dbo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE FUNCTION [jsharmony].[mynow_do]
()
RETURNS DATETIME2(7)   
AS 
BEGIN
  RETURN (SYSDATETIME())
END







GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE FUNCTION [jsharmony].[mype]
()	
RETURNS bigint   
AS 
BEGIN
DECLARE @rslt bigint

  SET @rslt = {{schema}}.myPE_DO()

  return (@rslt)

END




GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [jsharmony].[mype_do]
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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE FUNCTION [jsharmony].[mypec]
()	
RETURNS bigint   
AS 
BEGIN
DECLARE @rslt bigint

  SET @rslt = {{schema}}.myPEC_DO()

  return (@rslt)

END




GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [jsharmony].[mypec_do]
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
    if substring(@an,1,1) = 'C' and isnumeric(substring(@an,2,100))<>0
	  set @rslt = convert(bigint,substring(@an,2,100)) 
  END 
  return (@rslt);
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [jsharmony].[mytodate] (@X DATETIME2(7))
RETURNS date
AS
BEGIN
	
	RETURN DATEADD(day, DATEDIFF(day, 0, @X), 0)


END



GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [jsharmony].[mytoday] ()
RETURNS date
AS
BEGIN
	RETURN ({{schema}}.myTODAY_DO())
END



GO
GRANT EXECUTE ON [jsharmony].[myTODAY] TO [{{schema}}_role_exec] AS [dbo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [jsharmony].[mytoday_do] ()
RETURNS date
AS
BEGIN
	
	RETURN DATEADD(day, DATEDIFF(day, 0, {{schema}}.myNOW()), 0)


END



GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE FUNCTION [jsharmony].[nonequalc]
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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE FUNCTION [jsharmony].[nonequald]
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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE FUNCTION [jsharmony].[nonequaln]
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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [jsharmony].[table_type]
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
GRANT EXECUTE ON [jsharmony].[TABLE_TYPE] TO [{{schema}}_role_exec] AS [dbo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[ppd](
	[ppd_process] [nvarchar](32) NOT NULL,
	[ppd_attrib] [nvarchar](16) NOT NULL,
	[ppd_desc] [nvarchar](255) NOT NULL,
	[ppd_type] [nvarchar](8) NOT NULL,
	[codename] [nvarchar](16) NULL,
	[ppd_gpp] [bit] NOT NULL,
	[ppd_ppp] [bit] NOT NULL,
	[ppd_xpp] [bit] NOT NULL,
	[ppd_id] [bigint] IDENTITY(1,1) NOT NULL,
	[ppd_etstmp] [datetime2](7) NOT NULL,
	[ppd_eu] [nvarchar](20) NOT NULL,
	[ppd_mtstmp] [datetime2](7) NOT NULL,
	[ppd_mu] [nvarchar](20) NOT NULL,
	[ppd_snotes] [nvarchar](max) NULL,
 CONSTRAINT [PK_PPD] PRIMARY KEY CLUSTERED 
(
	[PPD_PROCESS] ASC,
	[PPD_ATTRIB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/****** Script for SelectTopNRows command from SSMS  ******/
create view [jsharmony].[ucod_ppp_process_v] as
SELECT distinct
       NULL codseq
      ,PPD_PROCESS codeval
      ,PPD_PROCESS codetxt
      ,NULL codecode
      ,NULL codetdt
      ,NULL codetcm
  FROM {{schema}}.PPD
 where PPD_PPP = 1

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[aud_h](
	[aud_seq] [bigint] IDENTITY(1,1) NOT NULL,
	[table_name] [varchar](32) NOT NULL,
	[table_id] [bigint] NOT NULL,
	[aud_op] [char](10) NOT NULL,
	[aud_u] [nvarchar](20) NOT NULL,
	[db_k] [char](1) NOT NULL,
	[aud_tstmp] [datetime2](7) NOT NULL,
	[c_id] [bigint] NULL,
	[e_id] [bigint] NULL,
	[ref_name] [varchar](32) NULL,
	[ref_id] [bigint] NULL,
	[subj] [nvarchar](255) NULL,
 CONSTRAINT [PK_AUD_H] PRIMARY KEY CLUSTERED 
(
	[AUD_SEQ] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[aud_d](
	[aud_seq] [bigint] NOT NULL,
	[column_name] [varchar](30) NOT NULL,
	[column_val] [nvarchar](max) NULL,
 CONSTRAINT [PK_AUD_D] PRIMARY KEY CLUSTERED 
(
	[AUD_SEQ] ASC,
	[COLUMN_NAME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












CREATE VIEW [jsharmony].[v_audl_raw]
AS
SELECT  AUD_H.aud_seq,
        AUD_H.c_id,
        AUD_H.e_id,
        AUD_H.table_name,
        AUD_H.table_id,
        AUD_H.aud_op,
        AUD_H.aud_u,
			  {{schema}}.myCUSER_FMT(AUD_H.AUD_U) pe_name,
			  AUD_H.db_k,
			  AUD_H.aud_tstmp,
			  AUD_H.ref_name,
			  AUD_H.ref_id,
			  AUD_H.subj,
        AUD_D.column_name, 
			  AUD_D.column_val
FROM          {{schema}}.AUD_H 
LEFT OUTER JOIN {{schema}}.AUD_D ON AUD_H.AUD_SEQ = AUD_D.AUD_SEQ







GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/****** Script for SelectTopNRows command from SSMS  ******/
create view [jsharmony].[ucod_xpp_process_v] as
SELECT distinct
       NULL codseq
      ,PPD_PROCESS codeval
      ,PPD_PROCESS codetxt
      ,NULL codecode
      ,NULL codetdt
      ,NULL codetcm
  FROM {{schema}}.PPD
 where PPD_XPP = 1

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/****** Script for SelectTopNRows command from SSMS  ******/
create view [jsharmony].[ucod2_gpp_process_attrib_v] as
SELECT NULL codseq
      ,PPD_PROCESS codeval1
      ,PPD_ATTRIB codeval2
      ,PPD_DESC codetxt
      ,NULL codecode
      ,NULL codetdt
      ,NULL codetcm
      ,NULL cod_etstmp
      ,NULL cod_eu
      ,NULL cod_mtstmp
      ,NULL cod_mu
      ,NULL cod_snotes
      ,NULL cod_notes
  FROM {{schema}}.PPD
 WHERE PPD_GPP = 1
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/****** Script for SelectTopNRows command from SSMS  ******/
create view [jsharmony].[ucod2_ppp_process_attrib_v] as
SELECT NULL codseq
      ,PPD_PROCESS codeval1
      ,PPD_ATTRIB codeval2
      ,PPD_DESC codetxt
      ,NULL codecode
      ,NULL codetdt
      ,NULL codetcm
      ,NULL cod_etstmp
      ,NULL cod_eu
      ,NULL cod_mtstmp
      ,NULL cod_mu
      ,NULL cod_snotes
      ,NULL cod_notes
  FROM {{schema}}.PPD
 WHERE PPD_PPP = 1

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/****** Script for SelectTopNRows command from SSMS  ******/
create view [jsharmony].[ucod2_xpp_process_attrib_v] as
SELECT NULL codseq
      ,PPD_PROCESS codeval1
      ,PPD_ATTRIB codeval2
      ,PPD_DESC codetxt
      ,NULL codecode
      ,NULL codetdt
      ,NULL codetcm
      ,NULL cod_etstmp
      ,NULL cod_eu
      ,NULL cod_mtstmp
      ,NULL cod_mu
      ,NULL cod_snotes
      ,NULL cod_notes
  FROM {{schema}}.PPD
 WHERE PPD_XPP = 1

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[sper](
	[pe_id] [bigint] NOT NULL,
	[sper_snotes] [nvarchar](255) NULL,
	[sper_id] [bigint] IDENTITY(1,1) NOT NULL,
	[sr_name] [nvarchar](16) NOT NULL,
 CONSTRAINT [PK_SPER] PRIMARY KEY CLUSTERED 
(
	[pe_id] ASC,
	[sr_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_SPER] UNIQUE NONCLUSTERED 
(
	[SPER_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [jsharmony].[v_my_roles] as
select SPER.sr_name
  from {{schema}}.SPER
 where SPER.PE_ID = {{schema}}.myPE()


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[numbers](
	[number_val] [smallint] NOT NULL,
 CONSTRAINT [PK_NUMBERS] PRIMARY KEY CLUSTERED 
(
	[number_val] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







/****** Script for SelectTopNRows command from SSMS  ******/
CREATE view [jsharmony].[v_months] as
select number_val month_val,
       right('0'+convert(nvarchar(50),number_val),2) month_txt2,
       right('0'+convert(nvarchar(50),number_val),2) month_txt
  from {{schema}}.NUMBERS
 where N <=12;





GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





/****** Script for SelectTopNRows command from SSMS  ******/
CREATE view [jsharmony].[v_years] as
select datepart(year,sysdatetime())+number_val-1 year_val,
       datepart(year,sysdatetime())+number_val-1 year_txt
  from {{schema}}.NUMBERS
 where number_val <=10;



GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[ppp](
	[pe_id] [bigint] NOT NULL,
	[ppp_process] [nvarchar](32) NOT NULL,
	[ppp_attrib] [nvarchar](16) NOT NULL,
	[ppp_val] [varchar](256) NULL,
	[ppp_etstmp] [datetime2](7) NOT NULL,
	[ppp_eu] [nvarchar](20) NOT NULL,
	[ppp_mtstmp] [datetime2](7) NOT NULL,
	[ppp_mu] [nvarchar](20) NOT NULL,
	[ppp_id] [bigint] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_PPP] PRIMARY KEY CLUSTERED 
(
	[pe_id] ASC,
	[ppp_process] ASC,
	[ppp_attrib] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[gpp](
	[gpp_process] [nvarchar](32) NOT NULL,
	[gpp_attrib] [nvarchar](16) NOT NULL,
	[gpp_val] [varchar](256) NULL,
	[gpp_etstmp] [datetime2](7) NOT NULL,
	[gpp_eu] [nvarchar](20) NOT NULL,
	[gpp_mtstmp] [datetime2](7) NOT NULL,
	[gpp_mu] [nvarchar](20) NOT NULL,
	[gpp_id] [bigint] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_GPP] PRIMARY KEY CLUSTERED 
(
	[gpp_process] ASC,
	[gpp_attrib] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[xpp](
	[xpp_process] [nvarchar](32) NOT NULL,
	[xpp_attrib] [nvarchar](16) NOT NULL,
	[xpp_val] [varchar](256) NOT NULL,
	[xpp_etstmp] [datetime2](7) NOT NULL,
	[xpp_eu] [nvarchar](20) NOT NULL,
	[xpp_mtstmp] [datetime2](7) NOT NULL,
	[xpp_mu] [nvarchar](20) NOT NULL,
	[xpp_id] [bigint] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_XPP] PRIMARY KEY CLUSTERED 
(
	[xpp_process] ASC,
	[xpp_attrib] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [jsharmony].[v_pp] AS
 SELECT PPD.PPD_PROCESS AS pp_process, 
        PPD.PPD_ATTRIB AS pp_attrib, 
		    CASE WHEN PPP_VAL IS NULL OR PPP_VAL = '' 
		         THEN CASE WHEN GPP_VAL IS NULL OR GPP_VAL = '' 
			                 THEN XPP_VAL 
					   ELSE GPP_VAL END 
			  ELSE PPP_VAL END AS pp_val, 
		    CASE WHEN PPP_VAL IS NULL OR PPP_VAL = '' 
		         THEN CASE WHEN GPP_VAL IS NULL OR GPP_VAL = '' 
			                 THEN 'XPP' 
					             ELSE 'GPP' END 
			  ELSE convert(varchar,PPP.PE_ID) END AS pp_source 
   FROM {{schema}}.PPD 
   LEFT OUTER JOIN {{schema}}.XPP ON PPD.PPD_PROCESS = XPP.XPP_PROCESS AND PPD.PPD_ATTRIB = XPP.XPP_ATTRIB 
   LEFT OUTER JOIN {{schema}}.GPP ON PPD.PPD_PROCESS = GPP.GPP_PROCESS AND PPD.PPD_ATTRIB = GPP.GPP_ATTRIB 
   LEFT OUTER JOIN {{schema}}.PPP ON PPD.PPD_PROCESS = PPP.PPP_PROCESS AND PPD.PPD_ATTRIB = PPP.PPP_ATTRIB AND PPP.PE_ID = {{schema}}.myPE();




GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[d](
	[d_id] [bigint] IDENTITY(1,1) NOT NULL,
	[d_scope] [nvarchar](8) NOT NULL,
	[d_scope_id] [bigint] NOT NULL,
	[c_id] [bigint] NULL,
	[e_id] [bigint] NULL,
	[d_sts] [nvarchar](8) NOT NULL,
	[d_ctgr] [nvarchar](8) NOT NULL,
	[d_desc] [nvarchar](255) NULL,
	[d_ext] [nvarchar](16) NULL,
	[d_size] [bigint] NULL,
	[d_filename]  AS (('D'+CONVERT([varchar](50),[d_id],(0)))+isnull([d_ext],'')) PERSISTED,
	[d_etstmp] [datetime2](7) NOT NULL,
	[d_eu] [nvarchar](20) NOT NULL,
	[d_mtstmp] [datetime2](7) NOT NULL,
	[d_mu] [nvarchar](20) NOT NULL,
	[d_utstmp] [datetime2](7) NOT NULL,
	[d_uu] [nvarchar](20) NOT NULL,
	[d_synctstmp] [datetime2](7) NULL,
	[d_snotes] [nvarchar](255) NULL,
	[d_id_main] [bigint] NULL,
 CONSTRAINT [PK_D] PRIMARY KEY CLUSTERED 
(
	[d_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Script for SelectTopNRows command from SSMS  ******/
create view [jsharmony].[v_d_x] as
SELECT d_id
      ,d_scope
      ,d_scope_id
      ,c_id
      ,e_id
      ,d_sts
      ,d_ctgr
      ,d_desc
      ,d_ext
      ,d_size
      ,d_filename
      ,d_etstmp
      ,d_eu
      ,d_mtstmp
      ,d_mu
      ,d_utstmp
      ,d_uu
      ,d_synctstmp
      ,d_snotes
      ,d_id_main
  FROM {{schema}}.D
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[dual](
	[dummy] [nvarchar](1) NOT NULL,
	[dual_ident] [bigint] NOT NULL,
	[dual_bigint] [bigint] NULL,
	[dual_nvarchar50] [nvarchar](50) NULL,
 CONSTRAINT [PK_DUAL] PRIMARY KEY CLUSTERED 
(
	[dual_ident] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE view [jsharmony].[v_house] as
select NAME.PP_VAL house_name,
       ADDR.PP_VAL house_addr,
	     CITY.PP_VAL house_city,
	     [STATE].PP_VAL house_state,
	     ZIP.PP_VAL house_zip,
       isnull(ADDR.PP_VAL,'')+', '+isnull(CITY.PP_VAL,'')+' '+isnull([STATE].PP_VAL,'')+' '+isnull(ZIP.PP_VAL,'') house_full_addr,
	     BPHONE.PP_VAL house_bphone,
	     FAX.PP_VAL house_fax,
	     EMAIL.PP_VAL house_email,
	     CONTACT.PP_VAL house_contact
  from {{schema}}.dual
 left outer join {{schema}}.V_PP NAME on NAME.PP_PROCESS='HOUSE' and NAME.PP_ATTRIB='NAME'
 left outer join {{schema}}.V_PP ADDR on ADDR.PP_PROCESS='HOUSE' and ADDR.PP_ATTRIB='ADDR'
 left outer join {{schema}}.V_PP CITY on CITY.PP_PROCESS='HOUSE' and CITY.PP_ATTRIB='CITY'
 left outer join {{schema}}.V_PP [STATE] on[STATE].PP_PROCESS='HOUSE' and [STATE].PP_ATTRIB='STATE'
 left outer join {{schema}}.V_PP ZIP on ZIP.PP_PROCESS='HOUSE' and ZIP.PP_ATTRIB='ZIP'
 left outer join {{schema}}.V_PP BPHONE on BPHONE.PP_PROCESS='HOUSE' and BPHONE.PP_ATTRIB='BPHONE'
 left outer join {{schema}}.V_PP FAX on FAX.PP_PROCESS='HOUSE' and FAX.PP_ATTRIB='FAX'
 left outer join {{schema}}.V_PP EMAIL on EMAIL.PP_PROCESS='HOUSE' and EMAIL.PP_ATTRIB='EMAIL'
 left outer join {{schema}}.V_PP CONTACT on CONTACT.PP_PROCESS='HOUSE' and CONTACT.PP_ATTRIB='CONTACT'




GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[crm](
	[sm_id] [bigint] NOT NULL,
	[crm_snotes] [nvarchar](255) NULL,
	[crm_id] [bigint] IDENTITY(1,1) NOT NULL,
	[cr_name] [nvarchar](16) NOT NULL,
 CONSTRAINT [PK_CRM] PRIMARY KEY CLUSTERED 
(
	[cr_name] ASC,
	[sm_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_CRM] UNIQUE NONCLUSTERED 
(
	[crm_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[cr](
	[cr_id] [bigint] IDENTITY(1,1) NOT NULL,
	[cr_seq] [smallint] NULL,
	[cr_sts] [nvarchar](8) NOT NULL,
	[cr_name] [nvarchar](16) NOT NULL,
	[cr_desc] [nvarchar](255) NOT NULL,
	[cr_code] [nvarchar](50) NULL,
	[cr_attrib] [nvarchar](50) NULL,
	[cr_snotes] [nvarchar](255) NULL,
 CONSTRAINT [PK_CR] PRIMARY KEY CLUSTERED 
(
	[cr_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_CR_CR_Desc] UNIQUE NONCLUSTERED 
(
	[cr_desc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_CR_CR_ID] UNIQUE NONCLUSTERED 
(
	[cr_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[sm](
	[sm_id_auto] [bigint] IDENTITY(1,1) NOT NULL,
	[sm_utype] [char](1) NOT NULL,
	[sm_id] [bigint] NOT NULL,
	[sm_sts] [nvarchar](8) NOT NULL,
	[sm_id_parent] [bigint] NULL,
	[sm_name] [nvarchar](30) NOT NULL,
	[sm_seq] [int] NULL,
	[sm_desc] [nvarchar](255) NOT NULL,
	[sm_descl] [nvarchar](max) NULL,
	[sm_descvl] [nvarchar](max) NULL,
	[sm_cmd] [varchar](255) NULL,
	[sm_image] [nvarchar](255) NULL,
	[sm_snotes] [nvarchar](255) NULL,
	[sm_subcmd] [varchar](255) NULL,
 CONSTRAINT [PK_SM] PRIMARY KEY CLUSTERED 
(
	[sm_id_auto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_SM_SM_DESC] UNIQUE NONCLUSTERED 
(
	[sm_id_parent] ASC,
	[sm_desc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_SM_SM_ID] UNIQUE NONCLUSTERED 
(
	[sm_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_SM_SM_NAME] UNIQUE NONCLUSTERED 
(
	[sm_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [jsharmony].[v_crmsel]
AS
SELECT {{schema}}.CRM.crm_id, 
       ISNULL({{schema}}.DUAL.DUAL_NVARCHAR50, '') AS new_cr_name, 
	     DUAL.DUAL_BIGINT AS new_sm_id,
	     CASE WHEN CRM.CRM_ID IS NULL 
	          THEN 0 
			 ELSE 1 END AS crmsel_sel, 
	     M.cr_id, 
	     M.cr_seq, 
	     M.cr_sts, 
	     M.cr_name, 
	     M.cr_desc, 
	     M.sm_id_auto, 
	     M.sm_utype, 
       M.sm_id, 
	     M.sm_sts, 
	     M.sm_id_parent, 
	     M.sm_name, 
	     M.sm_seq, 
	     M.sm_desc, 
	     M.sm_descl, 
	     M.sm_descvl, 
	     M.sm_cmd, 
	     M.sm_image, 
	     M.sm_snotes,
	     M.sm_subcmd
  FROM (SELECT {{schema}}.CR.CR_ID,
               {{schema}}.CR.CR_SEQ, 
               {{schema}}.CR.CR_STS, 
               {{schema}}.CR.CR_Name, 
               {{schema}}.CR.CR_Desc, 
               {{schema}}.SM.SM_ID_AUTO, 
			   {{schema}}.SM.SM_UTYPE, 
			   {{schema}}.SM.SM_ID, 
			   {{schema}}.SM.SM_STS, 
			   {{schema}}.SM.SM_ID_Parent, 
			   {{schema}}.SM.SM_Name, 
               {{schema}}.SM.SM_Seq, 
			   {{schema}}.SM.SM_DESC, 
			   {{schema}}.SM.SM_DESCL, 
			   {{schema}}.SM.SM_DESCVL, 
			   {{schema}}.SM.SM_Cmd, 
			   {{schema}}.SM.SM_Image, 
			   {{schema}}.SM.SM_SNotes, 
               {{schema}}.SM.SM_SubCmd
          FROM {{schema}}.CR 
		  LEFT OUTER JOIN {{schema}}.SM ON {{schema}}.SM.SM_UTYPE = 'C') AS M 
 INNER JOIN {{schema}}.DUAL ON 1 = 1 
  LEFT OUTER JOIN {{schema}}.CRM ON {{schema}}.CRM.CR_NAME = M.CR_Name AND {{schema}}.CRM.SM_ID = M.SM_ID;




GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[cper](
	[pe_id] [bigint] NOT NULL,
	[cper_snotes] [nvarchar](255) NULL,
	[cper_id] [bigint] IDENTITY(1,1) NOT NULL,
	[cr_name] [nvarchar](16) NOT NULL,
 CONSTRAINT [PK_CPER] PRIMARY KEY CLUSTERED 
(
	[pe_id] ASC,
	[cr_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_CPER] UNIQUE NONCLUSTERED 
(
	[cper_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [jsharmony].[v_cper_nostar] as
select *
  from {{schema}}.cper
 where CR_NAME <> 'C*';

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[sr](
	[sr_id] [bigint] IDENTITY(1,1) NOT NULL,
	[sr_seq] [smallint] NOT NULL,
	[sr_sts] [nvarchar](8) NOT NULL,
	[sr_name] [nvarchar](16) NOT NULL,
	[sr_desc] [nvarchar](255) NOT NULL,
	[sr_code] [nvarchar](50) NULL,
	[sr_attrib] [nvarchar](50) NULL,
	[sr_snotes] [nvarchar](255) NULL,
 CONSTRAINT [PK_SR] PRIMARY KEY CLUSTERED 
(
	[sr_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_SR_SR_Desc] UNIQUE NONCLUSTERED 
(
	[sr_desc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_SR_SR_ID] UNIQUE NONCLUSTERED 
(
	[sr_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[srm](
	[sm_id] [bigint] NOT NULL,
	[srm_snotes] [nvarchar](255) NULL,
	[srm_id] [bigint] IDENTITY(1,1) NOT NULL,
	[sr_name] [nvarchar](16) NOT NULL,
 CONSTRAINT [PK_SRM] PRIMARY KEY CLUSTERED 
(
	[sr_name] ASC,
	[sm_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_SRM] UNIQUE NONCLUSTERED 
(
	[srm_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [jsharmony].[v_srmsel]
AS
SELECT {{schema}}.SRM.srm_id, 
       ISNULL({{schema}}.DUAL.DUAL_NVARCHAR50, '') AS new_sr_name, 
	   DUAL.DUAL_BIGINT AS new_sm_id,
	   CASE WHEN SRM.SRM_ID IS NULL 
	        THEN 0 
			ELSE 1 END AS srmsel_sel, 
	     M.sr_id, 
       M.sr_seq, 
       M.sr_sts, 
       M.sr_name, 
       M.sr_desc, 
	   M.sm_id_auto, 
	   M.sm_utype, 
       M.sm_id, 
	   M.sm_sts, 
	   M.sm_id_parent, 
	   M.sm_name, 
	   M.sm_seq, 
	   M.sm_desc, 
	   M.sm_descl, 
	   M.sm_descvl, 
	   M.sm_cmd, 
	   M.sm_image, 
	   M.sm_snotes,
	   M.sm_subcmd
  FROM (SELECT {{schema}}.SR.SR_ID, 
               {{schema}}.SR.SR_SEQ, 
               {{schema}}.SR.SR_STS, 
               {{schema}}.SR.SR_Name, 
               {{schema}}.SR.SR_Desc, 
               {{schema}}.SM.SM_ID_AUTO, 
			   {{schema}}.SM.SM_UTYPE, 
			   {{schema}}.SM.SM_ID, 
			   {{schema}}.SM.SM_STS, 
			   {{schema}}.SM.SM_ID_Parent, 
			   {{schema}}.SM.SM_Name, 
               {{schema}}.SM.SM_Seq, 
			   {{schema}}.SM.SM_DESC, 
			   {{schema}}.SM.SM_DESCL, 
			   {{schema}}.SM.SM_DESCVL, 
			   {{schema}}.SM.SM_Cmd, 
			   {{schema}}.SM.SM_Image, 
			   {{schema}}.SM.SM_SNotes, 
               {{schema}}.SM.SM_SubCmd
          FROM {{schema}}.SR 
		  LEFT OUTER JOIN {{schema}}.SM ON {{schema}}.SM.SM_UTYPE = 'S') AS M 
 INNER JOIN {{schema}}.DUAL ON 1 = 1 
  LEFT OUTER JOIN {{schema}}.SRM ON {{schema}}.SRM.SR_NAME = M.SR_Name AND {{schema}}.SRM.SM_ID = M.SM_ID;


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



































CREATE VIEW [jsharmony].[v_gppl] AS
SELECT {{schema}}.GPP.*,
       {{schema}}.get_PPD_DESC(GPP_PROCESS, GPP_ATTRIB) ppd_desc,
	   {{schema}}.audit_info(GPP_ETstmp, GPP_EU, GPP_MTstmp, GPP_MU) gpp_info
  FROM {{schema}}.GPP;


















GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



































CREATE VIEW [jsharmony].[v_pppl] AS
SELECT PPP.*,
       {{schema}}.get_PPD_DESC(PPP_PROCESS, PPP_ATTRIB) ppd_desc,
	   {{schema}}.audit_info(PPP_ETstmp, PPP_EU, PPP_MTstmp, PPP_MU) ppp_info
  FROM {{schema}}.PPP

















GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



































CREATE VIEW [jsharmony].[v_xppl] AS
SELECT XPP.*,
       {{schema}}.get_PPD_DESC(XPP_PROCESS, XPP_ATTRIB) ppd_desc,
	   {{schema}}.audit_info(XPP_ETstmp, XPP_EU, XPP_MTstmp, XPP_MU) xpp_info







  FROM {{schema}}.XPP;


















GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



































CREATE VIEW [jsharmony].[v_ppdl] AS
SELECT PPD.*,
	   {{schema}}.audit_info(PPD_ETstmp, PPD_EU, PPD_MTstmp, PPD_MU) ppd_info
  FROM {{schema}}.PPD;


















GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/****** Script for SelectTopNRows command from SSMS  ******/
create view [jsharmony].[ucod_gpp_process_v] as
SELECT distinct
       NULL codseq
      ,PPD_PROCESS codeval
      ,PPD_PROCESS codetxt
      ,NULL codecode
      ,NULL codetdt
      ,NULL codetcm
  FROM {{schema}}.PPD
 where PPD_GPP = 1
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create view [jsharmony].[v_mype] as
select {{schema}}.myPE() mype
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ARITHABORT ON
GO
CREATE TABLE [jsharmony].[cpe](
	[pe_id] [bigint] IDENTITY(1,1) NOT NULL,
	[c_id] [bigint] NOT NULL,
	[pe_sts] [nvarchar](8) NOT NULL,
	[pe_stsdt] [date] NOT NULL,
	[pe_fname] [nvarchar](35) NOT NULL,
	[pe_mname] [nvarchar](35) NULL,
	[pe_lname] [nvarchar](35) NOT NULL,
	[pe_jtitle] [nvarchar](35) NULL,
	[pe_bphone] [nvarchar](30) NULL,
	[pe_cphone] [nvarchar](30) NULL,
	[pe_email] [nvarchar](255) NOT NULL,
	[pe_etstmp] [datetime2](7) NOT NULL,
	[pe_eu] [nvarchar](20) NOT NULL,
	[pe_mtstmp] [datetime2](7) NOT NULL,
	[pe_mu] [nvarchar](20) NOT NULL,
	[pe_pw1] [nvarchar](255) NULL,
	[pe_pw2] [nvarchar](255) NULL,
	[pe_hash] [varbinary](200) NOT NULL,
	[pe_ll_ip] [nvarchar](255) NULL,
	[pe_ll_tstmp] [datetime2](7) NULL,
	[pe_snotes] [nvarchar](255) NULL,
	[pe_name]  AS (([pe_lname]+', ')+[pe_fname]) PERSISTED NOT NULL,
	[pe_unq_pe_email]  AS (case when [pe_sts]='ACTIVE' then case when isnull([pe_email],'')='' then 'E'+CONVERT([varchar](50),[pe_id],(0)) else 'S'+[pe_email] end else 'E'+CONVERT([varchar](50),[pe_id],(0)) end) PERSISTED,
 CONSTRAINT [PK_CPE] PRIMARY KEY CLUSTERED 
(
	[pe_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_CPE_PE_Email] UNIQUE NONCLUSTERED 
(
	[pe_unq_pe_email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[gcod_h](
	[codename] [nvarchar](16) NOT NULL,
	[codemean] [nvarchar](128) NULL,
	[codecodemean] [nvarchar](128) NULL,
	[codeattribmean] [nvarchar](128) NULL,
	[cod_h_etstmp] [datetime2](7) NULL,
	[cod_h_eu] [nvarchar](20) NULL,
	[cod_h_mtstmp] [datetime2](7) NULL,
	[cod_h_mu] [nvarchar](20) NULL,
	[cod_snotes] [nvarchar](255) NULL,
	[codeschema] [nvarchar](16) NULL,
 CONSTRAINT [PK_GCOD_H] PRIMARY KEY CLUSTERED 
(
	[codename] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[gcod2_d_scope_d_ctgr](
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
 CONSTRAINT [PK_GCOD2_D_SCOPE_D_CTGR] PRIMARY KEY CLUSTERED 
(
	[gcod2_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_GCOD2_D_SCOPE_D_CTGR_codeval1_codeval2] UNIQUE NONCLUSTERED 
(
	[codeval1] ASC,
	[codeval2] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_GCOD2_D_SCOPE_D_CTGR_codeval1_CODETXT] UNIQUE NONCLUSTERED 
(
	[codeval1] ASC,
	[codetxt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[gcod2_h](
	[codename] [nvarchar](16) NOT NULL,
	[codemean] [nvarchar](128) NULL,
	[codecodemean] [nvarchar](128) NULL,
	[codeattribmean] [nvarchar](128) NULL,
	[cod_h_etstmp] [datetime2](7) NULL,
	[cod_h_eu] [nvarchar](20) NULL,
	[cod_h_mtstmp] [datetime2](7) NULL,
	[cod_h_mu] [nvarchar](20) NULL,
	[cod_snotes] [nvarchar](255) NULL,
	[codeschema] [nvarchar](16) NULL,
 CONSTRAINT [PK_GCOD2_H] PRIMARY KEY CLUSTERED 
(
	[codename] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ARITHABORT ON
GO
CREATE TABLE [jsharmony].[h](
	[h_id] [bigint] IDENTITY(1,1) NOT NULL,
	[hp_code] [varchar](50) NULL,
	[h_title] [nvarchar](70) NOT NULL,
	[h_text] [nvarchar](max) NOT NULL,
	[h_etstmp] [datetime2](7) NOT NULL,
	[h_eu] [nvarchar](20) NOT NULL,
	[h_mtstmp] [datetime2](7) NOT NULL,
	[h_mu] [nvarchar](20) NOT NULL,
	[h_unique]  AS (case when [hp_code] IS NOT NULL then 'X'+[hp_code] else 'Y'+CONVERT([varchar](50),[h_id],(0)) end) PERSISTED,
	[h_seq] [int] NULL,
	[h_index_a] [bit] NOT NULL,
	[h_index_p] [bit] NOT NULL,
 CONSTRAINT [PK_H] PRIMARY KEY CLUSTERED 
(
	[h_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_H_H_Title] UNIQUE NONCLUSTERED 
(
	[h_title] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_H_H_UNIQUE] UNIQUE NONCLUSTERED 
(
	[h_unique] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[hp](
	[hp_code] [varchar](50) NOT NULL,
	[hp_desc] [nvarchar](50) NOT NULL,
	[hp_id] [bigint] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_HP] PRIMARY KEY CLUSTERED 
(
	[hp_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_HP_HP_Desc] UNIQUE NONCLUSTERED 
(
	[hp_desc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_HP_HP_ID] UNIQUE NONCLUSTERED 
(
	[hp_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[n](
	[n_id] [bigint] IDENTITY(1,1) NOT NULL,
	[n_scope] [nvarchar](8) NOT NULL,
	[n_scope_id] [bigint] NOT NULL,
	[n_sts] [nvarchar](8) NOT NULL,
	[c_id] [bigint] NULL,
	[e_id] [bigint] NULL,
	[n_type] [nvarchar](8) NOT NULL,
	[n_note] [nvarchar](max) NOT NULL,
	[n_etstmp] [datetime2](7) NOT NULL,
	[n_eu] [nvarchar](20) NOT NULL,
	[n_mtstmp] [datetime2](7) NOT NULL,
	[n_mu] [nvarchar](20) NOT NULL,
	[n_synctstmp] [datetime2](7) NULL,
	[n_snotes] [nvarchar](255) NULL,
	[n_id_main] [bigint] NULL,
 CONSTRAINT [PK_N] PRIMARY KEY CLUSTERED 
(
	[n_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ARITHABORT ON
GO
CREATE TABLE [jsharmony].[pe](
	[pe_id] [bigint] IDENTITY(1,1) NOT NULL,
	[pe_sts] [nvarchar](8) NOT NULL,
	[pe_stsdt] [date] NOT NULL,
	[pe_fname] [nvarchar](35) NOT NULL,
	[pe_mname] [nvarchar](35) NULL,
	[pe_lname] [nvarchar](35) NOT NULL,
	[pe_jtitle] [nvarchar](35) NULL,
	[pe_bphone] [nvarchar](30) NULL,
	[pe_cphone] [nvarchar](30) NULL,
	[pe_country] [nvarchar](8) NOT NULL,
	[pe_addr] [nvarchar](200) NULL,
	[pe_city] [nvarchar](50) NULL,
	[pe_state] [nvarchar](8) NULL,
	[pe_zip] [nvarchar](20) NULL,
	[pe_email] [nvarchar](255) NOT NULL,
	[pe_startdt] [date] NOT NULL,
	[pe_enddt] [date] NULL,
	[pe_unotes] [nvarchar](4000) NULL,
	[pe_etstmp] [datetime2](7) NOT NULL,
	[pe_eu] [nvarchar](20) NOT NULL,
	[pe_mtstmp] [datetime2](7) NOT NULL,
	[pe_mu] [nvarchar](20) NOT NULL,
	[pe_pw1] [nvarchar](255) NULL,
	[pe_pw2] [nvarchar](255) NULL,
	[pe_hash] [varbinary](200) NOT NULL,
	[pe_ll_ip] [nvarchar](255) NULL,
	[pe_ll_tstmp] [datetime2](7) NULL,
	[pe_snotes] [nvarchar](255) NULL,
	[pe_name]  AS (([pe_lname]+', ')+[pe_fname]) PERSISTED NOT NULL,
	[pe_initials]  AS ((isnull(substring([pe_fname],(1),(1)),'')+isnull(substring([pe_mname],(1),(1)),''))+isnull(substring([pe_lname],(1),(1)),'')) PERSISTED NOT NULL,
	[pe_unq_pe_email]  AS (case when [pe_sts]='ACTIVE' then case when isnull([pe_email],'')='' then 'E'+CONVERT([varchar](50),[pe_id],(0)) else 'S'+[pe_email] end else 'E'+CONVERT([varchar](50),[pe_id],(0)) end) PERSISTED,
 CONSTRAINT [PK_PE] PRIMARY KEY CLUSTERED 
(
	[pe_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_PE_PE_Email] UNIQUE NONCLUSTERED 
(
	[pe_unq_pe_email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[rq](
	[rq_id] [bigint] IDENTITY(1,1) NOT NULL,
	[rq_etstmp] [datetime2](7) NOT NULL,
	[rq_eu] [nvarchar](20) NOT NULL,
	[rq_name] [nvarchar](255) NOT NULL,
	[rq_message] [nvarchar](max) NOT NULL,
	[rq_rslt] [nvarchar](8) NULL,
	[rq_rslt_tstmp] [datetime2](7) NULL,
	[rq_rslt_u] [nvarchar](20) NULL,
	[rq_snotes] [nvarchar](max) NULL,
 CONSTRAINT [PK_RQ] PRIMARY KEY CLUSTERED 
(
	[rq_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[rqst](
	[rqst_id] [bigint] IDENTITY(1,1) NOT NULL,
	[rqst_etstmp] [datetime2](7) NOT NULL,
	[rqst_eu] [nvarchar](20) NOT NULL,
	[rqst_source] [nvarchar](8) NOT NULL,
	[rqst_atype] [nvarchar](8) NOT NULL,
	[rqst_aname] [nvarchar](50) NOT NULL,
	[rqst_parms] [nvarchar](max) NULL,
	[rqst_ident] [nvarchar](255) NULL,
	[rqst_rslt] [nvarchar](8) NULL,
	[rqst_rslt_tstmp] [datetime2](7) NULL,
	[rqst_rslt_u] [nvarchar](20) NULL,
	[rqst_snotes] [nvarchar](max) NULL,
 CONSTRAINT [PK_RQST] PRIMARY KEY CLUSTERED 
(
	[rqst_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[rqst_d](
	[rqst_d_id] [bigint] IDENTITY(1,1) NOT NULL,
	[rqst_id] [bigint] NOT NULL,
	[d_scope] [nvarchar](8) NULL,
	[d_scope_id] [bigint] NULL,
	[d_ctgr] [nvarchar](8) NULL,
	[d_desc] [nvarchar](255) NULL,
 CONSTRAINT [PK_RQST_D] PRIMARY KEY CLUSTERED 
(
	[rqst_d_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[rqst_email](
	[rqst_email_id] [bigint] IDENTITY(1,1) NOT NULL,
	[rqst_id] [bigint] NOT NULL,
	[email_txt_attrib] [nvarchar](32) NULL,
	[email_to] [nvarchar](255) NOT NULL,
	[email_cc] [nvarchar](255) NULL,
	[email_bcc] [nvarchar](255) NULL,
	[email_attach] [smallint] NULL,
	[email_subject] [nvarchar](500) NULL,
	[email_text] [ntext] NULL,
	[email_html] [ntext] NULL,
	[email_d_id] [bigint] NULL,
 CONSTRAINT [PK_RQST_EMAIL] PRIMARY KEY CLUSTERED 
(
	[rqst_email_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[rqst_n](
	[rqst_n_id] [bigint] IDENTITY(1,1) NOT NULL,
	[rqst_id] [bigint] NOT NULL,
	[n_scope] [nvarchar](8) NULL,
	[n_scope_id] [bigint] NULL,
	[n_type] [nvarchar](8) NULL,
	[n_note] [nvarchar](max) NULL,
 CONSTRAINT [PK_RQST_N] PRIMARY KEY CLUSTERED 
(
	[rqst_n_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[rqst_rq](
	[rqst_rq_id] [bigint] IDENTITY(1,1) NOT NULL,
	[rqst_id] [bigint] NOT NULL,
	[rq_name] [nvarchar](255) NOT NULL,
	[rq_message] [nvarchar](max) NULL,
 CONSTRAINT [PK_RQST_RQ] PRIMARY KEY CLUSTERED 
(
	[rqst_rq_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[rqst_sms](
	[rqst_sms_id] [bigint] IDENTITY(1,1) NOT NULL,
	[rqst_id] [bigint] NOT NULL,
	[sms_txt_attrib] [nvarchar](32) NULL,
	[sms_to] [nvarchar](255) NOT NULL,
	[sms_body] [ntext] NULL,
 CONSTRAINT [PK_RQST_SMS] PRIMARY KEY CLUSTERED 
(
	[rqst_sms_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[script](
	[script_name] [nvarchar](32) NOT NULL,
	[script_txt] [nvarchar](max) NULL,
 CONSTRAINT [PK_SCRIPT] PRIMARY KEY CLUSTERED 
(
	[script_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[sf](
	[sf_id] [bigint] IDENTITY(1,1) NOT NULL,
	[sf_seq] [smallint] NOT NULL,
	[sf_sts] [nvarchar](8) NOT NULL,
	[sf_name] [nvarchar](16) NOT NULL,
	[sf_desc] [nvarchar](255) NOT NULL,
	[sf_code] [nvarchar](50) NULL,
	[sf_attrib] [nvarchar](50) NULL,
	[sf_snotes] [nvarchar](255) NULL,
 CONSTRAINT [PK_SF] PRIMARY KEY CLUSTERED 
(
	[sf_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_SF_SF_CODE_SF_NAME] UNIQUE NONCLUSTERED 
(
	[sf_code] ASC,
	[sf_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_SF_SF_Desc] UNIQUE NONCLUSTERED 
(
	[sf_desc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_SF_SF_ID] UNIQUE NONCLUSTERED 
(
	[sf_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[spef](
	[pe_id] [bigint] NOT NULL,
	[spef_snotes] [nvarchar](255) NULL,
	[spef_id] [bigint] IDENTITY(1,1) NOT NULL,
	[sf_name] [nvarchar](16) NOT NULL,
 CONSTRAINT [PK_SPEF] PRIMARY KEY CLUSTERED 
(
	[pe_id] ASC,
	[sf_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_SPEF] UNIQUE NONCLUSTERED 
(
	[spef_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[txt](
	[txt_process] [nvarchar](32) NOT NULL,
	[txt_attrib] [nvarchar](32) NOT NULL,
	[txt_type] [nvarchar](8) NOT NULL,
	[txt_tval] [nvarchar](max) NULL,
	[txt_val] [nvarchar](max) NULL,
	[txt_bcc] [nvarchar](255) NULL,
	[txt_desc] [nvarchar](255) NULL,
	[txt_id] [bigint] IDENTITY(1,1) NOT NULL,
	[txt_etstmp] [datetime2](7) NOT NULL,
	[txt_eu] [varchar](64) NOT NULL,
	[txt_mtstmp] [datetime2](7) NOT NULL,
	[txt_mu] [varchar](64) NOT NULL,
 CONSTRAINT [PK_TXT] PRIMARY KEY CLUSTERED 
(
	[txt_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_TXT] UNIQUE NONCLUSTERED 
(
	[txt_process] ASC,
	[txt_attrib] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[ucod_ac](
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
 CONSTRAINT [PK_UCOD_AC] PRIMARY KEY CLUSTERED 
(
	[ucod_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_UCOD_AC_CODETXT] UNIQUE NONCLUSTERED 
(
  [codetxt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_UCOD_AC_codeval] UNIQUE NONCLUSTERED 
(
  [codeval] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[ucod_ac1](
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
 CONSTRAINT [PK_UCOD_AC1] PRIMARY KEY CLUSTERED 
(
  [ucod_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_UCOD_AC1_CODETXT] UNIQUE NONCLUSTERED 
(
  [codetxt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_UCOD_AC1_codeval] UNIQUE NONCLUSTERED 
(
  [codeval] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[ucod_ahc](
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
 CONSTRAINT [PK_UCOD_AHC] PRIMARY KEY CLUSTERED 
(
  [ucod_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_UCOD_AHC_CODETXT] UNIQUE NONCLUSTERED 
(
  [codetxt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_UCOD_AHC_codeval] UNIQUE NONCLUSTERED 
(
  [codeval] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[ucod_country](
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
 CONSTRAINT [PK_UCOD_COUNTRY] PRIMARY KEY CLUSTERED 
(
  [ucod_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_UCOD_COUNTRY_CODETXT] UNIQUE NONCLUSTERED 
(
  [codetxt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_UCOD_COUNTRY_codeval] UNIQUE NONCLUSTERED 
(
  [codeval] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[ucod_d_scope](
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
 CONSTRAINT [PK_UCOD_D_SCOPE] PRIMARY KEY CLUSTERED 
(
  [ucod_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_UCOD_D_SCOPE_CODETXT] UNIQUE NONCLUSTERED 
(
  [codetxt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_UCOD_D_SCOPE_codeval] UNIQUE NONCLUSTERED 
(
  [codeval] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[ucod_h](
	[codename] [nvarchar](16) NOT NULL,
	[codemean] [nvarchar](128) NULL,
	[codecodemean] [nvarchar](128) NULL,
	[codeattribmean] [nvarchar](128) NULL,
	[cod_h_etstmp] [datetime2](7) NULL,
	[cod_h_eu] [nvarchar](20) NULL,
	[cod_h_mtstmp] [datetime2](7) NULL,
	[cod_h_mu] [nvarchar](20) NULL,
	[cod_snotes] [nvarchar](255) NULL,
	[codeschema] [nvarchar](16) NULL,
	[ucod_h_id] [bigint] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_UCOD_H] PRIMARY KEY CLUSTERED 
(
	[ucod_h_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_UCOD_H] UNIQUE NONCLUSTERED 
(
	[codeschema] ASC,
	[codename] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[ucod_n_scope](
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
 CONSTRAINT [PK_UCOD_N_SCOPE] PRIMARY KEY CLUSTERED 
(
  [ucod_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_UCOD_N_SCOPE_CODETXT] UNIQUE NONCLUSTERED 
(
  [codetxt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_UCOD_N_SCOPE_codeval] UNIQUE NONCLUSTERED 
(
  [codeval] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[ucod_n_type](
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
 CONSTRAINT [PK_UCOD_N_TYPE] PRIMARY KEY CLUSTERED 
(
  [ucod_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_UCOD_N_TYPE_CODETXT] UNIQUE NONCLUSTERED 
(
  [codetxt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_UCOD_N_TYPE_codeval] UNIQUE NONCLUSTERED 
(
  [codeval] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[ucod_ppd_type](
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
 CONSTRAINT [PK_UCOD_PPD_TYPE] PRIMARY KEY CLUSTERED 
(
  [ucod_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_UCOD_PPD_TYPE_CODETXT] UNIQUE NONCLUSTERED 
(
  [codetxt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_UCOD_PPD_TYPE_codeval] UNIQUE NONCLUSTERED 
(
  [codeval] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[ucod_rqst_atype](
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
 CONSTRAINT [PK_UCOD_RQST_ATYPE] PRIMARY KEY CLUSTERED 
(
  [ucod_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_UCOD_RQST_ATYPE_CODETXT] UNIQUE NONCLUSTERED 
(
  [codetxt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_UCOD_RQST_ATYPE_codeval] UNIQUE NONCLUSTERED 
(
  [codeval] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[ucod_rqst_source](
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
 CONSTRAINT [PK_UCOD_RQST_SOURCE] PRIMARY KEY CLUSTERED 
(
  [ucod_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_UCOD_RQST_SOURCE_CODETXT] UNIQUE NONCLUSTERED 
(
  [codetxt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_UCOD_RQST_SOURCE_codeval] UNIQUE NONCLUSTERED 
(
  [codeval] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[ucod_txt_type](
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
 CONSTRAINT [PK_UCOD_TXT_TYPE] PRIMARY KEY CLUSTERED 
(
  [ucod_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_UCOD_TXT_TYPE_CODETXT] UNIQUE NONCLUSTERED 
(
  [codetxt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_UCOD_TXT_TYPE_codeval] UNIQUE NONCLUSTERED 
(
  [codeval] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[ucod_v_sts](
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
 CONSTRAINT [PK_UCOD_V_STS] PRIMARY KEY CLUSTERED 
(
	[ucod_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_UCOD_V_STS_CODETXT] UNIQUE NONCLUSTERED 
(
	[codetxt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_UCOD_V_STS_codeval] UNIQUE NONCLUSTERED 
(
	[codeval] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[ucod2_country_state](
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
 CONSTRAINT [PK_UCOD2_COUNTRY_STATE] PRIMARY KEY CLUSTERED 
(
	[ucod2_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_UCOD2_COUNTRY_STATE_codeval1_codeval2] UNIQUE NONCLUSTERED 
(
	[codeval1] ASC,
	[codeval2] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_UCOD2_COUNTRY_STATE_codeval1_CODETXT] UNIQUE NONCLUSTERED 
(
	[codeval1] ASC,
	[codetxt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[ucod2_h](
	[codename] [nvarchar](16) NOT NULL,
	[codemean] [nvarchar](128) NULL,
	[codecodemean] [nvarchar](128) NULL,
	[codeattribmean] [nvarchar](128) NULL,
	[cod_h_etstmp] [datetime2](7) NULL,
	[cod_h_eu] [nvarchar](20) NULL,
	[cod_h_mtstmp] [datetime2](7) NULL,
	[cod_h_mu] [nvarchar](20) NULL,
	[cod_snotes] [nvarchar](255) NULL,
	[codeschema] [nvarchar](16) NULL,
	[ucod2_h_id] [bigint] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_UCOD2_H] PRIMARY KEY CLUSTERED 
(
	[ucod2_h_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNQ_UCOD2_H] UNIQUE NONCLUSTERED 
(
	[codeschema] ASC,
	[codename] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [jsharmony].[v](
	[v_id] [bigint] IDENTITY(1,1) NOT NULL,
	[v_comp] [nvarchar](50) NOT NULL,
	[v_no_major] [int] NOT NULL,
	[v_no_minor] [int] NOT NULL,
	[v_no_build] [int] NOT NULL,
	[v_no_rev] [int] NOT NULL,
	[v_sts] [nvarchar](8) NOT NULL,
	[v_note] [nvarchar](max) NULL,
	[v_etstmp] [datetime2](7) NOT NULL,
	[v_eu] [nvarchar](20) NOT NULL,
	[v_mtstmp] [datetime2](7) NOT NULL,
	[v_mu] [nvarchar](20) NOT NULL,
	[v_snotes] [nvarchar](255) NULL,
 CONSTRAINT [UNQ_V] PRIMARY KEY CLUSTERED 
(
	[v_no_major] ASC,
	[v_no_minor] ASC,
	[v_no_build] ASC,
	[v_no_rev] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CPE_C_ID] ON [jsharmony].[cpe]
(
	[c_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_D_C_ID] ON [jsharmony].[d]
(
	[c_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_D_SCOPE] ON [jsharmony].[d]
(
	[d_scope] ASC,
	[d_scope_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_H] ON [jsharmony].[h]
(
	[hp_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_RQ_RQ_NAME] ON [jsharmony].[rq]
(
	[rq_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [jsharmony].[AUD_H] ADD  CONSTRAINT [DF_AUD_H_DB_K]  DEFAULT ('0') FOR [DB_K]
GO
ALTER TABLE [jsharmony].[cpe] ADD  CONSTRAINT [DF_CPE_PE_STS]  DEFAULT (N'ACTIVE') FOR [pe_sts]
GO
ALTER TABLE [jsharmony].[cpe] ADD  CONSTRAINT [DF_CPE_PE_STS_Dt]  DEFAULT ([jsharmony].[myTODAY]()) FOR [pe_stsdt]
GO
ALTER TABLE [jsharmony].[cpe] ADD  CONSTRAINT [DF_CPE_PE_ETstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [pe_etstmp]
GO
ALTER TABLE [jsharmony].[cpe] ADD  CONSTRAINT [DF_CPE_PE_EU]  DEFAULT ([jsharmony].[myCUSER]()) FOR [pe_eu]
GO
ALTER TABLE [jsharmony].[cpe] ADD  CONSTRAINT [DF_CPE_PE_MTstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [pe_mtstmp]
GO
ALTER TABLE [jsharmony].[cpe] ADD  CONSTRAINT [DF_CPE_PE_MU]  DEFAULT ([jsharmony].[myCUSER]()) FOR [pe_mu]
GO
ALTER TABLE [jsharmony].[cpe] ADD  CONSTRAINT [DF_CPE_PE_Hash]  DEFAULT ((0)) FOR [pe_hash]
GO
ALTER TABLE [jsharmony].[cr] ADD  CONSTRAINT [DF_CR_CR_STS]  DEFAULT ('ACTIVE') FOR [cr_sts]
GO
ALTER TABLE [jsharmony].[d] ADD  CONSTRAINT [DF_D_D_SCOPE]  DEFAULT (N'S') FOR [d_scope]
GO
ALTER TABLE [jsharmony].[d] ADD  CONSTRAINT [DF_D_D_SCOPE_ID]  DEFAULT ((0)) FOR [d_scope_id]
GO
ALTER TABLE [jsharmony].[d] ADD  CONSTRAINT [DF_D_C_ID]  DEFAULT (NULL) FOR [c_id]
GO
ALTER TABLE [jsharmony].[d] ADD  CONSTRAINT [DF_D_E_ID]  DEFAULT (NULL) FOR [e_id]
GO
ALTER TABLE [jsharmony].[d] ADD  CONSTRAINT [DF_D_D_STS]  DEFAULT (N'A') FOR [d_sts]
GO
ALTER TABLE [jsharmony].[d] ADD  CONSTRAINT [DF_D_D_ETstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [d_etstmp]
GO
ALTER TABLE [jsharmony].[d] ADD  CONSTRAINT [DF_D_D_EU]  DEFAULT ([jsharmony].[myCUSER]()) FOR [d_eu]
GO
ALTER TABLE [jsharmony].[d] ADD  CONSTRAINT [DF_D_D_MTstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [d_mtstmp]
GO
ALTER TABLE [jsharmony].[d] ADD  CONSTRAINT [DF_D_D_MU]  DEFAULT ([jsharmony].[myCUSER]()) FOR [d_mu]
GO
ALTER TABLE [jsharmony].[d] ADD  CONSTRAINT [DF_D_D_UTstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [d_utstmp]
GO
ALTER TABLE [jsharmony].[d] ADD  CONSTRAINT [DF_D_D_UU]  DEFAULT ([jsharmony].[myCUSER]()) FOR [d_uu]
GO
ALTER TABLE [jsharmony].[gcod_h] ADD  CONSTRAINT [DF_GCOD_H_GCOD_H_Edt]  DEFAULT ([jsharmony].[myNOW]()) FOR [cod_h_etstmp]
GO
ALTER TABLE [jsharmony].[gcod_h] ADD  CONSTRAINT [DF_GCOD_H_GCOD_H_EUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [cod_h_eu]
GO
ALTER TABLE [jsharmony].[gcod_h] ADD  CONSTRAINT [DF_GCOD_H_GCOD_H_MDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [cod_h_mtstmp]
GO
ALTER TABLE [jsharmony].[gcod_h] ADD  CONSTRAINT [DF_GCOD_H_GCOD_H_MUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [cod_h_mu]
GO
ALTER TABLE [jsharmony].[gcod2_d_scope_d_ctgr] ADD  CONSTRAINT [DF_GCOD2_D_SCOPE_D_CTGR_COD_EDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [cod_etstmp]
GO
ALTER TABLE [jsharmony].[gcod2_d_scope_d_ctgr] ADD  CONSTRAINT [DF_GCOD2_D_SCOPE_D_CTGR_cod_euser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [cod_eu]
GO
ALTER TABLE [jsharmony].[gcod2_d_scope_d_ctgr] ADD  CONSTRAINT [DF_GCOD2_D_SCOPE_D_CTGR_COD_MDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [cod_mtstmp]
GO
ALTER TABLE [jsharmony].[gcod2_d_scope_d_ctgr] ADD  CONSTRAINT [DF_GCOD2_D_SCOPE_D_CTGR_cod_muser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [cod_mu]
GO
ALTER TABLE [jsharmony].[gcod2_h] ADD  CONSTRAINT [DF_GCOD2_H_GCOD2_H_Edt]  DEFAULT ([jsharmony].[myNOW]()) FOR [cod_h_etstmp]
GO
ALTER TABLE [jsharmony].[gcod2_h] ADD  CONSTRAINT [DF_GCOD2_H_GCOD2_H_EUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [cod_h_eu]
GO
ALTER TABLE [jsharmony].[gcod2_h] ADD  CONSTRAINT [DF_GCOD2_H_GCOD2_H_MDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [cod_h_mtstmp]
GO
ALTER TABLE [jsharmony].[gcod2_h] ADD  CONSTRAINT [DF_GCOD2_H_GCOD2_H_MUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [cod_h_mu]
GO
ALTER TABLE [jsharmony].[gpp] ADD  CONSTRAINT [DF_GPP_GPP_ETstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [gpp_etstmp]
GO
ALTER TABLE [jsharmony].[gpp] ADD  CONSTRAINT [DF_GPP_GPP_EUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [gpp_eu]
GO
ALTER TABLE [jsharmony].[gpp] ADD  CONSTRAINT [DF_GPP_GPP_MTstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [gpp_mtstmp]
GO
ALTER TABLE [jsharmony].[gpp] ADD  CONSTRAINT [DF_GPP_GPP_MUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [gpp_mu]
GO
ALTER TABLE [jsharmony].[h] ADD  CONSTRAINT [DF_H_H_ETstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [h_etstmp]
GO
ALTER TABLE [jsharmony].[h] ADD  CONSTRAINT [DF_H_H_EU]  DEFAULT ([jsharmony].[myCUSER]()) FOR [h_eu]
GO
ALTER TABLE [jsharmony].[h] ADD  CONSTRAINT [DF_H_H_MTstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [h_mtstmp]
GO
ALTER TABLE [jsharmony].[h] ADD  CONSTRAINT [DF_H_H_MU]  DEFAULT ([jsharmony].[myCUSER]()) FOR [h_mu]
GO
ALTER TABLE [jsharmony].[h] ADD  CONSTRAINT [DF_H_H_INDEX_A]  DEFAULT ((1)) FOR [h_index_a]
GO
ALTER TABLE [jsharmony].[h] ADD  CONSTRAINT [DF_H_H_INDEX_P]  DEFAULT ((1)) FOR [h_index_p]
GO
ALTER TABLE [jsharmony].[n] ADD  CONSTRAINT [DF_N_N_SCOPE]  DEFAULT (N'S') FOR [n_scope]
GO
ALTER TABLE [jsharmony].[n] ADD  CONSTRAINT [DF_N_N_SCOPE_ID]  DEFAULT ((0)) FOR [n_scope_id]
GO
ALTER TABLE [jsharmony].[n] ADD  CONSTRAINT [DF_N_N_STS]  DEFAULT ('A') FOR [n_sts]
GO
ALTER TABLE [jsharmony].[n] ADD  CONSTRAINT [DF_N_C_ID]  DEFAULT (NULL) FOR [c_id]
GO
ALTER TABLE [jsharmony].[n] ADD  CONSTRAINT [DF_N_E_ID]  DEFAULT (NULL) FOR [e_id]
GO
ALTER TABLE [jsharmony].[n] ADD  CONSTRAINT [DF_N_N_ETstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [n_etstmp]
GO
ALTER TABLE [jsharmony].[n] ADD  CONSTRAINT [DF_N_N_EU]  DEFAULT ([jsharmony].[myCUSER]()) FOR [n_eu]
GO
ALTER TABLE [jsharmony].[n] ADD  CONSTRAINT [DF_N_N_MTstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [n_mtstmp]
GO
ALTER TABLE [jsharmony].[n] ADD  CONSTRAINT [DF_N_N_MU]  DEFAULT ([jsharmony].[myCUSER]()) FOR [n_mu]
GO
ALTER TABLE [jsharmony].[pe] ADD  CONSTRAINT [DF_PE_PE_STS]  DEFAULT (N'ACTIVE') FOR [pe_sts]
GO
ALTER TABLE [jsharmony].[pe] ADD  CONSTRAINT [DF__PE__PE_STS_Dt__17C286CF]  DEFAULT ([jsharmony].[myTODAY]()) FOR [pe_stsdt]
GO
ALTER TABLE [jsharmony].[pe] ADD  CONSTRAINT [DF_PE_PE_COUNTRY]  DEFAULT ('USA') FOR [pe_country]
GO
ALTER TABLE [jsharmony].[pe] ADD  CONSTRAINT [DF_PE_PE_STARTDT]  DEFAULT ([jsharmony].[myNOW]()) FOR [pe_startdt]
GO
ALTER TABLE [jsharmony].[pe] ADD  CONSTRAINT [DF_PE_PE_ETstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [pe_etstmp]
GO
ALTER TABLE [jsharmony].[pe] ADD  CONSTRAINT [DF__PE__PE_EU]  DEFAULT ([jsharmony].[myCUSER]()) FOR [pe_eu]
GO
ALTER TABLE [jsharmony].[pe] ADD  CONSTRAINT [DF__PE__PE_MTstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [pe_mtstmp]
GO
ALTER TABLE [jsharmony].[pe] ADD  CONSTRAINT [DF__PE__PE_MU]  DEFAULT ([jsharmony].[myCUSER]()) FOR [pe_mu]
GO
ALTER TABLE [jsharmony].[pe] ADD  CONSTRAINT [DF__PE__PE_Hash__597119F2]  DEFAULT ((0)) FOR [pe_hash]
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
ALTER TABLE [jsharmony].[PPP] ADD  CONSTRAINT [DF_PPP_PPP_ETstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [ppp_etstmp]
GO
ALTER TABLE [jsharmony].[PPP] ADD  CONSTRAINT [DF_PPP_PPP_EUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [ppp_eu]
GO
ALTER TABLE [jsharmony].[PPP] ADD  CONSTRAINT [DF_PPP_PPP_MTstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [ppp_mtstmp]
GO
ALTER TABLE [jsharmony].[PPP] ADD  CONSTRAINT [DF_PPP_PPP_MUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [ppp_mu]
GO
ALTER TABLE [jsharmony].[rq] ADD  CONSTRAINT [DF_RQ_RQ_ETstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [rq_etstmp]
GO
ALTER TABLE [jsharmony].[rq] ADD  CONSTRAINT [DF_RQ_RQ_EU]  DEFAULT ([jsharmony].[myCUSER]()) FOR [rq_eu]
GO
ALTER TABLE [jsharmony].[rqst] ADD  CONSTRAINT [DF_RQST_RQST_ETstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [rqst_etstmp]
GO
ALTER TABLE [jsharmony].[rqst] ADD  CONSTRAINT [DF_RQST_RQST_EU]  DEFAULT ([jsharmony].[myCUSER]()) FOR [rqst_eu]
GO
ALTER TABLE [jsharmony].[sf] ADD  CONSTRAINT [DF_SF_SF_STS]  DEFAULT ('ACTIVE') FOR [SF_STS]
GO
ALTER TABLE [jsharmony].[sm] ADD  CONSTRAINT [DF_SM_SM_UTYPE]  DEFAULT ('S') FOR [sm_utype]
GO
ALTER TABLE [jsharmony].[sm] ADD  CONSTRAINT [DF_SM_SM_STS]  DEFAULT ('ACTIVE') FOR [sm_sts]
GO
ALTER TABLE [jsharmony].[sr] ADD  CONSTRAINT [DF_SR_SR_STS]  DEFAULT ('ACTIVE') FOR [sr_sts]
GO
ALTER TABLE [jsharmony].[txt] ADD  CONSTRAINT [DF_TXT_TXT_TYPE]  DEFAULT ('TEXT') FOR [txt_type]
GO
ALTER TABLE [jsharmony].[txt] ADD  CONSTRAINT [DF_TXT_TXT_ETstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [txt_etstmp]
GO
ALTER TABLE [jsharmony].[txt] ADD  CONSTRAINT [DF_TXT_TXT_EUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [txt_eu]
GO
ALTER TABLE [jsharmony].[txt] ADD  CONSTRAINT [DF_TXT_TXT_MTstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [txt_mtstmp]
GO
ALTER TABLE [jsharmony].[txt] ADD  CONSTRAINT [DF_TXT_TXT_MUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [txt_mu]
GO
ALTER TABLE [jsharmony].[ucod_ac] ADD  CONSTRAINT [DF_UCOD_AC_COD_EDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [cod_etstmp]
GO
ALTER TABLE [jsharmony].[ucod_ac] ADD  CONSTRAINT [DF_UCOD_AC_cod_euser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [cod_eu]
GO
ALTER TABLE [jsharmony].[ucod_ac] ADD  CONSTRAINT [DF_UCOD_AC_COD_MDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [cod_mtstmp]
GO
ALTER TABLE [jsharmony].[ucod_ac] ADD  CONSTRAINT [DF_UCOD_AC_cod_muser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [cod_mu]
GO
ALTER TABLE [jsharmony].[ucod_ac1] ADD  CONSTRAINT [DF_UCOD_AC1_COD_EDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [cod_etstmp]
GO
ALTER TABLE [jsharmony].[ucod_ac1] ADD  CONSTRAINT [DF_UCOD_AC1_cod_euser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [cod_eu]
GO
ALTER TABLE [jsharmony].[ucod_ac1] ADD  CONSTRAINT [DF_UCOD_AC1_COD_MDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [cod_mtstmp]
GO
ALTER TABLE [jsharmony].[ucod_ac1] ADD  CONSTRAINT [DF_UCOD_AC1_cod_muser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [cod_mu]
GO
ALTER TABLE [jsharmony].[ucod_ahc] ADD  CONSTRAINT [DF_UCOD_AHC_COD_EDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [cod_etstmp]
GO
ALTER TABLE [jsharmony].[ucod_ahc] ADD  CONSTRAINT [DF_UCOD_AHC_cod_euser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [cod_eu]
GO
ALTER TABLE [jsharmony].[ucod_ahc] ADD  CONSTRAINT [DF_UCOD_AHC_COD_MDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [cod_mtstmp]
GO
ALTER TABLE [jsharmony].[ucod_ahc] ADD  CONSTRAINT [DF_UCOD_AHC_cod_muser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [cod_mu]
GO
ALTER TABLE [jsharmony].[ucod_country] ADD  CONSTRAINT [DF_UCOD_COUNTRY_COD_EDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [cod_etstmp]
GO
ALTER TABLE [jsharmony].[ucod_country] ADD  CONSTRAINT [DF_UCOD_COUNTRY_cod_euser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [cod_eu]
GO
ALTER TABLE [jsharmony].[ucod_country] ADD  CONSTRAINT [DF_UCOD_COUNTRY_COD_MDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [cod_mtstmp]
GO
ALTER TABLE [jsharmony].[ucod_country] ADD  CONSTRAINT [DF_UCOD_COUNTRY_cod_muser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [cod_mu]
GO
ALTER TABLE [jsharmony].[ucod_d_scope] ADD  CONSTRAINT [DF_UCOD_SCOPE_COD_EDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [cod_etstmp]
GO
ALTER TABLE [jsharmony].[ucod_d_scope] ADD  CONSTRAINT [DF_UCOD_SCOPE_cod_euser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [cod_eu]
GO
ALTER TABLE [jsharmony].[ucod_d_scope] ADD  CONSTRAINT [DF_UCOD_SCOPE_COD_MDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [cod_mtstmp]
GO
ALTER TABLE [jsharmony].[ucod_d_scope] ADD  CONSTRAINT [DF_UCOD_SCOPE_cod_muser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [cod_mu]
GO
ALTER TABLE [jsharmony].[ucod_h] ADD  CONSTRAINT [DF_COD_H_COD_H_Edt]  DEFAULT ([jsharmony].[myNOW]()) FOR [cod_h_etstmp]
GO
ALTER TABLE [jsharmony].[ucod_h] ADD  CONSTRAINT [DF_COD_H_COD_H_EUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [cod_h_eu]
GO
ALTER TABLE [jsharmony].[ucod_h] ADD  CONSTRAINT [DF_COD_H_COD_H_MDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [cod_h_mtstmp]
GO
ALTER TABLE [jsharmony].[ucod_h] ADD  CONSTRAINT [DF_COD_H_COD_H_MUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [cod_h_mu]
GO
ALTER TABLE [jsharmony].[ucod_n_scope] ADD  CONSTRAINT [DF_UCON_SCOPE_COD_EDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [cod_etstmp]
GO
ALTER TABLE [jsharmony].[ucod_n_scope] ADD  CONSTRAINT [DF_UCON_SCOPE_cod_euser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [cod_eu]
GO
ALTER TABLE [jsharmony].[ucod_n_scope] ADD  CONSTRAINT [DF_UCON_SCOPE_COD_MDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [cod_mtstmp]
GO
ALTER TABLE [jsharmony].[ucod_n_scope] ADD  CONSTRAINT [DF_UCON_SCOPE_cod_muser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [cod_mu]
GO
ALTER TABLE [jsharmony].[ucod_n_type] ADD  CONSTRAINT [DF_UCOD_N_TYPE_COD_EDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [cod_etstmp]
GO
ALTER TABLE [jsharmony].[ucod_n_type] ADD  CONSTRAINT [DF_UCOD_N_TYPE_cod_euser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [cod_eu]
GO
ALTER TABLE [jsharmony].[ucod_n_type] ADD  CONSTRAINT [DF_UCOD_N_TYPE_COD_MDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [cod_mtstmp]
GO
ALTER TABLE [jsharmony].[ucod_n_type] ADD  CONSTRAINT [DF_UCOD_N_TYPE_cod_muser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [cod_mu]
GO
ALTER TABLE [jsharmony].[ucod_ppd_type] ADD  CONSTRAINT [DF_UCOD_PPD_TYPE_COD_EDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [cod_etstmp]
GO
ALTER TABLE [jsharmony].[ucod_ppd_type] ADD  CONSTRAINT [DF_UCOD_PPD_TYPE_cod_euser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [cod_eu]
GO
ALTER TABLE [jsharmony].[ucod_ppd_type] ADD  CONSTRAINT [DF_UCOD_PPD_TYPE_COD_MDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [cod_mtstmp]
GO
ALTER TABLE [jsharmony].[ucod_ppd_type] ADD  CONSTRAINT [DF_UCOD_PPD_TYPE_cod_muser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [cod_mu]
GO
ALTER TABLE [jsharmony].[ucod_rqst_atype] ADD  CONSTRAINT [DF_UCOD_RQST_ATYPE_COD_EDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [cod_etstmp]
GO
ALTER TABLE [jsharmony].[ucod_rqst_atype] ADD  CONSTRAINT [DF_UCOD_RQST_ATYPE_cod_euser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [cod_eu]
GO
ALTER TABLE [jsharmony].[ucod_rqst_atype] ADD  CONSTRAINT [DF_UCOD_RQST_ATYPE_COD_MDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [cod_mtstmp]
GO
ALTER TABLE [jsharmony].[ucod_rqst_atype] ADD  CONSTRAINT [DF_UCOD_RQST_ATYPE_cod_muser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [cod_mu]
GO
ALTER TABLE [jsharmony].[ucod_rqst_source] ADD  CONSTRAINT [DF_UCOD_RQST_SOURCE_COD_EDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [cod_etstmp]
GO
ALTER TABLE [jsharmony].[ucod_rqst_source] ADD  CONSTRAINT [DF_UCOD_RQST_SOURCE_cod_euser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [cod_eu]
GO
ALTER TABLE [jsharmony].[ucod_rqst_source] ADD  CONSTRAINT [DF_UCOD_RQST_SOURCE_COD_MDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [cod_mtstmp]
GO
ALTER TABLE [jsharmony].[ucod_rqst_source] ADD  CONSTRAINT [DF_UCOD_RQST_SOURCE_cod_muser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [cod_mu]
GO
ALTER TABLE [jsharmony].[ucod_txt_type] ADD  CONSTRAINT [DF_UCOD_TXT_TYPE_COD_EDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [cod_etstmp]
GO
ALTER TABLE [jsharmony].[ucod_txt_type] ADD  CONSTRAINT [DF_UCOD_TXT_TYPE_cod_euser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [cod_eu]
GO
ALTER TABLE [jsharmony].[ucod_txt_type] ADD  CONSTRAINT [DF_UCOD_TXT_TYPE_COD_MDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [cod_mtstmp]
GO
ALTER TABLE [jsharmony].[ucod_txt_type] ADD  CONSTRAINT [DF_UCOD_TXT_TYPE_cod_muser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [cod_mu]
GO
ALTER TABLE [jsharmony].[ucod_v_sts] ADD  CONSTRAINT [DF_UCOD_V_STS_COD_EDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [cod_etstmp]
GO
ALTER TABLE [jsharmony].[ucod_v_sts] ADD  CONSTRAINT [DF_UCOD_V_STS_cod_euser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [cod_eu]
GO
ALTER TABLE [jsharmony].[ucod_v_sts] ADD  CONSTRAINT [DF_UCOD_V_STS_COD_MDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [cod_mtstmp]
GO
ALTER TABLE [jsharmony].[ucod_v_sts] ADD  CONSTRAINT [DF_UCOD_V_STS_cod_muser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [cod_mu]
GO
ALTER TABLE [jsharmony].[ucod2_country_state] ADD  CONSTRAINT [DF_UCOD2_COUNTRY_STATE_COD_EDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [cod_etstmp]
GO
ALTER TABLE [jsharmony].[ucod2_country_state] ADD  CONSTRAINT [DF_UCOD2_COUNTRY_STATE_cod_euser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [cod_eu]
GO
ALTER TABLE [jsharmony].[ucod2_country_state] ADD  CONSTRAINT [DF_UCOD2_COUNTRY_STATE_COD_MDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [cod_mtstmp]
GO
ALTER TABLE [jsharmony].[ucod2_country_state] ADD  CONSTRAINT [DF_UCOD2_COUNTRY_STATE_cod_muser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [cod_mu]
GO
ALTER TABLE [jsharmony].[ucod2_h] ADD  CONSTRAINT [DF_UCOD2_H_UCOD2_H_Edt]  DEFAULT ([jsharmony].[myNOW]()) FOR [cod_h_etstmp]
GO
ALTER TABLE [jsharmony].[ucod2_h] ADD  CONSTRAINT [DF_UCOD2_H_UCOD2_H_EUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [cod_h_eu]
GO
ALTER TABLE [jsharmony].[ucod2_h] ADD  CONSTRAINT [DF_UCOD2_H_UCOD2_H_MDt]  DEFAULT ([jsharmony].[myNOW]()) FOR [cod_h_mtstmp]
GO
ALTER TABLE [jsharmony].[ucod2_h] ADD  CONSTRAINT [DF_UCOD2_H_UCOD2_H_MUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [cod_h_mu]
GO
ALTER TABLE [jsharmony].[V] ADD  CONSTRAINT [DF_V_V_NO_MAJOR]  DEFAULT ((0)) FOR [v_no_major]
GO
ALTER TABLE [jsharmony].[V] ADD  CONSTRAINT [DF_V_V_NO_MINOR]  DEFAULT ((0)) FOR [v_no_minor]
GO
ALTER TABLE [jsharmony].[V] ADD  CONSTRAINT [DF_V_V_NO_BUILD]  DEFAULT ((0)) FOR [v_no_build]
GO
ALTER TABLE [jsharmony].[V] ADD  CONSTRAINT [DF_V_V_NO_REV]  DEFAULT ((0)) FOR [v_no_rev]
GO
ALTER TABLE [jsharmony].[V] ADD  CONSTRAINT [DF_V_V_STS]  DEFAULT ('OK') FOR [v_sts]
GO
ALTER TABLE [jsharmony].[V] ADD  CONSTRAINT [DF_V_V_ETstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [v_etstmp]
GO
ALTER TABLE [jsharmony].[V] ADD  CONSTRAINT [DF_V_V_EU]  DEFAULT ([jsharmony].[myCUSER]()) FOR [v_eu]
GO
ALTER TABLE [jsharmony].[V] ADD  CONSTRAINT [DF_V_V_MTstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [v_mtstmp]
GO
ALTER TABLE [jsharmony].[V] ADD  CONSTRAINT [DF_V_V_MU]  DEFAULT ([jsharmony].[myCUSER]()) FOR [v_mu]
GO
ALTER TABLE [jsharmony].[xpp] ADD  CONSTRAINT [DF_XPP_XPP_ETstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [xpp_etstmp]
GO
ALTER TABLE [jsharmony].[xpp] ADD  CONSTRAINT [DF_XPP_XPP_EUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [xpp_eu]
GO
ALTER TABLE [jsharmony].[xpp] ADD  CONSTRAINT [DF_XPP_XPP_MTstmp]  DEFAULT ([jsharmony].[myNOW]()) FOR [xpp_mtstmp]
GO
ALTER TABLE [jsharmony].[xpp] ADD  CONSTRAINT [DF_XPP_XPP_MUser]  DEFAULT ([jsharmony].[myCUSER]()) FOR [xpp_mu]
GO
ALTER TABLE [jsharmony].[AUD_D]  WITH CHECK ADD  CONSTRAINT [FK_AUD_D_AUD_H] FOREIGN KEY([AUD_SEQ])
REFERENCES [jsharmony].[AUD_H] ([AUD_SEQ])
GO
ALTER TABLE [jsharmony].[AUD_D] CHECK CONSTRAINT [FK_AUD_D_AUD_H]
GO
ALTER TABLE [jsharmony].[cpe]  WITH CHECK ADD  CONSTRAINT [FK_CPE_UCOD_AHC] FOREIGN KEY([pe_sts])
REFERENCES [jsharmony].[ucod_ahc] ([codeval])
GO
ALTER TABLE [jsharmony].[cpe] CHECK CONSTRAINT [FK_CPE_UCOD_AHC]
GO
ALTER TABLE [jsharmony].[cper]  WITH CHECK ADD  CONSTRAINT [FK_CPER_CPE] FOREIGN KEY([pe_id])
REFERENCES [jsharmony].[cpe] ([pe_id])
ON DELETE CASCADE
GO
ALTER TABLE [jsharmony].[cper] CHECK CONSTRAINT [FK_CPER_CPE]
GO
ALTER TABLE [jsharmony].[cper]  WITH CHECK ADD  CONSTRAINT [FK_CPER_CR_CR_NAME] FOREIGN KEY([cr_name])
REFERENCES [jsharmony].[cr] ([cr_name])
GO
ALTER TABLE [jsharmony].[cper] CHECK CONSTRAINT [FK_CPER_CR_CR_NAME]
GO
ALTER TABLE [jsharmony].[cr]  WITH CHECK ADD  CONSTRAINT [FK_CR_UCOD_AHC] FOREIGN KEY([cr_sts])
REFERENCES [jsharmony].[ucod_ahc] ([codeval])
GO
ALTER TABLE [jsharmony].[cr] CHECK CONSTRAINT [FK_CR_UCOD_AHC]
GO
ALTER TABLE [jsharmony].[crm]  WITH CHECK ADD  CONSTRAINT [FK_CRM_CR_CR_NAME] FOREIGN KEY([cr_name])
REFERENCES [jsharmony].[cr] ([cr_name])
ON DELETE CASCADE
GO
ALTER TABLE [jsharmony].[crm] CHECK CONSTRAINT [FK_CRM_CR_CR_NAME]
GO
ALTER TABLE [jsharmony].[crm]  WITH CHECK ADD  CONSTRAINT [FK_CRM_SM] FOREIGN KEY([sm_id])
REFERENCES [jsharmony].[sm] ([sm_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [jsharmony].[crm] CHECK CONSTRAINT [FK_CRM_SM]
GO
ALTER TABLE [jsharmony].[d]  WITH CHECK ADD  CONSTRAINT [FK_D_GCOD2_D_SCOPE_D_CTGR] FOREIGN KEY([d_scope], [d_ctgr])
REFERENCES [jsharmony].[gcod2_d_scope_d_ctgr] ([codeval1], [codeval2])
GO
ALTER TABLE [jsharmony].[d] CHECK CONSTRAINT [FK_D_GCOD2_D_SCOPE_D_CTGR]
GO
ALTER TABLE [jsharmony].[d]  WITH CHECK ADD  CONSTRAINT [FK_D_UCOD_D_SCOPE] FOREIGN KEY([d_scope])
REFERENCES [jsharmony].[ucod_d_scope] ([codeval])
GO
ALTER TABLE [jsharmony].[d] CHECK CONSTRAINT [FK_D_UCOD_D_SCOPE]
GO
ALTER TABLE [jsharmony].[gpp]  WITH CHECK ADD  CONSTRAINT [FK_GPP_PPD] FOREIGN KEY([gpp_process], [gpp_attrib])
REFERENCES [jsharmony].[PPD] ([PPD_PROCESS], [PPD_ATTRIB])
GO
ALTER TABLE [jsharmony].[gpp] CHECK CONSTRAINT [FK_GPP_PPD]
GO
ALTER TABLE [jsharmony].[h]  WITH CHECK ADD  CONSTRAINT [FK_H_HP] FOREIGN KEY([hp_code])
REFERENCES [jsharmony].[hp] ([hp_code])
GO
ALTER TABLE [jsharmony].[h] CHECK CONSTRAINT [FK_H_HP]
GO
ALTER TABLE [jsharmony].[n]  WITH CHECK ADD  CONSTRAINT [FK_N_UCOD_AC1] FOREIGN KEY([n_sts])
REFERENCES [jsharmony].[ucod_ac1] ([codeval])
GO
ALTER TABLE [jsharmony].[n] CHECK CONSTRAINT [FK_N_UCOD_AC1]
GO
ALTER TABLE [jsharmony].[n]  WITH CHECK ADD  CONSTRAINT [FK_N_UCOD_N_SCOPE] FOREIGN KEY([n_scope])
REFERENCES [jsharmony].[ucod_n_scope] ([codeval])
GO
ALTER TABLE [jsharmony].[n] CHECK CONSTRAINT [FK_N_UCOD_N_SCOPE]
GO
ALTER TABLE [jsharmony].[n]  WITH CHECK ADD  CONSTRAINT [FK_N_UCOD_N_TYPE] FOREIGN KEY([n_type])
REFERENCES [jsharmony].[ucod_n_type] ([codeval])
GO
ALTER TABLE [jsharmony].[n] CHECK CONSTRAINT [FK_N_UCOD_N_TYPE]
GO
ALTER TABLE [jsharmony].[pe]  WITH CHECK ADD  CONSTRAINT [FK_PE_UCOD_AHC] FOREIGN KEY([pe_sts])
REFERENCES [jsharmony].[ucod_ahc] ([codeval])
GO
ALTER TABLE [jsharmony].[pe] CHECK CONSTRAINT [FK_PE_UCOD_AHC]
GO
ALTER TABLE [jsharmony].[pe]  WITH CHECK ADD  CONSTRAINT [FK_PE_UCOD_COUNTRY] FOREIGN KEY([pe_country])
REFERENCES [jsharmony].[ucod_country] ([codeval])
GO
ALTER TABLE [jsharmony].[pe] CHECK CONSTRAINT [FK_PE_UCOD_COUNTRY]
GO
ALTER TABLE [jsharmony].[pe]  WITH CHECK ADD  CONSTRAINT [FK_PE_UCOD2_COUNTRY_STATE] FOREIGN KEY([pe_country], [pe_state])
REFERENCES [jsharmony].[ucod2_country_state] ([codeval1], [codeval2])
GO
ALTER TABLE [jsharmony].[pe] CHECK CONSTRAINT [FK_PE_UCOD2_COUNTRY_STATE]
GO
ALTER TABLE [jsharmony].[PPD]  WITH CHECK ADD  CONSTRAINT [FK_PPD_UCOD_PPD_TYPE] FOREIGN KEY([PPD_TYPE])
REFERENCES [jsharmony].[ucod_ppd_type] ([codeval])
GO
ALTER TABLE [jsharmony].[PPD] CHECK CONSTRAINT [FK_PPD_UCOD_PPD_TYPE]
GO
ALTER TABLE [jsharmony].[PPP]  WITH CHECK ADD  CONSTRAINT [FK_PPP_PE] FOREIGN KEY([pe_id])
REFERENCES [jsharmony].[pe] ([pe_id])
ON DELETE CASCADE
GO
ALTER TABLE [jsharmony].[PPP] CHECK CONSTRAINT [FK_PPP_PE]
GO
ALTER TABLE [jsharmony].[PPP]  WITH CHECK ADD  CONSTRAINT [FK_PPP_PPD] FOREIGN KEY([ppp_process], [ppp_attrib])
REFERENCES [jsharmony].[PPD] ([PPD_PROCESS], [PPD_ATTRIB])
ON DELETE CASCADE
GO
ALTER TABLE [jsharmony].[PPP] CHECK CONSTRAINT [FK_PPP_PPD]
GO
ALTER TABLE [jsharmony].[rqst]  WITH CHECK ADD  CONSTRAINT [FK_RQST_UCOD_RQST_ATYPE] FOREIGN KEY([rqst_atype])
REFERENCES [jsharmony].[ucod_rqst_atype] ([codeval])
GO
ALTER TABLE [jsharmony].[rqst] CHECK CONSTRAINT [FK_RQST_UCOD_RQST_ATYPE]
GO
ALTER TABLE [jsharmony].[rqst]  WITH CHECK ADD  CONSTRAINT [FK_RQST_UCOD_RQST_SOURCE] FOREIGN KEY([rqst_source])
REFERENCES [jsharmony].[ucod_rqst_source] ([codeval])
GO
ALTER TABLE [jsharmony].[rqst] CHECK CONSTRAINT [FK_RQST_UCOD_RQST_SOURCE]
GO
ALTER TABLE [jsharmony].[rqst_d]  WITH CHECK ADD  CONSTRAINT [FK_RQST_D_RQST] FOREIGN KEY([rqst_id])
REFERENCES [jsharmony].[rqst] ([rqst_id])
GO
ALTER TABLE [jsharmony].[rqst_d] CHECK CONSTRAINT [FK_RQST_D_RQST]
GO
ALTER TABLE [jsharmony].[rqst_email]  WITH CHECK ADD  CONSTRAINT [FK_RQST_EMAIL_RQST] FOREIGN KEY([rqst_id])
REFERENCES [jsharmony].[rqst] ([rqst_id])
GO
ALTER TABLE [jsharmony].[rqst_email] CHECK CONSTRAINT [FK_RQST_EMAIL_RQST]
GO
ALTER TABLE [jsharmony].[rqst_n]  WITH CHECK ADD  CONSTRAINT [FK_RQST_N_RQST] FOREIGN KEY([rqst_id])
REFERENCES [jsharmony].[rqst] ([rqst_id])
GO
ALTER TABLE [jsharmony].[rqst_n] CHECK CONSTRAINT [FK_RQST_N_RQST]
GO
ALTER TABLE [jsharmony].[rqst_rq]  WITH CHECK ADD  CONSTRAINT [FK_RQST_RQ_RQST] FOREIGN KEY([rqst_id])
REFERENCES [jsharmony].[rqst] ([rqst_id])
GO
ALTER TABLE [jsharmony].[rqst_rq] CHECK CONSTRAINT [FK_RQST_RQ_RQST]
GO
ALTER TABLE [jsharmony].[rqst_sms]  WITH CHECK ADD  CONSTRAINT [FK_RQST_SMS_RQST] FOREIGN KEY([rqst_id])
REFERENCES [jsharmony].[rqst] ([rqst_id])
GO
ALTER TABLE [jsharmony].[rqst_sms] CHECK CONSTRAINT [FK_RQST_SMS_RQST]
GO
ALTER TABLE [jsharmony].[sf]  WITH CHECK ADD  CONSTRAINT [FK_SF_UCOD_AHC] FOREIGN KEY([SF_STS])
REFERENCES [jsharmony].[ucod_ahc] ([codeval])
GO
ALTER TABLE [jsharmony].[sf] CHECK CONSTRAINT [FK_SF_UCOD_AHC]
GO
ALTER TABLE [jsharmony].[sm]  WITH CHECK ADD  CONSTRAINT [FK_SM_SM] FOREIGN KEY([sm_id_parent])
REFERENCES [jsharmony].[sm] ([sm_id])
GO
ALTER TABLE [jsharmony].[sm] CHECK CONSTRAINT [FK_SM_SM]
GO
ALTER TABLE [jsharmony].[sm]  WITH CHECK ADD  CONSTRAINT [FK_SM_UCOD_AHC] FOREIGN KEY([sm_sts])
REFERENCES [jsharmony].[ucod_ahc] ([codeval])
GO
ALTER TABLE [jsharmony].[sm] CHECK CONSTRAINT [FK_SM_UCOD_AHC]
GO
ALTER TABLE [jsharmony].[spef]  WITH CHECK ADD  CONSTRAINT [FK_SPEF_PE] FOREIGN KEY([pe_id])
REFERENCES [jsharmony].[pe] ([pe_id])
GO
ALTER TABLE [jsharmony].[spef] CHECK CONSTRAINT [FK_SPEF_PE]
GO
ALTER TABLE [jsharmony].[spef]  WITH CHECK ADD  CONSTRAINT [FK_SPEF_SF_SF_NAME] FOREIGN KEY([sf_name])
REFERENCES [jsharmony].[sf] ([sf_name])
GO
ALTER TABLE [jsharmony].[spef] CHECK CONSTRAINT [FK_SPEF_SF_SF_NAME]
GO
ALTER TABLE [jsharmony].[sper]  WITH CHECK ADD  CONSTRAINT [FK_SPER_PE] FOREIGN KEY([pe_id])
REFERENCES [jsharmony].[pe] ([pe_id])
GO
ALTER TABLE [jsharmony].[sper] CHECK CONSTRAINT [FK_SPER_PE]
GO
ALTER TABLE [jsharmony].[sper]  WITH CHECK ADD  CONSTRAINT [FK_SPER_SR_SR_NAME] FOREIGN KEY([sr_name])
REFERENCES [jsharmony].[sr] ([sr_name])
GO
ALTER TABLE [jsharmony].[sper] CHECK CONSTRAINT [FK_SPER_SR_SR_NAME]
GO
ALTER TABLE [jsharmony].[sr]  WITH CHECK ADD  CONSTRAINT [FK_SR_UCOD_AHC] FOREIGN KEY([sr_sts])
REFERENCES [jsharmony].[ucod_ahc] ([codeval])
GO
ALTER TABLE [jsharmony].[sr] CHECK CONSTRAINT [FK_SR_UCOD_AHC]
GO
ALTER TABLE [jsharmony].[srm]  WITH CHECK ADD  CONSTRAINT [FK_SRM_SM] FOREIGN KEY([sm_id])
REFERENCES [jsharmony].[sm] ([sm_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [jsharmony].[srm] CHECK CONSTRAINT [FK_SRM_SM]
GO
ALTER TABLE [jsharmony].[srm]  WITH CHECK ADD  CONSTRAINT [FK_SRM_SR_SR_NAME] FOREIGN KEY([sr_name])
REFERENCES [jsharmony].[sr] ([sr_name])
ON DELETE CASCADE
GO
ALTER TABLE [jsharmony].[srm] CHECK CONSTRAINT [FK_SRM_SR_SR_NAME]
GO
ALTER TABLE [jsharmony].[txt]  WITH CHECK ADD  CONSTRAINT [FK_TXT_UCOD_TXT_TYPE] FOREIGN KEY([txt_type])
REFERENCES [jsharmony].[ucod_txt_type] ([codeval])
GO
ALTER TABLE [jsharmony].[txt] CHECK CONSTRAINT [FK_TXT_UCOD_TXT_TYPE]
GO
ALTER TABLE [jsharmony].[V]  WITH CHECK ADD  CONSTRAINT [FK_V_UCOD_V_STS] FOREIGN KEY([v_sts])
REFERENCES [jsharmony].[ucod_v_sts] ([codeval])
GO
ALTER TABLE [jsharmony].[V] CHECK CONSTRAINT [FK_V_UCOD_V_STS]
GO
ALTER TABLE [jsharmony].[xpp]  WITH CHECK ADD  CONSTRAINT [FK_XPP_PPD] FOREIGN KEY([xpp_process], [xpp_attrib])
REFERENCES [jsharmony].[PPD] ([PPD_PROCESS], [PPD_ATTRIB])
GO
ALTER TABLE [jsharmony].[xpp] CHECK CONSTRAINT [FK_XPP_PPD]
GO
ALTER TABLE [jsharmony].[cpe]  WITH CHECK ADD  CONSTRAINT [CK_CPE_PE_Email] CHECK  ((isnull([pe_email],'')<>''))
GO
ALTER TABLE [jsharmony].[cpe] CHECK CONSTRAINT [CK_CPE_PE_Email]
GO
ALTER TABLE [jsharmony].[pe]  WITH CHECK ADD  CONSTRAINT [CK_PE_PE_Email] CHECK  ((isnull([pe_email],'')<>''))
GO
ALTER TABLE [jsharmony].[pe] CHECK CONSTRAINT [CK_PE_PE_Email]
GO
ALTER TABLE [jsharmony].[sm]  WITH CHECK ADD  CONSTRAINT [CK_SM_SM_UTYPE] CHECK  (([sm_utype]='C' OR [sm_utype]='S'))
GO
ALTER TABLE [jsharmony].[sm] CHECK CONSTRAINT [CK_SM_SM_UTYPE]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE  [jsharmony].[audh]
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
	  FROM {{schema}}.V_PP
     where PP_PROCESS = 'SQL'
	   and PP_ATTRIB = 'GETCID';

    SELECT @GETEID = PP_VAL
	  FROM {{schema}}.V_PP
     where PP_PROCESS = 'SQL'
	   and PP_ATTRIB = 'GETEID';

    SET @MYUSER = CASE WHEN @u IS NULL THEN {{schema}}.myCUSER() ELSE @u END

    if (@OP = 'D')
	begin
		select top(1)
			     @WK_C_ID = C_ID,
		       @WK_E_ID = E_ID,
		       @WK_REF_NAME = REF_NAME,
		       @WK_REF_ID = REF_ID,
		       @WK_SUBJ = SUBJ
		  from {{schema}}.AUD_H
         where TABLE_NAME = lower(@tname)
		   and TABLE_ID = @tid
		   and AUD_OP = 'I'
         order by AUD_SEQ desc; 
         if @@ROWCOUNT = 0
		 begin

           if (@cid is null and lower(@tname) <> 'c')
		   begin	
	         SET @SQLCMD = 'select @my_c_id  = ' + @GETCID + '(''' + lower(@tname) + ''',' + convert(varchar,@tid) + ')'
	         EXECUTE sp_executesql @SQLCMD, N'@my_c_id bigint OUTPUT', @MY_C_ID=@my_c_id OUTPUT
	         SET @C_ID = @MY_C_ID
           end

           if (@eid is null and lower(@tname) <> 'e')
		   begin	
	         SET @SQLCMD = 'select @my_e_id  = ' + @GETEID + '(''' + lower(@tname) + ''',' + convert(varchar,@tid) + ')'
	         EXECUTE sp_executesql @SQLCMD, N'@my_e_id bigint OUTPUT', @MY_E_ID=@my_e_id OUTPUT
	         SET @E_ID = @MY_E_ID
		   end

		   select @WK_C_ID = case when @cid is not null then @cid
		                          when lower(@tname) = 'c' then @tid 
							      else @C_ID end,  
		          @WK_E_ID = case when @eid is not null then @eid
		                          when lower(@tname)  = 'e' then @tid 
								  else @E_ID end, 
		          @WK_REF_NAME = @ref_name,
		          @WK_REF_ID = @ref_id,
		          @WK_SUBJ = @subj;
		 end
	end
    ELSE
	begin

        if (@cid is null and lower(@tname) <> 'c')
		begin	
	      SET @SQLCMD = 'select @my_c_id  = ' + @GETCID + '(''' + lower(@tname) + ''',' + convert(varchar,@tid) + ')'
	      EXECUTE sp_executesql @SQLCMD, N'@my_c_id bigint OUTPUT', @MY_C_ID=@my_c_id OUTPUT
	      SET @C_ID = @MY_C_ID
        end

        if (@eid is null and lower(@tname) <> 'e')
		begin	
	      SET @SQLCMD = 'select @my_e_id  = ' + @GETEID + '(''' + lower(@tname) + ''',' + convert(varchar,@tid) + ')'
	      EXECUTE sp_executesql @SQLCMD, N'@my_e_id bigint OUTPUT', @MY_E_ID=@my_e_id OUTPUT
	      SET @E_ID = @MY_E_ID
		end

		SET @WK_C_ID = case when @cid is not null then @cid
		                    when lower(@tname) = 'c' then @tid 
							else @C_ID end;  
		SET @WK_E_ID = case when @eid is not null then @eid
		                    when lower(@tname) = 'e' then @tid 
							else @E_ID end; 
		SET @WK_REF_NAME = @ref_name;
		SET @WK_REF_ID = @ref_id;
		SET @WK_SUBJ = @subj;
	end

    INSERT INTO {{schema}}.AUD_H 
	                  (TABLE_NAME, TABLE_ID, AUD_OP, AUD_U, AUD_Tstmp, C_ID, E_ID, REF_NAME, REF_ID, SUBJ) 
               VALUES (lower(@tname), 
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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE  [jsharmony].[audh_base]
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

    SET @MYUSER = CASE WHEN @u IS NULL THEN {{schema}}.myCUSER() ELSE @u END

    if (@OP = 'D')
	begin
		select top(1)
		       @WK_REF_NAME = REF_NAME,
		       @WK_REF_ID = REF_ID,
		       @WK_SUBJ = SUBJ
		  from {{schema}}.AUD_H
         where TABLE_NAME = lower(@tname)
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

    INSERT INTO {{schema}}.AUD_H 
	                  (TABLE_NAME, TABLE_ID, AUD_OP, AUD_U, AUD_Tstmp, REF_NAME, REF_ID, SUBJ) 
               VALUES (lower(@tname), 
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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE  [jsharmony].[check_code]
(
	@in_tblname nvarchar(255),
	@in_codeval nvarchar(8)
)	
as
BEGIN

DECLARE	@return_value int

BEGIN TRY
EXEC	@return_value = [jsharmony].[CHECK_CODE_P]
		@in_tblname = @in_tblname,
		@in_codeval = @in_codeval
END TRY	
BEGIN CATCH	
SELECT @return_value = -1
END CATCH

RETURN( @return_value)

END




GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE PROCEDURE  [jsharmony].[check_code_p]
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
   order by (case table_schema when '{{schema}}' then 1 else 2 end),table_schema;

  exec sp_executesql @runmesql, N'@irslt bigint output', @irslt = @rslt output 	
      
  return (@rslt)

END







GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE  [jsharmony].[check_code2]
(
	@in_tblname nvarchar(255),
	@in_codeval1 nvarchar(8),
	@in_codeval2 nvarchar(8)
)	
as
BEGIN

DECLARE	@return_value int

BEGIN TRY
EXEC	@return_value = [jsharmony].[CHECK_CODE2_P]
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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE  [jsharmony].[check_code2_p]
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
   order by (case table_schema when '{{schema}}' then 1 else 2 end),table_schema;

  exec sp_executesql @runmesql, N'@irslt bigint output', @irslt = @rslt output 	
      
  return (@rslt)

END






GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE  [jsharmony].[check_foreign]
(
	@in_tblname nvarchar(16),
	@in_tblid bigint
)	
as
BEGIN

DECLARE	@return_value int

BEGIN TRY
EXEC	@return_value = [jsharmony].[CHECK_FOREIGN_P]
		@in_tblname = @in_tblname,
		@in_tblid = @in_tblid
END TRY	
BEGIN CATCH	
SELECT @return_value = -1
END CATCH

RETURN( @return_value)

END


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE  [jsharmony].[check_foreign_p]
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
   order by (case table_schema when '{{schema}}' then 1 else 2 end),table_schema;

  exec sp_executesql @runmesql, N'@irslt bigint output', @irslt = @rslt output 	
      
  return (@rslt)

END





GO
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
    from {{schema}}.SCRIPT
   where SCRIPT_NAME = 'CREATE_GCOD';

  set @rrr = replace(@rrr, '%%%schema%%%', lower(isnull(@in_codeschema,'dbo')))
  set @rrr = replace(@rrr, '%%%name%%%', lower(@in_codename))
  set @rrr = replace(@rrr, '%%%mean%%%', lower(@in_codemean))

  EXEC (@rrr)      

  select @rrrt = SCRIPT_TXT
    from {{schema}}.SCRIPT
   where SCRIPT_NAME = 'CREATE_GCOD_TRIGGER';

  set @rrrt = replace(@rrrt, '%%%schema%%%', lower(isnull(@in_codeschema,'dbo')))
  set @rrrt = replace(@rrrt, '%%%name%%%', lower(@in_codename))
  set @rrrt = replace(@rrrt, '%%%mean%%%', lower(@in_codemean))

  EXEC (@rrrt)      

  return (@rslt)

END






GO
GRANT EXECUTE ON [jsharmony].[create_gcod] TO [{{schema}}_role_dev] AS [dbo]
GO
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
    from {{schema}}.SCRIPT
   where SCRIPT_NAME = 'CREATE_GCOD2';

  set @rrr = replace(@rrr, '%%%schema%%%', lower(isnull(@in_codeschema,'dbo')))
  set @rrr = replace(@rrr, '%%%name%%%', lower(@in_codename))
  set @rrr = replace(@rrr, '%%%mean%%%', lower(@in_codemean))

  EXEC (@rrr)      

  select @rrrt = SCRIPT_TXT
    from {{schema}}.SCRIPT
   where SCRIPT_NAME = 'CREATE_GCOD2_TRIGGER';

  set @rrrt = replace(@rrrt, '%%%schema%%%', lower(isnull(@in_codeschema,'dbo')))
  set @rrrt = replace(@rrrt, '%%%name%%%', lower(@in_codename))
  set @rrrt = replace(@rrrt, '%%%mean%%%', lower(@in_codemean))

  EXEC (@rrrt)      

  return (@rslt)

END






GO
GRANT EXECUTE ON [jsharmony].[create_gcod2] TO [{{schema}}_role_dev] AS [dbo]
GO
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
    from {{schema}}.SCRIPT
   where SCRIPT_NAME = 'CREATE_UCOD';

  set @rrr = replace(@rrr, '%%%schema%%%', lower(isnull(@in_codeschema,'dbo')))
  set @rrr = replace(@rrr, '%%%name%%%', lower(@in_codename))
  set @rrr = replace(@rrr, '%%%mean%%%', lower(@in_codemean))

  EXEC (@rrr)      

  return (@rslt)

END






GO
GRANT EXECUTE ON [jsharmony].[create_ucod] TO [{{schema}}_role_dev] AS [dbo]
GO
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
    from {{schema}}.SCRIPT
   where SCRIPT_NAME = 'CREATE_UCOD2';

  set @rrr = replace(@rrr, '%%%schema%%%', lower(isnull(@in_codeschema,'dbo')))
  set @rrr = replace(@rrr, '%%%name%%%', lower(@in_codename))
  set @rrr = replace(@rrr, '%%%mean%%%', lower(@in_codemean))

  EXEC (@rrr)      

  return (@rslt)

END






GO
GRANT EXECUTE ON [jsharmony].[create_ucod2] TO [{{schema}}_role_dev] AS [dbo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





/*@ SEND DEBUGGING INFO TO TEXT FILE @*/
CREATE PROCEDURE  [jsharmony].[zz-filedebug]
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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE trigger [jsharmony].[CPE_IUD] on [jsharmony].[cpe]
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
  
  SET @CURDTTM = {{schema}}.myNOW_DO()
  SET @CURDTTM_CHAR = CONVERT(NVARCHAR, @CURDTTM, 120)+'.0000000'
  SET @MYUSER = {{schema}}.myCUSER() 

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
	  if ({{schema}}.NONEQUALC(@I_PE_PW1, @I_PE_PW2) > 0)
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
		@TP='U' AND {{schema}}.NONEQUALN(@D_C_ID, @I_C_ID) > 0)
	BEGIN
		EXEC	@C = [jsharmony].[CHECK_FOREIGN]
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

	  set @hash = {{schema}}.myHASH('C', @I_PE_ID, @NEWPW);

	  if (@hash is null)
      BEGIN
        CLOSE CUR_CPE_IUD
        DEALLOCATE CUR_CPE_IUD
        SET @M = 'Application Error - Missing or Incorrect Password'
        raiserror(@M,16,1)
        ROLLBACK TRANSACTION
        return
      END

      UPDATE {{schema}}.CPE
	     SET PE_STSDt = @CURDTTM,
		     PE_ETstmp = @CURDTTM,
			 PE_EU = @MYUSER,
		     PE_MTstmp = @CURDTTM,
			 PE_MU = @MYUSER,
			 PE_Hash = @hash,
			 PE_PW1 = NULL,
			 PE_PW2 = NULL
       WHERE CPE.PE_ID = @I_PE_ID;

      INSERT INTO {{schema}}.CPER (PE_ID, CR_NAME)
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
	  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH @TP, 'CPE', @WK_PE_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ,@WK_C_ID
	END
 
    IF @TP='U' OR @TP='D'
	BEGIN

      IF (@TP = 'D' AND @D_C_ID IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALC(@D_C_ID, @I_C_ID) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH 'U', 'CPE', @I_PE_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ,@WK_C_ID
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('C_ID'), @D_C_ID)
      END

      IF (@TP = 'D' AND @D_PE_STS IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALC(@D_PE_STS, @I_PE_STS) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH 'U', 'CPE', @I_PE_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ,@WK_C_ID
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('PE_STS'), @D_PE_STS)
      END

      IF (@TP = 'D' AND @D_PE_FName IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALC(@D_PE_FName, @I_PE_FName) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH 'U', 'CPE', @I_PE_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ,@WK_C_ID
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('PE_FName'), @D_PE_FName)
      END

      IF (@TP = 'D' AND @D_PE_MName IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALC(@D_PE_MName, @I_PE_MName) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH 'U', 'CPE', @I_PE_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ,@WK_C_ID
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('PE_MName'), @D_PE_MName)
      END

      IF (@TP = 'D' AND @D_PE_LName IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALC(@D_PE_LName, @I_PE_LName) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH 'U', 'CPE', @I_PE_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ,@WK_C_ID
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('PE_LName'), @D_PE_LName)
      END

      IF (@TP = 'D' AND @D_PE_JTitle IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALC(@D_PE_JTitle, @I_PE_JTitle) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH 'U', 'CPE', @I_PE_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ,@WK_C_ID
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('PE_JTitle'), @D_PE_JTitle)
      END

      IF (@TP = 'D' AND @D_PE_BPhone IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALC(@D_PE_BPhone, @I_PE_BPhone) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH 'U', 'CPE', @I_PE_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ,@WK_C_ID
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('PE_BPhone'), @D_PE_BPhone)
      END

      IF (@TP = 'D' AND @D_PE_CPhone IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALC(@D_PE_CPhone, @I_PE_CPhone) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH 'U', 'CPE', @I_PE_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ,@WK_C_ID
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('PE_CPhone'), @D_PE_CPhone)
      END

      IF (@TP = 'D' AND @D_PE_Email IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALC(@D_PE_Email, @I_PE_Email) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH 'U', 'CPE', @I_PE_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ,@WK_C_ID
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('PE_Email'), @D_PE_Email)
      END

      IF (@TP = 'D' AND @D_PE_LL_TSTMP IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALD(@D_PE_LL_TSTMP, @I_PE_LL_TSTMP) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH 'U', 'CPE', @I_PE_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ,@WK_C_ID
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('PE_LL_TSTMP'), @D_PE_LL_TSTMP)
      END

	  IF (@TP = 'U' AND isnull(@NEWPW,'') <> '')
	  BEGIN
		set @hash = {{schema}}.myHASH('C', @I_PE_ID, @NEWPW);

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
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH 'U', 'CPE', @I_PE_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ,@WK_C_ID
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('PE_PW'), '*')

	    SET @UPDATE_PW = 'Y'
	  END


    END  /* END OF "IF @TP='U' OR @TP='D'"  */


	/******************************************/
	/****** SPECIAL BACK ACTION - BEGIN  ******/
	/******************************************/

    IF (@TP='U' AND @MY_AUD_SEQ <> 0)
	BEGIN
      UPDATE {{schema}}.CPE
	     SET PE_STSDt = CASE WHEN {{schema}}.NONEQUALC(@D_PE_STS, @I_PE_STS) > 0 THEN @CURDTTM ELSE PE_STSDt END,
		     PE_MTstmp = @CURDTTM,
			 PE_MU = @MYUSER,
			 PE_Hash = case @UPDATE_PW when 'Y' then @hash else PE_Hash end,
			 PE_PW1 = NULL,
			 PE_PW2 = NULL
       WHERE CPE.PE_ID = @I_PE_ID;
    END  
    ELSE IF (@TP='U' AND (@I_PE_PW1 is not null or @I_PE_PW2 is not null))
	BEGIN
      UPDATE {{schema}}.CPE
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
ALTER TABLE [jsharmony].[cpe] ENABLE TRIGGER [CPE_IUD]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE trigger [jsharmony].[CPER_IUD] on [jsharmony].[cper]
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
  
  SET @CURDTTM = {{schema}}.myNOW_DO()
  SET @CURDTTM_CHAR = CONVERT(NVARCHAR, @CURDTTM, 120)+'.0000000'
  SET @MYUSER = {{schema}}.myCUSER() 

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
	  FROM {{schema}}.CPE
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
                  inner join {{schema}}.CPE on CPE.C_ID = CF.C_ID
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
	  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH @TP, 'CPER', @WK_CPER_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ
	END

    IF @TP='U' OR @TP='D'
	BEGIN

      IF (@TP = 'D' AND @D_PE_ID IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALN(@D_PE_ID, @I_PE_ID) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH 'U', 'CPER', @I_CPER_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('PE_ID'), @D_PE_ID)
      END

      IF (@TP = 'D' AND @D_CR_NAME IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALC(@D_CR_NAME, @I_CR_NAME) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH 'U', 'CPER', @I_CPER_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('CR_NAME'), @D_CR_NAME)
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
ALTER TABLE [jsharmony].[cper] ENABLE TRIGGER [CPER_IUD]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE trigger [jsharmony].[D_IUD] on [jsharmony].[d]
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

  DECLARE @SQLCMD nvarchar(max)
  DECLARE @DSCOPE_DCTGR nvarchar(max)

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
  
  SET @CURDTTM = {{schema}}.myNOW_DO()
  SET @CURDTTM_CHAR = CONVERT(NVARCHAR, @CURDTTM, 120)+'.0000000'
  SET @MYUSER = {{schema}}.myCUSER() 

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
	FROM {{schema}}.V_PP
   where PP_PROCESS = 'SQL'
	 and PP_ATTRIB = 'DSCOPE_DCTGR';
  IF (@TP='I' OR @TP='U') AND @DSCOPE_DCTGR IS NULL
  BEGIN
    raiserror('DSCOPE_DCTGR parameter not set',16,1)
    ROLLBACK TRANSACTION
    return
  END

  
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
		@TP='U' AND ({{schema}}.nonequalc(@D_D_SCOPE, @I_D_SCOPE)>0
		             OR
					 {{schema}}.nonequaln(@D_D_SCOPE_ID, @I_D_SCOPE_ID)>0))
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
		EXEC	@C = [jsharmony].[CHECK_FOREIGN]
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
		EXEC	@C = [jsharmony].[CHECK_CODE2]
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


    IF (@TP='I')
	BEGIN


	  IF (@I_D_SYNCTSTMP is null)
        UPDATE {{schema}}.D
	     SET C_ID = NULL,
		     E_ID = NULL,
		     D_ETstmp = @CURDTTM,
			 D_EU = @MYUSER,
		     D_MTstmp = @CURDTTM,
			 D_MU = @MYUSER
         WHERE D.D_ID = @I_D_ID;
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
	  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE  @TP, 'D', @WK_D_ID, @MYUSER, @CURDTTM, @WK_REF_NAME, @WK_REF_ID, default
	END

 
    IF @TP='U' OR @TP='D'
	BEGIN

      IF (@TP = 'D' AND @D_D_SCOPE IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALC(@D_D_SCOPE, @I_D_SCOPE) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE  'U', 'D', @I_D_ID, @MYUSER, @CURDTTM, @I_D_SCOPE, @I_D_SCOPE_ID, default
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('D_SCOPE'), @D_D_SCOPE)
      END

      IF (@TP = 'D' AND @D_D_SCOPE_ID IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALN(@D_D_SCOPE_ID, @I_D_SCOPE_ID) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE  'U', 'D', @I_D_ID, @MYUSER, @CURDTTM, @I_D_SCOPE, @I_D_SCOPE_ID, default
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('D_SCOPE_ID'), @D_D_SCOPE_ID)
      END

      IF (@TP = 'D' AND @D_D_STS IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALC(@D_D_STS, @I_D_STS) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE  'U', 'D', @I_D_ID, @MYUSER, @CURDTTM, @I_D_SCOPE, @I_D_SCOPE_ID, default
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('D_STS'), @D_D_STS)
      END

      IF (@TP = 'D' AND @D_D_CTGR IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALC(@D_D_CTGR, @I_D_CTGR) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE  'U', 'D', @I_D_ID, @MYUSER, @CURDTTM, @I_D_SCOPE, @I_D_SCOPE_ID, default
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('D_CTGR'), @D_D_CTGR)
      END

      IF (@TP = 'D' AND @D_D_Desc IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALC(@D_D_Desc, @I_D_Desc) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE  'U', 'D', @I_D_ID, @MYUSER, @CURDTTM, @I_D_SCOPE, @I_D_SCOPE_ID, default
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('D_Desc'), @D_D_Desc)
      END

      IF (@TP = 'D' AND @D_D_UTSTMP IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALD(@D_D_UTSTMP, @I_D_UTSTMP) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE  'U', 'D', @I_D_ID, @MYUSER, @CURDTTM, @I_D_SCOPE, @I_D_SCOPE_ID, default
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('D_UTSTMP'), @D_D_UTSTMP)
      END

      IF (@TP = 'D' AND @D_D_UU IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALC(@D_D_UU, @I_D_UU) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE  'U', 'D', @I_D_ID, @MYUSER, @CURDTTM, @I_D_SCOPE, @I_D_SCOPE_ID, default
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('D_UU'), @D_D_UU)
      END

      IF (@TP = 'D' AND @D_C_ID IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALN(@D_C_ID, @I_C_ID) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE  'U', 'D', @I_D_ID, @MYUSER, @CURDTTM, @I_D_SCOPE, @I_D_SCOPE_ID, default
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('C_ID'), @D_C_ID)
      END

      IF (@TP = 'D' AND @D_E_ID IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALN(@D_E_ID, @I_E_ID) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE  'U', 'D', @I_D_ID, @MYUSER, @CURDTTM, @I_D_SCOPE, @I_D_SCOPE_ID, default
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('E_ID'), @D_E_ID)
      END


    END  /* END OF "IF @TP='U' OR @TP='D'"  */


	/******************************************/
	/****** SPECIAL BACK ACTION - BEGIN  ******/
	/******************************************/

    IF (@TP='U' AND @MY_AUD_SEQ <> 0)
	BEGIN
 	  if ({{schema}}.NONEQUALD(@D_D_SYNCTstmp, @I_D_SYNCTstmp) <= 0)
        UPDATE {{schema}}.D
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
ALTER TABLE [jsharmony].[d] ENABLE TRIGGER [D_IUD]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE trigger [jsharmony].[GCOD2_D_SCOPE_D_CTGR_IUD] on [jsharmony].[gcod2_d_scope_d_ctgr]
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
  
  SET @CURDTTM = {{schema}}.myNOW_DO()
  SET @CURDT = {{schema}}.myTODATE(@CURDTTM)
  SET @CURDTTM_CHAR = CONVERT(NVARCHAR, @CURDTTM, 120)+'.0000000'
  SET @MYUSER = {{schema}}.myCUSER() 

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
      UPDATE {{schema}}.GCOD2_D_SCOPE_D_CTGR
	     SET cod_etstmp = @CURDTTM,
			 cod_eu = @MYUSER,
		     cod_mtstmp = @CURDTTM,
			 cod_mu = @MYUSER
       WHERE GCOD2_D_SCOPE_D_CTGR.GCOD2_ID = @I_GCOD2_ID;
    END  

	/******************************************/
	/****** SPECIAL FRONT ACTION - END   ******/
	/******************************************/


    SET @MY_AUD_SEQ = 0
	IF (@TP='I' OR @TP='D')
	BEGIN  
	  SET @WK_GCOD2_ID = ISNULL(@D_GCOD2_ID,@I_GCOD2_ID)
	  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE @TP, 'GCOD2_D_SCOPE_D_CTGR', @WK_GCOD2_ID, @MYUSER, @CURDTTM
	END

 
    IF @TP='U' OR @TP='D'
	BEGIN

      IF (@TP = 'D' AND @D_CODSEQ IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALN(@D_CODSEQ, @I_CODSEQ) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE 'U', 'GCOD2_D_SCOPE_D_CTGR', @I_GCOD2_ID, @MYUSER, @CURDTTM
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('CODSEQ'), @D_CODSEQ)
      END

      IF (@TP = 'D' AND @D_CODETDT IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALD(@D_CODETDT, @I_CODETDT) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE 'U', 'GCOD2_D_SCOPE_D_CTGR', @I_GCOD2_ID, @MYUSER, @CURDTTM
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('CODETDT'), @D_CODETDT)
      END

      IF (@TP = 'D' AND @D_CODEVAL1 IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALC(@D_CODEVAL1, @I_CODEVAL1) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE 'U', 'GCOD2_D_SCOPE_D_CTGR', @I_GCOD2_ID, @MYUSER, @CURDTTM
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('CODEVAL1'), @D_CODEVAL1)
      END

      IF (@TP = 'D' AND @D_CODEVAL2 IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALC(@D_CODEVAL2, @I_CODEVAL2) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE 'U', 'GCOD2_D_SCOPE_D_CTGR', @I_GCOD2_ID, @MYUSER, @CURDTTM
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('CODEVAL2'), @D_CODEVAL2)
      END

      IF (@TP = 'D' AND @D_CODETXT IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALC(@D_CODETXT, @I_CODETXT) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE 'U', 'GCOD2_D_SCOPE_D_CTGR', @I_GCOD2_ID, @MYUSER, @CURDTTM
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('CODETXT'), @D_CODETXT)
      END

      IF (@TP = 'D' AND @D_CODECODE IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALC(@D_CODECODE, @I_CODECODE) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE 'U', 'GCOD2_D_SCOPE_D_CTGR', @I_GCOD2_ID, @MYUSER, @CURDTTM
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('CODECODE'), @D_CODECODE)
      END

      IF (@TP = 'D' AND @D_CODEATTRIB IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALC(@D_CODEATTRIB, @I_CODEATTRIB) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE 'U', 'GCOD2_D_SCOPE_D_CTGR', @I_GCOD2_ID, @MYUSER, @CURDTTM
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('CODEATTRIB'), @D_CODEATTRIB)
      END

      IF (@TP = 'D' AND @D_CODETCM IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALC(@D_CODETCM, @I_CODETCM) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE 'U', 'GCOD2_D_SCOPE_D_CTGR', @I_GCOD2_ID, @MYUSER, @CURDTTM
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('CODETCM'), @D_CODETCM)
      END

    END  /* END OF "IF @TP='U' OR @TP='D'"  */


	/******************************************/
	/****** SPECIAL BACK ACTION - BEGIN  ******/
	/******************************************/

    IF (@TP='U' AND @MY_AUD_SEQ <> 0)
	BEGIN
      UPDATE {{schema}}.GCOD2_D_SCOPE_D_CTGR
	     SET cod_mtstmp = @CURDTTM,
			 cod_mu = @MYUSER
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
ALTER TABLE [jsharmony].[gcod2_d_scope_d_ctgr] ENABLE TRIGGER [GCOD2_D_SCOPE_D_CTGR_IUD]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE trigger [jsharmony].[GPP_IUD] on [jsharmony].[gpp]
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

  SET @CURDTTM = {{schema}}.myNOW_DO()
  SET @CURDTTM_CHAR = CONVERT(NVARCHAR, @CURDTTM, 120)+'.0000000'
  SET @MYUSER = {{schema}}.myCUSER() 

  IF @TP = 'U' AND UPDATE(GPP_ID)
  BEGIN
    raiserror('Cannot update identity',16,1)
	ROLLBACK TRANSACTION
    return
  END

  if(@TP = 'I')
  BEGIN
  
    update {{schema}}.GPP set
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
        SET @ERRTXT = {{schema}}.CHECK_PP('GPP',@I_GPP_PROCESS,@I_GPP_ATTRIB,@I_GPP_VAL)
        IF @ERRTXT IS NOT null  
        BEGIN
          raiserror(@ERRTXT,16,1)
	      ROLLBACK TRANSACTION
          return
        END
      END

	  SET @WK_ID = ISNULL(@I_GPP_ID,@D_GPP_ID)
	  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE @TP, 'GPP', @WK_ID, @MYUSER, @CURDTTM

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
          SET @ERRTXT = {{schema}}.CHECK_PP('GPP',@I_GPP_PROCESS,@I_GPP_ATTRIB,@I_GPP_VAL)
          IF @ERRTXT IS NOT null  
          BEGIN
            raiserror(@ERRTXT,16,1)
	        ROLLBACK TRANSACTION
            return
          END
        END


      END

	  SET @WK_ID = ISNULL(@I_GPP_ID,@D_GPP_ID)
	  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE @TP, 'GPP', @WK_ID, @MYUSER, @CURDTTM
            
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
ALTER TABLE [jsharmony].[gpp] ENABLE TRIGGER [GPP_IUD]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE trigger [jsharmony].[H_IUD] on [jsharmony].[h]
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
  
  SET @CURDTTM = {{schema}}.myNOW_DO()
  SET @CURDT = {{schema}}.myTODATE(@CURDTTM)
  SET @CURDTTM_CHAR = CONVERT(NVARCHAR, @CURDTTM, 120)+'.0000000'
  SET @MYUSER = {{schema}}.myCUSER() 

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
      UPDATE {{schema}}.H
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
	  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE @TP, 'H', @WK_H_ID, @MYUSER, @CURDTTM
	END

 
    IF @TP='U' OR @TP='D'
	BEGIN

      IF (@TP = 'D' AND @D_HP_CODE IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALC(@D_HP_CODE, @I_HP_CODE) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE 'U', 'H', @I_H_ID, @MYUSER, @CURDTTM
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('HP_CODE'), @D_HP_CODE)
      END

      IF (@TP = 'D' AND @D_H_TITLE IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALC(@D_H_TITLE, @I_H_TITLE) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE 'U', 'H', @I_H_ID, @MYUSER, @CURDTTM
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('H_TITLE'), @D_H_TITLE)
      END

      IF (@TP = 'D' AND @D_H_TEXT IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALC(@D_H_TEXT, @I_H_TEXT) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE 'U', 'H', @I_H_ID, @MYUSER, @CURDTTM
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('H_TEXT'), @D_H_TEXT)
      END

      IF (@TP = 'D' AND @D_H_SEQ IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALN(@D_H_SEQ, @I_H_SEQ) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE 'U', 'H', @I_H_ID, @MYUSER, @CURDTTM
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('H_SEQ'), @D_H_SEQ)
      END

      IF (@TP = 'D' AND @D_H_INDEX_A IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALN(@D_H_INDEX_A, @I_H_INDEX_A) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE 'U', 'H', @I_H_ID, @MYUSER, @CURDTTM
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('H_INDEX_A'), @D_H_INDEX_A)
      END

      IF (@TP = 'D' AND @D_H_INDEX_P IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALN(@D_H_INDEX_P, @I_H_INDEX_P) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE 'U', 'H', @I_H_ID, @MYUSER, @CURDTTM
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('H_INDEX_P'), @D_H_INDEX_P)
      END

    END  /* END OF "IF @TP='U' OR @TP='D'"  */


	/******************************************/
	/****** SPECIAL BACK ACTION - BEGIN  ******/
	/******************************************/

    IF (@TP='U' AND @MY_AUD_SEQ <> 0)
	BEGIN
      UPDATE {{schema}}.H
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
ALTER TABLE [jsharmony].[h] ENABLE TRIGGER [H_IUD]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE trigger [jsharmony].[N_IUD] on [jsharmony].[n]
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

  DECLARE @SQLCMD nvarchar(max)
  DECLARE @GETCID nvarchar(max)
  DECLARE @GETEID nvarchar(max)

  DECLARE @C_ID BIGINT = NULL;
  DECLARE @E_ID BIGINT = NULL;

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
  
  SET @CURDTTM = {{schema}}.myNOW_DO()
  SET @CURDTTM_CHAR = CONVERT(NVARCHAR, @CURDTTM, 120)+'.0000000'
  SET @MYUSER = {{schema}}.myCUSER() 

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
		@TP='U' AND ({{schema}}.nonequalc(@D_N_SCOPE, @I_N_SCOPE)>0
		             OR
					 {{schema}}.nonequaln(@D_N_SCOPE_ID, @I_N_SCOPE_ID)>0))
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

    IF (@TP='I')
	BEGIN

      UPDATE {{schema}}.N
	     SET C_ID = NULL,
		     E_ID = NULL,
		     N_ETstmp = @CURDTTM,
			 N_EU = @MYUSER,
		     N_MTstmp = @CURDTTM,
			 N_MU = @MYUSER
         WHERE N.N_ID = @I_N_ID;

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
	  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE @TP, 'N', @WK_N_ID, @MYUSER, @CURDTTM, @WK_REF_NAME, @WK_REF_ID, default
	END

 
    IF @TP='U' OR @TP='D'
	BEGIN

      IF (@TP = 'D' AND @D_N_SCOPE IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALC(@D_N_SCOPE, @I_N_SCOPE) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE  'U', 'N', @I_N_ID, @MYUSER, @CURDTTM, @I_N_SCOPE, @I_N_SCOPE_ID, default
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('N_SCOPE'), @D_N_SCOPE)
      END

      IF (@TP = 'D' AND @D_N_SCOPE_ID IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALN(@D_N_SCOPE_ID, @I_N_SCOPE_ID) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE  'U', 'N', @I_N_ID, @MYUSER, @CURDTTM, @I_N_SCOPE, @I_N_SCOPE_ID, default
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('N_SCOPE_ID'), @D_N_SCOPE_ID)
      END

      IF (@TP = 'D' AND @D_N_STS IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALC(@D_N_STS, @I_N_STS) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE  'U', 'N', @I_N_ID, @MYUSER, @CURDTTM, @I_N_SCOPE, @I_N_SCOPE_ID, default
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('N_STS'), @D_N_STS)
      END

      IF (@TP = 'D' AND @D_N_TYPE IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALC(@D_N_TYPE, @I_N_TYPE) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE  'U', 'N', @I_N_ID, @MYUSER, @CURDTTM, @I_N_SCOPE, @I_N_SCOPE_ID, default
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('N_TYPE'), @D_N_TYPE)
      END

      IF (@TP = 'D' AND @D_N_Note IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALC(@D_N_Note, @I_N_Note) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE  'U', 'N', @I_N_ID, @MYUSER, @CURDTTM, @I_N_SCOPE, @I_N_SCOPE_ID, default
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('N_Note'), @D_N_Note)
      END

	  IF (@TP = 'D' AND @D_C_ID IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALN(@D_C_ID, @I_C_ID) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE  'U', 'N', @I_N_ID, @MYUSER, @CURDTTM, @I_N_SCOPE, @I_N_SCOPE_ID, default
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('C_ID'), @D_C_ID)
      END

      IF (@TP = 'D' AND @D_E_ID IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALN(@D_E_ID, @I_E_ID) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE  'U', 'N', @I_N_ID, @MYUSER, @CURDTTM, @I_N_SCOPE, @I_N_SCOPE_ID, default
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('E_ID'), @D_E_ID)
      END


    END  /* END OF "IF @TP='U' OR @TP='D'"  */

	/******************************************/
	/****** SPECIAL BACK ACTION - BEGIN  ******/
	/******************************************/

    IF (@TP='U' AND @MY_AUD_SEQ <> 0)
	BEGIN
        UPDATE {{schema}}.N
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
ALTER TABLE [jsharmony].[n] ENABLE TRIGGER [N_IUD]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE trigger [jsharmony].[PE_IUD] on [jsharmony].[pe]
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
  
  SET @CURDTTM = {{schema}}.myNOW_DO()
  SET @CURDTTM_CHAR = CONVERT(NVARCHAR, @CURDTTM, 120)+'.0000000'
  SET @MYUSER = {{schema}}.myCUSER() 

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
	  
	  if ({{schema}}.EXISTS_D('PE', @D_PE_ID) > 0)
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
	  if ({{schema}}.NONEQUALC(@I_PE_PW1, @I_PE_PW2) > 0)
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

	  set @hash = {{schema}}.myHASH('S', @I_PE_ID, @NEWPW);

	  if (@hash is null)
      BEGIN
        CLOSE CUR_PE_IUD
        DEALLOCATE CUR_PE_IUD
        SET @M = 'Application Error - Missing or Incorrect Password'
        raiserror(@M,16,1)
        ROLLBACK TRANSACTION
        return
      END

      UPDATE {{schema}}.PE
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
	  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE @TP, 'PE', @WK_PE_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ
	END
 
    IF @TP='U' OR @TP='D'
	BEGIN

      IF (@TP = 'D' AND @D_PE_STS IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALC(@D_PE_STS, @I_PE_STS) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE 'U', 'PE', @I_PE_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('PE_STS'), @D_PE_STS)
      END

      IF (@TP = 'D' AND @D_PE_FName IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALC(@D_PE_FName, @I_PE_FName) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE 'U', 'PE', @I_PE_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('PE_FName'), @D_PE_FName)
      END

      IF (@TP = 'D' AND @D_PE_MName IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALC(@D_PE_MName, @I_PE_MName) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE 'U', 'PE', @I_PE_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('PE_MName'), @D_PE_MName)
      END

      IF (@TP = 'D' AND @D_PE_LName IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALC(@D_PE_LName, @I_PE_LName) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE 'U', 'PE', @I_PE_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('PE_LName'), @D_PE_LName)
      END

      IF (@TP = 'D' AND @D_PE_JTitle IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALC(@D_PE_JTitle, @I_PE_JTitle) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE 'U', 'PE', @I_PE_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('PE_JTitle'), @D_PE_JTitle)
      END

      IF (@TP = 'D' AND @D_PE_BPhone IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALC(@D_PE_BPhone, @I_PE_BPhone) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE 'U', 'PE', @I_PE_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('PE_BPhone'), @D_PE_BPhone)
      END

      IF (@TP = 'D' AND @D_PE_CPhone IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALC(@D_PE_CPhone, @I_PE_CPhone) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE 'U', 'PE', @I_PE_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('PE_CPhone'), @D_PE_CPhone)
      END

      IF (@TP = 'D' AND @D_PE_Email IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALC(@D_PE_Email, @I_PE_Email) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE 'U', 'PE', @I_PE_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('PE_Email'), @D_PE_Email)
      END

      IF (@TP = 'D' AND @D_PE_LL_TSTMP IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALD(@D_PE_LL_TSTMP, @I_PE_LL_TSTMP) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE 'U', 'PE', @I_PE_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('PE_LL_TSTMP'), @D_PE_LL_TSTMP)
      END

	  IF (@TP = 'U' AND isnull(@NEWPW,'') <> '')
	  BEGIN
		set @hash = {{schema}}.myHASH('S', @I_PE_ID, @NEWPW);

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
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE 'U', 'PE', @I_PE_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('PE_PW'), '*')

	    SET @UPDATE_PW = 'Y'
	  END


    END  /* END OF "IF @TP='U' OR @TP='D'"  */


	/******************************************/
	/****** SPECIAL BACK ACTION - BEGIN  ******/
	/******************************************/

    IF (@TP='U' AND @MY_AUD_SEQ <> 0)
	BEGIN
      UPDATE {{schema}}.PE
	     SET PE_STSDt = CASE WHEN {{schema}}.NONEQUALC(@D_PE_STS, @I_PE_STS) > 0 THEN @CURDTTM ELSE PE_STSDt END,
		     PE_MTstmp = @CURDTTM,
			 PE_MU = @MYUSER,
			 PE_Hash = case @UPDATE_PW when 'Y' then @hash else PE_Hash end,
			 PE_PW1 = NULL,
			 PE_PW2 = NULL
       WHERE PE.PE_ID = @I_PE_ID;
    END  
    ELSE IF (@TP='U' AND (@I_PE_PW1 is not null or @I_PE_PW2 is not null))
	BEGIN
      UPDATE {{schema}}.PE
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
ALTER TABLE [jsharmony].[pe] ENABLE TRIGGER [PE_IUD]
GO
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
  
  SET @MYGETDATE = {{schema}}.myNOW()

  SET @MYUSER = {{schema}}.myCUSER() 

  if(@TP = 'I')
  BEGIN
  
    update {{schema}}.PPD set
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
      update {{schema}}.PPD set
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

  SET @CURDTTM = {{schema}}.myNOW_DO()
  SET @CURDTTM_CHAR = CONVERT(NVARCHAR, @CURDTTM, 120)+'.0000000'
  SET @MYUSER = {{schema}}.myCUSER() 

  IF @TP = 'U' AND UPDATE(PPP_ID)
  BEGIN
    raiserror('Cannot update identity',16,1)
	ROLLBACK TRANSACTION
    return
  END

  if(@TP = 'I')
  BEGIN
  
    update {{schema}}.PPP set
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
        SET @ERRTXT = {{schema}}.CHECK_PP('PPP',@I_PPP_PROCESS,@I_PPP_ATTRIB,@I_PPP_VAL)
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
	  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE @TP, 'PPP', @WK_ID, @MYUSER, @CURDTTM

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
      update {{schema}}.PPP set
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
          SET @ERRTXT = {{schema}}.CHECK_PP('PPP',@I_PPP_PROCESS,@I_PPP_ATTRIB,@I_PPP_VAL)
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
	  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE @TP, 'PPP', @WK_ID, @MYUSER, @CURDTTM
            
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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE trigger [jsharmony].[SPEF_IUD] on [jsharmony].[spef]
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
  
  SET @CURDTTM = {{schema}}.myNOW_DO()
  SET @CURDTTM_CHAR = CONVERT(NVARCHAR, @CURDTTM, 120)+'.0000000'
  SET @MYUSER = {{schema}}.myCUSER() 

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
	  FROM {{schema}}.PE
     WHERE PE_ID = @I_PE_ID; 

	/******************************************/
	/****** SPECIAL FRONT ACTION - END   ******/
	/******************************************/

    SET @MY_AUD_SEQ = 0
	IF (@TP='I' OR @TP='D')
	BEGIN  
	  SET @WK_SPEF_ID = ISNULL(@D_SPEF_ID,@I_SPEF_ID)
	  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE @TP, 'SPEF', @WK_SPEF_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ
	END

    IF @TP='U' OR @TP='D'
	BEGIN

      IF (@TP = 'D' AND @D_PE_ID IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALN(@D_PE_ID, @I_PE_ID) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE 'U', 'SPEF', @I_SPEF_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('PE_ID'), @D_PE_ID)
      END

      IF (@TP = 'D' AND @D_SF_NAME IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALC(@D_SF_NAME, @I_SF_NAME) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE 'U', 'SPEF', @I_SPEF_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('SF_NAME'), @D_SF_NAME)
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
ALTER TABLE [jsharmony].[spef] ENABLE TRIGGER [SPEF_IUD]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE trigger [jsharmony].[SPER_IUD] on [jsharmony].[sper]
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

  DECLARE @MY_PE_ID BIGINT = {{schema}}.mype()

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
  
  SET @CURDTTM = {{schema}}.myNOW_DO()
  SET @CURDTTM_CHAR = CONVERT(NVARCHAR, @CURDTTM, 120)+'.0000000'
  SET @MYUSER = {{schema}}.myCUSER() 

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
                           from {{schema}}.V_MY_ROLES
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
	  FROM {{schema}}.PE
     WHERE PE_ID = @I_PE_ID; 

	/******************************************/
	/****** SPECIAL FRONT ACTION - END   ******/
	/******************************************/

    SET @MY_AUD_SEQ = 0
	IF (@TP='I' OR @TP='D')
	BEGIN  
	  SET @WK_SPER_ID = ISNULL(@D_SPER_ID,@I_SPER_ID)
	  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE @TP, 'SPER', @WK_SPER_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ
	END

    IF @TP='U' OR @TP='D'
	BEGIN

      IF (@TP = 'D' AND @D_PE_ID IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALN(@D_PE_ID, @I_PE_ID) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE 'U', 'SPER', @I_SPER_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('PE_ID'), @D_PE_ID)
      END

      IF (@TP = 'D' AND @D_SR_NAME IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALC(@D_SR_NAME, @I_SR_NAME) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE 'U', 'SPER', @I_SPER_ID, @MYUSER, @CURDTTM,default,default,@WK_SUBJ
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('SR_NAME'), @D_SR_NAME)
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
ALTER TABLE [jsharmony].[sper] ENABLE TRIGGER [SPER_IUD]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE trigger [jsharmony].[TXT_IUD] on [jsharmony].[txt]
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
  
  SET @CURDTTM = {{schema}}.myNOW_DO()
  SET @CURDT = {{schema}}.myTODATE(@CURDTTM)
  SET @CURDTTM_CHAR = CONVERT(NVARCHAR, @CURDTTM, 120)+'.0000000'
  SET @MYUSER = {{schema}}.myCUSER() 

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
      UPDATE {{schema}}.TXT
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
	  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE @TP, 'TXT', @WK_TXT_ID, @MYUSER, @CURDTTM
	END

 
    IF @TP='U' OR @TP='D'
	BEGIN

      IF (@TP = 'D' AND @D_TXT_PROCESS IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALC(@D_TXT_PROCESS, @I_TXT_PROCESS) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE 'U', 'TXT', @I_TXT_ID, @MYUSER, @CURDTTM
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('TXT_PROCESS'), @D_TXT_PROCESS)
      END

      IF (@TP = 'D' AND @D_TXT_ATTRIB IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALC(@D_TXT_ATTRIB, @I_TXT_ATTRIB) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE 'U', 'TXT', @I_TXT_ID, @MYUSER, @CURDTTM
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('TXT_ATTRIB'), @D_TXT_ATTRIB)
      END
	  
      IF (@TP = 'D' AND @D_TXT_TYPE IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALC(@D_TXT_TYPE, @I_TXT_TYPE) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE 'U', 'TXT', @I_TXT_ID, @MYUSER, @CURDTTM
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('TXT_TYPE'), @D_TXT_TYPE)
      END

      IF (@TP = 'D' AND @D_TXT_TVAL IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALC(@D_TXT_TVAL, @I_TXT_TVAL) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE 'U', 'TXT', @I_TXT_ID, @MYUSER, @CURDTTM
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('TXT_TVAL'), @D_TXT_TVAL)
      END

      IF (@TP = 'D' AND @D_TXT_VAL IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALC(@D_TXT_VAL, @I_TXT_VAL) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE 'U', 'TXT', @I_TXT_ID, @MYUSER, @CURDTTM
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('TXT_VAL'), @D_TXT_VAL)
      END

      IF (@TP = 'D' AND @D_TXT_BCC IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALC(@D_TXT_BCC, @I_TXT_BCC) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE 'U', 'TXT', @I_TXT_ID, @MYUSER, @CURDTTM
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('TXT_BCC'), @D_TXT_BCC)
      END

      IF (@TP = 'D' AND @D_TXT_DESC IS NOT NULL OR
          @TP = 'U' AND {{schema}}.NONEQUALC(@D_TXT_DESC, @I_TXT_DESC) > 0)
      BEGIN
        IF (@MY_AUD_SEQ=0)
		  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE 'U', 'TXT', @I_TXT_ID, @MYUSER, @CURDTTM
        INSERT INTO {{schema}}.AUD_D VALUES (@MY_AUD_SEQ, lower('TXT_DESC'), @D_TXT_DESC)
      END


    END  /* END OF "IF @TP='U' OR @TP='D'"  */


	/******************************************/
	/****** SPECIAL BACK ACTION - BEGIN  ******/
	/******************************************/

    IF (@TP='U' AND @MY_AUD_SEQ <> 0)
	BEGIN
      UPDATE {{schema}}.TXT
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
ALTER TABLE [jsharmony].[txt] ENABLE TRIGGER [TXT_IUD]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE trigger [jsharmony].[XPP_IUD] on [jsharmony].[xpp]
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

  SET @CURDTTM = {{schema}}.myNOW_DO()
  SET @CURDTTM_CHAR = CONVERT(NVARCHAR, @CURDTTM, 120)+'.0000000'
  SET @MYUSER = {{schema}}.myCUSER() 

  IF @TP = 'U' AND UPDATE(XPP_ID)
  BEGIN
    raiserror('Cannot update identity',16,1)
	ROLLBACK TRANSACTION
    return
  END

  if(@TP = 'I')
  BEGIN
  
    update {{schema}}.XPP set
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
      
      SET @ERRTXT = {{schema}}.CHECK_PP('XPP',@I_XPP_PROCESS,@I_XPP_ATTRIB,@I_XPP_VAL)
      
      IF @ERRTXT IS NOT null  
      BEGIN
        CLOSE CUR_XPP_I
        DEALLOCATE CUR_XPP_I
        raiserror(@ERRTXT,16,1)
	    ROLLBACK TRANSACTION
        return
      END

	  SET @WK_ID = ISNULL(@I_XPP_ID,@D_XPP_ID)
	  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE @TP, 'XPP', @WK_ID, @MYUSER, @CURDTTM

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
      update {{schema}}.XPP set
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
      
        SET @ERRTXT = {{schema}}.CHECK_PP('XPP',@I_XPP_PROCESS,@I_XPP_ATTRIB,@I_XPP_VAL)
       
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
	  EXEC	@MY_AUD_SEQ = {{schema}}.AUDH_BASE @TP, 'XPP', @WK_ID, @MYUSER, @CURDTTM
            
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
ALTER TABLE [jsharmony].[xpp] ENABLE TRIGGER [XPP_IUD]
GO
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

    delete from {{schema}}.CRM
	 where CRM_ID in (
	   select i.CRM_ID
	     from inserted i
        inner join deleted d on d.SM_ID=i.SM_ID
        where {{schema}}.NONEQUALN(d.CRMSEL_SEL, i.CRMSEL_SEL) > 0
		  and isnull(i.CRMSEL_SEL,0) = 0);

	 
    insert into {{schema}}.CRM (CR_NAME, SM_ID)
	   select i.NEW_CR_NAME, i.SM_ID
	     from inserted i
        inner join deleted d on d.SM_ID=i.SM_ID
        where {{schema}}.NONEQUALN(d.CRMSEL_SEL, i.CRMSEL_SEL) > 0
		  and isnull(i.CRMSEL_SEL,0) = 1
		  and isnull(i.NEW_CR_NAME,'')<>'';
	 
    insert into {{schema}}.CRM (CR_NAME, SM_ID)
	   select i.CR_NAME, i.NEW_SM_ID
	     from inserted i
        inner join deleted d on d.SM_ID=i.SM_ID
        where {{schema}}.NONEQUALN(d.CRMSEL_SEL, i.CRMSEL_SEL) > 0
		  and isnull(i.CRMSEL_SEL,0) = 1
		  and isnull(i.NEW_CR_NAME,'')='';
	 
  END
end



GO
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

    delete from {{schema}}.SRM
	 where SRM_ID in (
	   select i.SRM_ID
	     from inserted i
        inner join deleted d on d.SM_ID=i.SM_ID
        where {{schema}}.NONEQUALN(d.SRMSEL_SEL, i.SRMSEL_SEL) > 0
		  and isnull(i.SRMSEL_SEL,0) = 0);

	 
    insert into {{schema}}.SRM (SR_NAME, SM_ID)
	   select i.NEW_SR_NAME, i.SM_ID
	     from inserted i
        inner join deleted d on d.SM_ID=i.SM_ID
        where {{schema}}.NONEQUALN(d.SRMSEL_SEL, i.SRMSEL_SEL) > 0
		  and isnull(i.SRMSEL_SEL,0) = 1
		  and isnull(i.NEW_SR_NAME,'')<>'';
	 
    insert into {{schema}}.SRM (SR_NAME, SM_ID)
	   select i.SR_NAME, i.NEW_SM_ID
	     from inserted i
        inner join deleted d on d.SM_ID=i.SM_ID
        where {{schema}}.NONEQUALN(d.SRMSEL_SEL, i.SRMSEL_SEL) > 0
		  and isnull(i.SRMSEL_SEL,0) = 1
		  and isnull(i.NEW_SR_NAME,'')='';
	 
  END
end


GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_D', @level2type=N'COLUMN',@level2name=N'AUD_SEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_D', @level2type=N'COLUMN',@level2name=N'AUD_SEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_D', @level2type=N'COLUMN',@level2name=N'AUD_SEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_D', @level2type=N'COLUMN',@level2name=N'AUD_SEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_D', @level2type=N'COLUMN',@level2name=N'AUD_SEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Audit Trail Sequence - AUD_H' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_D', @level2type=N'COLUMN',@level2name=N'AUD_SEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=0x00 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_D', @level2type=N'COLUMN',@level2name=N'AUD_SEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_D', @level2type=N'COLUMN',@level2name=N'COLUMN_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_D', @level2type=N'COLUMN',@level2name=N'COLUMN_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_D', @level2type=N'COLUMN',@level2name=N'COLUMN_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_D', @level2type=N'COLUMN',@level2name=N'COLUMN_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_D', @level2type=N'COLUMN',@level2name=N'COLUMN_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Audit Trail Detail Column Name' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_D', @level2type=N'COLUMN',@level2name=N'COLUMN_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=0x00 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_D', @level2type=N'COLUMN',@level2name=N'COLUMN_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_D', @level2type=N'COLUMN',@level2name=N'COLUMN_VAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_D', @level2type=N'COLUMN',@level2name=N'COLUMN_VAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_D', @level2type=N'COLUMN',@level2name=N'COLUMN_VAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=4515 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_D', @level2type=N'COLUMN',@level2name=N'COLUMN_VAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_D', @level2type=N'COLUMN',@level2name=N'COLUMN_VAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Audit Trail Detail Previous Value' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_D', @level2type=N'COLUMN',@level2name=N'COLUMN_VAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=0x00 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_D', @level2type=N'COLUMN',@level2name=N'COLUMN_VAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Audit Trail Detail (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_D'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_SEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_SEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_SEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_SEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_SEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Audit Trail Sequence' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_SEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_SEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'TABLE_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'TABLE_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'TABLE_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=960 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'TABLE_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'TABLE_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Audit Trail Header Table Name' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'TABLE_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'TABLE_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'TABLE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'TABLE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'TABLE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'TABLE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'TABLE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Audit Trail Header ID Value' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'TABLE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'TABLE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_OP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_OP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_OP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_OP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_OP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Audit Trail Header Operation - DUI' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_OP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_OP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_U'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_U'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_U'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_U'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_U'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Audit Trail Header User Number' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_U'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_U'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_Tstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_Tstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_Tstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=3690 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_Tstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_Tstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Audit Trail Header Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_Tstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'AUD_Tstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Customer ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'C_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Equipment ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'E_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Reference Name' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'REF_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Reference ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'REF_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Subject' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H', @level2type=N'COLUMN',@level2name=N'SUBJ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Audit Trail Header (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'AUD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'IMD' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'NT', @value=N'N' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'TRIGGER', @value=N'Referential Integrity back to AC' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'C_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel Status - ACTIVE, HOLD, CLOSED - UCOD_AHC' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'NT', @value=N'N' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_STSDt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_STSDt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_STSDt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_STSDt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_STSDt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel Status Last Change Date' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_STSDt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_STSDt'
GO
EXEC sys.sp_addextendedproperty @name=N'TRIGGER', @value=N'Date' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_STSDt'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_FName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_FName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_FName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_FName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_FName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_FName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel First Name' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_FName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_FName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel Middle Name' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_MName'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_LName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_LName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_LName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_LName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_LName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_LName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel Last Name' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_LName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_LName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel Job Title' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_JTitle'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel Business Phone Number' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_BPhone'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel Cell Phone Number' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_CPhone'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_Email'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_Email'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_Email'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_Email'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_Email'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_Email'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel Email' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_Email'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_Email'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel Entry User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel Hash' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_Hash'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel last login IP' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_LL_IP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel last login timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_LL_Tstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel System Notes' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE', @level2type=N'COLUMN',@level2name=N'PE_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Customer Personnel (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPER', @level2type=N'COLUMN',@level2name=N'PE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel Role System Notes' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPER', @level2type=N'COLUMN',@level2name=N'CPER_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel Role ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPER', @level2type=N'COLUMN',@level2name=N'CPER_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role Name' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPER', @level2type=N'COLUMN',@level2name=N'CR_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Customer - Personnel Roles (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CPER'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'SIMD' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Role ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'NT', @value=N'' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Role Sequence' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_SEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Role Status COD(AHC) - ACTIVE, HOLD, CLOSED' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'NT', @value=N'N' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Role Name' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=4920 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Role Description' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Role System Notes' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CR', @level2type=N'COLUMN',@level2name=N'CR_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Customer - Roles (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Menu Item ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CRM', @level2type=N'COLUMN',@level2name=N'SM_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role Menu Item System Notes' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CRM', @level2type=N'COLUMN',@level2name=N'CRM_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role Menu Item ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CRM', @level2type=N'COLUMN',@level2name=N'CRM_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role Name' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CRM', @level2type=N'COLUMN',@level2name=N'CR_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Customer - Role Menu Items (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'CRM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'D', @level2type=N'COLUMN',@level2name=N'D_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document Scope - UCOD_D_SCOPE' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'D', @level2type=N'COLUMN',@level2name=N'D_SCOPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document Scope ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'D', @level2type=N'COLUMN',@level2name=N'D_SCOPE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client ID - C' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'D', @level2type=N'COLUMN',@level2name=N'C_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Employee ID - E' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'D', @level2type=N'COLUMN',@level2name=N'E_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document Status - UCOD_AC1' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'D', @level2type=N'COLUMN',@level2name=N'D_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document Category - GCOD2_D_SCOPE_D_CTGR' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'D', @level2type=N'COLUMN',@level2name=N'D_CTGR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document Description' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'D', @level2type=N'COLUMN',@level2name=N'D_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document Extension (file suffix)' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'D', @level2type=N'COLUMN',@level2name=N'D_EXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document Size in bytes' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'D', @level2type=N'COLUMN',@level2name=N'D_SIZE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document File Name' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'D', @level2type=N'COLUMN',@level2name=N'D_FileName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'D', @level2type=N'COLUMN',@level2name=N'D_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document Entry User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'D', @level2type=N'COLUMN',@level2name=N'D_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'D', @level2type=N'COLUMN',@level2name=N'D_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'D', @level2type=N'COLUMN',@level2name=N'D_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document Last Upload Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'D', @level2type=N'COLUMN',@level2name=N'D_UTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document Last Upload User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'D', @level2type=N'COLUMN',@level2name=N'D_UU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document Synchronization Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'D', @level2type=N'COLUMN',@level2name=N'D_SYNCTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document System Notes' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'D', @level2type=N'COLUMN',@level2name=N'D_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document Main ID (Synchronization)' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'D', @level2type=N'COLUMN',@level2name=N'D_ID_MAIN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Documents (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'D'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Table (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'DUAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Name' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=2 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=5565 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Description' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Code Description' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'CODECODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Attrib Description' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'CODEATTRIBMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=3 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=4 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Entry User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=5 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=6 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'cod_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'cod_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=7 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'cod_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'cod_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'cod_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header System Notes' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'cod_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H', @level2type=N'COLUMN',@level2name=N'cod_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User Codes Header (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_D_SCOPE_D_CTGR', @level2type=N'COLUMN',@level2name=N'GCOD2_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Sequence' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_D_SCOPE_D_CTGR', @level2type=N'COLUMN',@level2name=N'CODSEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_D_SCOPE_D_CTGR', @level2type=N'COLUMN',@level2name=N'CODEVAL1'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Description' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_D_SCOPE_D_CTGR', @level2type=N'COLUMN',@level2name=N'CODETXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Additional Code' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_D_SCOPE_D_CTGR', @level2type=N'COLUMN',@level2name=N'CODECODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Date' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_D_SCOPE_D_CTGR', @level2type=N'COLUMN',@level2name=N'CODETDT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Comment' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_D_SCOPE_D_CTGR', @level2type=N'COLUMN',@level2name=N'CODETCM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_D_SCOPE_D_CTGR', @level2type=N'COLUMN',@level2name=N'cod_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_D_SCOPE_D_CTGR', @level2type=N'COLUMN',@level2name=N'cod_eu'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_D_SCOPE_D_CTGR', @level2type=N'COLUMN',@level2name=N'cod_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_D_SCOPE_D_CTGR', @level2type=N'COLUMN',@level2name=N'cod_mu'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code System Notes' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_D_SCOPE_D_CTGR', @level2type=N'COLUMN',@level2name=N'cod_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User Codes 2 - Document Scope / Category' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_D_SCOPE_D_CTGR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Name' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=2 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=5565 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Description' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Code Description' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'CODECODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Attrib Description' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'CODEATTRIBMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=3 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=4 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Entry User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=5 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=6 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'cod_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'cod_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=7 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'cod_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'cod_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'cod_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header System Notes' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'cod_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H', @level2type=N'COLUMN',@level2name=N'cod_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User Codes 2 Header (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GCOD2_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'GPP Process Name' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GPP', @level2type=N'COLUMN',@level2name=N'GPP_PROCESS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'GPP Attribute (Parameter) Name' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GPP', @level2type=N'COLUMN',@level2name=N'GPP_ATTRIB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'GPP Attribute (Parameter) value' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GPP', @level2type=N'COLUMN',@level2name=N'GPP_VAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Process Parameters - Global (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'GPP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'H', @level2type=N'COLUMN',@level2name=N'H_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help Header Code' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'H', @level2type=N'COLUMN',@level2name=N'HP_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help Title' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'H', @level2type=N'COLUMN',@level2name=N'H_Title'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help Text' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'H', @level2type=N'COLUMN',@level2name=N'H_Text'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'H', @level2type=N'COLUMN',@level2name=N'H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help Entry User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'H', @level2type=N'COLUMN',@level2name=N'H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help Last Modification Entry' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'H', @level2type=N'COLUMN',@level2name=N'H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'H', @level2type=N'COLUMN',@level2name=N'H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help UNIQUE - not null HP_CODE unique' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'H', @level2type=N'COLUMN',@level2name=N'H_UNIQUE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help Sequence' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'H', @level2type=N'COLUMN',@level2name=N'H_SEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help - Show on Admin Index' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'H', @level2type=N'COLUMN',@level2name=N'H_INDEX_A'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help - Show on Portal Index' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'H', @level2type=N'COLUMN',@level2name=N'H_INDEX_P'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help Panel Code' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'HP', @level2type=N'COLUMN',@level2name=N'HP_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help Panel Description' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'HP', @level2type=N'COLUMN',@level2name=N'HP_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help Panel ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'HP', @level2type=N'COLUMN',@level2name=N'HP_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help Header (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'HP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Note ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'N', @level2type=N'COLUMN',@level2name=N'N_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Note Scope - UCOD_N_SCOPE' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'N', @level2type=N'COLUMN',@level2name=N'N_SCOPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Note Scope ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'N', @level2type=N'COLUMN',@level2name=N'N_SCOPE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Note Status - UCOD_AC1' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'N', @level2type=N'COLUMN',@level2name=N'N_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client ID - C' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'N', @level2type=N'COLUMN',@level2name=N'C_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Employee ID - E' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'N', @level2type=N'COLUMN',@level2name=N'E_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Note Type - UCOD_N_TYPE - C,S,U' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'N', @level2type=N'COLUMN',@level2name=N'N_TYPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Note NOTE' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'N', @level2type=N'COLUMN',@level2name=N'N_Note'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Note Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'N', @level2type=N'COLUMN',@level2name=N'N_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Note Entry User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'N', @level2type=N'COLUMN',@level2name=N'N_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Note Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'N', @level2type=N'COLUMN',@level2name=N'N_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Note Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'N', @level2type=N'COLUMN',@level2name=N'N_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Note System Notes' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'N', @level2type=N'COLUMN',@level2name=N'N_Snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Notes (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'N'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Table (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'NUMBERS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Status ACTIVE, HOLD, CLOSED - UCOD_AHC' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_STSDt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_STSDt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_STSDt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_STSDt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_STSDt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Status Last Change Date' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_STSDt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_STSDt'
GO
EXEC sys.sp_addextendedproperty @name=N'TRIGGER', @value=N'Date' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_STSDt'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_FName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_FName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_FName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_FName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_FName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_FName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel First Name' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_FName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_FName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Middle Name' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_MName'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_LName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_LName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_LName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_LName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_LName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_LName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Last Name' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_LName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_LName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Job Title' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_JTitle'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Business Phone Number' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_BPhone'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Cell Phone Number' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_CPhone'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel country - UCOD_COUNTRY' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_COUNTRY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel address' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel city' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_CITY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel state - UCOD2_COUNTRY_STATE' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_STATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel zip code' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_ZIP'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_EMAIL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_EMAIL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_EMAIL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_EMAIL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_EMAIL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_EMAIL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Email' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_EMAIL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_EMAIL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel start date' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_STARTDT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel end date' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_ENDDT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel user notes' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_UNOTES'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Entry User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Hash' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_Hash'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel last login IP' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_LL_IP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel last login timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_LL_Tstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel System Notes' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE', @level2type=N'COLUMN',@level2name=N'PE_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'PPD Process Name' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PPD', @level2type=N'COLUMN',@level2name=N'PPD_PROCESS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'PPD Attribute (Parameter) Name' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PPD', @level2type=N'COLUMN',@level2name=N'PPD_ATTRIB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'PPD Attribute (Parameter) Description' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PPD', @level2type=N'COLUMN',@level2name=N'PPD_DESC'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'PPD Attribute (Parameter) Type - UCOD_PPD_TYPE' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PPD', @level2type=N'COLUMN',@level2name=N'PPD_TYPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Process Parameters Dictionary (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PPD'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PPP', @level2type=N'COLUMN',@level2name=N'PE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'XPP Process Name' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PPP', @level2type=N'COLUMN',@level2name=N'PPP_PROCESS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'XPP Attribute (Parameter) Name' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PPP', @level2type=N'COLUMN',@level2name=N'PPP_ATTRIB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'XPP Attribute (Parameter) value' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PPP', @level2type=N'COLUMN',@level2name=N'PPP_VAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Process Parameters - Personal (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'PPP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Queue Request ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQ', @level2type=N'COLUMN',@level2name=N'RQ_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Queue Request Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQ', @level2type=N'COLUMN',@level2name=N'RQ_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Queue Request Entry User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQ', @level2type=N'COLUMN',@level2name=N'RQ_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Queue Request Queue Name' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQ', @level2type=N'COLUMN',@level2name=N'RQ_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Queue Request Message' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQ', @level2type=N'COLUMN',@level2name=N'RQ_MESSAGE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Queue Request Result - OK, ERROR' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQ', @level2type=N'COLUMN',@level2name=N'RQ_RSLT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Queue Request Result Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQ', @level2type=N'COLUMN',@level2name=N'RQ_RSLT_TStmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Queue Request Result User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQ', @level2type=N'COLUMN',@level2name=N'RQ_RSLT_U'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Queue Request System Notes' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQ', @level2type=N'COLUMN',@level2name=N'RQ_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Queue Request (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQST', @level2type=N'COLUMN',@level2name=N'RQST_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQST', @level2type=N'COLUMN',@level2name=N'RQST_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Entry User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQST', @level2type=N'COLUMN',@level2name=N'RQST_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Source - UCOD_RQST_SOURCE' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQST', @level2type=N'COLUMN',@level2name=N'RQST_SOURCE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Type - UCOD_RQST_ATYPE' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQST', @level2type=N'COLUMN',@level2name=N'RQST_ATYPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Name' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQST', @level2type=N'COLUMN',@level2name=N'RQST_ANAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Parameters' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQST', @level2type=N'COLUMN',@level2name=N'RQST_PARMS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Result - OK, ERROR' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQST', @level2type=N'COLUMN',@level2name=N'RQST_RSLT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Result Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQST', @level2type=N'COLUMN',@level2name=N'RQST_RSLT_TStmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Result User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQST', @level2type=N'COLUMN',@level2name=N'RQST_RSLT_U'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request System Notes' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQST', @level2type=N'COLUMN',@level2name=N'RQST_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQST'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Document ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQST_D', @level2type=N'COLUMN',@level2name=N'RQST_D_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQST_D', @level2type=N'COLUMN',@level2name=N'RQST_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Document Scope' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQST_D', @level2type=N'COLUMN',@level2name=N'D_SCOPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Document Scope ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQST_D', @level2type=N'COLUMN',@level2name=N'D_SCOPE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Document Category' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQST_D', @level2type=N'COLUMN',@level2name=N'D_CTGR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Document Description' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQST_D', @level2type=N'COLUMN',@level2name=N'D_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request - Document (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQST_D'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Email ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQST_EMAIL', @level2type=N'COLUMN',@level2name=N'RQST_EMAIL_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQST_EMAIL', @level2type=N'COLUMN',@level2name=N'RQST_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Email SUBJECT' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQST_EMAIL', @level2type=N'COLUMN',@level2name=N'EMAIL_TXT_ATTRIB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Email TO' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQST_EMAIL', @level2type=N'COLUMN',@level2name=N'EMAIL_TO'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Email CC' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQST_EMAIL', @level2type=N'COLUMN',@level2name=N'EMAIL_CC'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Email BCC' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQST_EMAIL', @level2type=N'COLUMN',@level2name=N'EMAIL_BCC'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request - EMail (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQST_EMAIL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Note ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQST_N', @level2type=N'COLUMN',@level2name=N'RQST_N_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQST_N', @level2type=N'COLUMN',@level2name=N'RQST_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Note Scope' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQST_N', @level2type=N'COLUMN',@level2name=N'N_SCOPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Note Scope ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQST_N', @level2type=N'COLUMN',@level2name=N'N_SCOPE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Note Type' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQST_N', @level2type=N'COLUMN',@level2name=N'N_TYPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Note Note' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQST_N', @level2type=N'COLUMN',@level2name=N'N_Note'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request - Note (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQST_N'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Document ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQST_RQ', @level2type=N'COLUMN',@level2name=N'RQST_RQ_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQST_RQ', @level2type=N'COLUMN',@level2name=N'RQST_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request - RQ (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQST_RQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action SMS ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQST_SMS', @level2type=N'COLUMN',@level2name=N'RQST_SMS_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQST_SMS', @level2type=N'COLUMN',@level2name=N'RQST_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action SMS SUBJECT' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQST_SMS', @level2type=N'COLUMN',@level2name=N'SMS_TXT_ATTRIB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action SMS TO' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQST_SMS', @level2type=N'COLUMN',@level2name=N'SMS_TO'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request - SMS (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'RQST_SMS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Scripts (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SCRIPT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Function ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SF', @level2type=N'COLUMN',@level2name=N'SF_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Function Sequence' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SF', @level2type=N'COLUMN',@level2name=N'SF_SEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Function Status COD(AHC) - ACTIVE, HOLD, CLOSED' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SF', @level2type=N'COLUMN',@level2name=N'SF_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Function Name' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SF', @level2type=N'COLUMN',@level2name=N'SF_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Function Description' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SF', @level2type=N'COLUMN',@level2name=N'SF_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Function Code' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SF', @level2type=N'COLUMN',@level2name=N'SF_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Function Attrib' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SF', @level2type=N'COLUMN',@level2name=N'SF_ATTRIB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Function System Notes' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SF', @level2type=N'COLUMN',@level2name=N'SF_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Security - Functions (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SF'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Menu Item User Type - S-System, C-Customer' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_UTYPE'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'SIMD' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Menu Item ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'NT', @value=N'' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=2 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Menu Item Status COD(AHC) - ACTIVE, HOLD, CLOSED' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'NT', @value=N'N' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=4 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=2550 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Menu Item Name' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=5 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Menu Item Sequence' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Seq'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_DESC'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_DESC'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_DESC'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=6 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_DESC'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=3090 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_DESC'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_DESC'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Menu Item Description' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_DESC'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_DESC'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_DESCL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_DESCL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=7 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_DESCL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=4470 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_DESCL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_DESCL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Menu Item Description Long' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_DESCL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_DESCL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_DESCVL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_DESCVL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=8 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_DESCVL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=8370 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_DESCVL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_DESCVL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Menu Item Description Very Long' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_DESCVL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_DESCVL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Cmd'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Cmd'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=9 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Cmd'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Cmd'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Cmd'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Menu Item Command' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Cmd'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Cmd'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Image'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Image'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=10 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Image'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Image'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Image'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'For buttons as SMs: unique identifier for image' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Image'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_Image'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=11 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Menu Item System Notes' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM', @level2type=N'COLUMN',@level2name=N'SM_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Security - Menu Items (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SPEF', @level2type=N'COLUMN',@level2name=N'PE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Function System Notes' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SPEF', @level2type=N'COLUMN',@level2name=N'SPEF_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Function ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SPEF', @level2type=N'COLUMN',@level2name=N'SPEF_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Function Name' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SPEF', @level2type=N'COLUMN',@level2name=N'SF_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Security - Personnel Functions (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SPEF'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SPER', @level2type=N'COLUMN',@level2name=N'PE_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Role System Notes' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SPER', @level2type=N'COLUMN',@level2name=N'SPER_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Role ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SPER', @level2type=N'COLUMN',@level2name=N'SPER_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role Name' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SPER', @level2type=N'COLUMN',@level2name=N'SR_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Security - Personnel Roles (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SPER'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'SIMD' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'NT', @value=N'' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role Sequence' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_SEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role Status COD(AHC) - ACTIVE, HOLD, CLOSED' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'NT', @value=N'N' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role Name' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=4920 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role Description' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role Code' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role Attrib' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_ATTRIB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role System Notes' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SR', @level2type=N'COLUMN',@level2name=N'SR_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Security - Roles (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Menu Item ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SRM', @level2type=N'COLUMN',@level2name=N'SM_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role Menu Item System Notes' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SRM', @level2type=N'COLUMN',@level2name=N'SRM_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role Menu Item ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SRM', @level2type=N'COLUMN',@level2name=N'SRM_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role Name' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SRM', @level2type=N'COLUMN',@level2name=N'SR_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Security - Role Menu Items (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'SRM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_PROCESS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_PROCESS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_PROCESS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_PROCESS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_PROCESS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SPP Process Name' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_PROCESS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_PROCESS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_ATTRIB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_ATTRIB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_ATTRIB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_ATTRIB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_ATTRIB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SPP Attribute (Parameter) Name' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_ATTRIB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_ATTRIB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SPP Attribute (Parameter) Type HTML / TAXT - UCOD_TXT_TYPE' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_TYPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_TVAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_TVAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_TVAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=1350 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_TVAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_TVAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SPP Attribute (Parameter) Title' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_TVAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_TVAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_VAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_VAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_VAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=10110 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_VAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_VAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SPP Attribute (Parameter) value' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_VAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_VAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SPP BCC' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_BCC'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=525 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SPP Description' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_Desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SPP ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SPP Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SPP Entry User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SPP Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SPP Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT', @level2type=N'COLUMN',@level2name=N'TXT_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'String Process Parameters (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'TXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_AC', @level2type=N'COLUMN',@level2name=N'UCOD_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Sequence' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_AC', @level2type=N'COLUMN',@level2name=N'CODSEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_AC', @level2type=N'COLUMN',@level2name=N'CODEVAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Description' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_AC', @level2type=N'COLUMN',@level2name=N'CODETXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Additional Code' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_AC', @level2type=N'COLUMN',@level2name=N'CODECODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Date' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_AC', @level2type=N'COLUMN',@level2name=N'CODETDT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Comment' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_AC', @level2type=N'COLUMN',@level2name=N'CODETCM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_AC', @level2type=N'COLUMN',@level2name=N'cod_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_AC', @level2type=N'COLUMN',@level2name=N'cod_eu'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_AC', @level2type=N'COLUMN',@level2name=N'cod_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_AC', @level2type=N'COLUMN',@level2name=N'cod_mu'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code System Notes' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_AC', @level2type=N'COLUMN',@level2name=N'cod_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Codes - Active / Closed' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_AC'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_AC1', @level2type=N'COLUMN',@level2name=N'UCOD_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Sequence' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_AC1', @level2type=N'COLUMN',@level2name=N'CODSEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_AC1', @level2type=N'COLUMN',@level2name=N'CODEVAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Description' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_AC1', @level2type=N'COLUMN',@level2name=N'CODETXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Additional Code' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_AC1', @level2type=N'COLUMN',@level2name=N'CODECODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Date' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_AC1', @level2type=N'COLUMN',@level2name=N'CODETDT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Comment' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_AC1', @level2type=N'COLUMN',@level2name=N'CODETCM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_AC1', @level2type=N'COLUMN',@level2name=N'cod_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_AC1', @level2type=N'COLUMN',@level2name=N'cod_eu'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_AC1', @level2type=N'COLUMN',@level2name=N'cod_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_AC1', @level2type=N'COLUMN',@level2name=N'cod_mu'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code System Notes' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_AC1', @level2type=N'COLUMN',@level2name=N'cod_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Codes - A / C' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_AC1'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_AHC', @level2type=N'COLUMN',@level2name=N'UCOD_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Sequence' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_AHC', @level2type=N'COLUMN',@level2name=N'CODSEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_AHC', @level2type=N'COLUMN',@level2name=N'CODEVAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Description' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_AHC', @level2type=N'COLUMN',@level2name=N'CODETXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Additional Code' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_AHC', @level2type=N'COLUMN',@level2name=N'CODECODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Date' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_AHC', @level2type=N'COLUMN',@level2name=N'CODETDT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Comment' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_AHC', @level2type=N'COLUMN',@level2name=N'CODETCM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_AHC', @level2type=N'COLUMN',@level2name=N'cod_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_AHC', @level2type=N'COLUMN',@level2name=N'cod_eu'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_AHC', @level2type=N'COLUMN',@level2name=N'cod_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_AHC', @level2type=N'COLUMN',@level2name=N'cod_mu'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code System Notes' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_AHC', @level2type=N'COLUMN',@level2name=N'cod_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Codes - Active / Hold / Closed' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_AHC'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_COUNTRY', @level2type=N'COLUMN',@level2name=N'UCOD_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Sequence' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_COUNTRY', @level2type=N'COLUMN',@level2name=N'CODSEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_COUNTRY', @level2type=N'COLUMN',@level2name=N'CODEVAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Description' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_COUNTRY', @level2type=N'COLUMN',@level2name=N'CODETXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Additional Code' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_COUNTRY', @level2type=N'COLUMN',@level2name=N'CODECODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Date' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_COUNTRY', @level2type=N'COLUMN',@level2name=N'CODETDT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Comment' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_COUNTRY', @level2type=N'COLUMN',@level2name=N'CODETCM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_COUNTRY', @level2type=N'COLUMN',@level2name=N'cod_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_COUNTRY', @level2type=N'COLUMN',@level2name=N'cod_eu'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_COUNTRY', @level2type=N'COLUMN',@level2name=N'cod_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_COUNTRY', @level2type=N'COLUMN',@level2name=N'cod_mu'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code System Notes' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_COUNTRY', @level2type=N'COLUMN',@level2name=N'cod_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Codes - TOrder Payment Method' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_COUNTRY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_D_SCOPE', @level2type=N'COLUMN',@level2name=N'UCOD_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Sequence' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_D_SCOPE', @level2type=N'COLUMN',@level2name=N'CODSEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_D_SCOPE', @level2type=N'COLUMN',@level2name=N'CODEVAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Description' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_D_SCOPE', @level2type=N'COLUMN',@level2name=N'CODETXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Additional Code' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_D_SCOPE', @level2type=N'COLUMN',@level2name=N'CODECODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Date' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_D_SCOPE', @level2type=N'COLUMN',@level2name=N'CODETDT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Comment' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_D_SCOPE', @level2type=N'COLUMN',@level2name=N'CODETCM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_D_SCOPE', @level2type=N'COLUMN',@level2name=N'cod_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_D_SCOPE', @level2type=N'COLUMN',@level2name=N'cod_eu'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_D_SCOPE', @level2type=N'COLUMN',@level2name=N'cod_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_D_SCOPE', @level2type=N'COLUMN',@level2name=N'cod_mu'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code System Notes' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_D_SCOPE', @level2type=N'COLUMN',@level2name=N'cod_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Codes - Document Scope' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_D_SCOPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Name' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=2 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=5565 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Description' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=3 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=4 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Entry User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=5 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=6 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'cod_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'cod_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=7 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'cod_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'cod_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'cod_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header System Notes' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'cod_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H', @level2type=N'COLUMN',@level2name=N'cod_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Codes Header (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_N_SCOPE', @level2type=N'COLUMN',@level2name=N'UCOD_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Sequence' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_N_SCOPE', @level2type=N'COLUMN',@level2name=N'CODSEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_N_SCOPE', @level2type=N'COLUMN',@level2name=N'CODEVAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Description' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_N_SCOPE', @level2type=N'COLUMN',@level2name=N'CODETXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Additional Code' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_N_SCOPE', @level2type=N'COLUMN',@level2name=N'CODECODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Date' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_N_SCOPE', @level2type=N'COLUMN',@level2name=N'CODETDT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Comment' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_N_SCOPE', @level2type=N'COLUMN',@level2name=N'CODETCM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_N_SCOPE', @level2type=N'COLUMN',@level2name=N'cod_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_N_SCOPE', @level2type=N'COLUMN',@level2name=N'cod_eu'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_N_SCOPE', @level2type=N'COLUMN',@level2name=N'cod_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_N_SCOPE', @level2type=N'COLUMN',@level2name=N'cod_mu'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code System Notes' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_N_SCOPE', @level2type=N'COLUMN',@level2name=N'cod_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Codes - Note Scope' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_N_SCOPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_N_TYPE', @level2type=N'COLUMN',@level2name=N'UCOD_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Sequence' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_N_TYPE', @level2type=N'COLUMN',@level2name=N'CODSEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_N_TYPE', @level2type=N'COLUMN',@level2name=N'CODEVAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Description' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_N_TYPE', @level2type=N'COLUMN',@level2name=N'CODETXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Additional Code' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_N_TYPE', @level2type=N'COLUMN',@level2name=N'CODECODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Date' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_N_TYPE', @level2type=N'COLUMN',@level2name=N'CODETDT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Comment' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_N_TYPE', @level2type=N'COLUMN',@level2name=N'CODETCM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_N_TYPE', @level2type=N'COLUMN',@level2name=N'cod_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_N_TYPE', @level2type=N'COLUMN',@level2name=N'cod_eu'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_N_TYPE', @level2type=N'COLUMN',@level2name=N'cod_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_N_TYPE', @level2type=N'COLUMN',@level2name=N'cod_mu'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code System Notes' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_N_TYPE', @level2type=N'COLUMN',@level2name=N'cod_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Codes - Note Type' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_N_TYPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_PPD_TYPE', @level2type=N'COLUMN',@level2name=N'UCOD_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Sequence' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_PPD_TYPE', @level2type=N'COLUMN',@level2name=N'CODSEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_PPD_TYPE', @level2type=N'COLUMN',@level2name=N'CODEVAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Description' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_PPD_TYPE', @level2type=N'COLUMN',@level2name=N'CODETXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Additional Code' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_PPD_TYPE', @level2type=N'COLUMN',@level2name=N'CODECODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Date' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_PPD_TYPE', @level2type=N'COLUMN',@level2name=N'CODETDT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Comment' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_PPD_TYPE', @level2type=N'COLUMN',@level2name=N'CODETCM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_PPD_TYPE', @level2type=N'COLUMN',@level2name=N'cod_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_PPD_TYPE', @level2type=N'COLUMN',@level2name=N'cod_eu'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_PPD_TYPE', @level2type=N'COLUMN',@level2name=N'cod_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_PPD_TYPE', @level2type=N'COLUMN',@level2name=N'cod_mu'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code System Notes' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_PPD_TYPE', @level2type=N'COLUMN',@level2name=N'cod_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Codes - Process Parameter Type' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_PPD_TYPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_RQST_ATYPE', @level2type=N'COLUMN',@level2name=N'UCOD_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Sequence' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_RQST_ATYPE', @level2type=N'COLUMN',@level2name=N'CODSEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_RQST_ATYPE', @level2type=N'COLUMN',@level2name=N'CODEVAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Description' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_RQST_ATYPE', @level2type=N'COLUMN',@level2name=N'CODETXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Additional Code' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_RQST_ATYPE', @level2type=N'COLUMN',@level2name=N'CODECODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Date' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_RQST_ATYPE', @level2type=N'COLUMN',@level2name=N'CODETDT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Comment' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_RQST_ATYPE', @level2type=N'COLUMN',@level2name=N'CODETCM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_RQST_ATYPE', @level2type=N'COLUMN',@level2name=N'cod_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_RQST_ATYPE', @level2type=N'COLUMN',@level2name=N'cod_eu'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_RQST_ATYPE', @level2type=N'COLUMN',@level2name=N'cod_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_RQST_ATYPE', @level2type=N'COLUMN',@level2name=N'cod_mu'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code System Notes' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_RQST_ATYPE', @level2type=N'COLUMN',@level2name=N'cod_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Codes - Request Type (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_RQST_ATYPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_RQST_SOURCE', @level2type=N'COLUMN',@level2name=N'UCOD_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Sequence' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_RQST_SOURCE', @level2type=N'COLUMN',@level2name=N'CODSEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_RQST_SOURCE', @level2type=N'COLUMN',@level2name=N'CODEVAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Description' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_RQST_SOURCE', @level2type=N'COLUMN',@level2name=N'CODETXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Additional Code' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_RQST_SOURCE', @level2type=N'COLUMN',@level2name=N'CODECODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Date' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_RQST_SOURCE', @level2type=N'COLUMN',@level2name=N'CODETDT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Comment' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_RQST_SOURCE', @level2type=N'COLUMN',@level2name=N'CODETCM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_RQST_SOURCE', @level2type=N'COLUMN',@level2name=N'cod_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_RQST_SOURCE', @level2type=N'COLUMN',@level2name=N'cod_eu'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_RQST_SOURCE', @level2type=N'COLUMN',@level2name=N'cod_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_RQST_SOURCE', @level2type=N'COLUMN',@level2name=N'cod_mu'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code System Notes' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_RQST_SOURCE', @level2type=N'COLUMN',@level2name=N'cod_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Codes - Request Source (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_RQST_SOURCE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_TXT_TYPE', @level2type=N'COLUMN',@level2name=N'UCOD_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Sequence' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_TXT_TYPE', @level2type=N'COLUMN',@level2name=N'CODSEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_TXT_TYPE', @level2type=N'COLUMN',@level2name=N'CODEVAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Description' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_TXT_TYPE', @level2type=N'COLUMN',@level2name=N'CODETXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Additional Code' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_TXT_TYPE', @level2type=N'COLUMN',@level2name=N'CODECODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Date' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_TXT_TYPE', @level2type=N'COLUMN',@level2name=N'CODETDT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Comment' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_TXT_TYPE', @level2type=N'COLUMN',@level2name=N'CODETCM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_TXT_TYPE', @level2type=N'COLUMN',@level2name=N'cod_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_TXT_TYPE', @level2type=N'COLUMN',@level2name=N'cod_eu'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_TXT_TYPE', @level2type=N'COLUMN',@level2name=N'cod_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_TXT_TYPE', @level2type=N'COLUMN',@level2name=N'cod_mu'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code System Notes' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_TXT_TYPE', @level2type=N'COLUMN',@level2name=N'cod_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Codes - Text Type (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_TXT_TYPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_V_STS', @level2type=N'COLUMN',@level2name=N'UCOD_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Sequence' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_V_STS', @level2type=N'COLUMN',@level2name=N'CODSEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_V_STS', @level2type=N'COLUMN',@level2name=N'CODEVAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Description' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_V_STS', @level2type=N'COLUMN',@level2name=N'CODETXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Additional Code' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_V_STS', @level2type=N'COLUMN',@level2name=N'CODECODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Date' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_V_STS', @level2type=N'COLUMN',@level2name=N'CODETDT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Comment' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_V_STS', @level2type=N'COLUMN',@level2name=N'CODETCM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_V_STS', @level2type=N'COLUMN',@level2name=N'cod_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_V_STS', @level2type=N'COLUMN',@level2name=N'cod_eu'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_V_STS', @level2type=N'COLUMN',@level2name=N'cod_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_V_STS', @level2type=N'COLUMN',@level2name=N'cod_mu'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code System Notes' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_V_STS', @level2type=N'COLUMN',@level2name=N'cod_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Codes - Version Status' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD_V_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value ID' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_COUNTRY_STATE', @level2type=N'COLUMN',@level2name=N'UCOD2_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Sequence' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_COUNTRY_STATE', @level2type=N'COLUMN',@level2name=N'CODSEQ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_COUNTRY_STATE', @level2type=N'COLUMN',@level2name=N'CODEVAL1'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Description' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_COUNTRY_STATE', @level2type=N'COLUMN',@level2name=N'CODETXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Additional Code' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_COUNTRY_STATE', @level2type=N'COLUMN',@level2name=N'CODECODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Date' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_COUNTRY_STATE', @level2type=N'COLUMN',@level2name=N'CODETDT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Comment' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_COUNTRY_STATE', @level2type=N'COLUMN',@level2name=N'CODETCM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_COUNTRY_STATE', @level2type=N'COLUMN',@level2name=N'cod_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_COUNTRY_STATE', @level2type=N'COLUMN',@level2name=N'cod_eu'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_COUNTRY_STATE', @level2type=N'COLUMN',@level2name=N'cod_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_COUNTRY_STATE', @level2type=N'COLUMN',@level2name=N'cod_mu'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code System Notes' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_COUNTRY_STATE', @level2type=N'COLUMN',@level2name=N'cod_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Codes 2 - Country / State' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_COUNTRY_STATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Name' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'CODENAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=2 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=5565 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Description' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'CODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Code Description' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'CODECODEMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Attrib Description' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'CODEATTRIBMEAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=3 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=4 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Entry User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=5 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=6 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'COD_H_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'cod_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'cod_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=7 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'cod_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'cod_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'cod_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header System Notes' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'cod_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H', @level2type=N'COLUMN',@level2name=N'cod_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Codes 2 Header (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'UCOD2_H'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Version ID (internal)' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'V', @level2type=N'COLUMN',@level2name=N'V_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Version Component Name' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'V', @level2type=N'COLUMN',@level2name=N'V_COMP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Version Number - Major' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'V', @level2type=N'COLUMN',@level2name=N'V_NO_MAJOR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Version Number - Minor' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'V', @level2type=N'COLUMN',@level2name=N'V_NO_MINOR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Version Number - Build' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'V', @level2type=N'COLUMN',@level2name=N'V_NO_BUILD'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Version Number - Revision' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'V', @level2type=N'COLUMN',@level2name=N'V_NO_REV'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Version status - UCOD_V_STS' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'V', @level2type=N'COLUMN',@level2name=N'V_STS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Version Note' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'V', @level2type=N'COLUMN',@level2name=N'V_NOTE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Version entry date' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'V', @level2type=N'COLUMN',@level2name=N'V_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Version entry user' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'V', @level2type=N'COLUMN',@level2name=N'V_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Version last modification date' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'V', @level2type=N'COLUMN',@level2name=N'V_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Version last modification user' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'V', @level2type=N'COLUMN',@level2name=N'V_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Version System Notes' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'V', @level2type=N'COLUMN',@level2name=N'V_SNotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Versions (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'V'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_PROCESS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_PROCESS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_PROCESS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_PROCESS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_PROCESS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'XPP Process Name' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_PROCESS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=0x00 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_PROCESS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_ATTRIB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_ATTRIB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_ATTRIB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=2460 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_ATTRIB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_ATTRIB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'XPP Attribute (Parameter) Name' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_ATTRIB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=0x00 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_ATTRIB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_VAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_VAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_VAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=3975 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_VAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_VAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'XPP Attribute (Parameter) value' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_VAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=0x00 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_VAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=0x00 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_ETstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=0x00 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_EU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=0x00 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_MTstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=0x00 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_MU'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=0x00 , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP', @level2type=N'COLUMN',@level2name=N'XPP_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Process Parameters - System (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{{schema}}', @level1type=N'TABLE',@level1name=N'XPP'
GO



/****** Object:  View [jsharmony].[V_DL]    Script Date: 10/24/2018 12:14:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [jsharmony].[v_dl] AS
SELECT D.d_id
      ,D.d_scope
      ,D.d_scope_id
      ,D.c_id
      ,D.e_id
      ,D.d_sts
      ,D.d_ctgr
	    ,GDD.CODETXT d_ctgr_txt
      ,D.d_desc
      ,D.d_ext
      ,D.d_size
      ,D.d_filename
      ,D.d_etstmp
      ,D.d_eu
      ,{{schema}}.myCUSER_FMT(D_EU) d_eu_fmt
      ,D.d_mtstmp
      ,D.d_mu
      ,{{schema}}.myCUSER_FMT(D_MU) d_mu_fmt
      ,D.d_utstmp
      ,D.d_uu
      ,{{schema}}.myCUSER_FMT(D_UU) d_uu_fmt
      ,D.d_snotes
	    ,DUAL.DUAL_NVARCHAR50 title_h
	    ,DUAL.DUAL_NVARCHAR50 title_b
  FROM {{schema}}.D
  INNER JOIN {{schema}}.DUAL on 1=1
  LEFT OUTER JOIN  {{schema}}.GCOD2_D_SCOPE_D_CTGR GDD ON GDD.CODEVAL1 = D.D_SCOPE
                                             AND GDD.CODEVAL2 = D.D_CTGR   

GO


/****** Object:  View [dbo].[V_NL]    Script Date: 10/24/2018 12:27:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [jsharmony].[v_nl] as
SELECT N.n_id
      ,N.n_scope
      ,N.n_scope_id
	    ,n_sts
      ,N.c_id
	    ,DUAL.DUAL_NVARCHAR50 c_name
	    ,DUAL.DUAL_NVARCHAR50 c_name_ext
      ,N.e_id
	    ,DUAL.DUAL_NVARCHAR50 e_name
      ,N.n_type
      ,N.n_note
      ,{{schema}}.myTODATE(N.N_ETstmp) n_dt
      ,N.n_etstmp
      ,{{schema}}.myMMDDYYHHMI(N.N_ETstmp) n_etstmp_fmt
      ,N.n_eu
      ,{{schema}}.myCUSER_FMT(N.N_EU) n_eu_fmt
      ,N.n_mtstmp
      ,{{schema}}.myMMDDYYHHMI(N.N_MTstmp) n_mtstmp_fmt
      ,N.n_mu
      ,{{schema}}.myCUSER_FMT(N.N_MU) n_mu_fmt
      ,N.n_snotes
	    ,DUAL.DUAL_NVARCHAR50 title_h
	    ,DUAL.DUAL_NVARCHAR50 title_b
  FROM {{schema}}.N
  INNER JOIN {{schema}}.DUAL ON 1=1

GO

