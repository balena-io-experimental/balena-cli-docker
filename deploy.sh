#!/bin/sh

export DOCKER_REPO="klutchell/balena-cli"
export BALENA_CLI_VERSION="12.37.0"
export DOCKER_CLI_EXPERIMENTAL=enabled

docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

docker buildx build alpine \
    --build-arg BALENA_CLI_VERSION \
    --platform linux/amd64,linux/arm/v7,linux/arm/v6 \
    --tag "${DOCKER_REPO}:${BALENA_CLI_VERSION}-alpine" \
    --tag "${DOCKER_REPO}:latest" \
    --pull --push

docker buildx build buster-slim \
    --build-arg BALENA_CLI_VERSION \
    --platform linux/amd64,linux/arm64,linux/arm/v7 \
    --tag "${DOCKER_REPO}:${BALENA_CLI_VERSION}-buster-slim" \
    --pull --push
