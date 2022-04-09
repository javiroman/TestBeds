-- 
-- Car Repairs database.
--

\c postgres;

DROP DATABASE IF EXISTS carrepairs;
CREATE DATABASE carrepairs;
\c carrepairs;

-- CAR GARAGES entity
DROP TABLE IF EXISTS garages;
CREATE TABLE garages (
  garageID char(7) PRIMARY KEY NOT NULL,
  garageName char(25) NOT NULL,
  garageCity char(10) NOT NULL
); 

-- CAR WORKS entity
DROP TABLE IF EXISTS works;
CREATE TABLE works (
  carID char(7) NOT NULL,
  dateIn char(10) NOT NULL,
  dateOut char(10),
  cost char(10),
  PRIMARY KEY (carID, dateIn),
  garageID char(4) REFERENCES garages (garageID) 
	ON DELETE CASCADE ON UPDATE CASCADE
);

-- CAR REPAIRS entity
DROP TABLE IF EXISTS repairs;
CREATE TABLE repairs (
  repairID char(4) PRIMARY KEY NOT NULL,
  repairName char(10) NOT NULL,
  repairDesc char(25) NOT NULL
); 

-- WORKS / REPAIRS relationship
DROP TABLE IF EXISTS workRepair;
CREATE TABLE workRepair (
  carID char(7) NOT NULL,
  dateIn char(10) NOT NULL,
  repairID char(4) NOT NULL,
  PRIMARY KEY (carID, dateIn, repairID),
  FOREIGN KEY (carID, dateIn) REFERENCES works (carID, dateIn)
	ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (repairID) REFERENCES repairs (repairID)
	ON DELETE CASCADE ON UPDATE CASCADE
); 

--
-- Entity tables initial insertions.
--

INSERT INTO garages VALUES 
	('G1', 'Garage One', 'Madrid'),
	('G2', 'Garage Two', 'Madrid'),
	('G3', 'Garage Three', 'Madrid'),
	('G4', 'Garage Four', 'Sevilla');

INSERT INTO works VALUES 
	('1019GZF', '01/01/2015', NULL, NULL, 'G1'),
	('1019GZF', '02/01/2015', NULL, NULL, 'G1'),
	('1030GZF', '02/01/2015', NULL, NULL, 'G1'),
	('2039GRF', '03/01/2015', NULL, NULL, 'G1'),
	('1019RZF', '12/01/2015', NULL, NULL, 'G3'),
	('2019XZF', '02/03/2015', NULL, NULL, 'G1'),
	('3010ABC', '02/02/2015', NULL, NULL, 'G4'),
	('3110ABZ', '02/03/2015', NULL, NULL, 'G1'),
	('2210ABZ', '05/01/2015', NULL, NULL, 'G2');

INSERT INTO repairs VALUES 
	('R1', 'Scrach', 'Scrach repair'),
	('R2', 'Dent', 'Dent repair'),
	('R3', 'Paintwork', 'Paintwork repair'),
	('R4', 'Wheels', 'Wheels repair'),
	('R5', 'Engine', 'Engine repair');

--
-- Relationship tables initial insertions.
--

INSERT INTO workRepair VALUES 
	('1019GZF', '01/01/2015', 'R1'),
	('1019GZF', '01/01/2015', 'R2'),
	('1019GZF', '02/01/2015', 'R3'),
	('1030GZF', '02/01/2015', 'R4'),
	('2039GRF', '03/01/2015', 'R1'),
	('1019RZF', '12/01/2015', 'R1'),
	('2019XZF', '02/03/2015', 'R1'),
	('3010ABC', '02/02/2015', 'R2'),
	('3110ABZ', '02/03/2015', 'R4'),
	('2210ABZ', '05/01/2015', 'R3');

--
-- Regular/Interactive insertions
--

-- Insert new car with plate 1111AAA with repairs R1 and R2 from Garage G1
INSERT INTO works VALUES ('1111AAA', '05/01/2015', NULL, NULL, 'G1');
INSERT INTO workRepair VALUES
	('1111AAA', '05/01/2015', 'R1'),
	('1111AAA', '05/01/2015', 'R2');


