//(routetype, req, res, callback, require, jsh, modelid, params)
var _ = require('lodash');
var Helper = require('../Helper.js');
var model = jsh.getModelClone(req, modelid);
var dbs = {};
for(var dbid in jsh.DB) dbs[dbid] = jsh.DB[dbid].dbconfig._driver.name;
model.oninit = "jsh.App[modelid].DBs = "+JSON.stringify(dbs)+";"+model.oninit;
//Save model to local request cache
req.jshlocal.Models[modelid] = model;
return callback();