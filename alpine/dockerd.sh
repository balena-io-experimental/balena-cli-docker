#!/bin/sh

# clean old docker data
rm -rf /var/run/docker/*
rm /var/run/docker.sock

# start dockerd in the background
dockerd &
sleep 5

exec "$@"
