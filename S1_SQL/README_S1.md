# S1 — SQL scripts for analytical cohort construction and temporal-integrity dataset

## Purpose
This supplement provides the SQL chain used to derive the analytical sprint-level cohort and the temporal-integrity modeling dataset from TAWOS v1.1.

## Provenance
The core cohort-building SQL (`10_build_analytical_cohort.sql`) and temporal-integrity SQL (`15_build_temporal_integrity.sql`) were recovered from the authors' MySQL Workbench execution history dated **2026-07-21**. The history entries were decoded from Workbench XML/HTML escaping; the SQL logic was not reconstructed from memory. The diagnostic and export scripts are the saved working queries from the same analysis.

Source database: **TAWOS v1.1**, MySQL dump described by Tawosi et al. (2022), DOI `10.5522/04/21308124`.

## Recommended execution order
1. `01`–`09`: source-database diagnostics (read-only; optional for reproduction, useful for environment checks).
2. `10_build_analytical_cohort.sql`: creates the cohort pipeline and `article_final_cohort`.
3. `11`–`14`: cohort funnel and cohort exports/checks.
4. `15_build_temporal_integrity.sql`: creates temporal-integrity tables.
5. `16`–`19`: temporal summary, sprint-level export, 50-column modeling dataset, and integrity checks.
6. `20_verify_expected_counts.sql`: package-level verification helper added after the analysis.

## Expected control values
Cohort funnel (sprints):
`4594 -> 4507 -> 4504 -> 4457 -> 4401 -> 1399 -> 1201 -> 1169 -> 1069 -> 994 -> 952`.

Final analytical cohort:
- sprints: **952**
- projects: **15**
- repositories: **9**
- issues: **23,661**
- primary-success sprints (`success_90_end24=1`): **156**

Temporal-integrity checks:
- modeling rows: **952**
- projects: **15**
- `stable_from_start_flag=1`: **3**
- `stable_after_20pct_flag=1`: **21**
- invalid share-range checks: **0**

Modeling export produced by `18_modeling_dataset.sql`: **952 rows x 50 columns**.

## Key operational definitions embedded in the original SQL
- eligible project: at least 20 eligible sprints;
- first 5 eligible sprints per project are excluded from the final modeling cohort and serve as history;
- experienced team member: at least 5 prior assigned issues in the same project before sprint start;
- final cohort requires at least 70% experienced team members;
- high-priority issues: `BLOCKER`, `CRITICAL`, `HIGHEST`;
- invalid resolution timestamp: `Resolution_Date < Creation_Date`;
- `effort_subset` and `story_point_subset`: positive-field coverage at least 50%;
- primary outcome: at least 90% of final-sprint issues resolved no later than 24 hours after planned sprint end.

## Important point-in-time limitation
As stated in the manuscript, the temporal-integrity analysis is evaluated relative to the observed final sprint issue set. It quantifies retrospective divergence of the final snapshot and does not reconstruct issues that had been removed from the sprint before the final state.

## Verification outputs from the preserved MySQL database
The `verification_outputs/` directory contains small exports made from the preserved TAWOS working database after recovery of the SQL history. They are included as provenance checks, not as additional analytical inputs. In particular, they document the project-level eligible-sprint counts, participant-history coverage, samples of the history tables, and the final cohort count of 952.
