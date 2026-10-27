# Official image, pinned by digest. Renovate bumps it.
FROM nousresearch/hermes-agent:v0.22.5@sha256:9c5561579f3ffdf333401797094ac3a743738d6c25d40f4331c7bf77b694238d

# nginx as an extra s6 service (see rootfs/), in front of the loopback-only dashboard.
RUN apt-get update \
    && apt-get install -y --no-install-recommends nginx \
    && rm -rf /var/lib/apt/lists/*

# Vite's preload helper hardcodes base "/", so lazy chunks (Chat, xterm)
# miss the ingress prefix. Prefix it at runtime; build fails if upstream changes it.
# Drop once Hermes builds with a runtime base.
RUN cd /opt/hermes/hermes_cli/web_dist/assets \
    && f=$(grep -l 'function(e){return`/`+e}' *.js) \
    && sed -i 's#function(e){return`/`+e}#function(e){return(window.__HERMES_BASE_PATH__||``)+`/`+e}#' $f

# nginx service + config.
COPY rootfs /

# The dashboard listens on loopback only, on port 9120. nginx sits in front of it:
# - port 8099 is the sidebar (ingress). Home Assistant already checks the user there.
# - port 9119 is the published port, for remote access.
# On loopback, Hermes asks for no login. Once HERMES_DASHBOARD_PUBLIC_URL is set
# (see cont-init.d/016-direct-access), it asks for its login on every request.
ENV HERMES_DASHBOARD=1 \
    HERMES_DASHBOARD_HOST=127.0.0.1 \
    HERMES_DASHBOARD_PORT=9120

# Gateway stays up even with no platform configured.
CMD ["gateway", "run"]
