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
var os = require("os");
var _ = require('lodash');
var jsHarmony = require('jsharmony');
var jsHarmonyModule = require('jsharmony/jsHarmonyModule');
var jsHarmonySite = require('jsharmony/jsHarmonySite');
var jsHarmonyRouter = require('jsharmony/jsHarmonyRouter');
var HelperFS = jsHarmony.lib.HelperFS;
var Helper = jsHarmony.lib.Helper;
var cookieParser = require('cookie-parser');
var jsHarmonyFactoryConfig = require('./jsHarmonyFactoryConfig.js');
var jsHarmonyFactoryJobProc = require('./models/_jobproc.js');

var agreement = require('./models/_agreement.js');
var menu = require('./models/_menu.js');
var funcs = require('./models/_funcs.js');

function jsHarmonyFactory(name, options){
  options = _.extend({
    mainSiteID: 'main',
    clientSiteID: 'client',
    clientPortal: false,
  }, options);
  var _this = this;
  if(name) _this.name = name;
  _this.Config = new jsHarmonyFactoryConfig();
  _this.typename = 'jsHarmonyFactory';

  _this.mainSiteID = options.mainSiteID;
  _this.clientSiteID = options.clientSiteID;
  _this.clientPortal = options.clientPortal;

  _this.mainRouter = null;
  _this.clientRouter = null;
  _this.funcs = new funcs(_this);;
}

jsHarmonyFactory.prototype = new jsHarmonyModule();

jsHarmonyFactory.Application = function(options){
  return (new jsHarmonyFactory(null,options)).Application();
}

jsHarmonyFactory.prototype.onModuleAdded = function(jsh){
  var _this = this;
  //CREATE SITES in JSH
  if(!(_this.mainSiteID in jsh.Sites)) jsh.Sites[_this.mainSiteID] = new jsHarmonySite.Placeholder();
  if(_this.clientPortal && !(_this.clientSiteID in jsh.Sites)) jsh.Sites[_this.clientSiteID] = new jsHarmonySite.Placeholder();
}

jsHarmonyFactory.prototype.Init = function(cb){
  var _this = this;

  this.jsh.SetJobProc(new jsHarmonyFactoryJobProc(this, _this.jsh.DB['default']));

  if(_this.clientPortal){
    var prevClientConfig = this.jsh.Sites[_this.clientSiteID];
    if(prevClientConfig && prevClientConfig.initialized) throw new Error('jsHarmony Factory could not initialize site "'+_this.clientSiteID+'": Already initialized');
    this.jsh.Sites[_this.clientSiteID] = new jsHarmonySite(_this.jsh, _this.clientSiteID, _this.GetDefaultClientConfig());
    this.jsh.Sites[_this.clientSiteID].Merge(prevClientConfig);
  }
  var prevMainConfig = this.jsh.Sites[_this.mainSiteID];
  if(prevMainConfig && prevMainConfig.initialized) throw new Error('jsHarmony Factory could not initialize site "'+_this.mainSiteID+'": Already initialized');
  this.jsh.Sites[_this.mainSiteID] = new jsHarmonySite(_this.jsh, _this.mainSiteID, _this.GetDefaultMainConfig());
  this.jsh.Sites[_this.mainSiteID].Merge(prevMainConfig);

  var mainSite = this.jsh.Sites[_this.mainSiteID];
  var clientSite = this.jsh.Sites[_this.clientSiteID];

  if(typeof _this.jsh.Config.server.https_port == 'undefined'){
    if(mainSite && mainSite.auth && (typeof mainSite.auth.allow_insecure_http_logins === 'undefined'))
      mainSite.auth.allow_insecure_http_logins = true;
    if(clientSite && clientSite.auth && (typeof clientSite.auth.allow_insecure_http_logins === 'undefined'))
      clientSite.auth.allow_insecure_http_logins = true;
  }

  _this.jsh.Config.server.add_default_routes = false;
  this.jsh.CreateServer(_this.jsh.Config.server, function(server){
    _this.jsh.Servers['default'] = server;

    var app = _this.app = _this.jsh.Servers['default'].app;

    _this.VerifyConfig();

    app.use(jsHarmonyRouter.PublicRoot(path.join(__dirname, 'public')));

    if(_this.clientPortal){
      app.get(/^\/client$/, function (req, res, next) { res.redirect('/client/'); });
      app.use('/client', cookieParser(_this.Config.clientcookiesalt, { path: '/client/' }));
      app.all('/client/login', function (req, res, next) { req._override_basetemplate = 'public'; req._override_title = 'Customer Portal Login'; next(); });
      app.all('/client/login/forgot_password', function (req, res, next) { req._override_basetemplate = 'public'; next(); });
      app.all('/client/logout', function (req, res, next) { req._override_basetemplate = 'public'; next(); });
      _this.clientRouter = jsHarmonyRouter(_this.jsh, _this.clientSiteID);
      _this.clientRouter.get('*', function(req, res, next){
        _this.jsh.Gen404(req, res);
        return;
      });
      app.use('/client', _this.clientRouter);
    }

    app.use('/', cookieParser(_this.Config.maincookiesalt, { path: '/' }));
    app.all('/login', function (req, res, next) { req._override_basetemplate = 'public'; req._override_title = 'Login'; next(); });
    app.all('/login/forgot_password', function (req, res, next) { req._override_basetemplate = 'public'; next(); });
    app.all('/logout', function (req, res, next) { req._override_basetemplate = 'public'; next(); });
    _this.mainRouter = jsHarmonyRouter(_this.jsh, _this.mainSiteID);
    app.use('/', _this.mainRouter);

    _this.jsh.Servers['default'].addDefaultRoutes();

    if(cb) return cb();

  });
}

jsHarmonyFactory.prototype.Run = function(onComplete){
  this.jsh.Servers['default'].Run(onComplete);
  if(this.Config.auto_start_job_processor) this.jsh.AppSrv.JobProc.Run();
}

jsHarmonyFactory.prototype.GetDefaultMainConfig = function(){
  var _this = this;
  var jsh = this.jsh;
  /*******************
   *** MAIN SYSTEM ***
   *******************/
  var jshconfig_main = {
    basetemplate: 'index',
    baseurl: '/',
    publicurl: '/',
    show_system_errors: true,
    auth: {
      salt: _this.Config.mainsalt,
      supersalt: _this.Config.mainsalt,
      sql_auth: "main_sql_auth",
      sql_login: "main_sql_login",
      sql_superlogin: "main_sql_superlogin",
      sql_loginsuccess: "main_sql_loginsuccess",
      sql_passwordreset: "main_sql_passwordreset",
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
    onLoad: function (jsh) {
    }
  }
  jshconfig_main.private_apps = [
    {
      '/_funcs/LOG_DOWNLOAD': _this.funcs.LOG_DOWNLOAD,
      '/_funcs/DEV_DB_SCRIPTS': _this.funcs.DEV_DB_SCRIPTS,
      '/_funcs/DEV_DB_SCHEMA': _this.funcs.DEV_DB_SCHEMA,
      '/_funcs/DEV_MODELS': _this.funcs.DEV_MODELS
    }
  ];
  return jshconfig_main;
}

jsHarmonyFactory.prototype.GetDefaultClientConfig = function(){
  var _this = this;
  var jsh = this.jsh;
  /**************
   *** CLIENT ***
   **************/
  var jshconfig_client = {
    home_url: '/client/',
    basetemplate: 'client',
    baseurl: '/client/',
    publicurl: '/',
    show_system_errors: false,
    auth: {
      salt: _this.Config.clientsalt,
      supersalt: _this.Config.mainsalt,
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
  var required_fields = ['mainsalt', 'maincookiesalt'];
  if(_this.clientPortal) required_fields = required_fields.concat(['clientsalt', 'clientcookiesalt']);
  _.each(required_fields, function (val) { good_config &= verify_config(_this.Config[val], "config.modules['jsHarmonyFactory']." + val); });
  if (!good_config) { console.log('\r\n*** Invalid config, could not start server ***\r\n'); process.exit(1); }
}

exports = module.exports = jsHarmonyFactory;