source ./hive.env
nohup $HIVE_HOME/bin/hive --service metastore --hiveconf hive.root.logger=DEBUG,console &> metastore.log &
