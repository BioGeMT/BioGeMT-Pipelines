#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <release-tag-or-commit>" >&2
    exit 1
fi

RELEASE="$1"

require_release "$RELEASE"
require_command git
require_command uv
ensure_server_layout

RELEASE_DIR="$(release_dir_for "$RELEASE")"

if [[ -d "$RELEASE_DIR/.git" ]]; then
    cd "$RELEASE_DIR"
    git fetch --tags
else
    git clone "$PIPELINE_REPOSITORY" "$RELEASE_DIR"
    cd "$RELEASE_DIR"
fi

git checkout "$RELEASE"

if [[ -n "$(git status --porcelain)" ]]; then
    echo "Refusing to activate $RELEASE because $RELEASE_DIR has local changes." >&2
    exit 1
fi

uv sync --frozen
uv run pytest

ln -sfn "$RELEASE_DIR" "$PIPELINE_CURRENT_LINK"

echo "Activated $PIPELINE_NAME release $RELEASE"
echo "Current release: $PIPELINE_CURRENT_LINK -> $RELEASE_DIR"
