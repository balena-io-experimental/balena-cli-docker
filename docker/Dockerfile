ARG BALENA_CLI_VERSION

FROM klutchell/balena-cli:${BALENA_CLI_VERSION}-buster

# hadolint ignore=DL3008
RUN apt-get update && apt-get install --no-install-recommends -y \
    ca-certificates docker.io && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# overlay2 requires a docker volume for graph
VOLUME /var/lib/docker

COPY init.sh ./

RUN chmod +x ./init.sh

ENTRYPOINT [ "./init.sh" ]

CMD [ "--help" ]
