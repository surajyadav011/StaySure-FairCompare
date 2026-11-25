-- db connection check
SELECT
    current_database() AS database_name,
    current_user AS connected_user,
    version() AS postgres_version;


-- Create a schema for raw data
CREATE SCHEMA IF NOT EXISTS raw;

-- Create the raw hotel bookings table
CREATE TABLE IF NOT EXISTS raw.hotel_bookings (
    hotel TEXT,
    is_canceled TEXT,
    lead_time TEXT,
    arrival_date_year TEXT,
    arrival_date_month TEXT,
    arrival_date_week_number TEXT,
    arrival_date_day_of_month TEXT,
    stays_in_weekend_nights TEXT,
    stays_in_week_nights TEXT,
    adults TEXT,
    children TEXT,
    babies TEXT,
    meal TEXT,
    country TEXT,
    market_segment TEXT,
    distribution_channel TEXT,
    is_repeated_guest TEXT,
    previous_cancellations TEXT,
    previous_bookings_not_canceled TEXT,
    reserved_room_type TEXT,
    assigned_room_type TEXT,
    booking_changes TEXT,
    deposit_type TEXT,
    agent TEXT,
    company TEXT,
    days_in_waiting_list TEXT,
    customer_type TEXT,
    adr TEXT,
    required_car_parking_spaces TEXT,
    total_of_special_requests TEXT,
    reservation_status TEXT,
    reservation_status_date TEXT
);










 