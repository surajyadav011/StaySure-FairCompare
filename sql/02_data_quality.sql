
-- ------------------------------------ BUSINESS QUESTION --------------------------------------------------------------------------------

-- How many hotel bookings were canceled, and how many were not?

select is_canceled,
count(*) as total_bookings
from raw.hotel_bookings
group by is_canceled
order by is_canceled;

-- Q.How many bookings belong to each hotel type?


SELECT hotel,
COUNT(*) AS total_bookings
FROM raw.hotel_bookings
GROUP BY hotel
ORDER BY total_bookings DESC;

-- Q. How many missing values exist in children, agent, company, and country?

SELECT COUNT(*) AS total_bookings,
SUM(CASE WHEN children IS NULL
OR UPPER(TRIM(children)) IN ('NA', 'NULL', '')
THEN 1 ELSE 0
END) AS missing_children,

SUM(CASE WHEN agent IS NULL
OR UPPER(TRIM(agent)) IN ('NA', 'NULL', '')
THEN 1 ELSE 0
END) AS missing_agent,

SUM(CASE
WHEN company IS NULL
OR UPPER(TRIM(company)) IN ('NA', 'NULL', '')
THEN 1 ELSE 0
END) AS missing_company,

SUM(CASE
WHEN country IS NULL
OR UPPER(TRIM(country)) IN ('NA', 'NULL', '')
THEN 1 ELSE 0
END) AS missing_country

FROM raw.hotel_bookings;


-- Q. How many bookings have a negative ADR?

SELECT
    COUNT(*) AS negative_adr_bookings
FROM raw.hotel_bookings
WHERE CASE
WHEN TRIM(adr) ~ '^-?[0-9]+(\.[0-9]+)?$'
THEN TRIM(adr)::NUMERIC < 0
ELSE FALSE
END;



-- Q. How many bookings have zero guests?

SELECT COUNT(*) AS total_bookings,
SUM(CASE WHEN TRIM(adults) = '0'
AND TRIM(children) IN ('0', '0.0')
AND TRIM(babies) = '0'
THEN 1 ELSE 0
END ) AS zero_guest_bookings
FROM raw.hotel_bookings;


-- Q. Find invalid cancellation flags and status mismatches

SELECT SUM(CASE
WHEN is_canceled IS NULL
OR TRIM(is_canceled) NOT IN ('0', '1')
THEN 1 ELSE 0
END ) AS invalid_cancellation_flags,

SUM( CASE
WHEN TRIM(is_canceled) = '0'
AND COALESCE(TRIM(reservation_status), '') <> 'Check-Out'
THEN 1
WHEN TRIM(is_canceled) = '1'
AND COALESCE(TRIM(reservation_status), '')
NOT IN ('Canceled', 'No-Show')
THEN 1 ELSE 0
END ) AS status_mismatches
FROM raw.hotel_bookings;

-- Check the highest ADR in the dataset
SELECT MAX(CASE WHEN TRIM(adr) ~ '^-?[0-9]+(\.[0-9]+)?$'
THEN TRIM(adr)::NUMERIC END) AS max_adr
FROM raw.hotel_bookings;

-- Count records belonging to identical full-row groups

SELECT COALESCE(SUM(group_size), 0) AS duplicate_like_rows
FROM ( SELECT COUNT(*) AS group_size
FROM raw.hotel_bookings h
GROUP BY to_jsonb(h)
HAVING COUNT(*) > 1
) d;
