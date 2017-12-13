pragma foreign_keys = ON;

begin;

/*********UCOD_COUNTRY*********/
%%%create_ucod("country","jsharmony_")%%%
insert into jsharmony_ucod_country(codeval,codetxt) values ('USA','United States');
insert into jsharmony_ucod_country(codeval,codetxt) values ('CANADA','Canada');
insert into jsharmony_ucod_country(codeval,codetxt) values ('MEXICO','Mexico');


/*********UCOD2_COUNTRY_STATE*********/
%%%create_ucod2("country_state","jsharmony_")%%%
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('CANADA','AB','Alberta');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('CANADA','BC','British Columbia');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('CANADA','MB','Manitoba');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('CANADA','NB','New Brunswick');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('CANADA','NL','Newfoundland and Labrador');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('CANADA','NS','Nova Scotia');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('CANADA','NT','Northwest Territories');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('CANADA','NU','Nunavut');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('CANADA','ON','Ontario');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('CANADA','PE','Prince Edward Island');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('CANADA','QC','Quebec');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('CANADA','SK','Saskatchewan');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('CANADA','YT','Yukon');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','AG','Aguascalientes');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','BN','Baja California');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','BS','Baja California Sur');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','CA','Coahuila');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','CH','Chihuahua');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','CL','Colima');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','CM','Compeche');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','CP','Chiapas');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','DF','Federal District');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','DU','Durango');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','GR','Guerrero');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','GT','Guanajuato');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','HI','Hidalgo');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','JA','Jalisco');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','MC','Michoacan');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','MR','Morelos');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','MX','Mexico');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','NA','Nayarit');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','NL','Nuevo Leon');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','OA','Oaxaca');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','PU','Puebla');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','QE','Queretaro');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','QR','Quintana Roo');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','SI','Sinaloa');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','SL','San Luis Potosí');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','SO','Sonora');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','TB','Tabasco');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','TL','Tlaxcala');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','TM','Tamaulipas');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','VE','Veracruz');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','YU','Yucatán');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('MEXICO','ZA','Zacatecas');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','AK','Alaska');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','AL','Alabama');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','AR','Arkansas');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','AS','American Samoa');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','AZ','Arizona');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','CA','California');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','CO','Colorado');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','CT','Connecticut');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','DC','District of Columbia');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','DE','Delaware');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','FL','Florida');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','FM','Federated States of Micronesia');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','GA','Georgia');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','GU','Guam');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','HI','Hawaii');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','IA','Iowa');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','ID','Idaho');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','IL','Illinois');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','IN','Indiana');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','KS','Kansas');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','KY','Kentucky');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','LA','Louisiana');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','MA','Massachusetts');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','MD','Maryland');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','ME','Maine');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','MH','Marshall Islands');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','MI','Michigan');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','MN','Minnesota');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','MO','Missouri');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','MP','Northern Mariana Islands');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','MS','Mississippi');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','MT','Montana');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','NC','North Carolina');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','ND','North Dakota');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','NE','Nebraska');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','NH','New Hampshire');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','NJ','New Jersey');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','NM','New Mexico');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','NV','Nevada');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','NY','New York');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','OH','Ohio');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','OK','Oklahoma');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','OR','Oregon');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','PA','Pennsylvania');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','PR','Puerto Rico');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','PW','Palau');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','RI','Rhode Island');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','SC','South Carolina');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','SD','South Dakota');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','TN','Tennessee');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','TX','Texas');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','UT','Utah');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','VA','Virginia');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','VI','Virgin Islands');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','VT','Vermont');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','WA','Washington');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','WI','Wisconsin');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','WV','West Virginia');
insert into jsharmony_ucod2_country_state(codeval1,codeval2,codetxt) values ('USA','WY','Wyoming');

/***************PE***************/
create table jsharmony_pe (
    pe_id integer primary key autoincrement NOT NULL,
    pe_sts text DEFAULT 'ACTIVE' NOT NULL,
    pe_stsdt text,
    pe_fname text NOT NULL,
    pe_mname text,
    pe_lname text NOT NULL,
    pe_jtitle text,
    pe_bphone text,
    pe_cphone text,
    pe_country text DEFAULT 'USA' NOT NULL,
    pe_addr text,
    pe_city text,
    pe_state text,
    pe_zip text,
    pe_email text NOT NULL,
    pe_startdt text,
    pe_enddt date,
    pe_unotes text,
    pe_etstmp text,
    pe_eu text,
    pe_mtstmp text,
    pe_mu text,
    pe_pw1 text,
    pe_pw2 text,
    pe_hash blob DEFAULT X'00' NOT NULL,
    pe_ll_ip text,
    pe_ll_tstmp text,
    pe_snotes text
);

create trigger insert_jsharmony_pe after insert on jsharmony_pe
begin
  update jsharmony_pe set 
    pe_startdt = ifnull(NEW.pe_startdt,date('now','localtime')),
    pe_stsdt  = datetime('now','localtime'),
    pe_eu     = (select context from jsharmony_meta limit 1),
    pe_etstmp = datetime('now','localtime'),
    pe_mu     = (select context from jsharmony_meta limit 1),
    pe_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;
end;

create trigger update_jsharmony_pe after update on jsharmony_pe
begin
  select case when NEW.pe_stsdt is null then raise(FAIL,'pe_stsdt cannot be null') end\;
  select case when NEW.pe_id <> OLD.pe_id then raise(FAIL,'Cannot update identity') end\;
  --jsharmony_d exists error
  --passwords different error
  --passwords >= 6 characters error
  --generate password hash

  update jsharmony_pe set
    pe_stsdt  = case when NEW.pe_sts<>OLD.pe_sts then datetime('now','localtime') else NEW.pe_stsdt end,
    pe_mu     = (select context from jsharmony_meta limit 1),
    pe_mtstmp = datetime('now','localtime')
    where rowid = new.rowid\;
end;

insert into jsharmony_pe (pe_fname,pe_lname,pe_email,pe_pw1,pe_pw2)
  values ('First','User','%%%INIT_DB_ADMIN_EMAIL%%%','%%%INIT_DB_ADMIN_PASS%%%','%%%INIT_DB_ADMIN_PASS%%%');

select * from jsharmony_pe;

end;