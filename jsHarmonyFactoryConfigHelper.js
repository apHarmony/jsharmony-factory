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

jsHarmonyFactoryConfigHelper = { };

jsHarmonyFactoryConfigHelper.JobProc = { };

jsHarmonyFactoryConfigHelper.JobProc.ExecuteSQL = function (sql, cb){
  return function (jobproc){
    jobproc.AppSrv.ExecRecordset('jobproc', sql, [], { }, function (err, rslt) {
      if (err) return jobproc.AppSrv.jsh.Log.error('Error Running Task: '+err.toString());
      if (rslt && rslt[0] && rslt[0].length) jobproc.AppSrv.jsh.Log.info('Task Result: '+JSON.stringify(rslt));
      if (cb) cb(rslt);
    });
  }
}

exports = module.exports = jsHarmonyFactoryConfigHelper;