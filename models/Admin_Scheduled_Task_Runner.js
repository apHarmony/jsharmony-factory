jsh.App[modelid] = new (function(){
  var _this = this;

  var tmpl_scheduled_task_listing = '';

  this.oninit = function() {
    tmpl_scheduled_task_listing = jsh.$root('.'+xmodel.class+'_scheduled_task_listing').html();
    
    XForm.prototype.XExecute('../_funcs/SCHEDULED_TASK_RUNNER', { }, function (rslt) { //On success
      if ('_success' in rslt) {
        _this.render(rslt.scheduled_tasks);
      }
    });
  };

  this.render = function(scheduled_tasks) {
    var jcontainer = jsh.$root('.'+xmodel.class+'_scheduled_task_listing_container');
    
    jcontainer.html(XExt.renderClientEJS(tmpl_scheduled_task_listing, {
      _: _,
      jsh: jsh,
      scheduled_tasks: scheduled_tasks,
    }));

    jcontainer.$find('.scheduled_task').on('click', function() {
      var task_id = $(this).data('key');
      XExt.Confirm('Run "'+task_id+'"?', function(){
        XForm.prototype.XExecutePost('../_funcs/SCHEDULED_TASK_RUNNER', { task_id: task_id }, function (rslt) { //On success
          if ('_success' in rslt) {
            XExt.Alert('Task run successfully.');
          }
        });
      });
    });
  };
})();