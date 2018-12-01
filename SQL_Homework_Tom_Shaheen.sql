USE sakila

-- 1a. Display the first and last names of all actors from the table `actor`.
SELECT first_name, last_name 
FROM actor

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT CONCAT(UPPER(first_name), ' ', UPPER(last_name))
AS 'Actor Name'
FROM actor;

-- * 2a. You need to find the ID number, first name, and last name of an actor,
-- of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

SELECT actor_ID, first_name, last_name FROM actor
WHERE first_name ="Joe";

-- * 2b. Find all actors whose last name contain the letters `GEN`:

SELECT actor_ID, first_name, last_name FROM actor
WHERE last_name LIKE "%gen%";

-- * 2c. Find all actors whose last names contain the letters `LI`. 
-- This time, order the rows by last name and first name, in that order:
SELECT actor_ID, first_name, last_name FROM actor
WHERE last_name LIKE "%li%"
ORDER BY last_name, first_name;

-- * 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: 
-- Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM country
WHERE country IN('Afghanistan', 'Bangladesh', 'China');

-- * 3a. You want to keep a description of each actor. You don't think you will be performing queries on a 
-- description, so create a column in the table `actor` named `description` and use the data type `BLOB` 
-- (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
ALTER TABLE actor
ADD description BLOB;
  
-- * 3b. Very quickly you realize that entering descriptions for each actor is too much effort. 
-- Delete the `description` column.
-- ALTER TABLE "table_name" DROP "column_name";
ALTER TABLE actor
DROP COLUMN description;


-- * 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name 'Last Name', count(last_name) 'Number of Actors with Last Name'
FROM actor 
GROUP by last_name;

-- * 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
SELECT last_name 'Last Name', count(last_name) 'Number of Actors with Last Name'
FROM actor 
GROUP by last_name
HAVING count(last_name)>1;

-- * 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. 
-- Write a query to fix the record.
UPDATE actor 
SET first_name='Harpo'
WHERE first_name='Groucho'
AND last_name='Williams';

-- * 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. 
-- It turns out that `GROUCHO` was the correct name after all! 
-- In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE actor
SET first_name='Groucho'
WHERE first_name='Harpo'
AND last_name='Williams';
-- * 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
SHOW CREATE TABLE address;


SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME='address';

  -- * Hint: [https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html]
  --         (https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html)

-- * 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. 
-- Use the tables `staff` and `address`:
SELECT s.first_name, s.last_name, a.address 
FROM staff s JOIN address a
ON s.address_id=a.address_id;

-- * 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005.
--  Use tables `staff` and `payment`.
SELECT s.first_name, s.last_name, SUM(amount) AS 'Total Sales' 
FROM payment p JOIN staff s
ON p.staff_id=s.staff_id
GROUP BY s.staff_id;

-- * 6c. List each film and the number of actors who are listed for that film.
--  Use tables `film_actor` and `film`. Use inner join.
SELECT f.title AS 'Film Title', 
COUNT(a.actor_id) AS 'Number of Actors'
FROM  film f INNER JOIN film_actor a 
ON f.film_id = a.film_id
GROUP BY f.title;

-- * 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT COUNT(i.inventory_id) AS 'Number of Copies'
FROM inventory i
WHERE i.film_id IN
(
SELECT f.film_id  FROM film f
WHERE f.title = 'Hunchback Impossible'
);

-- * 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. 
-- List the customers alphabetically by last name:
SELECT c.last_name, c.first_name, SUM(p.amount) "Total Payments"
FROM payment p
JOIN customer c
ON c.customer_id=p.customer_id
GROUP BY c.customer_id
ORDER BY c.last_name, c.first_name;

 --  ![Total amount paid](Images/total_payment.png)

-- * 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters `K` and `Q` 
-- whose language is English.
SELECT f.title FROM film f
WHERE (f.title LIKE 'K%'OR f.title LIKE 'Q%')
AND f.language_id IN
(
SELECT l.language_id FROM language l
WHERE l.name='English'
);
-- * 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.

SELECT a.first_name, a.last_name FROM actor a
WHERE a. actor_id IN
(
SELECT fa.actor_id
FROM film_actor fa
WHERE fa.film_id IN
	(SELECT f.film_id
    FROM film f
    WHERE f.title = 'Alone Trip'
    )
);

-- * 7c. You want to run an email marketing campaign in Canada, for which you will need the names 
-- and email addresses of all Canadian customers. Use joins to retrieve this information.

SELECT cu.first_name, cu.last_name, cu.email 
FROM city ct
JOIN country cy
ON cy.country_id=ct.country_id
JOIN address a 
ON ct.city_id = a.city_id
JOIN customer cu
ON cu.address_id=a.address_id
WHERE cy.country = 'Canada';


-- * 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as _family_ films.

SELECT f.title
FROM film f
WHERE f.film_id IN
(
SELECT fc.film_id 
FROM film_category fc
JOIN category c
ON c.category_id = fc.category_id
WHERE c.name='Family'    
);

-- * 7e. Display the most frequently rented movies in descending order.

SELECT f.title, COUNT(i.film_id) AS 'Number Of Rentals'  
FROM rental r
JOIN inventory i
ON r.inventory_id=i.inventory_id
JOIN film f ON
i.film_id=f.film_id

GROUP BY i.film_id
HAVING COUNT(i.film_id)>'20'
ORDER BY COUNT(i.film_id) DESC;

-- * 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT * FROM total_sales_t;

-- * 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id 'Store ID', c.City, cy.Country 
FROM store s
JOIN address a
ON s.address_id=a.address_id
JOIN city c
ON a.city_id=c.city_id
JOIN country cy
ON c.country_id=cy.country_id;

-- * 7h. List the top five genres in gross revenue in descending order. 
-- (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT * FROM category
SELECT * FROM film_category
SELECT * FROM inventory
SELECT * FROM payment
SELECT * FROM rental

SELECT c.name, SUM(p.amount) 'Total Revenue' FROM payment p
JOIN rental r
ON p.customer_id=r.customer_id
JOIN inventory i
ON r.inventory_id=i.inventory_id
JOIN film f
ON i.film_id=f.film_id
JOIN film_category fc
ON f.film_id=fc.film_id
JOIN category c
ON fc.category_id=c.category_id
GROUP BY c.name 
ORDER by SUM(p.amount) DESC
LIMIT 5;

-- * 8a. In your new role as an executive, you would like to have an easy way of viewing the 
-- Top five genres by gross revenue. Use the solution from the problem above to create a view. 
-- If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW Top_5_Genres AS
SELECT c.name 'Genre', SUM(p.amount) 'Total Revenue' FROM payment p
JOIN rental r
ON p.customer_id=r.customer_id
JOIN inventory i
ON r.inventory_id=i.inventory_id
JOIN film f
ON i.film_id=f.film_id
JOIN film_category fc
ON f.film_id=fc.film_id
JOIN category c
ON fc.category_id=c.category_id
GROUP BY c.name 
ORDER by SUM(p.amount) DESC
LIMIT 5;

-- * 8b. How would you display the view that you created in 8a?
SELECT * FROM Top_5_Genres;

-- * 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.

DROP VIEW Top_5_Genres;
-- ## Appendix: List of Tables in the Sakila DB

-- * A schema is also available as `sakila_schema.svg`. Open it with a browser to view.

-- ```sql
-- 'actor'
-- 'actor_info'
-- 'address'
-- 'category'
-- 'city'
-- 'country'
-- 'customer'
-- 'customer_list'
-- 'film'
-- 'film_actor'
-- 'film_category'
-- 'film_list'
-- 'film_text'
-- 'inventory'
-- 'language'
-- 'nicer_but_slower_film_list'
-- 'payment'
-- 'rental'
-- 'sales_by_film_category'
-- 'sales_by_store'
-- 'staff'
-- 'staff_list'
-- 'store'
-- ```

-- ## Uploading Homework

-- * To submit this homework using BootCampSpot:

  -- * Create a GitHub repository.
  -- * Upload your .sql file with the completed queries.
  --  Submit a link to your GitHub repo through BootCampSpot.