CREATE OR REPLACE FUNCTION public.clients_info(client_id integer,
													left_boundary timestamptz,
													right_boundary timestamptz) 

RETURNS TABLE (metric_name TEXT, metric_value TEXT) 
AS $$

WITH client_information AS (
	 						SELECT concat_ws(' ', c.first_name, c.last_name, c.email) AS client_info
	 						FROM customer c 
	 						WHERE c.customer_id = client_id),

	 
	 films_information AS (
							SELECT string_agg(f2.title, ', ') AS films_list,
				 				CAST(count(r.inventory_id) AS TEXT) AS count_inventory
				 			FROM film f2
				 			JOIN inventory i 
				 			ON f2.film_id = i.film_id 
				 			JOIN rental r 
				 			ON r.inventory_id = i.inventory_id 
				 			WHERE r.customer_id = client_id AND r.rental_id in ( SELECT rental_id
				 															FROM rental r3
				 															WHERE r3.customer_id = client_id 
				 															AND r3.rental_date 
				 															BETWEEN left_boundary AND right_boundary)), 
	 					
	 payments AS (
	 			SELECT CAST(count(p.payment_id) AS TEXT) AS count_payments, 
	 			CAST(sum(p.amount) AS TEXT) AS total
	 			FROM payment p
	 			JOIN rental r2 
	 			ON p.rental_id = r2.rental_id 
	 			WHERE p.customer_id = client_id AND r2.rental_id in ( SELECT rental_id
	 															FROM rental r3
	 															WHERE r3.customer_id = client_id 
	 															AND r3.rental_date 
	 															BETWEEN left_boundary AND right_boundary))
	 															

	 					
	 
	 
	 SELECT 'client information' AS metric_name, client_info AS metric_value FROM client_information 
	 UNION ALL
	 SELECT 'number of films', count_inventory FROM films_information
	 UNION ALL
	 SELECT 'titles of films', films_list FROM films_information 
	 UNION ALL 
	 SELECT 'number of payments', count_payments FROM payments 
	 UNION ALL
	 SELECT 'total amount', total FROM payments


$$ LANGUAGE sql;

SELECT * FROM public.clients_info(123, '2005-05-30 23:47:56.000 +0300', '2005-07-08 18:54:00.712 +0300');