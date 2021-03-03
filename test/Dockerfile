ARG BASE_IMAGE
FROM ${BASE_IMAGE:-test-alpine-s6} AS builder

ENV TZ="UTC" \
  PUID="1000" \
  PGID="1000"

RUN apk add --update --no-cache \
    bash \
    rrdtool-cached \
    shadow \
    tzdata \
  && addgroup -g ${PGID} rrdcached \
  && adduser -D -H -u ${PUID} -G rrdcached -s /bin/sh rrdcached \
  && rm -rf /tmp/* /var/cache/apk/*

COPY rootfs /

EXPOSE 42217
WORKDIR /data
VOLUME [ "/data/db", "/data/journal" ]

HEALTHCHECK --interval=10s --timeout=5s --start-period=5m \
  CMD echo PING | nc 127.0.0.1 42217 | grep PONG || exit 1
