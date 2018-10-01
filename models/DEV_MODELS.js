jsh.App.DEV_MODELS = { }

jsh.App.DEV_MODELS.Models = {};  //Populated onroute

jsh.App.DEV_MODELS.oninit = function(xform) {
  var _this = this;
  var models = JSON.parse(_this.Models);
  jsh.$root('.DEV_MODELS_rslt').text(JSON.stringify(models,null,4));
}
