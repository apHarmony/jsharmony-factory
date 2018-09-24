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


var fs = require('fs');
var path = require('path');
var debug = require('debug')('jsharmony');
var express = require('express');
var os = require("os");
var _ = require('lodash');
var jsHarmony = require('jsharmony');
var jsHarmonyModule = require('jsharmony/jsHarmonyModule');
var jsHarmonySite = require('jsHarmony/jsHarmonySite');
var jsHarmonyRouter = require('jsHarmony/jsHarmonyRouter');
var HelperFS = jsHarmony.lib.HelperFS;
var Helper = jsHarmony.lib.Helper;
var cookieParser = require('cookie-parser');
var jsHarmonyFactoryConfig = require('./jsharmonyFactoryConfig.js');
var jsHarmonyFactoryMailer = require('./lib/Mailer.js');
var jsHarmonyFactoryJobProc = require('./models/_jobproc.js');

var agreement = require('./models/_agreement.js');
var adminfuncs = require('./models/_funcs.js');
var menu = require('./models/_menu.js');

function jsHarmonyFactory(adminConfig, clientConfig){
  var _this = this;
  _this.Config = new jsHarmonyFactoryConfig();
  _this.typename = 'jsHarmonyFactory';
  _this.adminConfig = adminConfig||{};
  _this.clientConfig = clientConfig;

  _this.adminRouter = null;
  _this.clientRouter = null;
}

jsHarmonyFactory.prototype = new jsHarmonyModule();

jsHarmonyFactory.Application = function(adminConfig, clientConfig){
  return (new jsHarmonyFactory(adminConfig, clientConfig)).Application();
}

jsHarmonyFactory.prototype.Init = function(cb){
  var _this = this;

  _this.jsh.Mailer = jsHarmonyFactoryMailer(_this.Config.mailer_settings, _this.jsh.Log.info);
  this.jsh.SetJobProc(new jsHarmonyFactoryJobProc(this, _this.jsh.DB['default']));

  if(_this.clientConfig){
    this.jsh.Sites['client'] = new jsHarmonySite(_this.GetDefaultClientConfig());
    this.jsh.Sites['client'].Merge(_this.clientConfig);
  }
  this.jsh.Sites['admin'] = new jsHarmonySite(_this.GetDefaultAdminConfig());
  this.jsh.Sites['admin'].Merge(_this.adminConfig);

  _this.adminConfig = this.jsh.Sites['admin'];
  _this.clientConfig = this.jsh.Sites['client'];

  if(typeof _this.jsh.Config.server.https_port == 'undefined'){
    if(_this.adminConfig && _this.adminConfig.auth && (typeof _this.adminConfig.auth.allow_insecure_http_logins === 'undefined'))
      _this.adminConfig.auth.allow_insecure_http_logins = true;
    if(_this.clientConfig && _this.clientConfig.auth && (typeof _this.clientConfig.auth.allow_insecure_http_logins === 'undefined'))
      _this.clientConfig.auth.allow_insecure_http_logins = true;
  }

  _this.jsh.Config.server.add_default_routes = false;
  this.jsh.CreateServer(_this.jsh.Config.server, function(server){
    _this.jsh.Servers['default'] = server;

    var app = _this.app = _this.jsh.Servers['default'].app;

    _this.VerifyConfig();

    app.use(express.static(path.join(__dirname, 'public')));

    if(_this.clientConfig){
      app.get(/^\/client$/, function (req, res, next) { res.redirect('/client/'); });
      app.use('/client', cookieParser(_this.Config.clientcookiesalt, { path: '/client/' }));
      app.all('/client/login', function (req, res, next) { req._override_basetemplate = 'public'; req._override_title = 'Customer Portal Login'; next(); });
      app.all('/client/login/forgot_password', function (req, res, next) { req._override_basetemplate = 'public'; next(); });
      app.all('/client/logout', function (req, res, next) { req._override_basetemplate = 'public'; next(); });
      _this.clientRouter = jsHarmonyRouter(_this.jsh, 'client');
      _this.clientRouter.get('*', function(req, res, next){
        _this.jsh.Gen404(req, res);
        return;
      });
      app.use('/client', _this.clientRouter);
    }

    app.use('/', cookieParser(_this.Config.admincookiesalt, { path: '/' }));
    app.all('/login', function (req, res, next) { req._override_basetemplate = 'public'; req._override_title = 'Login'; next(); });
    app.all('/login/forgot_password', function (req, res, next) { req._override_basetemplate = 'public'; next(); });
    app.all('/logout', function (req, res, next) { req._override_basetemplate = 'public'; next(); });
    _this.adminRouter = jsHarmonyRouter(_this.jsh, 'admin');
    app.use('/', _this.adminRouter);

    _this.jsh.Servers['default'].addDefaultRoutes();

    if(cb) return cb();

  });
}

jsHarmonyFactory.prototype.Run = function(onServerReady){
  this.jsh.Servers['default'].Run(onServerReady);
  this.jsh.AppSrv.JobProc.Run();
}

jsHarmonyFactory.prototype.GetDefaultAdminConfig = function(){
  var _this = this;
  var jsh = this.jsh;
  /*************
   *** ADMIN ***
   *************/
  var jshconfig_admin = {
    id: 'main',
    basetemplate: 'index',
    baseurl: '/',
    show_system_errors: true,
    auth: {
      salt: _this.Config.adminsalt,
      supersalt: _this.Config.adminsalt,
      sql_auth: "admin_sql_auth",
      sql_login: "admin_sql_login",
      sql_superlogin: "admin_sql_superlogin",
      sql_loginsuccess: "admin_sql_loginsuccess",
      sql_passwordreset: "admin_sql_passwordreset",
      getuser_name: function (user_info, jsh) { return user_info[jsh.map.user_firstname] + ' ' + user_info[jsh.map.user_lastname]; },
      getContextUser: function (user_info, jsh) { return 'S' + user_info[jsh.map.user_id]; }
    },
    menu: menu.bind(null, 'S'),
    globalparams: {
      'barcode_server': _this.Config.barcode_settings.server,
      'scanner_server': _this.Config.scanner_settings.server,
      'user_id': function (req) { return req.user_id; },
      'user_name': function (req) { return req.user_name; }
    },
    sqlparams: {
      "TSTMP": "TSTMP",
      "CUSER": "CUSER"
    },
    onLoad: function (jsh) {
    }
  }
  jshconfig_admin.private_apps = [
    {
      '/_funcs/LOG_DOWNLOAD': adminfuncs.LOG_DOWNLOAD,
      '/_funcs/DEV_DB_SCRIPTS': adminfuncs.DEV_DB_SCRIPTS
    }
  ];
  return jshconfig_admin;
}

jsHarmonyFactory.prototype.GetDefaultClientConfig = function(){
  var _this = this;
  var jsh = this.jsh;
  /**************
   *** CLIENT ***
   **************/
  var jshconfig_client = {
    id: 'client',
    basetemplate: 'client',
    baseurl: '/client/',
    show_system_errors: false,
    auth: {
      salt: _this.Config.clientsalt,
      supersalt: _this.Config.adminsalt,
      sql_auth: "client_sql_auth",
      sql_login: "client_sql_login",
      sql_superlogin: "client_sql_superlogin",
      sql_loginsuccess: "client_sql_loginsuccess",
      sql_passwordreset: "client_sql_passwordreset",
      getuser_name: function (user_info, jsh) { return user_info[jsh.map.user_firstname] + ' ' + user_info[jsh.map.user_lastname]; },
      getContextUser: function (user_info, jsh) { return 'C' + user_info[jsh.map.user_id]; },
      onAuthComplete: function (req, user_info, jsh) {
        req.gdata = {};
        req.gdata[jsh.map.client_id] = user_info[jsh.map.client_id];
        req.gdata[jsh.map.client_name] = user_info[jsh.map.client_name];
        req.gdata[jsh.map.client_agreement_tstmp] = user_info[jsh.map.client_agreement_tstmp];
        req.gdata[jsh.map.client_overdue] = parseFloat(user_info[jsh.map.client_overdue]);
        req.gdata[jsh.map.client_overdue_ignore] = 0;
      },
    },
    menu: menu.bind(null, 'C'),
    datalock: { /* jsh.map.client_id (below) */ },
    datalocktypes: { /* jsh.map.client_id (below) */ },
    globalparams: {
      'user_id': function (req) { return req.user_id; },
      'user_name': function (req) { return req.user_name; },
      'company_id': function (req) { return req.gdata[jsh.map.client_id]; },
      'company_name': function (req) { return req.gdata[jsh.map.client_name]; },
      'barcode_server': _this.Config.barcode_settings.server
    },
    sqlparams: {
      "TSTMP": "TSTMP",
      "CUSER": "CUSER"
    }
  };
  jshconfig_client.globalparams[jsh.map.client_id] = function (req) { return req.gdata[jsh.map.client_id]; }
  jshconfig_client.globalparams[jsh.map.client_name] = function (req) { return req.gdata[jsh.map.client_name]; }
  jshconfig_client.datalock[jsh.map.client_id] = function (req) { return req.gdata[jsh.map.client_id]; };
  jshconfig_client.datalocktypes[jsh.map.client_id] = { 'name': jsh.map.client_id, 'type': 'bigint' };
  var ignore_overdue = function (req, res, next) { req.gdata[jsh.map.client_overdue_ignore] = 1; next(); };
  var ignore_overdue_transaction = function (req, res, next) {
    if (req.gdata[jsh.map.client_overdue] <= 0) { return next(); }
    if (!('data' in req.body)) { return next(); }
    var data = JSON.parse(req.body.data);
    if (!(data instanceof Array)) { return next(); }
    var overdue_transaction = true;
    for (var i = 0; i < data.length; i++) {
      var action = data[i];
      if ((action.model == 'C_PA_CC') || (action.model == 'C_PACC_PACCI') || (action.model == 'C_PACC_INFO')) continue;
      overdue_transaction = false;
    }
    if (overdue_transaction) req.gdata[jsh.map.client_overdue_ignore] = 1;
    next();
  };
  jshconfig_client.private_apps = [
    {
      '/agreement/': agreement.form,
      '/agreement/_sign': agreement.sign,
      '*': agreement.check,
      '/agreement/welcome/': agreement.welcome
    },
    {
      '/_d/_transaction/': ignore_overdue_transaction,
      '*': function (req, res, next) {
        if (req.gdata[jsh.map.client_overdue_ignore] > 0) return next();
        if (req.gdata[jsh.map.client_overdue] > 0) { console.log('Redirect-Payment'); return Helper.Redirect302(res, req.baseurl + 'C_PA_CC/'); }
        next();
      }
    }
  ];
  return jshconfig_client;
}

jsHarmonyFactory.prototype.VerifyConfig = function(){
  var _this = this;
  function verify_config(x, _caption) { if (!x || (_.isObject(x) && _.isEmpty(x))) { console.log('*** Missing app.config.js setting: ' + _caption); return false; } return true; }
  var good_config = true;
  var required_fields = ['adminsalt', 'admincookiesalt'];
  if(_this.clientConfig) required_fields = required_fields.concat(['clientsalt', 'clientcookiesalt']);
  _.each(required_fields, function (val) { good_config &= verify_config(_this.Config[val], "config.modules['jsHarmonyFactory']." + val); });
  if (!good_config) { console.log('\r\n*** Invalid config, could not start server ***\r\n'); process.exit(1); }
}

exports = module.exports = jsHarmonyFactory;