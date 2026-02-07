--🔹 KPI & Business Performance
-- 1. What is the overall booking success rate?
SELECT 
    CONCAT(
     CAST(
        COUNT(CASE WHEN booking_status = 'Success' THEN 1 END) 
        * 100.0 / COUNT(booking_status)
        AS decimal(10,2))
     ,'%')AS success_rate_percentage
FROM bookings

/*Out of total bookings, 62.02% rides were successfully completed, 
indicating moderate platform fulfillment efficiency. 
Remaining 37.98% represents Failures 
due to cancellations and incomplete rides.*/


--2. What is the total number of bookings?
select
   count(*)as TotalBooking 
from bookings

/*The platform recorded 100,000 total bookings during the observed period, 
indicating overall demand volume across all service categories.*/

--3.What is the total revenue generated from successful rides?
select
   cast(sum(Booking_value)as decimal(10,2)) as Total_revenue
from Bookings where Booking_status='Success'

/*Total revenue generated from successful rides during 
the analysis period is ₹22659570.72 */

--4.What is the overall cancellation rate?
SELECT 
    Cast(
        COUNT(CASE 
                WHEN booking_status IN 
                     ('Cancelled by Customer','Cancelled by Driver')
             THEN 1 END)
        * 100.0 / COUNT(*)
    as decimal (10,2)) AS cancellation_rate_percentage
FROM bookings;

/*Out of the Total booking 37.11% booking are cancelled because of
various operational and customer-related reasons. This represents 
significant fulfillment leakage and highlights the need to optimize 
driver allocation, reduce arrival delays, and improve customer commitment. 
Reducing cancellations to below 10% could substantially improve revenue 
realization and platform efficiency.*/

--5.What is the incomplete ride rate?
SELECT 
    Cast(
        COUNT(CASE 
                WHEN booking_status ='Incomplete'             
             THEN 1 END)
        * 100.0 / COUNT(*)
    as decimal (10,2)) AS Incomplete_ride_rate
FROM bookings;
/* Incomplete rides account for 7.87% of total bookings, indicating relatively 
low post-pickup operational failure. This suggests strong trip execution reliability,
with most accepted rides being completed successfully. However, further analysis of 
breakdown and customer-demand termination cases could help reduce this rate below 5% */

--🔹 Vehicle Performance Analysis

--6.What is the success rate by vehicle type?
SELECT 
    Vehicle_Type,
    Cast(
        COUNT(CASE 
                WHEN booking_status ='Success'             
             THEN 1 END)
        * 100.0 / COUNT(*)
    as decimal (10,2)) AS Success_rate
FROM bookings
group by Vehicle_Type
Order By Success_rate Desc

/* Prime Sedan demonstrates the highest ride fulfillment efficiency, 
though success rates remain largely consistent across all vehicle categories.*/


--7.Which vehicle type generates the highest revenue?
SELECT 
    Vehicle_Type,
    Round(sum(Booking_Value),2) as Revenue_by_vehicle
FROM bookings
WHERE booking_status = 'Success'
group by Vehicle_Type
Order By Revenue_by_vehicle Desc
/* Prime Plus emerges as the highest revenue-generating vehicle segment, 
indicating strong monetization through premium ride pricing. */

--8.What is the average ride distance for each vehicle type?
SELECT 
    Vehicle_Type,
    Round(avg(Ride_Distance_km),2) as avg_ride_distance
FROM bookings
Group by Vehicle_Type
/*Premium vehicle categories such as Prime SUV and Prime Sedan exhibit 
higher average trip distances, indicating their preference for long-haul 
and airport transfers. In contrast, Bikes and eBikes dominate short-distance 
urban mobility, positioning them as last-mile connectivity solutions*/

--9.What is the cancellation rate by vehicle type?
SELECT 
    Vehicle_Type,
    Cast(
        COUNT(CASE 
                WHEN booking_status IN 
                     ('Cancelled by Customer','Cancelled by Driver')
             THEN 1 END)
        * 100.0 / COUNT(*)
    as decimal (10,2)) AS Vehicle_cancellation_rate
FROM bookings
group by Vehicle_Type
/*Bike and Mini segments exhibit relatively higher cancellation rates 
compared to premium fleets, potentially driven by driver supply volatility 
and shorter trip economics reducing ride acceptance incentives.*/

--10.Which vehicle type has the highest incomplete ride rate?
SELECT 
    Vehicle_Type,
    Cast(
        COUNT(CASE 
                WHEN booking_status ='Incomplete'   
             THEN 1 END)
        * 100.0 / COUNT(*)
    as decimal (10,2)) AS Vehicle_Incomplete_rate
FROM bookings
group by Vehicle_Type

/*Bike and Mini segments exhibit marginally higher incomplete ride rates, 
likely due to longer trip distances increasing exposure to 
mid-ride disruptions such as vehicle breakdown or route deviation.*/

-- 🔹 Revenue & Pricing Insights

--11. What is the average booking value per ride by vehicle type?
   select
       Vehicle_Type,
       Round(Avg(Booking_Value),2) Avg_booking_value
   from Bookings
   group by Vehicle_Type


--12. What is the correlation between ride distance and booking value?
    select
      Ride_Distance_km,
      Round(sum(Booking_Value),2) as Ride_Revenue
    from Bookings
    WHERE booking_status = 'Success'
    Group by Ride_Distance_km
    Order By Ride_Revenue desc

    SELECT 
        (AVG(ride_distance_km * booking_value) 
         - AVG(ride_distance_km) * AVG(booking_value)) -- Covariance
        /
        (STDEV(ride_distance_km) * STDEV(booking_value))  --- Pearson Correlation Coefficient.
        AS correlation_coefficient
    FROM bookings
    WHERE booking_status = 'Success';
    
    /*A strong positive correlation exists between ride distance 
    and booking value, confirming a distance-based pricing model. 
    Fare increases proportionally with trip length, ensuring revenue 
    scalability with ride duration. */


--13. Which pickup locations generate the highest revenue?
    select Top 1
       Pickup_Location,
       Round(Sum(Booking_Value),2) Revenue_by_location
   from Bookings
   where Booking_Status ='Success'
   group by Pickup_Location
   Order by Revenue_by_location desc

   /* Langford Town generated the highest revenue among all pickup zones, 
   indicating strong ride demand combined with higher booking values. 
   This suggests the presence of premium riders, commercial hubs, or 
   airport connectivity driving monetization in the region. */

--14. What are the peak revenue-generating days and hours?
    SELECT 
        DATENAME(WEEKDAY, Date) AS Day_Name,
        DATEPART(HOUR, Time) AS Hour_Of_Day,
        CASE 
            WHEN DATEPART(hour, Time) < 12 THEN 'Morning'
            WHEN DATEPART(hour, Time) >= 12 AND DATEPART(hour, Time) < 17 THEN 'Afternoon'
            ELSE 'Evening'
        END AS HourName,
        ROUND(SUM(Booking_Value), 2) AS Revenue_by_time
    FROM Bookings
    WHERE Booking_Status = 'Success'
    GROUP BY 
        DATENAME(WEEKDAY, Date),
        DATEPART(HOUR, Time)
    ORDER BY Revenue_by_time DESC;

      /* Revenue peaks during weekday afternoon hours, highlighting strong office 
      commute and business travel demand. Targeted surge pricing and driver incentives 
      during these windows could maximize platform earnings.*/

--🔹 Cancellation Analytics
    --15. What is the total number of rides cancelled by customers vs drivers?
     Select 
     Count(
         case when Booking_Status ='Cancelled by Customer'
         Then 1 END 
     ) AS Ride_cancelled_by_customer,
     Count(
         case when Booking_Status ='Cancelled by Driver' 
         Then 1 End 
     ) as Ride_cancelled_by_Driver
     From Bookings

     /* Customer-initiated cancellations (18,078) significantly exceed driver 
     cancellations (12,036), indicating higher demand-side drop-offs. This 
     suggests potential issues such as long driver arrival times, fare sensitivity, 
     or booking intent volatility, leading to revenue leakage before ride fulfillment.*/

    --16. What are the top reasons for customer cancellations?
    SELECT 
    Reason_for_cancelling_by_Customer,
    Count(Reason_for_cancelling_by_Customer) as Reason_count
    from Bookings
    GROUP BY Reason_for_cancelling_by_Customer 
    Order By Reason_count desc
    /*Customer cancellations are primarily driven by ‘Change of Plans’ (5,208 cases), 
    reflecting booking intent volatility. However, a significant share of cancellations 
    stems from operational inefficiencies, including drivers not moving toward pickup 
    locations (3,694) and drivers requesting cancellations (3,580). This highlights 
    supply-side service gaps impacting ride fulfillment. */


    --17. What are the top reasons for driver cancellations?
     SELECT 
        Driver_Cancel_Reason,
        Count(Driver_Cancel_Reason) as Reason_count
    from Bookings
    WHERE booking_status = 'Cancelled by Driver'
    GROUP BY Driver_Cancel_Reason
    Order By Reason_count desc
    /*Driver cancellations are primarily driven by personal and 
    vehicle-related issues (3,082 cases), indicating fleet availability and 
    maintenance challenges. A comparable volume of cancellations arises from 
    customer-related conflicts (3,026), suggesting rider behavior and policy 
    compliance also significantly impact ride fulfillment.*/


    --18. Which locations have the highest cancellation rates?
    SELECT 
        Pickup_Location,
        Count(Booking_ID) as Total_Booking,
        Count(Case when Booking_Status In ('Cancelled by Driver','Cancelled by Customer') Then 1 end ) as Location_by_cancellation
    from Bookings
    GROUP BY Pickup_Location
    Order BY Location_by_cancellation desc
    /* Malleshwars=am has shown major cancelltion which indicatyes poor location quality major address issue  laso low sucess or rides completetion followerd by HSR LAYOUT ,
    Btm , Belladur , LangFord town with total major failed rides which idicated major operatio inefficiency of pickup location */

    --Operational Efficiency
    -- 19. What is the average VTAT and CTAT for each vehicle type?

    select
        Vehicle_Type,
        Round(Avg(Avg_VTAT),2) Avg_Vehicle_time,
        Round(Avg([Avg_CTAT]),2) Avg_Customer_time
    from Bookings
    WHERE booking_status = 'Success'
    Group by Vehicle_Type
    /*Average vehicle arrival times remain consistent across all vehicle 
    categories at approximately 7 minutes, indicating balanced driver 
    distribution and efficient fleet dispatching irrespective of vehicle 
    tier.*/

    --20 .Which pickup locations have the highest average arrival time?

    select
        Pickup_Location,
        Avg(Avg_VTAT) PickupVtat
    from Bookings
    GROUP BY Pickup_Location
    Order BY PickupVtat desc
    /*Pickup zones such as Malleshwaram and HSR Layout exhibit the highest 
    average driver arrival times, indicating localized supply-demand 
    imbalances and navigation challenges. Elevated VTAT in these regions 
    contributes to increased cancellation risk and reduced ride fulfillment 
    efficiency*/


   -- 🔹 Customer Experience & Ratings

   --21. What is the average customer rating by vehicle type?

     select
         Vehicle_Type,
        Round(Avg(Customer_Rating),2) Rating_by_Customer
    from Bookings
    GROUP BY  Vehicle_Type
    Order BY Rating_by_Customer desc

    /*Customer satisfaction remains consistently high across all vehicle categories, 
    with average ratings clustered around 4.25. The minimal variation suggests standardized 
    service quality and comparable ride experiences irrespective of vehicle tier.”*/

   --22.What is the average driver rating by vehicle type?
     select
        Vehicle_Type,
        Round(Avg(Driver_Ratings),2) Rating_by_Driver
    from Bookings
    GROUP BY  Vehicle_Type
    Order BY Rating_by_Driver desc


    --23. What are the top 10 pickup locations by ride demand?
    SELECT TOP 10
        pickup_location,
        COUNT(*) AS total_ride_demand
    FROM bookings
    WHERE booking_status = 'Success'
    GROUP BY pickup_location
    ORDER BY total_ride_demand DESC;
    /*Ride demand is highly concentrated across major residential and commercial 
    corridors such as Marathahalli, Arekere, and Langford Town. However, the relatively
    small variance in booking volume across the top 10 zones suggests a uniformly 
    distributed demand pattern rather than a single dominant hotspot.*/
 
    --24. What are the most common pickup-drop route pairs?
    select
        Pickup_Location+'→'+Drop_Location as route,
        Count (Case when Booking_status='Success' then 1 end)  Sucess_rate
    from Bookings
    GROUP BY Pickup_Location+'→'+Drop_Location
    Order By Sucess_rate desc
    
    /*The Brookefield → HSR Layout corridor records the highest ride frequency, 
    indicating strong commuter movement between residential tech hubs and employment centers. */

    --25. Which routes generate the highest revenue?
    select
        Pickup_Location+'→'+Drop_Location as route,
        Round(Sum (Booking_Value),2)  Revenue_by_route
    from Bookings
    Where Booking_status='Success'
    GROUP BY Pickup_Location+'→'+Drop_Location
    Order By Revenue_by_route desc

    
    /*Brookefield → HSR Layout emerges not only as the most frequently traveled 
    route but also the highest revenue-generating corridor, indicating both strong 
    demand density and high trip monetization. */