ARG ALPINE_VERSION
FROM --platform=${TARGETPLATFORM:-linux/amd64} alpine:${ALPINE_VERSION:-latest} as builder

ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN printf "I am running on ${BUILDPLATFORM:-linux/amd64}, building for ${TARGETPLATFORM:-linux/amd64}\n$(uname -a)\n"

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

ENV JUSTC_ENVDIR_VERSION="1.0.0" \
  SOCKLOG_VERSION="2.2.1" \
  SOCKLOG_RELEASE="5" \
  S6_OVERLAY_PREINIT_VERSION="1.0.2" \
  S6_OVERLAY_VERSION="2.1.0.2" \
  DIST_PATH="/dist"

RUN apk --update --no-cache add \
    autoconf \
    automake \
    binutils \
    build-base \
    curl \
    rsync \
    skalibs-dev \
    tar \
    tree

WORKDIR /tmp/justc-envdir
RUN curl -sSL "https://github.com/just-containers/justc-envdir/releases/download/v${JUSTC_ENVDIR_VERSION}/justc-envdir-${JUSTC_ENVDIR_VERSION}.tar.gz" | tar xz --strip 1 \
  && ./configure \
    --enable-shared \
    --disable-allstatic \
    --prefix=/usr \
  && make -j$(nproc) \
  && make DESTDIR=${DIST_PATH} install \
  && tree ${DIST_PATH}

WORKDIR /tmp/socklog
RUN curl -sSL "https://github.com/just-containers/socklog/releases/download/v${SOCKLOG_VERSION}-${SOCKLOG_RELEASE}/socklog-${SOCKLOG_VERSION}.tar.gz" | tar xz --strip 1 \
  && ./configure \
    --enable-shared \
    --disable-allstatic \
    --prefix=/usr \
  && make -j$(nproc) \
  && make DESTDIR=${DIST_PATH} install \
  && tree ${DIST_PATH}

WORKDIR /tmp/s6-overlay-preinit
RUN curl -sSL "https://github.com/just-containers/s6-overlay-preinit/releases/download/v${S6_OVERLAY_PREINIT_VERSION}/s6-overlay-preinit-${S6_OVERLAY_PREINIT_VERSION}.tar.gz" | tar xz --strip 1 \
  && ./configure \
    --enable-shared \
    --disable-allstatic \
  && make -j$(nproc) \
  && make DESTDIR=${DIST_PATH} install \
  && tree ${DIST_PATH}

WORKDIR /tmp/s6-overlay
RUN curl -SsOL https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-nobin.tar.gz \
  && tar zxf s6-overlay-nobin.tar.gz -C ${DIST_PATH}/

WORKDIR /tmp/socklog-overlay
RUN wget -q "https://github.com/just-containers/socklog-overlay/archive/master.zip" -qO "socklog-overlay.zip" \
  && unzip socklog-overlay.zip \
  && rsync -a ./socklog-overlay-master/overlay-rootfs/ ${DIST_PATH}/ \
  && mkdir -p ${DIST_PATH}/var/log/socklog/cron \
    ${DIST_PATH}/var/log/socklog/daemon \
    ${DIST_PATH}/var/log/socklog/debug \
    ${DIST_PATH}/var/log/socklog/errors \
    ${DIST_PATH}/var/log/socklog/everything \
    ${DIST_PATH}/var/log/socklog/kernel \
    ${DIST_PATH}/var/log/socklog/mail \
    ${DIST_PATH}/var/log/socklog/messages \
    ${DIST_PATH}/var/log/socklog/secure \
    ${DIST_PATH}/var/log/socklog/user \
  && tree ${DIST_PATH}

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

RUN apk --update --no-cache add \
    s6 \
    s6-dns \
    s6-linux-utils \
    s6-networking \
    s6-portable-utils \
    s6-rc \
  && s6-rmrf /var/cache/apk/* /tmp/*

COPY --from=builder /dist /

ENTRYPOINT ["/init"]
