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

var DatabaseScripter = require('../lib/DatabaseScripter.js');
var JSHdb = require('jsharmony-db');
var path = require('path');
var _ = require('lodash');
var jsHarmony = require('jsharmony');
var Helper = require('jsharmony/Helper');
var jsHarmonyFactory = require('../index');
var wclib = require('jsharmony/WebConnect.js');
var wc = new wclib.WebConnect();
var xlib = wclib.xlib;
var fs = require('fs');

var jsh = null;
var dbs = null;
var jsHarmonyFactory_Init = {};
var cliReturnCode = 1;

var _IS_WINDOWS = /^win/.test(process.platform);
var scriptConfig = {
  _IS_WINDOWS: _IS_WINDOWS,
  _NSTART_CMD: _IS_WINDOWS ? 'nstart.cmd' : 'nstart.sh',

  _JSH_DBSERVER: '',
  _JSH_DBNAME: '',
  _JSH_DBUSER: '',
  _JSH_DBPASS: '',
  _JSH_DBTYPE: '',

  _ADMIN_DBUSER: '',
  _ADMIN_DBPASS: '',
  _JSH_ADMIN_EMAIL: '',
  _JSH_ADMIN_PASS: '',

  sqlFuncs: [],
};

jsHarmonyFactory_Init.Run = function(run_cb){
  jsh = new jsHarmonyFactory.Application();
  jsh.Config.appbasepath = process.cwd();
  jsh.Config.silentStart = true;
  jsh.Config.interactive = true;
  jsh.Init(function(){

    process.on('exit',function(){ process.exit(cliReturnCode); });

    if(!jsh.DBConfig['default']){
      console.log('\r\nPlease configure dbconfig in '+jsh.Config.appbasepath+(scriptConfig._IS_WINDOWS?'\\':'/')+'app.config.js before running init database operation');
      process.exit();
    }
  
    var db = jsh.DB['default'];
    dbs = new DatabaseScripter(jsh, scriptConfig);
  
    scriptConfig._JSH_DBSERVER = dbs.getDBServer();
    scriptConfig._JSH_DBNAME = dbs.getDBName();
    scriptConfig._JSH_DBUSER = jsh.DBConfig['default'].user;
    scriptConfig._JSH_DBPASS = jsh.DBConfig['default'].password;
    scriptConfig._JSH_DBTYPE = dbs.getDBType();
    scriptConfig._ADMIN_DBUSER = '';
    scriptConfig._ADMIN_DBPASS = '';
  
    Promise.resolve()
  
    //Check if the database connection string works
    .then(function(){ return new Promise(function(resolve, reject){
      db.Scalar('','select 1',[],{},function(err,rslt){
        if(err){ console.log('\r\nERROR: Could not connect to database.  Please check your dbconfig in '+jsh.Config.appbasepath+(scriptConfig._IS_WINDOWS?'\\':'/')+'app.config.js'); return reject(); }
        if(rslt && (rslt.toString()=="1")){
          resolve();
        }
      });
    }); })
  
    .then(function(){ return new Promise(function(resolve, reject){
      db.Close(function(){
        resolve();
      });
    }); })
  
    //Get database information
    .then(function(){ return new Promise(function(login_resolve, login_reject){
      if(_.includes(['sqlite'],scriptConfig._JSH_DBTYPE)) return login_resolve();
  
      var try_login = function(){
  
        console.log('\r\n===================================');
        console.log('Please enter a database admin login');
        console.log('===================================');
  
        Promise.resolve()
  
        //Ask for the database admin user
        .then(xlib.getStringAsync(function(){
          if(jsh.DBConfig['default'].user){
            console.log('Database user: ' + jsh.DBConfig['default'].user + '   (from app.config.js)');
            return false;
          }
          process.stdout.write('Please enter an ADMIN database user for running the scripts: ');
        },function(rslt,retry){
            if(rslt){ jsh.DBConfig['default'].user = rslt; return true; }
            else{ process.stdout.write('Invalid entry.  Please enter a valid database user: '); retry(); }
        }))
  
        //Ask for admin password
        .then(xlib.getStringAsync(function(){
          if(jsh.DBConfig['default'].password){
            console.log('Database password: ******   (from app.config.js)');
            return false;
          }
          process.stdout.write('Please enter the password for user "'+jsh.DBConfig['default'].user+'": ');
        },function(rslt,retry){
          jsh.DBConfig['default'].password = rslt;
            return true;
        },'*'))
  
  
        //Check if user has sysadmin access
        .then(function(){ return new Promise(function(resolve, reject){
          db.Close(function(){
            db.setSilent(true);
            db.Scalar('',db.ParseSQLFuncs(db.ParseSQL('init_sysadmin_access'), dbs.getSQLFuncs()),[],{},function(err,rslt){
              db.setSilent(false);
              db.Close(function(){
                if(!err && rslt && (rslt.toString()=="1")){
                  console.log('\r\n');
                  return resolve();
                }
                if(err){ console.log('Could not log in, or user does not have db admin access ('+err + ')'); }
                //Log in
                if(!err) console.log('> User does not have db admin access');
    
                jsh.DBConfig['default'].user = '';
                jsh.DBConfig['default'].password = '';
                try_login();
              });
            });
          });
        }); })
  
        .then(function(){
          scriptConfig._ADMIN_DBUSER = jsh.DBConfig['default'].user;
          scriptConfig._ADMIN_DBPASS = jsh.DBConfig['default'].password;
          login_resolve();
        });
  
      }; //END try_login
      try_login();
  
    }); })
  
    //Initialize Database
    .then(function(){ return new Promise(function(resolve, reject){
      console.log('');
      console.log('=============================');
      console.log('Running INIT Database Scripts');
      console.log('=============================');
      dbs.Run(['*','init','init'],function(){
        dbs.Run(['*','restructure'],function(){
          dbs.Run(['*','init_data'],resolve);
        });
      });
    }); })
  
    //Callback
    .then(function(){ return new Promise(function(resolve, reject){
      console.log('');
      console.log('');
      console.log('');
      console.log('The jsHarmony Factory database has been initialized!');
      console.log('');
      console.log('** Please verify the configuration in '+jsh.Config.appbasepath+(scriptConfig._IS_WINDOWS?'\\':'/')+'app.config.js');
      console.log('** Be sure to configure ports and HTTPS for security');
      console.log('');
      console.log('Then start the server by running '+(scriptConfig._IS_WINDOWS?'':'./')+scriptConfig._NSTART_CMD);
      console.log('');
      console.log('Log in with the admin account below:');
      console.log('User: '+scriptConfig._JSH_ADMIN_EMAIL);
      console.log('Password: '+scriptConfig._JSH_ADMIN_PASS);
      console.log('');
      cliReturnCode = 0; //Success
  
      db.Close(function(){
        if(run_cb) run_cb();
        resolve();
      });
    }); })
  
    .catch(function(err){
      if(err) console.log(err);
    });

  });
}
  
jsHarmonyFactory_Init.Run();