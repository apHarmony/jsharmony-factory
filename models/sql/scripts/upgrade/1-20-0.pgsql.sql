jsharmony.version_increment('jsHarmonyFactory',1,20,0,0);

alter table {schema}.audit_detail alter column audit_column_name character varying(32) not null;

%%%RESTART%%%
