#!/usr/bin/env bash
set -euo pipefail

IMAGE="${BIOGEMT_GENOMIC_REGION_ANNOTATOR_IMAGE:-ghcr.io/biogemt/genomic-region-annotator:0.1.0}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="${BIOGEMT_CONFIG:-${ROOT_DIR}/config/server.env}"

if [[ -f "${CONFIG_FILE}" ]]; then
  # shellcheck source=/dev/null
  source "${CONFIG_FILE}"
fi

BIOGEMT_ROOT="${BIOGEMT_ROOT:-/srv/biogemt}"
BIOGEMT_DATA="${BIOGEMT_DATA:-${BIOGEMT_ROOT}/data}"

ok=true
check_ok() { printf '[OK] %s\n' "$1"; }
check_warn() { printf '[WARN] %s\n' "$1"; }
check_fail() { printf '[FAIL] %s\n' "$1"; ok=false; }

printf 'BioGeMT doctor\n'
printf 'Root: %s\n' "${BIOGEMT_ROOT}"
printf 'Data: %s\n' "${BIOGEMT_DATA}"
printf 'Image: %s\n\n' "${IMAGE}"

if command -v docker >/dev/null 2>&1; then
  check_ok "Docker command found: $(command -v docker)"
else
  check_fail "Docker command not found in PATH"
fi

if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
  check_ok "Docker daemon is reachable"
else
  check_fail "Docker daemon is not reachable by this user"
fi

if [[ -d "${BIOGEMT_ROOT}" && -r "${BIOGEMT_ROOT}" ]]; then
  check_ok "BIOGEMT_ROOT is readable"
else
  check_warn "BIOGEMT_ROOT does not exist or is not readable: ${BIOGEMT_ROOT}"
fi

if [[ -d "${BIOGEMT_DATA}" && -r "${BIOGEMT_DATA}" ]]; then
  check_ok "BIOGEMT_DATA is readable"
else
  check_warn "BIOGEMT_DATA does not exist or is not readable yet: ${BIOGEMT_DATA}"
fi

if command -v docker >/dev/null 2>&1 && docker image inspect "${IMAGE}" >/dev/null 2>&1; then
  check_ok "Configured image is available locally"
elif command -v docker >/dev/null 2>&1; then
  set +e
  manifest_output="$(docker manifest inspect "${IMAGE}" 2>&1 >/dev/null)"
  manifest_status=$?
  set -e
  if [[ ${manifest_status} -eq 0 ]]; then
    check_ok "Configured image can be resolved from registry"
  elif [[ "${manifest_output}" == *unauthorized* ]]; then
    check_fail "Configured image exists behind GHCR authorization or is not public: ${IMAGE}"
    check_warn "Make the GHCR package public, or run 'docker login ghcr.io' with package read access."
  else
    check_fail "Configured image is not local and could not be resolved: ${IMAGE}"
    check_warn "Docker said: ${manifest_output}"
  fi
else
  check_fail "Configured image could not be checked because Docker is unavailable"
fi

if [[ "${ok}" == true ]]; then
  printf '\nDoctor completed successfully.\n'
else
  printf '\nDoctor found issues.\n' >&2
  exit 1
fi
