SELECT
    COUNT(*) AS sprints_total,

    SUM(Project_ID IS NOT NULL)
        AS project_id_present,

    SUM(Start_Date IS NOT NULL)
        AS start_date_present,

    SUM(End_Date IS NOT NULL)
        AS end_date_present,

    SUM(Activated_Date IS NOT NULL)
        AS activated_date_present,

    SUM(Complete_Date IS NOT NULL)
        AS complete_date_present,

    COUNT(DISTINCT Project_ID)
        AS projects_with_sprints
FROM Sprint;
