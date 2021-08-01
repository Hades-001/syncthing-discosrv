FROM alpine:3.14.0

########################################
#              Settings                #
########################################

ENV DEBUG                   false
ENV SERVER_PORT             8443
ENV REPLICATION_PORT        19200

########################################
#               Build                  #
########################################

ARG STDISCOSRV_VER=v1.8.0
ARG PLATFORM=amd64
ARG STDISCOSRV_URL=https://github.com/syncthing/discosrv/releases/download/${STDISCOSRV_VER}/stdiscosrv-linux-${PLATFORM}-${STDISCOSRV_VER}.tar.gz

RUN set -ex && \
    apk add --no-cache ca-certificates su-exec tar wget && \
    mkdir -p /var/stdiscosrv && \
    cd /tmp && \
    wget ${STDISCOSRV_URL} && \
    tar xzvf stdiscosrv-linux-${PLATFORM}-${STDISCOSRV_VER}.tar.gz && \
    mv stdiscosrv-linux-${PLATFORM}-${STDISCOSRV_VER}/stdiscosrv /usr/bin/stdiscosrv && \
    rm -rf /tmp/*

VOLUME ["/var/stdiscosrv"]

WORKDIR /var/stdiscosrv

ENV PUID=1000 PGID=1000 HOME=/var/stdiscosrv

COPY docker-entrypoint.sh /bin/entrypoint.sh
RUN chmod a+x /bin/entrypoint.sh
ENTRYPOINT ["/bin/entrypoint.sh"]

EXPOSE ${SERVER_PORT} ${REPLICATION_PORT}

CMD /usr/bin/stdiscosrv \
    -debug="${DEBUG}" \
    -listen=":${SERVER_PORT}" \
    -replication-listen=":${REPLICATION_PORT}" \