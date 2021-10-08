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

exports = module.exports = function(module){

  var _transform = function(elem){
    if(!module || !module.transform || !module.transform.mapping) return elem;
    return module.transform.mapping[elem];
  }

  var generateMenu = function(type, req, res, jsh, params, onComplete) {
    var static_menu = _.extend({ main_menu: [], sub_menu: [] }, (module && module.Config) ? module.Config.static_menu : {} );

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
    jsh.AppSrv.ExecMultiRecordset(req._DBContext, menusql, [dbtypes.BigInt, dbtypes.VarChar(255)], sqlparams, function (err, rslt) {
      if(err){ return Helper.GenError(req, res, -99999, "An unexpected database error has occurred: "+err.toString()); }

      var xmenu = {};
      xmenu.MainMenu = [];
      xmenu.SubMenus = {};
      if ((rslt != null) && (rslt.length == 1) && (rslt[0] != null) && (rslt[0].length == 2)) {
        var main_menu = rslt[0][0];
        var sub_menu = rslt[0][1];

        var key_menu_id = _transform('menu_id');
        var key_menu_parent_name = _transform('menu_parent_name');
        var key_menu_seq = _transform('menu_seq');
        var key_menu_name = _transform('menu_name');
        var key_menu_cmd = _transform('menu_cmd');

        //Merge Database Menu with Static Menu
        function merge_menu(menu_items, static_menu_items){
          var menu_ids = _.reduce(menu_items, function(rslt, menu_item, key){ rslt[(menu_item[key_menu_id]||'').toString()] = true; return rslt; }, {});
          _.each(static_menu_items, function(menu_item){
            var menu_id = (menu_item[key_menu_id]||'').toString();
            //If menu item is not in the menu
            if(!(menu_id in menu_ids)){
              //Check if user has access to role
              var has_access = false;
              if(req._roles && ('roles' in menu_item)){
                var roles = menu_item.roles;
                if((req.jshsite.id in roles) && !_.isString(roles[req.jshsite.id])) roles = roles[req.jshsite.id];
                else if(req.jshsite.id != 'main') roles = [];
                if(_.isArray(roles)){
                  for(var i=0;i<roles.length;i++){ if(roles[i] in req._roles) has_access = true; break; }
                }
              }
              if(has_access) menu_items.push(menu_item);
            }
          });
        }
        merge_menu(main_menu, static_menu.main_menu);
        merge_menu(sub_menu, static_menu.sub_menu);

        //Add menu seq, if not defined
        function add_menu_seq(menu_items){
          _.each(menu_items, function(menu_item){
            var menu_seq = menu_item[key_menu_seq];
            if(!menu_seq && ((typeof menu_seq == 'undefined') || (menu_seq === null))) menu_item[key_menu_seq] = menu_item[key_menu_id];
          });
        }
        add_menu_seq(main_menu);
        add_menu_seq(sub_menu);

        //Sort Menus
        function sort_cmp(a,b){
          if(a<b) return -1;
          else if(a>b) return 1;
          return 0;
        }

        main_menu.sort(function(a,b){
          var rslt = 0;
          rslt = sort_cmp(a[key_menu_seq], b[key_menu_seq]);  if(rslt) return rslt;
          rslt = sort_cmp(a[key_menu_name], b[key_menu_name]);  if(rslt) return rslt;
          rslt = sort_cmp(a[menu_id], b[menu_id]);  if(rslt) return rslt;
          return 0;
        });
        
        sub_menu.sort(function(a,b){
          var rslt = 0;
          rslt = sort_cmp(a[key_menu_parent_name], b[key_menu_parent_name]);  if(rslt) return rslt;
          rslt = sort_cmp(a[key_menu_seq], b[key_menu_seq]);  if(rslt) return rslt;
          rslt = sort_cmp(a[key_menu_name], b[key_menu_name]);  if(rslt) return rslt;
          rslt = sort_cmp(a[menu_id], b[menu_id]);  if(rslt) return rslt;
          return 0;
        });

        //Generate the Main Menu
        _.each(main_menu, function (menuitem) {

          //If menu_cmd is blank, get first child
          if(!menuitem[key_menu_cmd]){
            for(var i=0;i<sub_menu.length;i++){
              if((sub_menu[i][key_menu_parent_name]||'').toUpperCase()==(menuitem[key_menu_name]||'').toUpperCase()){
                menuitem[key_menu_cmd] = sub_menu[i][key_menu_cmd];
                break;
              }
            }
          }
          
          //Generate Link + Onclick Event
          var link_url = generateLink(req, jsh, menuitem);
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
        _.each(sub_menu, function (menuitem) {

          //Create a new submenu for each Parent ID
          if(!menuitem[jsh.map.menu_parentname]) return;
          if(menuitem[jsh.map.menu_parentname].toString().toUpperCase() !== last_parentname) {
            if (cur_sub_menu.length > 0) xmenu.SubMenus[last_parentname] = cur_sub_menu;
            cur_sub_menu = [];
            last_parentname = menuitem[jsh.map.menu_parentname].toString().toUpperCase();
            cur_parent = _.find(xmenu.MainMenu,function(menuitem){ return menuitem.ID==last_parentname; });
          }

          //Generate Link + Onclick Event
          var link_url = generateLink(req, jsh, menuitem);
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
      else {
        return Helper.GenError(req, res, -99999, "An unexpected database error has occurred: Menu SQL must return two recordsets - menu and submenu");
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
  };

  function generateLink(req, jsh, menuitem){
    var rslt = (menuitem[jsh.map.menu_command]||'').toString();
    var cmdLowerCase = rslt.toLowerCase();
    if(!rslt || (!Helper.beginsWith(cmdLowerCase, '/') && !Helper.beginsWith(cmdLowerCase, 'http://') && !Helper.beginsWith(cmdLowerCase, 'https://'))){
      rslt = req.baseurl + rslt;
    }
    if (menuitem[jsh.map.menu_subcommand]) rslt += menuitem[jsh.map.menu_subcommand];
    rslt = Helper.ResolveParams(req, rslt);
    return rslt;
  }

  return generateMenu;
}