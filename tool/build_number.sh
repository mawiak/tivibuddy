#!/usr/bin/env bash
# Prints the Android version code base for a build: seconds since
# 2026-01-01 UTC. It grows with every build, locally and in CI, so a newer
# build always installs over an older one. Split APKs add up to 4000 for
# their ABI, which a build half a day later already exceeds.
set -euo pipefail
echo $(( $(date -u +%s) - $(date -u -j -f "%Y-%m-%d %H:%M:%S" "2026-01-01 00:00:00" +%s 2>/dev/null || date -u -d "2026-01-01 00:00:00" +%s) ))
