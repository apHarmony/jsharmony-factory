jsh.App[modelid] = new (function(){
  var _this = this;

  this.getFormElement = function(){
    return jsh.$root('.xformcontainer.xelem'+xmodel.class);
  };

  this.oninit = function(xmodel) {
    var jform = _this.getFormElement();
    XForm.prototype.XExecute('../_funcs/DEV_DB_SCRIPTS', { }, function (rslt) { //On success
      if ('_success' in rslt) {
        _this.RenderDBListing(rslt.dbs);
      }
    });
    jform.$find('.db').change(function(){
      var db = jform.$find('.db').val();
      if(!db){
        jform.$find('.run').hide();
        jform.$find('.restart_link').hide();
      }
      else _this.GetScripts(db);
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
  };

  this.GetScripts = function(dbid){
    XForm.prototype.XExecute('../_funcs/DEV_DB_SCRIPTS', { db: dbid }, function (rslt) { //On success
      if ('_success' in rslt) {
        _this.RenderScripts(rslt.scripts, rslt.hasAdmin);
      }
    });
  };

  this.RenderScripts = function(scripts, hasAdmin){
    var jform = _this.getFormElement();
    jform.$find('.run').show();
    jform.$find('.restart_link').show();
    jform.$find('.rslt').text('');

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

    var jobj = jform.$find('.listing');
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
    allscripts = { '(All)': allscripts };
    jobj.children('ul').prepend(_this.RenderScriptsNode(allscripts).children());
    //Attach events
    jobj.$find('a.run').click(function(e){ e.preventDefault(); _this.ExecScript(this, 'run'); });
    jobj.$find('a.info').click(function(e){ e.preventDefault(); _this.ExecScript(this, 'read'); });
    if(hasAdmin){
      jform.$find('.runas .admin_container').show();
      jform.$find('.runas .admin').prop('checked', true);
    }
    else {
      jform.$find('.runas .admin_container').hide();
      jform.$find('.runas .admin').prop('checked', false);
    }
    _this.renderRunAs();
  };

  this.RenderScriptsNode = function(node){
    var jlist = $('<ul></ul>');
    for(var childname in node){
      if(_.isString(node[childname])) continue;
      var jchild = $('<li class="node"></li>');
      jchild.data('id',(childname=='(All)'?'*':childname));
      //Link to run script
      var jchildlink = $('<a class="run"></a>');
      jchildlink.text(childname);
      jchildlink.prop('href','#');
      jchild.append(jchildlink);
      //Link to read script
      var jchildinfolink = $('<a class="info"></a>');
      jchildinfolink.html('<img src="<%=jsh._PUBLICURL%>images/icon_search.png" width="12" style="padding-left:8px;position:relative;top:2px;" />');
      jchildinfolink.prop('href','#');
      jchild.append(jchildinfolink);
      //Children
      var childlist = _this.RenderScriptsNode(node[childname]);
      if(childlist.length) jchild.append(childlist);
      jlist.append(jchild);
    }
    if(!jlist.children().length) return $();
    return jlist;
  };

  this.ExecScript = function(obj, mode){
    var jform = _this.getFormElement();
    var jobj = $(obj);
    jform.$find('.rslt').text('');

    var starttm = Date.now();

    var scriptid = [];
    var parent = jobj.parent().closest('li');
    while(parent.hasClass('node')){
      scriptid.unshift(parent.data('id'));
      parent = parent.parent().closest('li');
    }

    var params = { scriptid: scriptid, mode: mode, db: jform.$find('.db').val() };
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

    XExt.execif((mode=='run'), function(f){
      XExt.Confirm('Are you sure you want to run '+scriptid.join('::')+'?', f);
    }, function(){
      XForm.prototype.XExecutePost('../_funcs/DEV_DB_SCRIPTS', { data: JSON.stringify(params) }, function (rslt) { //On success
        if ('_success' in rslt) {
          if(mode=='read'){
            jform.$find('.rslt').text(params.scriptid+'\r\n-------------------------------\r\n'+rslt.src);
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
            jform.$find('.rslt').text(txt);
            if(rslt.dbcommands.restart) XExt.Alert('Restarting jsHarmony');
          }
        }
      });
    });
  };

})();