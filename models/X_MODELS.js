jsh.App.X_MODELS = { }

jsh.App.X_MODELS.ShowUserModels = function(popupmodelid, parentmodelid, fieldid, onComplete){
  var searchitems = [];
  searchitems.push(new jsh.XSearch.SearchItem('model_module', 'jsharmonyFactory', 'and', '<>'));
  var popupmodel = jsh.XModels[popupmodelid];
  popupmodel.controller.SetFilter(searchitems, true);
  popupmodel.controller.FilterApply(onComplete);
}
