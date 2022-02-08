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
    ]
  };

  this.getFormElement = function(){
    return jsh.$root('.xformcontainer.xelem'+xmodel.class);
  };

  this.oninit = function(xmodel) {
    var jform = _this.getFormElement();
    _this.LoadScripts();
    var jSamples = jform.$find('.samples');
    jSamples.change(function(){
      var sampleName = jSamples.val();
      if(!(sampleName in _this.samples)){ return XExt.Alert('Sample not found: '+sampleName); }
      var sampleJS = _this.samples[sampleName];
      if(_.isArray(sampleJS)) sampleJS = sampleJS.join('\r\n');
      jform.$find('.js').val(sampleJS);
      jSamples.val('');
    });
    jform.$find('.runjs').click(function(){ _this.RunJS(); });
  };

  this.LoadScripts = function(){
    var jform = _this.getFormElement();
    jform.$find('.run').show();
    jform.$find('.rslt').html('');
    var jSamples = jform.$find('.samples');
    jSamples.empty();
    jSamples.append($('<option>',{value:''}).text('Please select...'));
    for(var sampleName in _this.samples){
      var option = $('<option></option>');
      option.text(sampleName);
      option.val(sampleName);
      jSamples.append(option);
    }
  };

  this.RunJS = function(){
    var jform = _this.getFormElement();
    var js = jform.$find('.js').val();
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
        str += "<div style='font-weight:bold'>Time: " + (endtm-starttm) + 'ms</div>';
        jform.$find('.rslt').html(str);
      }
    });
  };

})();