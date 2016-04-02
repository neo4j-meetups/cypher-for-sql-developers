 # coding=utf-8

from bs4 import BeautifulSoup
from soupselect import select

import unicodecsv
import glob

countries = {}
country_mappings = {
    "USA": "United States",
    "Korea Republic": "South Korea",
    "Côte d'Ivoire": "Ivory Coast"
}

page = BeautifulSoup(open("data/associations.html", 'r').read(), "html.parser")

for row in select(page, "div.ranking-teamlist li"):
    association = row.get("data-confederation")
    country = select(row, "a")[0].text

    country = country.encode("utf-8")
    if country_mappings.get(country) is not None:
        print country
        country = country_mappings[country]

    countries[country] = (association,)

page = BeautifulSoup(open("data/countryCodes.html", 'r').read(), "html.parser")

for row in select(page, "table table.wikitable tr"):
    columns = select(row, "td")

    if len(columns) > 0:
        country = select(columns[0], "a")[0].text
        code = columns[1].text

        if countries.get(country):
            entry = countries[country]
            if len(entry) == 1:
                countries[country] = (code, entry[0])

country_mappings = {
    "China PR": "China",
    "Republic of Ireland": "Ireland",
    "Congo": "Congo DR",
    "Bosnia and Herzegovina": "Bosnia-Herzegovina",
    "South Korea": "Korea, South",
    "Ivory Coast": "Cote d'Ivoire"
}

with open("data/countries.csv", "w") as countries_file:
    writer = unicodecsv.writer(countries_file, delimiter=",")
    writer.writerow(["countryCode","country","confederation"])

    for key in countries:
        entry = countries[key]

        if country_mappings.get(key) is not None:
            key = country_mappings[key]

        if len(entry) == 2:
            writer.writerow([entry[0],key, entry[1]])

# print countries
