-- =====================================================================
-- OLA RIDE BOOKING ANALYSIS  |  MySQL
-- Dataset : 103,024 bookings (July 2024)
-- Table   : bookings
--
-- | #  | Business Question                              | SQL Concept            |
-- |----|------------------------------------------------|------------------------|
-- | 1  | How many total bookings are there?             | COUNT()                |
-- | 2  | What is the booking status distribution?       | GROUP BY              |
-- | 3  | How many successful rides are there?           | SUM()                  |
-- | 4  | How many rides were cancelled?                 | SUM() / WHERE          |
-- | 5  | What is the cancellation rate?                 | SUM() + calculation    |
-- | 6  | What is the total revenue?                     | SUM()                  |
-- | 7  | What is the average booking value?             | AVG()                  |
-- | 8  | Which vehicle type has the most bookings?      | GROUP BY, ORDER BY     |
-- | 9  | Which vehicle type generates the most revenue? | SUM(), GROUP BY        |
-- | 10 | Which payment method is most used?             | GROUP BY, COUNT()      |
-- | 11 | What are the peak booking hours?               | GROUP BY               |
-- | 12 | Which pickup locations are most popular?       | GROUP BY, LIMIT        |
-- | 13 | Which drop locations are most popular?         | GROUP BY, LIMIT        |
-- | 14 | What is the average ride distance?             | AVG()                  |
-- | 15 | What is the average customer rating?           | AVG()                  |
-- | 16 | What is the average driver rating?             | AVG()                  |
-- | 17 | Which month has the most bookings?             | GROUP BY, ORDER BY     |
-- | 18 | Which month generates the most revenue?        | SUM(), GROUP BY        |
-- | 19 | How many rides are incomplete?                 | SUM()                  |
-- | 20 | What are the main cancellation reasons?        | GROUP BY               |
-- =====================================================================


-- =====================================================================
-- SETUP: Create database, table and load the clean CSV
-- =====================================================================
CREATE DATABASE IF NOT EXISTS ola_analytics;
USE ola_analytics;

DROP TABLE IF EXISTS bookings;

CREATE TABLE bookings (
    Date                        DATE,
    Time                        TIME,
    Booking_ID                  VARCHAR(20) PRIMARY KEY,
    Booking_Status              VARCHAR(30),
    Customer_ID                 VARCHAR(20),
    Vehicle_Type                VARCHAR(20),
    Pickup_Location             VARCHAR(50),
    Drop_Location               VARCHAR(50),
    V_TAT                       INT,
    C_TAT                       INT,
    Canceled_Rides_by_Customer  VARCHAR(60),
    Canceled_Rides_by_Driver    VARCHAR(60),
    Incomplete_Rides            VARCHAR(5),
    Incomplete_Rides_Reason     VARCHAR(40),
    Booking_Value               INT,
    Payment_Method              VARCHAR(20),
    Ride_Distance               INT,
    Driver_Ratings              DECIMAL(3,1),
    Customer_Rating             DECIMAL(3,1),
    Month_Name                  VARCHAR(15),
    Day_Name                    VARCHAR(15),
    Booking_Hour                TINYINT,
    Successful_Ride             TINYINT,
    Canceled_Ride               TINYINT,
    Customer_Canceled           TINYINT,
    Driver_Canceled             TINYINT,
    Incomplete_Ride_Flag        TINYINT,
    Total_Booking               TINYINT
);

-- Update the file path, then run (blank values are stored as \N = NULL)
LOAD DATA LOCAL INFILE 'C:/path/to/ola_clean.csv'
INTO TABLE bookings
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Quick check: should return 103024
SELECT COUNT(*) AS Rows_Loaded FROM bookings;


-- =====================================================================
-- ANALYSIS QUERIES
-- =====================================================================

-- ---------------------------------------------------------------------
-- Q1. How many total bookings are there?   [COUNT()]
-- ---------------------------------------------------------------------
SELECT COUNT(*) AS Total_Bookings
FROM bookings;

-- ---------------------------------------------------------------------
-- Q2. What is the booking status distribution?   [GROUP BY]
-- ---------------------------------------------------------------------
SELECT
    Booking_Status,
    COUNT(*) AS Total_Bookings,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM bookings), 2) AS Percentage
FROM bookings
GROUP BY Booking_Status
ORDER BY Total_Bookings DESC;

-- ---------------------------------------------------------------------
-- Q3. How many successful rides are there?   [SUM()]
-- ---------------------------------------------------------------------
SELECT SUM(Successful_Ride) AS Successful_Rides
FROM bookings;

-- ---------------------------------------------------------------------
-- Q4. How many rides were cancelled?   [SUM() / WHERE]
-- ---------------------------------------------------------------------
SELECT SUM(Canceled_Ride) AS Total_Cancelled_Rides
FROM bookings;

-- Split by who cancelled
SELECT
    SUM(Customer_Canceled) AS Cancelled_By_Customer,
    SUM(Driver_Canceled)   AS Cancelled_By_Driver
FROM bookings;

-- Same result using WHERE
SELECT COUNT(*) AS Total_Cancelled_Rides
FROM bookings
WHERE Booking_Status IN ('Canceled by Customer', 'Canceled by Driver');

-- ---------------------------------------------------------------------
-- Q5. What is the cancellation rate?   [SUM() + calculation]
-- ---------------------------------------------------------------------
SELECT
    ROUND(SUM(Canceled_Ride) * 100.0 / COUNT(*), 2) AS Cancellation_Rate_Pct
FROM bookings;

-- ---------------------------------------------------------------------
-- Q6. What is the total revenue?   [SUM()]
-- Revenue counts successful rides only (Booking_Value is also filled
-- for cancelled bookings, so the filter is required).
-- ---------------------------------------------------------------------
SELECT SUM(Booking_Value) AS Total_Revenue
FROM bookings
WHERE Booking_Status = 'Success';

-- ---------------------------------------------------------------------
-- Q7. What is the average booking value?   [AVG()]
-- ---------------------------------------------------------------------
SELECT ROUND(AVG(Booking_Value), 2) AS Avg_Booking_Value
FROM bookings
WHERE Booking_Status = 'Success';

-- ---------------------------------------------------------------------
-- Q8. Which vehicle type has the most bookings?   [GROUP BY, ORDER BY]
-- ---------------------------------------------------------------------
SELECT
    Vehicle_Type,
    COUNT(*) AS Total_Bookings
FROM bookings
GROUP BY Vehicle_Type
ORDER BY Total_Bookings DESC;

-- ---------------------------------------------------------------------
-- Q9. Which vehicle type generates the most revenue?   [SUM(), GROUP BY]
-- ---------------------------------------------------------------------
SELECT
    Vehicle_Type,
    SUM(Successful_Ride) AS Successful_Rides,
    SUM(Booking_Value)   AS Revenue
FROM bookings
WHERE Booking_Status = 'Success'
GROUP BY Vehicle_Type
ORDER BY Revenue DESC;

-- ---------------------------------------------------------------------
-- Q10. Which payment method is most used?   [GROUP BY, COUNT()]
-- ---------------------------------------------------------------------
SELECT
    Payment_Method,
    COUNT(*) AS Total_Rides
FROM bookings
WHERE Payment_Method IS NOT NULL
GROUP BY Payment_Method
ORDER BY Total_Rides DESC;

-- ---------------------------------------------------------------------
-- Q11. What are the peak booking hours?   [GROUP BY]
-- ---------------------------------------------------------------------
SELECT
    Booking_Hour,
    COUNT(*) AS Total_Bookings
FROM bookings
GROUP BY Booking_Hour
ORDER BY Total_Bookings DESC;

-- ---------------------------------------------------------------------
-- Q12. Which pickup locations are most popular?   [GROUP BY, LIMIT]
-- ---------------------------------------------------------------------
SELECT
    Pickup_Location,
    COUNT(*) AS Total_Bookings
FROM bookings
GROUP BY Pickup_Location
ORDER BY Total_Bookings DESC
LIMIT 10;

-- ---------------------------------------------------------------------
-- Q13. Which drop locations are most popular?   [GROUP BY, LIMIT]
-- ---------------------------------------------------------------------
SELECT
    Drop_Location,
    COUNT(*) AS Total_Bookings
FROM bookings
GROUP BY Drop_Location
ORDER BY Total_Bookings DESC
LIMIT 10;

-- ---------------------------------------------------------------------
-- Q14. What is the average ride distance?   [AVG()]
-- (completed rides only; cancelled bookings have distance 0)
-- ---------------------------------------------------------------------
SELECT ROUND(AVG(Ride_Distance), 2) AS Avg_Ride_Distance_KM
FROM bookings
WHERE Booking_Status = 'Success';

-- ---------------------------------------------------------------------
-- Q15. What is the average customer rating?   [AVG()]
-- ---------------------------------------------------------------------
SELECT ROUND(AVG(Customer_Rating), 2) AS Avg_Customer_Rating
FROM bookings
WHERE Customer_Rating IS NOT NULL;

-- ---------------------------------------------------------------------
-- Q16. What is the average driver rating?   [AVG()]
-- ---------------------------------------------------------------------
SELECT ROUND(AVG(Driver_Ratings), 2) AS Avg_Driver_Rating
FROM bookings
WHERE Driver_Ratings IS NOT NULL;

-- ---------------------------------------------------------------------
-- Q17. Which month has the most bookings?   [GROUP BY, ORDER BY]
-- Note: this dataset covers July 2024 only, so one row is returned.
-- The query works unchanged if you add more months later.
-- ---------------------------------------------------------------------
SELECT
    Month_Name,
    COUNT(*) AS Total_Bookings
FROM bookings
GROUP BY Month_Name
ORDER BY Total_Bookings DESC;

-- ---------------------------------------------------------------------
-- Q18. Which month generates the most revenue?   [SUM(), GROUP BY]
-- ---------------------------------------------------------------------
SELECT
    Month_Name,
    SUM(Booking_Value) AS Revenue
FROM bookings
WHERE Booking_Status = 'Success'
GROUP BY Month_Name
ORDER BY Revenue DESC;

-- ---------------------------------------------------------------------
-- Q19. How many rides are incomplete?   [SUM()]
-- ---------------------------------------------------------------------
SELECT SUM(Incomplete_Ride_Flag) AS Incomplete_Rides
FROM bookings;

-- ---------------------------------------------------------------------
-- Q20. What are the main cancellation reasons?   [GROUP BY]
-- ---------------------------------------------------------------------

-- Customer cancellation reasons
SELECT
    Canceled_Rides_by_Customer AS Reason,
    COUNT(*) AS Total
FROM bookings
WHERE Customer_Canceled = 1
GROUP BY Canceled_Rides_by_Customer
ORDER BY Total DESC;

-- Driver cancellation reasons
SELECT
    Canceled_Rides_by_Driver AS Reason,
    COUNT(*) AS Total
FROM bookings
WHERE Driver_Canceled = 1
GROUP BY Canceled_Rides_by_Driver
ORDER BY Total DESC;

-- =====================================================================
-- END OF ANALYSIS
-- =====================================================================
