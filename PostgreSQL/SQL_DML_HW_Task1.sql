--TASK 1

INSERT INTO public.film (title, language_id, rental_duration, rental_rate) 
SELECT 'KILL BILL', (SELECT language_id FROM public."language" WHERE lower("name") = 'english'), 1, 4.99
WHERE NOT EXISTS (SELECT title FROM public.film WHERE lower(title) = 'KILL BILL')
UNION 
SELECT 'HARRY POTTER', (SELECT language_id FROM public."language" WHERE lower("name") = 'english'), 2, 9.99
WHERE NOT EXISTS (SELECT title FROM public.film WHERE lower(title) = 'HARRY POTTER')
UNION 
SELECT 'THE LORD OF THE RINGS', (SELECT language_id FROM public."language" WHERE lower("name") = 'english'), 3, 19.99
WHERE NOT EXISTS (SELECT title FROM public.film WHERE lower(title) = 'THE LORD OF THE RINGS')
RETURNING *;
	
INSERT INTO public.actor (first_name, last_name) 
SELECT 'UMA', 'THURMAN'
WHERE NOT EXISTS (SELECT * FROM public.actor WHERE upper(first_name) = 'UMA' AND upper(last_name) = 'THURMAN')
UNION 
SELECT 'DAVID', 'CARRADINE'
WHERE NOT EXISTS (SELECT * FROM public.actor WHERE upper(first_name) = 'DAVID' AND upper(last_name) = 'CARRADINE')
UNION 
SELECT 'ELIJAH', 'WOOD'
WHERE NOT EXISTS (SELECT * FROM public.actor WHERE upper(first_name) = 'ELIJAH' AND upper(last_name) = 'WOOD')
UNION 
SELECT 'IAN', 'MCKELLEN'
WHERE NOT EXISTS (SELECT * FROM public.actor WHERE upper(first_name) = 'IAN' AND upper(last_name) = 'MCKELLEN')
UNION 
SELECT 'DANIEL', 'RADCLIFFE'
WHERE NOT EXISTS (SELECT * FROM public.actor WHERE upper(first_name) = 'DANIEL' AND upper(last_name) = 'RADCLIFFE')
UNION 
SELECT 'RUPERT', 'GRINT'
WHERE NOT EXISTS (SELECT * FROM public.actor WHERE upper(first_name) = 'RUPERT' AND upper(last_name) = 'GRINT')
RETURNING *;
-- all actors are already in DB

INSERT INTO film_actor (actor_id, film_id) 
SELECT 
(SELECT actor_id FROM public.actor WHERE upper(first_name) = 'UMA' AND upper(last_name) = 'THURMAN'),
(SELECT film_id FROM public.film WHERE upper(title) = 'KILL BILL')
UNION
SELECT 
(SELECT actor_id FROM public.actor WHERE upper(first_name) = 'DAVID' AND upper(last_name) = 'CARRADINE'),
(SELECT film_id FROM public.film WHERE upper(title) = 'KILL BILL')
UNION
SELECT 
(SELECT actor_id FROM public.actor WHERE upper(first_name) = 'ELIJAH' AND upper(last_name) = 'WOOD'),
(SELECT film_id FROM public.film WHERE upper(title) = 'THE LORD OF THE RINGS')
UNION 
SELECT 
(SELECT actor_id FROM public.actor WHERE upper(first_name) = 'IAN' AND upper(last_name) = 'MCKELLEN'),
(SELECT film_id FROM public.film WHERE upper(title) = 'THE LORD OF THE RINGS')
UNION
SELECT 
(SELECT actor_id FROM public.actor WHERE upper(first_name) = 'DANIEL' AND upper(last_name) = 'RADCLIFFE'),
(SELECT film_id FROM public.film WHERE upper(title) = 'HARRY POTTER')
UNION 
SELECT  
(SELECT actor_id FROM public.actor WHERE upper(first_name) = 'RUPERT' AND upper(last_name) = 'GRINT'),
(SELECT film_id FROM public.film WHERE upper(title) = 'HARRY POTTER')
RETURNING *;

INSERT INTO inventory (film_id, store_id)
SELECT 
(SELECT film_id FROM public.film WHERE upper(title) = 'HARRY POTTER'), 
(SELECT store_id FROM public.store WHERE store_id = 2)
UNION
SELECT
(SELECT film_id FROM public.film WHERE upper(title) = 'KILL BILL'),
(SELECT store_id FROM public.store WHERE store_id = 2)
UNION
SELECT
(SELECT film_id FROM public.film WHERE upper(title) = 'THE LORD OF THE RINGS'),
(SELECT store_id FROM public.store WHERE store_id = 2)
RETURNING *;
		
	
WITH payments_43(customer_id) AS (	
SELECT customer_id, count(payment_id) AS payments
FROM payment 
GROUP BY customer_id
HAVING  count(payment_id) > 42
ORDER BY customer_id),

rentals_43(customer_id) AS (
SELECT customer_id, count(rental_id) AS rentals
FROM rental  
GROUP BY customer_id
HAVING  count(rental_id) > 42
ORDER BY customer_id)
--I chose customerID 82

UPDATE public.customer 
SET 
	first_name = 'INDRE',
	last_name = 'NARKEVICIENE',
	email = 'INDRE.NARKEVICIENE@gmail.com',
	address_id = 12,
	create_date = current_date
WHERE customer_id = 82 
AND customer_id IN (SELECT customer_id FROM rentals_43)
AND customer_id  IN (SELECT customer_id FROM payments_43);


DELETE FROM public.payment WHERE customer_id IN 
(SELECT customer_id FROM public.customer WHERE upper(first_name) = 'INDRE' AND upper(last_name) = 'NARKEVICIENE');
DELETE FROM rental  WHERE customer_id IN
(SELECT customer_id FROM public.customer WHERE upper(first_name) = 'INDRE' AND upper(last_name) = 'NARKEVICIENE');



-- TASK or add records for the   first half of 2017
INSERT INTO rental (rental_date, inventory_id, customer_id, return_date, staff_id, last_update)
VALUES (current_date, 4582, 81, current_date, 2, current_date),
		(current_date, 4583, 81, current_date, 5, current_date),
		(current_date, 4584, 81, current_date, 2, current_date)
RETURNING * ;

INSERT INTO payment (customer_id, staff_id, rental_id, amount, payment_date)
VALUES (81, 2, 32299, 15, '2017-01-10'::timestamp),
		(81, 5, 32298, 10, '2017-02-10'::timestamp),
		(81, 2, 32297, 18, '2017-03-10'::timestamp)
RETURNING *;

