#!/bin/sh
# Retry boot dependencies without changing Swarm membership or touching app data.
set -eu
if ! systemctl is-active --quiet docker.service; then
    systemctl reset-failed docker.service 'mnt-docker\x2dswarm.mount' || true
    systemctl start docker.service
fi

# The standalone proxy can miss Docker's initial restart attempt while the
# Swarm overlay is waiting for quorum. Only start its existing container.
proxy_state=$(timeout 10 docker container inspect --format '{{.State.Running}}' nginx-reverse-proxy 2>/dev/null) || exit 0
if [ "$proxy_state" = false ]; then
    timeout 10 docker node ls >/dev/null
    timeout 75 docker container start nginx-reverse-proxy
fi
