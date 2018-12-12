jsh.App.CRMSEL_SEL = { }

jsh.App.CRMSEL_SEL.loadobj = '';
jsh.App.CRMSEL_SEL.ops = [];

jsh.App.CRMSEL_SEL.oninit = function(xmodel) {
  var _this = this;
  xmodel.controller.form.GetReselectParams = function(){ 
	  var rslt = this.GetKeys(); 
	  rslt.sr_name = this.Data.new_sr_name; 
	  return rslt; 
  };
  var old_onbeforeunload = window.onbeforeunload;
  window.onbeforeunload = function(){
	  jsh.XPage.RefreshParent();
	  if(old_onbeforeunload) old_onbeforeunload();
  }
}

jsh.App.CRMSEL_SEL.oncommit = function(){
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

jsh.App.CRMSEL_SEL.SelectAll = function(){
  var _this = this;
	_this.ForAllChildren(function (obj) {
    if ($(obj).is(':checked')) return;
    if ($(obj).css('visibility').toLowerCase() == 'hidden') return;
    _this.ops.push(function () { $(obj).trigger('click'); });
  });
}

jsh.App.CRMSEL_SEL.DeselectAll = function(){
  var _this = this;
	_this.ForAllChildren(function (obj) {
    if (!$(obj).is(':checked')) return;
    if ($(obj).css('visibility').toLowerCase() == 'hidden') return;
    _this.ops.push(function () { $(obj).trigger('click'); });
  });
}

jsh.App.CRMSEL_SEL.ForAllChildren = function(add_op) {
  var _this = this;
  if (_this.loadobj) return;
  _this.ops = [];
  //First, Select All Unchecked
  var jtbl = jsh.$root('.xform' + xmodel.class + '.xtbl');
  _this.loadobj = 'CRMSEL_SELLOADER';
  jsh.xLoader.StartLoading(_this.loadobj);
  
  function fselectall() {
    jtbl.find('input.checkbox.crmsel_sel').each(function () {
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