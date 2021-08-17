#!/bin/sh

set -e

DOCKER_REPO="${1:-klutchell}/balena-cli"
BALENA_CLI_VERSION="$(jq -r '.dependencies."balena-cli"' package.json | tr -d '^')"

docker build . \
    --pull \
    --tag "${DOCKER_REPO}:${BALENA_CLI_VERSION}" \
    --tag "${DOCKER_REPO}:latest" \
    --load
