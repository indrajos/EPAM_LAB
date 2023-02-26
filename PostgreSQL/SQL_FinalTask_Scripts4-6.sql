-- FUNCTIONS - 3 -

-- FUNCTION FOR EMPLOYEE TABLE UPDATE
CREATE OR REPLACE FUNCTION fuel.update_employee(PK integer, update_column TEXT, value_to_update TEXT) 											
RETURNS SETOF fuel.employee  
AS $$

BEGIN
	--check PK
	IF NOT EXISTS (SELECT employee_id FROM fuel.employee 
					WHERE employee_id = PK)
	THEN 
		RAISE EXCEPTION 'PK does not exist';
	END IF; 

	-- check colomn name
	IF NOT EXISTS (SELECT column_name FROM information_schema.columns 
					WHERE table_name='employee' and column_name=lower(update_column))
	THEN 
		RAISE EXCEPTION 'Column name does not exist';
	ELSE
		EXECUTE format('UPDATE fuel.employee SET %I = $1 WHERE employee_id = $2', update_column) 
					USING value_to_update, PK;
				
		RETURN query 
		SELECT * FROM fuel.employee WHERE employee_id = PK;
	END IF; 

END 
$$
LANGUAGE plpgsql;

SELECT * FROM fuel.update_employee (4, 'last_name', 'Jameson');


-- FUNCTION FOR ORDERS TABLE INSERTS
CREATE OR REPLACE FUNCTION fuel.insert_orders (st_name text, empl_full_name text) 												
RETURNS SETOF fuel.orders  
AS $$

DECLARE 
	st_id int;
	empl_id int;

BEGIN
	
	-- check employee 
	IF NOT EXISTS (SELECT employee_id FROM fuel.employee 
					WHERE lower(full_name) = lower(empl_full_name)) 
	THEN 
		RAISE EXCEPTION 'Employee does not exist';
	END IF;

	-- check station
	IF NOT EXISTS (SELECT station_id FROM fuel.station  
					WHERE lower(station_name) = lower(st_name))
	THEN 
		RAISE EXCEPTION 'Station does not exist';
	END IF;

	-- get station and employee ids
	SELECT station_id FROM fuel.station WHERE lower(station_name) = lower(st_name) INTO st_id;
	SELECT employee_id FROM fuel.employee WHERE lower(full_name) = lower(empl_full_name) INTO empl_id;
	
	-- check if employee works in that station
	IF NOT EXISTS (SELECT schedule_id  FROM fuel.schedule s  
					WHERE station_id = st_id AND employee_id = empl_id)
	THEN 
		RAISE EXCEPTION 'Employee does not work in this station';

	ELSE
		
	-- inserting data
		INSERT INTO fuel.orders (order_date, station_id, employee_id) 
		VALUES (current_timestamp, st_id, empl_id);
  
		RETURN query 
		SELECT * FROM fuel.orders ORDER BY order_id DESC LIMIT 1 ;
	END IF; 

END 
$$
LANGUAGE plpgsql;

SELECT * FROM fuel.insert_orders ('reformatu station', 'john andersen');


--VIEW - 5 -
CREATE VIEW fuel_stations_sales_last_month AS 
(SELECT s.station_name, l.country, l.city, l.street, l.building,
		e.full_name , e.empl_position,
		o.order_date, p.product_name, op.product_sale_price, op.product_amount
FROM station s
FULL OUTER JOIN locations l
ON s.location_id = l.location_id 
FULL OUTER JOIN schedule s2 
ON s2.station_id = s.station_id 
FULL OUTER JOIN employee e
ON e.employee_id = s2.employee_id
FULL OUTER JOIN orders o
ON o.employee_id = e.employee_id
FULL OUTER JOIN order_product op
ON op.order_id = o.order_id
FULL OUTER JOIN product p
ON p.product_id = op.product_id
WHERE o.order_date >= date_trunc('month', current_date - interval '1' MONTH)
AND  o.order_date < date_trunc('month', current_date));


--ROLE - 6 -
CREATE ROLE manager WITH LOGIN PASSWORD 'password1';
GRANT CONNECT ON DATABASE training TO manager; 
GRANT USAGE ON SCHEMA fuel TO manager;
GRANT SELECT ON ALL TABLES IN SCHEMA fuel TO manager;

--role checks
/* 
SET ROLE manager;

SELECT * FROM information_schema.table_privileges WHERE grantee = 'manager';

SELECT * FROM fuel.employee e ;

INSERT INTO fuel.station (location_id, station_name)
VALUES (3, 'blaaaaa');

DROP OWNED BY manager;
DROP ROLE manager;
*/