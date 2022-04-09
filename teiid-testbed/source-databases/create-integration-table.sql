-- 
-- Integration table for CarSales and CarRepairs federation
--

USE carsales;

-- Integration table 
DROP TABLE IF EXISTS platesvin;
CREATE TABLE platesvin (
  carPlate char(7) NOT NULL,
  carVIN char(7) NOT NULL,
  PRIMARY KEY (carPlate)
);

--
-- Entity tables initial insertions.
--
INSERT INTO platesvin VALUES 
	('1019GZF', 'VIN1111'),
	('1030GZF', 'VIN2222'),
	('2039GRF', 'VIN3333'),
	('1019RZF', 'VIN4444'),
	('2019XZF', 'VIN5555'),
	('3010ABC', 'VIN6666'),
	('3110ABZ', 'VIN7777'),
	('2210ABZ', 'VIN8888');


