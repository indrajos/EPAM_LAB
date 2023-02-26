CREATE DATABASE training_health;

CREATE SCHEMA health; 


CREATE TABLE IF NOT EXISTS health.address
(
	address_id			serial PRIMARY KEY,
	zip_code			int NOT NULL, 
	city 				text NOT NULL DEFAULT 'Plunge',
	street				text NOT NULL,
	building			text NOT NULL,
	apartment			text 
);
CREATE TABLE IF NOT EXISTS health.institution
(
	institution_id		serial PRIMARY KEY,
	institution_name	TEXT NOT NULL,
	address_id			serial NOT NULL REFERENCES health.address
);

CREATE TABLE IF NOT EXISTS health.employee
(
	employee_id				serial PRIMARY KEY,
	employee_ssn			bigint NOT NULL UNIQUE, 
	address_id				serial NOT NULL REFERENCES health.address,
	first_name				TEXT NOT NULL,
	last_name				TEXT NOT NULL,
	full_name				TEXT GENERATED ALWAYS AS (first_name || ' ' || last_name) STORED,
	empl_capabilities		TEXT NOT NULL,
	phone_number			bigserial NOT NULL CHECK (length(CAST(phone_number AS TEXT)) < 12),
	empl_capacity			int NOT NULL 
);
CREATE TABLE IF NOT EXISTS health.patient
(
	patient_id				serial PRIMARY KEY,
	patient_ssn				bigint NOT NULL UNIQUE,
	address_id				serial NOT NULL REFERENCES health.address,
	first_name				TEXT NOT NULL,
	last_name				TEXT NOT NULL,
	full_name				TEXT GENERATED ALWAYS AS (first_name || ' ' || last_name) STORED NOT NULL,
	birth_date 				date NOT NULL CHECK (birth_date < CURRENT_DATE),
	phone_number			bigserial CHECK (length(CAST(phone_number AS TEXT)) < 12),
	registration_date		date NOT NULL DEFAULT current_date, -- registered AS a patient FIRST time 
	employee_id				serial NOT NULL REFERENCES health.employee -- FAMILY doctor id
);

CREATE TABLE IF NOT EXISTS health.registration -- registration ONLY FOR one institution 'Health center of Plunge'
(
	patient_id			serial NOT NULL REFERENCES health.patient,
	employee_id			serial NOT NULL REFERENCES health.employee,
	institution_name	text DEFAULT 'Health center of Plunge', -- IF registration would be FOR many institutions, THEN it should be used institution_id NOT name
	visit_time  		time NOT NULL, 							
	visit_date			date NOT NULL CHECK (visit_date > CURRENT_DATE) 
);
CREATE TABLE IF NOT EXISTS health.workplace 
(
	employee_id			serial NOT NULL REFERENCES health.employee,
	institution_id		serial  NOT NULL REFERENCES health.institution
);


-- INSERT THE VALUES FOR ALL TABLES

INSERT INTO health.address (zip_code, street, building)
VALUES (90125, 'Vaizganto', '91'),
		(90143, 'Vaizganto', '112'),
		(90125, 'Vaizganto', '34'),
		(90125, 'Vaizganto', '35'),
		(90162, 'Telsiu', '13');
INSERT INTO health.address (zip_code, street, building, apartment)
VALUES
		(90162, 'Telsiu', '12', '7'),
		(90160, 'Rietavo', '4', '1'),
		(90160, 'Vaizganto', '4', '2'),
		(90160, 'Rietavo', '4', '3'),
		(90160, 'Vaizganto', '4', '4');

INSERT INTO health.institution (institution_name, address_id)
VALUES ('SG clinic', (SELECT address_id FROM health.address WHERE street LIKE '%Tels%' AND building = '13')),
		('Medicine center of Samogitia', (SELECT address_id FROM health.address WHERE street LIKE '%Vaizgant%' AND building = '112')),
		('Health center of Plunge', (SELECT address_id FROM health.address WHERE street LIKE '%Vaizgant%' AND building = '91')),
		('Anteja', (SELECT address_id FROM health.address WHERE street LIKE '%Vaizgant%' AND building = '34')),
		('Sanus', (SELECT address_id FROM health.address WHERE street LIKE '%Vaizgant%' AND building = '35'));


INSERT INTO health.employee (employee_ssn, first_name , last_name, empl_capabilities, phone_number, empl_capacity, address_id)
SELECT  
37777777777, 'Mark', 'Urban', 'family doctor', 37064444444, 200,
(SELECT address_id FROM health.address WHERE street LIKE '%Rietav%' AND building = '4' AND apartment = '1')
UNION 
SELECT 
47777777777, 'Monika', 'Urban', 'dentist', 37064444455, 100,
(SELECT address_id FROM health.address WHERE street LIKE '%Rietav%' AND building = '4' AND apartment = '1')
UNION 
SELECT 
38888888888, 'John', 'Smith', 'family doctor', 37064466666, 200,
(SELECT address_id FROM health.address WHERE street LIKE '%Tels%' AND building = '12' AND apartment = '7')
UNION 
SELECT 
49999999999, 'Lolita', 'Smith', 'psychologist', 37064444333, 100,
(SELECT address_id FROM health.address WHERE street LIKE '%Tels%' AND building = '12' AND apartment = '7')
UNION 
SELECT 
32222222222, 'Peter', 'Thurman', 'family doctor', 37064444441, 200,
(SELECT address_id FROM health.address WHERE street LIKE '%Vaizgant%' AND building = '34');


INSERT INTO health.patient (patient_ssn, first_name, last_name, birth_date, phone_number, employee_id, address_id)
SELECT  34567891122, 'Ana', 'Smith', '2000-01-01'::date, 37065433221, 
(SELECT employee_id FROM health.employee WHERE first_name = 'Mark' AND last_name = 'Urban'),
(SELECT address_id FROM health.address WHERE street LIKE '%Tels%' AND building = '12' AND apartment = '7')
UNION 
SELECT 34567891133, 'Zhana', 'Smith', '2000-01-02'::date, 37065433222, 
(SELECT employee_id FROM health.employee WHERE first_name = 'Mark' AND last_name = 'Urban'),
(SELECT address_id FROM health.address WHERE street LIKE '%Tels%' AND building = '12' AND apartment = '7')
UNION 
SELECT 34567891144, 'Robert', 'Johnson', '2000-01-21'::date, 37065433223, 
(SELECT employee_id FROM health.employee WHERE first_name = 'John' AND last_name = 'Smith'),
(SELECT address_id FROM health.address WHERE street LIKE '%Rietav%' AND building = '4' AND apartment = '1')
UNION 
SELECT 34567891155, 'Marija', 'Johnson', '2000-01-14'::date, 37065433224, 
(SELECT employee_id FROM health.employee WHERE first_name = 'John' AND last_name = 'Smith'),
(SELECT address_id FROM health.address WHERE street LIKE '%Rietav%' AND building = '4' AND apartment = '1')
UNION 
SELECT 34567891166, 'Oleg', 'Surajev', '2000-01-20'::date, 37065433225, 
(SELECT employee_id FROM health.employee WHERE first_name = 'John' AND last_name = 'Smith'),
(SELECT address_id FROM health.address WHERE street LIKE '%Rietav%' AND building = '4' AND apartment = '3');



INSERT INTO health.registration (patient_id, employee_id, visit_time, visit_date)
SELECT 
(SELECT patient_id FROM health.patient WHERE patient_ssn = 34567891166),
(SELECT employee_id FROM health.patient WHERE patient_ssn = 34567891166),
'10:30'::time, '2022-12-24'::date
UNION
SELECT 
(SELECT patient_id FROM health.patient WHERE patient_ssn = 34567891155),
(SELECT employee_id FROM health.patient WHERE patient_ssn = 34567891155),
'10:30'::time, '2022-12-24'::date
UNION
SELECT 
(SELECT patient_id FROM health.patient WHERE patient_ssn = 34567891166),
(SELECT employee_id FROM health.employee WHERE employee_ssn = 47777777777),
'10:30'::time, '2022-12-28'::date
UNION
SELECT 
(SELECT patient_id FROM health.patient WHERE patient_ssn = 34567891166),
(SELECT employee_id FROM health.employee WHERE employee_ssn = 49999999999),
'10:30'::time, '2022-12-31'::date
UNION
SELECT 
(SELECT patient_id FROM health.patient WHERE patient_ssn = 34567891122),
(SELECT employee_id FROM health.employee WHERE employee_ssn = 37777777777),
'10:30'::time, '2022-12-31'::date
UNION
SELECT 
(SELECT patient_id FROM health.patient WHERE patient_ssn = 34567891133),
(SELECT employee_id FROM health.employee WHERE employee_ssn = 37777777777),
'10:00'::time, '2022-12-31'::date
UNION
SELECT 
(SELECT patient_id FROM health.patient WHERE patient_ssn = 34567891144),
(SELECT employee_id FROM health.employee WHERE employee_ssn = 38888888888),
'10:00'::time, '2022-12-30'::date
UNION
SELECT 
(SELECT patient_id FROM health.patient WHERE patient_ssn = 34567891155),
(SELECT employee_id FROM health.employee WHERE employee_ssn = 38888888888),
'10:30'::time, '2022-12-30'::date;

 
INSERT INTO health.workplace
SELECT
(SELECT employee_id FROM health.employee WHERE first_name = 'John' AND last_name = 'Smith'),
(SELECT institution_id FROM health.institution WHERE institution_name = 'Health center of Plunge')
UNION 
SELECT 
(SELECT employee_id FROM health.employee WHERE first_name = 'Mark' AND last_name = 'Urban'),
(SELECT institution_id FROM health.institution WHERE institution_name = 'Health center of Plunge')
UNION 
SELECT 
(SELECT employee_id FROM health.employee WHERE first_name = 'Peter' AND last_name = 'Thurman'),
(SELECT institution_id FROM health.institution WHERE institution_name = 'Health center of Plunge')
UNION 
SELECT 
(SELECT employee_id FROM health.employee WHERE first_name = 'Monika' AND last_name = 'Urban'),
(SELECT institution_id FROM health.institution WHERE institution_name = 'Health center of Plunge')
UNION 
SELECT 
(SELECT employee_id FROM health.employee WHERE first_name = 'Lolita' AND last_name = 'Smith'),
(SELECT institution_id FROM health.institution WHERE institution_name = 'SG clinic')
UNION 
SELECT 
(SELECT employee_id FROM health.employee WHERE first_name = 'Lolita' AND last_name = 'Smith'),
(SELECT institution_id FROM health.institution WHERE institution_name = 'Health center of Plunge')
UNION 
SELECT 
(SELECT employee_id FROM health.employee WHERE first_name = 'Monika' AND last_name = 'Urban'),
(SELECT institution_id FROM health.institution WHERE institution_name = 'Sanus');


-- QUERY for determination doctors workload
SELECT e.first_name, e.last_name,
		(CASE WHEN count(r.employee_id) > 4 THEN 'enought workload'
		ELSE 'insufficient workload' END) AS total_visits 
FROM health.registration r
JOIN health.employee e
ON r.employee_id = e.employee_id
WHERE visit_date BETWEEN '2022-10-01' AND '20023-01-01'
GROUP BY e.first_name, e.last_name
ORDER BY total_visits DESC ;
