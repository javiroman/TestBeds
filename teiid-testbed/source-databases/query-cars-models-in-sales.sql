system echo "List of model information on each car in sales shop"
system echo "---------------------------------------------------"

USE carsales;

SELECT carID, 
       models.* 
FROM shopModels 
LEFT JOIN models ON models.modID = shopModels.modID;


