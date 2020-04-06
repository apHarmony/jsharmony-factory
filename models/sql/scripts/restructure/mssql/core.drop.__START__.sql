if (object_id('{schema}.v_doc_ext', 'V') is not null) drop view {schema}.v_doc_ext;
go
if (object_id('{schema}.v_doc', 'V') is not null) drop view {schema}.v_doc;
go
if (object_id('{schema}.v_doc_filename', 'V') is not null) drop view {schema}.v_doc_filename;
go
if (object_id('{schema}.v_note_ext', 'V') is not null) drop view {schema}.v_note_ext;
go
if (object_id('{schema}.v_note', 'V') is not null) drop view {schema}.v_note;
go