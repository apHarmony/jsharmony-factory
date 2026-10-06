jsh.App[modelid] = new (function(){
  var _this = this;

  this.samples = {
    'List Models': 'return _.keys(jsh.Models)',
    'Get Model Fields': [
      "var model = jsh.Models['MODELID'];",
      'var rslt_fields = [];',
      '_.each(model.fields, function(field){',
      "  var base_field = _.pick(field,['name','caption','format']);",
      '  var rslt_field = {',
      '    name: field.name,',
      '    caption: field.caption,',
      '    format: field.format,',
      '  };',
      '  rslt_fields.push(rslt_field);',
      '});',
      'return rslt_fields;'
    ],
    'Run DB Script': [
      "var dbid = 'default';",
      'var db = jsh.DB[dbid];',
      'var dbconfig = jsh.DBConfig[dbid];',
      "var sqlsrc = '';",
      "db.RunScripts(jsh, ['script','path'], { dbconfig: dbconfig, sqlFuncs: { DB: dbconfig.database, DB_LCASE: dbconfig.database.toLowerCase() } }, function(err, rslt, stats){ });",
    ],
    'Static Menu': [
      "return JSON.stringify(jsh.Modules['jsHarmonyFactory'].Config.static_menu,null,4);",
    ],
  };

  this.getFormElement = function(){
    return jsh.xd('.xformcontainer.xelem'+xmodel.class);
  };

  this.oninit = function(xmodel) {
    var xdform = _this.getFormElement();
    _this.LoadScripts();
    var xdSamples = xdform.get('.samples');
    xdSamples.on('change', function(){
      var sampleName = xdSamples.value;
      if(!(sampleName in _this.samples)){ return XExt.Alert('Sample not found: '+sampleName); }
      var sampleJS = _this.samples[sampleName];
      if(_.isArray(sampleJS)) sampleJS = sampleJS.join('\r\n');
      xdform.get('.js').value = sampleJS;
      xdSamples.value = '';
    });
    xdform.get('.runjs').on('click', function(){ _this.RunJS(); });
  };

  this.LoadScripts = function(){
    var xdform = _this.getFormElement();
    xdform.get('.run').style.display = true;
    xdform.get('.rslt').clear();
    var xdSamples = xdform.get('.samples');
    xdSamples.clear();
    var tmpl = jsh.xd('.'+xmodel.class+'_script_listing_template').html;
    xdSamples.append(XDom.render.ejs(tmpl, {samples: _this.samples}));
  };

  this.RunJS = function(){
    var xdform = _this.getFormElement();
    var js = xdform.get('.js').value;
    var starttm = Date.now();
    var params = { js: js };
    XForm.prototype.XExecutePost('../_js/exec', params, function (rslt) { //On success
      if ('_success' in rslt) {
        var str = '';
        var jsrslt = rslt.jsrslt;
        if(rslt.err){
          str += '<div><b>ERROR: </b><pre>'+JSON.stringify(rslt.err,null,4)+'</pre></div>';
        }
        
        str += '<h1 style="margin-top:10px;">Result</h1>';
        str += '<pre>';
        if(_.isString(jsrslt)){
          str += XExt.escapeHTMLBR(jsrslt);
        }
        else{
          str += JSON.stringify(jsrslt,null,4);
        }
        str += '</pre>';

        str += "<div style='font-weight:bold'>Operation complete</div>";
        var endtm = Date.now();
        str += "<div style='font-weight:bold' class='runtime'>Time: " + (endtm-starttm) + 'ms</div>';
        xdform.get('.rslt').html = str;
      }
    });
  };

})();