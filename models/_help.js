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

function getHelpURL(req, jsh, jshFactory, helpid){
  var help_view = getHelpView(req, jsh, jshFactory);
  var help_view_model = jsh.getModel(req, help_view);
  if(!help_view_model) return '';
  var helpid = helpid||'';
  return req.baseurl + help_view_model.id + '/?' + jshFactory.Config.help_panelid + '=' + encodeURIComponent(helpid); //help_listing
}

function getHelpOnClick(req, jsh, jshFactory) {
  var help_view = getHelpView(req, jsh, jshFactory);
  if(!help_view) return req.jshsite.instance+'.XExt.Alert(\'Help not initialized.\'); return false;';
  return jsh.getModelLinkOnClick(req, undefined, help_view);
}
function getHelpView(req, jsh, jshFactory){
  if(!jshFactory.Config.help_view) return null;
  if(_.isString(jshFactory.Config.help_view)) return jshFactory.Config.help_view;
  for(var siteid in jshFactory.Config.help_view){
    if(req.jshsite.id==siteid) return jshFactory.Config.help_view[siteid];
  }
  return '';
  //throw new Error("help_view not defined in _config.json for '"+siteid+"' site");
}

exports = module.exports = function(req, res, jsh, helpid, onComplete){
  var jshFactory = this;
  var helpurl = getHelpURL(req, jsh, jshFactory, helpid);
  var helpurl_onclick = getHelpOnClick(req, jsh, jshFactory);
  return onComplete(helpurl, helpurl_onclick);
};
