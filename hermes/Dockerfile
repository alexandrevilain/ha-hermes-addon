# Official image, pinned by digest. Renovate bumps it.
FROM nousresearch/hermes-agent:v0.22.2@sha256:36099926da316742423544e055d4734777105ffe6341873af5459b957d0c2919

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

# Loopback bind = no dashboard login; Home Assistant ingress does the auth.
ENV HERMES_DASHBOARD=1 \
    HERMES_DASHBOARD_HOST=127.0.0.1 \
    HERMES_DASHBOARD_PORT=9119

# Gateway stays up even with no platform configured.
CMD ["gateway", "run"]
