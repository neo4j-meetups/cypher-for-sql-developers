# coding=utf-8

import unicodecsv

with open('data/confederations.csv', "r") as file:
    reader = unicodecsv.reader(file, delimiter=",")
    next(reader)
    for row in reader:
        print "INSERT INTO confederations VALUES('{0}', '{1}', '{2}', '{3}');".format(
            row[0].encode("utf-8"),
            row[1].encode("utf-8").replace("'", "''"),
            row[2].encode("utf-8").replace("'", "''"),
            row[3].encode("utf-8").replace("'", "''"))
