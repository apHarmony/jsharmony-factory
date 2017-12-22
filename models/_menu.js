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

exports = module.exports = function GenMenu(type, req, res, jsh, params, onComplete) {
  if(!req.isAuthenticated){
    params.XMenu = {};
    return onComplete();
  }
  var rootmenu = '';
  var basetemplate = req.jshconfig.basetemplate;
  if (basetemplate == 'index') rootmenu = 'ADMIN';
  else if (basetemplate == 'client') rootmenu = 'CLIENT';

  if (rootmenu == '') { onComplete(); return; }
  var dbtypes = jsh.AppSrv.DB.types;
  var topmenu = '';
  if ('TopMenu' in params) topmenu = params.TopMenu;
  
  var menusql = "menu_admin";
  if (type == 'C') menusql = "menu_client";
  
  var sqlparams = {};
  sqlparams[jsh.map.user_id] = req.user_id;
  sqlparams['ROOT_MENU'] = rootmenu;
  sqlparams['TOP_MENU'] = topmenu;
  jsh.AppSrv.ExecMultiRecordset(req._DBContext, menusql, [dbtypes.BigInt, dbtypes.VarChar(30), dbtypes.VarChar(30)], sqlparams, function (err, rslt) {
    if(err){ return Helper.GenError(req, res, -99999, "An unexpected database error has occurred: "+err.toString()); }
    console.log(JSON.stringify(rslt,null,4));
    var xmenu = {};
    xmenu.MainMenu = [];
    xmenu.SubMenus = {};
    if ((rslt != null) && (rslt.length == 1) && (rslt[0] != null) && (rslt[0].length == 2)) {
      _.each(rslt[0][0], function (menuitem) {
        var link_url = GenLink(req, jsh, menuitem);
        var link_onclick = '';
        
        if (menuitem[jsh.map.menu_command] && menuitem[jsh.map.menu_command].substr(0, 3) == 'js:') {
          link_url = '#';
          link_onclick = menuitem[jsh.map.menu_command].substr(3) + ' return false;';
        }
        else if (jsh.hasModel(req, menuitem[jsh.map.menu_command])) {
          var link_targetmodelid = jsh.parseLink(menuitem[jsh.map.menu_command]).modelid;
          link_url = jsh.getURL(req, menuitem[jsh.map.menu_command]);
          link_onclick = jsh.getModelLinkOnClick(link_targetmodelid, req, menuitem[jsh.map.menu_command]);
        }

        var selected = false;
        if (menuitem[jsh.map.menu_name].toString().toUpperCase() == topmenu.toString().toUpperCase()) {
          selected = true;
        }
        xmenu.MainMenu.push({ Title: menuitem[jsh.map.menu_title], Link: link_url, OnClick: link_onclick, Selected: selected, ID: menuitem[jsh.map.menu_name].toString().toUpperCase()  });
      });
      //Submenu
      var last_parent = null;
      var cur_sub_menu = [];
      _.each(rslt[0][1], function (menuitem) {
        if (menuitem[jsh.map.menu_parentname] !== last_parent) {
          if (cur_sub_menu.length > 0) xmenu.SubMenus[last_parent] = cur_sub_menu;
          cur_sub_menu = [];
          last_parent = menuitem[jsh.map.menu_parentname];
        }
        var link_url = GenLink(req, jsh, menuitem);
        var link_onclick = '';
        
        if (menuitem[jsh.map.menu_command] && menuitem[jsh.map.menu_command].substr(0, 3) == 'js:') {
          link_url = '#';
          link_onclick = menuitem[jsh.map.menu_command].substr(3)+' return false;';
        }
        else if (jsh.hasModel(req, menuitem[jsh.map.menu_command])) {
          var link_targetmodelid = jsh.parseLink(menuitem[jsh.map.menu_command]).modelid;
          link_url = jsh.getURL(req, menuitem[jsh.map.menu_command]);
          if (menuitem[jsh.map.menu_subcommand]) link_url += menuitem[jsh.map.menu_subcommand];
          link_onclick = jsh.getModelLinkOnClick(link_targetmodelid, req, menuitem[jsh.map.menu_command]);
        }

        cur_sub_menu.push({ Title: menuitem[jsh.map.menu_title], Link: link_url, OnClick: link_onclick });
      });
      if (cur_sub_menu.length > 0) xmenu.SubMenus[last_parent] = cur_sub_menu;
    }
    params.XMenu = xmenu;
    onComplete();
  });
}

function GenLink(req, jsh, menuitem){
  var rslt = req.baseurl + menuitem[jsh.map.menu_command];
  if (menuitem[jsh.map.menu_subcommand]) rslt += menuitem[jsh.map.menu_subcommand];
  rslt = Helper.ResolveParams(req, rslt);
  return rslt;
}