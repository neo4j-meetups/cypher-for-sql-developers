// link players transfers
MATCH (t:Transfer)-[:OF_PLAYER]->(p:Player)
with p as player, t
order by t.year
with player, collect(t) as transfers
UNWIND range(0,SIZE(transfers)-2, 1) as idx
with player, transfers[idx]  as a, transfers[idx+1] as b
MERGE (a)-[:NEXT]-> (b);

// Add cash flow
MATCH (t:Transfer) WITH DISTINCT t.year AS year
MATCH (seller)<-[:FROM_CLUB]-(t:Transfer)-[:TO_CLUB]->(buyer)
WHERE t.year = year
WITH year, seller, buyer,sum(t.numericFee) AS cash_flow, count(t) AS players
MERGE (buyer)-[:CASH_FLOW {total: cash_flow, year: year, playerCount: players}]->(seller);
