-- 
-- Car Repairs database with Vehicle identification number VIN as
-- car identifier.
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
  carVIN char(7) NOT NULL,
  dateIn char(10) NOT NULL,
  dateOut char(10),
  cost char(10),
  PRIMARY KEY (carVIN, dateIn),
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
  carVIN char(7) NOT NULL,
  dateIn char(10) NOT NULL,
  repairID char(4) NOT NULL,
  PRIMARY KEY (carVIN, dateIn, repairID),
  FOREIGN KEY (carVIN, dateIn) REFERENCES works (carVIN, dateIn)
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
	('VIN1111', '01/01/2015', NULL, NULL, 'G1'),
	('VIN1111', '02/01/2015', NULL, NULL, 'G1'),
	('VIN2222', '02/01/2015', NULL, NULL, 'G1'),
	('VIN3333', '03/01/2015', NULL, NULL, 'G1'),
	('VIN4444', '12/01/2015', NULL, NULL, 'G3'),
	('VIN5555', '02/03/2015', NULL, NULL, 'G1'),
	('VIN6666', '02/02/2015', NULL, NULL, 'G4'),
	('VIN7777', '02/03/2015', NULL, NULL, 'G1'),
	('VIN8888', '05/01/2015', NULL, NULL, 'G2');

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
	('VIN1111', '01/01/2015', 'R1'),
	('VIN1111', '01/01/2015', 'R2'),
	('VIN1111', '02/01/2015', 'R3'),
	('VIN2222', '02/01/2015', 'R4'),
	('VIN3333', '03/01/2015', 'R1'),
	('VIN4444', '12/01/2015', 'R1'),
	('VIN5555', '02/03/2015', 'R1'),
	('VIN6666', '02/02/2015', 'R2'),
	('VIN7777', '02/03/2015', 'R4'),
	('VIN8888', '05/01/2015', 'R3');

--
-- Regular/Interactive insertions
--

-- Create new car with VIN VIN9999 and repairs R1 and R2 from Garage G1
INSERT INTO works VALUES ('VIN9999', '05/01/2015', NULL, NULL, 'G1');
INSERT INTO workRepair VALUES
	('VIN9999', '05/01/2015', 'R1'),
	('VIN9999', '05/01/2015', 'R2');


