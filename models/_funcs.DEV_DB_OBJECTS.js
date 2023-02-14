/*
Copyright 2022 apHarmony

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
var _ = require('lodash');
var async = require('async');

module.exports = exports = function(module, funcs){
  var exports = {};

  exports.DEV_DB_OBJECTS = function (req, res, next) {
    var verb = req.method.toLowerCase();
    if (!req.body) req.body = {};
    
    var Q = req.query;
    var P = {};
    if (req.body && ('data' in req.body)){
      try{ P = JSON.parse(req.body.data); }
      catch(ex){ Helper.GenError(req, res, -4, 'Invalid Parameters'); return; }
    }
    var jsh = module.jsh;
    var appsrv = jsh.AppSrv;
    var model = jsh.getModel(req, module.namespace + funcs._transform('Dev/DBObjects'));
    
    if (!Helper.hasModelAction(req, model, 'B')) { Helper.GenError(req, res, -11, 'Invalid Model Access'); return; }

    if (verb == 'get') {
      if (!appsrv.ParamCheck('Q', Q, ['|db'])) { Helper.GenError(req, res, -4, 'Invalid Parameters'); return; }
      let dbid = Q.db;

      if(dbid){
        if(!(dbid in jsh.DB)) { Helper.GenError(req, res, -4, 'Invalid Databse ID'); return; }
        let sqlext = jsh.DB[dbid].getSQLExt();
        res.end(JSON.stringify({ _success: 1, objects: sqlext.Objects, hasAdmin: !!jsh.DBConfig[dbid].admin_user }));
      }
      else {
        var dbs = [];
        for(var dbid_key in jsh.DB) dbs.push(dbid_key);
        res.end(JSON.stringify({ _success: 1, dbs: dbs }));
      }
      
      return;
    }
    else if (verb == 'post') {
      if (!appsrv.ParamCheck('Q', Q, [])) { Helper.GenError(req, res, -4, 'Invalid Parameters'); return; }
      if (!appsrv.ParamCheck('P', P, ['&moduleName','&scriptName','&objectName','&mode','&db','|runas_user','|runas_password','|runas_admin'])) { return Helper.GenError(req, res, -4, 'Invalid Parameters'); }

      var scriptName = P.scriptName;
      if(!scriptName) { Helper.GenError(req, res, -4, 'Invalid Parameters'); return; }
      if(!_.includes(['view','drop','init','init_data','restructure','sample_data','recreate','recreate_sample'],scriptName)) { Helper.GenError(req, res, -4, 'Invalid Parameters'); return; }
      var objectName = P.objectName;
      if(!objectName) { Helper.GenError(req, res, -4, 'Invalid Parameters'); return; }
      var moduleName = P.moduleName;
      if(!moduleName) { Helper.GenError(req, res, -4, 'Invalid Parameters'); return; }

      var mode = P.mode;
      if(!_.includes(['run','preview'],mode)) { Helper.GenError(req, res, -4, 'Invalid Parameters'); return; }

      let dbid = P.db;
      if(!(dbid in jsh.DB)) { Helper.GenError(req, res, -4, 'Invalid Database ID'); return; }
      var db = jsh.DB[dbid];

      let sqlext = jsh.DB[dbid].getSQLExt();
      if(!sqlext.Objects || !sqlext.Objects[moduleName]){ Helper.GenError(req, res, -1, 'Module not found'); return; }

      var sqlModule = sqlext.Objects[moduleName];
      var sqlObject = null;
      for(var i=0;i<sqlModule.length;i++){
        if(sqlModule[i].name == objectName){
          sqlObject = sqlModule[i];
          break;
        }
      }
      if(!sqlObject){ Helper.GenError(req, res, -1, 'Object not found'); return; }

      //Run as user, if applicable
      var dbconfig = jsh.DBConfig[dbid];
      if(P.runas_admin){
        dbconfig = _.extend({}, dbconfig);
        dbconfig.user = dbconfig.admin_user;
        if(dbconfig.admin_password) dbconfig.password = dbconfig.admin_password;
        if(dbconfig.options) dbconfig.options = _.extend({}, dbconfig.options);
        if(dbconfig.options.pooled) dbconfig.options.pooled = false;
      }
      else if(P.runas_user){
        dbconfig = _.extend({}, dbconfig);
        dbconfig.user = P.runas_user;
        dbconfig.password = P.runas_password;
        if(dbconfig.options) dbconfig.options = _.extend({}, dbconfig.options);
        if(dbconfig.options.pooled) dbconfig.options.pooled = false;
      }
      var sqlFuncs  = [];
      sqlFuncs['DB'] = dbconfig.database;
      sqlFuncs['DB_LCASE'] = dbconfig.database.toLowerCase();
      sqlFuncs['INIT_DB'] = sqlFuncs['DB'];
      sqlFuncs['INIT_DB_LCASE'] = sqlFuncs['DB_LCASE'];

      var sqlsrc = '';
      if(scriptName=='view'){
        return res.end(JSON.stringify({ _success: 1, src: JSON.stringify(sqlObject,null,4) }));
      }
      else if(_.includes(['drop','init','init_data','sample_data','restructure','recreate','recreate_sample'], scriptName)){
        let subScripts = [];
        if(scriptName=='restructure') subScripts = ['restructure_drop','restructure_init'];
        else if(scriptName=='recreate') subScripts = ['drop','init','restructure_drop','restructure_init','init_data'];
        else if(scriptName=='recreate_sample') subScripts = ['drop','init','restructure_drop','restructure_init','init_data','sample_data'];
        else subScripts = [scriptName];
        sqlsrc = _.filter(_.map(subScripts, function(subScriptName){ return db.getObjectSQL(jsh, sqlext, moduleName, jsh.Modules[moduleName], subScriptName, jsh.DBConfig[dbid], { filterObject: objectName }); }), function(val){ return val.trim(); }).join('\n');
      }
      else {
        return Helper.GenError(req, res, -99999, 'Unsupported operation');
      }
      sqlsrc = db.ParseSQLFuncs(sqlsrc, sqlFuncs);
      var sqlBatch = db.sql.ParseBatchSQL(sqlsrc);

      if(mode=='run'){
        var dbrslt = [];
        var dbstats = [];

        async.eachSeries(sqlBatch, function(sql, sql_cb){
          db.MultiRecordset('system', sql, [], {}, undefined, function(err, rslt, stats){
            if(err){ err.sql = sql; return jsh.AppSrv.AppDBError(req, res, err, stats); }
            dbrslt.push(rslt);
            dbstats.push(stats);
            return sql_cb();
          }, dbconfig);
        }, function(err){
          if(err) return Helper.GenError(req, res, -99999, 'Error running database operation: '+err.toString());
          res.end(JSON.stringify({ _success: 1, _stats: Helper.FormatStats(req, dbstats, { notices: true, show_all_messages: true }), dbrslt: dbrslt }));
        });
      }
      else if(mode=='preview'){
        return res.end(JSON.stringify({ _success: 1, src: sqlBatch.join('\n') }));
      }

      return;
    }
    return next();
  };

  return exports;
};
