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

var wclib = require('jsharmony/WebConnect.js');
var wc = new wclib.WebConnect();
var xlib = wclib.xlib;
var JSHdb = require('jsharmony-db');
var db = null;
var jsHarmonyFactory = require('../index');

exports = module.exports = {};

exports.Run = function(run_cb){
  Promise.resolve()

  //Check if the database connection string works
  .then(function(){ return new Promise(function(resolve, reject){
    console.log('\r\nTesting database connection');
    //Load app.settings.js and parse inheritance
    if(!global.jsHarmonyFactorySettings_Loaded) jsHarmonyFactory.LoadSettings();
    //Load database driver
    db = new JSHdb();
    //db.Recordset('','select * from C where C_ID >= @C_ID',[JSHdb.types.BigInt],{'C_ID': 10},function(err,rslt){
    db.Scalar('','select 1',[],{},function(err,rslt){
      if(err){ console.log('\r\nERROR: Could not connect to database.  Please check your global.dbconfig in app.settings.js and try again.'); return reject(); }
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
    if(rslt=="1"){ }
    else if(rslt=="2"){ process.exit(1); }
    else{ console.log('Invalid entry.  Please enter the number of your selection'); retry(); return false; }
  }))*/

  //Creating tables
  .then(function(){ return new Promise(function(resolve, reject){
    console.log('\r\nCreating tables...');
    //db.Recordset('','select * from C where C_ID >= @C_ID',[JSHdb.types.BigInt],{'C_ID': 10},function(err,rslt){
    db.Scalar('','select 2',[],{},function(err,rslt){
      if(err){ console.log('\r\nERROR: Error initializing database: '+err.toString()); return reject(); }
      console.log('OK');
      resolve();
    });
  }); })

  //Callback
  .then(function(){
    db.Close(function(){ if(run_cb) run_cb(); });
  })

  .catch(function(err){
    if(err) console.log(err);
    db.Close();
    process.exit(1);
  });
}
