FROM node:12-buster-slim

WORKDIR /usr/src/app

ARG BALENA_CLI_VERSION

ENV DEBCONF_NONINTERACTIVE_SEEN true
ENV DEBIAN_FRONTEND noninteractive

# hadolint ignore=DL3008
RUN apt-get update && apt-get install --no-install-recommends -y \
        build-essential \
        ca-certificates \
        curl \
        git \
        gnupg \
        openssh-client \
        python3 && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    npm install balena-cli@${BALENA_CLI_VERSION} -g --production --unsafe-perm

RUN balena --version

ENTRYPOINT [ "balena" ]

CMD [ "--help" ]
