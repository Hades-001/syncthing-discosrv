FROM --platform=${TARGETPLATFORM} golang:1.20-alpine as builder
ENV CGO_ENABLED=0
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

FROM --platform=${TARGETPLATFORM} alpine:3.17
COPY --from=builder /root/syncthing/stdiscosrv /bin/stdiscosrv

ENV DEBUG                   false
ENV SERVER_PORT             8443
ENV REPLICATION_PORT        19200

RUN apk add --no-cache ca-certificates su-exec tzdata

VOLUME ["/var/stdiscosrv"]

WORKDIR /var/stdiscosrv

ENV TZ=Asia/Shanghai
RUN cp /usr/share/zoneinfo/${TZ} /etc/localtime && \
	echo "${TZ}" > /etc/timezone

ENV PUID=1000 PGID=1000 HOME=/var/stdiscosrv

COPY docker-entrypoint.sh /bin/entrypoint.sh
RUN chmod a+x /bin/entrypoint.sh
ENTRYPOINT ["/bin/entrypoint.sh"]

EXPOSE ${SERVER_PORT} ${REPLICATION_PORT}

CMD /bin/stdiscosrv \
    -debug="${DEBUG}" \
    -listen=":${SERVER_PORT}" \
    -replication-listen=":${REPLICATION_PORT}" \
