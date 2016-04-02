#!/bin/bash

# Create countries table
# Script to migrate country out of players table and clubs table and replace with foreign key/primary key

cat << EndOfMessage
CREATE TABLE confederations (
    "id" character varying(10) NOT NULL PRIMARY KEY,
    "shortName" character varying(50) NOT NULL,
    "name" character varying(100) NOT NULL,
    "region" character varying(100) NOT NULL
);
EndOfMessage

cat << EndOfMessage
ALTER TABLE ONLY confederations
ADD CONSTRAINT pk_confederations PRIMARY KEY ("id");
EndOfMessage

python sql/add_confederations.py

cat << EndOfMessage
CREATE TABLE countries (
    "code" character varying(3) NOT NULL PRIMARY KEY,
    "name" character varying(50) NOT NULL,
    "federation" character varying(10) NOT NULL REFERENCES confederations (id)
);
EndOfMessage

cat << EndOfMessage
ALTER TABLE ONLY countries
ADD CONSTRAINT pk_countries PRIMARY KEY ("code");
EndOfMessage

python sql/add_countries.py

cat << EndOfMessage
ALTER TABLE players
ADD COLUMN country_id character varying(3);
EndOfMessage

cat << EndOfMessage
UPDATE players AS p
SET country_id = c.code
FROM players
INNER JOIN countries AS c ON c.name = players.nationality
WHERE p.id = players.id
EndOfMessage

cat << EndOfMessage
ALTER TABLE players
ADD CONSTRAINT playersfk FOREIGN KEY (country_id) REFERENCES countries (code) MATCH FULL;
EndOfMessage

cat << EndOfMessage
ALTER TABLE players
DROP COLUMN nationality;
EndOfMessage

cat << EndOfMessage
ALTER TABLE clubs
ADD COLUMN country_id character varying(3);
EndOfMessage

cat << EndOfMessage
UPDATE clubs AS cl
SET country_id = c.code
FROM clubs
INNER JOIN countries AS c ON c.name = clubs.country
WHERE cl.id = clubs.id

EndOfMessage

cat << EndOfMessage
UPDATE clubs SET country_id = 'FRA' WHERE country = 'Monaco';
EndOfMessage
