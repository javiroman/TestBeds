source ./hive.env
nohup $HIVE_HOME/bin/hive --service hiveserver2 --hiveconf hive.root.logger=DEBUG,console &> hiveserver2.log &
