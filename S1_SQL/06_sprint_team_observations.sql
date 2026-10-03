SELECT
    i.Project_ID,
    p.Project_Key,

    i.Sprint_ID,
    s.Name AS sprint_name,
    s.State AS sprint_state,

    s.Start_Date,
    s.End_Date,
    s.Activated_Date,
    s.Complete_Date,

    TIMESTAMPDIFF(
        HOUR,
        s.End_Date,
        s.Complete_Date
    ) AS completion_delay_hours,

    COUNT(*) AS issue_count,

    COUNT(DISTINCT i.Assignee_ID)
        AS core_team_size,

    SUM(i.Assignee_ID IS NOT NULL)
        AS assigned_issue_count,

    SUM(i.Resolution IS NOT NULL)
        AS resolved_issue_count,

    ROUND(
        AVG(i.Resolution IS NOT NULL),
        4
    ) AS resolved_issue_share,

    SUM(
        CASE
            WHEN i.Story_Point IS NOT NULL
            THEN i.Story_Point
            ELSE 0
        END
    ) AS total_story_points,

    SUM(
        CASE
            WHEN i.Total_Effort_Minutes IS NOT NULL
            THEN i.Total_Effort_Minutes
            ELSE 0
        END
    ) AS total_effort_minutes,

    AVG(i.Resolution_Time_Minutes)
        AS avg_resolution_time_minutes,

    SUM(i.Type = 'Bug')
        AS bug_count

FROM Issue i

JOIN Project p
    ON p.ID = i.Project_ID

JOIN Sprint s
    ON s.ID = i.Sprint_ID

WHERE
    i.Assignee_ID IS NOT NULL

GROUP BY
    i.Project_ID,
    p.Project_Key,
    i.Sprint_ID,
    s.Name,
    s.State,
    s.Start_Date,
    s.End_Date,
    s.Activated_Date,
    s.Complete_Date

HAVING
    issue_count >= 5
    AND core_team_size >= 2

ORDER BY
    issue_count DESC

LIMIT 5000;
