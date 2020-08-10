ARG ALPINE_VERSION
FROM --platform=${TARGETPLATFORM:-linux/amd64} alpine:${ALPINE_VERSION:-latest} as builder

ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN printf "I am running on ${BUILDPLATFORM:-linux/amd64}, building for ${TARGETPLATFORM:-linux/amd64}\n$(uname -a)\n"

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

RUN apk --update --no-cache add \
    autoconf \
    automake \
    binutils \
    build-base \
    curl \
    skalibs-dev \
    tar \
    tree

ENV JUSTC_ENVDIR_VERSION="1.0.0"
WORKDIR /tmp/justc-envdir
RUN curl -sSL "https://github.com/just-containers/justc-envdir/releases/download/v${JUSTC_ENVDIR_VERSION}/justc-envdir-${JUSTC_ENVDIR_VERSION}.tar.gz" | tar xz --strip 1 \
  && ./configure \
    --enable-shared \
    --disable-allstatic \
    --prefix=/usr \
  && make -j$(nproc) \
  && make DESTDIR=/dist install \
  && tree /dist

ENV SOCKLOG_VERSION="2.2.1" \
  SOCKLOG_RELEASE="5"
WORKDIR /tmp/socklog
RUN curl -sSL "https://github.com/just-containers/socklog/releases/download/v${SOCKLOG_VERSION}-${SOCKLOG_RELEASE}/socklog-${SOCKLOG_VERSION}.tar.gz" | tar xz --strip 1 \
  && ./configure \
    --enable-shared \
    --disable-allstatic \
    --prefix=/usr \
  && make -j$(nproc) \
  && make DESTDIR=/dist install \
  && tree /dist

ARG ALPINE_VERSION
FROM --platform=${TARGETPLATFORM:-linux/amd64} alpine:${ALPINE_VERSION:-latest}

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL maintainer="CrazyMax" \
  org.opencontainers.image.created=$BUILD_DATE \
  org.opencontainers.image.url="https://github.com/crazy-max/docker-alpine-s6" \
  org.opencontainers.image.source="https://github.com/crazy-max/docker-alpine-s6" \
  org.opencontainers.image.version=$VERSION \
  org.opencontainers.image.revision=$VCS_REF \
  org.opencontainers.image.vendor="CrazyMax" \
  org.opencontainers.image.title="alpine-s6" \
  org.opencontainers.image.description="Alpine Linux with s6 overlay" \
  org.opencontainers.image.licenses="MIT"

ENV S6_OVERLAY_VERSION="2.0.0.1"

COPY --from=builder /dist /

RUN apk --update --no-cache add \
    s6 \
    s6-dns \
    s6-linux-utils \
    s6-networking \
    s6-portable-utils \
    s6-rc \
  && apk --update --no-cache add -t build-dependencies \
    curl \
  && justc-envdir /tmp uname -a \
  && curl -SsOL https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-nobin.tar.gz \
  && tar zxf s6-overlay-nobin.tar.gz \
  && apk del build-dependencies \
  && s6-rmrf s6-overlay-nobin* /var/cache/apk/* /tmp/*

RUN apk --update --no-cache add -t build-dependencies \
    rsync \
  && wget -q "https://github.com/just-containers/socklog-overlay/archive/master.zip" -qO "/tmp/socklog-overlay.zip" \
  && unzip /tmp/socklog-overlay.zip -d /tmp/ \
  && rsync -a /tmp/socklog-overlay-master/overlay-rootfs/ / \
  && mkdir -p /var/log/socklog/cron \
    /var/log/socklog/daemon \
    /var/log/socklog/debug \
    /var/log/socklog/errors \
    /var/log/socklog/everything \
    /var/log/socklog/kernel \
    /var/log/socklog/mail \
    /var/log/socklog/messages \
    /var/log/socklog/secure \
    /var/log/socklog/user \
  && apk del build-dependencies \
  && s6-rmrf /var/cache/apk/* /tmp/*
