ARG BASE_TAG
FROM alpine:${BASE_TAG}
LABEL MAINTAINER=AwEi \
      GITHUB="https://github.com/chenwei791129/docker-alpine-ssh-client" \
      DOCKERHUB="https://hub.docker.com/r/awei/alpine-ssh-client"

RUN apk add --no-cache --purge openssh-client rsync && \
    mkdir -p ~/.ssh && \
    chmod 700 ~/.ssh && \
    echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config

ENTRYPOINT ["/bin/sh"]
