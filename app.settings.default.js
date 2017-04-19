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

var path = require('path');

global.app_settings = { }
global.http_ip = '0.0.0.0';
global.https_ip = '0.0.0.0';
global.https_key = global.appbasepath + '/cert/localhost-key.pem';
global.https_cert = global.appbasepath + '/cert/localhost-cert.pem';
global.support_email = 'donotreply@company.com';
global.error_email = 'donotreply@company.com';
global.mailer_email = 'DO NOT REPLY <donotreply@company.com>';
global.barcode_settings = { server: 'https://localhost:3101' };
global.scanner_settings = { server: 'https://localhost:3105' };
global.google_settings = { API_KEY: '' };
global.twilio_settings = {
  SMS_FROM: '+12223334444',
  ACCOUNT_SID: '',
  AUTH_TOKEN: ''
};
global.mailer_settings = {
  type: 'smtp',
  host: 'mail.company.com',
  port: 465,
  auth: {
    user: 'donotreply@company.com',
    pass: ''
  },
  secure: true,
  debug: false,
  tls: { rejectUnauthorized: false },
  maxConnections: 5,
  maxMessages: 10
};
global.debug_params = {
  web_detailed_errors: true, //Be sure to set to false in production - you do not want error stack traces showing to users
  pipe_log : true,  //Show LOG messages on CONSOLE
  appsrv_requests: true,  //Record all APPSRV requests on LOG/CONSOLE
  report_debug: false,  //Display report warnings (Null value, etc.)
  db_requests: false,     //Log every database request through DB.js
  db_error_sql_state: true,       //Log SQL state during DB error
  job_requests: false,   //Record all JOB requests on LOG/CONSOLE
  email_override: 'donotreply@company.com',  //Send all emails to this address instead of to the client
  sms_override: '+12223334444',         //Send all SMS messages to this phone instead of to the client
  no_job_email: false,                   //Disable sending EMAILS from JOB
  no_job_sms: false,                     //Disable sending SMS messages from JOB
  disable_job_processor: false,          //Disable Job Processor
  disable_email: false,
  hide_deprecated: false,
  jsh_error_level: 1 //1 = ERROR, 2 = WARNING, 4 = INFO  :: Messages generated while parsing jsHarmony configs
}
global.excel_timeout = 4 * 60 * 60; //4* 60 * 60; //4 hours
global.JobCheckDelay = 60000; //JobProc sleep time after no jobs found - Default 60000
global.JobSleepDelay = 5000; //JobProc sleep time after last job item executed - Default 5000