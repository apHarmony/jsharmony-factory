jsh.App[modelid] = new (function(){
  var _this = this;

  this.getFormElement = function(){
    return jsh.xd('.xformcontainer.xelem'+xmodel.class);
  };

  this.oninit = function(xmodel) {
    var xdform = _this.getFormElement();
    XForm.prototype.XExecute('../_funcs/DEV_DB_DIFF', { }, function (rslt) { //On success
      if ('_success' in rslt) {
        _this.RenderDBListing(rslt.dbs);
      }
    });
    xdform.get('.db').on('change', function(){
      var db = xdform.get('.db').value;
      var url = window.location.href.split('?')[0];
      XExt.navTo(url + '?' + XExt.escapeQuery({ db: db }));
    });
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
    if(dbs.length==1) _this.GetModules(dbs[0]);
    else if(jsh._GET['db']){
      xdobj.value = jsh._GET['db'];
      _this.GetModules(jsh._GET['db']);
    }
  };

  this.GetModules = function(dbid){
    XForm.prototype.XExecute('../_funcs/DEV_DB_DIFF', { db: dbid }, function (rslt) { //On success
      if ('_success' in rslt) {
        _this.RenderModules(rslt.modules);
        if(jsh._GET['moduleName']) _this.ExecDiff(jsh._GET['moduleName']);
      }
    });
  };

  this.RenderModules = function(modules){
    var xdform = _this.getFormElement();
    xdform.get('.run').style.display = true;
    xdform.get('.rslt').text = '';

    //--------------------

    var xdobj = xdform.get('.listing');
    //Clear any existing content
    xdobj.clear();
    //Render modules tree
    xdobj.append(_this.RenderModulesNode(modules));
    //Attach events
    xdobj.get('a.generate').on('click', function(e){
      e.preventDefault();
      var moduleName = XDom(this).parent().parent('li').data.id;
      var url = window.location.href.split('?')[0];
      XExt.navTo(url + '?' + XExt.escapeQuery({ db: xdform.get('.db').value, moduleName: moduleName }));
    });
  };

  this.RenderModulesNode = function(node){
    if(!node || !node.length) return '';
    var tmpl = jsh.xd('.'+xmodel.class+'_module_listing_template').html;
    return XDom.render.ejs(tmpl, {node: node});
  };

  this.ExecDiff = function(moduleName, mode){
    var xdform = _this.getFormElement();
    xdform.get('.rslt').text = '';

    var params = { moduleName: moduleName, db: xdform.get('.db').value };
    var runas_user = xdform.get('.user').value.trim();
    var runas_password = xdform.get('.password').value;
    if(runas_user){
      params.runas_user = runas_user;
      params.runas_password = runas_password;
    }

    XForm.prototype.XExecutePost('../_funcs/DEV_DB_DIFF', { data: JSON.stringify(params) }, function (rslt) { //On success
      if ('_success' in rslt) {
        xdform.get('.rslt').text = params.moduleName+'\r\n-------------------------------\r\n'+rslt.src;
      }
    });
  };

})();