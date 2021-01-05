#!/bin/sh

set -e

export DOCKER_REPO="klutchell/balena-cli"
export BALENA_CLI_VERSION="12.37.0"
export DOCKER_CLI_EXPERIMENTAL=enabled

docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

# missing linux/arm64 for now
docker buildx build alpine \
    --build-arg BALENA_CLI_VERSION \
    --platform linux/amd64,linux/arm/v7,linux/arm/v6 \
    --tag "${DOCKER_REPO}:${BALENA_CLI_VERSION}-alpine" \
    --tag "${DOCKER_REPO}:alpine" \
    --pull --push

# missing linux/arm/v6 for now
docker buildx build buster \
    --build-arg BALENA_CLI_VERSION \
    --platform linux/amd64,linux/arm64,linux/arm/v7 \
    --tag "${DOCKER_REPO}:${BALENA_CLI_VERSION}-buster" \
    --tag "${DOCKER_REPO}:buster" \
    --tag "${DOCKER_REPO}:${BALENA_CLI_VERSION}" \
    --tag "${DOCKER_REPO}:latest" \
    --pull --push

# missing linux/arm/v6 for now
docker buildx build docker \
    --build-arg BALENA_CLI_VERSION \
    --platform linux/amd64,linux/arm64,linux/arm/v7 \
    --tag "${DOCKER_REPO}:${BALENA_CLI_VERSION}-docker" \
    --tag "${DOCKER_REPO}:docker" \
    --pull --push
