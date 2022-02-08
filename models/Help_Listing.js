jsh.App[modelid] = new (function(){
  var _this = this;

  this.checkedTargetMatch = false;

  this.oninit = function(xmodel) {
    _this.checkedTargetMatch = false;
    if('help_target_code' in _GET){
      xmodel.controller.grid.Data['help_target_code'] = _GET.help_target_code;
    }
  };

  this.onload = function(xmodel, callback){
    var xgrid = xmodel.controller.grid;
    if(xgrid.RowCount == 1){
      if(xmodel.get('help_target_code', 0)=='*'){
        XExt.navTo(jsh.$root('.xgrid_'+xmodel.class+'_placeholder a').first().prop('href'));
        return false;
      }
    }
    if(!_this.checkedTargetMatch && ('help_target_code' in _GET)){
      _this.checkedTargetMatch = true;
      if(xgrid.RowCount == 0){
        delete xgrid.Data.help_target_code;
        delete jsh._GET.help_target_code;
        jsh.XPage.Select(undefined, callback);
      } else {
        XExt.navTo(jsh.$root('.xgrid_'+xmodel.class+'_placeholder a').first().prop('href'));
      }
    }
    return false;
  };

})();
