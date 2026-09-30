#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

REF="${1:-$PIPELINE_DEFAULT_REF}"

require_command git
require_command uv
ensure_server_layout

if [[ -d "$PIPELINE_DIR/.git" ]]; then
    echo "Pipeline already installed at $PIPELINE_DIR"
    echo "Use ./scripts/update.sh <version> to deploy a specific version."
    exit 0
fi

git clone "$PIPELINE_REPOSITORY" "$PIPELINE_DIR"

cd "$PIPELINE_DIR"

git checkout "$REF"

uv sync --frozen

echo "Installed $PIPELINE_NAME at $PIPELINE_DIR using ref $REF"
