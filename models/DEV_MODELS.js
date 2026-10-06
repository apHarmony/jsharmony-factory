jsh.App[modelid] = new (function(){
  var _this = this;

  this.Models = {};  //Populated onroute
  this.ModelData = '{}';  //Populated onroute

  this.panelViewer = null;
  this.panelNSConflicts = null;
  this.panelUtilities = null;

  this.getFormElement = function(){
    return jsh.xd('.xformcontainer.xelem'+xmodel.class);
  };

  this.oninit = function(xmodel) {
    var xdform = _this.getFormElement();
    this.panelViewer = xdform.get('.viewer');
    this.panelNSConflicts = xdform.get('.namespace_conflicts');
    this.panelUtilities = xdform.get('.utilities');

    _this.Models = _this.Models.sort(function(a, b){
      if(a.toUpperCase() > b.toUpperCase()) return 1;
      else if(a.toUpperCase() < b.toUpperCase()) return -1;
    });

    _this.RenderModelListing();
    _this.panelViewer.get('.modelid').on('change', function(){
      var modelid = _this.panelViewer.get('.modelid').value;
      if(!modelid) return XExt.Alert('Please select a Model ID');
      var url = window.location.href.split('?')[0];
      XExt.navTo(url + '?' + XExt.escapeQuery({ modelid: modelid }));
    });
    _this.panelNSConflicts.get('.run').on('click', function(){
      _this.RenderNamespaceConflicts();
    });
    _this.panelUtilities.get('.auto_controls').on('click', function(){
      _this.RenderAutoControls();
    });
    _this.panelUtilities.get('.model_listing').on('click', function(){
      XExt.navTo('/_listing');
    });
  };
  
  this.RenderModelListing = function(dbs){
    var tmpl = jsh.xd('.'+xmodel.class+'_model_listing_template').html;
    var xdobj = _this.panelViewer.get('.modelid');
    xdobj.append(XDom.render.ejs(tmpl, {Models: _this.Models}));
    if(_GET['modelid']){
      xdobj.value = _GET['modelid'];
      var modeldata = JSON.parse(_this.ModelData);
      _this.panelViewer.get('.rslt').text = JSON.stringify(modeldata,null,4);
    }
  };

  this.RenderNamespaceConflicts = function(){
    XForm.prototype.XExecute('../_funcs/DEV_MODELS', { action: 'namespace_conflicts' }, function (rslt) { //On success
      if ('_success' in rslt) {
        var overview = 'SYNTAX:\n\
{\n\
    "BASEMODELNAME": [\n\
        "MODELID": [\n\
            "REFERENCED_BY"\n\
        ]\n\
    ]\n\
}\n\n';
        var rslt_content = overview +  JSON.stringify(rslt.conflicts,null,4);
        rslt_content = XExt.ReplaceAll(rslt_content, '[RED]', '<span style="color:red;font-weight:bold;">');
        rslt_content = XExt.ReplaceAll(rslt_content, '[/RED]', '</span>');
        _this.panelNSConflicts.get('.rslt').html = rslt_content;
      }
    });
  };

  this.RenderAutoControls = function(){
    XForm.prototype.XExecute('../_funcs/DEV_MODELS', { action: 'auto_controls' }, function (rslt) { //On success
      if ('_success' in rslt) {
        var rslt_content = JSON.stringify(rslt.content,null,4);
        _this.panelUtilities.get('.rslt').html = rslt_content;
      }
    });
  };

})();


