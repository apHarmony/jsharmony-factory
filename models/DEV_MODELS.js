jsh.App[modelid] = new (function(){
  var _this = this;

  this.Models = {};  //Populated onroute
  this.ModelData = '{}';  //Populated onroute

  this.panelViewer = null;
  this.panelNSConflicts = null;
  this.panelUtilities = null;

  this.getFormElement = function(){
    return jsh.$root('.xformcontainer.xelem'+xmodel.class);
  };

  this.oninit = function(xmodel) {
    var jform = _this.getFormElement();
    this.panelViewer = jform.$find('.viewer');
    this.panelNSConflicts = jform.$find('.namespace_conflicts');
    this.panelUtilities = jform.$find('.utilities');

    _this.Models = _this.Models.sort(function(a, b){
      if(a.toUpperCase() > b.toUpperCase()) return 1;
      else if(a.toUpperCase() < b.toUpperCase()) return -1;
    });

    _this.RenderModelListing();
    _this.panelViewer.$find('.modelid').change(function(){
      var modelid = _this.panelViewer.$find('.modelid').val();
      if(!modelid) return XExt.Alert('Please select a Model ID');
      var url = window.location.href.split('?')[0];
      XExt.navTo(url + '?' + $.param({ modelid: modelid }));
    });
    _this.panelNSConflicts.$find('.run').click(function(){
      _this.RenderNamespaceConflicts();
    });
    _this.panelUtilities.$find('.auto_controls').click(function(){
      _this.RenderAutoControls();
    });
    _this.panelUtilities.$find('.model_listing').click(function(){
      XExt.navTo('/_listing');
    });
  };
  
  this.RenderModelListing = function(dbs){
    var jobj = _this.panelViewer.$find('.modelid');
    jobj.append($('<option>',{value:''}).text('Please select...'));
    for(var i=0;i<_this.Models.length;i++){
      var modelid = _this.Models[i];
      jobj.append($('<option>',{value:modelid}).text(modelid));
    }
    if(_GET['modelid']){
      jobj.val(_GET['modelid']);
      var modeldata = JSON.parse(_this.ModelData);
      _this.panelViewer.$find('.rslt').text(JSON.stringify(modeldata,null,4));
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
        _this.panelNSConflicts.$find('.rslt').html(rslt_content);
      }
    });
  };

  this.RenderAutoControls = function(){
    XForm.prototype.XExecute('../_funcs/DEV_MODELS', { action: 'auto_controls' }, function (rslt) { //On success
      if ('_success' in rslt) {
        var rslt_content = JSON.stringify(rslt.content,null,4);
        _this.panelUtilities.$find('.rslt').html(rslt_content);
      }
    });
  };

})();


