# Live TV

Requirements: LIVE-1, LIVE-2, DATA-1 to DATA-3, RES-1 to RES-3, PLAY-1 to PLAY-3, UI-1 to
UI-3.

## Behaviour

- **Section layout (TV):** the live TV section is the guide, following the common IPTV player
  layout: details of the focused programme at the top, with a preview of the channel played
  last on their left while it plays, and the programme grid below (see [TV guide](#tv-guide)).
  Phones show details and grid with a category selector in the header, without preview.
- **Left** from the programme running now focuses the channel column of the grid (up and down
  change the channel, select plays it, right returns to the programmes). Left from there
  opens the **categories** as a column that pushes the grid to the right. They switch the grid
  as soon as they get focus. "All channels" is the first entry, "Update channels" the last.
  With more than one playlist, the first entry selects the playlist. Right closes them and
  returns to the grid, left opens the side menu, which also closes them.
- **Back from the player** returns to the guide on the channel played last, which continues
  in the preview. Select on it returns to full screen without opening the stream again.
  Leaving the live TV section stops playback. The screen stays on while a stream plays.
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

Now and next are requested only for the channel that rested in focus for 400 ms or is
playing, cached for five minutes and refreshed when the current programme ends. They come
from the loaded guide; channels without guide data fall back to `get_short_epg` (titles are
base64 encoded).

## TV guide

The grid shows the channels of the selected category: channels as rows, time as columns, a
line at the current time and the playing channel marked in the accent colour.

| Key                          | Action                                                  |
|------------------------------|---------------------------------------------------------|
| Right / left                 | Next / previous programme; empty times move by 30 min   |
| Up / down, channel up / down | Previous / next channel, keeping the time position      |
| Page up / down               | One screen of channels                                  |
| Select                       | Play the channel in full screen                         |
| Up from the first channel    | Category button (phones)                                |
| Left from the current programme | Channel column (no catch-up yet, past is hidden)     |
| Left from the channel column | Categories                                              |

On touch screens a tap plays the channel and dragging sideways moves the time axis.

The grid is one focus node that tracks the focused row and a time inside the focused
programme, instead of a focus node per programme. Rows are virtualized with a fixed height.
Each visible row loads its programmes from SQLite for a window of 12 hours aligned to 6 hour
chunks, so moving within a chunk does not query again (`guide_providers.dart`).

## Guide loading

1. The guide is loaded after every catalog load and when the live TV section opens
   and the last complete guide load is older than 12 hours.
2. `xmltv.php` can be hundreds of megabytes. `xmltv_loader.dart` downloads it in a background
   isolate and feeds the XML event stream to `XmltvReader`, which keeps only programmes of
   channels in the catalog (`epg_channel_id`) from three hours ago up to the configured days
   ahead. Programmes arrive in batches of 1000.
3. Programmes are stored in `epg_programmes` (`WITHOUT ROWID`, times as epoch seconds,
   primary key playlist, channel, start). Like channels, each load marks its rows and
   removes the rows of older loads when it completes.
4. Changing the number of days marks all guides as outdated; switching the guide off
   deletes them.

On the Fire TV Stick Lite a real provider guide (more than 85,000 programmes kept) loads in
about one minute in the background, with the app at about 120 to 145 MB.


## Playback

`PlaybackEngine` (`app/lib/features/player/domain/`) abstracts the player. The implementation
uses media_kit (libmpv with FFmpeg). On Android the hardware decoder (MediaCodec) renders
straight into the video surface (`vo=mediacodec_embed`, `hwdec=mediacodec`). The default
copy mode reads decoded frames back, which costs more CPU and shows striped green frames on
MediaTek chips such as the Fire TV Stick Lite. With direct rendering a 720p H.264 channel
needs about 45 % of one of four cores on that device. mpv warnings and errors are written to the platform log with the prefix `mpv`.

Live streams are requested as MPEG-TS (`/live/<user>/<password>/<id>.ts`). mpv reconnects
after short network drops. The screen stays awake during playback (wakelock).

## Not yet implemented

Favorites, channel number input, recently watched, catch-up, external XMLTV sources, HLS
output option and a configurable user agent.
