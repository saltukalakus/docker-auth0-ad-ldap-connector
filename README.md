Dockerization of the Auth0 AD LDAP connector for Linux

## Instructions to deploy

 1. Copy `config.json.dist` to `config.json` and edit the file with your settings.
 1. Start-up a container which mounts `config.json` and your cert files and exposes ports 8357 and 8080. The script [`example-run.sh`](example-run.sh) can help you get started and could be run as-is. Note that it will start the container with host networking.
 
## Certs

If you don't mount your own certs the container will automatically generate a self signed cert INSIDE the container. You can mount your own `cert.crt` and `cert.pem` to `/opt/auth-adldap/certs/`

*NOTE* If you connect to a freshly provisioned LDAP connection with a previously unused `TICKET URL` for the first time and you have not mapped a cert from outside the container, then the container will generate a cert inside the container and post it to Auth0 for that connection in your LDAP Connector dashboard. From that point forward, that LDAP connection in Auth0 will only work with the cert inside that container. If you delete the container and start up a new one, you cannot use it with the same `TICKET URL` (PROVISIONING_TICKET in the config.json file) because the cert in the new container will be different. See "Cert mismatch problem" section below

## Troubleshooting

Go to http://localhost:8357 and click the [Troubleshooting](https://auth0.com/docs/connector/modify#troubleshooting) tab to run the tests.

### Cert mismatch problem
If you have the following issue where the containers output is something like the following:

	Posting certificates and signInEndpoint: http://your-host:4000/wsfed

.. followed by

	Unexpected status while configuring connection: 504
	
.. and the container shuts down, then it means the LDAP connection in your Auth0 dashboard is already setup using a different cert. In other words, the LDAP agent already connected to it once using a different cert and now only that original cert that was used will continue to work with that connection configured in the Auth0 dashboard.

The solution is to either use the original cert or to delete the LDAP connection configured in your Auth0 dashboard and create a new one and use it's `TICKET URL` (PROVISIONING_TICKET in the config.json file). Continue using the same cert otherwise you will get this error again.

<hr>

#### Credit where due:

 - https://github.com/SwingDev/swg-auth0-ad-ldap-connector  
   This project differs from that one in that the goal of this project is to provide a turn-key solution that is simpler to run.

#### Disclaimer

This project is provide as-is and without any warranty or representations for reliability and or safety. Use at your own risk.