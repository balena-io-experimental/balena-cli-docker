#!/bin/sh

set -e

export DOCKER_REPO="${1:-klutchell}/balena-cli"
export BALENA_CLI_VERSION="${2:-12.46.1}"
export DOCKER_BUILDKIT=1
export DOCKER_CLI_EXPERIMENTAL=enabled

docker buildx build . \
    --pull \
    --build-arg BALENA_CLI_VERSION \
    --tag "${DOCKER_REPO}:${BALENA_CLI_VERSION}" \
    --tag "${DOCKER_REPO}:latest" \
    --load
