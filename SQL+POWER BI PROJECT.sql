use project; 
describe cfe;
 select * from cfe; 
Select concat(Round(sum(transaction_qty*unit_price)/1000,1),"k")As total_sales
from cfe
where month(transaction_date)=4;


-- selected Month / CM - May=5
-- PM - April= 4
SELECT 
   MONTH(transaction_date)AS MONTH, -- Number of Month
   Round(Sum(unit_price*transaction_qty)) As Total_Sales, -- Total Sales Column
   (Sum(unit_price*transaction_qty) - LAG(Sum(unit_price*transaction_qty),1) -- Month Sales Difference
   Over (Order BY MONTH(transaction_date))) / LAG(Sum(unit_price*transaction_qty),1) -- Dividion By PM Sales
   OVER (Order BY MONTH(transaction_date)) * 100 AS MOM_INCREASE_PERCENTAGE -- Percentage
   From cfe 
     WHERE 
      MONTH(transaction_date) IN (4,5) -- for Months of April(PM) and May (CM)
	GROUP BY 
    MONTH(transaction_date)
    ORDER BY 
    MONTH(transaction_date);
    
    -- TOTAL ORDER ANALYSIS -- 
select Count(transaction_id) As Total_Orders
from cfe
where
 month(transaction_date) = 3;
 
 SELECT 
   MONTH(transaction_date)AS MONTH, -- Number of Month
   Round(Count(transaction_id)) As Total_Orders, -- Total Sales Column
   (Count(transaction_id) - LAG(Count(transaction_id),1) -- Month Sales Difference
   Over (Order BY MONTH(transaction_date))) / LAG(Count(transaction_id),1) -- Dividion By PM Sales
   OVER (Order BY MONTH(transaction_date)) * 100 AS MOM_INCREASE_PERCENTAGE -- Percentage
   From cfe
     WHERE
      MONTH(transaction_date) IN (4,5) -- for Months of April(PM) and May (CM)
	GROUP BY 
    MONTH(transaction_date);
 
-- TOTAL QUANTITY ANALYSIS--
SELECT sum(transaction_qty) As Total_qty
from cfe
where
 month(transaction_date) = 3;
 
SELECT 
   MONTH(transaction_date)AS MONTH, -- Number of Month
   Round(Sum(transaction_qty)) As Total_Quantity_Sales, -- Total Sales Column
   (Sum(transaction_qty) - LAG(Sum(transaction_qty),1) -- Month Sales Difference
   Over (Order BY MONTH(transaction_date))) / LAG(Sum(transaction_qty),1) -- Dividion By PM Sales
   OVER (Order BY MONTH(transaction_date)) * 100 AS MOM_INCREASE_PERCENTAGE -- Percentage
   From cfe
     WHERE
      MONTH(transaction_date) IN (4,5) -- for Months of April(PM) and May (CM)
	GROUP BY 
    MONTH(transaction_date)
    ORDER BY  
    MONTH(transaction_date);

 -- Calender Heat Map ----
 select concat(Round(sum(transaction_qty*unit_price)/1000,1),'k') As Total_sales,
 sum(transaction_qty) As Total_qty,
 count(transaction_id) As Total_order
 from cfe 
 where 
 transaction_date="2023-05-18";
	
 SELECT 
    CONCAT(ROUND(SUM(unit_price * transaction_qty) / 1000, 1),'K') AS total_sales,
    CONCAT(ROUND(COUNT(transaction_id) / 1000, 1),'K') AS total_orders,
    CONCAT(ROUND(SUM(transaction_qty) / 1000, 1),'K') AS total_quantity_sold
FROM 
    cfe
WHERE  
    transaction_date = '2023-05-18'; -- For 18 May 2023
    -- Sales Analysis by Weekdays and Weekends --
 -- Weekend - sat and sun
 -- Weekdays - Mon to Fri
 Sun = 1
 Mon = 2
 .
 .
 Sat = 7;
 Select 
 case When Dayofweek(transaction_date) IN (1,7) Then 'Weekends'
 Else 'Weekdays'
 END AS Day_type,
concat(round(SUM(transaction_qty*unit_price)/ 1000,1),'k') AS Total_Sales
 from cfe
 where month(transaction_date)=5
 Group by case When Dayofweek(transaction_date) IN (1,7) Then 'Weekends'
 Else 'Weekdays'
 END ; 
 
 -- Sales Analysis By Store location --
 SELECT 
 store_location,
 concat(round(SUM(transaction_qty*unit_price)/ 1000,2),'k') AS Total_Sales
 from cfe
 where month(transaction_date)=4
 group by store_location
 order by SUM(transaction_qty*unit_price) desc;
 
 
 
 -- Daily Sales Analysis With Average Line --
 SELECT AVG(Total_sales) AS Average_Sales
 from
(
SELECT SUM(transaction_qty*unit_price) AS Total_Sales
FROM cfe
WHERE MONTH(transaction_date)=5
group by transaction_date 
) As Internal_Query;

SELECT 
    DAY(transaction_date) AS Day_Of_Month,
    SUM(transaction_qty * unit_price) AS Total_Sales
FROM
    cfe
WHERE
    MONTH(transaction_date)=5
    group by transaction_date;
    
    SELECT 
    day_of_month,
    CASE 
        WHEN total_sales > avg_sales THEN 'Above Average'
        WHEN total_sales < avg_sales THEN 'Below Average'
        ELSE 'Average'
    END AS sales_status,
    total_sales
FROM (
    SELECT 
        DAY(transaction_date) AS day_of_month,
        SUM(unit_price * transaction_qty) AS total_sales,
        AVG(SUM(unit_price * transaction_qty)) OVER () AS Avg_Sales
    FROM 
        cfe
    WHERE 
        MONTH(transaction_date) = 5  -- Filter for May
    GROUP BY 
        DAY(transaction_date)
) AS sales_data
ORDER BY 
    day_of_month;
    -- Sales Analysis by Product Category --

    select   product_category,
 concat(round(SUM(transaction_qty*unit_price)/ 1000,1),'k') AS Total_Sales
 from cfe 
 where month(transaction_date)=5
 group by product_category 
 order by  SUM(transaction_qty*unit_price)desc;
    -- Top 10 Product By Sales -- 
 select   product_type,
 concat(round(SUM(transaction_qty*unit_price)/ 1000,1),'k') AS Total_Sales
 from cfe 
 where month(transaction_date)=5
 group by product_type 
 order by  SUM(transaction_qty*unit_price)desc
 limit 10;
 
 -- Sales Analysis By Days and Hours --
 Select
 SUM(transaction_qty*unit_price) AS Total_Sales,
 Sum(transaction_qty) As Total_qty_Sold,
 count(*) As Total_Orders
 from cfe 
 where month(transaction_date)=5 -- MAY
 AND dayofweek(transaction_date)=1 -- SUN
 AND hour(transaction_time)=8 ;-- Hours No 8

SELECT 
HOUR(transaction_time) AS Hours,
SUM(transaction_qty*unit_price) AS Total_Sales
from cfe
where month(transaction_date)=4 -- April
group by HOUR(transaction_time)
order by HOUR(transaction_time) ;

SELECT 
CASE 
when dayofweek(transaction_date)=1 Then 'Sunday'
when dayofweek(transaction_date)=2 Then 'Monday'
when dayofweek(transaction_date)=3 Then 'Tuesday'
when dayofweek(transaction_date)=4 Then 'Wednesday'
when dayofweek(transaction_date)=5 Then 'Thursday'
when dayofweek(transaction_date)=6 Then 'Friday'
Else 'Saturday'
End As Weeks_Sales,
round(SUM(transaction_qty*unit_price)) AS Total_Sales
from cfe
where month(transaction_date)=5
group by
CASE 
when dayofweek(transaction_date)=1 Then 'Sunday'
when dayofweek(transaction_date)=2 Then 'Monday'
when dayofweek(transaction_date)=3 Then 'Tuesday'
when dayofweek(transaction_date)=4 Then 'Wednesday'
when dayofweek(transaction_date)=5 Then 'Thursday'
when dayofweek(transaction_date)=6 Then 'Friday'
Else 'Saturday'
End
