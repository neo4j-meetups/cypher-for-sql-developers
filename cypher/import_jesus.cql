//Index Players
CREATE INDEX ON :Player(player_uri);

//Index Clubs
CREATE INDEX ON :Club(club_name);

//Load Players
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///all_transfers.csv" AS row
MERGE (player:Player {player_uri: row.playerUri})
SET player.player_name =  row.playerName, player.player_position = row.playerPosition;

//Load Clubs (part 1)
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///all_transfers.csv" AS row
MERGE (:Club {club_name: row.sellerClubName, club_country: row.sellerClubCountry});

//Load Clubs (part 2)
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///all_transfers.csv" AS row
MERGE (:Club {club_name: row.buyerClubName, club_country: row.buyerClubCountry});

//Load Transfers
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///all_transfers.csv" AS row
MATCH (player:Player {player_uri: row.playerUri})
MATCH (source:Club {club_name: row.sellerClubName, club_country: row.sellerClubCountry})
MATCH (destination:Club {club_name: row.buyerClubName, club_country: row.buyerClubCountry})
CREATE (t:Transfer {transfer_season: row.season, transfer_player_age: row.playerAge, transfer_rank: row.transferRank, transfer_fee_text: row.transferFeeText, transfer_fee_num: row.transferFeeNum})
CREATE (t)-[:OF_PLAYER]->(player), (t)-[:FROM_CLUB]->(source), (t)-[:TO_CLUB]->(destination);

// convert numeric transfer fees
MATCH (t:Transfer)
WITH t,
CASE
 WHEN t.transfer_fee_text =~ ".*Th.*" THEN toInt(t.transfer_fee_num)*1000
 WHEN t.transfer_fee_text =~ ".*,.*" THEN toInt(replace(t.transfer_fee_num,',',''))*10000
 ELSE toInt(t.transfer_fee_num)*1000000
END AS numeric_fee
SET t.transfer_fee = numeric_fee;

//Add year to transfer
MATCH (t:Transfer)
WITH distinct t.transfer_season as raw_season, toInt(left(t.transfer_season,2)) as date
WITH raw_season, CASE WHEN date>89 THEN date + 1900
 ELSE date + 2000 END AS year
MATCH (t:Transfer) WHERE t.transfer_season = raw_season
SET t.transfer_year = year;

// Label loans
MATCH (t:Transfer)
WHERE t.transfer_fee_text STARTS WITH 'Loan'
SET t:Loan;

// link players transfers
MATCH (t:Transfer)-[:OF_PLAYER]->(p:Player)
with p as player, t
order by t.transfer_year
with player, collect(t) as transfers
UNWIND range(0,length(transfers)-2, 1) as idx
with player, transfers[idx]  as a, transfers[idx+1] as b
MERGE (a)-[:NEXT]-> (b);

// Add cash flow
MATCH (t:Transfer) WITH DISTINCT t.transfer_year AS year
MATCH (seller)<-[:FROM_CLUB]-(t:Transfer)-[:TO_CLUB]->(buyer)
WHERE t.transfer_year = year
WITH year, seller, buyer,sum(t.transfer_fee) AS cash_flow, count(t) AS players
MERGE (buyer)-[:CASH_FLOW {total: cash_flow, year: year, playerCount: players}]->(seller);
