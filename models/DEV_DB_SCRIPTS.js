function DEV_DB_SCRIPTS_oninit(xform) {
  XPost.prototype.XExecute('../_funcs/DEV_DB_SCRIPTS', { }, function (rslt) { //On success
    if ('_success' in rslt) { 
      DEV_DB_SCRIPTS_RenderScripts(rslt.scripts);
    }
  });
}

function DEV_DB_SCRIPTS_RenderScripts(scripts){

  function union(a,b){
    var rslt = {};
    for(var key in a){
      if(key in b) rslt[key] = union(a[key],b[key]);
    }
    if(_.isEmpty(rslt)) return { "...": "..." };
    return rslt;
  }

  //--------------------

  var jobj = $('#DEV_DB_SCRIPTS_listing');
  //Clear any existing content
  jobj.empty();
  //Render scripts tree
  jobj.append(DEV_DB_SCRIPTS_RenderScriptsNode(scripts));
  //Generate "All" tree
  var allscripts = null;
  for(var component in scripts){
    if(allscripts===null) allscripts = scripts[component];
    else allscripts = union(allscripts, scripts[component]);
  }
  allscripts = { "(All)": allscripts };
  jobj.children("ul").prepend(DEV_DB_SCRIPTS_RenderScriptsNode(allscripts).children());
  //Attach events
  jobj.find('a').click(function(e){ e.preventDefault(); DEV_DB_SCRIPTS_RunScript(this); });
}

function DEV_DB_SCRIPTS_RenderScriptsNode(node){
  var jlist = $('<ul></ul>');
  for(var childname in node){
    if(_.isString(node[childname])) continue;
    var jchild = $('<li class="DEV_DB_SCRIPTS_node"></li>');
    var jchildlink = $('<a></a>');
    jchildlink.text(childname);
    jchildlink.prop('href','#');
    jchild.data('id',(childname=='(All)'?'*':childname));
    jchild.append(jchildlink);
    var childlist = DEV_DB_SCRIPTS_RenderScriptsNode(node[childname]);
    if(childlist.length) jchild.append(childlist);
    jlist.append(jchild);
  }
  if(!jlist.children().length) return $();
  return jlist;
}

function DEV_DB_SCRIPTS_RunScript(obj){
  var jobj = $(obj);
  $('#DEV_DB_SCRIPTS_rslt').text('');

  var sql = $('#DEV_DB_sql').val();
  starttm = Date.now();

  var scriptid = [];
  var parent = jobj.parent().closest('li');
  while(parent.hasClass('DEV_DB_SCRIPTS_node')){
    scriptid.unshift(parent.data('id'));
    parent = parent.parent().closest('li');
  }

  var params = { scriptid: scriptid };
  var runas_user = $('#DEV_DB_SCRIPTS_user').val().trim();
  var runas_password = $('#DEV_DB_SCRIPTS_password').val();
  if(runas_user){
    params.runas_user = runas_user;
    params.runas_password = runas_password;
  }

  XPost.prototype.XExecutePost('../_funcs/DEV_DB_SCRIPTS', { data: JSON.stringify(params) }, function (rslt) { //On success
    if ('_success' in rslt) {
      var txt = '';
      if(rslt.dbrslt[0]) for(var i=0;i<rslt.dbrslt[0].length;i++){
        txt += "Resultset " + (i+1).toString() + "\r\n" + "------------------------------------\r\n";
        txt += JSON.stringify(rslt.dbrslt[0][i],null,4) + "\r\n\r\n";
      }
      txt += "\r\nOperation complete";
      var endtm = Date.now();
      txt += "\r\nTime: " + (endtm-starttm) + "ms";
      $('#DEV_DB_SCRIPTS_rslt').text(txt);
    }
  });
}