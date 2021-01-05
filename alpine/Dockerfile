FROM node:12-alpine

WORKDIR /usr/src/app

ARG BALENA_CLI_VERSION

# hadolint ignore=DL3018
RUN apk add --no-cache -t .build-deps \
        build-base \
        curl \
        git \
        linux-headers \
        python3 && \
    npm install balena-cli@${BALENA_CLI_VERSION} -g --production --unsafe-perm && \
    apk del --purge .build-deps

RUN balena --version

# https://github.com/balena-io/balena-cli/blob/master/INSTALL-LINUX.md#additional-dependencies
# hadolint ignore=DL3018
RUN apk add --no-cache avahi bash ca-certificates docker openssh

# overlay2 requires a docker volume for graph
VOLUME /var/lib/docker

COPY *.sh ./

RUN chmod +x ./*.sh

ENV PATH "${PATH}:/usr/src/app"

ENTRYPOINT [ "balena" ]

CMD [ "--help" ]
