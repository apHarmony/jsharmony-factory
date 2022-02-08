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

/* eslint-disable no-console  */

function DatabaseScripter(jsh, scriptConfig){
  this.jsh = jsh;
  this.scriptConfig = scriptConfig;
  this.db = null;
}

DatabaseScripter.prototype.getSQLFuncs = function(){
  var _this = this;
  var sqlFuncs = [];
  sqlFuncs['INIT_DB'] = _this.scriptConfig._JSH_DBNAME;
  sqlFuncs['INIT_DB_LCASE'] = _this.scriptConfig._JSH_DBNAME.toLowerCase();
  sqlFuncs['INIT_DB_USER'] = _this.scriptConfig._JSH_DBUSER;
  sqlFuncs['INIT_DB_PASS'] = _this.scriptConfig._JSH_DBPASS;
  sqlFuncs['INIT_DB_HASH_MAIN'] = _this.jsh.Config.modules['jsHarmonyFactory'].mainsalt;
  sqlFuncs['INIT_DB_HASH_CLIENT'] = _this.jsh.Config.modules['jsHarmonyFactory'].clientsalt;
  sqlFuncs['INIT_DB_ADMIN_EMAIL'] = _this.scriptConfig._JSH_ADMIN_EMAIL;
  sqlFuncs['INIT_DB_ADMIN_PASS'] = _this.scriptConfig._JSH_ADMIN_PASS;
  sqlFuncs['DB'] = _this.scriptConfig._JSH_DBNAME;
  sqlFuncs['DB_LCASE'] = _this.scriptConfig._JSH_DBNAME.toLowerCase();
  return sqlFuncs;
};

DatabaseScripter.prototype.Run = function(scripttype, run_cb){
  var _this = this;
  if(!scripttype) throw new Error('DatabaseScripter - scripttype is required');
  var scriptname = '';
  for(var i=0;i<scripttype.length;i++){
    if(scripttype[i]=='*') continue;
    if(scriptname) scriptname += ':';
    scriptname += scripttype[i];
  }

  Promise.resolve()

    //Check if the database connection string works
    .then(function(){ return new Promise(function(resolve, reject){
      //Load app.config.js and parse inheritance
      _this.jsh.Init(function(){

        _this.db = _this.jsh.DB['default'];
    
        _this.db.Scalar('','select 1',[],{},function(err,rslt){
          if(err){ console.log('\r\nERROR: Could not connect to database.  Please check your dbconfig in app.config.js & app.config.local.js and try again by running:\r\nnpm run -s init-factory'); return reject(); }
          if(rslt && (rslt.toString()=='1')){
            resolve();
          }
        });

      });
    }); })

    .then(function(){ return new Promise(function(resolve, reject){
      console.log('Running scripts - '+scriptname+'...');
      var dbtype = _this.db.getType();
      var default_pass = 'ChangeMe';
      var last_dbscript_name = '';
      var last_bi = -1;
      var chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
      for(var i=0;i<6;i++) default_pass += chars.charAt(Math.floor(Math.random()*chars.length));

      if(!_this.scriptConfig._JSH_ADMIN_EMAIL) _this.scriptConfig._JSH_ADMIN_EMAIL = 'admin@jsharmony.com';
      if(!_this.scriptConfig._JSH_ADMIN_PASS) _this.scriptConfig._JSH_ADMIN_PASS = default_pass;

      //Load and Execute Database Scripts
      var onSQL = function(dbscript_name, bi, sql){
        if(dbtype=='mssql'){
          if(last_dbscript_name != dbscript_name) console.log(dbscript_name);
        }
        else console.log(dbscript_name + ' ' + bi.toString());
        last_dbscript_name = dbscript_name;
        last_bi= bi;
      };
      var onSQLResult = function(err, rslt, sql){
        if(err){
          console.log('\r\nERROR: Error running database scripts (' + last_dbscript_name + '::' + last_bi + '): '+err.toString());
        }
        else if(rslt && rslt.length) console.log(rslt);
      };
      _this.db.RunScripts(_this.jsh, scripttype, {
        sqlFuncs: _this.getSQLFuncs(),
        onSQL: onSQL,
        onSQLResult: onSQLResult
      }, function(err){
        if(err){ console.log('\r\nERROR: Database Operation failed.'); return reject(); }
        console.log('...OK');
        resolve();
      });
    }); })

    //Callback
    .then(function(){
      if(!_this.db){
        if(run_cb) run_cb();
        return;
      }
      _this.db.Close(function(){ if(run_cb) run_cb(); });
    })

    .catch(function(err){
      if(err) console.log(err);
      _this.db.Close();
      process.exit(1);
    });
};

DatabaseScripter.prototype.getDBType = function(){
  return this.jsh.DBConfig['default']._driver.name;
};

DatabaseScripter.prototype.getDBServer = function(){
  var dbtype = this.jsh.DBConfig['default']._driver.name;
  if(dbtype=='pgsql') return this.jsh.DBConfig['default'].host;
  else if(dbtype=='mssql'){
    var server = this.jsh.DBConfig['default'].server;
    if(this.jsh.DBConfig['default'].options.instanceName && (server.indexOf('\\')<0)) server += '\\' + this.jsh.DBConfig['default'].options.instanceName;
    return server;
  }
  else if(dbtype=='sqlite') return '';
  else throw new Error('Database type not supported');
};

DatabaseScripter.prototype.setDBServer = function(val){
  var dbtype = this.jsh.DBConfig['default']._driver.name;
  if(dbtype=='pgsql') this.jsh.DBConfig['default'].host = val;
  else if(dbtype=='mssql') this.jsh.DBConfig['default'].server = val;
  else throw new Error('Database type not supported');
};

DatabaseScripter.prototype.getDBName = function(){
  return this.jsh.DBConfig['default'].database;
};

DatabaseScripter.prototype.setDBName = function(val){
  var dbtype = this.jsh.DBConfig['default']._driver.name;
  if(!val){
    if(dbtype=='pgsql') this.jsh.DBConfig['default'].database = 'postgres';
    else if(dbtype=='mssql') this.jsh.DBConfig['default'].database = 'master';
    else if(dbtype=='sqlite') this.jsh.DBConfig['default'].database = ':memory:';
    else throw new Error('Database type not supported');
  }
  else this.jsh.DBConfig['default'].database = val;
  if((dbtype=='mssql') && (this.jsh.DBConfig['default'].options)) this.jsh.DBConfig['default'].options.database = this.jsh.DBConfig['default'].database;
};

exports = module.exports = DatabaseScripter;