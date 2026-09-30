#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <installed-release>" >&2
    exit 1
fi

RELEASE="$1"
RELEASE_DIR="$(release_dir_for "$RELEASE")"

require_release "$RELEASE"

if [[ ! -d "$RELEASE_DIR/.git" ]]; then
    echo "Release $RELEASE is not installed at $RELEASE_DIR" >&2
    echo "Install it first with ./scripts/install.sh $RELEASE" >&2
    exit 1
fi

ln -sfn "$RELEASE_DIR" "$PIPELINE_CURRENT_LINK"

echo "Activated $PIPELINE_NAME release $RELEASE"
echo "Current release: $PIPELINE_CURRENT_LINK -> $RELEASE_DIR"
