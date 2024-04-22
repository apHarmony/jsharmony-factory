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

module.exports = exports = function(module, funcs){
  var exports = {};

  exports.DEV_DB_UPGRADE = function (req, res, next) {

    //Replace scripts with "..." and prune empty scripts
    function clearScripts(node){
      var rslt = {};
      for(var key in node){
        var val = node[key];
        if(_.isString(val)){
          if(val.trim()) rslt[key] = '...';
        }
        else{
          var childScripts = clearScripts(val);
          if(!_.isEmpty(childScripts)) rslt[key] = childScripts;
        }
      }
      return rslt;
    }

    function getUpdateScripts(scripts){
      var rslt = clearScripts(scripts);
      _.each(_.keys(rslt), function(moduleName){
        if(!rslt[moduleName] || !rslt[moduleName].upgrade){ delete rslt[moduleName]; return; }
        rslt[moduleName] = rslt[moduleName].upgrade;
        for(var key in rslt[moduleName]){
          rslt[moduleName][key] = '...';
        }
      });
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
    var jsh = module.jsh;
    var appsrv = jsh.AppSrv;
    var model = jsh.getModel(req, module.namespace + funcs._transform('Dev/DBUpgrade'));
    
    if (!Helper.hasModelAction(req, model, 'B')) { Helper.GenError(req, res, -11, 'Invalid Model Access'); return; }

    function getVersions(version_cb){
      var sql = 'select version_component, version_no_major, version_no_minor, version_no_build, version_no_rev from {schema}.'+funcs._transform('version__tbl');
      jsh.DB.default.Recordset('system', funcs.replaceSchema(sql), [], {}, undefined, function(err, rslt){
        if(err) return version_cb(err);
        var versions = {};
        _.each(rslt, function(row){
          if(row && row.version_component){
            var moduleVersion = (row.version_no_major||'0').toString()+'-'+(row.version_no_minor||'0').toString()+'-'+(row.version_no_build||'0').toString()+'-'+(row.version_no_rev||'0').toString();
            versions[row.version_component] = moduleVersion;
          }
        });
        return version_cb(null, versions);
      });
    }

    if (verb == 'get') {
      if (!appsrv.ParamCheck('Q', Q, ['|db'])) { Helper.GenError(req, res, -4, 'Invalid Parameters'); return; }
      let dbid = Q.db;

      if(dbid){
        if(!(dbid in jsh.DB)) { Helper.GenError(req, res, -4, 'Invalid Databse ID'); return; }
        let sqlext = jsh.DB[dbid].getSQLExt();
        var scripts = getUpdateScripts(sqlext.Scripts);
        res.type('json');
        res.end(JSON.stringify({ _success: 1, scripts: scripts, hasAdmin: !!jsh.DBConfig[dbid].admin_user }));
      }
      else {
        var dbs = [];
        for(var dbid_key in jsh.DB) dbs.push(dbid_key);
        getVersions(function(err, versions){
          if(err) return Helper.GenError(req, res, -99999, err.toString());
          res.type('json');
          res.end(JSON.stringify({ _success: 1, dbs: dbs, versions: versions }));
        });
      }
      
      return;
    }
    else if (verb == 'post') {
      if (!appsrv.ParamCheck('Q', Q, [])) { Helper.GenError(req, res, -4, 'Invalid Parameters'); return; }
      if (!appsrv.ParamCheck('P', P, ['&moduleName','&scriptName','&mode','&db','|runas_user','|runas_password','|runas_admin'])) { return Helper.GenError(req, res, -4, 'Invalid Parameters'); }

      var scriptName = P.scriptName;
      if(!scriptName) { Helper.GenError(req, res, -4, 'Invalid Parameters'); return; }
      var moduleName = P.moduleName;
      if(!moduleName) { Helper.GenError(req, res, -4, 'Invalid Parameters'); return; }

      var mode = P.mode;
      if(!_.includes(['run','preview'],mode)) { Helper.GenError(req, res, -4, 'Invalid Parameters'); return; }

      let dbid = P.db;
      if(!(dbid in jsh.DB)) { Helper.GenError(req, res, -4, 'Invalid Database ID'); return; }
      var db = jsh.DB[dbid];

      let sqlext = jsh.DB[dbid].getSQLExt();
      if(!sqlext.Objects || !sqlext.Objects[moduleName]){ Helper.GenError(req, res, -1, 'Module not found'); return; }

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

      var scriptid = [moduleName, 'upgrade', scriptName];

      if(mode=='run'){
        db.RunScripts(jsh, scriptid, { dbconfig: dbconfig, sqlFuncs: sqlFuncs }, function(err, rslt, stats, dbcommands){
          if(err){ err.sql = 'scriptid:'+scriptid; return jsh.AppSrv.AppDBError(req, res, err, stats); }
          getVersions(function(err, versions){
            if(err) return Helper.GenError(req, res, -99999, err.toString());
            if(dbcommands && dbcommands.restart) jsh.Restart(1000);
            res.type('json');
            res.end(JSON.stringify({
              _success: 1,
              _stats: Helper.FormatStats(req, stats, { notices: true, show_all_messages: true }),
              dbrslt: rslt,
              dbcommands: dbcommands,
              versions: versions
            }));
          });
          return;
        });
      }
      else if(mode=='preview'){
        var sqlsrc = '';
        db.RunScripts(jsh, scriptid, { noCommands: true, dbconfig: dbconfig, sqlFuncs: sqlFuncs, onSQL: function(dbscript_name, bi, sql){
          sqlsrc += sql + '\r\n';
          return false;
        } }, function(err, rslt){
          if(err){ err.sql = 'scriptid:'+scriptid; return jsh.AppSrv.AppDBError(req, res, err); }
          res.type('json');
          res.end(JSON.stringify({ _success: 1, src: sqlsrc }));
          return;
        });
      }

      return;
    }
    return next();
  };

  return exports;
};
