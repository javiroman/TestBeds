#!/bin/bash
# sh install-antelope.sh get builder kudu
# sh install-antelope.sh get builder hive
# sh install-antelope.sh get builder hadoop
# sh install-antelope.sh get builder impala

# sh install-antelope.sh master kudu
# sh install-antelope.sh worker kudu
#
# sh install-antelope.sh master hms
#
# sh install-antelope.sh master impala
# sh install-antelope.sh worker impala

message()
{
    [[ "$1" == "OK" ]] && echo "OK" && return
    echo -ne "[antelope-install] $1 ... "
}

install_bootstrap()
{
    [[ $(which sshpass 2> /dev/null) ]] && return 
    message "Installing sshpass"
    sudo yum install sshpass -y &> /dev/null
    message "OK"
}

get_help()
{
   # Display Help
   echo "Syntax: antilope-install.sh [get|master|worker|help]"
   echo 
   echo "options:"
   echo "help                                   Print this Help."
   echo "get builder-ip [hive|impala|kudu|hadoop] Get from builder ip the tar.gz package."
   echo "master [metastore|impala|kudu]         Install master daemon of selected technology."
   echo "worker [impala|kudu]                   Install worker daemon of selected technology."
   echo
   exit 
}

install_kudu()
{
   message "Create kudu user"
   [[ ! $(id kudu 2> /dev/null) ]] && sudo adduser -r kudu
   message "OK"

   message "Create kudu folders"
   for i in lib/kudu/${1}/wal lib/kudu/${1}/data log/kudu; do
       [[ ! -d /var/$i ]] && sudo mkdir -p /var/$i
   done
   sudo chown -R kudu: /var/lib/kudu
   sudo chown -R kudu: /var/log/kudu
   message "OK"

   message "Installing kudu dependencies"
   sudo yum install -y \
    tree \
    vim \
    cyrus-sasl-gssapi \
    cyrus-sasl-plain \
    cyrus-sasl-devel \
    krb5-server \
    krb5-workstation \
    openssl \
    lzo-devel \
    tzdata &> /dev/null
   message "OK"

   message "Unpacking kudu"
   sudo tar xzf antelope-kudu.tar.gz -P -C /opt
   sudo chown -R kudu: /opt/antelope/kudu
   message "OK"

   if [ $1 == "master" ]; then
       message "Master daemon"
       sudo ln -fs /opt/antelope/kudu/systemd/kudu-master.service /etc/systemd/system/
       sudo systemctl start kudu-master
       sudo systemctl enable kudu-master
   else
       message "TServer daemon"
       sudo ln -fs /opt/antelope/kudu/systemd/kudu-tserver.service /etc/systemd/system/
       sudo systemctl start kudu-tserver
       sudo systemctl enable kudu-tserver
   fi
   message "OK"
}

install_impala()
{
   #
   # Recuerda que falta:
   # sudo tar xvzf antelope-hadoop.tar.gz -P -C /
   # sudo tar xzf antelope-hive.tar.gz -P -C /
   # 

   sudo yum install -y java-1.8.0-openjdk-devel &> /dev/null
   sudo adduser -r impala
   sudo mkdir /var/log/impala
   sudo chown -R impala: /var/log/impala

   message "Unpacking impala"
   sudo tar xzf antelope-impala.tar.gz -P -C /
   sudo chown -R impala: /opt/antelope/impala/
   message "OK"
   
   sudo tee /etc/ld.so.conf.d/impala.conf <<!
/opt/antelope/impala/lib64/
!
   sudo ldconfig
  
   if [ $1 == "master" ]; then
       message "Impala masters daemons"
       sudo ln -fs /opt/antelope/impala/systemd/impala-catalog.service /etc/systemd/system/
       sudo ln -fs /opt/antelope/impala/systemd/impala-admission.service /etc/systemd/system/
       sudo ln -fs /opt/antelope/impala/systemd/impala-statestore.service /etc/systemd/system/
       sudo systemctl start impala-catalog
       sudo systemctl start impala-admission
       sudo systemctl start impala-statestore
       sudo systemctl enable impala-catalog
       sudo systemctl enable impala-admission
       sudo systemctl enable impala-statestore
   else
       message "Impala Worker daemon"
       sudo ln -fs /opt/antelope/impala/systemd/impala.service /etc/systemd/system/
       sudo systemctl start impala
       sudo systemctl enable impala
   fi
   message "OK"
}

install_hms()
{
   message "HMS PostgreSQL RPMs installation"
   sudo yum install -y \
        java-1.8.0-openjdk-devel \
    postgresql \
    postgresql-server \
    postgresql-contrib \
    postgresql-jdbc &> /dev/null
   message "OK"

   message "HMS PostgreSQL Initialization"
   sudo postgresql-setup initdb
   sudo sed -i "s/\#listen_addresses =.*/listen_addresses = \'*\'/g" /var/lib/pgsql/data/postgresql.conf
   [[ ! $(sudo grep 'host  all  all 0.0.0.0/0 md5' /var/lib/pgsql/data/pg_hba.conf) ]] && \
    echo 'host  all  all 0.0.0.0/0 md5' | sudo tee -a /var/lib/pgsql/data/pg_hba.conf   
   sudo systemctl restart postgresql
   sudo systemctl enable postgresql
   message "OK"

   message "HMS PostgreSQL postgres admin user password"
   sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';" 2> /dev/null
   message "OK"

   message "HMS PostgreSQL metastore database creation"
   sudo -u postgres psql -c "CREATE DATABASE metastore;" 2> /dev/null
   message "OK"

   # for connecting remotely: 
   #    psql -h masters.antelope.lan -U postgres (password prompt: postgres)
   #    psql postgresql://postgres:postgres@masters.antelope.lan (without password prompt)
 
   # check everything is ok
   [[ ! $(psql postgresql://postgres:postgres@masters.antelope.lan -c '\l' | grep metastore) ]] && \
    echo "ERROR: No metastore created. Aborting." && \
    exit 1

  # sudo adduser -r hive 
  # - Get Hive from builder VM:
  # sudo chown -R hive: /opt/antelope/hive/
  # sudo ln -s /usr/share/java/postgresql-jdbc.jar /opt/antelope/hive/lib/
  # Setup Hive:
  # sudo -E -u hive vim /opt/antelope/hive/conf/hive-site.xml
  # - Get Hadoop from internet:
  # curl -LO https://ftp.cixug.es/apache/hadoop/common/hadoop-3.3.1/hadoop-3.3.1.tar.gz
  # sudo chown -R hive: /opt/antelope/hadoop/
  # sudo rm /opt/antelope/hive/lib/guava-19.0.jar
  # sudo -E -u hive cp /opt/antelope/hadoop/share/hadoop/hdfs/lib/guava-27.0-jre.jar /opt/antelope/hive/lib/
  #
  # export JAVA_HOME=/usr/lib/jvm/java/
  # export HADOOP_HOME=/opt/antelope/hadoop/
  # /opt/antelope/hive/bin/schematool -initSchema -dbType postgres
  #
  # - Fake hadoop files:
  # sudo -E -u hive vim /opt/antelope/hadoop/etc/hadoop/core-site.xml
  # sudo -E -u hive vim /opt/antelope/hadoop/etc/hadoop/hdfs-site.xml
  #
  # - No podemos levantar Hive Metastore (HMS) sin copiar el jar de Kudu:
  #   kudu/build/release/bin/hms-plugin.jar -> /opt/antelope/hive/lib
  #
  # scp builder.antelope.lan:build/kudu/build/release/bin/hms-plugin.jar . (debe de ir en el tar.gz de KUDU) TODO
  # sudo cp hms-plugin.jar /opt/antelope/hive/lib/
  # sudo chown hive: /opt/antelope/hive/lib/hms-plugin.jar 
  # cat run-metastore.sh 
  #    export JAVA_HOME=/usr/lib/jvm/java/
  #    export HADOOP_HOME=/opt/antelope/hadoop
  #    setsid /opt/antelope/hive/bin/hive --service metastore --hiveconf hive.root.logger=DEBUG,console &> /tmp/metastore.log &

}

install_master()
{
    case $1 in
    "kudu")
        install_kudu master
        ;;
    "impala")
         install_impala master
        ;;
    "hms")
         install_hms 
        ;;
    *)
        echo "ERROR: kudu or impala only"
        ;;
    esac
}

install_worker()
{
    case $1 in
    "kudu")
        install_kudu tserver
        ;;
    "impala")
        install_impala worker
        ;;
    *)
        echo "ERROR: kudu or impala only"
        ;;
    esac
}


install_bootstrap

case $1 in
"help")
    help
    ;;
"get")
    [[ -z $2 ]] && echo "Error: no builder IP provided" && get_help
    [[ -z $3 ]] && echo "Error: no technology provided" && get_help
    message "Getting $2 from $3"
        [[ ! -e antelope-$3.tar.gz ]] && sshpass -p adm scp \
        -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
                vagrant@${2}:build/antelope-$3.tar.gz .
    message "OK"
    ;; 
"master")
    [[ -z $2 ]] && echo "Error: no technology provided" && get_help 
    install_master $2
    ;;
"worker")
    [[ -z $2 ]] && echo "Error: no technology provided" && get_help
    install_worker $2
    ;;
*)
    get_help
    ;;
esac

# Notes: systemctl list-unit-files --state=enabled | grep -E 'impala|metastore|kudu'
