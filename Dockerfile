FROM node:12-alpine

WORKDIR /usr/src/app

ARG BALENA_CLI_VERSION

# hadolint ignore=DL3018
RUN apk update && apk add --no-cache -t .build-deps \
        libstdc++ \
        binutils-gold \
        curl \
        g++ \
        gcc \
        gnupg \
        libgcc \
        linux-headers \
        make \
        python3 \
        git \
        openssh \
        bash && \
    npm install balena-cli@${BALENA_CLI_VERSION} -g --production --unsafe-perm && \
    apk del --purge .build-deps

RUN balena --version

ENTRYPOINT [ "balena" ]

CMD [ "--help" ]
