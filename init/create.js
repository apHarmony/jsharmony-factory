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
var _ = require('lodash');
var jsHarmony = require('jsharmony');
var Helper = require('jsharmony/Helper');
var HelperFS = require('jsharmony/HelperFS');
var jsHarmonyFactory = require('../index');
var dbs = new DatabaseScripter();
var wclib = require('jsharmony/WebConnect.js');
var wc = new wclib.WebConnect();
var xlib = wclib.xlib;
var fs = require('fs');
var DEFAULT_DB_SERVER = '___DB_SERVER___';
var DEFAULT_DB_NAME = '___DB_NAME___';
var DEFAULT_DB_USER = '___DB_USER___';
var DEFAULT_DB_PASS = '___DB_PASS___';
var DEFAULT_SQLITE_PATH = 'data/db/project.db';
global._IS_WINDOWS = /^win/.test(process.platform);
global._NSTART_CMD = global._IS_WINDOWS ? 'nstart.cmd' : 'nstart.sh';

var jsHarmonyFactory_Init = {};
global.cliReturnCode = 1;

jsHarmonyFactory_Init.Run = function(run_cb){
  global.appbasepath = process.cwd();
  process.on('exit',function(){ process.exit(global.cliReturnCode); });

  if(!global.jsHarmonyFactorySettings_Loaded) jsHarmonyFactory.LoadSettings();
  var db = new JSHdb();
  var path_models_sql = path.join(path.dirname(module.filename),'../models/sql/');
  var sqlbase = jsHarmony.LoadSQL(path_models_sql,global.dbconfig._driver.name);

  global._ORIG_DBSERVER = DatabaseScripter.getDBServer();
  global._ORIG_DBNAME = DatabaseScripter.getDBName();
  global._ORIG_DBUSER = global.dbconfig.user;
  global._ORIG_DBPASS = global.dbconfig.password;

  global._ORIG_DEFAULTS = true;

  if(global._ORIG_DBSERVER == DEFAULT_DB_SERVER) global._ORIG_DBSERVER = '';
  else global._ORIG_DEFAULTS = false;

  if(global._ORIG_DBNAME == DEFAULT_DB_NAME) global._ORIG_DBNAME = '';
  else global._ORIG_DEFAULTS = false;

  if(global._ORIG_DBUSER == DEFAULT_DB_USER){ global._ORIG_DBUSER = ''; global.dbconfig.user = ''; }
  else global._ORIG_DEFAULTS = false;

  if(global._ORIG_DBPASS == DEFAULT_DB_PASS){ global._ORIG_DBPASS = '';  global.dbconfig.password = ''; }
  else global._ORIG_DEFAULTS = false;

  global._JSH_DBSERVER = '';
  global._JSH_DBNAME = '';
  global._JSH_DBUSER = '';
  global._JSH_DBPASS = '';
  global._JSH_DBTYPE = DatabaseScripter.getDBType();
  if(global._ORIG_DBSERVER) global._JSH_DBSERVER = global._ORIG_DBSERVER;
  if(global._ORIG_DBNAME) global._JSH_DBNAME = global._ORIG_DBNAME;
  if(global._ORIG_DBUSER) global._JSH_DBUSER = global._ORIG_DBUSER;
  if(global._ORIG_DBPASS) global._JSH_DBPASS = global._ORIG_DBPASS;

  global._ADMIN_DBUSER = '';
  global._ADMIN_DBPASS = '';
  global._JSH_ADMIN_EMAIL = '';
  global._JSH_ADMIN_PASS = '';

  if(!global.dbconfig){
    console.log('ERROR: No global.dbconfig defined in app.settings.js');
    return;
  }

  Promise.resolve()

  //Get database information
  .then(function(){ return new Promise(function(login_resolve, login_reject){
    if(_.includes(['sqlite'],global._JSH_DBTYPE)) return login_resolve();

    var try_login = function(){

      console.log('\r\n=======================================');
      console.log('Please enter database admin information');
      console.log('=======================================');

      Promise.resolve()

      //Ask for the database server
      .then(xlib.getStringAsync(function(){
        if(global._ORIG_DBSERVER){
          console.log('Database server: ' + global._ORIG_DBSERVER + '   (from app.settings.js)');
          return false;
        }

        process.stdout.write('Please enter the database server: ');
      },function(rslt,retry){
          if(rslt){ DatabaseScripter.setDBServer(rslt); return true; }
          else{ process.stdout.write('Invalid entry.  Please enter a valid database server: '); retry(); }
      }))

      .then(function(){ return new Promise(function(resolve, reject){
        DatabaseScripter.setDBName('');
        resolve();
      }); })

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

      //Ask for admin user
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
        global._JSH_DBSERVER = DatabaseScripter.getDBServer();
        global._ADMIN_DBUSER = global.dbconfig.user;
        global._ADMIN_DBPASS = global.dbconfig.password;
        login_resolve();
      });

    }; //END try_login
    try_login();

  }); })

  //Ask for the NEW database path, if applicable
  .then(xlib.getStringAsync(function(){
    if(global._JSH_DBTYPE != 'sqlite') return false;
    if(global._JSH_DBNAME){
      console.log('NEW Database path: ' + global._JSH_DBNAME + '   (from app.settings.js)');
      return false;
    }
    process.stdout.write('NEW database path ['+DEFAULT_SQLITE_PATH+']: ');
  },function(rslt,retry){
      if(!rslt) rslt = DEFAULT_SQLITE_PATH;
      try{
        var dbpath = path.resolve(rslt);
        var dbfolder = path.dirname(dbpath);
        HelperFS.createFolderRecursiveSync(dbfolder);
        HelperFS.touchSync(dbpath);
      }
      catch(ex){
        console.log(ex);
        process.stdout.write('Error creating database.  Please enter a valid database path: '); 
        retry();
        return;
      }
      global._JSH_DBNAME = rslt;
      DatabaseScripter.setDBName(global._JSH_DBNAME);
      return true;
  }))

  //Ask for the NEW database name, if applicable
  .then(xlib.getStringAsync(function(){
    if(global._JSH_DBTYPE == 'sqlite') return false;
    if(global._JSH_DBNAME){
      console.log('NEW Database name: ' + global._JSH_DBNAME + '   (from app.settings.js)');
      return false;
    }
    process.stdout.write('Please enter the NEW database name: ');
  },function(rslt,retry){
      if(rslt){ global._JSH_DBNAME = rslt; return true; }
      else{ process.stdout.write('Invalid entry.  Please enter a valid database name: '); retry(); }
  }))

  //Create Database
  .then(function(){ return new Promise(function(resolve, reject){
    if(!global._JSH_DBUSER) global._JSH_DBUSER = 'jsharmony_'+global._JSH_DBNAME.toLowerCase()+'_user';
    if(!global._JSH_DBPASS) global._JSH_DBPASS = xlib.getSalt(16);
    console.log('');
    console.log('===============================');
    console.log('Running CREATE Database Scripts');
    console.log('===============================');
    dbs.Run('create',resolve);
  }); })

  //*** Update connection string in app.settings.js
  .then(function(){ return new Promise(function(resolve, reject){
    if(global._ORIG_DEFAULTS || true){
      var cursettings = fs.readFileSync(global.appbasepath+'/app.settings.js','utf8');
      global._ORIG_DEFAULTS = false;

      if(_.includes(['sqlite'],global._JSH_DBTYPE)){
        if(
          ((cursettings.match(new RegExp(DEFAULT_DB_NAME,'g')) || []).length==1)){
          console.log('Updating app.settings.js');
          cursettings = cursettings.replace(DEFAULT_DB_NAME, Helper.escapeJS(global._JSH_DBNAME));
          fs.writeFileSync(global.appbasepath+'/app.settings.js', cursettings, 'utf8');
          global._ORIG_DEFAULTS = true;
        }
      }
      else if(_.includes(['pgsql','mssql'],global._JSH_DBTYPE)){
        if(
          ((cursettings.match(new RegExp(DEFAULT_DB_SERVER,'g')) || []).length==1) &&
          ((cursettings.match(new RegExp(DEFAULT_DB_NAME,'g')) || []).length==1) &&
          ((cursettings.match(new RegExp(DEFAULT_DB_USER,'g')) || []).length==1) &&
          ((cursettings.match(new RegExp(DEFAULT_DB_PASS,'g')) || []).length==1)){
          console.log('Updating app.settings.js');
          cursettings = cursettings.replace(DEFAULT_DB_SERVER, Helper.escapeJS(global._JSH_DBSERVER));
          cursettings = cursettings.replace(DEFAULT_DB_NAME, Helper.escapeJS(global._JSH_DBNAME));
          cursettings = cursettings.replace(DEFAULT_DB_USER, Helper.escapeJS(global._JSH_DBUSER));
          cursettings = cursettings.replace(DEFAULT_DB_PASS, Helper.escapeJS(global._JSH_DBPASS));
          fs.writeFileSync(global.appbasepath+'/app.settings.js', cursettings, 'utf8');
          global._ORIG_DEFAULTS = true;
        }
      }
    }
    DatabaseScripter.setDBName(global._JSH_DBNAME);
    db.Close(function(){
      resolve();
    });
  }); })

  //Initialize Database
  .then(function(){ return new Promise(function(resolve, reject){
    console.log('');
    console.log('=============================');
    console.log('Running INIT Database Scriptss');
    console.log('=============================');
    dbs.Run('init',resolve);
  }); })

  
  .then(function(){ return new Promise(function(resolve, reject){
    if(!global._ORIG_DEFAULTS &&
      ((global._ORIG_DBSERVER != global._JSH_DBSERVER) ||
      (global._ORIG_DBNAME != global._JSH_DBNAME) ||
      (global._ORIG_DBUSER != global._JSH_DBUSER) ||
      (global._ORIG_DBPASS != global._JSH_DBPASS))
    ){
      //*** If did not update app.settings.js, show results and tell user to update app.settings.js on their own 
      console.log('');
      console.log('------------------------------------------------');
      console.log('Please update global.dbconfig in '+global.appbasepath+(global._IS_WINDOWS?'\\':'/')+'app.settings.js with the following database connection information:');
      console.log('------------------------------------------------');
      if(_.includes(['pgsql','mssql'],global._JSH_DBTYPE)) console.log('SERVER: ' + global._JSH_DBSERVER);
      console.log('DATABASE: ' + global._JSH_DBNAME);
      if(_.includes(['pgsql','mssql'],global._JSH_DBTYPE)) console.log('USER: ' + global._JSH_DBUSER);
      if(_.includes(['pgsql','mssql'],global._JSH_DBTYPE)) console.log('PASSWORD: ' + global._JSH_DBPASS);
      console.log('------------------------------------------------');
    }
    else {
      console.log('');
      console.log('');
      console.log('');
      console.log('The jsHarmony Factory database has been created!');
      console.log('');
      console.log('** Please verify the configuration in '+global.appbasepath+(global._IS_WINDOWS?'\\':'/')+'app.settings.js');
      console.log('** Be sure to configure ports and HTTPS for security');
      console.log('');
    }
    console.log('Then start the server by running '+(global._IS_WINDOWS?'':'./')+global._NSTART_CMD);
    console.log('');
    console.log('Log in with the admin account below:');
    console.log('User: '+global._JSH_ADMIN_EMAIL);
    console.log('Password: '+global._JSH_ADMIN_PASS);
    console.log('');
    resolve();
  }); })

  //Callback
  .then(function(){
    global.cliReturnCode = 0; //Success
    if(run_cb) run_cb();
  })

  .catch(function(err){
    if(err) console.log(err);
  });
}
  
jsHarmonyFactory_Init.Run();