import os

from keystoneauth1 import identity
from keystoneauth1 import session

host_ip = os.getenv('HOST_IP', 'localhost')
auth = identity.v3.oidc.OidcPassword(
    f'http://{host_ip}/identity/v3',
    identity_provider='sso',
    protocol='openid',
    client_id='devstack',
    client_secret='nomoresecret',
    access_token_endpoint=f'http://{host_ip}:8080/auth/realms/master/protocol/openid-connect/token',
    discovery_endpoint=f'http://{host_ip}:8080/auth/realms/master/.well-known/openid-configuration',
    username='admin',
    password='nomoresecret',
    project_name='test_project',
    project_domain_name='sso',
)
s = session.Session(auth)

if s.get_token():
    print('Authentication successful!')
