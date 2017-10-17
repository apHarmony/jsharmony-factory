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

var path = require('path');
var fs = require('fs');
var async = require('async');
var jsHarmony = require('jsharmony');
var wclib = require('jsharmony/WebConnect.js');
var wc = new wclib.WebConnect();
var xlib = wclib.xlib;
var JSHdb = require('jsharmony-db');
var jsHarmonyFactory = require('../index');

function DatabaseScripter(){
  this.db = null;
  this.sqlbase = {};
};

DatabaseScripter.prototype.Run = function(scripttype, run_cb){
  var _this = this;
  var dbscripts = {};
  var dbscript_names = [];
  if(!scripttype) throw new Error('DatabaseScripter - scripttype is required');

  Promise.resolve()

  //Check if the database connection string works
  .then(function(){ return new Promise(function(resolve, reject){
    //Load app.settings.js and parse inheritance
    if(!global.jsHarmonyFactorySettings_Loaded) jsHarmonyFactory.LoadSettings();
    //Load database driver
    _this.db = new JSHdb();
    var path_models_sql = path.join(path.dirname(module.filename),'../models/sql/');
    _this.sqlbase = jsHarmony.LoadSQL(path_models_sql,global.dbconfig._driver.name);
	
    _this.db.Scalar('','select 1',[],{},function(err,rslt){
      if(err){ console.log('\r\nERROR: Could not connect to database.  Please check your global.dbconfig in app.settings.js and try again by running:\r\nnpm run -s init-factory'); return reject(); }
      if(rslt && (rslt.toString()=="1")){
        resolve();
      }
    });
  }); })

  /*
  //Confirm database table creation
  .then(xlib.getStringAsync(function(){
    console.log('\r\nCreate the required database tables for jsHarmony Factory?');
    console.log('1) Yes');
    console.log('2) No');
  },function(rslt,retry){
    if(rslt=="1"){ return true; }
    else if(rslt=="2"){ 
      console.log('\r\nDatabase tables will not be initialized.\r\n\r\nYou can manually run this operation in the future via:\r\nnpm run -s init-factory');
      return false;
    }
    else{ console.log('Invalid entry.  Please enter the number of your selection'); retry(); }
  }))
  */

  //Load Database Scripts
  .then(function(){ return new Promise(function(resolve, reject){
    console.log('Loading scripts...');

    var path_init_sql = path.join(path.dirname(module.filename),global.dbconfig._driver.name);
    var files = fs.readdirSync(path_init_sql);
    files.sort();
    dbscript_names = [];
    for (var i = 0; i < files.length; i++) {
      var fname = files[i];
      if (fname.indexOf('.sql', fname.length - 4) == -1) continue;
      if (fname.substr(0,scripttype.length+1) != (scripttype+'.')) continue;
      dbscripts[fname] = fs.readFileSync(path_init_sql + '/' + fname,'utf8');
      dbscript_names.push(fname);
    }
    resolve();
  }); })

  .then(function(){ return new Promise(function(resolve, reject){
    console.log('Running scripts...');
    _this.sqlbase.SQL['INIT_DB'] = global._JSH_DBNAME;
    _this.sqlbase.SQL['INIT_DB_LCASE'] = global._JSH_DBNAME.toLowerCase();
    _this.sqlbase.SQL['INIT_DB_USER'] = global._JSH_DBUSER;
    _this.sqlbase.SQL['INIT_DB_PASS'] = global._JSH_DBPASS;
    _this.sqlbase.SQL['INIT_DB_HASH_ADMIN'] = global.adminsalt;
    _this.sqlbase.SQL['INIT_DB_HASH_CLIENT'] = global.clientsalt;
    _this.sqlbase.SQL['INIT_DB_ADMIN_EMAIL'] = global._JSH_ADMIN_EMAIL||'admin@jsharmony.com';
    _this.sqlbase.SQL['INIT_DB_ADMIN_PASS'] = global._JSH_ADMIN_PASS||'ChangeMe';

    async.eachSeries(dbscript_names, function(dbscript_name, cb){
      var bsql = _this.db.sql.ParseBatchSQL(JSHdb.ParseSQL(dbscripts[dbscript_name],_this.sqlbase));
      var bi = 0;

      async.eachSeries(bsql, function(sql, sql_cb){
        bi++;
        console.log(dbscript_name + ' ' + bi.toString());
        _this.db.Scalar('',sql,[],{},function(err,rslt){
          if(err){ console.log('\r\n'+sql); console.log('\r\nERROR: Error running database scripts: '+err.toString()); return cb(err); }
          return sql_cb();
        });
      }, cb);
    }, function(err){
      if(err){ console.log('\r\nERROR: Database Operation failed.'); return reject(); }
      console.log('Database Operation Complete');
      resolve();
    });
  }); })

  //Callback
  .then(function(){
    _this.db.Close(function(){ if(run_cb) run_cb(); });
  })

  .catch(function(err){
    if(err) console.log(err);
    _this.db.Close();
    process.exit(1);
  });
}

DatabaseScripter.getDBServer = function(){
  var dbtype = global.dbconfig._driver.name;
  if(dbtype=='pgsql') return global.dbconfig.host;
  else if(dbtype=='mssql') return global.dbconfig.server;
  else throw new Error('Database type not supported');
}

DatabaseScripter.setDBServer = function(val){
  var dbtype = global.dbconfig._driver.name;
  if(dbtype=='pgsql') global.dbconfig.host = val;
  else if(dbtype=='mssql') global.dbconfig.server = val;
  else throw new Error('Database type not supported');
}

DatabaseScripter.getDBName = function(){
  return global.dbconfig.database;
}

DatabaseScripter.setDBName = function(val){
  var dbtype = global.dbconfig._driver.name;
  if(!val){
    if(dbtype=='pgsql') global.dbconfig.database = 'postgres';
    else if(dbtype=='mssql') global.dbconfig.database = 'master';
    else throw new Error('Database type not supported');
  }
  else global.dbconfig.database = val;
  if((dbtype=='mssql') && (global.dbconfig.options)) global.dbconfig.options.database = global.dbconfig.database;
}

exports = module.exports = DatabaseScripter;