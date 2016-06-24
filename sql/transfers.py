# coding=utf-8

import unicodecsv

with open('data/transfers.csv', "r") as file:
    reader = unicodecsv.reader(file, delimiter=",")
    next(reader)
    for row in reader:
        if row[14] == "End of loan":
            continue

        fee = row[14].encode("utf-8")
        rawNumeric = fee.replace("k", "").replace("m", "").replace("Loan fee:", "").replace("£", "")
        numericFee = float(rawNumeric) * 1000 if fee.endswith("k") else float(rawNumeric) * 1000000

        # print "INSERT INTO transfers VALUES('{0}', '{1}', {2}, '{3}', {4}, '{5}', '{6}', '{7}');".format(
        #     row[16].encode("utf-8"),
        #     fee,
        #     int(numericFee),
        #     row[0],
        #     row[12],
        #     row[2],
        #     row[6],
        #     row[10])

        print "UPDATE transfers SET season = '{0}' WHERE id = '{1}';".format(row[0], row[16].encode("utf-8"))
