FROM alpine
LABEL MAINTAINER=AwEi \
      GITHUB="https://github.com/chenwei791129/docker-alpine-openssh-client" \
      DOCKERHUB="https://hub.docker.com/r/awei/alpine-openssh-client"

RUN apk add openssh-client

ENTRYPOINT ["/bin/sh"]
