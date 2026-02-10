#!/bin/bash
#
# Test Docker image build and verify installed tools.

readonly IMAGE="local/alpine-ssh-client:test"
readonly PLATFORM="linux/amd64"

err() {
  echo "[ERROR]: $*" >&2
}

detect_runtime() {
  if command -v podman &> /dev/null; then
    echo "podman"
  elif command -v docker &> /dev/null; then
    echo "docker"
  else
    err "Neither podman nor docker found"
    exit 1
  fi
}

run_test() {
  local tool="$1"
  if ! "${DOCKER}" run --platform "${PLATFORM}" -it --rm \
    --entrypoint "${tool}" "${IMAGE}" -V; then
    err "${tool} command failed"
    exit 1
  fi
}

main() {
  readonly DOCKER="$(detect_runtime)"
  echo "Running tests using ${DOCKER}..."

  "${DOCKER}" rmi "${IMAGE}" || true
  if ! "${DOCKER}" buildx build \
    --build-arg BASE_TAG=3.23.3 \
    --platform "${PLATFORM}" \
    -t "${IMAGE}" .; then
    err "Build failed"
    exit 1
  fi

  "${DOCKER}" images "${IMAGE}"

  run_test "ssh"
  run_test "rsync"
  run_test "sshpass"

  echo "All tests passed successfully."
}

main "$@"
