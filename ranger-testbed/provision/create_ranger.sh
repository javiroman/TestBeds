#!/bin/bash
installpath=/usr/lib/ranger

s3bucket_http_url=https://s3.amazonaws.com/aws-bigdata-blog/artifacts/aws-blog-emr-ranger

ranger_download_version=2.1.0-SNAPSHOT
ranger_s3bucket=$s3bucket_http_url/ranger/ranger-$ranger_download_version
ranger_admin_server=ranger-$ranger_download_version-admin
ranger_user_sync=ranger-$ranger_download_version-usersync

mysql_jar_location=$s3bucket_http_url/ranger/ranger-$ranger_download_version/mysql-connector-java-5.1.39.jar
mysql_jar=mysql-connector-java-5.1.39.jar

#Install mySQL 5.6
sudo yum install wget -y
sudo yum install lsof -y

wget http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
sudo rpm -ivh mysql-community-release-el7-5.noarch.rpm
sudo yum install mysql-server -y
sudo systemctl start mysqld
sudo chkconfig mysqld on
mysqladmin -u root password rangeradmin || true
mysql -u root -prangeradmin -e "CREATE USER 'rangeradmin'@'localhost' IDENTIFIED BY 'rangeradmin';" || true
mysql -u root -prangeradmin -e "create database ranger;" || true
mysql -u root -prangeradmin -e "GRANT ALL PRIVILEGES ON *.* TO 'rangeradmin'@'localhost' IDENTIFIED BY 'rangeradmin'" || true
mysql -u root -prangeradmin -e "FLUSH PRIVILEGES;" || true


# Install apache ranger
sudo rm -rf $installpath
sudo mkdir -p $installpath/hadoop
cd $installpath
sudo wget $ranger_s3bucket/$ranger_admin_server.tar.gz
sudo wget $ranger_s3bucket/$ranger_user_sync.tar.gz
sudo wget $mysql_jar_location
sudo wget $ranger_s3bucket/solr_for_audit_setup.tar.gz


#Update ranger admin install.properties
sudo tar -xvf $ranger_admin_server.tar.gz
cd $ranger_admin_server
sudo sed -i "s|SQL_CONNECTOR_JAR=.*|SQL_CONNECTOR_JAR=$installpath/$mysql_jar|g" install.properties
sudo sed -i "s|db_root_password=.*|db_root_password=rangeradmin|g" install.properties
sudo sed -i "s|db_password=.*|db_password=rangeradmin|g" install.properties
sudo sed -i "s|audit_db_password=.*|audit_db_password=rangerlogger|g" install.properties
sudo sed -i "s|audit_store=.*|audit_store=solr|g" install.properties
sudo sed -i "s|audit_solr_urls=.*|audit_solr_urls=http://localhost:8983/solr/ranger_audits|g" install.properties
sudo sed -i "s|policymgr_external_url=.*|policymgr_external_url=http://$hostname:6080|g" install.properties
sudo chmod +x setup.sh
sudo -E ./setup.sh


#Download the install solr for ranger
cd $installpath
sudo tar -xvf solr_for_audit_setup.tar.gz
cd solr_for_audit_setup
sudo sed -i "s|SOLR_HOST_URL=.*|SOLR_HOST_URL=http://$hostname:8983|g" install.properties
sudo sed -i "s|SOLR_RANGER_PORT=.*|SOLR_RANGER_PORT=8983|g" install.properties
sudo chmod +x setup.sh
sudo -E ./setup.sh
sudo /opt/solr/ranger_audit_server/scripts/start_solr.sh || true
sudo /usr/bin/ranger-admin start

i=0;
while ! timeout 1 bash -c "echo > /dev/tcp/$hostname/6080"; do
        sleep 10;
        i=$((i + 1))
        if (( i > 6 )); then
                break;
        fi
done
