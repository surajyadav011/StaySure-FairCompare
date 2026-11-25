# Data Quality, Limitations and Responsible Interpretation

## 1. Historical observational data

The project uses a public historical hotel booking dataset. It is not a live feed, not a randomized experiment, and may not represent current cancellation behavior, other hotels or other markets.

## 2. No unique booking identifier

There is no verified unique booking ID in the raw data. Records that agree across all 32 fields **cannot automatically be treated as erroneous duplicates**: two distinct bookings may legitimately have identical field values.

- Rows belonging to repeated complete-row patterns: **40,165**.
- Surplus rows relative to one-per-pattern counting: **31,994**.
- If one row per exact pattern were retained hypothetically: **87,396 bookings**, **24,025 canceled**, **27.49% overall cancellation**.
- Main analysis retains all **119,390 records** and reports **37.04% overall cancellation**.

This discrepancy underscores sensitivity to record identity and dataset assumptions. The project **does not claim** true duplicate bookings or use the one-per-pattern rate as its main result.

## 3. Missing and unusual values

The notebook reports:
- `children`: **4 missing**
- `agent`: **16,340 missing**
- `company`: **112,593 missing**
- `country`: **488 missing**
- **180 zero-guest rows** according to the explicit zero-guest definition
- **1 negative ADR record**
- Highest ADR of **5400**, treated as an extreme-value sensitivity case, not automatically an error
- No invalid cancellation flags and no cancellation/status mismatches in the tested rules

Missing `agent` or `company` does not necessarily mean a corrupt booking. Data quality flags are retained rather than indiscriminately dropping records.

## 4. Channel comparison is not causal

Standardization adjusts for **hotel type** and **lead-time bucket** only. The Direct and TA/TO groups may still differ in market segment, deposits, customer type, season, guest history and other observed or unobserved characteristics.

Therefore:
- The **raw gap of 23.57 pp** is a descriptive association.
- The **standardized gap of 18.49 pp** is also a descriptive association under one common hotel × lead-time composition.
- The **5.07 pp reduction** reflects the chosen standardization, not a causal effect or guaranteed business improvement.
- Do not claim that moving a reservation between channels will change its outcome by 18.49 or 23.57 points.

## 5. Robustness scope

The reported standardized-rate scenarios separately exclude:
1. Zero-guest rows,
2. The negative ADR row,
3. The row with ADR = 5400.

Each scenario recalculates the pooled stratum weights. The zero-guest filter excludes **180 rows overall**, of which **154** are Direct/TA/TO bookings. Each ADR filter excludes **one row overall**, and that row is in the Direct/TA/TO comparison population. The respective fair-comparison populations are **112,515 (baseline)**, **112,361 (without zero guests)** and **112,514 (each ADR exclusion)**. These tests produce gaps around **18.48–18.49 pp**, but they do not assess every potential bias.

**Crucially:** The hypothetical identical-pattern exercise calculates **overall** cancellation performance only; it does **not** provide a standardized channel comparison after deduplication. Do not describe the standardized gap as tested or stable under deduplication.

## 6. Small and heterogeneous channel groups

The **Undefined** channel has only five bookings. Its observed 80% cancellation rate is unstable and should not be compared at face value with much larger groups. GDS has only 193 bookings; percentages for small groups warrant extra caution. The primary fair comparison intentionally focuses on **Direct and TA/TO**, not all channels simultaneously.

## 7. Reproducibility and operational limitations

- The Jupyter notebook uses `pathlib` to locate project files relative to the repository. Launch Jupyter from the repository root or its `notebooks/` folder so the path lookup resolves as intended. Python package dependencies must still be installed.
- The PostgreSQL scripts include table creation and analysis but **do not automatically load** the CSV. A separate manual import step is required.
- The Excel workbook is supplied, but a standalone Power Query M-script export is **not** included in the repository.
- The Tableau packaged workbook and screenshots are included; interactive behavior should be tested in Tableau Public before making claims about live filter interactions.
- CSV exports have **different row grains and percentage scales**. Validate units and joins before reusing data.

## 8. Future improvements

Potential extensions include a portable Python file-path strategy, a repeatable PostgreSQL loader, more explicit data provenance checks, a documented comparison with additional covariates, and validation of published Tableau action filters. These are **opportunities**, not features already implemented.

## Source

[TidyTuesday hotel bookings dataset and original data dictionary](https://github.com/rfordatascience/tidytuesday/blob/main/data/2020/2020-02-11/readme.md).
