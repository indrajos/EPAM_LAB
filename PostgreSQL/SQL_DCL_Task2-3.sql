
-- 2 -
CREATE ROLE db_developer WITH LOGIN PASSWORD 'password1';
	GRANT CONNECT ON DATABASE "newDB" TO db_developer; -- DB name may cause error, need TO change
	GRANT USAGE, CREATE ON SCHEMA public TO db_developer;
	GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO db_developer;
	GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO db_developer;

/*
SELECT * FROM information_schema.table_privileges WHERE grantee = 'db_developer';
SET ROLE db_developer;
INSERT INTO film (title, language_id)
VALUES ('ababa', 1);
 */

CREATE ROLE backend_tester;   
	GRANT CONNECT ON DATABASE "newDB" TO backend_tester; 
	GRANT USAGE ON SCHEMA public TO backend_tester;
	GRANT SELECT ON ALL TABLES IN SCHEMA public TO backend_tester;

/*
SELECT * FROM information_schema.table_privileges WHERE grantee = 'backend_tester';
SET ROLE backend_tester;
INSERT INTO film (title, language_id)
VALUES ('ababa', 1);
*/

CREATE ROLE customer; 
	GRANT CONNECT ON DATABASE "newDB" TO customer;
	GRANT SELECT ON TABLE public.film, public.actor, public.customer  TO customer;

/*
SELECT * FROM information_schema.table_privileges WHERE grantee = 'customer';
SET ROLE customer;
SELECT * FROM public.film;
SELECT * FROM public.city;
 */


CREATE ROLE client_eleanor_hunt  WITH LOGIN PASSWORD 'password2';
GRANT customer TO client_eleanor_hunt;

-- 3 -
ALTER TABLE public.rental ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customer ENABLE ROW LEVEL SECURITY;


CREATE POLICY policy_customer ON public.customer TO customer
USING ('client_' || lower(first_name) || '_' || lower(last_name) = current_user);

GRANT SELECT ON TABLE public.customer TO client_eleanor_hunt;			


CREATE POLICY policy_rental ON public.rental TO customer
USING (customer_id = (SELECT customer_id FROM customer c 
					WHERE 'client_' || lower(c.first_name) || '_' || lower(c.last_name) = current_user));

GRANT SELECT ON TABLE public.rental TO client_eleanor_hunt;	


CREATE POLICY policy_payment ON public.payment TO customer
USING (payment.customer_id = (SELECT customer_id FROM public.customer c 
								WHERE 'client_' || lower(c.first_name) || '_' || lower(c.last_name) = current_user));

GRANT SELECT ON TABLE payment TO client_eleanor_hunt;

/*
SELECT * FROM information_schema.table_privileges WHERE grantee = 'customer';
 SET ROLE client_eleanor_hunt;
 SELECT * FROM public.film;
SELECT * FROM public.customer;
 SELECT * FROM public.payment;
 */



/*
 my drafts
 
SELECT current_user;
SELECT SESSION_USER;
SELECT rolname FROM pg_roles;
select * from pg_policies


SET ROLE postgres

SET ROLE client_eleanor_hunt
SET ROLE db_developer
SET ROLE backend_tester
SET ROLE customer


DROP OWNED BY client_eleanor_hunt;
DROP ROLE client_eleanor_hunt;
DROP OWNED BY db_developer;
DROP ROLE db_developer;


DROP POLICY client_payment ON payment;
DROP POLICY policy_rental ON rental;
DROP POLICY policy_customer ON customer;


*/


