

Use grocery_sales_database;


/* ---------------------------------------------------------
   SECTION 1 — BASIC BUSINESS METRICS
--------------------------------------------------------- */

-- Q1. Calculate the total sales revenue, total number of orders, and average order value.
SELECT 
    SUM(p.Price * s.Quantity) AS revenue,
    COUNT(*) AS orders,
    AVG(p.Price * s.Quantity) AS avg_order_value
FROM Sales s
JOIN Products p ON s.ProductID = p.ProductID;

-- Q2. Calculate the total quantity sold for each product.
SELECT 
    p.ProductName,
    SUM(s.Quantity) AS qty_sold
FROM Products p
JOIN Sales s ON p.ProductID = s.ProductID
GROUP BY p.ProductName;

-- Q3. Generate a category-wise summary of total revenue and total quantity sold.
SELECT 
    c.CategoryName,
    SUM(p.Price * s.Quantity) AS revenue,
    SUM(s.Quantity) AS qty_sold
FROM Categories c
JOIN Products p ON c.CategoryID = p.CategoryID
JOIN Sales s ON s.ProductID = p.ProductID
GROUP BY c.CategoryName;


/* -----------------------------------------
   SECTION 2 — CUSTOMER ANALYSIS
----------------------------------------- */

-- Q4. Identify the top 10 customers based on their total spending.
SELECT 
    CONCAT(c.FirstName, ' ', c.LastName) AS customer,
    SUM(p.Price * s.Quantity) AS total_spent
FROM Customers c
JOIN Sales s ON c.CustomerID = s.CustomerID
JOIN Products p ON s.ProductID = p.ProductID
GROUP BY customer
ORDER BY total_spent DESC
LIMIT 10;

-- Q5. Count how many customers are one-time buyers vs repeat buyers.
SELECT 
    CASE WHEN orders = 1 THEN 'One-time' ELSE 'Repeat' END AS type,
    COUNT(*) AS total_customers
FROM (
    SELECT CustomerID, COUNT(*) AS orders
    FROM Sales
    GROUP BY CustomerID
) t
GROUP BY type;

-- Q6.Create a Customer Lifetime Value (CLV) report with total revenue and total orders per customer.
SELECT 
    CONCAT(c.FirstName, ' ', c.LastName) AS customer,
    COUNT(s.SalesID) AS total_orders,
    SUM(p.Price * s.Quantity) AS total_revenue
FROM Customers c
JOIN Sales s ON c.CustomerID = s.CustomerID
JOIN Products p ON s.ProductID = p.ProductID
GROUP BY customer
ORDER BY total_revenue DESC;

-- Q7. Determine which city generates the highest customer revenue.
SELECT 
    ci.CityName,
    SUM(p.Price * s.Quantity) AS revenue
FROM Cities ci
JOIN Customers c ON ci.CityID = c.CityID
JOIN Sales s ON s.CustomerID = c.CustomerID
JOIN Products p ON s.ProductID = p.ProductID
GROUP BY ci.CityName
ORDER BY revenue DESC;

-- Q8. Analyze customer revenue distribution at the country level.
SELECT 
    co.CountryName,
    SUM(p.Price * s.Quantity) AS revenue
FROM Countries co
JOIN Cities ci ON co.CountryID = ci.CountryID
JOIN Customers c ON ci.CityID = c.CityID
JOIN Sales s ON c.CustomerID = s.CustomerID
JOIN Products p ON s.ProductID = p.ProductID
GROUP BY co.CountryName
ORDER BY revenue DESC;


/* -----------------------------------------
   SECTION 3 — PRODUCT ANALYSIS
----------------------------------------- */

-- Q9. . Identify the top-selling products based on total revenue and quantity sold.
SELECT 
    p.ProductName,
    SUM(p.Price * s.Quantity) AS revenue,
    SUM(s.Quantity) AS qty_sold
FROM Products p
JOIN Sales s ON p.ProductID = s.ProductID
GROUP BY p.ProductName
ORDER BY revenue DESC;

-- Q10. Identify which categories generate high revenue but sell low quantities
SELECT 
    c.CategoryName,
    SUM(p.Price * s.Quantity) AS revenue,
    SUM(s.Quantity) AS qty
FROM Categories c
JOIN Products p ON c.CategoryID = p.CategoryID
JOIN Sales s ON p.ProductID = s.ProductID
GROUP BY c.CategoryName
HAVING revenue >= (SELECT AVG(p.Price * s.Quantity) FROM Products p JOIN Sales s ON p.ProductID = s.ProductID)
   AND qty <= (SELECT AVG(Quantity) FROM Sales);

-- Q11.Identify which products generate low revenue but sell high quantities
SELECT 
    p.ProductName,
    SUM(p.Price * s.Quantity) AS revenue,
    SUM(s.Quantity) AS qty
FROM Products p
JOIN Sales s ON p.ProductID = s.ProductID
GROUP BY p.ProductName
HAVING revenue <= (SELECT AVG(p.Price * s.Quantity) FROM Products p JOIN Sales s ON p.ProductID = s.ProductID)
   AND qty >= (SELECT AVG(Quantity) FROM Sales);


/* -----------------------------------------
   SECTION 4 — SALESPERSON ANALYSIS
----------------------------------------- */

-- Q12. Calculate the total revenue, total number of orders, and average discount for each salesperson.
SELECT 
    CONCAT(e.FirstName, ' ', e.LastName) AS salesperson,
    SUM(p.Price * s.Quantity) AS revenue,
    COUNT(*) AS orders,
    AVG(s.Discount) AS avg_discount
FROM Employees e
JOIN Sales s ON s.SalesPersonID = e.EmployeeID
JOIN Products p ON s.ProductID = p.ProductID
GROUP BY salesperson
ORDER BY revenue DESC;

-- Q13. Identify the top 3 and bottom 3 performing salespersons.
(SELECT 
    CONCAT(e.FirstName, ' ', e.LastName) AS salesperson,
    SUM(p.Price * s.Quantity) AS revenue
 FROM Employees e
 JOIN Sales s ON s.SalesPersonID = e.EmployeeID
 JOIN Products p ON s.ProductID = p.ProductID
 GROUP BY salesperson
 ORDER BY revenue DESC
 LIMIT 3)
UNION ALL
(SELECT 
    CONCAT(e.FirstName, ' ', e.LastName) AS salesperson,
    SUM(p.Price * s.Quantity) AS revenue
 FROM Employees e
 JOIN Sales s ON s.SalesPersonID = e.EmployeeID
 JOIN Products p ON s.ProductID = p.ProductID
 GROUP BY salesperson
 ORDER BY revenue ASC
 LIMIT 3);

-- Q14. Determine which salesperson handles the highest number of repeat customers.
SELECT 
    CONCAT(e.FirstName, ' ', e.LastName) AS salesperson,
    COUNT(DISTINCT s.CustomerID) AS repeat_customers
FROM Sales s
JOIN Employees e ON s.SalesPersonID = e.EmployeeID
WHERE s.CustomerID IN (
    SELECT CustomerID FROM Sales GROUP BY CustomerID HAVING COUNT(*) >= 2
)
GROUP BY salesperson
ORDER BY repeat_customers DESC;


/* -----------------------------------------
   SECTION 5 — DISCOUNT ANALYSIS
----------------------------------------- */

-- Q15. Check whether discounted orders have higher quantities than non-discounted orders.
SELECT 
    CASE WHEN Discount > 0 THEN 'Discounted' ELSE 'No Discount' END AS type,
    AVG(Quantity) AS avg_qty
FROM Sales
GROUP BY type;

-- Q16.Compare category-wise average discount and total revenue.
SELECT 
    c.CategoryName,
    AVG(s.Discount) AS avg_discount,
    SUM(p.Price * s.Quantity) AS revenue
FROM Categories c
JOIN Products p ON c.CategoryID = p.CategoryID
JOIN Sales s ON p.ProductID = s.ProductID
GROUP BY c.CategoryName
ORDER BY revenue DESC;


/* -----------------------------------------
   SECTION 6 — TIME BASED INSIGHTS
----------------------------------------- */

-- Q17. . Identify the time range (morning, afternoon, evening, night) with the highest number of sales
SELECT 
    CASE
        WHEN HOUR(STR_TO_DATE(SalesTime_PART, '%r')) BETWEEN 5 AND 11 THEN 'Morning'
        WHEN HOUR(STR_TO_DATE(SalesTime_PART, '%r')) BETWEEN 12 AND 16 THEN 'Afternoon'
        WHEN HOUR(STR_TO_DATE(SalesTime_PART, '%r')) BETWEEN 17 AND 20 THEN 'Evening'
        ELSE 'Night'
    END AS time_range,
    COUNT(*) AS total_sales
FROM Sales
GROUP BY time_range
ORDER BY total_sales DESC;


/* -----------------------------------------

----------------------------------------- */

-- Q19. Identify the top 1 revenue-generating product in each category.
SELECT 
    CategoryName, 
    ProductName, 
    total_revenue
FROM (
    SELECT
        c.CategoryName,
        p.ProductName,
        SUM(p.Price * s.Quantity) AS total_revenue,
        ROW_NUMBER() OVER(
            PARTITION BY c.CategoryID 
            ORDER BY SUM(p.Price * s.Quantity) DESC
        ) AS rn
    FROM Categories c
    JOIN Products p ON c.CategoryID = p.CategoryID
    JOIN Sales s ON s.ProductID = p.ProductID
    GROUP BY c.CategoryName, p.ProductName, c.CategoryID
) AS t
WHERE rn = 1;


