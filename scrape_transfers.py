 # coding=utf-8

from bs4 import BeautifulSoup
from soupselect import select

import unicodecsv
import glob

# file = "data/raw/1991-1.html"

with open("data/transfers.csv", "w") as file:
    writer = unicodecsv.writer(file, delimiter=",")

    writer.writerow(["season","playerName","playerUri","sellerClubName","sellerClubNameShort","sellerClubCountry", "sellerClubUri",
        "buyerClubName","buyerClubNameShort","buyerClubCountry", "buyerClubUri", "playerPosition","playerAge", "playerNationality",
        "transferFee","transferRank", "transferUri"])

    for file in glob.glob("data/raw/*.html"):
        print file
        page = BeautifulSoup(open(file, 'r').read(), "html.parser")
        for entry in select(page, "div#yw1 table.items tbody tr"):
            columns = select(entry, "td")
            if len(columns) == 18:
                transferRank = columns[0].text
                link = select(columns[1], "a")[0]
                playerUri = link["href"]
                playerName = link.text
                playerPosition = select(columns[1], "table.inline-table tr td")[2].text
                playerAge = columns[5].text
                playerNationality = select(columns[8], "img")[0]["title"]

                sellerColumn = columns[11]
                sellerClubUri = select(sellerColumn, "a")[0]["href"]
                sellerClubName = select(columns[10], "img")[0]["alt"]
                sellerClubShortName = select(sellerColumn, "a")[0].text

                if len(select(columns[12], "img")) > 0 :
                    sellerClubCountry = select(columns[12], "img")[0]["title"]
                else:
                    sellerClubCountry = ""
                # sellerClubLeague = select(columns[12], "a")[0].text

                buyerColumn = columns[13]
                buyerClubUri = select(buyerColumn, "a")[1]["href"]
                buyerClubName = select(columns[14], "img")[0]["alt"]
                buyerClubShortName = select(buyerColumn, "a")[1].text
                buyerClubCountry = select(columns[16], "img")[0]["title"]

                transferFeeText = columns[17].text
                transferUri = select(columns[17], "a")[0]["href"]
                season = select(columns[7], "a")[0].text

                row = [
                    season, playerName.encode("utf-8"), playerUri, sellerClubName.encode("utf-8"), sellerClubShortName.encode("utf-8"),
                    sellerClubCountry, sellerClubUri, buyerClubName.encode("utf-8"), buyerClubShortName.encode("utf-8"), buyerClubCountry,
                    buyerClubUri, playerPosition, playerAge, playerNationality, transferFeeText, transferRank, transferUri
                    ]

                print row

                writer.writerow(row)
