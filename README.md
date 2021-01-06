# balena-cli-docker

Multiarch docker images with balena-cli and a small footprint.

## Tags

- `<cli-version>-buster`, `buster`, `<cli-version>`, `latest`
- `<cli-version>-alpine`, `alpine`

## Usage

```bash
docker run --rm -it klutchell/balena-cli:latest --help

# example: scan for balena devices
docker run --rm -it \
    --privileged --network host \
    klutchell/balena-cli:latest scan

# enable ssh by sharing your host ssh-agent socket
docker run --rm -it \
    -e SSH_AUTH_SOCK -v "$(dirname "${SSH_AUTH_SOCK}")"
    klutchell/balena-cli:latest --help

# enable ssh by providing a private ssh key
docker run --rm -it \
    -e SSH_PRIVATE_KEY="$(</path/to/priv/key)" \
    klutchell/balena-cli:latest --help

# enable build, deploy, and preload by sharing your host docker socket
docker run --rm -it \
    -v /var/run/docker.sock:/var/run/docker.sock \
    klutchell/balena-cli:docker --help

# enable build, deploy, and preload by running docker-in-docker
docker run --rm -it --privileged \
    klutchell/balena-cli:docker --help
```
