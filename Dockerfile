FROM debian:bullseye-slim

ENV LANG="C.UTF-8" \
    DEBIAN_FRONTEND="noninteractive" \
    CURL_CA_BUNDLE="/etc/ssl/certs/ca-certificates.crt" \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0 \
    S6_CMD_WAIT_FOR_SERVICES=1


SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG S6_OVERLAY_VERSION \
    FLICD_VERSION \
    TARGETARCH

WORKDIR /usr/src

RUN set -x; \
    apt-get update && apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        curl \
        tzdata \
        xz-utils; \
    mkdir -p /usr/share/man/man1; \
    \
    if [ "${TARGETARCH}" = "arm64" ]; then \
        export BUILD_ARCH="aarch64"; \
    elif [ "${TARGETARCH}" = "amd64" ]; then \
        export BUILD_ARCH="x86_64"; \
    else \
        export BUILD_ARCH="${TARGETARCH}"; \
    fi \
    ; \
    curl -L -f -s "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${BUILD_ARCH}.tar.xz" \
        | tar Jxvf - -C / ; \
    curl -L -f -s "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz" \
        | tar Jxvf - -C / \
    ; \
    mkdir -p /usr/src/flicd; \
    curl -L -f -s "https://github.com/50ButtonsEach/fliclib-linux-hci/archive/refs/tags/${FLICD_VERSION}.tar.gz" \
        | tar zxvf - -C /usr/src/flicd --strip-components 1 \
    ; \
    cp "/usr/src/flicd/bin/${BUILD_ARCH}/flicd" /usr/bin/flicd; \
    chmod +x /usr/bin/flicd; \
    \
    rm -rf /var/lib/apt/lists/*; \
    rm -rf /usr/src/*

VOLUME ["/data"]
EXPOSE 5551

CMD ["/usr/bin/flicd", "-f", "/data/flicd.db", "-s", "0.0.0.0", "-p", "5551", "-h", "hci0", "-w"]

WORKDIR /
ENTRYPOINT ["/init"]
