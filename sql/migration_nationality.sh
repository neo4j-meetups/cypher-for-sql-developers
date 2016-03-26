#!/bin/bash

cat << EndOfMessage
ALTER TABLE players
ADD COLUMN nationality varying(30);

EndOfMessage

# Need to add this script
python sql/players_add_nationality.py
