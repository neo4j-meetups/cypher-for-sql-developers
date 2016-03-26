 # coding=utf-8

from bs4 import BeautifulSoup
from soupselect import select

import unicodecsv
import glob

file = "data/associations.html"

print file
page = BeautifulSoup(open(file, 'r').read(), "html.parser")

with open("data/countries.csv", "w") as countries_file:
    writer = unicodecsv.writer(countries_file, delimiter=",")
    writer.writerow(["country","confederation"])

    for row in select(page, "div.ranking-teamlist li"):
        association = row.get("data-confederation")
        country = select(row, "a")[0].text
        writer.writerow([country, association])
