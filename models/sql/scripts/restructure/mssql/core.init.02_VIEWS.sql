/****** Object:  View [{schema}].[v_doc]    Script Date: 10/24/2018 12:14:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [{schema}].[v_doc] AS
SELECT doc__tbl.doc_id
      ,doc__tbl.doc_scope
      ,doc__tbl.doc_scope_id
      ,doc__tbl.cust_id
      ,doc__tbl.item_id
      ,doc__tbl.doc_sts
      ,doc__tbl.doc_ctgr
      ,GDD.code_txt doc_ctgr_txt
      ,doc__tbl.doc_desc
      ,doc__tbl.doc_ext
      ,doc__tbl.doc_size
      ,doc__tbl.doc_filename
      ,doc__tbl.doc_etstmp
      ,doc__tbl.doc_euser
      ,{schema}.my_db_user_fmt(doc_euser) doc_euser_fmt
      ,doc__tbl.doc_mtstmp
      ,doc__tbl.doc_muser
      ,{schema}.my_db_user_fmt(doc_muser) doc_muser_fmt
      ,doc__tbl.doc_uptstmp
      ,doc__tbl.doc_upuser
      ,{schema}.my_db_user_fmt(doc_upuser) doc_upuser_fmt
      ,doc__tbl.doc_snotes
      ,null title_head
      ,null title_detail
  FROM {schema}.doc__tbl
  LEFT OUTER JOIN  {schema}.code2_doc_scope_doc_ctgr GDD ON GDD.code_val1 = doc__tbl.doc_scope
                                             AND GDD.code_val2 = doc__tbl.doc_ctgr   

GO


CREATE VIEW [{schema}].[v_doc_ext] AS
SELECT doc__tbl.doc_id
      ,doc__tbl.doc_scope
      ,doc__tbl.doc_scope_id
      ,doc__tbl.cust_id
      ,doc__tbl.item_id
      ,doc__tbl.doc_sts
      ,doc__tbl.doc_ctgr
      ,doc__tbl.doc_desc
      ,doc__tbl.doc_ext
      ,doc__tbl.doc_size
      ,doc__tbl.doc_filename
      ,doc__tbl.doc_etstmp
      ,doc__tbl.doc_euser
      ,{schema}.my_db_user_fmt(doc_euser) doc_euser_fmt
      ,doc__tbl.doc_mtstmp
      ,doc__tbl.doc_muser
      ,{schema}.my_db_user_fmt(doc_muser) doc_muser_fmt
      ,doc__tbl.doc_uptstmp
      ,doc__tbl.doc_upuser
      ,{schema}.my_db_user_fmt(doc_upuser) doc_upuser_fmt
      ,doc__tbl.doc_snotes
      ,null title_head
      ,null title_detail
      ,{schema}.get_cust_name(doc__tbl.cust_id) cust_name
      ,{schema}.get_cust_name_ext(doc__tbl.cust_id) cust_name_ext
      ,{schema}.get_item_name(doc__tbl.item_id) item_name
  FROM {schema}.doc__tbl

GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Script for SelectTopNRows command from SSMS  ******/
create view [{schema}].[v_doc_filename] as
SELECT doc_id
      ,doc_scope
      ,doc_scope_id
      ,cust_id
      ,item_id
      ,doc_sts
      ,doc_ctgr
      ,doc_desc
      ,doc_ext
      ,doc_size
      ,doc_filename
      ,doc_etstmp
      ,doc_euser
      ,doc_mtstmp
      ,doc_muser
      ,doc_uptstmp
      ,doc_upuser
      ,doc_sync_tstmp
      ,doc_snotes
      ,doc_sync_id
  FROM {schema}.doc__tbl
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/****** Object:  View [{schema}].[v_note]    Script Date: 10/24/2018 12:27:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [{schema}].[v_note] as
SELECT note__tbl.note_id
      ,note__tbl.note_scope
      ,note__tbl.note_scope_id
      ,note__tbl.note_sts
      ,note__tbl.cust_id
      ,note__tbl.item_id
      ,note__tbl.note_type
      ,note__tbl.note_body
      ,{schema}.my_to_date(note__tbl.note_etstmp) note_dt
      ,note__tbl.note_etstmp
      ,{schema}.my_mmddyyhhmi(note__tbl.note_etstmp) note_etstmp_fmt
      ,note__tbl.note_euser
      ,{schema}.my_db_user_fmt(note__tbl.note_euser) note_euser_fmt
      ,note__tbl.note_mtstmp
      ,{schema}.my_mmddyyhhmi(note__tbl.note_mtstmp) note_mtstmp_fmt
      ,note__tbl.note_muser
      ,{schema}.my_db_user_fmt(note__tbl.note_muser) note_muser_fmt
      ,note__tbl.note_snotes
      ,null title_head
      ,null title_detail
      ,{schema}.get_cust_name(note__tbl.cust_id) cust_name
      ,{schema}.get_cust_name_ext(note__tbl.cust_id) cust_name_ext
      ,{schema}.get_item_name(note__tbl.item_id) item_name
  FROM {schema}.note__tbl

GO


CREATE VIEW [{schema}].[v_note_ext] AS
SELECT note__tbl.note_id
      ,note__tbl.note_scope
      ,note__tbl.note_scope_id
        ,note__tbl.note_sts
      ,note__tbl.cust_id
      ,note__tbl.item_id
      ,note__tbl.note_type
      ,note__tbl.note_body
      ,note__tbl.note_etstmp
      ,note__tbl.note_euser
      ,{schema}.my_db_user_fmt(note__tbl.note_euser) note_euser_fmt
      ,note__tbl.note_mtstmp
      ,note__tbl.note_muser
      ,{schema}.my_db_user_fmt(note__tbl.note_muser) note_muser_fmt
      ,note__tbl.note_snotes
      ,null title_head
      ,null title_detail
      ,{schema}.get_cust_name(note__tbl.cust_id) cust_name
      ,{schema}.get_cust_name_ext(note__tbl.cust_id) cust_name_ext
      ,{schema}.get_item_name(note__tbl.item_id) item_name
  FROM {schema}.note__tbl

GO
