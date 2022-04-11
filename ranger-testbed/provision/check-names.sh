declare -A HOSTS
HOSTS=( 
    ["ranger-dns"]="10.100.0.2" 
    ["ranger"]="10.100.0.3" 
    ["ranger-nn"]="10.100.0.4" 
    ["ranger-dn1"]="10.100.0.5" 
    ["ranger-dn2"]="10.100.0.6" 
    ["ranger-dn3"]="10.100.0.7" 
    ["ranger-hive"]="10.100.0.8" 
)

for i in "${!HOSTS[@]}"; do
    echo "($i , ${HOSTS[$i]})"
    #ssh -i $HOME/.vagrant.d/insecure_private_key vagrant@${HOSTS[$i]} "host $i.ranger.lan"
    ssh -i $HOME/.vagrant.d/insecure_private_key vagrant@$1 \
        "host $i.ranger.lan && host ${HOSTS[$i]}"
done

