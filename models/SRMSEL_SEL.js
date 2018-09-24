var SRMSEL_SEL_loadobj = '';
var SRMSEL_SEL_ops = [];

function SRMSEL_SEL_SelectAll(){
	SRMSEL_SEL_ForAllChildren(function (obj) {
    if ($(obj).is(':checked')) return;
    if ($(obj).css('visibility').toLowerCase() == 'hidden') return;
    SRMSEL_SEL_ops.push(function () { $(obj).trigger('click'); });
  });
}

function SRMSEL_SEL_DeselectAll(){
	SRMSEL_SEL_ForAllChildren(function (obj) {
    if (!$(obj).is(':checked')) return;
    if ($(obj).css('visibility').toLowerCase() == 'hidden') return;
    SRMSEL_SEL_ops.push(function () { $(obj).trigger('click'); });
  });
}

function SRMSEL_SEL_ForAllChildren(add_op) {
	  if (SRMSEL_SEL_loadobj) return;
	  SRMSEL_SEL_ops = [];
	  //First, Select All Unchecked
	  var jtbl = $('#xform' + XBase['SRMSEL_SEL'][0] + '.xtbl');
	  var xform = jsh.App['xform_' + XBase['SRMSEL_SEL'][0]];
	  SRMSEL_SEL_loadobj = 'SRMSEL_SELLOADER';
	  jsh.xLoader.StartLoading(SRMSEL_SEL_loadobj);
	  
	  function fselectall() {
	    jtbl.find('input.checkbox.srmsel_sel').each(function () {
	      add_op(this);
	    });
	    SRMSEL_SEL_oncommit();
	  }
	  
	  function loadmore() {
	    if (xform.EOF) { fselectall(); return; }
	    xform.Load(xform.RowCount, undefined, loadmore);
	  }
	  loadmore();
}

function SRMSEL_SEL_oninit(xform) {
  jsh.App['xform_post_'+XBase['SRMSEL_SEL'][0]].GetReselectParams = function(){ 
	  var rslt = this.GetKeys(); 
	  rslt.sr_name = this.Data.new_sr_name; 
	  return rslt; 
  };
  var old_onbeforeunload = window.onbeforeunload;
  window.onbeforeunload = function(){
	  jsh.XForm_RefreshParent();
	  if(old_onbeforeunload) old_onbeforeunload();
  }
}

function SRMSEL_SEL_oncommit(){
	  if(!SRMSEL_SEL_loadobj){ $(document.activeElement).blur(); return; }
	  if (SRMSEL_SEL_ops.length == 0) {
	    jsh.xLoader.StopLoading(SRMSEL_SEL_loadobj);
	    XExt.Alert('Operation complete.',function(){
	    	$('.save').first().focus().blur();
	    });
	    SRMSEL_SEL_loadobj = '';
	    return;
	  }
	  var op = SRMSEL_SEL_ops.shift();
	  op();
}