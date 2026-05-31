#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE="docker-infrastructure-bastion"

docker build -t "$IMAGE" "$SCRIPT_DIR/bastion"

exec docker run --rm -it \
    --add-host=host.docker.internal:host-gateway \
    "$IMAGE"
