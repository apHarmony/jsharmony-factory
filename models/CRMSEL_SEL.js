var CRMSEL_SEL_loadobj = '';
var CRMSEL_SEL_ops = [];

function CRMSEL_SEL_SelectAll(){
	CRMSEL_SEL_ForAllChildren(function (obj) {
    if ($(obj).is(':checked')) return;
    if ($(obj).css('visibility').toLowerCase() == 'hidden') return;
    CRMSEL_SEL_ops.push(function () { $(obj).trigger('click'); });
  });
}

function CRMSEL_SEL_DeselectAll(){
	CRMSEL_SEL_ForAllChildren(function (obj) {
    if (!$(obj).is(':checked')) return;
    if ($(obj).css('visibility').toLowerCase() == 'hidden') return;
    CRMSEL_SEL_ops.push(function () { $(obj).trigger('click'); });
  });
}

function CRMSEL_SEL_ForAllChildren(add_op) {
	  if (CRMSEL_SEL_loadobj) return;
	  CRMSEL_SEL_ops = [];
	  //First, Select All Unchecked
	  var jtbl = $('#xform' + XBase['CRMSEL_SEL'][0] + '.xtbl');
	  var xform = window['xform_' + XBase['CRMSEL_SEL'][0]];
	  CRMSEL_SEL_loadobj = 'CRMSEL_SELLOADER';
	  window.xLoader.StartLoading(CRMSEL_SEL_loadobj);
	  
	  function fselectall() {
	    jtbl.find('input.checkbox.crmsel_sel').each(function () {
	      add_op(this);
	    });
	    CRMSEL_SEL_oncommit();
	  }
	  
	  function loadmore() {
	    if (xform.EOF) { fselectall(); return; }
	    xform.Load(xform.RowCount, undefined, loadmore);
	  }
	  loadmore();
}

function CRMSEL_SEL_oninit(xform) {
  window['xform_post_'+XBase['CRMSEL_SEL'][0]].GetReselectParams = function(){ 
	  var rslt = this.GetKeys(); 
	  rslt.sr_name = this.Data.new_sr_name; 
	  return rslt; 
  };
  var old_onbeforeunload = window.onbeforeunload;
  window.onbeforeunload = function(){
	  XForm_RefreshParent();
	  if(old_onbeforeunload) old_onbeforeunload();
  }
}

function CRMSEL_SEL_oncommit(){
	  if(!CRMSEL_SEL_loadobj){ $(document.activeElement).blur(); return; }
	  if (CRMSEL_SEL_ops.length == 0) {
	    window.xLoader.StopLoading(CRMSEL_SEL_loadobj);
	    XExt.Alert('Operation complete.',function(){
	    	$('.save').first().focus().blur();
	    });
	    CRMSEL_SEL_loadobj = '';
	    return;
	  }
	  var op = CRMSEL_SEL_ops.shift();
	  op();
}