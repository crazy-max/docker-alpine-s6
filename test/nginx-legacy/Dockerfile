# syntax=docker/dockerfile:1
ARG BASE_IMAGE
FROM ${BASE_IMAGE:-alpine-s6:local}
RUN apk add --no-cache nginx
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
CMD ["/usr/sbin/nginx"]
