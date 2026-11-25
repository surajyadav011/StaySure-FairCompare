# Methodology — StaySure FairCompare

## 1. Objective

Describe cancellation performance for hotel bookings and assess how much the observed **TA/TO minus Direct** cancellation-rate gap changes when both channels are compared under the **same distribution of hotel type and lead-time buckets**.

This is descriptive standardization of observational data; it is **not** a randomized experiment, predictive model or causal identification strategy.

## 2. Dataset and analysis population

- Public TidyTuesday hotel bookings dataset: **119,390 booking rows**, **32 original fields**.
- Cancellation outcome: `is_canceled` (1 = canceled; 0 = not canceled).
- Overall KPIs include all distribution channels.
- Fair-comparison population is restricted to **Direct** and **TA/TO** channels: **112,515 rows**.
- Hotel strata: **City Hotel** and **Resort Hotel**.
- Lead-time strata: **0–30**, **31–90**, and **91+** days.
- Together these yield **six common hotel × lead-time strata** and **12 channel-specific rows**; both channels are observed in all six strata.

## 3. Definitions

For each channel or group:

`cancellation_rate = canceled_bookings / total_bookings`

For the raw gap:

`raw_gap_pp = 100 * (rate_TA_TO - rate_Direct)`

For each common stratum `s`:

- `N(Direct,s)`: Direct bookings in stratum `s`
- `N(TA/TO,s)`: TA/TO bookings in stratum `s`
- `N(s) = N(Direct,s) + N(TA/TO,s)`
- `N(total) = sum_s N(s) = 112,515`
- **Common pooled weight:** `w(s) = N(s) / N(total)`
- **Within-channel cancellation rate:** `r(channel,s) = canceled(channel,s) / N(channel,s)`

The weights sum to 1 across the **six unique strata**, not across all 12 channel rows (the same weight is stored on each channel row).

The **directly standardized rate** is:

```text
standardized_rate(channel) = Σ over strata s [w(s) × r(channel,s)]
standardized_gap_pp = 100 × (standardized_rate(TA/TO) - standardized_rate(Direct))
gap_reduction_pp = raw_gap_pp - standardized_gap_pp
```

This uses the combined Direct + TA/TO booking mix as the shared reference population. Rates are computed before rounding; displayed percentages and percentage-point gaps are rounded at presentation time.

## 4. Verified result

| Comparison | Direct | TA/TO | TA/TO − Direct |
|---|---:|---:|---:|
| Raw cancellation rate | 17.46% | 41.03% | 23.57 pp |
| Hotel × lead-time standardized rate | 21.12% | 39.61% | 18.49 pp |

Using full precision, the difference between raw and standardized gaps is **5.07 percentage points**. Subtracting the individually rounded displayed gaps may yield 5.08; use unrounded rates for this calculation.

**Interpretation:** Some of the raw channel gap is associated with differences in hotel/lead-time composition. A substantial descriptive gap remains under these controls, but no causal channel effect is established.

## 5. Quality checks and exclusions

The original 119,390 rows are retained in the main analysis; flags identify:
- **180 zero-guest rows**
- **1 negative ADR row**
- **1 extreme ADR row with ADR = 5400**

The three exclusions are assessed **separately** against the original standardized comparison, not as one combined cleaned subset. Sensitivity weights are recomputed for each restricted comparison.

| Sensitivity scenario | Rows removed (all channels) | Rows removed (Direct + TA/TO) | Standardized Direct | Standardized TA/TO | Gap |
|---|---:|---:|---:|---:|---:|
| Original | 0 | 0 | 21.12% | 39.61% | 18.49 pp |
| Exclude zero guests | 180 | 154 | 21.16% | 39.64% | 18.48 pp |
| Exclude negative ADR | 1 | 1 | 21.12% | 39.61% | 18.49 pp |
| Exclude extreme ADR | 1 | 1 | 21.12% | 39.61% | 18.49 pp |

The 180 zero-guest exclusions include **154 Direct/TA/TO rows** and **26 bookings from other channels**. The standardized comparison is recalculated on 112,515 rows in the original scenario and 112,361 in the no-zero-guests scenario (112,514 for each ADR exclusion). These are small changes relative to the comparison population; the results do not demonstrate immunity to other biases.

The hypothetical one-row-per-identical-pattern calculation is **separate** from these channel-standardization scenarios. It compares overall cancellation rates only; it does not establish that the standardized channel gap is robust to deduplication.

## 6. Implementation references

- `sql/03_cleaning.sql`: typed analysis table, lead-time buckets and quality flags
- `sql/04_kpi_analysis.sql`: grouped cancellation KPIs
- `sql/05_fair_comparison.sql`: pooled standardization
- `sql/06_sensitivity.sql`: exclusion and duplicate-pattern checks
- `notebooks/01_data_validation_eda.ipynb`: independent pandas implementation
- `data/processed/fair_channel_groups.csv`: 12-group stratum details (fractional rate fields)
- `data/processed/channel_comparison.csv`: percentage-valued raw and standardized rates
- `data/processed/sensitivity_summary.csv`: percentage-valued sensitivity rates, percentage-point gaps and counts of excluded rows

**Unit warning:** In `fair_channel_groups.csv`, `cancellation_rate` and `weighted_rate` are proportions (0–1); in `channel_comparison.csv` and `sensitivity_summary.csv`, the `*_pct` columns are already on a 0–100 percentage scale. Avoid multiplying the latter by 100 when formatting Tableau values.

## 7. Interpretive boundaries

Confounding may remain from variables such as market segment, customer type, deposit type, previous cancellations, seasonality and other factors. This project does not attempt propensity matching, full multivariable adjustment or experimentation. See [limitations](limitations.md).
