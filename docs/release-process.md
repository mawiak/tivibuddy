# Release process

## Commits

Commits follow [Conventional Commits](https://www.conventionalcommits.org/):

| Type       | Use for                                   | Version impact |
|------------|-------------------------------------------|----------------|
| `feat`     | New user-visible functionality            | minor          |
| `fix`      | Bug fixes                                 | patch          |
| `perf`     | Performance improvements                  | patch          |
| `refactor` | Code changes without behaviour change     | none           |
| `docs`     | Documentation only                        | none           |
| `test`     | Tests only                                | none           |
| `build`    | Build system, dependencies                | none           |
| `ci`       | CI configuration                          | none           |
| `chore`    | Maintenance                               | none           |

A `!` after the type or a `BREAKING CHANGE:` footer marks a breaking change (major, or minor
while below 1.0.0).

## Branches

- Before the first release: all work on `develop`.
- After the first release: `main` contains released versions only. Work happens in
  `feat/<name>` or `fix/<name>` branches merged into `develop`. A release merges `develop` into
  `main`.

## Versioning

Semantic Versioning, starting at `0.1.0`. Git tags use the form `vX.Y.Z`. The version in
`app/pubspec.yaml` matches the tag.

## Changelog

`CHANGELOG.md` follows Keep a Changelog. Changes are collected under `Unreleased` and moved to
a version section on release.

## Release builds

`.github/workflows/ci.yml` checks formatting, analysis and tests on every push to `develop` and
`main` and on pull requests.

`.github/workflows/release.yml` runs for a tag `vX.Y.Z` (the version must match
`app/pubspec.yaml`): it analyses, tests, builds a universal APK and APKs per ABI, signs them and
creates the GitHub release with the changelog section of that version as notes. The universal
APK is attached twice, as `tivibuddy-X.Y.Z-universal.apk` and as `tivibuddy.apk`, so

    https://github.com/mawiak/tivibuddy/releases/latest/download/tivibuddy.apk

always downloads the newest release. One Downloader code for that address serves all releases
(created by hand at aftv.news; there is no API). Started by hand, the workflow builds the same
APKs and keeps them as workflow artifacts without a release.

Releases carry the "Send log to developer" Telegram configuration from repository secrets.

Version codes are the seconds since 2026-01-01 (`tool/build_number.sh`), so every build, local
or CI, installs over older ones. Split APKs add up to 4000 for their ABI.

Other platforms (iOS, macOS, Windows, Linux, web) and the sync server image follow later.

## Signing

APKs are signed with the TiviBuddy release key (`CN=TiviBuddy`). The first builds were signed
with a development key; APK Signature Scheme v3 key rotation lets installed apps update without
losing data: `tool/sign_release_apk.sh` signs with the old key (v2, for Android 8 and older)
and with the new key plus a lineage in which the old key approves the new one (v3, Android 9 and
newer, `--rotation-min-sdk-version 28`). Tested on a Fire TV Stick 4K Max: the update kept all
data and Android lists the old key as past signature.

The keys, the lineage and their passwords live in `~/.tivibuddy-release/` on the owner's machine
(`release.jks`, `legacy.p12`, `lineage.bin`, `passwords.txt`) and as repository secrets
(`RELEASE_KEYSTORE_BASE64`, `LEGACY_KEYSTORE_BASE64`, `ROTATION_LINEAGE_BASE64`,
`RELEASE_STORE_PASSWORD`, `LEGACY_STORE_PASSWORD`). They are never committed. Losing them means
no update can be installed over existing apps anymore, so the owner keeps a backup.

`tool/deploy_firetv.sh` and `tool/build_tester_apk.sh` sign the same way when the keys exist
locally; since the rotation, devices refuse APKs with only the development key.
