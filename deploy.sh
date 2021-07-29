#!/bin/sh

set -e

export DOCKER_REPO="${1:-klutchell}/balena-cli"
export BALENA_CLI_VERSION="${2:-12.44.29}"
export DOCKER_BUILDKIT=1
export DOCKER_CLI_EXPERIMENTAL=enabled

docker run --rm --privileged multiarch/qemu-user-static:5.2.0-2 --reset -p yes

docker buildx build . \
    --pull \
    --platform linux/amd64,linux/arm64,linux/arm/v7,linux/arm/v6 \
    --build-arg BALENA_CLI_VERSION \
    --tag "${DOCKER_REPO}:${BALENA_CLI_VERSION}" \
    --tag "${DOCKER_REPO}:latest" \
    --push
