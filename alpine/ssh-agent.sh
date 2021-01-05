#!/bin/sh

eval "$(ssh-agent -s)"

echo "${SSH_PRIVATE_KEY}" | tr -d '\r' | ssh-add -

exec "$@"
