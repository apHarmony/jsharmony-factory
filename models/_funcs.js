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

function ModuleFunctions(module){

  this.LOG_DOWNLOAD = function (req, res, next) {
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
    var model = jsh.getModel(req, module.namespace + 'LOG');
    
    if (!Helper.hasModelAction(req, model, 'B')) { Helper.GenError(req, res, -11, 'Invalid Model Access'); return; }
    
    if (verb == 'get') {
      var farr = [];
      async.waterfall([
        function (cb) {
          fs.readdir(jsh.Config.logdir, function (err, files) {
            if (err) return cb(err);
            _.each(files, function (file) { farr.push({ src: jsh.Config.logdir + file, dest: file }); });
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

  this.DEV_DB_SCRIPTS = function (req, res, next) {

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
    var model = jsh.getModel(req, module.namespace + 'DEV_DB_SCRIPTS');
    
    if (!Helper.hasModelAction(req, model, 'B')) { Helper.GenError(req, res, -11, 'Invalid Model Access'); return; }

    var dbscripter = 1;
    
    if (verb == 'get') {
      if (!appsrv.ParamCheck('Q', Q, ['|db'])) { Helper.GenError(req, res, -4, 'Invalid Parameters'); return; }
      var dbid = Q.db;

      if(dbid){
        if(!(dbid in jsh.DB)) { Helper.GenError(req, res, -4, 'Invalid Databse ID'); return; }
        var sqlext = jsh.DB[dbid].getSQLExt();
        res.end(JSON.stringify({ _success: 1, scripts: clearScripts(sqlext.Scripts) }));
      }
      else {
        var dbs = [];
        for(var dbid in jsh.DB) dbs.push(dbid);
        res.end(JSON.stringify({ _success: 1, dbs: dbs }));
      }
      
      return;
    }
    else if (verb == 'post') {
      if (!appsrv.ParamCheck('Q', Q, [])) { Helper.GenError(req, res, -4, 'Invalid Parameters'); return; }
      if (!appsrv.ParamCheck('P', P, ['&scriptid','&mode','&db','|runas_user','|runas_password'])) { return Helper.GenError(req, res, -4, 'Invalid Parameters'); }

      var scriptid = P.scriptid;
      if(!_.isArray(scriptid)) { Helper.GenError(req, res, -4, 'Invalid Parameters'); return; }
      for(var i=0;i<scriptid.length;i++){ if(!_.isString(scriptid[i])) { Helper.GenError(req, res, -4, 'Invalid Parameters'); return; } }

      var mode = P.mode;
      if(!_.includes(['run','read'],mode)) { Helper.GenError(req, res, -4, 'Invalid Parameters'); return; }

      var dbid = P.db;
      if(!(dbid in jsh.DB)) { Helper.GenError(req, res, -4, 'Invalid Database ID'); return; }
      var db = jsh.DB[dbid];

      //Run as user, if applicable
      var dbconfig = jsh.DBConfig[dbid];
      if(P.runas_user){
        dbconfig = _.extend({}, dbconfig);
        dbconfig.user = P.runas_user;
        dbconfig.password = P.runas_password;
      }
      var sqlFuncs  = [];
      sqlFuncs['DB'] = dbconfig.database;
      sqlFuncs['DB_LCASE'] = dbconfig.database.toLowerCase();

      if(mode=='run'){
        db.RunScripts(jsh, scriptid, { dbconfig: dbconfig, sqlFuncs: sqlFuncs }, function(err, rslt, stats){
          if(err){ err.sql = 'scriptid:'+scriptid; return jsh.AppSrv.AppDBError(req, res, err, stats); }
          res.end(JSON.stringify({ _success: 1, _stats: Helper.FormatStats(req, stats, { notices: true, show_all_messages: true }), dbrslt: rslt }));
          return;
        });
      }
      else if(mode=='read'){
        var sqlsrc = '';
        db.RunScripts(jsh, scriptid, { dbconfig: dbconfig, sqlFuncs: sqlFuncs, onSQL: function(dbscript_name, bi, sql){
          sqlsrc += sql + "\r\n";
          return false;
        } }, function(err, rslt){
          if(err){ err.sql = 'scriptid:'+scriptid; return jsh.AppSrv.AppDBError(req, res, err); }
          res.end(JSON.stringify({ _success: 1, src: sqlsrc }));
          return;
        });
      }

      return;
    }
    return next();
  }

  this.DEV_DB_SCHEMA = function (req, res, next) {

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
    var model = jsh.getModel(req, module.namespace + 'DEV_DB_SCHEMA');
    
    if (!Helper.hasModelAction(req, model, 'B')) { Helper.GenError(req, res, -11, 'Invalid Model Access'); return; }

    if (verb == 'get') {
      if (!appsrv.ParamCheck('Q', Q, ['|db'])) { Helper.GenError(req, res, -4, 'Invalid Parameters'); return; }
      var dbid = Q.db;

      if(dbid){
        if(!(dbid in jsh.DB)) { Helper.GenError(req, res, -4, 'Invalid Databse ID'); return; }
        var schema = jsh.DB[dbid].schema_definition;
        res.end(JSON.stringify({ _success: 1, schema: schema }));
      }
      else {
        var dbs = [];
        for(var dbid in jsh.DB) dbs.push(dbid);
        res.end(JSON.stringify({ _success: 1, dbs: dbs }));
      }
      
      return;
    }

    return next();
  }

  this.DEV_MODELS = function (req, res, next) {

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
    var model = jsh.getModel(req, module.namespace + 'DEV_MODELS');
    
    if (!Helper.hasModelAction(req, model, 'B')) { Helper.GenError(req, res, -11, 'Invalid Model Access'); return; }

    if (verb == 'get') {
      if (!appsrv.ParamCheck('Q', Q, ['&action'])) { Helper.GenError(req, res, -4, 'Invalid Parameters'); return; }

      var actions = ['namespace_conflicts'];

      if (!_.includes(actions, Q.action)) { Helper.GenError(req, res, -4, 'Invalid Parameters'); return; }

      if(Q.action=='namespace_conflicts'){
        appsrv.ExecRecordset(req._DBContext, "select sm_cmd,sm_name from jsharmony.sm order by sm_cmd", [], {}, function(err, rslt){
          var menumodels = {};
          if(rslt && rslt[0]){
            _.each(rslt[0], function(row){
              menumodels[row.sm_cmd] = row.sm_name;
            });
          }
          var fullmodelids = _.keys(jsh.Models);
          var basenames = {};
          _.each(fullmodelids, function(fullmodelid){
            var basename = jsh.getBaseModelName(fullmodelid);
            if(!(basename in basenames)) basenames[basename] = [];
            basenames[basename].push(fullmodelid);
          });
          var conflicts = {};
          var sortedbasenames = _.keys(basenames);
          sortedbasenames.sort();
          for(var i=0;i<sortedbasenames.length;i++){
            var basename = sortedbasenames[i];
            if(basenames[basename].length > 1){
              conflicts[basename] = {};
              _.each(basenames[basename], function(fullmodelid){
                var model = jsh.getModel(null, fullmodelid);
                var namespace = model.namespace;
                conflicts[basename][fullmodelid] = [];
                _.each(model._referencedby, function(fullreferencemodelid){
                  if(jsh.getNamespace(fullreferencemodelid) != namespace){
                    fullreferencemodelid = '[RED]'+fullreferencemodelid+'[/RED]';
                  }
                  conflicts[basename][fullmodelid].push(fullreferencemodelid);
                });
                if(fullmodelid in menumodels) conflicts[basename][fullmodelid].push('[RED]Menu: '+menumodels[fullmodelid]+'[/RED]');
              });
            }
          }
          res.end(JSON.stringify({ _success: 1, conflicts: conflicts }));
        });
      }
      
      return;
    }

    return next();
  }
}

exports = module.exports = ModuleFunctions;
