jsh.App.DEV_DB = { }

jsh.App.DEV_DB.DBs = {};  //Populated onroute

jsh.App.DEV_DB.samples = {};
jsh.App.DEV_DB.samples.mssql = {
  "Select": "select * from c;select * from cf",
  "List Tables": "",
  "List Views": "",
  "List Stored Procedures": "",
  "Describe Table": "select * from information_schema.columns where table_name = 'xxxxx' order by ordinal_position",
  "Create Table": "",
  "Create View": "",
  "Create Stored Procedure": "",
  "Create UCOD": "",
};
jsh.App.DEV_DB.samples.pgsql = {
  "Select": "select * from c;select * from cf",
  "List Tables": "",
  "List Views": "",
  "List Stored Procedures": "",
  "Describe Table": "select column_name, data_type, character_maximum_length from INFORMATION_SCHEMA.COLUMNS where table_name = 'xxxxx';",
  "Create Table": "",
  "Create View": "",
  "Create Stored Procedure": "",
  "Create UCOD": "",
};
jsh.App.DEV_DB.samples.sqlite = {
  "Select": "select * from c;select * from cf",
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


jsh.App.DEV_DB.oninit = function(xform) {
  var _this = this;
  $('#DEV_DB_db').change(function(){
    var db = $('#DEV_DB_db').val();
    if(!db) $('#DEV_DB_run').hide();
    else jsh.App.DEV_DB.LoadScripts(db);
  });
  var jSamples = $('#DEV_DB_samples');
  jSamples.change(function(){
    var db = $('#DEV_DB_db').val();
    var dbtype = _this.DBs[db];
    var sampleName = jSamples.val();
    var samples = _this.samples[dbtype];
    if(!(sampleName in samples)){ return XExt.Alert('Sample not found: '+sampleName); }
    var sampleSQL = samples[sampleName];
    $('#DEV_DB_sql').val(sampleSQL)
    jSamples.val('');
  });
  $('#DEV_DB_runsql').click(function(){ jsh.App.DEV_DB.RunSQL(); });
  $('#DEV_DB_runas_toggle').click(function(){ $('#DEV_DB_runas').toggle(); return false; });

  jsh.App.DEV_DB.RenderDBListing(_.keys(_this.DBs));
}

jsh.App.DEV_DB.RenderDBListing = function(dbs){
  var jobj = $('#DEV_DB_db');
  if(dbs.length > 1){
    $('#DEV_DB_dbselect').show();
    jobj.append($('<option>',{value:''}).text('Please select...'));
  }
  else {
    $('#DEV_DB_dbselect').hide();
    jobj.empty();
  }
  for(var i=0;i<dbs.length;i++){
    var db = dbs[i];
    jobj.append($('<option>',{value:db}).text(db));
  }
  if(dbs.length==1) jsh.App.DEV_DB.LoadScripts(dbs[0]);
}

jsh.App.DEV_DB.LoadScripts = function(db){
  var _this = this;
  $('#DEV_DB_run').show();
  $('#DEV_DB_rslt').text('');
  var jSamples = $('#DEV_DB_samples');
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
    if('Select' in samples){
      $('#DEV_DB_sql').val(samples['Select'])
    }
  }
}

jsh.App.DEV_DB.RunSQL = function(){
  var _this = this;
  var sql = $('#DEV_DB_sql').val();
  var db = $('#DEV_DB_db').val();
  var dbtype = _this.DBs[db];
  starttm = Date.now();
  if(dbtype=='pgsql') sql = "select '-----TABLE-----' as table_boundary;"+sql;
  var params = { sql: sql, db: db };
  var runas_user = $('#DEV_DB_user').val().trim();
  var runas_password = $('#DEV_DB_password').val();
  if(runas_user){
    params.runas_user = runas_user;
    params.runas_password = runas_password;
  }
  XPost.prototype.XExecutePost('../_db/exec', params, function (rslt) { //On success
    if ('_success' in rslt) { 
      var txt = '';
      if(rslt.dbrslt[0]) for(var i=0;i<rslt.dbrslt[0].length;i++){
        txt += "Resultset " + (i+1).toString() + "\r\n" + "------------------------------------\r\n";
        txt += JSON.stringify(rslt.dbrslt[0][i],null,4) + "\r\n\r\n";
      }
      txt += "\r\nOperation complete";
      var endtm = Date.now();
      txt += "\r\nTime: " + (endtm-starttm) + "ms";
      $('#DEV_DB_rslt').text(txt);
    }
  });
}