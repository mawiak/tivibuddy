# Settings

Requirements: SET-1 to SET-3, I18N-1, I18N-2.

Settings are part of the home screen (last menu entry) and grouped into three sections.

## Profile section (synchronized with the profile)

| Setting     | Values                                       | Default         |
|-------------|----------------------------------------------|-----------------|
| Playlists   | Opens the playlist management                | -               |
| Language    | Device language or any available translation | Device language |
| Reset       | Restores the defaults of the active profile  | -               |

The language list is built from the ARB files (`AppLocalizations.supportedLocales`). Each ARB
file contains a `languageName` key with the name of the language in that language, so a new
translation appears in the list without code changes.

Profile settings are stored as key-value rows (`profile_setting_entries`) with sync columns. A
cleared value keeps a row with `deleted = true` so the change can be synchronized.

## Device section (this installation only)

| Setting         | Values                                        | Default               |
|-----------------|-----------------------------------------------|-----------------------|
| Start profile   | Profile selection or one profile              | Profile selection     |
| Programme guide | Do not load, 1, 2, 3, 5 or 7 days ahead       | 3 days ahead          |
| Profiles        | Opens the profile picker                      | -                     |
| Reset           | Restores the defaults of all device settings  | -                     |

Device settings are stored in `device_setting_entries` and are never synchronized.

## Player section (this installation only)

| Setting           | Values                                                        | Default  |
|-------------------|---------------------------------------------------------------|----------|
| Video decoder     | Hardware, hardware copy mode, software                        | Hardware |
| Audio passthrough | Any of Dolby Digital, Dolby Digital Plus, DTS, DTS-HD, TrueHD | Off      |

The decoder applies from the next playback, because it is chosen when the player is created.
Hardware renders straight into the video surface; copy mode is the media_kit default and
helps on chips that show wrong colours with direct rendering (reported for the Nvidia
Shield); software decoding works everywhere but needs much more CPU.

Without passthrough all audio is decoded to PCM, which every output plays. Passthrough sends
the selected formats unchanged over HDMI or S/PDIF (mpv `audio-spdif`), so a receiver or
soundbar shows and decodes them itself; a format the receiver does not support stays silent.
TrueHD (Atmos) is only played through passthrough, the bundled FFmpeg has no TrueHD decoder.
Both are stored under the keys `player.decoder` and `player.passthrough`.

## General section

About TiviBuddy: version, license, legal disclaimer and the licenses of the bundled open
source packages.

## Planned

Buffer settings, preferred audio and subtitle languages, category order
and hidden categories, and the sync server configuration are added together with the features
they belong to.
