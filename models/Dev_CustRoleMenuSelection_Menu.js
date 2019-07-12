jsh.App[modelid] = { }

jsh.App[modelid].loadobj = '';
jsh.App[modelid].ops = [];

jsh.App[modelid].oninit = function(xmodel) {
  var _this = this;
  xmodel.controller.form.GetReselectParams = function(){ 
	  var rslt = this.GetKeys(); 
	  rslt.sys_role_name = this.Data.new_sys_role_name; 
	  return rslt; 
  };
  var old_onbeforeunload = window.onbeforeunload;
  window.onbeforeunload = function(){
	  jsh.XPage.RefreshParent();
	  if(old_onbeforeunload) old_onbeforeunload();
  }
}

jsh.App[modelid].oncommit = function(){
  var _this = this;
  if(!_this.loadobj){ $(document.activeElement).blur(); return; }
  if (_this.ops.length == 0) {
    jsh.xLoader.StopLoading(_this.loadobj);
    XExt.Alert('Operation complete.',function(){
      jsh.$root('.save').first().focus().blur();
    });
    _this.loadobj = '';
    return;
  }
  var op = _this.ops.shift();
  op();
}

jsh.App[modelid].SelectAll = function(){
  var _this = this;
	_this.ForAllChildren(function (obj) {
    if ($(obj).is(':checked')) return;
    if ($(obj).css('visibility').toLowerCase() == 'hidden') return;
    _this.ops.push(function () { $(obj).trigger('click'); });
  });
}

jsh.App[modelid].DeselectAll = function(){
  var _this = this;
	_this.ForAllChildren(function (obj) {
    if (!$(obj).is(':checked')) return;
    if ($(obj).css('visibility').toLowerCase() == 'hidden') return;
    _this.ops.push(function () { $(obj).trigger('click'); });
  });
}

jsh.App[modelid].ForAllChildren = function(add_op) {
  var _this = this;
  if (_this.loadobj) return;
  _this.ops = [];
  //First, Select All Unchecked
  var jtbl = jsh.$root('.xform' + xmodel.class + '.xtbl');
  _this.loadobj = 'CRMSEL_SELLOADER';
  jsh.xLoader.StartLoading(_this.loadobj);
  
  function fselectall() {
    jtbl.find('input.checkbox.cust_menu_role_selection').each(function () {
      add_op(this);
    });
    _this.oncommit();
  }
  
  function loadmore() {
    var xgrid = xmodel.controller.grid;
    if (xgrid.EOF) { fselectall(); return; }
    xgrid.Load(xgrid.RowCount, undefined, loadmore);
  }
  loadmore();
}