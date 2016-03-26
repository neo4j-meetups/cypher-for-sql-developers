
// Top Sellers
MATCH (t:Transfer)-[:FROM_CLUB]->(c)
WHERE  t.year = 2012
RETURN c.name AS Club, sum(t.numericFee) AS saleAmount
ORDER BY saleAmount DESC
LIMIT 10

// Top Buyers
MATCH (t:Transfer)-[:TO_CLUB]->(c)
WHERE t.year = 2012
RETURN c.name, sum(t.numericFee)
ORDER BY sum(t.numericFee) DESC
LIMIT 25

// Balance
MATCH (acq:Transfer)-[:TO_CLUB]->(c)
WHERE acq.year = 2014
WITH c, sum(acq.numericFee) AS spent
MATCH (c)<-[:FROM_CLUB]-(sale:Transfer)
WHERE sale.year = 2014
RETURN c.name, spent, sum(sale.numericFee) AS received, spent - sum(sale.numericFee) as balance
ORDER BY balance DESC
LIMIT 25

// Balances over last 26 years
MATCH (acq:Transfer)-[:TO_CLUB]->(c:Club)
WITH c, sum(acq.numericFee) AS spent
MATCH (c)<-[:FROM_CLUB]-(sale:Transfer)
RETURN c.name, spent, sum(sale.numericFee) AS received, spent - sum(sale.numericFee) as balance
ORDER BY balance DESC
LIMIT 100

// Largest short term benefits/loses on individual players (as text)
MATCH (p:Player)<-[:OF_PLAYER]-(acq:Transfer)-[:TO_CLUB]->(c), (acq)-[:FROM_CLUB]->(boughtFrom),
 (p:Player)<-[:OF_PLAYER]-(sale:Transfer)-[:FROM_CLUB]->(c), (sale)-[:TO_CLUB]->(soldTo)
WHERE acq.year < sale.year AND NOT sale:Loan AND NOT acq:Loan
RETURN c.name + " bought " + p.name + " from " + boughtFrom.name + " in " + acq.year + " for " + acq.fee + " and sold it to " + soldTo.name + " " + (sale.year - acq.year) + " years later in " + sale.year + " for " + sale.fee + CASE WHEN (sale.numericFee - acq.numericFee)>=0 THEN " making a profit of " + ((sale.numericFee - acq.numericFee)/1000000) + "Mill. £" ELSE " losing " + (abs(sale.numericFee - acq.numericFee)/1000000) + "Mill. £" END as story
order by (sale.numericFee - acq.numericFee)/(sale.year - acq.year) desc
limit 10


// Largest lumps of money
MATCH (buyer)-[f:CASH_FLOW]->(seller)
RETURN f.year AS year, buyer.name AS buyer, seller.name AS seller, f.total AS amount, f.playerCount AS playersTransferred
ORDER BY amount DESC limit 10

// Top 3 biggest spenders per season
MATCH (acq:Transfer)-[:TO_CLUB]->(c)
WITH c, acq.year AS season, sum(acq.numericFee) AS spent
MATCH (c)<-[:FROM_CLUB]-(sale:Transfer)
WHERE sale.year = season
WITH c.name as club, season, spent, sum(sale.numericFee) AS received, spent - sum(sale.numericFee) as balance
WITH season,club, balance
ORDER BY season, balance DESC
WITH season, COLLECT({club: club, balance: balance})[0..3] AS records
UNWIND records AS record
RETURN season, record.club, record.balance
ORDER BY season DESC

// Length 3 cash flow paths for given team and season
MATCH path = (buyer:Club)-[:CASH_FLOW*..3]->(seller:Club)
WHERE buyer.name = "Real Madrid" AND all(f in relationships(path) WHERE f.year=2000)
return *

//Happy returns (graph)
match (c:Club)<-[f:FROM_CLUB]-(sale:Transfer)-[:NEXT*1..]->(rebuy:Transfer)-[t:TO_CLUB]->(c), (sale)-[:OF_PLAYER]->(p)
where not (sale:Loan) and not(rebuy:Loan)
return c, p, rebuy.numericFee - sale.numericFee as `devaluation/revaluation`, sale, rebuy, f, t
order by `devaluation/revaluation`
LIMIT 2

//happy returns (tabular)
match (c:Club)<-[f:FROM_CLUB]-(sale:Transfer)-[:NEXT*1..]->(rebuy:Transfer)-[t:TO_CLUB]->(c), (sale)-[:OF_PLAYER]->(p)
where not (sale:Loan) and not(rebuy:Loan)
return c.name, p.name, rebuy.numericFee - sale.numericFee as `devaluation/revaluation`, sale.season, rebuy.season
order by `devaluation/revaluation`
LIMIT 5

// players with biggest transfer money footprint
MATCH (t:Transfer)-[:OF_PLAYER]->(p:Player)
return p.name, sum(t.numericFee) as moneyTrace
order by moneyTrace desc
limit 20

// Club's transfer balance per season
MATCH (acq:Transfer)-[:TO_CLUB]->(c)
WHERE c.name = 'Real Madrid'
WITH c, acq.year AS season, sum(acq.numericFee) AS spent
MATCH (c)<-[:FROM_CLUB]-(sale:Transfer)
WHERE sale.year = season
RETURN c.name, season, spent, sum(sale.numericFee) AS received, (spent - sum(sale.numericFee))/1000000 + "M" as balance
ORDER BY season
LIMIT 25

// players trajectory
MATCH (t:Transfer)-[:OF_PLAYER]->(p:Player{name:'Stefan Effenberg'}), (t)-[:TO_CLUB]->(c)
with p.name as player, c.name as club, t.year  as yr
order by yr
return player, collect(club)
limit 20

// Largest short term benefits/loses on individual players (as table)
MATCH (boughtFrom:Club)<-[:FROM_CLUB]-(acq:Transfer)-[:TO_CLUB]->(c)<-[:FROM_CLUB]-(sale:Transfer)-[:TO_CLUB]->(soldTo:Club),
     (acq:Transfer)-[:OF_PLAYER]->(p:Player)<-[:OF_PLAYER]-(sale:Transfer)
WHERE acq.year < sale.year AND NOT sale:Loan AND NOT acq:Loan
RETURN c.name AS Club, p.name AS Player, ((sale.numericFee - acq.numericFee)/1000000) AS ProfitLoss, boughtFrom.name AS BoughtFrom, acq.year AS BoughtYear, acq.fee AS BuyPrice, soldTo.name AS SoldTo, sale.year AS SaleYear, sale.fee AS SalePrice
order by (sale.numericFee - acq.numericFee)/(sale.year - acq.year) desc
limit 10
