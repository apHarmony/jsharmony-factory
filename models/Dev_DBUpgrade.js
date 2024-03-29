jsh.App[modelid] = new (function(){
  var _this = this;

  this.dbmenuId = 0;
  this.moduleVersions = {};
  this.hasAdmin = false;
  this.scripts = {};

  this.getFormElement = function(){
    return jsh.$root('.xformcontainer.xelem'+xmodel.class);
  };

  this.oninit = function(xmodel) {
    var jform = _this.getFormElement();
    XForm.prototype.XExecute('../_funcs/DEV_DB_UPGRADE', { }, function (rslt) { //On success
      if ('_success' in rslt) {
        _this.RenderDBListing(rslt.dbs);
        _this.moduleVersions = rslt.versions;
      }
    });
    jform.$find('.db').change(function(){
      XExt.navTo(window.location.href.split('?')[0] + '?' + $.param({ db: jform.$find('.db').val() }));
    });
    jform.$find('.runas .admin').change(function(){
      _this.renderRunAs();
    });
  };

  this.renderRunAs = function(){
    var jform = _this.getFormElement();
    var checked = jform.$find('.runas .admin').prop('checked');
    if(checked){
      XPage.Disable(jform.$find('.runas .user'));
      XPage.Disable(jform.$find('.runas .password'));
      jform.$find('.runas .user').val('');
      jform.$find('.runas .password').val('');
    }
    else {
      XPage.Enable(jform.$find('.runas .user'));
      XPage.Enable(jform.$find('.runas .password'));
    }
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
    if(dbs.length==1) _this.GetScripts(dbs[0]);
    else if(jsh._GET['db']){
      jobj.val(jsh._GET['db']);
      _this.GetScripts(jsh._GET['db']);
    }
  };

  this.GetScripts = function(dbid){
    XForm.prototype.XExecute('../_funcs/DEV_DB_UPGRADE', { db: dbid }, function (rslt) { //On success
      if ('_success' in rslt) {
        _this.scripts = rslt.scripts;
        _this.hasAdmin = rslt.hasAdmin;
        _this.RenderScripts();
      }
    });
  };

  this.RenderScripts = function(){
    var jform = _this.getFormElement();
    jform.$find('.run').show();
    jform.$find('.restart_link').show();
    jform.$find('.rslt').text('');
    jform.$find('.rslt_actions').hide();

    var jobj = jform.$find('.listing');
    //Clear any existing content
    jobj.empty();
    //Render scripts
    jobj.append(_this.RenderModules(_this.scripts));
    //Attach events
    jobj.$find('a.upgrade_link').click(function(e){ e.preventDefault(); _this.ExecScript('preview', this); });
    if(_this.hasAdmin){
      jform.$find('.runas .admin_container').show();
      jform.$find('.runas .admin').prop('checked', true);
    }
    else {
      jform.$find('.runas .admin_container').hide();
      jform.$find('.runas .admin').prop('checked', false);
    }
    _this.renderRunAs();
  };

  this.RenderModules = function(node){
    var jlist = $('<ul></ul>');
    for(var moduleName in node){
      if(_.isEmpty(node[moduleName])) continue;
      var jchild = $('<li class="node"></li>');
      jchild.data('id',moduleName);
      jchild.append('<span>'+XExt.escapeHTML(moduleName)+'</span>');
      //Children
      var childlist = _this.RenderModuleScripts(moduleName, node[moduleName]);
      if(childlist.length) jchild.append(childlist);
      jlist.append(jchild);
    }
    if(!jlist.children().length) return $();
    return jlist;
  };

  this.isVersionActive = function(moduleName, scriptName){
    if(moduleName in _this.moduleVersions){
      var curVersion = (_this.moduleVersions[moduleName]||'').split('-');
      var scriptVersion = (scriptName||'').split('-');
      for(var i=0;i<4;i++){
        var curSubVersion = parseInt(curVersion[i]||'0');
        if(curSubVersion.toString() != curVersion[i]) curSubVersion = 0;
        var scriptSubVersion = parseInt(scriptVersion[i]||'0');
        if(scriptSubVersion.toString() != (scriptVersion[i]||'0')) return true;
        if(curSubVersion > scriptSubVersion) return false;
        if(curSubVersion < scriptSubVersion) return true;
      }
      return false;
    }
    return true;
  };

  this.RenderModuleScripts = function(moduleName, scripts){
    var jlist = $('<ul></ul>');
    for(var scriptName in scripts){
      var jtype = $('<li class="node"></li>');
      jtype.data('id',scriptName);
      var isActive = _this.isVersionActive(moduleName, scriptName);
      jtype.append('<a href="#" class="upgrade_link '+(isActive?'active':'')+'" data-script="'+XExt.escapeHTML(scriptName)+'" data-module="'+XExt.escapeHTML(moduleName)+'">'+XExt.escapeHTML(scriptName)+'</a>');
      jlist.append(jtype);
    }
    if(!jlist.children().length) return $();
    return jlist;
  };

  this.ExecScript = function(mode, obj){
    var jform = _this.getFormElement();
    var jobj = $(obj);
    if(mode=='preview'){
      jform.$find('.rslt').text('');
      jform.$find('.rslt_actions').hide();
    }

    var scriptName = jobj.data('script');
    var moduleName = jobj.data('module');

    var starttm = Date.now();

    var params = { scriptName: scriptName, moduleName: moduleName, mode: mode, db: jform.$find('.db').val() };
    if(jform.$find('.admin').prop('checked')){
      params.runas_admin = true;
    }
    else {
      var runas_user = jform.$find('.user').val().trim();
      var runas_password = jform.$find('.password').val();
      if(runas_user){
        params.runas_user = runas_user;
        params.runas_password = runas_password;
      }
    }

    XForm.prototype.XExecutePost('../_funcs/DEV_DB_UPGRADE', { data: JSON.stringify(params) }, function (rslt) { //On success
      if ('_success' in rslt) {
        if(mode=='preview'){
          jform.$find('.rslt').text(moduleName+' :: '+scriptName+'\r\n-------------------------------\r\n'+rslt.src);
          jform.$find('.rslt_actions').show();
          jform.$find('.rslt_actions').off('click').on('click', function(){
            _this.ExecScript('run', obj, scriptName);
          });
        }
        else{
          var txt = moduleName+' :: '+scriptName+'\r\n-------------------------------\r\n';
          if(rslt._stats){
            _.each(rslt._stats, function(stats){
              _.each(stats.warnings, function(warning){ txt += 'WARNING: '+warning+'\r\n'; });
              _.each(stats.notices, function(notice){ txt += 'NOTICE: '+notice+'\r\n'; });
            });
          }
          if(rslt.dbrslt[0]) for(var i=0;i<rslt.dbrslt[0].length;i++){
            txt += 'Resultset ' + (i+1).toString() + '\r\n' + '------------------------------------\r\n';
            txt += JSON.stringify(rslt.dbrslt[0][i],null,4) + '\r\n\r\n';
          }
          txt += '\r\nOperation complete';
          var endtm = Date.now();
          txt += '\r\nTime: ' + (endtm-starttm) + 'ms';
          _this.moduleVersions = rslt.versions;
          _this.RenderScripts();
          jform.$find('.rslt').text(txt);
          if(rslt.dbcommands.restart) XExt.Alert('Restarting jsHarmony');
        }
      }
    });
  };

})();