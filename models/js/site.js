(function(jsh){
  var XExt = jsh.XExt;
  var XForm = jsh.XForm;

  jsh.System.suggestFeature = function(app_name){
    XExt.CustomPrompt('.suggest_feature', jsh.RenderEJS(jsh.GetEJS('jsHarmonyFactory.SuggestFeature'),{app_name: app_name}), function () { //onInit
    }, function (success) { //onAccept
      //Save content to server
      var jprompt = jsh.$root('.xdialogblock .suggest_feature');
      var params = {
        message_text: jprompt.$find('.message_text').val()
      };
      XForm.Post('/_funcs/SUGGEST_FEATURE',{},params,function(){
        success();
        setTimeout(function(){ XExt.Alert('Thank you for your feedback'); }, 1);
      });
    });
  };
})(window['{req.jshsite.instance}']);