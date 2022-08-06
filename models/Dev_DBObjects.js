jsh.App[modelid] = new (function(){
  var _this = this;

  this.dbmenuId = 0;

  this.getFormElement = function(){
    return jsh.$root('.xformcontainer.xelem'+xmodel.class);
  };

  this.oninit = function(xmodel) {
    var jform = _this.getFormElement();
    XForm.prototype.XExecute('../_funcs/DEV_DB_OBJECTS', { }, function (rslt) { //On success
      if ('_success' in rslt) {
        _this.RenderDBListing(rslt.dbs);
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
    if(dbs.length==1) _this.GetObjects(dbs[0]);
    else if(jsh._GET['db']){
      jobj.val(jsh._GET['db']);
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
    var jform = _this.getFormElement();
    jform.$find('.run').show();
    jform.$find('.restart_link').show();
    jform.$find('.rslt').text('');
    jform.$find('.rslt_actions').hide();

    var jobj = jform.$find('.listing');
    //Clear any existing content
    jobj.empty();
    //Render objects
    jobj.append(_this.RenderModules(objects));
    //Attach events
    jobj.$find('a.dbmenu_link').click(function(e){ e.preventDefault(); var id = $(this).data('id'); jform.$find('.dbmenu[data-id='+id+']').toggle(); });
    _.each(['view','drop','init','init_data','restructure','sample_data','recreate','recreate_sample'], function(scriptName){
      jobj.$find('a.dbmenu_'+scriptName).click(function(e){ e.preventDefault(); _this.ExecScript('preview', this, scriptName); });
    });
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

  this.RenderModules = function(node){
    var jlist = $('<ul></ul>');
    for(var moduleName in node){
      if(!node[moduleName] || !node[moduleName].length) continue;
      var jchild = $('<li class="node"></li>');
      jchild.data('id',moduleName);
      jchild.append('<span>'+XExt.escapeHTML(moduleName)+'</span>');
      //Children
      var childlist = _this.RenderModuleObjects(moduleName, node[moduleName]);
      if(childlist.length) jchild.append(childlist);
      jlist.append(jchild);
    }
    if(!jlist.children().length) return $();
    return jlist;
  };

  this.RenderModuleObjects = function(moduleName, dbobjects){
    var jform = _this.getFormElement();
    var dbid = jform.$find('.db').val();
    var jlist = $('<ul></ul>');
    var objectTypes = {};
    _.each(dbobjects, function(dbobject){
      if(!dbobject) return;
      var objectType = dbobject.type || 'other';
      if(!(objectType in objectTypes)) objectTypes[objectType] = [];
      objectTypes[objectType].push(dbobject);
    });
    for(var objectType in objectTypes){
      var jtype = $('<li class="node"></li>');
      jtype.data('id',objectType);
      jtype.append('<span>'+XExt.escapeHTML(objectType)+'</span>');

      var jtypelist = $('<ul></ul>');
      _.each(objectTypes[objectType], function(dbobject){
        ++_this.dbmenuId;
        var jobject = $('<li class="node"></li>');
        jobject.data('id',dbobject.name);
        jobject.append('<a href="#" class="dbmenu_link" data-id="'+_this.dbmenuId+'">'+XExt.escapeHTML(dbobject.name)+'</a>');
        var dbmenu_html = '<div class="dbmenu" data-id="'+_this.dbmenuId+'" data-name="' + XExt.escapeHTML(dbobject.name) + '" data-module="' + XExt.escapeHTML(moduleName) + '">';
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
        for(var actionName in actions){
          dbmenu_html += '<a href="#" class="dbmenu_'+XExt.escapeHTML(actionName)+'">'+XExt.escapeHTML(actions[actionName])+'</a>';
        }
        dbmenu_html += '<a href="<%=jsh._BASEURL%><%=model.module_namespace%>Dev/DBSQL?db='+XExt.escapeHTML(dbid)+'&table='+XExt.escapeHTML(dbobject.name)+'" target="_blank" class="dbmenu_select">Select</a>';
        dbmenu_html += '</div>';
        jobject.append(dbmenu_html);
        jtypelist.append(jobject);
      });
      jtype.append(jtypelist);

      jlist.append(jtype);
    }
    if(!jlist.children().length) return $();
    return jlist;
  };

  this.ExecScript = function(mode, obj, scriptName){
    var jform = _this.getFormElement();
    var jobj = $(obj);
    if(mode=='preview'){
      jform.$find('.rslt').text('');
      jform.$find('.rslt_actions').hide();
    }

    var objectName = jobj.closest('.dbmenu').data('name');
    var moduleName = jobj.closest('.dbmenu').data('module');

    var starttm = Date.now();

    var params = { scriptName: scriptName, objectName: objectName, moduleName: moduleName, mode: mode, db: jform.$find('.db').val() };
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

    XForm.prototype.XExecutePost('../_funcs/DEV_DB_OBJECTS', { data: JSON.stringify(params) }, function (rslt) { //On success
      if ('_success' in rslt) {
        if(mode=='preview'){
          jform.$find('.rslt').text(objectName+' :: '+scriptName+'\r\n-------------------------------\r\n'+rslt.src);
          if(_.includes(['drop','init','init_data','restructure','sample_data','recreate','recreate_sample'], scriptName)){
            jform.$find('.rslt_actions').show();
            jform.$find('.rslt_actions').off('click').on('click', function(){
              _this.ExecScript('run', obj, scriptName);
            });
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
          if(rslt.dbrslt[0]) for(var i=0;i<rslt.dbrslt[0].length;i++){
            txt += 'Resultset ' + (i+1).toString() + '\r\n' + '------------------------------------\r\n';
            txt += JSON.stringify(rslt.dbrslt[0][i],null,4) + '\r\n\r\n';
          }
          txt += '\r\nOperation complete';
          var endtm = Date.now();
          txt += '\r\nTime: ' + (endtm-starttm) + 'ms';
          jform.$find('.rslt').text(txt);
        }
      }
    });
  };

})();