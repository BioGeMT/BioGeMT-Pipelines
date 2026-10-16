#!/usr/bin/env bash
set -euo pipefail

IMAGE="${BIOGEMT_GENOMIC_REGION_ANNOTATOR_IMAGE:-ghcr.io/biogemt/genomic-region-annotator:0.1.0}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CONFIG_FILE="${BIOGEMT_CONFIG:-${ROOT_DIR}/config/server.env}"

if [[ -f "${CONFIG_FILE}" ]]; then
  # shellcheck source=/dev/null
  source "${CONFIG_FILE}"
fi

BIOGEMT_ROOT="${BIOGEMT_ROOT:-/srv/biogemt}"
BIOGEMT_DATA="${BIOGEMT_DATA:-${BIOGEMT_ROOT}/data}"

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is required but was not found in PATH." >&2
  exit 127
fi

if ! docker image inspect "${IMAGE}" >/dev/null 2>&1; then
  if ! manifest_output="$(docker manifest inspect "${IMAGE}" 2>&1)"; then
    cat >&2 <<ERROR
Unable to access ${IMAGE}.

The image is not available locally, and Docker could not read it from GHCR.
The launcher must start the container to run any command, including --help.

Docker reported:
${manifest_output}
ERROR
    if [[ "${manifest_output}" == *unauthorized* || "${manifest_output}" == *denied* ]]; then
      cat >&2 <<ERROR
GHCR denied access. The package may be private, or Docker may not have credentials
with read access. Make the package public, or run 'docker login ghcr.io' with an
account/token that can read BioGeMT packages.
ERROR
    elif [[ "${manifest_output}" == *"manifest unknown"* || "${manifest_output}" == *"not found"* ]]; then
      echo "Check that the package name and tag are published: ${IMAGE}" >&2
    else
      echo "Check Docker's network connection to ghcr.io." >&2
    fi
    exit 125
  fi
fi

mounts=(
  -v "${PWD}:${PWD}"
  -w "${PWD}"
)

if [[ -d "${BIOGEMT_DATA}" ]]; then
  mounts+=( -v "${BIOGEMT_DATA}:${BIOGEMT_DATA}:ro" )
fi

exec docker run --rm \
  --user "$(id -u):$(id -g)" \
  "${mounts[@]}" \
  "${IMAGE}" \
  "$@"
