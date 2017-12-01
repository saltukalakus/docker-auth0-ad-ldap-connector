FROM node:6.12
USER root

ARG VERSION=3.8.2

# prep work
RUN mkdir -p /opt/auth0-adldap/certs
COPY resources/healthcheck.js /opt/auth0-adldap
RUN apt-get update && apt-get install -y \
	bash ca-certificates git openssl apt-utils \
	make python gcc libffi-dev g++ && \
	chmod 777 /opt/auth0-adldap  && \
	chown -R node /opt/auth0-adldap && \
	rm -rf /var/lib/apt/lists/*

# use tini
ENV TINI_VERSION v0.9.0
RUN set -x \
	&& curl -fSL "https://github.com/krallin/tini/releases/download/$TINI_VERSION/tini" -o /usr/local/bin/tini \
	&& curl -fSL "https://github.com/krallin/tini/releases/download/$TINI_VERSION/tini.asc" -o /usr/local/bin/tini.asc \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 6380DC428747F6C393FEACA59A84159D7001A4E5 \
	&& gpg --batch --verify /usr/local/bin/tini.asc /usr/local/bin/tini \
	&& rm -r "$GNUPGHOME" /usr/local/bin/tini.asc \
	&& chmod +x /usr/local/bin/tini

# download and install the connector
WORKDIR /opt/auth0-adldap
RUN curl -Lo /tmp/adldap.tar.gz https://github.com/auth0/ad-ldap-connector/archive/v$VERSION.tar.gz && \
    tar -xzf /tmp/adldap.tar.gz -C /tmp && \
    mv /tmp/ad-ldap-connector-$VERSION/* /opt/auth0-adldap/ && \
	npm install && \
    npm cache clean && \
    apt-get purge -y make python gcc libffi-dev g++ && \
    rm -rf /tmp/* && \
    chmod 777 /opt/auth0-adldap/certs && \
	chown -R node:node /opt/auth0-adldap

#
COPY resources/entrypoint.sh /opt/auth0-adldap
RUN chmod +x /opt/auth0-adldap/entrypoint.sh
USER node
HEALTHCHECK CMD curl --fail http://localhost:8080 || exit 1
EXPOSE 8080 8357
ENTRYPOINT ["/usr/local/bin/tini", "--", "/opt/auth0-adldap/entrypoint.sh"]