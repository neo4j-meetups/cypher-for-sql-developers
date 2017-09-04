//Index Players
CREATE CONSTRAINT ON (player:Player)
ASSERT player.id IS UNIQUE;

//Index Clubs
CREATE CONSTRAINT ON (club:Club)
ASSERT club.id IS UNIQUE;

// Make sure clubs have a name
CREATE CONSTRAINT ON (club:Club) ASSERT EXISTS(club.name);

//Load Players
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///transfers.csv" AS row
MERGE (player:Player {id: row.playerUri})
SET player.name =  row.playerName, player.position = row.playerPosition;

//Load Clubs (part 1)
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///transfers.csv" AS row
MERGE (club:Club {id: row.sellerClubUri})
ON CREATE SET club.name = row.sellerClubName, club.country = row.sellerClubCountry;

//Load Clubs (part 2)
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///transfers.csv" AS row
MERGE (club:Club {id: row.buyerClubUri})
ON CREATE SET club.name = row.buyerClubName, club.country = row.buyerClubCountry;

CREATE CONSTRAINT ON ()-[player:OF_PLAYER]-()
ASSERT exists(player.age);

//Load Transfers
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///transfers.csv" AS row
MATCH (player:Player {id: row.playerUri})
MATCH (source:Club {id: row.sellerClubUri})
MATCH (destination:Club {id: row.buyerClubUri})
MERGE (t:Transfer {id: row.transferUri})
ON CREATE SET t.season = row.season,
              t.rank = row.transferRank,
              t.fee = row.transferFee
MERGE (t)-[:OF_PLAYER {age : toint(row.playerAge)}]->(player)
MERGE (t)-[:FROM_CLUB]->(source)
MERGE (t)-[:TO_CLUB]->(destination);

// convert numeric transfer fees
MATCH (t:Transfer)
WITH t, replace(replace(replace(replace(t.fee, "k", ""), "m", ""), "Loan fee:", ""), "£", "") AS rawNumeric
WITH t,
CASE
 WHEN t.fee ENDS WITH "k" THEN toFloat(rawNumeric)*1000
 ELSE toFloat(rawNumeric) *1000000
END AS numericFee
SET t.numericFee = numericFee;

//Add year to transfer
MATCH (t:Transfer)
WITH distinct t.season as raw_season, toInt(left(t.season,2)) as date
WITH raw_season, CASE WHEN date>89 THEN date + 1900
 ELSE date + 2000 END AS year
MATCH (t:Transfer) WHERE t.season = raw_season
SET t.year = year;

// // Label loans
MATCH (t:Transfer)
WHERE t.fee STARTS WITH 'Loan'
SET t:Loan;

CREATE INDEX ON :Club(name);
CREATE INDEX ON :Player(name);
