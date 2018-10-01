jsh.App.X_MODELS = { }

jsh.App.X_MODELS.ShowUserModels = function(popupmodelid, parentmodelid, fieldid, onComplete){
  var searchitems = [];
  searchitems.push(new jsh.XSearch.SearchItem('model_component', 'jsharmonyFactory', 'and', '<>'));
  jsh.App['XForm' + popupmodelid + '_SetFilter'](searchitems, true);
  jsh.App['XForm' + popupmodelid + '_FilterApply'](onComplete);
}
