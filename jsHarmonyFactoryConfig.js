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

  //Debug settings
  this.debug_params = {
    job_requests: false,                      //Record all JOB requests on LOG/CONSOLE
    //email_override: 'donotreply@company.com', //Send all emails to this address instead of to the client
    //sms_override: '+12223334444',             //Send all SMS messages to this phone instead of to the client
    no_job_email: false,                      //Disable sending EMAILS from JOB
    no_job_sms: false,                        //Disable sending SMS messages from JOB
    disable_job_processor: false,             //Disable Job Processor
  };

  //Excel integration token timeout
  this.excel_timeout = 4 * 60 * 60; //4 hours
  //Job Processor sleep time after no jobs found - Default 60000
  this.JobCheckDelay = 60000;
  //Job Processor sleep time after last job item executed - Default 5000
  this.JobSleepDelay = 5000;
  
  //Enable scheduled tasks
  this.enable_scheduler = 1;
  //Scheduled task definition
  this.scheduled_tasks = {};
  /*
  //Sample Scheduled Task
  this.scheduled_tasks["sample_task"] = {
    action: jsh.AppSrv.JobProc.ExecuteSQL("SQL;"),
    when: function (curdt, lastdt) {  //return true if the job should run
      var paused120minutes = (curdt.getTime() - lastdt.getTime() > (1000 * 60 * 120));
      if (!paused120minutes) return false; //if the job already ran, do not run it for 2 hrs
      return ((curdt.getHours() == 3) || (curdt.getHours() == 15)); //Run the job at 3am and 3pm
    }
  };
  */

  //Mapping of database fields for job processor
  this.job_field_mapping = {};

  this._validProperties = _.keys(this);
}
jsHarmonyFactoryConfig.prototype = new jsHarmonyConfig.Base();

exports = module.exports = jsHarmonyFactoryConfig;