# query -> List the car models with their reparations

SQL=$(cat <<EOF

SELECT models.modID,repairs.repairID FROM models, repairs
	ORDER BY models.modID;

EOF
)

run=$(echo mvn -q install \
	-Dvdb="CarSalesRepairsDatabase" \
	-Dsql=\"$SQL\" \
	-Dusername=\"user\" \
	-Dpassword=\"@123user\")

eval $run
