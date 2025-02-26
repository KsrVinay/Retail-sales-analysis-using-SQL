create database project_retail_sales
use project_retail_sales

--importing file using ssms import wizard--
/* steps --
-- Step 1: Open SQL Server Management Studio (SSMS) and connect to your database.

-- Step 2: Right-click on the database where you want to import the data.
--         Select "Tasks" → Click "Import Data".

-- Step 3: In the "Choose a Data Source" window:
--         - Select "Microsoft Excel" as the data source.
--         - Click "Browse" and select your Excel file.
--         - Check the box "First row has column names".
--         - Click "Next".

-- Step 4: In the "Choose a Destination" window:
--         - Select "SQL Server Native Client".
--         - Choose your database where data will be imported.
--         - Click "Next".

-- Step 5: In the "Select Source Tables and Views" window:
--         - Select the correct Excel sheet (e.g., "Sheet1$").
--         - Click "Edit Mappings" to check or modify column mappings.
--         - Click "Next".

-- Step 6: Click "Finish" and wait for the import process to complete.

-- Step 7: Verify that data is successfully imported by running:
SELECT * FROM your_table_name;

-- another way to import the data,
BULK INSERT retail_sales
FROM 'C:\Users\YourName\Downloads\retail_sales.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,  -- Skips header
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n',  
    TABLOCK
);

*/

EXEC sp_rename 'dbo.[SQL - Retail Sales Analysis_utf]', 'retail_sales';--changing dataset name into readable simple table name

select * from retail_sales

--Data Cleaning Queries

--check the details of table
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'retail_sales';

--checking the null value details for each column
SELECT 
    COLUMN_NAME, 
    SUM(CASE WHEN COLUMN_NAME IS NULL THEN 1 ELSE 0 END) AS NullCount
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'retail_sales'
GROUP BY COLUMN_NAME
HAVING SUM(CASE WHEN COLUMN_NAME IS NULL THEN 1 ELSE 0 END) > 0;

-- Count total records
SELECT COUNT(*) FROM retail_sales;


--Data Exploration Queries

-- Total number of sales
SELECT COUNT(*) AS total_sales FROM retail_sales;

-- Unique customers
SELECT COUNT(DISTINCT customer_id) AS unique_customers FROM retail_sales;

-- List unique product categories
SELECT DISTINCT category FROM retail_sales;

--Data Analysis & Business Questions

-- 1. Total Revenue Generated
SELECT SUM(total_sale) AS total_revenue FROM retail_sales;

-- 2. Total Number of Transactions
SELECT COUNT(transactions_id) AS total_transactions FROM retail_sales;

-- 3. Top 5 Selling Categories
SELECT TOP 5 category, SUM(quantiy) AS total_quantity
FROM retail_sales
GROUP BY category
ORDER BY total_quantity DESC;

-- 4. Monthly Sales Trend
SELECT 
    FORMAT(sale_date, 'yyyy-MM') AS month, 
    SUM(total_sale) AS monthly_revenue
FROM retail_sales
GROUP BY FORMAT(sale_date, 'yyyy-MM')
ORDER BY month;

-- 5. Best Performing Customers (Top 5 by Spending)
SELECT TOP 5 customer_id, SUM(total_sale) AS total_spent
FROM retail_sales
GROUP BY customer_id
ORDER BY total_spent DESC;

-- 6. Gender-wise Revenue Analysis
SELECT gender, SUM(total_sale) AS revenue
FROM retail_sales
GROUP BY gender
ORDER BY revenue DESC;

-- 7. Age Group Analysis (Using CASE WHEN for Bucketing)
SELECT 
    CASE 
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 50 THEN '36-50'
        ELSE '50+'
    END AS age_group, 
    SUM(total_sale) AS total_spent
FROM retail_sales
GROUP BY 
    CASE 
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 50 THEN '36-50'
        ELSE '50+'
    END
ORDER BY total_spent DESC;

-- 8. Peak Sales Hours
SELECT 
    DATEPART(HOUR, sale_time) AS hour_of_day, 
    COUNT(transactions_id) AS total_sales
FROM retail_sales
GROUP BY DATEPART(HOUR, sale_time)
ORDER BY total_sales DESC;

-- 9. Profitability Analysis 
SELECT category, 
       SUM(total_sale - cogs) AS total_profit
FROM retail_sales
GROUP BY category
ORDER BY total_profit DESC;

-- 10. Customer Retention: Repeat Customers vs New Customers
WITH RepeatCustomers AS (
    SELECT customer_id
    FROM retail_sales
    GROUP BY customer_id
    HAVING COUNT(transactions_id) > 1  -- Customers who made more than one purchase
)
SELECT 
    COUNT(DISTINCT r.customer_id) AS total_customers,  -- Total unique customers
    COUNT(DISTINCT rc.customer_id) AS repeat_customers  -- Customers with more than one transaction
FROM retail_sales r
LEFT JOIN RepeatCustomers rc ON r.customer_id = rc.customer_id;

-- STEP 4: Business Insights (SQL Server)

-- 1. Find the Most Profitable Category
SELECT TOP 1 category, SUM(total_sale - cogs) AS total_profit
FROM retail_sales
GROUP BY category
ORDER BY total_profit DESC;

-- 2. Which Day of the Week Has the Highest Sales?
SELECT TOP 1 
    DATENAME(WEEKDAY, sale_date) AS day_of_week,
    SUM(total_sale) AS total_revenue
FROM retail_sales
GROUP BY DATENAME(WEEKDAY, sale_date)
ORDER BY total_revenue DESC;

-- 3. Average Spending Per Customer
SELECT AVG(total_sale) AS avg_spending_per_customer
FROM retail_sales;


-- 5. Seasonal Sales Trends (By Quarter)
SELECT 
    DATEPART(QUARTER, sale_date) AS quarter,
    SUM(total_sale) AS total_revenue
FROM retail_sales
GROUP BY DATEPART(QUARTER, sale_date)
ORDER BY total_revenue DESC;










