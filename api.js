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
var _ = require('lodash');
var async = require('async');

function jsHarmonyFactoryAPI(options){
  this.options = _.extend({ db: 'default' }, options);
  if(!this.options.db) this.options.db = 'default';
  //Load Config
  this.jsh = new jsHarmonyFactory.Application();
  this.jsh.Config.appbasepath = process.cwd();
  this.jsh.Config.silentStart = true;
}
jsHarmonyFactoryAPI.prototype.Init = function(cb){
  var _this = this;
  _this.jsh.Init(function(){
    _this.db = _this.jsh.DB[_this.options.db];
    _this.codegen = new jsHarmonyCodeGen(_this.jsh);
    if(cb) return cb();
  });
}
//Execute DB Operation
jsHarmonyFactoryAPI.prototype.dbTest = function(onComplete){
  this.db.Scalar('','select 1',[],{},function(err,rslt){
    if(err){ console.log('\r\nERROR: Could not connect to database.  Please check your database config in app.config.js & app.config.local.js and try again by running:\r\nnpm run -s init-factory'); return onComplete(err); }
    if(rslt && (rslt.toString()=="1")){
      return onComplete();
    }
 });
}
jsHarmonyFactoryAPI.prototype.dbClose = function(onComplete){
  var _this = this;
  async.eachOf(_this.jsh.DB, function(db, dbid, cb){
    db.Close(cb);
  }, onComplete);
}

module.exports = exports = jsHarmonyFactoryAPI;