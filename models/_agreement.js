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

var HelperRender = require('jsharmony/HelperRender');
var async = require('async');
var XValidate = require('jsharmony-validate');
var _ = require('lodash');
var Helper = require('jsharmony/Helper');
var crypto = require('crypto');

exports = module.exports = {};

exports.check = function (req, res, next) {
  var _this = this;
  if (!req.gdata[_this.jsh.map.client_agreement_tstmp]) {
    return this.jsh.Redirect302(res, req.baseurl + 'agreement/');
  }
  next();
}

exports.welcome = function (req, res, next) {
  var _this = this;
  var verb = req.method.toLowerCase();
  if (verb !== 'get') return next();
  
  var cms_welcome = '';
  var appsrv = this;
  async.series([
    function (cb) { HelperRender.getTXT(req, res, appsrv, 'agreement', 'CMS', 'AGREEMENT_DONE', function (rslt) { cms_welcome = rslt; cb(); }) },
    function (cb) {
      var params = {};
      req.jshconfig.menu(req, res, _this.jsh, params, function () {
        HelperRender.reqGet(req, res, _this.jsh, 'welcome', 'Welcome', { basetemplate: 'client', TopMenu: '', XMenu: params.XMenu, params: { cms_welcome: cms_welcome, req: req } }, cb);
      });
    }
  ]);
}

exports.form = function (req, res, next) {
  var _this = this;
  var verb = req.method.toLowerCase();
  if (verb !== 'get') return next();
  
  if (req.gdata[_this.jsh.map.client_agreement_tstmp]) { return _this.jsh.Redirect302(res, req.baseurl); }
  
  req.bcrumb_override = '<a href="' + global.home_url + '/">Home</a> &gt; User Agreement';
  //Get cms_join_text from database
  var cms_agreement = '';
  var COD_STATE = [];
  var COD_MONTH = [];
  var COD_YEAR = [];
  var appsrv = _this;
  var blank_code = {};
  blank_code[_this.jsh.map.codeval] = '';
  blank_code[_this.jsh.map.codetxt] = '';
  async.series([
    function (cb) { HelperRender.getTXT(req, res, appsrv, 'agreeement', 'CMS', 'AGREEMENT', function (rslt) { cms_agreement = rslt; cb(); }) },
    function (cb) { HelperRender.getDBRecordset(req, res, appsrv, 'join', "agreement_COD_STATE", [], {}, function (rslt) { COD_STATE = rslt; COD_STATE.unshift(blank_code); cb(); }) },
    function (cb) { HelperRender.getDBRecordset(req, res, appsrv, 'join', "agreement_COD_MONTH", [], {}, function (rslt) { COD_MONTH = rslt; COD_MONTH.unshift(blank_code); cb(); }) },
    function (cb) { HelperRender.getDBRecordset(req, res, appsrv, 'join', "agreement_COD_YEAR", [], {}, function (rslt) { COD_YEAR = rslt; COD_YEAR.unshift(blank_code); cb(); }) },
    function (cb) { HelperRender.reqGet(req, res, _this.jsh, 'agreement.form', 'User Agreement', { basetemplate: 'public', TopMenu: 'join', params: { cms_agreement: cms_agreement, COD_STATE: COD_STATE, COD_MONTH: COD_MONTH, COD_YEAR: COD_YEAR } }, cb); }
  ]);
}

exports.sign = function (req, res, next) {
  //Function to create new C_PRE
  var verb = req.method.toLowerCase();
  if (verb !== 'post') return next();
  
  var Q = req.query;
  var P = req.body;
  var appsrv = this;
  var jsh = this.jsh;
  
  var fields = {
    "A_Name": { "caption": "Signed Name", "actions": "I", "type": "varchar", "length": 72, "validators": [XValidate._v_Required(), XValidate._v_MaxLength(72)] },
    "A_DOB": { "caption": "Date of Birth", "actions": "I", "type": "date", "validators": [XValidate._v_Required(), XValidate._v_MaxLength(10), XValidate._v_IsDate(), XValidate._v_IsValidDOB()] }
  }
  
  //Validate Parameters
  if (!appsrv.ParamCheck('Q', Q, [])) { Helper.GenError(req, res, -4, 'Invalid Parameters'); return; }
  if (!appsrv.ParamCheck('P', P, _.map(fields, function (val, key) { return '&' + key; }))) { Helper.GenError(req, res, -4, 'Invalid Parameters'); return; }
  
  var sql = '';
  var sql_ptypes = [];
  var sql_params = {};
  var verrors = {};
  var dbtypes = appsrv.DB.types;
  var validate = new XValidate();
  
  //sql = "update C set C_ATstmp=getdate() where C_ID=@C_ID";
  sql = "agreement_sign";
  sql_ptypes.push(dbtypes.BigInt, dbtypes.VarChar(dbtypes.MAX));
  sql_params['C_ID'] = req.gdata[jsh.map.client_id];
  sql_params['RQST_PARMS'] = JSON.stringify({
    'A_Name': P.A_Name,
    'A_DOB': P.A_DOB,
    'C_ID': req.gdata[jsh.map.client_id]
  });
  
  var fieldnames = _.keys(fields);
  _.each(fields, function (val, key) {
    validate.AddValidator('_obj.' + key, val.caption, 'I', val.validators);
  });
  
  var verrors = _.merge(verrors, validate.Validate('I', P));
  if (!_.isEmpty(verrors)) { Helper.GenError(req, res, -2, verrors[''].join('\n')); return; }
  
  appsrv.ExecCommand('agreement', sql, sql_ptypes, sql_params, function (err, rslt) {
    if (err != null) { err.sql = sql; appsrv.AppDBError(req, res, err); return; }
    rslt = {};
    rslt['_success'] = 1;
    res.end(JSON.stringify(rslt));
  });
}
exports.paymentresult = function (req, res, next) {
  //Validate hash and return result of payment to client
  var verb = req.method.toLowerCase();
  if (verb !== 'post') return next();
  
  var Q = req.query;
  var P = req.body;
  var appsrv = this;
  var jsh = this.jsh;
  
  var fields = {
    "payment_id": { "caption": "Invoice ID", "actions": "B", "type": "bigint", "validators": [XValidate._v_Required(), XValidate._v_IsNumeric()] },
    "fp_hash": { "caption": "Hash", "actions": "B", "type": "varchar", "length": 50, "validators": [XValidate._v_Required(), XValidate._v_MaxLength(50)] },
  }
  
  //Validate Parameters
  if (!appsrv.ParamCheck('Q', Q, [])) { Helper.GenError(req, res, -4, 'Invalid Parameters'); return; }
  if (!appsrv.ParamCheck('P', P, _.map(fields, function (val, key) { return '&' + key; }))) { Helper.GenError(req, res, -4, 'Invalid Parameters'); return; }
  
  var sql = '';
  var sql_ptypes = [];
  var sql_params = {};
  var verrors = {};
  var dbtypes = appsrv.DB.types;
  var validate = new XValidate();
  
  var fieldnames = _.keys(fields);
  sql = "agreement_paymentresult";
  _.each(fields, function (val, key) {
    validate.AddValidator('_obj.' + key, val.caption, 'B', val.validators);
    var dbtype = appsrv.getDBType(val);
    sql_ptypes.push(dbtype);
    if (key == 'fp_hash') sql_params[key] = new Buffer(P[key], "hex");
    else sql_params[key] = appsrv.DeformatParam(val, P[key], verrors);
  });
  
  var verrors = _.merge(verrors, validate.Validate('B', sql_params));
  if (!_.isEmpty(verrors)) { Helper.GenError(req, res, -2, verrors[''].join('\n')); return; }
  
  appsrv.ExecRow('join', sql, sql_ptypes, sql_params, function (err, rslt) {
    if (err != null) { err.sql = sql; appsrv.AppDBError(req, res, err); return; }
    else {
      if ((rslt != null) && (rslt.length == 1)) rslt = rslt[0];
      if (rslt != null) {
        rslt.key = '';
        if (rslt.PE_ID) {
          rslt.key = crypto.createHash('sha1').update(rslt.PE_ID + req.jshconfig.auth.salt + rslt.PE_LL_Tstmp).digest('hex');
        }
        rslt.NEW_CLIENT_ERROR = 0;
        if (!rslt.C_ID || !rslt.PE_ID || rslt.NEW_CLIENT_Result) rslt.NEW_CLIENT_ERROR = 1;
        delete rslt.C_ID;
        delete rslt.PE_ID;
        delete rslt.PE_LL_Tstmp;
        delete rslt.NEW_CLIENT_Result;
        rslt['_success'] = 1;
        res.end(JSON.stringify(rslt));
      }
      else { Helper.GenError(req, res, -1, 'Record not found'); return; }
    }
  });
}