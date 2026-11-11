# Decisions

Decisions agreed with the project owner. Do not reopen them without the owner asking.

| Date       | Topic               | Decision                                                                  |
|------------|---------------------|---------------------------------------------------------------------------|
| 2026-11-11 | Client stack        | Flutter (Dart) with media_kit (libmpv / FFmpeg) as player                 |
| 2026-11-11 | State and data      | Riverpod, go_router, drift (SQLite), streaming parsers in isolates        |
| 2026-11-11 | Sync architecture   | Own API service in Dart with PostgreSQL, Docker image, in `server/`       |
| 2026-11-11 | Sync authentication | One household account per installation, profiles below it                 |
| 2026-11-11 | Credentials         | Playlist passwords synced encrypted, stored locally in secure storage     |
| 2026-11-11 | Minimum hardware    | Fire TV Stick Lite (armv7, about 1 GB RAM, Fire OS 7)                     |
| 2026-11-11 | License             | GPL-3.0                                                                   |
| 2026-11-11 | Avatars             | Bundled avatar set plus custom image where a file picker exists           |
| 2026-11-11 | Profile protection  | Optional 4-digit PIN per profile, parental controls later                 |
| 2026-11-11 | Settings scope      | Mixed: device settings and per-profile settings (see SET-1, SET-2)        |
| 2026-11-11 | Sources             | Xtream Codes first, provider abstraction for M3U and XMLTV later          |
| 2026-11-11 | Test deployment     | adb script for Fire TV now, GitHub Actions release builds later           |
| 2026-11-11 | Git and releases    | `develop` until first release, Conventional Commits, SemVer, changelog    |
| 2026-11-11 | Web support         | Best effort, browser codec and CORS limitations accepted                  |
| 2026-11-11 | Metadata            | Key-less sources first (TVmaze, Wikidata, Cinemeta), keyed sources later  |
| 2026-11-11 | Application ID      | `io.github.mawiak.tivibuddy` (Android package, iOS/macOS bundle ID)       |
| 2026-11-11 | Default profile PIN | A default profile with PIN asks for it directly on start, back shows picker |
| 2026-11-11 | Bundled avatars     | Drawn from icons and colours, no image assets                             |
| 2026-11-11 | Hosting             | GitHub `mawiak/tivibuddy`, private until the owner decides otherwise      |
| 2026-11-11 | Settings scope M4   | Framework, language, start profile, about; feature settings grow with features |
| 2026-11-11 | App language        | Per profile (system default), options read from ARB files                 |
