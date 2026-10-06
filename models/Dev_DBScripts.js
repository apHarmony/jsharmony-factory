jsh.App[modelid] = new (function(){
  var _this = this;

  this.getFormElement = function(){
    return jsh.xd('.xformcontainer.xelem'+xmodel.class);
  };

  this.oninit = function(xmodel) {
    var xdform = _this.getFormElement();
    XForm.prototype.XExecute('../_funcs/DEV_DB_SCRIPTS', { }, function (rslt) { //On success
      if ('_success' in rslt) {
        _this.RenderDBListing(rslt.dbs);
      }
    });
    xdform.get('.db').on('change', function(){
      var db = xdform.get('.db').value;
      if(!db){
        xdform.get('.run').style.display = false;
        xdform.get('.restart_link').style.display = false;
      }
      else _this.GetScripts(db);
    });
    xdform.get('.runas .admin').on('change', function(){
      _this.renderRunAs();
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
  };

  this.GetScripts = function(dbid){
    XForm.prototype.XExecute('../_funcs/DEV_DB_SCRIPTS', { db: dbid }, function (rslt) { //On success
      if ('_success' in rslt) {
        _this.RenderScripts(rslt.scripts, rslt.hasAdmin);
      }
    });
  };

  this.RenderScripts = function(scripts, hasAdmin){
    var xdform = _this.getFormElement();
    xdform.get('.run').style.display = true;
    xdform.get('.restart_link').style.display = true;
    xdform.get('.rslt').text = '';

    function union(a,b){
      var rslt = {};
      if((a=='...')||(b=='...')) return '...';
      for(var akey in a){
        if(akey in b) rslt[akey] = union(a[akey],b[akey]);
        else rslt[akey] = a[akey];
      }
      for(var bkey in b){
        if(!(bkey in a)) rslt[bkey] = b[bkey];
      }
      return rslt;
    }

    //--------------------

    var xdobj = xdform.get('.listing');
    //Clear any existing content
    xdobj.clear();
    //Render scripts tree
    xdobj.append(XDom.render(_this.RenderScriptsNode(scripts)));
    //Generate "All" tree
    var allscripts = null;
    for(var module in scripts){
      if(allscripts===null) allscripts = scripts[module];
      else allscripts = union(allscripts, scripts[module]);
    }
    allscripts = { '(All)': allscripts };
    xdobj.getChildren('ul').prepend(XDom(XDom.render(_this.RenderScriptsNode(allscripts))).children);
    //Attach events
    xdobj.get('a.run').on('click', function(e){ e.preventDefault(); _this.ExecScript(this, 'run'); });
    xdobj.get('a.info').on('click', function(e){ e.preventDefault(); _this.ExecScript(this, 'read'); });
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

  this.RenderScriptsNode = function(node){
    var xdform = _this.getFormElement();
    var tmpl = xdform.get('.'+xmodel.class+'_scripts_listing_template').html;
    return XExt.renderClientEJS(tmpl, {node: node, _this: _this, _: _});
  };

  this.ExecScript = function(obj, mode){
    var xdform = _this.getFormElement();
    var xdobj = XDom(obj);
    xdform.get('.rslt').text = '';

    var starttm = Date.now();

    var scriptid = [];
    var xdparent = xdobj.parent().parent('li');
    while(xdparent.class.contains('node')){
      scriptid.unshift(xdparent.data.id);
      xdparent = xdparent.parent().parent('li');
    }

    var params = { scriptid: scriptid, mode: mode, db: xdform.get('.db').value };
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

    XExt.execif((mode=='run'), function(f){
      XExt.Confirm('Are you sure you want to run '+scriptid.join('::')+'?', f);
    }, function(){
      XForm.prototype.XExecutePost('../_funcs/DEV_DB_SCRIPTS', { data: JSON.stringify(params) }, function (rslt) { //On success
        if ('_success' in rslt) {
          if(mode=='read'){
            xdform.get('.rslt').text = params.scriptid+'\r\n-------------------------------\r\n'+rslt.src;
          }
          else{
            var txt = '';
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
            xdform.get('.rslt').text = txt;
            if(rslt.dbcommands.restart) XExt.Alert('Restarting jsHarmony');
          }
        }
      });
    });
  };

})();