
-- Q1. Cancellation rate after excluding zero-guest bookings
SELECT COUNT(*) AS total_bookings,
SUM(is_canceled) AS canceled_bookings,
ROUND(100.0*SUM(is_canceled)/COUNT(*),2) AS cancellation_rate_pct
FROM clean.hotel_bookings_analysis
WHERE zero_guest_flag=0;


-- Q2. Standardized rates excluding zero-guest bookings
WITH channel_groups AS (
SELECT hotel,lead_time_bucket,distribution_channel,
COUNT(*) AS bookings,
SUM(is_canceled) AS canceled_bookings
FROM clean.hotel_bookings_analysis
WHERE distribution_channel IN ('Direct','TA/TO')
AND zero_guest_flag=0
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
ROUND(100.0*SUM(canceled_bookings)/SUM(bookings),2) AS raw_rate_pct,
ROUND(100.0*SUM((canceled_bookings*1.0/bookings)*(pooled_bookings*1.0/all_pooled_bookings)),2) AS standardized_rate_pct
FROM weighted
GROUP BY distribution_channel
ORDER BY distribution_channel;


-- Q3. Cancellation rate excluding negative ADR
SELECT COUNT(*) AS total_bookings,
SUM(is_canceled) AS canceled_bookings,
ROUND(100.0*SUM(is_canceled)/COUNT(*),2) AS cancellation_rate_pct
FROM clean.hotel_bookings_analysis
WHERE adr>=0 OR adr IS NULL;


-- Q4. Cancellation rate excluding the extreme ADR record
SELECT COUNT(*) AS total_bookings,
SUM(is_canceled) AS canceled_bookings,
ROUND(100.0*SUM(is_canceled)/COUNT(*),2) AS cancellation_rate_pct
FROM clean.hotel_bookings_analysis
WHERE adr<>5400 OR adr IS NULL;


-- Q5. Hypothetical sensitivity to identical full-row patterns
WITH patterns AS (
SELECT to_jsonb(h) AS row_pattern,
COUNT(*) AS group_size,
MAX(TRIM(is_canceled)::INTEGER) AS canceled
FROM raw.hotel_bookings h
GROUP BY to_jsonb(h)
)
SELECT SUM(group_size) AS original_bookings,
COUNT(*) AS one_per_pattern_bookings,
SUM(group_size*canceled) AS original_cancellations,
SUM(canceled) AS one_per_pattern_cancellations,
ROUND(100.0*SUM(group_size*canceled)/SUM(group_size),2) AS original_rate_pct,
ROUND(100.0*SUM(canceled)/COUNT(*),2) AS one_per_pattern_rate_pct
FROM patterns;

