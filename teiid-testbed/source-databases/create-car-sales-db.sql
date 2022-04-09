-- 
-- Car Sales database.
--

DROP DATABASE IF EXISTS carsales;
CREATE DATABASE carsales;
USE carsales;

-- CAR MODELS entity
DROP TABLE IF EXISTS models;
CREATE TABLE models (
  modID char(4) NOT NULL,
  model char(10) NOT NULL,
  modType char(10) NOT NULL,
  modEngine char(10) NOT NULL,
  PRIMARY KEY (modID)
);

-- CAR DEALERS entity
DROP TABLE IF EXISTS cardealers;
CREATE TABLE cardealers (
  dealID char(4) NOT NULL,
  dealMod char(10) NOT NULL,
  dealCity char(10) NOT NULL,
  dealPost char(40) NOT NULL,
  PRIMARY KEY (dealID)
); 

-- CAR SHOP entity
DROP TABLE IF EXISTS carshop;
CREATE TABLE carshop (
  carID char(7) NOT NULL,
  carYear char(10) NOT NULL,
  carColour char(10) NOT NULL,
  PRIMARY KEY (carID)
); 

-- CAR DEALERS / CAR SHOP relationship
DROP TABLE IF EXISTS dealersShop;
CREATE TABLE dealersShop (
  dealID char(4) NOT NULL,
  carID  char(7) NOT NULL,
  PRIMARY KEY (dealID, carID),
  FOREIGN KEY (dealID) REFERENCES cardealers (dealID) 
	ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (carID) REFERENCES carshop (carID)
	ON DELETE CASCADE ON UPDATE CASCADE
); 

-- CAR SHOP / MODELS relationship
DROP TABLE IF EXISTS shopModels;
CREATE TABLE shopModels (
  modID char(4) NOT NULL,
  carID char(7) NOT NULL,
  PRIMARY KEY (modID, carID),
  FOREIGN KEY (modID) REFERENCES models (modID)
	ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (carID) REFERENCES carshop (carID)
	ON DELETE CASCADE ON UPDATE CASCADE
); 

-- CAR DEALERS / MODELS relationship
DROP TABLE IF EXISTS dealersModels;
CREATE TABLE dealersModels (
  dealID char(4) NOT NULL,
  modID  char(4) NOT NULL,
  PRIMARY KEY (dealID, modID),
  FOREIGN KEY (dealID) REFERENCES cardealers (dealID),
  FOREIGN KEY (modID) REFERENCES models (modID)
); 

--
-- Entity tables initial insertions.
--

INSERT INTO models VALUES ("M1", "AUDI", "A3", "1500");
INSERT INTO models VALUES ("M2", "AUDI", "A3", "2000");
INSERT INTO models VALUES ("M3", "AUDI", "A4", "2000");
INSERT INTO models VALUES ("M4", "BMW", "5", "2500");
INSERT INTO models VALUES ("M5", "BMW", "3", "1500");
INSERT INTO models VALUES ("M6", "PEUGEOT", "308", "1900");
INSERT INTO models VALUES ("M7", "PEUGEOT", "206", "1200");
INSERT INTO models VALUES ("M8", "HONDA", "ACCORD", "1500");
INSERT INTO models VALUES ("M9", "HONDA", "CIVC", "2000");

INSERT INTO cardealers VALUES ("C1", "AUDI", "MADRID", "28008");
INSERT INTO cardealers VALUES ("C2", "AUDI", "SEVILLA", "25002");
INSERT INTO cardealers VALUES ("C3", "AUDI", "BARCELONA", "25002");
INSERT INTO cardealers VALUES ("C4", "BMW", "MADRID", "28008");
INSERT INTO cardealers VALUES ("C5", "BMW", "VALENCIA", "28008");
INSERT INTO cardealers VALUES ("C6", "PEUGEOT", "MADRID", "28008");
INSERT INTO cardealers VALUES ("C7", "HONDA", "MADRID", "28008");
INSERT INTO cardealers VALUES ("C8", "SKODA", "MADRID", "28008");

INSERT INTO carshop VALUES ("1019GZF", "2008", "Black");
INSERT INTO carshop VALUES ("1030GZF", "2010", "White");
INSERT INTO carshop VALUES ("2039GRF", "2012", "White");
INSERT INTO carshop VALUES ("1019RZF", "2015", "Red");
INSERT INTO carshop VALUES ("2019XZF", "2003", "Black");
INSERT INTO carshop VALUES ("3010ABC", "2006", "Black");
INSERT INTO carshop VALUES ("3110ABZ", "2007", "Red");
INSERT INTO carshop VALUES ("2210ABZ", "2007", "Black");

--
-- Relationship tables initial insertions.
--

INSERT INTO dealersModels VALUES ("C1", "M1");
INSERT INTO dealersModels VALUES ("C1", "M2");
INSERT INTO dealersModels VALUES ("C1", "M3");
INSERT INTO dealersModels VALUES ("C2", "M1");
INSERT INTO dealersModels VALUES ("C2", "M2");
INSERT INTO dealersModels VALUES ("C3", "M1");
INSERT INTO dealersModels VALUES ("C4", "M4");

INSERT INTO shopModels VALUES ("M1", "1019GZF");
INSERT INTO shopModels VALUES ("M1", "1030GZF");
INSERT INTO shopModels VALUES ("M2", "2039GRF");
INSERT INTO shopModels VALUES ("M3", "1019RZF");
INSERT INTO shopModels VALUES ("M4", "2019XZF");
INSERT INTO shopModels VALUES ("M5", "3010ABC");
INSERT INTO shopModels VALUES ("M1", "3110ABZ");
INSERT INTO shopModels VALUES ("M3", "2210ABZ");

INSERT INTO dealersShop VALUES ("C1", "1019GZF");
INSERT INTO dealersShop VALUES ("C2", "1030GZF");
INSERT INTO dealersShop VALUES ("C2", "2039GRF");
INSERT INTO dealersShop VALUES ("C3", "1019RZF");
INSERT INTO dealersShop VALUES ("C4", "2019XZF");
INSERT INTO dealersShop VALUES ("C4", "3010ABC");
INSERT INTO dealersShop VALUES ("C1", "3110ABZ");
INSERT INTO dealersShop VALUES ("C2", "2210ABZ");

--
-- Regular/Interactive insertions
--

-- Buy a Audi A3 2000 cc white from dealer C1 with plate 1234ABC
INSERT INTO carshop VALUES ("1234ABC", "2008", "White");
INSERT INTO shopModels VALUES ("M1", "1234ABC");
INSERT INTO dealersShop VALUES ("C1", "1234ABC");

-- Buy a BMW 5 Series 2500 cc black from dealer C1 with plate 1234ABC
INSERT INTO carshop VALUES ("2222ABC", "2010", "black");
INSERT INTO shopModels VALUES ("M4", "2222ABC");
INSERT INTO dealersShop VALUES ("C4", "2222ABC");

-- Buy a BMW 3 Series 2500 cc black from dealer C1 with plate 1234ABC
INSERT INTO carshop VALUES ("1111AAA", "2010", "black");
INSERT INTO shopModels VALUES ("M5", "1111AAA");
INSERT INTO dealersShop VALUES ("C5", "1111AAA");

-- Delete car in cascade
-- DELETE FROM carshop WHERE carID="1111AAA";

-- References:
-- http://code.tutsplus.com/articles/sql-for-beginners-part-3-database-relationships--net-8561
-- http://www.joinfu.com/2005/12/managing-many-to-many-relationships-in-mysql-part-1/
-- http://www.sitepoint.com/understanding-sql-joins-mysql-database/
-- http://www.codeproject.com/Articles/33052/Visual-Representation-of-SQL-Joins

