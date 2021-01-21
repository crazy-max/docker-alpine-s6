ARG ALPINE_VERSION
ARG ALPINE_BUILD_VERSION
FROM --platform=${TARGETPLATFORM:-linux/amd64} alpine:${ALPINE_BUILD_VERSION:-${ALPINE_VERSION:-latest}} as builder

ENV SKALIBS_VERSION="2.10.0.1" \
  EXECLINE_VERSION="2.7.0.0" \
  S6_VERSION="2.10.0.0" \
  S6_DNS_VERSION="2.3.5.0" \
  S6_LINUX_UTILS_VERSION="2.5.1.4" \
  S6_NETWORKING_VERSION="2.4.0.0" \
  S6_PORTABLE_UTILS_VERSION="2.2.3.1" \
  S6_RC_VERSION="0.5.2.1" \
  JUSTC_ENVDIR_VERSION="1.0.1" \
  SOCKLOG_VERSION="2.2.2" \
  SOCKLOG_RELEASE="" \
  S6_OVERLAY_PREINIT_VERSION="1.0.4" \
  S6_OVERLAY_VERSION="2.2.0.0" \
  DIST_PATH="/dist"

RUN apk --update --no-cache add \
    bearssl-dev \
    build-base \
    curl \
    rsync \
    tar \
    tree

WORKDIR /tmp/skalibs
RUN curl -sSL "https://skarnet.org/software/skalibs/skalibs-${SKALIBS_VERSION}.tar.gz" | tar xz --strip 1
COPY patchs/skalibs .
RUN sed -i "s|@@VERSION@@|${SKALIBS_VERSION}|" -i *.pc \
  && ./configure \
    --enable-shared \
    --enable-static \
    --libdir=/usr/lib \
  && make DESTDIR=${DIST_PATH} install -j$(nproc) \
  && make install -j$(nproc) \
  && mkdir -p /usr/lib/skalibs/sysdeps \
  && tree ${DIST_PATH}

WORKDIR /tmp/execline
RUN curl -sSL "https://skarnet.org/software/execline/execline-${EXECLINE_VERSION}.tar.gz" | tar xz --strip 1 \
  && ./configure \
    --enable-shared \
    --enable-static \
    --disable-allstatic \
    --libdir=/usr/lib \
    --with-dynlib=/lib \
  && make DESTDIR=${DIST_PATH} install -j$(nproc) \
  && make install -j$(nproc) \
  && tree ${DIST_PATH}

WORKDIR /tmp/s6
RUN curl -sSL "https://skarnet.org/software/s6/s6-${S6_VERSION}.tar.gz" | tar xz --strip 1
COPY patchs/s6 .
RUN ./configure \
    --enable-shared \
    --enable-static \
    --disable-allstatic \
    --libdir=/usr/lib \
    --libexecdir=/lib/s6 \
    --with-dynlib=/lib \
  && make DESTDIR=${DIST_PATH} install -j$(nproc) \
  && make install -j$(nproc) \
  && mkdir -p "${DIST_PATH}/lib/s6" \
  && cp s6-svscanboot "${DIST_PATH}/lib/s6/s6-svscanboot" \
  && mkdir -p "${DIST_PATH}/etc/init.d" \
  && cp s6.initd "${DIST_PATH}/etc/init.d/s6" \
  && tree ${DIST_PATH}

WORKDIR /tmp/s6-dns
RUN curl -sSL "https://skarnet.org/software/s6-dns/s6-dns-${S6_DNS_VERSION}.tar.gz" | tar xz --strip 1 \
  && ./configure \
    --enable-shared \
    --enable-static \
    --disable-allstatic \
    --prefix=/usr \
    --libdir=/usr/lib \
    --libexecdir=/usr/lib/s6-dns \
    --with-dynlib=/lib \
  && make DESTDIR=${DIST_PATH} install -j$(nproc) \
  && make install -j$(nproc) \
  && tree ${DIST_PATH}

WORKDIR /tmp/s6-linux-utils
RUN curl -sSL "https://skarnet.org/software/s6-linux-utils/s6-linux-utils-${S6_LINUX_UTILS_VERSION}.tar.gz" | tar xz --strip 1 \
  && ./configure \
    --enable-shared \
    --enable-static \
    --disable-allstatic \
    --prefix=/usr \
    --libdir=/usr/lib \
  && make DESTDIR=${DIST_PATH} install -j$(nproc) \
  && make install -j$(nproc) \
  && tree ${DIST_PATH}

WORKDIR /tmp/s6-networking
RUN curl -sSL "https://skarnet.org/software/s6-networking/s6-networking-${S6_NETWORKING_VERSION}.tar.gz" | tar xz --strip 1 \
  && ./configure \
    --enable-shared \
    --enable-static \
    --disable-allstatic \
    --prefix=/usr \
    --libdir=/usr/lib \
    --libexecdir=/usr/lib/s6-networking \
    --with-dynlib=/lib \
    --enable-ssl=bearssl \
  && make DESTDIR=${DIST_PATH} install -j$(nproc) \
  && make install -j$(nproc) \
  && tree ${DIST_PATH}

WORKDIR /tmp/s6-portable-utils
RUN curl -sSL "https://skarnet.org/software/s6-portable-utils/s6-portable-utils-${S6_PORTABLE_UTILS_VERSION}.tar.gz" | tar xz --strip 1 \
  && ./configure \
    --enable-shared \
    --enable-static \
    --disable-allstatic \
    --prefix=/usr \
    --libdir=/usr/lib \
  && make DESTDIR=${DIST_PATH} install -j$(nproc) \
  && make install -j$(nproc) \
  && tree ${DIST_PATH}

WORKDIR /tmp/s6-rc
RUN curl -sSL "https://skarnet.org/software/s6-rc/s6-rc-${S6_RC_VERSION}.tar.gz" | tar xz --strip 1 \
  && ./configure \
    --enable-shared \
    --enable-static \
    --disable-allstatic \
    --libdir=/usr/lib \
    --libexecdir=/lib/s6-rc \
    --with-dynlib=/lib \
  && make DESTDIR=${DIST_PATH} install -j$(nproc) \
  && make install -j$(nproc) \
  && tree ${DIST_PATH}

WORKDIR /tmp/justc-envdir
RUN curl -sSL "https://github.com/just-containers/justc-envdir/releases/download/v${JUSTC_ENVDIR_VERSION}/justc-envdir-${JUSTC_ENVDIR_VERSION}.tar.gz" | tar xz --strip 1 \
  && ./configure \
    --enable-shared \
    --disable-allstatic \
    --prefix=/usr \
  && make DESTDIR=${DIST_PATH} install -j$(nproc) \
  && make install -j$(nproc) \
  && tree ${DIST_PATH}

WORKDIR /tmp/socklog
RUN curl -sSL "https://github.com/just-containers/socklog/releases/download/v${SOCKLOG_VERSION}${SOCKLOG_RELEASE}/socklog-${SOCKLOG_VERSION}.tar.gz" | tar xz --strip 1 \
  && ./configure \
    --enable-shared \
    --disable-allstatic \
    --prefix=/usr \
  && make DESTDIR=${DIST_PATH} install -j$(nproc) \
  && make install -j$(nproc) \
  && tree ${DIST_PATH}

WORKDIR /tmp/s6-overlay-preinit
RUN curl -sSL "https://github.com/just-containers/s6-overlay-preinit/releases/download/v${S6_OVERLAY_PREINIT_VERSION}/s6-overlay-preinit-${S6_OVERLAY_PREINIT_VERSION}.tar.gz" | tar xz --strip 1 \
  && ./configure \
    --enable-shared \
    --disable-allstatic \
  && make DESTDIR=${DIST_PATH} install -j$(nproc) \
  && make install -j$(nproc) \
  && tree ${DIST_PATH}

WORKDIR /tmp/s6-overlay
RUN curl -SsOL https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-nobin.tar.gz \
  && tar zxf s6-overlay-nobin.tar.gz -C ${DIST_PATH}/

WORKDIR /tmp/socklog-overlay
RUN wget -q "https://github.com/just-containers/socklog-overlay/archive/master.zip" -qO "socklog-overlay.zip" \
  && unzip socklog-overlay.zip \
  && rsync -a ./socklog-overlay-master/overlay-rootfs/ ${DIST_PATH}/ \
  && mkdir -p \
    ${DIST_PATH}/var/log/socklog/cron \
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

ARG TARGETPLATFORM
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

COPY --from=builder /dist /

RUN apk --update --no-cache add \
    bearssl \
  && s6-rmrf /var/cache/apk/* /tmp/*

ENTRYPOINT ["/init"]
