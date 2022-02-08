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

var Helper = require('jsharmony/Helper');
var _ = require('lodash');

module.exports = exports = function(module, funcs){
  var exports = {};

  exports.DEV_MODELS = function (req, res, next) {

    var verb = req.method.toLowerCase();
    if (!req.body) req.body = {};
    
    var Q = req.query;
    var P = {};
    if (req.body && ('data' in req.body)){
      try{ P = JSON.parse(req.body.data); }
      catch(ex){ Helper.GenError(req, res, -4, 'Invalid Parameters'); return; }
    }
    var jsh = module.jsh;
    var appsrv = jsh.AppSrv;
    var model = jsh.getModel(req, module.namespace + funcs._transform('Dev/Models'));
    
    if (!Helper.hasModelAction(req, model, 'B')) { Helper.GenError(req, res, -11, 'Invalid Model Access'); return; }

    if (verb == 'get') {
      if (!appsrv.ParamCheck('Q', Q, ['&action'])) { Helper.GenError(req, res, -4, 'Invalid Parameters'); return; }
      if (!appsrv.ParamCheck('P', P, [])) { Helper.GenError(req, res, -4, 'Invalid Parameters'); return; }

      var actions = ['namespace_conflicts','auto_controls'];

      if (!_.includes(actions, Q.action)) { Helper.GenError(req, res, -4, 'Invalid Parameters'); return; }

      if(Q.action=='namespace_conflicts'){
        appsrv.ExecRecordset(req._DBContext, 'select '+funcs._transform('menu_cmd')+','+funcs._transform('menu_name')+' from '+module.schema+'.'+funcs._transform('menu__tbl')+' order by '+funcs._transform('menu_cmd'), [], {}, function(err, rslt){
          var menumodels = {};
          if(rslt && rslt[0]){
            _.each(rslt[0], function(row){
              menumodels[row[funcs._transform('menu_cmd')]] = row[funcs._transform('menu_name')];
            });
          }
          var fullmodelids = _.keys(jsh.Models);
          var basenames = {};
          _.each(fullmodelids, function(fullmodelid){
            var basename = jsh.getBaseModelName(fullmodelid);
            if(!(basename in basenames)) basenames[basename] = [];
            basenames[basename].push(fullmodelid);
          });
          var conflicts = {};
          var sortedbasenames = _.keys(basenames);
          sortedbasenames.sort();
          for(var i=0;i<sortedbasenames.length;i++){
            var basename = sortedbasenames[i];
            if(basenames[basename].length > 1){
              conflicts[basename] = {};
              _.each(basenames[basename], function(fullmodelid){
                var model = jsh.getModel(null, fullmodelid);
                var namespace = model.namespace;
                conflicts[basename][fullmodelid] = [];
                _.each(model._referencedby, function(fullreferencemodelid){
                  if(jsh.getNamespace(fullreferencemodelid) != namespace){
                    fullreferencemodelid = '[RED]'+fullreferencemodelid+'[/RED]';
                  }
                  conflicts[basename][fullmodelid].push(fullreferencemodelid);
                });
                if(fullmodelid in menumodels) conflicts[basename][fullmodelid].push('[RED]Menu: '+menumodels[fullmodelid]+'[/RED]');
              });
            }
          }
          res.end(JSON.stringify({ _success: 1, conflicts: conflicts }));
        });
      }
      else if(Q.action=='auto_controls'){
        var auto_controls = [];
        _.each(jsh.Models, function(model, modelid){
          _.each(model.fields, function(field){
            if(model.layout=='grid'){
              if(field._auto.actions && (field._auto.control || !('control' in field))) auto_controls.push(model.id + ':' + (field.name||JSON.stringify(field)));
            }
            else{
              if(field._auto.control){
                auto_controls.push(model.id + ':' + (field.name||JSON.stringify(field)));
              }
            }
          });
        });
        res.end(JSON.stringify({ _success: 1, content: auto_controls }));
      }
      
      return;
    }

    return next();
  };

  return exports;
};
