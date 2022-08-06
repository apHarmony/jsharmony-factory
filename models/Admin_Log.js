jsh.App[modelid] = new (function(){
  var _this = this;

  _this.onload = function(){
    //Load API Data
    this.loadData();
  };

  _this.loadData = function(){

    var filename = jsh._GET['filename'];
    xmodel.set('filename', filename);

    XForm.prototype.XExecute('../_funcs/LOG_DOWNLOAD', { filename: filename, output: 'json' }, function (rslt) { //On Success
      if ('_success' in rslt) {
        //Render Log
        if(!(rslt.log||'').trim()){
          $('#'+xmodel.class+'_log').html('-----------');
        }
        else {
          $('#'+xmodel.class+'_log').html(XExt.escapeHTMLBR(rslt.log));
        }
        xmodel.set('mtime', rslt.mtime);
      }
      else XExt.Alert('Error while loading data');
    }, function (err) {
      //Additional error handling
    });
  };

})();