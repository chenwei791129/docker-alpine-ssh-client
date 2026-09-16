#!/bin/bash
#
# Test Docker image builds (slim and fat variants) and verify installed tools.

readonly IMAGE="local/alpine-ssh-client:test"
readonly FAT_IMAGE="local/alpine-ssh-client:test-fat"
readonly PLATFORM="linux/amd64"
readonly BASE_TAG="3.23.3"

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

#######################################
# Rebuild an image from the given Dockerfile.
# Arguments:
#   Image tag, Dockerfile path
#######################################
build_image() {
  local image="$1"
  local dockerfile="$2"
  "${DOCKER}" rmi "${image}" || true
  if ! "${DOCKER}" buildx build \
    --build-arg BASE_TAG="${BASE_TAG}" \
    --platform "${PLATFORM}" \
    -f "${dockerfile}" \
    -t "${image}" .; then
    err "Build of ${dockerfile} failed"
    exit 1
  fi
  "${DOCKER}" images "${image}"
}

#######################################
# Run a tool inside an image and fail if it exits non-zero.
# Arguments:
#   Image tag, tool name, version flag (default -V)
#######################################
run_test() {
  local image="$1"
  local tool="$2"
  local version_flag="${3:--V}"
  if ! "${DOCKER}" run --platform "${PLATFORM}" -it --rm \
    --entrypoint "${tool}" "${image}" "${version_flag}"; then
    err "${tool} command failed in ${image}"
    exit 1
  fi
}

main() {
  readonly DOCKER="$(detect_runtime)"
  echo "Running tests using ${DOCKER}..."

  build_image "${IMAGE}" "Dockerfile"
  run_test "${IMAGE}" "ssh"
  run_test "${IMAGE}" "rsync"
  run_test "${IMAGE}" "sshpass"

  build_image "${FAT_IMAGE}" "Dockerfile.fat"
  run_test "${FAT_IMAGE}" "ssh"
  run_test "${FAT_IMAGE}" "rsync"
  run_test "${FAT_IMAGE}" "sshpass"
  run_test "${FAT_IMAGE}" "bash" "--version"
  run_test "${FAT_IMAGE}" "jq" "--version"

  echo "All tests passed successfully."
}

main "$@"
