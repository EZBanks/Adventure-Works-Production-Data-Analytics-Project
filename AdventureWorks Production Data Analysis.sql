
--Showing product quantity produced by year

SELECT Year(ActualEndDate) AS Production_Year
,COUNT(Year(ActualEndDate)) AS Total_Quantity
FROM AdventureWorks2014.Production.WorkOrderRouting Work 
GROUP BY Year(ActualEndDate)

--Calculating total quantity in inventory across all production units 

SELECT Inv.ProductID, Inv.LocationID, Loc.Name, Inv.Quantity
,SUM(Quantity) OVER (PARTITION BY Inv.LocationID) AS Total_Qty_by_Unit
FROM AdventureWorks2014.Production.ProductInventory Inv
JOIN AdventureWorks2014.Production.Location Loc
ON Inv.LocationID = Loc.LocationID
WHERE Quantity > '0'
ORDER BY Total_Qty_by_Unit DESC


--Showing products as finished goods ready for sale
WITH ProductInventory_CTE (ProductID, LocationID, Name, Quantity, Total_Qty_by_Product)
AS(
SELECT Inv.ProductID,  Inv.LocationID, Loc.Name, Inv.Quantity
,SUM(Quantity) OVER (PARTITION BY Inv.ProductID) AS Total_Qty_by_Product
FROM AdventureWorks2014.Production.ProductInventory Inv
JOIN AdventureWorks2014.Production.Location Loc
ON Inv.LocationID = Loc.LocationID
)
SELECT ProductID
,LocationID
,Name AS Production_Unit
,Total_Qty_by_Product
FROM ProductInventory_CTE
WHERE LocationID = '7'


--Showing Total Days of Production and Total Days Overdue by Production Unit from 2011 to 2014
SELECT Work.LocationID
,Name AS Production_Unit
,SUM(DATEDIFF(day, ActualStartDate, ActualEndDate)) AS Total_Days_Production_by_Prod_Unit
,SUM(DATEDIFF(day, ScheduledStartDate, ActualStartDate)) AS Total_Days_Overdue_by_Prod_Unit
FROM AdventureWorks2014.Production.WorkOrderRouting Work
JOIN AdventureWorks2014.Production.Location Loc
ON Work.LocationID = Loc.LocationID
GROUP BY Work.LocationID, Name
ORDER BY Total_Days_Production_by_Prod_Unit DESC 

----Showing Number of Days of Production and Number of Days Overdue for Subassembly Production Unit from 2011 to 2014
SELECT Work.LocationID
,Loc.Name AS Production_Unit
,ScheduledStartDate
,ActualStartDate
,ActualEndDate
,DATEDIFF(day, ActualStartDate, ActualEndDate) AS Number_of_Days_to_Finish_a_Work_Order 
,DATEDIFF(day, ScheduledStartDate, ActualStartDate) AS Number_of_Days_Overdue
FROM AdventureWorks2014.Production.WorkOrderRouting Work
JOIN AdventureWorks2014.Production.Location Loc
ON Work.LocationID = Loc.LocationID
GROUP BY Work.LocationID, Name, ActualStartDate, ActualEndDate, ScheduledStartDate



--Calculating total orders and sales amount by product
WITH SalesOrder_CTE (LineTotal, ProductID, Name, OrderQty, Total_Sales_Amt_by_Product, Total_Orders_by_Product)
AS(
SELECT ord.ProductID, ord.LineTotal, prod.Name, ord.OrderQty
,SUM(LineTotal) OVER (PARTITION BY ord.ProductID) AS Total_Sales_Amt_by_Product
,SUM(OrderQty) OVER (PARTITION BY ord.ProductID) AS Total_Orders_by_Product
FROM AdventureWorks2014.Sales.SalesOrderDetail ord
JOIN AdventureWorks2014.Production.Product prod
ON ord.ProductID = prod.ProductID
)
SELECT Name AS Product_Name
,FORMAT (Total_Sales_Amt_by_Product,'C','en-us') AS Total_Sales_Amt_by_Product
,Total_Orders_by_Product
FROM SalesOrder_CTE
GROUP BY Name, Total_Sales_Amt_by_Product, Total_Orders_by_Product
ORDER BY Total_Sales_Amt_by_Product DESC





