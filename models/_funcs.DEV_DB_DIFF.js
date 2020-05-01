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
var _ = require('lodash');

module.exports = exports = function(module, funcs){
  var exports = {};

  exports.DEV_DB_DIFF = function (req, res, next) {

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
    var dbtypes = appsrv.DB.types;
    var model = jsh.getModel(req, module.namespace + funcs._transform('Dev/DBDiff'));
    
    if (!Helper.hasModelAction(req, model, 'B')) { Helper.GenError(req, res, -11, 'Invalid Model Access'); return; }

    if (verb == 'get') {
      if (!appsrv.ParamCheck('Q', Q, ['|db'])) { Helper.GenError(req, res, -4, 'Invalid Parameters'); return; }
      var dbid = Q.db;

      if(dbid){
        if(!(dbid in jsh.DB)) { Helper.GenError(req, res, -4, 'Invalid Databse ID'); return; }
        var sqlext = jsh.DB[dbid].getSQLExt();
        res.end(JSON.stringify({ _success: 1, modules: _.keys(sqlext.Objects) }));
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
      if (!appsrv.ParamCheck('P', P, ['&moduleName','&db','|runas_user','|runas_password'])) { return Helper.GenError(req, res, -4, 'Invalid Parameters'); }

      var dbid = P.db;
      if(!(dbid in jsh.DB)) { Helper.GenError(req, res, -4, 'Invalid Database ID'); return; }
      var db = jsh.DB[dbid];
      var sqlext = jsh.DB[dbid].getSQLExt();

      var moduleName = P.moduleName;
      if(!(moduleName in sqlext.Objects)) { Helper.GenError(req, res, -4, 'Invalid Parameters'); return; }

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

      db.getObjectDiff(jsh, sqlext, moduleName, function(err, sql){
        if(err) return jsh.AppSrv.AppDBError(req, res, err);
        sql += "\r\n";
        res.end(JSON.stringify({ _success: 1, src: sql }));
      });
      return;
    }
    return next();
  }

  return exports;
};
