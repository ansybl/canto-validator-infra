FROM golang:1.19-alpine AS buildenv

# currently testnet seems to be running on v3 only
# v4 would get appHash verification issue vs other nodes
ENV VERSION 3.0.0

# Set up dependencies
RUN apk add --update --no-cache \
    eudev-dev \
    gcc \
    git \
    libc-dev \
    linux-headers \
    make

# Set working directory for the build
WORKDIR /app

RUN wget https://github.com/Canto-Network/Canto/archive/refs/tags/v$VERSION.tar.gz && \
    tar -xvf v$VERSION.tar.gz && \
    cd Canto-$VERSION && \
    make install && \
    wget https://github.com/a8m/envsubst/releases/download/v1.2.0/envsubst-`uname -s`-`uname -m` -O /tmp/envsubst

FROM alpine:3

ENV CANTOD_HOME=/root/.cantod

RUN apk add --no-cache --update \
    ca-certificates \
    curl \
    jq \
    supervisor

COPY --from=buildenv /go/bin/cantod /tmp/
COPY --from=buildenv /tmp/envsubst /tmp/

RUN install -m 0755 -o root -g root -t /usr/local/bin /tmp/cantod && \
    rm /tmp/cantod && \
    install -m 0755 -o root -g root -t /usr/local/bin /tmp/envsubst && \
    rm /tmp/envsubst

WORKDIR /root

# Add supervisor configuration files
RUN mkdir -p /etc/supervisor/conf.d/ $CANTOD_HOME/config
COPY ./supervisor/supervisord.conf /etc/supervisord.conf
COPY ./supervisor/conf.d/* /etc/supervisor/conf.d/
COPY ./config/* $CANTOD_HOME/config/

# Expose ports
EXPOSE 26656 26657 26658
EXPOSE 1317

# Add entrypoint script
COPY ./scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod u+x /usr/local/bin/entrypoint.sh
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

STOPSIGNAL SIGINT
