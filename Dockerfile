FROM curlimages/curl AS sources

RUN --mount=type=bind,source=.whitelist-version,target=.whitelist-version \
  export WHITELIST_VERSION=$(cat .whitelist-version) \
  && rm -rf /tmp/* \
  && cd /tmp \
  && curl -SL --connect-timeout 8 --max-time 120 --retry 128 --retry-delay 5 "https://github.com/anudeepND/whitelist/archive/refs/tags/${WHITELIST_VERSION}.tar.gz" -o whitelist.tar.gz \
  && mkdir -p /tmp/whitelist \
  && tar -xf whitelist.tar.gz -C /tmp/whitelist --strip-components=1 \
  && rm -rf /tmp/whitelist.tar.gz

############################################################

FROM pihole/pihole:2024.01.0 AS runtime

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
