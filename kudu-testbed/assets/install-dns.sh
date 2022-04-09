#!/bin/bash
DOMAIN="antelope.lan"

DNS=dns
MASTERS=masters
TABLET1=tablet-server01
TABLET2=tablet-server02
TABLET3=tablet-server03
SOURCES=sources

HOST_DNS="$DNS.$DOMAIN"
HOST_MASTERS="$MASTERS.$DOMAIN"
HOST_TABLET1="$TABLET1.$DOMAIN"
HOST_TABLET2="$TABLET2.$DOMAIN"
HOST_TABLET3="$TABLET3.$DOMAIN"
HOST_SOURCES="$SOURCES.$DOMAIN"

# 10.0.0.0/24 10.0.0.255
IP_DNS="10.0.0.7"
IP_DNS_INV="7"
IP_MASTERS="10.0.0.2"
IP_MASTERS_INV="2"
IP_TABLET1="10.0.0.3"
IP_TABLET1_INV="3"
IP_TABLET2="10.0.0.4"
IP_TABLET2_INV="4"
IP_TABLET3="10.0.0.5"
IP_TABLET3_INV="5"
IP_SOURCES="10.0.0.6"
IP_SOURCES_INV="6"

IP_INV="0.0.10"
IP_REV="10.0.0"

[[ -z $1 ]] && echo "ERROR: please provide client or server parameter" && exit

if [ "$1" == "client" ]; then

    sudo yum install bind-utils -y
    sudo tee /etc/dhcp/dhclient.conf <<!
# The custom DNS server IP
prepend domain-name-servers ${IP_DNS};
!

    sudo systemctl restart NetworkManager
    echo "dns client installed"
    echo "bye."
    exit
fi

sudo yum install bind bind-utils -y

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

    /* 
     - If you are building an AUTHORITATIVE DNS server, do NOT enable recursion.
     - If you are building a RECURSIVE (caching) DNS server, you need to enable 
       recursion. 
     - If your recursive DNS server has a public IP address, you MUST enable access 
       control to limit queries to your legitimate users. Failing to do so will
       cause your server to become part of large scale DNS amplification 
       attacks. Implementing BCP38 within your network would greatly
       reduce such attack surface 
    */
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
    IN      NS      ${HOST_MN}.

; name servers - A records
${HOST_DNS}.   IN      A       ${IP_DNS}

; 10.0.0.0/24 - A records
${HOST_MASTERS}.  IN A ${IP_MASTERS}
${HOST_TABLET1}.  IN A ${IP_TABLET1}
${HOST_TABLET2}.  IN A ${IP_TABLET2}
${HOST_TABLET3}.  IN A ${IP_TABLET3}
${HOST_SOURCES}.  IN A ${IP_SOURCES}
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
${IP_MASTERS_INV} IN        PTR     ${HOST_MASTERS}.     
${IP_TABLET1_INV} IN        PTR     ${HOST_TABLET1}.     
${IP_TABLET2_INV} IN        PTR     ${HOST_TABLET2}.     
${IP_TABLET3_INV} IN        PTR     ${HOST_TABLET3}.     
${IP_SOURCES_INV} IN        PTR     ${HOST_SOURCES}.     
!

sudo tee /etc/dhcp/dhclient.conf <<!
# The custom DNS server IP
prepend domain-name-servers ${IP_DNS};
append domain-name "antelope.lan";
!

sudo systemctl restart named
sudo systemctl enable named
sudo systemctl restart NetworkManager

