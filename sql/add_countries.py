# coding=utf-8

import unicodecsv

with open("data/countries.csv", "r") as file:
    reader = unicodecsv.reader(file, delimiter=",")
    next(reader)

    for row in reader:
        country = row[0].encode("utf-8").replace("'", "''")
        confederation = row[1]

        print "INSERT INTO countries VALUES('{0}', '{1}', '{2}');".format(
            row[0].encode("utf-8"),
            row[1].encode("utf-8").replace("'", "''"),
            row[2].encode("utf-8"))
