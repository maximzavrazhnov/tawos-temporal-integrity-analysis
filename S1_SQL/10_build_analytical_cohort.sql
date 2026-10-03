/*
ORIGINAL ANALYTICAL-COHORT SQL recovered from MySQL Workbench execution history dated 2026-07-21.
Only XML/HTML history encoding was decoded; SQL semantics were not reconstructed or altered.
This script creates article_sprint_base -> article_final_cohort and all intermediate article_* tables.
*/

USE TAWOS;

SET SESSION group_concat_max_len = 100000;

DROP TABLE IF EXISTS article_final_cohort;

DROP TABLE IF EXISTS article_history_coverage;

DROP TABLE IF EXISTS article_team_member_history;

DROP TABLE IF EXISTS article_assigned_issue_history;

DROP TABLE IF EXISTS article_sprint_team_members;

DROP TABLE IF EXISTS article_ranked_candidates;

DROP TABLE IF EXISTS article_project_counts;

DROP TABLE IF EXISTS article_eligible_preproject;

DROP TABLE IF EXISTS article_sprint_base;

CREATE TABLE article_sprint_base AS
SELECT
    s.ID AS Sprint_ID,
    s.Project_ID,
    p.Project_Key,
    p.Name AS project_name,
    r.Name AS repository_name,

    s.Name AS sprint_name,
    s.State AS sprint_state,

    s.Start_Date,
    s.End_Date,
    s.Activated_Date,
    s.Complete_Date,

    TIMESTAMPDIFF(
        HOUR,
        s.Start_Date,
        s.End_Date
    ) AS planned_duration_hours,

    TIMESTAMPDIFF(
        HOUR,
        s.End_Date,
        s.Complete_Date
    ) AS completion_delay_hours,

    TIMESTAMPADD(
        SECOND,
        FLOOR(
            TIMESTAMPDIFF(
                SECOND,
                s.Start_Date,
                s.End_Date
            ) * 0.20
        ),
        s.Start_Date
    ) AS prediction_time_20pct,

    COUNT(i.ID) AS issue_count,

    SUM(
        CASE
            WHEN i.Assignee_ID IS NOT NULL THEN 1
            ELSE 0
        END
    ) AS assigned_issue_count,

    ROUND(
        SUM(
            CASE
                WHEN i.Assignee_ID IS NOT NULL THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(i.ID), 0),
        6
    ) AS assigned_issue_share,

    COUNT(DISTINCT i.Assignee_ID) AS core_team_size,

    -- Любая задача с содержательно допустимой датой разрешения
    SUM(
        CASE
            WHEN i.Resolution_Date IS NOT NULL
             AND (
                    i.Creation_Date IS NULL
                    OR i.Resolution_Date >= i.Creation_Date
                 )
            THEN 1
            ELSE 0
        END
    ) AS resolved_any_count,

    ROUND(
        SUM(
            CASE
                WHEN i.Resolution_Date IS NOT NULL
                 AND (
                        i.Creation_Date IS NULL
                        OR i.Resolution_Date >= i.Creation_Date
                     )
                THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(i.ID), 0),
        6
    ) AS resolved_any_share,

    -- Разрешено не позднее плановой даты окончания
    SUM(
        CASE
            WHEN i.Resolution_Date IS NOT NULL
             AND (
                    i.Creation_Date IS NULL
                    OR i.Resolution_Date >= i.Creation_Date
                 )
             AND s.End_Date IS NOT NULL
             AND i.Resolution_Date <= s.End_Date
            THEN 1
            ELSE 0
        END
    ) AS resolved_by_end_count,

    ROUND(
        SUM(
            CASE
                WHEN i.Resolution_Date IS NOT NULL
                 AND (
                        i.Creation_Date IS NULL
                        OR i.Resolution_Date >= i.Creation_Date
                     )
                 AND s.End_Date IS NOT NULL
                 AND i.Resolution_Date <= s.End_Date
                THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(i.ID), 0),
        6
    ) AS resolved_by_end_share,

    -- Разрешено не позднее чем через 24 часа после срока
    SUM(
        CASE
            WHEN i.Resolution_Date IS NOT NULL
             AND (
                    i.Creation_Date IS NULL
                    OR i.Resolution_Date >= i.Creation_Date
                 )
             AND s.End_Date IS NOT NULL
             AND i.Resolution_Date <= DATE_ADD(
                    s.End_Date,
                    INTERVAL 24 HOUR
                 )
            THEN 1
            ELSE 0
        END
    ) AS resolved_by_end24_count,

    ROUND(
        SUM(
            CASE
                WHEN i.Resolution_Date IS NOT NULL
                 AND (
                        i.Creation_Date IS NULL
                        OR i.Resolution_Date >= i.Creation_Date
                     )
                 AND s.End_Date IS NOT NULL
                 AND i.Resolution_Date <= DATE_ADD(
                        s.End_Date,
                        INTERVAL 24 HOUR
                     )
                THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(i.ID), 0),
        6
    ) AS resolved_by_end24_share,

    -- Разрешено не позднее чем через 48 часов после срока
    SUM(
        CASE
            WHEN i.Resolution_Date IS NOT NULL
             AND (
                    i.Creation_Date IS NULL
                    OR i.Resolution_Date >= i.Creation_Date
                 )
             AND s.End_Date IS NOT NULL
             AND i.Resolution_Date <= DATE_ADD(
                    s.End_Date,
                    INTERVAL 48 HOUR
                 )
            THEN 1
            ELSE 0
        END
    ) AS resolved_by_end48_count,

    ROUND(
        SUM(
            CASE
                WHEN i.Resolution_Date IS NOT NULL
                 AND (
                        i.Creation_Date IS NULL
                        OR i.Resolution_Date >= i.Creation_Date
                     )
                 AND s.End_Date IS NOT NULL
                 AND i.Resolution_Date <= DATE_ADD(
                        s.End_Date,
                        INTERVAL 48 HOUR
                     )
                THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(i.ID), 0),
        6
    ) AS resolved_by_end48_share,

    -- Разрешение именно с итогом Complete
    SUM(
        CASE
            WHEN UPPER(TRIM(COALESCE(i.Resolution, ''))) = 'COMPLETE'
             AND i.Resolution_Date IS NOT NULL
             AND s.End_Date IS NOT NULL
             AND i.Resolution_Date <= DATE_ADD(
                    s.End_Date,
                    INTERVAL 24 HOUR
                 )
            THEN 1
            ELSE 0
        END
    ) AS complete_resolution_by_end24_count,

    ROUND(
        SUM(
            CASE
                WHEN UPPER(TRIM(COALESCE(i.Resolution, ''))) = 'COMPLETE'
                 AND i.Resolution_Date IS NOT NULL
                 AND s.End_Date IS NOT NULL
                 AND i.Resolution_Date <= DATE_ADD(
                        s.End_Date,
                        INTERVAL 24 HOUR
                     )
                THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(i.ID), 0),
        6
    ) AS complete_resolution_by_end24_share,

    -- Аномальные даты разрешения
    SUM(
        CASE
            WHEN i.Resolution_Date IS NOT NULL
             AND i.Creation_Date IS NOT NULL
             AND i.Resolution_Date < i.Creation_Date
            THEN 1
            ELSE 0
        END
    ) AS invalid_resolution_date_count,

    -- Структура задач
    SUM(
        CASE
            WHEN UPPER(TRIM(COALESCE(i.Type, ''))) = 'BUG'
            THEN 1
            ELSE 0
        END
    ) AS bug_count,

    ROUND(
        SUM(
            CASE
                WHEN UPPER(TRIM(COALESCE(i.Type, ''))) = 'BUG'
                THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(i.ID), 0),
        6
    ) AS bug_share,

    SUM(
        CASE
            WHEN UPPER(TRIM(COALESCE(i.Priority, '')))
                 IN ('BLOCKER', 'CRITICAL', 'HIGHEST')
            THEN 1
            ELSE 0
        END
    ) AS high_priority_issue_count,

    -- Story points
    SUM(
        CASE
            WHEN i.Story_Point IS NOT NULL THEN 1
            ELSE 0
        END
    ) AS story_point_present_count,

    SUM(
        CASE
            WHEN i.Story_Point IS NOT NULL
             AND i.Story_Point > 0
            THEN 1
            ELSE 0
        END
    ) AS positive_story_point_count,

    ROUND(
        SUM(
            CASE
                WHEN i.Story_Point IS NOT NULL
                 AND i.Story_Point > 0
                THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(i.ID), 0),
        6
    ) AS positive_story_point_share,

    SUM(
        CASE
            WHEN i.Story_Point IS NOT NULL
             AND i.Story_Point > 0
            THEN i.Story_Point
            ELSE 0
        END
    ) AS total_story_points,

    -- Трудоемкость
    SUM(
        CASE
            WHEN i.Total_Effort_Minutes IS NOT NULL
             AND i.Total_Effort_Minutes > 0
            THEN 1
            ELSE 0
        END
    ) AS positive_effort_issue_count,

    ROUND(
        SUM(
            CASE
                WHEN i.Total_Effort_Minutes IS NOT NULL
                 AND i.Total_Effort_Minutes > 0
                THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(i.ID), 0),
        6
    ) AS positive_effort_issue_share,

    SUM(
        CASE
            WHEN i.Total_Effort_Minutes IS NOT NULL
             AND i.Total_Effort_Minutes > 0
            THEN i.Total_Effort_Minutes
            ELSE 0
        END
    ) AS total_positive_effort_minutes,

    AVG(
        CASE
            WHEN i.Resolution_Time_Minutes IS NOT NULL
             AND i.Resolution_Time_Minutes > 0
            THEN i.Resolution_Time_Minutes
            ELSE NULL
        END
    ) AS avg_positive_resolution_time_minutes

FROM sprint s

JOIN project p
    ON p.ID = s.Project_ID

LEFT JOIN repository r
    ON r.ID = p.Repository_ID

LEFT JOIN issue i
    ON i.Sprint_ID = s.ID

GROUP BY
    s.ID,
    s.Project_ID,
    p.Project_Key,
    p.Name,
    r.Name,
    s.Name,
    s.State,
    s.Start_Date,
    s.End_Date,
    s.Activated_Date,
    s.Complete_Date;

ALTER TABLE article_sprint_base
    ADD PRIMARY KEY (Sprint_ID),
    ADD INDEX idx_article_base_project (Project_ID),
    ADD INDEX idx_article_base_start (Start_Date);

CREATE TABLE article_eligible_preproject AS
SELECT *
FROM article_sprint_base
WHERE
    UPPER(TRIM(COALESCE(sprint_state, ''))) = 'CLOSED'

    AND Start_Date IS NOT NULL
    AND End_Date IS NOT NULL
    AND Complete_Date IS NOT NULL

    AND End_Date > Start_Date
    AND Complete_Date >= Start_Date

    -- Плановая продолжительность от 3 до 45 суток
    AND planned_duration_hours BETWEEN 72 AND 1080

    -- Административное закрытие не позднее 90 суток после срока
    AND Complete_Date <= DATE_ADD(
        End_Date,
        INTERVAL 90 DAY
    )

    -- Минимальный масштаб спринта
    AND issue_count >= 10

    -- Команда от 3 до 25 исполнителей
    AND core_team_size BETWEEN 3 AND 25

    -- Исполнитель указан минимум у 70% задач
    AND assigned_issue_share >= 0.70;

ALTER TABLE article_eligible_preproject
    ADD PRIMARY KEY (Sprint_ID),
    ADD INDEX idx_article_eligible_project (Project_ID),
    ADD INDEX idx_article_eligible_start (Start_Date);

CREATE TABLE article_project_counts AS
SELECT
    Project_ID,
    COUNT(*) AS eligible_sprint_count
FROM article_eligible_preproject
GROUP BY Project_ID;

ALTER TABLE article_project_counts
    ADD PRIMARY KEY (Project_ID);

CREATE TABLE article_ranked_candidates AS
SELECT
    e.*,
    pc.eligible_sprint_count,

    ROW_NUMBER() OVER (
        PARTITION BY e.Project_ID
        ORDER BY
            e.Start_Date,
            e.Sprint_ID
    ) AS eligible_sprint_order

FROM article_eligible_preproject e

JOIN article_project_counts pc
    ON pc.Project_ID = e.Project_ID
   AND pc.eligible_sprint_count >= 20;

ALTER TABLE article_ranked_candidates
    ADD PRIMARY KEY (Sprint_ID),
    ADD INDEX idx_article_ranked_project (Project_ID),
    ADD INDEX idx_article_ranked_order (
        Project_ID,
        eligible_sprint_order
    );

CREATE TABLE article_sprint_team_members AS
SELECT DISTINCT
    i.Project_ID,
    i.Sprint_ID,
    i.Assignee_ID
FROM issue i
WHERE
    i.Sprint_ID IS NOT NULL
    AND i.Assignee_ID IS NOT NULL;

ALTER TABLE article_sprint_team_members
    ADD PRIMARY KEY (Sprint_ID, Assignee_ID),
    ADD INDEX idx_article_team_project (Project_ID),
    ADD INDEX idx_article_team_assignee (Assignee_ID);

CREATE TABLE article_assigned_issue_history AS
SELECT
    i.ID AS Issue_ID,
    i.Project_ID,
    i.Sprint_ID,
    i.Assignee_ID,
    i.Creation_Date
FROM issue i
WHERE
    i.Assignee_ID IS NOT NULL
    AND i.Project_ID IS NOT NULL
    AND i.Creation_Date IS NOT NULL;

ALTER TABLE article_assigned_issue_history
    ADD PRIMARY KEY (Issue_ID),
    ADD INDEX idx_article_history_lookup (
        Project_ID,
        Assignee_ID,
        Creation_Date
    ),
    ADD INDEX idx_article_history_sprint (Sprint_ID);

CREATE TABLE article_team_member_history AS
SELECT
    c.Project_ID,
    c.Sprint_ID,
    tm.Assignee_ID,

    COUNT(h.Issue_ID) AS prior_task_count

FROM article_ranked_candidates c

JOIN article_sprint_team_members tm
    ON tm.Project_ID = c.Project_ID
   AND tm.Sprint_ID = c.Sprint_ID

LEFT JOIN article_assigned_issue_history h
    ON h.Project_ID = c.Project_ID
   AND h.Assignee_ID = tm.Assignee_ID
   AND h.Creation_Date < c.Start_Date
   AND (
        h.Sprint_ID IS NULL
        OR h.Sprint_ID <> c.Sprint_ID
   )

WHERE
    c.eligible_sprint_order > 5

GROUP BY
    c.Project_ID,
    c.Sprint_ID,
    tm.Assignee_ID;

ALTER TABLE article_team_member_history
    ADD PRIMARY KEY (Sprint_ID, Assignee_ID),
    ADD INDEX idx_article_member_history_project (Project_ID);

CREATE TABLE article_history_coverage AS
SELECT
    Project_ID,
    Sprint_ID,

    COUNT(*) AS team_member_count,

    SUM(
        CASE
            WHEN prior_task_count >= 5 THEN 1
            ELSE 0
        END
    ) AS experienced_member_count,

    ROUND(
        SUM(
            CASE
                WHEN prior_task_count >= 5 THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(*), 0),
        6
    ) AS experienced_member_share,

    AVG(prior_task_count) AS avg_prior_task_count,

    MIN(prior_task_count) AS min_prior_task_count,

    MAX(prior_task_count) AS max_prior_task_count

FROM article_team_member_history

GROUP BY
    Project_ID,
    Sprint_ID;

ALTER TABLE article_history_coverage
    ADD PRIMARY KEY (Sprint_ID),
    ADD INDEX idx_article_coverage_project (Project_ID);

CREATE TABLE article_final_cohort AS
SELECT
    c.*,

    hc.team_member_count,
    hc.experienced_member_count,
    hc.experienced_member_share,
    hc.avg_prior_task_count,
    hc.min_prior_task_count,
    hc.max_prior_task_count,

    -- Основной outcome:
    -- минимум 90% задач разрешены не позднее 24 часов после срока
    CASE
        WHEN c.resolved_by_end24_share >= 0.90 THEN 1
        ELSE 0
    END AS success_90_end24,

    -- Альтернативные определения для robustness analysis
    CASE
        WHEN c.resolved_by_end_share >= 0.80 THEN 1
        ELSE 0
    END AS success_80_end0,

    CASE
        WHEN c.resolved_by_end24_share >= 0.80 THEN 1
        ELSE 0
    END AS success_80_end24,

    CASE
        WHEN c.resolved_by_end24_share >= 0.95 THEN 1
        ELSE 0
    END AS success_95_end24,

    CASE
        WHEN c.resolved_by_end48_share >= 0.90 THEN 1
        ELSE 0
    END AS success_90_end48,

    -- Принадлежность к дополнительным подвыборкам
    CASE
        WHEN c.positive_effort_issue_share >= 0.50 THEN 1
        ELSE 0
    END AS effort_subset,

    CASE
        WHEN c.positive_story_point_share >= 0.50 THEN 1
        ELSE 0
    END AS story_point_subset

FROM article_ranked_candidates c

JOIN article_history_coverage hc
    ON hc.Project_ID = c.Project_ID
   AND hc.Sprint_ID = c.Sprint_ID

WHERE
    c.eligible_sprint_order > 5
    AND hc.experienced_member_share >= 0.70;

ALTER TABLE article_final_cohort
    ADD PRIMARY KEY (Sprint_ID),
    ADD INDEX idx_article_final_project (Project_ID),
    ADD INDEX idx_article_final_start (Start_Date),
    ADD INDEX idx_article_final_outcome (success_90_end24);
