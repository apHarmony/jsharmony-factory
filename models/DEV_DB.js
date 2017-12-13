function DEV_DB_RunSQL(){
  var sql = $('#DEV_DB_sql').val();
  starttm = Date.now();
  XPost.prototype.XExecutePost('../_db/exec', { sql: sql }, function (rslt) { //On success
    if ('_success' in rslt) { 
      var txt = '';
      if(rslt.dbrslt[0]) for(var i=0;i<rslt.dbrslt[0].length;i++){
        txt += "Resultset " + (i+1).toString() + "\r\n" + "------------------------------------\r\n";
        txt += JSON.stringify(rslt.dbrslt[0][i],null,4) + "\r\n\r\n";
      }
      txt += "\r\nOperation complete";
      var endtm = Date.now();
      txt += "\r\nTime: " + (endtm-starttm) + "ms";
      $('#DEV_DB_rslt').text(txt);
    }
  });
}