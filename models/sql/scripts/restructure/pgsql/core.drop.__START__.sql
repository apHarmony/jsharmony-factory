SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = {schema}, pg_catalog;

drop view if exists v_doc_ext;
drop view if exists v_doc;
drop view if exists v_doc_filename;
drop view if exists v_note_ext;
drop view if exists v_note;
