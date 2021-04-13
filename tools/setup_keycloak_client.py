import os

from onboarding_tools.keycloak import KeycloakClient

c = KeycloakClient()

host_ip = os.getenv('HOST_IP', 'localhost')
redirect_uris = [
    f'http://{host_ip}/identity/v3/auth/OS-FEDERATION/identity_providers/sso/protocols/openid/websso',
    f'http://{host_ip}/identity/v3/auth/OS-FEDERATION/websso/openid'
]

c.create_client('master', 'devstack', 'nomoresecret', redirect_uris)
