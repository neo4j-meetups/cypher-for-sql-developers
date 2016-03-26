import unicodecsv

clubs = {}
with open('data/transfers.csv', "r") as file:
    reader = unicodecsv.reader(file, delimiter=",")
    next(reader)
    for row in reader:
        clubs[row[6]] = (row[3], row[5])
        clubs[row[10]] = (row[7], row[9])

for club in clubs:
    entry = clubs[club]
    print "INSERT INTO clubs VALUES('{0}', '{1}', '{2}');".format(
        club.encode("utf-8"),
        entry[0].encode("utf-8").replace("'", "''"),
        entry[1].encode("utf-8").replace("'", "''")
    )
