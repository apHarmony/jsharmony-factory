jsh.App[modelid] = new (function(){
  var _this = this;

  this.sm_id_auto = 0;

  this.oninit = function(){
    XModels[modelid].sm_id_auto = function () { 
      if(!_this.sm_id_auto) _this.sm_id_auto = xmodel.controller.form.Data.sm_id_auto;
      return _this.sm_id_auto;
    };
    jsh.$root('.sm_id_auto.tree').data('oncontextmenu','return '+jsh.getInstance()+'.App['+modelid+'].oncontextmenu(this, n);');
  }

  this.oncontextmenu = function(ctrl, n){
    var menuid = '._item_context_menu_sm_id_auto';
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

  this.sm_id_onchange = function(obj, newval, undoChange) {
    if(jsh.XPage.GetChanges().length){
      undoChange();
      return XExt.Alert('Please save changes before navigating to a different record.');
    }
    jsh.App[modelid].select_sm_id_auto(newval);
  }

  this.select_sm_id_auto = function(newval, cb){
    xmodel.controller.form.Data.cur_sm_id_auto = newval;
    xmodel.controller.form.Data.sm_id_auto = newval;
    this.sm_id_auto = newval;
    jsh.XPage.Select({ modelid: XBase[xmodel.module_namespace+'X_SML_EDIT'][0], force: true }, cb);
  }

  this.item_insert = function(context_item){
    if(jsh.XPage.GetChanges().length) return XExt.Alert('Please save changes before adding menu items.');

    var fields = {
      "sm_name": { "caption": "Menu ID", "actions": "BI", "type": "varchar", "length": 30, "validators": [XValidate._v_Required(), XValidate._v_MaxLength(30)] },
      "sm_desc": { "caption": "Display Name", "actions": "BI", "type": "varchar", "length": 255, "validators": [XValidate._v_Required(), XValidate._v_MaxLength(255)] },
    }
    var data = { 'sm_id_parent': jsh.xContentMenuItemData.id };
    var validate = new XValidate();
    _.each(fields, function (val, key) { validate.AddControlValidator('.X_SMLW_InsertPopup .' + key, '_obj.' + key, val.caption, 'BI', val.validators); });

    XExt.CustomPrompt('.X_SMLW_InsertPopup','\
      <div class="X_SMLW_InsertPopup xdialogbox xpromptbox" style="width:360px;"> \
        <h3>Add Child Item</h3> \
        <div align="left" style="padding-top:15px;"> \
          <div style="width:100px;display:inline-block;margin-bottom:8px;text-align:right;">Menu ID:</div> <input type="text" class="sm_name" style="width:150px;" maxlength="255" /> (ex. ORDERS)<br/> \
          <div style="width:100px;display:inline-block;text-align:right;">Display Name:</div> <input type="text" class="sm_desc" style="width:150px;"maxlength="255" /><br/> \
          <div style="text-align:center;"><input type="button" value="Add" class="button_ok" style="margin-right:15px;" /> <input type="button" value="Cancel" class="button_cancel" /></div> \
        </div> \
      </div> \
    ',function(){ //onInit
      window.setTimeout(function(){jsh.$root('.X_SMLW_InsertPopup .sm_name').focus();},1);
    }, function (success) { //onAccept
      _.each(fields, function (val, key) { data[key] = jsh.$root('.X_SMLW_InsertPopup .' + key).val(); });
      if (!validate.ValidateControls('I', data, '')) return;
      XForm.prototype.XExecutePost('X_SMLW_INSERT', data, function (rslt) { //On success
        if ('_success' in rslt) { 
          jsh.App[modelid].select_sm_id_auto(parseInt(rslt.X_SMLW_INSERT[0].sm_id_auto), function(){
            success(); 
            jsh.XPage.Refresh(); 
          });
        }
      });
    }, function () { //onCancel
    }, function () { //onClosed
    });
  }

  this.getSMbyValue = function(sm_id_auto){
    if(!sm_id_auto) return null;
    var lov = xmodel.controller.form.LOVs.sm_id_auto;
    for(var i=0;i<lov.length;i++){
      if(lov[i][jsh.uimap.codeval]==sm_id_auto.toString()) return lov[i];
    }
    return null;
  }

  this.getSMbyID = function(sm_id){
    if(!sm_id) return null;
    var lov = xmodel.controller.form.LOVs.sm_id_auto;
    for(var i=0;i<lov.length;i++){
      if(lov[i][jsh.uimap.code_id]==sm_id.toString()) return lov[i];
    }
    return null;
  }

  this.item_delete = function(context_item){
    if(jsh.XPage.GetChanges().length) return XExt.Alert('Please save changes before deleting menu items.');
    var item_desc = XExt.getLOVTxt(xmodel.controller.form.LOVs.sm_id_auto,context_item);

    var sm = jsh.App[modelid].getSMbyValue(context_item);
    var sm_parent = null;
    var has_children = false;
    if(sm){
      if(!sm[jsh.uimap.code_parent_id]) return XExt.Alert('Cannot delete root node');
      sm_parent = jsh.App[modelid].getSMbyID(sm[jsh.uimap.code_parent_id]);
      var lov = xmodel.controller.form.LOVs.sm_id_auto;
      for(var i=0;i<lov.length;i++){
        if(lov[i][jsh.uimap.code_parent_id] && (lov[i][jsh.uimap.code_parent_id].toString()==sm[jsh.uimap.code_id].toString())) has_children = true;
      }
    }

    if(has_children){ XExt.Alert('Cannot delete menu item with children.  Please delete child items first.'); return; }

    //Move to parent ID if the deleted node is selected
    var new_sm_id_auto = null;
    if(_this.sm_id_auto==context_item){
      if(sm_parent) new_sm_id_auto = sm_parent[jsh.uimap.codeval];
    }

    XExt.Confirm('Are you sure you want to delete \''+item_desc+'\'?',function(){ 
      XForm.prototype.XExecutePost('X_SMLW_DELETE', { sm_id_auto: context_item }, function (rslt) { //On success
        if ('_success' in rslt) { 
          //Select parent
          if(new_sm_id_auto) XExt.TreeSelectNode(jsh.$root('.sm_id_auto.tree'),new_sm_id_auto);
          jsh.XPage.Refresh(); 
        }
      });
    });
  }

})();