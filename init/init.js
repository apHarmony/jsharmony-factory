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

  CLIENT_PORTAL: undefined,
  SAMPLE_DATA: false,
  USE_IPC: false,
  RESULT_MESSAGE: '',

  sqlFuncs: [],
};

jsHarmonyFactory_Init.Run = function(run_cb){
  jsh = new jsHarmonyFactory.Application();
  jsh.Config.appbasepath = process.cwd();
  jsh.Config.silentStart = true;
  jsh.Config.interactive = true;
  jsh.Config.onConfigLoaded.push(function(cb){
    jsh.Config.system_settings.automatic_schema = false;
    jsh.Config.debug_params.jsh_error_level = 1;
    jsh.Config.loadModels = false;
    return cb();
  });
  jsh.Init(function(){

    process.on('exit',function(){ process.exit(cliReturnCode); });
    process.on('uncaughtException', function (err) { console.log(err); });

    if(!jsh.DBConfig['default']){
      console.log('\r\nPlease configure dbconfig in '+jsh.Config.appbasepath+(scriptConfig._IS_WINDOWS?'\\':'/')+'app.config.js / app.config.local.js before running init database operation');
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
    scriptConfig.CLIENT_PORTAL = undefined;
    scriptConfig.SAMPLE_DATA = false;

    //Read command line arguments for user / pass
    for(var i=1;i<process.argv.length;i++){
      var arg = process.argv[i];
      var nextarg = '';
      if(process.argv.length > (i+1)) nextarg = process.argv[i+1];
      if(arg=='--db-user'){
        jsh.DBConfig['default'].user = nextarg;
        i++;
      }
      else if(arg=='--db-pass'){
        jsh.DBConfig['default'].password = nextarg;
        i++;
      }
      else if(arg=='--with-client-portal') scriptConfig.CLIENT_PORTAL = true;
      else if(arg=='--no-client-portal') scriptConfig.CLIENT_PORTAL = false;
      else if(arg=='--with-sample-data') scriptConfig.SAMPLE_DATA = true;
      else if(arg=='--use-ipc') scriptConfig.USE_IPC = true;
    }
  
    Promise.resolve()
  
    //Check if the database connection string works
    .then(function(){ return new Promise(function(resolve, reject){
      db.Scalar('','select 1',[],{},function(err,rslt){
        if(err){ console.log('\r\nERROR: Could not connect to database.  Please check your dbconfig in '+jsh.Config.appbasepath+(scriptConfig._IS_WINDOWS?'\\':'/')+'app.config.js / app.config.local.js'); return reject(); }
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
            console.log('Database user: ' + jsh.DBConfig['default'].user + '   (from app.config.js / params)');
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
            console.log('Database password: ******   (from app.config.js / params)');
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

    //Ask for the database type
    .then(xlib.getStringAsync(function(){
      if(typeof scriptConfig.CLIENT_PORTAL != 'undefined') return false;
      console.log('\r\nInitialize client portal?');
      console.log('1) Yes');
      console.log('2) No');
    },function(rslt,retry){
      if(rslt=="1"){ scriptConfig.CLIENT_PORTAL = true; return true; }
      else if(rslt=="2"){ scriptConfig.CLIENT_PORTAL = false; return true; }
      else{ console.log('Invalid entry.  Please enter the number of your selection'); retry(); }
    }))
  
    //Initialize Database
    .then(function(){ return new Promise(function(resolve, reject){
      console.log('');
      console.log('=============================');
      console.log('Running INIT Database Scripts');
      console.log('=============================');
      dbs.Run(['*','init','core','init'],function(){
        Helper.execif(scriptConfig.CLIENT_PORTAL, function(onComplete){
          dbs.Run(['*','init','cust','init'],function(){
            dbs.Run(['application','init'],onComplete);
          });
        },
        function(){
          dbs.Run(['*','restructure','core'],function(){
            Helper.execif(scriptConfig.CLIENT_PORTAL, function(onComplete){
              dbs.Run(['*','restructure','cust'],function(){
                dbs.Run(['application','restructure'],onComplete);
              });
            },
            function(){
              dbs.Run(['*','init_data','core'],function(){
                Helper.execif(scriptConfig.CLIENT_PORTAL, function(onComplete){
                  dbs.Run(['*','init_data','cust'],onComplete);
                },
                function(){
                  Helper.execif(scriptConfig.SAMPLE_DATA, function(onComplete){
                    dbs.Run(['*','sample_data'],onComplete);
                  },
                  resolve);
                });
              });
            });
          });
        });
      });
    }); })
  
    //Callback
    .then(function(){ return new Promise(function(resolve, reject){
      rslt += 'The jsHarmony database has been initialized!\r\n';
      rslt += '\r\n';
      rslt += '** Please verify the configuration in '+jsh.Config.appbasepath+(scriptConfig._IS_WINDOWS?'\\':'/')+'app.config.js / app.config.local.js\r\n';
      rslt += '** Be sure to configure ports and HTTPS for security\r\n';
      rslt += '\r\n';
      rslt += 'Then start the server by running '+(scriptConfig._IS_WINDOWS?'':'./')+scriptConfig._NSTART_CMD+'\r\n';
      rslt += '\r\n';
      rslt += 'Log in with the admin account below:\r\n';
      rslt += 'User: '+scriptConfig._JSH_ADMIN_EMAIL+'\r\n';
      rslt += 'Password: '+scriptConfig._JSH_ADMIN_PASS+'\r\n';
      rslt += '\r\n';
      scriptConfig.RESULT_MESSAGE = rslt;
      return resolve();
    }); })

    //Callback
    .then(function(){ return new Promise(function(resolve, reject){
      if(scriptConfig.USE_IPC && process.send){
        process.send(JSON.stringify(scriptConfig));
      }
      else {
        console.log('\r\n\r\n\r\n' + scriptConfig.RESULT_MESSAGE);
      }
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