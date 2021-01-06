#!/bin/sh

# start dockerd in the background
if ! docker info >/dev/null 2>&1
then
    [ -e /var/run/docker.sock ] && rm /var/run/docker.sock
    dockerd &
fi

if [ ! -e "${SSH_AUTH_SOCK}" ]
then
    eval "$(ssh-agent -s)"
fi

if [ -n "${SSH_PRIVATE_KEY}" ]
then
    echo "${SSH_PRIVATE_KEY}" | tr -d '\r' | ssh-add -
fi

# attempt to determine if an executable
# was provided in the command or just args
if [ -x "${1}" ] || [ -x "$(which "${1}")" ]
then
    exec "$@"
else
    exec balena "$@"
fi
