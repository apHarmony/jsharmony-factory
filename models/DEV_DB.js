jsh.App[modelid] = { }

jsh.App[modelid].DBs = {};  //Populated onroute

jsh.App[modelid].samples = {};
jsh.App[modelid].samples.mssql = {
  "Select": "select top 1000 * from TABLE;",
  "List Tables": "select schemas.name schema_name, objects.name table_name from sys.objects inner join sys.schemas on sys.schemas.schema_id = sys.objects.schema_id where TYPE='U' order by schema_name,table_name",
  "List Views": "select schemas.name schema_name, objects.name table_name from sys.objects inner join sys.schemas on sys.schemas.schema_id = sys.objects.schema_id where TYPE='V' order by schema_name,table_name",
  "List Stored Procedures": "select schemas.name schema_name, objects.name table_name from sys.objects inner join sys.schemas on sys.schemas.schema_id = sys.objects.schema_id where TYPE='P' order by schema_name,table_name",
  "Describe Table": "select * from information_schema.columns where table_name = 'xxxxx' order by ordinal_position",
  "Create Table": "",
  "Create View": "",
  "Create Stored Procedure": "",
  "Create UCOD": "",
};
jsh.App[modelid].samples.pgsql = {
  "Select": "select * from TABLE limit 1000;",
  "List Tables": "select table_schema||'.'||table_name as table from information_schema.tables where table_type='BASE TABLE' and table_schema not in ('information_schema','pg_catalog') order by table_schema,table_name",
  "List Views": "select table_schema||'.'||table_name as view from information_schema.tables where table_type='VIEW' and table_schema not in ('information_schema','pg_catalog') order by table_schema,table_name",
  "List Stored Procedures": "SELECT nspname||'.'||proname as proc from pg_catalog.pg_namespace n inner join pg_catalog.pg_proc p on pronamespace = n.oid where nspname not in ('information_schema','pg_catalog') order by nspname,proname",
  "Describe Table": "select column_name, data_type, character_maximum_length from INFORMATION_SCHEMA.COLUMNS where table_schema = 'public' and table_name = 'xxxxx';",
  "Drop / Create Table": "drop table if exists c;\r\n\
create table public.c (\
  c_id bigserial primary key not null,\r\n\
  c_sts character varying(8) NOT NULL references public.ucod_c_sts(codeval),\r\n\
  c_atstmp timestamp without time zone DEFAULT mynow() NOT NULL,\r\n\
  c_name character varying(255) NOT NULL UNIQUE,\r\n\
  c_ein bytea DEFAULT '\\x00'::bytea NOT NULL,\r\n\
  c_einhash bytea DEFAULT '\\x00'::bytea NOT NULL,\r\n\
  c_doc_ext character varying(16),\r\n\
  c_doc_size bigint,\r\n\
  c_doc_utstmp timestamp without time zone,\r\n\
  c_doc_uu character varying(20),\r\n\
  foreign key (c_sts) references public.ucod_c_sts(codeval)\r\n\
);\r\n\
insert into c(c_id,c_sts,c_name) values (1,'ACTIVE','ACME Industries');",
  "Drop / Create View": "drop view if exists v_c;\r\n\
  create view v_c as\r\n\
  select c_id,c_sts,c_name,ucod_c_sts.codetxt as c_sts_txt,c_einhash\r\n\
    from public.c\r\n\
    left outer join public.ucod_c_sts on c.c_sts = ucod_c_sts.codeval;",
  "Create Stored Procedure": "",
  "Create UCOD": "",
};
jsh.App[modelid].samples.sqlite = {
  "Select": "select * from TABLE limit 1000;",
  "List Tables": "SELECT name FROM sqlite_master WHERE type='table' order by name;",
  "List Views": "SELECT name FROM sqlite_master WHERE type='view' order by name;",
  "Describe Table": "PRAGMA table_info(xxxxx);",
  "Drop / Create Table": "drop table if exists c;\r\n\
create table c (\r\n\
  c_id integer primary key autoincrement not null,\r\n\
  c_sts text not null,\r\n\
  c_atstmp text,\r\n\
  c_name text not null unique,\r\n\
  c_ein blob,\r\n\
  c_einhash blob,\r\n\
  c_doc_ext text,\r\n\
  c_doc_size integer,\r\n\
  c_doc_utstmp text,\r\n\
  c_doc_uu text,\r\n\
  foreign key (c_sts) references ucod_c_sts(codeval)\r\n\
);\r\n\
insert into c(c_id,c_sts,c_name) values (1,'ACTIVE','ACME Industries');",
  "Drop / Create View": "drop view if exists v_c;\r\n\
create view v_c as\r\n\
select c_id,c_sts,c_name,ucod_c_sts.codetxt as c_sts_txt,c_einhash\r\n\
  from c\r\n\
  left outer join ucod_c_sts on c.c_sts = ucod_c_sts.codeval;",
  "Create UCOD": "create_ucod('ucod_c_sts');\r\n\
INSERT INTO jsharmony_ucod_h (codename, codemean) VALUES ('c_sts', 'Customer Status');\r\n\
insert into ucod_c_sts(codseq,codeval,codetxt,codecode) values (1,'ACTIVE','Active','A');",
};


jsh.App[modelid].oninit = function(xmodel) {
  var _this = this;
  jsh.$root('.DEV_DB_db').change(function(){
    var db = jsh.$root('.DEV_DB_db').val();
    if(!db) jsh.$root('.DEV_DB_run').hide();
    else jsh.App[modelid].LoadScripts(db);
  });
  var jSamples = jsh.$root('.DEV_DB_samples');
  jSamples.change(function(){
    var db = jsh.$root('.DEV_DB_db').val();
    var dbtype = _this.DBs[db];
    var sampleName = jSamples.val();
    var samples = _this.samples[dbtype];
    if(!(sampleName in samples)){ return XExt.Alert('Sample not found: '+sampleName); }
    var sampleSQL = samples[sampleName];
    jsh.$root('.DEV_DB_sql').val(sampleSQL)
    jSamples.val('');
  });
  jsh.$root('.DEV_DB_runsql').click(function(){ jsh.App[modelid].RunSQL(); });
  jsh.$root('.DEV_DB_runas_toggle').click(function(){ jsh.$root('.DEV_DB_runas').toggle(); return false; });

  jsh.App[modelid].RenderDBListing(_.keys(_this.DBs));
}

jsh.App[modelid].RenderDBListing = function(dbs){
  var jobj = jsh.$root('.DEV_DB_db');
  if(dbs.length > 1){
    jsh.$root('.DEV_DB_dbselect').show();
    jobj.append($('<option>',{value:''}).text('Please select...'));
  }
  else {
    jsh.$root('.DEV_DB_dbselect').hide();
    jobj.empty();
  }
  for(var i=0;i<dbs.length;i++){
    var db = dbs[i];
    jobj.append($('<option>',{value:db}).text(db));
  }
  if(dbs.length==1) jsh.App[modelid].LoadScripts(dbs[0]);
  else if(_GET['db']){
    jobj.val(_GET['db']).change();
  }
}

jsh.App[modelid].LoadScripts = function(db){
  var _this = this;
  jsh.$root('.DEV_DB_run').show();
  jsh.$root('.DEV_DB_rslt').html('');
  var jSamples = jsh.$root('.DEV_DB_samples');
  jSamples.empty();
  jSamples.append($('<option>',{value:''}).text('Please select...'));
  var dbtype = _this.DBs[db];
  if(dbtype in _this.samples){
    var samples = _this.samples[dbtype];
    for(var sampleName in samples){
      var option = $('<option></option>');
      option.text(sampleName);
      option.val(sampleName);
      jSamples.append(option);
    }
    if(_GET['table']){
      var sql = samples['Select'];
      sql = sql.replace('TABLE',_GET['table']);
      jsh.$root('.DEV_DB_sql').val(sql);
      jsh.$root('.DEV_DB_runsql').click();

    }
    else if('Select' in samples){
      jsh.$root('.DEV_DB_sql').val(samples['Select'])
    }
  }
}

jsh.App[modelid].RunSQL = function(){
  var _this = this;
  var sql = jsh.$root('.DEV_DB_sql').val();
  var db = jsh.$root('.DEV_DB_db').val();
  var dbtype = _this.DBs[db];
  var starttm = Date.now();
  var params = { sql: sql, db: db };
  var runas_user = jsh.$root('.DEV_DB_user').val().trim();
  var runas_password = jsh.$root('.DEV_DB_password').val();
  var nocontext = jsh.$root('.DEV_DB_nocontext').is(':checked');
  if(runas_user){
    params.runas_user = runas_user;
    params.runas_password = runas_password;
  }
  params.show_notices = true;
  params.nocontext = nocontext?'1':'';
  XForm.prototype.XExecutePost('../_db/exec', params, function (rslt) { //On success
    if ('_success' in rslt) { 
      var str = '';
      if(rslt._stats){
        _.each(rslt._stats.warnings, function(warning){ str += "<div><b>WARNING: </b>"+warning+"</div>"; });
        _.each(rslt._stats.notices, function(notice){ str += "<div><b>NOTICE: </b>"+notice+"</div>"; });
      }
      if(rslt.dbrslt && rslt.dbrslt.length){
        for(var i=0;i<rslt.dbrslt.length;i++){
          var dbrslt = rslt.dbrslt[i];
          str += '<h1 style="margin-top:10px;">Resultset '+(i+1)+'</h1>';
          if(dbrslt.length){
            str += '<table border=1>';
            var headers = _.keys(dbrslt[0]);
            str += '<tr>';
            for(var j=0;j<headers.length;j++){
              str += '<th>' + XExt.escapeHTMLBR(headers[j]) + '</th>';
            }
            str += '</tr>';
            for(var j=0;j<dbrslt.length;j++){
              var row = dbrslt[j];
              str += '<tr>';
              for(var col in row){
                var escval = XExt.escapeHTMLBR(row[col])||'';
                if((escval.indexOf(' ')<0)||(escval.length < 50)) escval = '<span style="white-space:nowrap;">'+escval+'</span>';
                if(row[col]===null) escval = '<span class="null">null</span>';
                str += '<td style="font-family:monospace;">' + escval + '</td>';
              }
              str += '</tr>';
            }
            str += '</table>';
          }
          else str += '<div>Empty</div>';
          str += '<div style="height:40px;"></div>';
        }
      }
      //Raw output
      /*
      var txt = '';
      if(rslt.dbrslt[0]) for(var i=0;i<rslt.dbrslt[0].length;i++){
        txt += "Resultset " + (i+1).toString() + "\r\n" + "------------------------------------\r\n";
        txt += JSON.stringify(rslt.dbrslt[0][i],null,4) + "\r\n\r\n";
      }
      txt += '';
      str = '<pre>'+XExt.escapeHTMLBR(txt)+'</pre>';
      */
      str += "<div style='font-weight:bold'>Operation complete</div>";
      var endtm = Date.now();
      str += "<div style='font-weight:bold'>Time: " + (endtm-starttm) + "ms</div>";
      jsh.$root('.DEV_DB_rslt').html(str);
    }
  });
}