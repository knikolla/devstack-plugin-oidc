import os
import uuid

from keystoneauth1 import identity
from keystoneauth1 import session
from keystoneclient.v3 import client as client

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

c = client.Client(session=s)
a = c.application_credentials.create(name=uuid.uuid4().hex)

auth_cred = identity.v3.ApplicationCredential(
    auth_url=f'http://{host_ip}/identity/v3',
    application_credential_id=a.id,
    application_credential_secret=a.secret,
)
sess_cred = session.Session(auth_cred)
if sess_cred.get_token():
    print('Authentication successful with app_cred!')
