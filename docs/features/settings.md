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

On Android the section shows:

| Setting      | Values                                                        | Default   |
|--------------|---------------------------------------------------------------|-----------|
| Player       | Automatic (Media3, then media_kit), Media3 only, media_kit only | Automatic |
| Audio output | Information only: which formats the output passes through now | -         |
| Match frame rate | Off, films and series only, always                       | Off       |

With Media3 the audio output needs no setting: the connected TV, soundbar or receiver reports
over HDMI which formats it decodes; those are passed through, everything else is decoded.
Phones and tablets always decode.

Match frame rate switches the display to a mode with the current resolution whose refresh rate
is the highest whole multiple of the video frame rate (`DisplayModes.kt`): 23.976 fps films at
23.976 Hz, 25 fps TV at 50 Hz, 29.97 fps at 59.94 Hz. Media3 measures the frame rate from the
timestamps of the first 48 frames, because MKV files and TS streams often do not state it;
media_kit reports `container-fps`. `FrameRateFollower` pauses playback while the TV switches,
waits until the display reports the new mode and the HDMI sink reports the same audio formats
as before (at most eight seconds), then replaces the Media3 player with a new one at the same
position and resumes:
HDMI renegotiates audio during the switch, and a running Media3 player keeps the PCM-only
capabilities it saw meanwhile, even through later seeks; only a new player passes through
again. media_kit reloads its audio output instead. The display stays at the last rate when the player closes,
which saves a switch when the next stream fits. With "films and series only" live TV switches
the display back to its default mode. Every step is logged with `display:`.

Fire TV devices only offer other display modes to apps when their video resolution is set to
automatic and their own "Match original frame rate" option is on; with a fixed resolution such
as 2160p 50 Hz the app sees that single mode and logs that no mode fits. The video decoder and audio passthrough settings below
belong to media_kit and appear on Android only with "media_kit only"; desktop platforms play
with media_kit and always show them. The player choice is stored under `player.engine`.


| Setting           | Values                                                        | Default  |
|-------------------|---------------------------------------------------------------|----------|
| Video decoder     | Hardware, hardware copy mode, software                        | Hardware |
| Audio passthrough | Any of Dolby Digital, Dolby Digital Plus, DTS, DTS-HD, TrueHD | Off      |

The decoder applies from the next playback, because it is chosen when the player is created.
Hardware renders straight into the video surface; copy mode is the media_kit default and
helps on chips that show wrong colours with direct rendering (reported for the Nvidia
Shield); software decoding works everywhere but needs much more CPU.

Audio plays through Android AudioTrack (`ao=audiotrack`) instead of the OpenSL ES output media_kit
selects, which mixes everything down to stereo and cannot pass formats through.
Without passthrough all audio is decoded to PCM (multichannel where the output supports it),
which every output plays. Passthrough sends
the selected formats unchanged over HDMI or S/PDIF (mpv `audio-spdif`), so a receiver or
soundbar shows and decodes them itself. Only formats the output accepts right now are passed
through (`AudioCapabilities.kt`, after ExoPlayer's checks): the Android setting for encoded
surround output, the Fire TV switch for an external surround system and the encodings the HDMI
sink reports. Sending a refused format stalls mpv (frozen picture, no sound), which is what a
Fire TV with surround output switched off did. The passthrough dialog shows what the device
accepts at the moment, and every player logs chosen, accepted and used formats.

mpv passes formats through to AudioTrack only as IEC 61937. Some devices accept AC3 on paper
but never play that stream; the Fire TV Stick 4K Max is one of them. When the audio output is
still not open three seconds after a stream started with passthrough and playback has not
moved for two more seconds, the player switches passthrough off for the rest of the run and reopens the stream at the same position with
decoded audio. Real passthrough on such devices needs a second playback engine such as
ExoPlayer, which sends the compressed frames directly (backlog).
TrueHD (Atmos) is only played through passthrough, the bundled FFmpeg has no TrueHD decoder.
Both are stored under the keys `player.decoder` and `player.passthrough`.

## General section

About TiviBuddy: version, license, legal disclaimer and the licenses of the bundled open
source packages.

## Planned

Buffer settings, preferred audio and subtitle languages, category order
and hidden categories, and the sync server configuration are added together with the features
they belong to.
