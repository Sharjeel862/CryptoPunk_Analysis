# CryptoPunk_Analysis
This project focuses on analyzing CryptoPunks transactions over a period of time using MySQL Exploratory Data Analysis (EDA) Queries

## Table of Contents

- [Introduction](#introduction)
- [Questions and Answers](#questions-and-answers)
- [Project Structure](#project-structure)
- [Usage](#usage)
- [Contributing](#contributing)

## Introduction

That data set is a sales data set of one of the most famous NFT projects, Cryptopunks. Meaning each row of the data set represents a sale of an NFT. The data includes sales from January 1st, 2018 to December 31st, 2021. The table has several columns including the buyer address, the ETH price, the price in U.S. dollars, the seller’s address, the date, the time, the NFT ID, the transaction hash, and the NFT name.
You might not understand all the jargon around the NFT space, but you should be able to infer enough to answer the following prompts.

## Questions and Answers

#### Question 1 How many sales occurred during this time period? 

```sql
SELECT COUNT(*) as Trasactions
FROM pricedata;
```

#### Question 2 Return the top 5 most expensive transactions (by USD price) for this data set. Return the name, ETH price, and USD price, as well as the date.

```sql
SELECT name, event_date, ETH_price, USD_price
FROM pricedata
ORDER BY USD_price DESC
LIMIT 5;
```

#### Question 3 Return a table with a row for each transaction with an event column, a USD price column, and a moving average of USD price that averages the last 50 transactions.

```sql
SELECT event_date, USD_price, AVG(USD_price)
OVER (ORDER BY event_date ROWS BETWEEN 49 PRECEDING AND CURRENT ROW) AS moving_average_USD
FROM pricedata;
```

#### Question 4 Return all the NFT names and their average sale price in USD. Sort descending. Name the average column as average_price.

```sql
SELECT name, AVG(USD_price) as average_price
FROM pricedata
GROUP BY name
ORDER BY AVG(USD_price) DESC;
```

#### Question 5 Return each day of the week and the number of sales that occurred on that day of the week, as well as the average price in ETH. Order by the count of transactions in ascending order.

```sql
SELECT DAYNAME(event_date) as Weekday, COUNT(*) as Transactions, AVG(ETH_price) as avg_price_ETH
FROM pricedata
GROUP BY DAYNAME(event_date)
ORDER BY COUNT(*) ASC;
```

#### Question 6 Construct a column that describes each sale and is called summary. The sentence should include who sold the NFT name, who bought the NFT,  who sold the NFT, the date, and what price it was sold for in USD rounded to the nearest thousandth.

```sql
SELECT CONCAT(name, ' was sold for $', ROUND(USD_price, -3), ' to ', buyer_address, ' from ', seller_address, ' on ', event_date) as summary
FROM pricedata;
```

#### Question 7 Create a view called “1919_purchases” and contains any sales where “0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685” was the buyer.

```sql
CREATE VIEW 1919_purchases as
SELECT * FROM pricedata
WHERE buyer_address = '0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685';

SELECT * FROM 1919_purchases;
```

#### Question 8 Create a histogram of ETH price ranges. Round to the nearest hundred value.

```sql
SELECT ROUND(ETH_price, -2) as bucket, 
COUNT(*) as count,
RPAD('', COUNT(*), '*') as bar 
FROM pricedata
GROUP BY bucket
ORDER BY bucket;
```

#### Question 9 Return a unioned query that contains the highest price each NFT was bought for and a new column called status saying “highest” with a query that has the lowest price each NFT was bought for and the status column saying “lowest”. The table should have a name column, a price column called price, and a status column. Order the result set by the name of the NFT, and the status, in ascending order. 

```sql
SELECT name, MAX(USD_price) as price, "Highest" as Status
FROM pricedata
GROUP BY name
UNION
SELECT name, MIN(USD_price) as price, "Lowest" as Status
FROM pricedata
GROUP BY name
ORDER BY name, Status;
```

#### Question 10 What NFT sold the most each month / year combination? Also, what was the name and the price in USD? Order in chronological format. 

```sql
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
```

#### Question 11 Return the total volume (sum of all sales), round to the nearest hundred on a monthly basis (month/year).

```sql
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
```

#### Question 12 Count how many transactions the wallet "0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685"had over this time period.

```sql
SELECT COUNT(*) as Transactions
FROM pricedata
WHERE buyer_address = '0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685'
OR seller_address = '0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685';
```

#### Question 13 Create an “estimated average value calculator” that has a representative price of the collection every day based off of these criteria:
 - Exclude all daily outlier sales where the purchase price is below 10% of the daily average price
 - Take the daily average of remaining transactions
 
```sql
WITH Price_Per_Day AS(
SELECT event_date, USD_price, AVG(USD_price)
OVER (ORDER BY event_date) AS Avg_Price_USD
FROM pricedata)

SELECT * FROM Price_Per_Day
WHERE USD_price > (0.10 * Avg_Price_USD);
```


## Project Structure

The project repository is structured as follows:

```
├── data/                  # Directory containing the dataset
├── NFT_1.sql/               # Directory containing SQL query files
└── README.md              # Project README file
```

## Usage

1. Clone the repository:

   ```
   git clone https://github.com/Sharjeel862/CryptoPunk_Analysis.git
   ```

2. Import the dataset into your SQL database management system.

3. Run SQL queries in 'NFT_1.sql' against the database to perform data analysis and generate insights.

## Contributing

Contributions to this project are welcome. If you have suggestions for improvements or find any issues, feel free to open a pull request or submit an issue in the repository.
