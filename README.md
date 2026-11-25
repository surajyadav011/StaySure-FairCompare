# StaySure FairCompare
### Hotel Booking Cancellation & Fair Channel Performance Analytics

**An end-to-end, reproducible portfolio project** using Excel/Power Query, PostgreSQL, Python and Tableau to analyze hotel booking cancellations and compare distribution channels after accounting for differences in hotel type and booking lead time.

[**Explore the interactive Tableau Public workbook**](https://public.tableau.com/app/profile/suraj.suraj1627/viz/StaySure_FairCompare/Dashboard1)

![Hotel Cancellation Performance](tableau/screenshots/dashboard_01.png)
![Fair Channel Comparison and Robustness](tableau/screenshots/dashboard_02.png)

## Business problem

Direct bookings and travel-agent/tour-operator bookings have different cancellation rates. But they may also have different mixes of city/resort bookings and advance booking lead times. **How much of the observed cancellation-rate gap remains after comparing the channels using the same hotel-type × lead-time mix?**

This is an **observational comparison**, not a causal estimate of changing a booking channel.

## Verified highlights

| Metric | Result |
|---|---:|
| Total bookings | 119,390 |
| Canceled bookings | 44,224 |
| Overall cancellation rate | 37.04% |
| Direct booking cancellation rate | 17.46% |
| TA/TO cancellation rate | 41.03% |
| Raw TA/TO minus Direct gap | 23.57 percentage points |
| Standardized Direct rate | 21.12% |
| Standardized TA/TO rate | 39.61% |
| Standardized gap | 18.49 percentage points |
| Reduction in gap after standardization | 5.07 percentage points |

The standardized comparison uses **112,515 Direct and TA/TO bookings** across **six common hotel × lead-time strata** (12 channel-specific groups).

## Tools and analytical workflow

1. **Excel / Power Query:** initial data inspection and cleaning workflow (workbook at `excel/StaySure_FairCompare.xlsx`).
2. **PostgreSQL:** raw data schema, quality checks, typed analysis table, KPIs, hotel/lead-time/channel comparisons, direct standardization and sensitivity queries.
3. **Python (pandas, Matplotlib):** independent validation, exploratory plots, stratum-weight calculations, sensitivity checks and Tableau CSV exports.
4. **Tableau Public:** two dashboards covering overall cancellation performance and fair channel comparison / robustness.

## Repository structure

```text
StaySure-FairCompare/
├── data/
│   ├── raw/
│   │   └── hotels.csv
│   └── processed/
│       ├── hotel_bookings_analysis.csv
│       ├── fair_channel_groups.csv
│       ├── channel_comparison.csv
│       └── sensitivity_summary.csv
├── excel/
│   └── StaySure_FairCompare.xlsx
├── notebooks/
│   └── 01_data_validation_eda.ipynb
├── sql/
│   ├── 01_setup.sql
│   ├── 02_data_quality.sql
│   ├── 03_cleaning.sql
│   ├── 04_kpi_analysis.sql
│   ├── 05_fair_comparison.sql
│   └── 06_sensitivity.sql
├── tableau/
│   ├── StaySure_FairCompare.twbx
│   └── screenshots/
│       ├── dashboard_01.png
│       └── dashboard_02.png
└── docs/
    ├── methodology.md
    ├── data_dictionary.md
    ├── key_findings.md
    └── limitations.md
```

## How to reproduce

### Data and Python

- Clone the repository, then create a Python environment and install the notebook dependencies: `python -m pip install pandas matplotlib jupyter`.
- Start Jupyter: `jupyter notebook` and open `notebooks/01_data_validation_eda.ipynb`.
- **Important portability note:** the committed notebook currently uses author-specific absolute Windows paths in its CSV input and export cells. **Change those paths to your local clone directory** before running; they are not portable as committed.
- Run notebook cells in order. It checks the raw dataset, computes the standardized comparison, and exports the four files in `data/processed/`.

### PostgreSQL

- Create/connect to a PostgreSQL database.
- Run `sql/01_setup.sql` to create `raw.hotel_bookings` (all 32 fields initially stored as text).
- Import `data/raw/hotels.csv` into the raw table **before running the remaining scripts**. For example, inside `psql`, adapt the CSV path in:
  ```sql
  \copy raw.hotel_bookings FROM 'path/to/data/raw/hotels.csv' WITH (FORMAT csv, HEADER true, NULL '')
  ```
- Run `sql/02_data_quality.sql`, `sql/03_cleaning.sql`, `sql/04_kpi_analysis.sql`, `sql/05_fair_comparison.sql`, then `sql/06_sensitivity.sql` in order.
- The table-creation step in `03_cleaning.sql` is designed for a fresh database; repeating it without resetting the clean table can produce an already-exists error.
- Compare SQL outputs with the notebook results and `docs/key_findings.md`.

### Tableau

Open `tableau/StaySure_FairCompare.twbx` in Tableau, or use the [public dashboard](https://public.tableau.com/app/profile/suraj.suraj1627/viz/StaySure_FairCompare/Dashboard1). Tableau uses the analysis CSV exports for charts, standardized groups and sensitivity summaries.

## Analytical method

Raw cancellation rate = canceled bookings / bookings. For the fair comparison, group only **Direct** and **TA/TO** by hotel (City / Resort) and lead-time buckets (0–30, 31–90, 91+ days). For each stratum, compute a shared weight from the combined Direct + TA/TO booking count. Multiply each channel's within-stratum cancellation rate by the same shared weight, then sum across strata. Full derivation: [Methodology](docs/methodology.md).

## Documentation

- [Methodology and standardization formula](docs/methodology.md)
- [Data dictionary](docs/data_dictionary.md)
- [Detailed findings and sensitivity results](docs/key_findings.md)
- [Data quality, limitations and interpretation](docs/limitations.md)

## Dataset and credit

Dataset: [TidyTuesday — Hotel bookings, 2020-02-11](https://github.com/rfordatascience/tidytuesday/tree/main/data/2020/2020-02-11), derived from the Hotel Booking Demand dataset described by António, Almeida and Nunes (2019). This is a historical, publicly shared dataset, **not real-time hotel operations data**.

## Interpretation caution

A lower adjusted cancellation rate in Direct does **not** prove that moving TA/TO customers to Direct would reduce cancellations. Unmeasured customer and booking characteristics may explain part of the remaining gap. Identical-looking full rows were retained because no unique booking identifier is available to establish true duplicate bookings. See [Limitations](docs/limitations.md).
