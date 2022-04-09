mvn -q install -Dvdb="myVDB" -Dsql="select * from carshop" -Dusername="user" -Dpassword="@123user"

#
# Testing Dynamic VDB
#

# Testing simple model of carsales MySQL database
# mvn install -Dvdb="CarSalesDatabase" -Dsql="select * from carshop" -Dusername="user" -Dpassword="@123user"

# Testing simple model of carsales database with a more complex SQL (join):
# query -> List the car model information on each car in sales shop
# mvn -q install -Dvdb="CarSalesDatabase" -Dsql="SELECT carID,models.* FROM shopModels LEFT JOIN models ON models.modID = shopModels.modID;" -Dusername="user" -Dpassword="@123user"

# Testing simple model of carreparis PostgreSQL database
# mvn -q install -Dvdb="CarSalesRepairsDatabase" -Dsql="select * from works" -Dusername="user" -Dpassword="@123user"

# Testing a virtual table "carshopworks"
# mvn -q install -Dvdb="CarSalesRepairsDatabase" -Dsql="select * from carshopworks" -Dusername="user" -Dpassword="@123user"
