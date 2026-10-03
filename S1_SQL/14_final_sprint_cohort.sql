USE TAWOS;

SELECT
    f.Project_ID,
    f.Project_Key,
    f.project_name,
    f.repository_name,

    f.Sprint_ID,
    f.sprint_name,
    f.sprint_state,

    f.Start_Date,
    f.End_Date,
    f.Complete_Date,
    f.prediction_time_20pct,

    f.planned_duration_hours,

    ROUND(
        f.planned_duration_hours / 24,
        2
    ) AS planned_duration_days,

    f.completion_delay_hours,

    f.eligible_sprint_count,
    f.eligible_sprint_order,

    f.issue_count,

    f.assigned_issue_count,
    f.assigned_issue_share,

    f.core_team_size,

    (
        SELECT GROUP_CONCAT(
            tm.Assignee_ID
            ORDER BY tm.Assignee_ID
            SEPARATOR '|'
        )
        FROM article_sprint_team_members tm
        WHERE
            tm.Project_ID = f.Project_ID
            AND tm.Sprint_ID = f.Sprint_ID
    ) AS team_member_ids,

    f.team_member_count,
    f.experienced_member_count,
    f.experienced_member_share,

    ROUND(
        f.avg_prior_task_count,
        2
    ) AS avg_prior_task_count,

    f.min_prior_task_count,
    f.max_prior_task_count,

    f.resolved_any_count,
    f.resolved_any_share,

    f.resolved_by_end_count,
    f.resolved_by_end_share,

    f.resolved_by_end24_count,
    f.resolved_by_end24_share,

    f.resolved_by_end48_count,
    f.resolved_by_end48_share,

    f.complete_resolution_by_end24_count,
    f.complete_resolution_by_end24_share,

    f.invalid_resolution_date_count,

    f.success_90_end24,
    f.success_80_end0,
    f.success_80_end24,
    f.success_95_end24,
    f.success_90_end48,

    f.bug_count,
    f.bug_share,

    f.high_priority_issue_count,

    f.story_point_present_count,
    f.positive_story_point_count,
    f.positive_story_point_share,
    f.total_story_points,

    f.positive_effort_issue_count,
    f.positive_effort_issue_share,
    f.total_positive_effort_minutes,

    f.avg_positive_resolution_time_minutes,

    f.effort_subset,
    f.story_point_subset

FROM article_final_cohort f

ORDER BY
    f.Project_ID,
    f.Start_Date,
    f.Sprint_ID;
