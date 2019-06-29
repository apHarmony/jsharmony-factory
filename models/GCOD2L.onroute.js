//(routetype, req, res, callback, require, jsh, modelid, params)
var _ = require('lodash');
var Helper = require('../Helper.js');
var model = jsh.getModelClone(req, modelid);

var codename = '';
if(params && params.query && params.query.codename) codename = params.query.codename;
else if(params && params.post && params.post.codename) codename = params.post.codename;
if(!codename) return Helper.GenError(req, res, -2, "Error: "+modelid+" routetype: "+routetype+" missing codename.");

var codeschema = '';
if(params && params.query && params.query.codeschema) codeschema = params.query.codeschema;
else if(params && params.post && params.post.codeschema) codeschema = params.post.codeschema;

//Check if code exists
var dbtypes = jsh.AppSrv.DB.types;
jsh.AppSrv.ExecRow(req._DBContext, "select codemean,codecodemean,codeattribmean from jsharmony.gcod2_h where codename=@codename and coalesce(codeschema,'')=coalesce(@codeschema,'')", [dbtypes.VarChar(128),dbtypes.VarChar(128)], { 'codename': codename, 'codeschema': codeschema }, function (err, rslt) {
  if (err) { jsh.Log.error(err); Helper.GenError(req, res, -99999, "An unexpected error has occurred"); return; }
  if (rslt && rslt.length && rslt[0]) {
    //Set title
    model.title = 'TABLE - '+rslt[0]['codemean'];
    //Set table
    model.table = 'gcod2_'+codename;
    if(codeschema){ 
      if(jsh.DBConfig['default']._driver.name=='sqlite') model.table = codeschema+'_'+model.table;
      else model.table = codeschema+'.'+model.table;
    }
    //Set caption of codecode column
    jsh.AppSrv.getFieldByName(model.fields,'codecode').caption = rslt[0]['codecodemean'];
    if (!rslt[0]['codecodemean']) { 
      jsh.AppSrv.getFieldByName(model.fields,'codecode').actions = 'B'; 
      jsh.AppSrv.getFieldByName(model.fields,'codecode').control = 'hidden'; 
    }
    //Set caption of codeattrib column
    jsh.AppSrv.getFieldByName(model.fields,'codeattrib').caption = rslt[0]['codeattribmean'];
    if (!rslt[0]['codeattribmean']) { 
      jsh.AppSrv.getFieldByName(model.fields,'codeattrib').actions = 'B'; 
      jsh.AppSrv.getFieldByName(model.fields,'codeattrib').control = 'hidden'; 
    }
    //Save model to local request cache
    req.jshlocal.Models[modelid] = model;
    return callback();
  }
  else { Helper.GenError(req, res, -1, "codename not found"); return; }
});
