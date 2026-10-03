USE TAWOS;

-- Verification helper added for the supplementary package (not part of the original execution history).
SELECT 'article_sprint_base' AS object_name, COUNT(*) AS row_count, COUNT(DISTINCT Project_ID) AS project_count FROM article_sprint_base
UNION ALL SELECT 'article_eligible_preproject', COUNT(*), COUNT(DISTINCT Project_ID) FROM article_eligible_preproject
UNION ALL SELECT 'article_ranked_candidates', COUNT(*), COUNT(DISTINCT Project_ID) FROM article_ranked_candidates
UNION ALL SELECT 'article_final_cohort', COUNT(*), COUNT(DISTINCT Project_ID) FROM article_final_cohort
UNION ALL SELECT 'article_temporal_integrity', COUNT(*), COUNT(DISTINCT Project_ID) FROM article_temporal_integrity;

SELECT
    SUM(issue_count) AS final_issue_count,
    COUNT(DISTINCT repository_name) AS final_repository_count,
    SUM(stable_from_start_flag) AS stable_from_start_count,
    SUM(stable_after_20pct_flag) AS stable_after_20pct_count
FROM article_temporal_integrity;
