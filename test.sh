#!/bin/bash

echo "Running tests..."

docker rmi local/alpine-ssh-client:test || true
docker buildx build --build-arg BASE_TAG=3.22.1 --platform linux/amd64 -t local/alpine-ssh-client:test .
if [ $? -ne 0 ]; then
    echo "Build failed"
    exit 1
fi

docker run --platform linux/amd64 -it --rm --entrypoint ssh local/alpine-ssh-client:test -V
if [ $? -ne 0 ]; then
    echo "SSH command failed"
    exit 1
fi

docker run --platform linux/amd64 -it --rm --entrypoint rsync local/alpine-ssh-client:test -V
if [ $? -ne 0 ]; then
    echo "Rsync command failed"
    exit 1
fi

echo "All tests passed successfully."
exit 0
