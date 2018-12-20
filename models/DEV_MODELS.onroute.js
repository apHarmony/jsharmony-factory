//(routetype, req, res, callback, require, jsh, modelid, params)
var _ = require('lodash');
var Helper = require('../Helper.js');
var ejsext = require('../lib/ejsext.js');
var model = jsh.getModelClone(req, modelid);

model.oninit = "_this.Models = "+JSON.stringify(_.keys(jsh.Models))+";"+model.oninit;
if(req.query.modelid){
  var modeldata = ejsext.escapeJS(JSON.stringify(jsh.getModel(req, req.query.modelid)||{'MODEL':'NOT FOUND'}));
  modeldata = modeldata.replace(/script/g, 'scr"+"ipt');
  model.oninit = "_this.ModelData = \""+modeldata+"\";"+model.oninit;
}

//Save model to local request cache
req.jshlocal.Models[modelid] = model;
return callback();