jsh.App[modelid] = { }

jsh.App[modelid].oninit = function(xmodel) {
  var _this = this;
  XForm.prototype.XExecute('../_funcs/DEV_DB_SCRIPTS', { }, function (rslt) { //On success
    if ('_success' in rslt) { 
      _this.RenderDBListing(rslt.dbs);
    }
  });
  jsh.$root('.DEV_DB_SCRIPTS_db').change(function(){
    var db = jsh.$root('.DEV_DB_SCRIPTS_db').val();
    if(!db) jsh.$root('.DEV_DB_SCRIPTS_run').hide();
    else _this.GetScripts(db);
  });
}

jsh.App[modelid].RenderDBListing = function(dbs){
  var _this = this;
  var jobj = jsh.$root('.DEV_DB_SCRIPTS_db');
  if(dbs.length > 1){
    jsh.$root('.DEV_DB_SCRIPTS_dbselect').show();
    jobj.append($('<option>',{value:''}).text('Please select...'));
  }
  else {
    jsh.$root('.DEV_DB_SCRIPTS_dbselect').hide();
    jobj.empty();
  }
  for(var i=0;i<dbs.length;i++){
    var db = dbs[i];
    jobj.append($('<option>',{value:db}).text(db));
  }
  if(dbs.length==1) _this.GetScripts(dbs[0]);
}

jsh.App[modelid].GetScripts = function(dbid){
  var _this = this;
  XForm.prototype.XExecute('../_funcs/DEV_DB_SCRIPTS', { db: dbid }, function (rslt) { //On success
    if ('_success' in rslt) { 
      _this.RenderScripts(rslt.scripts);
    }
  });
}

jsh.App[modelid].RenderScripts = function(scripts){
  var _this = this;
  jsh.$root('.DEV_DB_SCRIPTS_run').show();
  jsh.$root('.DEV_DB_SCRIPTS_rslt').text('');

  function union(a,b){
    var rslt = {};
    for(var key in a){
      if(key in b) rslt[key] = union(a[key],b[key]);
    }
    if(_.isEmpty(rslt)) return { "...": "..." };
    return rslt;
  }

  //--------------------

  var jobj = jsh.$root('.DEV_DB_SCRIPTS_listing');
  //Clear any existing content
  jobj.empty();
  //Render scripts tree
  jobj.append(_this.RenderScriptsNode(scripts));
  //Generate "All" tree
  var allscripts = null;
  for(var module in scripts){
    if(allscripts===null) allscripts = scripts[module];
    else allscripts = union(allscripts, scripts[module]);
  }
  allscripts = { "(All)": allscripts };
  jobj.children("ul").prepend(_this.RenderScriptsNode(allscripts).children());
  //Attach events
  jobj.find('a.run').click(function(e){ e.preventDefault(); _this.ExecScript(this, 'run'); });
  jobj.find('a.info').click(function(e){ e.preventDefault(); _this.ExecScript(this, 'read'); });
}

jsh.App[modelid].RenderScriptsNode = function(node){
  var _this = this;
  var jlist = $('<ul></ul>');
  for(var childname in node){
    if(_.isString(node[childname])) continue;
    var jchild = $('<li class="DEV_DB_SCRIPTS_node"></li>');
    jchild.data('id',(childname=='(All)'?'*':childname));
    //Link to run script
    var jchildlink = $('<a class="run"></a>');
    jchildlink.text(childname);
    jchildlink.prop('href','#');
    jchild.append(jchildlink);
    //Link to read script
    var jchildinfolink = $('<a class="info"></a>');
    jchildinfolink.html('<img src="/images/icon_search.png" width="12" style="padding-left:8px;position:relative;top:2px;" />');
    jchildinfolink.prop('href','#');
    jchild.append(jchildinfolink);
    //Children
    var childlist = _this.RenderScriptsNode(node[childname]);
    if(childlist.length) jchild.append(childlist);
    jlist.append(jchild);
  }
  if(!jlist.children().length) return $();
  return jlist;
}

jsh.App[modelid].ExecScript = function(obj, mode){
  var _this = this;
  var jobj = $(obj);
  jsh.$root('.DEV_DB_SCRIPTS_rslt').text('');

  var sql = jsh.$root('.DEV_DB_sql').val();
  var starttm = Date.now();

  var scriptid = [];
  var parent = jobj.parent().closest('li');
  while(parent.hasClass('DEV_DB_SCRIPTS_node')){
    scriptid.unshift(parent.data('id'));
    parent = parent.parent().closest('li');
  }

  var params = { scriptid: scriptid, mode: mode, db: jsh.$root('.DEV_DB_SCRIPTS_db').val() };
  var runas_user = jsh.$root('.DEV_DB_SCRIPTS_user').val().trim();
  var runas_password = jsh.$root('.DEV_DB_SCRIPTS_password').val();
  if(runas_user){
    params.runas_user = runas_user;
    params.runas_password = runas_password;
  }

  XForm.prototype.XExecutePost('../_funcs/DEV_DB_SCRIPTS', { data: JSON.stringify(params) }, function (rslt) { //On success
    if ('_success' in rslt) {
      if(mode=='read'){
        jsh.$root('.DEV_DB_SCRIPTS_rslt').text(params.scriptid+"\r\n-------------------------------\r\n"+rslt.src);
      }
      else{
        var txt = '';
        if(rslt._stats){
          _.each(rslt._stats, function(stats){
            _.each(stats.warnings, function(warning){ txt += "WARNING: "+warning+"\r\n"; });
            _.each(stats.notices, function(notice){ txt += "NOTICE: "+notice+"\r\n"; });
          });
        }
        if(rslt.dbrslt[0]) for(var i=0;i<rslt.dbrslt[0].length;i++){
          txt += "Resultset " + (i+1).toString() + "\r\n" + "------------------------------------\r\n";
          txt += JSON.stringify(rslt.dbrslt[0][i],null,4) + "\r\n\r\n";
        }
        txt += "\r\nOperation complete";
        var endtm = Date.now();
        txt += "\r\nTime: " + (endtm-starttm) + "ms";
        jsh.$root('.DEV_DB_SCRIPTS_rslt').text(txt);
      }
    }
  });
}