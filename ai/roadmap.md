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
| 5  | Live TV: catalog, categories, channels, player, zapping, now/next      | in progress |
| 6  | EPG grid (TV guide) with XMLTV loading                                 | planned     |
| 7  | VOD movies: categories, grid, detail, playback, resume, favorites      | planned     |
| 8  | VOD series: seasons, episodes, progress, watched state                 | planned     |
| 9  | Metadata enrichment from key-less sources                              | planned     |
| 10 | Sync server (Dart, PostgreSQL, Docker) and client sync                 | planned     |
| 11 | CI and release builds for all platforms                                | planned     |
| 12 | M3U playlists, external XMLTV, catch-up, keyed metadata sources        | planned     |

Notes:

- Data models from milestone 2 on already carry the fields needed for sync (stable UUIDs,
  updated-at timestamps, soft-delete flags), so milestone 10 does not require migrations of
  existing semantics.
- Each milestone is tested on a Fire TV before it is marked `done`.
- Open item for web support: add `sqlite3.wasm` and `drift_worker.js` to `app/web/`.
