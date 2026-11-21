#!/usr/bin/env bash
# Prints the CHANGELOG.md section of a version, for release notes.
#
# Usage: tool/changelog_section.sh <version>
set -euo pipefail
version="${1:?version}"
changelog="$(dirname "${BASH_SOURCE[0]}")/../CHANGELOG.md"
awk -v v="${version}" '
  /^## \[/ { if (found) exit; if (index($0, "[" v "]")) { found = 1; next } }
  found { print }
' "${changelog}"
