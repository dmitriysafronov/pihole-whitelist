ARG PIHOLE_VERSION=2024.01.0

############################################################

FROM curlimages/curl AS sources

ARG WHITELIST_VERSION=v2.0.1

RUN set -x \
		&& rm -rf /tmp/* \
		&& cd /tmp \
		&& curl -SL --connect-timeout 8 --max-time 120 --retry 128 --retry-delay 5 "https://github.com/anudeepND/whitelist/archive/refs/tags/${WHITELIST_VERSION}.tar.gz" -o whitelist.tar.gz \
		&& mkdir -p /tmp/whitelist \
		&& tar -xf whitelist.tar.gz -C /tmp/whitelist --strip-components=1 \
		&& rm -rf /tmp/whitelist.tar.gz

############################################################

FROM ghcr.io/pi-hole/pihole:${PIHOLE_VERSION} AS runtime

RUN set -ex && \
    apt-get update -y && apt-get install --no-install-recommends --no-install-suggests -y \
        git \
        python3 \
    && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/*

COPY ./cron.daily /etc/cron.daily/whitelist

COPY --from=sources /tmp/whitelist/ /opt/whitelist/

RUN chmod a+x /opt/whitelist/scripts/whitelist.py /etc/cron.daily/whitelist
