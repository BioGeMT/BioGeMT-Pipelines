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
  if ! docker manifest inspect "${IMAGE}" >/dev/null 2>&1; then
    cat >&2 <<ERROR
Unable to access ${IMAGE}.

The image is not available locally and Docker cannot read it from GHCR.
If Docker reports "unauthorized", either make the GHCR package public or run
'docker login ghcr.io' with an account/token that can read BioGeMT packages.
ERROR
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
