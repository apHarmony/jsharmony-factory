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
    if (job.email_to) job.email_to = _this.jshFactory.Config.debug_params.email_override;
    if (job.email_cc) job.email_cc = _this.jshFactory.Config.debug_params.email_override;
    if (job.email_bcc) job.email_bcc = _this.jshFactory.Config.debug_params.email_override;
  }
  if (_this.jshFactory.Config.debug_params.sms_override) {
    if (job.sms_to) job.sms_to = _this.jshFactory.Config.debug_params.sms_override;
  }
  _this.jsh.Log.info('Starting Job #' + job.rqst_id);
  if (_this.jshFactory.Config.debug_params.job_requests) _this.jsh.Log.info(job);
  
  if (job.rqst_atype == 'REPORT') return _this.ExecJob_REPORT(job, onComplete);
  else if (job.rqst_atype == 'MESSAGE') return _this.ExecJob_MESSAGE(job, onComplete);
  else return _this.SetJobResult(job, 'ERROR', 'rqst_atype not Supported', onComplete);
};

AppSrvJobProc.prototype.ExecJob_MESSAGE = function (job, onComplete) {
  var _this = this;
  var thisapp = this.AppSrv;
  if (job.rqst_atype != 'MESSAGE') return _this.SetJobResult(job, 'ERROR', 'rqst_atype not MESSAGE', onComplete);
  
  var rparams = {};
  if (job.rqst_parms){
    try{
      rparams = JSON.parse(job.rqst_parms);
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
  if (job.rqst_atype != 'REPORT') return _this.SetJobResult(job, 'ERROR', 'rqst_atype not REPORT', onComplete);

  //Process Report ID (make sure it's in the system)
  var fullmodelid = job.rqst_aname;
  if (!thisapp.jsh.hasModel(undefined, fullmodelid)) return _this.SetJobResult(job, 'ERROR', 'Report not found in collection', onComplete);
  
  var rparams = {};
  if (job.rqst_parms) rparams = JSON.parse(job.rqst_parms);

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
  var d_id = null;
  var rq_id = null;
  var saveD = function (callback) {
    _this.db.Scalar('jobproc', "jobproc_saveD", 
      [dbtypes.VarChar(8), dbtypes.BigInt, dbtypes.VarChar(8), dbtypes.VarChar(255), dbtypes.BigInt], 
      { 'd_scope': job.d_scope, 'd_scope_id': job.d_scope_id, 'd_ctgr': job.d_ctgr, 'd_desc': job.d_desc, 'd_size': fsize }, function (err, rslt) {
      if ((err == null) && (rslt == null)) { _this.jsh.Log.error(err); err = Helper.NewError('Error inserting document', -99999); }
      if (err == null) d_id = rslt;
      callback(err);
    });
  };
  var saveRQ = function (callback) {
    var rq_message = job.rq_message || '{}';
    var rq_message_obj = {};
    try {
      rq_message_obj = JSON.parse(rq_message);
    }
    catch (ex) {
      _this.jsh.Log.error('Error parsing rq_message: ' + rq_message_obj);
    }
    _this.db.Scalar('jobproc', "jobproc_saveRQ", 
      [dbtypes.VarChar(255)], { 'rq_name': job.rq_name }, function (err, rslt) {
      if ((err == null) && (rslt == null)) { _this.jsh.Log.error(err); err = Helper.NewError('Error inserting remote queue request', -99999); }
      if (err == null) {
        rq_id = rslt;
        rq_message_obj.url = '/_dl/RQ/' + rq_id + '/RQ_FILE';
        rq_message_obj.filetype = 'pdf';
        _this.db.Command('jobproc', "jobproc_saverq_message", 
          [dbtypes.BigInt, dbtypes.VarChar(dbtypes.MAX)], 
          { 'rq_id': rq_id, 'rq_message': JSON.stringify(rq_message_obj) }, function (err, rslt) {
          callback(err);
        });
      }
      else callback(err);
    });
  };
  var saveN = function (callback) {
    _this.db.Command('jobproc', "jobproc_saveN", 
      [dbtypes.VarChar(8), dbtypes.BigInt, dbtypes.VarChar(8), dbtypes.VarChar(dbtypes.MAX)], 
      { 'n_scope': job.n_scope, 'n_scope_id': job.n_scope_id, 'n_type': job.n_type, 'n_note': job.n_note }, function (err, rslt) {
      callback(err);
    });
  };
  var sendEMAIL = function (callback) {
    //Add attachment??
    if (_this.jshFactory.Config.debug_params.no_job_email) return callback(null);
    var attachments = [];
    async.waterfall([
      function(cb){
        if (job.email_attach && tmppath){
          fs.exists(tmppath, function(exists){
            if(!exists) return cb(new Error('Report output does not exist'));
            attachments.push({ filename: 'D' + (d_id||'0') + '.pdf', content: fs.createReadStream(tmppath) });
            return cb();
          });
        }
        else return cb();
      },
      function(cb){
        if (job.email_d_id){
          var email_d_id_path = _this.jsh.Config.datadir + '/D/D_FILE_' + job.email_d_id;
          fs.exists(email_d_id_path, function(exists){
            if(!exists) return cb(new Error('Email d_id does not exist'));
            attachments.push({ filename: job.email_d_filename, content: fs.createReadStream(email_d_id_path) });
            return cb();
          });
        }
        else return cb();
      },
      function(cb){
        if (job.email_txt_attrib) thisapp.jsh.SendTXTEmail('jobproc', job.email_txt_attrib, job.email_to, job.email_cc, job.email_bcc, attachments, dbdata, cb);
        else thisapp.jsh.SendBaseEmail('jobproc', job.email_subject, job.email_text, job.email_html, job.email_to, job.email_cc, job.email_bcc, attachments, dbdata, cb);
      }
    ], callback);
  }
  var sendSMS = function (callback) {
    //Add attachment??
    if (_this.jshFactory.Config.debug_params.no_job_sms) return callback(null);
    if (job.sms_txt_attrib) SMS.SendTXTSMS('jobproc', thisapp.jsh, job.sms_txt_attrib, job.sms_to, dbdata, callback);
    else SMS.SendBaseSMS('jobproc', thisapp.jsh, job.sms_body, job.sms_to, dbdata, callback);
  }
  
  var execarr = [];
  if (job.d_scope && tmppath) {
    execarr.push(saveD);
    execarr.push(function (cb) { HelperFS.copyFile(tmppath, (_this.jsh.Config.datadir + 'D/d_file_' + d_id), cb); });
  }
  if (job.rq_name && tmppath) {
    execarr.push(saveRQ);
    execarr.push(function (cb) { HelperFS.copyFile(tmppath, (_this.jsh.Config.datadir + 'RQ/rq_file_' + rq_id), cb); });
  }
  if (job.n_scope) execarr.push(saveN);
  if (job.sms_to) execarr.push(sendSMS);
  if (job.email_to) execarr.push(sendEMAIL);
  
  async.waterfall(execarr, function (err, rslt) {
    if(err && _this.jsh.Config.debug_params.report_debug) console.log(err);
    if (err) return _this.SetJobResult(job, 'ERROR', err.toString(), onComplete);
    else return _this.SetJobResult(job, 'OK', null, onComplete);
  });
}

AppSrvJobProc.prototype.SetJobResult = function (job, rqst_rslt, rqst_snotes, onComplete) {
  this.jsh.Log.info('Completed Job #' + job.rqst_id + ': ' + rqst_rslt + (rqst_snotes ? ' - ' + rqst_snotes : ''));
  var dbtypes = this.AppSrv.DB.types;
  this.AppSrv.ExecRow('jobproc', "jobproc_jobresult", [dbtypes.VarChar(8), dbtypes.VarChar(dbtypes.MAX), dbtypes.BigInt], { 'rqst_rslt': rqst_rslt, 'rqst_snotes': rqst_snotes, 'rqst_id': job.rqst_id }, function (err, rslt) {
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
  var job_sql_params = { 'rqst_source': jrow.rqst_source, 'rqst_atype': 'REPORT', 'rqst_aname': fullmodelid, 'rqst_parms': JSON.stringify(rparams) };
  jobvalidate.AddValidator('_obj.rqst_source', 'rqst_source', 'B', [XValidate._v_MaxLength(8), XValidate._v_Required()]);
  if ('d_scope' in jrow) {
    //Add Document to Job
    if (!('d_scope_id' in jrow) || !('d_ctgr' in jrow) || !('d_desc' in jrow)) throw new Error('Job with d_scope requires d_scope_id, d_ctgr, and d_desc');
    job_sql += this.AppSrv.getSQL('','jobproc_add_RQST_D');
    job_sql_ptypes.push(dbtypes.VarChar(8));
    job_sql_params['d_scope'] = jrow.d_scope;
    jobvalidate.AddValidator('_obj.d_scope', 'd_scope', 'B', [XValidate._v_MaxLength(8), XValidate._v_Required()]);
    job_sql_ptypes.push(dbtypes.BigInt);
    job_sql_params['d_scope_id'] = jrow.d_scope_id;
    jobvalidate.AddValidator('_obj.d_scope_id', 'd_scope_id', 'B', [XValidate._v_IsNumeric(), XValidate._v_Required()]);
    job_sql_ptypes.push(dbtypes.VarChar(8));
    job_sql_params['d_ctgr'] = jrow.d_ctgr;
    jobvalidate.AddValidator('_obj.d_ctgr', 'd_ctgr', 'B', [XValidate._v_MaxLength(8), XValidate._v_Required()]);
    job_sql_ptypes.push(dbtypes.VarChar(255));
    job_sql_params['d_desc'] = jrow.d_desc;
    jobvalidate.AddValidator('_obj.d_desc', 'd_desc', 'B', [XValidate._v_MaxLength(255), XValidate._v_Required()]);
  }
  if ('rq_name' in jrow) {
    //Add Document to Job
    job_sql += this.AppSrv.getSQL('','jobproc_add_RQST_RQ');
    job_sql_ptypes.push(dbtypes.VarChar(255));
    job_sql_params['rq_name'] = jrow.rq_name;
    jobvalidate.AddValidator('_obj.rq_name', 'rq_name', 'B', [XValidate._v_MaxLength(255), XValidate._v_Required()]);
    job_sql_ptypes.push(dbtypes.VarChar(dbtypes.MAX));
    job_sql_params['rq_message'] = jrow.rq_message || '';
    jobvalidate.AddValidator('_obj.rq_message', 'rq_message', 'B', [XValidate._v_MaxLength(8)]);
  }
  if ('email_to' in jrow) {
    //Add Email to Job
    if (!('email_txt_attrib' in jrow) && !('email_subject' in jrow)) throw new Error('Job with email_to requires email_txt_attrib or email_subject');
    job_sql += this.AppSrv.getSQL('','jobproc_add_RQST_EMAIL');
    job_sql_ptypes.push(dbtypes.VarChar(32));
    job_sql_params['email_txt_attrib'] = jrow.email_txt_attrib;
    jobvalidate.AddValidator('_obj.email_txt_attrib', 'email_txt_attrib', 'B', [XValidate._v_MaxLength(32)]);
    job_sql_ptypes.push(dbtypes.VarChar(255));
    job_sql_params['email_to'] = jrow.email_to;
    jobvalidate.AddValidator('_obj.email_to', 'email_to', 'B', [XValidate._v_MaxLength(255), XValidate._v_Required()]);
    job_sql_ptypes.push(dbtypes.VarChar(255));
    job_sql_params['email_cc'] = jrow.email_cc || null;
    jobvalidate.AddValidator('_obj.email_cc', 'email_cc', 'B', [XValidate._v_MaxLength(255)]);
    job_sql_ptypes.push(dbtypes.VarChar(255));
    job_sql_params['email_bcc'] = jrow.email_bcc || null;
    jobvalidate.AddValidator('_obj.email_bcc', 'email_bcc', 'B', [XValidate._v_MaxLength(255)]);
    job_sql_ptypes.push(dbtypes.SmallInt);
    job_sql_params['email_attach'] = jrow.email_attach;
    jobvalidate.AddValidator('_obj.email_attach', 'email_attach', 'B', [XValidate._v_IsNumeric()]);
    job_sql_ptypes.push(dbtypes.VarChar(500));
    job_sql_params['email_subject'] = jrow.email_subject || null;
    jobvalidate.AddValidator('_obj.email_subject', 'email_subject', 'B', [XValidate._v_MaxLength(500)]);
    job_sql_ptypes.push(dbtypes.VarChar(dbtypes.MAX));
    job_sql_params['email_text'] = jrow.email_text || null;
    job_sql_ptypes.push(dbtypes.VarChar(dbtypes.MAX));
    job_sql_params['email_html'] = jrow.email_html || null;
    job_sql_ptypes.push(dbtypes.BigInt);
    job_sql_params['email_d_id'] = jrow.email_d_id || null;
    jobvalidate.AddValidator('_obj.email_d_id', 'email_d_id', 'B', [XValidate._v_IsNumeric()]);
  }
  if ('sms_to' in jrow) {
    //Add SMS to Job
    if (!('sms_txt_attrib' in jrow) && !('sms_body' in jrow)) throw new Error('Job with sms_to requires sms_txt_attrib or sms_body');
    job_sql += this.AppSrv.getSQL('','jobproc_add_RQST_SMS');
    job_sql_ptypes.push(dbtypes.VarChar(32));
    job_sql_params['sms_txt_attrib'] = jrow.sms_txt_attrib;
    jobvalidate.AddValidator('_obj.sms_txt_attrib', 'sms_txt_attrib', 'B', [XValidate._v_MaxLength(32)]);
    job_sql_ptypes.push(dbtypes.VarChar(255));
    job_sql_params['sms_to'] = jrow.sms_to;
    jobvalidate.AddValidator('_obj.sms_to', 'sms_to', 'B', [XValidate._v_MaxLength(255), XValidate._v_Required()]);
    job_sql_ptypes.push(dbtypes.VarChar(dbtypes.MAX));
    job_sql_params['sms_body'] = jrow.sms_body || null;
  }
  if ('n_scope' in jrow) {
    //Add Note to Job
    if (!('n_scope_id' in jrow) || !('n_type' in jrow) || !('n_note' in jrow)) throw new Error('Job with n_scope requires n_scope_id, n_type, and n_note');
    job_sql += this.AppSrv.getSQL('','jobproc_add_RQST_N');
    job_sql_ptypes.push(dbtypes.VarChar(8));
    job_sql_params['n_scope'] = jrow.n_scope;
    jobvalidate.AddValidator('_obj.n_scope', 'n_scope', 'B', [XValidate._v_MaxLength(8), XValidate._v_Required()]);
    job_sql_ptypes.push(dbtypes.BigInt);
    job_sql_params['n_scope_id'] = jrow.n_scope_id;
    jobvalidate.AddValidator('_obj.n_scope_id', 'n_scope_id', 'B', [XValidate._v_IsNumeric(), XValidate._v_Required()]);
    job_sql_ptypes.push(dbtypes.VarChar(8));
    job_sql_params['n_type'] = jrow.n_type;
    jobvalidate.AddValidator('_obj.n_type', 'n_type', 'B', [XValidate._v_MaxLength(8), XValidate._v_Required()]);
    job_sql_ptypes.push(dbtypes.VarChar(dbtypes.MAX));
    job_sql_params['n_note'] = jrow.n_note;
    jobvalidate.AddValidator('_obj.n_note', 'n_note', 'B', [XValidate._v_Required()]);
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

AppSrvJobProc.prototype.SetSubscriberQueueResult = function (rq_id, rq_rslt, rq_snotes, onComplete) {
  var _this = this;
  _this.jsh.Log.info('Completed Queue Task #' + rq_id + ': ' + rq_rslt + (rq_snotes ? ' - ' + rq_snotes : ''));
  var dbtypes = this.AppSrv.DB.types;
  this.AppSrv.ExecRow('jobproc', "jobproc_queueresult", [dbtypes.VarChar(8), dbtypes.VarChar(dbtypes.MAX), dbtypes.BigInt], { 'rq_rslt': rq_rslt, 'rq_snotes': rq_snotes, 'rq_id': rq_id }, function (err, rslt) {
    if (err) { _this.jsh.Log.error(err); }
    if (onComplete) onComplete();
  });
}

AppSrvJobProc.prototype.SubscribeToQueue = function (req, res, queueid) {
  //Check if queue has a message, otherwise, add to subscriptions
  var _this = this;
  var dbtypes = this.AppSrv.DB.types;
  this.AppSrv.ExecRow('jobproc', "jobproc_queuecheck", [dbtypes.VarChar(255)], { 'rq_name': queueid }, function (err, rslt) {
    if (err != null) { _this.jsh.Log.error(err); return onComplete(null); }
    if ((rslt != null) && (rslt.length == 1) && (rslt[0])) {
      var queuetask = _this.map_db_rslt(rslt[0]);
      _this.jsh.Log.info('Notifying subscriber ' + queueid);
      var msg = JSON.stringify({ ID: queuetask.rq_id, MESSAGE: queuetask.rq_message });
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
        if (!(queuetask.rq_name in _this.AppSrv.jsh.Config.queues)) {
          _this.SetSubscriberQueueResult(queuetask.rq_id, 'ERROR', 'Queue not set up in config', queue_cb);
        }
        else {
          if(!_this.QueueHistory[queuetask.rq_name]) _this.jsh.Log.info('Message for queue ' + queuetask.rq_name);
          _this.QueueHistory[queuetask.rq_name] = 1;
          var msg = JSON.stringify({ ID: queuetask.rq_id, MESSAGE: queuetask.rq_message });
          _this.AppSrv.SendQueue(queuetask.rq_name, msg);
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
  this.AppSrv.ExecScalar('jobproc', "jobproc_queuepop", [dbtypes.BigInt, dbtypes.VarChar(255)], { 'rq_id': queueresult.ID, 'rq_name': queueid }, function (err, rslt) {
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