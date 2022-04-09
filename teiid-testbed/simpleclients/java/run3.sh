# query -> List the car models with their reparations

SQL=$(cat <<EOF

SELECT models.model,repairs.repairID FROM models, repairs
	ORDER BY models.model;

EOF
)

run=$(echo mvn -q install \
	-Dvdb="CarSalesRepairsDatabase" \
	-Dsql=\"$SQL\" \
	-Dusername=\"user\" \
	-Dpassword=\"@123user\")

eval $run
