# Hosts

```
$ cat /etc/hosts
10.100.0.2 ranger-dns.ranger.lan (DNS, NFS)
10.100.0.3 ranger.ranger.lan (Solr, MySQL, Ranger ...)
10.100.0.4 ranger-nn.ranger.lan (NameNode, SecondaryNameNode, ResourceManager)
10.100.0.5 ranger-dn1.ranger.lan (DataNode, NodeManager)
10.100.0.6 ranger-dn2.ranger.lan (DataNode, NodeManager)
10.100.0.7 ranger-dn3.ranger.lan (DataNode, NodeManager)
10.100.0.8 ranger-hive.ranger.lan (PostgreSQL, HiveMetaStore, HiveServer2)

```

# UI

NameNode UI: http://ranger-nn.ranger.lan:9870

YARN UI: http://ranger-nn.ranger.lan:8088

HiveServer2 UI: http://ranger-hive.ranger.lan:10002
