jsh.App[modelid] = new (function(){
  var _this = this;

  this.DBs = {};  //Populated onroute

  this.getFormElement = function(){
    return jsh.$root('.xformcontainer.xelem'+xmodel.class);
  };

  this.oninit = function(xmodel) {
    var jform = _this.getFormElement();
    XForm.prototype.XExecute('../_funcs/DEV_DB_SCHEMA', { }, function (rslt) { //On success
      if ('_success' in rslt) {
        _this.RenderDBListing(rslt.dbs);
      }
    });
    jform.$find('.db').change(function(){
      var db = jform.$find('.db').val();
      if(!db) jform.$find('.run').hide();
      else _this.GetSchema(db);
    });
  };

  this.RenderDBListing = function(dbs){
    var jform = _this.getFormElement();
    var jobj = jform.$find('.db');
    if(dbs.length > 1){
      jform.$find('.dbselect').show();
      jobj.append($('<option>',{value:''}).text('Please select...'));
    }
    else {
      jform.$find('.dbselect').hide();
      jobj.empty();
    }
    for(var i=0;i<dbs.length;i++){
      var db = dbs[i];
      jobj.append($('<option>',{value:db}).text(db));
    }
    if(dbs.length==1) _this.GetSchema(dbs[0]);
  };

  this.GetSchema = function(dbid){
    XForm.prototype.XExecute('../_funcs/DEV_DB_SCHEMA', { db: dbid }, function (rslt) { //On success
      if ('_success' in rslt) {
        _this.RenderSchema(dbid, rslt.schema, rslt.funcs);
      }
    });
  };

  this.getTable = function(obj){
    var jobj = $(obj);
    var tableId = jobj.data('tableid');
    return _this.getFormElement().$find('.schema_table_'+tableId);
  };

  this.RenderSchema = function(dbid, schema, funcs){
    var jform = _this.getFormElement();
    var jobj = jform.$find('.rslt');
    var schemaHTML = '';
    schemaHTML +=
      '<div>Click on a database object for details:<br/><br/>\
         <div>\
           <a href="#" class="show_all" onclick="return false;">[Show All]</a> | \
           <a href="#" class="hide_all" onclick="return false;">[Hide All]</a>\
         </div>\
       </div>';
    //var tables = _.map(schema.tables, function(table){ console.log(table); });
    schemaHTML += '<table border="0" cellpadding="0" cellspacing="0" class="schema_container">';
    var tableId = 0;
    _.each(schema.tables, function(table, tableName){
      tableId++;
      var dispName = tableName;
      if(dispName && (dispName[0]=='.')) dispName = dispName.substr(1);
      dispName = 'table_' + dispName;
      var tableColumns = _.map(table.fields, function(field){ return field.name; }).join(',');
      schemaHTML += '<tr>';
      schemaHTML +=
        '<td class="table_name"><a href="#" class="expandable" data-tableid="'+tableId+'" onclick="return false;">'+XExt.escapeHTML(dispName.substr(6))+'</a></td>\
         <td><a href="#" class="expandable" data-tableid="'+tableId+'" onclick="return false;">Schema</a></td>\
         <td><a href="<%=jsh._BASEURL%><%=model.module_namespace%>Dev/DBSQL?db='+XExt.escapeHTML(dbid)+'&table='+XExt.escapeHTML(dispName.substr(6))+'" target="_blank">Data</a></td>\
         <td><a href="<%=jsh._BASEURL%>_funcs/DEV_DB_SCHEMA?action=model&db='+XExt.escapeHTML(dbid)+'&schema='+XExt.escapeHTML(table.schema)+'&table='+XExt.escapeHTML(table.name)+'&output=text" target="_blank">Gen:Model</a></td>\
         <td><a href="<%=jsh._BASEURL%>_funcs/DEV_DB_SCHEMA?action=create&db='+XExt.escapeHTML(dbid)+'&schema='+XExt.escapeHTML(table.schema)+'&table='+XExt.escapeHTML(table.name)+'&output=dbobject" target="_blank">Gen:SQLObject</a></td>\
         <td><a href="<%=jsh._BASEURL%>_funcs/DEV_DB_SCHEMA?action=insert&db='+XExt.escapeHTML(dbid)+'&table='+XExt.escapeHTML(dispName.substr(6))+'&output=dbobject&rows=200&columns='+XExt.escapeHTML(tableColumns)+'" target="_blank">Gen:Insert</a></td>\
         <td width="100%"></td>';
      schemaHTML += '</tr>';
      schemaHTML += '<tr><td colspan="7">';
      schemaHTML += '<table class="schema_table schema_table_'+tableId+'" cellpadding="0" cellspacing="0" border="0" style="display:none;">';
      schemaHTML += '<tr>';
      schemaHTML += '<th>Column</th>';
      schemaHTML += '<th>Type</th>';
      schemaHTML += '<th>Null</th>';
      schemaHTML += '<th>Key</th>';
      schemaHTML += '<th>Attributes</th>';
      schemaHTML += '</tr>';
      _.each(table.fields, function(field){
        schemaHTML += '<tr>';
        schemaHTML += '<td>'+XExt.escapeHTML(field.name)+'</td>';
        var typedesc = field.type;
        if('length' in field) typedesc += '('+field.length+')';
        else if(('precision' in field) && field.precision && field.precision.length) typedesc += '(' + field.precision.join(',')+')';
        else if('precision' in field) typedesc += '('+field.precision+')';
        schemaHTML += '<td>'+XExt.escapeHTML(typedesc)+'</td>';
        var fielddesc = [];
        var notnull = false;
        if(field.coldef && field.coldef.required) notnull = true;
        schemaHTML += '<td>'+(notnull?'No':'Yes')+'</td>';
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
        schemaHTML += '<td>'+XExt.escapeHTMLBR(keytype)+'</td>';
        if(field.coldef){
          if(field.coldef.readonly) fielddesc.push('readonly');
        }
        schemaHTML += '<td>'+XExt.escapeHTML(fielddesc.join(','))+'</td>';
        schemaHTML += '</tr>';
      });
      schemaHTML += '<tr><td colspan="5"><a href="<%=jsh._BASEURL%><%=model.module_namespace%>Dev/DBSQL?db='+XExt.escapeHTML(dbid)+'&scripttype=recreate&table='+XExt.escapeHTML(dispName.substr(6))+'" target="_blank">&gt; Recreate</a></td>';
      schemaHTML += '</table>';
      schemaHTML += '</td></tr>';
    });
    _.each(funcs, function(func, funcName){
      tableId++;
      var dispName = funcName;
      if(dispName && (dispName[0]=='.')) dispName = dispName.substr(1);
      dispName = 'func_' + dispName;
      var funcVal = func;
      if(_.isString(funcVal)) funcVal = XExt.escapeHTMLBR(funcVal);
      else funcVal = '<pre>' + XExt.escapeHTML(JSON.stringify(funcVal,null,4)) + '</pre>';

      schemaHTML += '<tr>';
      schemaHTML +=
        '<td class="func_name"><a href="#" class="func_name expandable" data-tableid="'+tableId+'" onclick="return false;">Func: '+XExt.escapeHTML(dispName.substr(5))+'</a></td>\
         <td><a href="#" class="expandable" data-tableid="'+tableId+'" onclick="return false;">Definition</a></td>\
         <td colspan="5" width="100%"></td>';
      schemaHTML += '</tr>';
      schemaHTML += '<tr><td colspan="7">';
      schemaHTML += '<table class="schema_table schema_table_'+tableId+'" cellpadding="0" cellspacing="0" border="0" style="display:none;">';
      schemaHTML += '<tr>';
      schemaHTML += '<td>' + funcVal + '</td>';
      schemaHTML += '</tr>';
      schemaHTML += '</table>';
      schemaHTML += '</td></tr>';
    });
    schemaHTML += '</table>';
    jobj[0].innerHTML = schemaHTML;
    jobj.$find('.show_all').click(function(){ jobj.$find('table.schema_table').show(); });
    jobj.$find('.hide_all').click(function(){ jobj.$find('table.schema_table').hide(); });
    $('.expandable').click(function(){ _this.getTable(this).toggle(); });
    //jform.$find('.rslt').text(JSON.stringify(schema));
    jsh.XWindowResize();
  };

})();