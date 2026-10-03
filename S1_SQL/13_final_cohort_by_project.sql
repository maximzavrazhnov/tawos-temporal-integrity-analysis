USE TAWOS;

SELECT
    Project_ID,
    Project_Key,
    project_name,
    repository_name,

    COUNT(*) AS sprint_count,

    MIN(Start_Date) AS earliest_sprint_start,

    MAX(End_Date) AS latest_sprint_end,

    SUM(issue_count) AS total_issue_count,

    ROUND(
        AVG(issue_count),
        2
    ) AS mean_issue_count,

    ROUND(
        AVG(core_team_size),
        2
    ) AS mean_team_size,

    MIN(core_team_size) AS min_team_size,

    MAX(core_team_size) AS max_team_size,

    ROUND(
        AVG(assigned_issue_share),
        4
    ) AS mean_assigned_issue_share,

    ROUND(
        AVG(experienced_member_share),
        4
    ) AS mean_experienced_member_share,

    ROUND(
        AVG(avg_prior_task_count),
        2
    ) AS mean_prior_task_count,

    SUM(success_90_end24)
        AS primary_success_count,

    COUNT(*) - SUM(success_90_end24)
        AS primary_failure_count,

    ROUND(
        AVG(success_90_end24),
        4
    ) AS primary_success_rate,

    ROUND(
        AVG(resolved_by_end24_share),
        4
    ) AS mean_resolved_by_end24_share,

    SUM(effort_subset)
        AS effort_subset_sprint_count,

    SUM(story_point_subset)
        AS story_point_subset_sprint_count

FROM article_final_cohort

GROUP BY
    Project_ID,
    Project_Key,
    project_name,
    repository_name

ORDER BY
    sprint_count DESC,
    Project_Key;
