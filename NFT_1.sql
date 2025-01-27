CREATE DATABASE cryptopunk;

USE cryptopunk;

CREATE TABLE pricedata(
buyer_address text,
eth_price double,
usd_price double,
seller_address text,
event_date varchar(255),
token_id int,
transaction_hash text,
name text
);


/*1. How many sales occurred during this time period?*/
SELECT COUNT(*) as Trasactions
FROM pricedata;

/*2. Return the top 5 most expensive transactions (by USD price) for this data set.
Return the name, ETH price, and USD price, as well as the date.*/
SELECT name, event_date, ETH_price, USD_price
FROM pricedata
ORDER BY USD_price DESC
LIMIT 5;

/*3. Return a table with a row for each transaction with an event column, 
a USD price column, and a moving average of USD price that averages the last 50 transactions..*/
SELECT event_date, USD_price, AVG(USD_price)
OVER (ORDER BY event_date ROWS BETWEEN 49 PRECEDING AND CURRENT ROW) AS moving_average_USD
FROM pricedata;

/*4. Return all the NFT names and their average sale price in USD.
Sort descending. Name the average column as average_price.*/
SELECT name, AVG(USD_price) as average_price
FROM pricedata
GROUP BY name
ORDER BY AVG(USD_price) DESC;

/*5. Return each day of the week and the number of sales that occurred on that day of the week, 
as well as the average price in ETH. Order by the count of transactions in ascending order.*/
SELECT DAYNAME(event_date) as Weekday, COUNT(*) as Transactions, AVG(ETH_price) as avg_price_ETH
FROM pricedata
GROUP BY DAYNAME(event_date)
ORDER BY COUNT(*) ASC;

/*6. Construct a column that describes each sale and is called summary. 
The sentence should include who sold the NFT name, who bought the NFT, 
who sold the NFT, the date, and what price it was sold for in USD rounded to the nearest thousandth.*/
SELECT CONCAT(name, ' was sold for $', ROUND(USD_price, -3), ' to ', buyer_address, ' from ', seller_address, ' on ', event_date) as summary
FROM pricedata;

/*7. Create a view called “1919_purchases” and 
contains any sales where “0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685” was the buyer.*/
CREATE VIEW 1919_purchases as
SELECT * FROM pricedata
WHERE buyer_address = '0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685';

SELECT * FROM 1919_purchases;

/*8. Create a histogram of ETH price ranges. Round to the nearest hundred value.*/
SELECT ROUND(ETH_price, -2) as bucket, 
COUNT(*) as count,
RPAD('', COUNT(*), '*') as bar 
FROM pricedata
GROUP BY bucket
ORDER BY bucket;

/*9. Return a unioned query that contains the highest price each NFT was bought for and a new column called status saying “highest” 
with a query that has the lowest price each NFT was bought for and the status column saying “lowest”.
The table should have a name column, a price column called price, and a status column. 
Order the result set by the name of the NFT, and the status, in ascending order.*/
SELECT name, MAX(USD_price) as price, "Highest" as Status
FROM pricedata
GROUP BY name
UNION
SELECT name, MIN(USD_price) as price, "Lowest" as Status
FROM pricedata
GROUP BY name
ORDER BY name, Status;

/*10. What NFT sold the most each month / year combination? 
Also, what was the name and the price in USD? Order in chronological format.*/
WITH NFT_Sales_Month AS (
SELECT YEAR(event_date) as Year,
MONTH(event_date) as Month,
MONTHNAME(event_date) as Month_Name,
name, COUNT(*) as Transactions
FROM pricedata
GROUP BY YEAR(event_date), MONTH(event_date), MONTHNAME(event_date), name)

SELECT Year, Month_Name,
name, Transactions
FROM NFT_Sales_Month as NF1
WHERE Transactions = (SELECT MAX(Transactions)
					FROM NFT_Sales_Month as NF2
                    WHERE NF1.Year = NF2.Year
                    AND NF1.Month = NF2.Month)
ORDER BY Year, Month, Name, Transactions DESC;

/*11. Return the total volume (sum of all sales), 
round to the nearest hundred on a monthly basis (month/year).*/
WITH Sales_Volume AS (
SELECT YEAR(event_date) as Year,
MONTH(event_date) as Month,
MONTHNAME(event_date) as Month_Name,
ROUND(SUM(USD_price),-2) as Sales
FROM pricedata
GROUP BY YEAR(event_date), MONTH(event_date), MONTHNAME(event_date))

SELECT Year, Month_Name, Sales
FROM Sales_Volume
ORDER BY Year, Month;

/*12. Count how many transactions the 
wallet "0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685"had over this time period.*/
SELECT COUNT(*) as Transactions
FROM pricedata
WHERE buyer_address = '0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685'
OR seller_address = '0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685';

/*13. Create an “estimated average value calculator” that has a 
representative price of the collection every day based off of these criteria:
 - Exclude all daily outlier sales where the purchase price is below 10% of the daily average price
 - Take the daily average of remaining transactions*/
WITH Price_Per_Day AS(
SELECT event_date, USD_price, AVG(USD_price)
OVER (ORDER BY event_date) AS Avg_Price_USD
FROM pricedata)

SELECT * FROM Price_Per_Day
WHERE USD_price > (0.10 * Avg_Price_USD);