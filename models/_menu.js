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
  var startmodel = null;
  if(!req.isAuthenticated){
    params.menudata = {};
    params.startmodel = null;
    return onComplete();
  }
  var startmodel = null;
  var rootmenu = '';
  var basetemplate = req.jshsite.basetemplate;
  if (basetemplate == 'index') rootmenu = 'MAIN';
  else if (basetemplate == 'client') rootmenu = 'CLIENT';

  if (rootmenu == '') { onComplete(); return; }
  var dbtypes = jsh.AppSrv.DB.types;
  var selectedmenu = '';
  if ('selectedmenu' in params){
    selectedmenu = params.selectedmenu;
    if(!_.isString(selectedmenu) && _.isArray(selectedmenu)) selectedmenu = selectedmenu[selectedmenu.length - 1];
  }
  selectedmenu = (selectedmenu||'').toString().toUpperCase();
  
  var menusql = "menu_main";
  if (type == 'C') menusql = "menu_client";
  else if(req.jshsite && !req.jshsite.auth && req._roles && (req._roles.SYSADMIN || req._roles.DEV)) menusql = 'menu_main_noauth';

  //Select menu data from the database
  var sqlparams = {};
  sqlparams[jsh.map.user_id] = req.user_id;
  sqlparams['root_menu'] = rootmenu;
  jsh.AppSrv.ExecMultiRecordset(req._DBContext, menusql, [dbtypes.BigInt, dbtypes.VarChar(30)], sqlparams, function (err, rslt) {
    if(err){ return Helper.GenError(req, res, -99999, "An unexpected database error has occurred: "+err.toString()); }
    var xmenu = {};
    xmenu.MainMenu = [];
    xmenu.SubMenus = {};
    if ((rslt != null) && (rslt.length == 1) && (rslt[0] != null) && (rslt[0].length == 2)) {

      //Generate the Main Menu
      _.each(rslt[0][0], function (menuitem) {
        
        //Generate Link + Onclick Event
        var link_url = GenLink(req, jsh, menuitem);
        var link_onclick = '';
        if (menuitem[jsh.map.menu_command] && menuitem[jsh.map.menu_command].substr(0, 3) == 'js:') {
          link_url = '#';
          link_onclick = 'return '+req.jshsite.instance+'.XExt.JSEval('+JSON.stringify(menuitem[jsh.map.menu_command].substr(3)) + ')||false;';
        }
        else if (jsh.hasModel(req, menuitem[jsh.map.menu_command])) {
          link_url = jsh.getURL(req, undefined, menuitem[jsh.map.menu_command]);
          link_onclick = jsh.getURL_onclick(req, undefined, menuitem[jsh.map.menu_command]);
        }

        //Check if the menu item is selected
        var selected = false;
        console.log(jsh.map);
        if (menuitem[jsh.map.menu_name].toString().toUpperCase() == selectedmenu) {
          selected = true;
        }

        //Add the menu item to the array
        xmenu.MainMenu.push({ 
          ID: menuitem[jsh.map.menu_name].toString().toUpperCase(),
          Title: menuitem[jsh.map.menu_title], 
          Link: link_url,
          OnClick: link_onclick,
          Selected: selected
        });
      });

      //Generate the Submenus
      var last_parentname = null;
      var cur_parent = null;
      var cur_sub_menu = [];
      _.each(rslt[0][1], function (menuitem) {

        //Create a new submenu for each Parent ID
        if(!menuitem[jsh.map.menu_parentname]) return;
        if(menuitem[jsh.map.menu_parentname].toString().toUpperCase() !== last_parentname) {
          if (cur_sub_menu.length > 0) xmenu.SubMenus[last_parentname] = cur_sub_menu;
          cur_sub_menu = [];
          last_parentname = menuitem[jsh.map.menu_parentname].toString().toUpperCase();
          cur_parent = _.find(xmenu.MainMenu,function(menuitem){ return menuitem.ID==last_parentname; });
        }

        //Generate Link + Onclick Event
        var link_url = GenLink(req, jsh, menuitem);
        var link_onclick = '';
        if (menuitem[jsh.map.menu_command] && menuitem[jsh.map.menu_command].substr(0, 3) == 'js:') {
          link_url = '#';
          link_onclick = 'return '+req.jshsite.instance+'.XExt.JSEval('+JSON.stringify(menuitem[jsh.map.menu_command].substr(3)) + ')||false;';
        }
        else if (jsh.hasModel(req, menuitem[jsh.map.menu_command])) {
          link_url = jsh.getURL(req, undefined, menuitem[jsh.map.menu_command]);
          if (menuitem[jsh.map.menu_subcommand]) link_url += menuitem[jsh.map.menu_subcommand];
          link_onclick = jsh.getURL_onclick(req, undefined, menuitem[jsh.map.menu_command]);
        }

        //Check if the menu item is selected
        var selected = false;
        if (menuitem[jsh.map.menu_name].toString().toUpperCase() == selectedmenu) {
          cur_parent.Selected = true;
          selected = true;
        }

        //Add the menu item to the array
        cur_sub_menu.push({
          ID: menuitem[jsh.map.menu_name].toString().toUpperCase(),
          Title: menuitem[jsh.map.menu_title], 
          Link: link_url, 
          OnClick: link_onclick,
          Selected: selected
        });
      });
      if (cur_sub_menu.length > 0) xmenu.SubMenus[last_parentname] = cur_sub_menu;
    }

    //Find the startmodel
    for(var i=0;i<xmenu.MainMenu.length;i++){
      var menuitem = xmenu.MainMenu[i];
      if(menuitem.Link && (menuitem.Link != '/')){
        startmodel = menuitem.Link;
        break;
      }
    }

    //Return the data
    params.startmodel = startmodel;
    params.menudata = xmenu;
    onComplete();
  });
}

function GenLink(req, jsh, menuitem){
  var rslt = req.baseurl + menuitem[jsh.map.menu_command];
  if (menuitem[jsh.map.menu_subcommand]) rslt += menuitem[jsh.map.menu_subcommand];
  rslt = Helper.ResolveParams(req, rslt);
  return rslt;
}