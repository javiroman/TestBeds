\echo "List of cars with theirs repairs"

\c carrepairs;

SELECT carID, 
       repairs.* 
FROM workrepair 
LEFT JOIN repairs ON workRepair.repairID = repairs.repairID;



