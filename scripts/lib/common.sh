#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [[ -f "$REPO_ROOT/config/server.env" ]]; then
    # shellcheck source=/dev/null
    source "$REPO_ROOT/config/server.env"
fi

BIOGEMT_ROOT="${BIOGEMT_ROOT:-/srv/biogemt}"
PIPELINE_NAME="genomic_region_annotator"
PIPELINE_REPOSITORY="${PIPELINE_REPOSITORY:-https://github.com/BioGeMT/genomic_region_annotator.git}"
PIPELINE_COMMAND="${PIPELINE_COMMAND:-genomic-region-annotator}"
PIPELINE_DEFAULT_REF="${PIPELINE_DEFAULT_REF:-main}"

PIPELINES_DIR="${PIPELINES_DIR:-$BIOGEMT_ROOT/pipelines}"
DATA_DIR="${DATA_DIR:-$BIOGEMT_ROOT/data}"
RUNS_DIR="${RUNS_DIR:-$BIOGEMT_ROOT/runs}"
LOGS_DIR="${LOGS_DIR:-$BIOGEMT_ROOT/logs}"
PIPELINE_DIR="${PIPELINE_DIR:-$PIPELINES_DIR/$PIPELINE_NAME}"
PIPELINE_RUNS_DIR="${PIPELINE_RUNS_DIR:-$RUNS_DIR/$PIPELINE_NAME}"
PIPELINE_LOG_DIR="${PIPELINE_LOG_DIR:-$LOGS_DIR/$PIPELINE_NAME}"

require_command() {
    local command_name="$1"

    if ! command -v "$command_name" >/dev/null 2>&1; then
        echo "Required command not found: $command_name" >&2
        exit 1
    fi
}

require_installed_pipeline() {
    if [[ ! -d "$PIPELINE_DIR/.git" ]]; then
        echo "Pipeline is not installed at $PIPELINE_DIR" >&2
        echo "Run ./scripts/install.sh first." >&2
        exit 1
    fi
}

ensure_server_layout() {
    mkdir -p \
        "$PIPELINES_DIR" \
        "$DATA_DIR" \
        "$PIPELINE_RUNS_DIR" \
        "$PIPELINE_LOG_DIR"
}
