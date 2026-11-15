# Roadmap

Implementation order agreed with the project owner. Status values: `planned`, `in progress`,
`done`.

| #  | Milestone                                                              | Status      |
|----|------------------------------------------------------------------------|-------------|
| 0  | Repository skeleton, guidelines, documentation                         | done        |
| 1  | App scaffold, workspace, theme, TV focus, i18n, adb deploy script      | done        |
| 2  | User profiles (CRUD), profile picker, avatars, PIN, default profile    | done        |
| 3  | Xtream Codes playlists (CRUD) per profile, connection test             | done        |
| 4  | Settings (device and profile)                                          | done        |
| 5  | Live TV: catalog, categories, channels, player, zapping, now/next      | done        |
| 6  | EPG grid (TV guide) with XMLTV loading                                 | done        |
| 7  | VOD movies: categories, grid, detail, playback, resume, favorites      | done        |
| 8  | VOD series: seasons, episodes, progress, watched state                 | done        |
| 9  | Metadata enrichment from key-less sources                              | planned     |
| 10 | Sync server (Dart, PostgreSQL, Docker) and client sync                 | planned     |
| 11 | CI and release builds for all platforms                                | planned     |
| 12 | M3U playlists, external XMLTV, catch-up, keyed metadata sources        | planned     |

Notes:

- Data models from milestone 2 on already carry the fields needed for sync (stable UUIDs,
  updated-at timestamps, soft-delete flags), so milestone 10 does not require migrations of
  existing semantics.
- Each milestone is tested on a Fire TV before it is marked `done`.
- Milestone 11 publishes a universal Android APK (all ABIs, agreed 2026-11-14) next to the
  per-ABI APKs, plus a proper release signing key instead of the debug key.
- Open item for web support: add `sqlite3.wasm` and `drift_worker.js` to `app/web/`.

## Backlog of detail features

Agreed with the owner on 2026-11-11: basics of every area first, details afterwards. Nothing
here may be dropped silently; when an item is implemented, remove it here and mention it in
`CHANGELOG.md`. Check this list when planning each milestone.

Live TV and player:

- Remember the chosen audio and subtitle track per channel or title; preferred audio and
  subtitle languages per profile (SET-2). Low priority for the owner (2026-11-14).
- Optional second playback engine (ExoPlayer / Media3) for instant audio track switching;
  mpv pauses about half a second for its refresh seek.
- Player options in the OSD: aspect ratio / zoom, playback speed for VOD, stream info
  (codec, resolution, bitrate), sleep timer.
- Buffer size as a device setting (SET-1); automatic software fallback when the hardware
  decoder fails (the decoder mode itself is a setting since 2026-11-15).
- Favorites for channels and a favorites category; recently watched channels.
- Channel number input with the remote; previous channel across channel lists.
- Catch-up / timeshift (LIVE-3), past programmes in the guide.
- Reminders and programme details for future programmes in the guide; guide search.
- Category order and hidden categories per profile (SET-2); hidden channels.
- Optional: hide the side menu entirely in the guide; autoplay the last channel in the
  preview on start; long-press context menus (UI-1).
- HLS output option and configurable user agent per playlist.
- Gzip-compressed XMLTV, external XMLTV sources (PL-3).

VOD and general:

- Search: case-insensitive umlauts, search in plot and cast, recent searches.
- Series: automatic next episode at the end, mark episodes or seasons watched by hand,
  context menu on posters (favorite, watched) in the grids.
- Metadata enrichment and caching (milestone 9).
