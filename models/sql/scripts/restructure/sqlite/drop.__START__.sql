/***************TABLE TRIGGERS***************/

drop trigger if exists jsharmony_cper_insert;
drop trigger if exists jsharmony_cper_update;
drop trigger if exists jsharmony_cper_delete;

drop trigger if exists jsharmony_d_before_insert;
drop trigger if exists jsharmony_d_after_insert;
drop trigger if exists jsharmony_d_before_update;
drop trigger if exists jsharmony_d_after_update;
drop trigger if exists jsharmony_d_delete;

drop trigger if exists jsharmony_n_before_insert;
drop trigger if exists jsharmony_n_after_insert;
drop trigger if exists jsharmony_n_before_update;
drop trigger if exists jsharmony_n_after_update;
drop trigger if exists jsharmony_n_delete;

drop trigger if exists jsharmony_pe_before_insert;
drop trigger if exists jsharmony_pe_after_insert;
drop trigger if exists jsharmony_pe_before_update;
drop trigger if exists jsharmony_pe_after_update;
drop trigger if exists jsharmony_pe_delete;

drop trigger if exists jsharmony_cpe_before_insert;
drop trigger if exists jsharmony_cpe_after_insert;
drop trigger if exists jsharmony_cpe_before_update;
drop trigger if exists jsharmony_cpe_after_update;
drop trigger if exists jsharmony_cpe_delete;

drop trigger if exists jsharmony_gpp_before_insert;
drop trigger if exists jsharmony_gpp_after_insert;
drop trigger if exists jsharmony_gpp_before_update;
drop trigger if exists jsharmony_gpp_after_update;
drop trigger if exists jsharmony_gpp_delete;

drop trigger if exists jsharmony_xpp_before_insert;
drop trigger if exists jsharmony_xpp_after_insert;
drop trigger if exists jsharmony_xpp_before_update;
drop trigger if exists jsharmony_xpp_after_update;
drop trigger if exists jsharmony_xpp_delete;

drop trigger if exists jsharmony_ppp_before_insert;
drop trigger if exists jsharmony_ppp_after_insert;
drop trigger if exists jsharmony_ppp_before_update;
drop trigger if exists jsharmony_ppp_after_update;
drop trigger if exists jsharmony_ppp_delete;

drop trigger if exists jsharmony_ppd_after_insert;
drop trigger if exists jsharmony_ppd_before_update;
drop trigger if exists jsharmony_ppd_after_update;
drop trigger if exists jsharmony_ppd_delete;

drop trigger if exists jsharmony_h_after_insert;
drop trigger if exists jsharmony_h_before_update;
drop trigger if exists jsharmony_h_after_update;
drop trigger if exists jsharmony_h_delete;

drop trigger if exists jsharmony_spef_after_insert;
drop trigger if exists jsharmony_spef_before_update;
drop trigger if exists jsharmony_spef_after_update;
drop trigger if exists jsharmony_spef_delete;

drop trigger if exists jsharmony_sper_before_insert;
drop trigger if exists jsharmony_sper_after_insert;
drop trigger if exists jsharmony_sper_before_update;
drop trigger if exists jsharmony_sper_after_update;
drop trigger if exists jsharmony_sper_delete;

drop trigger if exists jsharmony_txt_after_insert;
drop trigger if exists jsharmony_txt_before_update;
drop trigger if exists jsharmony_txt_after_update;
drop trigger if exists jsharmony_txt_delete;

drop trigger if exists jsharmony_rq_after_insert;

drop trigger if exists jsharmony_rqst_after_insert;

drop trigger if exists jsharmony_gcod_h_after_insert;
drop trigger if exists jsharmony_gcod_h_after_update;

drop trigger if exists jsharmony_gcod2_h_after_insert;
drop trigger if exists jsharmony_gcod2_h_after_update;

drop trigger if exists jsharmony_ucod_h_after_insert;
drop trigger if exists jsharmony_ucod_h_after_update;

drop trigger if exists jsharmony_ucod2_h_after_insert;
drop trigger if exists jsharmony_ucod2_h_after_update;

drop trigger if exists jsharmony_v_after_insert;
drop trigger if exists jsharmony_v_after_update;

/***************VIEWS***************/
drop view if exists jsharmony_v_pp;
drop view if exists jsharmony_v_house;
drop view if exists jsharmony_ucod2_gpp_process_attrib_v;
drop view if exists jsharmony_ucod2_ppp_process_attrib_v;
drop view if exists jsharmony_ucod2_xpp_process_attrib_v;
drop view if exists jsharmony_ucod_gpp_process_v;
drop view if exists jsharmony_ucod_ppp_process_v;
drop view if exists jsharmony_ucod_xpp_process_v;
drop view if exists jsharmony_v_audl_raw;
drop view if exists jsharmony_v_cper_nostar;
drop view if exists jsharmony_v_crmsel;
drop view if exists jsharmony_v_dl;
drop view if exists jsharmony_v_d_ext;
drop view if exists jsharmony_v_d_x;
drop view if exists jsharmony_v_gppl;
drop view if exists jsharmony_v_months;
drop view if exists jsharmony_v_mype;
drop view if exists jsharmony_v_my_roles;
drop view if exists jsharmony_v_nl;
drop view if exists jsharmony_v_n_ext;
drop view if exists jsharmony_v_ppdl;
drop view if exists jsharmony_v_pppl;
drop view if exists jsharmony_v_srmsel;
drop view if exists jsharmony_v_xppl;
drop view if exists jsharmony_v_years;
