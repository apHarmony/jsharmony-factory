function X_MODELS_ShowUserModels(popupmodelid, parentmodelid, fieldid, onComplete) {
  var searchitems = [];
  searchitems.push(new XSearch.SearchItem('model_component', 'jsharmony-factory', 'and', '<>'));
  window['XForm' + popupmodelid + '_SetFilter'](searchitems, true);
  window['XForm' + popupmodelid + '_FilterApply']();
  onComplete();
}
