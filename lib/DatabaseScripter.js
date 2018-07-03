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
  this.jsh = null
  this.db = null;
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
    //Load app.settings.js and parse inheritance
    if(!global.jsHarmonyFactorySettings_Loaded) jsHarmonyFactory.LoadSettings();
    //Load database driver
    _this.jsh = new jsHarmony({ silent: true });
    _this.db = _this.jsh.AppSrv.db;
    
    _this.db.Scalar('','select 1',[],{},function(err,rslt){
      if(err){ console.log('\r\nERROR: Could not connect to database.  Please check your global.dbconfig in app.settings.js and try again by running:\r\nnpm run -s init-factory'); return reject(); }
      if(rslt && (rslt.toString()=="1")){
        resolve();
      }
    });
  }); })

  .then(function(){ return new Promise(function(resolve, reject){
    console.log('Running scripts - '+scriptname+'...');
    var default_pass = 'ChangeMe';
    var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    for(var i=0;i<6;i++) default_pass += chars.charAt(Math.floor(Math.random()*chars.length));

    if(!global._JSH_ADMIN_EMAIL) global._JSH_ADMIN_EMAIL = 'admin@jsharmony.com';
    if(!global._JSH_ADMIN_PASS) global._JSH_ADMIN_PASS = default_pass;

    _this.jsh.SQL['INIT_DB'] = global._JSH_DBNAME;
    _this.jsh.SQL['INIT_DB_LCASE'] = global._JSH_DBNAME.toLowerCase();
    _this.jsh.SQL['INIT_DB_USER'] = global._JSH_DBUSER;
    _this.jsh.SQL['INIT_DB_PASS'] = global._JSH_DBPASS;
    _this.jsh.SQL['INIT_DB_HASH_ADMIN'] = global.adminsalt;
    _this.jsh.SQL['INIT_DB_HASH_CLIENT'] = global.clientsalt;
    _this.jsh.SQL['INIT_DB_ADMIN_EMAIL'] = global._JSH_ADMIN_EMAIL;
    _this.jsh.SQL['INIT_DB_ADMIN_PASS'] = global._JSH_ADMIN_PASS;

    //Load and Execute Database Scripts
    var onSQL = function(dbscript_name, bi, sql){ console.log(dbscript_name + ' ' + bi.toString()); };
    var onSQLResult = function(err, rslt){
      if(err){ 
        if(global.dbconfig._driver.name!='sqlite') console.log('\r\n'+sql); 
        console.log('\r\nERROR: Error running database scripts: '+err.toString()); 
      }
      else if(rslt && rslt.length) console.log(rslt);
    }
    _this.db.RunScripts(_this.jsh, scripttype, {
      onSQL: onSQL,
      onSQLResult: onSQLResult
    }, function(err){
      if(err){ console.log('\r\nERROR: Database Operation failed.'); return reject(); }
      console.log('Database Operation Complete');
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
}

DatabaseScripter.getDBType = function(){
  return global.dbconfig._driver.name;
}

DatabaseScripter.getDBServer = function(){
  var dbtype = global.dbconfig._driver.name;
  if(dbtype=='pgsql') return global.dbconfig.host;
  else if(dbtype=='mssql') return global.dbconfig.server;
  else if(dbtype=='sqlite') return '';
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
    else if(dbtype=='sqlite') global.dbconfig.database = ':memory:';
    else throw new Error('Database type not supported');
  }
  else global.dbconfig.database = val;
  if((dbtype=='mssql') && (global.dbconfig.options)) global.dbconfig.options.database = global.dbconfig.database;
}

exports = module.exports = DatabaseScripter;