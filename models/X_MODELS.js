jsh.App[modelid] = { }

jsh.App[modelid].ShowUserModels = function(popupmodelid, parentmodelid, fieldid, onComplete){
  var searchitems = [];
  searchitems.push(new jsh.XSearch.SearchItem('model_module', 'jsharmonyFactory', 'and', '<>'));
  searchitems.push(new jsh.XSearch.SearchItem('model_module', 'jsharmony', 'and', '<>'));
  var popupmodel = jsh.XModels[popupmodelid];
  popupmodel.controller.SetSearch(searchitems, true);
  popupmodel.controller.RunSearch(onComplete);
}
