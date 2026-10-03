USE TAWOS;

SELECT
    ti.Project_ID,
    ti.Project_Key,
    ti.project_name,
    ti.repository_name,

    ti.Sprint_ID,
    ti.sprint_name,
    ti.Start_Date,
    ti.End_Date,
    ti.prediction_time_20pct,

    f.eligible_sprint_order,

    ROUND(
        TIMESTAMPDIFF(
            HOUR,
            ti.Start_Date,
            ti.End_Date
        ) / 24,
        4
    ) AS planned_duration_days,

    ti.issue_count,
    ti.core_team_size,

    f.assigned_issue_share,
    f.experienced_member_share,
    f.avg_prior_task_count,

    f.bug_count,
    f.bug_share,

    f.high_priority_issue_count,

    ROUND(
        f.high_priority_issue_count
        / NULLIF(f.issue_count, 0),
        6
    ) AS high_priority_issue_share,

    f.positive_story_point_share,
    f.positive_effort_issue_share,

    -- Позднее создание задач
    ti.created_after_start_count,
    ti.created_after_start_share,

    ti.created_after_20pct_count,
    ti.created_after_20pct_share,

    GREATEST(
        ti.created_after_start_count
        -
        ti.created_after_20pct_count,
        0
    ) AS created_between_start_and_20pct_count,

    ROUND(
        GREATEST(
            ti.created_after_start_count
            -
            ti.created_after_20pct_count,
            0
        )
        / NULLIF(ti.issue_count, 0),
        6
    ) AS created_between_start_and_20pct_share,

    -- Задачи, разрешенные до начала спринта
    ti.resolved_before_start_count,
    ti.resolved_before_start_share,

    ti.missing_resolution_date_count,

    -- Изменения исполнителей
    ti.assignee_change_event_count,
    ti.assignee_changed_issue_count,
    ti.assignee_changed_issue_share,

    ti.assignee_changed_after_20pct_issue_count,
    ti.assignee_changed_after_20pct_issue_share,

    GREATEST(
        ti.assignee_changed_issue_count
        -
        ti.assignee_changed_after_20pct_issue_count,
        0
    ) AS assignee_changed_before_20pct_issue_count,

    ROUND(
        GREATEST(
            ti.assignee_changed_issue_count
            -
            ti.assignee_changed_after_20pct_issue_count,
            0
        )
        / NULLIF(ti.issue_count, 0),
        6
    ) AS assignee_changed_before_20pct_issue_share,

    -- Изменения принадлежности задач спринту
    ti.sprint_change_event_count,
    ti.sprint_changed_issue_count,
    ti.sprint_changed_issue_share,

    ti.sprint_changed_after_20pct_issue_count,
    ti.sprint_changed_after_20pct_issue_share,

    GREATEST(
        ti.sprint_changed_issue_count
        -
        ti.sprint_changed_after_20pct_issue_count,
        0
    ) AS sprint_changed_before_20pct_issue_count,

    ROUND(
        GREATEST(
            ti.sprint_changed_issue_count
            -
            ti.sprint_changed_after_20pct_issue_count,
            0
        )
        / NULLIF(ti.issue_count, 0),
        6
    ) AS sprint_changed_before_20pct_issue_share,

    ti.stable_from_start_flag,
    ti.stable_after_20pct_flag,

    -- Операционная результативность:
    -- используется только для дополнительного анализа
    f.resolved_by_end24_count,
    f.resolved_by_end24_share,
    f.success_90_end24

FROM article_temporal_integrity ti

JOIN article_final_cohort f
    ON f.Project_ID = ti.Project_ID
   AND f.Sprint_ID = ti.Sprint_ID

ORDER BY
    ti.Project_ID,
    ti.Start_Date,
    ti.Sprint_ID;
