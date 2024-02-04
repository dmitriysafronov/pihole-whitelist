FROM ubuntu AS sources

ARG DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN set -x \
		&& apt-get update && apt-get install -y \
			curl \
		&& rm -rf /var/lib/apt/lists/*

ARG WHITELIST_VERSION=v2.0.1

RUN set -x \
		&& cd /tmp \
		&& curl -SL --connect-timeout 8 --max-time 120 --retry 128 --retry-delay 5 "https://github.com/anudeepND/whitelist/archive/refs/tags/${WHITELIST_VERSION}.tar.gz" -o whitelist.tar.gz \
		&& mkdir -p /opt/whitelist \
		&& tar -xf whitelist.tar.gz -C /opt/whitelist --strip-components=1 \
		&& rm -rf /tmp/*

############################################################

ARG PIHOLE_VERSION=2024.01.0

FROM ghcr.io/pi-hole/pihole:${PIHOLE_VERSION}

RUN set -ex && \
    apt-get update -y && apt-get install --no-install-recommends --no-install-suggests -y \
        git \
        python3 \
    && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/*

COPY ./cron.daily /etc/cron.daily/whitelist

COPY --from=sources /opt/whitelist/ /opt/whitelist/

RUN chmod a+x /opt/whitelist/scripts/whitelist.py /etc/cron.daily/whitelist
