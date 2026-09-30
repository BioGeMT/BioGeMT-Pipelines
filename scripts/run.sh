#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

require_command uv
require_installed_pipeline

export BIOGEMT_DATA_DIR="$DATA_DIR"
export BIOGEMT_RUNS_DIR="$PIPELINE_RUNS_DIR"
export BIOGEMT_LOGS_DIR="$PIPELINE_LOG_DIR"

cd "$PIPELINE_DIR"

exec uv run "$PIPELINE_COMMAND" "$@"
