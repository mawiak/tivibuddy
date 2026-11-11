# Live TV

Requirements: LIVE-1, DATA-1 to DATA-3, RES-1 to RES-3, PLAY-1 to PLAY-3, UI-1 to UI-3.

## Behaviour

- **Section layout (TV):** categories on the left, channel list in the middle, details of the
  focused channel on the right (logo, catch-up days, now and next programme with progress and
  description). Phones show the channel list with a category selector in the header.
- **Categories** switch the channel list as soon as they get focus. "All channels" is the
  first entry, "Update channels" the last. With more than one playlist, the first entry
  selects the playlist.
- **Right from the categories** focuses the last focused channel of the list, or its first
  channel after a category change.
- **Player:** full screen.

  | Key                          | Action                                          |
  |------------------------------|-------------------------------------------------|
  | Up / down, channel up / down | Previous / next channel of the list (wraps)     |
  | Select                       | Channel list overlay; retry after a failure     |
  | Left / right / info          | Show the info bar                               |
  | Play / pause                 | Pause and resume                                |
  | Back                         | Close the overlay, otherwise leave the player   |

  Zapping waits 450 ms after the last key press before a stream is opened, so passing channels
  quickly does not start every stream in between. The info bar appears on every channel change
  and hides after five seconds.

## Catalog loading

1. `get_live_categories` is small and decoded directly.
2. `get_live_streams` can be tens of megabytes. It is downloaded and parsed in a background
   isolate (`xtream_live_loader.dart`) with `JsonArraySplitter`, which decodes one channel
   object at a time. Channels arrive in batches of 500 and are written to SQLite.
3. Every load marks its channels with its start time; completing the load removes channels
   the provider no longer delivers. The previous catalog stays visible while a refresh runs.
4. The catalog is refreshed automatically when the section opens and the last complete load
   is older than 12 hours, and manually with "Update channels".

The catalog tables (`live_categories`, `live_channels`, `catalog_states`) are a local cache
and are not synchronized. Deleting a playlist deletes its catalog.

## Channel lists

Channel lists are `PagedList`s: the number of channels is known, rows load in pages of 100
from indexed SQL queries and at most eight pages stay in memory. Rows have a fixed height, so
lists jump to any position without measuring.

## Programme information

Now and next come from `get_short_epg` (titles are base64 encoded), are requested only for
the channel that rested in focus for 400 ms or is playing, cached for five minutes and
refreshed when the current programme ends. The full guide follows with the EPG milestone.

## Playback

`PlaybackEngine` (`app/lib/features/player/domain/`) abstracts the player. The implementation
uses media_kit (libmpv with FFmpeg). On the Fire TV Stick Lite H.264 is decoded by the
hardware decoder (MediaCodec, copy mode); a 1080p channel needs about 60 % of one of four
cores. mpv warnings and errors are written to the platform log with the prefix `mpv`.

Live streams are requested as MPEG-TS (`/live/<user>/<password>/<id>.ts`). mpv reconnects
after short network drops. The screen stays awake during playback (wakelock).

## Not yet implemented

Favorites, channel number input, recently watched, EPG grid, catch-up, HLS output option and a
configurable user agent.
