//(routetype, req, res, callback, require, jsh, modelid, params)
var Helper = require('../Helper.js');
var model = jsh.getModelClone(req, modelid);

var code_name = '';
if(params && params.query && params.query.code_name) code_name = params.query.code_name;
else if(params && params.post && params.post.code_name) code_name = params.post.code_name;
if(!code_name) return Helper.GenError(req, res, -2, 'Error: '+modelid+' routetype: '+routetype+' missing code_name.');

var code_schema = '';
if(params && params.query && params.query.code_schema) code_schema = params.query.code_schema;
else if(params && params.post && params.post.code_schema) code_schema = params.post.code_schema;

//Check if code exists
var dbtypes = jsh.AppSrv.DB.types;
jsh.AppSrv.ExecRow(req._DBContext, "select code_desc,code_code_desc,code_attrib_desc from {schema}.code2_sys where code_name=@code_name and coalesce(code_schema,'')=coalesce(@code_schema,'')", [dbtypes.VarChar(128),dbtypes.VarChar(128)], { 'code_name': code_name, 'code_schema': code_schema }, function (err, rslt) {
  if (err) { jsh.Log.error(err); Helper.GenError(req, res, -99999, 'An unexpected error has occurred'); return; }
  if (rslt && rslt.length && rslt[0]) {
    //Set title
    model.title = rslt[0]['code_desc']+' - '+code_schema;
    //Set table
    model.table = 'code2_sys_'+code_name;
    if(code_schema){
      if(jsh.DBConfig['default']._driver.name=='sqlite') model.table = code_schema+'_'+model.table;
      else model.table = code_schema+'.'+model.table;
    }
    //Set caption of code_code column
    jsh.AppSrv.getFieldByName(model.fields,'code_code').caption = rslt[0]['code_code_desc'];
    if (!rslt[0]['code_code_desc']) {
      jsh.AppSrv.getFieldByName(model.fields,'code_code').actions = 'B';
      jsh.AppSrv.getFieldByName(model.fields,'code_code').control = 'hidden';
    }
    //Set caption of code_attrib column
    jsh.AppSrv.getFieldByName(model.fields,'code_attrib').caption = rslt[0]['code_attrib_desc'];
    if (!rslt[0]['code_attrib_desc']) {
      jsh.AppSrv.getFieldByName(model.fields,'code_attrib').actions = 'B';
      jsh.AppSrv.getFieldByName(model.fields,'code_attrib').control = 'hidden';
    }
    //Save model to local request cache
    req.jshlocal.Models[modelid] = model;
    return callback();
  }
  else { Helper.GenError(req, res, -1, 'code_name not found'); return; }
});
