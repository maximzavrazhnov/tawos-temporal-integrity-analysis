SELECT
    ID,
    Issue_Key,
    Type,
    Priority,
    Status,
    Resolution,

    Creation_Date,
    Estimation_Date,
    Resolution_Date,
    Last_Updated,

    Story_Point,
    Timespent,
    In_Progress_Minutes,
    Total_Effort_Minutes,
    Resolution_Time_Minutes,

    Creator_ID,
    Reporter_ID,
    Assignee_ID,
    Project_ID,
    Sprint_ID

FROM Issue
ORDER BY ID
LIMIT 500;
