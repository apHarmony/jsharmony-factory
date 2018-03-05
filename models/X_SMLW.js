var X_SMLW_sm_id_auto = 0;

function X_SMLW_oninit(){
  XForms[XBase['X_SMLW'][0]].sm_id_auto = function () { 
    if(!X_SMLW_sm_id_auto) X_SMLW_sm_id_auto = window['xform_'+XBase['X_SMLW'][0]].Data.sm_id_auto;
    return X_SMLW_sm_id_auto;
  };
  $('#sm_id_auto.tree').data('oncontextmenu','return X_SMLW_oncontextmenu(this, n);');
}
function X_SMLW_oncontextmenu(ctrl, n){
  var menuid = '#_item_context_menu_sm_id_auto';
  var menu_add = $(menuid).children('.add');
  var menu_delete = $(menuid).children('.delete');
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
function X_SMLW_sm_id_onchange(obj, newval) {
  X_SMLW_select_sm_id_auto(newval);
}
function X_SMLW_select_sm_id_auto(newval,cb){
  xform_X_SMLW.Data.cur_sm_id_auto = newval;
  xform_X_SMLW.Data.sm_id_auto = newval;
  X_SMLW_sm_id_auto = newval;
  XForm_Select(cb, XBase['X_SML_EDIT'][0]);
}
function X_SMLW_item_insert(context_item){
  if(XForm_GetChanges().length) return XExt.Alert('Please save changes before adding menu items.');

  var fields = {
    "sm_name": { "caption": "Menu ID", "actions": "BI", "type": "varchar", "length": 30, "validators": [XValidate._v_Required(), XValidate._v_MaxLength(30)] },
    "sm_desc": { "caption": "Display Name", "actions": "BI", "type": "varchar", "length": 255, "validators": [XValidate._v_Required(), XValidate._v_MaxLength(255)] },
  }
  var data = { 'sm_id_parent': window.xContentMenuItemData.id };
  var validate = new XValidate();
  _.each(fields, function (val, key) { validate.AddControlValidator('#X_SMLW_InsertPopup .' + key, '_obj.' + key, val.caption, 'BI', val.validators); });

  XExt.CustomPrompt('X_SMLW_InsertPopup','\
    <div id="X_SMLW_InsertPopup" class="xdialogbox xpromptbox" style="width:360px;"> \
      <h3>Add Child Item</h3> \
      <div align="left" style="padding-top:15px;"> \
        <div style="width:100px;display:inline-block;margin-bottom:8px;text-align:right;">Menu ID:</div> <input type="text" class="sm_name" style="width:150px;" maxlength="30" /> (ex. ORDERS)<br/> \
        <div style="width:100px;display:inline-block;text-align:right;">Display Name:</div> <input type="text" class="sm_desc" style="width:150px;"maxlength="255" /><br/> \
        <div style="text-align:center;"><input type="button" value="Add" class="button_ok" style="margin-right:15px;" /> <input type="button" value="Cancel" class="button_cancel" /></div> \
      </div> \
    </div> \
  ',function(){ //onInit
    window.setTimeout(function(){$('#X_SMLW_InsertPopup .sm_name').focus();},1);
  }, function (success) { //onAccept
    _.each(fields, function (val, key) { data[key] = $('#X_SMLW_InsertPopup .' + key).val(); });
    if (!validate.ValidateControls('I', data, '')) return;
    XPost.prototype.XExecutePost('X_SMLW_INSERT', data, function (rslt) { //On success
      if ('_success' in rslt) { 
        X_SMLW_select_sm_id_auto(parseInt(rslt.X_SMLW_INSERT[0].sm_id_auto),function(){
          success(); 
          XForm_Refresh(); 
        });
      }
    });
  }, function () { //onCancel
  }, function () { //onClosed
  });
}
function X_SMLW_getSMbyValue(sm_id_auto){
  if(!sm_id_auto) return null;
  var lov = window['xform_'+XBase["X_SMLW"]]._LOVs.sm_id_auto;
  for(var i=0;i<lov.length;i++){
    if(lov[i][window.jshuimap.codeval]==sm_id_auto.toString()) return lov[i];
  }
  return null;
}
function X_SMLW_getSMbyID(sm_id){
  if(!sm_id_auto) return null;
  var lov = window['xform_'+XBase["X_SMLW"]]._LOVs.sm_id_auto;
  for(var i=0;i<lov.length;i++){
    if(lov[i][window.jshuimap.codeid]==sm_id.toString()) return lov[i];
  }
  return null;
}
function X_SMLW_item_delete(context_item){
  if(XForm_GetChanges().length) return XExt.Alert('Please save changes before deleting menu items.');
  var item_desc = XExt.getLOVTxt(window['xform_'+XBase["X_SMLW"]]._LOVs.sm_id_auto,context_item);

  var sm = X_SMLW_getSMbyValue(context_item);
  var sm_parent = null;
  var has_children = false;
  if(sm){
    sm_parent = X_SMLW_getSMbyID(sm[window.jshuimap.codeparentid]);
    var lov = window['xform_'+XBase["X_SMLW"]]._LOVs.sm_id_auto;
    for(var i=0;i<lov.length;i++){
      if(lov[i][window.jshuimap.codeparentid] && (lov[i][window.jshuimap.codeparentid].toString()==sm[window.jshuimap.codeid].toString())) has_children = true;
    }
  }

  if(has_children){ XExt.Alert('Cannot delete menu item with children.  Please delete child items first.'); return; }

  //Move to parent ID if the deleted node is selected
  var new_sm_id_auto = null;
  if(X_SMLW_sm_id_auto==context_item){
    if(sm_parent) new_sm_id_auto = sm_parent[window.jshuimap.codeval];
  }

  XExt.Confirm('Are you sure you want to delete \''+item_desc+'\'?',function(){ 
    XPost.prototype.XExecutePost('X_SMLW_DELETE', { sm_id_auto: context_item }, function (rslt) { //On success
      if ('_success' in rslt) { 
        //Select parent
        if(new_sm_id_auto) XExt.TreeSelectNode($('#sm_id_auto.tree'),new_sm_id_auto);
        XForm_Refresh(); 
      }
    });
  });
}