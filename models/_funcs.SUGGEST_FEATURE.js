/*
Copyright 2021 apHarmony

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

module.exports = exports = function(module, funcs){
  var exports = {};

  exports.SUGGEST_FEATURE = function (req, res, next) {

    var verb = req.method.toLowerCase();
    if (!req.body) req.body = {};

    var Q = req.query;
    var P = req.body;

    var jsh = module.jsh;
    var appsrv = this;
    var dbtypes = appsrv.DB.types;

    //Validate parameters
    if (!appsrv.ParamCheck('P', P, ['&message_text'])) { Helper.GenError(req, res, -4, 'Invalid Parameters'); return; }
    if (!appsrv.ParamCheck('Q', Q, [])) { Helper.GenError(req, res, -4, 'Invalid Parameters'); return; }

    if (!req.isAuthenticated) { Helper.GenError(req, res, -10, 'Please log in to send a message'); return; }

    var factoryConfig = jsh.Config.modules['jsHarmonyFactory'];
    if (!factoryConfig.suggest_feature.enabled) { Helper.GenError(req, res, -1, 'Suggest a Feature is disabled'); return; }

    if (req.method == 'POST') {
      var _this = this;
      var sys_user_name = 'an unknown user';
      var accountCookie = Helper.GetCookie(req, jsh, 'account');
      if(accountCookie){
        if('username' in accountCookie) sys_user_name = accountCookie.username;
      }

      // ----------------------- email -------------------
      var suggest_feature_email = factoryConfig.suggest_feature.email || jsh.Config.support_email;
      if(!suggest_feature_email) { Helper.GenError(req, res, -99999, 'Suggest a Feature requires either jsHarmony Config support_email or Factory Config suggest_feature.email to be configured'); return; }
      var email_params = {
        'SYS_USER_NAME': sys_user_name,
        'MESSAGE_TEXT': P.message_text,
        'URL': req.header('Referer')
      };
      jsh.SendTXTEmail(req._DBContext, 'SUGGEST_FEATURE', suggest_feature_email, null, null, null, email_params, function (err) {
        if (err) { jsh.Log.error(err); return res.end('An error occurred sending the feature suggestion email.  Please contact support for assistance.'); }
        res.end(JSON.stringify({
          '_success': 1,
        }));
      });

      // ----------------------- audit -------------------
      var sql_ptypes = [
        dbtypes.VarChar(dbtypes.MAX)
      ];
      var sql_params = {
        audit_column_val: P.message_text + ' :: ' + (req.header('Referer')||'')
      };

      var sql = "jsharmony.log_audit_other('SUGGEST_FEATURE',0,1=1,'message_text',@audit_column_val)"
      appsrv.ExecCommand('S1', sql, sql_ptypes, sql_params, function(err, dbrslt, stats) {
        if(err) return console.log(err);
      });

      return;
    }

    return next();
  }

  return exports;
};

