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

  exports.DEV_EMAILTEST = function (req, res, next) {

    var verb = req.method.toLowerCase();
    if (!req.body) req.body = {};
    
    var Q = req.query;
    var P = req.body||{};
    var jsh = module.jsh;
    var appsrv = jsh.AppSrv;
    var model = jsh.getModel(req, module.namespace + 'Dev/EmailTest');
    var XValidate = jsh.XValidate;
    
    if (!Helper.hasModelAction(req, model, 'B')) { Helper.GenError(req, res, -11, 'Invalid Model Access'); return; }

    if (verb == 'post') {
      if (!appsrv.ParamCheck('Q', Q, [])) { Helper.GenError(req, res, -4, 'Invalid Parameters'); return; }
      if (!appsrv.ParamCheck('P', P, ['&to','&subject','&body'])) { Helper.GenError(req, res, -4, 'Invalid Parameters'); return; }

      var validate = new XValidate();
      var verrors = {};
      validate.AddValidator('_obj.to', 'To Address', 'B', [XValidate._v_IsEmail(), XValidate._v_Required()]);
      validate.AddValidator('_obj.subject', 'Subject', 'B', [XValidate._v_Required()]);
      validate.AddValidator('_obj.body', 'Body', 'B', [XValidate._v_Required()]);
      verrors = _.merge(verrors, validate.Validate('B', P));
      if (!_.isEmpty(verrors)) { Helper.GenError(req, res, -2, verrors[''].join('\n')); return; }

      jsh.SendBaseEmail(req._DBContext, P.subject, P.body, P.body, P.to, undefined, undefined, undefined, {}, function(err){
        if (err) { return Helper.GenError(req, res, -99999, err.toString()); }
        res.end(JSON.stringify({ _success: 1 }));
      });
      return;
    }
    return next();
  };

  return exports;
};
