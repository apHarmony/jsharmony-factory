CREATE ROLE [{schema}_role_exec]
GO
CREATE ROLE [{schema}_role_dev]
GO
ALTER ROLE [db_datareader] ADD MEMBER [{schema}_role_exec]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [{schema}_role_exec]
GO
ALTER ROLE [db_datareader] ADD MEMBER [{schema}_role_dev]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [{schema}_role_dev]
GO
GRANT CREATE TABLE TO [{schema}_role_dev] AS [dbo]
GO
/*
GRANT VIEW ANY COLUMN ENCRYPTION KEY DEFINITION TO [public] AS [dbo]
GRANT VIEW ANY COLUMN MASTER KEY DEFINITION TO [public] AS [dbo]
*/
CREATE SCHEMA [{schema}]
GO
GRANT ALTER ON SCHEMA::[{schema}] TO [{schema}_role_dev] AS [dbo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [{schema}].[log_audit_info] 
(@etstmp datetime2(7),
 @euser     nvarchar(max),
 @mtstmp datetime2(7),
 @muser     nvarchar(max))
RETURNS VARCHAR(MAX)
AS
BEGIN
  DECLARE @rslt nvarchar(max) = NULL

  SET @rslt =  'INFO'+char(13)+char(10)+ 
               '         Entered:  '+{schema}.my_mmddyyhhmi(@etstmp)+'  '+{schema}.my_db_user_fmt(@euser)+
               char(13)+char(10)+ 
               'Last Updated:  '+{schema}.my_mmddyyhhmi(@mtstmp)+'  '+{schema}.my_db_user_fmt(@muser); 

  RETURN @rslt
END


GO
GRANT EXECUTE ON [{schema}].[log_audit_info] TO [{schema}_role_exec] AS [dbo]
GRANT EXECUTE ON [{schema}].[log_audit_info] TO [{schema}_role_dev] AS [dbo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE FUNCTION [{schema}].[check_param]
(
    @in_table nvarchar(32),
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
DECLARE @param_type NVARCHAR(32)
DECLARE @code_name NVARCHAR(128)
DECLARE @is_param_app BIT
DECLARE @is_param_user BIT
DECLARE @is_param_sys BIT


  SELECT @rslt = NULL
  SELECT @param_type = NULL
  
  SELECT @param_type = param__tbl.param_type,
         @code_name = param__tbl.code_name,
         @is_param_app = param__tbl.is_param_app,
         @is_param_user = param__tbl.is_param_user,
         @is_param_sys = param__tbl.is_param_sys
    FROM {schema}.param__tbl
   WHERE param__tbl.param_process = @in_process
     AND param__tbl.param_attrib = @in_attrib      

  IF @param_type IS NULL
    RETURN 'Process parameter '+@in_process+'.'+@in_attrib+' is not defined in param__tbl'
  
  IF @in_table NOT IN ('param_app','param_user','param_sys')
    RETURN 'Table '+@in_table + ' is not defined'
 
  IF @in_table='param_app' AND @is_param_app=0
    RETURN 'Process parameter '+@in_process+'.'+@in_attrib+' is not assigned to '+@in_table
  ELSE IF @in_table='param_user' AND @is_param_user=0
    RETURN 'Process parameter '+@in_process+'.'+@in_attrib+' is not assigned to '+@in_table
  ELSE IF @in_table='param_sys' AND @is_param_sys=0
    RETURN 'Process parameter '+@in_process+'.'+@in_attrib+' is not assigned to '+@in_table

  IF ISNULL(@in_val,'') = ''
    RETURN 'Value has to be present'

  IF @param_type='N' AND ISNUMERIC(@in_val)=0
    RETURN 'Value '+@in_val+' is not numeric'

  IF ISNULL(@code_name,'') != ''
  BEGIN 
    select @c = count(*)
      from ucod
     where code_name = @code_name
       and code_val = @in_val 
       
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

CREATE FUNCTION [{schema}].[doc_filename]
(
    @in_doc_id bigint,
    @in_doc_ext NVARCHAR(MAX)
)    
RETURNS NVARCHAR(MAX)  
AS 
BEGIN
DECLARE @rslt NVARCHAR(MAX) = NULL

  SELECT @rslt = ('D'+CONVERT([varchar](50),@in_doc_id,(0)))+isnull(@in_doc_ext,'');

  RETURN (@rslt)

END

GO

GRANT EXECUTE ON {schema}.doc_filename TO {schema}_role_exec;
GO
GRANT EXECUTE ON {schema}.doc_filename TO {schema}_role_dev;
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [{schema}].[exists_doc]
(
    @tbl nvarchar(MAX),
    @id bigint
)    
RETURNS bit  
AS 
BEGIN
DECLARE @rslt BIT = 0

  select top(1) @rslt=1
    from {schema}.doc__tbl
   where doc_scope = @tbl
     and doc_scope_id = @id;     

return(isnull(@rslt,0))
  
END










GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE FUNCTION [{schema}].[exists_note]
(
    @tbl nvarchar(MAX),
    @id bigint
)    
RETURNS bit  
AS 
BEGIN
DECLARE @rslt BIT = 0

  select top(1) @rslt=1
    from {schema}.note__tbl
   where note_scope = @tbl
     and note_scope_id = @id;     

return(isnull(@rslt,0))
  
END









GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE FUNCTION [{schema}].[get_cust_user_name]
(
    @in_sys_user_id BIGINT
)    
RETURNS NVARCHAR(MAX)  
AS 
BEGIN
DECLARE @rslt NVARCHAR(MAX) = NULL

  RETURN (@rslt)

END


GO
GRANT EXECUTE ON [{schema}].[get_cust_user_name] TO [{schema}_role_exec] AS [dbo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [{schema}].[get_sys_user_name]
(
    @in_sys_user_id BIGINT
)    
RETURNS NVARCHAR(MAX)  
AS 
BEGIN
DECLARE @rslt NVARCHAR(MAX) = NULL

  SELECT @rslt = sys_user_lname+', '+sys_user_fname
    FROM {schema}.sys_user
   WHERE sys_user_id = @in_sys_user_id;

  RETURN (@rslt)

END

GO
GRANT EXECUTE ON [{schema}].[get_sys_user_name] TO [{schema}_role_exec] AS [dbo]
GO
GRANT EXECUTE ON [{schema}].[get_sys_user_name] TO [{schema}_role_dev] AS [dbo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE FUNCTION [{schema}].[get_param_desc]
(
    @in_param_process NVARCHAR(MAX),
    @in_param_attrib NVARCHAR(MAX)
)    
RETURNS NVARCHAR(MAX)  
AS 
BEGIN
DECLARE @rslt NVARCHAR(MAX) = NULL

  SELECT @rslt = param_desc
    FROM {schema}.param__tbl
   WHERE param_process = @in_param_process
     AND param_attrib = @in_param_attrib

  RETURN (@rslt)

END
GO
GRANT EXECUTE ON [{schema}].[get_param_desc] TO [{schema}_role_exec] AS [dbo]
GO
GRANT EXECUTE ON [{schema}].[get_param_desc] TO [{schema}_role_dev] AS [dbo]
GO




GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [{schema}].[my_db_user]
()    
RETURNS varchar(20)   
AS 
BEGIN
DECLARE @rslt varchar(20)

  SET @rslt = {schema}.my_db_user_exec()

  return (@rslt)

END



GO
GRANT REFERENCES ON [{schema}].[my_db_user] TO [{schema}_role_dev] AS [dbo]
GO
GRANT EXECUTE ON [{schema}].[my_db_user] TO [{schema}_role_exec] AS [dbo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE FUNCTION [{schema}].[my_db_user_exec]
()    
RETURNS varchar(20)   
AS 
BEGIN
DECLARE @rslt nvarchar(20)
DECLARE @an varchar(255)
DECLARE @sys_user_id BIGINT=-1;

  SET @rslt = '0'
  SET @an = LTRIM(RTRIM(REPLACE(ISNULL(CONVERT(VARCHAR(128), CONTEXT_INFO()), APP_NAME()),CHAR(0),'')))
  IF ((@an IS NOT NULL) AND (@an <> 'DBAPP')) 
  BEGIN 
    SELECT @sys_user_id=sys_user_id
      FROM {schema}.sys_user
     WHERE sys_user_email = @an;
    
    SET @rslt = CASE WHEN @sys_user_id=(-1) THEN @an ELSE 'P'+CONVERT(VARCHAR(30),@sys_user_id) END
  END 
  return (@rslt)
END





GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE FUNCTION [{schema}].[my_db_user_fmt]
(@USER VARCHAR(20))    
RETURNS nvarchar(120)   
AS 
BEGIN
DECLARE @rslt nvarchar(255)

  SET @rslt = {schema}.my_db_user_fmt_exec(@USER)
  
  return (@rslt)

END




GO
GRANT REFERENCES ON [{schema}].[my_db_user_fmt] TO [{schema}_role_dev] AS [dbo]
GO
GRANT EXECUTE ON [{schema}].[my_db_user_fmt] TO [{schema}_role_exec] AS [dbo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE FUNCTION [{schema}].[my_db_user_fmt_exec]
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
    select @rslt = 'S-'+isnull(sys_user_name,'')
     from {schema}.sys_user
    where convert(varchar(50),sys_user_id)=substring(@USER,2,1024);
  end
:if:client_portal:
  else if (substring(@USER,1,1)='C' and isnumeric(substring(@USER,2,1024))=1)
  begin
    set @rslt = @USER;
    select @rslt = 'C-'+isnull(sys_user_name,'')
     from {schema}.cust_user
    where convert(varchar(50),sys_user_id)=substring(@USER,2,1024);
  end
:endif:

  return (@rslt)

END





GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE FUNCTION [{schema}].[my_hash]
(@TYPE CHAR(1),
 @sys_user_id bigint,
 @pw nvarchar(255))    
RETURNS varbinary(200)   
AS 
BEGIN
DECLARE @rslt varbinary(200) = NULL
DECLARE @seed nvarchar(255) = NULL
DECLARE @val varchar(255)

  if (@TYPE = 'S')
  BEGIN
    select @seed = param_cur_val
      from {schema}.v_param_cur
     where param_cur_process = 'USERS'
       and param_cur_attrib = 'HASH_SEED_S';
  END
  else if (@TYPE = 'C')
  BEGIN
    select @seed = param_cur_val
      from {schema}.v_param_cur
     where param_cur_process = 'USERS'
       and param_cur_attrib = 'HASH_SEED_C';
  END

  if (@seed is not null
      and isnull(@sys_user_id,0) > 0
      and isnull(@pw,'') <> '')
  begin
    select @val = (convert(varchar(50),@sys_user_id)+@pw+@seed)
    select @rslt = hashbytes('sha1',@val)
  end

  return @rslt

END






GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [{schema}].[my_mmddyyhhmi] (@X DATETIME2(7))
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







CREATE FUNCTION [{schema}].[my_now]
()
RETURNS DATETIME2(7)   
AS 
BEGIN
  RETURN ({schema}.my_now_exec())
END







GO
GRANT REFERENCES ON [{schema}].[my_now] TO [{schema}_role_dev] AS [dbo]
GO
GRANT EXECUTE ON [{schema}].[my_now] TO [{schema}_role_exec] AS [dbo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE FUNCTION [{schema}].[my_now_exec]
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






CREATE FUNCTION [{schema}].[my_sys_user_id]
()    
RETURNS bigint   
AS 
BEGIN
DECLARE @rslt bigint

  SET @rslt = {schema}.my_user_do()

  return (@rslt)

END
go
GRANT EXECUTE ON [{schema}].[my_sys_user_id] TO [{schema}_role_exec] AS [dbo]
go
GRANT EXECUTE ON [{schema}].[my_sys_user_id] TO [{schema}_role_dev] AS [dbo]



GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [{schema}].[my_user_do]
()    
RETURNS bigint   
AS 
BEGIN
DECLARE @rslt bigint
DECLARE @an varchar(255)
DECLARE @sys_user_id BIGINT=-1;

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







CREATE FUNCTION [{schema}].[my_cust_user_id]
()    
RETURNS bigint   
AS 
BEGIN
DECLARE @rslt bigint

  SET @rslt = {schema}.my_cust_user_id_exec()

  return (@rslt)

END
go
GRANT EXECUTE ON [{schema}].[my_cust_user_id] TO [{schema}_role_exec] AS [dbo]
go
GRANT EXECUTE ON [{schema}].[my_cust_user_id] TO [{schema}_role_dev] AS [dbo]



GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [{schema}].[my_cust_user_id_exec]
()    
RETURNS bigint   
AS 
BEGIN
DECLARE @rslt bigint
DECLARE @an varchar(255)
DECLARE @sys_user_id BIGINT=-1;

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





CREATE FUNCTION [{schema}].[my_to_date] (@X DATETIME2(7))
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





CREATE FUNCTION [{schema}].[my_today] ()
RETURNS date
AS
BEGIN
    RETURN ({schema}.my_today_exec())
END



GO
GRANT EXECUTE ON [{schema}].[my_today] TO [{schema}_role_exec] AS [dbo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [{schema}].[my_today_exec] ()
RETURNS date
AS
BEGIN
    
    RETURN DATEADD(day, DATEDIFF(day, 0, {schema}.my_now()), 0)


END



GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE FUNCTION [{schema}].[nequal_chr]
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









CREATE FUNCTION [{schema}].[nequal_date]
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






CREATE FUNCTION [{schema}].[nequal_num]
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





CREATE FUNCTION [{schema}].[table_type]
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
GRANT EXECUTE ON [{schema}].[table_type] TO [{schema}_role_exec] AS [dbo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [{schema}].[param__tbl](
    [param_process] [nvarchar](32) NOT NULL,
    [param_attrib] [nvarchar](16) NOT NULL,
    [param_desc] [nvarchar](255) NOT NULL,
    [param_type] [nvarchar](32) NOT NULL,
    [code_name] [nvarchar](128) NULL,
    [is_param_app] [bit] NOT NULL,
    [is_param_user] [bit] NOT NULL,
    [is_param_sys] [bit] NOT NULL,
    [param_id] [bigint] IDENTITY(1,1) NOT NULL,
    [param_etstmp] [datetime2](7) NOT NULL,
    [param_euser] [nvarchar](20) NOT NULL,
    [param_mtstmp] [datetime2](7) NOT NULL,
    [param_muser] [nvarchar](20) NOT NULL,
    [param_snotes] [nvarchar](max) NULL,
 CONSTRAINT [pk_param__tbl] PRIMARY KEY CLUSTERED 
(
    [param_process] ASC,
    [param_attrib] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/****** Script for SelectTopNRows command from SSMS  ******/
create view [{schema}].[code_param_user_process] as
SELECT distinct
       NULL code_seq
      ,param_process code_val
      ,param_process code_txt
      ,NULL code_code
      ,NULL code_end_dt
      ,NULL code_end_reason
  FROM {schema}.param__tbl
 where is_param_user = 1

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [{schema}].[audit__tbl](
    [audit_seq] [bigint] IDENTITY(1,1) NOT NULL,
    [audit_table_name] [varchar](32) NOT NULL,
    [audit_table_id] [bigint] NOT NULL,
    [audit_op] [char](10) NOT NULL,
    [audit_user] [nvarchar](20) NOT NULL,
    [db_id] [char](1) NOT NULL,
    [audit_tstmp] [datetime2](7) NOT NULL,
    [cust_id] [bigint] NULL,
    [item_id] [bigint] NULL,
    [audit_ref_name] [varchar](32) NULL,
    [audit_ref_id] [bigint] NULL,
    [audit_subject] [nvarchar](255) NULL,
 CONSTRAINT [pk_audit__tbl] PRIMARY KEY CLUSTERED 
(
    [audit_seq] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [{schema}].[audit_detail](
    [audit_seq] [bigint] NOT NULL,
    [audit_column_name] [varchar](30) NOT NULL,
    [audit_column_val] [nvarchar](max) NULL,
 CONSTRAINT [pk_audit_detail] PRIMARY KEY CLUSTERED 
(
    [audit_seq] ASC,
    [audit_column_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












CREATE VIEW [{schema}].[v_audit_detail]
AS
SELECT  audit__tbl.audit_seq,
        audit__tbl.cust_id,
        audit__tbl.item_id,
        audit__tbl.audit_table_name,
        audit__tbl.audit_table_id,
        audit__tbl.audit_op,
        audit__tbl.audit_user,
              {schema}.my_db_user_fmt(audit__tbl.audit_user) sys_user_name,
              audit__tbl.db_id,
              audit__tbl.audit_tstmp,
              audit__tbl.audit_ref_name,
              audit__tbl.audit_ref_id,
              audit__tbl.audit_subject,
        audit_detail.audit_column_name, 
              audit_detail.audit_column_val
FROM          {schema}.audit__tbl 
LEFT OUTER JOIN {schema}.audit_detail ON audit__tbl.audit_seq = audit_detail.audit_seq







GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/****** Script for SelectTopNRows command from SSMS  ******/
create view [{schema}].[code_param_sys_process] as
SELECT distinct
       NULL code_seq
      ,param_process code_val
      ,param_process code_txt
      ,NULL code_code
      ,NULL code_end_dt
      ,NULL code_end_reason
  FROM {schema}.param__tbl
 where is_param_sys = 1

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/****** Script for SelectTopNRows command from SSMS  ******/
create view [{schema}].[code2_param_app_attrib] as
SELECT NULL code_seq
      ,param_process code_val1
      ,param_attrib code_val2
      ,param_desc code_txt
      ,NULL code_code
      ,NULL code_end_dt
      ,NULL code_end_reason
      ,NULL code_etstmp
      ,NULL code_euser
      ,NULL code_mtstmp
      ,NULL code_muser
      ,NULL code_snotes
      ,NULL code_notes
  FROM {schema}.param__tbl
 WHERE is_param_app = 1
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/****** Script for SelectTopNRows command from SSMS  ******/
create view [{schema}].[code2_param_user_attrib] as
SELECT NULL code_seq
      ,param_process code_val1
      ,param_attrib code_val2
      ,param_desc code_txt
      ,NULL code_code
      ,NULL code_end_dt
      ,NULL code_end_reason
      ,NULL code_etstmp
      ,NULL code_euser
      ,NULL code_mtstmp
      ,NULL code_muser
      ,NULL code_snotes
      ,NULL code_notes
  FROM {schema}.param__tbl
 WHERE is_param_user = 1

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/****** Script for SelectTopNRows command from SSMS  ******/
create view [{schema}].[code2_param_sys_attrib] as
SELECT NULL code_seq
      ,param_process code_val1
      ,param_attrib code_val2
      ,param_desc code_txt
      ,NULL code_code
      ,NULL code_end_dt
      ,NULL code_end_reason
      ,NULL code_etstmp
      ,NULL code_euser
      ,NULL code_mtstmp
      ,NULL code_muser
      ,NULL code_snotes
      ,NULL code_notes
  FROM {schema}.param__tbl
 WHERE is_param_sys = 1

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [{schema}].[sys_user_role](
    [sys_user_id] [bigint] NOT NULL,
    [sys_user_role_snotes] [nvarchar](255) NULL,
    [sys_user_role_id] [bigint] IDENTITY(1,1) NOT NULL,
    [sys_role_name] [nvarchar](16) NOT NULL,
 CONSTRAINT [pk_sys_user_role] PRIMARY KEY CLUSTERED 
(
    [sys_user_id] ASC,
    [sys_role_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_sys_user_role] UNIQUE NONCLUSTERED 
(
    [sys_user_role_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [{schema}].[v_my_roles] as
select sys_user_role.sys_role_name
  from {schema}.sys_user_role
 where sys_user_role.sys_user_id = {schema}.my_sys_user_id()


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [{schema}].[number__tbl](
    [number_val] [smallint] NOT NULL,
 CONSTRAINT [pk_number__tbl] PRIMARY KEY CLUSTERED 
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
CREATE view [{schema}].[v_month] as
select number_val month_val,
       right('0'+convert(nvarchar(50),number_val),2) month_txt2,
       right('0'+convert(nvarchar(50),number_val),2) month_txt
  from {schema}.number__tbl
 where number_val <=12;





GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





/****** Script for SelectTopNRows command from SSMS  ******/
CREATE view [{schema}].[v_year] as
select datepart(year,sysdatetime())+number_val-1 year_val,
       datepart(year,sysdatetime())+number_val-1 year_txt
  from {schema}.number__tbl
 where number_val <=10;



GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [{schema}].[param_user](
    [sys_user_id] [bigint] NOT NULL,
    [param_user_process] [nvarchar](32) NOT NULL,
    [param_user_attrib] [nvarchar](16) NOT NULL,
    [param_user_val] [varchar](256) NULL,
    [param_user_etstmp] [datetime2](7) NOT NULL,
    [param_user_euser] [nvarchar](20) NOT NULL,
    [param_user_mtstmp] [datetime2](7) NOT NULL,
    [param_user_muser] [nvarchar](20) NOT NULL,
    [param_user_id] [bigint] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [pk_param_user] PRIMARY KEY CLUSTERED 
(
    [sys_user_id] ASC,
    [param_user_process] ASC,
    [param_user_attrib] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [{schema}].[param_app](
    [param_app_process] [nvarchar](32) NOT NULL,
    [param_app_attrib] [nvarchar](16) NOT NULL,
    [param_app_val] [varchar](256) NULL,
    [param_app_etstmp] [datetime2](7) NOT NULL,
    [param_app_euser] [nvarchar](20) NOT NULL,
    [param_app_mtstmp] [datetime2](7) NOT NULL,
    [param_app_muser] [nvarchar](20) NOT NULL,
    [param_app_id] [bigint] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [pk_param_app] PRIMARY KEY CLUSTERED 
(
    [param_app_process] ASC,
    [param_app_attrib] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [{schema}].[param_sys](
    [param_sys_process] [nvarchar](32) NOT NULL,
    [param_sys_attrib] [nvarchar](16) NOT NULL,
    [param_sys_val] [varchar](256) NOT NULL,
    [param_sys_etstmp] [datetime2](7) NOT NULL,
    [param_sys_euser] [nvarchar](20) NOT NULL,
    [param_sys_mtstmp] [datetime2](7) NOT NULL,
    [param_sys_muser] [nvarchar](20) NOT NULL,
    [param_sys_id] [bigint] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [pk_param_sys] PRIMARY KEY CLUSTERED 
(
    [param_sys_process] ASC,
    [param_sys_attrib] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [{schema}].[v_param_cur] AS
 SELECT param__tbl.param_process AS param_cur_process, 
        param__tbl.param_attrib AS param_cur_attrib, 
            CASE WHEN param_user_val IS NULL OR param_user_val = '' 
                 THEN CASE WHEN param_app_val IS NULL OR param_app_val = '' 
                             THEN param_sys_val 
                       ELSE param_app_val END 
              ELSE param_user_val END AS param_cur_val, 
            CASE WHEN param_user_val IS NULL OR param_user_val = '' 
                 THEN CASE WHEN param_app_val IS NULL OR param_app_val = '' 
                             THEN 'param_sys' 
                                 ELSE 'param_app' END 
              ELSE convert(varchar,param_user.sys_user_id) END AS param_cur_source 
   FROM {schema}.param__tbl 
   LEFT OUTER JOIN {schema}.param_sys ON param__tbl.param_process = param_sys.param_sys_process AND param__tbl.param_attrib = param_sys.param_sys_attrib 
   LEFT OUTER JOIN {schema}.param_app ON param__tbl.param_process = param_app.param_app_process AND param__tbl.param_attrib = param_app.param_app_attrib 
   LEFT OUTER JOIN {schema}.param_user ON param__tbl.param_process = param_user.param_user_process AND param__tbl.param_attrib = param_user.param_user_attrib AND param_user.sys_user_id = {schema}.my_sys_user_id();




GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [{schema}].[doc__tbl](
    [doc_id] [bigint] IDENTITY(1,1) NOT NULL,
    [doc_scope] [nvarchar](32) NOT NULL,
    [doc_scope_id] [bigint] NOT NULL,
    [cust_id] [bigint] NULL,
    [item_id] [bigint] NULL,
    [doc_sts] [nvarchar](32) NOT NULL,
    [doc_ctgr] [nvarchar](32) NOT NULL,
    [doc_desc] [nvarchar](255) NULL,
    [doc_ext] [nvarchar](16) NULL,
    [doc_size] [bigint] NULL,
    [doc_filename]  AS (('D'+CONVERT([varchar](50),[doc_id],(0)))+isnull([doc_ext],'')) PERSISTED,
    [doc_etstmp] [datetime2](7) NOT NULL,
    [doc_euser] [nvarchar](20) NOT NULL,
    [doc_mtstmp] [datetime2](7) NOT NULL,
    [doc_muser] [nvarchar](20) NOT NULL,
    [doc_uptstmp] [datetime2](7) NOT NULL,
    [doc_upuser] [nvarchar](20) NOT NULL,
    [doc_sync_tstmp] [datetime2](7) NULL,
    [doc_snotes] [nvarchar](255) NULL,
    [doc_sync_id] [bigint] NULL,
 CONSTRAINT [pk_doc__tbl] PRIMARY KEY CLUSTERED 
(
    [doc_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [{schema}].[single](
    [single_dummy] [nvarchar](1) NOT NULL,
    [single_ident] [bigint] NOT NULL,
    [dual_bigint] [bigint] NULL,
    [dual_nvarchar50] [nvarchar](50) NULL,
 CONSTRAINT [pk_single] PRIMARY KEY CLUSTERED 
(
    [single_ident] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE view [{schema}].[v_app_info] as
select NAME.param_cur_val app_title,
       ADDR.param_cur_val app_addr,
         CITY.param_cur_val app_city,
         [STATE].param_cur_val app_state,
         ZIP.param_cur_val app_zip,
       isnull(ADDR.param_cur_val,'')+', '+isnull(CITY.param_cur_val,'')+' '+isnull([STATE].param_cur_val,'')+' '+isnull(ZIP.param_cur_val,'') app_full_addr,
         BPHONE.param_cur_val app_bphone,
         FAX.param_cur_val app_fax,
         EMAIL.param_cur_val app_email,
         CONTACT.param_cur_val app_contact
  from {schema}.single
 left outer join {schema}.v_param_cur NAME on NAME.param_cur_process='HOUSE' and NAME.param_cur_attrib='NAME'
 left outer join {schema}.v_param_cur ADDR on ADDR.param_cur_process='HOUSE' and ADDR.param_cur_attrib='ADDR'
 left outer join {schema}.v_param_cur CITY on CITY.param_cur_process='HOUSE' and CITY.param_cur_attrib='CITY'
 left outer join {schema}.v_param_cur [STATE] on[STATE].param_cur_process='HOUSE' and [STATE].param_cur_attrib='STATE'
 left outer join {schema}.v_param_cur ZIP on ZIP.param_cur_process='HOUSE' and ZIP.param_cur_attrib='ZIP'
 left outer join {schema}.v_param_cur BPHONE on BPHONE.param_cur_process='HOUSE' and BPHONE.param_cur_attrib='BPHONE'
 left outer join {schema}.v_param_cur FAX on FAX.param_cur_process='HOUSE' and FAX.param_cur_attrib='FAX'
 left outer join {schema}.v_param_cur EMAIL on EMAIL.param_cur_process='HOUSE' and EMAIL.param_cur_attrib='EMAIL'
 left outer join {schema}.v_param_cur CONTACT on CONTACT.param_cur_process='HOUSE' and CONTACT.param_cur_attrib='CONTACT'



GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [{schema}].[menu__tbl](
    [menu_id_auto] [bigint] IDENTITY(1,1) NOT NULL,
    [menu_group] [char](1) NOT NULL,
    [menu_id] [bigint] NOT NULL,
    [menu_sts] [nvarchar](32) NOT NULL,
    [menu_id_parent] [bigint] NULL,
    [menu_name] [nvarchar](255) NOT NULL,
    [menu_seq] [int] NULL,
    [menu_desc] [nvarchar](255) NOT NULL,
    [menu_desc_ext] [nvarchar](max) NULL,
    [menu_desc_ext2] [nvarchar](max) NULL,
    [menu_cmd] [varchar](255) NULL,
    [menu_image] [nvarchar](255) NULL,
    [menu_snotes] [nvarchar](255) NULL,
    [menu_subcmd] [varchar](255) NULL,
 CONSTRAINT [pk_menu__tbl] PRIMARY KEY CLUSTERED 
(
    [menu_id_auto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_menu__tbl_menu_desc] UNIQUE NONCLUSTERED 
(
    [menu_id_parent] ASC,
    [menu_desc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_menu__tbl_menu_id] UNIQUE NONCLUSTERED 
(
    [menu_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_menu__tbl_menu_name] UNIQUE NONCLUSTERED 
(
    [menu_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [{schema}].[sys_role](
    [sys_role_id] [bigint] IDENTITY(1,1) NOT NULL,
    [sys_role_seq] [smallint] NOT NULL,
    [sys_role_sts] [nvarchar](32) NOT NULL,
    [sys_role_name] [nvarchar](16) NOT NULL,
    [sys_role_desc] [nvarchar](255) NOT NULL,
    [sys_role_code] [nvarchar](50) NULL,
    [sys_role_attrib] [nvarchar](50) NULL,
    [sys_role_snotes] [nvarchar](255) NULL,
 CONSTRAINT [pk_sys_role] PRIMARY KEY CLUSTERED 
(
    [sys_role_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_sys_role_sys_role_desc] UNIQUE NONCLUSTERED 
(
    [sys_role_desc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_sys_role_sys_role_id] UNIQUE NONCLUSTERED 
(
    [sys_role_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [{schema}].[sys_menu_role](
    [menu_id] [bigint] NOT NULL,
    [sys_menu_role_snotes] [nvarchar](255) NULL,
    [sys_menu_role_id] [bigint] IDENTITY(1,1) NOT NULL,
    [sys_role_name] [nvarchar](16) NOT NULL,
 CONSTRAINT [pk_sys_menu_role] PRIMARY KEY CLUSTERED 
(
    [sys_role_name] ASC,
    [menu_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_sys_menu_role] UNIQUE NONCLUSTERED 
(
    [sys_menu_role_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [{schema}].[v_sys_menu_role_selection]
AS
SELECT {schema}.sys_menu_role.sys_menu_role_id, 
       ISNULL({schema}.single.dual_nvarchar50, '') AS new_sys_role_name, 
       single.dual_bigint AS new_menu_id,
       CASE WHEN sys_menu_role.sys_menu_role_id IS NULL 
            THEN 0 
            ELSE 1 END AS sys_menu_role_selection, 
         M.sys_role_id, 
       M.sys_role_seq, 
       M.sys_role_sts, 
       M.sys_role_name, 
       M.sys_role_desc, 
       M.menu_id_auto, 
       M.menu_group, 
       M.menu_id, 
       M.menu_sts, 
       M.menu_id_parent, 
       M.menu_name, 
       M.menu_seq, 
       M.menu_desc, 
       M.menu_desc_ext, 
       M.menu_desc_ext2, 
       M.menu_cmd, 
       M.menu_image, 
       M.menu_snotes,
       M.menu_subcmd
  FROM (SELECT {schema}.sys_role.sys_role_id, 
               {schema}.sys_role.sys_role_seq, 
               {schema}.sys_role.sys_role_sts, 
               {schema}.sys_role.sys_role_name, 
               {schema}.sys_role.sys_role_desc, 
               {schema}.menu__tbl.menu_id_auto, 
               {schema}.menu__tbl.menu_group, 
               {schema}.menu__tbl.menu_id, 
               {schema}.menu__tbl.menu_sts, 
               {schema}.menu__tbl.menu_id_parent, 
               {schema}.menu__tbl.menu_name, 
               {schema}.menu__tbl.menu_seq, 
               {schema}.menu__tbl.menu_desc, 
               {schema}.menu__tbl.menu_desc_ext, 
               {schema}.menu__tbl.menu_desc_ext2, 
               {schema}.menu__tbl.menu_cmd, 
               {schema}.menu__tbl.menu_image, 
               {schema}.menu__tbl.menu_snotes, 
               {schema}.menu__tbl.menu_subcmd
          FROM {schema}.sys_role 
          LEFT OUTER JOIN {schema}.menu__tbl ON {schema}.menu__tbl.menu_group = 'S') AS M 
 INNER JOIN {schema}.single ON 1 = 1 
  LEFT OUTER JOIN {schema}.sys_menu_role ON {schema}.sys_menu_role.sys_role_name = M.sys_role_name AND {schema}.sys_menu_role.menu_id = M.menu_id;


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



































CREATE VIEW [{schema}].[v_param_app] AS
SELECT {schema}.param_app.*,
       {schema}.get_param_desc(param_app_process, param_app_attrib) param_desc,
       {schema}.log_audit_info(param_app_etstmp, param_app_euser, param_app_mtstmp, param_app_muser) param_app_info
  FROM {schema}.param_app;


















GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



































CREATE VIEW [{schema}].[v_param_user] AS
SELECT param_user.*,
       {schema}.get_param_desc(param_user_process, param_user_attrib) param_desc,
       {schema}.log_audit_info(param_user_etstmp, param_user_euser, param_user_mtstmp, param_user_muser) param_user_info
  FROM {schema}.param_user

















GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



































CREATE VIEW [{schema}].[v_param_sys] AS
SELECT param_sys.*,
       {schema}.get_param_desc(param_sys_process, param_sys_attrib) param_desc,
       {schema}.log_audit_info(param_sys_etstmp, param_sys_euser, param_sys_mtstmp, param_sys_muser) param_sys_info







  FROM {schema}.param_sys;


















GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



































CREATE VIEW [{schema}].[v_param] AS
SELECT param__tbl.*,
       {schema}.log_audit_info(param_etstmp, param_euser, param_mtstmp, param_muser) param_info
  FROM {schema}.param__tbl;


















GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/****** Script for SelectTopNRows command from SSMS  ******/
create view [{schema}].[code_param_app_process] as
SELECT distinct
       NULL code_seq
      ,param_process code_val
      ,param_process code_txt
      ,NULL code_code
      ,NULL code_end_dt
      ,NULL code_end_reason
  FROM {schema}.param__tbl
 where is_param_app = 1
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create view [{schema}].[v_my_user] as
select {schema}.my_sys_user_id() my_sys_user_id
GO



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [{schema}].[code_app](
    [code_name] [nvarchar](128) NOT NULL,
    [code_desc] [nvarchar](128) NULL,
    [code_code_desc] [nvarchar](128) NULL,
    [code_attrib_desc] [nvarchar](128) NULL,
    [code_h_etstmp] [datetime2](7) NULL,
    [code_h_euser] [nvarchar](20) NULL,
    [code_h_mtstmp] [datetime2](7) NULL,
    [code_h_muser] [nvarchar](20) NULL,
    [code_snotes] [nvarchar](255) NULL,
    [code_schema] [nvarchar](128) NULL,
    [code_type] [nvarchar](32) NULL default 'app',
    [code_app_h_id] [bigint] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [pk_code_app] PRIMARY KEY CLUSTERED 
(
    [code_app_h_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_code_app] UNIQUE NONCLUSTERED 
(
    [code_schema] ASC,
    [code_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [{schema}].[code2_doc_scope_doc_ctgr](
    [code2_app_id] [bigint] IDENTITY(1,1) NOT NULL,
    [code_seq] [smallint] NULL,
    [code_val1] [nvarchar](32) NOT NULL,
    [code_val2] [nvarchar](32) NOT NULL,
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
    [code_euser_fmt]  AS ([{schema}].[my_db_user_fmt]([code_euser])),
    [code_muser_fmt]  AS ([{schema}].[my_db_user_fmt]([code_muser])),
 CONSTRAINT [pk_code2_doc_scope_doc_ctgr] PRIMARY KEY CLUSTERED 
(
    [code2_app_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_code2_doc_scope_doc_ctgr_code_val1_code_val2] UNIQUE NONCLUSTERED 
(
    [code_val1] ASC,
    [code_val2] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_code2_doc_scope_doc_ctgr_code_val1_code_txt] UNIQUE NONCLUSTERED 
(
    [code_val1] ASC,
    [code_txt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [{schema}].[code2_app](
    [code_name] [nvarchar](128) NOT NULL,
    [code_desc] [nvarchar](128) NULL,
    [code_code_desc] [nvarchar](128) NULL,
    [code_attrib_desc] [nvarchar](128) NULL,
    [code_h_etstmp] [datetime2](7) NULL,
    [code_h_euser] [nvarchar](20) NULL,
    [code_h_mtstmp] [datetime2](7) NULL,
    [code_h_muser] [nvarchar](20) NULL,
    [code_snotes] [nvarchar](255) NULL,
    [code_schema] [nvarchar](128) NULL,
    [code_type] [nvarchar](32) NULL default 'app',
    [code2_app_h_id] [bigint] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [pk_code2_app] PRIMARY KEY CLUSTERED 
(
    [code2_app_h_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_code2_app] UNIQUE NONCLUSTERED 
(
    [code_schema] ASC,
    [code_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ARITHABORT ON
GO
CREATE TABLE [{schema}].[help__tbl](
    [help_id] [bigint] IDENTITY(1,1) NOT NULL,
    [help_target_code] [varchar](50) NULL,
  [help_target_id] [bigint] NULL,
    [help_title] [nvarchar](70) NOT NULL,
    [help_text] [nvarchar](max) NOT NULL,
    [help_etstmp] [datetime2](7) NOT NULL,
    [help_euser] [nvarchar](20) NOT NULL,
    [help_mtstmp] [datetime2](7) NOT NULL,
    [help_muser] [nvarchar](20) NOT NULL,
    [help_unq_code]  AS (case when [help_target_code] IS NOT NULL then 'X'+[help_target_code] else 'Y'+CONVERT([varchar](50),[help_id],(0)) end) PERSISTED,
    [help_seq] [int] NULL,
    [help_listing_main] [bit] NOT NULL,
    [help_listing_client] [bit] NOT NULL,
 CONSTRAINT [pk_help__tbl] PRIMARY KEY CLUSTERED 
(
    [help_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_help__tbl_help_title] UNIQUE NONCLUSTERED 
(
    [help_title] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_help__tbl_help_unq_code] UNIQUE NONCLUSTERED 
(
    [help_unq_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [{schema}].[help_target](
    [help_target_code] [varchar](50) NOT NULL,
    [help_target_desc] [nvarchar](50) NOT NULL,
    [help_target_id] [bigint] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [pk_help_target] PRIMARY KEY CLUSTERED 
(
    [help_target_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_help_target_help_target_desc] UNIQUE NONCLUSTERED 
(
    [help_target_desc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_help_target_help_target_id] UNIQUE NONCLUSTERED 
(
    [help_target_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [{schema}].[note__tbl](
    [note_id] [bigint] IDENTITY(1,1) NOT NULL,
    [note_scope] [nvarchar](32) NOT NULL,
    [note_scope_id] [bigint] NOT NULL,
    [note_sts] [nvarchar](32) NOT NULL,
    [cust_id] [bigint] NULL,
    [item_id] [bigint] NULL,
    [note_type] [nvarchar](32) NOT NULL,
    [note_body] [nvarchar](max) NOT NULL,
    [note_etstmp] [datetime2](7) NOT NULL,
    [note_euser] [nvarchar](20) NOT NULL,
    [note_mtstmp] [datetime2](7) NOT NULL,
    [note_muser] [nvarchar](20) NOT NULL,
    [note_sync_tstmp] [datetime2](7) NULL,
    [note_snotes] [nvarchar](255) NULL,
    [note_sync_id] [bigint] NULL,
 CONSTRAINT [pk_note__tbl] PRIMARY KEY CLUSTERED 
(
    [note_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ARITHABORT ON
GO
CREATE TABLE [{schema}].[sys_user](
    [sys_user_id] [bigint] IDENTITY(1,1) NOT NULL,
    [sys_user_sts] [nvarchar](32) NOT NULL,
    [sys_user_stsdt] [date] NOT NULL,
    [sys_user_fname] [nvarchar](35) NOT NULL,
    [sys_user_mname] [nvarchar](35) NULL,
    [sys_user_lname] [nvarchar](35) NOT NULL,
    [sys_user_jobtitle] [nvarchar](35) NULL,
    [sys_user_bphone] [nvarchar](30) NULL,
    [sys_user_cphone] [nvarchar](30) NULL,
    [sys_user_country] [nvarchar](32) NOT NULL,
    [sys_user_addr] [nvarchar](200) NULL,
    [sys_user_city] [nvarchar](50) NULL,
    [sys_user_state] [nvarchar](32) NULL,
    [sys_user_zip] [nvarchar](20) NULL,
    [sys_user_email] [nvarchar](255) NOT NULL,
    [sys_user_startdt] [date] NOT NULL,
    [sys_user_enddt] [date] NULL,
    [sys_user_unotes] [nvarchar](4000) NULL,
    [sys_user_etstmp] [datetime2](7) NOT NULL,
    [sys_user_euser] [nvarchar](20) NOT NULL,
    [sys_user_mtstmp] [datetime2](7) NOT NULL,
    [sys_user_muser] [nvarchar](20) NOT NULL,
    [sys_user_pw1] [nvarchar](255) NULL,
    [sys_user_pw2] [nvarchar](255) NULL,
    [sys_user_hash] [varbinary](200) NOT NULL,
    [sys_user_lastlogin_ip] [nvarchar](255) NULL,
    [sys_user_lastlogin_tstmp] [datetime2](7) NULL,
    [sys_user_snotes] [nvarchar](255) NULL,
    [sys_user_name]  AS (([sys_user_lname]+', ')+[sys_user_fname]) PERSISTED NOT NULL,
    [sys_user_initials]  AS ((isnull(substring([sys_user_fname],(1),(1)),'')+isnull(substring([sys_user_mname],(1),(1)),''))+isnull(substring([sys_user_lname],(1),(1)),'')) PERSISTED NOT NULL,
    [sys_user_unq_email]  AS (case when [sys_user_sts]='ACTIVE' then case when isnull([sys_user_email],'')='' then 'E'+CONVERT([varchar](50),[sys_user_id],(0)) else 'S'+[sys_user_email] end else 'E'+CONVERT([varchar](50),[sys_user_id],(0)) end) PERSISTED,
 CONSTRAINT [pk_sys_user] PRIMARY KEY CLUSTERED 
(
    [sys_user_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_sys_user_sys_user_email] UNIQUE NONCLUSTERED 
(
    [sys_user_unq_email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [{schema}].[queue__tbl](
    [queue_id] [bigint] IDENTITY(1,1) NOT NULL,
    [queue_etstmp] [datetime2](7) NOT NULL,
    [queue_euser] [nvarchar](20) NOT NULL,
    [queue_name] [nvarchar](255) NOT NULL,
    [queue_message] [nvarchar](max) NOT NULL,
    [queue_rslt] [nvarchar](32) NULL,
    [queue_rslt_tstmp] [datetime2](7) NULL,
    [queue_rslt_user] [nvarchar](20) NULL,
    [queue_snotes] [nvarchar](max) NULL,
 CONSTRAINT [pk_queue__tbl] PRIMARY KEY CLUSTERED 
(
    [queue_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [{schema}].[job__tbl](
    [job_id] [bigint] IDENTITY(1,1) NOT NULL,
    [job_etstmp] [datetime2](7) NOT NULL,
    [job_user] [nvarchar](20) NOT NULL,
    [job_source] [nvarchar](32) NOT NULL,
    [job_action] [nvarchar](32) NOT NULL,
    [job_action_target] [nvarchar](50) NOT NULL,
    [job_params] [nvarchar](max) NULL,
    [job_tag] [nvarchar](255) NULL,
    [job_rslt] [nvarchar](32) NULL,
    [job_rslt_tstmp] [datetime2](7) NULL,
    [job_rslt_user] [nvarchar](20) NULL,
    [job_snotes] [nvarchar](max) NULL,
 CONSTRAINT [pk_job__tbl] PRIMARY KEY CLUSTERED 
(
    [job_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [{schema}].[job_doc](
    [job_doc_id] [bigint] IDENTITY(1,1) NOT NULL,
    [job_id] [bigint] NOT NULL,
    [doc_scope] [nvarchar](32) NULL,
    [doc_scope_id] [bigint] NULL,
    [doc_ctgr] [nvarchar](32) NULL,
    [doc_desc] [nvarchar](255) NULL,
 CONSTRAINT [pk_job_doc] PRIMARY KEY CLUSTERED 
(
    [job_doc_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [{schema}].[job_email](
    [job_email_id] [bigint] IDENTITY(1,1) NOT NULL,
    [job_id] [bigint] NOT NULL,
    [email_txt_attrib] [nvarchar](32) NULL,
    [email_to] [nvarchar](255) NOT NULL,
    [email_cc] [nvarchar](255) NULL,
    [email_bcc] [nvarchar](255) NULL,
    [email_attach] [nvarchar](max) NULL,
    [email_subject] [nvarchar](500) NULL,
    [email_text] [ntext] NULL,
    [email_html] [ntext] NULL,
    [email_doc_id] [bigint] NULL,
 CONSTRAINT [pk_job_email] PRIMARY KEY CLUSTERED 
(
    [job_email_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [{schema}].[job_note](
    [job_note_id] [bigint] IDENTITY(1,1) NOT NULL,
    [job_id] [bigint] NOT NULL,
    [note_scope] [nvarchar](32) NULL,
    [note_scope_id] [bigint] NULL,
    [note_type] [nvarchar](32) NULL,
    [note_body] [nvarchar](max) NULL,
 CONSTRAINT [pk_job_note] PRIMARY KEY CLUSTERED 
(
    [job_note_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [{schema}].[job_queue](
    [job_queue_id] [bigint] IDENTITY(1,1) NOT NULL,
    [job_id] [bigint] NOT NULL,
    [queue_name] [nvarchar](255) NOT NULL,
    [queue_message] [nvarchar](max) NULL,
 CONSTRAINT [pk_job_queue] PRIMARY KEY CLUSTERED 
(
    [job_queue_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [{schema}].[job_sms](
    [job_sms_id] [bigint] IDENTITY(1,1) NOT NULL,
    [job_id] [bigint] NOT NULL,
    [sms_txt_attrib] [nvarchar](32) NULL,
    [sms_to] [nvarchar](255) NOT NULL,
    [sms_body] [ntext] NULL,
 CONSTRAINT [pk_job_sms] PRIMARY KEY CLUSTERED 
(
    [job_sms_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [{schema}].[script__tbl](
    [script_name] [nvarchar](32) NOT NULL,
    [script_txt] [nvarchar](max) NULL,
 CONSTRAINT [pk_SCRIPT] PRIMARY KEY CLUSTERED 
(
    [script_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [{schema}].[sys_func](
    [sys_func_id] [bigint] IDENTITY(1,1) NOT NULL,
    [sys_func_seq] [smallint] NOT NULL,
    [sys_func_sts] [nvarchar](32) NOT NULL,
    [sys_func_name] [nvarchar](16) NOT NULL,
    [sys_func_desc] [nvarchar](255) NOT NULL,
    [sys_func_code] [nvarchar](50) NULL,
    [sys_func_attrib] [nvarchar](50) NULL,
    [sys_func_snotes] [nvarchar](255) NULL,
 CONSTRAINT [pk_sys_func] PRIMARY KEY CLUSTERED 
(
    [sys_func_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_sys_func_sys_func_code_sys_func_name] UNIQUE NONCLUSTERED 
(
    [sys_func_code] ASC,
    [sys_func_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_sys_func_sys_func_desc] UNIQUE NONCLUSTERED 
(
    [sys_func_desc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_sys_func_sys_func_id] UNIQUE NONCLUSTERED 
(
    [sys_func_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [{schema}].[sys_user_func](
    [sys_user_id] [bigint] NOT NULL,
    [sys_user_func_snotes] [nvarchar](255) NULL,
    [sys_user_func_id] [bigint] IDENTITY(1,1) NOT NULL,
    [sys_func_name] [nvarchar](16) NOT NULL,
 CONSTRAINT [pk_sys_user_func] PRIMARY KEY CLUSTERED 
(
    [sys_user_id] ASC,
    [sys_func_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_sys_user_func] UNIQUE NONCLUSTERED 
(
    [sys_user_func_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [{schema}].[txt__tbl](
    [txt_process] [nvarchar](32) NOT NULL,
    [txt_attrib] [nvarchar](32) NOT NULL,
    [txt_type] [nvarchar](32) NOT NULL,
    [txt_title] [nvarchar](max) NULL,
    [txt_body] [nvarchar](max) NULL,
    [txt_bcc] [nvarchar](255) NULL,
    [txt_desc] [nvarchar](255) NULL,
    [txt_id] [bigint] IDENTITY(1,1) NOT NULL,
    [txt_etstmp] [datetime2](7) NOT NULL,
    [txt_euser] [varchar](64) NOT NULL,
    [txt_mtstmp] [datetime2](7) NOT NULL,
    [txt_muser] [varchar](64) NOT NULL,
 CONSTRAINT [pk_txt__tbl] PRIMARY KEY CLUSTERED 
(
    [txt_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_txt__tbl] UNIQUE NONCLUSTERED 
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
CREATE TABLE [{schema}].[code_ac](
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
 CONSTRAINT [pk_code_ac] PRIMARY KEY CLUSTERED 
(
    [code_sys_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_code_ac_code_txt] UNIQUE NONCLUSTERED 
(
  [code_txt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_code_ac_code_val] UNIQUE NONCLUSTERED 
(
  [code_val] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [{schema}].[code_ac1](
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
 CONSTRAINT [pk_code_ac1] PRIMARY KEY CLUSTERED 
(
  [code_sys_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_code_ac1_code_txt] UNIQUE NONCLUSTERED 
(
  [code_txt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_code_ac1_code_val] UNIQUE NONCLUSTERED 
(
  [code_val] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [{schema}].[code_ahc](
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
 CONSTRAINT [pk_code_ahc] PRIMARY KEY CLUSTERED 
(
  [code_sys_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_code_ahc_code_txt] UNIQUE NONCLUSTERED 
(
  [code_txt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_code_ahc_code_val] UNIQUE NONCLUSTERED 
(
  [code_val] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [{schema}].[code_country](
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
 CONSTRAINT [pk_code_country] PRIMARY KEY CLUSTERED 
(
  [code_sys_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_code_country_code_txt] UNIQUE NONCLUSTERED 
(
  [code_txt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_code_country_code_val] UNIQUE NONCLUSTERED 
(
  [code_val] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [{schema}].[code_doc_scope](
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
 CONSTRAINT [pk_code_doc_scope] PRIMARY KEY CLUSTERED 
(
  [code_sys_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_code_doc_scope_code_txt] UNIQUE NONCLUSTERED 
(
  [code_txt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_code_doc_scope_code_val] UNIQUE NONCLUSTERED 
(
  [code_val] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if not exists(select * from sys.tables where name = N'code_sys' and schema_name(schema_id)='{schema}' and type='U')
begin
CREATE TABLE [{schema}].[code_sys](
    [code_name] [nvarchar](128) NOT NULL,
    [code_desc] [nvarchar](128) NULL,
    [code_code_desc] [nvarchar](128) NULL,
    [code_attrib_desc] [nvarchar](128) NULL,
    [code_h_etstmp] [datetime2](7) NULL,
    [code_h_euser] [nvarchar](20) NULL,
    [code_h_mtstmp] [datetime2](7) NULL,
    [code_h_muser] [nvarchar](20) NULL,
    [code_snotes] [nvarchar](255) NULL,
    [code_schema] [nvarchar](128) NULL,
  [code_type] [nvarchar](32) NULL default 'sys',
    [code_sys_h_id] [bigint] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [pk_code_sys] PRIMARY KEY CLUSTERED 
(
    [code_sys_h_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_code_sys] UNIQUE NONCLUSTERED 
(
    [code_schema] ASC,
    [code_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
end
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [{schema}].[code_note_scope](
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
 CONSTRAINT [pk_code_note_scope] PRIMARY KEY CLUSTERED 
(
  [code_sys_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_code_note_scope_code_txt] UNIQUE NONCLUSTERED 
(
  [code_txt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_code_note_scope_code_val] UNIQUE NONCLUSTERED 
(
  [code_val] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [{schema}].[code_note_type](
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
 CONSTRAINT [pk_code_note_type] PRIMARY KEY CLUSTERED 
(
  [code_sys_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_code_note_type_code_txt] UNIQUE NONCLUSTERED 
(
  [code_txt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_code_note_type_code_val] UNIQUE NONCLUSTERED 
(
  [code_val] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [{schema}].[code_param_type](
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
 CONSTRAINT [pk_code_param_type] PRIMARY KEY CLUSTERED 
(
  [code_sys_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_code_param_type_code_txt] UNIQUE NONCLUSTERED 
(
  [code_txt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_code_param_type_code_val] UNIQUE NONCLUSTERED 
(
  [code_val] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [{schema}].[code_job_action](
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
 CONSTRAINT [pk_code_job_action] PRIMARY KEY CLUSTERED 
(
  [code_sys_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_code_job_action_code_txt] UNIQUE NONCLUSTERED 
(
  [code_txt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_code_job_action_code_val] UNIQUE NONCLUSTERED 
(
  [code_val] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [{schema}].[code_job_source](
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
 CONSTRAINT [pk_code_job_source] PRIMARY KEY CLUSTERED 
(
  [code_sys_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_code_job_source_code_txt] UNIQUE NONCLUSTERED 
(
  [code_txt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_code_job_source_code_val] UNIQUE NONCLUSTERED 
(
  [code_val] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [{schema}].[code_txt_type](
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
 CONSTRAINT [pk_code_txt_type] PRIMARY KEY CLUSTERED 
(
  [code_sys_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_code_txt_type_code_txt] UNIQUE NONCLUSTERED 
(
  [code_txt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_code_txt_type_code_val] UNIQUE NONCLUSTERED 
(
  [code_val] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [{schema}].[code_version_sts](
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
 CONSTRAINT [pk_code_version_sts] PRIMARY KEY CLUSTERED 
(
    [code_sys_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_code_version_sts_code_txt] UNIQUE NONCLUSTERED 
(
    [code_txt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_code_version_sts_code_val] UNIQUE NONCLUSTERED 
(
    [code_val] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [{schema}].[code2_country_state](
    [code2_sys_id] [bigint] IDENTITY(1,1) NOT NULL,
    [code_seq] [smallint] NULL,
    [code_val1] [nvarchar](32) NOT NULL,
    [code_val2] [nvarchar](32) NOT NULL,
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
 CONSTRAINT [pk_code2_country_state] PRIMARY KEY CLUSTERED 
(
    [code2_sys_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_code2_country_state_code_val1_code_val2] UNIQUE NONCLUSTERED 
(
    [code_val1] ASC,
    [code_val2] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_code2_country_state_code_val1_code_txt] UNIQUE NONCLUSTERED 
(
    [code_val1] ASC,
    [code_txt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if not exists(select * from sys.tables where name = N'code2_sys' and schema_name(schema_id)='{schema}' and type='U')
begin
CREATE TABLE [{schema}].[code2_sys](
    [code_name] [nvarchar](128) NOT NULL,
    [code_desc] [nvarchar](128) NULL,
    [code_code_desc] [nvarchar](128) NULL,
    [code_attrib_desc] [nvarchar](128) NULL,
    [code_h_etstmp] [datetime2](7) NULL,
    [code_h_euser] [nvarchar](20) NULL,
    [code_h_mtstmp] [datetime2](7) NULL,
    [code_h_muser] [nvarchar](20) NULL,
    [code_snotes] [nvarchar](255) NULL,
    [code_schema] [nvarchar](128) NULL,
    [code_type] [nvarchar](32) NULL default 'sys',
    [code2_sys_h_id] [bigint] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [pk_code2_sys] PRIMARY KEY CLUSTERED 
(
    [code2_sys_h_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_code2_sys] UNIQUE NONCLUSTERED 
(
    [code_schema] ASC,
    [code_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
end
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [{schema}].[version__tbl](
    [version_id] [bigint] IDENTITY(1,1) NOT NULL,
    [version_component] [nvarchar](50) NOT NULL,
    [version_no_major] [int] NOT NULL,
    [version_no_minor] [int] NOT NULL,
    [version_no_build] [int] NOT NULL,
    [version_no_rev] [int] NOT NULL,
    [version_sts] [nvarchar](32) NOT NULL,
    [version_note] [nvarchar](max) NULL,
    [version_etstmp] [datetime2](7) NOT NULL,
    [version_euser] [nvarchar](20) NOT NULL,
    [version_mtstmp] [datetime2](7) NOT NULL,
    [version_muser] [nvarchar](20) NOT NULL,
    [version_snotes] [nvarchar](255) NULL,
 CONSTRAINT [unq_version__tbl] PRIMARY KEY CLUSTERED 
(
    [version_no_major] ASC,
    [version_no_minor] ASC,
    [version_no_build] ASC,
    [version_no_rev] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_doc__tbl_cust_id] ON [{schema}].[doc__tbl]
(
    [cust_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_doc_scope] ON [{schema}].[doc__tbl]
(
    [doc_scope] ASC,
    [doc_scope_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_help__tbl] ON [{schema}].[help__tbl]
(
    [help_target_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_queue__tbl_queue_name] ON [{schema}].[queue__tbl]
(
    [queue_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [{schema}].[audit__tbl] ADD  CONSTRAINT [df_audit__tbl_db_id]  DEFAULT ('0') FOR [db_id]
GO
ALTER TABLE [{schema}].[doc__tbl] ADD  CONSTRAINT [df_doc__tbl_doc_scope]  DEFAULT (N'S') FOR [doc_scope]
GO
ALTER TABLE [{schema}].[doc__tbl] ADD  CONSTRAINT [df_doc__tbl_doc_scope_id]  DEFAULT ((0)) FOR [doc_scope_id]
GO
ALTER TABLE [{schema}].[doc__tbl] ADD  CONSTRAINT [df_doc__tbl_cust_id]  DEFAULT (NULL) FOR [cust_id]
GO
ALTER TABLE [{schema}].[doc__tbl] ADD  CONSTRAINT [df_doc__tbl_item_id]  DEFAULT (NULL) FOR [item_id]
GO
ALTER TABLE [{schema}].[doc__tbl] ADD  CONSTRAINT [df_doc__tbl_doc_sts]  DEFAULT (N'A') FOR [doc_sts]
GO
ALTER TABLE [{schema}].[doc__tbl] ADD  CONSTRAINT [df_doc__tbl_doc_etstmp]  DEFAULT ([{schema}].[my_now]()) FOR [doc_etstmp]
GO
ALTER TABLE [{schema}].[doc__tbl] ADD  CONSTRAINT [df_doc__tbl_doc_euser]  DEFAULT ([{schema}].[my_db_user]()) FOR [doc_euser]
GO
ALTER TABLE [{schema}].[doc__tbl] ADD  CONSTRAINT [df_doc__tbl_doc_mtstmp]  DEFAULT ([{schema}].[my_now]()) FOR [doc_mtstmp]
GO
ALTER TABLE [{schema}].[doc__tbl] ADD  CONSTRAINT [df_doc__tbl_doc_muser]  DEFAULT ([{schema}].[my_db_user]()) FOR [doc_muser]
GO
ALTER TABLE [{schema}].[doc__tbl] ADD  CONSTRAINT [df_doc__tbl_doc_uptstmp]  DEFAULT ([{schema}].[my_now]()) FOR [doc_uptstmp]
GO
ALTER TABLE [{schema}].[doc__tbl] ADD  CONSTRAINT [df_doc__tbl_doc_upuser]  DEFAULT ([{schema}].[my_db_user]()) FOR [doc_upuser]
GO
ALTER TABLE [{schema}].[code_app] ADD  CONSTRAINT [df_code_app_code_app_Edt]  DEFAULT ([{schema}].[my_now]()) FOR [code_h_etstmp]
GO
ALTER TABLE [{schema}].[code_app] ADD  CONSTRAINT [df_code_app_code_app_euser]  DEFAULT ([{schema}].[my_db_user]()) FOR [code_h_euser]
GO
ALTER TABLE [{schema}].[code_app] ADD  CONSTRAINT [df_code_app_code_app_MDt]  DEFAULT ([{schema}].[my_now]()) FOR [code_h_mtstmp]
GO
ALTER TABLE [{schema}].[code_app] ADD  CONSTRAINT [df_code_app_code_app_muser]  DEFAULT ([{schema}].[my_db_user]()) FOR [code_h_muser]
GO
ALTER TABLE [{schema}].[code2_doc_scope_doc_ctgr] ADD  CONSTRAINT [df_code2_doc_scope_doc_ctgr_code_etstmp]  DEFAULT ([{schema}].[my_now]()) FOR [code_etstmp]
GO
ALTER TABLE [{schema}].[code2_doc_scope_doc_ctgr] ADD  CONSTRAINT [df_code2_doc_scope_doc_ctgr_code_euser]  DEFAULT ([{schema}].[my_db_user]()) FOR [code_euser]
GO
ALTER TABLE [{schema}].[code2_doc_scope_doc_ctgr] ADD  CONSTRAINT [df_code2_doc_scope_doc_ctgr_code_mtstmp]  DEFAULT ([{schema}].[my_now]()) FOR [code_mtstmp]
GO
ALTER TABLE [{schema}].[code2_doc_scope_doc_ctgr] ADD  CONSTRAINT [df_code2_doc_scope_doc_ctgr_code_muser]  DEFAULT ([{schema}].[my_db_user]()) FOR [code_muser]
GO
ALTER TABLE [{schema}].[code2_app] ADD  CONSTRAINT [df_code2_app_code2_app_Edt]  DEFAULT ([{schema}].[my_now]()) FOR [code_h_etstmp]
GO
ALTER TABLE [{schema}].[code2_app] ADD  CONSTRAINT [df_code2_app_code2_app_euser]  DEFAULT ([{schema}].[my_db_user]()) FOR [code_h_euser]
GO
ALTER TABLE [{schema}].[code2_app] ADD  CONSTRAINT [df_code2_app_code2_app_MDt]  DEFAULT ([{schema}].[my_now]()) FOR [code_h_mtstmp]
GO
ALTER TABLE [{schema}].[code2_app] ADD  CONSTRAINT [df_code2_app_code2_app_muser]  DEFAULT ([{schema}].[my_db_user]()) FOR [code_h_muser]
GO
ALTER TABLE [{schema}].[param_app] ADD  CONSTRAINT [df_param_app_param_app_etstmp]  DEFAULT ([{schema}].[my_now]()) FOR [param_app_etstmp]
GO
ALTER TABLE [{schema}].[param_app] ADD  CONSTRAINT [df_param_app_param_app_euser]  DEFAULT ([{schema}].[my_db_user]()) FOR [param_app_euser]
GO
ALTER TABLE [{schema}].[param_app] ADD  CONSTRAINT [df_param_app_param_app_mtstmp]  DEFAULT ([{schema}].[my_now]()) FOR [param_app_mtstmp]
GO
ALTER TABLE [{schema}].[param_app] ADD  CONSTRAINT [df_param_app_param_app_muser]  DEFAULT ([{schema}].[my_db_user]()) FOR [param_app_muser]
GO
ALTER TABLE [{schema}].[help__tbl] ADD  CONSTRAINT [df_help__tbl_help_etstmp]  DEFAULT ([{schema}].[my_now]()) FOR [help_etstmp]
GO
ALTER TABLE [{schema}].[help__tbl] ADD  CONSTRAINT [df_help__tbl_help_euser]  DEFAULT ([{schema}].[my_db_user]()) FOR [help_euser]
GO
ALTER TABLE [{schema}].[help__tbl] ADD  CONSTRAINT [df_help__tbl_help_mtstmp]  DEFAULT ([{schema}].[my_now]()) FOR [help_mtstmp]
GO
ALTER TABLE [{schema}].[help__tbl] ADD  CONSTRAINT [df_help__tbl_help_muser]  DEFAULT ([{schema}].[my_db_user]()) FOR [help_muser]
GO
ALTER TABLE [{schema}].[help__tbl] ADD  CONSTRAINT [df_help__tbl_help_listing_main]  DEFAULT ((1)) FOR [help_listing_main]
GO
ALTER TABLE [{schema}].[help__tbl] ADD  CONSTRAINT [df_help__tbl_help_listing_client]  DEFAULT ((1)) FOR [help_listing_client]
GO
ALTER TABLE [{schema}].[note__tbl] ADD  CONSTRAINT [df_note__tbl_note_scope]  DEFAULT (N'S') FOR [note_scope]
GO
ALTER TABLE [{schema}].[note__tbl] ADD  CONSTRAINT [df_note__tbl_note_scope_id]  DEFAULT ((0)) FOR [note_scope_id]
GO
ALTER TABLE [{schema}].[note__tbl] ADD  CONSTRAINT [df_note__tbl_note_sts]  DEFAULT ('A') FOR [note_sts]
GO
ALTER TABLE [{schema}].[note__tbl] ADD  CONSTRAINT [df_note__tbl_cust_id]  DEFAULT (NULL) FOR [cust_id]
GO
ALTER TABLE [{schema}].[note__tbl] ADD  CONSTRAINT [df_note__tbl_item_id]  DEFAULT (NULL) FOR [item_id]
GO
ALTER TABLE [{schema}].[note__tbl] ADD  CONSTRAINT [df_note__tbl_note_etstmp]  DEFAULT ([{schema}].[my_now]()) FOR [note_etstmp]
GO
ALTER TABLE [{schema}].[note__tbl] ADD  CONSTRAINT [df_note__tbl_note_euser]  DEFAULT ([{schema}].[my_db_user]()) FOR [note_euser]
GO
ALTER TABLE [{schema}].[note__tbl] ADD  CONSTRAINT [df_note__tbl_note_mtstmp]  DEFAULT ([{schema}].[my_now]()) FOR [note_mtstmp]
GO
ALTER TABLE [{schema}].[note__tbl] ADD  CONSTRAINT [df_note__tbl_note_muser]  DEFAULT ([{schema}].[my_db_user]()) FOR [note_muser]
GO
ALTER TABLE [{schema}].[sys_user] ADD  CONSTRAINT [df_sys_user_sys_user_sts]  DEFAULT (N'ACTIVE') FOR [sys_user_sts]
GO
ALTER TABLE [{schema}].[sys_user] ADD  CONSTRAINT [df_sys_user_sys_user_stsdt]  DEFAULT ([{schema}].[my_today]()) FOR [sys_user_stsdt]
GO
ALTER TABLE [{schema}].[sys_user] ADD  CONSTRAINT [df_sys_user_sys_user_country]  DEFAULT ('USA') FOR [sys_user_country]
GO
ALTER TABLE [{schema}].[sys_user] ADD  CONSTRAINT [df_sys_user_sys_user_startdt]  DEFAULT ([{schema}].[my_now]()) FOR [sys_user_startdt]
GO
ALTER TABLE [{schema}].[sys_user] ADD  CONSTRAINT [df_sys_user_sys_user_etstmp]  DEFAULT ([{schema}].[my_now]()) FOR [sys_user_etstmp]
GO
ALTER TABLE [{schema}].[sys_user] ADD  CONSTRAINT [df_sys_user_sys_user_euser]  DEFAULT ([{schema}].[my_db_user]()) FOR [sys_user_euser]
GO
ALTER TABLE [{schema}].[sys_user] ADD  CONSTRAINT [df_sys_user_sys_user_mtstmp]  DEFAULT ([{schema}].[my_now]()) FOR [sys_user_mtstmp]
GO
ALTER TABLE [{schema}].[sys_user] ADD  CONSTRAINT [df_sys_user_sys_user_muser]  DEFAULT ([{schema}].[my_db_user]()) FOR [sys_user_muser]
GO
ALTER TABLE [{schema}].[sys_user] ADD  CONSTRAINT [df_sys_user_sys_user_hash]  DEFAULT ((0)) FOR [sys_user_hash]
GO
ALTER TABLE [{schema}].[param__tbl] ADD  CONSTRAINT [df_param__tbl_is_param_app]  DEFAULT ((0)) FOR [is_param_app]
GO
ALTER TABLE [{schema}].[param__tbl] ADD  CONSTRAINT [df_param__tbl_is_param_user]  DEFAULT ((0)) FOR [is_param_user]
GO
ALTER TABLE [{schema}].[param__tbl] ADD  CONSTRAINT [df_param__tbl_is_param_sys]  DEFAULT ((0)) FOR [is_param_sys]
GO
ALTER TABLE [{schema}].[param__tbl] ADD  CONSTRAINT [df_param__tbl_param_etstmp]  DEFAULT ([{schema}].[my_now]()) FOR [param_etstmp]
GO
ALTER TABLE [{schema}].[param__tbl] ADD  CONSTRAINT [df_param__tbl_param__tbl_euser]  DEFAULT ([{schema}].[my_db_user]()) FOR [param_euser]
GO
ALTER TABLE [{schema}].[param__tbl] ADD  CONSTRAINT [df_param__tbl_param_mtstmp]  DEFAULT ([{schema}].[my_now]()) FOR [param_mtstmp]
GO
ALTER TABLE [{schema}].[param__tbl] ADD  CONSTRAINT [df_param__tbl_param__tbl_muser]  DEFAULT ([{schema}].[my_db_user]()) FOR [param_muser]
GO
ALTER TABLE [{schema}].[param_user] ADD  CONSTRAINT [df_param_user_param_user_etstmp]  DEFAULT ([{schema}].[my_now]()) FOR [param_user_etstmp]
GO
ALTER TABLE [{schema}].[param_user] ADD  CONSTRAINT [df_param_user_param_user_euser]  DEFAULT ([{schema}].[my_db_user]()) FOR [param_user_euser]
GO
ALTER TABLE [{schema}].[param_user] ADD  CONSTRAINT [df_param_user_param_user_mtstmp]  DEFAULT ([{schema}].[my_now]()) FOR [param_user_mtstmp]
GO
ALTER TABLE [{schema}].[param_user] ADD  CONSTRAINT [df_param_user_param_user_muser]  DEFAULT ([{schema}].[my_db_user]()) FOR [param_user_muser]
GO
ALTER TABLE [{schema}].[queue__tbl] ADD  CONSTRAINT [df_queue__tbl_queue_etstmp]  DEFAULT ([{schema}].[my_now]()) FOR [queue_etstmp]
GO
ALTER TABLE [{schema}].[queue__tbl] ADD  CONSTRAINT [df_queue__tbl_queue_euser]  DEFAULT ([{schema}].[my_db_user]()) FOR [queue_euser]
GO
ALTER TABLE [{schema}].[job__tbl] ADD  CONSTRAINT [df_job__tbl_job_etstmp]  DEFAULT ([{schema}].[my_now]()) FOR [job_etstmp]
GO
ALTER TABLE [{schema}].[job__tbl] ADD  CONSTRAINT [df_job__tbl_job_user]  DEFAULT ([{schema}].[my_db_user]()) FOR [job_user]
GO
ALTER TABLE [{schema}].[sys_func] ADD  CONSTRAINT [df_sys_func_sys_func_sts]  DEFAULT ('ACTIVE') FOR [sys_func_sts]
GO
ALTER TABLE [{schema}].[menu__tbl] ADD  CONSTRAINT [df_menu__tbl_menu_group]  DEFAULT ('S') FOR [menu_group]
GO
ALTER TABLE [{schema}].[menu__tbl] ADD  CONSTRAINT [df_menu__tbl_menu_sts]  DEFAULT ('ACTIVE') FOR [menu_sts]
GO
ALTER TABLE [{schema}].[sys_role] ADD  CONSTRAINT [df_sys_role_sys_role_sts]  DEFAULT ('ACTIVE') FOR [sys_role_sts]
GO
ALTER TABLE [{schema}].[txt__tbl] ADD  CONSTRAINT [df_txt__tbl_txt_type]  DEFAULT ('TEXT') FOR [txt_type]
GO
ALTER TABLE [{schema}].[txt__tbl] ADD  CONSTRAINT [df_txt__tbl_txt_etstmp]  DEFAULT ([{schema}].[my_now]()) FOR [txt_etstmp]
GO
ALTER TABLE [{schema}].[txt__tbl] ADD  CONSTRAINT [df_txt__tbl_txt_euser]  DEFAULT ([{schema}].[my_db_user]()) FOR [txt_euser]
GO
ALTER TABLE [{schema}].[txt__tbl] ADD  CONSTRAINT [df_txt__tbl_txt_mtstmp]  DEFAULT ([{schema}].[my_now]()) FOR [txt_mtstmp]
GO
ALTER TABLE [{schema}].[txt__tbl] ADD  CONSTRAINT [df_txt__tbl_txt_muser]  DEFAULT ([{schema}].[my_db_user]()) FOR [txt_muser]
GO
ALTER TABLE [{schema}].[code_ac] ADD  CONSTRAINT [df_code_ac_code_etstmp]  DEFAULT ([{schema}].[my_now]()) FOR [code_etstmp]
GO
ALTER TABLE [{schema}].[code_ac] ADD  CONSTRAINT [df_code_ac_code_euser]  DEFAULT ([{schema}].[my_db_user]()) FOR [code_euser]
GO
ALTER TABLE [{schema}].[code_ac] ADD  CONSTRAINT [df_code_ac_code_mtstmp]  DEFAULT ([{schema}].[my_now]()) FOR [code_mtstmp]
GO
ALTER TABLE [{schema}].[code_ac] ADD  CONSTRAINT [df_code_ac_code_muser]  DEFAULT ([{schema}].[my_db_user]()) FOR [code_muser]
GO
ALTER TABLE [{schema}].[code_ac1] ADD  CONSTRAINT [df_code_ac1_code_etstmp]  DEFAULT ([{schema}].[my_now]()) FOR [code_etstmp]
GO
ALTER TABLE [{schema}].[code_ac1] ADD  CONSTRAINT [df_code_ac1_code_euser]  DEFAULT ([{schema}].[my_db_user]()) FOR [code_euser]
GO
ALTER TABLE [{schema}].[code_ac1] ADD  CONSTRAINT [df_code_ac1_code_mtstmp]  DEFAULT ([{schema}].[my_now]()) FOR [code_mtstmp]
GO
ALTER TABLE [{schema}].[code_ac1] ADD  CONSTRAINT [df_code_ac1_code_muser]  DEFAULT ([{schema}].[my_db_user]()) FOR [code_muser]
GO
ALTER TABLE [{schema}].[code_ahc] ADD  CONSTRAINT [df_code_ahc_code_etstmp]  DEFAULT ([{schema}].[my_now]()) FOR [code_etstmp]
GO
ALTER TABLE [{schema}].[code_ahc] ADD  CONSTRAINT [df_code_ahc_code_euser]  DEFAULT ([{schema}].[my_db_user]()) FOR [code_euser]
GO
ALTER TABLE [{schema}].[code_ahc] ADD  CONSTRAINT [df_code_ahc_code_mtstmp]  DEFAULT ([{schema}].[my_now]()) FOR [code_mtstmp]
GO
ALTER TABLE [{schema}].[code_ahc] ADD  CONSTRAINT [df_code_ahc_code_muser]  DEFAULT ([{schema}].[my_db_user]()) FOR [code_muser]
GO
ALTER TABLE [{schema}].[code_country] ADD  CONSTRAINT [df_code_country_code_etstmp]  DEFAULT ([{schema}].[my_now]()) FOR [code_etstmp]
GO
ALTER TABLE [{schema}].[code_country] ADD  CONSTRAINT [df_code_country_code_euser]  DEFAULT ([{schema}].[my_db_user]()) FOR [code_euser]
GO
ALTER TABLE [{schema}].[code_country] ADD  CONSTRAINT [df_code_country_code_mtstmp]  DEFAULT ([{schema}].[my_now]()) FOR [code_mtstmp]
GO
ALTER TABLE [{schema}].[code_country] ADD  CONSTRAINT [df_code_country_code_muser]  DEFAULT ([{schema}].[my_db_user]()) FOR [code_muser]
GO
ALTER TABLE [{schema}].[code_doc_scope] ADD  CONSTRAINT [df_code_doc_scope_code_etstmp]  DEFAULT ([{schema}].[my_now]()) FOR [code_etstmp]
GO
ALTER TABLE [{schema}].[code_doc_scope] ADD  CONSTRAINT [df_code_doc_scope_code_euser]  DEFAULT ([{schema}].[my_db_user]()) FOR [code_euser]
GO
ALTER TABLE [{schema}].[code_doc_scope] ADD  CONSTRAINT [df_code_doc_scope_code_mtstmp]  DEFAULT ([{schema}].[my_now]()) FOR [code_mtstmp]
GO
ALTER TABLE [{schema}].[code_doc_scope] ADD  CONSTRAINT [df_code_doc_scope_code_muser]  DEFAULT ([{schema}].[my_db_user]()) FOR [code_muser]
GO
:if:separate_code_type_tables:
ALTER TABLE [{schema}].[code_sys] ADD  CONSTRAINT [df_code_sys_code_h_etstmp]  DEFAULT ([{schema}].[my_now]()) FOR [code_h_etstmp]
GO
ALTER TABLE [{schema}].[code_sys] ADD  CONSTRAINT [df_code_sys_code_h_euser]  DEFAULT ([{schema}].[my_db_user]()) FOR [code_h_euser]
GO
ALTER TABLE [{schema}].[code_sys] ADD  CONSTRAINT [df_code_sys_code_h_mtstmp]  DEFAULT ([{schema}].[my_now]()) FOR [code_h_mtstmp]
GO
ALTER TABLE [{schema}].[code_sys] ADD  CONSTRAINT [df_code_sys_code_h_muser]  DEFAULT ([{schema}].[my_db_user]()) FOR [code_h_muser]
GO
:endif:
ALTER TABLE [{schema}].[code_note_scope] ADD  CONSTRAINT [df_code_note_scope_code_etstmp]  DEFAULT ([{schema}].[my_now]()) FOR [code_etstmp]
GO
ALTER TABLE [{schema}].[code_note_scope] ADD  CONSTRAINT [df_code_note_scope_code_euser]  DEFAULT ([{schema}].[my_db_user]()) FOR [code_euser]
GO
ALTER TABLE [{schema}].[code_note_scope] ADD  CONSTRAINT [df_code_note_scope_code_mtstmp]  DEFAULT ([{schema}].[my_now]()) FOR [code_mtstmp]
GO
ALTER TABLE [{schema}].[code_note_scope] ADD  CONSTRAINT [df_code_note_scope_code_muser]  DEFAULT ([{schema}].[my_db_user]()) FOR [code_muser]
GO
ALTER TABLE [{schema}].[code_note_type] ADD  CONSTRAINT [df_code_note_type_code_etstmp]  DEFAULT ([{schema}].[my_now]()) FOR [code_etstmp]
GO
ALTER TABLE [{schema}].[code_note_type] ADD  CONSTRAINT [df_code_note_type_code_euser]  DEFAULT ([{schema}].[my_db_user]()) FOR [code_euser]
GO
ALTER TABLE [{schema}].[code_note_type] ADD  CONSTRAINT [df_code_note_type_code_mtstmp]  DEFAULT ([{schema}].[my_now]()) FOR [code_mtstmp]
GO
ALTER TABLE [{schema}].[code_note_type] ADD  CONSTRAINT [df_code_note_type_code_muser]  DEFAULT ([{schema}].[my_db_user]()) FOR [code_muser]
GO
ALTER TABLE [{schema}].[code_param_type] ADD  CONSTRAINT [df_code_param_type_code_etstmp]  DEFAULT ([{schema}].[my_now]()) FOR [code_etstmp]
GO
ALTER TABLE [{schema}].[code_param_type] ADD  CONSTRAINT [df_code_param_type_code_euser]  DEFAULT ([{schema}].[my_db_user]()) FOR [code_euser]
GO
ALTER TABLE [{schema}].[code_param_type] ADD  CONSTRAINT [df_code_param_type_code_mtstmp]  DEFAULT ([{schema}].[my_now]()) FOR [code_mtstmp]
GO
ALTER TABLE [{schema}].[code_param_type] ADD  CONSTRAINT [df_code_param_type_code_muser]  DEFAULT ([{schema}].[my_db_user]()) FOR [code_muser]
GO
ALTER TABLE [{schema}].[code_job_action] ADD  CONSTRAINT [df_code_job_action_code_etstmp]  DEFAULT ([{schema}].[my_now]()) FOR [code_etstmp]
GO
ALTER TABLE [{schema}].[code_job_action] ADD  CONSTRAINT [df_code_job_action_code_euser]  DEFAULT ([{schema}].[my_db_user]()) FOR [code_euser]
GO
ALTER TABLE [{schema}].[code_job_action] ADD  CONSTRAINT [df_code_job_action_code_mtstmp]  DEFAULT ([{schema}].[my_now]()) FOR [code_mtstmp]
GO
ALTER TABLE [{schema}].[code_job_action] ADD  CONSTRAINT [df_code_job_action_code_muser]  DEFAULT ([{schema}].[my_db_user]()) FOR [code_muser]
GO
ALTER TABLE [{schema}].[code_job_source] ADD  CONSTRAINT [df_code_job_source_code_etstmp]  DEFAULT ([{schema}].[my_now]()) FOR [code_etstmp]
GO
ALTER TABLE [{schema}].[code_job_source] ADD  CONSTRAINT [df_code_job_source_code_euser]  DEFAULT ([{schema}].[my_db_user]()) FOR [code_euser]
GO
ALTER TABLE [{schema}].[code_job_source] ADD  CONSTRAINT [df_code_job_source_code_mtstmp]  DEFAULT ([{schema}].[my_now]()) FOR [code_mtstmp]
GO
ALTER TABLE [{schema}].[code_job_source] ADD  CONSTRAINT [df_code_job_source_code_muser]  DEFAULT ([{schema}].[my_db_user]()) FOR [code_muser]
GO
ALTER TABLE [{schema}].[code_txt_type] ADD  CONSTRAINT [df_code_txt_type_code_etstmp]  DEFAULT ([{schema}].[my_now]()) FOR [code_etstmp]
GO
ALTER TABLE [{schema}].[code_txt_type] ADD  CONSTRAINT [df_code_txt_type_code_euser]  DEFAULT ([{schema}].[my_db_user]()) FOR [code_euser]
GO
ALTER TABLE [{schema}].[code_txt_type] ADD  CONSTRAINT [df_code_txt_type_code_mtstmp]  DEFAULT ([{schema}].[my_now]()) FOR [code_mtstmp]
GO
ALTER TABLE [{schema}].[code_txt_type] ADD  CONSTRAINT [df_code_txt_type_code_muser]  DEFAULT ([{schema}].[my_db_user]()) FOR [code_muser]
GO
ALTER TABLE [{schema}].[code_version_sts] ADD  CONSTRAINT [df_code_version_sts_code_etstmp]  DEFAULT ([{schema}].[my_now]()) FOR [code_etstmp]
GO
ALTER TABLE [{schema}].[code_version_sts] ADD  CONSTRAINT [df_code_version_sts_code_euser]  DEFAULT ([{schema}].[my_db_user]()) FOR [code_euser]
GO
ALTER TABLE [{schema}].[code_version_sts] ADD  CONSTRAINT [df_code_version_sts_code_mtstmp]  DEFAULT ([{schema}].[my_now]()) FOR [code_mtstmp]
GO
ALTER TABLE [{schema}].[code_version_sts] ADD  CONSTRAINT [df_code_version_sts_code_muser]  DEFAULT ([{schema}].[my_db_user]()) FOR [code_muser]
GO
ALTER TABLE [{schema}].[code2_country_state] ADD  CONSTRAINT [df_code2_country_state_code_etstmp]  DEFAULT ([{schema}].[my_now]()) FOR [code_etstmp]
GO
ALTER TABLE [{schema}].[code2_country_state] ADD  CONSTRAINT [df_code2_country_state_code_euser]  DEFAULT ([{schema}].[my_db_user]()) FOR [code_euser]
GO
ALTER TABLE [{schema}].[code2_country_state] ADD  CONSTRAINT [df_code2_country_state_code_mtstmp]  DEFAULT ([{schema}].[my_now]()) FOR [code_mtstmp]
GO
ALTER TABLE [{schema}].[code2_country_state] ADD  CONSTRAINT [df_code2_country_state_code_muser]  DEFAULT ([{schema}].[my_db_user]()) FOR [code_muser]
GO
:if:separate_code_type_tables:
ALTER TABLE [{schema}].[code2_sys] ADD  CONSTRAINT [df_code2_sys_code2_sys_Edt]  DEFAULT ([{schema}].[my_now]()) FOR [code_h_etstmp]
GO
ALTER TABLE [{schema}].[code2_sys] ADD  CONSTRAINT [df_code2_sys_code2_sys_euser]  DEFAULT ([{schema}].[my_db_user]()) FOR [code_h_euser]
GO
ALTER TABLE [{schema}].[code2_sys] ADD  CONSTRAINT [df_code2_sys_code2_sys_MDt]  DEFAULT ([{schema}].[my_now]()) FOR [code_h_mtstmp]
GO
ALTER TABLE [{schema}].[code2_sys] ADD  CONSTRAINT [df_code2_sys_code2_sys_muser]  DEFAULT ([{schema}].[my_db_user]()) FOR [code_h_muser]
GO
:endif:
ALTER TABLE [{schema}].[version__tbl] ADD  CONSTRAINT [df_version__tbl_version_no_major]  DEFAULT ((0)) FOR [version_no_major]
GO
ALTER TABLE [{schema}].[version__tbl] ADD  CONSTRAINT [df_version__tbl_version_no_minor]  DEFAULT ((0)) FOR [version_no_minor]
GO
ALTER TABLE [{schema}].[version__tbl] ADD  CONSTRAINT [df_version__tbl_version_no_build]  DEFAULT ((0)) FOR [version_no_build]
GO
ALTER TABLE [{schema}].[version__tbl] ADD  CONSTRAINT [df_version__tbl_version_no_rev]  DEFAULT ((0)) FOR [version_no_rev]
GO
ALTER TABLE [{schema}].[version__tbl] ADD  CONSTRAINT [df_version__tbl_version_sts]  DEFAULT ('OK') FOR [version_sts]
GO
ALTER TABLE [{schema}].[version__tbl] ADD  CONSTRAINT [df_version__tbl_version_etstmp]  DEFAULT ([{schema}].[my_now]()) FOR [version_etstmp]
GO
ALTER TABLE [{schema}].[version__tbl] ADD  CONSTRAINT [df_version__tbl_version_euser]  DEFAULT ([{schema}].[my_db_user]()) FOR [version_euser]
GO
ALTER TABLE [{schema}].[version__tbl] ADD  CONSTRAINT [df_version__tbl_version_mtstmp]  DEFAULT ([{schema}].[my_now]()) FOR [version_mtstmp]
GO
ALTER TABLE [{schema}].[version__tbl] ADD  CONSTRAINT [df_version__tbl_version_muser]  DEFAULT ([{schema}].[my_db_user]()) FOR [version_muser]
GO
ALTER TABLE [{schema}].[param_sys] ADD  CONSTRAINT [df_param_sys_param_sys_etstmp]  DEFAULT ([{schema}].[my_now]()) FOR [param_sys_etstmp]
GO
ALTER TABLE [{schema}].[param_sys] ADD  CONSTRAINT [df_param_sys_param_sys_euser]  DEFAULT ([{schema}].[my_db_user]()) FOR [param_sys_euser]
GO
ALTER TABLE [{schema}].[param_sys] ADD  CONSTRAINT [df_param_sys_param_sys_mtstmp]  DEFAULT ([{schema}].[my_now]()) FOR [param_sys_mtstmp]
GO
ALTER TABLE [{schema}].[param_sys] ADD  CONSTRAINT [df_param_sys_param_sys_muser]  DEFAULT ([{schema}].[my_db_user]()) FOR [param_sys_muser]
GO
ALTER TABLE [{schema}].[audit_detail]  WITH CHECK ADD  CONSTRAINT [fk_audit_detail_audit__tbl] FOREIGN KEY([audit_seq])
REFERENCES [{schema}].[audit__tbl] ([audit_seq])
GO
ALTER TABLE [{schema}].[audit_detail] CHECK CONSTRAINT [fk_audit_detail_audit__tbl]
GO
ALTER TABLE [{schema}].[doc__tbl]  WITH CHECK ADD  CONSTRAINT [fk_doc__tbl_code2_doc_scope_doc_ctgr] FOREIGN KEY([doc_scope], [doc_ctgr])
REFERENCES [{schema}].[code2_doc_scope_doc_ctgr] ([code_val1], [code_val2])
GO
ALTER TABLE [{schema}].[doc__tbl] CHECK CONSTRAINT [fk_doc__tbl_code2_doc_scope_doc_ctgr]
GO
ALTER TABLE [{schema}].[doc__tbl]  WITH CHECK ADD  CONSTRAINT [fk_doc__tbl_code_doc_scope] FOREIGN KEY([doc_scope])
REFERENCES [{schema}].[code_doc_scope] ([code_val])
GO
ALTER TABLE [{schema}].[doc__tbl] CHECK CONSTRAINT [fk_doc__tbl_code_doc_scope]
GO
ALTER TABLE [{schema}].[param_app]  WITH CHECK ADD  CONSTRAINT [fk_param_app_param__tbl] FOREIGN KEY([param_app_process], [param_app_attrib])
REFERENCES [{schema}].[param__tbl] ([param_process], [param_attrib])
GO
ALTER TABLE [{schema}].[param_app] CHECK CONSTRAINT [fk_param_app_param__tbl]
GO
ALTER TABLE [{schema}].[help__tbl]  WITH CHECK ADD  CONSTRAINT [fk_help__tbl_help_target] FOREIGN KEY([help_target_id])
REFERENCES [{schema}].[help_target] ([help_target_id])
GO
ALTER TABLE [{schema}].[help__tbl] CHECK CONSTRAINT [fk_help__tbl_help_target]
GO
ALTER TABLE [{schema}].[note__tbl]  WITH CHECK ADD  CONSTRAINT [fk_note__tbl_code_ac1] FOREIGN KEY([note_sts])
REFERENCES [{schema}].[code_ac1] ([code_val])
GO
ALTER TABLE [{schema}].[note__tbl] CHECK CONSTRAINT [fk_note__tbl_code_ac1]
GO
ALTER TABLE [{schema}].[note__tbl]  WITH CHECK ADD  CONSTRAINT [fk_note__tbl_code_note_scope] FOREIGN KEY([note_scope])
REFERENCES [{schema}].[code_note_scope] ([code_val])
GO
ALTER TABLE [{schema}].[note__tbl] CHECK CONSTRAINT [fk_note__tbl_code_note_scope]
GO
ALTER TABLE [{schema}].[note__tbl]  WITH CHECK ADD  CONSTRAINT [fk_note__tbl_code_note_type] FOREIGN KEY([note_type])
REFERENCES [{schema}].[code_note_type] ([code_val])
GO
ALTER TABLE [{schema}].[note__tbl] CHECK CONSTRAINT [fk_note__tbl_code_note_type]
GO
ALTER TABLE [{schema}].[sys_user]  WITH CHECK ADD  CONSTRAINT [fk_sys_user_code_ahc] FOREIGN KEY([sys_user_sts])
REFERENCES [{schema}].[code_ahc] ([code_val])
GO
ALTER TABLE [{schema}].[sys_user] CHECK CONSTRAINT [fk_sys_user_code_ahc]
GO
ALTER TABLE [{schema}].[sys_user]  WITH CHECK ADD  CONSTRAINT [fk_sys_user_code_country] FOREIGN KEY([sys_user_country])
REFERENCES [{schema}].[code_country] ([code_val])
GO
ALTER TABLE [{schema}].[sys_user] CHECK CONSTRAINT [fk_sys_user_code_country]
GO
ALTER TABLE [{schema}].[sys_user]  WITH CHECK ADD  CONSTRAINT [fk_sys_user_code2_country_state] FOREIGN KEY([sys_user_country], [sys_user_state])
REFERENCES [{schema}].[code2_country_state] ([code_val1], [code_val2])
GO
ALTER TABLE [{schema}].[sys_user] CHECK CONSTRAINT [fk_sys_user_code2_country_state]
GO
ALTER TABLE [{schema}].[param__tbl]  WITH CHECK ADD  CONSTRAINT [fk_param__tbl_code_param_type] FOREIGN KEY([param_type])
REFERENCES [{schema}].[code_param_type] ([code_val])
GO
ALTER TABLE [{schema}].[param__tbl] CHECK CONSTRAINT [fk_param__tbl_code_param_type]
GO
ALTER TABLE [{schema}].[param_user]  WITH CHECK ADD  CONSTRAINT [fk_param_user_sys_user] FOREIGN KEY([sys_user_id])
REFERENCES [{schema}].[sys_user] ([sys_user_id])
ON DELETE CASCADE
GO
ALTER TABLE [{schema}].[param_user] CHECK CONSTRAINT [fk_param_user_sys_user]
GO
ALTER TABLE [{schema}].[param_user]  WITH CHECK ADD  CONSTRAINT [fk_param_user_param__tbl] FOREIGN KEY([param_user_process], [param_user_attrib])
REFERENCES [{schema}].[param__tbl] ([param_process], [param_attrib])
ON DELETE CASCADE
GO
ALTER TABLE [{schema}].[param_user] CHECK CONSTRAINT [fk_param_user_param__tbl]
GO
ALTER TABLE [{schema}].[job__tbl]  WITH CHECK ADD  CONSTRAINT [fk_job__tbl_code_job_action] FOREIGN KEY([job_action])
REFERENCES [{schema}].[code_job_action] ([code_val])
GO
ALTER TABLE [{schema}].[job__tbl] CHECK CONSTRAINT [fk_job__tbl_code_job_action]
GO
ALTER TABLE [{schema}].[job__tbl]  WITH CHECK ADD  CONSTRAINT [fk_job__tbl_code_job_source] FOREIGN KEY([job_source])
REFERENCES [{schema}].[code_job_source] ([code_val])
GO
ALTER TABLE [{schema}].[job__tbl] CHECK CONSTRAINT [fk_job__tbl_code_job_source]
GO
ALTER TABLE [{schema}].[job_doc]  WITH CHECK ADD  CONSTRAINT [fk_job_doc_job__tbl] FOREIGN KEY([job_id])
REFERENCES [{schema}].[job__tbl] ([job_id])
GO
ALTER TABLE [{schema}].[job_doc] CHECK CONSTRAINT [fk_job_doc_job__tbl]
GO
ALTER TABLE [{schema}].[job_email]  WITH CHECK ADD  CONSTRAINT [fk_job_email_job__tbl] FOREIGN KEY([job_id])
REFERENCES [{schema}].[job__tbl] ([job_id])
GO
ALTER TABLE [{schema}].[job_email] CHECK CONSTRAINT [fk_job_email_job__tbl]
GO
ALTER TABLE [{schema}].[job_note]  WITH CHECK ADD  CONSTRAINT [fk_job_note_job__tbl] FOREIGN KEY([job_id])
REFERENCES [{schema}].[job__tbl] ([job_id])
GO
ALTER TABLE [{schema}].[job_note] CHECK CONSTRAINT [fk_job_note_job__tbl]
GO
ALTER TABLE [{schema}].[job_queue]  WITH CHECK ADD  CONSTRAINT [fk_job_queue_job__tbl] FOREIGN KEY([job_id])
REFERENCES [{schema}].[job__tbl] ([job_id])
GO
ALTER TABLE [{schema}].[job_queue] CHECK CONSTRAINT [fk_job_queue_job__tbl]
GO
ALTER TABLE [{schema}].[job_sms]  WITH CHECK ADD  CONSTRAINT [fk_job_sms_job__tbl] FOREIGN KEY([job_id])
REFERENCES [{schema}].[job__tbl] ([job_id])
GO
ALTER TABLE [{schema}].[job_sms] CHECK CONSTRAINT [fk_job_sms_job__tbl]
GO
ALTER TABLE [{schema}].[sys_func]  WITH CHECK ADD  CONSTRAINT [fk_sys_func_code_ahc] FOREIGN KEY([sys_func_sts])
REFERENCES [{schema}].[code_ahc] ([code_val])
GO
ALTER TABLE [{schema}].[sys_func] CHECK CONSTRAINT [fk_sys_func_code_ahc]
GO
ALTER TABLE [{schema}].[menu__tbl]  WITH CHECK ADD  CONSTRAINT [fk_menu__tbl_menu__tbl] FOREIGN KEY([menu_id_parent])
REFERENCES [{schema}].[menu__tbl] ([menu_id])
GO
ALTER TABLE [{schema}].[menu__tbl] CHECK CONSTRAINT [fk_menu__tbl_menu__tbl]
GO
ALTER TABLE [{schema}].[menu__tbl]  WITH CHECK ADD  CONSTRAINT [fk_menu__tbl_code_ahc] FOREIGN KEY([menu_sts])
REFERENCES [{schema}].[code_ahc] ([code_val])
GO
ALTER TABLE [{schema}].[menu__tbl] CHECK CONSTRAINT [fk_menu__tbl_code_ahc]
GO
ALTER TABLE [{schema}].[sys_user_func]  WITH CHECK ADD  CONSTRAINT [fk_sys_user_func_sys_user] FOREIGN KEY([sys_user_id])
REFERENCES [{schema}].[sys_user] ([sys_user_id])
ON DELETE CASCADE
GO
ALTER TABLE [{schema}].[sys_user_func] CHECK CONSTRAINT [fk_sys_user_func_sys_user]
GO
ALTER TABLE [{schema}].[sys_user_func]  WITH CHECK ADD  CONSTRAINT [fk_sys_user_func_sys_func_sys_func_name] FOREIGN KEY([sys_func_name])
REFERENCES [{schema}].[sys_func] ([sys_func_name])
GO
ALTER TABLE [{schema}].[sys_user_func] CHECK CONSTRAINT [fk_sys_user_func_sys_func_sys_func_name]
GO
ALTER TABLE [{schema}].[sys_user_role]  WITH CHECK ADD  CONSTRAINT [fk_sys_user_role_sys_user] FOREIGN KEY([sys_user_id])
REFERENCES [{schema}].[sys_user] ([sys_user_id])
ON DELETE CASCADE
GO
ALTER TABLE [{schema}].[sys_user_role] CHECK CONSTRAINT [fk_sys_user_role_sys_user]
GO
ALTER TABLE [{schema}].[sys_user_role]  WITH CHECK ADD  CONSTRAINT [fk_sys_user_role_sys_role_sys_role_name] FOREIGN KEY([sys_role_name])
REFERENCES [{schema}].[sys_role] ([sys_role_name])
ON DELETE CASCADE
GO
ALTER TABLE [{schema}].[sys_user_role] CHECK CONSTRAINT [fk_sys_user_role_sys_role_sys_role_name]
GO
ALTER TABLE [{schema}].[sys_role]  WITH CHECK ADD  CONSTRAINT [fk_sys_role_code_ahc] FOREIGN KEY([sys_role_sts])
REFERENCES [{schema}].[code_ahc] ([code_val])
GO
ALTER TABLE [{schema}].[sys_role] CHECK CONSTRAINT [fk_sys_role_code_ahc]
GO
ALTER TABLE [{schema}].[sys_menu_role]  WITH CHECK ADD  CONSTRAINT [fk_sys_menu_role_menu__tbl] FOREIGN KEY([menu_id])
REFERENCES [{schema}].[menu__tbl] ([menu_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [{schema}].[sys_menu_role] CHECK CONSTRAINT [fk_sys_menu_role_menu__tbl]
GO
ALTER TABLE [{schema}].[sys_menu_role]  WITH CHECK ADD  CONSTRAINT [fk_sys_menu_role_sys_role_sys_role_name] FOREIGN KEY([sys_role_name])
REFERENCES [{schema}].[sys_role] ([sys_role_name])
ON DELETE CASCADE
GO
ALTER TABLE [{schema}].[sys_menu_role] CHECK CONSTRAINT [fk_sys_menu_role_sys_role_sys_role_name]
GO
ALTER TABLE [{schema}].[txt__tbl]  WITH CHECK ADD  CONSTRAINT [fk_txt__tbl_code_txt_type] FOREIGN KEY([txt_type])
REFERENCES [{schema}].[code_txt_type] ([code_val])
GO
ALTER TABLE [{schema}].[txt__tbl] CHECK CONSTRAINT [fk_txt__tbl_code_txt_type]
GO
ALTER TABLE [{schema}].[version__tbl]  WITH CHECK ADD  CONSTRAINT [fk_version__tbl_code_version_sts] FOREIGN KEY([version_sts])
REFERENCES [{schema}].[code_version_sts] ([code_val])
GO
ALTER TABLE [{schema}].[version__tbl] CHECK CONSTRAINT [fk_version__tbl_code_version_sts]
GO
ALTER TABLE [{schema}].[param_sys]  WITH CHECK ADD  CONSTRAINT [fk_param_sys_param__tbl] FOREIGN KEY([param_sys_process], [param_sys_attrib])
REFERENCES [{schema}].[param__tbl] ([param_process], [param_attrib])
GO
ALTER TABLE [{schema}].[param_sys] CHECK CONSTRAINT [fk_param_sys_param__tbl]
GO
ALTER TABLE [{schema}].[sys_user]  WITH CHECK ADD  CONSTRAINT [ck_sys_user_sys_user_email] CHECK  ((isnull([sys_user_email],'')<>''))
GO
ALTER TABLE [{schema}].[sys_user] CHECK CONSTRAINT [ck_sys_user_sys_user_email]
GO
ALTER TABLE [{schema}].[menu__tbl]  WITH CHECK ADD  CONSTRAINT [ck_menu__tbl_menu_group] CHECK  (([menu_group]='C' OR [menu_group]='S'))
GO
ALTER TABLE [{schema}].[menu__tbl] CHECK CONSTRAINT [ck_menu__tbl_menu_group]
GO




SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure  [{schema}].[get_cust_id]
(
    @in_tabn  nvarchar(32),
    @in_tabid bigint,
    @rslt bigint output
)    
as
BEGIN

  DECLARE @sqlcmd nvarchar(max)
  DECLARE @get_cust_id nvarchar(max)

  

  SELECT @get_cust_id = param_cur_val FROM {schema}.v_param_cur where param_cur_process = 'SQL' and param_cur_attrib = 'get_cust_id';
  if(@get_cust_id is null)
  begin
    set @rslt = null;
    return;
  end
  SET @sqlcmd = 'select @rslt  = ' + @get_cust_id + '(''' + @in_tabn + ''',' + isnull(convert(varchar,@in_tabid),'NULL') + ')'
  EXECUTE sp_executesql @sqlcmd, N'@rslt bigint OUTPUT', @rslt=@rslt OUTPUT

END
GO
GRANT EXECUTE ON [{schema}].[get_cust_id] TO [{schema}_role_dev] AS [dbo]
GO




SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure  [{schema}].[get_item_id]
(
    @in_tabn  nvarchar(32),
    @in_tabid bigint,
    @rslt bigint output
)    
as
BEGIN

  DECLARE @sqlcmd nvarchar(max)
  DECLARE @get_item_id nvarchar(max)


  SELECT @get_item_id = param_cur_val FROM {schema}.v_param_cur where param_cur_process = 'SQL' and param_cur_attrib = 'get_item_id';
  if(@get_item_id is null)
  begin
    set @rslt = null;
    return;
  end
  SET @sqlcmd = 'select @rslt  = ' + @get_item_id + '(''' + @in_tabn + ''',' + isnull(convert(varchar,@in_tabid),'NULL') + ')'
  EXECUTE sp_executesql @sqlcmd, N'@rslt bigint OUTPUT', @rslt=@rslt OUTPUT

  return;

END
GO
GRANT EXECUTE ON [{schema}].[get_item_id] TO [{schema}_role_dev] AS [dbo]
GO





SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure  [{schema}].[check_scope_id]
(
    @in_scope  nvarchar(32),
    @in_scope_id bigint,
    @in_cust_id bigint,
    @rslt bigint output
)    
as
BEGIN

  DECLARE @sqlcmd nvarchar(max)
  DECLARE @check_scope_id nvarchar(max)

  SELECT @check_scope_id = param_cur_val FROM {schema}.v_param_cur where param_cur_process = 'SQL' and param_cur_attrib = 'check_scope_id';
  if(@check_scope_id is null)
  begin
    if (@in_scope='U') select @rslt = sys_user_id from {schema}.sys_user where sys_user_id=@in_scope_id;
    else if (@in_scope='S') select @rslt = 1;
    else select @rslt = null;
    return;
  end
  SET @sqlcmd = 'select @rslt  = ' + @check_scope_id + '(''' + @in_scope + ''',' + isnull(convert(varchar,@in_scope_id),'NULL') + ',' + isnull(convert(varchar,@in_cust_id),'NULL') + ')'
  EXECUTE sp_executesql @sqlcmd, N'@rslt bigint OUTPUT', @rslt=@rslt OUTPUT

  return;

END
GO
GRANT EXECUTE ON [{schema}].[check_scope_id] TO [{schema}_role_dev] AS [dbo]
GO




SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [{schema}].[log_audit]
(
    @op           nvarchar(max),
    @tname        NVARCHAR(MAX),
    @tid          bigint,
    @u            NVARCHAR(MAX),
    @tstmp        DATETIME2(7),
    @audit_ref_name     varchar(32) = NULL,
    @audit_ref_id       bigint = NULL,
    @audit_subject         nvarchar(255) = NULL,
    @custid          bigint = NULL, 
    @itemid          bigint = NULL 
)    
as
BEGIN
  DECLARE @MY_audit_seq BIGINT=0
  DECLARE @MYUSER NVARCHAR(MAX)
  DECLARE @WK_cust_id bigint = NULL
  DECLARE @WK_item_id bigint = NULL
  DECLARE @WK_audit_ref_name varchar(32) = NULL
  DECLARE @WK_audit_ref_id bigint = NULL
  DECLARE @WK_audit_subject nvarchar(255) = NULL
 
  DECLARE @doc_ctgr_table nvarchar(max)
  DECLARE @cust_id bigint
  DECLARE @item_id bigint
  DECLARE @tname_lower nvarchar(max)

  BEGIN TRY  

    SET @MYUSER = CASE WHEN @u IS NULL THEN {schema}.my_db_user() ELSE @u END
    select @tname_lower = lower(@tname);

    if (@op = 'D')
    begin
        select top(1)
                 @WK_cust_id = cust_id,
               @WK_item_id = item_id,
               @WK_audit_ref_name = audit_ref_name,
               @WK_audit_ref_id = audit_ref_id,
               @WK_audit_subject = audit_subject
          from {schema}.audit__tbl
         where audit_table_name = lower(@tname)
           and audit_table_id = @tid
           and audit_op = 'I'
         order by audit_seq desc; 
         if @@ROWCOUNT = 0
         begin

          if (@custid is null and lower(@tname) <> lower('cust'))
          begin
            exec {schema}.get_cust_id @tname_lower, @tid, @rslt = @cust_id output;
          end
          if (@itemid is null and lower(@tname) <> lower('item__tbl'))
          begin
            exec {schema}.get_item_id @tname_lower, @tid, @rslt = @item_id output;
          end

           select @WK_cust_id = case when @custid is not null then @custid
                                  when lower(@tname) = lower('cust') then @tid 
                                  else @cust_id end,  
                  @WK_item_id = case when @itemid is not null then @itemid
                                  when lower(@tname)  = lower('item__tbl') then @tid 
                                  else @item_id end, 
                  @WK_audit_ref_name = @audit_ref_name,
                  @WK_audit_ref_id = @audit_ref_id,
                  @WK_audit_subject = @audit_subject;
         end
    end
    ELSE
    begin

        if (@custid is null and lower(@tname) <> lower('cust'))
        begin
          exec {schema}.get_cust_id @tname_lower, @tid, @rslt = @cust_id output;
        end

        if (@itemid is null and lower(@tname) <> lower('item__tbl'))
        begin
          exec {schema}.get_item_id @tname_lower, @tid, @rslt = @item_id output;
        end

        SET @WK_cust_id = case when @custid is not null then @custid
                            when lower(@tname) = lower('cust') then @tid 
                            else @cust_id end;  
        SET @WK_item_id = case when @itemid is not null then @itemid
                            when lower(@tname) = lower('item__tbl') then @tid 
                            else @item_id end; 
        SET @WK_audit_ref_name = @audit_ref_name;
        SET @WK_audit_ref_id = @audit_ref_id;
        SET @WK_audit_subject = @audit_subject;
    end

    INSERT INTO {schema}.audit__tbl 
                      (audit_table_name, audit_table_id, audit_op, audit_user, audit_tstmp, cust_id, item_id, audit_ref_name, audit_ref_id, audit_subject) 
               VALUES (lower(@tname), 
                       @tid, 
                       @op, 
                       @MYUSER, 
                       @tstmp, 
                       isnull(@custid, @WK_cust_id), 
                       isnull(@itemid, @WK_item_id),
                       @WK_audit_ref_name,
                       @WK_audit_ref_id,
                       @WK_audit_subject)
    SET @MY_audit_seq = SCOPE_IDENTITY() 
    
  END TRY
  BEGIN CATCH
    RETURN 0
  END CATCH
   
  RETURN @MY_audit_seq
END


















GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE  [{schema}].[log_audit_base]
(
    @op           nvarchar(max),
    @tname        NVARCHAR(MAX),
    @tid          bigint,
    @u            NVARCHAR(MAX),
    @tstmp        DATETIME2(7),
    @audit_ref_name     varchar(32) = NULL,
    @audit_ref_id       bigint = NULL,
    @audit_subject         nvarchar(255) = NULL
)    
as
BEGIN
  DECLARE @MY_audit_seq BIGINT=0
  DECLARE @MYUSER NVARCHAR(MAX)
  DECLARE @WK_audit_ref_name varchar(32) = NULL
  DECLARE @WK_audit_ref_id bigint = NULL
  DECLARE @WK_audit_subject nvarchar(255) = NULL
 
  BEGIN TRY  

    SET @MYUSER = CASE WHEN @u IS NULL THEN {schema}.my_db_user() ELSE @u END

    if (@op = 'D')
    begin
        select top(1)
               @WK_audit_ref_name = audit_ref_name,
               @WK_audit_ref_id = audit_ref_id,
               @WK_audit_subject = audit_subject
          from {schema}.audit__tbl
         where audit_table_name = lower(@tname)
           and audit_table_id = @tid
           and audit_op = 'I'
         order by audit_seq desc; 
         if @@ROWCOUNT = 0
         begin
           select @WK_audit_ref_name = @audit_ref_name,
                  @WK_audit_ref_id = @audit_ref_id,
                  @WK_audit_subject = @audit_subject;
         end
    end
    ELSE
    begin
        SET @WK_audit_ref_name = @audit_ref_name;
        SET @WK_audit_ref_id = @audit_ref_id;
        SET @WK_audit_subject = @audit_subject;
    end

    INSERT INTO {schema}.audit__tbl 
                      (audit_table_name, audit_table_id, audit_op, audit_user, audit_tstmp, audit_ref_name, audit_ref_id, audit_subject) 
               VALUES (lower(@tname), 
                       @tid, 
                       @op, 
                       @MYUSER, 
                       @tstmp, 
                       @WK_audit_ref_name,
                       @WK_audit_ref_id,
                       @WK_audit_subject)
    SET @MY_audit_seq = SCOPE_IDENTITY() 
    
  END TRY
  BEGIN CATCH
    RETURN 0
  END CATCH
   
  RETURN @MY_audit_seq
END


















GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE PROCEDURE  [{schema}].[check_code_exec]
(
    @in_tblname nvarchar(255),
    @in_code_val nvarchar(32)
)    
as
BEGIN

  DECLARE @rslt INT
  DECLARE @runmesql NVARCHAR(512)

  SELECT @rslt = 0
  SELECT top(1)
         @runmesql = 'select @irslt = count(*) from ['+table_schema+'].[' + table_name + '] where code_val = ''' + 
                     isnull(@in_code_val,'') + ''''
    from information_schema.tables
   where table_name = @in_tblname
   order by (case table_schema when '{schema}' then 1 else 2 end),table_schema;

  exec sp_executesql @runmesql, N'@irslt bigint output', @irslt = @rslt output     
      
  return (@rslt)

END




GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE  [{schema}].[check_code]
(
    @in_tblname nvarchar(255),
    @in_code_val nvarchar(32)
)    
as
BEGIN

DECLARE    @return_value int

BEGIN TRY
EXEC    @return_value = [{schema}].[check_code_exec]
        @in_tblname = @in_tblname,
        @in_code_val = @in_code_val
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







CREATE PROCEDURE  [{schema}].[check_code2_exec]
(
    @in_tblname nvarchar(255),
    @in_code_val1 nvarchar(32),
    @in_code_val2 nvarchar(32)
)    
as
BEGIN

  DECLARE @rslt INT
  DECLARE @runmesql NVARCHAR(512)

  SELECT @rslt = 0
  SELECT top(1)
         @runmesql = 'select @irslt = count(*) from ['+table_schema+'].[' + table_name + '] where code_val1 = ''' + 
                     isnull(@in_code_val1,'') + ''' and code_val2 = ''' + isnull(@in_code_val2,'') +  ''''
    from information_schema.tables
   where table_name = @in_tblname
   order by (case table_schema when '{schema}' then 1 else 2 end),table_schema;

  exec sp_executesql @runmesql, N'@irslt bigint output', @irslt = @rslt output     
      
  return (@rslt)

END






GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE  [{schema}].[check_code2]
(
    @in_tblname nvarchar(255),
    @in_code_val1 nvarchar(32),
    @in_code_val2 nvarchar(32)
)    
as
BEGIN

DECLARE    @return_value int

BEGIN TRY
EXEC    @return_value = [{schema}].[check_code2_exec]
        @in_tblname = @in_tblname,
        @in_code_val1 = @in_code_val1,
        @in_code_val2 = @in_code_val2
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




CREATE PROCEDURE  [{schema}].[create_code]
(
    @in_code_schema nvarchar(max),
    @in_code_name   nvarchar(max),
    @in_code_desc   nvarchar(max)
)    
as
BEGIN

  DECLARE @rslt INT = 0
  DECLARE @rrr NVARCHAR(max)
  DECLARE @rrrt NVARCHAR(max)

  select @rrr = script_txt
    from {schema}.script__tbl
   where script_name = 'create_code';

  set @rrr = replace(@rrr, '%%%schema%%%', lower(isnull(@in_code_schema,'dbo')))
  set @rrr = replace(@rrr, '%%%name%%%', lower(@in_code_name))
  set @rrr = replace(@rrr, '%%%mean%%%', lower(@in_code_desc))

  EXEC (@rrr)      

  select @rrrt = script_txt
    from {schema}.script__tbl
   where script_name = 'create_code_TRIGGER';

  set @rrrt = replace(@rrrt, '%%%schema%%%', lower(isnull(@in_code_schema,'dbo')))
  set @rrrt = replace(@rrrt, '%%%name%%%', lower(@in_code_name))
  set @rrrt = replace(@rrrt, '%%%mean%%%', lower(@in_code_desc))

  EXEC (@rrrt)      

  return (@rslt)

END






GO
GRANT EXECUTE ON [{schema}].[create_code] TO [{schema}_role_dev] AS [dbo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE  [{schema}].[create_code2]
(
    @in_code_schema nvarchar(max),
    @in_code_name   nvarchar(max),
    @in_code_desc   nvarchar(max)
)    
as
BEGIN

  DECLARE @rslt INT = 0
  DECLARE @rrr NVARCHAR(max)
  DECLARE @rrrt NVARCHAR(max)

  select @rrr = script_txt
    from {schema}.script__tbl
   where script_name = 'create_code2';

  set @rrr = replace(@rrr, '%%%schema%%%', lower(isnull(@in_code_schema,'dbo')))
  set @rrr = replace(@rrr, '%%%name%%%', lower(@in_code_name))
  set @rrr = replace(@rrr, '%%%mean%%%', lower(@in_code_desc))

  EXEC (@rrr)      

  select @rrrt = script_txt
    from {schema}.script__tbl
   where script_name = 'create_code2_TRIGGER';

  set @rrrt = replace(@rrrt, '%%%schema%%%', lower(isnull(@in_code_schema,'dbo')))
  set @rrrt = replace(@rrrt, '%%%name%%%', lower(@in_code_name))
  set @rrrt = replace(@rrrt, '%%%mean%%%', lower(@in_code_desc))

  EXEC (@rrrt)      

  return (@rslt)

END






GO
GRANT EXECUTE ON [{schema}].[create_code2] TO [{schema}_role_dev] AS [dbo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE  [{schema}].[create_code_app]
(
    @in_code_schema nvarchar(max),
    @in_code_name   nvarchar(max),
    @in_code_desc   nvarchar(max)
)    
as
BEGIN

  DECLARE @rslt INT = 0
  DECLARE @rrr NVARCHAR(max)
  DECLARE @rrrt NVARCHAR(max)

  select @rrr = script_txt
    from {schema}.script__tbl
   where script_name = 'create_code_app';

  set @rrr = replace(@rrr, '%%%schema%%%', lower(isnull(@in_code_schema,'dbo')))
  set @rrr = replace(@rrr, '%%%name%%%', lower(@in_code_name))
  set @rrr = replace(@rrr, '%%%mean%%%', lower(@in_code_desc))

  EXEC (@rrr)      

  select @rrrt = script_txt
    from {schema}.script__tbl
   where script_name = 'create_code_app_TRIGGER';

  set @rrrt = replace(@rrrt, '%%%schema%%%', lower(isnull(@in_code_schema,'dbo')))
  set @rrrt = replace(@rrrt, '%%%name%%%', lower(@in_code_name))
  set @rrrt = replace(@rrrt, '%%%mean%%%', lower(@in_code_desc))

  EXEC (@rrrt)      

  return (@rslt)

END






GO
GRANT EXECUTE ON [{schema}].[create_code_app] TO [{schema}_role_dev] AS [dbo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE  [{schema}].[create_code2_app]
(
    @in_code_schema nvarchar(max),
    @in_code_name   nvarchar(max),
    @in_code_desc   nvarchar(max)
)    
as
BEGIN

  DECLARE @rslt INT = 0
  DECLARE @rrr NVARCHAR(max)
  DECLARE @rrrt NVARCHAR(max)

  select @rrr = script_txt
    from {schema}.script__tbl
   where script_name = 'create_code2_app';

  set @rrr = replace(@rrr, '%%%schema%%%', lower(isnull(@in_code_schema,'dbo')))
  set @rrr = replace(@rrr, '%%%name%%%', lower(@in_code_name))
  set @rrr = replace(@rrr, '%%%mean%%%', lower(@in_code_desc))

  EXEC (@rrr)      

  select @rrrt = script_txt
    from {schema}.script__tbl
   where script_name = 'create_code2_app_TRIGGER';

  set @rrrt = replace(@rrrt, '%%%schema%%%', lower(isnull(@in_code_schema,'dbo')))
  set @rrrt = replace(@rrrt, '%%%name%%%', lower(@in_code_name))
  set @rrrt = replace(@rrrt, '%%%mean%%%', lower(@in_code_desc))

  EXEC (@rrrt)      

  return (@rslt)

END






GO
GRANT EXECUTE ON [{schema}].[create_code2_app] TO [{schema}_role_dev] AS [dbo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE  [{schema}].[create_code_sys]
(
    @in_code_schema nvarchar(max),
    @in_code_name   nvarchar(max),
    @in_code_desc   nvarchar(max)
)    
as
BEGIN

  DECLARE @rslt INT = 0
  DECLARE @rrr NVARCHAR(max)

  select @rrr = script_txt
    from {schema}.script__tbl
   where script_name = 'create_code_sys';

  set @rrr = replace(@rrr, '%%%schema%%%', lower(isnull(@in_code_schema,'dbo')))
  set @rrr = replace(@rrr, '%%%name%%%', lower(@in_code_name))
  set @rrr = replace(@rrr, '%%%mean%%%', lower(@in_code_desc))

  EXEC (@rrr)      

  return (@rslt)

END






GO
GRANT EXECUTE ON [{schema}].[create_code_sys] TO [{schema}_role_dev] AS [dbo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




create PROCEDURE  [{schema}].[create_code2_sys]
(
    @in_code_schema nvarchar(max),
    @in_code_name   nvarchar(max),
    @in_code_desc   nvarchar(max)
)    
as
BEGIN

  DECLARE @rslt INT = 0
  DECLARE @rrr NVARCHAR(max)

  select @rrr = script_txt
    from {schema}.script__tbl
   where script_name = 'create_code2_sys';

  set @rrr = replace(@rrr, '%%%schema%%%', lower(isnull(@in_code_schema,'dbo')))
  set @rrr = replace(@rrr, '%%%name%%%', lower(@in_code_name))
  set @rrr = replace(@rrr, '%%%mean%%%', lower(@in_code_desc))

  EXEC (@rrr)      

  return (@rslt)

END






GO
GRANT EXECUTE ON [{schema}].[create_code2_sys] TO [{schema}_role_dev] AS [dbo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




/*@ SEND DEBUGGING INFO TO TEXT FILE @*/
CREATE PROCEDURE  [{schema}].[zz-filedebug]
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
                     ' doc__tbl_QT_TNAME=' + @D_QT_TNAME + 
                     ' doc__tbl_Q_ID=' + LTRIM(RTRIM(ISNULL(STR(@D_Q_ID),'null'))) +
                     ' doc__tbl_CT_ID=' + LTRIM(RTRIM(ISNULL(STR(@D_CT_ID),'null'))) );
*/
END
















GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE trigger [{schema}].[doc__tbl_iud] on [{schema}].[doc__tbl]
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
  DECLARE CUR_doc__tbl_iud CURSOR LOCAL FOR
     SELECT  del.doc_id, i.doc_id,
             del.doc_scope, i.doc_scope,
             del.doc_scope_id, i.doc_scope_id,
             del.doc_sts, i.doc_sts,
             del.doc_ctgr, i.doc_ctgr,
             del.doc_desc, i.doc_desc,
             del.doc_uptstmp, i.doc_uptstmp,
             del.doc_upuser, i.doc_upuser,
             del.doc_sync_tstmp, i.doc_sync_tstmp,
             del.cust_id, i.cust_id,
             del.item_id, i.item_id
       FROM deleted del FULL OUTER JOIN inserted i
                       ON i.doc_id = del.doc_id;
  DECLARE @D_doc_id bigint
  DECLARE @I_doc_id bigint
  DECLARE @D_doc_scope NVARCHAR(MAX)
  DECLARE @I_doc_scope NVARCHAR(MAX)
  DECLARE @D_doc_scope_id bigint
  DECLARE @I_doc_scope_id bigint
  DECLARE @D_doc_sts NVARCHAR(MAX)
  DECLARE @I_doc_sts NVARCHAR(MAX)
  DECLARE @D_doc_ctgr NVARCHAR(MAX)
  DECLARE @I_doc_ctgr NVARCHAR(MAX)
  DECLARE @D_doc_desc NVARCHAR(MAX) 
  DECLARE @I_doc_desc NVARCHAR(MAX)
  DECLARE @D_doc_uptstmp datetime2(7) 
  DECLARE @I_doc_uptstmp datetime2(7)
  DECLARE @D_doc_upuser NVARCHAR(MAX) 
  DECLARE @I_doc_upuser NVARCHAR(MAX)
  DECLARE @D_doc_sync_tstmp datetime2(7) 
  DECLARE @I_doc_sync_tstmp datetime2(7)
  DECLARE @D_cust_id bigint 
  DECLARE @I_cust_id bigint
  DECLARE @D_item_id bigint 
  DECLARE @I_item_id bigint

  DECLARE @MYERROR_NO INT = 0
  DECLARE @MYERROR_MSG NVARCHAR(MAX) = NULL

  DECLARE @xloc nvarchar(MAX)
  DECLARE @xtxt nvarchar(MAX)

  DECLARE @DYNSQL NVARCHAR(MAX)
  DECLARE @C BIGINT
  DECLARE @WK_doc_id BIGINT
  DECLARE @WK_audit_ref_name NVARCHAR(MAX)
  DECLARE @WK_audit_ref_id BIGINT
  DECLARE @M NVARCHAR(MAX)
  DECLARE @code_val NVARCHAR(MAX)
  DECLARE @cust_user_user BIT
  DECLARE @USER_cust_id BIGINT

  DECLARE @SQLCMD nvarchar(max)
  DECLARE @doc_ctgr_table nvarchar(max)
  DECLARE @cust_id bigint
  DECLARE @item_id bigint
  declare @lookup_doc_scope nvarchar(max)
  declare @lookup_doc_scope_id bigint
  declare @lookup_doc_scope_tbl nvarchar(max)

  DECLARE @db_id NVARCHAR(MAX)
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
  
  SET @CURDTTM = {schema}.my_now_exec()
  SET @CURDTTM_CHAR = CONVERT(NVARCHAR, @CURDTTM, 120)+'.0000000'
  SET @MYUSER = {schema}.my_db_user() 

  IF @TP = 'U' AND UPDATE(doc_id)
  BEGIN
    EXEC [{schema}].[zz-filedebug] 'TRIGGER','doc__tbl_iud','ERR', 'Cannot update ID'
    raiserror('Cannot update identity',16,1)
    ROLLBACK TRANSACTION
    return
  END

  IF @TP = 'U' AND UPDATE(doc_scope)
  BEGIN
    EXEC [{schema}].[zz-filedebug] 'TRIGGER','doc__tbl_iud','ERR', 'Cannot update doc_scope'
    raiserror('Cannot update foreign key doc_scope',16,1)
    ROLLBACK TRANSACTION
    return
  END

  IF @TP = 'U' AND UPDATE(doc_scope_id)
  BEGIN
    EXEC [{schema}].[zz-filedebug] 'TRIGGER','doc__tbl_iud','ERR', 'Cannot update doc_scope_id'
    raiserror('Cannot update foreign key doc_scope_id',16,1)
    ROLLBACK TRANSACTION
    return
  END

  SELECT @doc_ctgr_table = param_cur_val
    FROM {schema}.v_param_cur
   where param_cur_process = 'SQL'
     and param_cur_attrib = 'doc_ctgr_table';
  IF (@TP='I' OR @TP='U') AND @doc_ctgr_table IS NULL
  BEGIN
    raiserror('doc_ctgr_table parameter not set',16,1)
    ROLLBACK TRANSACTION
    return
  END

  
  OPEN CUR_doc__tbl_iud
  FETCH NEXT FROM CUR_doc__tbl_iud
        INTO @D_doc_id, @I_doc_id,
             @D_doc_scope, @I_doc_scope,
             @D_doc_scope_id, @I_doc_scope_id,
             @D_doc_sts, @I_doc_sts,
             @D_doc_ctgr, @I_doc_ctgr,
             @D_doc_desc, @I_doc_desc,
             @D_doc_uptstmp, @I_doc_uptstmp,
             @D_doc_upuser, @I_doc_upuser,
             @D_doc_sync_tstmp, @I_doc_sync_tstmp,
             @D_cust_id, @I_cust_id,
             @D_item_id, @I_item_id

  WHILE (@@Fetch_Status = 0)
  BEGIN
      

    /******************************************/
    /****** SPECIAL FRONT ACTION - BEGIN ******/
    /******************************************/

 
    IF (@TP='I' 
        OR 
        @TP='U' AND ({schema}.nequal_chr(@D_doc_scope, @I_doc_scope)>0
                     OR
                     {schema}.nequal_num(@D_doc_scope_id, @I_doc_scope_id)>0))
    BEGIN
        IF @I_doc_scope = 'S' AND @I_doc_scope_id <> 0
           OR
           @I_doc_scope <> 'S' AND @I_doc_scope_id is NULL
        BEGIN
            CLOSE CUR_doc__tbl_iud
            DEALLOCATE CUR_doc__tbl_iud
            SET @M = 'SCOPE ID INCONSISTENT WITH SCOPE'
            raiserror(@M ,16,1)
            ROLLBACK TRANSACTION
            return
        END 
    END   
 
    IF (@TP='I' OR @TP='U')
    BEGIN
        exec [{schema}].[check_scope_id] @I_doc_scope, @I_doc_scope_id, null, @rslt = @C output;
        IF isnull(@C,0) <= 0
        BEGIN
            CLOSE CUR_doc__tbl_iud
            DEALLOCATE CUR_doc__tbl_iud
            SET @M = 'Table ' + @I_doc_scope + ' does not contain record ' + CONVERT(NVARCHAR(MAX),@I_doc_scope_id)
            raiserror(@M ,16,1)
            ROLLBACK TRANSACTION
            return
        END 
    END   


 
    IF (@TP='I' OR @TP='U')
    BEGIN
        SET @doc_ctgr_table = isnull(@doc_ctgr_table,'')
        EXEC    @C = [{schema}].[check_code2]
             @in_tblname = @doc_ctgr_table,
            @in_code_val1 = @I_doc_scope,
            @in_code_val2 = @I_doc_ctgr
        IF @C <= 0
        BEGIN
            CLOSE CUR_doc__tbl_iud
            DEALLOCATE CUR_doc__tbl_iud
            SET @M = 'Document Type not allowed for selected Scope'
            raiserror(@M ,16,1)
            ROLLBACK TRANSACTION
            return
        END 
    END   


    SET @cust_user_user = 0
    SET @USER_cust_id = NULL      
:if:client_portal:
    IF SUBSTRING(@MYUSER,1,1) = 'C'
    BEGIN
      SELECT @USER_cust_id = cust_id
        FROM {schema}.cust_user
       WHERE substring(@MYUSER,2,1024)=convert(varchar, sys_user_id);   
      
      IF @USER_cust_id is not null
        SET @cust_user_user = 1
    END
:endif:

    select @lookup_doc_scope = isnull(@I_doc_scope,@D_doc_scope);
    select @lookup_doc_scope_id = isnull(convert(nvarchar,isnull(@I_doc_scope_id,@D_doc_scope_id)),'');
    select @lookup_doc_scope_tbl = isnull(code_code, code_val) from {schema}.code_sys_doc_scope where code_val = @lookup_doc_scope;

    exec {schema}.get_cust_id @lookup_doc_scope_tbl, @lookup_doc_scope_id, @rslt = @cust_id output;
    exec {schema}.get_item_id @lookup_doc_scope_tbl, @lookup_doc_scope_id, @rslt = @item_id output;


    IF (@cust_user_user = 1)
    BEGIN

      IF @USER_cust_id <> isnull(@cust_id,0)
      BEGIN
        CLOSE CUR_doc__tbl_iud
        DEALLOCATE CUR_doc__tbl_iud
        SET @M = 'Application Error - Client User has no rights to perform this operation'
        raiserror(@M ,16,1)
        ROLLBACK TRANSACTION
        return
      END 

    END

    IF (@TP='I')
    BEGIN

      IF @cust_id is not null
      BEGIN
        exec [{schema}].[check_scope_id] @I_doc_scope, @I_doc_scope_id, @cust_id, @rslt = @C output;
        IF isnull(@C,0) <= 0
        BEGIN
            CLOSE CUR_doc__tbl_iud
            DEALLOCATE CUR_doc__tbl_iud
            SET @M = 'Application Error - Client User has no rights to perform this operation'
            raiserror(@M ,16,1)
            ROLLBACK TRANSACTION
            return
        END 
      END   


      IF (@I_doc_sync_tstmp is null)
        UPDATE {schema}.doc__tbl
         SET cust_id = @cust_id,
             item_id = @item_id,
             doc_etstmp = @CURDTTM,
             doc_euser = @MYUSER,
             doc_mtstmp = @CURDTTM,
             doc_muser = @MYUSER
         WHERE doc__tbl.doc_id = @I_doc_id;
    END  

    IF (@TP='U')
    BEGIN

      IF @I_cust_id is not null
         and
         {schema}.nequal_num(@D_cust_id, @I_cust_id) > 0
      BEGIN
        exec [{schema}].[check_scope_id] @I_doc_scope, @I_doc_scope_id, @I_cust_id, @rslt = @C output;
        IF isnull(@C,0) <= 0
        BEGIN
            CLOSE CUR_doc__tbl_iud
            DEALLOCATE CUR_doc__tbl_iud
            SET @M = 'Application Error - Client User has no rights to perform this operation'
            raiserror(@M ,16,1)
            ROLLBACK TRANSACTION
            return
        END 
      END   
         
    END

    /******************************************/
    /****** SPECIAL FRONT ACTION - END   ******/
    /******************************************/


    SET @MY_audit_seq = 0
    IF (@TP='I' OR @TP='D')
    BEGIN  
      SET @WK_doc_id = ISNULL(@D_doc_id,@I_doc_id)
      SET @WK_audit_ref_name = ISNULL(@D_doc_scope,@I_doc_scope)
      SET @WK_audit_ref_id = ISNULL(@D_doc_scope_id,@I_doc_scope_id)
      EXEC    @MY_audit_seq = {schema}.log_audit_base  @TP, 'D', @WK_doc_id, @MYUSER, @CURDTTM, @WK_audit_ref_name, @WK_audit_ref_id, default
    END

 
    IF @TP='U' OR @TP='D'
    BEGIN

      IF (@TP = 'D' AND @D_doc_scope IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_doc_scope, @I_doc_scope) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base  'U', 'D', @I_doc_id, @MYUSER, @CURDTTM, @I_doc_scope, @I_doc_scope_id, default
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('doc_scope'), @D_doc_scope)
      END

      IF (@TP = 'D' AND @D_doc_scope_id IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_num(@D_doc_scope_id, @I_doc_scope_id) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base  'U', 'D', @I_doc_id, @MYUSER, @CURDTTM, @I_doc_scope, @I_doc_scope_id, default
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('doc_scope_id'), @D_doc_scope_id)
      END

      IF (@TP = 'D' AND @D_doc_sts IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_doc_sts, @I_doc_sts) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base  'U', 'D', @I_doc_id, @MYUSER, @CURDTTM, @I_doc_scope, @I_doc_scope_id, default
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('doc_sts'), @D_doc_sts)
      END

      IF (@TP = 'D' AND @D_doc_ctgr IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_doc_ctgr, @I_doc_ctgr) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base  'U', 'D', @I_doc_id, @MYUSER, @CURDTTM, @I_doc_scope, @I_doc_scope_id, default
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('doc_ctgr'), @D_doc_ctgr)
      END

      IF (@TP = 'D' AND @D_doc_desc IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_doc_desc, @I_doc_desc) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base  'U', 'D', @I_doc_id, @MYUSER, @CURDTTM, @I_doc_scope, @I_doc_scope_id, default
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('doc_desc'), @D_doc_desc)
      END

      IF (@TP = 'D' AND @D_doc_uptstmp IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_date(@D_doc_uptstmp, @I_doc_uptstmp) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base  'U', 'D', @I_doc_id, @MYUSER, @CURDTTM, @I_doc_scope, @I_doc_scope_id, default
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('doc_uptstmp'), @D_doc_uptstmp)
      END

      IF (@TP = 'D' AND @D_doc_upuser IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_doc_upuser, @I_doc_upuser) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base  'U', 'D', @I_doc_id, @MYUSER, @CURDTTM, @I_doc_scope, @I_doc_scope_id, default
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('doc_upuser'), @D_doc_upuser)
      END

      IF (@TP = 'D' AND @D_cust_id IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_num(@D_cust_id, @I_cust_id) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base  'U', 'D', @I_doc_id, @MYUSER, @CURDTTM, @I_doc_scope, @I_doc_scope_id, default
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('cust_id'), @D_cust_id)
      END

      IF (@TP = 'D' AND @D_item_id IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_num(@D_item_id, @I_item_id) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base  'U', 'D', @I_doc_id, @MYUSER, @CURDTTM, @I_doc_scope, @I_doc_scope_id, default
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('item_id'), @D_item_id)
      END


    END  /* END OF "IF @TP='U' OR @TP='D'"  */


    /******************************************/
    /****** SPECIAL BACK ACTION - BEGIN  ******/
    /******************************************/

    IF (@TP='U' AND @MY_audit_seq <> 0)
    BEGIN
       if ({schema}.nequal_date(@D_doc_sync_tstmp, @I_doc_sync_tstmp) <= 0)
        UPDATE {schema}.doc__tbl
         SET doc_mtstmp = @CURDTTM,
             doc_muser = @MYUSER,
             doc_sync_tstmp = NULL
         WHERE doc__tbl.doc_id = @I_doc_id;
    END  

    /*****************************************/
    /****** SPECIAL BACK ACTION - END   ******/
    /*****************************************/



            
    FETCH NEXT FROM CUR_doc__tbl_iud
        INTO @D_doc_id, @I_doc_id,
             @D_doc_scope,  @I_doc_scope,
             @D_doc_scope_id, @I_doc_scope_id,
             @D_doc_sts, @I_doc_sts,
             @D_doc_ctgr, @I_doc_ctgr,
             @D_doc_desc, @I_doc_desc,
             @D_doc_uptstmp, @I_doc_uptstmp,
             @D_doc_upuser, @I_doc_upuser,
             @D_doc_sync_tstmp, @I_doc_sync_tstmp,
             @D_cust_id, @I_cust_id,
             @D_item_id, @I_item_id

  END
  CLOSE CUR_doc__tbl_iud
  DEALLOCATE CUR_doc__tbl_iud

  RETURN

END

GO
ALTER TABLE [{schema}].[doc__tbl] ENABLE TRIGGER [doc__tbl_iud]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE trigger [{schema}].[code2_doc_scope_doc_ctgr_iud] on [{schema}].[code2_doc_scope_doc_ctgr]
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
  DECLARE CUR_code2_doc_scope_doc_ctgr_iud CURSOR LOCAL FOR
     SELECT  del.code2_app_id, i.code2_app_id,
             del.code_seq, i.code_seq,
             del.code_end_dt, i.code_end_dt,
             del.code_val1, i.code_val1,
             del.code_val2, i.code_val2,
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
  DECLARE @D_code_val2 NVARCHAR(MAX)
  DECLARE @I_code_val2 NVARCHAR(MAX)
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
  DECLARE @cust_user_user BIT
  DECLARE @WK_code2_app_id BIGINT

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

  IF @TP = 'U' AND UPDATE(code2_app_id)
  BEGIN
    EXEC [{schema}].[zz-filedebug] 'TRIGGER','code2_doc_scope_doc_ctgr_iud','ERR', 'Cannot update ID'
    raiserror('Cannot update identity',16,1)
    ROLLBACK TRANSACTION
    return
  END

  IF @TP = 'U' AND UPDATE(code_val1)
  BEGIN
    EXEC [{schema}].[zz-filedebug] 'TRIGGER','code2_doc_scope_doc_ctgr_iud','ERR', 'Cannot update code_val1'
    raiserror('Cannot update foreign key code_val1',16,1)
    ROLLBACK TRANSACTION
    return
  END

  IF @TP = 'U' AND UPDATE(code_val2)
  BEGIN
    EXEC [{schema}].[zz-filedebug] 'TRIGGER','code2_doc_scope_doc_ctgr_iud','ERR', 'Cannot update code_val2'
    raiserror('Cannot update foreign key code_val2',16,1)
    ROLLBACK TRANSACTION
    return
  END

  
  OPEN CUR_code2_doc_scope_doc_ctgr_iud
  FETCH NEXT FROM CUR_code2_doc_scope_doc_ctgr_iud
        INTO @D_code2_app_id, @I_code2_app_id,
             @D_code_seq, @I_code_seq,
             @D_code_end_dt, @I_code_end_dt,
             @D_code_val1, @I_code_val1,
             @D_code_val2, @I_code_val2,
             @D_code_txt, @I_code_txt,
             @D_code_code, @I_code_code,
             @D_code_attrib, @I_code_attrib,
             @D_code_end_reason, @I_code_end_reason

  WHILE (@@Fetch_Status = 0)
  BEGIN

    /******************************************/
    /****** SPECIAL FRONT ACTION - BEGIN ******/
    /******************************************/

    IF (@TP='I')
    BEGIN
      UPDATE {schema}.code2_doc_scope_doc_ctgr
         SET code_etstmp = @CURDTTM,
             code_euser = @MYUSER,
             code_mtstmp = @CURDTTM,
             code_muser = @MYUSER
       WHERE code2_doc_scope_doc_ctgr.code2_app_id = @I_code2_app_id;
    END  

    /******************************************/
    /****** SPECIAL FRONT ACTION - END   ******/
    /******************************************/


    SET @MY_audit_seq = 0
    IF (@TP='I' OR @TP='D')
    BEGIN  
      SET @WK_code2_app_id = ISNULL(@D_code2_app_id,@I_code2_app_id)
      EXEC    @MY_audit_seq = {schema}.log_audit_base @TP, 'code2_doc_scope_doc_ctgr', @WK_code2_app_id, @MYUSER, @CURDTTM
    END

 
    IF @TP='U' OR @TP='D'
    BEGIN

      IF (@TP = 'D' AND @D_code_seq IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_num(@D_code_seq, @I_code_seq) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base 'U', 'code2_doc_scope_doc_ctgr', @I_code2_app_id, @MYUSER, @CURDTTM
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('code_seq'), @D_code_seq)
      END

      IF (@TP = 'D' AND @D_code_end_dt IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_date(@D_code_end_dt, @I_code_end_dt) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base 'U', 'code2_doc_scope_doc_ctgr', @I_code2_app_id, @MYUSER, @CURDTTM
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('code_end_dt'), @D_code_end_dt)
      END

      IF (@TP = 'D' AND @D_code_val1 IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_code_val1, @I_code_val1) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base 'U', 'code2_doc_scope_doc_ctgr', @I_code2_app_id, @MYUSER, @CURDTTM
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('code_val1'), @D_code_val1)
      END

      IF (@TP = 'D' AND @D_code_val2 IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_code_val2, @I_code_val2) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base 'U', 'code2_doc_scope_doc_ctgr', @I_code2_app_id, @MYUSER, @CURDTTM
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('code_val2'), @D_code_val2)
      END

      IF (@TP = 'D' AND @D_code_txt IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_code_txt, @I_code_txt) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base 'U', 'code2_doc_scope_doc_ctgr', @I_code2_app_id, @MYUSER, @CURDTTM
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('code_txt'), @D_code_txt)
      END

      IF (@TP = 'D' AND @D_code_code IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_code_code, @I_code_code) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base 'U', 'code2_doc_scope_doc_ctgr', @I_code2_app_id, @MYUSER, @CURDTTM
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('code_code'), @D_code_code)
      END

      IF (@TP = 'D' AND @D_code_attrib IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_code_attrib, @I_code_attrib) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base 'U', 'code2_doc_scope_doc_ctgr', @I_code2_app_id, @MYUSER, @CURDTTM
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('code_attrib'), @D_code_attrib)
      END

      IF (@TP = 'D' AND @D_code_end_reason IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_code_end_reason, @I_code_end_reason) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base 'U', 'code2_doc_scope_doc_ctgr', @I_code2_app_id, @MYUSER, @CURDTTM
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('code_end_reason'), @D_code_end_reason)
      END

    END  /* END OF "IF @TP='U' OR @TP='D'"  */


    /******************************************/
    /****** SPECIAL BACK ACTION - BEGIN  ******/
    /******************************************/

    IF (@TP='U' AND @MY_audit_seq <> 0)
    BEGIN
      UPDATE {schema}.code2_doc_scope_doc_ctgr
         SET code_mtstmp = @CURDTTM,
             code_muser = @MYUSER
       WHERE code2_doc_scope_doc_ctgr.code2_app_id = @I_code2_app_id;
    END  

    /*****************************************/
    /****** SPECIAL BACK ACTION - END   ******/
    /*****************************************/



            
    FETCH NEXT FROM CUR_code2_doc_scope_doc_ctgr_iud
        INTO @D_code2_app_id, @I_code2_app_id,
             @D_code_seq,  @I_code_seq,
             @D_code_end_dt, @I_code_end_dt,
             @D_code_val1, @I_code_val1,
             @D_code_val2, @I_code_val2,
             @D_code_txt, @I_code_txt,
             @D_code_code, @I_code_code,
             @D_code_attrib, @I_code_attrib,
             @D_code_end_reason, @I_code_end_reason


  END
  CLOSE CUR_code2_doc_scope_doc_ctgr_iud
  DEALLOCATE CUR_code2_doc_scope_doc_ctgr_iud


  RETURN

END
GO
ALTER TABLE [{schema}].[code2_doc_scope_doc_ctgr] ENABLE TRIGGER [code2_doc_scope_doc_ctgr_iud]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE trigger [{schema}].[param_app_iud] on [{schema}].[param_app]
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
  DECLARE @MY_audit_seq NUMERIC(20,0)
  DECLARE CUR_param_app_I CURSOR LOCAL FOR SELECT param_app_id,
                                            param_app_process, 
                                            param_app_attrib, 
                                            param_app_val
                                       FROM INSERTED
  DECLARE CUR_param_app_DU CURSOR LOCAL FOR 
     SELECT  del.param_app_id, i.param_app_id,
             del.param_app_process, i.param_app_process,
             del.param_app_attrib, i.param_app_attrib,
             del.param_app_val, i.param_app_val
       FROM deleted del FULL OUTER JOIN inserted i
                       ON i.param_app_id = del.param_app_id
  DECLARE @D_param_app_id bigint
  DECLARE @I_param_app_id bigint
  DECLARE @D_param_app_process nvarchar(MAX)
  DECLARE @I_param_app_process nvarchar(MAX)
  DECLARE @D_param_app_attrib nvarchar(MAX)
  DECLARE @I_param_app_attrib nvarchar(MAX)
  DECLARE @D_param_app_val nvarchar(MAX)
  DECLARE @I_param_app_val nvarchar(MAX)
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

  SET @CURDTTM = {schema}.my_now_exec()
  SET @CURDTTM_CHAR = CONVERT(NVARCHAR, @CURDTTM, 120)+'.0000000'
  SET @MYUSER = {schema}.my_db_user() 

  IF @TP = 'U' AND UPDATE(param_app_id)
  BEGIN
    raiserror('Cannot update identity',16,1)
    ROLLBACK TRANSACTION
    return
  END

  if(@TP = 'I')
  BEGIN
  
    update {schema}.param_app set
      param_app_etstmp = @CURDTTM,
      param_app_euser =@MYUSER, 
      param_app_mtstmp = @CURDTTM,
      param_app_muser =@MYUSER 
      from inserted WHERE param_app.param_app_id=INSERTED.param_app_id
  
    OPEN CUR_param_app_I
    FETCH NEXT FROM CUR_param_app_I INTO @I_param_app_id, 
                                   @I_param_app_process, 
                                   @I_param_app_attrib,
                                   @I_param_app_val
    WHILE (@@Fetch_Status = 0)
    BEGIN
      
      IF (@I_param_app_val IS NOT NULL)
      BEGIN
        SET @ERRTXT = {schema}.check_param('param_app',@I_param_app_process,@I_param_app_attrib,@I_param_app_val)
        IF @ERRTXT IS NOT null  
        BEGIN
          raiserror(@ERRTXT,16,1)
          ROLLBACK TRANSACTION
          return
        END
      END

      SET @WK_ID = ISNULL(@I_param_app_id,@D_param_app_id)
      EXEC    @MY_audit_seq = {schema}.log_audit_base @TP, 'param_app', @WK_ID, @MYUSER, @CURDTTM

      FETCH NEXT FROM CUR_param_app_I INTO @I_param_app_id, 
                                     @I_param_app_process, 
                                     @I_param_app_attrib,
                                     @I_param_app_val
    END
    CLOSE CUR_param_app_I
    DEALLOCATE CUR_param_app_I
  END
  ELSE 
  BEGIN
  
    if(@TP = 'U')
    BEGIN
      update param_app set
        param_app_mtstmp = @CURDTTM,
        param_app_muser =@MYUSER 
        from inserted WHERE param_app.param_app_id = INSERTED.param_app_id
    END

    OPEN CUR_param_app_DU
    FETCH NEXT FROM CUR_param_app_DU
          INTO @D_param_app_id, @I_param_app_id,
               @D_param_app_process, @I_param_app_process,
               @D_param_app_attrib, @I_param_app_attrib,
               @D_param_app_val, @I_param_app_val
    WHILE (@@Fetch_Status = 0)
    BEGIN
      if(@TP = 'U')
      BEGIN
        IF (@I_param_app_val IS NOT NULL)
        BEGIN      
          SET @ERRTXT = {schema}.check_param('param_app',@I_param_app_process,@I_param_app_attrib,@I_param_app_val)
          IF @ERRTXT IS NOT null  
          BEGIN
            raiserror(@ERRTXT,16,1)
            ROLLBACK TRANSACTION
            return
          END
        END


      END

      SET @WK_ID = ISNULL(@I_param_app_id,@D_param_app_id)
      EXEC    @MY_audit_seq = {schema}.log_audit_base @TP, 'param_app', @WK_ID, @MYUSER, @CURDTTM
            
      FETCH NEXT FROM CUR_param_app_DU
            INTO @D_param_app_id, @I_param_app_id,
                 @D_param_app_process, @I_param_app_process,
                 @D_param_app_attrib, @I_param_app_attrib,
                 @D_param_app_val, @I_param_app_val
    END
    CLOSE CUR_param_app_DU
    DEALLOCATE CUR_param_app_DU
  END

  RETURN

END

GO
ALTER TABLE [{schema}].[param_app] ENABLE TRIGGER [param_app_iud]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE trigger [{schema}].[help__tbl_iud] on [{schema}].[help__tbl]
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
  DECLARE CUR_help__tbl_iud CURSOR LOCAL FOR
     SELECT  del.help_id, i.help_id,
             del.help_target_code, i.help_target_code,
             del.help_title, i.help_title,
             del.help_text, i.help_text,
             del.help_seq, i.help_seq,
             del.help_listing_main, i.help_listing_main,
             del.help_listing_client, i.help_listing_client
       FROM deleted del FULL OUTER JOIN inserted i
                       ON i.help_id = del.help_id;
  DECLARE @D_help_id bigint
  DECLARE @I_help_id bigint
  DECLARE @D_help_target_code NVARCHAR(MAX)
  DECLARE @I_help_target_code NVARCHAR(MAX)
  DECLARE @D_help_title NVARCHAR(MAX)
  DECLARE @I_help_title NVARCHAR(MAX)
  DECLARE @D_help_text NVARCHAR(MAX)
  DECLARE @I_help_text NVARCHAR(MAX)
  DECLARE @D_help_seq BIGINT
  DECLARE @I_help_seq BIGINT
  DECLARE @D_help_listing_main BIGINT
  DECLARE @I_help_listing_main BIGINT
  DECLARE @D_help_listing_client BIGINT
  DECLARE @I_help_listing_client BIGINT

  DECLARE @MYERROR_NO INT = 0
  DECLARE @MYERROR_MSG NVARCHAR(MAX) = NULL

  DECLARE @xloc nvarchar(MAX)
  DECLARE @xtxt nvarchar(MAX)

  DECLARE @DYNSQL NVARCHAR(MAX)
  DECLARE @C BIGINT
  DECLARE @code_val NVARCHAR(MAX)
  DECLARE @WK_help_id bigint
  DECLARE @M NVARCHAR(MAX)
  DECLARE @cust_user_user BIT

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

  IF @TP = 'U' AND UPDATE(help_id)
  BEGIN
    EXEC [{schema}].[zz-filedebug] 'TRIGGER','help__tbl_iud','ERR', 'Cannot update ID'
    raiserror('Cannot update identity',16,1)
    ROLLBACK TRANSACTION
    return
  END

  
  OPEN CUR_help__tbl_iud
  FETCH NEXT FROM CUR_help__tbl_iud
        INTO @D_help_id, @I_help_id,
             @D_help_target_code, @I_help_target_code,
             @D_help_title, @I_help_title,
             @D_help_text, @I_help_text,
             @D_help_seq, @I_help_seq,
             @D_help_listing_main, @I_help_listing_main,
             @D_help_listing_client, @I_help_listing_client

  WHILE (@@Fetch_Status = 0)
  BEGIN

    /******************************************/
    /****** SPECIAL FRONT ACTION - BEGIN ******/
    /******************************************/

    IF (@TP='I')
    BEGIN
      UPDATE {schema}.help__tbl
         SET help_etstmp = @CURDTTM,
             help_euser = @MYUSER,
             help_mtstmp = @CURDTTM,
             help_muser = @MYUSER
       WHERE help__tbl.help_id = @I_help_id;
    END  

    /******************************************/
    /****** SPECIAL FRONT ACTION - END   ******/
    /******************************************/


    SET @MY_audit_seq = 0
    IF (@TP='I' OR @TP='D')
    BEGIN  
      SET @WK_help_id = ISNULL(@D_help_id,@I_help_id)
      EXEC    @MY_audit_seq = {schema}.log_audit_base @TP, 'help__tbl', @WK_help_id, @MYUSER, @CURDTTM
    END

 
    IF @TP='U' OR @TP='D'
    BEGIN

      IF (@TP = 'D' AND @D_help_target_code IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_help_target_code, @I_help_target_code) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base 'U', 'help__tbl', @I_help_id, @MYUSER, @CURDTTM
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('help_target_code'), @D_help_target_code)
      END

      IF (@TP = 'D' AND @D_help_title IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_help_title, @I_help_title) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base 'U', 'help__tbl', @I_help_id, @MYUSER, @CURDTTM
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('help_title'), @D_help_title)
      END

      IF (@TP = 'D' AND @D_help_text IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_help_text, @I_help_text) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base 'U', 'help__tbl', @I_help_id, @MYUSER, @CURDTTM
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('help_text'), @D_help_text)
      END

      IF (@TP = 'D' AND @D_help_seq IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_num(@D_help_seq, @I_help_seq) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base 'U', 'help__tbl', @I_help_id, @MYUSER, @CURDTTM
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('help_seq'), @D_help_seq)
      END

      IF (@TP = 'D' AND @D_help_listing_main IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_num(@D_help_listing_main, @I_help_listing_main) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base 'U', 'help__tbl', @I_help_id, @MYUSER, @CURDTTM
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('help_listing_main'), @D_help_listing_main)
      END

      IF (@TP = 'D' AND @D_help_listing_client IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_num(@D_help_listing_client, @I_help_listing_client) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base 'U', 'help__tbl', @I_help_id, @MYUSER, @CURDTTM
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('help_listing_client'), @D_help_listing_client)
      END

    END  /* END OF "IF @TP='U' OR @TP='D'"  */


    /******************************************/
    /****** SPECIAL BACK ACTION - BEGIN  ******/
    /******************************************/

    IF (@TP='U' AND @MY_audit_seq <> 0)
    BEGIN
      UPDATE {schema}.help__tbl
         SET help_mtstmp = @CURDTTM,
             help_muser = @MYUSER
       WHERE help__tbl.help_id = @I_help_id;
    END  

    /*****************************************/
    /****** SPECIAL BACK ACTION - END   ******/
    /*****************************************/



            
    FETCH NEXT FROM CUR_help__tbl_iud
        INTO @D_help_id, @I_help_id,
             @D_help_target_code,  @I_help_target_code,
             @D_help_title, @I_help_title,
             @D_help_text, @I_help_text,
             @D_help_seq, @I_help_seq,
             @D_help_listing_main, @I_help_listing_main,
             @D_help_listing_client, @I_help_listing_client


  END
  CLOSE CUR_help__tbl_iud
  DEALLOCATE CUR_help__tbl_iud

  RETURN

END
GO
ALTER TABLE [{schema}].[help__tbl] ENABLE TRIGGER [help__tbl_iud]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE trigger [{schema}].[help_target_iud] on [{schema}].[help_target]
for insert, update, delete
AS
BEGIN
  set nocount on
  DECLARE @TP char(1)
  DECLARE CUR_help_target_iud CURSOR LOCAL FOR
     SELECT  del.help_target_id, i.help_target_id,
             del.help_target_code, i.help_target_code,
             del.help_target_desc, i.help_target_desc
       FROM deleted del FULL OUTER JOIN inserted i
                       ON i.help_target_id = del.help_target_id;
  DECLARE @D_help_target_id bigint
  DECLARE @I_help_target_id bigint
  DECLARE @D_help_target_code NVARCHAR(MAX)
  DECLARE @I_help_target_code NVARCHAR(MAX)
  DECLARE @D_help_target_desc NVARCHAR(MAX)
  DECLARE @I_help_target_desc NVARCHAR(MAX)

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
  
  OPEN CUR_help_target_iud
  FETCH NEXT FROM CUR_help_target_iud
        INTO @D_help_target_id, @I_help_target_id,
             @D_help_target_code, @I_help_target_code,
             @D_help_target_desc, @I_help_target_desc

  WHILE (@@Fetch_Status = 0)
  BEGIN

    /******************************************/
    /****** SPECIAL FRONT ACTION - BEGIN ******/
    /******************************************/

    IF (@TP='U')
    BEGIN
      UPDATE {schema}.help__tbl set
        help_target_code = @I_help_target_code
        where {schema}.help__tbl.help_target_id = @I_help_target_id;
    END  

    /******************************************/
    /****** SPECIAL FRONT ACTION - END   ******/
    /******************************************/



            
    FETCH NEXT FROM CUR_help_target_iud
        INTO @D_help_target_id, @I_help_target_id,
             @D_help_target_code,  @I_help_target_code,
             @D_help_target_desc, @I_help_target_desc


  END
  CLOSE CUR_help_target_iud
  DEALLOCATE CUR_help_target_iud

  RETURN

END
GO
ALTER TABLE [{schema}].[help_target] ENABLE TRIGGER [help_target_iud]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE trigger [{schema}].[note__tbl_iud] on [{schema}].[note__tbl]
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
  DECLARE CUR_note__tbl_iud CURSOR LOCAL FOR
     SELECT  del.note_id, i.note_id,
             del.note_scope, i.note_scope,
             del.note_scope_id, i.note_scope_id,
             del.note_sts, i.note_sts,
             del.note_type, i.note_type,
             del.note_body, i.note_body,
             del.cust_id, i.cust_id,
             del.item_id, i.item_id
       FROM deleted del FULL OUTER JOIN inserted i
                       ON i.note_id = del.note_id;
  DECLARE @D_note_id bigint
  DECLARE @I_note_id bigint
  DECLARE @D_note_scope NVARCHAR(MAX)
  DECLARE @I_note_scope NVARCHAR(MAX)
  DECLARE @D_note_scope_id bigint
  DECLARE @I_note_scope_id bigint
  DECLARE @D_note_sts NVARCHAR(MAX)
  DECLARE @I_note_sts NVARCHAR(MAX)
  DECLARE @D_note_type NVARCHAR(MAX)
  DECLARE @I_note_type NVARCHAR(MAX)
  DECLARE @D_note_body NVARCHAR(MAX) 
  DECLARE @I_note_body NVARCHAR(MAX)
  DECLARE @D_cust_id bigint 
  DECLARE @I_cust_id bigint
  DECLARE @D_item_id bigint 
  DECLARE @I_item_id bigint

  DECLARE @MYERROR_NO INT = 0
  DECLARE @MYERROR_MSG NVARCHAR(MAX) = NULL

  DECLARE @xloc nvarchar(MAX)
  DECLARE @xtxt nvarchar(MAX)

  DECLARE @DYNSQL NVARCHAR(MAX)
  DECLARE @C BIGINT
  DECLARE @WK_note_id BIGINT
  DECLARE @WK_audit_ref_name NVARCHAR(MAX)
  DECLARE @WK_audit_ref_id BIGINT
  DECLARE @M NVARCHAR(MAX)
  DECLARE @code_val NVARCHAR(MAX)
  DECLARE @cust_user_user bit
  DECLARE @USER_cust_id bigint

  DECLARE @SQLCMD nvarchar(max)

  DECLARE @cust_id BIGINT = NULL;
  DECLARE @item_id BIGINT = NULL;
  declare @lookup_note_scope nvarchar(max);
  declare @lookup_note_scope_id bigint;
  declare @lookup_note_scope_tbl nvarchar(max);

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
  SET @CURDTTM_CHAR = CONVERT(NVARCHAR, @CURDTTM, 120)+'.0000000'
  SET @MYUSER = {schema}.my_db_user() 

  IF @TP = 'U' AND UPDATE(note_id)
  BEGIN
    EXEC [{schema}].[zz-filedebug] 'TRIGGER','note__tbl_iud','ERR', 'Cannot update ID'
    raiserror('Cannot update identity',16,1)
    ROLLBACK TRANSACTION
    return
  END

  IF @TP = 'U' AND UPDATE(note_scope)
  BEGIN
    EXEC [{schema}].[zz-filedebug] 'TRIGGER','note__tbl_iud','ERR', 'Cannot update note_scope'
    raiserror('Cannot update foreign key note_scope',16,1)
    ROLLBACK TRANSACTION
    return
  END

  IF @TP = 'U' AND UPDATE(note_scope_id)
  BEGIN
    EXEC [{schema}].[zz-filedebug] 'TRIGGER','note__tbl_iud','ERR', 'Cannot update note_scope_id'
    raiserror('Cannot update foreign key note_scope_id',16,1)
    ROLLBACK TRANSACTION
    return
  END

  IF @TP = 'U' AND UPDATE(note_type)
  BEGIN
    EXEC [{schema}].[zz-filedebug] 'TRIGGER','note__tbl_iud','ERR', 'Cannot update note_type'
    raiserror('Cannot update foreign key note_type',16,1)
    ROLLBACK TRANSACTION
    return
  END
  
  OPEN CUR_note__tbl_iud
  FETCH NEXT FROM CUR_note__tbl_iud
        INTO @D_note_id, @I_note_id,
             @D_note_scope, @I_note_scope,
             @D_note_scope_id, @I_note_scope_id,
             @D_note_sts, @I_note_sts,
             @D_note_type, @I_note_type,
             @D_note_body, @I_note_body,
             @D_cust_id, @I_cust_id,
             @D_item_id, @I_item_id

  WHILE (@@Fetch_Status = 0)
  BEGIN

    /******************************************/
    /****** SPECIAL FRONT ACTION - BEGIN ******/
    /******************************************/
 
    IF (@TP='I' 
        OR 
        @TP='U' AND ({schema}.nequal_chr(@D_note_scope, @I_note_scope)>0
                     OR
                     {schema}.nequal_num(@D_note_scope_id, @I_note_scope_id)>0))
    BEGIN
        IF @I_note_scope = 'S' AND @I_note_scope_id <> 0
           OR
           @I_note_scope <> 'S' AND @I_note_scope_id is NULL
        BEGIN
            CLOSE CUR_note__tbl_iud
            DEALLOCATE CUR_note__tbl_iud
            SET @M = 'SCOPE ID INCONSISTENT WITH SCOPE'
            raiserror(@M ,16,1)
            ROLLBACK TRANSACTION
            return
        END 
    END   
 
    IF (@TP='I' OR @TP='U')
    BEGIN
        exec [{schema}].[check_scope_id] @I_note_scope, @I_note_scope_id, null, @rslt = @C output;
        IF isnull(@C,0) <= 0
        BEGIN
            CLOSE CUR_note__tbl_iud
            DEALLOCATE CUR_note__tbl_iud
            SET @M = 'Table ' + @I_note_scope + ' does not contain record ' + CONVERT(NVARCHAR(MAX),@I_note_scope_id)
            raiserror(@M ,16,1)
            ROLLBACK TRANSACTION
            return
        END 
    END   



    SET @cust_user_USER = 0
    SET @USER_cust_id = NULL      
:if:client_portal:
    IF SUBSTRING(@MYUSER,1,1) = 'C'
    BEGIN
      SELECT @USER_cust_id = cust_id
        FROM {schema}.cust_user
       WHERE substring(@MYUSER,2,1024)=convert(varchar, sys_user_id);   
      
      IF @USER_cust_id is not null
        SET @cust_user_USER = 1
    END
:endif:

    select @lookup_note_scope = isnull(@I_note_scope,@D_note_scope);
    select @lookup_note_scope_id = isnull(convert(nvarchar,isnull(@I_note_scope_id,@D_note_scope_id)),'');
    select @lookup_note_scope_tbl = isnull(code_code, code_val) from {schema}.code_sys_note_scope where code_val = @lookup_note_scope;

    exec {schema}.get_cust_id @lookup_note_scope_tbl, @lookup_note_scope_id, @rslt = @cust_id output;
    exec {schema}.get_item_id @lookup_note_scope_tbl, @lookup_note_scope_id, @rslt = @item_id output;


    IF (@cust_user_USER = 1)
    BEGIN

      IF @USER_cust_id <> isnull(@cust_id,0)
      BEGIN
        CLOSE CUR_note__tbl_iud
        DEALLOCATE CUR_note__tbl_iud
        SET @M = 'Application Error - Customer User has no rights to perform this operation'
        raiserror(@M ,16,1)
        ROLLBACK TRANSACTION
        return
      END 

    END


    IF (@TP='I')
    BEGIN

      IF @USER_cust_id is not null
      BEGIN
        exec [{schema}].[check_scope_id] @I_note_scope, @I_note_scope_id, @cust_id, @rslt = @C output;
        IF isnull(@C,0) <= 0
        BEGIN
            CLOSE CUR_note__tbl_iud
            DEALLOCATE CUR_note__tbl_iud
            SET @M = 'Table cust does not contain record ' + CONVERT(NVARCHAR(MAX),@cust_id)
            raiserror(@M ,16,1)
            ROLLBACK TRANSACTION
            return
        END 
      END   

        UPDATE {schema}.note__tbl
         SET cust_id = @cust_id,
             item_id = @item_id,
             note_etstmp = @CURDTTM,
             note_euser = @MYUSER,
             note_mtstmp = @CURDTTM,
             note_muser = @MYUSER
         WHERE note_id = @I_note_id;
    END  

    IF (@TP='U')
    BEGIN

      IF @I_cust_id is not null
         and
         {schema}.nequal_num(@D_cust_id, @I_cust_id) > 0
      BEGIN
        exec [{schema}].[check_scope_id] @I_note_scope, @I_note_scope_id, @I_cust_id, @rslt = @C output;
        IF isnull(@C,0) <= 0
        BEGIN
            CLOSE CUR_note__tbl_iud
            DEALLOCATE CUR_note__tbl_iud
            SET @M = 'Table cust does not contain record ' + CONVERT(NVARCHAR(MAX),@I_cust_id)
            raiserror(@M ,16,1)
            ROLLBACK TRANSACTION
            return
        END 
      END   

    END


    /******************************************/
    /****** SPECIAL FRONT ACTION - END   ******/
    /******************************************/


    SET @MY_audit_seq = 0
    IF (@TP='I' OR @TP='D')
    BEGIN  
      SET @WK_note_id = ISNULL(@D_note_id,@I_note_id)
      SET @WK_audit_ref_name = ISNULL(@D_note_scope,@I_note_scope)
      SET @WK_audit_ref_id = ISNULL(@D_note_scope_id,@I_note_scope_id)
      EXEC    @MY_audit_seq = {schema}.log_audit_base @TP, 'note__tbl', @WK_note_id, @MYUSER, @CURDTTM, @WK_audit_ref_name, @WK_audit_ref_id, default
    END

 
    IF @TP='U' OR @TP='D'
    BEGIN

      IF (@TP = 'D' AND @D_note_scope IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_note_scope, @I_note_scope) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base  'U', 'note__tbl', @I_note_id, @MYUSER, @CURDTTM, @I_note_scope, @I_note_scope_id, default
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('note_scope'), @D_note_scope)
      END

      IF (@TP = 'D' AND @D_note_scope_id IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_num(@D_note_scope_id, @I_note_scope_id) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base  'U', 'note__tbl', @I_note_id, @MYUSER, @CURDTTM, @I_note_scope, @I_note_scope_id, default
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('note_scope_id'), @D_note_scope_id)
      END

      IF (@TP = 'D' AND @D_note_sts IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_note_sts, @I_note_sts) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base  'U', 'note__tbl', @I_note_id, @MYUSER, @CURDTTM, @I_note_scope, @I_note_scope_id, default
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('note_sts'), @D_note_sts)
      END

      IF (@TP = 'D' AND @D_note_type IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_note_type, @I_note_type) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base  'U', 'note__tbl', @I_note_id, @MYUSER, @CURDTTM, @I_note_scope, @I_note_scope_id, default
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('note_type'), @D_note_type)
      END

      IF (@TP = 'D' AND @D_note_body IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_note_body, @I_note_body) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base  'U', 'note__tbl', @I_note_id, @MYUSER, @CURDTTM, @I_note_scope, @I_note_scope_id, default
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('note_body'), @D_note_body)
      END

      IF (@TP = 'D' AND @D_cust_id IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_num(@D_cust_id, @I_cust_id) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base  'U', 'note__tbl', @I_note_id, @MYUSER, @CURDTTM, @I_note_scope, @I_note_scope_id, default
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('cust_id'), @D_cust_id)
      END

      IF (@TP = 'D' AND @D_item_id IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_num(@D_item_id, @I_item_id) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base  'U', 'note__tbl', @I_note_id, @MYUSER, @CURDTTM, @I_note_scope, @I_note_scope_id, default
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('item_id'), @D_item_id)
      END


    END  /* END OF "IF @TP='U' OR @TP='D'"  */

    /******************************************/
    /****** SPECIAL BACK ACTION - BEGIN  ******/
    /******************************************/

    IF (@TP='U' AND @MY_audit_seq <> 0)
    BEGIN
        UPDATE {schema}.note__tbl
         SET note_mtstmp = @CURDTTM,
             note_muser = @MYUSER
         WHERE note__tbl.note_id = @I_note_id;
    END  

    /*****************************************/
    /****** SPECIAL BACK ACTION - END   ******/
    /*****************************************/



            
    FETCH NEXT FROM CUR_note__tbl_iud
        INTO @D_note_id, @I_note_id,
             @D_note_scope,  @I_note_scope,
             @D_note_scope_id, @I_note_scope_id,
             @D_note_sts, @I_note_sts,
             @D_note_type, @I_note_type,
             @D_note_body, @I_note_body,
             @D_cust_id, @I_cust_id,
             @D_item_id, @I_item_id

  END
  CLOSE CUR_note__tbl_iud
  DEALLOCATE CUR_note__tbl_iud

  RETURN

END

GO
ALTER TABLE [{schema}].[note__tbl] ENABLE TRIGGER [note__tbl_iud]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE trigger [{schema}].[sys_user_iud] on [{schema}].[sys_user]
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
GO
ALTER TABLE [{schema}].[sys_user] ENABLE TRIGGER [sys_user_iud]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE trigger [{schema}].[param__tbl_iud] on [{schema}].[param__tbl]
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
  
  SET @MYGETDATE = {schema}.my_now()

  SET @MYUSER = {schema}.my_db_user() 

  if(@TP = 'I')
  BEGIN
  
    update {schema}.param__tbl set
      param_etstmp = @MYGETDATE,
      param_euser =@MYUSER, 
      param_mtstmp = @MYGETDATE,
      param_muser =@MYUSER 
      from INSERTED
      WHERE param__tbl.param_id=INSERTED.param_id 
  
  END
  ELSE 
  BEGIN
  
    if(@TP = 'U')
    BEGIN
      update {schema}.param__tbl set
        param_mtstmp = @MYGETDATE,
        param_muser =@MYUSER 
      from inserted 
      WHERE param__tbl.param_id=INSERTED.param_id 
    END

  END

  RETURN

END



GO
ALTER TABLE [{schema}].[param__tbl] ENABLE TRIGGER [param__tbl_iud]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE trigger [{schema}].[param_user_iud] on [{schema}].[param_user]
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
  DECLARE @MY_audit_seq NUMERIC(20,0)
  DECLARE CUR_param_user_I CURSOR LOCAL FOR SELECT param_user_id,
                                      param_user_process, 
                                      param_user_attrib, 
                                      param_user_val
                                 FROM INSERTED
  DECLARE CUR_param_user_DU CURSOR LOCAL FOR 
     SELECT  del.param_user_id, i.param_user_id,
             del.param_user_process, i.param_user_process,
             del.param_user_attrib, i.param_user_attrib,
             del.param_user_val, i.param_user_val
       FROM deleted del FULL OUTER JOIN inserted i
                       ON i.param_user_id = del.param_user_id
  DECLARE @D_param_user_id bigint
  DECLARE @I_param_user_id bigint
  DECLARE @D_param_user_process nvarchar(MAX)
  DECLARE @I_param_user_process nvarchar(MAX)
  DECLARE @D_param_user_attrib nvarchar(MAX)
  DECLARE @I_param_user_attrib nvarchar(MAX)
  DECLARE @D_param_user_val nvarchar(MAX)
  DECLARE @I_param_user_val nvarchar(MAX)
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

  SET @CURDTTM = {schema}.my_now_exec()
  SET @CURDTTM_CHAR = CONVERT(NVARCHAR, @CURDTTM, 120)+'.0000000'
  SET @MYUSER = {schema}.my_db_user() 

  IF @TP = 'U' AND UPDATE(param_user_id)
  BEGIN
    raiserror('Cannot update identity',16,1)
    ROLLBACK TRANSACTION
    return
  END

  if(@TP = 'I')
  BEGIN
  
    update {schema}.param_user set
      param_user_etstmp = @CURDTTM,
      param_user_euser =@MYUSER, 
      param_user_mtstmp = @CURDTTM,
      param_user_muser =@MYUSER 
      from inserted WHERE param_user.param_user_id=INSERTED.param_user_id
  
    OPEN CUR_param_user_I
    FETCH NEXT FROM CUR_param_user_I INTO @I_param_user_id, 
                                   @I_param_user_process, 
                                   @I_param_user_attrib,
                                   @I_param_user_val
    WHILE (@@Fetch_Status = 0)
    BEGIN
      
      IF (@I_param_user_val IS NOT NULL)
      BEGIN
        SET @ERRTXT = {schema}.check_param('param_user',@I_param_user_process,@I_param_user_attrib,@I_param_user_val)
        IF @ERRTXT IS NOT null  
        BEGIN
          CLOSE CUR_param_user_I
          DEALLOCATE CUR_param_user_I
          raiserror(@ERRTXT,16,1)
          ROLLBACK TRANSACTION
          return
        END
      END

      SET @WK_ID = ISNULL(@I_param_user_id,@D_param_user_id)
      EXEC    @MY_audit_seq = {schema}.log_audit_base @TP, 'param_user', @WK_ID, @MYUSER, @CURDTTM

      FETCH NEXT FROM CUR_param_user_I INTO @I_param_user_id, 
                                     @I_param_user_process, 
                                     @I_param_user_attrib,
                                     @I_param_user_val
    END
    CLOSE CUR_param_user_I
    DEALLOCATE CUR_param_user_I
  END
  ELSE 
  BEGIN
  
    if(@TP = 'U')
    BEGIN
      update {schema}.param_user set
        param_user_mtstmp = @CURDTTM,
        param_user_muser =@MYUSER 
        from inserted WHERE param_user.param_user_id = INSERTED.param_user_id
    END

    OPEN CUR_param_user_DU
    FETCH NEXT FROM CUR_param_user_DU
          INTO @D_param_user_id, @I_param_user_id,
               @D_param_user_process, @I_param_user_process,
               @D_param_user_attrib, @I_param_user_attrib,
               @D_param_user_val, @I_param_user_val
    WHILE (@@Fetch_Status = 0)
    BEGIN
      if(@TP = 'U')
      BEGIN
     
        IF (@I_param_user_val IS NOT NULL)
        BEGIN
          SET @ERRTXT = {schema}.check_param('param_user',@I_param_user_process,@I_param_user_attrib,@I_param_user_val)
          IF @ERRTXT IS NOT null  
          BEGIN
            CLOSE CUR_param_user_DU
            DEALLOCATE CUR_param_user_DU
            raiserror(@ERRTXT,16,1)
            ROLLBACK TRANSACTION
            return
          END
        END
      END

      SET @WK_ID = ISNULL(@I_param_user_id,@D_param_user_id)
      EXEC    @MY_audit_seq = {schema}.log_audit_base @TP, 'param_user', @WK_ID, @MYUSER, @CURDTTM
            
      FETCH NEXT FROM CUR_param_user_DU
            INTO @D_param_user_id, @I_param_user_id,
                 @D_param_user_process, @I_param_user_process,
                 @D_param_user_attrib, @I_param_user_attrib,
                 @D_param_user_val, @I_param_user_val
    END
    CLOSE CUR_param_user_DU
    DEALLOCATE CUR_param_user_DU
  END

  RETURN

END

GO
ALTER TABLE [{schema}].[param_user] ENABLE TRIGGER [param_user_iud]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE trigger [{schema}].[sys_user_func_iud] on [{schema}].[sys_user_func]
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
  DECLARE CUR_sys_user_func_iud CURSOR LOCAL FOR
     SELECT  del.sys_user_func_id, i.sys_user_func_id,
             del.sys_user_id, i.sys_user_id,
             del.sys_func_name, i.sys_func_name
       FROM deleted del FULL OUTER JOIN inserted i
                       ON i.sys_user_func_id = del.sys_user_func_id;
  DECLARE @D_sys_user_func_id bigint
  DECLARE @I_sys_user_func_id bigint
  DECLARE @D_sys_user_id bigint
  DECLARE @I_sys_user_id bigint
  DECLARE @D_sys_func_name nvarchar(max)
  DECLARE @I_sys_func_name nvarchar(max)

  DECLARE @MYERROR_NO INT = 0
  DECLARE @MYERROR_MSG NVARCHAR(MAX) = NULL

  DECLARE @xloc nvarchar(MAX)
  DECLARE @xtxt nvarchar(MAX)

  DECLARE @DYNSQL NVARCHAR(MAX)
  DECLARE @C BIGINT
  DECLARE @WK_sys_user_func_id BIGINT
  DECLARE @WK_audit_subject NVARCHAR(MAX)
  DECLARE @code_val NVARCHAR(MAX)

  /*
  EXEC [{schema}].[zz-filedebug] 'TRIGGER','sys_user_func_iud','START', ''
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

  IF @TP = 'U' AND UPDATE(sys_user_func_id)
  BEGIN
    EXEC [{schema}].[zz-filedebug] 'TRIGGER','sys_user_func_iud','ERR', 'Cannot update ID'
    raiserror('Cannot update identity',16,1)
    ROLLBACK TRANSACTION
    return
  END

  IF @TP = 'U' AND UPDATE(sys_user_id)
  BEGIN
    EXEC [{schema}].[zz-filedebug] 'TRIGGER','sys_user_func_iud','ERR', 'Cannot update sys_user_id'
    raiserror('Cannot update foreign key',16,1)
    ROLLBACK TRANSACTION
    return
  END

  
  OPEN CUR_sys_user_func_iud
  FETCH NEXT FROM CUR_sys_user_func_iud
        INTO @D_sys_user_func_id, @I_sys_user_func_id,
             @D_sys_user_id, @I_sys_user_id,
             @D_sys_func_name, @I_sys_func_name

  WHILE (@@Fetch_Status = 0)
  BEGIN
      
    SET @xloc = 'TP=' + ISNULL(@TP,'null')
    SET @xtxt = 'I_sys_user_func_id=' + LTRIM(ISNULL(STR(@I_sys_user_func_id),'null')) +
                ' doc__tbl_sys_user_func_id=' + LTRIM(ISNULL(STR(@D_sys_user_func_id),'null')) 
    /* 
    EXEC [{schema}].[zz-filedebug] 'TRIGGER','sys_user_func_iud',@xloc, @xtxt 
    */

    /******************************************/
    /****** SPECIAL FRONT ACTION - BEGIN ******/
    /******************************************/
    
    SELECT @WK_audit_subject = isnull(sys_user_lname,'')+', '+isnull(sys_user_fname,'')
      FROM {schema}.sys_user
     WHERE sys_user_id = @I_sys_user_id; 

    /******************************************/
    /****** SPECIAL FRONT ACTION - END   ******/
    /******************************************/

    SET @MY_audit_seq = 0
    IF (@TP='I' OR @TP='D')
    BEGIN  
      SET @WK_sys_user_func_id = ISNULL(@D_sys_user_func_id,@I_sys_user_func_id)
      EXEC    @MY_audit_seq = {schema}.log_audit_base @TP, 'sys_user_func', @WK_sys_user_func_id, @MYUSER, @CURDTTM,default,default,@WK_audit_subject
    END

    IF @TP='U' OR @TP='D'
    BEGIN

      IF (@TP = 'D' AND @D_sys_user_id IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_num(@D_sys_user_id, @I_sys_user_id) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base 'U', 'sys_user_func', @I_sys_user_func_id, @MYUSER, @CURDTTM,default,default,@WK_audit_subject
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('sys_user_id'), @D_sys_user_id)
      END

      IF (@TP = 'D' AND @D_sys_func_name IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_sys_func_name, @I_sys_func_name) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base 'U', 'sys_user_func', @I_sys_user_func_id, @MYUSER, @CURDTTM,default,default,@WK_audit_subject
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('sys_func_name'), @D_sys_func_name)
      END

    END  /* END OF "IF @TP='U' OR @TP='D'"  */

    /******************************************/
    /****** SPECIAL BACK ACTION - BEGIN  ******/
    /******************************************/

    /*****************************************/
    /****** SPECIAL BACK ACTION - END   ******/
    /*****************************************/
            
    FETCH NEXT FROM CUR_sys_user_func_iud
          INTO @D_sys_user_func_id, @I_sys_user_func_id,
               @D_sys_user_id,  @I_sys_user_id,
               @D_sys_func_name,  @I_sys_func_name
  END
  CLOSE CUR_sys_user_func_iud
  DEALLOCATE CUR_sys_user_func_iud
  /*
  EXEC [{schema}].[zz-filedebug] 'TRIGGER','sys_user_func_iud','RETURN', ''
  */
  RETURN

END
GO
ALTER TABLE [{schema}].[sys_user_func] ENABLE TRIGGER [sys_user_func_iud]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE trigger [{schema}].[sys_user_role_iud] on [{schema}].[sys_user_role]
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
  DECLARE CUR_sys_user_role_iud CURSOR LOCAL FOR
     SELECT  del.sys_user_role_id, i.sys_user_role_id,
             del.sys_user_id, i.sys_user_id,
             del.sys_role_name, i.sys_role_name
       FROM deleted del FULL OUTER JOIN inserted i
                       ON i.sys_user_role_id = del.sys_user_role_id;
  DECLARE @D_sys_user_role_id bigint
  DECLARE @I_sys_user_role_id bigint
  DECLARE @D_sys_user_id bigint
  DECLARE @I_sys_user_id bigint
  DECLARE @D_sys_role_name nvarchar(max)
  DECLARE @I_sys_role_name nvarchar(max)

  DECLARE @MYERROR_NO INT = 0
  DECLARE @MYERROR_MSG NVARCHAR(MAX) = NULL

  DECLARE @xloc nvarchar(MAX)
  DECLARE @xtxt nvarchar(MAX)

  DECLARE @DYNSQL NVARCHAR(MAX)
  DECLARE @C BIGINT
  DECLARE @WK_sys_user_role_id BIGINT
  DECLARE @WK_audit_subject NVARCHAR(MAX)
  DECLARE @code_val NVARCHAR(MAX)

  DECLARE @MY_sys_user_id BIGINT = {schema}.my_sys_user_id()

  /*
  EXEC [{schema}].[zz-filedebug] 'TRIGGER','sys_user_role_iud','START', ''
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

  IF @TP = 'U' AND UPDATE(sys_user_role_id)
  BEGIN
    EXEC [{schema}].[zz-filedebug] 'TRIGGER','sys_user_role_iud','ERR', 'Cannot update ID'
    raiserror('Cannot update identity',16,1)
    ROLLBACK TRANSACTION
    return
  END

  IF @TP = 'U' AND UPDATE(sys_user_id)
  BEGIN
    EXEC [{schema}].[zz-filedebug] 'TRIGGER','sys_user_role_iud','ERR', 'Cannot update sys_user_id'
    raiserror('Cannot update foreign key',16,1)
    ROLLBACK TRANSACTION
    return
  END

  
  OPEN CUR_sys_user_role_iud
  FETCH NEXT FROM CUR_sys_user_role_iud
        INTO @D_sys_user_role_id, @I_sys_user_role_id,
             @D_sys_user_id, @I_sys_user_id,
             @D_sys_role_name, @I_sys_role_name

  WHILE (@@Fetch_Status = 0)
  BEGIN
      
    SET @xloc = 'TP=' + ISNULL(@TP,'null')
    SET @xtxt = 'I_sys_user_role_id=' + LTRIM(ISNULL(STR(@I_sys_user_role_id),'null')) +
                ' doc__tbl_sys_user_role_id=' + LTRIM(ISNULL(STR(@D_sys_user_role_id),'null')) 
    /*
    EXEC [{schema}].[zz-filedebug] 'TRIGGER','sys_user_role_iud',@xloc, @xtxt
    */

    /******************************************/
    /****** SPECIAL FRONT ACTION - BEGIN ******/
    /******************************************/

    IF @MY_sys_user_id is not null
    BEGIN
      IF isnull(@I_sys_user_id, @D_sys_user_id) <> @MY_sys_user_id
      BEGIN
        /* NOT ME */
        IF (case when @TP = 'D' then @D_sys_role_name else @I_sys_role_name end) = 'DEV' 
        BEGIN
          IF not exists (select sys_role_name
                           from {schema}.v_my_roles
                          where sys_role_name = 'DEV') 
          BEGIN
            EXEC [{schema}].[zz-filedebug] 'TRIGGER','sys_user_role_iud','ERR', 'Only Developer can maintain Developer Role(1)'
            raiserror('Application Error - Only Developer can maintain Developer Role(1).',16,1)
            ROLLBACK TRANSACTION
            return
          END
        END
      END
      ELSE 
      BEGIN
        /* ME */
        IF @TP <> 'D' and @I_sys_role_name = 'DEV' 
        BEGIN
          EXEC [{schema}].[zz-filedebug] 'TRIGGER','sys_user_role_iud','ERR', 'Only Developer can maintain Developer Role(2)'
          raiserror('Application Error - Only Developer can maintain Developer Role(2).',16,1)
          ROLLBACK TRANSACTION
          return
        END
      END
    END

    SELECT @WK_audit_subject = isnull(sys_user_lname,'')+', '+isnull(sys_user_fname,'')
      FROM {schema}.sys_user
     WHERE sys_user_id = @I_sys_user_id; 

    /******************************************/
    /****** SPECIAL FRONT ACTION - END   ******/
    /******************************************/

    SET @MY_audit_seq = 0
    IF (@TP='I' OR @TP='D')
    BEGIN  
      SET @WK_sys_user_role_id = ISNULL(@D_sys_user_role_id,@I_sys_user_role_id)
      EXEC    @MY_audit_seq = {schema}.log_audit_base @TP, 'sys_user_role', @WK_sys_user_role_id, @MYUSER, @CURDTTM,default,default,@WK_audit_subject
    END

    IF @TP='U' OR @TP='D'
    BEGIN

      IF (@TP = 'D' AND @D_sys_user_id IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_num(@D_sys_user_id, @I_sys_user_id) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base 'U', 'sys_user_role', @I_sys_user_role_id, @MYUSER, @CURDTTM,default,default,@WK_audit_subject
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('sys_user_id'), @D_sys_user_id)
      END

      IF (@TP = 'D' AND @D_sys_role_name IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_sys_role_name, @I_sys_role_name) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base 'U', 'sys_user_role', @I_sys_user_role_id, @MYUSER, @CURDTTM,default,default,@WK_audit_subject
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('sys_role_name'), @D_sys_role_name)
      END

    END  /* END OF "IF @TP='U' OR @TP='D'"  */

    /******************************************/
    /****** SPECIAL BACK ACTION - BEGIN  ******/
    /******************************************/

    /*****************************************/
    /****** SPECIAL BACK ACTION - END   ******/
    /*****************************************/
            
    FETCH NEXT FROM CUR_sys_user_role_iud
          INTO @D_sys_user_role_id, @I_sys_user_role_id,
               @D_sys_user_id,  @I_sys_user_id,
               @D_sys_role_name,  @I_sys_role_name
  END
  CLOSE CUR_sys_user_role_iud
  DEALLOCATE CUR_sys_user_role_iud

  /*
  EXEC [{schema}].[zz-filedebug] 'TRIGGER','sys_user_role_iud','RETURN', ''
  */

  RETURN

END
GO
ALTER TABLE [{schema}].[sys_user_role] ENABLE TRIGGER [sys_user_role_iud]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE trigger [{schema}].[txt__tbl_iud] on [{schema}].[txt__tbl]
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
  DECLARE CUR_TXT_iud CURSOR LOCAL FOR
     SELECT  del.txt_id, i.txt_id,
             del.txt_process, i.txt_process,
             del.txt_attrib, i.txt_attrib,
             del.txt_type, i.txt_type,
             del.txt_title, i.txt_title,
             del.txt_body, i.txt_body,
             del.txt_bcc, i.txt_bcc,
             del.txt_desc, i.txt_desc
       FROM deleted del FULL OUTER JOIN inserted i
                       ON i.txt_id = del.txt_id;
  DECLARE @D_txt_id bigint
  DECLARE @I_txt_id bigint
  DECLARE @D_txt_process NVARCHAR(MAX)
  DECLARE @I_txt_process NVARCHAR(MAX)
  DECLARE @D_txt_attrib NVARCHAR(MAX)
  DECLARE @I_txt_attrib NVARCHAR(MAX)
  DECLARE @D_txt_type NVARCHAR(MAX)
  DECLARE @I_txt_type NVARCHAR(MAX)
  DECLARE @D_txt_title NVARCHAR(MAX)
  DECLARE @I_txt_title NVARCHAR(MAX)
  DECLARE @D_txt_body NVARCHAR(MAX) 
  DECLARE @I_txt_body NVARCHAR(MAX)
  DECLARE @D_txt_bcc NVARCHAR(MAX) 
  DECLARE @I_txt_bcc NVARCHAR(MAX)
  DECLARE @D_txt_desc NVARCHAR(MAX) 
  DECLARE @I_txt_desc NVARCHAR(MAX)

  DECLARE @MYERROR_NO INT = 0
  DECLARE @MYERROR_MSG NVARCHAR(MAX) = NULL

  DECLARE @xloc nvarchar(MAX)
  DECLARE @xtxt nvarchar(MAX)

  DECLARE @DYNSQL NVARCHAR(MAX)
  DECLARE @C BIGINT
  DECLARE @code_val NVARCHAR(MAX)
  DECLARE @WK_txt_id bigint
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

  IF @TP = 'U' AND UPDATE(txt_id)
  BEGIN
    EXEC [{schema}].[zz-filedebug] 'TRIGGER','txt__tbl_iud','ERR', 'Cannot update ID'
    raiserror('Cannot update identity',16,1)
    ROLLBACK TRANSACTION
    return
  END

  
  OPEN CUR_TXT_iud
  FETCH NEXT FROM CUR_TXT_iud
        INTO @D_txt_id, @I_txt_id,
             @D_txt_process, @I_txt_process,
             @D_txt_attrib, @I_txt_attrib,
             @D_txt_type, @I_txt_type,
             @D_txt_title, @I_txt_title,
             @D_txt_body, @I_txt_body,
             @D_txt_bcc, @I_txt_bcc,
             @D_txt_desc, @I_txt_desc

  WHILE (@@Fetch_Status = 0)
  BEGIN

    /******************************************/
    /****** SPECIAL FRONT ACTION - BEGIN ******/
    /******************************************/

    IF (@TP='I')
    BEGIN
      UPDATE {schema}.txt__tbl
         SET txt_etstmp = @CURDTTM,
             txt_euser = @MYUSER,
             txt_mtstmp = @CURDTTM,
             txt_muser = @MYUSER
       WHERE txt__tbl.txt_id = @I_txt_id;
    END  

    /******************************************/
    /****** SPECIAL FRONT ACTION - END   ******/
    /******************************************/


    SET @MY_audit_seq = 0
    IF (@TP='I' OR @TP='D')
    BEGIN  
      SET @WK_txt_id = ISNULL(@D_txt_id,@I_txt_id)
      EXEC    @MY_audit_seq = {schema}.log_audit_base @TP, 'txt__tbl', @WK_txt_id, @MYUSER, @CURDTTM
    END

 
    IF @TP='U' OR @TP='D'
    BEGIN

      IF (@TP = 'D' AND @D_txt_process IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_txt_process, @I_txt_process) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base 'U', 'txt__tbl', @I_txt_id, @MYUSER, @CURDTTM
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('txt_process'), @D_txt_process)
      END

      IF (@TP = 'D' AND @D_txt_attrib IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_txt_attrib, @I_txt_attrib) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base 'U', 'txt__tbl', @I_txt_id, @MYUSER, @CURDTTM
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('txt_attrib'), @D_txt_attrib)
      END
      
      IF (@TP = 'D' AND @D_txt_type IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_txt_type, @I_txt_type) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base 'U', 'txt__tbl', @I_txt_id, @MYUSER, @CURDTTM
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('txt_type'), @D_txt_type)
      END

      IF (@TP = 'D' AND @D_txt_title IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_txt_title, @I_txt_title) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base 'U', 'txt__tbl', @I_txt_id, @MYUSER, @CURDTTM
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('txt_title'), @D_txt_title)
      END

      IF (@TP = 'D' AND @D_txt_body IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_txt_body, @I_txt_body) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base 'U', 'txt__tbl', @I_txt_id, @MYUSER, @CURDTTM
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('txt_body'), @D_txt_body)
      END

      IF (@TP = 'D' AND @D_txt_bcc IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_txt_bcc, @I_txt_bcc) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base 'U', 'txt__tbl', @I_txt_id, @MYUSER, @CURDTTM
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('txt_bcc'), @D_txt_bcc)
      END

      IF (@TP = 'D' AND @D_txt_desc IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_txt_desc, @I_txt_desc) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit_base 'U', 'txt__tbl', @I_txt_id, @MYUSER, @CURDTTM
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('txt_desc'), @D_txt_desc)
      END


    END  /* END OF "IF @TP='U' OR @TP='D'"  */


    /******************************************/
    /****** SPECIAL BACK ACTION - BEGIN  ******/
    /******************************************/

    IF (@TP='U' AND @MY_audit_seq <> 0)
    BEGIN
      UPDATE {schema}.txt__tbl
         SET txt_mtstmp = @CURDTTM,
             txt_muser = @MYUSER
       WHERE txt__tbl.txt_id = @I_txt_id;
    END  

    /*****************************************/
    /****** SPECIAL BACK ACTION - END   ******/
    /*****************************************/



            
    FETCH NEXT FROM CUR_TXT_iud
        INTO @D_txt_id, @I_txt_id,
             @D_txt_process,  @I_txt_process,
             @D_txt_attrib, @I_txt_attrib,
             @D_txt_type, @I_txt_type,
             @D_txt_title, @I_txt_title,
             @D_txt_body, @I_txt_body,
             @D_txt_bcc, @I_txt_bcc,
             @D_txt_desc, @I_txt_desc

  END
  CLOSE CUR_TXT_iud
  DEALLOCATE CUR_TXT_iud

  RETURN

  ERROR_BAD:  

  CLOSE CUR_PL_iud
  DEALLOCATE CUR_PL_iud
  raiserror(@M ,16,1)
  ROLLBACK TRANSACTION
  return

END

GO
ALTER TABLE [{schema}].[txt__tbl] ENABLE TRIGGER [txt__tbl_iud]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE trigger [{schema}].[param_sys_iud] on [{schema}].[param_sys]
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
  DECLARE @MY_audit_seq NUMERIC(20,0)
  DECLARE CUR_param_sys_I CURSOR LOCAL FOR SELECT param_sys_id,
                                      param_sys_process, 
                                      param_sys_attrib, 
                                      param_sys_val
                                 FROM INSERTED
  DECLARE CUR_param_sys_DU CURSOR LOCAL FOR 
     SELECT  del.param_sys_id, i.param_sys_id,
             del.param_sys_process, i.param_sys_process,
             del.param_sys_attrib, i.param_sys_attrib,
             del.param_sys_val, i.param_sys_val
       FROM deleted del FULL OUTER JOIN inserted i
                       ON i.param_sys_id = del.param_sys_id
  DECLARE @D_param_sys_id bigint
  DECLARE @I_param_sys_id bigint
  DECLARE @D_param_sys_process nvarchar(MAX)
  DECLARE @I_param_sys_process nvarchar(MAX)
  DECLARE @D_param_sys_attrib nvarchar(MAX)
  DECLARE @I_param_sys_attrib nvarchar(MAX)
  DECLARE @D_param_sys_val nvarchar(MAX)
  DECLARE @I_param_sys_val nvarchar(MAX)
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

  SET @CURDTTM = {schema}.my_now_exec()
  SET @CURDTTM_CHAR = CONVERT(NVARCHAR, @CURDTTM, 120)+'.0000000'
  SET @MYUSER = {schema}.my_db_user() 

  IF @TP = 'U' AND UPDATE(param_sys_id)
  BEGIN
    raiserror('Cannot update identity',16,1)
    ROLLBACK TRANSACTION
    return
  END

  if(@TP = 'I')
  BEGIN
  
    update {schema}.param_sys set
      param_sys_etstmp = @CURDTTM,
      param_sys_euser =@MYUSER, 
      param_sys_mtstmp = @CURDTTM,
      param_sys_muser =@MYUSER 
      from inserted WHERE param_sys.param_sys_id=INSERTED.param_sys_id
  
    OPEN CUR_param_sys_I
    FETCH NEXT FROM CUR_param_sys_I INTO @I_param_sys_id, 
                                   @I_param_sys_process, 
                                   @I_param_sys_attrib,
                                   @I_param_sys_val
    WHILE (@@Fetch_Status = 0)
    BEGIN
      
      SET @ERRTXT = {schema}.check_param('param_sys',@I_param_sys_process,@I_param_sys_attrib,@I_param_sys_val)
      
      IF @ERRTXT IS NOT null  
      BEGIN
        CLOSE CUR_param_sys_I
        DEALLOCATE CUR_param_sys_I
        raiserror(@ERRTXT,16,1)
        ROLLBACK TRANSACTION
        return
      END

      SET @WK_ID = ISNULL(@I_param_sys_id,@D_param_sys_id)
      EXEC    @MY_audit_seq = {schema}.log_audit_base @TP, 'param_sys', @WK_ID, @MYUSER, @CURDTTM

      FETCH NEXT FROM CUR_param_sys_I INTO @I_param_sys_id, 
                                     @I_param_sys_process, 
                                     @I_param_sys_attrib,
                                     @I_param_sys_val
    END
    CLOSE CUR_param_sys_I
    DEALLOCATE CUR_param_sys_I
  END
  ELSE 
  BEGIN
  
    if(@TP = 'U')
    BEGIN
      update {schema}.param_sys set
        param_sys_mtstmp = @CURDTTM,
        param_sys_muser =@MYUSER 
        from inserted WHERE param_sys.param_sys_id = INSERTED.param_sys_id
    END

    OPEN CUR_param_sys_DU
    FETCH NEXT FROM CUR_param_sys_DU
          INTO @D_param_sys_id, @I_param_sys_id,
               @D_param_sys_process, @I_param_sys_process,
               @D_param_sys_attrib, @I_param_sys_attrib,
               @D_param_sys_val, @I_param_sys_val
    WHILE (@@Fetch_Status = 0)
    BEGIN
      if(@TP = 'U')
      BEGIN
      
        SET @ERRTXT = {schema}.check_param('param_sys',@I_param_sys_process,@I_param_sys_attrib,@I_param_sys_val)
       
        IF @ERRTXT IS NOT null  
        BEGIN
          CLOSE CUR_param_sys_DU
          DEALLOCATE CUR_param_sys_DU
          raiserror(@ERRTXT,16,1)
          ROLLBACK TRANSACTION
          return
        END
      END

      SET @WK_ID = ISNULL(@I_param_sys_id,@D_param_sys_id)
      EXEC    @MY_audit_seq = {schema}.log_audit_base @TP, 'param_sys', @WK_ID, @MYUSER, @CURDTTM
            
      FETCH NEXT FROM CUR_param_sys_DU
            INTO @D_param_sys_id, @I_param_sys_id,
                 @D_param_sys_process, @I_param_sys_process,
                 @D_param_sys_attrib, @I_param_sys_attrib,
                 @D_param_sys_val, @I_param_sys_val
    END
    CLOSE CUR_param_sys_DU
    DEALLOCATE CUR_param_sys_DU
  END

  RETURN

END

GO
ALTER TABLE [{schema}].[param_sys] ENABLE TRIGGER [param_sys_iud]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE trigger [{schema}].[v_sys_menu_role_selection_iud_INSTEADOF_UPDATE] on [{schema}].[v_sys_menu_role_selection]
instead of update
as
begin
  set nocount on
  declare @I int
  IF (UPDATE(sys_menu_role_selection))
  BEGIN
  set @I = 1

    delete from {schema}.sys_menu_role
     where sys_menu_role_id in (
       select i.sys_menu_role_id
         from inserted i
        inner join deleted del on del.menu_id=i.menu_id
        where {schema}.nequal_num(del.sys_menu_role_selection, i.sys_menu_role_selection) > 0
          and isnull(i.sys_menu_role_selection,0) = 0);

     
    insert into {schema}.sys_menu_role (sys_role_name, menu_id)
       select i.new_sys_role_name, i.menu_id
         from inserted i
        inner join deleted del on del.menu_id=i.menu_id
        where {schema}.nequal_num(del.sys_menu_role_selection, i.sys_menu_role_selection) > 0
          and isnull(i.sys_menu_role_selection,0) = 1
          and isnull(i.new_sys_role_name,'')<>'';
     
    insert into {schema}.sys_menu_role (sys_role_name, menu_id)
       select i.sys_role_name, i.new_menu_id
         from inserted i
        inner join deleted del on del.menu_id=i.menu_id
        where {schema}.nequal_num(del.sys_menu_role_selection, i.sys_menu_role_selection) > 0
          and isnull(i.sys_menu_role_selection,0) = 1
          and isnull(i.new_sys_role_name,'')='';
     
  END
end


GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit_detail', @level2type=N'COLUMN',@level2name=N'audit_seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit_detail', @level2type=N'COLUMN',@level2name=N'audit_seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit_detail', @level2type=N'COLUMN',@level2name=N'audit_seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit_detail', @level2type=N'COLUMN',@level2name=N'audit_seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit_detail', @level2type=N'COLUMN',@level2name=N'audit_seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Audit Trail Sequence - audit__tbl' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit_detail', @level2type=N'COLUMN',@level2name=N'audit_seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=0x00 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit_detail', @level2type=N'COLUMN',@level2name=N'audit_seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit_detail', @level2type=N'COLUMN',@level2name=N'audit_column_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit_detail', @level2type=N'COLUMN',@level2name=N'audit_column_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit_detail', @level2type=N'COLUMN',@level2name=N'audit_column_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit_detail', @level2type=N'COLUMN',@level2name=N'audit_column_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit_detail', @level2type=N'COLUMN',@level2name=N'audit_column_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Audit Trail Detail Column Name' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit_detail', @level2type=N'COLUMN',@level2name=N'audit_column_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=0x00 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit_detail', @level2type=N'COLUMN',@level2name=N'audit_column_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit_detail', @level2type=N'COLUMN',@level2name=N'audit_column_val'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit_detail', @level2type=N'COLUMN',@level2name=N'audit_column_val'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit_detail', @level2type=N'COLUMN',@level2name=N'audit_column_val'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=4515 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit_detail', @level2type=N'COLUMN',@level2name=N'audit_column_val'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit_detail', @level2type=N'COLUMN',@level2name=N'audit_column_val'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Audit Trail Detail Previous Value' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit_detail', @level2type=N'COLUMN',@level2name=N'audit_column_val'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=0x00 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit_detail', @level2type=N'COLUMN',@level2name=N'audit_column_val'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Audit Trail Detail (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit_detail'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl', @level2type=N'COLUMN',@level2name=N'audit_seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl', @level2type=N'COLUMN',@level2name=N'audit_seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl', @level2type=N'COLUMN',@level2name=N'audit_seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl', @level2type=N'COLUMN',@level2name=N'audit_seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl', @level2type=N'COLUMN',@level2name=N'audit_seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Audit Trail Sequence' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl', @level2type=N'COLUMN',@level2name=N'audit_seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl', @level2type=N'COLUMN',@level2name=N'audit_seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl', @level2type=N'COLUMN',@level2name=N'audit_table_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl', @level2type=N'COLUMN',@level2name=N'audit_table_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl', @level2type=N'COLUMN',@level2name=N'audit_table_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=960 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl', @level2type=N'COLUMN',@level2name=N'audit_table_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl', @level2type=N'COLUMN',@level2name=N'audit_table_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Audit Trail Header Table Name' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl', @level2type=N'COLUMN',@level2name=N'audit_table_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl', @level2type=N'COLUMN',@level2name=N'audit_table_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl', @level2type=N'COLUMN',@level2name=N'audit_table_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl', @level2type=N'COLUMN',@level2name=N'audit_table_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl', @level2type=N'COLUMN',@level2name=N'audit_table_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl', @level2type=N'COLUMN',@level2name=N'audit_table_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl', @level2type=N'COLUMN',@level2name=N'audit_table_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Audit Trail Header ID Value' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl', @level2type=N'COLUMN',@level2name=N'audit_table_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl', @level2type=N'COLUMN',@level2name=N'audit_table_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl', @level2type=N'COLUMN',@level2name=N'audit_op'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl', @level2type=N'COLUMN',@level2name=N'audit_op'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl', @level2type=N'COLUMN',@level2name=N'audit_op'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl', @level2type=N'COLUMN',@level2name=N'audit_op'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl', @level2type=N'COLUMN',@level2name=N'audit_op'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Audit Trail Header Operation - DUI' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl', @level2type=N'COLUMN',@level2name=N'audit_op'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl', @level2type=N'COLUMN',@level2name=N'audit_op'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl', @level2type=N'COLUMN',@level2name=N'audit_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl', @level2type=N'COLUMN',@level2name=N'audit_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl', @level2type=N'COLUMN',@level2name=N'audit_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl', @level2type=N'COLUMN',@level2name=N'audit_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl', @level2type=N'COLUMN',@level2name=N'audit_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Audit Trail Header User Number' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl', @level2type=N'COLUMN',@level2name=N'audit_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl', @level2type=N'COLUMN',@level2name=N'audit_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl', @level2type=N'COLUMN',@level2name=N'audit_tstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl', @level2type=N'COLUMN',@level2name=N'audit_tstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl', @level2type=N'COLUMN',@level2name=N'audit_tstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=3690 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl', @level2type=N'COLUMN',@level2name=N'audit_tstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl', @level2type=N'COLUMN',@level2name=N'audit_tstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Audit Trail Header Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl', @level2type=N'COLUMN',@level2name=N'audit_tstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl', @level2type=N'COLUMN',@level2name=N'audit_tstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Customer ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl', @level2type=N'COLUMN',@level2name=N'cust_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Equipment ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl', @level2type=N'COLUMN',@level2name=N'item_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Reference Name' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl', @level2type=N'COLUMN',@level2name=N'audit_ref_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Reference ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl', @level2type=N'COLUMN',@level2name=N'audit_ref_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Subject' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl', @level2type=N'COLUMN',@level2name=N'audit_subject'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Audit Trail Header (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'audit__tbl'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'doc__tbl', @level2type=N'COLUMN',@level2name=N'doc_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document Scope - code_doc_scope' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'doc__tbl', @level2type=N'COLUMN',@level2name=N'doc_scope'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document Scope ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'doc__tbl', @level2type=N'COLUMN',@level2name=N'doc_scope_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client ID - C' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'doc__tbl', @level2type=N'COLUMN',@level2name=N'cust_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Employee ID - E' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'doc__tbl', @level2type=N'COLUMN',@level2name=N'item_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document Status - code_ac1' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'doc__tbl', @level2type=N'COLUMN',@level2name=N'doc_sts'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document Category - code2_doc_scope_doc_ctgr' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'doc__tbl', @level2type=N'COLUMN',@level2name=N'doc_ctgr'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document Description' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'doc__tbl', @level2type=N'COLUMN',@level2name=N'doc_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document Extension (file suffix)' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'doc__tbl', @level2type=N'COLUMN',@level2name=N'doc_ext'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document Size in bytes' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'doc__tbl', @level2type=N'COLUMN',@level2name=N'doc_size'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document File Name' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'doc__tbl', @level2type=N'COLUMN',@level2name=N'doc_filename'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'doc__tbl', @level2type=N'COLUMN',@level2name=N'doc_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document Entry User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'doc__tbl', @level2type=N'COLUMN',@level2name=N'doc_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'doc__tbl', @level2type=N'COLUMN',@level2name=N'doc_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'doc__tbl', @level2type=N'COLUMN',@level2name=N'doc_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document Last Upload Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'doc__tbl', @level2type=N'COLUMN',@level2name=N'doc_uptstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document Last Upload User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'doc__tbl', @level2type=N'COLUMN',@level2name=N'doc_upuser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document Synchronization Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'doc__tbl', @level2type=N'COLUMN',@level2name=N'doc_sync_tstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document System Notes' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'doc__tbl', @level2type=N'COLUMN',@level2name=N'doc_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document Main ID (Synchronization)' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'doc__tbl', @level2type=N'COLUMN',@level2name=N'doc_sync_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Documents (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'doc__tbl'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Table (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'single'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Name' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=2 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=5565 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Description' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Code Description' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_code_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Attrib Description' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_attrib_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_h_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_h_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=3 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_h_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_h_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_h_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_h_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_h_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_h_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_h_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=4 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_h_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_h_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_h_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Entry User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_h_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_h_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_h_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_h_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=5 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_h_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_h_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_h_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_h_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_h_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_h_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_h_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=6 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_h_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_h_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_h_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_h_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_h_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=7 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header System Notes' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app', @level2type=N'COLUMN',@level2name=N'code_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User Codes Header (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_app'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_doc_scope_doc_ctgr', @level2type=N'COLUMN',@level2name=N'code2_app_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Sequence' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_doc_scope_doc_ctgr', @level2type=N'COLUMN',@level2name=N'code_seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_doc_scope_doc_ctgr', @level2type=N'COLUMN',@level2name=N'code_val1'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Description' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_doc_scope_doc_ctgr', @level2type=N'COLUMN',@level2name=N'code_txt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Additional Code' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_doc_scope_doc_ctgr', @level2type=N'COLUMN',@level2name=N'code_code'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Date' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_doc_scope_doc_ctgr', @level2type=N'COLUMN',@level2name=N'code_end_dt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Comment' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_doc_scope_doc_ctgr', @level2type=N'COLUMN',@level2name=N'code_end_reason'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_doc_scope_doc_ctgr', @level2type=N'COLUMN',@level2name=N'code_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_doc_scope_doc_ctgr', @level2type=N'COLUMN',@level2name=N'code_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_doc_scope_doc_ctgr', @level2type=N'COLUMN',@level2name=N'code_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_doc_scope_doc_ctgr', @level2type=N'COLUMN',@level2name=N'code_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code System Notes' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_doc_scope_doc_ctgr', @level2type=N'COLUMN',@level2name=N'code_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User Codes 2 - Document Scope / Category' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_doc_scope_doc_ctgr'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Name' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=2 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=5565 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Description' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Code Description' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_code_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Attrib Description' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_attrib_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_h_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_h_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=3 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_h_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_h_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_h_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_h_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_h_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_h_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_h_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=4 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_h_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_h_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_h_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Entry User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_h_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_h_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_h_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_h_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=5 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_h_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_h_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_h_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_h_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_h_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_h_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_h_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=6 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_h_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_h_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_h_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_h_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_h_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=7 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header System Notes' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app', @level2type=N'COLUMN',@level2name=N'code_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User Codes 2 Header (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_app'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'param_app Process Name' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_app', @level2type=N'COLUMN',@level2name=N'param_app_process'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'param_app Attribute (Parameter) Name' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_app', @level2type=N'COLUMN',@level2name=N'param_app_attrib'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'param_app Attribute (Parameter) value' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_app', @level2type=N'COLUMN',@level2name=N'param_app_val'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Process Parameters - Global (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_app'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'help__tbl', @level2type=N'COLUMN',@level2name=N'help_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help Header Code' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'help__tbl', @level2type=N'COLUMN',@level2name=N'help_target_code'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help Title' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'help__tbl', @level2type=N'COLUMN',@level2name=N'help_title'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help Text' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'help__tbl', @level2type=N'COLUMN',@level2name=N'help_text'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'help__tbl', @level2type=N'COLUMN',@level2name=N'help_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help Entry User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'help__tbl', @level2type=N'COLUMN',@level2name=N'help_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help Last Modification Entry' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'help__tbl', @level2type=N'COLUMN',@level2name=N'help_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'help__tbl', @level2type=N'COLUMN',@level2name=N'help_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help UNIQUE - not null help_target_code unique' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'help__tbl', @level2type=N'COLUMN',@level2name=N'help_unq_code'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help Sequence' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'help__tbl', @level2type=N'COLUMN',@level2name=N'help_seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help - Show on Admin Index' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'help__tbl', @level2type=N'COLUMN',@level2name=N'help_listing_main'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help - Show on Portal Index' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'help__tbl', @level2type=N'COLUMN',@level2name=N'help_listing_client'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'help__tbl'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help Target Code' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'help_target', @level2type=N'COLUMN',@level2name=N'help_target_code'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help Target Description' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'help_target', @level2type=N'COLUMN',@level2name=N'help_target_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help Target ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'help_target', @level2type=N'COLUMN',@level2name=N'help_target_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Help Header (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'help_target'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Note ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'note__tbl', @level2type=N'COLUMN',@level2name=N'note_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Note Scope - code_note_scope' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'note__tbl', @level2type=N'COLUMN',@level2name=N'note_scope'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Note Scope ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'note__tbl', @level2type=N'COLUMN',@level2name=N'note_scope_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Note Status - code_ac1' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'note__tbl', @level2type=N'COLUMN',@level2name=N'note_sts'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client ID - C' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'note__tbl', @level2type=N'COLUMN',@level2name=N'cust_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Employee ID - E' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'note__tbl', @level2type=N'COLUMN',@level2name=N'item_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Note Type - code_note_type - C,S,U' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'note__tbl', @level2type=N'COLUMN',@level2name=N'note_type'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Note NOTE' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'note__tbl', @level2type=N'COLUMN',@level2name=N'note_body'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Note Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'note__tbl', @level2type=N'COLUMN',@level2name=N'note_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Note Entry User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'note__tbl', @level2type=N'COLUMN',@level2name=N'note_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Note Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'note__tbl', @level2type=N'COLUMN',@level2name=N'note_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Note Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'note__tbl', @level2type=N'COLUMN',@level2name=N'note_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Note System Notes' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'note__tbl', @level2type=N'COLUMN',@level2name=N'note_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Notes (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'note__tbl'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Table (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'number__tbl'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Status ACTIVE, HOLD, CLOSED - code_ahc' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_sts'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_stsdt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_stsdt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_stsdt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_stsdt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_stsdt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Status Last Change Date' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_stsdt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_stsdt'
GO
EXEC sys.sp_addextendedproperty @name=N'TRIGGER', @value=N'Date' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_stsdt'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_fname'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_fname'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_fname'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_fname'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_fname'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_fname'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel First Name' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_fname'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_fname'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Middle Name' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_mname'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_lname'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_lname'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_lname'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_lname'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_lname'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_lname'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Last Name' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_lname'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_lname'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Job Title' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_jobtitle'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Business Phone Number' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_bphone'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Cell Phone Number' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_cphone'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel country - code_country' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_country'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel address' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_addr'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel city' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_city'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel state - code2_country_state' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_state'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel zip code' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_zip'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_email'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_email'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_email'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_email'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_email'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_email'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Email' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_email'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_email'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel start date' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_startdt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel end date' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_enddt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel user notes' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_unotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Entry User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Hash' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_hash'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel last login IP' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_lastlogin_ip'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel last login timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_lastlogin_tstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel System Notes' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user', @level2type=N'COLUMN',@level2name=N'sys_user_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'param__tbl Process Name' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param__tbl', @level2type=N'COLUMN',@level2name=N'param_process'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'param__tbl Attribute (Parameter) Name' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param__tbl', @level2type=N'COLUMN',@level2name=N'param_attrib'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'param__tbl Attribute (Parameter) Description' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param__tbl', @level2type=N'COLUMN',@level2name=N'param_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'param__tbl Attribute (Parameter) Type - code_param_type' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param__tbl', @level2type=N'COLUMN',@level2name=N'param_type'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Process Parameters Dictionary (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param__tbl'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_user', @level2type=N'COLUMN',@level2name=N'sys_user_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'param_sys Process Name' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_user', @level2type=N'COLUMN',@level2name=N'param_user_process'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'param_sys Attribute (Parameter) Name' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_user', @level2type=N'COLUMN',@level2name=N'param_user_attrib'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'param_sys Attribute (Parameter) value' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_user', @level2type=N'COLUMN',@level2name=N'param_user_val'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Process Parameters - Personal (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Queue Request ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'queue__tbl', @level2type=N'COLUMN',@level2name=N'queue_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Queue Request Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'queue__tbl', @level2type=N'COLUMN',@level2name=N'queue_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Queue Request Entry User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'queue__tbl', @level2type=N'COLUMN',@level2name=N'queue_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Queue Request Queue Name' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'queue__tbl', @level2type=N'COLUMN',@level2name=N'queue_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Queue Request Message' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'queue__tbl', @level2type=N'COLUMN',@level2name=N'queue_message'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Queue Request Result - OK, ERROR' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'queue__tbl', @level2type=N'COLUMN',@level2name=N'queue_rslt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Queue Request Result Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'queue__tbl', @level2type=N'COLUMN',@level2name=N'queue_rslt_tstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Queue Request Result User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'queue__tbl', @level2type=N'COLUMN',@level2name=N'queue_rslt_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Queue Request System Notes' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'queue__tbl', @level2type=N'COLUMN',@level2name=N'queue_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Queue Request (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'queue__tbl'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'job__tbl', @level2type=N'COLUMN',@level2name=N'job_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'job__tbl', @level2type=N'COLUMN',@level2name=N'job_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Entry User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'job__tbl', @level2type=N'COLUMN',@level2name=N'job_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Source - code_job_source' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'job__tbl', @level2type=N'COLUMN',@level2name=N'job_source'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Type - code_job_action' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'job__tbl', @level2type=N'COLUMN',@level2name=N'job_action'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Name' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'job__tbl', @level2type=N'COLUMN',@level2name=N'job_action_target'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Parameters' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'job__tbl', @level2type=N'COLUMN',@level2name=N'job_params'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Result - OK, ERROR' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'job__tbl', @level2type=N'COLUMN',@level2name=N'job_rslt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Result Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'job__tbl', @level2type=N'COLUMN',@level2name=N'job_rslt_tstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Result User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'job__tbl', @level2type=N'COLUMN',@level2name=N'job_rslt_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request System Notes' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'job__tbl', @level2type=N'COLUMN',@level2name=N'job_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'job__tbl'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Document ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'job_doc', @level2type=N'COLUMN',@level2name=N'job_doc_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'job_doc', @level2type=N'COLUMN',@level2name=N'job_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Document Scope' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'job_doc', @level2type=N'COLUMN',@level2name=N'doc_scope'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Document Scope ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'job_doc', @level2type=N'COLUMN',@level2name=N'doc_scope_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Document Category' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'job_doc', @level2type=N'COLUMN',@level2name=N'doc_ctgr'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Document Description' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'job_doc', @level2type=N'COLUMN',@level2name=N'doc_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request - Document (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'job_doc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Email ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'job_email', @level2type=N'COLUMN',@level2name=N'job_email_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'job_email', @level2type=N'COLUMN',@level2name=N'job_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Email SUBJECT' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'job_email', @level2type=N'COLUMN',@level2name=N'email_txt_attrib'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Email TO' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'job_email', @level2type=N'COLUMN',@level2name=N'email_to'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Email CC' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'job_email', @level2type=N'COLUMN',@level2name=N'email_cc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Email BCC' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'job_email', @level2type=N'COLUMN',@level2name=N'email_bcc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request - EMail (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'job_email'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Note ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'job_note', @level2type=N'COLUMN',@level2name=N'job_note_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'job_note', @level2type=N'COLUMN',@level2name=N'job_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Note Scope' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'job_note', @level2type=N'COLUMN',@level2name=N'note_scope'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Note Scope ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'job_note', @level2type=N'COLUMN',@level2name=N'note_scope_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Note Type' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'job_note', @level2type=N'COLUMN',@level2name=N'note_type'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Note Note' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'job_note', @level2type=N'COLUMN',@level2name=N'note_body'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request - Note (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'job_note'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action Document ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'job_queue', @level2type=N'COLUMN',@level2name=N'job_queue_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'job_queue', @level2type=N'COLUMN',@level2name=N'job_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request - queue__tbl (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'job_queue'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action SMS ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'job_sms', @level2type=N'COLUMN',@level2name=N'job_sms_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'job_sms', @level2type=N'COLUMN',@level2name=N'job_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action SMS SUBJECT' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'job_sms', @level2type=N'COLUMN',@level2name=N'sms_txt_attrib'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request Action SMS TO' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'job_sms', @level2type=N'COLUMN',@level2name=N'sms_to'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request - SMS (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'job_sms'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Scripts (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'script__tbl'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Function ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_func', @level2type=N'COLUMN',@level2name=N'sys_func_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Function Sequence' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_func', @level2type=N'COLUMN',@level2name=N'sys_func_seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Function Status Code(AHC) - ACTIVE, HOLD, CLOSED' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_func', @level2type=N'COLUMN',@level2name=N'sys_func_sts'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Function Name' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_func', @level2type=N'COLUMN',@level2name=N'sys_func_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Function Description' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_func', @level2type=N'COLUMN',@level2name=N'sys_func_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Function Code' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_func', @level2type=N'COLUMN',@level2name=N'sys_func_code'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Function Attrib' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_func', @level2type=N'COLUMN',@level2name=N'sys_func_attrib'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Function System Notes' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_func', @level2type=N'COLUMN',@level2name=N'sys_func_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Security - Functions (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_func'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Menu Item User Type - S-System, C-Customer' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_group'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'SIMD' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Menu Item ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_id'
GO
EXEC sys.sp_addextendedproperty @name=N'NT', @value=N'' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_id'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_sts'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_sts'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_sts'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=2 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_sts'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_sts'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_sts'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Menu Item Status Code(AHC) - ACTIVE, HOLD, CLOSED' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_sts'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_sts'
GO
EXEC sys.sp_addextendedproperty @name=N'NT', @value=N'note__tbl' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_sts'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=4 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=2550 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Menu Item Name' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=5 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Menu Item Sequence' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_seq'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=6 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=3090 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Menu Item Description' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_desc_ext'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_desc_ext'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=7 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_desc_ext'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=4470 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_desc_ext'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_desc_ext'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Menu Item Description Long' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_desc_ext'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_desc_ext'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_desc_ext2'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_desc_ext2'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=8 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_desc_ext2'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=8370 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_desc_ext2'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_desc_ext2'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Menu Item Description Very Long' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_desc_ext2'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_desc_ext2'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_cmd'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_cmd'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=9 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_cmd'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_cmd'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_cmd'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Menu Item Command' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_cmd'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_cmd'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_image'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_image'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=10 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_image'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_image'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_image'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'For buttons as SMs: unique identifier for image' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_image'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_image'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=11 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Menu Item System Notes' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl', @level2type=N'COLUMN',@level2name=N'menu_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Security - Menu Items (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'menu__tbl'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user_func', @level2type=N'COLUMN',@level2name=N'sys_user_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Function System Notes' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user_func', @level2type=N'COLUMN',@level2name=N'sys_user_func_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Function ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user_func', @level2type=N'COLUMN',@level2name=N'sys_user_func_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Function Name' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user_func', @level2type=N'COLUMN',@level2name=N'sys_func_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Security - Personnel Functions (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user_func'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user_role', @level2type=N'COLUMN',@level2name=N'sys_user_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Role System Notes' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user_role', @level2type=N'COLUMN',@level2name=N'sys_user_role_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personnel Role ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user_role', @level2type=N'COLUMN',@level2name=N'sys_user_role_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role Name' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user_role', @level2type=N'COLUMN',@level2name=N'sys_role_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Security - Personnel Roles (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_user_role'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'SIMD' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_role', @level2type=N'COLUMN',@level2name=N'sys_role_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_role', @level2type=N'COLUMN',@level2name=N'sys_role_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_role', @level2type=N'COLUMN',@level2name=N'sys_role_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_role', @level2type=N'COLUMN',@level2name=N'sys_role_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_role', @level2type=N'COLUMN',@level2name=N'sys_role_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_role', @level2type=N'COLUMN',@level2name=N'sys_role_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_role', @level2type=N'COLUMN',@level2name=N'sys_role_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_role', @level2type=N'COLUMN',@level2name=N'sys_role_id'
GO
EXEC sys.sp_addextendedproperty @name=N'NT', @value=N'' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_role', @level2type=N'COLUMN',@level2name=N'sys_role_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role Sequence' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_role', @level2type=N'COLUMN',@level2name=N'sys_role_seq'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_role', @level2type=N'COLUMN',@level2name=N'sys_role_sts'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_role', @level2type=N'COLUMN',@level2name=N'sys_role_sts'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_role', @level2type=N'COLUMN',@level2name=N'sys_role_sts'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_role', @level2type=N'COLUMN',@level2name=N'sys_role_sts'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_role', @level2type=N'COLUMN',@level2name=N'sys_role_sts'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_role', @level2type=N'COLUMN',@level2name=N'sys_role_sts'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role Status Code(AHC) - ACTIVE, HOLD, CLOSED' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_role', @level2type=N'COLUMN',@level2name=N'sys_role_sts'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_role', @level2type=N'COLUMN',@level2name=N'sys_role_sts'
GO
EXEC sys.sp_addextendedproperty @name=N'NT', @value=N'note__tbl' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_role', @level2type=N'COLUMN',@level2name=N'sys_role_sts'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_role', @level2type=N'COLUMN',@level2name=N'sys_role_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_role', @level2type=N'COLUMN',@level2name=N'sys_role_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_role', @level2type=N'COLUMN',@level2name=N'sys_role_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_role', @level2type=N'COLUMN',@level2name=N'sys_role_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_role', @level2type=N'COLUMN',@level2name=N'sys_role_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_role', @level2type=N'COLUMN',@level2name=N'sys_role_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role Name' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_role', @level2type=N'COLUMN',@level2name=N'sys_role_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_role', @level2type=N'COLUMN',@level2name=N'sys_role_name'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_role', @level2type=N'COLUMN',@level2name=N'sys_role_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_role', @level2type=N'COLUMN',@level2name=N'sys_role_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_role', @level2type=N'COLUMN',@level2name=N'sys_role_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_role', @level2type=N'COLUMN',@level2name=N'sys_role_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=4920 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_role', @level2type=N'COLUMN',@level2name=N'sys_role_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_role', @level2type=N'COLUMN',@level2name=N'sys_role_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role Description' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_role', @level2type=N'COLUMN',@level2name=N'sys_role_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_role', @level2type=N'COLUMN',@level2name=N'sys_role_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role Code' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_role', @level2type=N'COLUMN',@level2name=N'sys_role_code'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role Attrib' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_role', @level2type=N'COLUMN',@level2name=N'sys_role_attrib'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_role', @level2type=N'COLUMN',@level2name=N'sys_role_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_role', @level2type=N'COLUMN',@level2name=N'sys_role_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_role', @level2type=N'COLUMN',@level2name=N'sys_role_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_role', @level2type=N'COLUMN',@level2name=N'sys_role_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_role', @level2type=N'COLUMN',@level2name=N'sys_role_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role System Notes' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_role', @level2type=N'COLUMN',@level2name=N'sys_role_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_role', @level2type=N'COLUMN',@level2name=N'sys_role_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Security - Roles (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_role'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Menu Item ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_menu_role', @level2type=N'COLUMN',@level2name=N'menu_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role Menu Item System Notes' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_menu_role', @level2type=N'COLUMN',@level2name=N'sys_menu_role_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role Menu Item ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_menu_role', @level2type=N'COLUMN',@level2name=N'sys_menu_role_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role Name' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_menu_role', @level2type=N'COLUMN',@level2name=N'sys_role_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Security - Role Menu Items (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'sys_menu_role'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_process'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_process'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_process'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_process'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_process'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SPP Process Name' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_process'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_process'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_attrib'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_attrib'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_attrib'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_attrib'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_attrib'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SPP Attribute (Parameter) Name' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_attrib'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_attrib'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SPP Attribute (Parameter) Type HTML / TAXT - code_txt_type' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_type'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_title'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_title'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_title'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=1350 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_title'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_title'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SPP Attribute (Parameter) Title' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_title'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_title'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_body'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_body'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_body'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=10110 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_body'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_body'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SPP Attribute (Parameter) value' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_body'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_body'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SPP BCC' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_bcc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=525 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SPP Description' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SPP ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SPP Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SPP Entry User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SPP Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SPP Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl', @level2type=N'COLUMN',@level2name=N'txt_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'String Process Parameters (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'txt__tbl'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_ac', @level2type=N'COLUMN',@level2name=N'code_sys_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Sequence' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_ac', @level2type=N'COLUMN',@level2name=N'code_seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_ac', @level2type=N'COLUMN',@level2name=N'code_val'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Description' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_ac', @level2type=N'COLUMN',@level2name=N'code_txt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Additional Code' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_ac', @level2type=N'COLUMN',@level2name=N'code_code'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Date' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_ac', @level2type=N'COLUMN',@level2name=N'code_end_dt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Comment' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_ac', @level2type=N'COLUMN',@level2name=N'code_end_reason'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_ac', @level2type=N'COLUMN',@level2name=N'code_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_ac', @level2type=N'COLUMN',@level2name=N'code_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_ac', @level2type=N'COLUMN',@level2name=N'code_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_ac', @level2type=N'COLUMN',@level2name=N'code_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code System Notes' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_ac', @level2type=N'COLUMN',@level2name=N'code_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Codes - Active / Closed' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_ac'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_ac1', @level2type=N'COLUMN',@level2name=N'code_sys_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Sequence' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_ac1', @level2type=N'COLUMN',@level2name=N'code_seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_ac1', @level2type=N'COLUMN',@level2name=N'code_val'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Description' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_ac1', @level2type=N'COLUMN',@level2name=N'code_txt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Additional Code' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_ac1', @level2type=N'COLUMN',@level2name=N'code_code'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Date' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_ac1', @level2type=N'COLUMN',@level2name=N'code_end_dt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Comment' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_ac1', @level2type=N'COLUMN',@level2name=N'code_end_reason'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_ac1', @level2type=N'COLUMN',@level2name=N'code_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_ac1', @level2type=N'COLUMN',@level2name=N'code_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_ac1', @level2type=N'COLUMN',@level2name=N'code_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_ac1', @level2type=N'COLUMN',@level2name=N'code_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code System Notes' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_ac1', @level2type=N'COLUMN',@level2name=N'code_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Codes - A / C' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_ac1'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_ahc', @level2type=N'COLUMN',@level2name=N'code_sys_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Sequence' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_ahc', @level2type=N'COLUMN',@level2name=N'code_seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_ahc', @level2type=N'COLUMN',@level2name=N'code_val'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Description' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_ahc', @level2type=N'COLUMN',@level2name=N'code_txt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Additional Code' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_ahc', @level2type=N'COLUMN',@level2name=N'code_code'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Date' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_ahc', @level2type=N'COLUMN',@level2name=N'code_end_dt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Comment' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_ahc', @level2type=N'COLUMN',@level2name=N'code_end_reason'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_ahc', @level2type=N'COLUMN',@level2name=N'code_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_ahc', @level2type=N'COLUMN',@level2name=N'code_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_ahc', @level2type=N'COLUMN',@level2name=N'code_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_ahc', @level2type=N'COLUMN',@level2name=N'code_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code System Notes' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_ahc', @level2type=N'COLUMN',@level2name=N'code_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Codes - Active / Hold / Closed' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_ahc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_country', @level2type=N'COLUMN',@level2name=N'code_sys_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Sequence' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_country', @level2type=N'COLUMN',@level2name=N'code_seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_country', @level2type=N'COLUMN',@level2name=N'code_val'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Description' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_country', @level2type=N'COLUMN',@level2name=N'code_txt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Additional Code' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_country', @level2type=N'COLUMN',@level2name=N'code_code'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Date' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_country', @level2type=N'COLUMN',@level2name=N'code_end_dt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Comment' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_country', @level2type=N'COLUMN',@level2name=N'code_end_reason'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_country', @level2type=N'COLUMN',@level2name=N'code_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_country', @level2type=N'COLUMN',@level2name=N'code_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_country', @level2type=N'COLUMN',@level2name=N'code_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_country', @level2type=N'COLUMN',@level2name=N'code_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code System Notes' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_country', @level2type=N'COLUMN',@level2name=N'code_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Codes - TOrder Payment Method' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_country'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_doc_scope', @level2type=N'COLUMN',@level2name=N'code_sys_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Sequence' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_doc_scope', @level2type=N'COLUMN',@level2name=N'code_seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_doc_scope', @level2type=N'COLUMN',@level2name=N'code_val'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Description' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_doc_scope', @level2type=N'COLUMN',@level2name=N'code_txt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Additional Code' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_doc_scope', @level2type=N'COLUMN',@level2name=N'code_code'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Date' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_doc_scope', @level2type=N'COLUMN',@level2name=N'code_end_dt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Comment' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_doc_scope', @level2type=N'COLUMN',@level2name=N'code_end_reason'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_doc_scope', @level2type=N'COLUMN',@level2name=N'code_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_doc_scope', @level2type=N'COLUMN',@level2name=N'code_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_doc_scope', @level2type=N'COLUMN',@level2name=N'code_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_doc_scope', @level2type=N'COLUMN',@level2name=N'code_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code System Notes' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_doc_scope', @level2type=N'COLUMN',@level2name=N'code_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Codes - Document Scope' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_doc_scope'
GO
:if:separate_code_type_tables:
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Name' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=2 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=5565 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Description' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_h_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_h_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=3 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_h_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_h_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_h_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_h_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_h_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_h_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_h_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=4 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_h_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_h_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_h_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Entry User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_h_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_h_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_h_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_h_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=5 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_h_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_h_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_h_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_h_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_h_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_h_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_h_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=6 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_h_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_h_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_h_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_h_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_h_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=7 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header System Notes' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys', @level2type=N'COLUMN',@level2name=N'code_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Codes Header (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_sys'
GO
:endif:
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_note_scope', @level2type=N'COLUMN',@level2name=N'code_sys_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Sequence' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_note_scope', @level2type=N'COLUMN',@level2name=N'code_seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_note_scope', @level2type=N'COLUMN',@level2name=N'code_val'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Description' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_note_scope', @level2type=N'COLUMN',@level2name=N'code_txt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Additional Code' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_note_scope', @level2type=N'COLUMN',@level2name=N'code_code'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Date' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_note_scope', @level2type=N'COLUMN',@level2name=N'code_end_dt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Comment' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_note_scope', @level2type=N'COLUMN',@level2name=N'code_end_reason'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_note_scope', @level2type=N'COLUMN',@level2name=N'code_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_note_scope', @level2type=N'COLUMN',@level2name=N'code_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_note_scope', @level2type=N'COLUMN',@level2name=N'code_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_note_scope', @level2type=N'COLUMN',@level2name=N'code_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code System Notes' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_note_scope', @level2type=N'COLUMN',@level2name=N'code_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Codes - Note Scope' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_note_scope'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_note_type', @level2type=N'COLUMN',@level2name=N'code_sys_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Sequence' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_note_type', @level2type=N'COLUMN',@level2name=N'code_seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_note_type', @level2type=N'COLUMN',@level2name=N'code_val'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Description' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_note_type', @level2type=N'COLUMN',@level2name=N'code_txt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Additional Code' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_note_type', @level2type=N'COLUMN',@level2name=N'code_code'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Date' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_note_type', @level2type=N'COLUMN',@level2name=N'code_end_dt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Comment' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_note_type', @level2type=N'COLUMN',@level2name=N'code_end_reason'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_note_type', @level2type=N'COLUMN',@level2name=N'code_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_note_type', @level2type=N'COLUMN',@level2name=N'code_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_note_type', @level2type=N'COLUMN',@level2name=N'code_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_note_type', @level2type=N'COLUMN',@level2name=N'code_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code System Notes' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_note_type', @level2type=N'COLUMN',@level2name=N'code_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Codes - Note Type' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_note_type'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_param_type', @level2type=N'COLUMN',@level2name=N'code_sys_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Sequence' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_param_type', @level2type=N'COLUMN',@level2name=N'code_seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_param_type', @level2type=N'COLUMN',@level2name=N'code_val'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Description' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_param_type', @level2type=N'COLUMN',@level2name=N'code_txt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Additional Code' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_param_type', @level2type=N'COLUMN',@level2name=N'code_code'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Date' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_param_type', @level2type=N'COLUMN',@level2name=N'code_end_dt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Comment' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_param_type', @level2type=N'COLUMN',@level2name=N'code_end_reason'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_param_type', @level2type=N'COLUMN',@level2name=N'code_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_param_type', @level2type=N'COLUMN',@level2name=N'code_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_param_type', @level2type=N'COLUMN',@level2name=N'code_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_param_type', @level2type=N'COLUMN',@level2name=N'code_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code System Notes' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_param_type', @level2type=N'COLUMN',@level2name=N'code_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Codes - Process Parameter Type' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_param_type'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_job_action', @level2type=N'COLUMN',@level2name=N'code_sys_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Sequence' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_job_action', @level2type=N'COLUMN',@level2name=N'code_seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_job_action', @level2type=N'COLUMN',@level2name=N'code_val'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Description' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_job_action', @level2type=N'COLUMN',@level2name=N'code_txt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Additional Code' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_job_action', @level2type=N'COLUMN',@level2name=N'code_code'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Date' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_job_action', @level2type=N'COLUMN',@level2name=N'code_end_dt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Comment' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_job_action', @level2type=N'COLUMN',@level2name=N'code_end_reason'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_job_action', @level2type=N'COLUMN',@level2name=N'code_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_job_action', @level2type=N'COLUMN',@level2name=N'code_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_job_action', @level2type=N'COLUMN',@level2name=N'code_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_job_action', @level2type=N'COLUMN',@level2name=N'code_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code System Notes' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_job_action', @level2type=N'COLUMN',@level2name=N'code_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Codes - Request Type (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_job_action'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_job_source', @level2type=N'COLUMN',@level2name=N'code_sys_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Sequence' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_job_source', @level2type=N'COLUMN',@level2name=N'code_seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_job_source', @level2type=N'COLUMN',@level2name=N'code_val'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Description' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_job_source', @level2type=N'COLUMN',@level2name=N'code_txt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Additional Code' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_job_source', @level2type=N'COLUMN',@level2name=N'code_code'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Date' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_job_source', @level2type=N'COLUMN',@level2name=N'code_end_dt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Comment' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_job_source', @level2type=N'COLUMN',@level2name=N'code_end_reason'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_job_source', @level2type=N'COLUMN',@level2name=N'code_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_job_source', @level2type=N'COLUMN',@level2name=N'code_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_job_source', @level2type=N'COLUMN',@level2name=N'code_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_job_source', @level2type=N'COLUMN',@level2name=N'code_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code System Notes' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_job_source', @level2type=N'COLUMN',@level2name=N'code_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Codes - Request Source (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_job_source'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_txt_type', @level2type=N'COLUMN',@level2name=N'code_sys_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Sequence' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_txt_type', @level2type=N'COLUMN',@level2name=N'code_seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_txt_type', @level2type=N'COLUMN',@level2name=N'code_val'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Description' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_txt_type', @level2type=N'COLUMN',@level2name=N'code_txt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Additional Code' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_txt_type', @level2type=N'COLUMN',@level2name=N'code_code'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Date' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_txt_type', @level2type=N'COLUMN',@level2name=N'code_end_dt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Comment' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_txt_type', @level2type=N'COLUMN',@level2name=N'code_end_reason'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_txt_type', @level2type=N'COLUMN',@level2name=N'code_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_txt_type', @level2type=N'COLUMN',@level2name=N'code_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_txt_type', @level2type=N'COLUMN',@level2name=N'code_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_txt_type', @level2type=N'COLUMN',@level2name=N'code_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code System Notes' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_txt_type', @level2type=N'COLUMN',@level2name=N'code_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Codes - Text Type (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_txt_type'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_version_sts', @level2type=N'COLUMN',@level2name=N'code_sys_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Sequence' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_version_sts', @level2type=N'COLUMN',@level2name=N'code_seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_version_sts', @level2type=N'COLUMN',@level2name=N'code_val'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Description' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_version_sts', @level2type=N'COLUMN',@level2name=N'code_txt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Additional Code' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_version_sts', @level2type=N'COLUMN',@level2name=N'code_code'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Date' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_version_sts', @level2type=N'COLUMN',@level2name=N'code_end_dt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Comment' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_version_sts', @level2type=N'COLUMN',@level2name=N'code_end_reason'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_version_sts', @level2type=N'COLUMN',@level2name=N'code_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_version_sts', @level2type=N'COLUMN',@level2name=N'code_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_version_sts', @level2type=N'COLUMN',@level2name=N'code_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_version_sts', @level2type=N'COLUMN',@level2name=N'code_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code System Notes' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_version_sts', @level2type=N'COLUMN',@level2name=N'code_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Codes - Version Status' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code_version_sts'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_country_state', @level2type=N'COLUMN',@level2name=N'code2_sys_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Sequence' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_country_state', @level2type=N'COLUMN',@level2name=N'code_seq'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_country_state', @level2type=N'COLUMN',@level2name=N'code_val1'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Description' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_country_state', @level2type=N'COLUMN',@level2name=N'code_txt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Additional Code' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_country_state', @level2type=N'COLUMN',@level2name=N'code_code'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Date' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_country_state', @level2type=N'COLUMN',@level2name=N'code_end_dt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Termination Comment' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_country_state', @level2type=N'COLUMN',@level2name=N'code_end_reason'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_country_state', @level2type=N'COLUMN',@level2name=N'code_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Entry User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_country_state', @level2type=N'COLUMN',@level2name=N'code_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_country_state', @level2type=N'COLUMN',@level2name=N'code_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Value Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_country_state', @level2type=N'COLUMN',@level2name=N'code_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code System Notes' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_country_state', @level2type=N'COLUMN',@level2name=N'code_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Codes 2 - Country / State' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_country_state'
GO
:if:separate_code_type_tables:
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Name' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=2 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=5565 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Description' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Code Description' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_code_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Attrib Description' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_attrib_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_h_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_h_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=3 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_h_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_h_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_h_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_h_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_h_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_h_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_h_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=4 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_h_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_h_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_h_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Entry User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_h_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_h_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_h_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_h_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=5 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_h_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_h_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_h_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_h_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_h_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_h_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_h_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=6 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_h_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_h_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_h_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_h_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_h_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=7 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code Header System Notes' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys', @level2type=N'COLUMN',@level2name=N'code_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Codes 2 Header (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'code2_sys'
GO
:endif:
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Version ID (internal)' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'version__tbl', @level2type=N'COLUMN',@level2name=N'version_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Version Component Name' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'version__tbl', @level2type=N'COLUMN',@level2name=N'version_component'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Version Number - Major' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'version__tbl', @level2type=N'COLUMN',@level2name=N'version_no_major'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Version Number - Minor' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'version__tbl', @level2type=N'COLUMN',@level2name=N'version_no_minor'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Version Number - Build' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'version__tbl', @level2type=N'COLUMN',@level2name=N'version_no_build'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Version Number - Revision' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'version__tbl', @level2type=N'COLUMN',@level2name=N'version_no_rev'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Version status - code_version_sts' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'version__tbl', @level2type=N'COLUMN',@level2name=N'version_sts'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Version Note' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'version__tbl', @level2type=N'COLUMN',@level2name=N'version_note'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Version entry date' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'version__tbl', @level2type=N'COLUMN',@level2name=N'version_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Version entry user' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'version__tbl', @level2type=N'COLUMN',@level2name=N'version_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Version last modification date' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'version__tbl', @level2type=N'COLUMN',@level2name=N'version_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Version last modification user' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'version__tbl', @level2type=N'COLUMN',@level2name=N'version_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Version System Notes' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'version__tbl', @level2type=N'COLUMN',@level2name=N'version_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Versions (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'version__tbl'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_process'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_process'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_process'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_process'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_process'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'param_sys Process Name' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_process'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=0x00 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_process'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_attrib'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_attrib'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_attrib'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=2460 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_attrib'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_attrib'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'param_sys Attribute (Parameter) Name' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_attrib'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=0x00 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_attrib'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_val'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_val'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_val'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=3975 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_val'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_val'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'param_sys Attribute (Parameter) value' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_val'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=0x00 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_val'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=0x00 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=0x00 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=0x00 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=0x00 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=0x00 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys', @level2type=N'COLUMN',@level2name=N'param_sys_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Process Parameters - System (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'param_sys'
GO



