# Verified Findings

These results are computed from the committed project SQL, notebook and CSV exports. Percentages are rounded for presentation; calculations use the original unrounded values.

## Overall cancellation performance

| Measure | Value |
|---|---:|
| Booking records | 119,390 |
| Canceled bookings | 44,224 |
| Overall cancellation rate | 37.04% |

## By hotel

| Hotel | Bookings | Canceled | Cancellation rate |
|---|---:|---:|---:|
| City Hotel | 79,330 | 33,102 | 41.73% |
| Resort Hotel | 40,060 | 11,122 | 27.76% |

## By distribution channel

| Channel | Bookings | Canceled | Cancellation rate |
|---|---:|---:|---:|
| Direct | 14,645 | 2,557 | 17.46% |
| TA/TO | 97,870 | 40,152 | 41.03% |
| Corporate | 6,677 | 1,474 | 22.08% |
| GDS | 193 | 37 | 19.17% |
| Undefined | 5 | 4 | 80.00% |

**Interpretation:** The Undefined group contains only five bookings and is excluded from the dashboard's channel-rate chart to avoid overemphasizing an unstable percentage. Those records remain in the overall KPIs.

## By booking lead time

| Lead-time bucket | Bookings | Canceled | Cancellation rate |
|---|---:|---:|---:|
| 0–30 days | 38,706 | 7,185 | 18.56% |
| 31–90 days | 29,553 | 11,141 | 37.70% |
| 91+ days | 51,131 | 25,898 | 50.65% |

In this dataset, longer lead times are **associated with** higher cancellation rates. This is not proof that shortening lead time would itself cause fewer cancellations.

## Direct vs TA/TO: raw and standardized

| Measure | Direct | TA/TO |
|---|---:|---:|
| Raw cancellation rate | 17.46% | 41.03% |
| Standardized rate (same hotel × lead-time mix) | 21.12% | 39.61% |

- Raw gap: **23.57 percentage points** (TA/TO minus Direct)
- Standardized gap: **18.49 percentage points**
- Gap reduction after standardizing composition: **5.07 percentage points** (computed from full precision)

The standardized analysis includes **112,515** Direct + TA/TO bookings and six shared hotel × lead-time strata.

## Within-stratum descriptive comparison

| Hotel | Lead time | Direct cancel rate | TA/TO cancel rate |
|---|---|---:|---:|
| City Hotel | 0–30 days | 13.70% | 25.20% |
| City Hotel | 31–90 days | 23.36% | 40.82% |
| City Hotel | 91+ days | 25.67% | 57.35% |
| Resort Hotel | 0–30 days | 10.07% | 14.79% |
| Resort Hotel | 31–90 days | 20.05% | 34.69% |
| Resort Hotel | 91+ days | 27.91% | 41.18% |

TA/TO has the higher observed cancellation rate in all six displayed strata. **This is a descriptive relationship**, not evidence that the channel independently causes cancellations.

## Sensitivity of the standardized gap

| Scenario (each exclusion separate) | Removed overall | Removed in Direct + TA/TO | Direct | TA/TO | Gap |
|---|---:|---:|---:|---:|---:|
| Original | 0 | 0 | 21.12% | 39.61% | 18.49 pp |
| Exclude zero-guest rows | 180 | 154 | 21.16% | 39.64% | 18.48 pp |
| Exclude negative ADR row | 1 | 1 | 21.12% | 39.61% | 18.49 pp |
| Exclude extreme ADR row | 1 | 1 | 21.12% | 39.61% | 18.49 pp |

In the no-zero-guests scenario, 180 rows leave the overall dataset but only 154 belong to Direct or TA/TO; the comparison population decreases from 112,515 to 112,361 bookings. Each ADR scenario removes one comparison booking (112,514 remaining). Small exclusion counts help explain the limited numerical movement but do not, on their own, prove the analysis is unbiased.

The conclusion is numerically similar under these three specific exclusions. This does **not** establish robustness to every possible data issue or unmeasured confounding.

## Identical full-row patterns — separate quality sensitivity

- **40,165** rows participate in repeated full-row patterns.
- **31,994** are surplus rows relative to keeping one per exact full-row pattern.
- A hypothetical one-per-pattern dataset would have **87,396** rows and **24,025** canceled rows, an overall cancellation rate of **27.49%** instead of **37.04%**.

Because there is **no unique booking identifier**, these repeated records were **not removed**. This hypothetical exercise concerns the **overall cancellation rate only**; it does not provide a deduplicated standardized channel-gap estimate.

## Business use and limits

The analysis motivates segmentation and further investigation of booking policies, risk indicators and channel composition. It **does not** justify a claim that reallocating bookings from TA/TO to Direct will cause a specific reduction in cancellations.

See [methodology](methodology.md) and [limitations](limitations.md).
