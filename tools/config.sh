export HOST_IP=`ip addr show eth0 | grep "inet " | awk '{ print $2 }' | awk -F "/"  '{ print $1 }'`
export HOST_IPV6=`ip addr show eth0 | grep "inet6 " | awk '{ print $2 }' | awk -F "/"  '{ print $1 }'`

export KEYCLOAK_URL="http://${HOST_IP}:8080"
export KEYCLOAK_USERNAME='admin'
export KEYCLOAK_PASSWORD='nomoresecret'
