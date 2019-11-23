jsh.App[modelid] = new (function(){
  var _this = this;

  this.menu_id_auto = 0;

  this.oninit = function(){
    XModels[modelid].menu_id_auto = function () { 
      if(!_this.menu_id_auto) _this.menu_id_auto = xmodel.controller.form.Data.menu_id_auto;
      return _this.menu_id_auto;
    };
    jsh.$root('.menu_id_auto.tree').data('oncontextmenu','return '+XExt.getJSApp(modelid)+'.oncontextmenu(this, n);');
  }

  this.oncontextmenu = function(ctrl, n){
    var menuid = '._item_context_menu_menu_id_auto';
    var menu_add = jsh.$root(menuid).children('.insert');
    var menu_delete = jsh.$root(menuid).children('.delete');
    var jctrl = $(ctrl);
    var level = 0;
    var jpctrl = jctrl;
    while(!jpctrl.hasClass('tree') && (level < 100)){ level++; jpctrl = jpctrl.parent(); }
    if(level == 1){
      menu_add.show();
      menu_delete.hide();
    }
    else if(level == 2){
      menu_add.show();
      menu_delete.show();
    }
    else if(level == 3){
      menu_add.hide();
      menu_delete.show();
    }
    else {
    }
    XExt.ShowContextMenu(menuid, $(ctrl).data('value'), { id:n });
    return false;
  }

  this.menu_id_onchange = function(obj, newval, undoChange) {
    if(jsh.XPage.GetChanges().length){
      undoChange();
      return XExt.Alert('Please save changes before navigating to a different record.');
    }
    jsh.App[modelid].select_menu_id_auto(newval);
  }

  this.select_menu_id_auto = function(newval, cb){
    xmodel.set('cur_menu_id_auto', newval);
    xmodel.controller.form.Data.menu_id_auto = newval;
    this.menu_id_auto = newval;
    jsh.XPage.Select({ modelid: XBase[xmodel.module_namespace+'Dev/Menu'][0], force: true }, cb);
  }

  this.item_insert = function(context_item){
    if(jsh.XPage.GetChanges().length) return XExt.Alert('Please save changes before adding menu items.');

    var fields = {
      "menu_name": { "caption": "Menu ID", "actions": "BI", "type": "varchar", "length": 30, "validators": [XValidate._v_Required(), XValidate._v_MaxLength(30)] },
      "menu_desc": { "caption": "Display Name", "actions": "BI", "type": "varchar", "length": 255, "validators": [XValidate._v_Required(), XValidate._v_MaxLength(255)] },
    }
    var data = { 'menu_id_parent': jsh.xContextMenuItemData.id };
    var validate = new XValidate();
    _.each(fields, function (val, key) { validate.AddControlValidator('.Menu_InsertPopup .' + key, '_obj.' + key, val.caption, 'BI', val.validators); });

    XExt.CustomPrompt('.Menu_InsertPopup','\
      <div class="Menu_InsertPopup xdialogbox xpromptbox" style="width:360px;"> \
        <h3>Add Child Item</h3> \
        <div align="left" style="padding-top:15px;"> \
          <div style="width:100px;display:inline-block;margin-bottom:8px;text-align:right;">Menu ID:</div> <input type="text" class="menu_name" style="width:150px;" maxlength="255" /> (ex. ORDERS)<br/> \
          <div style="width:100px;display:inline-block;text-align:right;">Display Name:</div> <input type="text" class="menu_desc" style="width:150px;"maxlength="255" /><br/> \
          <div style="text-align:center;"><input type="button" value="Add" class="button_ok" style="margin-right:15px;" /> <input type="button" value="Cancel" class="button_cancel" /></div> \
        </div> \
      </div> \
    ',function(){ //onInit
      window.setTimeout(function(){jsh.$root('.Menu_InsertPopup .menu_name').focus();},1);
    }, function (success) { //onAccept
      _.each(fields, function (val, key) { data[key] = jsh.$root('.Menu_InsertPopup .' + key).val(); });
      if (!validate.ValidateControls('I', data, '')) return;
      var insertTarget = xmodel.module_namespace+'Dev/Menu_Exec_Insert';
      XForm.prototype.XExecutePost(insertTarget, data, function (rslt) { //On success
        if ('_success' in rslt) {
          jsh.App[modelid].select_menu_id_auto(parseInt(rslt[insertTarget][0].menu_id_auto), function(){
            success(); 
            jsh.XPage.Refresh(); 
          });
        }
      });
    }, function () { //onCancel
    }, function () { //onClosed
    });
  }

  this.getSMbyValue = function(menu_id_auto){
    if(!menu_id_auto) return null;
    var lov = xmodel.controller.form.LOVs.menu_id_auto;
    for(var i=0;i<lov.length;i++){
      if(lov[i][jsh.uimap.code_val]==menu_id_auto.toString()) return lov[i];
    }
    return null;
  }

  this.getSMbyID = function(menu_id){
    if(!menu_id) return null;
    var lov = xmodel.controller.form.LOVs.menu_id_auto;
    for(var i=0;i<lov.length;i++){
      if(lov[i][jsh.uimap.code_id]==menu_id.toString()) return lov[i];
    }
    return null;
  }

  this.item_delete = function(context_item){
    if(jsh.XPage.GetChanges().length) return XExt.Alert('Please save changes before deleting menu items.');
    var item_desc = XExt.getLOVTxt(xmodel.controller.form.LOVs.menu_id_auto,context_item);

    var menu = jsh.App[modelid].getSMbyValue(context_item);
    var menu_parent = null;
    var has_children = false;
    if(menu){
      if(!menu[jsh.uimap.code_parent_id]) return XExt.Alert('Cannot delete root node');
      menu_parent = jsh.App[modelid].getSMbyID(menu[jsh.uimap.code_parent_id]);
      var lov = xmodel.controller.form.LOVs.menu_id_auto;
      for(var i=0;i<lov.length;i++){
        if(lov[i][jsh.uimap.code_parent_id] && (lov[i][jsh.uimap.code_parent_id].toString()==menu[jsh.uimap.code_id].toString())) has_children = true;
      }
    }

    if(has_children){ XExt.Alert('Cannot delete menu item with children.  Please delete child items first.'); return; }

    //Move to parent ID if the deleted node is selected
    var new_menu_id_auto = null;
    if(_this.menu_id_auto==context_item){
      if(menu_parent) new_menu_id_auto = menu_parent[jsh.uimap.code_val];
    }

    XExt.Confirm('Are you sure you want to delete \''+item_desc+'\'?',function(){ 
      XForm.prototype.XExecutePost(xmodel.module_namespace+'Dev/Menu_Exec_Delete', { menu_id_auto: context_item }, function (rslt) { //On success
        if ('_success' in rslt) { 
          //Select parent
          if(new_menu_id_auto) XExt.TreeSelectNode(jsh.$root('.menu_id_auto.tree'),new_menu_id_auto);
          jsh.XPage.Refresh(); 
        }
      });
    });
  }

})();