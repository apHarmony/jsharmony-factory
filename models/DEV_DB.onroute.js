//(routetype, req, res, callback, require, jsh, modelid, params)
var _ = require('lodash');
var Helper = require('../Helper.js');
var model = jsh.getModelClone(req, modelid);
model.oninit = "window.DEV_DB_type = '"+jsh.AppSrv.db.name+"';"+model.oninit;
//Save model to local request cache
req.jshlocal.Models[modelid] = model;
return callback();