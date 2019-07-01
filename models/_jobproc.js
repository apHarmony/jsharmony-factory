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

AppSrvJobProc.prototype._transform = function(elem){
  return this.jshFactory.transform.mapping[elem];
}

AppSrvJobProc.prototype._map = function(elem){
  return this.jshFactory.Config.job_field_mapping[elem];
}

AppSrvJobProc.prototype.transform_db_params = function(params) {
  var _this = this;
  if (!params) return params;
  var rslt = {};
  for (var f in params) {
    if (f in _this.jshFactory.transform.mapping) {
      rslt[_this.jshFactory.transform.mapping[f]] = params[f];
    }
    else rslt[f] = params[f];
  }
  return rslt;
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
  this.AppSrv.ExecRow('jobproc', _this._transform("jobproc_jobcheck"), [], {}, function (err, rslt) {
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
  _this.jsh.Log.info('Starting Job #' + job.job_id);
  if (_this.jshFactory.Config.debug_params.job_requests) _this.jsh.Log.info(job);
  
  if (job.job_action == 'REPORT') return _this.ExecJob_REPORT(job, onComplete);
  else if (job.job_action == 'MESSAGE') return _this.ExecJob_MESSAGE(job, onComplete);
  else return _this.SetJobResult(job, 'ERROR', 'job_action not Supported', onComplete);
};

AppSrvJobProc.prototype.ExecJob_MESSAGE = function (job, onComplete) {
  var _this = this;
  var thisapp = this.AppSrv;
  if (job.job_action != 'MESSAGE') return _this.SetJobResult(job, 'ERROR', 'job_action not MESSAGE', onComplete);
  
  var rparams = {};
  if (job.job_params){
    try{
      rparams = JSON.parse(job.job_params);
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
  if (job.job_action != 'REPORT') return _this.SetJobResult(job, 'ERROR', 'job_action not REPORT', onComplete);

  //Process Report ID (make sure it's in the system)
  var fullmodelid = job.job_action_target;
  if (!thisapp.jsh.hasModel(undefined, fullmodelid)) return _this.SetJobResult(job, 'ERROR', 'Report not found in collection', onComplete);
  
  var rparams = {};
  if (job.job_params) rparams = JSON.parse(job.job_params);

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
  var _transform = function(elem){ return _this._transform(elem); };

  if (_this.jsh.Config.debug_params.report_debug) console.log(dbdata);
  var thisapp = this.AppSrv;
  var dbtypes = thisapp.DB.types;
  var doc_id = null;
  var queue_id = null;
  var saveD = function (callback) {
    let sqlparams = {};
    sqlparams[_transform('doc_scope')] = job.doc_scope;
    sqlparams[_transform('doc_scope_id')] = job.doc_scope_id;
    sqlparams[_transform('doc_ctgr')] = job.doc_ctgr;
    sqlparams[_transform('doc_desc')] = job.doc_desc;
    sqlparams[_transform('doc_size')] = fsize;
    _this.db.Scalar('jobproc', _this._transform("jobproc_save_doc"), 
      [dbtypes.VarChar(8), dbtypes.BigInt, dbtypes.VarChar(8), dbtypes.VarChar(255), dbtypes.BigInt], 
      sqlparams, function (err, rslt) {
      if ((err == null) && (rslt == null)) { _this.jsh.Log.error(err); err = Helper.NewError('Error inserting document', -99999); }
      if (err == null) doc_id = rslt;
      callback(err);
    });
  };
  var saveRQ = function (callback) {
    var queue_message = job.queue_message || '{}';
    var queue_message_obj = {};
    try {
      queue_message_obj = JSON.parse(queue_message);
    }
    catch (ex) {
      _this.jsh.Log.error('Error parsing '+_transform('queue_message')+': ' + queue_message_obj);
    }
    let sqlparams = {};
    sqlparams[_transform('queue_name')] = job.queue_name;
    _this.db.Scalar('jobproc', _this._transform("jobproc_save_queue"), 
      [dbtypes.VarChar(255)], sqlparams, function (err, rslt) {
      if ((err == null) && (rslt == null)) { _this.jsh.Log.error(err); err = Helper.NewError('Error inserting remote queue request', -99999); }
      if (err == null) {
        queue_id = rslt;
        queue_message_obj.url = '/_dl/'+this.jshFactory.namespace+_transform('Queue__model')+'/' + queue_id + '/'+_transform('queue__tbl')+'_file';
        queue_message_obj.filetype = 'pdf';
        let sqlparams = {};
        sqlparams[_transform('queue_id')] = queue_id;
        sqlparams[_transform('queue_message')] = JSON.stringify(queue_message_obj);
        _this.db.Command('jobproc', _this._transform("jobproc_save_queue_message"), 
          [dbtypes.BigInt, dbtypes.VarChar(dbtypes.MAX)], 
          sqlparams, function (err, rslt) {
          callback(err);
        });
      }
      else callback(err);
    });
  };
  var saveN = function (callback) {
    let sqlparams = {};
    sqlparams[_transform('note_scope')] = job.note_scope;
    sqlparams[_transform('note_scope_id')] = job.note_scope_id;
    sqlparams[_transform('note_type')] = job.note_type;
    sqlparams[_transform('note_body')] = job.note_body;
    _this.db.Command('jobproc', _this._transform("jobproc_save_note"), 
      [dbtypes.VarChar(8), dbtypes.BigInt, dbtypes.VarChar(8), dbtypes.VarChar(dbtypes.MAX)], 
      sqlparams, function (err, rslt) {
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
            var filename = _transform('doc') + (doc_id||'0') + '.pdf';
            if(job.email_attach.toString().substr(0,9)=='filename:') filename = job.email_attach.substr(9);
            attachments.push({ filename: filename, content: fs.createReadStream(tmppath) });
            return cb();
          });
        }
        else return cb();
      },
      function(cb){
        if (job.email_doc_id){
          var email_doc_id_path = _this.jsh.Config.datadir + '/'+_transform('doc')+'/'+_transform('doc')+'_file_' + job.email_doc_id;
          fs.exists(email_doc_id_path, function(exists){
            if(!exists) return cb(new Error('Email '+_transform('email_doc_id')+' does not exist'));
            attachments.push({ filename: job.email_doc_filename, content: fs.createReadStream(email_doc_id_path) });
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
  if (job.doc_scope && tmppath) {
    execarr.push(saveD);
    execarr.push(function (cb) { HelperFS.copyFile(tmppath, (_this.jsh.Config.datadir +_transform('doc')+'/'+_transform('doc')+'_file_' + doc_id), cb); });
  }
  if (job.queue_name && tmppath) {
    execarr.push(saveRQ);
    execarr.push(function (cb) { HelperFS.copyFile(tmppath, (_this.jsh.Config.datadir +_transform('queue__tbl')+'/'+_transform('queue__tbl')+'_file_' + queue_id), cb); });
  }
  if (job.note_scope) execarr.push(saveN);
  if (job.sms_to) execarr.push(sendSMS);
  if (job.email_to) execarr.push(sendEMAIL);
  
  async.waterfall(execarr, function (err, rslt) {
    if(err && _this.jsh.Config.debug_params.report_debug) console.log(err);
    if (err) return _this.SetJobResult(job, 'ERROR', err.toString(), onComplete);
    else return _this.SetJobResult(job, 'OK', null, onComplete);
  });
}

AppSrvJobProc.prototype.SetJobResult = function (job, job_rslt, job_snotes, onComplete) {
  var _this = this;
  this.jsh.Log.info('Completed Job #' + job.job_id + ': ' + job_rslt + (job_snotes ? ' - ' + job_snotes : ''));
  var dbtypes = this.AppSrv.DB.types;
  let sqlparams = {};
  sqlparams[_this._transform('job_rslt')] = job_rslt;
  sqlparams[_this._transform('job_snotes')] = job_snotes;
  sqlparams[_this._transform('job_id')] = job.job_id;
  this.AppSrv.ExecRow('jobproc', _this._transform("jobproc_jobresult"), [dbtypes.VarChar(8), dbtypes.VarChar(dbtypes.MAX), dbtypes.BigInt], sqlparams, function (err, rslt) {
    onComplete();
  });
}

AppSrvJobProc.prototype.AddDBJob = function (req, res, jobtasks, jobtaskid, _jrow, fullmodelid, rparams) {
  var _this = this;
  var _transform = function(elem){ return _this._transform(elem); };
  var _map = function(elem){ return _this._map(elem); };
  var thisapp = this.AppSrv;
  var dbtypes = thisapp.DB.types;
  var jobvalidate = new XValidate();
  var jrow = _this.map_db_rslt(_jrow);
  var job_sql = this.AppSrv.getSQL('',_this._transform('jobproc_add_BEGIN'));
  var job_sql_ptypes = [dbtypes.VarChar(8), dbtypes.VarChar(8), dbtypes.VarChar(50), dbtypes.VarChar(dbtypes.MAX)];
  var job_sql_params = {};
  job_sql_params['job_source'] = jrow.job_source;
  job_sql_params['job_action'] = 'REPORT';
  job_sql_params['job_action_target'] = fullmodelid;
  job_sql_params['job_params'] = JSON.stringify(rparams);
  jobvalidate.AddValidator('_obj.job_source', _transform('job_source'), 'B', [XValidate._v_MaxLength(8), XValidate._v_Required()]);
  if ('doc_scope' in jrow) {
    //Add Document to Job
    if (!('doc_scope_id' in jrow) || !('doc_ctgr' in jrow) || !('doc_desc' in jrow)) throw new Error('Job with d_scope requires d_scope_id, d_ctgr, and d_desc');
    job_sql += this.AppSrv.getSQL('',_this._transform('jobproc_add_doc'));
    job_sql_ptypes.push(dbtypes.VarChar(8));
    job_sql_params['doc_scope'] = jrow.doc_scope;
    jobvalidate.AddValidator('_obj.doc_scope', _transform('doc_scope'), 'B', [XValidate._v_MaxLength(8), XValidate._v_Required()]);
    job_sql_ptypes.push(dbtypes.BigInt);
    job_sql_params['doc_scope_id'] = jrow.doc_scope_id;
    jobvalidate.AddValidator('_obj.doc_scope_id', _transform('doc_scope_id'), 'B', [XValidate._v_IsNumeric(), XValidate._v_Required()]);
    job_sql_ptypes.push(dbtypes.VarChar(8));
    job_sql_params['doc_ctgr'] = jrow.doc_ctgr;
    jobvalidate.AddValidator('_obj.doc_ctgr', _transform('doc_ctgr'), 'B', [XValidate._v_MaxLength(8), XValidate._v_Required()]);
    job_sql_ptypes.push(dbtypes.VarChar(255));
    job_sql_params['doc_desc'] = jrow.doc_desc;
    jobvalidate.AddValidator('_obj.doc_desc', _transform('doc_desc'), 'B', [XValidate._v_MaxLength(255), XValidate._v_Required()]);
  }
  if ('queue_name' in jrow) {
    //Add Document to Job
    job_sql += this.AppSrv.getSQL('',_this._transform('jobproc_add_queue'));
    job_sql_ptypes.push(dbtypes.VarChar(255));
    job_sql_params['queue_name'] = jrow.queue_name;
    jobvalidate.AddValidator('_obj.queue_name', _transform('queue_name'), 'B', [XValidate._v_MaxLength(255), XValidate._v_Required()]);
    job_sql_ptypes.push(dbtypes.VarChar(dbtypes.MAX));
    job_sql_params['queue_message'] = jrow.queue_message || '';
    jobvalidate.AddValidator('_obj.queue_message', _transform('queue_message'), 'B', [XValidate._v_MaxLength(8)]);
  }
  if ('email_to' in jrow) {
    //Add Email to Job
    if (!('email_txt_attrib' in jrow) && !('email_subject' in jrow)) throw new Error('Job with email_to requires email_txt_attrib or email_subject');
    job_sql += this.AppSrv.getSQL('',_this._transform('jobproc_add_email'));
    job_sql_ptypes.push(dbtypes.VarChar(32));
    job_sql_params['email_txt_attrib'] = jrow.email_txt_attrib;
    jobvalidate.AddValidator('_obj.email_txt_attrib', _transform('email_txt_attrib'), 'B', [XValidate._v_MaxLength(32)]);
    job_sql_ptypes.push(dbtypes.VarChar(255));
    job_sql_params['email_to'] = jrow.email_to;
    jobvalidate.AddValidator('_obj.email_to', _transform('email_to'), 'B', [XValidate._v_MaxLength(255), XValidate._v_Required()]);
    job_sql_ptypes.push(dbtypes.VarChar(255));
    job_sql_params['email_cc'] = jrow.email_cc || null;
    jobvalidate.AddValidator('_obj.email_cc', _transform('email_cc'), 'B', [XValidate._v_MaxLength(255)]);
    job_sql_ptypes.push(dbtypes.VarChar(255));
    job_sql_params['email_bcc'] = jrow.email_bcc || null;
    jobvalidate.AddValidator('_obj.email_bcc', _transform('email_bcc'), 'B', [XValidate._v_MaxLength(255)]);
    job_sql_ptypes.push(dbtypes.VarChar(dbtypes.MAX));
    job_sql_params['email_attach'] = jrow.email_attach || null;
    job_sql_ptypes.push(dbtypes.VarChar(500));
    job_sql_params['email_subject'] = jrow.email_subject || null;
    jobvalidate.AddValidator('_obj.email_subject', _transform('email_subject'), 'B', [XValidate._v_MaxLength(500)]);
    job_sql_ptypes.push(dbtypes.VarChar(dbtypes.MAX));
    job_sql_params['email_text'] = jrow.email_text || null;
    job_sql_ptypes.push(dbtypes.VarChar(dbtypes.MAX));
    job_sql_params['email_html'] = jrow.email_html || null;
    job_sql_ptypes.push(dbtypes.BigInt);
    job_sql_params['email_doc_id'] = jrow.email_doc_id || null;
    jobvalidate.AddValidator('_obj.email_doc_id', _transform('email_doc_id'), 'B', [XValidate._v_IsNumeric()]);
  }
  if ('sms_to' in jrow) {
    //Add SMS to Job
    if (!('sms_txt_attrib' in jrow) && !('sms_body' in jrow)) throw new Error('Job with sms_to requires sms_txt_attrib or sms_body');
    job_sql += this.AppSrv.getSQL('',_this._transform('jobproc_add_sms'));
    job_sql_ptypes.push(dbtypes.VarChar(32));
    job_sql_params['sms_txt_attrib'] = jrow.sms_txt_attrib;
    jobvalidate.AddValidator('_obj.sms_txt_attrib', _transform('sms_txt_attrib'), 'B', [XValidate._v_MaxLength(32)]);
    job_sql_ptypes.push(dbtypes.VarChar(255));
    job_sql_params['sms_to'] = jrow.sms_to;
    jobvalidate.AddValidator('_obj.sms_to', _transform('sms_to'), 'B', [XValidate._v_MaxLength(255), XValidate._v_Required()]);
    job_sql_ptypes.push(dbtypes.VarChar(dbtypes.MAX));
    job_sql_params['sms_body'] = jrow.sms_body || null;
  }
  if ('note_scope' in jrow) {
    //Add Note to Job
    if (!('note_scope_id' in jrow) || !('note_type' in jrow) || !('note_note' in jrow)) throw new Error('Job with n_scope requires n_scope_id, n_type, and n_note');
    job_sql += this.AppSrv.getSQL('',_this._transform('jobproc_add_note'));
    job_sql_ptypes.push(dbtypes.VarChar(8));
    job_sql_params['note_scope'] = jrow.note_scope;
    jobvalidate.AddValidator('_obj.note_scope', _transform('note_scope'), 'B', [XValidate._v_MaxLength(8), XValidate._v_Required()]);
    job_sql_ptypes.push(dbtypes.BigInt);
    job_sql_params['note_scope_id'] = jrow.note_scope_id;
    jobvalidate.AddValidator('_obj.note_scope_id', _transform('note_scope_id'), 'B', [XValidate._v_IsNumeric(), XValidate._v_Required()]);
    job_sql_ptypes.push(dbtypes.VarChar(8));
    job_sql_params['note_type'] = jrow.note_type;
    jobvalidate.AddValidator('_obj.note_type', _transform('note_type'), 'B', [XValidate._v_MaxLength(8), XValidate._v_Required()]);
    job_sql_ptypes.push(dbtypes.VarChar(dbtypes.MAX));
    job_sql_params['note_body'] = jrow.note_body;
    jobvalidate.AddValidator('_obj.note_body', _transform('note_body'), 'B', [XValidate._v_Required()]);
  }
  job_sql += this.AppSrv.getSQL('',_this._transform('jobproc_add_END'));
  var verrors = _.merge(verrors, jobvalidate.Validate('B', job_sql_params));
  //Transform job_sql_params
  _this.transform_db_params(job_sql_params);
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

AppSrvJobProc.prototype.SetSubscriberQueueResult = function (queue_id, queue_rslt, queue_snotes, onComplete) {
  var _this = this;
  _this.jsh.Log.info('Completed Queue Task #' + queue_id + ': ' + queue_rslt + (queue_snotes ? ' - ' + queue_snotes : ''));
  var dbtypes = this.AppSrv.DB.types;
  let sqlparams = {};
  sqlparams[_this._transform('queue_rslt')] = queue_rslt;
  sqlparams[_this._transform('queue_snotes')] = queue_snotes;
  sqlparams[_this._transform('queue_id')] = queue_id;
  this.AppSrv.ExecRow('jobproc', _this._transform("jobproc_queueresult"), [dbtypes.VarChar(8), dbtypes.VarChar(dbtypes.MAX), dbtypes.BigInt], sqlparams, function (err, rslt) {
    if (err) { _this.jsh.Log.error(err); }
    if (onComplete) onComplete();
  });
}

AppSrvJobProc.prototype.SubscribeToQueue = function (req, res, queue_name) {
  //Check if queue has a message, otherwise, add to subscriptions
  var _this = this;
  var dbtypes = this.AppSrv.DB.types;
  let sqlparams = {};
  sqlparams[_this._transform('queue_name')] = queue_name;
  this.AppSrv.ExecRow('jobproc', _this._transform("jobproc_queuecheck"), [dbtypes.VarChar(255)], sqlparams, function (err, rslt) {
    if (err != null) { _this.jsh.Log.error(err); return onComplete(null); }
    if ((rslt != null) && (rslt.length == 1) && (rslt[0])) {
      var queuetask = _this.map_db_rslt(rslt[0]);
      _this.jsh.Log.info('Notifying subscriber ' + queue_name);
      var msg = JSON.stringify({ ID: queuetask.queue_id, MESSAGE: queuetask.queue_message });
      res.send(msg);
    }
    else {
      _this.AppSrv.QueueSubscriptions.push({ id: queue_name, req: req, res: res });
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
  this.AppSrv.ExecRecordset('jobproc', _this._transform("jobproc_queuesubscribers"), [], {}, function (err, rslt) {
    if (err != null) { _this.jsh.Log.error(err); return onComplete(null); }
    //Handle invalid queue
    //Update results
    if ((rslt != null) && (rslt.length == 1) && (rslt[0])) {
      async.each(rslt[0], function (row, queue_cb) {
        var queuetask = _this.map_db_rslt(row);
        if (!(queuetask.queue_name in _this.AppSrv.jsh.Config.queues)) {
          _this.SetSubscriberQueueResult(queuetask.queue_id, 'ERROR', 'Queue not set up in config', queue_cb);
        }
        else {
          if(!_this.QueueHistory[queuetask.queue_name]) _this.jsh.Log.info('Message for queue ' + queuetask.queue_name);
          _this.QueueHistory[queuetask.queue_name] = 1;
          var msg = JSON.stringify({ ID: queuetask.queue_id, MESSAGE: queuetask.queue_message });
          _this.AppSrv.SendQueue(queuetask.queue_name, msg);
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

AppSrvJobProc.prototype.PopQueue = function (req, res, queue_name, queueresult, onComplete) {
  var _this = this;
  var dbtypes = this.AppSrv.DB.types;
  let sqlparams = {};
  sqlparams[_this._transform('queue_id')] = queueresult.ID;
  sqlparams[_this._transform('queue_name')] = queue_name;
  this.AppSrv.ExecScalar('jobproc', _this._transform("jobproc_queuepop"), [dbtypes.BigInt, dbtypes.VarChar(255)], sqlparams, function (err, rslt) {
    if (err) { return Helper.GenError(req, res, -99999, err); }
    else if ((rslt == null) || (rslt.length != 1) || (!rslt[0])) { return Helper.GenError(req, res, -99999, 'Queue item ID does not exist or has already been resulted.'); }
    if (onComplete) onComplete(null);
    _this.SetSubscriberQueueResult(queueresult.ID, queueresult.RSLT, queueresult.NOTES, function () {
      //Delete request file, if applicable
      if (queueresult.RSLT == 'OK') HelperFS.tryUnlink((_this.jsh.Config.datadir +_transform('queue__tbl')+'/'+_transform('queue__tbl')+'_file_' + queueresult.ID), onComplete);
      else if (onComplete) onComplete();
    });
  });
}

module.exports = AppSrvJobProc;