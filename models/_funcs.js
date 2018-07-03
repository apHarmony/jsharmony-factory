/*
Copyright 2017 apHarmony

This file is part of jsHarmony.

jsHarmony is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

jsHarmony is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this package.  If not, see <http://www.gnu.org/licenses/>.
*/

var Helper = require('jsharmony/Helper');
var HelperFS = require('jsharmony/HelperFS');
var fs = require('fs');
var path = require('path');
var _ = require('lodash');
var async = require('async');
var XValidate = require('jsharmony-validate');
var archiver = require('archiver');
var dczip = require('decompress-zip');
var crypto = require('crypto');
var moment = require('moment');

exports = module.exports = {};

exports.LOG_DOWNLOAD = function (req, res, next) {
  var verb = req.method.toLowerCase();
  if (!req.body) req.body = {};
  
  var Q = req.query;
  var P = {};
  if (req.body && ('data' in req.body)){
    try{ P = JSON.parse(req.body.data); }
    catch(ex){ Helper.GenError(req, res, -4, 'Invalid Parameters'); return; }
  }
  var appsrv = this;
  var jsh = this.jsh;
  var dbtypes = appsrv.DB.types;
  var model = jsh.getModel(req, 'LOG');
  
  if (!Helper.HasModelAccess(req, model, 'B')) { Helper.GenError(req, res, -11, 'Invalid Model Access'); return; }
  
  if (verb == 'get') {
    var farr = [];
    async.waterfall([
      function (cb) {
        fs.readdir(global.logdir, function (err, files) {
          if (err) return cb(err);
          _.each(files, function (file) { farr.push({ src: global.logdir + file, dest: file }); });
          return cb(null);
        });
      },
      function (cb) {
        res.writeHead(200, {
          'Content-Type': 'application/zip',
          'Content-disposition': 'attachment; filename=logs_' + moment().format('YYYYMMDDHHmmss') + '.zip'
        });
        var zip = archiver('zip');
        zip.pipe(res);
        _.each(farr, function (val) { zip.file(val.src, { name: val.dest }); });
        zip.finalize();
      }
    ], function (err, rslt) {
      if (err) {
        if ('number' in err) { return Helper.GenError(req, res, err.number, err.message); }
        return Helper.GenError(req, res, -99999, err.message);
      }
    });
    return;
  }
  return next();
}

exports.DEV_DB_SCRIPTS = function (req, res, next) {

  //Replace scripts with "..." and prune empty scripts
  function clearScripts(node){
    var rslt = {};
    for(var key in node){
      var val = node[key];
      if(_.isString(val)){
        if(val.trim()) rslt[key] = "...";
      }
      else{
        var childScripts = clearScripts(val);
        if(!_.isEmpty(childScripts)) rslt[key] = childScripts;
      }
    }
    return rslt;
  }

  //-------------------------------------------------------

  var verb = req.method.toLowerCase();
  if (!req.body) req.body = {};
  
  var Q = req.query;
  var P = {};
  if (req.body && ('data' in req.body)){
    try{ P = JSON.parse(req.body.data); }
    catch(ex){ Helper.GenError(req, res, -4, 'Invalid Parameters'); return; }
  }
  var appsrv = this;
  var jsh = this.jsh;
  var dbtypes = appsrv.DB.types;
  var model = jsh.getModel(req, 'DEV_DB_SCRIPTS');
  
  if (!Helper.HasModelAccess(req, model, 'B')) { Helper.GenError(req, res, -11, 'Invalid Model Access'); return; }

  var dbscripter = 1;
  
  if (verb == 'get') {
    res.end(JSON.stringify({ _success: 1, scripts: clearScripts(jsh.SQLScripts) }));
    return;
  }
  else if (verb == 'post') {
    if (!appsrv.ParamCheck('Q', Q, [])) { Helper.GenError(req, res, -4, 'Invalid Parameters'); return; }
    if (!appsrv.ParamCheck('P', P, ['&scriptid','|runas_user','|runas_password'])) { return Helper.GenError(req, res, -4, 'Invalid Parameters'); }

    var scriptid = P.scriptid;
    if(!_.isArray(scriptid)) { Helper.GenError(req, res, -4, 'Invalid Parameters'); return; }
    for(var i=0;i<scriptid.length;i++){ if(!_.isString(scriptid[i])) { Helper.GenError(req, res, -4, 'Invalid Parameters'); return; } }

    //Run as user, if applicable
    var constring = global.dbconfig;
    if(P.runas_user){
      constring = _.extend({}, constring);
      constring.user = P.runas_user;
      constring.password = P.runas_password;
    }
    var sqlbase = { SQL: [] };
    sqlbase.SQL['DB'] = global.dbconfig.database;
    sqlbase.SQL['DB_LCASE'] = global.dbconfig.database.toLowerCase();

    appsrv.db.RunScripts(jsh, scriptid, { constring: constring, sqlbase: sqlbase }, function(err, rslt){
      if(err){ err.sql = 'scriptid:'+scriptid; return jsh.AppSrv.AppDBError(req, res, err); }
      res.end(JSON.stringify({ _success: 1, dbrslt: rslt }));
      return;
    });
    return;
  }
  return next();
}