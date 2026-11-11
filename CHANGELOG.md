# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Repository skeleton: license (GPL-3.0), git configuration, project documentation and AI guidelines.
- Flutter app for Android, iOS, macOS, Windows, Linux and web with dark TV theme.
- Remote-control navigation: side menu that expands on focus, select and back key handling.
- Marquee text for list entries that do not fit.
- English and German translations.
- Fire TV launcher integration and adb deploy script.
- User profiles: create, edit and delete profiles with name, bundled or custom avatar and
  optional PIN; profile picker with manage mode; optional default profile on start.
- Local SQLite database.

- Confirmation before replacing the start profile of another profile.
- Xtream Codes playlists per profile: add, edit and delete with connection test, account
  status and expiry; complete playlist links are split automatically; passwords in secure
  storage.
- Settings section with entries for playlists and profiles.

### Fixed

- White frame shown on Android before the first Flutter frame.
- Saving an edited profile did not return to the profile picker.
