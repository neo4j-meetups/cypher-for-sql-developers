SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';

SET search_path = public, pg_catalog;
SET default_tablespace = '';
SET default_with_oids = false;

CREATE TABLE players (
    "id" character varying(100) NOT NULL,
    "name" character varying(150) NOT NULL,
    "position" character varying(20)
);

CREATE TABLE clubs (
    "id" character varying(100) NOT NULL,
    "name" character varying(50) NOT NULL,
    "country" character varying(50)
);

CREATE TABLE transfers (
    "id" character varying(100) NOT NULL,
    "fee" character varying(50) NOT NULL,
    "numericFee" integer NOT NULL,
    "player_age" smallint NOT NULL,
    "season" character varying(5) NOT NULL,
    "player_id" character varying(100) NOT NULL REFERENCES players (id),
    "from_club_id" character varying(100) NOT NULL REFERENCES clubs (id),
    "to_club_id" character varying(100) NOT NULL REFERENCES clubs (id)
);
