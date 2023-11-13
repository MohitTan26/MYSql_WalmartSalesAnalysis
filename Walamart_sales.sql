Create database salesDataWalmart; 

USE salesDataWalmart;

create table sales(
	invoice_id 	VARCHAR(30) NOT NULL PRIMARY KEY,
    branch 	VARCHAR(30) NOT NULL,
    city  VARCHAR(30) NOT NULL,
    customer_line VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(30) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    VAT FLOAT(6,4) NOT NULL,
    total DECIMAL(12,4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12,4) NOT NULL,
    rating FLOAT(2,1)
);

SELECT *
FROM sales;





-- ----------------------------------------------------------------------------------
-- FEATURE ENGINEERING --
-- ----------------------------------------------------------------------------------

-- INSERT COLUMN time_of_day--

Select
	time,
	(CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "MORNING"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "AFTERNOON"
        ELSE "EVENING"
	END
    )AS time_of_day
FROM sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales
SET time_of_day= (
	CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "MORNING"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "AFTERNOON"
        ELSE "EVENING"
	END
    );
	
-- ADDING COLUMN day_name --

ALTER TABLE sales ADD COLUMN day_name VARCHAR(20);

UPDATE sales
SET day_name= DAYNAME(date);

-- ADDING COLUMN month_name --

ALTER TABLE sales ADD COLUMN month_name VARCHAR(20);

UPDATE sales
SET month_name= MONTHNAME(date);

-- FEATURE ENGINEERING COMPLETED --

SELECT * FROM sales;

-- ----------------------------------------------------------------------------------
-- GENERIC QUERIES--
-- ----------------------------------------------------------------------------------

-- How many unique cities does the data have?
SELECT
	COUNT(DISTINCT city) as number_of_citites 
FROM sales;

-- In which city is each branch?
SELECT 
	DISTINCT(city), branch
FROM sales;

-- ----------------------------------------------------------------------------------
-- PRODUCT ---- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------

-- How many unique product lines does the data have?
SELECT 
	COUNT(DISTINCT product_line) as number_of_product_lines
FROM sales;

-- What is the most common payment method?
SELECT
	COUNT(payment_method) AS count, 
    payment_method
FROM sales
GROUP BY payment_method
ORDER BY count desc; 

-- What is the most selling product line?
SELECT 
	COUNT(product_line) as count, 
    product_line
FROM sales
GROUP BY product_line
ORDER BY count DESC;

-- What is the total revenue by month?
SELECT 
	SUM(total) AS total_revenue, 
    month_name
FROM sales
GROUP BY month_name
ORDER BY total_revenue DESC;

-- What month had the largest COGS?
SELECT 
	SUM(cogs) as cogs, 
    month_name as month
FROM sales
GROUP BY month
ORDER BY cogs DESC;

-- What product line had the largest revenue?
SELECT 
	SUM(total) as total_revenue,
    product_line
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC;

-- What is the city with the largest revenue?
SELECT
	SUM(total) AS total_revenue,
    city
FROM sales
GROUP BY city
ORDER BY total_revenue DESC;
	
-- What product line had the largest VAT?
SELECT
	AVG(VAT) AS vat,
    product_line
FROM sales
GROUP BY PRODUCT_LINE
ORDER BY vat DESC;

-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
SELECT	
	AVG(quantity) AS avg_qty,
    product_line
FROM sales
GROUP BY product_line;

SELECT
	product_line,
    CASE
		WHEN AVG(quantity) > 6 THEN 'GOOD'
		ELSE 'BAD'
    END AS remark
FROM sales
GROUP BY product_line;

-- Which branch sold more products than average product sold?
SELECT
	AVG(quantity) AS avg_qty
FROM sales;

SELECT
	branch,
    SUM(quantity) AS qty
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);
    
-- What is the most common product line by gender?
SELECT
	gender,
	product_line,
    COUNT(gender) AS total_gender
FROM sales
GROUP BY gender, product_line
ORDER BY total_gender DESC;

-- What is the average rating of each product line?
SELECT
	product_line,
	ROUND(AVG(rating),2 ) AS avg_rating
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;

-- ----------------------------------------------------------------------------------
-- Sales-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------

-- Number of sales made in each time of the day per weekday
SELECT
	time_of_day,
    COUNT(*) AS total_sales
FROM sales
WHERE day_name="Sunday"
GROUP BY time_of_day;

-- Which of the customer types brings the most revenue?
SELECT
	customer_line,
	SUM(total) AS total_revenue
FROM sales
GROUP BY customer_line
ORDER BY total_revenue DESC;

-- Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT 
	AVG(VAT) AS avg_vat,
    city
FROM sales
GROUP BY city
ORDER BY avg_vat DESC;

-- Which customer type pays the most in VAT?
SELECT
	SUM(VAT) AS total_vat,
    customer_line
FROM sales
GROUP BY customer_line
ORDER BY total_vat DESC;

-- ----------------------------------------------------------------------------------
-- Customer-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------

-- How many unique customer types does the data have?
SELECT
	DISTINCT customer_line
FROM sales;

-- How many unique payment methods does the data have?
SELECT
	DISTINCT payment_method
FROM sales;

-- What is the most common customer type?
SELECT
	COUNT(*) AS total_customer,
    customer_line
FROM sales
GROUP BY customer_line
ORDER BY total_customer DESC;

-- What is the gender of most of the customers?
SELECT
	COUNT(*) AS customers,
    gender
FROM sales
GROUP BY gender
ORDER BY customers DESC;

-- What is the gender distribution per branch?
SELECT
	gender,
    branch,
    COUNT(*) as total_distribtion
FROM sales
GROUP BY branch, gender
ORDER BY branch;

-- Which day fo the week has the best avg ratings?
SELECT
	day_name,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY day_name
ORDER BY avg_rating DESC;

-- Which day of the week has the best average ratings per branch?
SELECT
	branch,
	day_name,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY day_name, branch
ORDER BY avg_rating DESC;