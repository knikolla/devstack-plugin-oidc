# OpenID Connect Plugin for Devstack
Devstack plugin that automates setting up OpenID Connect with Keystone
and Devstack.

## Quickstart
```bash
$ vagrant up
```

If you have Vagrant installed and want to get started as quickly as possible,
the default configuration gets you a Wallaby release of OpenStack Keystone
and Keycloak.

To spin up a Keycloak instance, `docker-compose` is used.

`tools/test_login.py` provides a verification and example for authenticating
to OpenID Connect using the CLI with a username/password.

## Configuration
The plugin exposes the following configuration options via environment
variables.

* OIDC_CLIENT_ID=devstack
  * Client ID for the client assigned to Keystone
* OIDC_CLIENT_SECRET=nomoresecret
  * Client Secret for the client assigned to Keystone
* OIDC_ISSUER="http://$HOST_IP:8080/auth/realms/master"
  * Issuer ID of the authorization server, if this matches the default above,
    the plugin will attempt to automatically create the client using the ID
    and secret provided in the preceding configuration options.
* OIDC_METADATA_URL="http://$HOST_IP:8080/auth/realms/master/.well-known/openid-configuration"
  * URL of the well known endpoint of the authorization server.
* OIDC_JWKS_URL="https://$HOST_IP:8443/auth/realms/master/protocol/openid-connect/certs"
  * URL of the JWKS endpoint of the authorization server providing the public keys used
    for signing the JWT token.
* IDP_ID="sso"
  * Name to register the identity provider in Keystone.

## Future work
- [ ] Remove dependency on `CCI-MOC/onboarding-tools`
- [ ] Add workflow for continuous integration
- [ ] Split out shell scripts from `Vagrantfile` into dedicated `.sh` file

## References
For an example of setting up a more complete Devstack,
including Nova, Cinder, and Glance, see [here](
https://github.com/nerc-project/coldfront-plugin-openstack/blob/main/ci/devstack.sh).
This is used by `nerc-project/coldfront-plugin-openstack` to perform
integration testing with OpenStack and Keycloak in a GitHub Action.

Read the Devstack documentation [here](https://docs.openstack.org/devstack/latest/)
for information on its configuration options exposed using `local.conf`.
