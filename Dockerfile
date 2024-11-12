FROM alpine:3.20

ENV ORAS_VERSION="1.2.0"

RUN apk add --no-cache curl bash

RUN curl -sL https://github.com/oras-project/oras/releases/download/v${ORAS_VERSION}/oras_${ORAS_VERSION}_linux_amd64.tar.gz > /opt/oras_amd64.tar.gz

RUN cd /opt \
	&& tar xfz oras_amd64.tar.gz \
	&& mv oras /bin/oras \
	&& mkdir -p /.docker \
	&& chown nobody:nobody /tmp /.docker

COPY proxy-trivy-dbs.sh /bin/proxy-trivy-dbs
COPY acr-oauth.sh /bin/acr-oauth

USER nobody

ENTRYPOINT ["proxy-trivy-dbs"]
