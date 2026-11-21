#!/usr/bin/env bash
# Builds a universal release APK (all ABIs) for testers, with "Send log to
# developer" enabled.
#
# Usage: tool/build_tester_apk.sh
#
# The Telegram bot token (line 1) and chat id (line 2) are read from
# ~/.tivibuddy-telegram, or from TIVIBUDDY_TELEGRAM_FILE. They are compiled
# into the APK only and never stored in the repository.

set -euo pipefail

readonly REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly APP_DIR="${REPO_ROOT}/app"
readonly SECRETS="${TIVIBUDDY_TELEGRAM_FILE:-${HOME}/.tivibuddy-telegram}"

[[ -f "${SECRETS}" ]] || { echo "Missing ${SECRETS}" >&2; exit 1; }
token="$(sed -n 1p "${SECRETS}")"
chat="$(sed -n 2p "${SECRETS}")"
[[ -n "${token}" && -n "${chat}" ]] || {
  echo "${SECRETS} needs the bot token on line 1 and the chat id on line 2" >&2
  exit 1
}

version="$(sed -n 's/^version: \([^+]*\).*/\1/p' "${APP_DIR}/pubspec.yaml")"
commit="$(git -C "${REPO_ROOT}" rev-parse --short HEAD)"

cd "${APP_DIR}"
flutter build apk --release \
  "--build-number=$("${REPO_ROOT}/tool/build_number.sh")" \
  --dart-define="TELEGRAM_BOT_TOKEN=${token}" \
  --dart-define="TELEGRAM_CHAT_ID=${chat}"

out="build/app/outputs/flutter-apk/tivibuddy-${version}-${commit}-universal.apk"
# Signed like releases (key rotation), so it updates installed apps.
"${REPO_ROOT}/tool/sign_release_apk.sh" build/app/outputs/flutter-apk/app-release.apk "${out}" >/dev/null
echo "Tester APK: ${APP_DIR}/${out}"
