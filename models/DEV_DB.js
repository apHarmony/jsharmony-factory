window.DEV_DB_type = ''; //Populated onroute

var DEV_DB_samples = {};
DEV_DB_samples.mssql = {
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
DEV_DB_samples.pgsql = {
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
DEV_DB_samples.sqlite = {
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


function DEV_DB_oninit(xform) {
  var jSamples = $('#DEV_DB_samples');
  if(window.DEV_DB_type in DEV_DB_samples){
    var samples = DEV_DB_samples[window.DEV_DB_type];
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
  jSamples.change(function(){
    var sampleName = jSamples.val();
    var samples = DEV_DB_samples[window.DEV_DB_type];
    if(!(sampleName in samples)){ return XExt.Alert('Sample not found: '+sampleName); }
    var sampleSQL = samples[sampleName];
    $('#DEV_DB_sql').val(sampleSQL)
    jSamples.val('');
  });
}

function DEV_DB_RunSQL(){
  var sql = $('#DEV_DB_sql').val();
  starttm = Date.now();
  if(window.DEV_DB_type=='pgsql') sql = "select '-----TABLE-----' as table_boundary;"+sql;
  XPost.prototype.XExecutePost('../_db/exec', { sql: sql }, function (rslt) { //On success
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