# At NameNode

sudo yum install rpcbind nfs-server nfs-lock nfs-idmap vim -y
sudo mkdir -p /opt/shared/ && sudo chown -R vagrant: /opt/shared/
echo ‘/opt/shared *(rw,sync,no_root_squash)’ > /etc/exports
sudo systemctl start nfs-server
sudo systemctl enable nfs-server
showmount -e

# On every DataNode
sudo mkdir -p /opt/shared
echo '100.0.10.100:/opt/shared /opt/shared nfs    defaults    0 0' | sudo tee -a /etc/fstab
sudo mount -a



