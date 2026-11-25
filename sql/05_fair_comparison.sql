
-- Q1. Compare Direct and TA/TO within hotel and lead-time groups
SELECT hotel,lead_time_bucket,distribution_channel,
COUNT(*) AS total_bookings,
SUM(is_canceled) AS canceled_bookings,
ROUND(100.0*SUM(is_canceled)/COUNT(*),2) AS cancellation_rate_pct
FROM clean.hotel_bookings_analysis
WHERE distribution_channel IN ('Direct','TA/TO')
GROUP BY hotel,lead_time_bucket,distribution_channel
ORDER BY hotel,MIN(lead_time),distribution_channel;


-- Q2. Compare raw and standardized cancellation rates
WITH channel_groups AS (
SELECT hotel,lead_time_bucket,distribution_channel,
COUNT(*) AS bookings,
SUM(is_canceled) AS canceled_bookings
FROM clean.hotel_bookings_analysis
WHERE distribution_channel IN ('Direct','TA/TO')
GROUP BY hotel,lead_time_bucket,distribution_channel
),
weighted AS (
SELECT *,
SUM(bookings) OVER(PARTITION BY hotel,lead_time_bucket) AS pooled_bookings,
SUM(bookings) OVER() AS all_pooled_bookings
FROM channel_groups
)
SELECT distribution_channel,
SUM(bookings) AS total_bookings,
SUM(canceled_bookings) AS canceled_bookings,
ROUND(100.0*SUM(canceled_bookings)/SUM(bookings),2) AS raw_rate_pct,
ROUND(100.0*SUM((canceled_bookings*1.0/bookings)*(pooled_bookings*1.0/all_pooled_bookings)),2) AS standardized_rate_pct
FROM weighted
GROUP BY distribution_channel
ORDER BY distribution_channel;
