jsh.App[modelid] = new (function(){
  var _this = this;

  this.DBs = {};  //Populated onroute

  this.oninit = function(xmodel) {
    XForm.prototype.XExecute('../_funcs/DEV_DB_SCHEMA', { }, function (rslt) { //On success
      if ('_success' in rslt) { 
        _this.RenderDBListing(rslt.dbs);
      }
    });
    jsh.$root('.DEV_DB_SCHEMA_db').change(function(){
      var db = jsh.$root('.DEV_DB_SCHEMA_db').val();
      if(!db) jsh.$root('.DEV_DB_SCHEMA_run').hide();
      else _this.GetSchema(db);
    });
  }

  this.RenderDBListing = function(dbs){
    var jobj = jsh.$root('.DEV_DB_SCHEMA_db');
    if(dbs.length > 1){
      jsh.$root('.DEV_DB_SCHEMA_dbselect').show();
      jobj.append($('<option>',{value:''}).text('Please select...'));
    }
    else {
      jsh.$root('.DEV_DB_SCHEMA_dbselect').hide();
      jobj.empty();
    }
    for(var i=0;i<dbs.length;i++){
      var db = dbs[i];
      jobj.append($('<option>',{value:db}).text(db));
    }
    if(dbs.length==1) _this.GetSchema(dbs[0]);
  }

  this.GetSchema = function(dbid){
    XForm.prototype.XExecute('../_funcs/DEV_DB_SCHEMA', { db: dbid }, function (rslt) { //On success
      if ('_success' in rslt) { 
        _this.RenderSchema(dbid, rslt.schema, rslt.funcs);
      }
    });
  }

  this.getTable = function(obj){
    var jobj = $(obj);
    while(jobj.length){
      if(jobj.is('table')) return jobj;
      jobj = jobj.next();
    }
  }

  this.RenderSchema = function(dbid, schema, funcs){
    var jobj = jsh.$root('.DEV_DB_SCHEMA_rslt');
    jobj.html('');
    $('<div>\
      <a href="#" class="show_all" onclick="return false;">[Show All]</a> | \
      <a href="#" class="hide_all" onclick="return false;">[Hide All]</a>\
      </div>').appendTo(jobj);
    jobj.find('.show_all').click(function(){ jobj.find('table').show(); });
    jobj.find('.hide_all').click(function(){ jobj.find('table').hide(); });
    //var tables = _.map(schema.tables, function(table){ console.log(table); });
    _.each(schema.tables, function(table, tableName){
      var dispName = tableName;
      if(dispName && (dispName[0]=='.')) dispName = dispName.substr(1);
      dispName = 'table_' + dispName;
      $('<a href="#" class="table_name expandable" onclick="return false;">'+XExt.escapeHTML(dispName.substr(6))+'</a> &nbsp; \
         <a href="#" class="expandable" onclick="return false;">Schema</a> &nbsp; \
         <a href="DEV_DB?db='+XExt.escapeHTML(dbid)+'&table='+XExt.escapeHTML(dispName.substr(6))+'" target="_blank">Data</a> &nbsp; \
         <br/>').appendTo(jobj);
      var html = '<table cellpadding="0" cellspacing="0" border="0" style="display:none;">';
      html += '<tr>';
      html += '<th>Column</th>';
      html += '<th>Type</th>';
      html += '<th>Null</th>';
      html += '<th>Key</th>';
      html += '<th>Attributes</th>';
      html += '</tr>';
      _.each(table.fields, function(field){
        html += '<tr>';
        html += '<td>'+XExt.escapeHTML(field.name)+'</td>';
        var typedesc = field.type;
        if('length' in field) typedesc += '('+field.length+')';
        else if(('precision' in field) && field.precision && field.precision.length) typedesc += '(' + field.precision.join(',')+')';
        else if('precision' in field) typedesc += '('+field.precision+')';
        html += '<td>'+XExt.escapeHTML(typedesc)+'</td>';
        var fielddesc = [];
        var notnull = false;
        if(field.coldef && field.coldef.required) notnull = true;
        html += '<td>'+(notnull?'No':'Yes')+'</td>';
        var keytype = '';
        if(field.coldef && field.coldef.primary_key) keytype = 'Primary';
        else if(field.foreignkeys){
          _.each(field.foreignkeys.direct, function(key){
            if(keytype) keytype += '\r\n';
            keytype += (key.schema_name?key.schema_name+'.':'')+key.table_name+'('+key.column_name+')';
          });
          if(table.table_type=='view'){
            _.each(field.foreignkeys.indirect, function(key){
              if(keytype) keytype += '\r\n';
              keytype += '~~'+(key.schema_name?key.schema_name+'.':'')+key.table_name+'('+key.column_name+')';
            });
          }
        }
        html += '<td>'+XExt.escapeHTMLBR(keytype)+'</td>';
        if(field.coldef){
          if(field.coldef.readonly) fielddesc.push('readonly');
        }
        html += '<td>'+XExt.escapeHTML(fielddesc.join(','))+'</td>';
        html += '</tr>';
      });
      html += '</table>';
      $(html).appendTo(jobj);
      //console.log(table);
    });
    _.each(funcs, function(func, funcName){
      var dispName = funcName;
      if(dispName && (dispName[0]=='.')) dispName = dispName.substr(1);
      dispName = 'func_' + dispName;
      var funcVal = func;
      if(_.isString(funcVal)) funcVal = XExt.escapeHTMLBR(funcVal);
      else funcVal = '<pre>' + XExt.escapeHTML(JSON.stringify(funcVal,null,4)) + '</pre>';
      $('<a href="#" class="func_name expandable" onclick="return false;">Func: '+XExt.escapeHTML(dispName.substr(5))+'</a> &nbsp; \
         <a href="#" class="expandable" onclick="return false;">Definition</a> \
         <br/>').appendTo(jobj);
      var html = '<table cellpadding="0" cellspacing="0" border="0" style="display:none;">';
      html += '<tr>';
      html += '<td>' + funcVal + '</td>';
      html += '</tr>';
      html += '</table>';
      $(html).appendTo(jobj);
    });
    $('.expandable').click(function(){ _this.getTable(this).toggle(); });
    //jsh.$root('.DEV_DB_SCHEMA_rslt').text(JSON.stringify(schema));
  }

})();