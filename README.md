# balena-cli-docker

[![Docker Pulls](https://img.shields.io/docker/pulls/klutchell/balena-cli.svg?style=flat-square)](https://hub.docker.com/r/klutchell/balena-cli/)
[![Docker Stars](https://img.shields.io/docker/stars/klutchell/balena-cli.svg?style=flat-square)](https://hub.docker.com/r/klutchell/balena-cli/)

Unofficial Docker images with the balena CLI and Docker-in-Docker.

## Environment Variables

These environment variables are available for additional functionality included in the CLI image.
In most cases these are optional, but some examples will highlight when environment variables are required.

- `-e "SSH_PRIVATE_KEY=$(</path/to/priv/key)"`: copy your private SSH key file contents as an environment variable
- `-e "DOCKERD=1"`: enable the included Docker-in-Docker daemon (requires `--privileged`)
- `-e "DOCKERD_EXTRA_ARGS=--key=val"`: provide additional args for the Docker-in-Docker daemon

## Volumes

Volumes can be used to persist data between instances of the CLI container, or to share
files between the host and the container.
In most cases these are optional, but some examples will highlight when volumes are required.

- `-v "balena_data:/root/.balena"`: persist balena credentials and downloads between instances
- `-v "docker_data:/var/lib/docker"`: persist cache between instances when using Docker-in-Docker (requires `-e "DOCKERD=1"`)
- `-v "$PWD:$PWD" -w "$PWD"`: bind mount your current working directory in the container to share app sources or balenaOS image files
- `-v "${SSH_AUTH_SOCK}:/ssh-agent"`: bind mount your host ssh-agent socket with preloaded SSH keys
- `-v "/var/run/docker.sock:/var/run/docker.sock"`: bind mount your host Docker socket instead of Docker-in-Docker

## Usage

Here are some examples of common CLI commands and how they are best used
with this image, since some special considerations must be made.

- [login](#login) - login to balena
- [push](#push) - start a build on the remote balenaCloud build servers, or a local mode device
- [logs](#logs) - show device logs
- [ssh](#ssh) - SSH into the host or application container of a device
- [apps](#app--apps) - list all applications
- [app](#app--apps) - display information about a single application
- [devices](#device--devices) - list all devices
- [device](#device--devices) - show info about a single device
- [tunnel](#tunnel) - tunnel local ports to your balenaOS device
- [preload](#preload) - preload an app on a disk image (or Edison zip archive)
- [build](#build--deploy) - build a project locally
- [deploy](#build--deploy) - deploy a single image or a multicontainer project to a balena application
- [join](#join--leave) - move a local device to an application on another balena server
- [leave](#join--leave) - remove a local device from its balena application
- [scan](#scan) - scan for balenaOS devices on your local network

### login

- <https://www.balena.io/docs/reference/balena-cli/#login>

The `balena login` command can't be used with web authorization and a browser
when running in a container. Instead it must be used with `--token` or `--credentials`.

Notice that here we've used a named volume `balena_data` to store credentials
for future runs of the CLI image. This is optional but avoids having to run the login
command again every time you run the image.

```bash
$ docker volume create balena_data
$ docker run --rm -it -v "balena_data:/root/.balena" klutchell/balena-cli /bin/bash
    
> balena login --credentials --email "johndoe@gmail.com" --password "secret"
> balena login --token "..."
> exit
```

### push

- <https://www.balena.io/docs/reference/balena-cli/#push-applicationordevice>

In this example we are mounting your current working directory into the container with `-v "$PWD:$PWD" -w "$PWD"`.
This will bind mount your current working directory into the container at the same absolute path.

This bind mount is required so the CLI has access to your app sources.

```bash
$ docker run --rm -it -v "balena_data:/root/.balena" \
    -v "$PWD:$PWD" -w "$PWD" \
    klutchell/balena-cli /bin/bash

> balena push myApp --source .
> balena push 10.0.0.1 --env MY_ENV_VAR=value --env my-service:SERVICE_VAR=value
> exit
```

### logs

- <https://www.balena.io/docs/reference/balena-cli/#logs-device>

```bash
$ docker run --rm -it -v "balena_data:/root/.balena" \
    klutchell/balena-cli /bin/bash

> balena logs 23c73a1 --service my-service
> balena logs 23c73a1.local --system --tail
> exit
```

### ssh

- <https://www.balena.io/docs/reference/balena-cli/#key-add-name-path>
- <https://www.balena.io/docs/reference/balena-cli/#ssh-applicationordevice-service>

The `balena ssh` command requires an existing SSH key added to your balenaCloud
account.

One way to make this key available to the container is to pass the private key file contents as an environment variable.

```bash
$ docker run --rm -it -v "balena_data:/root/.balena" \
    -e "SSH_PRIVATE_KEY=$(</path/to/priv/key)" \
    klutchell/balena-cli /bin/bash

> balena ssh f49cefd
> balena ssh f49cefd my-service
> balena ssh 192.168.0.1 --verbose
> exit
```

Another way to share SSH keys with the container is to mount your SSH agent socket with keys preloaded.

```bash
$ eval ssh-agent
$ ssh-add /path/to/priv/key

$ docker run --rm -it -v "balena_data:/root/.balena" \
    -v "${SSH_AUTH_SOCK}:/ssh-agent" \
    klutchell/balena-cli /bin/bash

> balena ssh f49cefd
> balena ssh f49cefd my-service
> balena ssh 192.168.0.1 --verbose
> exit
```

### app | apps

- <https://www.balena.io/docs/reference/balena-cli/#app-nameorslug>
- <https://www.balena.io/docs/reference/balena-cli/#apps>

```bash
$ docker run --rm -it -v "balena_data:/root/.balena" \
    klutchell/balena-cli /bin/bash

> balena apps
> balena app myorg/myapp
> exit
```

### device | devices

- <https://www.balena.io/docs/reference/balena-cli/#device-uuid>
- <https://www.balena.io/docs/reference/balena-cli/#devices>

```bash
$ docker run --rm -it -v "balena_data:/root/.balena" \
    klutchell/balena-cli /bin/bash

> balena devices --application MyApp
> balena device 7cf02a6
> exit
```

### tunnel

- <https://www.balena.io/docs/reference/balena-cli/#tunnel-deviceorapplication>

The `balena tunnel` command is easiest used when the host networking stack
can be shared with the container and ports can be easily assigned.

However the host networking driver only works on Linux hosts, and is not supported
on Docker Desktop for Mac, Docker Desktop for Windows, or Docker EE for Windows Server.

Instead you can bind specific port ranges to the host so you can access the tunnel
from outside the container via `localhost:[localPort]`.

Note that when exposing individual ports, you must specify all interfaces in the format
`[remotePort]:0.0.0.0:[localPort]` otherwise the tunnel will only be listening for
connections within the container.

```bash
$ docker run --rm -it -v "balena_data:/root/.balena" \
    -p 22222:22222 \
    -p 12345:54321
    klutchell/balena-cli /bin/bash

> balena tunnel 2ead211 -p 22222:0.0.0.0
> balena tunnel myApp -p 54321:0.0.0.0:12345
> exit
```

If you have host networking available then you do not need to specify ports
in your run command, and the interface `0.0.0.0` is optional in your tunnel command.

```bash
$ docker run --rm -it -v "balena_data:/root/.balena" \
    --network host \
    klutchell/balena-cli /bin/bash

> balena tunnel 2ead211 -p 22222
> balena tunnel myApp -p 54321:12345
> exit
```

### preload

- <https://www.balena.io/docs/reference/balena-cli/#os-download-type>
- <https://www.balena.io/docs/reference/balena-cli/#os-configure-image>
- <https://www.balena.io/docs/reference/balena-cli/#preload-image>

The `balena preload` command requires access to a Docker client and daemon.

The easiest way to run this command is to use the included Docker-in-Docker daemon.

```bash
$ docker run --rm -it -v "balena_data:/root/.balena" \
    -v "docker_data:/var/lib/docker" \
    -e "DOCKERD=1" --privileged \
    klutchell/balena-cli /bin/bash

> balena os download raspberrypi3 -o raspberry-pi.img
> balena os configure raspberry-pi.img --app MyApp
> balena preload raspberry-pi.img --app MyApp --commit current
> exit
```

Another way to run the `preload` command is to use the host OS Docker socket and avoid
starting a Docker daemon in the container. This is achieved with `-v "/var/run/docker.sock:/var/run/docker.sock"`.

In this example we are mounting your current working directory into the container with `-v "$PWD:$PWD" -w "$PWD"`.
This will bind mount your current working directory into the container at the same absolute path.

This bind mount is required when using the host Docker socket because the absolute path to the balenaOS image
file must be the same from both the perspective of the CLI in the container and the host Docker socket.

```bash
$ docker run --rm -it -v "balena_data:/root/.balena" \
    -v "/var/run/docker.sock:/var/run/docker.sock" \
    -v "$PWD:$PWD" -w "$PWD" \
    klutchell/balena-cli /bin/bash

> balena os download raspberrypi3 -o raspberry-pi.img
> balena os configure raspberry-pi.img --app MyApp
> balena preload raspberry-pi.img --app MyApp --commit current
> exit
```

### build | deploy

- <https://www.balena.io/docs/reference/balena-cli/#build-source>
- <https://www.balena.io/docs/reference/balena-cli/#deploy-appname-image>

The `build` and `deploy` commands both require access to a Docker client and daemon.

The easiest way to run these commands is to use the included Docker-in-Docker daemon.

In this example we are mounting your current working directory into the container with `-v "$PWD:$PWD" -w "$PWD"`.
This will bind mount your current working directory into the container at the same absolute path.

This bind mount is required so the CLI has access to your app sources.

```bash
$ docker run --rm -it -v "balena_data:/root/.balena" \
    -v "docker_data:/var/lib/docker" \
    -e DOCKERD=1 --privileged \
    -v "$PWD:$PWD" -w "$PWD" \
    klutchell/balena-cli /bin/bash

> balena build --application myApp
> balena deploy myApp
> exit
```

Another way to run the `build` and `deploy` commands is to use the host OS Docker socket and avoid
starting a Docker daemon in the container. This is achieved with `-v "/var/run/docker.sock:/var/run/docker.sock"`.

In this example we are mounting your current working directory into the container with `-v "$PWD:$PWD" -w "$PWD"`.
This will bind mount your current working directory into the container at the same absolute path.

This bind mount is required so the CLI has access to your app sources.

```bash
$ docker run --rm -it -v "balena_data:/root/.balena" \
    -v "/var/run/docker.sock:/var/run/docker.sock" \
    -v "$PWD:$PWD" -w "$PWD" \
    klutchell/balena-cli /bin/bash

> balena build --application myApp
> balena deploy myApp
> exit
```

### join | leave

- <https://www.balena.io/docs/reference/balena-cli/#join-deviceiporhostname>
- <https://www.balena.io/docs/reference/balena-cli/#leave-deviceiporhostname>

```bash
$ docker run --rm -it -v "balena_data:/root/.balena" \
    klutchell/balena-cli /bin/bash

> balena join balena.local --application MyApp
> balena leave balena.local
> exit
```

### scan

- <https://www.balena.io/docs/reference/balena-cli/#scan>

The `balena scan` command requires access to the host network interface
in order to bind and listen for multicast responses from devices.

However the host networking driver only works on Linux hosts, and is not supported
on Docker Desktop for Mac, Docker Desktop for Windows, or Docker EE for Windows Server.

```bash
docker run --rm -it --network host klutchell/balena-cli scan
```
