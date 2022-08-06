jsh.App[modelid] = new (function(){
  var _this = this;

  this.state_default = {
    db: '',
    sql: '',
  };
  this.defaultSQL = '';
  this.defaultDB = '';
  this.state = _.extend({}, this.state_default);
  this.DBs = {};  //Populated onroute
  this.TABLE_DEF = undefined;  //Populated onroute, if "table" is set
  this.TABLE_OBJ = undefined;  //Populated onroute, if "table" is set
  this.TABLE_INIT = '';  //Populated onroute, if "table" is set, and SqlObject is defined for the table

  this.samples = {};
  this.samples.mssql = {
    'Select': 'select top 1000 * from TABLENAME;',
    'Get DB / Server Name': 'select db_name() db_name,@@servername server_name;',
    'List Tables': "select schemas.name schema_name, objects.name table_name from sys.objects inner join sys.schemas on sys.schemas.schema_id = sys.objects.schema_id where TYPE='U' order by schema_name,table_name",
    'List Views': "select schemas.name schema_name, objects.name table_name from sys.objects inner join sys.schemas on sys.schemas.schema_id = sys.objects.schema_id where TYPE='V' order by schema_name,table_name",
    'List Stored Procedures': "select schemas.name schema_name, objects.name table_name from sys.objects inner join sys.schemas on sys.schemas.schema_id = sys.objects.schema_id where TYPE='P' order by schema_name,table_name",
    'Describe Table': "select * from information_schema.columns where table_name = 'xxxxx' order by ordinal_position",
    'Describe View / Object': "select object_definition(object_id('VIEW_NAME')) as Source;",
    'Create Table': '',
    'Create View': '',
    'Create Stored Procedure': '',
    'Create UCOD': '',
  };
  this.samples.pgsql = {
    'Select': 'select * from TABLENAME limit 1000;',
    'Get DB Name': 'select current_database() db_name;',
    'List Tables': "select table_schema||'.'||table_name as table from information_schema.tables where table_type='BASE TABLE' and table_schema not in ('information_schema','pg_catalog') order by table_schema,table_name",
    'List Views': "select table_schema||'.'||table_name as view from information_schema.tables where table_type='VIEW' and table_schema not in ('information_schema','pg_catalog') order by table_schema,table_name",
    'List Stored Procedures': "SELECT nspname||'.'||proname as proc from pg_catalog.pg_namespace n inner join pg_catalog.pg_proc p on pronamespace = n.oid where nspname not in ('information_schema','pg_catalog') order by nspname,proname",
    'Describe Table': "select column_name, data_type, character_maximum_length from INFORMATION_SCHEMA.COLUMNS where table_schema = 'public' and table_name = 'xxxxx';",
    'Drop / Create Table': "drop table if exists cust;\r\n\
  create table public.cust (\
    cust_id bigserial primary key not null,\r\n\
    cust_sts character varying(32) NOT NULL references public.code_sys_cust_sts(code_val),\r\n\
    cust_agreement_tstmp timestamp without time zone DEFAULT {schema}.my_now() NOT NULL,\r\n\
    cust_name character varying(255) NOT NULL UNIQUE,\r\n\
    cust_ein bytea DEFAULT '\\x00'::bytea NOT NULL,\r\n\
    cust_einhash bytea DEFAULT '\\x00'::bytea NOT NULL,\r\n\
    cust_doc_ext character varying(16),\r\n\
    cust_doc_size bigint,\r\n\
    cust_doc_uptstmp timestamp without time zone,\r\n\
    cust_doc_uu character varying(20),\r\n\
    foreign key (cust_sts) references public.code_sys_cust_sts(code_val)\r\n\
  );\r\n\
  insert into cust(cust_id,cust_sts,cust_name) values (1,'ACTIVE','ACME Industries');",
    'Drop / Create View': 'drop view if exists v_cust;\r\n\
    create view v_cust as\r\n\
    select cust_id,cust_sts,cust_name,code_sys_cust_sts.code_txt as cust_sts_txt,cust_einhash\r\n\
      from public.cust\r\n\
      left outer join public.code_sys_cust_sts on cust.cust_sts = code_sys_cust_sts.code_val;',
    'Create Stored Procedure': '',
    'Create UCOD': '',
  };
  this.samples.sqlite = {
    'Select': 'select * from TABLENAME limit 1000;',
    'List Tables': "SELECT name FROM sqlite_master WHERE type='table' order by name;",
    'List Views': "SELECT name FROM sqlite_master WHERE type='view' order by name;",
    'Describe Table': 'PRAGMA table_info(xxxxx);',
    'Drop / Create Table': "drop table if exists cust;\r\n\
  create table cust (\r\n\
    cust_id integer primary key autoincrement not null,\r\n\
    cust_sts text not null,\r\n\
    cust_agreement_tstmp text,\r\n\
    cust_name text not null unique,\r\n\
    cust_ein blob,\r\n\
    cust_einhash blob,\r\n\
    cust_doc_ext text,\r\n\
    cust_doc_size integer,\r\n\
    cust_doc_uptstmp text,\r\n\
    cust_doc_uu text,\r\n\
    foreign key (cust_sts) references code_sys_cust_sts(code_val)\r\n\
  );\r\n\
  insert into cust(cust_id,cust_sts,cust_name) values (1,'ACTIVE','ACME Industries');",
    'Recreate Table': '--***Run Restructure Drop\r\n'+
      'TABLE_INIT\r\n'+
      'insert into TABLENAME2(COLUMNS) select COLUMNS from TABLENAME;\r\n'+
      'PRAGMA foreign_keys=off;\r\n'+
      'drop table TABLENAME;\r\n'+
      'ALTER table TABLENAME2 RENAME TO TABLENAME;\r\n'+
      'PRAGMA foreign_keys=on;\r\n'+
      '--***Run Restructure Init\r\n',
    'Drop / Create View': 'drop view if exists v_cust;\r\n\
  create view v_cust as\r\n\
  select cust_id,cust_sts,cust_name,code_sys_cust_sts.code_txt as cust_sts_txt,cust_einhash\r\n\
    from cust\r\n\
    left outer join code_sys_cust_sts on cust.cust_sts = code_sys_cust_sts.code_val;',
    'Create UCOD': "create_code_sys('code_sys_cust_sts');\r\n\
  INSERT INTO {schema}_code_sys (code_name, code_desc) VALUES ('cust_sts', 'Customer Status');\r\n\
  insert into code_sys_cust_sts(code_seq,code_val,code_txt,code_code) values (1,'ACTIVE','Active','A');",
  };

  this.getFormElement = function(){
    return jsh.$root('.xformcontainer.xelem'+xmodel.class);
  };

  this.renderDB = function(){
    var jform = _this.getFormElement();
    var db = jform.$find('.db').val();
    if(!db) jform.$find('.run').hide();
    else{
      _this.LoadScripts(db);
    }
  };

  this.oninit = function(xmodel) {
    var jform = _this.getFormElement();
    jform.$find('.db').change(function(){
      _this.defaultDB = '';
      _this.renderDB();
    });
    var jSamples = jform.$find('.samples');
    jSamples.change(function(){
      var db = jform.$find('.db').val();
      var dbtype = _this.DBs[db];
      var sampleName = jSamples.val();
      var samples = _this.samples[dbtype];
      if(!(sampleName in samples)){ return XExt.Alert('Sample not found: '+sampleName); }
      var sampleSQL = samples[sampleName];
      jform.$find('.sql').val(sampleSQL);
      jSamples.val('');
    });
    jform.$find('.runsql').click(function(){ _this.RunSQL(); });
    jform.$find('.exportcsv').click(function(){ _this.ExportCSV(); });
    jform.$find('.runas_toggle').click(function(){ jform.$find('.runas').toggle(); return false; });

    _this.RenderDBListing(_.keys(_this.DBs));
  };

  this.onload = function(){
    var jform = _this.getFormElement();
    var jobj = jform.$find('.db');
    var dbs = _.keys(_this.DBs);
    _this.defaultDB = '';
    _this.defaultSQL = '';
    if(dbs.length==1){
      _this.defaultDB = dbs[0];
      _this.LoadScripts(dbs[0]);
    }
    else if(_this.state && _this.state.db){
      jobj.val(_this.state.db);
      _this.renderDB();
    }
    else if(_GET['db']){
      _this.defaultDB = _GET['db'];
      jobj.val(_GET['db']);
      _this.renderDB();
    }
    else {
      jobj.val('');
      _this.renderDB();
    }
    _this.saveState();
  };

  this.RenderDBListing = function(dbs){
    var jform = _this.getFormElement();
    var jobj = jform.$find('.db');
    if(dbs.length > 1){
      jform.$find('.dbselect').show();
      jobj.append($('<option>',{value:''}).text('Please select...'));
    }
    else {
      jform.$find('.dbselect').hide();
      jobj.empty();
    }
    for(var i=0;i<dbs.length;i++){
      var db = dbs[i];
      jobj.append($('<option>',{value:db}).text(db));
    }
  };

  this.LoadScripts = function(db){
    var jform = _this.getFormElement();
    jform.$find('.run').show();
    jform.$find('.rslt').html('');
    var jSamples = jform.$find('.samples');
    jSamples.empty();
    jSamples.append($('<option>',{value:''}).text('Please select...'));
    var dbtype = _this.DBs[db];
    
    var sql = '';
    if(_this.state && _this.state.sql){
      sql = _this.state.sql;
    }
    else if(_GET['sql']){
      sql = _GET['sql'];
    }
    if(sql) jform.$find('.sql').val(sql);

    if(dbtype in _this.samples){
      var samples = _this.samples[dbtype];
      for(var sampleName in samples){
        var option = $('<option></option>');
        option.text(sampleName);
        option.val(sampleName);
        jSamples.append(option);
      }
      if(!sql){
        if(_GET['table']){
          if(_GET['scripttype']=='recreate'){
            sql = samples['Recreate Table'];
            if(_this.TABLE_OBJ){
              var COLUMNS = _.map(_this.TABLE_OBJ.columns, function(column){ return column.name; }).join(',');
              sql = sql.replace(/COLUMNS/g,COLUMNS);
              var createSql = _this.TABLE_INIT||'create table TABLENAME();';
              createSql = createSql.replace(/TABLENAME/g,_GET['table']+'2');
              sql = sql.replace(/TABLE_INIT/g,createSql);
            }
            sql = sql.replace(/TABLENAME/g,_GET['table']);
            jform.$find('.sql').val(sql);
            _this.defaultSQL = sql;
          }
          else {
            sql = samples['Select'];
            sql = sql.replace('TABLENAME',_GET['table']);
            jform.$find('.sql').val(sql);
            _this.defaultSQL = sql;
            jform.$find('.runsql').click();
          }
        }
        else if('Select' in samples){
          sql = samples['Select'];
          jform.$find('.sql').val(sql);
          _this.defaultSQL = sql;
        }
      }
    }
  };

  this.getExecParams = function(){
    var jform = _this.getFormElement();
    var sql = jform.$find('.sql').val();
    var db = jform.$find('.db').val();
    var params = { sql: sql, db: db };
    var runas_user = jform.$find('.user').val().trim();
    var runas_password = jform.$find('.password').val();
    var nocontext = jform.$find('.nocontext').is(':checked');
    if(runas_user){
      params.runas_user = runas_user;
      params.runas_password = runas_password;
    }
    params.show_notices = true;
    params.nocontext = nocontext?'1':'';
    return params;
  };

  this.ExportCSV = function(){
    var params = _this.getExecParams();
    params.export_csv = 1;
    var url = jsh._BASEURL + '_db/exec';
    jsh.postFileProxy(url, params);
  };

  this.ongetstate = function(){ return _this.state; };

  this.onloadstate = function(xmodel, state){
    _this.state = _.extend({}, _this.state_default, _this.state, state);
  };

  this.saveState = function(){
    var jform = _this.getFormElement();
    var newState = {};
    newState.db = jform.$find('.db').val() || '';
    newState.sql = jform.$find('.sql').val() || '';
    if(newState.db == _this.defaultDB) newState.db = '';
    if(newState.sql == _this.defaultSQL) newState.sql = '';
    if(!_this.state){
      _this.state = newState;
    }
    else if(JSON.stringify(newState) != JSON.stringify(_this.state)){
      _this.state = newState;
      jsh.XPage.AddHistory();
    }
  };

  this.RunSQL = function(options){
    var jform = _this.getFormElement();
    var starttm = Date.now();

    var params = _this.getExecParams();

    if(jform.$find('.sql').val() != _this.defaultSQL) _this.defaultSQL = '';

    //Save history state
    _this.saveState();

    XForm.prototype.XExecutePost('../_db/exec', params, function (rslt) { //On success
      if ('_success' in rslt) {
        var str = '';
        if(rslt._stats){
          _.each(rslt._stats.warnings, function(warning){ str += '<div><b>WARNING: </b>'+warning+'</div>'; });
          _.each(rslt._stats.notices, function(notice){ str += '<div><b>NOTICE: </b>'+notice+'</div>'; });
        }
        if(rslt.dbrslt && rslt.dbrslt.length){
          for(var i=0;i<rslt.dbrslt.length;i++){
            var dbrslt = rslt.dbrslt[i];
            str += '<h1 style="margin-top:10px;">Resultset '+(i+1)+'</h1>';
            if(dbrslt.length){
              str += '<table border=1>';
              var headers = _.keys(dbrslt[0]);
              str += '<tr>';
              for(var k=0;k<headers.length;k++){
                str += '<th>' + XExt.escapeHTMLBR(headers[k]) + '</th>';
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
        str += "<div style='font-weight:bold'>Time: " + (endtm-starttm) + 'ms</div>';
        jform.$find('.rslt').html(str);
      }
    });
    
  };

})();