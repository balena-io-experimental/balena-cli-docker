#!/bin/sh

set -e

DOCKER_REPO="${1:-klutchell}/balena-cli"
BALENA_CLI_VERSION="$(jq -r '.dependencies."balena-cli"' package.json | tr -d '^')"

export DOCKER_BUILDKIT=1
export DOCKER_CLI_EXPERIMENTAL=enabled

docker run --rm --privileged multiarch/qemu-user-static:5.2.0-2 --reset -p yes

docker buildx build . \
    --pull \
    --platform linux/amd64,linux/arm64,linux/arm/v7,linux/arm/v6 \
    --tag "${DOCKER_REPO}:${BALENA_CLI_VERSION}" \
    --tag "${DOCKER_REPO}:latest" \
    --push
