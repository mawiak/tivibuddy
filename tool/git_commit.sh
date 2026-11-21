#!/usr/bin/env bash
# Prints the short commit id for --dart-define=GIT_COMMIT, with "-dirty"
# when the working tree has uncommitted changes, so a build always tells
# which code it contains.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
commit="$(git rev-parse --short=7 HEAD)"
[[ -z "$(git status --porcelain)" ]] || commit="${commit}-dirty"
echo "${commit}"
