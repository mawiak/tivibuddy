#!/usr/bin/env bash
# Builds TiviBuddy and installs it on a Fire TV / Android TV device over adb.
#
# Usage: tool/deploy_firetv.sh <device-ip[:port]> [--debug|--profile|--release] [--no-build]
#
# The device ABI is detected automatically, so the same command works for
# 32-bit devices (most Fire TV sticks, including the 4K Max) and 64-bit
# devices (for example Fire TV Cube, Nvidia Shield). With ~/.tivibuddy-telegram
# present (see build_tester_apk.sh) the build can send logs to the developer.

set -euo pipefail

readonly APP_ID="io.github.mawiak.tivibuddy"
readonly REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly APP_DIR="${REPO_ROOT}/app"

usage() {
  sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'
  exit 1
}

[[ $# -ge 1 ]] || usage

device="$1"
shift
[[ "${device}" == *:* ]] || device="${device}:5555"

mode="release"
build=true
for arg in "$@"; do
  case "${arg}" in
    --debug) mode="debug" ;;
    --profile) mode="profile" ;;
    --release) mode="release" ;;
    --no-build) build=false ;;
    *) usage ;;
  esac
done

echo "Connecting to ${device}"
adb connect "${device}" >/dev/null
adb -s "${device}" wait-for-device

abi="$(adb -s "${device}" shell getprop ro.product.cpu.abi | tr -d '\r')"
case "${abi}" in
  arm64-v8a | armeabi-v7a | x86_64) ;;
  *) echo "Unsupported device ABI: ${abi}" >&2; exit 1 ;;
esac
echo "Device ABI: ${abi}"

if [[ "${build}" == true ]]; then
  echo "Building ${mode} APKs"
  defines=()
  secrets="${TIVIBUDDY_TELEGRAM_FILE:-${HOME}/.tivibuddy-telegram}"
  if [[ -f "${secrets}" ]]; then
    defines=(
      "--dart-define=TELEGRAM_BOT_TOKEN=$(sed -n 1p "${secrets}")"
      "--dart-define=TELEGRAM_CHAT_ID=$(sed -n 2p "${secrets}")"
    )
  fi
  (cd "${APP_DIR}" && flutter build apk "--${mode}" --split-per-abi \
    "--build-number=$("${REPO_ROOT}/tool/build_number.sh")" \
    "--dart-define=GIT_COMMIT=$("${REPO_ROOT}/tool/git_commit.sh")" \
    ${defines[@]+"${defines[@]}"})
fi

apk="${APP_DIR}/build/app/outputs/flutter-apk/app-${abi}-${mode}.apk"
[[ -f "${apk}" ]] || { echo "APK not found: ${apk}" >&2; exit 1; }

# Installed apps carry the release key since the key rotation; an APK with
# only the development key would be refused.
if [[ -f "${HOME}/.tivibuddy-release/release.jks" || -n "${RELEASE_KEYSTORE:-}" ]]; then
  signed="${apk%.apk}-signed.apk"
  "${REPO_ROOT}/tool/sign_release_apk.sh" "${apk}" "${signed}" >/dev/null
  apk="${signed}"
fi

echo "Installing $(basename "${apk}") ($(du -h "${apk}" | cut -f1))"
adb -s "${device}" install -r "${apk}"

echo "Starting ${APP_ID}"
adb -s "${device}" shell am start -n "${APP_ID}/.MainActivity" >/dev/null
echo "Done"
