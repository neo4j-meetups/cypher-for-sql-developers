import unicodecsv

with open('data/transfers.csv', "r") as file:
    reader = unicodecsv.reader(file, delimiter=",")
    next(reader)
    for row in reader:
        print "UPDATE players SET nationality='{1}' WHERE players.id = '{0}';".format(
            row[2].encode("utf-8"),
            row[13].encode("utf-8").replace("'", "''"))
