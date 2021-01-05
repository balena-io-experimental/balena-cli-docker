# balena-cli-docker

Multiarch docker images with balena-cli and a small footprint.

## Building

Set `DOCKER_REPO` and `BALENA_CLI_VERSION` in `deploy.sh` and run.

```bash
./deploy.sh
```

## Usage

```bash
docker run --rm -it klutchell/balena-cli:latest --help

# enable ssh by sharing your host ssh-agent socket
docker run --rm -it \
    -e SSH_AUTH_SOCK -v "$(dirname "${SSH_AUTH_SOCK}")"
    klutchell/balena-cli:latest balena --help

# enable ssh by providing a private ssh key
docker run --rm -it \
    --entrypoint ssh-agent.sh \
    -e SSH_PRIVATE_KEY="$(</path/to/priv/key)" \
    klutchell/balena-cli:latest balena --help

# enable build, deploy, and preload by sharing your host docker socket
docker run --rm -it \
    -v /var/run/docker.sock:/var/run/docker.sock \
    klutchell/balena-cli:latest balena --help

# enable build, deploy, and preload by running docker-in-docker
docker run --rm -it \
    --entrypoint dockerd.sh \
    klutchell/balena-cli:latest balena --help
```