exports = module.exports = function(appConfig, installerParams, callback){
  require('jsharmony/init/install.app.config.local.js')(appConfig, installerParams, function(err){
    if(err) return callback(err);

    appConfig.body += "\r\n";
    appConfig.body += "  //jsHarmony Factory Configuration\r\n";
    appConfig.body += "  var configFactory = config.modules['jsHarmonyFactory'];\r\n";
    if(installerParams.manifest && installerParams.manifest.installer && installerParams.manifest.installer.jsharmony_factory_client_portal){
      appConfig.body += "  configFactory.clientsalt = "+JSON.stringify(installerParams.xlib.getSalt(60))+";\r\n";
      appConfig.body += "  configFactory.clientcookiesalt = "+JSON.stringify(installerParams.xlib.getSalt(60))+";\r\n";
    }
    appConfig.body += "  configFactory.mainsalt = "+JSON.stringify(installerParams.xlib.getSalt(60))+";\r\n";
    appConfig.body += "  configFactory.maincookiesalt = "+JSON.stringify(installerParams.xlib.getSalt(60))+";\r\n";

    return callback();
  });
}