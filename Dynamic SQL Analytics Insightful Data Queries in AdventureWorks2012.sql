 -- this uses  [AdventureWorks2012] 
 -- download here [https://learn.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-ver16&tabs=ssms]
/*1. for each product catagoery ,display the total number
of subcatagories and products.*/
--select * from [Production].[Product]
--select * from [Production].[ProductSubcategory]
--select * from [Production].[ProductCategory]

use [AdventureWorks2012]

select ppc.name as [Product Category]
,count(pp.productid) as [Product], count(psc.productsubcategoryid)
as [Total Productsubcategories] from 
[Production].[Product]  as pp
join [Production].[ProductSubcategory] psc
on pp.ProductSubcategoryID = pp.ProductSubcategoryID
join [Production].[ProductCategory] ppc
on psc.ProductCategoryID = ppc.ProductCategoryID
group by ppc.name

/*2. display the top 5 products, having the highest profit margin,
and their total sales to date. */

select top 5 p.name as [product name],
(p.listprice - p.standardcost) as profit,
sum(p.listprice * sh.orderqty) as [total sales]
from Production.Product p
join sales.SalesOrderDetail sh
on p.ProductID = sh.ProductID
GROUP BY p.ProductID, p.Name, p.ListPrice, p.StandardCost
ORDER BY Profit DESC;

/*3. list the products having a profit margin greater than 100%.*/
SELECT p.Name
FROM Production.Product p
WHERE (((p.ListPrice-p.StandardCost)/p.StandardCost)*100) > 100 
AND p.StandardCost>0;

/*4. list the total sales and units sold in the following list price ranges.*/

select sum(p.listprice * sd.orderqty) [Total sales],
sum(sd.orderqty) [unit sold],( select 
case when p.listprice between 0 and 99 then '0-99'
	when p.listprice between 100 and 999 then '100 -999'
	when p.listprice between 1000 and 9999 then '1000-9999'
	else '> 10000' end as ranges) as ranges
from production.product p
join [Sales].[SalesOrderDetail] sd
on p.productid = sd.productid
group by p.ListPrice --ranges
order by p.listprice asc

/*5.for each of the product categorey(biking, componets, clothing and accesories)
list the total sales and units sold in 2008. */

select pc.name as Category, 
sum(p.listprice * sd.orderqty) as [Total Sales],
sum(sd.orderqty) as [unit sold] from 
Production.ProductSubcategory psc
join Production.Product p
on p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN Production.ProductCategory pc
ON psc.ProductCategoryID = pc.ProductCategoryID
JOIN Sales.SalesOrderDetail sd
ON sd.ProductID = p.ProductID
--where year(p.sellstartdate) = '2008' and year(p.sellenddate) = '2008'
GROUP BY pc.ProductCategoryID, pc.Name;

/*6.show the total sales due to mareketing and promotion for 2007 and 2008.*/

SELECT YEAR(sh.OrderDate) AS YEAR, sr.Name as [reason type], 
SUM(p.ListPrice * sd.orderQty ) AS 'Total Sales'
from Production.ProductsubCategory psc
join Production.product p
on p.ProductSubcategoryID = psc.ProductSubcategoryID
join sales.SalesOrderDetail sd
on p.ProductID = sd.ProductID
join sales.SalesOrderHeader sh
on sh.SalesOrderID = sd.SalesOrderID
join sales.SalesOrderHeaderSalesReason sosr
on sh.SalesOrderID = sosr.SalesOrderID
join sales.SalesReason sr
on sr.SalesReasonID = sosr.SalesReasonID
WHERE sr.Name = 'Promotion' AND sr.Name = 'Marketing' AND 
(YEAR(sh.OrderDate) = 2007 AND YEAR(sh.OrderDate) = 2008)
GROUP BY sr.SalesReasonID, sr.Name, sh.OrderDate;

/*7. display the top 3 selling products, in 2008 for each 
of the sub categories listed below:
mountain bikes, road bikes and touring bikes.*/

select top 3 psc.name as [Subcategory name], p.name [Product name],
sum(p.listprice * so.orderqty ) [Total sales]
from Production.ProductSubcategory psc
join [Production].[Product] p
on p.ProductSubcategoryID = psc.ProductSubcategoryID
join [Sales].[SalesOrderDetail] so
on so.ProductID = p.ProductID
WHERE psc.Name = 'Mountain Bikes'
group by psc.name, p.name
order by sum(p.listprice * so.orderqty ) desc
----------------------------
/*8. find products that were sold every single month from 07/01/2005 - 07/31/2008 
and display their total sales amount and units sold to date. */

SELECT p.Name AS "Product Name", SUM(p.ListPrice * sd.orderQty)
AS "Total Sales", SUM(sd.orderQty) AS "Total Units Sold"
FROM Production.Product p
JOIN Sales.SalesOrderDetail sd
ON sd.ProductID = p.ProductID
JOIN sales.SalesOrderHeader sh
ON sh.SalesOrderID = sd.SalesOrderID
WHERE sh.OrderDate BETWEEN '07/01/2005' AND '07/31/2008'
GROUP BY p.ProductID, p.Name;

/*9.which is the best selling mountainb bikes? show the historic
pricing for the product and total sales and unit sold at
each price point.
note : [productlistpricehistory] table has the historic prices.
productsubcategoryid = 1 and mountain bike.*/

select p.name, year(ph.startdate) startdate, year(ph.enddate) as enddate,
p.listprice, sum(p.listprice * sd.orderqty) as [total sales],
sum(sd.orderqty) as [total unit sold]
from production.product p
join Production.ProductListPriceHistory ph
on p.productid = ph.productid
join sales.SalesOrderDetail sd
on p.productid = sd.productid
JOIN Production.ProductSubcategory psc
ON psc.ProductSubcategoryID = p.ProductSubcategoryID
WHERE psc.ProductSubcategoryID = 1
GROUP BY p.ProductID, p.Name,  ph.startDate, 
ph.endDate, p.ListPrice;


