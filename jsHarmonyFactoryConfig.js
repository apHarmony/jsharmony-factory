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

var jsHarmonyConfig = require('jsharmony/jsHarmonyConfig');
var path = require('path');
var _ = require('lodash');

function jsHarmonyFactoryConfig(){
  //jsHarmony Factory module path
  this.moduledir = path.dirname(module.filename);
  //Password salt for client site
  this.clientsalt = '';   //REQUIRED: Use a 60+ mixed character string
  //Cookie salt for client site
  this.clientcookiesalt = '';   //REQUIRED: Use a 60+ mixed character string
  //Password salt for main site
  this.mainsalt = '';   //REQUIRED: Use a 60+ mixed character string
  //Cookie site for main site
  this.maincookiesalt = '';   //REQUIRED: Use a 60+ mixed character string
  //Barcode integration settings
  this.barcode_settings = { server: 'https://localhost:3101' };
  //Scanner integration settings
  this.scanner_settings = { server: 'https://localhost:3105' };
  //Twilio settings
  this.twilio_settings = {
    SMS_FROM: '+12223334444', //"From" phone number
    ACCOUNT_SID: '',          //Twilio Account SID
    AUTH_TOKEN: ''            //Twilio Auth Token
  },
  //Settings for Suggest a Feature
  this.suggest_feature = {
    email: null,
    enabled: false
  };
  //Models for Help Listing
  this.help_view = {};
  //ID field for Help Listing
  this.help_panelid = '';
  //Subtitle for main site
  this.mainsitetitle = 'Database Management System';
  //Subtitle for client site
  this.clientsitetitle = 'Client Portal';

  //Debug settings
  this.debug_params = {
    job_requests: false,                      //Record all JOB requests on LOG/CONSOLE
    //email_override: 'donotreply@company.com', //Send all job processor emails to this address instead of to the client
    //sms_override: '+12223334444',             //Send all job processor SMS messages to this phone instead of to the client
    no_job_email: false,                      //Disable sending EMAILS from JOB
    no_job_sms: false,                        //Disable sending SMS messages from JOB
    disable_job_processor: false,             //Disable Job Processor
  };

  //Job Processor sleep time after no jobs found - Default 5000
  this.JobCheckDelay = 5000;
  //Job Processor sleep time after last job item executed - Default 5000
  this.JobSleepDelay = 5000;

  //Auto-start Job Processor
  this.auto_start_job_processor = undefined;
  //Enable scheduled tasks
  this.enable_scheduler = true;
  //Scheduled task definition
  this.scheduled_tasks = {};
  /*
  //Sample Scheduled Task
  this.scheduled_tasks["sample_task"] = {
    action: jsh.AppSrv.JobProc.ExecuteSQL("SQL;"),
    options: {
      quiet: false  //Do not log when starting task
    },
    when: function (curdt, lastdt) {  //return true if the job should run
      var paused120minutes = (curdt.getTime() - lastdt.getTime() > (1000 * 60 * 120));
      if (!paused120minutes) return false; //if the job already ran, do not run it for 2 hrs
      return ((curdt.getHours() == 3) || (curdt.getHours() == 15)); //Run the job at 3am and 3pm
    }
  };
  */

  //Mapping of database fields for job processor
  this.job_field_mapping = {};

  //Static menu
  this.static_menu = {
    main_menu: [
      //{ "menu_name": "Admin", "menu_desc": "Administration", "menu_cmd": "%%%NAMESPACE%%%Admin/Overview", "menu_subcmd": null, "menu_seq": 80000, "menu_id": 800, "roles": { "main": [ "SYSADMIN", "DEV" ] } },
    ],
    sub_menu: [
      //{ "menu_name": "Admin/SysUser_Listing", "menu_desc": "System Users", "menu_cmd": "%%%NAMESPACE%%%Admin/SysUser_Listing", "menu_subcmd": null, "menu_seq": 80000, "menu_id": 80000, "menu_parent_name": "Admin", "roles": { "main": [ "SYSADMIN", "DEV" ] } },      { "menu_name": "Admin/Param_User_Listing", "menu_desc": "User Settings", "menu_cmd": "%%%NAMESPACE%%%Admin/Param_User_Listing", "menu_subcmd": null, "menu_seq": 80081, "menu_id": 80081, "menu_parent_name": "Admin", "roles": { "main": [ "SYSADMIN", "DEV" ] } },
    ],
  };

  this._validProperties = _.keys(this);
}
jsHarmonyFactoryConfig.prototype = new jsHarmonyConfig.Base();

jsHarmonyFactoryConfig.prototype.Merge = function(config, jsh, sourceModuleName){
  var sourceModule = null;
  var _this = this;
  if(jsh && sourceModuleName) sourceModule = jsh.Modules[sourceModuleName];
  if(config.help_view){
    if(_.isString(config.help_view)) config.help_view = jsHarmonyConfig.addNamespace(config.help_view);
    else{
      for(var siteid in config.help_view){
        config.help_view[siteid] = jsHarmonyConfig.addNamespace(config.help_view[siteid], sourceModule);
      }
    }
  }
  jsHarmonyConfig.Base.prototype.Merge.call(_this, config, jsh, sourceModuleName, {
    'static_menu': function(obj, config){
      if(!config.static_menu) return;
      if(!obj.static_menu) obj.static_menu = {};
      if(!('main_menu' in obj.static_menu)) obj.static_menu.main_menu = [];
      if(!('sub_menu' in obj.static_menu)) obj.static_menu.sub_menu = [];
      function appendArray(dst,src){
        var menu_ids = {};
        for(let i=0;i<dst.length;i++) menu_ids[dst[i].menu_id] = i;
        for(let i=0;i<src.length;i++){
          if(!src[i].menu_id){ dst.push(src[i]); continue; }
          if(src[i].menu_id in menu_ids) dst[menu_ids[src[i].menu_id]] = src[i];
          else dst.push(src[i]);
        }
      }
      if(config.static_menu.main_menu) appendArray(obj.static_menu.main_menu,config.static_menu.main_menu);
      if(config.static_menu.sub_menu) appendArray(obj.static_menu.sub_menu,config.static_menu.sub_menu);
    }
  });
};

jsHarmonyFactoryConfig.prototype.Helper = require('./jsHarmonyFactoryConfigHelper.js');

exports = module.exports = jsHarmonyFactoryConfig;