import unicodecsv

with open('data/transfers.csv', "r") as file:
    reader = unicodecsv.reader(file, delimiter=",")
    next(reader)
    for row in reader:
        print "INSERT INTO players VALUES('{0}', '{1}', '{2}');".format(
            row[2].encode("utf-8"),
            row[1].encode("utf-8").replace("'", "''"),
            row[11].encode("utf-8"))
