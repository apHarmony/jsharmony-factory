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

  exports.DEV_DB_SCHEMA = function (req, res, next) {

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
    var model = jsh.getModel(req, module.namespace + funcs._transform('Dev/DBSchema'));
    
    if (!Helper.hasModelAction(req, model, 'B')) { Helper.GenError(req, res, -11, 'Invalid Model Access'); return; }

    if (verb == 'get') {
      if (!appsrv.ParamCheck('Q', Q, ['|db'])) { Helper.GenError(req, res, -4, 'Invalid Parameters'); return; }
      var dbid = Q.db;

      if(dbid){
        if(!(dbid in jsh.DB)) { Helper.GenError(req, res, -4, 'Invalid Database ID'); return; }
        var schema = jsh.DB[dbid].schema_definition;
        res.end(JSON.stringify({ _success: 1, schema: schema, funcs: jsh.DB[dbid].SQLExt.Funcs }));
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

  return exports;
};
