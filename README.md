# Ola Ride Booking & Customer Analytics

An end-to-end data analyst project that analyzes **103,024 Ola ride bookings (July 2024)** to understand booking performance, revenue, cancellations, payments, popular locations and customer ratings.

**Workflow:** Raw Data → Excel / Power Query cleaning → Clean CSV → MySQL analysis → Power BI dashboard → GitHub

---

## Business Objective

Answer key questions for an Ola-style ride-hailing business:

- How many bookings turn into successful rides?
- How much revenue do completed rides generate?
- Why do rides get cancelled, and who cancels more?
- Which vehicle types, payment methods and locations perform best?
- When is demand highest?

---

## Tools Used

| Tool | Purpose |
|---|---|
| Excel & Power Query | Data cleaning and transformation |
| MySQL | SQL-based business analysis |
| Power BI | Interactive dashboard and visualization |
| GitHub | Project documentation and portfolio |

---

## Dataset

- **Records:** 103,024 bookings
- **Period:** July 2024
- **Coverage:** 50 pickup and 50 drop-off areas (Bengaluru neighbourhoods)
- **Main fields:** booking status, customer, vehicle type, pickup/drop location, booking value, payment method, ride distance, driver and customer ratings, cancellation and incomplete-ride reasons

---

## Data Cleaning (Excel & Power Query)

- Cleaned text and numeric fields and removed unnecessary columns
- Corrected Date and Time formats
- Created analytical columns:
  - `Month_Name`, `Day_Name`, `Booking_Hour`
  - `Successful_Ride`, `Canceled_Ride`
  - `Customer_Canceled`, `Driver_Canceled`
  - `Incomplete_Ride_Flag`, `Total_Booking`

---

## SQL Analysis (MySQL)

All queries are in [`sql/ola_sql_analysis.sql`](sql/ola_sql_analysis.sql) using the table `bookings`.

| #  | Business Question                              | SQL Concept            |
| -- | ---------------------------------------------- | ---------------------- |
| 1  | How many total bookings are there?             | `COUNT()`              |
| 2  | What is the booking status distribution?       | `GROUP BY`             |
| 3  | How many successful rides are there?           | `SUM()`                |
| 4  | How many rides were cancelled?                 | `SUM()` / `WHERE`      |
| 5  | What is the cancellation rate?                 | `SUM()` + calculation  |
| 6  | What is the total revenue?                     | `SUM()`                |
| 7  | What is the average booking value?             | `AVG()`                |
| 8  | Which vehicle type has the most bookings?      | `GROUP BY`, `ORDER BY` |
| 9  | Which vehicle type generates the most revenue? | `SUM()`, `GROUP BY`    |
| 10 | Which payment method is most used?             | `GROUP BY`, `COUNT()`  |
| 11 | What are the peak booking hours?               | `GROUP BY`             |
| 12 | Which pickup locations are most popular?       | `GROUP BY`, `LIMIT`    |
| 13 | Which drop locations are most popular?         | `GROUP BY`, `LIMIT`    |
| 14 | What is the average ride distance?             | `AVG()`                |
| 15 | What is the average customer rating?           | `AVG()`                |
| 16 | What is the average driver rating?             | `AVG()`                |
| 17 | Which month has the most bookings?             | `GROUP BY`, `ORDER BY` |
| 18 | Which month generates the most revenue?        | `SUM()`, `GROUP BY`    |
| 19 | How many rides are incomplete?                 | `SUM()`                |
| 20 | What are the main cancellation reasons?        | `GROUP BY`             |

### Example: Total Revenue

```sql
SELECT SUM(Booking_Value) AS Total_Revenue
FROM bookings
WHERE Booking_Status = 'Success';
```

### Example: Vehicle Performance

```sql
SELECT
    Vehicle_Type,
    SUM(Successful_Ride) AS Successful_Rides,
    SUM(Booking_Value)   AS Revenue
FROM bookings
WHERE Booking_Status = 'Success'
GROUP BY Vehicle_Type
ORDER BY Revenue DESC;
```

---

## Power BI Dashboard

A two-page interactive dashboard built on the cleaned data (`data/ola_clean.csv`).

### Page 1: Overview

- Date range slicer (1 to 31 July 2024) and vehicle type slicer
- KPI cards: Total Bookings, Successful Rides, Total Revenue, Cancellation Rate, Avg Ride Distance, Avg Customer Rating
- Daily bookings trend (line chart)
- Revenue by vehicle type
- Rides by payment method (donut)
- Top 10 pickup and drop locations

![Page 1 - Overview](screenshots/page1.png)

### Page 2: Cancellation Analysis

- Booking status share (donut)
- Incomplete ride reasons (donut)
- Customer cancellation reasons
- Driver cancellation reasons
- Vehicle type slicer

![Page 2 - Cancellation Analysis](screenshots/page2.png)

---

## Key Insights

| Metric | Value |
|---|---|
| Total bookings | 103,024 |
| Successful rides | 63,967 (62.09%) |
| Cancelled rides | 28,933 (28.08%) |
| Cancelled by driver | 18,434 (17.89%) |
| Cancelled by customer | 10,499 (10.19%) |
| Driver not found | 10,124 (9.83%) |
| Total revenue (successful rides) | 35,080,467 |
| Average booking value | 548.42 |
| Average ride distance | 22.85 km |
| Average customer / driver rating | 4.0 / 4.0 |
| Incomplete rides | 3,926 |

**Findings**

1. **Only 62% of bookings are completed.** About 28% are cancelled and about 10% end with no driver found.
2. **Drivers cancel more than customers** (17.89% vs 10.19% of all bookings).
3. **Top customer cancellation reason:** "Driver is not moving towards pickup location" (3,175), followed by "Driver asked to cancel" (2,670).
4. **Top driver cancellation reason:** "Personal & Car related issue" (6,542), followed by "Customer related issue" (5,413).
5. **Cash is the most used payment method** (35,022 rides), then UPI (25,881). Cards are under 5% of rides.
6. **Prime Sedan leads in both bookings (14,877) and revenue (about 5.22M)**, though the top vehicle types are close.
7. **Demand is steady through the day.** The busiest hours (12, 15, 8 and 17) each have about 4,400 bookings, so there is no sharp peak.
8. **Location demand is spread evenly.** Top pickups are Banashankari, Yeshwanthpur and RT Nagar. Top drop-offs are Peenya, Mysore Road and MG Road.

**Business recommendations**

- Reduce driver-side cancellations with driver incentives and better driver-ETA tracking, because they are the largest cancellation group.
- Improve pickup tracking and ETA accuracy to cut customer cancellations caused by drivers not moving towards the pickup.
- Add driver supply in areas with high "driver not found" counts.
- Promote UPI and digital payments to reduce cash dependence.

---

## Notes and Assumptions

- Revenue counts **successful rides only**, because `Booking_Value` is also filled for cancelled bookings.
- "Driver Not Found" is not counted as a cancellation in `Canceled_Ride`; it is reported separately.
- Incomplete rides are part of the "Success" status (3,926 rides).
- The dataset covers July 2024 only, so month-level queries return one month.

---

## Repository Structure

```
ola-ride-analytics/
├── README.md
├── Ola_Dashboard.pbix        # Power BI report
├── data/
│   ├── ola_clean.csv         # Cleaned dataset (MySQL-ready)
│   └── clean_ola_data.xlsx   # Cleaned Excel file
├── sql/
│   └── ola_sql_analysis.sql  # Table setup + 20 business questions
└── screenshots/
    ├── page1.png
    └── page2.png
```

---

## How to Run

1. Open MySQL Workbench and run the setup section of `sql/ola_sql_analysis.sql`. Update the file path in the `LOAD DATA` line to where you saved `data/ola_clean.csv`.
2. Run the 20 analysis queries and compare results with the insights above.
3. Open `Ola_Dashboard.pbix` in Power BI Desktop to explore the dashboard.

---

## Skills Demonstrated

Data cleaning · SQL (aggregation, filtering, grouping) · KPI design · Dashboard design in Power BI · Business insight generation · Documentation

---

## Author

**[Tushar Subhash Walunj]**
