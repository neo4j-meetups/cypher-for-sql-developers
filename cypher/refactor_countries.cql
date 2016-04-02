// import confederations
LOAD CSV WITH HEADERS
FROM "file:///confederations.csv" AS row
MERGE (c:Confederation {id: row.urlName})
ON CREATE
SET c.shortName = row.shortName,
    c.region = row.region,
    c.name = row.name;

// import countries
LOAD CSV WITH HEADERS FROM "file:///countries.csv"
AS row
MERGE (country:Country {id: row.countryCode})
ON CREATE SET country.name = row.country

WITH country, row
MATCH (conf:Confederation {id: row.confederation })
MERGE (country)-[:PART_OF]->(conf);

// update clubs
MATCH (club:Club)
MATCH (country:Country {name: club.country})
MERGE (club)-[:PART_OF]->(country)
REMOVE club.country;

// update players
MATCH (player:Player)
MATCH (country:Country {name: player.nationality})
MERGE (player)-[:PLAYS_FOR]->(country)
REMOVE player.nationality;
