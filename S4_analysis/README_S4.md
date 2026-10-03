# S4 — statistical reproducibility notebook

`S4_reproducibility_analysis.ipynb` starts from the S3 derivative datasets and reproduces the manuscript's primary temporal metrics, paired stratified bootstrap intervals, model comparisons, project-context checks, LOPO decomposition, alternative outcomes, baselines, C-sensitivity, project-cluster bootstrap, jackknife, and Leave-One-Repository-Out checks.

The paired bootstrap reproduces the manuscript Table 3 intervals using the original algorithm: 2,000 stratified resamples with the same resampled test observations applied to all models and `numpy.random.default_rng(42)`. The per-iteration shuffled sample order is retained because it advances the random-number generator exactly as in the archived original analysis notebook.

The original computational environment is recorded in `environment.txt`. The notebook inputs are `../S3_data/S3_modeling_dataset.csv` and `../S3_data/S3_outcome_robustness.csv`.
