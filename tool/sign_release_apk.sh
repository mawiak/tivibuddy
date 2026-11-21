#!/usr/bin/env bash
# Signs a release APK with the TiviBuddy release key and the rotation lineage
# from the old development key, so installed apps update without losing data.
#
# Usage: tool/sign_release_apk.sh <input.apk> <output.apk>
#
# Expects, from environment variables (CI secrets) or ~/.tivibuddy-release/:
#   RELEASE_KEYSTORE / release.jks         new key (alias tivibuddy)
#   LEGACY_KEYSTORE / legacy.p12           old key (alias legacy)
#   ROTATION_LINEAGE / lineage.bin         proof that the old key trusts the new
#   RELEASE_STORE_PASSWORD, LEGACY_STORE_PASSWORD
#
# Android 9+ (API 28) verifies the v3 signature with the new key; older
# Android versions verify the v1/v2 signature of the old key.

set -euo pipefail

[[ $# -eq 2 ]] || { sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'; exit 1; }
input="$1"
output="$2"

keys="${HOME}/.tivibuddy-release"
if [[ -z "${RELEASE_STORE_PASSWORD:-}" && -f "${keys}/passwords.txt" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "${keys}/passwords.txt"
  set +a
fi
release_ks="${RELEASE_KEYSTORE:-${keys}/release.jks}"
legacy_ks="${LEGACY_KEYSTORE:-${keys}/legacy.p12}"
lineage="${ROTATION_LINEAGE:-${keys}/lineage.bin}"

sdk="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-${HOME}/Library/Android/sdk}}"
build_tools="$(ls -d "${sdk}"/build-tools/* | sort -V | tail -1)"

"${build_tools}/apksigner" sign \
  --ks "${legacy_ks}" --ks-key-alias legacy --ks-pass env:LEGACY_STORE_PASSWORD \
  --next-signer \
  --ks "${release_ks}" --ks-key-alias tivibuddy --ks-pass env:RELEASE_STORE_PASSWORD \
  --lineage "${lineage}" \
  --rotation-min-sdk-version 28 \
  --v4-signing-enabled false \
  --out "${output}" "${input}"

"${build_tools}/apksigner" verify --print-certs --verbose "${output}" \
  | grep -E "Verified using|Signer #[0-9]+ certificate DN" || true
