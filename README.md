# TAWOS Temporal Integrity Analysis — Final Reproducibility Repository

Package synchronized to the submitted manuscript:

**“Temporal Integrity of Digital Traces in Project Team Analytics: Risk of Information Leakage and Cross-Project Model Transferability”**  
Russian title: **«Временная состоятельность цифровых следов в аналитике проектных команд: риск информационной утечки и межпроектная переносимость моделей»**.

## Repository structure

```text
.
├── S1_SQL/                         # raw TAWOS -> analytical cohort -> temporal-integrity exports
├── S2_variable_dictionary.xlsx     # lineage / dictionary for 50 modeling variables
├── S3_data/                        # final derivative datasets used by the analysis
├── S4_analysis/                    # executed reproducibility notebook + exact environment
├── S5_extended_checks.xlsx         # sensitivity, LOPO, baselines, uncertainty, LORO
├── paper/                          # final submission metadata (manuscript itself is not duplicated)
├── requirements.txt
└── CITATION.cff
```

## Final study checkpoints

The final cohort contains **952 sprints, 15 projects, 9 repositories and 23,661 issues**. The main modeling dataset contains **952 rows × 50 variables** and the primary operational outcome is positive for **156/952 sprints (16.39%)**.

Temporal-integrity diagnostics show that, relative to the final sprint issue set:

- **39.43%** of issues were created after sprint start on average;
- **33.97%** changed assignee;
- **44.71%** changed sprint membership;
- only **3** sprints were stable from sprint start;
- only **21** were stable by the 20% horizon under the primary threshold.

## Validation interpretation

Three L2-regularized logistic models compare context/history information, early events, and the retrospective final snapshot. The retrospective specification has the highest point ROC-AUC in the temporal holdout.

Under Leave-One-Project-Out, the retrospective model reports:

- pooled ROC-AUC: **0.4790**;
- pair-weighted within-project ROC-AUC: **0.6782**;
- cross-project-pair ROC-AUC: **0.4590**.

The study therefore separates point-in-time admissibility, within-project ranking, calibration and cross-project transferability instead of treating them as one notion of model quality.

## Reproduce the data-preparation pipeline

1. Obtain **TAWOS v1.1** (DOI `10.5522/04/21308124`) and load its MySQL dump locally.
2. Follow [`S1_SQL/README_S1.md`](S1_SQL/README_S1.md).
3. Run SQL scripts `01`–`20` in the documented order. The central recovered source steps are:
   - `10_build_analytical_cohort.sql`;
   - `15_build_temporal_integrity.sql`.
4. Compare the resulting counts with the verification outputs and expected checkpoints in `S1_SQL/`.


## Reproduce the statistical analysis from final derivative data

The final S3 derivative datasets are already included. To run the exact final notebook with its archived relative paths:

```bash
python -m venv .venv
# Windows: .venv\Scripts\activate
# macOS/Linux: source .venv/bin/activate
pip install -r requirements.txt
cd S4_analysis
jupyter notebook S4_reproducibility_analysis.ipynb
```

The archived environment is:

- Python 3.12.13
- NumPy 2.0.2
- pandas 2.2.2
- SciPy 1.16.3
- scikit-learn 1.6.1
- statsmodels 0.14.6

## Important methodological limitation

Temporal-integrity indicators are evaluated relative to the **observed final sprint issue set**. They quantify how the final snapshot diverges from information available at earlier horizons. The final sample also remains a limited collection of public software projects.

## Manuscript status

The final submission metadata are retained in `paper/`, while S1–S5 are the exact supplementary components described in the manuscript's data/code-availability section.

## License

No repository-level software license is granted by default. The raw TAWOS source remains governed by its own terms.
