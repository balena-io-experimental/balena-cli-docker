# balena-cli-docker

Multiarch docker images with balena-cli and a small footprint.

## Tags

- `<cli-version>-debian`, `debian`, `<cli-version>`, `latest`
- `<cli-version>-alpine`, `alpine`

## Architectures

- `linux/arm/v6`  (alpine only)
- `linux/arm/v7`
- `linux/arm64`   (debian only)
- `linux/amd64`

## Build

```bash
docker build debian \
    --build-arg BALENA_CLI_VERSION="12.38.0" \
    --tag "balenacli:${BALENA_CLI_VERSION}" \
    --tag "balenacli:latest" \
    --pull

docker build alpine \
    --build-arg BALENA_CLI_VERSION="12.38.0" \
    --tag "balenacli:${BALENA_CLI_VERSION}" \
    --tag "balenacli:latest" \
    --pull
```

## Usage

### basic

```bash
# print usage
docker run --rm -it balenacli:latest --help
```

### scan

```bash
# balena scan requires the host network and NET_ADMIN
docker run --rm -it --cap-add NET_ADMIN --network host \
    balenacli:latest scan
```

### ssh

```bash
# balena ssh requires a private ssh key
docker run --rm -it -e SSH_PRIVATE_KEY="$(</path/to/priv/key)" \
    balenacli:latest ssh --help

# OR use your host ssh agent socket for balena ssh
docker run --rm -it -e SSH_AUTH_SOCK -v "$(dirname "${SSH_AUTH_SOCK}")" \
    balenacli:latest ssh --help
```

### build|deploy|preload

```bash
# balena build|deploy|preload with docker-in-docker requires SYS_ADMIN
docker run --rm -it --cap-add SYS_ADMIN \
    -v $PWD:/$PWD -w $PWD \
    balenacli:latest build --help

# OR use your host docker socket for balena build|deploy|preload
docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock \
    -v $PWD:/$PWD -w $PWD \
    balenacli:latest build --help
```
