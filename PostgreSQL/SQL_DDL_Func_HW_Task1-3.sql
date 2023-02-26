-- 1
CREATE OR REPLACE FUNCTION public.most_popular_films_by_countries(TEXT[]) 
RETURNS TABLE (country text, film text, rating mpaa_rating, "language" bpchar, "length" int2, "release year" year) 
AS $$
		WITH cte AS (
			SELECT DISTINCT ON (c.country) c.country, f.title, f.rating, l."name" , f."length", f.release_year, count(f.title) AS top
			FROM country c 
			JOIN city c2 
				ON c.country_id = c2.country_id 
			JOIN address a  
				ON c2.city_id  = a.city_id 
			JOIN customer c3 
				ON c3.address_id = a.address_id 
			JOIN rental r 
				ON r.customer_id = c3.customer_id 
			JOIN inventory inv 
				ON r.inventory_id = inv.inventory_id 
			JOIN film f 
				ON f.film_id = inv.film_id 
			JOIN "language" l 
				ON f.language_id = l.language_id 
			WHERE c.country = ANY ($1)
			GROUP BY c.country, f.title, f.rating, l."name" , f."length", f.release_year
			ORDER BY c.country, top DESC
			)
		
	SELECT country, title, rating, "name", "length", release_year
	FROM cte 
	
$$ LANGUAGE sql;

select * FROM public.most_popular_films_by_countries (ARRAY['Afghanistan', 'Brazil','United States']);


-- 2
CREATE OR REPLACE FUNCTION public.films_in_stock_by_title(title_text TEXT) 
RETURNS TABLE (row_num int, inventory_id int, film_title text, "language" bpchar, customer text, rental_date timestamptz) 
AS $$
   
 DECLARE
		inventory_array integer [];
 		i integer;					 -- inventory id
 		counter integer:=0;
   		
 BEGIN
	 -- create inventory id array with keyword
  		SELECT ARRAY (SELECT DISTINCT(i2.inventory_id)
		FROM inventory i2
		JOIN film f2
		ON f2.film_id = i2.film_id 
		WHERE lower(f2.title) LIKE lower(title_text)) INTO inventory_array;

	-- take inventory id one by one and check if it is in stock
  		FOREACH i IN ARRAY inventory_array
  		LOOP
   	  
   			IF inventory_in_stock(i) = FALSE 
				THEN RAISE EXCEPTION 'a movie with that title was not found. Missing inventory id: %', i;	
		
		-- if film is in stock create table with needed information
   			ELSE
   			counter = counter + 1; 
   			RETURN query 
			 	SELECT 
			 		counter AS row_num, 
			 		inv.inventory_id, 
			 		f.title, 
			 		l."name", 
			 		c.first_name ||' '|| c.last_name AS customer, 
			 		r.rental_date
			 	FROM inventory inv
			 	JOIN film f ON inv.film_id = f.film_id 
			 	JOIN "language" l ON f.language_id = l.language_id
			 	JOIN rental r ON r.inventory_id = inv.inventory_id
				JOIN customer c ON c.customer_id = r.customer_id 
				WHERE r.rental_date = (
										SELECT max(r.rental_date) 
										FROM rental r 
										WHERE r.inventory_id = i)
				AND r.inventory_id = i;
	
			END IF;
	END LOOP;
END; 
$$ LANGUAGE plpgsql;
	
 SELECT * FROM  public.films_in_stock_by_title('%LoVe%');




-- 3 -
CREATE OR REPLACE FUNCTION public.insert_film(
											TEXT, 
											YEAR DEFAULT EXTRACT(YEAR FROM current_date),
											TEXT DEFAULT 'russian') 											
RETURNS integer
AS $$

DECLARE 
	returning_id integer;

BEGIN
	
	-- insert language if not exists	
	IF EXISTS (SELECT "name" FROM public."language" WHERE lower("name") = lower($3))
	THEN 
		RAISE NOTICE 'language exists';
	ELSE
		INSERT INTO public."language" ("name")
		VALUES ($3);
	END IF; 
	
	
	-- insert movie if not exists	
	IF EXISTS (SELECT title FROM public.film f WHERE upper(title) = upper($1))
	THEN 
		RAISE EXCEPTION 'film with this title already exists';
	ELSE 
    	INSERT INTO public.film (title, release_year, language_id) 
   		SELECT  $1, $2::YEAR,(SELECT language_id FROM "language" WHERE lower("name") = lower($3))
   		RETURNING film_id INTO returning_id;
   	END IF;
	RETURN returning_id;

END
$$
LANGUAGE plpgsql;

