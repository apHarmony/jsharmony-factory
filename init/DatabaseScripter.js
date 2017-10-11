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
  this.dbadmin_access = false;
  this.dbadmin_user = '';
  this.dbadmin_password = '';
  this.dbaccess_user = '';
  this.dbaccess_password = '';
};

DatabaseScripter.prototype.Run = function(scripttype, run_cb){
  var _this = this;
  var dbscripts = {};
  var dbscript_names = [];

  Promise.resolve()

  //Check if the database connection string works
  .then(function(){ return new Promise(function(resolve, reject){
    console.log('\r\nTesting database connection');
    //Load app.settings.js and parse inheritance
    if(!global.jsHarmonyFactorySettings_Loaded) jsHarmonyFactory.LoadSettings();
    //Load database driver
    _this.db = new JSHdb();
    var path_models_sql = path.join(path.dirname(module.filename),'../models/sql/');
    _this.sqlbase = jsHarmony.LoadSQL(path_models_sql,global.dbconfig._driver.name);
	
    if(global.dbconfig){
      _this.dbaccess_user = _this.dbadmin_user = global.dbconfig.user;
      _this.dbaccess_password = _this.dbadmin_password = global.dbconfig.password;
    }
    _this.db.Scalar('','select 1',[],{},function(err,rslt){
      if(err){ console.log('\r\nERROR: Could not connect to database.  Please check your global.dbconfig in app.settings.js and try again by running:\r\nnpm run -s init-factory'); return reject(); }
      if(rslt && (rslt.toString()=="1")){
        console.log('OK');
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

  //Check if user has sysadmin access
  .then(function(){ return new Promise(function(resolve, reject){
    var firstrun = true;
    var xfunc = function(){
      if(_this.dbadmin_access) return resolve();
      console.log('\r\nChecking if current user has db admin access');
      _this.db.Scalar('',JSHdb.ParseSQL('init_sysadmin_access',_this.sqlbase),[],{},function(err,rslt){
        if(!err && rslt && (rslt.toString()=="1")){
          _this.dbadmin_access = true;
          console.log('OK');
          return resolve();
        }
        if(err){ console.log('\r\nError checking for db admin access'); if(firstrun) return reject(); }
        //Log in
        if(!err) console.log('> User does not have db admin access');
        console.log('\r\nPlease enter a database ADMIN user with create access:');
        xlib.getString(function(rslt, retry){
          if(!rslt){ console.log('Invalid entry.  Please enter a valid database user'); retry(); return false; }
          _this.dbadmin_user = rslt;
          console.log('\r\nPlease enter the database ADMIN password:');
          xlib.getString(function(rslt, retry){
            if(!rslt){ console.log('Invalid entry.  Please enter a valid database password'); retry(); return false; }
            _this.dbadmin_password = rslt;
            _this.db.Close(function(){
              global.dbconfig.user = _this.dbadmin_user;
              global.dbconfig.password = _this.dbadmin_password;
              firstrun = false;
              _this.db = new JSHdb();
              return xfunc();
            });
          },'*');
        });
      });
    };
    xfunc();
  }); })

  //Load Database Scripts
  .then(function(){ return new Promise(function(resolve, reject){
    console.log('\r\nLoading database initialization scripts...');

    var path_init_sql = path.join(path.dirname(module.filename),global.dbconfig._driver.name);
    var files = fs.readdirSync(path_init_sql);
    files.sort();
    dbscript_names = [];
    for (var i = 0; i < files.length; i++) {
      var fname = files[i];
      if (fname.indexOf('.sql', fname.length - 4) == -1) continue;
      dbscripts[fname] = fs.readFileSync(path_init_sql + '/' + fname,'utf8');
      dbscript_names.push(fname);
    }
    console.log('OK');
    resolve();
  }); })

  .then(function(){ return new Promise(function(resolve, reject){
    console.log('\r\nRunning database initialization scripts...');
    _this.sqlbase.SQL['INIT_DB_USER'] = _this.dbaccess_user;
    _this.sqlbase.SQL['INIT_DB'] = global.dbconfig.database;
    _this.sqlbase.SQL['INIT_DB_LCASE'] = global.dbconfig.database;

    async.eachSeries(dbscript_names, function(dbscript_name, cb){
      var bsql = _this.db.sql.ParseBatchSQL(JSHdb.ParseSQL(dbscripts[dbscript_name],_this.sqlbase));
      var bi = 0;

      async.eachSeries(bsql, function(sql, sql_cb){
        bi++;
        console.log(dbscript_name + ' ' + bi.toString());
        _this.db.Scalar('',sql,[],{},function(err,rslt){
          if(err){ console.log('\r\n'+sql); console.log('\r\nERROR: Error initializing database: '+err.toString()); return cb(err); }
          console.log('OK');
          return sql_cb();
        });
      }, cb);
    }, function(err){
      if(err){ console.log('\r\nERROR: Initialization failed.'); return reject(); }
      console.log('\r\nInitialization Complete');
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

exports = module.exports = DatabaseScripter;