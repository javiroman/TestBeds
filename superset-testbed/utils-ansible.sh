# Check hosts 
ansible -i provisioning/inventory \
    --private-key=/home/javiroman/.vagrant.d/insecure_private_key \
    -u vagrant \
    all -m ping

# Get all variables of hostvars
ansible -i provisioning/inventory -m debug -a "var=hostvars[inventory_hostname]" all

# Get IP in inventory
ansible -i provisioning/inventory -m debug -a "var=hostvars[inventory_hostname].ansible_host" all

# Get the IP of inventory giving the hostname inventory
ansible -i provisioning/inventory -m debug -a var=hostvars[kmod-dns].ansible_host all

# Execute only one play in the main playbook
ansible-playbook -vv -i provisioning/inventory \
    --private-key=/home/javiroman/.vagrant.d/insecure_private_key \
    -u vagrant \
    provisioning/site.yml \
    --limit "ldap"
# all host except only one
# --limit all:\!ldap
