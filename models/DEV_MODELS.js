jsh.App.DEV_MODELS = { }

jsh.App.DEV_MODELS.Models = {};  //Populated onroute
jsh.App.DEV_MODELS.ModelData = "{}";  //Populated onroute

jsh.App.DEV_MODELS.oninit = function(xmodel) {
  var _this = this;
  _this.Models = _this.Models.sort(function(a, b){
    if(a.toUpperCase() > b.toUpperCase()) return 1;
    else if(a.toUpperCase() < b.toUpperCase()) return -1;
  });
  _this.RenderModelListing();
  jsh.$root('.DEV_MODELS_modelid').change(function(){
    var modelid = jsh.$root('.DEV_MODELS_modelid').val();
    if(!modelid) return XExt.Alert('Please select a Model ID');
    var url = window.location.href.split('?')[0];
    XExt.navTo(url + '?' + $.param({ modelid: modelid }));
  });
}

jsh.App.DEV_MODELS.RenderModelListing = function(dbs){
  var _this = this;
  var jobj = jsh.$root('.DEV_MODELS_modelid');
  jobj.append($('<option>',{value:''}).text('Please select...'));
  for(var i=0;i<_this.Models.length;i++){
    var modelid = _this.Models[i];
    jobj.append($('<option>',{value:modelid}).text(modelid));
  }
  if(_GET['modelid']){
    jobj.val(_GET['modelid']);
    var modeldata = JSON.parse(_this.ModelData);
    jsh.$root('.DEV_MODELS_rslt').text(JSON.stringify(modeldata,null,4));
  }
}