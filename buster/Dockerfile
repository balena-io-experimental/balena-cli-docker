FROM node:12-buster-slim

WORKDIR /usr/src/app

ARG BALENA_CLI_VERSION

ENV DEBCONF_NONINTERACTIVE_SEEN true
ENV DEBIAN_FRONTEND noninteractive

# hadolint ignore=DL3008,SC2086
RUN buildDeps="build-essential ca-certificates curl git python3" && \
    apt-get update && apt-get install --no-install-recommends -y $buildDeps && \
    npm install balena-cli@${BALENA_CLI_VERSION} -g --production --unsafe-perm && \
    apt-get purge -y --auto-remove $buildDeps && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN balena --version

# https://github.com/balena-io/balena-cli/blob/master/INSTALL-LINUX.md#additional-dependencies
# hadolint ignore=DL3008
RUN apt-get update && apt-get install --no-install-recommends -y \
    avahi-daemon ca-certificates docker.io openssh-client && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# overlay2 requires a docker volume for graph
VOLUME /var/lib/docker

COPY *.sh ./

RUN chmod +x ./*.sh

ENV PATH "${PATH}:/usr/src/app"

ENTRYPOINT [ "balena" ]

CMD [ "--help" ]
