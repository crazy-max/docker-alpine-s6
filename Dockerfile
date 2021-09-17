ARG ALPINE_VERSION=latest
ARG XX_VERSION=1.0.0-rc.2

ARG SKALIBS_VERSION=2.10.0.3
ARG EXECLINE_VERSION=2.7.0.1
ARG S6_VERSION=2.10.0.3
ARG S6_DNS_VERSION=2.3.5.1
ARG S6_LINUX_UTILS_VERSION=2.5.1.5
ARG S6_NETWORKING_VERSION=2.4.1.1
ARG S6_PORTABLE_UTILS_VERSION=2.2.3.2
ARG S6_RC_VERSION=0.5.2.2
ARG JUSTC_ENVDIR_VERSION=1.0.1
ARG JUSTC_ENVDIR_RELEASE=-1
ARG JUSTC_INSTALLER_VERSION=1.0.1
ARG JUSTC_INSTALLER_RELEASE=-2
ARG SOCKLOG_VERSION=2.2.3
ARG SOCKLOG_RELEASE
ARG SOCKLOG_OVERLAY_VERSION=3.1.2
ARG SOCKLOG_OVERLAY_RELEASE=-0
ARG S6_OVERLAY_PREINIT_VERSION=1.0.5
ARG S6_OVERLAY_VERSION=2.2.0.3

ARG DIST_PATH=/dist
ARG OUT_PATH=/out

FROM --platform=$BUILDPLATFORM alpine:${ALPINE_VERSION} AS download
RUN apk --update --no-cache add curl tar
WORKDIR /dl

FROM download AS dl-skalibs
ARG SKALIBS_VERSION
RUN curl -sSL "https://skarnet.org/software/skalibs/skalibs-${SKALIBS_VERSION}.tar.gz" | tar xz --strip 1

FROM download AS dl-execline
ARG EXECLINE_VERSION
RUN curl -sSL "https://skarnet.org/software/execline/execline-${EXECLINE_VERSION}.tar.gz" | tar xz --strip 1

FROM download AS dl-s6
ARG S6_VERSION
RUN curl -sSL "https://skarnet.org/software/s6/s6-${S6_VERSION}.tar.gz" | tar xz --strip 1

FROM download AS dl-s6dns
ARG S6_DNS_VERSION
RUN curl -sSL "https://skarnet.org/software/s6-dns/s6-dns-${S6_DNS_VERSION}.tar.gz" | tar xz --strip 1

FROM download AS dl-s6linuxutils
ARG S6_LINUX_UTILS_VERSION
RUN curl -sSL "https://skarnet.org/software/s6-linux-utils/s6-linux-utils-${S6_LINUX_UTILS_VERSION}.tar.gz" | tar xz --strip 1

FROM download AS dl-s6networking
ARG S6_NETWORKING_VERSION
RUN curl -sSL "https://skarnet.org/software/s6-networking/s6-networking-${S6_NETWORKING_VERSION}.tar.gz" | tar xz --strip 1

FROM download AS dl-s6portableutils
ARG S6_PORTABLE_UTILS_VERSION
RUN curl -sSL "https://skarnet.org/software/s6-portable-utils/s6-portable-utils-${S6_PORTABLE_UTILS_VERSION}.tar.gz" | tar xz --strip 1

FROM download AS dl-s6rc
ARG S6_RC_VERSION
RUN curl -sSL "https://skarnet.org/software/s6-rc/s6-rc-${S6_RC_VERSION}.tar.gz" | tar xz --strip 1

FROM download AS dl-justcenvdir
ARG JUSTC_ENVDIR_VERSION
ARG JUSTC_ENVDIR_RELEASE
RUN curl -sSL "https://github.com/just-containers/justc-envdir/releases/download/v${JUSTC_ENVDIR_VERSION}${JUSTC_ENVDIR_RELEASE}/justc-envdir-${JUSTC_ENVDIR_VERSION}.tar.gz" | tar xz --strip 1

FROM download AS dl-justcinstaller
ARG JUSTC_INSTALLER_VERSION
ARG JUSTC_INSTALLER_RELEASE
RUN curl -sSL "https://github.com/just-containers/justc-installer/releases/download/v${JUSTC_INSTALLER_VERSION}${JUSTC_INSTALLER_RELEASE}/justc-installer-${JUSTC_INSTALLER_VERSION}.tar.gz" | tar xz --strip 1

FROM download AS dl-socklog
ARG SOCKLOG_VERSION
ARG SOCKLOG_RELEASE
RUN curl -sSL "https://github.com/just-containers/socklog/releases/download/v${SOCKLOG_VERSION}${SOCKLOG_RELEASE}/socklog-${SOCKLOG_VERSION}.tar.gz" | tar xz --strip 1

FROM download AS dl-s6overlaypreinit
ARG S6_OVERLAY_PREINIT_VERSION
RUN curl -sSL "https://github.com/just-containers/s6-overlay-preinit/releases/download/v${S6_OVERLAY_PREINIT_VERSION}/s6-overlay-preinit-${S6_OVERLAY_PREINIT_VERSION}.tar.gz" | tar xz --strip 1

FROM download AS dl-s6overlay
ARG S6_OVERLAY_VERSION
RUN curl -sSL "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-nobin.tar.gz" | tar -xz

FROM download AS dl-socklogoverlay
ARG SOCKLOG_OVERLAY_VERSION
ARG SOCKLOG_OVERLAY_RELEASE
RUN curl -sSL "https://github.com/just-containers/socklog-overlay/archive/v${SOCKLOG_OVERLAY_VERSION}${SOCKLOG_OVERLAY_RELEASE}.tar.gz" | tar xz --strip 1

FROM --platform=$BUILDPLATFORM tonistiigi/xx:${XX_VERSION} AS xx
FROM --platform=$BUILDPLATFORM alpine:${ALPINE_VERSION} AS builder
COPY --from=xx / /
RUN apk --update --no-cache add \
    clang \
    curl \
    file \
    findutils \
    make \
    pkgconf \
    tar \
    tree

ARG TARGETPLATFORM
ARG DIST_PATH
ENV XX_CC_PREFER_LINKER=ld
RUN xx-apk --update --no-cache add \
    bearssl-dev \
    g++ \
    gettext-dev \
    libc-dev \
    linux-headers

WORKDIR /tmp/skalibs
COPY --from=dl-skalibs /dl .
COPY patchs/skalibs .
RUN sed -i "s|@@VERSION@@|${SKALIBS_VERSION}|" -i *.pc \
  && ./configure \
    --host=$(xx-clang --print-target-triple) \
    --with-sysdep-devurandom=yes \
    --enable-shared \
    --enable-static \
    --libdir=/usr/lib \
  && make install -j$(nproc) \
  && make DESTDIR=${DIST_PATH} install -j$(nproc) \
  && mkdir -p "${DIST_PATH}/usr/lib/pkgconfig" \
  && cp -f skalibs.pc "${DIST_PATH}/usr/lib/pkgconfig/skalibs.pc" \
  && tree ${DIST_PATH}

WORKDIR /tmp/execline
COPY --from=dl-execline /dl .
RUN ./configure \
    --host=$(xx-clang --print-target-triple) \
    --enable-shared \
    --enable-static \
    --disable-allstatic \
    --libdir=/usr/lib \
    --with-dynlib=/lib \
  && make install -j$(nproc) \
  && make DESTDIR=${DIST_PATH} install -j$(nproc) \
  && tree ${DIST_PATH}

WORKDIR /tmp/s6
COPY --from=dl-s6 /dl .
COPY patchs/s6 .
RUN ./configure \
    --host=$(xx-clang --print-target-triple) \
    --enable-shared \
    --enable-static \
    --disable-allstatic \
    --libdir=/usr/lib \
    --libexecdir=/lib/s6 \
    --with-dynlib=/lib \
  && make install -j$(nproc) \
  && make DESTDIR=${DIST_PATH} install -j$(nproc) \
  && mkdir -p "${DIST_PATH}/lib/s6" \
  && cp s6-svscanboot "${DIST_PATH}/lib/s6/s6-svscanboot" \
  && mkdir -p "${DIST_PATH}/etc/init.d" \
  && cp s6.initd "${DIST_PATH}/etc/init.d/s6" \
  && tree ${DIST_PATH}

WORKDIR /tmp/s6dns
COPY --from=dl-s6dns /dl .
RUN ./configure \
    --host=$(xx-clang --print-target-triple) \
    --enable-shared \
    --enable-static \
    --disable-allstatic \
    --prefix=/usr \
    --libdir=/usr/lib \
    --libexecdir=/usr/lib/s6-dns \
    --with-dynlib=/lib \
  && make install -j$(nproc) \
  && make DESTDIR=${DIST_PATH} install -j$(nproc) \
  && tree ${DIST_PATH}

WORKDIR /tmp/s6-linux-utils
COPY --from=dl-s6linuxutils /dl .
RUN ./configure \
    --host=$(xx-clang --print-target-triple) \
    --enable-shared \
    --enable-static \
    --disable-allstatic \
    --prefix=/usr \
    --libdir=/usr/lib \
  && make install -j$(nproc) \
  && make DESTDIR=${DIST_PATH} install -j$(nproc) \
  && tree ${DIST_PATH}

WORKDIR /tmp/s6-networking
COPY --from=dl-s6networking /dl .
RUN ./configure \
    --host=$(xx-clang --print-target-triple) \
    --enable-shared \
    --enable-static \
    --disable-allstatic \
    --prefix=/usr \
    --libdir=/usr/lib \
    --libexecdir=/usr/lib/s6-networking \
    --with-dynlib=/lib \
    --enable-ssl=bearssl \
  && make install -j$(nproc) \
  && make DESTDIR=${DIST_PATH} install -j$(nproc) \
  && tree ${DIST_PATH}

WORKDIR /tmp/s6-portable-utils
COPY --from=dl-s6portableutils /dl .
RUN ./configure \
    --host=$(xx-clang --print-target-triple) \
    --enable-shared \
    --enable-static \
    --disable-allstatic \
    --prefix=/usr \
    --libdir=/usr/lib \
  && make install -j$(nproc) \
  && make DESTDIR=${DIST_PATH} install -j$(nproc) \
  && tree ${DIST_PATH}

WORKDIR /tmp/s6-rc
COPY --from=dl-s6rc /dl .
RUN ./configure \
    --host=$(xx-clang --print-target-triple) \
    --enable-shared \
    --enable-static \
    --disable-allstatic \
    --libdir=/usr/lib \
    --libexecdir=/lib/s6-rc \
    --with-dynlib=/lib \
  && make install -j$(nproc) \
  && make DESTDIR=${DIST_PATH} install -j$(nproc) \
  && tree ${DIST_PATH}

WORKDIR /tmp/justc-envdir
COPY --from=dl-justcenvdir /dl .
RUN ./configure \
    --host=$(xx-clang --print-target-triple) \
    --enable-shared \
    --disable-allstatic \
    --prefix=/usr \
  && make install -j$(nproc) \
  && make DESTDIR=${DIST_PATH} install -j$(nproc) \
  && tree ${DIST_PATH}

WORKDIR /tmp/justc-installer
COPY --from=dl-justcinstaller /dl .
RUN ./configure \
    --host=$(xx-clang --print-target-triple) \
    --enable-shared \
    --disable-allstatic \
    --prefix=/usr \
  && make install -j$(nproc) \
  && make DESTDIR=${DIST_PATH} install -j$(nproc) \
  && tree ${DIST_PATH}

WORKDIR /tmp/socklog
COPY --from=dl-socklog /dl .
RUN ./configure \
    --host=$(xx-clang --print-target-triple) \
    --enable-shared \
    --disable-allstatic \
    --prefix=/usr \
  && make install -j$(nproc) \
  && make DESTDIR=${DIST_PATH} install -j$(nproc) \
  && tree ${DIST_PATH}

WORKDIR /tmp/s6-overlay-preinit
COPY --from=dl-s6overlaypreinit /dl .
RUN ./configure \
    --host=$(xx-clang --print-target-triple) \
    --enable-shared \
    --disable-allstatic \
    --with-sysdeps=/usr/lib/skalibs/sysdeps \
    --prefix=/ \
  && make install -j$(nproc) \
  && make DESTDIR=${DIST_PATH} install -j$(nproc) \
  && tree ${DIST_PATH}

WORKDIR /tmp/s6-overlay
COPY --from=dl-s6overlay /dl .
RUN cp -Rf * ${DIST_PATH}/

WORKDIR /tmp/socklog-overlay
COPY --from=dl-socklogoverlay /dl .
RUN find "overlay-rootfs"/ -type f \
    -exec sh -c 'test "$(head -c 16 "$1")" = "#!/bin/execlineb"' sh {} \; \
    -exec chmod a+x {} \; \
  && cp -Rf overlay-rootfs/* ${DIST_PATH}/ \
  && tree ${DIST_PATH}

WORKDIR ${DIST_PATH}
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT
ARG S6_OVERLAY_VERSION
ARG OUT_PATH
RUN mkdir -p ${OUT_PATH} \
  && tar -zcvf ${OUT_PATH}/s6-overlay_${S6_OVERLAY_VERSION}_${TARGETOS}_${TARGETARCH}${TARGETVARIANT}.tar.gz . \
  && ls -al ${OUT_PATH}

FROM scratch AS artifacts
ARG OUT_PATH
COPY --from=builder ${OUT_PATH}/*.tar.gz /

FROM scratch AS dist
ARG DIST_PATH
COPY --from=builder ${DIST_PATH} /

FROM alpine:${ALPINE_VERSION}
ARG DIST_PATH
COPY --from=builder ${DIST_PATH} /
RUN apk --update --no-cache add \
    bearssl \
  && s6-rmrf /var/cache/apk/* /tmp/*
ENTRYPOINT ["/init"]
