USE TAWOS;

SELECT
    COUNT(*) AS final_sprint_count,

    COUNT(DISTINCT Project_ID) AS final_project_count,

    COUNT(DISTINCT repository_name) AS repository_count,

    MIN(Start_Date) AS earliest_sprint_start,

    MAX(End_Date) AS latest_sprint_end,

    SUM(issue_count) AS total_issues_in_final_cohort,

    ROUND(AVG(issue_count), 2) AS mean_issues_per_sprint,

    MIN(issue_count) AS min_issues_per_sprint,

    MAX(issue_count) AS max_issues_per_sprint,

    ROUND(AVG(core_team_size), 2) AS mean_team_size,

    MIN(core_team_size) AS min_team_size,

    MAX(core_team_size) AS max_team_size,

    ROUND(AVG(assigned_issue_share), 4)
        AS mean_assigned_issue_share,

    ROUND(AVG(experienced_member_share), 4)
        AS mean_experienced_member_share,

    ROUND(AVG(avg_prior_task_count), 2)
        AS mean_prior_tasks_per_member,

    SUM(success_90_end24) AS primary_success_count,

    COUNT(*) - SUM(success_90_end24)
        AS primary_failure_count,

    ROUND(
        AVG(success_90_end24),
        4
    ) AS primary_success_rate,

    ROUND(
        AVG(success_80_end0),
        4
    ) AS success_80_end0_rate,

    ROUND(
        AVG(success_80_end24),
        4
    ) AS success_80_end24_rate,

    ROUND(
        AVG(success_95_end24),
        4
    ) AS success_95_end24_rate,

    ROUND(
        AVG(success_90_end48),
        4
    ) AS success_90_end48_rate,

    SUM(effort_subset) AS effort_subset_sprint_count,

    ROUND(
        AVG(effort_subset),
        4
    ) AS effort_subset_share,

    SUM(story_point_subset)
        AS story_point_subset_sprint_count,

    ROUND(
        AVG(story_point_subset),
        4
    ) AS story_point_subset_share,

    (
        SELECT COUNT(
            DISTINCT CONCAT(
                f.Project_ID,
                ':',
                tm.Assignee_ID
            )
        )
        FROM article_final_cohort f
        JOIN article_sprint_team_members tm
            ON tm.Project_ID = f.Project_ID
           AND tm.Sprint_ID = f.Sprint_ID
    ) AS distinct_project_scoped_team_members

FROM article_final_cohort;
