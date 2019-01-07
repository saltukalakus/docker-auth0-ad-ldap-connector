FROM node:8.15.0-alpine

ARG VERSION=4.1.6

RUN mkdir -p /opt/auth0-adldap/certs
WORKDIR /opt/auth0-adldap

RUN apk --no-cache add bash ca-certificates curl g++ git make openssl python tini && \
	curl -Lo /tmp/adldap.tar.gz https://github.com/auth0/ad-ldap-connector/archive/v$VERSION.tar.gz && \
    tar -xzf /tmp/adldap.tar.gz -C /tmp && \
    mv /tmp/ad-ldap-connector-$VERSION/* /opt/auth0-adldap && \
    npm install && \
    chown -R node /opt/auth0-adldap && \
    apk del g++ make python && \
    rm -rf /tmp/* /var/cache/apk/*

COPY entrypoint.sh /opt/auth0-adldap
# Replace the host listening from 127.0.0.1 to 0.0.0.0 for the admin/server.js to be accessable from host machine.
RUN sed -i 's/127.0.0.1/0.0.0.0/g' /opt/auth0-adldap/admin/server.js
RUN chmod +x /opt/auth0-adldap/entrypoint.sh
USER node
EXPOSE 8357
ENTRYPOINT ["/sbin/tini", "--", "/opt/auth0-adldap/entrypoint.sh"]