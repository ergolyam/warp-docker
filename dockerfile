FROM docker.io/debian:trixie-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends curl gpg ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg

RUN bash -c '. /etc/os-release ; echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ ${VERSION_CODENAME} main" | tee /etc/apt/sources.list.d/cloudflare-client.list'

RUN apt-get update && \
    apt-get install -y --no-install-recommends cloudflare-warp supervisor socat && \
    rm -rf /var/lib/apt/lists/*

COPY supervisord.conf /etc/supervisor/supervisord.conf

COPY scripts/warp-svc-wrapper /usr/local/bin/warp-svc-wrapper
COPY scripts/warp-bootstrap /usr/local/bin/warp-bootstrap
COPY scripts/warp-socat /usr/local/bin/warp-socat
COPY scripts/supervisor-failfast /usr/local/bin/supervisor-failfast

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
