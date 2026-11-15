# Diagnostics

Testers can send a report to the developers so that problems on devices we do not have can be
analysed without asking back (DIAG-1, DIAG-2).

## Sending a report

Settings, General, "Send log to developer" asks what happened and sends the report as a text
file to the developer's Telegram bot chat. The entry only exists in tester builds; regular
builds have no destination compiled in and do not show it.

## Contents

- App version, time and the tester's description.
- Device model, Android version and build, supported ABIs, whether it is a TV device.
- Memory of the device and of the app (`/proc/meminfo`, `/proc/self/status`), load average.
- Player settings (decoder, audio passthrough).
- The last 3000 log lines since the app started: app messages, mpv warnings and errors, and
  player events. The player logs when it is created, every stream it opens, how long a stream
  took to start (`player started in ... ms`), stalls while playing (`player stalled`),
  failures, and lines of statistics 3 and 15 seconds after the start and then every minute:
  codec, hardware decoder in use, resolution, frame rates, bitrates, audio channels and output,
  dropped frames and the seconds buffered.

## Privacy

`redactCredentials` (`app/lib/core/logging/redact.dart`) replaces the account in Xtream stream
paths (`/live/<user>/<password>/`) and `username=` / `password=` query parameters with `***`
before a line is kept in memory or written to the platform log. The report is only built and
sent when the tester selects send; nothing is uploaded in the background.

## Tester builds

`tool/build_tester_apk.sh` builds a universal APK (all ABIs) with the bot token and chat id
passed as `--dart-define=TELEGRAM_BOT_TOKEN` and `TELEGRAM_CHAT_ID`. Both are read from
`~/.tivibuddy-telegram` (token on line 1, chat id on line 2) and never committed.
`tool/deploy_firetv.sh` passes them too when the file exists.

Anyone who extracts the APK can find the token and post to the bot. That is acceptable for a
small group of testers; if it leaks, revoke the token with `@BotFather` (`/revoke`) and build
again.
