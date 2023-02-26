--CREATE DATABASE training;

CREATE SCHEMA fuel;

-- CREATE ALL TABLES 

CREATE TABLE IF NOT EXISTS fuel.locations
(
	location_id			serial PRIMARY KEY,
	country				text NOT NULL DEFAULT 'Lithuania',
	city 				text NOT NULL,
	street				text NOT NULL,
	building			text NOT NULL
);

CREATE TABLE IF NOT EXISTS fuel.station 
(
	station_id		serial PRIMARY KEY,
	location_id		serial NOT NULL REFERENCES fuel.locations,
	station_name 	text NOT NULL  
);

CREATE TABLE IF NOT EXISTS fuel.employee 
(
	employee_id				serial PRIMARY KEY,
	first_name				TEXT NOT NULL,
	last_name				TEXT NOT NULL,
	full_name				TEXT GENERATED ALWAYS AS (first_name || ' ' || last_name) STORED NOT NULL,
	empl_position			TEXT NOT NULL 
);

CREATE TABLE IF NOT EXISTS fuel.schedule 
(
	schedule_id		serial PRIMARY KEY,
	station_id		serial NOT NULL REFERENCES fuel.station,
	employee_id		serial NOT NULL REFERENCES fuel.employee
);

CREATE TABLE IF NOT EXISTS fuel.product
(
	product_id			serial PRIMARY KEY,
	product_name		text NOT NULL,
	price 				decimal NOT NULL
);

CREATE TABLE IF NOT EXISTS fuel.orders 
(
	order_id		serial PRIMARY KEY,
	order_date		timestamp NOT NULL,
	station_id		serial NOT NULL REFERENCES fuel.station,
	employee_id		serial NOT NULL REFERENCES fuel.employee
);

CREATE TABLE IF NOT EXISTS fuel.order_product 
(
	op_id				serial PRIMARY KEY,
	order_id			serial NOT NULL REFERENCES fuel.orders,
	product_id			serial NOT NULL REFERENCES fuel.product,
	product_amount 		decimal NOT NULL,
	product_sale_price 	decimal NOT NULL 
);

ALTER TABLE fuel.order_product 
ADD CONSTRAINT amount_check CHECK (product_amount > 0);


-- make sure your surrogate keys values are not included in DML scripts (they should be created runtime by the database, as well as DEFAULT values where appropriate)

INSERT INTO fuel.locations (city, street, building)
VALUES ('Vilnius', 'Reformatu', '37A'),
		('Vilnius', 'Rugiu', '5'),
		('Kaunas', 'Taikos', '4'),
		('Klaipeda', 'Baltijos', '42C'),
		('Kaunas', 'Savanoriu', '214');
	
INSERT INTO fuel.station (location_id, station_name)
SELECT 
(SELECT location_id FROM fuel.locations WHERE lower(street) LIKE lower('%reformatu%')),
('Reformatu station')
UNION 
SELECT 
(SELECT location_id FROM fuel.locations WHERE lower(street) LIKE lower('%rugiu%')),
('Rugiu station')
UNION 
SELECT 
(SELECT location_id FROM fuel.locations WHERE lower(street) LIKE lower('%taikos%')),
('Taikos station')
UNION 
SELECT 
(SELECT location_id FROM fuel.locations WHERE lower(street) LIKE lower('%baltijos%')),
('Seaside station')
UNION 
SELECT 
(SELECT location_id FROM fuel.locations WHERE lower(street) LIKE lower('%savanoriu%')),
('Kaunas general');

INSERT INTO fuel.employee (first_name, last_name, empl_position)
VALUES ('John', 'Andersen', 'sales manager'),
		('Kristi', 'Smith', 'sales manager'),
		('Sara', 'Johnson', 'sales manager'),
		('Anna', 'Ivanova', 'general manager'),
		('Monika', 'Smart', 'sales manager');
		
INSERT INTO fuel.schedule (station_id, employee_id)
SELECT
(SELECT station_id FROM fuel.station WHERE lower(station_name) LIKE lower('%general%')),
(SELECT employee_id FROM fuel.employee WHERE lower(first_name) = lower('anna') AND lower(last_name) = lower('ivanova'))
UNION 
SELECT
(SELECT station_id FROM fuel.station WHERE lower(station_name) LIKE lower('%seaside%')),
(SELECT employee_id FROM fuel.employee WHERE lower(first_name) = lower('monika') AND lower(last_name) = lower('smart'))
UNION 
SELECT
(SELECT station_id FROM fuel.station WHERE lower(station_name) LIKE lower('%reformatu%')),
(SELECT employee_id FROM fuel.employee WHERE lower(first_name) = lower('john') AND lower(last_name) = lower('andersen'))
UNION 
SELECT
(SELECT station_id FROM fuel.station WHERE lower(station_name) LIKE lower('%reformatu%')),
(SELECT employee_id FROM fuel.employee WHERE lower(first_name) = lower('kristi') AND lower(last_name) = lower('smith'))
UNION 
SELECT
(SELECT station_id FROM fuel.station WHERE lower(station_name) LIKE lower('%taikos%')),
(SELECT employee_id FROM fuel.employee WHERE lower(first_name) = lower('sara') AND lower(last_name) = lower('johnson'));

INSERT INTO fuel.product (product_name, price)
VALUES ('A95', 1.45),
		('carwash', 15),
		('icecream', 2),
		('mineral water', 1.5),
		('window cleaner', 11),
		('A98', 1.45),
		('D', 1.57 ),
		('gas', 0.64),
		('coffee', 3.5),
		('hot sandwich', 4);
	


INSERT INTO fuel.orders (order_date, station_id, employee_id)
SELECT
('2022-12-19 10:23:54'::timestamp),
(SELECT station_id FROM fuel.station WHERE lower(station_name) LIKE lower('%general%')),
(SELECT employee_id FROM fuel.employee WHERE lower(first_name) = lower('anna') AND lower(last_name) = lower('ivanova'))
UNION 
SELECT
('2022-12-20 10:23:54'::timestamp),
(SELECT station_id FROM fuel.station WHERE lower(station_name) LIKE lower('%general%')),
(SELECT employee_id FROM fuel.employee WHERE lower(first_name) = lower('monika') AND lower(last_name) = lower('smart'))
UNION 
SELECT
('2022-12-19 11:23:54'::timestamp),
(SELECT station_id FROM fuel.station WHERE lower(station_name) LIKE lower('%seaside%')),
(SELECT employee_id FROM fuel.employee WHERE lower(first_name) = lower('anna') AND lower(last_name) = lower('ivanova'))
UNION 
SELECT
('2022-12-21 12:23:54'::timestamp),
(SELECT station_id FROM fuel.station WHERE lower(station_name) LIKE lower('%seaside%')),
(SELECT employee_id FROM fuel.employee WHERE lower(first_name) = lower('monika') AND lower(last_name) = lower('smart'))
UNION 
SELECT
('2022-12-22 10:23:54'::timestamp),
(SELECT station_id FROM fuel.station WHERE lower(station_name) LIKE lower('%reformatu%')),
(SELECT employee_id FROM fuel.employee WHERE lower(first_name) = lower('john') AND lower(last_name) = lower('andersen'))
UNION 
SELECT
('2022-12-23 10:23:54'::timestamp),
(SELECT station_id FROM fuel.station WHERE lower(station_name) LIKE lower('%reformatu%')),
(SELECT employee_id FROM fuel.employee WHERE lower(first_name) = lower('kristi') AND lower(last_name) = lower('smith'))
UNION 
SELECT
('2022-12-24 10:23:54'::timestamp),
(SELECT station_id FROM fuel.station WHERE lower(station_name) LIKE lower('%taikos%')),
(SELECT employee_id FROM fuel.employee WHERE lower(first_name) = lower('sara') AND lower(last_name) = lower('johnson'))
UNION 
SELECT
('2022-12-25 10:23:54'::timestamp),
(SELECT station_id FROM fuel.station WHERE lower(station_name) LIKE lower('%taikos%')),
(SELECT employee_id FROM fuel.employee WHERE lower(first_name) = lower('sara') AND lower(last_name) = lower('johnson'))
UNION 
SELECT
('2022-12-26 10:23:54'::timestamp),
(SELECT station_id FROM fuel.station WHERE lower(station_name) LIKE lower('%general%')),
(SELECT employee_id FROM fuel.employee WHERE lower(first_name) = lower('anna') AND lower(last_name) = lower('ivanova'))
UNION 
SELECT
('2022-12-27 10:23:54'::timestamp),
(SELECT station_id FROM fuel.station WHERE lower(station_name) LIKE lower('%general%')),
(SELECT employee_id FROM fuel.employee WHERE lower(first_name) = lower('anna') AND lower(last_name) = lower('ivanova'))
UNION 
SELECT
('2023-01-11 10:23:54'::timestamp),
(SELECT station_id FROM fuel.station WHERE lower(station_name) LIKE lower('%general%')),
(SELECT employee_id FROM fuel.employee WHERE lower(first_name) = lower('anna') AND lower(last_name) = lower('ivanova'));


INSERT INTO fuel.order_product (order_id, product_id, product_amount, product_sale_price)
SELECT
(SELECT order_id FROM fuel.orders WHERE station_id = 
		(SELECT station_id FROM fuel.station WHERE lower(station_name) LIKE lower('%general%'))
		AND employee_id = 
		(SELECT employee_id FROM fuel.employee WHERE lower(first_name) = lower('anna') AND lower(last_name) = lower('ivanova'))
		AND order_date = '2023-01-11 10:23:54'),
(SELECT product_id FROM fuel.product WHERE lower(product_name) = lower('a95')),
28.77, 1.45
UNION 
SELECT
(SELECT order_id FROM fuel.orders WHERE station_id = 
		(SELECT station_id FROM fuel.station WHERE lower(station_name) LIKE lower('%general%'))
		AND employee_id = 
		(SELECT employee_id FROM fuel.employee WHERE lower(first_name) = lower('anna') AND lower(last_name) = lower('ivanova'))
		AND order_date = '2022-12-27 10:23:54'),
(SELECT product_id FROM fuel.product WHERE lower(product_name) = lower('a95')),
12.73, 1.45
UNION 
SELECT
(SELECT order_id FROM fuel.orders WHERE station_id = 
		(SELECT station_id FROM fuel.station WHERE lower(station_name) LIKE lower('%general%'))
		AND employee_id = 
		(SELECT employee_id FROM fuel.employee WHERE lower(first_name) = lower('anna') AND lower(last_name) = lower('ivanova'))
		AND order_date = '2022-12-27 10:23:54'),
(SELECT product_id FROM fuel.product WHERE lower(product_name) = lower('coffee')),
2, 3.5
UNION 
SELECT
(SELECT order_id FROM fuel.orders WHERE station_id = 
		(SELECT station_id FROM fuel.station WHERE lower(station_name) LIKE lower('%general%'))
		AND employee_id = 
		(SELECT employee_id FROM fuel.employee WHERE lower(first_name) = lower('anna') AND lower(last_name) = lower('ivanova'))
		AND order_date = '2022-12-27 10:23:54'),
(SELECT product_id FROM fuel.product WHERE lower(product_name) = lower('hot sandwich')),
1, 4
UNION 
SELECT
(SELECT order_id FROM fuel.orders WHERE station_id = 
		(SELECT station_id FROM fuel.station WHERE lower(station_name) LIKE lower('%reformatu%'))
		AND employee_id = 
		(SELECT employee_id FROM fuel.employee WHERE lower(first_name) = lower('john') AND lower(last_name) = lower('andersen'))
		AND order_date = '2022-12-22 10:23:54'),
(SELECT product_id FROM fuel.product WHERE lower(product_name) = lower('d')),
25.14, 1.57
UNION 
SELECT
(SELECT order_id FROM fuel.orders WHERE station_id = 
		(SELECT station_id FROM fuel.station WHERE lower(station_name) LIKE lower('%reformatu%'))
		AND employee_id = 
		(SELECT employee_id FROM fuel.employee WHERE lower(first_name) = lower('john') AND lower(last_name) = lower('andersen'))
		AND order_date = '2022-12-22 10:23:54'),
(SELECT product_id FROM fuel.product WHERE lower(product_name) = lower('mineral water')),
1, 1.5 
UNION 
SELECT
(SELECT order_id FROM fuel.orders WHERE station_id = 
		(SELECT station_id FROM fuel.station WHERE lower(station_name) LIKE lower('%seaside%'))
		AND employee_id = 
		(SELECT employee_id FROM fuel.employee WHERE lower(first_name) = lower('monika') AND lower(last_name) = lower('smart'))
		AND order_date = '2022-12-21 12:23:54'),
(SELECT product_id FROM fuel.product WHERE lower(product_name) = lower('a95')),
35.17, 1.45
UNION 
SELECT
(SELECT order_id FROM fuel.orders WHERE station_id = 
		(SELECT station_id FROM fuel.station WHERE lower(station_name) LIKE lower('%taikos%'))
		AND employee_id =
		(SELECT employee_id FROM fuel.employee WHERE lower(first_name) = lower('sara') AND lower(last_name) = lower('johnson'))
		AND order_date = '2022-12-24 10:23:54'),
(SELECT product_id FROM fuel.product WHERE lower(product_name) = lower('d')),
27.23, 1.57
UNION 
SELECT
(SELECT order_id FROM fuel.orders WHERE station_id = 
		(SELECT station_id FROM fuel.station WHERE lower(station_name) LIKE lower('%general%'))
		AND employee_id = 
		(SELECT employee_id FROM fuel.employee WHERE lower(first_name) = lower('monika') AND lower(last_name) = lower('smart'))
		AND order_date = '2022-12-20 10:23:54'),
(SELECT product_id FROM fuel.product WHERE lower(product_name) = lower('a98')),
38.98, 1.45
UNION 
SELECT
(SELECT order_id FROM fuel.orders WHERE station_id = 
		(SELECT station_id FROM fuel.station WHERE lower(station_name) LIKE lower('%taikos%'))
		AND employee_id = 
		(SELECT employee_id FROM fuel.employee WHERE lower(first_name) = lower('sara') AND lower(last_name) = lower('johnson'))
		AND order_date = '2022-12-25 10:23:54'),
(SELECT product_id FROM fuel.product WHERE lower(product_name) = lower('a95')),
39.01, 1.45
UNION 
SELECT
(SELECT order_id FROM fuel.orders WHERE station_id = 
		(SELECT station_id FROM fuel.station WHERE lower(station_name) LIKE lower('%general%'))
		AND employee_id =
		(SELECT employee_id FROM fuel.employee WHERE lower(first_name) = lower('anna') AND lower(last_name) = lower('ivanova'))
		AND order_date = '2022-12-26 10:23:54'),
(SELECT product_id FROM fuel.product WHERE lower(product_name) = lower('d')),
37.12, 1.57
UNION 
SELECT
(SELECT order_id FROM fuel.orders WHERE station_id = 
		(SELECT station_id FROM fuel.station WHERE lower(station_name) LIKE lower('%seaside%'))
		AND employee_id =
		(SELECT employee_id FROM fuel.employee WHERE lower(first_name) = lower('anna') AND lower(last_name) = lower('ivanova'))
		AND order_date = '2022-12-19 11:23:54'),
(SELECT product_id FROM fuel.product WHERE lower(product_name) = lower('a95')),
21.99, 1.45
UNION 
SELECT
(SELECT order_id FROM fuel.orders WHERE station_id = 
		(SELECT station_id FROM fuel.station WHERE lower(station_name) LIKE lower('%reformatu%'))
		 AND employee_id = 
		(SELECT employee_id FROM fuel.employee WHERE lower(first_name) = lower('kristi') AND lower(last_name) = lower('smith'))
		AND order_date = '2022-12-23 10:23:54'),
(SELECT product_id FROM fuel.product WHERE lower(product_name) = lower('a95')),
40.12, 1.45
UNION 
SELECT
(SELECT order_id FROM fuel.orders WHERE station_id = 
		(SELECT station_id FROM fuel.station WHERE lower(station_name) LIKE lower('%general%'))
		AND employee_id =
		(SELECT employee_id FROM fuel.employee WHERE lower(first_name) = lower('anna') AND lower(last_name) = lower('ivanova'))
		AND order_date = '2022-12-19 10:23:54'),
(SELECT product_id FROM fuel.product WHERE lower(product_name) = lower('d')),
21.73, 1.57
UNION 
SELECT
(SELECT order_id FROM fuel.orders WHERE station_id = 
		(SELECT station_id FROM fuel.station WHERE lower(station_name) LIKE lower('%general%'))
		AND employee_id =
		(SELECT employee_id FROM fuel.employee WHERE lower(first_name) = lower('anna') AND lower(last_name) = lower('ivanova'))
		AND order_date = '2022-12-19 10:23:54'),
(SELECT product_id FROM fuel.product WHERE lower(product_name) = lower('coffee')),
1, 3.5
UNION 
SELECT
(SELECT order_id FROM fuel.orders WHERE station_id = 
		(SELECT station_id FROM fuel.station WHERE lower(station_name) LIKE lower('%general%'))
		AND employee_id =
		(SELECT employee_id FROM fuel.employee WHERE lower(first_name) = lower('anna') AND lower(last_name) = lower('ivanova'))
		AND order_date = '2022-12-19 10:23:54'),
(SELECT product_id FROM fuel.product WHERE lower(product_name) = lower('window cleaner')),
1, 11;
