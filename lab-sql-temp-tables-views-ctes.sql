-- Creating a Customer Summary Report

/* In this exercise, you will create a customer summary report that summarizes key information about customers in the Sakila database, including their rental history and payment details.
The report will be generated using a combination of views, CTEs, and temporary tables.*/

USE sakila;

-- Step 1: Create a View
-- First, create a view that summarizes rental information for each customer. The view should include the customer's ID, name, email address, and total number of rentals (rental_count).

CREATE VIEW rental_summary AS
SELECT c.customer_id, c.first_name, c.last_name, c.email, COUNT(r.rental_id) AS rental_count
FROM customer AS c
LEFT JOIN rental AS r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email
ORDER BY rental_count DESC;

SELECT * FROM rental_summary;

-- Step 2: Create a Temporary Table
/* Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid).
The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer. */

CREATE TEMPORARY TABLE payment_summary
SELECT r.customer_id, SUM(p.amount) AS total_paid
FROM rental_summary AS r
JOIN payment AS p ON r.customer_id = p.customer_id
GROUP BY r.customer_id
ORDER BY total_paid DESC;

SELECT * FROM payment_summary;

-- Step 3: Create a CTE and the Customer Summary Report
/* Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2.
The CTE should include the customer's name, email address, rental count, and total amount paid.
Next, using the CTE, create the query to generate the final customer summary report, which should include:
customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count. */

WITH customer_summary_report AS (
SELECT r.first_name, r.last_name, r.email, r.rental_count, p.total_paid
FROM rental_summary AS r
JOIN payment_summary AS p ON r.customer_id = p.customer_id
ORDER BY p.total_paid DESC
)
SELECT *, ROUND((total_paid / rental_count), 2) AS average_payment_per_rental
FROM customer_summary_report
ORDER BY average_payment_per_rental DESC;