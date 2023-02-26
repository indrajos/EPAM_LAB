CREATE DATABASE training;

CREATE SCHEMA kindergarden;

-- CREATE ALL TABLES 

CREATE TABLE IF NOT EXISTS kindergarden.kd_groups -- change table name because of naming convetion
(
	group_id		serial PRIMARY KEY, -- choose serial data type because of auto increment
	age_range		text NOT NULL, 
	group_name 		text NOT NULL  -- choose text data type instead of varchar, because it is not limited
);
CREATE TABLE IF NOT EXISTS kindergarden.activity
(
	activity_id			serial PRIMARY KEY,
	title				text NOT NULL, -- change column name because of naming convetion
	day_time  			time NOT NULL, -- change column name because of naming convetion
	activity_date		date NOT NULL CHECK (activity_date > CURRENT_DATE), -- change column name because of naming convetion
	activity_decription	text 
);
CREATE TABLE IF NOT EXISTS kindergarden.address
(
	address_id			serial PRIMARY KEY,
	zip_code			int NOT NULL, 
	city 				text NOT NULL,
	district			text,
	street				text NOT NULL,
	building			text NOT NULL,
	apartment			text 
);
CREATE TABLE IF NOT EXISTS kindergarden.menu
(
	dish_id				serial PRIMARY KEY,
	title				text NOT NULL,
	nutrition			text,
	ingredients			text NOT NULL,
	weight				decimal,
	meal_of_day			text
);
CREATE TABLE IF NOT EXISTS kindergarden.health_issues
(
	health_id				serial PRIMARY KEY,
	allergy					TEXT,
	other_disabilities		text, 
	physical_disabilities 	text
);
-- decided that table health_allergy is not necessary at all. In this case I added allergy column to health_issues table
-- and health_id column (FK) to allergy table.
CREATE TABLE IF NOT EXISTS kindergarden.allergy
(
	allergy_id			serial PRIMARY KEY,
	health_id			serial NOT NULL REFERENCES kindergarden.health_issues,
	title				text NOT NULL, 
	description 		text
);
CREATE TABLE IF NOT EXISTS kindergarden.food_restrictions
(
	dish_id					serial REFERENCES kindergarden.menu,
	allergy_id				serial NOT NULL REFERENCES kindergarden.allergy,
	allternative_dish_id	serial REFERENCES kindergarden.menu
);
CREATE TABLE IF NOT EXISTS kindergarden.employee
(
	employee_ssn			bigint PRIMARY KEY, -- bigint datatype for all persons as identifier of this schema
	address_id				serial NOT NULL REFERENCES kindergarden.address,
	first_name				TEXT NOT NULL,
	last_name				TEXT NOT NULL,
	empl_position			TEXT,
	phone_number			bigserial CHECK (length(CAST(phone_number AS TEXT)) < 12)
);
CREATE TABLE IF NOT EXISTS kindergarden.employee_per_group
(
	group_id				serial NOT NULL REFERENCES kindergarden.kd_groups,
	employee_ssn			bigint NOT NULL REFERENCES kindergarden.employee
);

CREATE TABLE IF NOT EXISTS kindergarden.child
(
	child_ssn				bigint PRIMARY KEY,
	group_id				serial NOT NULL REFERENCES kindergarden.kd_groups, 
	address_id				serial NOT NULL REFERENCES kindergarden.address,
	health_id				serial REFERENCES kindergarden.health_issues,
	first_name				TEXT NOT NULL,
	last_name				TEXT NOT NULL,
	full_name				TEXT GENERATED ALWAYS AS (first_name || ' ' || last_name) STORED NOT NULL, -- added addidionally as asked in task
	birth_date 				date NOT NULL CHECK (birth_date < CURRENT_DATE)
);
CREATE TABLE IF NOT EXISTS kindergarden.responsible_person
(
	person_ssn				bigint PRIMARY KEY,
	child_ssn				bigint NOT NULL REFERENCES kindergarden.child, 
	address_id				serial NOT NULL REFERENCES kindergarden.address,
	first_name				TEXT NOT NULL,
	last_name				TEXT NOT NULL,
	full_name				TEXT GENERATED ALWAYS AS (first_name || ' ' || last_name) STORED NOT NULL, -- added addidionally as asked in task
	phone_number			bigserial NOT NULL CHECK (length(CAST(phone_number AS TEXT)) < 12),
	relationship			TEXT NOT NULL 
);
CREATE TABLE IF NOT EXISTS kindergarden.achievement
(
	id						serial PRIMARY KEY,
	child_ssn				bigint NOT NULL REFERENCES kindergarden.child, 
	entry_date				date DEFAULT CURRENT_date,
	development				TEXT,
	school_preparation		TEXT,
	abilities				TEXT,
	behavior				TEXT
);
CREATE TABLE IF NOT EXISTS kindergarden.attendance
(
	id						serial PRIMARY KEY,
	child_ssn				bigint NOT NULL REFERENCES kindergarden.child, 
	entry_date				date NOT NULL DEFAULT CURRENT_date,
	is_arrived				boolean NOT NULL DEFAULT TRUE,
	reasons					TEXT
);
CREATE TABLE IF NOT EXISTS kindergarden.child_activity
(
	activity_id				serial NOT NULL REFERENCES kindergarden.activity, 
	child_ssn				bigint NOT NULL REFERENCES kindergarden.child
);
CREATE TABLE IF NOT EXISTS kindergarden.shuttle
(
	vehicle_id				serial PRIMARY KEY, 
	employee_ssn			bigint NOT NULL REFERENCES kindergarden.employee, 
	seats					int,
	vehicle_number			TEXT NOT NULL CHECK (length(vehicle_number) < 8)
);
CREATE TABLE IF NOT EXISTS kindergarden.children_per_vehicle
(
	child_ssn				bigint NOT NULL REFERENCES kindergarden.child,
	vehicle_id				serial NOT NULL REFERENCES kindergarden.shuttle
);


/* add additional columns before inserting values >> The default value can be an expression, 
which will be evaluated whenever the default value is inserted (not when the table is created)
A common example is for a timestamp column to have a default of CURRENT_TIMESTAMP, so that it gets set to the time of row insertion. 

I used this to make all list of commands:
DO $$
DECLARE 
    row record; 
    cmd text;
BEGIN
    FOR row IN SELECT schemaname, tablename FROM pg_tables WHERE schemaname = 'kindergarden' LOOP
        cmd := format('ALTER TABLE %I.%I ADD COLUMN record_ts date default current_date', row.schemaname, row.tablename);
        RAISE NOTICE '%', cmd;
        -- EXECUTE cmd;
    END LOOP;
END
$$ LANGUAGE plpgsql; 
*/

ALTER TABLE kindergarden.health_issues ADD COLUMN record_ts DATE DEFAULT CURRENT_DATE; 
ALTER TABLE kindergarden.allergy ADD COLUMN record_ts DATE DEFAULT CURRENT_DATE;  
ALTER TABLE kindergarden.menu ADD COLUMN record_ts DATE DEFAULT CURRENT_DATE; 
ALTER TABLE kindergarden.food_restrictions ADD COLUMN record_ts DATE DEFAULT CURRENT_DATE; 
ALTER TABLE kindergarden.kd_groups ADD COLUMN record_ts DATE DEFAULT CURRENT_DATE; 
ALTER TABLE kindergarden.activity ADD COLUMN record_ts DATE DEFAULT CURRENT_DATE; 
ALTER TABLE kindergarden.address ADD COLUMN record_ts DATE DEFAULT CURRENT_DATE; 
ALTER TABLE kindergarden.achievement ADD COLUMN record_ts DATE DEFAULT CURRENT_DATE; 
ALTER TABLE kindergarden.attendance ADD COLUMN record_ts DATE DEFAULT CURRENT_DATE; 
ALTER TABLE kindergarden.child_activity ADD COLUMN record_ts DATE DEFAULT CURRENT_DATE; 
ALTER TABLE kindergarden.employee_per_group ADD COLUMN record_ts DATE DEFAULT CURRENT_DATE; 
ALTER TABLE kindergarden.employee ADD COLUMN record_ts DATE DEFAULT CURRENT_DATE; 
ALTER TABLE kindergarden.shuttle ADD COLUMN record_ts DATE DEFAULT CURRENT_DATE; 
ALTER TABLE kindergarden.children_per_vehicle ADD COLUMN record_ts DATE DEFAULT CURRENT_DATE; 
ALTER TABLE kindergarden.child ADD COLUMN record_ts DATE DEFAULT CURRENT_DATE; 
ALTER TABLE kindergarden.responsible_person ADD COLUMN record_ts DATE DEFAULT CURRENT_DATE; 



/* INSERT THE VALUES FOR ALL TABLES
 * I know that some of values could be inserted by using select statement, but also I noticed that there are many mistakes in my ER diagram
 * 
 */

INSERT INTO kindergarden.kd_groups (age_range, group_name)
VALUES ('3-4', 'bunnies'),
		('4-5', 'flowers');

INSERT INTO kindergarden.activity (title, day_time, activity_date, activity_decription)
VALUES ('speech therapist', '10:30'::time, '2023-12-14'::date, 'Speech therapy is the assessment and 
		treatment of communication problems and speech disorders'),
		('music', '11:00'::time, '2023-12-20'::date, 'music activities: body percussions; finger plays; 
		memory songs; rhythm instruments; melody and harmony instruments');
	
INSERT INTO kindergarden.address (zip_code, city, district, street, building, apartment)
VALUES (32176, 'Vilnius', 'Jeruzale', 'Reformatu', '37A', '14'),
		(32000, 'Vilnius', 'Baltupiai', 'Rugiu', '5', '4');

INSERT INTO kindergarden.menu (title, nutrition, ingredients, weight, meal_of_day)
SELECT 'omelette', 
		'Energy 300kcals Protein 30 g Total fat 28g Saturated fat 5g Salt 1.2 g',
		'Eggs, milk, oil, salt', 152, 'breakfast'
		WHERE NOT EXISTS (SELECT title FROM kindergarden.menu WHERE title = 'omelette')
UNION
SELECT  'porridge', 
		'155 calories, with 6 grams of protein, 1 gram of fat, 33 grams of carbohydrate, and 5 grams of fiber', 
		'buckwheat, butter, salt', 100, 'breakfast'
		WHERE NOT EXISTS (SELECT title FROM kindergarden.menu WHERE title = 'porridge')
UNION
SELECT 'pancakes with peanut butter', 
		'Energy 300kcals Protein 30 g Total fat 28g Saturated fat 5g Salt 1.2 g',
		'Eggs, milk, peanut butter, flour, oil, sugar', 152, 'supper'
		WHERE NOT EXISTS (SELECT title FROM kindergarden.menu WHERE title = 'pancakes with peanut butter')
UNION
SELECT 'Banana pancakes', 
		'Energy 300kcals Protein 30 g Total fat 28g Saturated fat 5g Salt 1.2 g',
		'banana, milk, flour, oil', 110, 'supper'
		WHERE NOT EXISTS (SELECT title FROM kindergarden.menu WHERE title = 'Banana pancakes');

	

INSERT INTO kindergarden.health_issues (allergy)
VALUES ('allergy for eggs'), ('Allergy for peanuts');
INSERT INTO kindergarden.health_issues (other_disabilities, physical_disabilities)
VALUES ('Autism spectrum disorder', 'Doesn’t speak');

INSERT INTO kindergarden.allergy (health_id, title)
SELECT health_id, allergy FROM kindergarden.health_issues
		WHERE allergy IS NOT NULL;
	
UPDATE kindergarden.allergy 
SET description = 
CASE 
WHEN allergy_id = 1 THEN 'Strictly avoid eggs in food'
WHEN allergy_id = 2 THEN 'Strictly avoid peanuts in food'
END; 
							
INSERT INTO kindergarden.food_restrictions (dish_id, allergy_id, allternative_dish_id)
	SELECT 1, 
	(SELECT allergy_id FROM kindergarden.allergy WHERE lower(title) LIKE '%egg%'), 
	(SELECT dish_id FROM kindergarden.menu WHERE lower(ingredients) NOT LIKE '%egg%' LIMIT 1)
UNION 
	SELECT 4, 
	(SELECT allergy_id FROM kindergarden.allergy WHERE lower(title) LIKE '%peanut%'), 
	(SELECT dish_id FROM kindergarden.menu WHERE lower(ingredients) NOT LIKE '%peanut%' LIMIT 1);

INSERT INTO kindergarden.employee (employee_ssn, address_id, first_name, last_name, empl_position, phone_number)
VALUES (46701012233, 1, 'John', 'Andersen', 'driver', 37065454545),
		(37801012222, 2, 'Kristi', 'Smith', 'teacher', 37064545454);

INSERT INTO kindergarden.employee_per_group 
SELECT (SELECT group_id FROM kindergarden.kd_groups WHERE group_id = 1),
		(SELECT employee_ssn FROM kindergarden.employee WHERE employee_ssn = 37801012222)
UNION 
SELECT (SELECT group_id FROM kindergarden.kd_groups WHERE group_id = 2),
	   (SELECT employee_ssn FROM kindergarden.employee WHERE employee_ssn = 46701012233);
	
	
INSERT INTO kindergarden.child (child_ssn, group_id, address_id, health_id, first_name, last_name, birth_date)
VALUES (51901012233, 2, 2, 1, 'John', 'Smart', '2018-08-08'),
		(61802031111, 1, 1, 3, 'Sara', 'Johnson', '2019-12-12');
	
INSERT INTO kindergarden.responsible_person (person_ssn, child_ssn, address_id, first_name, last_name, phone_number, relationship)
VALUES (48901012222, 51901012233, 2, 'Anna', 'Smart', '37068145567', 'mother'),
		(38901023333, 51901012233, 1, 'David', 'Johnson', '37060070040', 'father');

INSERT INTO kindergarden.achievement (child_ssn, development, school_preparation, abilities, behavior)
VALUES (51901012233, 'Lack of emotional control', 'Does not pronounce the sound R', 'Knows the letters', 'normal'),
		(61802031111, 'Do not eat by herself', 'too small', 'The speach is clear', 'normal');

INSERT INTO kindergarden.attendance (child_ssn, is_arrived)
VALUES (51901012233, 'yes'),
		(61802031111, 'no');
	
INSERT INTO kindergarden.child_activity (activity_id, child_ssn)
VALUES (1, 51901012233),
		(2, 61802031111);

INSERT INTO kindergarden.shuttle (employee_ssn, seats, vehicle_number)
VALUES (46701012233, 16, 'ABC 123'),
		(37801012222, 16, 'TYZ 987');
	
INSERT INTO kindergarden.children_per_vehicle (child_ssn, vehicle_id)
VALUES (51901012233, 1),
		(61802031111, 1);
	
	
