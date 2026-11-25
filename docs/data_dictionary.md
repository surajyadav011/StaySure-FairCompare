# Data Dictionary

This project begins with the public TidyTuesday hotel booking dataset. The raw CSV and `raw.hotel_bookings` PostgreSQL table contain **32 original columns**. The derived analysis export adds **three feature columns**. Descriptions below are field meanings, not claims that each variable is fully validated or fit for causal modeling.

## Original dataset columns

| Column | Meaning / interpretation |
|---|---|
| `hotel` | Hotel category (City Hotel or Resort Hotel) |
| `is_canceled` | Cancellation indicator: 1 canceled, 0 not canceled |
| `lead_time` | Days between reservation entry and scheduled arrival |
| `arrival_date_year` | Scheduled arrival year |
| `arrival_date_month` | Scheduled arrival month |
| `arrival_date_week_number` | Scheduled arrival calendar week |
| `arrival_date_day_of_month` | Scheduled arrival day of month |
| `stays_in_weekend_nights` | Weekend nights booked |
| `stays_in_week_nights` | Weekday nights booked |
| `adults` | Number of adults on the booking |
| `children` | Number of children; may be missing |
| `babies` | Number of babies |
| `meal` | Booked meal-plan code |
| `country` | Country code; may be missing |
| `market_segment` | Booking market-segment category |
| `distribution_channel` | Distribution channel, including Direct, TA/TO, Corporate, GDS and Undefined |
| `is_repeated_guest` | Indicator for repeat guest |
| `previous_cancellations` | Previous bookings canceled by this customer |
| `previous_bookings_not_canceled` | Previous bookings not canceled |
| `reserved_room_type` | Code for originally reserved room type |
| `assigned_room_type` | Code for ultimately assigned room type |
| `booking_changes` | Number of changes/amendments to booking |
| `deposit_type` | Deposit requirement category |
| `agent` | Travel-agent identifier/code; frequently missing |
| `company` | Company identifier/code; frequently missing |
| `days_in_waiting_list` | Time spent on waiting list, in days |
| `customer_type` | Customer-type category |
| `adr` | Average daily rate; can contain anomalous values |
| `required_car_parking_spaces` | Number of requested parking spaces |
| `total_of_special_requests` | Number of special requests |
| `reservation_status` | Final reservation status (e.g. Check-Out, Canceled, No-Show) |
| `reservation_status_date` | Date the final reservation status was recorded |

Definitions are consistent with the published source: [TidyTuesday hotel bookings data documentation](https://github.com/rfordatascience/tidytuesday/blob/main/data/2020/2020-02-11/readme.md).

## Derived features in `data/processed/hotel_bookings_analysis.csv`

| Field | Definition |
|---|---|
| `lead_time_bucket` | `0-30 days` if lead_time 0–30, `31-90 days` if 31–90, `91+ days` if 91 or more, otherwise `Unknown` |
| `zero_guest_flag` | 1 if adults = 0, children = 0 and babies = 0; otherwise 0 (missing children are not automatically zero) |
| `adr_negative_flag` | 1 if ADR is negative, otherwise 0 |

The cleaned SQL layer converts applicable text fields to integers, numeric ADR and a date for `reservation_status_date`. The raw layer preserves source fields as text.

## Export tables used in Tableau

### `data/processed/fair_channel_groups.csv`

| Field | Meaning and units |
|---|---|
| `hotel` | City Hotel / Resort Hotel |
| `lead_time_bucket` | One of the three lead-time buckets |
| `distribution_channel` | Direct / TA/TO |
| `bookings` | Booking count for the channel × stratum |
| `canceled` | Canceled booking count for the channel × stratum |
| `cancellation_rate` | Fraction canceled, **0–1 scale** |
| `pooled_bookings` | Direct + TA/TO booking count in the stratum |
| `common_weight` | Pooled stratum bookings / all Direct + TA/TO bookings |
| `weighted_rate` | cancellation_rate × common_weight; fractional contribution to the standardized rate |

### `data/processed/channel_comparison.csv`

| Field | Meaning and units |
|---|---|
| `distribution_channel` | Direct / TA/TO |
| `raw_rate_pct` | Raw channel cancellation rate in **0–100 percentage units** |
| `standardized_rate_pct` | Hotel × lead-time standardized rate in **0–100 percentage units** |

### `data/processed/sensitivity_summary.csv`

| Field | Meaning and units |
|---|---|
| `scenario` | Original / No zero guests / No negative ADR / No extreme ADR |
| `direct_pct` | Standardized Direct rate, **0–100 percentage units** |
| `ta_to_pct` | Standardized TA/TO rate, **0–100 percentage units** |
| `gap_pp` | TA/TO minus Direct, **percentage points** |
| `rows_removed_all` | Number of bookings excluded from the **entire 119,390-row dataset** in this scenario |
| `rows_removed_fair` | Number of excluded bookings within the **Direct + TA/TO comparison population (112,515 rows)** |

## Important grain / identifier note

The raw and analysis booking tables have **one source row per recorded booking**, but **no unique booking ID**. Identical full-row records cannot safely be interpreted as duplicate bookings. Exported stratum tables have a different grain (channel × hotel × lead-time), and channel comparison tables have one row per channel. Do not join these datasets at booking-row level without accounting for differences in grain.
