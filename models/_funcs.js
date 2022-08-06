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

var _ = require('lodash');
var Helper = require('jsharmony/Helper');

function ModuleFunctions(module){

  _.extend(this, require('./_funcs.LOG.js')(module, this));
  _.extend(this, require('./_funcs.SUGGEST_FEATURE.js')(module, this));
  _.extend(this, require('./_funcs.DEV_DB_SCRIPTS.js')(module, this));
  _.extend(this, require('./_funcs.DEV_DB_OBJECTS.js')(module, this));
  _.extend(this, require('./_funcs.DEV_DB_UPGRADE.js')(module, this));
  _.extend(this, require('./_funcs.DEV_DB_DIFF.js')(module, this));
  _.extend(this, require('./_funcs.DEV_DB_SCHEMA.js')(module, this));
  _.extend(this, require('./_funcs.DEV_MODELS.js')(module, this));
  _.extend(this, require('./_funcs.DEV_EMAILTEST.js')(module, this));

  this.replaceSchema = function(sql){
    return Helper.ReplaceAll(sql,'{schema}.', module.schema?module.schema+'.':'');
  };
  
  this._transform = function(elem){
    return module.transform.mapping[elem];
  };
}

exports = module.exports = ModuleFunctions;
