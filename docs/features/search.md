# Search

Requirements: VOD-1, DATA-3, UI-1 to UI-4.

## Behaviour

- The search section has one text field. Select opens the keyboard (on Fire TV the full
  screen system keyboard); results appear while typing, 300 ms after the last change, from
  two characters on.
- Results are listed in one row per kind with their number: channels, movies, series. At most
  50 per kind; a more specific query narrows them.
- Select on a channel plays it; the player then zaps through all channels from there.
  Movies and series open their detail pages.
- The query is kept while the app runs, so coming back from a result shows the same results.

## Implementation

The search runs in SQLite on the local catalogs of the selected playlist
(`LiveTvRepository.search`, `MovieRepository.search`, `SeriesRepository.search`) with a
`LIKE '%query%'` on the name; `%` and `_` in the query are escaped (`like_pattern.dart`).
SQLite compares ASCII letters case-insensitively, umlauts only in their exact case. Queries
run on the database isolate, so typing never blocks the UI.

The catalogs only exist after a section was opened once (or the catalog loaded in the
background); searching does not load catalogs by itself.
