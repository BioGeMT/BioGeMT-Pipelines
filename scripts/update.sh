#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <version-or-tag>" >&2
    exit 1
fi

VERSION="$1"

require_command git
require_command uv
require_installed_pipeline

cd "$PIPELINE_DIR"

if [[ -n "$(git status --porcelain)" ]]; then
    echo "Refusing to update because $PIPELINE_DIR has local changes." >&2
    exit 1
fi

git fetch --tags
git checkout "$VERSION"

uv sync --frozen
uv run pytest

echo "Updated $PIPELINE_NAME at $PIPELINE_DIR to $VERSION"
