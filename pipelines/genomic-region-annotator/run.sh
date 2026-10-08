#!/usr/bin/env bash
set -euo pipefail

IMAGE="${BIOGEMT_GENOMIC_REGION_ANNOTATOR_IMAGE:-ghcr.io/biogemt/genomic-region-annotator:0.1.0}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CONFIG_FILE="${BIOGEMT_CONFIG:-${ROOT_DIR}/config/server.env}"

BIOGEMT_ROOT="${BIOGEMT_ROOT:-/srv/biogemt}"
BIOGEMT_DATA="${BIOGEMT_DATA:-${BIOGEMT_ROOT}/data}"
BIOGEMT_RUNS="${BIOGEMT_RUNS:-${BIOGEMT_ROOT}/runs}"

if [[ -f "${CONFIG_FILE}" ]]; then
  # shellcheck source=/dev/null
  source "${CONFIG_FILE}"
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is required but was not found in PATH." >&2
  exit 127
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
