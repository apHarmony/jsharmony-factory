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

var DatabaseScripter = require('./database.js')();

var jsHarmonyFactory_Init = {};
global.cliReturnCode = 1;

jsHarmonyFactory_Init.Run = function(run_cb){
  global.appbasepath = process.cwd();
  process.on('exit',function(){ process.exit(global.cliReturnCode); });

  Promise.resolve()

  //Ask for DB Server

  //Ask for DB Name

  //Create Database
  .then(function(){ return new Promise(function(resolve, reject){
    DatabaseScripter.Run('create',resolve);
  }); })

  //*** Restart if invalid DB Server / Name

  //Initialize Database
  .then(function(){ return new Promise(function(resolve, reject){
    DatabaseScripter.Run('init',resolve);
  }); })

  //Update Connection String, if applicable

  //Callback
  .then(function(){
    global.cliReturnCode = 0; //Success
    if(run_cb) run_cb();
  });
}
  
jsHarmonyFactory_Init.Run();