#!/bin/sh
# Local Home Assistant + Supervisor (official add-on devcontainer image) to test the add-on.
# Usage: ./dev.sh up | reload | watch | logs | down    (see DEV.md)
set -e
cd "$(dirname "$0")"

NAME=hermes-ha
IMAGE=ghcr.io/home-assistant/devcontainer:6-apps

case "$1" in
up)
    # Same setup as the official apps devcontainer: systemd boots dockerd, then supervisor_run.
    # Core serves on 80; its 8123 only redirects to :80.
    docker start "$NAME" 2>/dev/null || docker run -d --privileged --name "$NAME" \
        -p 7123:80 -p 9119:9119 -e SUPERVISOR_CHANNEL=stable \
        -v "$NAME-docker:/var/lib/docker" -v "$NAME-containerd:/var/lib/containerd" \
        -v "$NAME-supervisor:/mnt/supervisor" --tmpfs /tmp \
        -v "$PWD:/workspace:ro" "$IMAGE"
    until docker exec "$NAME" docker info >/dev/null 2>&1; do sleep 1; done
    docker exec -d -e SUPERVISOR_CHANNEL=stable "$NAME" supervisor_run
    echo "Home Assistant: http://localhost:7123 (first boot takes a few minutes)"
    ;;
reload)
    # A copy, not a bind mount, so the image: line can go: Supervisor then builds hermes/
    # instead of pulling the release.
    docker exec "$NAME" sh -c '
        set -e
        dst=/mnt/supervisor/apps/local/hermes
        rsync -a --delete /workspace/hermes/ $dst/
        sed -i "/^image:/d" $dst/config.yaml
        # Nested Docker trips the docker_gateway_unprotected check, which blocks installs.
        ha jobs options --ignore-conditions healthy >/dev/null
        ha store reload
        if ha apps info local_hermes --raw-json | jq -e ".data.version" >/dev/null; then
            ha apps rebuild local_hermes
        else
            ha apps install local_hermes && ha apps start local_hermes
        fi'
    ;;
watch)
    stamp=$(mktemp)
    "$0" reload || true
    while sleep 2; do
        if [ -n "$(find hermes -newer "$stamp" -print -quit)" ]; then
            touch "$stamp"
            "$0" reload || true
        fi
    done
    ;;
logs)
    docker exec "$NAME" docker logs -f app_local_hermes
    ;;
down)
    docker rm -f "$NAME"
    ;;
*)
    echo "usage: $0 up|reload|watch|logs|down" >&2
    exit 1
    ;;
esac
