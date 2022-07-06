# syntax=docker/dockerfile:1

ARG ALPINE_VERSION="latest"
ARG XX_VERSION="1.1.1"

ARG S6_OVERLAY_VERSION="3.1.1.2"
ARG S6_OVERLAY_REF="94ba8e04c2227720b5941bf6a84920cc464f1b12"

# https://bearssl.org/gitweb/?p=BearSSL;a=commit;h=79b1a9996c094ff593ae50bc4edc1f349f39dd6d
ARG BEARSSL_VERSION="0.6"
ARG BEARSSL_REF="79b1a9996c094ff593ae50bc4edc1f349f39dd6d"

ARG SKALIBS_VERSION="2.12.0.1"
ARG EXECLINE_VERSION="2.9.0.1"

ARG S6_VERSION="2.11.1.2"
ARG S6_RC_VERSION="0.5.3.2"
ARG S6_LINUX_INIT_VERSION="1.0.8.0"
ARG S6_PORTABLE_UTILS_VERSION="2.2.5.0"
ARG S6_LINUX_UTILS_VERSION="2.6.0.0"
ARG S6_DNS_VERSION="2.3.5.4"
ARG S6_NETWORKING_VERSION="2.5.1.1"
ARG S6_OVERLAY_HELPERS_VERSION="0.0.1.0"

FROM --platform=$BUILDPLATFORM tonistiigi/xx:${XX_VERSION} AS xx
FROM --platform=$BUILDPLATFORM alpine:${ALPINE_VERSION} AS alpine

FROM alpine AS src
RUN apk --update --no-cache add curl git tar
WORKDIR /src

FROM src AS src-s6overlay
ARG S6_OVERLAY_VERSION
ARG S6_OVERLAY_REF
RUN <<EOT
git clone https://github.com/just-containers/s6-overlay.git .
git reset --hard $S6_OVERLAY_REF
EOT

FROM src AS src-bearssl
ARG BEARSSL_VERSION
ARG BEARSSL_REF
RUN <<EOT
git clone https://www.bearssl.org/git/BearSSL .
git reset --hard $BEARSSL_REF
EOT

FROM src AS src-skalibs
ARG SKALIBS_VERSION
RUN curl -sSL "https://skarnet.org/software/skalibs/skalibs-${SKALIBS_VERSION}.tar.gz" | tar xz --strip 1

FROM src AS src-execline
ARG EXECLINE_VERSION
RUN curl -sSL "https://skarnet.org/software/execline/execline-${EXECLINE_VERSION}.tar.gz" | tar xz --strip 1

FROM src AS src-s6
ARG S6_VERSION
RUN curl -sSL "https://skarnet.org/software/s6/s6-${S6_VERSION}.tar.gz" | tar xz --strip 1

FROM src AS src-s6rc
ARG S6_RC_VERSION
RUN curl -sSL "https://skarnet.org/software/s6-rc/s6-rc-${S6_RC_VERSION}.tar.gz" | tar xz --strip 1

FROM src AS src-s6linuxinit
ARG S6_LINUX_INIT_VERSION
RUN curl -sSL "https://skarnet.org/software/s6-linux-init/s6-linux-init-${S6_LINUX_INIT_VERSION}.tar.gz" | tar xz --strip 1

FROM src AS src-s6portableutils
ARG S6_PORTABLE_UTILS_VERSION
RUN curl -sSL "https://skarnet.org/software/s6-portable-utils/s6-portable-utils-${S6_PORTABLE_UTILS_VERSION}.tar.gz" | tar xz --strip 1

FROM src AS src-s6linuxutils
ARG S6_LINUX_UTILS_VERSION
RUN curl -sSL "https://skarnet.org/software/s6-linux-utils/s6-linux-utils-${S6_LINUX_UTILS_VERSION}.tar.gz" | tar xz --strip 1

FROM src AS src-s6dns
ARG S6_DNS_VERSION
RUN curl -sSL "https://skarnet.org/software/s6-dns/s6-dns-${S6_DNS_VERSION}.tar.gz" | tar xz --strip 1

FROM src AS src-s6networking
ARG S6_NETWORKING_VERSION
RUN curl -sSL "https://skarnet.org/software/s6-networking/s6-networking-${S6_NETWORKING_VERSION}.tar.gz" | tar xz --strip 1

FROM src AS src-s6overlayhelpers
ARG S6_OVERLAY_HELPERS_VERSION
RUN <<EOT
git clone https://github.com/just-containers/s6-overlay-helpers.git .
git reset --hard v$S6_OVERLAY_HELPERS_VERSION
EOT

FROM alpine AS base
RUN apk --update --no-cache add bash clang curl git llvm make tar tree xz
COPY --from=xx / /

FROM base AS build
ARG TARGETPLATFORM
RUN xx-apk add musl-dev gcc g++ linux-headers
ENV XX_CC_PREFER_LINKER=ld

WORKDIR /usr/local/src/skalibs
COPY --from=src-skalibs /src .
RUN <<EOT
set -ex
DESTDIR=/out ./configure --host=$(xx-clang --print-target-triple) --enable-slashpackage --enable-static-libc --disable-shared --with-default-path=/command:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin --with-sysdep-devurandom=yes
make -j$(nproc)
make DESTDIR=/out -L install update global-links -j$(nproc)
EOT

WORKDIR /usr/local/src/execline
COPY --from=src-execline /src .
RUN <<EOT
set -ex
DESTDIR=/out ./configure --host=$(xx-clang --print-target-triple) --enable-slashpackage --enable-static-libc --disable-shared --disable-pedantic-posix
make -j$(nproc)
make DESTDIR=/out -L install update global-links -j$(nproc)
EOT

WORKDIR /usr/local/src/s6
COPY --from=src-s6 /src .
RUN <<EOT
set -ex
DESTDIR=/out ./configure --host=$(xx-clang --print-target-triple) --enable-slashpackage --enable-static-libc --disable-shared
make -j$(nproc)
make DESTDIR=/out -L install update global-links -j$(nproc)
EOT

WORKDIR /usr/local/src/s6rc
COPY --from=src-s6rc /src .
RUN <<EOT
set -ex
DESTDIR=/out ./configure --host=$(xx-clang --print-target-triple) --enable-slashpackage --enable-static-libc --disable-shared
make -j$(nproc)
make DESTDIR=/out -L install update global-links -j$(nproc)
EOT

WORKDIR /usr/local/src/s6linuxinit
COPY --from=src-s6linuxinit /src .
RUN <<EOT
set -ex
DESTDIR=/out ./configure --host=$(xx-clang --print-target-triple) --enable-slashpackage --enable-static-libc --disable-shared
make -j$(nproc)
make DESTDIR=/out -L install update global-links -j$(nproc)
EOT

WORKDIR /usr/local/src/s6portableutils
COPY --from=src-s6portableutils /src .
RUN <<EOT
set -ex
DESTDIR=/out ./configure --host=$(xx-clang --print-target-triple) --enable-slashpackage --enable-static-libc --disable-shared
make -j$(nproc)
make DESTDIR=/out -L install update global-links -j$(nproc)
EOT

WORKDIR /usr/local/src/s6linuxutils
COPY --from=src-s6linuxutils /src .
RUN <<EOT
set -ex
DESTDIR=/out ./configure --host=$(xx-clang --print-target-triple) --enable-slashpackage --enable-static-libc --disable-shared
make -j$(nproc)
make DESTDIR=/out -L install update global-links -j$(nproc)
EOT

WORKDIR /usr/local/src/s6dns
COPY --from=src-s6dns /src .
RUN <<EOT
set -ex
DESTDIR=/out ./configure --host=$(xx-clang --print-target-triple) --enable-slashpackage --enable-static-libc --disable-shared
make -j$(nproc)
make DESTDIR=/out -L install update global-links -j$(nproc)
EOT

# https://bearssl.org/gitweb/?p=BearSSL;a=blob;f=conf/Unix.mk;h=02f2b2be8ee48d1645b478fc02e53acede3c5102;hb=refs/heads/master
WORKDIR /usr/local/src/bearssl
COPY --from=src-bearssl /src .
RUN <<EOT
set -ex
mkdir -p /out/include
cp -a ./inc/*.h /out/include/
make lib CC=xx-clang AR=$(xx-info)-ar LDDLL=xx-clang LD=xx-clang
mkdir -p /out/lib
cp -f build/libbearssl.a /out/lib/
EOT

WORKDIR /usr/local/src/s6networking
COPY --from=src-s6networking /src .
RUN <<EOT
set -ex
DESTDIR=/out ./configure --host=$(xx-clang --print-target-triple) --enable-slashpackage --enable-static-libc --disable-shared --enable-ssl=bearssl --with-ssl-path=/out
make -j$(nproc)
make DESTDIR=/out -L install update global-links -j$(nproc)
EOT

WORKDIR /usr/local/src/s6overlayhelpers
COPY --from=src-s6overlayhelpers /src .
RUN <<EOT
set -ex
DESTDIR=/out ./configure --host=$(xx-clang --print-target-triple) --enable-slashpackage --enable-static-libc --disable-shared
make
make DESTDIR=/out -L install update global-links
EOT

WORKDIR /usr/local/src/s6overlay
ARG S6_OVERLAY_VERSION
COPY --from=src-s6overlay /src .
RUN <<EOT
set -ex

# cleanup
rm -rf /out/package/*/*/include /out/package/*/*/library

# s6-overlay
find ./layout/rootfs-overlay -type f -name .empty -print | xargs rm -f --
find ./layout/rootfs-overlay -name '*@VERSION@*' -print | while read name; do
  mv -f "$name" $(echo "$name" | sed -e "s/@VERSION@/$S6_OVERLAY_VERSION/")
done
find ./layout/rootfs-overlay -type f -size +0c -print | xargs sed -i -e "s|@SHEBANGDIR@|/command|g; s/@VERSION@/$S6_OVERLAY_VERSION/g;" --
(cd /out/package/admin/ ; ln -s s6-overlay-$S6_OVERLAY_VERSION s6-overlay)
cp -rf ./layout/rootfs-overlay/* /out/

# s6-syslogd-overlay
find ./layout/syslogd-overlay -type f -name .empty -print | xargs rm -f --
find ./layout/syslogd-overlay -name '*@VERSION@*' -print | while read name; do
  mv -f "$name" $(echo "$name" | sed -e "s/@VERSION@/$S6_OVERLAY_VERSION/")
done
find ./layout/syslogd-overlay -type f -size +0c -print | xargs sed -i -e "s|@SHEBANGDIR@|/command|g; s/@VERSION@/$S6_OVERLAY_VERSION/g;" --
cp -rf ./layout/syslogd-overlay/* /out/

# symlinks
mkdir -p /out/usr/bin
for i in $(ls -1 /out/command); do
  ln -s "../../command/$i" /out/usr/bin/
done
EOT

FROM base AS tgz
COPY --from=build /out /build
ARG S6_OVERLAY_VERSION
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT
WORKDIR /build
RUN mkdir -p /artifact && tar -zcvf /artifact/s6-overlay_${S6_OVERLAY_VERSION}_${TARGETOS}_${TARGETARCH}${TARGETVARIANT}.tar.gz .

FROM scratch AS artifact
COPY --from=tgz /artifact /

FROM scratch AS dist
COPY --from=build /out /

FROM alpine:${ALPINE_VERSION}
COPY --from=build /out /
RUN s6-rmrf /tmp/* && s6-ps
ENTRYPOINT ["/init"]
