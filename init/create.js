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
var HelperFS = require('jsharmony/HelperFS');
var jsHarmonyFactory = require('../index');
var CLI = require('jsharmony/CLI');
var fs = require('fs');

var jsh = null;
var dbs = null;
var jsHarmonyFactory_Create = {};
var cliReturnCode = 1;

var _IS_WINDOWS = /^win/.test(process.platform);
var scriptConfig = {
  _IS_WINDOWS: _IS_WINDOWS,
  _NSTART_CMD: _IS_WINDOWS ? 'nstart.cmd' : 'nstart.sh',
  DEFAULT_DB_SERVER: '___DB_SERVER___',
  DEFAULT_DB_NAME: '___DB_NAME___',
  DEFAULT_DB_USER: '___DB_USER___',
  DEFAULT_DB_PASS: '___DB_PASS___',
  DEFAULT_SQLITE_PATH: 'data/db/project.db',

  _ORIG_DBSERVER: '',
  _ORIG_DBNAME: '',
  _ORIG_DBUSER: '',
  _ORIG_DBPASS: '',
  _ORIG_DEFAULTS: true,

  _JSH_DBSERVER: '',
  _JSH_DBNAME: '',
  _JSH_DBUSER: '',
  _JSH_DBPASS: '',
  _JSH_DBTYPE: '',

  _ADMIN_DBUSER: '',
  _ADMIN_DBPASS: '',
  _JSH_ADMIN_EMAIL: '',
  _JSH_ADMIN_PASS: '',

  DB_USER_EXISTS: false,
  CLIENT_PORTAL: undefined,
  SAMPLE_DATA: false,
  SUPERVISOR: false,
  USE_IPC: false,
  USE_DEFAULT_SQLITE_PATH: false,
  PRE_CREATE: null,
  PRE_INIT: null,
  POST_INIT: null,
  RESULT_MESSAGE: '',

  sqlFuncs: [],
};

//Read args early to check whether client portal should be initialized
for(var i=1;i<process.argv.length;i++){
  var arg = process.argv[i];
  if(process.argv.length > (i+1)) nextarg = process.argv[i+1];
  if(arg=='--with-client-portal') scriptConfig.CLIENT_PORTAL = true;
  else if(arg=='--no-client-portal') scriptConfig.CLIENT_PORTAL = false;
}

function getNodeScriptParams(){
  var rslt = [];
  if(jsh.DBConfig['default'].user){ rslt.push('--db-user'); rslt.push(jsh.DBConfig['default'].user); }
  if(jsh.DBConfig['default'].password){ rslt.push('--db-pass'); rslt.push(jsh.DBConfig['default'].password); }
  return rslt;
}

jsHarmonyFactory_Create.Run = function(run_cb){

  process.on('exit',function(){ process.exit(cliReturnCode); });
  process.on('uncaughtException', function (err) { console.log(err); });

  jsh = new jsHarmonyFactory.Application({ clientPortal: !!scriptConfig.CLIENT_PORTAL });
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
    
    var db = jsh.DB['default'];
    dbs = new DatabaseScripter(jsh, scriptConfig);

    if(!jsh.DBConfig['default'] || (jsh.DBConfig['default']._driver.name=='none')){
      console.log('ERROR: No database driver defined in app.config.js');
      return;
    }
  
    scriptConfig._ORIG_DBSERVER = dbs.getDBServer();
    scriptConfig._ORIG_DBNAME = dbs.getDBName();
    scriptConfig._ORIG_DBUSER = jsh.DBConfig['default'].user || '';
    scriptConfig._ORIG_DBPASS = jsh.DBConfig['default'].password || '';
  
    scriptConfig._ORIG_DEFAULTS = true;
  
    if(scriptConfig._ORIG_DBSERVER == scriptConfig.DEFAULT_DB_SERVER) scriptConfig._ORIG_DBSERVER = '';
    else scriptConfig._ORIG_DEFAULTS = false;
  
    if(scriptConfig._ORIG_DBNAME == scriptConfig.DEFAULT_DB_NAME) scriptConfig._ORIG_DBNAME = '';
    else scriptConfig._ORIG_DEFAULTS = false;
  
    if(scriptConfig._ORIG_DBUSER == scriptConfig.DEFAULT_DB_USER){ scriptConfig._ORIG_DBUSER = ''; jsh.DBConfig['default'].user = ''; }
    else scriptConfig._ORIG_DEFAULTS = false;
  
    if(scriptConfig._ORIG_DBPASS == scriptConfig.DEFAULT_DB_PASS){ scriptConfig._ORIG_DBPASS = '';  jsh.DBConfig['default'].password = ''; }
    else scriptConfig._ORIG_DEFAULTS = false;

    scriptConfig._JSH_DBSERVER = '';
    scriptConfig._JSH_DBNAME = '';
    scriptConfig._JSH_DBUSER = '';
    scriptConfig._JSH_DBPASS = '';
    scriptConfig._JSH_DBTYPE = dbs.getDBType();
    if(scriptConfig._ORIG_DBSERVER) scriptConfig._JSH_DBSERVER = scriptConfig._ORIG_DBSERVER;
    if(scriptConfig._ORIG_DBNAME) scriptConfig._JSH_DBNAME = scriptConfig._ORIG_DBNAME;
    if(scriptConfig._ORIG_DBUSER) scriptConfig._JSH_DBUSER = scriptConfig._ORIG_DBUSER;
    if(scriptConfig._ORIG_DBPASS) scriptConfig._JSH_DBPASS = scriptConfig._ORIG_DBPASS;
  
    scriptConfig._ADMIN_DBUSER = '';
    scriptConfig._ADMIN_DBPASS = '';
    scriptConfig._JSH_ADMIN_EMAIL = '';
    scriptConfig._JSH_ADMIN_PASS = '';
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
      else if(arg=='--admin-pass'){
        scriptConfig._JSH_ADMIN_PASS = nextarg;
        i++;
      }
      else if(arg=='--with-sample-data') scriptConfig.SAMPLE_DATA = true;
      else if(arg=='--with-supervisor') scriptConfig.SUPERVISOR = true;
      else if(arg=='--use-ipc') scriptConfig.USE_IPC = true;
      else if(arg=='--use-default-sqlite-path') scriptConfig.USE_DEFAULT_SQLITE_PATH = true;
      else if(arg=='--pre-create'){ scriptConfig.PRE_CREATE = nextarg; i++; }
      else if(arg=='--pre-init'){ scriptConfig.PRE_INIT = nextarg; i++; }
      else if(arg=='--post-init'){ scriptConfig.POST_INIT = nextarg; i++; }
    }
  
    Promise.resolve()

    //Get database information
    .then(function(){ return new Promise(function(login_resolve, login_reject){
      if(_.includes(['sqlite'],scriptConfig._JSH_DBTYPE)) return login_resolve();
  
      var try_login = function(){
  
        console.log('\r\n===================================');
        console.log('Please enter a database admin login');
        console.log('===================================');
  
        Promise.resolve()
  
        //Ask for the database server
        .then(CLI.getStringAsync(function(){
          if(scriptConfig._ORIG_DBSERVER){
            console.log('Database server: ' + scriptConfig._ORIG_DBSERVER + '   (from app.config.js)');
            return false;
          }
  
          process.stdout.write('Please enter the database server: ');
        },function(rslt,retry){
            if(rslt){ dbs.setDBServer(rslt); return true; }
            else{ process.stdout.write('Invalid entry.  Please enter a valid database server: '); retry(); }
        }))
  
        .then(function(){ return new Promise(function(resolve, reject){
          dbs.setDBName('');
          resolve();
        }); })

        //Ask for the database admin user
        .then(CLI.getStringAsync(function(){
          if(jsh.DBConfig['default'].user){
            console.log('Database user: ' + jsh.DBConfig['default'].user + '   (from app.config.js / params)');
            return false;
          }
          process.stdout.write('Please enter an ADMIN database user for running the scripts: ');
        },function(rslt,retry){
            if(rslt){ jsh.DBConfig['default'].user = rslt; return true; }
            else{ process.stdout.write('Invalid entry.  Please enter a valid database user: '); retry(); }
        }))
  
        //Ask for admin user
        .then(CLI.getStringAsync(function(){
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
                return reject();
              });
            });
          });
        }); })
  
        .then(function(){
          scriptConfig._JSH_DBSERVER = dbs.getDBServer();
          scriptConfig._ADMIN_DBUSER = jsh.DBConfig['default'].user;
          scriptConfig._ADMIN_DBPASS = jsh.DBConfig['default'].password;
          return login_resolve();
        })

        .catch(function(err){
          if(err) console.log(err);
          else try_login();
        });
  
      }; //END try_login
      try_login();
  
    }); })

    //Ask for the NEW database path, if applicable
    .then(CLI.getStringAsync(function(){
      if(scriptConfig._JSH_DBTYPE != 'sqlite') return false;
      if(scriptConfig.USE_DEFAULT_SQLITE_PATH){
        return '';
      }
      if(scriptConfig._JSH_DBNAME){
        console.log('NEW Database path: ' + scriptConfig._JSH_DBNAME + '   (from app.config.js)');
        var dbpath = path.resolve(scriptConfig._JSH_DBNAME);
        var dbfolder = path.dirname(dbpath);
        HelperFS.createFolderRecursiveSync(dbfolder);
        HelperFS.touchSync(dbpath);
        return false;
      }
      process.stdout.write('NEW database path ['+scriptConfig.DEFAULT_SQLITE_PATH+']: ');
    },function(rslt,retry){
        if(!rslt) rslt = scriptConfig.DEFAULT_SQLITE_PATH;
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
        scriptConfig._JSH_DBNAME = rslt;
        dbs.setDBName(scriptConfig._JSH_DBNAME);
        return true;
    }))
  
    //Ask for the NEW database name, if applicable
    .then(CLI.getStringAsync(function(){
      if(scriptConfig._JSH_DBTYPE == 'sqlite') return false;
      if(scriptConfig._JSH_DBNAME){
        console.log('NEW Database name: ' + scriptConfig._JSH_DBNAME + '   (from app.config.js)');
        return false;
      }
      process.stdout.write('Please enter the NEW database name: ');
    },function(rslt,retry){
        if(rslt){ scriptConfig._JSH_DBNAME = rslt; return true; }
        else{ process.stdout.write('Invalid entry.  Please enter a valid database name: '); retry(); }
    }))

    //Check if the database user already exists
    .then(function(){ return new Promise(function(resolve, reject){
      if(scriptConfig._JSH_DBTYPE == 'sqlite') return resolve();
      if(!scriptConfig._JSH_DBUSER) scriptConfig._JSH_DBUSER = 'jsharmony_'+scriptConfig._JSH_DBNAME.toLowerCase()+'_user';
      if(!scriptConfig._JSH_DBPASS) scriptConfig._JSH_DBPASS = CLI.genDBPassword(16);
      
      db.Scalar('',db.ParseSQLFuncs(db.ParseSQL('init_db_user_exists'), dbs.getSQLFuncs()),[],{},function(err,rslt){
        db.Close(function(){
          if(!err && rslt && (rslt.toString()=="1")){
            scriptConfig._JSH_DBPASS = '';
            scriptConfig.DB_USER_EXISTS = true;
          }
          return resolve();
        });
      });
    }); })

    //Run Pre-Create Script
    .then(function(){ return new Promise(function(resolve, reject){
      if(!scriptConfig.PRE_CREATE) return resolve();
      if(fs.existsSync(scriptConfig.PRE_CREATE)){
        CLI.runNodeScript(scriptConfig.PRE_CREATE,getNodeScriptParams(),{},function(errCode){
          if(!errCode) return resolve();
        });
        return;
      }
      else return reject(console.log('pre-create script not found'));
    }); })
  
    //Create Database
    .then(function(){ return new Promise(function(resolve, reject){
      console.log('');
      console.log('===============================');
      console.log('Running CREATE Database Scripts');
      console.log('===============================');
      dbs.Run(['*','init','core','create'],resolve);
    }); })
  
    //*** Update connection string in app.config.js
    .then(function(){ return new Promise(function(resolve, reject){
      function updateConfig(fname){
        if(!fs.existsSync(fname)) return;
        if(scriptConfig._ORIG_DEFAULTS || true){
          var curconfig = fs.readFileSync(fname,'utf8');
          scriptConfig._ORIG_DEFAULTS = false;
    
          if(_.includes(['sqlite'],scriptConfig._JSH_DBTYPE)){
            if(
              ((curconfig.match(new RegExp(scriptConfig.DEFAULT_DB_NAME,'g')) || []).length==1)){
              console.log('Updating '+fname);
              curconfig = curconfig.replace(scriptConfig.DEFAULT_DB_NAME, Helper.escapeJS(scriptConfig._JSH_DBNAME));
              fs.writeFileSync(fname, curconfig, 'utf8');
              scriptConfig._ORIG_DEFAULTS = true;
            }
          }
          else if(_.includes(['pgsql','mssql'],scriptConfig._JSH_DBTYPE)){
            if(
              ((curconfig.match(new RegExp(scriptConfig.DEFAULT_DB_SERVER,'g')) || []).length==1) &&
              ((curconfig.match(new RegExp(scriptConfig.DEFAULT_DB_NAME,'g')) || []).length==1) &&
              ((curconfig.match(new RegExp(scriptConfig.DEFAULT_DB_USER,'g')) || []).length==1) &&
              ((curconfig.match(new RegExp(scriptConfig.DEFAULT_DB_PASS,'g')) || []).length==1)){
              console.log('Updating '+fname);
              curconfig = curconfig.replace(scriptConfig.DEFAULT_DB_SERVER, Helper.escapeJS(scriptConfig._JSH_DBSERVER));
              curconfig = curconfig.replace(scriptConfig.DEFAULT_DB_NAME, Helper.escapeJS(scriptConfig._JSH_DBNAME));
              curconfig = curconfig.replace(scriptConfig.DEFAULT_DB_USER, Helper.escapeJS(scriptConfig._JSH_DBUSER));
              curconfig = curconfig.replace(scriptConfig.DEFAULT_DB_PASS, Helper.escapeJS(scriptConfig._JSH_DBPASS));
              fs.writeFileSync(fname, curconfig, 'utf8');
              scriptConfig._ORIG_DEFAULTS = true;
            }
          }
        }
      }
      updateConfig(jsh.Config.appbasepath+'/app.config.js');
      updateConfig(jsh.Config.appbasepath+'/app.config.local.js');
      dbs.setDBName(scriptConfig._JSH_DBNAME);
      db.Close(function(){
        resolve();
      });
    }); })

    //Run Pre-Init Script
    .then(function(){ return new Promise(function(resolve, reject){
      if(!scriptConfig.PRE_INIT) return resolve();
      if(fs.existsSync(scriptConfig.PRE_INIT)){
        CLI.runNodeScript(scriptConfig.PRE_INIT,getNodeScriptParams(),{},function(errCode){
          if(!errCode) return resolve();
        });
        return;
      }
      else return reject(console.log('pre-init script not found'));
    }); })
  
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

    //Run Post-Init Script
    .then(function(){ return new Promise(function(resolve, reject){
      if(!scriptConfig.POST_INIT) return resolve();
      if(fs.existsSync(scriptConfig.POST_INIT)){
        CLI.runNodeScript(scriptConfig.POST_INIT,getNodeScriptParams(),{},function(errCode){
          if(!errCode) return resolve();
        });
        return;
      }
      else return reject(console.log('post-init script not found'));
    }); })

    .then(function(){ return new Promise(function(resolve, reject){
      var rslt = '';
      if(!scriptConfig._ORIG_DEFAULTS &&
        ((scriptConfig._ORIG_DBSERVER != scriptConfig._JSH_DBSERVER) ||
        (scriptConfig._ORIG_DBNAME != scriptConfig._JSH_DBNAME) ||
        (scriptConfig._ORIG_DBUSER != scriptConfig._JSH_DBUSER) ||
        ((scriptConfig._ORIG_DBPASS != scriptConfig._JSH_DBPASS) && !scriptConfig.DB_USER_EXISTS) ||
        (!scriptConfig._ORIG_DBPASS && scriptConfig.DB_USER_EXISTS))
      ){
        //*** If did not update app.config.js, show results and tell user to update app.config.js on their own 
        rslt += '------------------------------------------------\r\n';
        rslt += 'Please update dbconfig in '+jsh.Config.appbasepath+(scriptConfig._IS_WINDOWS?'\\':'/')+'app.config.js & app.config.local.js with the following database connection information:\r\n';
        rslt += '------------------------------------------------\r\n';
        if(_.includes(['pgsql','mssql'],scriptConfig._JSH_DBTYPE)) rslt += 'SERVER: ' + scriptConfig._JSH_DBSERVER + '\r\n';
        rslt += 'DATABASE: ' + scriptConfig._JSH_DBNAME + '\r\n';
        if(_.includes(['pgsql','mssql'],scriptConfig._JSH_DBTYPE)) rslt += 'USER: ' + scriptConfig._JSH_DBUSER + '\r\n';
        if(_.includes(['pgsql','mssql'],scriptConfig._JSH_DBTYPE) && !scriptConfig.DB_USER_EXISTS) rslt += 'PASSWORD: ' + scriptConfig._JSH_DBPASS + '\r\n';
        if(scriptConfig.DB_USER_EXISTS) rslt += 'DATABASE USER '+scriptConfig._JSH_DBUSER+' ALREADY EXISTED - PLEASE BE SURE TO ENTER THE PASSWORD IN app.config.js & app.config.local.js\r\n';
        rslt += '------------------------------------------------\r\n';
      }
      else {
        rslt += 'The jsHarmony database has been created!\r\n';
        rslt += '\r\n';
        rslt += '** Please verify the configuration in '+jsh.Config.appbasepath+(scriptConfig._IS_WINDOWS?'\\':'/')+'app.config.js & app.config.local.js\r\n';
        rslt += '** Be sure to configure ports and HTTPS for security\r\n';
        rslt += '\r\n';
        if(scriptConfig.DB_USER_EXISTS){
          rslt += '------------------------------------------------\r\n';
          rslt += 'DATABASE USER '+scriptConfig._JSH_DBUSER+' ALREADY EXISTED\r\n';
          rslt += 'PLEASE BE SURE TO ENTER THE PASSWORD IN '+jsh.Config.appbasepath+(scriptConfig._IS_WINDOWS?'\\':'/')+'app.config.js & app.config.local.js\r\n';
          rslt += '------------------------------------------------\r\n';
          rslt += '\r\n';
        }
      }
      rslt += 'Then start the server by running:\r\n';
      if(scriptConfig.SUPERVISOR){
        rslt += '  '+(scriptConfig._IS_WINDOWS?'':'./')+scriptConfig._NSTART_CMD+'\r\n';
        rslt += '  or\r\n';
      }
      rslt += '  node '+(scriptConfig._IS_WINDOWS?'':'./')+'app.js\r\n';
      rslt += '\r\n';
      rslt += 'Log in with the admin account below:\r\n';
      rslt += 'User: '+scriptConfig._JSH_ADMIN_EMAIL+'\r\n';
      rslt += 'Password: '+scriptConfig._JSH_ADMIN_PASS+'\r\n';
      rslt += '\r\n';
      scriptConfig.RESULT_MESSAGE = rslt;
      resolve();
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

//Check whether Client Portal should be initialized - required before loading SQL
Promise.resolve()
.then(CLI.getStringAsync(function(){
  if(typeof scriptConfig.CLIENT_PORTAL != 'undefined') return false;
  console.log('\r\nInitialize client portal?');
  console.log('1) Yes');
  console.log('2) No');
},function(rslt,retry){
  if(rslt=="1"){ scriptConfig.CLIENT_PORTAL = true; return true; }
  else if(rslt=="2"){ scriptConfig.CLIENT_PORTAL = false; return true; }
  else{ console.log('Invalid entry.  Please enter the number of your selection'); retry(); }
}))
.then(function(resolve, reject){
  setTimeout(function(){ jsHarmonyFactory_Create.Run() }, 1);
});