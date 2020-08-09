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
    tar

ENV JUSTC_ENVDIR_VERSION="1.0.0"
WORKDIR /tmp/justc-envdir
RUN apk --update --no-cache add \
    skalibs-dev \
  && curl -sSL "https://github.com/just-containers/justc-envdir/releases/download/v${JUSTC_ENVDIR_VERSION}/justc-envdir-${JUSTC_ENVDIR_VERSION}.tar.gz" | tar xz --strip 1 \
  && ./configure \
    --enable-shared \
    --disable-allstatic \
    --prefix=/usr \
  && make -j$(nproc) \
  && make install

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

COPY --from=builder /usr/bin/justc-envdir /usr/bin/justc-envdir

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
