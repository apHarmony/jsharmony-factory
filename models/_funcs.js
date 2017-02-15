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

var Helper = require('jsharmony/lib/Helper.js');
var HelperFS = require('jsharmony/lib/HelperFS.js');
var fs = require('fs');
var path = require('path');
var _ = require('lodash');
var async = require('async');
var XValidate = require('jsharmony-validate');
var archiver = require('archiver');
var dczip = require('decompress-zip');
var crypto = require('crypto');
var moment = require('moment');

exports = module.exports = {};

exports.LOG_DOWNLOAD = function (req, res, next) {
  var verb = req.method.toLowerCase();
  if (!req.body) req.body = {};
  
  var Q = req.query;
  var P = {};
  if (req.body && ('data' in req.body)) P = JSON.parse(req.body.data);
  var appsrv = this;
  var jsh = this.jsh;
  var dbtypes = appsrv.DB.types;
  var model = jsh.Models['LOG'];
  
  if (!Helper.HasModelAccess(req, model, 'B')) { Helper.GenError(req, res, -11, 'Invalid Model Access'); return; }
  
  if (verb == 'get') {
    var farr = [];
    async.waterfall([
      function (cb) {
        fs.readdir(global.logdir, function (err, files) {
          if (err) return cb(err);
          _.each(files, function (file) { farr.push({ src: global.logdir + file, dest: file }); });
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
    return;
  }
  return next();
}