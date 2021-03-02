ARG SKALIBS_VERSION="2.9.3.0"
ARG EXECLINE_VERSION="2.6.1.1"
ARG S6_VERSION="2.9.2.0"
ARG S6_DNS_VERSION="2.3.3.0"
ARG S6_LINUX_UTILS_VERSION="2.5.1.3"
ARG S6_NETWORKING_VERSION="2.3.2.0"
ARG S6_PORTABLE_UTILS_VERSION="2.2.3.0"
ARG S6_RC_VERSION="0.5.2.0"
ARG JUSTC_ENVDIR_VERSION="1.0.0"
ARG JUSTC_ENVDIR_RELEASE=""
ARG JUSTC_INSTALLER_VERSION="1.0.1"
ARG JUSTC_INSTALLER_RELEASE=""
ARG SOCKLOG_OVERLAY_VERSION="2.2.1"
ARG SOCKLOG_OVERLAY_RELEASE="-4"
ARG S6_OVERLAY_PREINIT_VERSION="1.0.4"
ARG S6_OVERLAY_VERSION="2.1.0.2"
ARG GOSU_VERSION="1.12"

FROM --platform=${BUILDPLATFORM:-linux/amd64} alpine as download

ARG SKALIBS_VERSION
ARG EXECLINE_VERSION
ARG S6_VERSION
ARG S6_DNS_VERSION
ARG S6_LINUX_UTILS_VERSION
ARG S6_NETWORKING_VERSION
ARG S6_PORTABLE_UTILS_VERSION
ARG S6_RC_VERSION
ARG JUSTC_ENVDIR_VERSION
ARG JUSTC_ENVDIR_RELEASE
ARG JUSTC_INSTALLER_VERSION
ARG JUSTC_INSTALLER_RELEASE
ARG SOCKLOG_OVERLAY_VERSION
ARG SOCKLOG_OVERLAY_RELEASE
ARG S6_OVERLAY_PREINIT_VERSION
ARG S6_OVERLAY_VERSION

RUN apk --update --no-cache add curl tar
WORKDIR /dist/skalibs
RUN curl -sSL "https://skarnet.org/software/skalibs/skalibs-${SKALIBS_VERSION}.tar.gz" | tar xz --strip 1
WORKDIR /dist/execline
RUN curl -sSL "https://skarnet.org/software/execline/execline-${EXECLINE_VERSION}.tar.gz" | tar xz --strip 1
WORKDIR /dist/s6
RUN curl -sSL "https://skarnet.org/software/s6/s6-${S6_VERSION}.tar.gz" | tar xz --strip 1
WORKDIR /dist/s6-dns
RUN curl -sSL "https://skarnet.org/software/s6-dns/s6-dns-${S6_DNS_VERSION}.tar.gz" | tar xz --strip 1
WORKDIR /dist/s6-linux-utils
RUN curl -sSL "https://skarnet.org/software/s6-linux-utils/s6-linux-utils-${S6_LINUX_UTILS_VERSION}.tar.gz" | tar xz --strip 1
WORKDIR /dist/s6-networking
RUN curl -sSL "https://skarnet.org/software/s6-networking/s6-networking-${S6_NETWORKING_VERSION}.tar.gz" | tar xz --strip 1
WORKDIR /dist/s6-portable-utils
RUN curl -sSL "https://skarnet.org/software/s6-portable-utils/s6-portable-utils-${S6_PORTABLE_UTILS_VERSION}.tar.gz" | tar xz --strip 1
WORKDIR /dist/s6-rc
RUN curl -sSL "https://skarnet.org/software/s6-rc/s6-rc-${S6_RC_VERSION}.tar.gz" | tar xz --strip 1
WORKDIR /dist/justc-envdir
RUN curl -sSL "https://github.com/just-containers/justc-envdir/releases/download/v${JUSTC_ENVDIR_VERSION}${JUSTC_ENVDIR_RELEASE}/justc-envdir-${JUSTC_ENVDIR_VERSION}.tar.gz" | tar xz --strip 1
WORKDIR /dist/justc-installer
RUN curl -sSL "https://github.com/just-containers/justc-installer/releases/download/v${JUSTC_INSTALLER_VERSION}${JUSTC_INSTALLER_RELEASE}/justc-installer-${JUSTC_INSTALLER_VERSION}.tar.gz" | tar xz --strip 1
WORKDIR /dist/s6-overlay-preinit
RUN curl -sSL "https://github.com/just-containers/s6-overlay-preinit/releases/download/v${S6_OVERLAY_PREINIT_VERSION}/s6-overlay-preinit-${S6_OVERLAY_PREINIT_VERSION}.tar.gz" | tar xz --strip 1
WORKDIR /dist/s6-overlay
RUN curl -sSL "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-nobin.tar.gz" | tar -xz
WORKDIR /dist
RUN wget -q "https://github.com/just-containers/socklog-overlay/archive/v${SOCKLOG_OVERLAY_VERSION}${SOCKLOG_OVERLAY_RELEASE}.zip" -qO "socklog-overlay.zip" \
  && unzip socklog-overlay.zip \
  && mv socklog-overlay-${SOCKLOG_OVERLAY_VERSION}${SOCKLOG_OVERLAY_RELEASE} socklog-overlay \
  && rm -f socklog-overlay.zip

ARG TARGETPLATFORM
ARG ALPINE_VERSION
FROM --platform=${TARGETPLATFORM:-linux/amd64} alpine:${ALPINE_VERSION:-latest} as builder

ENV DIST_PATH="/dist"

RUN apk --update --no-cache add \
    bearssl-dev \
    build-base \
    curl \
    rsync \
    socklog \
    tar \
    tree

COPY --from=download /dist /tmp

WORKDIR /tmp/skalibs
RUN ./configure \
    --enable-shared \
    --enable-static \
    --enable-allstatic \
    --libdir=/usr/lib \
  && make install -j$(nproc) \
  && make DESTDIR=${DIST_PATH} install -j$(nproc) \
  && tree ${DIST_PATH}

WORKDIR /tmp/execline
RUN ./configure \
    --enable-shared \
    --enable-static \
    --enable-allstatic \
    --libdir=/usr/lib \
    --with-dynlib=/lib \
  && make install -j$(nproc) \
  && make DESTDIR=${DIST_PATH} install -j$(nproc) \
  && tree ${DIST_PATH}

WORKDIR /tmp/s6
COPY patchs/s6 .
RUN ./configure \
    --enable-shared \
    --enable-static \
    --enable-allstatic \
    --libdir=/usr/lib \
    --libexecdir=/lib/s6 \
    --with-dynlib=/lib \
  && make install -j$(nproc) \
  && make DESTDIR=${DIST_PATH} install -j$(nproc) \
  && mkdir -p "${DIST_PATH}/etc/init.d" \
  && cp s6.initd "${DIST_PATH}/etc/init.d/s6" \
  && tree ${DIST_PATH}

WORKDIR /tmp/s6-dns
RUN ./configure \
    --enable-shared \
    --enable-static \
    --enable-allstatic \
    --prefix=/usr \
    --libdir=/usr/lib \
    --libexecdir=/usr/lib/s6-dns \
    --with-dynlib=/lib \
  && make install -j$(nproc) \
  && make DESTDIR=${DIST_PATH} install -j$(nproc) \
  && tree ${DIST_PATH}

WORKDIR /tmp/s6-linux-utils
RUN ./configure \
    --enable-shared \
    --enable-static \
    --enable-allstatic \
    --prefix=/usr \
    --libdir=/usr/lib \
  && make install -j$(nproc) \
  && make DESTDIR=${DIST_PATH} install -j$(nproc) \
  && tree ${DIST_PATH}

WORKDIR /tmp/s6-networking
RUN ./configure \
    --enable-shared \
    --enable-static \
    --enable-allstatic \
    --prefix=/usr \
    --libdir=/usr/lib \
    --libexecdir=/usr/lib/s6-networking \
    --with-dynlib=/lib \
    --enable-ssl=bearssl \
  && make install -j$(nproc) \
  && make DESTDIR=${DIST_PATH} install -j$(nproc) \
  && tree ${DIST_PATH}

WORKDIR /tmp/s6-portable-utils
RUN ./configure \
    --enable-shared \
    --enable-static \
    --enable-allstatic \
    --prefix=/usr \
    --libdir=/usr/lib \
  && make install -j$(nproc) \
  && make DESTDIR=${DIST_PATH} install -j$(nproc) \
  && tree ${DIST_PATH}

WORKDIR /tmp/s6-rc
RUN ./configure \
    --enable-shared \
    --enable-static \
    --enable-allstatic \
    --libdir=/usr/lib \
    --libexecdir=/lib/s6-rc \
    --with-dynlib=/lib \
  && make install -j$(nproc) \
  && make DESTDIR=${DIST_PATH} install -j$(nproc) \
  && tree ${DIST_PATH}

WORKDIR /tmp/justc-envdir
RUN ./configure \
    --enable-shared \
    --enable-allstatic \
    --prefix=/usr \
  && make install -j$(nproc) \
  && make DESTDIR=${DIST_PATH} install -j$(nproc) \
  && tree ${DIST_PATH}

WORKDIR /tmp/justc-installer
RUN ./configure \
    --enable-shared \
    --enable-allstatic \
    --prefix=/usr \
  && make install -j$(nproc) \
  && make DESTDIR=${DIST_PATH} install -j$(nproc) \
  && tree ${DIST_PATH}

WORKDIR /tmp/s6-overlay-preinit
RUN ./configure \
    --enable-shared \
    --enable-allstatic \
    --with-sysdeps=/usr/lib/skalibs/sysdeps \
    -prefix=/ \
  && make install -j$(nproc) \
  && make DESTDIR=${DIST_PATH} install -j$(nproc) \
  && tree ${DIST_PATH}

WORKDIR /tmp/s6-overlay
RUN rsync -a ./ ${DIST_PATH}/

WORKDIR /tmp/socklog-overlay
RUN rsync -a ./overlay-rootfs/ ${DIST_PATH}/ \
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
ARG GOSU_VERSION
WORKDIR /tmp/gosu
RUN GOSU_ARCH=$(case ${TARGETPLATFORM:-linux/amd64} in \
    "linux/amd64")   echo "amd64"    ;; \
    "linux/arm/v6")  echo "armel"    ;; \
    "linux/arm/v7")  echo "armhf"    ;; \
    "linux/arm64")   echo "arm64"    ;; \
    "linux/386")     echo "i386"     ;; \
    "linux/ppc64le") echo "ppc64el"  ;; \
    "linux/s390x")   echo "s390x"    ;; \
    *)               echo ""         ;; esac) \
  && echo "GOSU_ARCH=$GOSU_ARCH" \
  && mkdir -p ${DIST_PATH}/usr/local/bin/ \
  && curl -sSL "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-${GOSU_ARCH}" -o "${DIST_PATH}/usr/local/bin/gosu" \
  && chmod +x ${DIST_PATH}/usr/local/bin/gosu

WORKDIR /dist
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT
ARG S6_OVERLAY_VERSION
RUN mkdir -p /out \
  && tar -zcvf /out/s6-overlay_${S6_OVERLAY_VERSION}_${TARGETOS}_${TARGETARCH}${TARGETVARIANT}.tar.gz . \
  && ls -al /out/

FROM scratch AS artifacts
COPY --from=builder /out/*.tar.gz /

ARG TARGETPLATFORM
ARG ALPINE_VERSION
FROM --platform=${TARGETPLATFORM:-linux/amd64} alpine:${ALPINE_VERSION:-latest}
LABEL maintainer="CrazyMax"

RUN apk --update --no-cache add \
    bearssl \
    socklog \
  && rm -rf /var/cache/apk/* /tmp/*

COPY --from=builder /dist /

ENTRYPOINT ["/init"]
