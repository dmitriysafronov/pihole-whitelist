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

FROM pihole/pihole:2025.02.3 AS runtime

RUN apk add --no-cache \
      git \
      python3

COPY --from=sources /tmp/whitelist/ /opt/whitelist/

RUN --mount=type=bind,source=crontab.whitelist,target=crontab.whitelist \
  cat crontab.whitelist >> /crontab.txt
