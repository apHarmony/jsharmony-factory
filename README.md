# ==================
# jsharmony-factory
# ==================

Enterprise framework for jsHarmony

## Installation

npm install jsharmony-factory --save

## Usage

1. Create your database in PostgreSQL or SQL Server, and initialize the database with the jsHarmony Factory database template.
2. Create a file in the project root named "app.js" with the following code:
   ```javascript
   var jsHarmonyFactory = require('jsharmony-factory');
   var jsf = new jsHarmonyFactory();
   jsf.Run();
   ```
3. Create a file in the project root named "app.settings.js" with the following minimum settings:
   ```javascript
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
   ```
   ** Alternatively use the jsharmony-db-mssql library for SQL Server
3. Create a "data" folder and "models" folder.  Develop the models for the project.
4. Start the server with the following command:
   ```javascript
   node app.js
   ```
   ** For development, it is recommended to use the node-supervisor program to auto-restart the server on updates:
   ```javascript
   supervisor -i data,node-modules -e "node,js,json,css" node ./app.js
   ```

## Release History

* 1.0.0 Initial release