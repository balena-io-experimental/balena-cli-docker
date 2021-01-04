#!/bin/sh

export BALENA_CLI_VERSION=12.37.0
export DOCKER_CLI_EXPERIMENTAL=enabled

docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

docker buildx build . \
    --build-arg BALENA_CLI_VERSION \
    --platform linux/amd64,linux/arm64,linux/arm/v7,linux/arm/v6 \
    --tag "klutchell/balena-cli:${BALENA_CLI_VERSION}-alpine" \
    --tag "klutchell/balena-cli:latest" \
    --pull --push
