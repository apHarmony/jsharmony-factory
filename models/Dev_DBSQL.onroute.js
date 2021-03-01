//(routetype, req, res, callback, require, jsh, modelid, params)
var _ = require('lodash');
var Helper = require('../Helper.js');

if(routetype != 'model') return callback();

var model = jsh.getModelClone(req, modelid);
if (!Helper.hasModelAction(req, model, 'B')) { Helper.GenError(req, res, -11, 'Invalid Model Access'); return; }

var dbs = {};
for(var dbid in jsh.DB) dbs[dbid] = jsh.DB[dbid].dbconfig._driver.name;
model.oninit = "jsh.App[modelid].DBs = "+JSON.stringify(dbs)+";"+model.oninit;
if(req.query.table){
  if(jsh.DB[dbid] && jsh.DB[dbid].schema_definition && jsh.DB[dbid].schema_definition.tables){
    var tableName = req.query.table;
    var tableDef = jsh.DB[dbid].schema_definition.tables[tableName];
    if(!tableDef) tableDef = jsh.DB[dbid].schema_definition.tables['.'+tableName];
    model.oninit = 'jsh.App[modelid].TABLE_DEF = '+JSON.stringify(tableDef)+';'+model.oninit;

    var tableObject = null;
    var tableModule = null;
    if(jsh.DB[dbid].SQLExt && jsh.DB[dbid].SQLExt.Objects){
      _.each(jsh.DB[dbid].SQLExt.Objects, function(moduleObjects, moduleName){
        _.each(moduleObjects, function(sqlObject){
          if(sqlObject.type != 'table') return;
          if(!sqlObject.columns) return;
          var sqlObjectName = sqlObject.name;
          if(jsh.DB[dbid].getType()=='sqlite') sqlObjectName = Helper.ReplaceAll(sqlObjectName, '.', '_');
          if(sqlObjectName == tableName){
            tableObject = sqlObject;
            tableModule = jsh.Modules[moduleName];
          }
        });
      });
    }
    var tableInit = '';
    if(tableObject){
      var tableClone = JSON.parse(JSON.stringify(tableObject));
      tableClone.name = 'TABLENAME';
      tableInit = jsh.DB[dbid].sql.object.init(jsh, tableModule, tableClone);
    }
    model.oninit = 'jsh.App[modelid].TABLE_OBJ = '+JSON.stringify(tableClone)+';'+model.oninit;
    model.oninit = 'jsh.App[modelid].TABLE_INIT = '+JSON.stringify(tableInit)+';'+model.oninit;
    
  }
}
//Save model to local request cache
req.jshlocal.Models[modelid] = model;
return callback();