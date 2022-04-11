setup_env() {
    export DOMAIN=ranger.lan
    export IP_DNS="10.100.0.2"

    export HADOOP_VER=3.2.1
    export HADOOP=hadoop-${HADOOP_VER}.tar.gz

    export HIVE_VER=3.1.2
    export HIVE=apache-hive-${HIVE_VER}-bin.tar.gz

    export SPARK_VER=2.3.0
    export SPARK=spark-${SPARK_VER}-bin-hadoop2.7.tgz

    export TEZ_VER=0.9.2
    export TEZ=apache-tez-${TEZ_VER}-bin.tar.gz

    # Source Rease, no binary available
    # export RANGER_VER=2.2.0
    # export RANGER=apache-ranger-${RANGER_VER}.tar.gz

    export SOLR_VER=8.11.1
    export SOLR=solr-${SOLR_VER}.tar.gz

    export DOWNLOAD_URL=https://archive.apache.org/dist/
}

kernel_tunning() {
    setup_env

    echo "kernel tunning"

    # disable SELinux
    sudo setenforce 0
    sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

    # Disable swap
    sudo swapoff -a
    sudo sed -i '/swap/s/^/#/' /etc/fstab

    # Setup fqdn hostname and remove localhost to hostname
    echo $(hostname).$DOMAIN | sudo tee /etc/hostname
    sudo sed -i '$d' /etc/hosts
    sudo systemctl restart systemd-hostnamed
}

bootstrap_nfs() {
    sudo yum install rpcbind nfs-server nfs-lock nfs-idmap vim -y --quiet 
    sudo mkdir -p /opt/shared/ && sudo chown -R vagrant: /opt/shared/
    echo '/opt/shared *(rw,sync,no_root_squash)' | sudo tee /etc/exports
    sudo systemctl start nfs-server
    sudo systemctl enable nfs-server
}

bootstrap_dns() {
    setup_env

    sudo yum install bind -y --quiet 2> /dev/null

    DNS=ranger-dns
    RANGER=ranger
    NN=ranger-nn
    DN1=ranger-dn1
    DN2=ranger-dn2
    DN3=ranger-dn3
    HIVE=ranger-hive

    HOST_DNS="$DNS.$DOMAIN"
    HOST_RANGER="$RANGER.$DOMAIN"
    HOST_NN="$NN.$DOMAIN"
    HOST_DN1="$DN1.$DOMAIN"
    HOST_DN2="$DN2.$DOMAIN"
    HOST_DN3="$DN3.$DOMAIN"
    HOST_HIVE="$HIVE.$DOMAIN"

    # 10.100.0.0/24 10.100.0.255
    IP_DNS="10.100.0.2"
    IP_DNS_INV="2"

    IP_RANGER="10.100.0.3"
    IP_RANGER_INV="3"

    IP_NN="10.100.0.4"
    IP_NN_INV="4"

    IP_DN1="10.100.0.5"
    IP_DN1_INV="5"

    IP_DN2="10.100.0.6"
    IP_DN2_INV="6"

    IP_DN3="10.100.0.7"
    IP_DN3_INV="7"

    IP_HIVE="10.100.0.8"
    IP_HIVE_INV="8"

    IP_INV="0.100.10"
    IP_REV="10.100.0"

    sudo mkdir -p /etc/named/zones
    sudo mkdir -p /etc/dhcp

sudo tee /etc/named.conf <<! 
options {
    listen-on port 53 { any; };
    directory   "/var/named";
    dump-file   "/var/named/data/cache_dump.db";
    statistics-file "/var/named/data/named_stats.txt";
    memstatistics-file "/var/named/data/named_mem_stats.txt";
    allow-query     { any; };
    querylog yes;
    recursion yes;
    dnssec-enable yes;
    dnssec-validation yes;

    /* Path to ISC DLV key */
    bindkeys-file "/etc/named.iscdlv.key";

    managed-keys-directory "/var/named/dynamic";

    pid-file "/run/named/named.pid";
    session-keyfile "/run/named/session.key";
};

logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
        };
};

zone "." IN {
    type hint;
    file "named.ca";
};

include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";

/* 
 * custom
 */
include "/etc/named/named.conf.local";
!

sudo tee /etc/named/named.conf.local <<! 
zone "${DOMAIN}" IN {
    type master;
    file "/etc/named/zones/db.${DOMAIN}"; 
};

zone "${IP_INV}.in-addr.arpa" IN {
    type master;
    file "/etc/named/zones/db.${IP_REV}"; 
};
!

sudo tee /etc/named/zones/db.${DOMAIN} <<!
\$TTL    604800
@       IN      SOA     ${HOST_DNS}. admin.${DOMAIN}. (
             3          ; Serial
             604800     ; Refresh
              86400     ; Retry
            2419200     ; Expire
             604800 )   ; Negative Cache TTL

; name servers - NS records
    IN      NS      ${HOST_DNS}.

; name servers - A records
${HOST_DNS}.   IN      A       ${IP_DNS}

; 10.0.0.0/24 - A records
${HOST_RANGER}.  IN A ${IP_RANGER}
${HOST_NN}.  IN A ${IP_NN}
${HOST_DN1}.  IN A ${IP_DN1}
${HOST_DN2}.  IN A ${IP_DN2}
${HOST_DN3}.  IN A ${IP_DN3}
${HOST_HIVE}.  IN A ${IP_HIVE}
!

sudo tee /etc/named/zones/db.${IP_REV} <<!
\$TTL 604800 ; 1 week
@ IN SOA ${HOST_DNS}. admin.${DOMAIN}. (
    3         ; Serial
    604800    ; Refresh
    86400     ; Retry
    2419200   ; Expire
    604800 )  ; Negative Cache TTL

; name servers
@    IN      NS     ${HOST_DNS}. 

; PTR Records
${IP_DNS_INV}     IN        PTR     ${HOST_DNS}. 
${IP_RANGER_INV} IN        PTR     ${HOST_RANGER}.     
${IP_NN_INV} IN        PTR     ${HOST_NN}.     
${IP_DN1_INV} IN        PTR     ${HOST_DN1}.     
${IP_DN2_INV} IN        PTR     ${HOST_DN2}.     
${IP_DN3_INV} IN        PTR     ${HOST_DN3}.     
${IP_HIVE_INV} IN        PTR     ${HOST_HIVE}.     
!

sudo tee /etc/dhcp/dhclient.conf <<!
# The custom DNS server IP
prepend domain-name-servers ${IP_DNS};
!
    echo "starting bind ..."
    sudo systemctl restart named
    sudo systemctl enable named
    sudo systemctl restart NetworkManager
    echo "done."
}

bootstrap_host() {
    setup_env
    install_dhclient
    install_client_nfs
    install_java
    create_users
}

create_users() {
    for i in hdfs yarn hive spark; do sudo adduser $i;done
    for i in hdfs yarn hive spark; do sudo usermod -a -G vagrant $i;done
    sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
    sudo systemctl restart sshd
}

install_client_nfs() {
    setup_env
    sudo mkdir -p /opt/shared
    echo "${IP_DNS}:/opt/shared /opt/shared nfs    defaults    0 0" | sudo tee -a /etc/fstab
    sudo mount -a
}

install_java(){
    sudo yum install java java-1.8.0-openjdk-devel -y --quiet
    echo 'export JAVA_HOME=/usr/lib/jvm/java' | sudo tee /etc/profile.d/java.sh
}

install_dhclient() {
    setup_env
    sudo tee /etc/dhcp/dhclient.conf <<!
# The custom DNS server IP
prepend domain-name-servers ${IP_DNS};
!
    sudo systemctl restart NetworkManager
}

install_packages() {
    setup_env
    sudo yum --quiet install \
        vim \
        tree \
        nfs-utils\
        bind-utils -y 2> /dev/null
}

my_curl() {
    # --max-time 10     (how long each retry will wait)
    # --retry 5         (it will retry 5 times)
    # --retry-delay 0   (an exponential backoff algorithm)
    # --retry-max-time  (total time before it's considered failed)
 
    curl -LO --connect-timeout 10 \
        --max-time 60 \
        --retry 5 \
        --retry-delay 0 \
        --retry-max-time 40 \
        $1
}

download_stack() {
    setup_env

    my_curl ${DOWNLOAD_URL}/hadoop/core/hadoop-${HADOOP_VER}/$HADOOP
    my_curl ${DOWNLOAD_URL}/hive/hive-${HIVE_VER}/$HIVE
    my_curl ${DOWNLOAD_URL}/spark/spark-${SPARK_VER}/$SPARK
    my_curl ${DOWNLOAD_URL}/tez/${TEZ_VER}/$TEZ
    my_curl ${DOWNLOAD_URL}/ranger/${RANGER_VER}/$RANGER
    my_curl ${DOWNLOAD_URL}/lucene/solr/${SOLR_VER}/$SOLR
}

case $(hostname) in
  ranger-dns)
    kernel_tunning
    install_packages 
    bootstrap_dns
    bootstrap_nfs
    download_stack
    ;;
  ranger|ranger-nn|ranger-dn1|ranger-dn2|ranger-dn3)
    kernel_tunning
    install_packages 
    bootstrap_host
    ;;
  ranger-hive) 
    kernel_tunning
    install_packages 
    bootstrap_host
    ;;
  *)
    echo "wtf!"
    exit 1
    ;;
esac
