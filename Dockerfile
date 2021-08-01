########################################
#              Settings                #
########################################

ENV DEBUG                   false
ENV SERVER_PORT             8443
ENV REPLICATION_PORT        19200

########################################
#               Build                  #
########################################

FROM --platform=${TARGETPLATFORM} golang:alpine as builder
ARG TAG

WORKDIR /root

RUN set -ex && \
    apk add --no-cache git && \
    git clone https://github.com/syncthing/syncthing syncthing && \
    cd ./syncthing && \
    git fetch --all --tags && \
    git checkout tags/${TAG} && \
    rm -f stdiscosrv && \
    go run build.go -no-upgrade build stdiscosrv

FROM --platform=${TARGETPLATFORM} alpine:3.14.0

COPY --from=builder /root/syncthing/stdiscosrv /bin/stdiscosrv

RUN apk add --no-cache ca-certificates su-exec

VOLUME ["/var/stdiscosrv"]

WORKDIR /var/stdiscosrv

ENV PUID=1000 PGID=1000 HOME=/var/stdiscosrv

COPY docker-entrypoint.sh /bin/entrypoint.sh
RUN chmod a+x /bin/entrypoint.sh
ENTRYPOINT ["/bin/entrypoint.sh"]

EXPOSE ${SERVER_PORT} ${REPLICATION_PORT}

CMD /bin/stdiscosrv \
    -debug="${DEBUG}" \
    -listen=":${SERVER_PORT}" \
    -replication-listen=":${REPLICATION_PORT}" \
