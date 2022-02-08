//(routetype, req, res, callback, require, jsh, modelid, params)
var _ = require('lodash');
var ejsext = require('../lib/ejsext.js');
var model = jsh.getModelClone(req, modelid);

model.oninit = '_this.Models = '+JSON.stringify(['System Config','SQLExt'].concat(_.keys(jsh.Models)))+';'+model.oninit;
if(req.query.modelid){
  var modeldata = {};
  if(req.query.modelid=='System Config'){
    modeldata = jsh.Config;
  }
  else if(req.query.modelid=='SQLExt'){
    modeldata = jsh.DB['default'].SQLExt;
  }
  else{
    modeldata = jsh.getModel(req, req.query.modelid);
  }
  modeldata = ejsext.escapeJS(JSON.stringify(modeldata||{'MODEL':'NOT FOUND'}));
  modeldata = modeldata.replace(/script/g, 'scr"+"ipt');
  model.oninit = '_this.ModelData = "'+modeldata+'";'+model.oninit;
}

//Save model to local request cache
req.jshlocal.Models[modelid] = model;
return callback();