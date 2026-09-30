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

PIPELINES_DIR="${PIPELINES_DIR:-$BIOGEMT_ROOT/pipelines}"
DATA_DIR="${DATA_DIR:-$BIOGEMT_ROOT/data}"
RUNS_DIR="${RUNS_DIR:-$BIOGEMT_ROOT/runs}"
LOGS_DIR="${LOGS_DIR:-$BIOGEMT_ROOT/logs}"
PIPELINE_BASE_DIR="${PIPELINE_BASE_DIR:-$PIPELINES_DIR/$PIPELINE_NAME}"
PIPELINE_RELEASES_DIR="${PIPELINE_RELEASES_DIR:-$PIPELINE_BASE_DIR/releases}"
PIPELINE_CURRENT_LINK="${PIPELINE_CURRENT_LINK:-$PIPELINE_BASE_DIR/current}"
PIPELINE_DIR="${PIPELINE_DIR:-$PIPELINE_CURRENT_LINK}"
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
    if [[ ! -L "$PIPELINE_CURRENT_LINK" || ! -d "$PIPELINE_CURRENT_LINK/.git" ]]; then
        echo "Pipeline is not installed at $PIPELINE_CURRENT_LINK" >&2
        echo "Run ./scripts/install.sh <release> first." >&2
        exit 1
    fi
}

sanitize_release_name() {
    local release="$1"

    echo "$release" | sed 's#[^A-Za-z0-9._-]#__#g'
}

release_dir_for() {
    local release="$1"
    local safe_release

    safe_release="$(sanitize_release_name "$release")"
    echo "$PIPELINE_RELEASES_DIR/$safe_release"
}

ensure_server_layout() {
    mkdir -p \
        "$PIPELINES_DIR" \
        "$PIPELINE_RELEASES_DIR" \
        "$DATA_DIR" \
        "$PIPELINE_RUNS_DIR" \
        "$PIPELINE_LOG_DIR"
}
