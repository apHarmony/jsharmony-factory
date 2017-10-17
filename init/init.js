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

var DatabaseScripter = require('./DatabaseScripter.js');
var JSHdb = require('jsharmony-db');
var path = require('path');
var jsHarmony = require('jsharmony');
var Helper = require('jsharmony/Helper');
var jsHarmonyFactory = require('../index');
var dbs = new DatabaseScripter();
var wclib = require('jsharmony/WebConnect.js');
var wc = new wclib.WebConnect();
var xlib = wclib.xlib;
var fs = require('fs');
global._IS_WINDOWS = /^win/.test(process.platform);
global._NSTART_CMD = global._IS_WINDOWS ? 'nstart.cmd' : 'nstart.sh';


var jsHarmonyFactory_Init = {};
global.cliReturnCode = 1;

jsHarmonyFactory_Init.Run = function(run_cb){
  global.appbasepath = process.cwd();
  process.on('exit',function(){ process.exit(global.cliReturnCode); });

  if(!global.jsHarmonyFactorySettings_Loaded) jsHarmonyFactory.LoadSettings();
  if(!global.dbconfig){
    console.log('\r\nPlease configure global.dbconfig in '+global.appbasepath+(global._IS_WINDOWS?'\\':'/')+'app.settings.js before running init database operation');
    process.exit();
  }
  var db = new JSHdb();
  var path_models_sql = path.join(path.dirname(module.filename),'../models/sql/');
  var sqlbase = jsHarmony.LoadSQL(path_models_sql,global.dbconfig._driver.name);

  global._JSH_DBSERVER = DatabaseScripter.getDBServer();
  global._JSH_DBNAME = DatabaseScripter.getDBName();
  global._JSH_DBUSER = global.dbconfig.user;
  global._JSH_DBPASS = global.dbconfig.password;
  global._ADMIN_DBUSER = '';
  global._ADMIN_DBPASS = '';

  Promise.resolve()

  //Check if the database connection string works
  .then(function(){ return new Promise(function(resolve, reject){
    db.Scalar('','select 1',[],{},function(err,rslt){
      if(err){ console.log('\r\nERROR: Could not connect to database.  Please check your global.dbconfig in '+global.appbasepath+(global._IS_WINDOWS?'\\':'/')+'app.settings.js'); return reject(); }
      if(rslt && (rslt.toString()=="1")){
        resolve();
      }
    });
  }); })

  //Get database information
  .then(function(){ return new Promise(function(login_resolve, login_reject){

    var try_login = function(){

      console.log('\r\n=======================================');
      console.log('Please enter database admin information');
      console.log('=======================================');

      Promise.resolve()

      //Ask for the database admin user
      .then(xlib.getStringAsync(function(){
        if(global.dbconfig.user){
          console.log('Database user: ' + global.dbconfig.user + '   (from app.settings.js)');
          return false;
        }
        process.stdout.write('Please enter an ADMIN database user for running the scripts: ');
      },function(rslt,retry){
          if(rslt){ global.dbconfig.user = rslt; return true; }
          else{ process.stdout.write('Invalid entry.  Please enter a valid database user: '); retry(); }
      }))

      //Ask for admin password
      .then(xlib.getStringAsync(function(){
        if(global.dbconfig.password){
          console.log('Database password: ******   (from app.settings.js)');
          return false;
        }
        process.stdout.write('Please enter the password for user "'+global.dbconfig.user+'": ');
      },function(rslt,retry){
          global.dbconfig.password = rslt;
          return true;
      },'*'))


      //Check if user has sysadmin access
      .then(function(){ return new Promise(function(resolve, reject){
        db.Close(function(){
          db.Scalar('',JSHdb.ParseSQL('init_sysadmin_access',sqlbase),[],{},function(err,rslt){
            if(!err && rslt && (rslt.toString()=="1")){
              console.log('\r\n');
              return resolve();
            }
            if(err){ console.log('Error checking for db admin access: '+err); }
            //Log in
            if(!err) console.log('> User does not have db admin access');

            global.dbconfig.user = '';
            global.dbconfig.password = '';
            try_login();
          });
        });
      }); })

      .then(function(){
        global._ADMIN_DBUSER = global.dbconfig.user;
        global._ADMIN_DBPASS = global.dbconfig.password;
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
    dbs.Run('init',resolve);
  }); })

  //Callback
  .then(function(){
    console.log('');
    console.log('');
    console.log('');
    console.log('The jsHarmony Factory database has been initialized!');
    console.log('');
    console.log('** Please verify the configuration in '+global.appbasepath+(global._IS_WINDOWS?'\\':'/')+'app.settings.js');
    console.log('** Be sure to configure ports and HTTPS for security');
    console.log('');
    console.log('Then start the server by running '+(global._IS_WINDOWS?'':'./')+global._NSTART_CMD);
    console.log('');
    console.log('Log in with the admin account below:');
    console.log('User: '+global._JSH_ADMIN_EMAIL);
    console.log('Password: '+global._JSH_ADMIN_PASS);
    console.log('');
    global.cliReturnCode = 0; //Success
    if(run_cb) run_cb();
  })

  .catch(function(err){
    if(err) console.log(err);
  });
}
  
jsHarmonyFactory_Init.Run();