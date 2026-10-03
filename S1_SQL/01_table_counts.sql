USE TAWOS;

SELECT 'Repository' AS table_name, COUNT(*) AS row_count FROM Repository
UNION ALL
SELECT 'Project', COUNT(*) FROM Project
UNION ALL
SELECT 'User', COUNT(*) FROM `User`
UNION ALL
SELECT 'Sprint', COUNT(*) FROM Sprint
UNION ALL
SELECT 'Issue', COUNT(*) FROM Issue
UNION ALL
SELECT 'Comment', COUNT(*) FROM Comment
UNION ALL
SELECT 'Change_Log', COUNT(*) FROM Change_Log
UNION ALL
SELECT 'Issue_Link', COUNT(*) FROM Issue_Link
UNION ALL
SELECT 'Version', COUNT(*) FROM `Version`
UNION ALL
SELECT 'Component', COUNT(*) FROM Component;
