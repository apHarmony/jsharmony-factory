/*
Copyright 2022 apHarmony

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

var Helper = require('jsharmony/Helper');
var HelperFS = require('jsharmony/HelperFS');
var fs = require('fs');
var _ = require('lodash');
var async = require('async');
var archiver = require('archiver');
var moment = require('moment');
var path = require('path');

module.exports = exports = function(module, funcs){
  var exports = {};

  exports.LOG = function (req, res, next) {
    var verb = req.method.toLowerCase();
    if (!req.body) req.body = {};
    
    var Q = req.query;
    var P = {};
    if (req.body && ('data' in req.body)){
      try{ P = JSON.parse(req.body.data); }
      catch(ex){ Helper.GenError(req, res, -4, 'Invalid Parameters'); return; }
    }
    var jsh = module.jsh;
    var appsrv = jsh.AppSrv;

    var model = jsh.getModel(req, module.namespace + funcs._transform('Admin/Log_Listing'));
    
    if (!Helper.hasModelAction(req, model, 'B')) { Helper.GenError(req, res, -11, 'Invalid Model Access'); return; }
    
    if (verb == 'get') {

      if (!appsrv.ParamCheck('Q', Q, [])) { Helper.GenError(req, res, -4, 'Invalid Parameters'); return; }
      if (!appsrv.ParamCheck('P', P, [])) { Helper.GenError(req, res, -4, 'Invalid Parameters'); return; }

      var farr = [];
      async.waterfall([
        function (cb) {
          fs.readdir(jsh.Config.logdir, function (err, files) {
            if (err) return cb(err);

            async.each(files, function(fname, file_cb){
              fs.stat(path.join(jsh.Config.logdir, fname), function(err, stats){
                if(err) return file_cb(err);
                farr.push({
                  filename: fname,
                  mtime: stats.mtimeMs,
                });
                return file_cb();
              });
            }, function(err){
              if(err) return cb(err);
              return res.end(JSON.stringify({ _success: 1, files : farr }));
            });
          });
        },
      ], function (err, rslt) {
        if (err) {
          if ('number' in err) { return Helper.GenError(req, res, err.number, err.message); }
          return Helper.GenError(req, res, -99999, err.message);
        }
      });
      return;
    }
    return next();
  };

  exports.LOG_DOWNLOAD = function (req, res, next) {
    var verb = req.method.toLowerCase();
    if (!req.body) req.body = {};
    
    var Q = req.query;
    var P = {};
    if (req.body && ('data' in req.body)){
      try{ P = JSON.parse(req.body.data); }
      catch(ex){ Helper.GenError(req, res, -4, 'Invalid Parameters'); return; }
    }
    var jsh = module.jsh;
    var appsrv = jsh.AppSrv;

    var model = jsh.getModel(req, module.namespace + funcs._transform('Admin/Log_Listing'));
    
    if (!Helper.hasModelAction(req, model, 'B')) { Helper.GenError(req, res, -11, 'Invalid Model Access'); return; }
    
    if (verb == 'get') {

      if (!appsrv.ParamCheck('Q', Q, ['|filename','|output'])) { Helper.GenError(req, res, -4, 'Invalid Parameters'); return; }
      if (!appsrv.ParamCheck('P', P, [])) { Helper.GenError(req, res, -4, 'Invalid Parameters'); return; }

      if(Q.filename){
        var filename = HelperFS.cleanFileName(Q.filename);
        if(filename != Q.filename){ Helper.GenError(req, res, -4, 'Invalid Parameters'); return; }
        var filepath = path.join(jsh.Config.logdir, filename);
        fs.stat(filepath, function(err, stats){
          if(err) return Helper.GenError(req, res, -99999, err.message);
          if(Q.output=='json'){
            fs.readFile(filepath, 'utf8', function(err, fdata){
              if(err) return Helper.GenError(req, res, -99999, err.message);
              return res.end(JSON.stringify({ _success: 1, log: (fdata||'').toString(), mtime: stats.mtimeMs }, null, 4));
            });
          }
          else {
            HelperFS.outputFile(req, res, filepath, filename);
          }
        });
      }
      else {
        var farr = [];
        async.waterfall([
          function (cb) {
            fs.readdir(jsh.Config.logdir, function (err, files) {
              if (err) return cb(err);
              _.each(files, function (file) { farr.push({ src: jsh.Config.logdir + file, dest: file }); });
              return cb(null);
            });
          },
          function (cb) {
            res.writeHead(200, {
              'Content-Type': 'application/zip',
              'Content-disposition': 'attachment; filename=logs_' + moment().format('YYYYMMDDHHmmss') + '.zip'
            });
            var zip = archiver('zip');
            zip.pipe(res);
            _.each(farr, function (val) { zip.file(val.src, { name: val.dest }); });
            zip.finalize();
          }
        ], function (err, rslt) {
          if (err) {
            if ('number' in err) { return Helper.GenError(req, res, err.number, err.message); }
            return Helper.GenError(req, res, -99999, err.message);
          }
        });
      }
      return;
    }
    return next();
  };

  return exports;
};
