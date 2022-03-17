# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

OIDC_CLIENT_ID=${CLIENT_ID:-devstack}
OIDC_CLIENT_SECRET=${OIDC_CLIENT_SECRET:-nomoresecret}
OIDC_ISSUER=${OIDC_ISSUER:-"http://$HOST_IP:8080/auth/realms/master"}
OIDC_METADATA_URL=${OIDC_METADATA_URL:-"http://$HOST_IP:8080/auth/realms/master/.well-known/openid-configuration"}
OIDC_JWKS_URL=${OIDC_JWKS_URL:-"https://$HOST_IP:8443/auth/realms/master/protocol/openid-connect/certs"}

IDP_ID=${IDP_ID:-sso}
REDIRECT_URI="http://$HOST_IP/identity/v3/auth/OS-FEDERATION/identity_providers/$IDP_ID/protocols/openid/websso"

OIDC_PLUGIN="$DEST/devstack-plugin-oidc/devstack"

function install_federation {
    if is_ubuntu; then
        install_package libapache2-mod-auth-openidc
        sudo a2enmod headers
    elif is_fedora; then
        install_package mod_auth_openidc
        #FIXME: enable mod_headers
    else
        echo "Skipping installation. Only supported on Ubuntu and RHEL based."
    fi
}

function configure_federation {
    # Specify the header that contains information about the identity provider
    iniset $KEYSTONE_CONF openid remote_id_attribute "HTTP_OIDC_ISS"
    iniset $KEYSTONE_CONF auth methods "password,token,openid,application_credential"
    iniset $KEYSTONE_CONF federation trusted_dashboard "http://$HOST_IP/auth/websso/"

    cp /opt/stack/keystone/etc/sso_callback_template.html /etc/keystone/

    if [[ "$WSGI_MODE" == "uwsgi" ]]; then
        restart_service "devstack@keystone"
    fi

    if [[ "$OIDC_ISSUER" == "http://$HOST_IP:8080/auth/realms/master" ]]; then
        # Assuming we want to setup a local keycloak here.
        pip_install "git+https://github.com/CCI-MOC/onboarding-tools@be619be8904b08b07b3e9d10562f800ddf463d1f#egg=onboarding_tools"
        KEYCLOAK_URL="http://$HOST_IP:8080" \
            KEYCLOAK_USERNAME="admin" \
            KEYCLOAK_PASSWORD="nomoresecret" \
            python3 $DEST/devstack-plugin-oidc/tools/setup_keycloak_client.py
    fi

    local keystone_apache_conf=$(apache_site_config_for keystone-wsgi-public)
    cat $OIDC_PLUGIN/files/apache_oidc.conf | sudo tee -a $keystone_apache_conf
    sudo sed -i -e "
        s|%OIDC_CLIENT_ID%|$OIDC_CLIENT_ID|g;
        s|%OIDC_CLIENT_SECRET%|$OIDC_CLIENT_SECRET|g;
        s|%OIDC_METADATA_URL%|$OIDC_METADATA_URL|g;
        s|%OIDC_JWKS_URL%|$OIDC_JWKS_URL|g;
        s|%HOST_IP%|$HOST_IP|g;
        s|%IDP_ID%|$IDP_ID|g;
    " $keystone_apache_conf

    restart_apache_server
}

function register_federation {
    local domain=$(get_or_create_domain sso)
    local project=$(get_or_create_project test_project sso)
    local group=$(get_or_create_group sso_users sso)
    local role=$(get_or_create_role member)

    openstack role add --group $group --project $project $role

    openstack identity provider create --remote-id $OIDC_ISSUER --domain $domain $IDP_ID
    openstack mapping create --rules $OIDC_PLUGIN/files/mapping.json sso_oidc_mapping
    openstack federation protocol create --identity-provider $IDP_ID --mapping sso_oidc_mapping openid
}
