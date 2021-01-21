ALTER FUNCTION [{schema}].[get_cust_user_name]
(
    @in_sys_user_id BIGINT
)    
RETURNS NVARCHAR(MAX)  
AS 
BEGIN
DECLARE @rslt NVARCHAR(MAX) = NULL

  SELECT @rslt = sys_user_lname+', '+sys_user_fname
    FROM {schema}.cust_user
   WHERE sys_user_id = @in_sys_user_id;

  RETURN (@rslt)

END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [{schema}].[cust_menu_role](
    [menu_id] [bigint] NOT NULL,
    [cust_menu_role_snotes] [nvarchar](255) NULL,
    [cust_menu_role_id] [bigint] IDENTITY(1,1) NOT NULL,
    [cust_role_name] [nvarchar](16) NOT NULL,
 CONSTRAINT [pk_cust_menu_role] PRIMARY KEY CLUSTERED 
(
    [cust_role_name] ASC,
    [menu_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_cust_menu_role] UNIQUE NONCLUSTERED 
(
    [cust_menu_role_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [{schema}].[cust_role](
    [cust_role_id] [bigint] IDENTITY(1,1) NOT NULL,
    [cust_role_seq] [smallint] NULL,
    [cust_role_sts] [nvarchar](32) NOT NULL,
    [cust_role_name] [nvarchar](16) NOT NULL,
    [cust_role_desc] [nvarchar](255) NOT NULL,
    [cust_role_code] [nvarchar](50) NULL,
    [cust_role_attrib] [nvarchar](50) NULL,
    [cust_role_snotes] [nvarchar](255) NULL,
 CONSTRAINT [pk_cust_role] PRIMARY KEY CLUSTERED 
(
    [cust_role_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_cust_role_cust_role_desc] UNIQUE NONCLUSTERED 
(
    [cust_role_desc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_cust_role_cust_role_id] UNIQUE NONCLUSTERED 
(
    [cust_role_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [{schema}].[v_cust_menu_role_selection]
AS
SELECT {schema}.cust_menu_role.cust_menu_role_id, 
       ISNULL({schema}.single.dual_nvarchar50, '') AS new_cust_role_name, 
         single.dual_bigint AS new_menu_id,
         CASE WHEN cust_menu_role.cust_menu_role_id IS NULL 
              THEN 0 
             ELSE 1 END AS cust_menu_role_selection, 
         M.cust_role_id, 
         M.cust_role_seq, 
         M.cust_role_sts, 
         M.cust_role_name, 
         M.cust_role_desc, 
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
  FROM (SELECT {schema}.cust_role.cust_role_id,
               {schema}.cust_role.cust_role_seq, 
               {schema}.cust_role.cust_role_sts, 
               {schema}.cust_role.cust_role_name, 
               {schema}.cust_role.cust_role_desc, 
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
          FROM {schema}.cust_role 
          LEFT OUTER JOIN {schema}.menu__tbl ON {schema}.menu__tbl.menu_group = 'C') AS M 
 INNER JOIN {schema}.single ON 1 = 1 
  LEFT OUTER JOIN {schema}.cust_menu_role ON {schema}.cust_menu_role.cust_role_name = M.cust_role_name AND {schema}.cust_menu_role.menu_id = M.menu_id;




GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [{schema}].[cust_user_role](
    [sys_user_id] [bigint] NOT NULL,
    [cust_user_role_snotes] [nvarchar](255) NULL,
    [cust_user_role_id] [bigint] IDENTITY(1,1) NOT NULL,
    [cust_role_name] [nvarchar](16) NOT NULL,
 CONSTRAINT [pk_cust_user_role] PRIMARY KEY CLUSTERED 
(
    [sys_user_id] ASC,
    [cust_role_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_cust_user_role] UNIQUE NONCLUSTERED 
(
    [cust_user_role_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [{schema}].[v_cust_user_nostar] as
select *
  from {schema}.cust_user_role
 where cust_role_name <> 'C*';

GO



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ARITHABORT ON
GO
CREATE TABLE [{schema}].[cust_user](
    [sys_user_id] [bigint] IDENTITY(1,1) NOT NULL,
    [cust_id] [bigint] NOT NULL,
    [sys_user_sts] [nvarchar](32) NOT NULL,
    [sys_user_stsdt] [date] NOT NULL,
    [sys_user_fname] [nvarchar](35) NOT NULL,
    [sys_user_mname] [nvarchar](35) NULL,
    [sys_user_lname] [nvarchar](35) NOT NULL,
    [sys_user_jobtitle] [nvarchar](35) NULL,
    [sys_user_bphone] [nvarchar](30) NULL,
    [sys_user_cphone] [nvarchar](30) NULL,
    [sys_user_email] [nvarchar](255) NOT NULL,
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
    [sys_user_unq_email]  AS (case when [sys_user_sts]='ACTIVE' then case when isnull([sys_user_email],'')='' then 'E'+CONVERT([varchar](50),[sys_user_id],(0)) else 'S'+[sys_user_email] end else 'E'+CONVERT([varchar](50),[sys_user_id],(0)) end) PERSISTED,
 CONSTRAINT [pk_cust_user] PRIMARY KEY CLUSTERED 
(
    [sys_user_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [unq_cust_user_sys_user_email] UNIQUE NONCLUSTERED 
(
    [sys_user_unq_email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO



CREATE NONCLUSTERED INDEX [IX_cust_user_cust_id] ON [{schema}].[cust_user]
(
    [cust_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


ALTER TABLE [{schema}].[cust_user] ADD  CONSTRAINT [df_cust_user_sys_user_sts]  DEFAULT (N'ACTIVE') FOR [sys_user_sts]
GO
ALTER TABLE [{schema}].[cust_user] ADD  CONSTRAINT [df_cust_user_sys_user_sts_Dt]  DEFAULT ([{schema}].[my_today]()) FOR [sys_user_stsdt]
GO
ALTER TABLE [{schema}].[cust_user] ADD  CONSTRAINT [df_cust_user_sys_user_etstmp]  DEFAULT ([{schema}].[my_now]()) FOR [sys_user_etstmp]
GO
ALTER TABLE [{schema}].[cust_user] ADD  CONSTRAINT [df_cust_user_sys_user_euser]  DEFAULT ([{schema}].[my_db_user]()) FOR [sys_user_euser]
GO
ALTER TABLE [{schema}].[cust_user] ADD  CONSTRAINT [df_cust_user_sys_user_mtstmp]  DEFAULT ([{schema}].[my_now]()) FOR [sys_user_mtstmp]
GO
ALTER TABLE [{schema}].[cust_user] ADD  CONSTRAINT [df_cust_user_sys_user_muser]  DEFAULT ([{schema}].[my_db_user]()) FOR [sys_user_muser]
GO
ALTER TABLE [{schema}].[cust_user] ADD  CONSTRAINT [df_cust_user_sys_user_hash]  DEFAULT ((0)) FOR [sys_user_hash]
GO
ALTER TABLE [{schema}].[cust_role] ADD  CONSTRAINT [df_cust_role_cust_role_sts]  DEFAULT ('ACTIVE') FOR [cust_role_sts]
GO


ALTER TABLE [{schema}].[cust_user]  WITH CHECK ADD  CONSTRAINT [fk_cust_user_code_ahc] FOREIGN KEY([sys_user_sts])
REFERENCES [{schema}].[code_ahc] ([code_val])
GO
ALTER TABLE [{schema}].[cust_user] CHECK CONSTRAINT [fk_cust_user_code_ahc]
GO
ALTER TABLE [{schema}].[cust_user_role]  WITH CHECK ADD  CONSTRAINT [fk_cust_user_role_cust_user] FOREIGN KEY([sys_user_id])
REFERENCES [{schema}].[cust_user] ([sys_user_id])
ON DELETE CASCADE
GO
ALTER TABLE [{schema}].[cust_user_role] CHECK CONSTRAINT [fk_cust_user_role_cust_user]
GO
ALTER TABLE [{schema}].[cust_user_role]  WITH CHECK ADD  CONSTRAINT [fk_cust_user_role_cust_role_cust_role_name] FOREIGN KEY([cust_role_name])
REFERENCES [{schema}].[cust_role] ([cust_role_name])
ON DELETE CASCADE
GO
ALTER TABLE [{schema}].[cust_user_role] CHECK CONSTRAINT [fk_cust_user_role_cust_role_cust_role_name]
GO
ALTER TABLE [{schema}].[cust_role]  WITH CHECK ADD  CONSTRAINT [fk_cust_role_code_ahc] FOREIGN KEY([cust_role_sts])
REFERENCES [{schema}].[code_ahc] ([code_val])
GO
ALTER TABLE [{schema}].[cust_role] CHECK CONSTRAINT [fk_cust_role_code_ahc]
GO
ALTER TABLE [{schema}].[cust_menu_role]  WITH CHECK ADD  CONSTRAINT [fk_cust_menu_role_cust_role_cust_role_name] FOREIGN KEY([cust_role_name])
REFERENCES [{schema}].[cust_role] ([cust_role_name])
ON DELETE CASCADE
GO
ALTER TABLE [{schema}].[cust_menu_role] CHECK CONSTRAINT [fk_cust_menu_role_cust_role_cust_role_name]
GO
ALTER TABLE [{schema}].[cust_menu_role]  WITH CHECK ADD  CONSTRAINT [fk_cust_menu_role_menu__tbl] FOREIGN KEY([menu_id])
REFERENCES [{schema}].[menu__tbl] ([menu_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [{schema}].[cust_menu_role] CHECK CONSTRAINT [fk_cust_menu_role_menu__tbl]
GO


ALTER TABLE [{schema}].[cust_user]  WITH CHECK ADD  CONSTRAINT [ck_cust_user_sys_user_email] CHECK  ((isnull([sys_user_email],'')<>''))
GO
ALTER TABLE [{schema}].[cust_user] CHECK CONSTRAINT [ck_cust_user_sys_user_email]
GO



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE trigger [{schema}].[cust_user_iud] on [{schema}].[cust_user]
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
  DECLARE CUR_cust_user_iud CURSOR LOCAL FOR
     SELECT  del.sys_user_id, i.sys_user_id,
             del.cust_id, i.cust_id,
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
  DECLARE @D_cust_id bigint
  DECLARE @I_cust_id bigint
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
  DECLARE @WK_cust_id BIGINT
  DECLARE @WK_audit_subject NVARCHAR(MAX)
  DECLARE @code_val NVARCHAR(MAX)
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
  
  SET @CURDTTM = {schema}.my_now_exec()
  SET @CURDTTM_CHAR = CONVERT(NVARCHAR, @CURDTTM, 120)+'.0000000'
  SET @MYUSER = {schema}.my_db_user() 

  IF @TP = 'U' AND UPDATE(sys_user_id)
  BEGIN
    EXEC [{schema}].[zz-filedebug] 'TRIGGER','cust_user_iud','ERR', 'Cannot update ID'
    raiserror('Cannot update identity',16,1)
    ROLLBACK TRANSACTION
    return
  END

  IF @TP = 'U' AND UPDATE(cust_id)
  BEGIN
    EXEC [{schema}].[zz-filedebug] 'TRIGGER','cust_user_iud','ERR', 'Cannot update Customer ID'
    raiserror('Cannot update foreign key cust_id',16,1)
    ROLLBACK TRANSACTION
    return
  END

  
  OPEN CUR_cust_user_iud
  FETCH NEXT FROM CUR_cust_user_iud
        INTO @D_sys_user_id, @I_sys_user_id,
             @D_cust_id, @I_cust_id,
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

    SET @M = NULL
    SET @hash = NULL

    SET @NEWPW = NUll;
    SET @UPDATE_PW = 'note__tbl'

    SET @WK_cust_id = ISNULL(@I_cust_id,@D_cust_id)

    IF (@TP='I' or @TP='U')
    BEGIN
      if ({schema}.nequal_chr(@I_sys_user_pw1, @I_sys_user_pw2) > 0)
        SET @M = 'Application Error - New Password and Repeat Password are different'
      else if ((@TP='I' or isnull(@I_sys_user_pw1,'')>'') and len(ltrim(rtrim(isnull(@I_sys_user_pw1,'')))) < 6)
        SET @M = 'Application Error - Password length - at least 6 characters required'

      IF (@M is not null)
      BEGIN
        CLOSE CUR_cust_user_iud
        DEALLOCATE CUR_cust_user_iud
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


    IF (@TP='I' 
        OR 
        @TP='U' AND {schema}.nequal_num(@D_cust_id, @I_cust_id) > 0)
    BEGIN
        exec [{schema}].get_cust_id 'cust', @I_cust_id, @rslt = @C output;
        IF isnull(@C,0) <= 0
        BEGIN
            CLOSE CUR_cust_user_iud
            DEALLOCATE CUR_cust_user_iud
            SET @M = 'Table cust does not contain record ' + CONVERT(NVARCHAR(MAX),@I_cust_id)
            raiserror(@M ,16,1)
            ROLLBACK TRANSACTION
            return
        END 
    END   

    IF (@TP='I')
    BEGIN

      set @hash = {schema}.my_hash('C', @I_sys_user_id, @NEWPW);

      if (@hash is null)
      BEGIN
        CLOSE CUR_cust_user_iud
        DEALLOCATE CUR_cust_user_iud
        SET @M = 'Application Error - Missing or Incorrect Password'
        raiserror(@M,16,1)
        ROLLBACK TRANSACTION
        return
      END

      UPDATE {schema}.cust_user
         SET sys_user_stsdt = @CURDTTM,
             sys_user_etstmp = @CURDTTM,
             sys_user_euser = @MYUSER,
             sys_user_mtstmp = @CURDTTM,
             sys_user_muser = @MYUSER,
             sys_user_hash = @hash,
             sys_user_pw1 = NULL,
             sys_user_pw2 = NULL
       WHERE cust_user.sys_user_id = @I_sys_user_id;

      INSERT INTO {schema}.cust_user_role (sys_user_id, cust_role_name)
                 VALUES(@I_sys_user_id, 'C*');

    END  

    SET @WK_audit_subject = ISNULL(@I_sys_user_lname,'')+', '+ISNULL(@I_sys_user_fname,'') 

    /******************************************/
    /****** SPECIAL FRONT ACTION - END   ******/
    /******************************************/

    SET @MY_audit_seq = 0
    IF (@TP='I' OR @TP='D')
    BEGIN  
      SET @WK_sys_user_id = ISNULL(@D_sys_user_id,@I_sys_user_id)
      EXEC    @MY_audit_seq = {schema}.log_audit @TP, 'cust_user', @WK_sys_user_id, @MYUSER, @CURDTTM,default,default,@WK_audit_subject,@WK_cust_id
    END
 
    IF @TP='U' OR @TP='D'
    BEGIN

      IF (@TP = 'D' AND @D_cust_id IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_cust_id, @I_cust_id) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit 'U', 'cust_user', @I_sys_user_id, @MYUSER, @CURDTTM,default,default,@WK_audit_subject,@WK_cust_id
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('cust_id'), @D_cust_id)
      END

      IF (@TP = 'D' AND @D_sys_user_sts IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_sys_user_sts, @I_sys_user_sts) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit 'U', 'cust_user', @I_sys_user_id, @MYUSER, @CURDTTM,default,default,@WK_audit_subject,@WK_cust_id
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('sys_user_sts'), @D_sys_user_sts)
      END

      IF (@TP = 'D' AND @D_sys_user_fname IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_sys_user_fname, @I_sys_user_fname) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit 'U', 'cust_user', @I_sys_user_id, @MYUSER, @CURDTTM,default,default,@WK_audit_subject,@WK_cust_id
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('sys_user_fname'), @D_sys_user_fname)
      END

      IF (@TP = 'D' AND @D_sys_user_mname IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_sys_user_mname, @I_sys_user_mname) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit 'U', 'cust_user', @I_sys_user_id, @MYUSER, @CURDTTM,default,default,@WK_audit_subject,@WK_cust_id
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('sys_user_mname'), @D_sys_user_mname)
      END

      IF (@TP = 'D' AND @D_sys_user_lname IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_sys_user_lname, @I_sys_user_lname) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit 'U', 'cust_user', @I_sys_user_id, @MYUSER, @CURDTTM,default,default,@WK_audit_subject,@WK_cust_id
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('sys_user_lname'), @D_sys_user_lname)
      END

      IF (@TP = 'D' AND @D_sys_user_jobtitle IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_sys_user_jobtitle, @I_sys_user_jobtitle) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit 'U', 'cust_user', @I_sys_user_id, @MYUSER, @CURDTTM,default,default,@WK_audit_subject,@WK_cust_id
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('sys_user_jobtitle'), @D_sys_user_jobtitle)
      END

      IF (@TP = 'D' AND @D_sys_user_bphone IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_sys_user_bphone, @I_sys_user_bphone) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit 'U', 'cust_user', @I_sys_user_id, @MYUSER, @CURDTTM,default,default,@WK_audit_subject,@WK_cust_id
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('sys_user_bphone'), @D_sys_user_bphone)
      END

      IF (@TP = 'D' AND @D_sys_user_cphone IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_sys_user_cphone, @I_sys_user_cphone) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit 'U', 'cust_user', @I_sys_user_id, @MYUSER, @CURDTTM,default,default,@WK_audit_subject,@WK_cust_id
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('sys_user_cphone'), @D_sys_user_cphone)
      END

      IF (@TP = 'D' AND @D_sys_user_email IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_sys_user_email, @I_sys_user_email) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit 'U', 'cust_user', @I_sys_user_id, @MYUSER, @CURDTTM,default,default,@WK_audit_subject,@WK_cust_id
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('sys_user_email'), @D_sys_user_email)
      END

      IF (@TP = 'D' AND @D_sys_user_lastlogin_tstmp IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_date(@D_sys_user_lastlogin_tstmp, @I_sys_user_lastlogin_tstmp) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit 'U', 'cust_user', @I_sys_user_id, @MYUSER, @CURDTTM,default,default,@WK_audit_subject,@WK_cust_id
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('sys_user_lastlogin_tstmp'), @D_sys_user_lastlogin_tstmp)
      END

      IF (@TP = 'U' AND isnull(@NEWPW,'') <> '')
      BEGIN
        set @hash = {schema}.my_hash('C', @I_sys_user_id, @NEWPW);

        if (@hash is null)
        BEGIN
            CLOSE CUR_cust_user_iud
            DEALLOCATE CUR_cust_user_iud
            SET @M = 'Application Error - Incorrect Password'
            raiserror(@M,16,1)
            ROLLBACK TRANSACTION
            return
        END

        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit 'U', 'cust_user', @I_sys_user_id, @MYUSER, @CURDTTM,default,default,@WK_audit_subject,@WK_cust_id
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('sys_user_PW'), '*')

        SET @UPDATE_PW = 'Y'
      END


    END  /* END OF "IF @TP='U' OR @TP='D'"  */


    /******************************************/
    /****** SPECIAL BACK ACTION - BEGIN  ******/
    /******************************************/

    IF (@TP='U' AND @MY_audit_seq <> 0)
    BEGIN
      UPDATE {schema}.cust_user
         SET sys_user_stsdt = CASE WHEN {schema}.nequal_chr(@D_sys_user_sts, @I_sys_user_sts) > 0 THEN @CURDTTM ELSE sys_user_stsdt END,
             sys_user_mtstmp = @CURDTTM,
             sys_user_muser = @MYUSER,
             sys_user_hash = case @UPDATE_PW when 'Y' then @hash else sys_user_hash end,
             sys_user_pw1 = NULL,
             sys_user_pw2 = NULL
       WHERE cust_user.sys_user_id = @I_sys_user_id;
    END  
    ELSE IF (@TP='U' AND (@I_sys_user_pw1 is not null or @I_sys_user_pw2 is not null))
    BEGIN
      UPDATE {schema}.cust_user
         SET sys_user_pw1 = NULL,
             sys_user_pw2 = NULL
       WHERE cust_user.sys_user_id = @I_sys_user_id;
    END  

    /*****************************************/
    /****** SPECIAL BACK ACTION - END   ******/
    /*****************************************/



            
    FETCH NEXT FROM CUR_cust_user_iud
        INTO @D_sys_user_id, @I_sys_user_id,
             @D_cust_id, @I_cust_id,
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
  CLOSE CUR_cust_user_iud
  DEALLOCATE CUR_cust_user_iud

  /*
  EXEC [{schema}].[zz-filedebug] 'TRIGGER','cust_user_iud','RETURN', ''
  */

  RETURN

END
GO
ALTER TABLE [{schema}].[cust_user] ENABLE TRIGGER [cust_user_iud]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE trigger [{schema}].[cust_user_role_iud] on [{schema}].[cust_user_role]
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
  DECLARE CUR_cust_user_role_iud CURSOR LOCAL FOR
     SELECT  del.cust_user_role_id, i.cust_user_role_id,
             del.sys_user_id, i.sys_user_id,
             del.cust_role_name, i.cust_role_name
       FROM deleted del FULL OUTER JOIN inserted i
                       ON i.cust_user_role_id = del.cust_user_role_id;
  DECLARE @D_cust_user_role_id bigint
  DECLARE @I_cust_user_role_id bigint
  DECLARE @D_sys_user_id bigint
  DECLARE @I_sys_user_id bigint
  DECLARE @D_cust_role_name nvarchar(max)
  DECLARE @I_cust_role_name nvarchar(max)

  DECLARE @MYERROR_NO INT = 0
  DECLARE @MYERROR_MSG NVARCHAR(MAX) = NULL
  DECLARE @WK_cust_user_role_id bigint
  DECLARE @WK_audit_subject NVARCHAR(MAX)

  DECLARE @xloc nvarchar(MAX)
  DECLARE @xtxt nvarchar(MAX)

  DECLARE @DYNSQL NVARCHAR(MAX)
  DECLARE @C BIGINT
  DECLARE @code_val NVARCHAR(MAX)

  /*
  EXEC [{schema}].[zz-filedebug] 'TRIGGER','cust_user_role_iud','START', ''
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

  IF @TP = 'U' AND UPDATE(cust_user_role_id)
  BEGIN
    EXEC [{schema}].[zz-filedebug] 'TRIGGER','cust_user_role_iud','ERR', 'Cannot update ID'
    raiserror('Cannot update identity',16,1)
    ROLLBACK TRANSACTION
    return
  END

  IF @TP = 'U' AND UPDATE(sys_user_id)
  BEGIN
    EXEC [{schema}].[zz-filedebug] 'TRIGGER','cust_user_role_iud','ERR', 'Cannot update sys_user_id'
    raiserror('Cannot update foreign key',16,1)
    ROLLBACK TRANSACTION
    return
  END

  
  OPEN CUR_cust_user_role_iud
  FETCH NEXT FROM CUR_cust_user_role_iud
        INTO @D_cust_user_role_id, @I_cust_user_role_id,
             @D_sys_user_id, @I_sys_user_id,
             @D_cust_role_name, @I_cust_role_name

  WHILE (@@Fetch_Status = 0)
  BEGIN
      
    SET @xloc = 'TP=' + ISNULL(@TP,'null')
    SET @xtxt = 'I_cust_user_role_id=' + LTRIM(ISNULL(STR(@I_cust_user_role_id),'null')) +
                ' D_cust_user_role_id=' + LTRIM(ISNULL(STR(@D_cust_user_role_id),'null')) 
    /*
    EXEC [{schema}].[zz-filedebug] 'TRIGGER','cust_user_role_iud',@xloc, @xtxt
    */

    /******************************************/
    /****** SPECIAL FRONT ACTION - BEGIN ******/
    /******************************************/
    
    SELECT @WK_audit_subject = isnull(sys_user_lname,'')+', '+isnull(sys_user_fname,'')
      FROM {schema}.cust_user
     WHERE sys_user_id = @I_sys_user_id; 


/*
  THIS CODE DOES NOT BELONG IN jsharmony trigger - IT IS REQUIRED FOR BETTER PROTECTION IN ATRAX
  BUT COULD BE SKIPPED

    IF @I_cust_role_name IS NOT NULL
       AND
       @I_sys_user_id IS NOT NULL
    BEGIN

      IF EXISTS (select 1
                   from CF
                  inner join {schema}.cust_user on cust_user.cust_id = CF.cust_id
                  where cust_user.sys_user_id = @I_sys_user_id
                    and CF.CF_TYPE = 'LVL2')
      BEGIN
        IF @I_cust_role_name not in ('C*','CUSER','CMGR','CADMIN')
        BEGIN
          EXEC [{schema}].[zz-filedebug] 'TRIGGER','cust_user_role_iud','ERR', 'Invalid Role'
          raiserror('Role not compatible with LVL2',16,1)
          ROLLBACK TRANSACTION
          return
        END
      END
      ELSE
      BEGIN
        IF @I_cust_role_name not in ('C*','CL1')
        BEGIN
          EXEC [{schema}].[zz-filedebug] 'TRIGGER','cust_user_role_iud','ERR', 'Invalid Role'
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

    SET @MY_audit_seq = 0
    IF (@TP='I' OR @TP='D')
    BEGIN  
      SET @WK_cust_user_role_id = ISNULL(@D_cust_user_role_id,@I_cust_user_role_id)
      EXEC    @MY_audit_seq = {schema}.log_audit @TP, 'cust_user_role', @WK_cust_user_role_id, @MYUSER, @CURDTTM,default,default,@WK_audit_subject
    END

    IF @TP='U' OR @TP='D'
    BEGIN

      IF (@TP = 'D' AND @D_sys_user_id IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_num(@D_sys_user_id, @I_sys_user_id) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit 'U', 'cust_user_role', @I_cust_user_role_id, @MYUSER, @CURDTTM,default,default,@WK_audit_subject
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('sys_user_id'), @D_sys_user_id)
      END

      IF (@TP = 'D' AND @D_cust_role_name IS NOT NULL OR
          @TP = 'U' AND {schema}.nequal_chr(@D_cust_role_name, @I_cust_role_name) > 0)
      BEGIN
        IF (@MY_audit_seq=0)
          EXEC    @MY_audit_seq = {schema}.log_audit 'U', 'cust_user_role', @I_cust_user_role_id, @MYUSER, @CURDTTM,default,default,@WK_audit_subject
        INSERT INTO {schema}.audit_detail VALUES (@MY_audit_seq, lower('cust_role_name'), @D_cust_role_name)
      END

    END  /* END OF "IF @TP='U' OR @TP='D'"  */

    /******************************************/
    /****** SPECIAL BACK ACTION - BEGIN  ******/
    /******************************************/

    /*****************************************/
    /****** SPECIAL BACK ACTION - END   ******/
    /*****************************************/
            
    FETCH NEXT FROM CUR_cust_user_role_iud
          INTO @D_cust_user_role_id, @I_cust_user_role_id,
               @D_sys_user_id,  @I_sys_user_id,
               @D_cust_role_name,  @I_cust_role_name
  END
  CLOSE CUR_cust_user_role_iud
  DEALLOCATE CUR_cust_user_role_iud
  /*
  EXEC [{schema}].[zz-filedebug] 'TRIGGER','cust_user_role_iud','RETURN', ''
  */
  RETURN

END
GO
ALTER TABLE [{schema}].[cust_user_role] ENABLE TRIGGER [cust_user_role_iud]
GO



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [{schema}].[v_cust_menu_role_selection_iud_INSTEADOF_UPDATE] on [{schema}].[v_cust_menu_role_selection]
instead of update
as
begin
  set nocount on
  declare @I int
  IF (UPDATE(cust_menu_role_selection))
  BEGIN
  set @I = 1

    delete from {schema}.cust_menu_role
     where cust_menu_role_id in (
       select i.cust_menu_role_id
         from inserted i
        inner join deleted del on del.menu_id=i.menu_id
        where {schema}.nequal_num(del.cust_menu_role_selection, i.cust_menu_role_selection) > 0
          and isnull(i.cust_menu_role_selection,0) = 0);

     
    insert into {schema}.cust_menu_role (cust_role_name, menu_id)
       select i.new_cust_role_name, i.menu_id
         from inserted i
        inner join deleted del on del.menu_id=i.menu_id
        where {schema}.nequal_num(del.cust_menu_role_selection, i.cust_menu_role_selection) > 0
          and isnull(i.cust_menu_role_selection,0) = 1
          and isnull(i.new_cust_role_name,'')<>'';
     
    insert into {schema}.cust_menu_role (cust_role_name, menu_id)
       select i.cust_role_name, i.new_menu_id
         from inserted i
        inner join deleted del on del.menu_id=i.menu_id
        where {schema}.nequal_num(del.cust_menu_role_selection, i.cust_menu_role_selection) > 0
          and isnull(i.cust_menu_role_selection,0) = 1
          and isnull(i.new_cust_role_name,'')='';
     
  END
end



GO



EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'IMD' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_id'
GO
EXEC sys.sp_addextendedproperty @name=N'NT', @value=N'note__tbl' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_id'
GO
EXEC sys.sp_addextendedproperty @name=N'TRIGGER', @value=N'Referential Integrity back to AC' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'cust_id'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_sts'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_sts'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_sts'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_sts'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_sts'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_sts'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel Status - ACTIVE, HOLD, CLOSED - code_ahc' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_sts'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_sts'
GO
EXEC sys.sp_addextendedproperty @name=N'NT', @value=N'note__tbl' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_sts'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_stsdt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_stsdt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_stsdt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_stsdt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_stsdt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel Status Last Change Date' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_stsdt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_stsdt'
GO
EXEC sys.sp_addextendedproperty @name=N'TRIGGER', @value=N'Date' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_stsdt'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_fname'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_fname'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_fname'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_fname'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_fname'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_fname'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel First Name' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_fname'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_fname'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel Middle Name' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_mname'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_lname'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_lname'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_lname'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_lname'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_lname'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_lname'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel Last Name' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_lname'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_lname'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel Job Title' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_jobtitle'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel Business Phone Number' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_bphone'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel Cell Phone Number' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_cphone'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_email'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_email'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_email'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_email'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_email'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_email'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel Email' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_email'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_email'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel Entry Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_etstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel Entry User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_euser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel Last Modification Timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_mtstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel Last Modification User' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_muser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel Hash' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_hash'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel last login IP' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_lastlogin_ip'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel last login timestamp' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_lastlogin_tstmp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel System Notes' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user', @level2type=N'COLUMN',@level2name=N'sys_user_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Customer Personnel (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user_role', @level2type=N'COLUMN',@level2name=N'sys_user_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel Role System Notes' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user_role', @level2type=N'COLUMN',@level2name=N'cust_user_role_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Personnel Role ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user_role', @level2type=N'COLUMN',@level2name=N'cust_user_role_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role Name' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user_role', @level2type=N'COLUMN',@level2name=N'cust_role_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Customer - Personnel Roles (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_user_role'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'SIMD' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_role', @level2type=N'COLUMN',@level2name=N'cust_role_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_role', @level2type=N'COLUMN',@level2name=N'cust_role_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_role', @level2type=N'COLUMN',@level2name=N'cust_role_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_role', @level2type=N'COLUMN',@level2name=N'cust_role_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_role', @level2type=N'COLUMN',@level2name=N'cust_role_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_role', @level2type=N'COLUMN',@level2name=N'cust_role_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Role ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_role', @level2type=N'COLUMN',@level2name=N'cust_role_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_role', @level2type=N'COLUMN',@level2name=N'cust_role_id'
GO
EXEC sys.sp_addextendedproperty @name=N'NT', @value=N'' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_role', @level2type=N'COLUMN',@level2name=N'cust_role_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Role Sequence' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_role', @level2type=N'COLUMN',@level2name=N'cust_role_seq'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_role', @level2type=N'COLUMN',@level2name=N'cust_role_sts'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_role', @level2type=N'COLUMN',@level2name=N'cust_role_sts'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_role', @level2type=N'COLUMN',@level2name=N'cust_role_sts'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_role', @level2type=N'COLUMN',@level2name=N'cust_role_sts'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_role', @level2type=N'COLUMN',@level2name=N'cust_role_sts'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_role', @level2type=N'COLUMN',@level2name=N'cust_role_sts'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Role Status Code(AHC) - ACTIVE, HOLD, CLOSED' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_role', @level2type=N'COLUMN',@level2name=N'cust_role_sts'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_role', @level2type=N'COLUMN',@level2name=N'cust_role_sts'
GO
EXEC sys.sp_addextendedproperty @name=N'NT', @value=N'note__tbl' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_role', @level2type=N'COLUMN',@level2name=N'cust_role_sts'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_role', @level2type=N'COLUMN',@level2name=N'cust_role_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_role', @level2type=N'COLUMN',@level2name=N'cust_role_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_role', @level2type=N'COLUMN',@level2name=N'cust_role_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_role', @level2type=N'COLUMN',@level2name=N'cust_role_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_role', @level2type=N'COLUMN',@level2name=N'cust_role_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_role', @level2type=N'COLUMN',@level2name=N'cust_role_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Role Name' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_role', @level2type=N'COLUMN',@level2name=N'cust_role_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_role', @level2type=N'COLUMN',@level2name=N'cust_role_name'
GO
EXEC sys.sp_addextendedproperty @name=N'AUDIT', @value=N'M' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_role', @level2type=N'COLUMN',@level2name=N'cust_role_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_role', @level2type=N'COLUMN',@level2name=N'cust_role_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_role', @level2type=N'COLUMN',@level2name=N'cust_role_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_role', @level2type=N'COLUMN',@level2name=N'cust_role_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=4920 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_role', @level2type=N'COLUMN',@level2name=N'cust_role_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_role', @level2type=N'COLUMN',@level2name=N'cust_role_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Role Description' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_role', @level2type=N'COLUMN',@level2name=N'cust_role_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_role', @level2type=N'COLUMN',@level2name=N'cust_role_desc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_AggregateType', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_role', @level2type=N'COLUMN',@level2name=N'cust_role_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnHidden', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_role', @level2type=N'COLUMN',@level2name=N'cust_role_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnOrder', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_role', @level2type=N'COLUMN',@level2name=N'cust_role_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_ColumnWidth', @value=-1 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_role', @level2type=N'COLUMN',@level2name=N'cust_role_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_CurrencyLCID', @value=0 , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_role', @level2type=N'COLUMN',@level2name=N'cust_role_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Client Role System Notes' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_role', @level2type=N'COLUMN',@level2name=N'cust_role_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_TextAlign', @value=NULL , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_role', @level2type=N'COLUMN',@level2name=N'cust_role_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Customer - Roles (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_role'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Menu Item ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_menu_role', @level2type=N'COLUMN',@level2name=N'menu_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role Menu Item System Notes' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_menu_role', @level2type=N'COLUMN',@level2name=N'cust_menu_role_snotes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role Menu Item ID' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_menu_role', @level2type=N'COLUMN',@level2name=N'cust_menu_role_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role Name' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_menu_role', @level2type=N'COLUMN',@level2name=N'cust_role_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Customer - Role Menu Items (CONTROL)' , @level0type=N'SCHEMA',@level0name=N'{schema}', @level1type=N'TABLE',@level1name=N'cust_menu_role'
GO

