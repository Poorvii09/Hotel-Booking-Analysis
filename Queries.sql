use hotelbookings;
-- Total bookings
SELECT COUNT(*) AS total_bookings
FROM booking
WHERE status = 'Occupied';

-- Occupancy rate
SELECT ROUND(SUM(CASE WHEN status='Occupied' THEN 1 ELSE 0 END)*100.0/COUNT(*),2) AS occupancy_rate
FROM booking;

-- Vacancy rate
SELECT ROUND(SUM(CASE WHEN status='Vacant' THEN 1 ELSE 0 END)*100.0/COUNT(*),2) AS vacancy_rate
FROM booking;

-- Monthly occupancy
SELECT year, month, COUNT(*) AS occupied_rooms 
FROM booking
WHERE status='Occupied'
GROUP BY year,month
ORDER BY year,MIN(month_no);

-- Occupancy Rate by Month
SELECT year, month,ROUND(SUM(status='Occupied')*100/COUNT(*),2) AS occupancy_rate
FROM booking
GROUP BY year,month
ORDER BY year,MIN(month_no);

-- Yearly occupancy
SELECT year,ROUND(SUM(status='Occupied')*100/COUNT(*),2) AS occupancy_rate
FROM booking
GROUP BY year;

-- Most popular room
SELECT room_no, COUNT(*) AS total_bookings
FROM booking
WHERE status='Occupied'
GROUP BY room_no
ORDER BY total_bookings DESC;booking

-- Least used rooms
SELECT room_no, COUNT(*) AS total_bookings
FROM booking
WHERE status='Occupied'
GROUP BY room_no
ORDER BY total_bookings;

-- Room utilization %
SELECT room_no, ROUND(SUM(status='Occupied')*100/COUNT(*),2) AS utilization
FROM booking
GROUP BY room_no;


-- Top 10 repeated guests
SELECT guest_name,COUNT(*) AS stays
FROM booking
WHERE status='Occupied'
GROUP BY guest_name
ORDER BY stays DESC
LIMIT 10;

-- Total unique guests
SELECT COUNT(DISTINCT guest_name) AS unique_guests
FROM booking
WHERE status='Occupied';

-- Weekday occupancy
SELECT weekday, COUNT(*) AS occupied_rooms
FROM booking
WHERE status='Occupied'
GROUP BY weekday
ORDER BY FIELD(
weekday,
'Monday',
'Tuesday',
'Wednesday',
'Thursday',
'Friday',
'Saturday',
'Sunday'
);

-- Weekends vs Weekdays
SELECT is_weekend, COUNT(*) AS occupied_rooms
FROM booking
WHERE status='Occupied'
GROUP BY is_weekend;

-- Fully occupied days
SELECT date, COUNT(*) AS occupied_rooms
FROM booking
WHERE status='Occupied'
GROUP BY date
HAVING occupied_rooms=6;

-- Days with No Bookings
SELECT date
FROM booking
GROUP BY date
HAVING SUM(status='Occupied')=0;

-- Average occupied rooms per day
SELECT ROUND(AVG(occupied_rooms),2) AS avg_rooms
FROM
(
SELECT date, COUNT(*) AS occupied_rooms
FROM booking
WHERE status='Occupied'
GROUP BY date
)t;

-- Unique Guests
SELECT
COUNT(DISTINCT guest_name) AS unique_guests
FROM booking
WHERE status='Occupied';

-- Top Booking Months
SELECT month,COUNT(*) AS bookings
FROM booking
WHERE status='Occupied'
GROUP BY month
ORDER BY bookings DESC;

-- Peak Booking year
SELECT year,COUNT(*) AS bookings
FROM booking
WHERE status='Occupied'
GROUP BY year
ORDER BY bookings DESC;

-- Daily occupancy trend
SELECT date, COUNT(*) AS occupied_rooms
FROM booking
WHERE status='Occupied'
GROUP BY date
ORDER BY date;

-- Total 20 loyal customer
SELECT guest_name, COUNT(*) AS stays
FROM booking
WHERE status='Occupied'
GROUP BY guest_name
HAVING COUNT(*)>=5
ORDER BY stays DESC;

-- Guest staying in multiple years
SELECT guest_name, COUNT(DISTINCT year) AS years_visited
FROM booking
WHERE status='Occupied'
GROUP BY guest_name
HAVING years_visited>1
ORDER BY years_visited DESC;

-- Longest stay
WITH guest_stays AS (
    SELECT guest_name, date,
        ROW_NUMBER() OVER(
            PARTITION BY guest_name
            ORDER BY date
        ) AS rn
    FROM booking
    WHERE status='Occupied'
)
SELECT *
FROM guest_stays;

-- Occupancy Heatmap data
SELECT month, weekday,
COUNT(*) AS occupied_rooms
FROM booking
WHERE status='Occupied'
GROUP BY month,weekday;

-- Room occupancy by year
SELECT year, room_no, COUNT(*) AS bookings
FROM booking
WHERE status='Occupied'
GROUP BY year,room_no
ORDER BY year,room_no;

-- Executive Summary 
SELECT
COUNT(*) AS total_room_nights,
SUM(status='Occupied') AS occupied_room_nights,
SUM(status='Vacant') AS vacant_room_nights,
ROUND(SUM(status='Occupied')*100/COUNT(*),2)
AS occupancy_rate,
COUNT(DISTINCT guest_name)
AS unique_guests
FROM booking;

-- Ranking Rooms
SELECT
room_no,
COUNT(*) AS bookings,
RANK() OVER (ORDER BY COUNT(*) DESC) AS room_rank
FROM booking
WHERE status='Occupied'
GROUP BY room_no;

-- Monthly Booking rank
WITH monthly_bookings AS (
    SELECT
        year,
        month,
        month_no,
        COUNT(*) AS bookings
    FROM booking
    WHERE status = 'Occupied'
    GROUP BY year, month, month_no
)
SELECT
    year,
    month,
    bookings,
    DENSE_RANK() OVER (
        PARTITION BY year
        ORDER BY bookings DESC
    ) AS monthly_rank
FROM monthly_bookings
ORDER BY year, monthly_rank;