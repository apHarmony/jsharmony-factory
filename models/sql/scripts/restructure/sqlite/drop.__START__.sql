/***************TABLE TRIGGERS***************/

drop trigger if exists {{schema}}_cper_insert;
drop trigger if exists {{schema}}_cper_update;
drop trigger if exists {{schema}}_cper_delete;

drop trigger if exists {{schema}}_d_before_insert;
drop trigger if exists {{schema}}_d_after_insert;
drop trigger if exists {{schema}}_d_before_update;
drop trigger if exists {{schema}}_d_after_update;
drop trigger if exists {{schema}}_d_delete;

drop trigger if exists {{schema}}_n_before_insert;
drop trigger if exists {{schema}}_n_after_insert;
drop trigger if exists {{schema}}_n_before_update;
drop trigger if exists {{schema}}_n_after_update;
drop trigger if exists {{schema}}_n_delete;

drop trigger if exists {{schema}}_pe_before_insert;
drop trigger if exists {{schema}}_pe_after_insert;
drop trigger if exists {{schema}}_pe_before_update;
drop trigger if exists {{schema}}_pe_after_update;
drop trigger if exists {{schema}}_pe_delete;

drop trigger if exists {{schema}}_cpe_before_insert;
drop trigger if exists {{schema}}_cpe_after_insert;
drop trigger if exists {{schema}}_cpe_before_update;
drop trigger if exists {{schema}}_cpe_after_update;
drop trigger if exists {{schema}}_cpe_delete;

drop trigger if exists {{schema}}_gpp_before_insert;
drop trigger if exists {{schema}}_gpp_after_insert;
drop trigger if exists {{schema}}_gpp_before_update;
drop trigger if exists {{schema}}_gpp_after_update;
drop trigger if exists {{schema}}_gpp_delete;

drop trigger if exists {{schema}}_xpp_before_insert;
drop trigger if exists {{schema}}_xpp_after_insert;
drop trigger if exists {{schema}}_xpp_before_update;
drop trigger if exists {{schema}}_xpp_after_update;
drop trigger if exists {{schema}}_xpp_delete;

drop trigger if exists {{schema}}_ppp_before_insert;
drop trigger if exists {{schema}}_ppp_after_insert;
drop trigger if exists {{schema}}_ppp_before_update;
drop trigger if exists {{schema}}_ppp_after_update;
drop trigger if exists {{schema}}_ppp_delete;

drop trigger if exists {{schema}}_ppd_after_insert;
drop trigger if exists {{schema}}_ppd_before_update;
drop trigger if exists {{schema}}_ppd_after_update;
drop trigger if exists {{schema}}_ppd_delete;

drop trigger if exists {{schema}}_h_after_insert;
drop trigger if exists {{schema}}_h_before_update;
drop trigger if exists {{schema}}_h_after_update;
drop trigger if exists {{schema}}_h_delete;

drop trigger if exists {{schema}}_spef_after_insert;
drop trigger if exists {{schema}}_spef_before_update;
drop trigger if exists {{schema}}_spef_after_update;
drop trigger if exists {{schema}}_spef_delete;

drop trigger if exists {{schema}}_sper_before_insert;
drop trigger if exists {{schema}}_sper_after_insert;
drop trigger if exists {{schema}}_sper_before_update;
drop trigger if exists {{schema}}_sper_after_update;
drop trigger if exists {{schema}}_sper_delete;

drop trigger if exists {{schema}}_txt_after_insert;
drop trigger if exists {{schema}}_txt_before_update;
drop trigger if exists {{schema}}_txt_after_update;
drop trigger if exists {{schema}}_txt_delete;

drop trigger if exists {{schema}}_rq_after_insert;

drop trigger if exists {{schema}}_rqst_after_insert;

drop trigger if exists {{schema}}_gcod_h_after_insert;
drop trigger if exists {{schema}}_gcod_h_after_update;

drop trigger if exists {{schema}}_gcod2_h_after_insert;
drop trigger if exists {{schema}}_gcod2_h_after_update;

drop trigger if exists {{schema}}_ucod_h_after_insert;
drop trigger if exists {{schema}}_ucod_h_after_update;

drop trigger if exists {{schema}}_ucod2_h_after_insert;
drop trigger if exists {{schema}}_ucod2_h_after_update;

drop trigger if exists {{schema}}_v_after_insert;
drop trigger if exists {{schema}}_v_after_update;

/***************VIEWS***************/
drop view if exists {{schema}}_v_pp;
drop view if exists {{schema}}_v_house;
drop view if exists {{schema}}_ucod2_gpp_process_attrib_v;
drop view if exists {{schema}}_ucod2_ppp_process_attrib_v;
drop view if exists {{schema}}_ucod2_xpp_process_attrib_v;
drop view if exists {{schema}}_ucod_gpp_process_v;
drop view if exists {{schema}}_ucod_ppp_process_v;
drop view if exists {{schema}}_ucod_xpp_process_v;
drop view if exists {{schema}}_v_audl_raw;
drop view if exists {{schema}}_v_cper_nostar;
drop view if exists {{schema}}_v_crmsel;
drop view if exists {{schema}}_v_dl;
drop view if exists {{schema}}_v_d_ext;
drop view if exists {{schema}}_v_d_x;
drop view if exists {{schema}}_v_gppl;
drop view if exists {{schema}}_v_months;
drop view if exists {{schema}}_v_mype;
drop view if exists {{schema}}_v_my_roles;
drop view if exists {{schema}}_v_nl;
drop view if exists {{schema}}_v_n_ext;
drop view if exists {{schema}}_v_ppdl;
drop view if exists {{schema}}_v_pppl;
drop view if exists {{schema}}_v_srmsel;
drop view if exists {{schema}}_v_xppl;
drop view if exists {{schema}}_v_years;
