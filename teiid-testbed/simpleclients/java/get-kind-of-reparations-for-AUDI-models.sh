# query -> List the car models with their reparations

SQL=$(cat <<EOF

SELECT DISTINCT m.model, r.repairID, r.repairDesc
	FROM MODELS m, shopModels sm, CARSHOP c, 
	     WORKS w, workRepair wr, REPAIRS r
	WHERE     m.modID=sm.modID 
	AND       sm.carID=c.carID
	AND       c.carID=w.carID
	AND       w.carID=wr.carID
	AND       wr.repairID=r.repairID
	AND       m.model = 'AUDI'; 

EOF
)

run=$(echo mvn -q install \
	-Dvdb="CarSalesRepairsDatabase" \
	-Dsql=\"$SQL\" \
	-Dusername=\"user\" \
	-Dpassword=\"@123user\")

eval $run
