USE TAWOS;

WITH funnel AS (

    SELECT
        1 AS stage_order,
        'All sprints' AS stage_name,
        COUNT(*) AS sprint_count,
        COUNT(DISTINCT Project_ID) AS project_count
    FROM article_sprint_base

    UNION ALL

    SELECT
        2,
        'Closed sprints',
        COUNT(*),
        COUNT(DISTINCT Project_ID)
    FROM article_sprint_base
    WHERE UPPER(TRIM(COALESCE(sprint_state, ''))) = 'CLOSED'

    UNION ALL

    SELECT
        3,
        'Closed sprints with Start, End and Complete dates',
        COUNT(*),
        COUNT(DISTINCT Project_ID)
    FROM article_sprint_base
    WHERE
        UPPER(TRIM(COALESCE(sprint_state, ''))) = 'CLOSED'
        AND Start_Date IS NOT NULL
        AND End_Date IS NOT NULL
        AND Complete_Date IS NOT NULL

    UNION ALL

    SELECT
        4,
        'Valid date chronology',
        COUNT(*),
        COUNT(DISTINCT Project_ID)
    FROM article_sprint_base
    WHERE
        UPPER(TRIM(COALESCE(sprint_state, ''))) = 'CLOSED'
        AND Start_Date IS NOT NULL
        AND End_Date IS NOT NULL
        AND Complete_Date IS NOT NULL
        AND End_Date > Start_Date
        AND Complete_Date >= Start_Date

    UNION ALL

    SELECT
        5,
        'Planned duration from 3 to 45 days',
        COUNT(*),
        COUNT(DISTINCT Project_ID)
    FROM article_sprint_base
    WHERE
        UPPER(TRIM(COALESCE(sprint_state, ''))) = 'CLOSED'
        AND Start_Date IS NOT NULL
        AND End_Date IS NOT NULL
        AND Complete_Date IS NOT NULL
        AND End_Date > Start_Date
        AND Complete_Date >= Start_Date
        AND planned_duration_hours BETWEEN 72 AND 1080

    UNION ALL

    SELECT
        6,
        'Completed no later than 90 days after planned end',
        COUNT(*),
        COUNT(DISTINCT Project_ID)
    FROM article_sprint_base
    WHERE
        UPPER(TRIM(COALESCE(sprint_state, ''))) = 'CLOSED'
        AND Start_Date IS NOT NULL
        AND End_Date IS NOT NULL
        AND Complete_Date IS NOT NULL
        AND End_Date > Start_Date
        AND Complete_Date >= Start_Date
        AND planned_duration_hours BETWEEN 72 AND 1080
        AND Complete_Date <= DATE_ADD(
            End_Date,
            INTERVAL 90 DAY
        )

    UNION ALL

    SELECT
        7,
        'At least 10 issues',
        COUNT(*),
        COUNT(DISTINCT Project_ID)
    FROM article_sprint_base
    WHERE
        UPPER(TRIM(COALESCE(sprint_state, ''))) = 'CLOSED'
        AND Start_Date IS NOT NULL
        AND End_Date IS NOT NULL
        AND Complete_Date IS NOT NULL
        AND End_Date > Start_Date
        AND Complete_Date >= Start_Date
        AND planned_duration_hours BETWEEN 72 AND 1080
        AND Complete_Date <= DATE_ADD(
            End_Date,
            INTERVAL 90 DAY
        )
        AND issue_count >= 10

    UNION ALL

    SELECT
        8,
        'Team size from 3 to 25 members',
        COUNT(*),
        COUNT(DISTINCT Project_ID)
    FROM article_sprint_base
    WHERE
        UPPER(TRIM(COALESCE(sprint_state, ''))) = 'CLOSED'
        AND Start_Date IS NOT NULL
        AND End_Date IS NOT NULL
        AND Complete_Date IS NOT NULL
        AND End_Date > Start_Date
        AND Complete_Date >= Start_Date
        AND planned_duration_hours BETWEEN 72 AND 1080
        AND Complete_Date <= DATE_ADD(
            End_Date,
            INTERVAL 90 DAY
        )
        AND issue_count >= 10
        AND core_team_size BETWEEN 3 AND 25

    UNION ALL

    SELECT
        9,
        'At least 70 percent of issues assigned',
        COUNT(*),
        COUNT(DISTINCT Project_ID)
    FROM article_eligible_preproject

    UNION ALL

    SELECT
        10,
        'Projects with at least 20 eligible sprints',
        COUNT(*),
        COUNT(DISTINCT Project_ID)
    FROM article_ranked_candidates

    UNION ALL

    SELECT
        11,
        'After excluding first five sprints per project',
        COUNT(*),
        COUNT(DISTINCT Project_ID)
    FROM article_ranked_candidates
    WHERE eligible_sprint_order > 5

    UNION ALL

    SELECT
        12,
        'At least 70 percent experienced team members',
        COUNT(*),
        COUNT(DISTINCT Project_ID)
    FROM article_final_cohort
)

SELECT
    stage_order,
    stage_name,
    sprint_count,
    project_count,

    sprint_count
    -
    LAG(sprint_count) OVER (
        ORDER BY stage_order
    ) AS change_from_previous_stage,

    ROUND(
        100 * sprint_count
        / FIRST_VALUE(sprint_count) OVER (
            ORDER BY stage_order
        ),
        2
    ) AS retained_from_initial_percent

FROM funnel

ORDER BY stage_order;
