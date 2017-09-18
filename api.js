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

var jsHarmonyFactory = require('./index.js');
var jsHarmony = require('jsharmony');
var jsHarmonyCodeGen = require('jsharmony/CodeGen');
var JSHdb = require('jsharmony-db');
var path = require('path');

function jsHarmonyFactoryAPI(){
  //Load Settings
  if(!global.jsHarmonyFactorySettings_Loaded) jsHarmonyFactory.LoadSettings();

  //Initialize DB Components
  var path_models_sql = path.join(path.dirname(module.filename),'./models/sql/');
  this.sqlbase = {};
  this.db = new JSHdb();
  this.sqlbase = jsHarmony.LoadSQL(path_models_sql,global.dbconfig._driver.name);
  this.codegen = new jsHarmonyCodeGen(this.db);
}
//Execute DB Operation
jsHarmonyFactoryAPI.prototype.dbTest = function(onComplete){
  this.db.Scalar('','select 1',[],{},function(err,rslt){
    if(err){ console.log('\r\nERROR: Could not connect to database.  Please check your global.dbconfig in app.settings.js and try again by running:\r\nnpm run -s init-factory'); return onComplete(err); }
    if(rslt && (rslt.toString()=="1")){
      return onComplete();
    }
 });
}
jsHarmonyFactoryAPI.prototype.dbClose = function(onComplete){
  this.db.Close(function(){ if(onComplete) onComplete(); });
}

module.exports = exports = jsHarmonyFactoryAPI;