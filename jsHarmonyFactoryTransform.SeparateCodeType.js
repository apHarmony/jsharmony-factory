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

var transform = { }

transform.tables = {
  "code_app": "code_app", //"code"
  "code_sys": "code_sys", //"code"
  "code_app_": "code_app_", //"code_"
  "code_sys_": "code_sys_", //"code_"
  "code_app_base": "code_app_base", //"code_base"
  "code_sys_base": "code_sys_base", //"code_base"
  "code_app_prefix": "code_app", //"code"
  "code_sys_prefix": "code_sys", //"code"
  "code_ac": "code_sys_ac", //"code_ac"
  "code_ac1": "code_sys_ac1", //"code_ac1"
  "code_ahc": "code_sys_ahc", //"code_ahc"
  "code_country": "code_sys_country", //"code_country"
  "code_doc_scope": "code_sys_doc_scope", //"code_doc_scope"
  "code2_app": "code2_app", //"code2"
  "code2_sys": "code2_sys", //"code2"
  "code2_app_": "code2_app_", //"code2_"
  "code2_sys_": "code2_sys_", //"code2_"
  "code2_app_base": "code2_app_base", //"code2_base"
  "code2_sys_base": "code2_sys_base", //"code2_base"
  "code2_app_prefix": "code2_app", //"code2"
  "code2_sys_prefix": "code2_sys", //"code2"
  "code2_doc_scope_doc_ctgr": "code2_app_doc_scope_doc_ctgr", //"code2_doc_scope_doc_ctgr"
  "code2_country_state": "code2_sys_country_state", //"code2_country_state"
  "code_note_scope": "code_sys_note_scope", //"code_note_scope"
  "code_note_type": "code_sys_note_type", //"code_note_type"
  "code_param_type": "code_sys_param_type", //"code_param_type"
  "code_job_action": "code_sys_job_action", //"code_job_action"
  "code_job_source": "code_sys_job_source", //"code_job_source"
  "code_txt_type": "code_sys_txt_type", //"code_txt_type"
  "code_version_sts": "code_sys_version_sts", //"code_version_sts"
};

transform.fields = {
  "code_app_h_id": "code_app_h_id",
  "code_app_id": "code_app_id",
  "code2_app_h_id": "code2_app_h_id",
  "code2_app_id": "code2_app_id",
  "code_sys_h_id": "code_sys_h_id",
  "code_sys_id": "code_sys_id",
  "code2_sys_h_id": "code2_sys_h_id",
  "code2_sys_id": "code2_sys_id",
};

transform.models = {
  "Admin/Code2Value_App_Listing": "Admin/Code2Value_App_Listing",
  "Admin/Code2_App_Listing": "Admin/Code2_App_Listing",
  "Admin/CodeValue_App_Listing": "Admin/CodeValue_App_Listing",
  "Admin/Code_App_Listing": "Admin/Code_App_Listing",
  "Dev/CreateCode_App": "Dev/CreateCode_App",
  "Dev/CreateCode2_App": "Dev/CreateCode2_App",
  "Dev/CreateCode_Base": "Dev/CreateCode_Base",
  "Dev/CreateCode_Sys": "Dev/CreateCode_Sys",
  "Dev/CreateCode2_Sys": "Dev/CreateCode2_Sys",
  "Dev/Code2Value_Sys_Listing": "Dev/Code2Value_Sys_Listing",
  "Dev/Code2_Sys_Listing_Browse": "Dev/Code2_Sys_Listing_Browse",
  "Dev/CodeValue_Sys_Listing": "Dev/CodeValue_Sys_Listing",
  "Dev/Code_Sys_Listing_Browse": "Dev/Code_Sys_Listing_Browse",
  "Dev/Code2Value_App_Listing": "Dev/Code2Value_App_Listing",
  "Dev/Code2_App_Listing": "Dev/Code2_App_Listing",
  "Dev/CodeValue_App_Listing": "Dev/CodeValue_App_Listing",
  "Dev/Code_App_Listing": "Dev/Code_App_Listing",
  "Dev/Code2_Sys_Listing": "Dev/Code2_Sys_Listing",
  "Dev/Code_Sys_Listing": "Dev/Code_Sys_Listing",
};

transform.sql = {
  "create_code_app": "create_code_app",
  "create_code2_app": "create_code2_app",
  "create_code_sys": "create_code_sys",
  "create_code2_sys": "create_code2_sys",
  "code_sys_cust_sts": "code_sys_cust_sts", //"code_cust_sts"
  "separate_code_type_tables": "1",
}

transform.ignore_errors = {
  value: { 'n': true }
};

exports = module.exports = transform;