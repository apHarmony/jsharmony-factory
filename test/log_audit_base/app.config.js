/*
Copyright 2021 apHarmony

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


exports = module.exports = function(jsh, config, dbconfig){

  // in order to
  //  node ../../init/create.js
  // the database connection info needs to be set here. Database type can't be defined on the command line.
  //dbconfig['default'] = require('../lib/dbconfig.mssql.js');
  //dbconfig['default'] = require('../lib/dbconfig.pgsql.js');

  //Server Settings
  config.server.http_port = 8080;
  config.server.https_port = 8081;
  config.server.https_cert = 'path/to/https-cert.pem';
  config.server.https_key = 'path/to/https-key.pem';
  config.server.https_ca = 'path/to/https-ca.crt';
  config.frontsalt = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";   //REQUIRED: Use a 60+ mixed character string

  //jsHarmony Factory Configuration
  var configFactory = config.modules['jsHarmonyFactory'];

  configFactory.clientsalt = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";   //REQUIRED: Use a 60+ mixed character string
  configFactory.clientcookiesalt = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";   //REQUIRED: Use a 60+ mixed character string
  configFactory.mainsalt = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";   //REQUIRED: Use a 60+ mixed character string
  configFactory.maincookiesalt = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";   //REQUIRED: Use a 60+ mixed character string
}
