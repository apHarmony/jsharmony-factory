jsh.App[modelid] = new (function(){
  var _this = this;

  this.getFormElement = function(){
    return jsh.$root('.xformcontainer.xelem'+xmodel.class);
  };

  this.oninit = function(xmodel) {
    var jform = _this.getFormElement();
    XForm.prototype.XExecute('../_funcs/DEV_DB_DIFF', { }, function (rslt) { //On success
      if ('_success' in rslt) {
        _this.RenderDBListing(rslt.dbs);
      }
    });
    jform.$find('.db').change(function(){
      var db = jform.$find('.db').val();
      if(!db) jform.$find('.run').hide();
      else _this.GetModules(db);
    });
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
    if(dbs.length==1) _this.GetModules(dbs[0]);
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
    var jform = _this.getFormElement();
    jform.$find('.run').show();
    jform.$find('.rslt').text('');

    //--------------------

    var jobj = jform.$find('.listing');
    //Clear any existing content
    jobj.empty();
    //Render modules tree
    jobj.append(_this.RenderModulesNode(modules));
    //Attach events
    jobj.$find('a.generate').click(function(e){
      e.preventDefault();
      var moduleName = $(this).parent().closest('li').data('id');
      var url = window.location.href.split('?')[0];
      XExt.navTo(url + '?' + $.param({ moduleName: moduleName }));
    });
  };

  this.RenderModulesNode = function(node){
    var jlist = $('<ul></ul>');
    for(var i=0;i<node.length;i++){
      var childname = node[i];
      //Generate node
      var jchild = $('<li class="node"></li>');
      jchild.data('id',childname);
      //Link to run script
      var jchildlink = $('<a class="generate"></a>');
      jchildlink.text(childname);
      jchildlink.prop('href','#');
      jchild.append(jchildlink);
      //Add node to list
      jlist.append(jchild);
    }
    if(!jlist.children().length) return $();
    return jlist;
  };

  this.ExecDiff = function(moduleName, mode){
    var jform = _this.getFormElement();
    jform.$find('.rslt').text('');

    var params = { moduleName: moduleName, db: jform.$find('.db').val() };
    var runas_user = jform.$find('.user').val().trim();
    var runas_password = jform.$find('.password').val();
    if(runas_user){
      params.runas_user = runas_user;
      params.runas_password = runas_password;
    }

    XForm.prototype.XExecutePost('../_funcs/DEV_DB_DIFF', { data: JSON.stringify(params) }, function (rslt) { //On success
      if ('_success' in rslt) {
        jform.$find('.rslt').text(params.moduleName+'\r\n-------------------------------\r\n'+rslt.src);
      }
    });
  };

})();