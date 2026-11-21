# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- The about screen and the settings show the version with its commit id.
- HDR10 output and judder-free frame timing for full screen playback with Media3 on Android:
  the video gets its own layer below the interface.
- Match frame rate on Android (off, films and series only, always): the TV switches to the
  frame rate of the video, for example 23.976 Hz for films and 50 Hz for TV; playback waits
  while the TV switches and keeps Dolby passthrough.
- Player choice on Android (automatic, Media3 only, media_kit only) and an automatic audio
  output that shows which formats the connected device takes; decoder and passthrough
  settings only appear for media_kit.
- Android plays with Media3 (ExoPlayer) first, with real Dolby passthrough, and falls back to
  media_kit for streams Media3 cannot play.
- Audio tracks in the player options name their codec, for example Dolby Digital (AC3) or DTS.
- Right in the live TV player jumps back to the channel played before.
- "Send log to developer" in the settings of tester builds: sends device details and the
  recent app and player log, without playlist passwords.
- Player settings: video decoder mode (hardware, hardware copy, software) and audio
  passthrough of Dolby Digital, Dolby Digital Plus, DTS, DTS-HD and TrueHD to a receiver.
- Sorting of movies and series by playlist order, date added, name, rating or release year.
- Search over channels, movies and series of the selected playlist.
- VOD info bar with rewind, play/pause, fast forward and start over controls, resolution and
  audio channels.
- Player options for live TV, movies and series: audio, subtitle and video track in a bar
  with a side panel to choose from; down twice or the menu key in VOD, the menu key in live
  TV.
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
  programme, programme grid with now line, categories reached with left or back, navigation
  through channels and time, playback with OK, sideways drag on touch. Back from the player
  returns to the guide while the channel continues in the preview.
- Background loading of the provider XMLTV guide with a streaming XML parser; now and next
  come from the loaded guide.
- Setting for how many days of guide are loaded, including switching it off.
- Select or right on Live TV and Movies in the menu starts in the category list; the movie
  grid shows the details of the focused movie above one row of posters.
- Series: categories with continue watching and favorites, poster grid with details, detail
  page with seasons and episodes, play or resume the next episode, episode progress and
  watched state per profile.
- Movies: categories with continue watching and favorites, poster grid, detail page with
  provider metadata, player with seeking, resume position, watched state and favorites per
  profile.

### Fixed

- Frozen picture without sound when audio passthrough was on but the device did not accept
  it: only formats the audio output accepts are passed through.
- Frozen picture without sound with passthrough on devices that do not play mpv's passthrough
  stream: the player falls back to decoded audio after three seconds.
- Surround sound was mixed down to stereo and audio passthrough stayed silent: audio now
  plays through Android AudioTrack.
- Green or black video on the Nvidia Shield: Flutter draws with Skia on OpenGL ES instead of
  Impeller on Vulkan.
- Tapping a category on touch screens showed the previously selected one.
- Up and down in the open channel list of the player zapped instead of moving through the list.
- Posters and the guide keep their size when the categories open; they shift to the right.
- Green, striped video and stuttering sound on Fire TV: the hardware decoder now renders
  directly into the video surface.
- White frame shown on Android before the first Flutter frame.
- Saving an edited profile did not return to the profile picker.
- Changing any profile could switch back to the start profile while another profile was in
  use.
- Left from the live TV channel list did not reach the categories, and left from the
  content did not reach the side menu.
- Switching to "All channels" or "All movies" reset the focus to the first category.
- The first poster of a new grid could take the focus away from the side menu.
- Moving right from the side menu focused the element at the same height instead of the last
  focused or first element of the content.
