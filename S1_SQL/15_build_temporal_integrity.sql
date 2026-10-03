/*
ORIGINAL TEMPORAL-INTEGRITY SQL recovered from MySQL Workbench execution history dated 2026-07-21.
Only XML/HTML history encoding was decoded; SQL semantics were not reconstructed or altered.
*/

USE TAWOS;

DROP TABLE IF EXISTS article_temporal_integrity;

DROP TABLE IF EXISTS article_temporal_change_stats;

DROP TABLE IF EXISTS article_temporal_issue_stats;

DROP TABLE IF EXISTS article_final_cohort_issues;

CREATE TABLE article_final_cohort_issues AS
SELECT
    f.Project_ID,
    f.Project_Key,
    f.Sprint_ID,
    f.Start_Date,
    f.End_Date,
    f.prediction_time_20pct,

    i.ID AS Issue_ID,
    i.Creation_Date,
    i.Resolution_Date,
    i.Assignee_ID,
    i.Type,
    i.Priority

FROM article_final_cohort f

JOIN issue i
    ON i.Sprint_ID = f.Sprint_ID;

ALTER TABLE article_final_cohort_issues
    ADD PRIMARY KEY (Issue_ID),
    ADD INDEX idx_article_fci_sprint (Sprint_ID),
    ADD INDEX idx_article_fci_project (Project_ID);

CREATE TABLE article_temporal_issue_stats AS
SELECT
    Project_ID,
    Project_Key,
    Sprint_ID,

    COUNT(*) AS issue_count_check,

    SUM(
        CASE
            WHEN Creation_Date > Start_Date THEN 1
            ELSE 0
        END
    ) AS created_after_start_count,

    ROUND(
        AVG(
            CASE
                WHEN Creation_Date > Start_Date THEN 1
                ELSE 0
            END
        ),
        6
    ) AS created_after_start_share,

    SUM(
        CASE
            WHEN Creation_Date > prediction_time_20pct THEN 1
            ELSE 0
        END
    ) AS created_after_20pct_count,

    ROUND(
        AVG(
            CASE
                WHEN Creation_Date > prediction_time_20pct THEN 1
                ELSE 0
            END
        ),
        6
    ) AS created_after_20pct_share,

    SUM(
        CASE
            WHEN Resolution_Date IS NOT NULL
             AND Resolution_Date < Start_Date
            THEN 1
            ELSE 0
        END
    ) AS resolved_before_start_count,

    ROUND(
        AVG(
            CASE
                WHEN Resolution_Date IS NOT NULL
                 AND Resolution_Date < Start_Date
                THEN 1
                ELSE 0
            END
        ),
        6
    ) AS resolved_before_start_share,

    SUM(
        CASE
            WHEN Resolution_Date IS NULL THEN 1
            ELSE 0
        END
    ) AS missing_resolution_date_count

FROM article_final_cohort_issues

GROUP BY
    Project_ID,
    Project_Key,
    Sprint_ID;

ALTER TABLE article_temporal_issue_stats
    ADD PRIMARY KEY (Sprint_ID);

CREATE TABLE article_temporal_change_stats AS
SELECT
    x.Project_ID,
    x.Project_Key,
    x.Sprint_ID,

    SUM(
        CASE
            WHEN LOWER(TRIM(cl.Field)) = 'assignee'
             AND cl.Creation_Date >= x.Start_Date
             AND cl.Creation_Date <= x.End_Date
            THEN 1
            ELSE 0
        END
    ) AS assignee_change_event_count,

    COUNT(
        DISTINCT CASE
            WHEN LOWER(TRIM(cl.Field)) = 'assignee'
             AND cl.Creation_Date >= x.Start_Date
             AND cl.Creation_Date <= x.End_Date
            THEN x.Issue_ID
            ELSE NULL
        END
    ) AS assignee_changed_issue_count,

    COUNT(
        DISTINCT CASE
            WHEN LOWER(TRIM(cl.Field)) = 'assignee'
             AND cl.Creation_Date > x.prediction_time_20pct
             AND cl.Creation_Date <= x.End_Date
            THEN x.Issue_ID
            ELSE NULL
        END
    ) AS assignee_changed_after_20pct_issue_count,

    SUM(
        CASE
            WHEN LOWER(TRIM(cl.Field)) = 'sprint'
             AND cl.Creation_Date >= x.Start_Date
             AND cl.Creation_Date <= x.End_Date
            THEN 1
            ELSE 0
        END
    ) AS sprint_change_event_count,

    COUNT(
        DISTINCT CASE
            WHEN LOWER(TRIM(cl.Field)) = 'sprint'
             AND cl.Creation_Date >= x.Start_Date
             AND cl.Creation_Date <= x.End_Date
            THEN x.Issue_ID
            ELSE NULL
        END
    ) AS sprint_changed_issue_count,

    COUNT(
        DISTINCT CASE
            WHEN LOWER(TRIM(cl.Field)) = 'sprint'
             AND cl.Creation_Date > x.prediction_time_20pct
             AND cl.Creation_Date <= x.End_Date
            THEN x.Issue_ID
            ELSE NULL
        END
    ) AS sprint_changed_after_20pct_issue_count

FROM article_final_cohort_issues x

LEFT JOIN change_log cl
    ON cl.Issue_ID = x.Issue_ID

GROUP BY
    x.Project_ID,
    x.Project_Key,
    x.Sprint_ID;

ALTER TABLE article_temporal_change_stats
    ADD PRIMARY KEY (Sprint_ID);

CREATE TABLE article_temporal_integrity AS
SELECT
    f.Project_ID,
    f.Project_Key,
    f.project_name,
    f.repository_name,
    f.Sprint_ID,
    f.sprint_name,
    f.Start_Date,
    f.End_Date,
    f.prediction_time_20pct,
    f.issue_count,
    f.core_team_size,

    i.created_after_start_count,
    i.created_after_start_share,
    i.created_after_20pct_count,
    i.created_after_20pct_share,
    i.resolved_before_start_count,
    i.resolved_before_start_share,
    i.missing_resolution_date_count,

    c.assignee_change_event_count,
    c.assignee_changed_issue_count,

    ROUND(
        c.assignee_changed_issue_count
        / NULLIF(f.issue_count, 0),
        6
    ) AS assignee_changed_issue_share,

    c.assignee_changed_after_20pct_issue_count,

    ROUND(
        c.assignee_changed_after_20pct_issue_count
        / NULLIF(f.issue_count, 0),
        6
    ) AS assignee_changed_after_20pct_issue_share,

    c.sprint_change_event_count,
    c.sprint_changed_issue_count,

    ROUND(
        c.sprint_changed_issue_count
        / NULLIF(f.issue_count, 0),
        6
    ) AS sprint_changed_issue_share,

    c.sprint_changed_after_20pct_issue_count,

    ROUND(
        c.sprint_changed_after_20pct_issue_count
        / NULLIF(f.issue_count, 0),
        6
    ) AS sprint_changed_after_20pct_issue_share,

    CASE
        WHEN i.created_after_start_share <= 0.10
         AND i.resolved_before_start_share <= 0.05
         AND (
             c.assignee_changed_issue_count
             / NULLIF(f.issue_count, 0)
         ) <= 0.10
         AND (
             c.sprint_changed_issue_count
             / NULLIF(f.issue_count, 0)
         ) <= 0.10
        THEN 1
        ELSE 0
    END AS stable_from_start_flag,

    CASE
        WHEN i.created_after_20pct_share <= 0.10
         AND i.resolved_before_start_share <= 0.05
         AND (
             c.assignee_changed_after_20pct_issue_count
             / NULLIF(f.issue_count, 0)
         ) <= 0.10
         AND (
             c.sprint_changed_after_20pct_issue_count
             / NULLIF(f.issue_count, 0)
         ) <= 0.10
        THEN 1
        ELSE 0
    END AS stable_after_20pct_flag

FROM article_final_cohort f

JOIN article_temporal_issue_stats i
    ON i.Sprint_ID = f.Sprint_ID

JOIN article_temporal_change_stats c
    ON c.Sprint_ID = f.Sprint_ID;

ALTER TABLE article_temporal_integrity
    ADD PRIMARY KEY (Sprint_ID),
    ADD INDEX idx_article_ti_project (Project_ID);
