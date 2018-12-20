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

var _ = require('lodash');
var fs = require('fs');
var async = require('async');
var Helper = require('jsharmony/Helper');
var HelperFS = require('jsharmony/HelperFS');
var XValidate = require('jsharmony-validate');
var SMS = require('../lib/SMS.js');

function AppSrvJobProc(jshFactory, db) {
  this.jshFactory = jshFactory;
  this.jsh = jshFactory.jsh;
  this.db = db;
  this.AppSrv = jshFactory.jsh.AppSrv;
  this.TaskHistory = {};
  this.QueueHistory = {};
}

AppSrvJobProc.prototype.map_db_rslt = function(row) {
  var _this = this;
  if (!row) return row;
  var rslt = {};
  for (var f in row) {
    if (f in _this.jshFactory.Config.job_field_mapping) {
      rslt[_this.jshFactory.Config.job_field_mapping[f]] = row[f];
    }
    else rslt[f] = row[f];
  }
  return rslt;
}

AppSrvJobProc.prototype.Run = function () {
  if (this.jshFactory.Config.debug_params.disable_job_processor) return;
  var _this = this;
  _this.CheckJobQueue(function (job) {
    if (job) {
      _this.ExecJob(job, function () {
        _this.CheckSubscriberQueue(function () { setTimeout(function () { _this.Run(); }, _this.jshFactory.Config.JobSleepDelay); });
      });
    }
    else { _this.CheckSubscriberQueue(function () { setTimeout(function () { _this.Run(); }, _this.jshFactory.Config.JobCheckDelay); }); }
  });
}

AppSrvJobProc.prototype.CheckJobQueue = function (onComplete) {
  var _this = this;
  if (_this.jshFactory.Config.enable_scheduler && _this.jshFactory.Config.scheduled_tasks) {
    var curdt = new Date();
    for (var t in _this.jshFactory.Config.scheduled_tasks) {
      if (!(t in this.TaskHistory)) this.TaskHistory[t] = new Date(0);
      if (_this.jshFactory.Config.scheduled_tasks[t].when(curdt, this.TaskHistory[t])) {
        _this.jsh.Log.info('Running Task ' + t);
        _this.jshFactory.Config.scheduled_tasks[t].action(this);
        this.TaskHistory[t] = curdt;
      }
    }
  }
  this.AppSrv.ExecRow('jobproc', "jobproc_jobcheck", [], {}, function (err, rslt) {
    if (err != null) { _this.jsh.Log.error(err); return onComplete(null); }
    if ((rslt != null) && (rslt.length == 1) && (rslt[0] != null)) {
      var job = _this.map_db_rslt(rslt[0]);
      return onComplete(job);
    }
    else return onComplete(null);
  });
}

AppSrvJobProc.prototype.ExecJob = function (job, onComplete) {
  var _this = this;
  var thisapp = this.AppSrv;
  if (_this.jshFactory.Config.debug_params.email_override) {
    if (job.EMAIL_TO) job.EMAIL_TO = _this.jshFactory.Config.debug_params.email_override;
    if (job.EMAIL_CC) job.EMAIL_CC = _this.jshFactory.Config.debug_params.email_override;
    if (job.EMAIL_BCC) job.EMAIL_BCC = _this.jshFactory.Config.debug_params.email_override;
  }
  if (_this.jshFactory.Config.debug_params.sms_override) {
    if (job.SMS_TO) job.SMS_TO = _this.jshFactory.Config.debug_params.sms_override;
  }
  _this.jsh.Log.info('Starting Job #' + job.RQST_ID);
  if (_this.jshFactory.Config.debug_params.job_requests) _this.jsh.Log.info(job);
  
  if (job.RQST_ATYPE == 'REPORT') return _this.ExecJob_REPORT(job, onComplete);
  else if (job.RQST_ATYPE == 'MESSAGE') return _this.ExecJob_MESSAGE(job, onComplete);
  else return _this.SetJobResult(job, 'ERROR', 'RQST_ATYPE not Supported', onComplete);
};

AppSrvJobProc.prototype.ExecJob_MESSAGE = function (job, onComplete) {
  var _this = this;
  var thisapp = this.AppSrv;
  if (job.RQST_ATYPE != 'MESSAGE') return _this.SetJobResult(job, 'ERROR', 'RQST_ATYPE not MESSAGE', onComplete);
  
  var rparams = {};
  if (job.RQST_PARMS){
    try{
      rparams = JSON.parse(job.RQST_PARMS);
    }
    catch (ex) {
      return _this.SetJobResult(job, 'ERROR', 'Error parsing JOB MESSAGE - Invalid JSON', onComplete);
    }
  }
  _this.processJobResult(job, rparams, '', 0, onComplete);
};

AppSrvJobProc.prototype.ExecJob_REPORT = function (job, onComplete) {
  var _this = this;
  var thisapp = this.AppSrv;
  if (job.RQST_ATYPE != 'REPORT') return _this.SetJobResult(job, 'ERROR', 'RQST_ATYPE not REPORT', onComplete);

  //Process Report ID (make sure it's in the system)
  var fullmodelid = job.RQST_ANAME;
  if (!thisapp.jsh.hasModel(undefined, fullmodelid)) return _this.SetJobResult(job, 'ERROR', 'Report not found in collection', onComplete);
  
  var rparams = {};
  if (job.RQST_PARMS) rparams = JSON.parse(job.RQST_PARMS);

  thisapp.rptsrv.queueReport(undefined, undefined, fullmodelid, rparams, {}, { db: _this.db, dbcontext: 'jobproc', errorHandler: function(num, txt){ return _this.SetJobResult(job, 'ERROR', txt, onComplete); } }, function (err, tmppath, dispose, dbdata) {
    if (err) return _this.SetJobResult(job, 'ERROR', err.toString(), onComplete);
    /* Report Done */ 
    fs.stat(tmppath, function (err, stat) {
      if (err != null) return _this.SetJobResult(job, 'ERROR', 'Report file not found: '+err.toString(), onComplete);
      var fsize = stat.size;
      if (fsize > _this.jsh.Config.max_filesize) return _this.SetJobResult(job, 'ERROR', 'Report file size exceeds system maximum file size', function () { dispose(onComplete); });
      //Report is available at tmppath
      _this.processJobResult(job, dbdata, tmppath, fsize, function () { dispose(onComplete); });
    });
  });
}

AppSrvJobProc.prototype.processJobResult = function (job, dbdata, tmppath, fsize, onComplete) {
  var _this = this;
  if (_this.jsh.Config.debug_params.report_debug) console.log(dbdata);
  var thisapp = this.AppSrv;
  var dbtypes = thisapp.DB.types;
  var D_ID = null;
  var RQ_ID = null;
  var saveD = function (callback) {
    _this.db.Scalar('jobproc', "jobproc_saveD", 
      [dbtypes.VarChar(8), dbtypes.BigInt, dbtypes.VarChar(8), dbtypes.VarChar(255), dbtypes.BigInt], 
      { 'D_SCOPE': job.D_SCOPE, 'D_SCOPE_ID': job.D_SCOPE_ID, 'D_CTGR': job.D_CTGR, 'D_Desc': job.D_Desc, 'D_SIZE': fsize }, function (err, rslt) {
      if ((err == null) && (rslt == null)) { _this.jsh.Log.error(err); err = Helper.NewError('Error inserting document', -99999); }
      if (err == null) D_ID = rslt;
      callback(err);
    });
  };
  var saveRQ = function (callback) {
    var rq_message = job.RQ_MESSAGE || '{}';
    var rq_message_obj = {};
    try {
      rq_message_obj = JSON.parse(rq_message);
    }
    catch (ex) {
      _this.jsh.Log.error('Error parsing RQ_MESSAGE: ' + rq_message_obj);
    }
    _this.db.Scalar('jobproc', "jobproc_saveRQ", 
      [dbtypes.VarChar(255)], { 'RQ_NAME': job.RQ_NAME }, function (err, rslt) {
      if ((err == null) && (rslt == null)) { _this.jsh.Log.error(err); err = Helper.NewError('Error inserting remote queue request', -99999); }
      if (err == null) {
        RQ_ID = rslt;
        rq_message_obj.url = '/_dl/RQ/' + RQ_ID + '/RQ_FILE';
        rq_message_obj.filetype = 'pdf';
        _this.db.Command('jobproc', "jobproc_saveRQ_MESSAGE", 
          [dbtypes.BigInt, dbtypes.VarChar(dbtypes.MAX)], 
          { 'RQ_ID': RQ_ID, 'RQ_MESSAGE': JSON.stringify(rq_message_obj) }, function (err, rslt) {
          callback(err);
        });
      }
      else callback(err);
    });
  };
  var saveN = function (callback) {
    _this.db.Command('jobproc', "jobproc_saveN", 
      [dbtypes.VarChar(8), dbtypes.BigInt, dbtypes.VarChar(8), dbtypes.VarChar(dbtypes.MAX)], 
      { 'N_SCOPE': job.N_SCOPE, 'N_SCOPE_ID': job.N_SCOPE_ID, 'N_TYPE': job.N_TYPE, 'N_Note': job.N_Note }, function (err, rslt) {
      callback(err);
    });
  };
  var sendEMAIL = function (callback) {
    //Add attachment??
    if (_this.jshFactory.Config.debug_params.no_job_email) return callback(null);
    var attachments = [];
    async.waterfall([
      function(cb){
        if (job.EMAIL_ATTACH && tmppath){
          fs.exists(tmppath, function(exists){
            if(!exists) return cb(new Error('Report output does not exist'));
            attachments.push({ filename: 'D' + (D_ID||'0') + '.pdf', content: fs.createReadStream(tmppath) });
            return cb();
          });
        }
        else return cb();
      },
      function(cb){
        if (job.EMAIL_D_ID){
          var email_d_id_path = _this.jsh.Config.datadir + '/D/D_FILE_' + job.EMAIL_D_ID;
          fs.exists(email_d_id_path, function(exists){
            if(!exists) return cb(new Error('Email D_ID does not exist'));
            attachments.push({ filename: job.EMAIL_D_FileName, content: fs.createReadStream(email_d_id_path) });
            return cb();
          });
        }
        else return cb();
      },
      function(cb){
        if (job.EMAIL_TXT_ATTRIB) thisapp.jsh.SendTXTEmail('jobproc', job.EMAIL_TXT_ATTRIB, job.EMAIL_TO, job.EMAIL_CC, job.EMAIL_BCC, attachments, dbdata, cb);
        else thisapp.jsh.SendBaseEmail('jobproc', job.EMAIL_SUBJECT, job.EMAIL_TEXT, job.EMAIL_HTML, job.EMAIL_TO, job.EMAIL_CC, job.EMAIL_BCC, attachments, dbdata, cb);
      }
    ], callback);
  }
  var sendSMS = function (callback) {
    //Add attachment??
    if (_this.jshFactory.Config.debug_params.no_job_sms) return callback(null);
    if (job.SMS_TXT_ATTRIB) SMS.SendTXTSMS('jobproc', thisapp.jsh, job.SMS_TXT_ATTRIB, job.SMS_TO, dbdata, callback);
    else SMS.SendBaseSMS('jobproc', thisapp.jsh, job.SMS_BODY, job.SMS_TO, dbdata, callback);
  }
  
  var execarr = [];
  if (job.D_SCOPE && tmppath) {
    execarr.push(saveD);
    execarr.push(function (cb) { HelperFS.copyFile(tmppath, (_this.jsh.Config.datadir + 'D/d_file_' + D_ID), cb); });
  }
  if (job.RQ_NAME && tmppath) {
    execarr.push(saveRQ);
    execarr.push(function (cb) { HelperFS.copyFile(tmppath, (_this.jsh.Config.datadir + 'RQ/rq_file_' + RQ_ID), cb); });
  }
  if (job.N_SCOPE) execarr.push(saveN);
  if (job.SMS_TO) execarr.push(sendSMS);
  if (job.EMAIL_TO) execarr.push(sendEMAIL);
  
  async.waterfall(execarr, function (err, rslt) {
    if(err && _this.jsh.Config.debug_params.report_debug) console.log(err);
    if (err) return _this.SetJobResult(job, 'ERROR', err.toString(), onComplete);
    else return _this.SetJobResult(job, 'OK', null, onComplete);
  });
}

AppSrvJobProc.prototype.SetJobResult = function (job, RQST_RSLT, RQST_SNotes, onComplete) {
  this.jsh.Log.info('Completed Job #' + job.RQST_ID + ': ' + RQST_RSLT + (RQST_SNotes ? ' - ' + RQST_SNotes : ''));
  var dbtypes = this.AppSrv.DB.types;
  this.AppSrv.ExecRow('jobproc', "jobproc_jobresult", [dbtypes.VarChar(8), dbtypes.VarChar(dbtypes.MAX), dbtypes.BigInt], { 'RQST_RSLT': RQST_RSLT, 'RQST_SNotes': RQST_SNotes, 'RQST_ID': job.RQST_ID }, function (err, rslt) {
    onComplete();
  });
}

AppSrvJobProc.prototype.AddDBJob = function (req, res, jobtasks, jobtaskid, _jrow, fullmodelid, rparams) {
  var _this = this;
  var thisapp = this.AppSrv;
  var dbtypes = thisapp.DB.types;
  var jobvalidate = new XValidate();
  var jrow = _this.map_db_rslt(_jrow);
  var job_sql = this.AppSrv.getSQL('','jobproc_add_BEGIN');
  var job_sql_ptypes = [dbtypes.VarChar(8), dbtypes.VarChar(8), dbtypes.VarChar(50), dbtypes.VarChar(dbtypes.MAX)];
  var job_sql_params = { 'RQST_SOURCE': jrow.RQST_SOURCE, 'RQST_ATYPE': 'REPORT', 'RQST_ANAME': fullmodelid, 'RQST_PARMS': JSON.stringify(rparams) };
  jobvalidate.AddValidator('_obj.RQST_SOURCE', 'RQST_SOURCE', 'B', [XValidate._v_MaxLength(8), XValidate._v_Required()]);
  if ('D_SCOPE' in jrow) {
    //Add Document to Job
    if (!('D_SCOPE_ID' in jrow) || !('D_CTGR' in jrow) || !('D_Desc' in jrow)) throw new Error('Job with D_SCOPE requires D_SCOPE_ID, D_CTGR, and D_Desc');
    job_sql += this.AppSrv.getSQL('','jobproc_add_RQST_D');
    job_sql_ptypes.push(dbtypes.VarChar(8));
    job_sql_params['D_SCOPE'] = jrow.D_SCOPE;
    jobvalidate.AddValidator('_obj.D_SCOPE', 'D_SCOPE', 'B', [XValidate._v_MaxLength(8), XValidate._v_Required()]);
    job_sql_ptypes.push(dbtypes.BigInt);
    job_sql_params['D_SCOPE_ID'] = jrow.D_SCOPE_ID;
    jobvalidate.AddValidator('_obj.D_SCOPE_ID', 'D_SCOPE_ID', 'B', [XValidate._v_IsNumeric(), XValidate._v_Required()]);
    job_sql_ptypes.push(dbtypes.VarChar(8));
    job_sql_params['D_CTGR'] = jrow.D_CTGR;
    jobvalidate.AddValidator('_obj.D_CTGR', 'D_CTGR', 'B', [XValidate._v_MaxLength(8), XValidate._v_Required()]);
    job_sql_ptypes.push(dbtypes.VarChar(255));
    job_sql_params['D_Desc'] = jrow.D_Desc;
    jobvalidate.AddValidator('_obj.D_Desc', 'D_Desc', 'B', [XValidate._v_MaxLength(255), XValidate._v_Required()]);
  }
  if ('RQ_NAME' in jrow) {
    //Add Document to Job
    job_sql += this.AppSrv.getSQL('','jobproc_add_RQST_RQ');
    job_sql_ptypes.push(dbtypes.VarChar(255));
    job_sql_params['RQ_NAME'] = jrow.RQ_NAME;
    jobvalidate.AddValidator('_obj.RQ_NAME', 'RQ_NAME', 'B', [XValidate._v_MaxLength(255), XValidate._v_Required()]);
    job_sql_ptypes.push(dbtypes.VarChar(dbtypes.MAX));
    job_sql_params['RQ_MESSAGE'] = jrow.RQ_MESSAGE || '';
    jobvalidate.AddValidator('_obj.RQ_MESSAGE', 'RQ_MESSAGE', 'B', [XValidate._v_MaxLength(8)]);
  }
  if ('EMAIL_TO' in jrow) {
    //Add Email to Job
    if (!('EMAIL_TXT_ATTRIB' in jrow) && !('EMAIL_SUBJECT' in jrow)) throw new Error('Job with EMAIL_TO requires EMAIL_TXT_ATTRIB or EMAIL_SUBJECT');
    job_sql += this.AppSrv.getSQL('','jobproc_add_RQST_EMAIL');
    job_sql_ptypes.push(dbtypes.VarChar(32));
    job_sql_params['EMAIL_TXT_ATTRIB'] = jrow.EMAIL_TXT_ATTRIB;
    jobvalidate.AddValidator('_obj.EMAIL_TXT_ATTRIB', 'EMAIL_TXT_ATTRIB', 'B', [XValidate._v_MaxLength(32)]);
    job_sql_ptypes.push(dbtypes.VarChar(255));
    job_sql_params['EMAIL_TO'] = jrow.EMAIL_TO;
    jobvalidate.AddValidator('_obj.EMAIL_TO', 'EMAIL_TO', 'B', [XValidate._v_MaxLength(255), XValidate._v_Required()]);
    job_sql_ptypes.push(dbtypes.VarChar(255));
    job_sql_params['EMAIL_CC'] = jrow.EMAIL_CC || null;
    jobvalidate.AddValidator('_obj.EMAIL_CC', 'EMAIL_CC', 'B', [XValidate._v_MaxLength(255)]);
    job_sql_ptypes.push(dbtypes.VarChar(255));
    job_sql_params['EMAIL_BCC'] = jrow.EMAIL_BCC || null;
    jobvalidate.AddValidator('_obj.EMAIL_BCC', 'EMAIL_BCC', 'B', [XValidate._v_MaxLength(255)]);
    job_sql_ptypes.push(dbtypes.SmallInt);
    job_sql_params['EMAIL_ATTACH'] = jrow.EMAIL_ATTACH;
    jobvalidate.AddValidator('_obj.EMAIL_ATTACH', 'EMAIL_ATTACH', 'B', [XValidate._v_IsNumeric()]);
    job_sql_ptypes.push(dbtypes.VarChar(500));
    job_sql_params['EMAIL_SUBJECT'] = jrow.EMAIL_SUBJECT || null;
    jobvalidate.AddValidator('_obj.EMAIL_SUBJECT', 'EMAIL_SUBJECT', 'B', [XValidate._v_MaxLength(500)]);
    job_sql_ptypes.push(dbtypes.VarChar(dbtypes.MAX));
    job_sql_params['EMAIL_TEXT'] = jrow.EMAIL_TEXT || null;
    job_sql_ptypes.push(dbtypes.VarChar(dbtypes.MAX));
    job_sql_params['EMAIL_HTML'] = jrow.EMAIL_HTML || null;
    job_sql_ptypes.push(dbtypes.BigInt);
    job_sql_params['EMAIL_D_ID'] = jrow.EMAIL_D_ID || null;
    jobvalidate.AddValidator('_obj.EMAIL_D_ID', 'EMAIL_D_ID', 'B', [XValidate._v_IsNumeric()]);
  }
  if ('SMS_TO' in jrow) {
    //Add SMS to Job
    if (!('SMS_TXT_ATTRIB' in jrow) && !('SMS_BODY' in jrow)) throw new Error('Job with SMS_TO requires SMS_TXT_ATTRIB or SMS_BODY');
    job_sql += this.AppSrv.getSQL('','jobproc_add_RQST_SMS');
    job_sql_ptypes.push(dbtypes.VarChar(32));
    job_sql_params['SMS_TXT_ATTRIB'] = jrow.SMS_TXT_ATTRIB;
    jobvalidate.AddValidator('_obj.SMS_TXT_ATTRIB', 'SMS_TXT_ATTRIB', 'B', [XValidate._v_MaxLength(32)]);
    job_sql_ptypes.push(dbtypes.VarChar(255));
    job_sql_params['SMS_TO'] = jrow.SMS_TO;
    jobvalidate.AddValidator('_obj.SMS_TO', 'SMS_TO', 'B', [XValidate._v_MaxLength(255), XValidate._v_Required()]);
    job_sql_ptypes.push(dbtypes.VarChar(dbtypes.MAX));
    job_sql_params['SMS_BODY'] = jrow.SMS_BODY || null;
  }
  if ('N_SCOPE' in jrow) {
    //Add Note to Job
    if (!('N_SCOPE_ID' in jrow) || !('N_TYPE' in jrow) || !('N_Note' in jrow)) throw new Error('Job with N_SCOPE requires N_SCOPE_ID, N_TYPE, and N_Note');
    job_sql += this.AppSrv.getSQL('','jobproc_add_RQST_N');
    job_sql_ptypes.push(dbtypes.VarChar(8));
    job_sql_params['N_SCOPE'] = jrow.N_SCOPE;
    jobvalidate.AddValidator('_obj.N_SCOPE', 'N_SCOPE', 'B', [XValidate._v_MaxLength(8), XValidate._v_Required()]);
    job_sql_ptypes.push(dbtypes.BigInt);
    job_sql_params['N_SCOPE_ID'] = jrow.N_SCOPE_ID;
    jobvalidate.AddValidator('_obj.N_SCOPE_ID', 'N_SCOPE_ID', 'B', [XValidate._v_IsNumeric(), XValidate._v_Required()]);
    job_sql_ptypes.push(dbtypes.VarChar(8));
    job_sql_params['N_TYPE'] = jrow.N_TYPE;
    jobvalidate.AddValidator('_obj.N_TYPE', 'N_TYPE', 'B', [XValidate._v_MaxLength(8), XValidate._v_Required()]);
    job_sql_ptypes.push(dbtypes.VarChar(dbtypes.MAX));
    job_sql_params['N_Note'] = jrow.N_Note;
    jobvalidate.AddValidator('_obj.N_Note', 'N_Note', 'B', [XValidate._v_Required()]);
  }
  job_sql += this.AppSrv.getSQL('','jobproc_add_END');
  var verrors = _.merge(verrors, jobvalidate.Validate('B', job_sql_params));
  if (!_.isEmpty(verrors)) { Helper.GenError(req, res, -99999, 'Error during job queue: ' + verrors[''].join('\n') + ' ' + JSON.stringify(job_sql_params)); return; }
  //Add SQL to Transaction
  
  jobtasks[jobtaskid] = function (dbtrans, callback, transtbl) {
    _this.db.Command(req._DBContext, job_sql, job_sql_ptypes, job_sql_params, dbtrans, function (err, rslt) {
      if (err != null) { err.sql = job_sql; }
      callback(err, rslt);
    });
  }
  return true;
};

AppSrvJobProc.prototype.SetSubscriberQueueResult = function (RQ_ID, RQ_RSLT, RQ_SNotes, onComplete) {
  var _this = this;
  _this.jsh.Log.info('Completed Queue Task #' + RQ_ID + ': ' + RQ_RSLT + (RQ_SNotes ? ' - ' + RQ_SNotes : ''));
  var dbtypes = this.AppSrv.DB.types;
  this.AppSrv.ExecRow('jobproc', "jobproc_queueresult", [dbtypes.VarChar(8), dbtypes.VarChar(dbtypes.MAX), dbtypes.BigInt], { 'RQ_RSLT': RQ_RSLT, 'RQ_SNotes': RQ_SNotes, 'RQ_ID': RQ_ID }, function (err, rslt) {
    if (err) { _this.jsh.Log.error(err); }
    if (onComplete) onComplete();
  });
}

AppSrvJobProc.prototype.SubscribeToQueue = function (req, res, queueid) {
  //Check if queue has a message, otherwise, add to subscriptions
  var _this = this;
  var dbtypes = this.AppSrv.DB.types;
  this.AppSrv.ExecRow('jobproc', "jobproc_queuecheck", [dbtypes.VarChar(255)], { 'RQ_NAME': queueid }, function (err, rslt) {
    if (err != null) { _this.jsh.Log.error(err); return onComplete(null); }
    if ((rslt != null) && (rslt.length == 1) && (rslt[0])) {
      var queuetask = _this.map_db_rslt(rslt[0]);
      _this.jsh.Log.info('Notifying subscriber ' + queueid);
      var msg = JSON.stringify({ ID: queuetask.RQ_ID, MESSAGE: queuetask.RQ_MESSAGE });
      res.send(msg);
    }
    else {
      _this.AppSrv.QueueSubscriptions.push({ id: queueid, req: req, res: res });
    }
  });
}

AppSrvJobProc.prototype.CheckSubscriberQueue = function (onComplete) {
  var _this = this;
  if(_.isEmpty(_this.AppSrv.jsh.Config.queues)) return onComplete();
  for(var queueName in _this.QueueHistory){
    if(_this.QueueHistory[queueName]==1) _this.QueueHistory[queueName] = 2;
    else delete _this.QueueHistory[queueName];
  }
  this.AppSrv.ExecRecordset('jobproc', "jobproc_queuesubscribers", [], {}, function (err, rslt) {
    if (err != null) { _this.jsh.Log.error(err); return onComplete(null); }
    //Handle invalid queue
    //Update results
    if ((rslt != null) && (rslt.length == 1) && (rslt[0])) {
      async.each(rslt[0], function (row, queue_cb) {
        var queuetask = _this.map_db_rslt(row);
        if (!(queuetask.RQ_NAME in _this.AppSrv.jsh.Config.queues)) {
          _this.SetSubscriberQueueResult(queuetask.RQ_ID, 'ERROR', 'Queue not set up in config', queue_cb);
        }
        else {
          if(!_this.QueueHistory[queuetask.RQ_NAME]) _this.jsh.Log.info('Message for queue ' + queuetask.RQ_NAME);
          _this.QueueHistory[queuetask.RQ_NAME] = 1;
          var msg = JSON.stringify({ ID: queuetask.RQ_ID, MESSAGE: queuetask.RQ_MESSAGE });
          _this.AppSrv.SendQueue(queuetask.RQ_NAME, msg);
          queue_cb(null);
        }
      },
        function (err) {
        if (err) _this.jsh.Log.error(err);
        return onComplete(null);
      });
    }
  });
}

AppSrvJobProc.prototype.PopQueue = function (req, res, queueid, queueresult, onComplete) {
  var _this = this;
  var dbtypes = this.AppSrv.DB.types;
  this.AppSrv.ExecScalar('jobproc', "jobproc_queuepop", [dbtypes.BigInt, dbtypes.VarChar(255)], { 'RQ_ID': queueresult.ID, 'RQ_NAME': queueid }, function (err, rslt) {
    if (err) { return Helper.GenError(req, res, -99999, err); }
    else if ((rslt == null) || (rslt.length != 1) || (!rslt[0])) { return Helper.GenError(req, res, -99999, 'Queue item ID does not exist or has already been resulted.'); }
    if (onComplete) onComplete(null);
    _this.SetSubscriberQueueResult(queueresult.ID, queueresult.RSLT, queueresult.NOTES, function () {
      //Delete request file, if applicable
      if (queueresult.RSLT == 'OK') HelperFS.tryUnlink((_this.jsh.Config.datadir + 'RQ/rq_file_' + queueresult.ID), onComplete);
      else if (onComplete) onComplete();
    });
  });
}

AppSrvJobProc.ExecuteSQL = function (sql){
  return function (jobproc){
    jobproc.AppSrv.ExecRecordset('jobproc', sql, [], { }, function (err, rslt) {
      if (err) _this.jsh.Log.error('Error Running Task: '+err.toString());
      if (rslt && rslt[0]) _this.jsh.Log.info('Task Result: '+JSON.stringify(rslt));
    });
  }
}

module.exports = AppSrvJobProc;