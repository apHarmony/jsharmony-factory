/***************cust_user***************/
create table {schema}_cust_user (
    sys_user_id integer primary key autoincrement NOT NULL,
    cust_id integer NOT NULL,
    sys_user_sts text DEFAULT 'ACTIVE' NOT NULL,
    sys_user_stsdt text,
    sys_user_fname text NOT NULL,
    sys_user_mname text,
    sys_user_lname text NOT NULL,
    sys_user_jobtitle text,
    sys_user_bphone text,
    sys_user_cphone text,
    sys_user_email text NOT NULL,
    sys_user_etstmp text,
    sys_user_euser text,
    sys_user_mtstmp text,
    sys_user_muser text,
    sys_user_pw1 text,
    sys_user_pw2 text,
    sys_user_hash blob DEFAULT X'00' NOT NULL,
    sys_user_lastlogin_ip text,
    sys_user_lastlogin_tstmp text,
    sys_user_snotes text,
    FOREIGN KEY (sys_user_sts) REFERENCES {schema}_code_ahc(code_val),
    CHECK (COALESCE(sys_user_email,'')<>'')
);

create index idx_{schema}_cust_user_cust_id on {schema}_cust_user(cust_id);

/***************cust_role***************/
CREATE TABLE {schema}_cust_role (
  cust_role_id integer primary key autoincrement NOT NULL,
  cust_role_seq integer NOT NULL,
  cust_role_sts text NOT NULL DEFAULT 'ACTIVE',
  cust_role_name text NOT NULL,
  cust_role_desc text NOT NULL,
  cust_role_snotes text,
  cust_role_code text,
  cust_role_attrib text,
  UNIQUE (cust_role_desc),
  UNIQUE (cust_role_name),
  FOREIGN KEY (cust_role_sts) REFERENCES {schema}_code_ahc(code_val)
);

/***************cust_user_role***************/
CREATE TABLE {schema}_cust_user_role (
  cust_user_role_id integer primary key autoincrement NOT NULL,
  sys_user_id integer NOT NULL,
  cust_role_name text NOT NULL,
  cust_user_role_snotes text,
  UNIQUE (sys_user_id, cust_role_name),
  FOREIGN KEY (sys_user_id) REFERENCES {schema}_cust_user(sys_user_id)
              ON UPDATE NO ACTION ON DELETE CASCADE,
  FOREIGN KEY (cust_role_name) REFERENCES {schema}_cust_role(cust_role_name)
              ON UPDATE NO ACTION ON DELETE CASCADE
);

/***************cust_menu_role***************/
CREATE TABLE {schema}_cust_menu_role (
  cust_menu_role_id integer primary key autoincrement NOT NULL,
  menu_id integer NOT NULL,
  cust_role_name text NOT NULL,
  cust_menu_role_snotes text,
  UNIQUE (cust_role_name, menu_id),
  FOREIGN KEY (menu_id) REFERENCES {schema}_menu__tbl(menu_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (cust_role_name) REFERENCES {schema}_cust_role(cust_role_name) ON DELETE CASCADE
);
