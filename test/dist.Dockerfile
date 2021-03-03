ARG DIST_IMAGE

FROM ${DIST_IMAGE:-test-alpine-s6-dist} AS s6-dist
FROM alpine
RUN apk add tree
COPY --from=s6-dist / /dist
RUN tree /dist
