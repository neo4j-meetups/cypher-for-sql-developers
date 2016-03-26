#!/usr/bin/env bash

for year in {1990..2016}
do
  echo ${year}
  for page in {1..10}
  do
#

    # wget "http://www.transfermarkt.co.uk/transfers/transferrekorde/statistik/top/saison_id/${year}/land_id//ausrichtung//spielerposition_id//altersklasse//leihe//w_s//plus//page/${page}" -O data/raw/${year}-${page}.html

    wget "http://www.transfermarkt.co.uk/transfers/transferrekorde/statistik?saison_id=${year}&land_id=0&ausrichtung=&spielerposition_id=&altersklasse=&leihe=&w_s=&plus=1&page=${page}" -O data/raw/${year}-${page}.html
  done
done
