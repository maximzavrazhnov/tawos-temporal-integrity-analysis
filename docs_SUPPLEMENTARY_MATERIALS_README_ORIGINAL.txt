Supplementary materials for
“Temporal Integrity of Digital Traces in Project Team Analytics: Risk of Information Leakage and Cross-Project Model Transferability”
====================================================================================================

S1_SQL.zip
  Original SQL workflow for TAWOS v1.1: source diagnostics, analytical cohort construction,
  temporal-integrity construction, exports, and verification checks. The previously missing
  upstream cohort-building SQL was recovered from the authors' MySQL Workbench execution history
  dated 2026-07-21 and is packaged as original executed logic rather than inferred reconstruction.

S2_variable_dictionary.xlsx
  Dictionary and lineage for the 50 variables in the sprint-level modeling dataset.

S3_data.zip
  Derivative analytical datasets used for modeling and robustness checks:
  - S3_modeling_dataset.csv (952 rows × 50 variables, 15 projects)
  - S3_modeling_checks.csv
  - S3_outcome_robustness.csv

S4_analysis.zip
  Executed reproducibility notebook and environment documentation. The notebook starts from S3
  and reproduces the manuscript's primary metrics and paired bootstrap intervals, plus the extended
  model-validation analyses.

S5_extended_checks.xlsx
  Extended checks S5.1–S5.6: stability-threshold sensitivity, LOPO project decomposition,
  alternative outcomes, baselines and C-sensitivity, cluster bootstrap / jackknife uncertainty,
  and Leave-One-Repository-Out.

Key study checkpoints
---------------------
Cohort funnel: 4594 -> 4507 -> 4504 -> 4457 -> 4401 -> 1399 -> 1201 -> 1169 -> 1069 -> 994 -> 952.
Final cohort: 952 sprints, 15 projects, 9 repositories, 23,661 issues.
Modeling dataset: 952 × 50.
Temporal stability at theta=0.10: 3 sprints at start; 21 sprints at the 20% horizon.
Primary operational outcome: 156/952 positive sprints (16.39%).

Source dataset
--------------
TAWOS v1.1, DOI 10.5522/04/21308124.
