SELECT
    COUNT(*) AS issues_total,

    ROUND(100 * AVG(Project_ID IS NOT NULL), 2)
        AS project_id_percent,

    ROUND(100 * AVG(Sprint_ID IS NOT NULL), 2)
        AS sprint_id_percent,

    ROUND(100 * AVG(Assignee_ID IS NOT NULL), 2)
        AS assignee_percent,

    ROUND(100 * AVG(Resolution_Date IS NOT NULL), 2)
        AS resolution_date_percent,

    ROUND(100 * AVG(Story_Point IS NOT NULL), 2)
        AS story_point_percent,

    ROUND(100 * AVG(Timespent IS NOT NULL), 2)
        AS timespent_percent,

    ROUND(100 * AVG(Total_Effort_Minutes IS NOT NULL), 2)
        AS total_effort_percent,

    ROUND(100 * AVG(Resolution_Time_Minutes IS NOT NULL), 2)
        AS resolution_time_percent
FROM Issue;
