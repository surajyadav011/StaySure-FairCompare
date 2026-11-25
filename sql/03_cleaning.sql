CREATE SCHEMA IF NOT EXISTS clean;

-- data-type conversion

SELECT hotel,
NULLIF(TRIM(is_canceled),'')::INTEGER AS is_canceled,
NULLIF(TRIM(lead_time),'')::INTEGER AS lead_time
FROM raw.hotel_bookings
LIMIT 10;

SELECT COUNT(*) AS total_rows,
SUM(CASE WHEN is_canceled IS NULL OR TRIM(is_canceled) !~ '^[01]$' THEN 1 ELSE 0 END) AS invalid_flags,
SUM(CASE WHEN lead_time IS NULL OR TRIM(lead_time) !~ '^[0-9]+$' THEN 1 ELSE 0 END) AS invalid_lead_time,
SUM(CASE WHEN children IS NOT NULL AND UPPER(TRIM(children)) NOT IN ('NA','NULL','') AND TRIM(children) !~ '^[0-9]+(\.0+)?$' THEN 1 ELSE 0 END) AS invalid_children
FROM raw.hotel_bookings;

-- Create an analysis-ready table without modifying raw data
CREATE TABLE clean.hotel_bookings AS
SELECT
hotel,
NULLIF(TRIM(is_canceled),'')::INTEGER AS is_canceled,
NULLIF(TRIM(lead_time),'')::INTEGER AS lead_time,
NULLIF(TRIM(arrival_date_year),'')::INTEGER AS arrival_date_year,
arrival_date_month,
NULLIF(TRIM(arrival_date_week_number),'')::INTEGER AS arrival_date_week_number,
NULLIF(TRIM(arrival_date_day_of_month),'')::INTEGER AS arrival_date_day_of_month,
NULLIF(TRIM(stays_in_weekend_nights),'')::INTEGER AS stays_in_weekend_nights,
NULLIF(TRIM(stays_in_week_nights),'')::INTEGER AS stays_in_week_nights,
NULLIF(TRIM(adults),'')::INTEGER AS adults,
CASE WHEN children IS NULL OR UPPER(TRIM(children)) IN ('NA','NULL','')
THEN NULL ELSE TRIM(children)::NUMERIC::INTEGER END AS children,
NULLIF(TRIM(babies),'')::INTEGER AS babies,
meal,
CASE WHEN country IS NULL OR UPPER(TRIM(country)) IN ('NA','NULL','')
THEN NULL ELSE TRIM(country) END AS country,
market_segment,
distribution_channel,
NULLIF(TRIM(is_repeated_guest),'')::INTEGER AS is_repeated_guest,
NULLIF(TRIM(previous_cancellations),'')::INTEGER AS previous_cancellations,
NULLIF(TRIM(previous_bookings_not_canceled),'')::INTEGER AS previous_bookings_not_canceled,
reserved_room_type,
assigned_room_type,
NULLIF(TRIM(booking_changes),'')::INTEGER AS booking_changes,
deposit_type,
CASE WHEN agent IS NULL OR UPPER(TRIM(agent)) IN ('NA','NULL','')
THEN NULL ELSE TRIM(agent) END AS agent,
CASE WHEN company IS NULL OR UPPER(TRIM(company)) IN ('NA','NULL','')
THEN NULL ELSE TRIM(company) END AS company,
NULLIF(TRIM(days_in_waiting_list),'')::INTEGER AS days_in_waiting_list,
customer_type,
NULLIF(TRIM(adr),'')::NUMERIC AS adr,
NULLIF(TRIM(required_car_parking_spaces),'')::INTEGER AS required_car_parking_spaces,
NULLIF(TRIM(total_of_special_requests),'')::INTEGER AS total_of_special_requests,
reservation_status,
NULLIF(TRIM(reservation_status_date),'')::DATE AS reservation_status_date
FROM raw.hotel_bookings;

SELECT COUNT(*) AS cleaned_rows,
COUNT(*) FILTER (WHERE children IS NULL) AS missing_children,
COUNT(*) FILTER (WHERE country IS NULL) AS missing_country,
COUNT(*) FILTER (WHERE adr < 0) AS negative_adr
FROM clean.hotel_bookings;


-- Create analysis-ready features
CREATE OR REPLACE VIEW clean.hotel_bookings_analysis AS
SELECT h.*,
CASE WHEN lead_time BETWEEN 0 AND 30 THEN '0-30 days'
WHEN lead_time BETWEEN 31 AND 90 THEN '31-90 days'
WHEN lead_time >= 91 THEN '91+ days'
ELSE 'Unknown' END AS lead_time_bucket,
CASE WHEN adults = 0 AND children = 0 AND babies = 0 THEN 1 ELSE 0 END AS zero_guest_flag,
CASE WHEN adr < 0 THEN 1 ELSE 0 END AS adr_negative_flag
FROM clean.hotel_bookings h;


-- Validate lead-time distribution
SELECT lead_time_bucket, COUNT(*) AS total_bookings
FROM clean.hotel_bookings_analysis
GROUP BY lead_time_bucket
ORDER BY lead_time_bucket;


-- Validate quality flags
SELECT COUNT(*) AS total_bookings,
SUM(zero_guest_flag) AS zero_guest_bookings,
SUM(adr_negative_flag) AS negative_adr_bookings
FROM clean.hotel_bookings_analysis;

