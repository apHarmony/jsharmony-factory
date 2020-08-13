/*
Copyright 2020 apHarmony

This file is part of jsHarmony.

jsHarmony is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

jsHarmony is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this package.  If not, see <http://www.gnu.org/licenses/>.
*/

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