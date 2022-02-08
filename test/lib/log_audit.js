/*
Copyright 2021 apHarmony

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

var jsHarmonyFactory = require('../../index');
var assert = require('assert');
var _ = require('lodash');
var path = require('path');
var async = require('async');

exports = module.exports = function shouldSupportLogAudit(dbconfig) {
  var dbid = 'default';
  var jsh = new jsHarmonyFactory.Application();
  jsh.DBConfig[dbid] = dbconfig;
  jsh.Config.appbasepath = path.join(__dirname, '..', 'log_audit_base');
  jsh.Config.silentStart = true;
  jsh.Config.interactive = true;
  jsh.Config.onConfigLoaded.push(function(cb){
    jsh.Config.system_settings.automatic_schema = false;
    return cb();
  });

  var printResult = false;
  var db;
  var dbtypes;
  var options = {sqlFuncs: {}};

  var insertCommand = function(table, scr_unotes, callback) {
    var sql_ptypes = [
      dbtypes.VarChar(32),
      dbtypes.DateTime(7),
      dbtypes.VarChar(32),
      dbtypes.DateTime(7),
      dbtypes.VarChar(20),
      dbtypes.VarChar(255),
    ];

    var sql_params = {
      'scr_sts': 'OPEN',
      'scr_sts_tstmp': new Date(),
      'scr_review_sts': 'PENDING',
      'scr_review_sts_tstmp': new Date(),
      'scr_review_sts_user': 'user',
      'scr_unotes': scr_unotes,
    };

    db.Scalar('','insert into application.'+table+'(scr_sts,scr_sts_tstmp,scr_review_sts,scr_review_sts_tstmp,scr_review_sts_user,scr_unotes) values (@scr_sts,@scr_sts_tstmp,@scr_review_sts,@scr_review_sts_tstmp,@scr_review_sts_user,@scr_unotes); select scr_id from application.'+table+' where scr_unotes=@scr_unotes',sql_ptypes,sql_params,function(err,rslt){
      assert.ifError(err);
      callback(err, rslt);
    });
  };

  var updateCommand = function(table, scr_id, scr_unotes, scr_sts, scr_review_sts, callback) {
    var sql_ptypes = [
      dbtypes.BigInt,
      dbtypes.VarChar(32),
      dbtypes.VarChar(32),
      dbtypes.VarChar(255),
    ];

    var sql_params = {
      'scr_id': scr_id,
      'scr_sts': scr_sts,
      'scr_review_sts': scr_review_sts,
      'scr_unotes': scr_unotes,
    };

    db.Command('','update application.'+table+' set scr_sts=@scr_sts,scr_review_sts=@scr_review_sts,scr_unotes=@scr_unotes where scr_id=@scr_id',sql_ptypes,sql_params,function(err,rslt){
      assert.ifError(err);
      callback(err);
    });
  };

  var deleteCommand = function(table, scr_id, callback) {
    var sql_ptypes = [
      dbtypes.BigInt,
    ];

    var sql_params = {
      'scr_id': scr_id,
    };

    db.Command('','delete from application.'+table+' where scr_id=@scr_id',sql_ptypes,sql_params,function(err,rslt){
      assert.ifError(err);
      callback(err);
    });
  };

  var otherCommand = function(table, col_name, value, callback) {
    var sql_ptypes = [
      dbtypes.VarChar(32),
      dbtypes.VarChar(30),
      dbtypes.VarChar(dbtypes.MAX),
    ];

    var sql_params = {
      table: table,
      col_name: col_name,
      value: value
    };

    db.Command('','jsharmony.log_audit_other(@table,0,(@value)!=\'no\',@col_name,@value)',sql_ptypes,sql_params,function(err,rslt){
      assert.ifError(err);
      callback(err);
    });
  };

  before(function(done) {
    this.timeout(10000);
    jsh.Init(function(){
      db = jsh.DB[dbid];
      dbtypes = jsh.AppSrv.DB.types;

      dbconfig = jsh.DBConfig[dbid];

      if(dbconfig.admin_user){
        dbconfig = _.extend({}, dbconfig);
        dbconfig.user = dbconfig.admin_user;
        dbconfig.password = dbconfig.admin_password;
      }

      options.dbconfig = dbconfig;
      var dbname = dbconfig.database;
      var sqlFuncs = options.sqlFuncs;
      sqlFuncs['INIT_DB'] = dbname;
      sqlFuncs['INIT_DB_LCASE'] = dbname.toLowerCase();
      sqlFuncs['INIT_DB_USER'] = dbconfig.user;
      sqlFuncs['INIT_DB_PASS'] = dbconfig.password;
      sqlFuncs['INIT_DB_HASH_MAIN'] =jsh.Config.modules['jsHarmonyFactory'].mainsalt;
      sqlFuncs['INIT_DB_HASH_CLIENT'] = jsh.Config.modules['jsHarmonyFactory'].clientsalt;
      sqlFuncs['INIT_DB_ADMIN_EMAIL'] = 'admin@jsharmony.com';
      sqlFuncs['INIT_DB_ADMIN_PASS'] = 'password';
      sqlFuncs['DB'] = dbname;
      sqlFuncs['DB_LCASE'] = dbname.toLowerCase();

      async.series([
        function(cb) {
          db.Scalar('','select count(*) from jsharmony.code',[],{},function(err,rslt){
            if(err) {
              db.RunScripts(jsh, ['*', 'init', 'core', 'init'], options, cb);
            } else {
              return cb();
            }
          });
        },
        function(cb) { db.RunScripts(jsh, ['application', 'drop'], options, cb);},
        function(cb) { db.RunScripts(jsh, ['application', 'init'], options, cb);},
        function(cb) { db.RunScripts(jsh, ['*', 'restructure', 'core'], options, cb);},
        function(cb) { db.RunScripts(jsh, ['application', 'restructure'], options, cb);},
        function(cb) { db.RunScripts(jsh, ['*', 'init_data', 'core'], options, cb);},
        function(cb) { db.RunScripts(jsh, ['application', 'init_data'], options, cb);},
      ], done);

    });
  });

  after(function(done) {
    db.RunScripts(jsh, ['application', 'drop'], options, function(err) {
      db.Close(done);
    });
  });

  beforeEach(function(done) {
    db.Command('','delete from jsharmony.audit_detail; delete from jsharmony.audit',[],{},function(err,rslt){
      assert.ifError(err);
      done(err);
    });
  });

  it('should be executed', function() {
    assert.ok(db);
  });

  it('audit view should be empty', function(done) {
    db.Recordset('','select * from jsharmony.v_audit_detail',[],{},function(err,rslt){
      assert.ifError(err);
      assert.deepEqual(rslt, []);
      done(err);
    });
  });

  it('log_audit_insert', function(done) {
    insertCommand('scr', 'log_audit_insert', function(err, scr_id) {
      db.Recordset('','select * from jsharmony.v_audit_detail',[],{},function(err,rslt){
        assert.ifError(err);
        if (printResult) console.log(rslt);
        assert.equal(rslt.length, 1, 'no audit row generated');
        assert.equal(rslt[0].audit_table_name, 'scr');
        assert.equal(rslt[0].audit_table_id, scr_id);
        assert.equal(rslt[0].audit_op.trim(), 'I');
        done(err);
      });
    });
  });

  it('log_audit_update', function(done) {
    insertCommand('scr', 'log_audit_update', function(err, scr_id) {
      updateCommand('scr', scr_id, 'log_audit_update: updated', 'EXP', 'NEGATIVE', function(err) {
        db.Recordset('','select * from jsharmony.v_audit_detail order by audit_seq',[],{},function(err,rslt){
          assert.ifError(err);
          if (printResult) console.log(rslt);
          rslt.shift();
          assert.equal(rslt.length, 1, 'wrong number of audit rows generated');
          var expectedColumns = {
            scr_sts: 'OPEN',
          };
          for (var i = 0;i < rslt.length;i++) {
            assert.equal(rslt[i].audit_table_name, 'scr');
            assert.equal(rslt[i].audit_table_id, scr_id);
            assert.equal(rslt[i].audit_op.trim(), 'U');
            var expected = expectedColumns[rslt[i].audit_column_name];
            delete expectedColumns[rslt[i].audit_column_name];
            assert.ok(expected, 'expected column audit not found');
            assert.equal(rslt[i].audit_column_val, expected);
          }
          assert.deepEqual(expectedColumns, {});
          done(err);
        });
      });
    });
  });

  it('log_audit_update_multi', function(done) {
    insertCommand('multi', 'log_audit_update_multi', function(err, scr_id) {
      updateCommand('multi', scr_id, 'log_audit_update_multi: updated', 'EXP', 'NEGATIVE', function(err) {
        db.Recordset('','select * from jsharmony.v_audit_detail order by audit_seq',[],{},function(err,rslt){
          assert.ifError(err);
          if (printResult) console.log(rslt);
          assert.equal(rslt.length, 3, 'wrong number of audit rows generated');
          var expectedColumns = {
            scr_sts: 'OPEN',
            scr_review_sts: 'PENDING',
            scr_unotes: 'log_audit_update_multi',
          };
          for (var i = 0;i < rslt.length;i++) {
            assert.equal(rslt[i].audit_table_name, 'multi');
            assert.equal(rslt[i].audit_table_id, scr_id);
            assert.equal(rslt[i].audit_op.trim(), 'U');
            var expected = expectedColumns[rslt[i].audit_column_name];
            delete expectedColumns[rslt[i].audit_column_name];
            assert.ok(expected, 'expected column audit not found');
            assert.equal(rslt[i].audit_column_val, expected);
          }
          assert.deepEqual(expectedColumns, {});
          done(err);
        });
      });
    });
  });

  it('log_audit_update_custom yes', function(done) {
    insertCommand('custom', 'log_audit_update_custom yes', function(err, scr_id) {
      updateCommand('custom', scr_id, 'log_audit_update_custom yes: updated', 'EXP', 'TRUEPOS', function(err) {
        db.Recordset('','select * from jsharmony.v_audit_detail order by audit_seq',[],{},function(err,rslt){
          assert.ifError(err);
          if (printResult) console.log(rslt);
          assert.equal(rslt.length, 1, 'no audit row generated');
          assert.equal(rslt[0].audit_table_name, 'custom');
          assert.equal(rslt[0].audit_table_id, scr_id);
          assert.equal(rslt[0].audit_op.trim(), 'U');
          done(err);
        });
      });
    });
  });

  it('log_audit_update_custom no', function(done) {
    insertCommand('custom', 'log_audit_update_custom no', function(err, scr_id) {
      updateCommand('custom', scr_id, 'log_audit_update_custom no: updated', 'EXP', 'FALSEPOS', function(err) {
        db.Recordset('','select * from jsharmony.v_audit_detail order by audit_seq',[],{},function(err,rslt){
          assert.ifError(err);
          if (printResult) console.log(rslt);
          assert.equal(rslt.length, 0, 'audit record should not have been generatead');
          done(err);
        });
      });
    });
  });

  it('log_audit_delete', function(done) {
    insertCommand('scr', 'log_audit_delete', function(err, scr_id) {
      deleteCommand('scr', scr_id, function(err) {
        db.Recordset('','select * from jsharmony.v_audit_detail order by audit_seq',[],{},function(err,rslt){
          assert.ifError(err);
          if (printResult) console.log(rslt);
          rslt.shift();
          assert.equal(rslt.length, 1, 'wrong number of audit rows generated');
          var expectedColumns = {
            scr_sts: 'OPEN',
          };
          for (var i = 0;i < rslt.length;i++) {
            assert.equal(rslt[i].audit_table_name, 'scr');
            assert.equal(rslt[i].audit_table_id, scr_id);
            assert.equal(rslt[i].audit_op.trim(), 'D');
            var expected = expectedColumns[rslt[i].audit_column_name];
            delete expectedColumns[rslt[i].audit_column_name];
            assert.ok(expected, 'expected column audit not found');
            assert.equal(rslt[i].audit_column_val, expected);
          }
          assert.deepEqual(expectedColumns, {});
          done(err);
        });
      });
    });
  });

  it('log_audit_delete_multi', function(done) {
    insertCommand('multi', 'log_audit_delete_multi', function(err, scr_id) {
      deleteCommand('multi', scr_id, function(err) {
        db.Recordset('','select * from jsharmony.v_audit_detail order by audit_seq',[],{},function(err,rslt){
          assert.ifError(err);
          if (printResult) console.log(rslt);
          assert.equal(rslt.length, 3, 'wrong number of audit rows generated');
          var expectedColumns = {
            scr_sts: 'OPEN',
            scr_review_sts: 'PENDING',
            scr_unotes: 'log_audit_delete_multi',
          };
          for (var i = 0;i < rslt.length;i++) {
            assert.equal(rslt[i].audit_table_name, 'multi');
            assert.equal(rslt[i].audit_table_id, scr_id);
            assert.equal(rslt[i].audit_op.trim(), 'D');
            var expected = expectedColumns[rslt[i].audit_column_name];
            delete expectedColumns[rslt[i].audit_column_name];
            assert.ok(expected, 'expected column audit not found');
            assert.equal(rslt[i].audit_column_val, expected);
          }
          assert.deepEqual(expectedColumns, {});
          done(err);
        });
      });
    });
  });

  it('log_audit_other yes', function(done) {
    otherCommand('other', 'column', 'value', function(err) {
      db.Recordset('','select * from jsharmony.v_audit_detail order by audit_seq',[],{},function(err,rslt){
        assert.ifError(err);
        if (printResult) console.log(rslt);
        assert.equal(rslt.length, 1, 'no audit row generated');
        assert.equal(rslt[0].audit_table_name, 'other');
        assert.equal(rslt[0].audit_column_name, 'column');
        assert.equal(rslt[0].audit_column_val, 'value');
        assert.equal(rslt[0].audit_op.trim(), 'O');
        done(err);
      });
    });
  });

  it('log_audit_other no', function(done) {
    otherCommand('other', 'column', 'no', function(err) {
      db.Recordset('','select * from jsharmony.v_audit_detail order by audit_seq',[],{},function(err,rslt){
        assert.ifError(err);
        if (printResult) console.log(rslt);
        assert.equal(rslt.length, 0, 'audit row generated');
        done(err);
      });
    });
  });
};