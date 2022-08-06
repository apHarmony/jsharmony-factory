jsh.App[modelid] = new (function(){
  var _this = this;

  //Member variables
  this.files = [];
  this.LOVs = { };

  this.onload = function(){
    this.initModel();
  };

  //Create model, draw controls
  this.initModel = function(){
    if('LogFiles' in jsh.XModels) return; //Grid already loaded

    //Define the grid in-memory
    XPage.LoadVirtualModel($('.'+xmodel.class+'_grid_container')[0], {
      'id': 'LogFiles',
      'layout': 'grid',
      'title': 'Log Files',
      'parent': xmodel.id,
      'unbound': true,
      'actions': 'B',
      'buttons': [
        {'link': "js:jsh.getFileProxy().prop('src', '/_funcs/LOG_DOWNLOAD');", 'icon': 'download', 'actions':'BIU', 'text':'Download All'},
      ],
      'sort': ['vmtime'],
      'hide_system_buttons': ['export'],
      'js': function(){ //This function is virtual and cannot reference any variables outside its scope
        var _this = this;
        //var modelid = [current model id];
        //var xmodel = [current model];
        var apiGrid = new jsh.XAPI.Grid.Static(modelid);
        var apiForm = new jsh.XAPI.Form.Static(modelid);

        _this.showLog = function(obj){
          var filename = xmodel.get('filename', obj);
          XExt.navTo(jsh._BASEURL+xmodel.module_namespace+'Admin/Log?action=browse&filename='+encodeURIComponent(filename));
        };

        _this.oninit = function(xmodel){
          //Custom oninit function
        };

        _this.onload = function(xmodel){
          //Custom onload function
        };

        _this.getapi = function(xmodel, apitype){
          if(apitype=='grid') return apiGrid;
          else if(apitype=='form') return apiForm;
        };

        _this.showTestMessage = function(){
          XExt.Alert('Test Message');
        };
      },
      'oninit':'_this.oninit(xmodel);',
      'onload':'_this.onload(xmodel);',
      'getapi':'return _this.getapi(xmodel, apitype);',
      'fields': [
        {'name': 'filename', 'caption':'File', 'type': 'varchar', 'length': -1, 'actions':'B', 'control':'label', 'key': true, 'link': '#', 'link_onclick': '_this.showLog(this); return false;' },
        {'name': 'mtime', 'caption':'Modified', 'type': 'float', 'actions':'B', 'control':'label', 'format': "date:'MM/DD/YYYY h:mm:ss A'" },
      ]
    }, function(newModel){
      //Model loaded
      //Connect model dataset with local dataset
      jsh.XModels['LogFiles'].getapi('grid').dataset = _this.files;
      jsh.XModels['LogFiles'].getapi('form').dataset = _this.files;
      jsh.XModels['LogFiles'].module_namespace = xmodel.module_namespace;
      //Get data from API
      _this.api_getLogs();
    });
  };

  //Render Grid
  this.renderFiles = function(){
    jsh.XModels['LogFiles'].controller.Render();
  };


  /////////
  // API //
  /////////

  //Get log from the API
  this.api_getLogs = function(onComplete){
    XForm.prototype.XExecute('../_funcs/LOG', { }, function (rslt) { //On Success
      if ('_success' in rslt) {
        _this.files.splice(0);
        for(var i=0;i<rslt.files.length;i++) _this.files.push({
          filename: rslt.files[i].filename,
          mtime: rslt.files[i].mtime,
        });
        _this.renderFiles();
        if (onComplete) onComplete();
      }
      else XExt.Alert('Error while loading data');
    }, function (err) {
      //Additional error handling
    });
  };

})();