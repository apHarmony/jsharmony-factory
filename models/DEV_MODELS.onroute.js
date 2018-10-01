//(routetype, req, res, callback, require, jsh, modelid, params)
var _ = require('lodash');
var Helper = require('../Helper.js');
var ejsext = require('../lib/ejsext.js');
var model = jsh.getModelClone(req, modelid);
var modelstxt = ejsext.escapeJS(JSON.stringify(jsh.Models));
modelstxt = modelstxt.replace(/script/g, 'scr"+"ipt');
model.oninit = "jsh.App.DEV_MODELS.Models = \""+modelstxt+"\";"+model.oninit;
//Save model to local request cache
req.jshlocal.Models[modelid] = model;
return callback();