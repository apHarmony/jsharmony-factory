jsh.App[modelid] = new (function(){
  var _this = this;

  this.DBs = {};  //Populated onroute

  this.getFormElement = function(){
    return jsh.xd('.xformcontainer.xelem'+xmodel.class);
  };

  this.oninit = function(xmodel) {
    var xdform = _this.getFormElement();
    XForm.prototype.XExecute('../_funcs/DEV_DB_SCHEMA', { }, function (rslt) { //On success
      if ('_success' in rslt) {
        _this.RenderDBListing(rslt.dbs);
      }
    });
    xdform.get('.db').on('change', function(){
      var db = xdform.get('.db').value;
      if(!db) xdform.get('.run').style.display = false;
      else _this.GetSchema(db);
    });
  };

  this.RenderDBListing = function(dbs){
    var xdform = _this.getFormElement();
    var xdobj = xdform.get('.db');
    var tmpl = jsh.xd('.'+xmodel.class+'_DB_listing_template').html;
    xdobj.append(XDom.render.ejs(tmpl, {dbs: dbs}));
    if(dbs.length > 1){
      xdform.get('.dbselect').style.display = true;
    }
    else {
      xdform.get('.dbselect').style.display = false;
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
    var xdobj = XDom(obj);
    var tableId = xdobj.data.tableid;
    return _this.getFormElement().get('.schema_table_'+tableId);
  };

  this.RenderSchema = function(dbid, schema, funcs){
    var xdform = _this.getFormElement();
    var xdobj = xdform.get('.rslt');
    var schemaHTML = '';
    schemaHTML +=
      '<div class="no_print">Click on a database object for details:<br/><br/>\
         <div>\
           <a href="#" class="show_all" onclick="return false;">[Show All]</a> | \
           <a href="#" class="hide_all" onclick="return false;">[Hide All]</a> | \
           <a href="#" class="print" onclick="return false;">[Print]</a>\
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
         <td><a class="no_print expandable" href="#" data-tableid="'+tableId+'" onclick="return false;">Schema</a></td>\
         <td><a class="no_print" href="<%=jsh._BASEURL%><%=model.module_namespace%>Dev/DBSQL?db='+XExt.escapeHTML(dbid)+'&table='+XExt.escapeHTML(dispName.substr(6))+'" target="_blank">Data</a></td>\
         <td><a class="no_print" href="<%=jsh._BASEURL%>_funcs/DEV_DB_SCHEMA?action=model&db='+XExt.escapeHTML(dbid)+'&schema='+XExt.escapeHTML(table.schema)+'&table='+XExt.escapeHTML(table.name)+'&output=text" target="_blank">Gen:Model</a></td>\
         <td><a class="no_print" href="<%=jsh._BASEURL%>_funcs/DEV_DB_SCHEMA?action=create&db='+XExt.escapeHTML(dbid)+'&schema='+XExt.escapeHTML(table.schema)+'&table='+XExt.escapeHTML(table.name)+'&output=dbobject" target="_blank">Gen:SQLObject</a></td>\
         <td><a class="no_print" href="<%=jsh._BASEURL%>_funcs/DEV_DB_SCHEMA?action=insert&db='+XExt.escapeHTML(dbid)+'&table='+XExt.escapeHTML(dispName.substr(6))+'&output=dbobject&rows=200&columns='+XExt.escapeHTML(tableColumns)+'" target="_blank">Gen:SampleData</a></td>\
         <td><a class="no_print" href="<%=jsh._BASEURL%>_funcs/DEV_DB_SCHEMA?action=insert&db='+XExt.escapeHTML(dbid)+'&table='+XExt.escapeHTML(dispName.substr(6))+'&output=sql&rows=200&columns='+XExt.escapeHTML(tableColumns)+'" target="_blank">Gen:Insert</a></td>\
         <td width="100%"></td>';
      schemaHTML += '</tr>';
      schemaHTML += '<tr><td colspan="8">';
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
      schemaHTML += '<tr class="no_print"><td colspan="6"><a href="<%=jsh._BASEURL%><%=model.module_namespace%>Dev/DBSQL?db='+XExt.escapeHTML(dbid)+'&scripttype=recreate&table='+XExt.escapeHTML(dispName.substr(6))+'" target="_blank">&gt; Recreate</a></td>';
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

      schemaHTML += '<tr class="no_print">';
      schemaHTML +=
        '<td class="func_name"><a href="#" class="func_name expandable" data-tableid="'+tableId+'" onclick="return false;">Func: '+XExt.escapeHTML(dispName.substr(5))+'</a></td>\
         <td><a href="#" class="expandable" data-tableid="'+tableId+'" onclick="return false;">Definition</a></td>\
         <td colspan="6" width="100%"></td>';
      schemaHTML += '</tr>';
      schemaHTML += '<tr class="no_print"><td colspan="8">';
      schemaHTML += '<table class="schema_table schema_table_'+tableId+'" cellpadding="0" cellspacing="0" border="0" style="display:none;">';
      schemaHTML += '<tr>';
      schemaHTML += '<td>' + funcVal + '</td>';
      schemaHTML += '</tr>';
      schemaHTML += '</table>';
      schemaHTML += '</td></tr>';
    });
    schemaHTML += '</table>';
    xdobj.element.innerHTML = schemaHTML;
    xdobj.get('.show_all').on('click', function(){ xdobj.get('table.schema_table').style.display = true; });
    xdobj.get('.hide_all').on('click', function(){ xdobj.get('table.schema_table').style.display = false; });
    xdobj.get('.print').on('click', function(){
      xdobj.get('.no_print').remove();
      xdobj.get('table.schema_table').style.display = true;
      xdobj.get('.schema_container').class.add('schema_print');
      window.print();
    });
    XDom('.expandable').on('click', function(){ var xdTable = _this.getTable(this); xdTable.style.display = !xdTable.isVisible(); });
    //jform.$find('.rslt').text(JSON.stringify(schema));
    jsh.XWindowResize();
  };

})();