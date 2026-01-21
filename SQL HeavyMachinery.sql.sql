----Q1 Find unique key column/s in dbo.Sales$
--Hint: Check for duplicates for most eligible column/s

 

select invoice, customerkey, count(*)
from dbo.sales$
group by invoice, customerkey
having count(*) > 1;

 

Select count(invoice)
from dbo.sales$;
group by invoice
having count(*) > 1;

 

-- Q2 Print months when revenue of 50 million was crossed
--Example part of Output
--Month_Year revenue_mill
--8:2007 50.172
--1:2009 50.04

 

select datepart(month,transactiondate) as Month ,datepart(year,transactiondate) as Year, 
CAST(SUM(price) / 1000000.0 AS DECIMAL(10, 3)) AS revenue_mill
from sales$??
group by datepart(month,transactiondate), datepart(year,transactiondate)
having sum(([Price]*[Qty])) > 50000000
order by datepart(month,transactiondate), datepart(year,transactiondate)

 

 

-- Q3 Find Top 10 customers who spent most money on orders

 

Select top 10 S.CustomerKey, C.CustomerName, Sum(s.Price) as MoneySpent
FROM Sales$ as S
?Join  Customers$ as C
?on S.CustomerKey = C.CustomerKey
?Group by S. CustomerKey,  C.CustomerName
?Order by Sum(Price) desc

 

--Q4 Print CustomerKey, Name and Country of top 10 spending customers
Select top 10 s.CustomerKey, c.CustomerName, c.Country, sum(s.Price) as total_sales 
from Sales$ as s join Customers$ as c on s.CustomerKey=c.CustomerKey
group by s.CustomerKey, c.CustomerName, c.Country order by total_sales desc;

 

 

----Q5 Find Top 10 stores with most sales in 2006 and 2007.
--Print results separately for 2006 and 2007. (Write 2 queries)
Select Top 10 s.storeid, sum(s.price) as total_sum, c.year
from sales$ s
join calendar$ c on s.transactiondate =c.date
where c.year in(2006)
group by s.storeid, c.year
order by total_sum desc;

 

Select Top 10 s.storeid, sum(s.price) as total_sum, c.year
from sales$ s
join calendar$ c on s.transactiondate =c.date
where c.year in(2007)
group by s.storeid, c.year
order by total_sum desc;

 

-- Q6 Between years 2006 and 2007 which stores were part of Top 10 sales list
-- Hint - Set operators
select top 10 s.storeid,SUM(s.price) as total_sales
from sales$ s
JOIN calendar$ c on s.transactiondate = c.year
where c.year IN (2006, 2007)
group by s.storeid
order by total_sales desc

 

--Q7 Which product is most famous with buyers of US
Select Top 1 ProductDescription, c.country, sum(s.price) as Num_Sales
from sales$ s
join customers$ c on s.customerkey = c.customerkey
join products$ p on s.productkey = p.productkey
where c.country = 'US'
group by productdescription, c.country
order by Num_sales desc;

 

--Q8 Find all details of products(from dbo.products$) which are top 5 in previous query
Select Top 5 ProductDescription, p.ProductKey, p.Brand, p.Type, p.color, p.shipdays, p.status, sum(price) as Num_Sales
from sales$ s
join products$ p on s.productkey = p.productkey
group by productdescription, p.ProductKey, p.Brand, p.Type, p.color, p.shipdays, p.status
order by Num_sales desc;


--Q9. Find out most successful channel responsible
--for sales and how much sales  it have done till now in millions
select top 5 c.ChannelKey, c.Channel,
SUM(s.Price) / 1000000 AS Total_Sales
from Sales$ as s
join Channel$ AS c ON s.ChannelKey = c.ChannelKey
group by c.ChannelKey,c.Channel
order by total_sales DESC;


--Q10 Which channel is most successful in latest 5
--years in data (Most recent 5 years)
--compute dynamically which are latest 5 years in data


select top 10 datepart(year,S.TransactionDate) as Date, c.Channel, sum(s.Price) as Sales
from Sales$ as s
join Channel$ as c on s.ChannelKey = c.ChannelKey
group by s.TransactionDate, c.channel
having datepart(year,S.TransactionDate) 
BETWEEN (select max(datepart(year,TransactionDate))-5 from sales$) 
and (select max(datepart(year,TransactionDate)) from sales$)
order by sum(s.Price) desc






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



-- Q12. For each country find out in which year they spent most money
select MaxRev.Country, WithYear.Date as Year, WithYear.MoneySpent as "Money Spent"
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




/Q13. Find out top performing employees for year
2011 in terms of number of orders assisted/

select top 5 datepart(year,transactiondate) as Year ,EmpKey, count(distinct Invoice) as Orders_Assisted
from Sales$
group by EmpKey, datepart(year,transactiondate)
having datepart(year,transactiondate) = 2011
order by Orders_Assisted desc


Q14. Find out top performing employees for year
2011 in terms of total revenue generated from sales/

select top 5 datepart(year,transactiondate) as Year ,EmpKey, round(sum(Price*Qty)/1000000,2) as Total_Revenue_mil
from Sales$
group by EmpKey, datepart(year,transactiondate)
having datepart(year,transactiondate) = 2011
order by Total_Revenue_mil desc



