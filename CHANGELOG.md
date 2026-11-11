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
- A PIN protected start profile asks for its PIN directly on start.
- Xtream Codes playlists per profile: add, edit and delete with connection test, account
  status and expiry; complete playlist links are split automatically; passwords in secure
  storage.
- Settings with profile, device and general sections: app language per profile (all
  available translations), start profile, reset of profile and device settings.
- About page with version, license, disclaimer and open source licenses.
- Live TV: categories, channel list with logos, details with now and next programme, full
  screen player with zapping, info bar and channel list overlay.
- Background loading of large channel catalogs with a streaming JSON parser.
- Video playback with libmpv/FFmpeg and hardware decoding.
- TV guide as the live TV view: preview of the channel played last, details of the focused
  programme, programme grid with now line, channel column and categories reached with left, navigation
  through channels and time, playback with OK, sideways drag on touch. Back from the player
  returns to the guide while the channel continues in the preview.
- Background loading of the provider XMLTV guide with a streaming XML parser; now and next
  come from the loaded guide.
- Setting for how many days of guide are loaded, including switching it off.

### Fixed

- Green, striped video and stuttering sound on Fire TV: the hardware decoder now renders
  directly into the video surface.
- White frame shown on Android before the first Flutter frame.
- Saving an edited profile did not return to the profile picker.
- Changing any profile could switch back to the start profile while another profile was in
  use.
- Left from the live TV channel list did not reach the categories, and left from the
  content did not reach the side menu.
- Moving right from the side menu focused the element at the same height instead of the last
  focused or first element of the content.
