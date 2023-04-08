ARG ALPINE_VERSION
FROM alpine:${ALPINE_VERSION}
LABEL maintainer="Abhinav A V <abhai2k@gmail.com>"

ARG S6_OVERLAY_VERSION

ENV PUID=1000 \
    PGID=1000 \ 
    UNAME="tundra" \
    GNAME="tundra" \
    TZ="UTC" \
    S6_GLOBAL_PATH="/command:/usr/bin:/bin:/usr/sbin" \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME=5000 \
    GLIBC_VERSION=2.34-r0

RUN set -eux; \ 
    apk upgrade --update --no-cache; \
    apk add --no-cache tzdata wget libintl gettext; \
    cp /usr/bin/envsubst /usr/local/bin/envsubst; \
    wget https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz \
         https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz \
         https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-noarch.tar.xz \
         https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/syslogd-overlay-noarch.tar.xz -P /tmp/; \
    tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz; \
    tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz; \
    tar -C / -Jxpf /tmp/s6-overlay-symlinks-noarch.tar.xz; \
    tar -C / -Jxpf /tmp/syslogd-overlay-noarch.tar.xz; \
    addgroup -g ${PGID} ${GNAME}; \
    adduser -DH -s /sbin/nologin -u ${PUID} ${UNAME} -G ${GNAME}; \
    wget https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -O /etc/apk/keys/sgerrand.rsa.pub; \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk -O glibc.apk; \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk -O glibc-bin.apk; \
    apk add --force-overwrite glibc-bin.apk glibc.apk;\
    /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib;\
    echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf;\
    rm -rf glibc.apk glibc-bin.apk /var/cache/apk/*; \
    rm -rf /tmp/*; \
    apk del wget gettext -r;

ADD /rootfs /

USER ${UNAME}

# Init
ENTRYPOINT [ "/init" ]


