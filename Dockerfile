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
RUN chmod +x /opt/auth0-adldap/entrypoint.sh
USER node
HEALTHCHECK CMD curl --fail http://localhost:8357/codemirror-addon/hint/show-hint.css || exit 1
EXPOSE 8357
ENTRYPOINT ["/sbin/tini", "--", "/opt/auth0-adldap/entrypoint.sh"]