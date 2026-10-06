jsh.App[modelid] = new (function(){
  var _this = this;

  this.dbmenuId = 0;
  this.curScript = null;

  this.getFormElement = function(){
    return jsh.xd('.xformcontainer.xelem'+xmodel.class);
  };

  this.oninit = function(xmodel) {
    var xdform = _this.getFormElement();
    XForm.prototype.XExecute('../_funcs/DEV_DB_OBJECTS', { }, function (rslt) { //On success
      if ('_success' in rslt) {
        _this.RenderDBListing(rslt.dbs);
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
    if(dbs.length==1) _this.GetObjects(dbs[0]);
    else if(jsh._GET['db']){
      xdobj.value = jsh._GET['db'];
      _this.GetObjects(jsh._GET['db']);
    }
  };

  this.GetObjects = function(dbid){
    XForm.prototype.XExecute('../_funcs/DEV_DB_OBJECTS', { db: dbid }, function (rslt) { //On success
      if ('_success' in rslt) {
        _this.RenderObjects(rslt.objects, rslt.hasAdmin);
      }
    });
  };

  this.RenderObjects = function(objects, hasAdmin){
    var xdform = _this.getFormElement();
    xdform.get('.run').style.display = true;
    xdform.get('.restart_link').style.display = true;
    xdform.get('.rslt').text = '';
    xdform.get('.rslt_actions').style.display = false;

    var xdobj = xdform.get('.listing');
    //Clear any existing content
    xdobj.clear();
    //Render objects
    xdobj.append(_this.RenderModules(objects));
    //Attach events
    xdobj.get('a.dbmenu_link').on('click', function(e){ e.preventDefault(); var id = XDom(this).data.id; var xdDBitem = xdform.get('.dbmenu[data-id="'+id+'"]'); xdDBitem.style.display = !xdDBitem.isVisible(); });
    _.each(['view','drop','init','init_data','restructure','sample_data','recreate','recreate_sample'], function(scriptName){
      xdobj.get('a.dbmenu_'+scriptName).on('click', function(e){ e.preventDefault(); _this.ExecScript('preview', this, scriptName); });
    });
    if(hasAdmin){
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
    var xdform = _this.getFormElement();
    var tmpl = xdform.get('.'+xmodel.class+'_module_listing_template').html;
    return XDom.render.ejs(tmpl, {node: node, _this: _this});
  };

  this.RenderModuleObjects = function(moduleName, dbobjects){
    var xdform = _this.getFormElement();
    var tmpl = xdform.get('.'+xmodel.class+'_module_objects_listing_template').html;
    var dbid = xdform.get('.db').value;
    var objectTypes = {};
    _.each(dbobjects, function(dbobject){
      if(!dbobject) return;
      var objectType = dbobject.type || 'other';
      if(!(objectType in objectTypes)) objectTypes[objectType] = [];
      objectTypes[objectType].push(dbobject);
    });
    var actions = {
      'view': 'View',
      'drop': 'Drop',
      'init': 'Init',
      'init_data': 'Init Data',
      'restructure': 'Restructure',
      'sample_data': 'Sample Data',
      'recreate': 'Recreate',
      'recreate_sample': 'Recreate w/Sample Data',
    };
    return XExt.renderClientEJS(tmpl, {moduleName: moduleName, objectTypes: objectTypes, dbid: dbid, _this: _this, actions: actions});
  };

  this.ExecScript = function(mode, obj, scriptName){
    var xdform = _this.getFormElement();
    var xdobj = XDom(obj);
    if(mode=='preview'){
      xdform.get('.rslt').text = '';
      xdform.get('.rslt_actions').style.display = false;
    }
    var xdDbMenu = xdobj.parent('.dbmenu');
    var objectName = xdDbMenu.data.name;
    var moduleName = xdDbMenu.data.module;

    var starttm = Date.now();

    var params = { scriptName: scriptName, objectName: objectName, moduleName: moduleName, mode: mode, db: xdform.get('.db').value };
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

    XForm.prototype.XExecutePost('../_funcs/DEV_DB_OBJECTS', { data: JSON.stringify(params) }, function (rslt) { //On success
      if ('_success' in rslt) {
        if(mode=='preview'){
          xdform.get('.rslt').text = objectName+' :: '+scriptName+'\r\n-------------------------------\r\n'+rslt.src;
          if(_.includes(['drop','init','init_data','restructure','sample_data','recreate','recreate_sample'], scriptName)){
            var xdrsltactions = xdform.get('.rslt_actions');
            xdrsltactions.style.display = true;
            _this.curScript = {mode: 'run', obj: obj, name: scriptName};
          }
        }
        else{
          var txt = objectName+' :: '+scriptName+'\r\n-------------------------------\r\n';
          if(rslt._stats){
            _.each(rslt._stats, function(stats){
              _.each(stats.warnings, function(warning){ txt += 'WARNING: '+warning+'\r\n'; });
              _.each(stats.notices, function(notice){ txt += 'NOTICE: '+notice+'\r\n'; });
            });
          }
          var rsltIdx = 0;
          if(rslt.dbrslt) for(var i=0;j<rslt.dbrslt.length;i++){
            if(rslt.dbrslt[i]) for(var j=0;j<rslt.dbrslt[i].length;j++){
              rsltIdx++;
              txt += 'Resultset ' + (rsltIdx).toString() + '\r\n' + '------------------------------------\r\n';
              txt += JSON.stringify(rslt.dbrslt[i][j],null,4) + '\r\n\r\n';
            }
          }
          txt += '\r\nOperation complete';
          var endtm = Date.now();
          txt += '\r\nTime: ' + (endtm-starttm) + 'ms';
          xdform.get('.rslt').text = txt;
        }
      }
    });
  };

})();