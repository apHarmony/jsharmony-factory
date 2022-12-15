jsharmony.version_increment('jsHarmonyFactory',1,16,0,0);

alter table {schema}.job__tbl add job_prty integer not null default 0;

%%%RESTART%%%
