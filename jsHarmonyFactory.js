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
var HelperFS = jsHarmony.lib.HelperFS;
var Helper = jsHarmony.lib.Helper;
var cookieParser = require('cookie-parser');

var agreement = require('./models/_agreement.js');
var adminfuncs = require('./models/_funcs.js');
var menu = require('./models/_menu.js');

function jsHarmonyFactory(adminConfig, clientConfig, onSettingsLoaded){
  var _this = this;
  _this.typename = 'jsHarmonyFactory';
  var factorypath = path.dirname(module.filename);

  if(!global.jsHarmonyFactorySettings_Loaded) jsHarmonyFactory.LoadSettings();
  HelperFS.loadViews(factorypath + '/views', '');
  if(!global.modeldir) global.modeldir = [];
  global.modeldir.unshift({ path: factorypath + '/models/', component: 'jsharmony-factory' });
  this.app = jsHarmony.App({'noroutes':1});
  this.app.jsh.SetJobProc(global.JobProc);
  this.VerifySettings();

  global.mailer = require('./lib/Mailer.js');
  this.app.use(express.static(path.join(__dirname, 'public')));

  if(clientConfig){
    clientConfig = Helper.MergeConfig(jsHarmonyFactory.GetDefaultClientConfig(this.app.jsh),clientConfig);
    _this.clientConfig = clientConfig;
    this.app.get(/^\/client$/, function (req, res, next) { res.redirect('/client/'); });
    this.app.use('/client', cookieParser(global.clientcookiesalt, { path: '/client/' }));
    this.app.all('/client/login', function (req, res, next) { req._override_basetemplate = 'public'; req._override_title = 'Customer Portal Login'; next(); });
    this.app.all('/client/login/forgot_password', function (req, res, next) { req._override_basetemplate = 'public'; next(); });
    this.app.all('/client/logout', function (req, res, next) { req._override_basetemplate = 'public'; next(); });
    _this.clientRouter = jsHarmony.Init.Routes(this.app.jsh, clientConfig);
    _this.clientRouter.get('*', function(req, res, next){
      HelperFS.gen404(req, res);
      return;
    });
    this.app.use('/client', _this.clientRouter);
  }

  if(!adminConfig) adminConfig = {};
  adminConfig = Helper.MergeConfig(jsHarmonyFactory.GetDefaultAdminConfig(this.app.jsh),adminConfig);
  _this.adminConfig = adminConfig;
  this.app.use('/', cookieParser(global.admincookiesalt, { path: '/' }));
  this.app.all('/login', function (req, res, next) { req._override_basetemplate = 'public'; req._override_title = 'Login'; next(); });
  this.app.all('/login/forgot_password', function (req, res, next) { req._override_basetemplate = 'public'; next(); });
  this.app.all('/logout', function (req, res, next) { req._override_basetemplate = 'public'; next(); });
  _this.adminRouter = jsHarmony.Init.Routes(this.app.jsh, adminConfig);
  this.app.use('/', _this.adminRouter);

  jsHarmony.Init.addDefaultRoutes(this.app);
}

jsHarmonyFactory.GetDefaultAdminConfig = function(jsh){
  /*************
   *** ADMIN ***
   *************/
  var jshconfig_admin = {
    id: 'main',
    basetemplate: 'index',
    baseurl: '/',
    show_system_errors: true,
    auth: {
      salt: global.adminsalt,
      supersalt: global.adminsalt,
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
      'barcode_server': global.barcode_settings.server,
      'scanner_server': global.scanner_settings.server,
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

jsHarmonyFactory.GetDefaultClientConfig = function(jsh){
  /**************
   *** CLIENT ***
   **************/
  var jshconfig_client = {
    id: 'client',
    basetemplate: 'client',
    baseurl: '/client/',
    show_system_errors: false,
    auth: {
      salt: global.clientsalt,
      supersalt: global.adminsalt,
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
      'barcode_server': global.barcode_settings.server
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

jsHarmonyFactory.LoadSettings = function(custom_settings_path){
  if(global.jsHarmonyFactorySettings_Loaded){ throw new Error('jsHarmonyFactory settings already loaded'); }

  //Include appropriate settings file based on Path
  if (!global.appbasepath) global.appbasepath = path.dirname(require.main.filename);
  
  //Create array of application path
  var mpath = global.appbasepath;
  var mbasename = '';
  var patharr = [];
  while (mbasename = path.basename(mpath)) {
    patharr.unshift(mbasename);
    mpath = path.dirname(mpath);
  }
  //Load Default Settings
  require('./app.settings.default.js');
  //Load app.settings.js
  if (fs.existsSync(global.appbasepath + '/app.settings.js')) require(global.appbasepath + '/app.settings.js');
  //Load settings based on Application Path
  var local_settings_file = global.appbasepath + '/app.settings.' + patharr.join('_') + '.js';
  if (fs.existsSync(local_settings_file)) require(local_settings_file);
  //Load settings based on Hostname
  var host_settings_file = global.appbasepath + '/app.settings.' + os.hostname().toLowerCase() + '.js';
  if (fs.existsSync(host_settings_file)) require(host_settings_file);
  //Load custom settings
  if(custom_settings_path && fs.existsSync(custom_settings_path)) require(custom_settings_path);

  if(!global.JobProc) global.JobProc = require('./models/_jobproc.js');
  global.jsHarmonyFactorySettings_Loaded = true;
}

jsHarmonyFactory.prototype.VerifySettings = function(){
  function verify_config(x, _caption) { if (!x || (_.isObject(x) && _.isEmpty(x))) { console.log('*** Missing app.settings.js setting: ' + _caption); return false; } return true; }
  var good_config = true;
  _.each(['clientsalt', 'clientcookiesalt', 'adminsalt', 'admincookiesalt', 'frontsalt'], function (val) { good_config &= verify_config(global[val], 'global.' + val); });
  if (!global.home_url) global.home_url = '';
  if ((typeof global.http_port === 'undefined') && (typeof global.https_port === 'undefined')) global.http_port = 0;
  if (!good_config) { console.log('\r\n*** Invalid config, could not start server ***\r\n'); process.exit(1); }
}

jsHarmonyFactory.prototype.Run = function (cb) {
  var _this = this;
  
  var jshconfig = { server: {
    request_timeout: global.request_timeout,
  } };
  if(typeof global.http_port !== 'undefined'){
    _this.app.set('port', process.env.PORT || global.http_port);
    jshconfig.server.http_port = _this.app.get('port');
    jshconfig.server.http_ip = global.http_ip;
  }
  if(typeof global.https_port !== 'undefined'){
    _this.app.set('tlsport', process.env.TLSPORT || global.https_port);
    jshconfig.server.https_port = _this.app.get('tlsport');
    jshconfig.server.https_ip = global.https_ip;
    jshconfig.server.https_cert = global.https_cert;
    jshconfig.server.https_key = global.https_key;
    jshconfig.server.https_ca = global.https_ca;
  }
  else {
    if(_this.adminConfig && _this.adminConfig.auth && (typeof _this.adminConfig.auth.allow_insecure_http_logins === 'undefined'))
      _this.adminConfig.auth.allow_insecure_http_logins = true;
    if(_this.clientConfig && _this.clientConfig.auth && (typeof _this.clientConfig.auth.allow_insecure_http_logins === 'undefined'))
      _this.clientConfig.auth.allow_insecure_http_logins = true;
  }
  jsHarmony.Run(jshconfig,_this.app.jsh,_this.app,cb);
}

exports = module.exports = jsHarmonyFactory;