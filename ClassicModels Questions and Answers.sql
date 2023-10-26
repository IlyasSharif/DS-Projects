-- Solutions to Richard Twatson's Classic Models Data Set and Corresponding Questions using MySQL
-- https://www.richardtwatson.com/open/private/ClassicModels.html
USE classicModels;

-------------------------------------------------------------------------------------------------
-- Single Entity
-- 1. Prepare a list of offices sorted by country, state, city.
SELECT officeCode, country, state, city FROM offices ORDER BY country, state, city;

-- 2. How many employees are there in the company?
SELECT COUNT(employeeNumber) FROM employees;

-- 3. What is the total of payments recieved?
SELECT SUM(amount) FROM payments;

-- 4. List the product lines that contain 'Cars'
SELECT productLine FROM productLines WHERE productLine LIKE '%Cars%';

-- 5. Report total payments for October 28, 2004.
SELECT SUM(amount) FROM payments WHERE paymentDate = '2004-10-28';

-- 6. Report those payments greater than $100,000.
SELECT checkNumber, amount FROM payments WHERE amount > 100000;

-- 7. List the products in each product line.
SELECT productLine, productName FROM products ORDER BY productLine, productName;

-- 8. How many products in each product line?
SELECT productLine, COUNT(productName) FROM products GROUP BY productLine;

-- 9. What is the minimum payment recieved?
SELECT MIN(amount) FROM payments;

-- 10. List all payments greater than twice the average payment
SELECT * FROM payments WHERE amount > 2*(SELECT AVG(amount) FROM payments);

-- 11. What is the average percentage markup of the MSRP on buyPrice?
--     HINT: Average percentage markup = AVG(MSRP/buyprice)*100 - 100
SELECT AVG(MSRP/buyprice)*100 - 100 AS 'Average Percentage Markup' FROM products;

-- 12. How many distinct products does ClassicModels sell?
SELECT COUNT(DISTINCT(productCode)) FROM products;

-- 13. Report the name and city of customers who don't have sales representatives.
SELECT customerName, city FROM customers WHERE salesRepEmployeeNumber IS NULL;

-- 14. What are the names of executives with VP or Manager in their title? Use the CONCAT 
--     function to combine the employee's first and last name into a single field for reporting
SELECT CONCAT(firstName, ' ', lastName) AS name, jobTitle FROM employees WHERE jobTitle LIKE 
	'%VP%' OR jobTitle LIKE '%Manager%';

-- 15. Which orders have a value greater than $5,000?
SELECT orderNumber, SUM(quantityOrdered*priceEach) AS orderValue FROM orderDetails 
	GROUP BY orderNumber HAVING SUM(quantityOrdered*priceEach)>5000;


-------------------------------------------------------------------------------------------------
-- One to Many Relationship
-- 1. Report the account representative for each customer.
SELECT customerName, CONCAT(firstName, ' ', lastName) as 'Account Representative' FROM customers 
	JOIN employees ON salesRepEmployeeNumber=employeeNumber;

-- 2. Report total payments for Atelier graphique.
SELECT SUM(amount) FROM payments JOIN customers 
	ON customers.customerNumber = payments.customerNumber WHERE customerName='Atelier graphique';

-- 3. Report the total payments by date
SELECT paymentDate, SUM(amount) AS 'Amount' FROM payments GROUP BY paymentDate;

-- 4. Report the products that have not been sold
SELECT productName FROM products WHERE productCode NOT IN (SELECT productCode FROM orderDetails);

-- 5. List the amount paid by each customer
SELECT customers.customerName, SUM(amount) AS 'Total Amount Paid' FROM payments JOIN customers 
	ON payments.customerNumber = customers.customerNumber GROUP BY payments.customerNumber;

-- 6. How many orders have been placed by Herkku Gifts?
SELECT COUNT(orderNumber) FROM orders WHERE customerNumber = (SELECT customerNumber 
	FROM customers WHERE customerName='Herkku Gifts');

-- 7. Who are the employees in Boston?
SELECT CONCAT(firstName, '' , lastName) AS 'Employee Name' FROM employees JOIN offices
	ON employees.officeCode = offices.officeCode WHERE offices.city = 'Boston';

-- 8. Report those payments greater than $100,000. Sort the report so the customer who made the 
--    highest payment appears first.
SELECT customerName, payments.amount FROM customers JOIN payments 
	ON customers.customerNumber = payments.customerNumber AND amount > 100000
    ORDER BY amount DESC;
    
-- 9. List the value of 'On Hold' orders.
SELECT SUM(quantityOrdered*priceEach) FROM orderDetails JOIN orders
	ON orders.orderNumber = orderDetails.orderNumber WHERE status='On Hold';

-- 10. Report the number of orders 'On Hold' for each customer.
SELECT customerName, COUNT(orderNumber) FROM orders JOIN customers 
	ON customers.customernumber = orders.customerNumber
    WHERE status='On Hold' GROUP BY customerName;

-- Bonus: Shows how much $ each order has on hold.
SELECT orders.orderNumber, SUM(quantityOrdered*priceEach) status FROM orders JOIN orderDetails 
	ON orders.orderNumber = orderDetails.orderNumber WHERE status='On Hold'
    GROUP BY orderDetails.orderNumber;


-------------------------------------------------------------------------------------------------
-- Many to Many Relationship
-- 1. List names of products sold by order date
SELECT productName, orderDate FROM orders 
	JOIN orderDetails ON orders.orderNumber = orderdetails.ordernumber
    JOIN products ON orderdetails.productCode = products.productCode
    ORDER BY orderDate;

-- 2. List all the order dates in descending order for orders for the 1940 Ford Pickup Truck
SELECT orderDate FROM orders JOIN orderDetails
	ON orders.orderNumber = orderDetails.orderNumber
    WHERE productCode = 
    (SELECT productCode FROM products WHERE productName = '1940 Ford Pickup Truck')
    ORDER BY orderDate DESC;
    
-- 3. List the names of customers and their corresponding order number where a particular order 
--    from that customer has a value greater than $25,000.
SELECT customerName, orders.orderNumber, SUM(quantityOrdered*priceEach) AS value  FROM customers 
	JOIN orders ON orders.customerNumber = customers.customerNumber
    JOIN orderDetails ON orders.orderNumber = orderDetails.orderNumber
    GROUP BY customerName, orderNumber HAVING SUM(quantityOrdered*priceEach)>25000
    ORDER BY customerName ASC;
    
-- 4. Are there any products that appear on all orders? 
-- (NEED TO COMPLETE)

-- 5. List the names of products sold at less than 80% of the MSRP
SELECT DISTINCT(productName) from products JOIN orderDetails
	ON orderDetails.productCode = products.productCode
    WHERE priceEach < .80*MSRP;
    
-- 6. Report those products that have been sold with a markup of 100% or more
--    (i.e., the priceEach is atleast twice the buyPrice)
SELECT DISTINCT(productName) from products JOIN orderDetails
	ON orderDetails.productCode = products.productCode
    WHERE priceEach >= 2*buyPrice;
    
-- 7. List the products ordered on a Monday
SELECT DISTINCT(productName) FROM orders
	JOIN orderDetails ON orders.orderNumber = orderDetails.orderNumber
    JOIN products 	  ON products.productCode = orderDetails.productCode
    WHERE DAYNAME(orderDate) = 'MONDAY';
    
-- 8. What is the quantity on hand for products listed on 'On Hold' orders?
SELECT DISTINCT(productName), quantityInStock FROM products
	JOIN orderDetails ON products.productCode = orderDetails.productCode
    JOIN orders 	  ON orders.orderNumber = orderDetails.orderNumber
    WHERE status='On Hold';
    
    
-------------------------------------------------------------------------------------------------
-- Regular Expressions
-- 1. Find products containing the name 'Ford'
SELECT productName from products WHERE productName LIKE '%Ford%';

-- 2. List products ending in 'ship'.
SELECT productName from products WHERE productName LIKE '%ship';

-- 3. Report the number of customers in Denmark, Norway, and Sweden.
SELECT country, COUNT(customerNumber) FROM customers WHERE country IN ('Denmark', 'Norway', 'Sweden') GROUP BY country;

-- 4. What are the products with a product code in the range S700_1000 to S700_1499
SELECT productName, productCode FROM products WHERE productCode BETWEEN 'S700_1000' AND 'S700_1499';

-- 5. Which customers have a digit in their name? (Done without using REGEXP)
SELECT customerName FROM customers WHERE customerName LIKE '%0%' OR customerName LIKE '%1%' OR customerName LIKE '%2%' 
OR customerName LIKE '%3%' OR customerName LIKE '%4%' OR customerName LIKE '%5%' OR customerName LIKE '%6%' 
OR customerName LIKE '%7%' OR customerName LIKE '%8%' OR customerName LIKE '%9%';

-- 6. List the names of employees called Dianne or Diane.
SELECT * FROM employees WHERE firstName IN ('Diane', 'Dianne');

-- 7. List the products containing ship or boat in their product name.
SELECT productName FROM products WHERE productName LIKE '%ship%' OR productName LIKE '%boat%';

-- 8. List the products with a product code beginning with S700.
SELECT productName FROM products WHERE productCode LIKE 'S700%';

-- 9. List the names of employees called Larry or Barry.
SELECT * FROM Employees WHERE firstName IN ('Larry','Barry');

-- 10. List the names of employees with non-alphabetic characters in their names. (Cant think of an easy way to do without regexp)
SELECT * FROM Employees WHERE LOWER(firstName ) REGEXP '[^a-z]';

-- 11. List the vendors whose name ends in Diecast
SELECT DISTINCT(productVendor) FROM Products WHERE productVendor LIKE '%diecast';


-------------------------------------------------------------------------------------------------
-- General queries
-- 1. Who is at the top of the organization (i.e., reports to no one)
SELECT firstName, lastName FROM employees WHERE reportsTo IS NULL;

-- 2. Who reports to William Patterson?
SELECT firstName, lastName FROM employees WHERE reportsTo = 
	(SELECT employeeNumber FROM employees WHERE lastName='Patterson' AND firstName='William');

-- 3. List all the products purchased by Herkku Gifts.
SELECT DISTINCT(productName) FROM orders 
	JOIN orderDetails ON orders.orderNumber = orderDetails.orderNumber
	JOIN products ON orderDetails.productCode = products.productCode
    WHERE customerNumber = (SELECT customerNumber FROM customers WHERE customerName='Herkku Gifts');

-- 4. Compute the commission for each sales representative, assuming the commission is 5% of the
--    value of an order. Sort by employee last name and first name.
SELECT CONCAT(firstName, ' ' ,lastName) AS name, 
	SUM(quantityOrdered*priceEach)*0.05 AS commision FROM employees 
	JOIN customers ON customers.salesRepEmployeeNumber = employees.employeeNumber
    JOIN orders ON customers.customerNumber = orders.customerNumber
    JOIN orderDetails ON orderDetails.orderNumber = orders.orderNumber
    GROUP BY employeeNumber
    ORDER BY name;
    
-- 5. What is the difference in days between the most recent and oldest order date in the Orders file?
SELECT DATEDIFF(MAX(orderDate), MIN(orderDate)) FROM orders;

-- 6. Compute the average time between order date and ship date for each customer ordered by the largest difference.
SELECT customerNumber, AVG(DATEDIFF(shippedDate, orderDate)) AS 'average days between ordering and shipping' 
	FROM orders GROUP BY customerNumber ORDER BY AVG(DATEDIFF(shippedDate, orderDate)) DESC;
    
-- 7. What is the value of orders shipped in August 2004?
SELECT SUM(quantityOrdered*priceEach) AS 'August 2004 Value Shipped' FROM orders 
	JOIN orderDetails ON orders.orderNumber = orderDetails.orderNumber
	WHERE MONTH(shippedDate)=8 AND YEAR(shippedDate)=2004;

-- 8. Compute the total value ordered, total amount paid, and their difference for each
--    customer for orders placed in 2004 and payments recieved in 2004. Only report those
--    customers where the absolute value of the difference is greater than $100.alter
CREATE OR REPLACE VIEW totalAmountPaid2004 AS 
	SELECT SUM(amount) as paid, customers.customerNumber FROM payments JOIN customers
	ON customers.customerNumber = payments.customerNumber 
    WHERE YEAR(paymentDate)=2004
    GROUP BY (customers.customerNumber);
    
CREATE OR REPLACE VIEW totalAmountOrdered2004 AS
	SELECT SUM(quantityOrdered*priceEach) as ordered, customerNumber FROM orders
    JOIN orderDetails ON orders.orderNumber = orderDetails.orderNumber
    WHERE YEAR(orderDate)=2004
    GROUP BY (customerNumber);

SELECT totalAmountOrdered2004.customerNumber, ordered-paid AS 'Account Balance' 
	FROM totalAmountOrdered2004 JOIN totalAmountPaid2004
    ON totalAmountOrdered2004.customerNumber = totalAmountPaid2004.customerNumber
    WHERE ordered-paid > 100;
    
-- 9. List the employees who report to those employees who report to Diane Murphy
--    Use the CONCAT function to combine the employee's first and last name
SELECT CONCAT(firstName, ' ', lastName), employeeNumber FROM employees
	WHERE reportsTo IN (SELECT employeeNumber FROM employees
		WHERE reportsTo = (SELECT employeeNumber FROM employees WHERE lastName='Murphy' AND firstName='Diane'));
        
-- 10. What is the percentage value of each product in inventory sorted by the highest percentage first.
SELECT productName, quantityInStock*buyPrice AS Stock, quantityInStock*buyPrice/(totalValue)*100 As Percentage FROM products,
	(SELECT SUM(quantityInStock*buyPrice) AS totalValue FROM products) AS totValTable
    ORDER BY Percentage DESC;
    
-- 11. SKIPPED

-- 12. SKIPPED

-- 13. What is the value of payments received in July 2004?
SELECT SUM(amount) FROM payments WHERE MONTH(paymentDate)=7 AND YEAR(paymentDate)=2004;

-- 14. What is the ratio of the value of payments made to orders recieved for each month
--     of 2004 (i.e., divide the value of payments made by the orders recieved)?
WITH MonthlyPayments2004 AS ( SELECT MONTH(paymentDate) AS period, SUM(amount) AS monthlyPayments FROM payments
							  WHERE YEAR(paymentDate)=2004 GROUP BY MONTH(paymentDate)),
	 MonthlyOrders2004   AS ( SELECT MONTH(orderDate) AS period, SUM(quantityOrdered*priceEach) AS monthlyOrders FROM orders, orderDetails
							  WHERE orders.orderNumber = orderDetails.orderNumber AND YEAR(orderDate)=2004 GROUP BY MONTH(orderDate))
	SELECT MonthlyPayments2004.period, monthlyPayments/monthlyOrders AS Ratio FROM MonthlyPayments2004 JOIN MonthlyOrders2004 
	ON MonthlyPayments2004.period = MonthlyOrders2004.period ORDER BY period ASC;

-- 15. What is the difference in amount recieved for each month of 2004 compared to 2003?
WITH MonthlyPayments2004 AS ( SELECT MONTH(paymentDate) AS period, SUM(amount) AS monthlyPayments4 FROM payments
							  WHERE YEAR(paymentDate)=2004 GROUP BY MONTH(paymentDate)),
	 MonthlyPayments2003 AS ( SELECT MONTH(paymentDate) AS period, SUM(amount) AS monthlyPayments3 FROM payments
							  WHERE YEAR(paymentDate)=2003 GROUP BY MONTH(paymentDate))
	SELECT MonthlyPayments2004.period AS period, monthlyPayments4-monthlyPayments3 AS diff FROM MonthlyPayments2004
	JOIN MonthlyPayments2003 ON MonthlyPayments2004.period = MonthlyPayments2003.period ORDER BY period ASC;
    
-- 16. SKIPPED

-- 17. SKIPPED

-- 18. Basket of goods analysis
WITH p1 AS ( SELECT products.productCode, productName AS `Product 1`, orderNumber FROM products, orderDetails WHERE orderDetails.productCode = products.productCode),
	 p2 AS ( SELECT products.productCode, productName AS `Product 2`, orderNumber FROM products, orderDetails WHERE orderDetails.productCode = products.productCode)
     SELECT `Product 1`, `Product 2`, count(*) AS Frequency FROM p1 JOIN p2 ON p1.orderNumber = p2.orderNumber
     WHERE p1.productCode > p2.productCode GROUP BY `Product 1`, `Product 2` HAVING Frequency > 10
     ORDER BY Frequency DESC, `Product 1`, `Product 2`;
     
-- 19. ABC reporting
WITH totRevTable AS (SELECT SUM(quantityOrdered*PriceEach) AS totalRevenue FROM orderDetails)
SELECT customerName, SUM(quantityOrdered*priceEach) AS `Revenue`, SUM(quantityOrdered*priceEach)/(SELECT totalRevenue FROM totRevTable) * 100 AS `Percentage`
	FROM customers
	JOIN orders ON customers.customerNumber = orders.customerNumber
    JOIN orderDetails ON orders.orderNumber = orderDetails.orderNumber
    GROUP BY customerName ORDER BY customerName;
    
-- 20. Compute profit generated by each customer based on their orders. Also, show each customer's profit as a percentage of total profit.
--     Sort by descending profit.
SELECT  customerName, SUM(quantityOrdered*(priceEach-buyPrice)) AS `Profit`,
	SUM(quantityOrdered*(priceEach-buyPrice)) / ( SELECT SUM(quantityOrdered*(priceEach-buyPrice)) FROM
    products JOIN orderDetails ON products.productCode = orderDetails.productCode ) AS `Profit Percentage`
	FROM customers 
	JOIN orders ON customers.customerNumber = orders.customerNumber
    JOIN orderDetails ON orders.orderNumber = orderDetails.orderNumber
    JOIN products ON products.productCode = orderDetails.productCode
    GROUP BY customerName;
    
-- 21. Compute the revenue generated by each sales representative based on the orders from the customers they serve.
SELECT  CONCAT(firstName,' ', lastName) AS `Name`, SUM(quantityOrdered*priceEach) AS `Revenue Generated`
	FROM employees
    JOIN customers ON employees.employeeNumber = customers.salesRepEmployeeNumber
	JOIN orders ON customers.customerNumber = orders.customerNumber
    JOIN orderDetails ON orders.orderNumber = orderDetails.orderNumber
    GROUP BY employeeNumber;
    
 -- 22. Compute the profit generated by each sales representative based on the orders from the customers they serve.
 --     Sort by profit generated descending.
SELECT  CONCAT(firstName,' ', lastName) AS `Name`, SUM(quantityOrdered*(priceEach-buyPrice)) AS `Profit Generated`
	FROM employees
    JOIN customers ON employees.employeeNumber = customers.salesRepEmployeeNumber
	JOIN orders ON customers.customerNumber = orders.customerNumber
    JOIN orderDetails ON orders.orderNumber = orderDetails.orderNumber
    JOIN products ON products.productCode = orderDetails.productCode
    GROUP BY employeeNumber
    ORDER BY `Profit Generated` Desc;

-- 23. Compute the Revenue generated by each product, sorted by product name.
SELECT productName, SUM(quantityOrdered*priceEach) AS `Revenue` 
	FROM products
	JOIN orderDetails ON orderDetails.productCode = products.productCode
    GROUP BY products.productCode
    ORDER BY productName;

-- 24. Compute the profit generated by each product line, sorted by profit descending
SELECT productLine, SUM(quantityOrdered*(priceEach-buyPrice)) AS `Profit` 
	FROM products
	JOIN orderDetails ON orderDetails.productCode = products.productCode
    GROUP BY productLine
    ORDER BY `Profit` DESC;

-- 25. Benford's Law
SELECT LEFT(amount, 1) as `Digit`, COUNT(*) AS `Observed`,
	(SELECT COUNT(*) FROM payments) * LOG10(1 + 1/LEFT(amount, 1)) AS `Expected` FROM payments
    GROUP BY `Digit`, `Expected` ORDER BY `Digit`;
    
-- 26. SALY analysis
WITH sales2003 AS ( SELECT productName, SUM(quantityOrdered*priceEach) AS `2003rev`
					FROM products JOIN orderDetails ON orderDetails.productCode = products.productCode 
                    JOIN orders ON orderDetails.orderNumber = orders.orderNumber
                    WHERE YEAR(orderDate)=2003 GROUP BY productName),
	sales2004 AS ( SELECT productName, SUM(quantityOrdered*priceEach) AS `2004rev`
					FROM products JOIN orderDetails ON orderDetails.productCode = products.productCode 
                    JOIN orders ON orderDetails.orderNumber = orders.orderNumber
                    WHERE YEAR(orderDate)=2004 GROUP BY productName)
	SELECT sales2004.productName, `2003rev`/`2004rev` AS `SALY ratio` 
    FROM sales2004 JOIN sales2003 ON sales2003.productName = sales2004.productName;
    
-- 27. Compute the ratio of payments for each customer for 2003 versus 2004
-- Same as above, expect now you are interested in joining the customers, orders and order details tables...

-- 28. Find the products sold in 2003 but not 2004.
SELECT DISTINCT(productName) 
	FROM products 
    JOIN orderDetails ON orderDetails.productCode = products.productCode
    JOIN orders ON orderDetails.orderNumber = orders.orderNumber
    WHERE YEAR(orderDate)=2003 AND productName NOT IN (SELECT DISTINCT(productName) 
	FROM products 
    JOIN orderDetails ON orderDetails.productCode = products.productCode
    JOIN orders ON orderDetails.orderNumber = orders.orderNumber
    WHERE YEAR(orderDate)=2004);

-- 29. Find the customers without payments in 2003.
SELECT DISTINCT customerName FROM customers JOIN payments ON customers.customerNumber = payments.customerNumber
	WHERE customerName NOT IN ( SELECT DISTINCT customerName FROM customers JOIN payments ON customers.customerNumber = payments.customerNumber WHERE YEAR(paymentDate)=2003 );


-------------------------------------------------------------------------------------------------
-- Correlated subqueries
-- 1. Who reports to Mary Patterson?
SELECT CONCAT(firstName, '  ', lastName) AS Name FROM employees WHERE reportsTO = (SELECT employeeNumber FROM employees WHERE lastName='Patterson' AND firstName='Mary');

-- 2. Which payments in any month and year are more than twice the average for that month and year (ie compare all payments in Oct 2004 with the average payment for Oct 2004)?
--    Order the results by the date of the payment. (Will need to do self-join)
SELECT amount, DATE(paymentDate) FROM Payments P1
	WHERE amount > 2 * ( SELECT AVG(amount) FROM payments P2 WHERE MONTH(P1.paymentDate)=MONTH(P2.paymentDate) AND YEAR(P1.paymentDate) = YEAR(P2.paymentDate) )
    ORDER BY P1.paymentDate;

-- 3. Report for each product, the percentage value of its stock on hand as a percentage of the stock on hand for product line to which it belongs.
--    Order the report by product line and percentage value within product line descending. Show percentages with two decimal places.
SELECT productName, productLine, quantityInStock*buyPrice/( SELECT SUM(quantityInStock*buyPrice) FROM products WHERE P.productLine = products.productLine) * 100 AS `percent`
	FROM products P
    ORDER BY productLine, `percent` DESC;

-- 4. For orders containing more than two products, report those products that constitute more than 50% of the value of the order.
SELECT productName FROM products WHERE productCode IN ( 
	SELECT productCode FROM orderDetails O WHERE quantityOrdered*priceEach > .5 * ( 
		SELECT SUM(quantityOrdered*priceEach) FROM orderDetails WHERE orderDetails.orderNumber=O.orderNumber GROUP BY O.orderNumber HAVING COUNT(*)>2 ) );



















