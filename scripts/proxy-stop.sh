#!/usr/bin/env bash
set -e

POLICY=no

# Update container restart policy
docker_stop(){
    local container=${1:?}
    local policy=${2:?}
    echo "Stopping container $container"
    docker update --restart=$policy $container >/dev/null
    docker stop $container >/dev/null
}

docker_stop nginx-proxy $POLICY
