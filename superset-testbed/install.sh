RPM_IP=$(hostname -I | cut -d' ' -f1)
RPM_URL=http://${RPM_IP}:8000

export RPM_URL
ansible-playbook -vv -i provisioning/inventory \
    --private-key=/home/javiroman/.vagrant.d/insecure_private_key \
    -u vagrant \
    provisioning/site.yml

#ansible-playbook -vv -i provisioning/inventory \
#    --private-key=/home/javiroman/.vagrant.d/insecure_private_key \
#    -u vagrant \
#    provisioning/site.yml
#    --limit "ldap"
   
