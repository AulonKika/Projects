select top 5 ProductDescription
from Products$


select top 10 ProductKey
from Sales$

--Q9. Find out most successful channel responsible
--for sales and how much sales  it have done till now in millions
select top 10 c.ChannelKey, c.Channel,
SUM(s.Price) / 1000000 AS Total_Sales
from Sales$ as s
join Channel$ AS c ON s.ChannelKey = c.ChannelKey
group by c.ChannelKey,c.Channel
order by total_sales DESC;



--Q10 Which channel is most successful in latest 5
--years in data (Most recent 5 years)
--compute dynamically which are latest 5 years in data

select top 10 datepart(year,S.TransactionDate) as Date, c.Channel, sum(s.Price) as Salesfrom Sales$ as sjoin Channel$ as c on s.ChannelKey = c.ChannelKeygroup by s.TransactionDate, c.channelhaving datepart(year,S.TransactionDate) BETWEEN (select max(datepart(year,TransactionDate))-5 from sales$) and (select max(datepart(year,TransactionDate)) from sales$)order by sum(s.Price) desc


-- Q11. Find out which is most profitable year and
-- because of which product and how much top product
-- contributed in that year in millions
select top 1 datepart(year,transactiondate) as Date, sum(price - cost) as Profit
from sales$
group by datepart(year,transactiondate)
order by sum(price) desc;



select  top 1 P.ProductDescription as Product, SUM(price) as Revenue, SUM(cost) as Cost, SUM(Price - cost) as Profit
from Sales$ as S left join Products$ as P
ON S.ProductKey = P.ProductKey
where datepart(year,transactiondate) = 2004
group by P.ProductDescription
order by SUM(Price - cost) desc;



SELECT TOP 5 DATEPART(YEAR,S.TransactionDate) AS Year, S.ProductKey, P.ProductDescription, ROUND(SUM(((S.Price-S.Cost)*S.Qty))/1000000,2) AS Profit_by_ProductFROM Sales$ AS SJOIN Products$ AS P ON S.ProductKey = P.ProductKeyGROUP BY DATEPART(YEAR,S.TransactionDate), S.ProductKey, P.ProductDescriptionHAVING DATEPART(YEAR,S.TransactionDate) = (  SELECT TOP 1 DATEPART(YEAR,TransactionDate) AS Year											 FROM Sales$												GROUP BY DATEPART(YEAR,TransactionDate)												ORDER BY ROUND((SUM((Price-Cost)*Qty)/1000000),2) DESC)ORDER BY Profit_by_Product DESCselect MaxRev.Country, WithYear.Date as Year, WithYear.MoneySpent as "Money Spent"
from (
select sub.country as Country, max(sub.MoneySpent) as "Money Spent"
from (
    select C.country, datepart(year,S.transactiondate) as Date, SUM(S.price) as MoneySpent
    from Sales$ as S join Customers$ as C
    ON S.CustomerKey = C.CustomerKey
    group by C.country, datepart(year,S.transactiondate)
) sub
group by sub.country) as MaxRev

inner join

(select C.country, datepart(year,S.transactiondate) as Date, SUM(S.price) as MoneySpent
from Sales$ as S join Customers$ as C
ON S.CustomerKey = C.CustomerKey
group by C.country, datepart(year,S.transactiondate)) as WithYear

on MaxRev.[Money Spent] = WithYear.MoneySpent

order by MaxRev.Country
;


CREATE VIEW 
[Spending] AS 
SELECT DATEPART(YEAR,S.TransactionDate) AS Year, C.Country, SUM(S.Price) AS Money_Spent
FROM Sales$ AS S
JOIN Customers$ AS C ON S.CustomerKey = C.CustomerKey
GROUP BY C.Country, DATEPART(YEAR,S.TransactionDate);
WITH RankedSpending AS (
SELECT 
Country, Year, ROUND((Money_spent/1000000),2) AS Money_spent, ROW_NUMBER() OVER (PARTITION BY Country ORDER BY Money_spent DESC) as rn
FROM spending)
SELECT  Country, Year, Money_spent
FROM RankedSpending
WHERE rn = 1;