/*
Copyright 2022 apHarmony

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

  exports.SCHEDULED_TASK_RUNNER = function (req, res, next) {
    var verb = req.method.toLowerCase();
    if (!req.body) req.body = {};
    
    var Q = req.query;
    var P = req.body;
   
    var jsh = module.jsh;
    var XValidate = jsh.XValidate;
    var appsrv = jsh.AppSrv;
    var model = jsh.getModel(req, module.namespace + funcs._transform('Admin/Scheduled_Task_Runner'));
    
    if (!Helper.hasModelAction(req, model, 'B')) { Helper.GenError(req, res, -11, 'Invalid Model Access'); return; }
    
    var scheduled_tasks = jsh.AppSrv.JobProc.jshFactory.Config.scheduled_tasks;

    if (verb == 'get') {
      res.type('json');
      res.end(JSON.stringify({ _success: 1, scheduled_tasks: scheduled_tasks ? Object.keys(scheduled_tasks) : [] }));
      return;
    }
    else if (verb == 'post') {
      if (!appsrv.ParamCheck('Q', Q, [])) { Helper.GenError(req, res, -4, 'Invalid Parameters'); return; }
      if (!appsrv.ParamCheck('P', P, ['&task_id'])) { return Helper.GenError(req, res, -4, 'Invalid Parameters'); }
      
      var validate = new XValidate();

      validate.AddValidator('_obj.task_id', 'Subcategory ID', 'B', [XValidate._v_Required()]);

      var verrors = _.merge({}, validate.Validate('B', req.body));
      if (!_.isEmpty(verrors)) { Helper.GenError(req, res, -2, verrors[''].join('\n')); return; }

      var task_id = P.task_id;
      if (!scheduled_tasks || !scheduled_tasks[task_id]) {
        return Helper.GenError(req, res, -9, 'Scheduled task "'+task_id+'" not found');
      }
      else {
        var scheduled_task = scheduled_tasks[task_id];
        if (!('action' in scheduled_task)) {
          return Helper.GenError(req, res, -9, 'Scheduled task "'+task_id+'" does not have an action defined');
        }
        var task_options = _.extend({}, scheduled_task.options, { run_type: 'manual' });
        scheduled_task.action(jsh.AppSrv.JobProc, task_options);
        res.type('json');
        res.end(JSON.stringify({ _success: 1 }));
        return;
      }
    }

    return next();
  };

  return exports;
};
