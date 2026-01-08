 Use Swiggy_Database;

Select * from swiggy_data;

-- BUSINESS REQUIREMENTS --
 -- Data Cleaning & Validation --
 -- Check Null Value --
 select 
 Sum(Case when state is null then 1 else 0 end) as Null_State,
 Sum(Case when City is null then 1 else 0 end) as Null_City,
 Sum(Case when Order_date is Null then 1 else 0 end)as Null_Order_date,
 Sum(Case when  restaurant_name is Null then 1 else 0 end)as Null_Restaurant_Name,
 Sum(Case when location is Null then 1 else 0 End)as Null_location,
 Sum(Case when category is Null Then 1 else 0 End) as Null_Category,
 Sum(Case When Dish_name is Null Then 1 else 0 end)as Null_Dish_name,
 Sum(Case when Price_INR is Null then 1 else 0 end)as Null_Price_INR,
 Sum(Case when Rating is Null then 1 else 0 end)as Null_Ratings,
 Sum(Case when Rating_Count is Null then 1 else 0 end)as Null_Rating_Count
 from swiggy_data;

 -- Blank & Empty String --
 Select * from 
 swiggy_data
 Where state=''or city= ''or Restaurant_Name=''or location=''or category=''or Dish_Name='';

 -- Duplicate Detection --
 Select state,City,Order_Date,Restaurant_Name,Location,Category,Dish_Name,Price_INR,Rating,Rating_Count,count(*) as cnt
 from swiggy_data
 Group by state,City,Order_Date,Restaurant_Name,Location,Category,Dish_Name,Price_INR,Rating,Rating_Count
 Having count(*)>1;

 -- Commands --
 Begin Transaction;
 
 Rollback;

 -- Delete Duplication --
 WITH CTE AS (
 Select *,ROW_NUMBER() OVER(
 PARTITION BY state,City,Order_Date,Restaurant_Name,Location,Category,Dish_Name,Price_INR,Rating,Rating_Count
 ORDER By (Select Null)
 )AS rn
 From swiggy_data
 )
 DELETE FROM CTE WHERE rn>1;
 -- For Id Number ---
 SELECT 
    ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS row_num,
    *
FROM swiggy_data;

-- STAR SCHEMA --
-- Dimension table --
-- Date Table --

create table dim_date(
date_id INT Identity(1,1) primary key,
Full_Date Date,
Year int,
Month int,
Month_Name Varchar(20),
Quarter int,
Day int,
Week int
)
select * from dim_date;
-- dim location--
Create Table dim_Location(
location_id int Identity(1,1) primary key,
State Varchar(100),
City Varchar(100),
location Varchar(200)
);

-- dim Restaurant --
Create Table dim_restaurant(
restaurant_id int Identity(1,1) Primary key,
restaurant_Name Varchar(200)
);

-- dim category --
Create table dim_category(
Category_id INT Identity(1,1) Primary Key,
Category Varchar(200)
);

--dim Dish --
Create Table dim_dish(
dish_id int identity(1,1) primary key,
Dish_Name Varchar(200)
)

-- Fact Table --
Create Table Fact_Swiggy_Orders(
Order_id int IDENTITY(1,1) PRIMARY KEY,
Price_INR Decimal(10,2),
Rating DECIMAL(4,2),
Rating_count INT,

date_id int,
location_id int,
Restaurant_id int,
Category_id int,
Dish_id int,
FOREIGN KEY (date_id) REFERENCES dim_date(date_id),
FOREIGN KEY (location_id) REFERENCES dim_location(location_id),
FOREIGN KEY (Restaurant_id) REFERENCES dim_Restaurant(Restaurant_id),
FOREIGN KEY (Category_id) REFERENCES dim_Category(Category_id),
FOREIGN KEY (dish_id) REFERENCES dim_dish(dish_id)
)

select * from Fact_Swiggy_Orders   

-- INSERT DATA IN ALL TABLES --
INSERT INTO dim_date
(Full_Date,Year,Month,Month_Name,Quarter,Day,Week)
Select distinct
 order_date,
 Year(order_date),
 Month(order_date),
 DateName(MONTH,order_date),
 DATEPART(QUARTER,order_date),
 DAY(order_date),
 DATEPART(WEEK,order_date)
 from swiggy_data
 where order_date is not null;

 Select * from Fact_Swiggy_Orders

---- RENAME COLUMN NAME --
 EXEC  sp_rename
     'fact_swiggy_orders.Ratimg_count',
	 'Rating_count',
	 'COLUMN';
 
 -- Dim location --
 INSERT INTO dim_Location
 (State,City,location)
 select distinct
 state,
 city,
 location
 from swiggy_data;

-- dim Restaurant --
INSERT INTO dim_restaurant(restaurant_Name)
Select Distinct
restaurant_Name
from swiggy_data;

--dim category --
INSERT INTO dim_category(Category)
Select distinct
category
From swiggy_data;
-- dim dish --
INSERT INTO dim_dish(dish_Name)
select distinct
Dish_Name
from swiggy_data;

-- Fact Table --
INSERT INTO fact_swiggy_orders
(date_id,Price_INR,rating,Rating_count,location_id,Restaurant_id,Category_id,Dish_id)
Select 
dd.date_id,
s.Price_INR,
s.Rating,
s.Rating_count,

dl.location_id,
dr.Restaurant_id,
dc.category_id,
dsh.dish_id
from swiggy_data s 

join dim_date as dd 
     ON dd.Full_Date=s.Order_Date

JOIN dim_Location dl
    ON dl.State=s.State
	AND dl.City=s.City
	AND dl.location=s.Location

JOIN dim_restaurant dr
    ON dr.restaurant_Name=s.Restaurant_Name

JOIN dim_category dc
    ON dc.Category=s.Category

JOIN dim_dish dsh
    ON dsh.Dish_Name=s.Dish_Name;

Select * from Fact_Swiggy_Orders f    --table a--
JOIN dim_date d ON f.date_id=d.date_id
JOIN dim_location dl ON f.location_id=dl.location_id
JOIN dim_Category dc ON f.category_id=dc.category_id
JOIN dim_Restaurant dr ON f.Restaurant_id=dr.Restaurant_id
JOIN dim_dish dsh  On f.dish_id=dsh.dish_id;

--KPI REQUIRMENT --
 --Total Orders --
 SELECT COUNT(*) AS TOTAL_ORDERS
 FROM Fact_Swiggy_Orders;

 -- Total Revenue (INR Million) --
 Select
 FORMAT(SUM(CONVERT(FLOAT,Price_INR))/1000000,'N2') + 'INR Million'
 AS Total_Revenue 
 From Fact_Swiggy_Orders;

 -- AVG Dish Price--
 Select
 FORMAT(AVG(CONVERT(FLOAT,Price_INR)),'N2') + 'INR'
 AS Total_Revenue 
 From Fact_Swiggy_Orders;

 -- AVG Rating--
 Select 
 AVG(Rating) As Avg_Rating
 from Fact_Swiggy_Orders;

 Select * from Fact_Swiggy_Orders;
 -- GRANULAR REQUIRMENTS --
 -- Deep-Dive Business Analysis --
 -- Date-Based Analysis --
 --1.Monthly order trends --
 SELECT 
 d.Year,
 d.month,
 d.Month_name,
 count(*) AS Total_Orders
 from Fact_Swiggy_Orders f
 JOIN dim_date d ON f.date_id=d.date_id
 GROUP BY d.Year,
 d.month,
 d.Month_name
 order by Total_Orders desc;

 -- Quarterly order trends --
 SELECT 
 d.Year,
 d.Quarter,
 count(*) AS Total_Orders
 from Fact_Swiggy_Orders f
 JOIN dim_date d ON f.date_id=d.date_id
 GROUP BY d.Year,
 d.Quarter
 order by Total_Orders desc;
 -- Year Wise Growth --
 SELECT 
 d.Year,
 count(*) AS Total_Orders
 from Fact_Swiggy_Orders f
 JOIN dim_date d ON f.date_id=d.date_id
 GROUP BY d.Year
 order by Total_Orders desc;

 --Day-of-week patterns (MON - SUN)--
 SELECT 
 DATENAME(Weekday,d.full_date) as Day_Name,
 count(*) AS Total_Orders
 from Fact_Swiggy_Orders f
 JOIN dim_date d ON f.date_id=d.date_id     
 GROUP BY DATENAME(Weekday,d.full_date)
 order by Total_Orders desc;

 -- TOP 10 Cities By Order Volume --
 Select TOP 10
 l.City,
 count(*) as Total_Orders
 From Fact_Swiggy_Orders f
 JOIN dim_Location l On f.location_id=l.location_id
 GROUP BY l.city
 ORDER BY Total_Orders DESC;

 -- Revenue contribution by states --
 Select 
 l.State,
 SUM(f.Price_INR) AS Total_Revenue
 From Fact_Swiggy_Orders f 
 JOIN dim_Location l On f.location_id=l.location_id
 GROUP BY l.State
 ORDER BY Total_Revenue DESC;

 -- FOOD PERFORMANCE --
 -- Top 10 restaurants by orders & Revenue --
 Select 
 r.restaurant_name,
 COUNT(*) AS Total_Orders,
 SUM(f.Price_INR) AS Total_Revenue
 From Fact_Swiggy_Orders f 
 JOIN dim_restaurant r On f.Restaurant_id=r.restaurant_id
 GROUP BY r.Restaurant_Name
 ORDER BY total_Orders Desc,Total_Revenue desc;

 --Top categories (Indian, Chinese, etc.)--
 Select 
 c.Category,
 COUNT(*) AS Total_Orders,
 SUM(f.Price_INR) AS Total_Revenue
 From Fact_Swiggy_Orders f 
 JOIN dim_category c On f.Category_id=c.Category_id
 GROUP BY c.Category
 ORDER BY total_Orders Desc,Total_Revenue desc;

-- Most Orderd Dishes --
Select top 10
 d.Dish_Name,
 COUNT(*) AS Total_Orders,
 SUM(f.Price_INR) AS Total_Revenue
 From Fact_Swiggy_Orders f 
 JOIN dim_dish d On f.Dish_id=d.dish_id
 GROUP BY d.Dish_Name
 ORDER BY total_Orders Desc,Total_Revenue desc;

 --Cuisine performance → Orders + Avg Rating --
 Select 
 c.Category,
 COUNT(*) AS Total_Orders,
 AVG(f.Rating) AS Avg_Rating
 From Fact_Swiggy_Orders f 
 JOIN dim_category c On f.Category_id=c.Category_id
 GROUP BY c.Category
 ORDER BY total_Orders Desc;

-- Customer Spending Insights

-- Total Order By Price Range --
Select 
 Case 
     When Price_INR < 100 then 'Under 100'
	 When price_INR between 100 and 199 Then '100 - 199'
	 When price_INR between 200 and 299 Then '200 - 299'
	 When price_INR between 300 and 399 Then '300 - 499'
	 Else '500+'
END AS Price_Range,
count(*) As Total_Orders,
Sum(Price_INR) AS Total_Revenue
From Fact_Swiggy_Orders
Group By Case 
     When Price_INR < 100 then 'Under 100'
	 When price_INR between 100 and 199 Then '100 - 199'
	 When price_INR between 200 and 299 Then '200 - 299'
	 When price_INR between 300 and 399 Then '300 - 499'
	 Else '500+'
	 End
Order by Total_Orders desc;
--Distribution of dish ratings from 1–5--
SELECT 
Rating,
Count(*) As Rating_Counts
From Fact_Swiggy_Orders
Group By Rating
Order by Rating desc;