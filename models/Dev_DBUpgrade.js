jsh.App[modelid] = new (function(){
  var _this = this;

  this.dbmenuId = 0;
  this.curScript = null;
  this.moduleVersions = {};
  this.hasAdmin = false;
  this.scripts = {};

  this.getFormElement = function(){
    return jsh.xd('.xformcontainer.xelem'+xmodel.class);
  };

  this.oninit = function(xmodel) {
    var xdform = _this.getFormElement();
    XForm.prototype.XExecute('../_funcs/DEV_DB_UPGRADE', { }, function (rslt) { //On success
      if ('_success' in rslt) {
        _this.RenderDBListing(rslt.dbs);
        _this.moduleVersions = rslt.versions;
      }
    });
    xdform.get('.db').on('change', function(){
      XExt.navTo(window.location.href.split('?')[0] + '?' + XExt.escapeQuery({ db: xdform.get('.db').value }));
    });
    xdform.get('.runas .admin').on('change', function(){
      _this.renderRunAs();
    });
    var xdrsltactions = xdform.get('.rslt_actions');
    xdrsltactions.on('click', function(e){
      if(_this.curScript){
        _this.ExecScript(_this.curScript.mode, _this.curScript.obj, _this.curScript.name);
      }
    });
  };

  this.renderRunAs = function(){
    var xdform = _this.getFormElement();
    var checked = xdform.get('.runas .admin').element.checked;
    var xduser = xdform.get('.runas .user');
    var xdpassword = xdform.get('.runas .password');
    if(checked){
      XPage.Disable(xduser.elements);
      XPage.Disable(xdpassword.elements);
      xduser.value = '';
      xdpassword.value = '';
    }
    else {
      XPage.Enable(xduser.elements);
      XPage.Enable(xdpassword.elements);
    }
  };

  this.RenderDBListing = function(dbs){
    var xdform = _this.getFormElement();
    var xdobj = xdform.get('.db');
    var tmpl = jsh.xd('.'+xmodel.class+'_DB_listing_template').html;
    xdobj.append(XDom.render.ejs(tmpl, {dbs: dbs}));
    if(dbs.length > 1){
      xdform.get('.dbselect').style.display = true;
    }
    else {
      xdform.get('.dbselect').style.display = false;
    }
    if(dbs.length==1) _this.GetScripts(dbs[0]);
    else if(jsh._GET['db']){
      xdobj.value = jsh._GET['db'];
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
    var xdform = _this.getFormElement();
    xdform.get('.run').style.display = true;
    xdform.get('.restart_link').style.display = true;
    xdform.get('.rslt').text = '';
    xdform.get('.rslt_actions').style.display = false;

    var xdobj = xdform.get('.listing');
    //Clear any existing content
    xdobj.clear();
    //Render scripts
    xdobj.append(_this.RenderModules(_this.scripts));
    //Attach events
    xdobj.get('a.upgrade_link').on('click', function(e){ e.preventDefault(); _this.ExecScript('preview', this); });
    if(_this.hasAdmin){
      xdform.get('.runas .admin_container').style.display = true;
      xdform.get('.runas .admin').element.checked = true;
    }
    else {
      xdform.get('.runas .admin_container').style.display = false;
      xdform.get('.runas .admin').element.checked = false;
    }
    _this.renderRunAs();
  };

  this.RenderModules = function(node){
    var tmpl = jsh.xd('.'+xmodel.class+'_module_listing_template').html;
    return XDom.render.ejs(tmpl, {node: node, _: _, _this: _this});
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
    var xdform = _this.getFormElement();
    var tmpl = xdform.get('.'+xmodel.class+'_module_scripts_listing_template').html;
    return XExt.renderClientEJS(tmpl, {scripts: scripts, moduleName: moduleName, _this: _this});
  };

  this.ExecScript = function(mode, obj){
    var xdform = _this.getFormElement();
    var xdobj = XDom(obj);
    if(mode=='preview'){
      xdform.get('.rslt').text = '';
      xdform.get('.rslt_actions').style.display = false;
    }

    var scriptName = xdobj.data.script;
    var moduleName = xdobj.data.module;

    var starttm = Date.now();

    var params = { scriptName: scriptName, moduleName: moduleName, mode: mode, db: xdform.get('.db').value };
    if(xdform.get('.admin').element.checked){
      params.runas_admin = true;
    }
    else {
      var runas_user = xdform.get('.user').value.trim();
      var runas_password = xdform.get('.password').value;
      if(runas_user){
        params.runas_user = runas_user;
        params.runas_password = runas_password;
      }
    }

    XForm.prototype.XExecutePost('../_funcs/DEV_DB_UPGRADE', { data: JSON.stringify(params) }, function (rslt) { //On success
      if ('_success' in rslt) {
        if(mode=='preview'){
          xdform.get('.rslt').text = moduleName+' :: '+scriptName+'\r\n-------------------------------\r\n'+rslt.src;
          var xdrsltactions = xdform.get('.rslt_actions');
          xdrsltactions.style.display = true;
          _this.curScript = {mode: 'run', obj: obj, name: scriptName};
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
          xdform.get('.rslt').text = txt;
          if(rslt.dbcommands.restart) XExt.Alert('Restarting jsHarmony');
        }
      }
    });
  };

})();