# syntax=docker/dockerfile:1

ARG BASE_IMAGE
FROM ${BASE_IMAGE:-alpine-s6:local} AS alpine-s6

FROM ubuntu:24.04
COPY --link --from=alpine-s6 / /
RUN apt-get update && apt-get install -y nginx
COPY rootfs /
ENTRYPOINT ["/init"]
