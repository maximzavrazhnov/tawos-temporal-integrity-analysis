USE TAWOS;

SELECT
    COUNT(*) AS sprint_count,

    ROUND(
        AVG(created_after_start_share),
        4
    ) AS mean_created_after_start_share,

    SUM(created_after_start_share = 0)
        AS sprints_without_late_created_issues,

    SUM(created_after_start_share <= 0.10)
        AS sprints_with_max_10pct_created_after_start,

    ROUND(
        AVG(created_after_20pct_share),
        4
    ) AS mean_created_after_20pct_share,

    SUM(created_after_20pct_share <= 0.10)
        AS sprints_with_max_10pct_created_after_20pct,

    ROUND(
        AVG(resolved_before_start_share),
        4
    ) AS mean_resolved_before_start_share,

    SUM(resolved_before_start_share > 0)
        AS sprints_with_pre_resolved_issues,

    ROUND(
        AVG(assignee_changed_issue_share),
        4
    ) AS mean_assignee_changed_issue_share,

    SUM(assignee_changed_issue_share = 0)
        AS sprints_without_assignee_changes,

    SUM(assignee_changed_issue_share <= 0.10)
        AS sprints_with_max_10pct_assignee_changes,

    ROUND(
        AVG(sprint_changed_issue_share),
        4
    ) AS mean_sprint_changed_issue_share,

    SUM(sprint_changed_issue_share = 0)
        AS sprints_without_scope_changes,

    SUM(sprint_changed_issue_share <= 0.10)
        AS sprints_with_max_10pct_scope_changes,

    SUM(stable_from_start_flag)
        AS stable_from_start_sprint_count,

    ROUND(
        AVG(stable_from_start_flag),
        4
    ) AS stable_from_start_share,

    SUM(stable_after_20pct_flag)
        AS stable_after_20pct_sprint_count,

    ROUND(
        AVG(stable_after_20pct_flag),
        4
    ) AS stable_after_20pct_share

FROM article_temporal_integrity;
