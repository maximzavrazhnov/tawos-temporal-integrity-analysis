USE TAWOS;

SELECT
    COUNT(*) AS row_count,
    COUNT(DISTINCT Project_ID) AS project_count,

    SUM(
        created_after_start_share < 0
        OR created_after_start_share > 1
    ) AS invalid_created_after_start_share,

    SUM(
        created_after_20pct_share < 0
        OR created_after_20pct_share > 1
    ) AS invalid_created_after_20pct_share,

    SUM(
        resolved_before_start_share < 0
        OR resolved_before_start_share > 1
    ) AS invalid_resolved_before_start_share,

    SUM(
        assignee_changed_issue_share < 0
        OR assignee_changed_issue_share > 1
    ) AS invalid_assignee_share,

    SUM(
        sprint_changed_issue_share < 0
        OR sprint_changed_issue_share > 1
    ) AS invalid_sprint_change_share,

    SUM(stable_from_start_flag) AS stable_from_start_count,

    SUM(stable_after_20pct_flag) AS stable_after_20pct_count

FROM article_temporal_integrity;
