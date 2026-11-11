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

Planned for milestone 11: GitHub Actions build artifacts for Android (APK split per ABI, AAB),
iOS, macOS, Windows, Linux, web and the sync server Docker image, and attach them to the GitHub
release. Version bumps and changelog generation will be automated with release-please.
