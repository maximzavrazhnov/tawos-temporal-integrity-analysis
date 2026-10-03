SELECT
    p.ID AS project_id,
    p.Project_Key,
    p.Name AS project_name,
    r.Name AS repository_name,
    p.Start_Date,
    p.Last_Update_Date
FROM Project p
LEFT JOIN Repository r
    ON r.ID = p.Repository_ID
ORDER BY p.ID;
