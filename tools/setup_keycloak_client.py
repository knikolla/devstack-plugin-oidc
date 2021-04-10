from onboarding_tools.keycloak import KeycloakClient

c = KeycloakClient()

c.create_client(
    'master',
    'devstack',
    'nomoresecret',
    ['http://10.0.3.2/identity/v3/auth/OS-FEDERATION/identity_providers/sso/protocols/openid/websso']
)
