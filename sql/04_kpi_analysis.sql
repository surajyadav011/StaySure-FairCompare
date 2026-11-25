
-- Q1. What is the cancellation rate for each distribution channel?
SELECT distribution_channel,
COUNT(*) AS total_bookings,
SUM(is_canceled) AS canceled_bookings,
ROUND(100.0*SUM(is_canceled)/COUNT(*),2) AS cancellation_rate_pct
FROM clean.hotel_bookings_analysis
GROUP BY distribution_channel
ORDER BY cancellation_rate_pct DESC;


-- Q2. What is the cancellation rate for each lead-time bucket?
SELECT lead_time_bucket,
COUNT(*) AS total_bookings,
SUM(is_canceled) AS canceled_bookings,
ROUND(100.0*SUM(is_canceled)/COUNT(*),2) AS cancellation_rate_pct
FROM clean.hotel_bookings_analysis
GROUP BY lead_time_bucket
ORDER BY MIN(lead_time);


-- Q3. What is the cancellation rate for each hotel type?
SELECT hotel,
COUNT(*) AS total_bookings,
SUM(is_canceled) AS canceled_bookings,
ROUND(100.0*SUM(is_canceled)/COUNT(*),2) AS cancellation_rate_pct
FROM clean.hotel_bookings_analysis
GROUP BY hotel
ORDER BY cancellation_rate_pct DESC;


-- Q4. Cancellation rate by hotel, channel and lead time
SELECT hotel,distribution_channel,lead_time_bucket,
COUNT(*) AS total_bookings,
SUM(is_canceled) AS canceled_bookings,
ROUND(100.0*SUM(is_canceled)/COUNT(*),2) AS cancellation_rate_pct
FROM clean.hotel_bookings_analysis
GROUP BY hotel,distribution_channel,lead_time_bucket
ORDER BY hotel,distribution_channel,MIN(lead_time);



-- Q5. Validate grouped booking and cancellation totals
WITH group_summary AS (
SELECT hotel,distribution_channel,lead_time_bucket,
COUNT(*) AS total_bookings,
SUM(is_canceled) AS canceled_bookings
FROM clean.hotel_bookings_analysis
GROUP BY hotel,distribution_channel,lead_time_bucket
)
SELECT COUNT(*) AS observed_groups,
SUM(total_bookings) AS total_bookings,
SUM(canceled_bookings) AS canceled_bookings
FROM group_summary;

