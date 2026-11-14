# Movies

Requirements: VOD-1, VOD-2 (provider metadata), DATA-1 to DATA-4, RES-1 to RES-3, PLAY-1 to
PLAY-4 (resume), UI-1 to UI-4.

## Behaviour

- **Section layout (TV):** details of the focused movie at the top (backdrop, list name,
  title, year, duration, genre, rating, plot; loaded after focus rested for 300 ms), below
  them one row of posters with the next row peeking in; the focused row scrolls to the top.
  Select or right on "Movies" in the menu starts in the categories. The poster grid uses
  the full width. Left from the first column or
  back opens the categories next to it, focused on (and scrolled to) the selected one. Select
  or right on a category closes them and focuses the first poster; left or back from them
  opens the side menu. Phones show the grid with a category selector in the header.
- **Categories:** "Continue watching", "Favorites" and "All movies" (per profile), then the
  provider categories and "Update movies" last. A category switches the grid as soon as it
  gets focus. The playlist choice is shared with live TV.
- **Posters** show a progress bar for started movies, a check mark for watched ones and a
  star for favorites. The title scrolls when the poster has focus.
- **Detail page:** backdrop, poster, year, duration, genre, rating, plot, director and cast
  from `get_vod_info`, loaded on demand and cached for ten minutes. Actions: play or resume
  at the saved position, start over, add to or remove from favorites, mark as watched or not
  watched.
- **Player:**

  | Key                          | Action                                     |
  |------------------------------|--------------------------------------------|
  | Left / right                 | Seek 10 seconds back / forward (repeats)   |
  | Rewind / fast forward        | Seek 30 seconds                            |
  | Select, play / pause         | Pause and resume; retry after a failure    |
  | Up / info                    | Show the info bar                          |
  | Down                         | Info bar; down again opens the options     |
  | Menu                         | Options                                    |
  | Back                         | Leave the player                           |

  **Options** (shared with live TV, `player_options.dart`): a bar at the bottom with audio,
  subtitle and video track and their current value. Select opens a side panel with the tracks
  of that type, the selected one marked; audio and subtitles can be switched off. Track names
  combine language and channel layout, for example "German, 5.1 surround sound". Left or back
  closes the panel, up or back closes the options.

  The position is saved every 15 seconds and when the player closes. A movie within five
  minutes of its end counts as watched and starts from the beginning next time.

## Data

- `get_vod_categories` and `get_vod_streams` are loaded like the live catalog: the list is
  streamed through `loadXtreamArray` in a background isolate and written in batches to
  `movie_categories` and `movies` (cache, no sync columns). The catalog is refreshed when the
  section opens and the last load is older than 12 hours, and with "Update movies".
- `movie_states` holds resume position, duration, watched and favorite per profile and movie.
  It carries the sync columns; movies are identified by playlist id and stream id, which are
  the same on every device. Deleting a playlist or profile marks its states deleted.
- Grids are `PagedList`s with pages of 60 movies; favorites and continue watching are SQL
  joins with the states of the active profile.
- Playback URL: `/movie/<user>/<password>/<id>.<container_extension>`.

## Not yet implemented

Search, sorting, trailers, remembered and preferred audio and subtitle languages, metadata from external sources
(milestone 9). See the backlog in `ai/roadmap.md`.
