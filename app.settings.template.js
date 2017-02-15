/*
Copyright 2017 apHarmony

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

var pgsqlDBDriver = require('jsharmony-db-pgsql');
global.dbconfig = { host: "server.domain.com", database: "DBNAME", user: "DBUSER", password: "DBPASS", _driver: new pgsqlDBDriver() };
global.http_port = 8080;
global.https_port = 8081;
global.https_cert = 'path/to/https-cert.pem';
global.https_key = 'path/to/https-key.pem';
global.clientsalt = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';   //REQUIRED: Use a 60+ mixed character string
global.clientcookiesalt = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';   //REQUIRED: Use a 60+ mixed character string
global.adminsalt = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';   //REQUIRED: Use a 60+ mixed character string
global.admincookiesalt = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';   //REQUIRED: Use a 60+ mixed character string
global.frontsalt = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'; //REQUIRED: Use a 60+ mixed character string
