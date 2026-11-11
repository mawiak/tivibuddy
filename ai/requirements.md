# Requirements

Every requirement has a stable ID. Reference IDs in commits, docs and reviews where useful.
All requirements must be re-checked at the end of every unit of work (see `workflow.md`).

## PLAT - Platforms

- PLAT-1: Runs on Android (phone, tablet, Android TV, Amazon Fire TV), iOS, macOS, Windows,
  Linux.
- PLAT-2: Runs as a web application where technically possible. Web is best effort: codec,
  CORS and mixed-content limitations of browsers are accepted and documented.
- PLAT-3: Fire TV is the primary target for the first milestones.
- PLAT-4: The weakest supported device is the Fire TV Stick Lite (32-bit armv7, about 1 GB RAM,
  Fire OS 7 / Android 9). Android builds must include armeabi-v7a and arm64-v8a.
- PLAT-5: Intermediate builds must be installable on a Fire TV through adb with a single script.

## UI - User interface and experience

- UI-1: Layout, structure and remote-control navigation follow the TiviMate conventions
  (left navigation rail, channel list with EPG preview, EPG grid, OSD while playing, long-press
  context menus), so users do not need to relearn. No copied artwork, logos or branding.
- UI-2: Fully operable with a D-pad remote (up, down, left, right, select, back, menu,
  play/pause). Focus is always visible and never lost.
- UI-3: The UI responds fast and fluidly. Target 60 fps on Fire TV Stick Lite for scrolling
  lists and the EPG grid. No blocking work on the UI isolate.
- UI-4: The UI scales responsively from TV down to phones. Text that does not fit (for example
  channel and programme names in lists) scrolls as a marquee when focused or selected.
- UI-5: Touch, mouse and keyboard input work on the respective platforms.

## RES - Resource usage

- RES-1: Minimal RAM and CPU usage. Large data sets are never held completely in memory.
- RES-2: Images are cached with size limits and decoded at display size.
- RES-3: Lists and grids are virtualized and load data in pages.

## PROF - User profiles (CRUD)

- PROF-1: Multiple user profiles with name and picture, shown as a profile picker like Netflix
  or Fire TV.
- PROF-2: If no profile exists, the app starts with creating the first profile.
- PROF-3: Profile pictures: a bundled avatar set selectable with the D-pad, plus a custom image
  on platforms with a file picker.
- PROF-4: Optional 4-digit PIN per profile.
- PROF-5: A setting allows starting directly into a default profile. The profile picker is then
  only reachable through the menu.
- PROF-6: Full CRUD: create, read, update, delete profiles.

## PL - Playlists (CRUD)

- PL-1: Each profile can have multiple Xtream Codes playlists.
- PL-2: Full CRUD for playlists. Connection test when saving.
- PL-3: The architecture uses a source/provider abstraction so that M3U/M3U8 playlists and
  external XMLTV EPG URLs can be added later without restructuring. Only Xtream Codes is
  implemented initially.
- PL-4: Playlist passwords are stored in secure platform storage (Keystore / Keychain / OS
  credential store) locally.

## SET - Settings (CRUD)

- SET-1: Device settings (apply to the installation): default profile start, player and
  decoder options, buffer sizes, sync server configuration.
- SET-2: Profile settings (apply per profile): language, theme, preferred audio and subtitle
  languages, category order, hidden categories.
- SET-3: Settings can be viewed, changed and reset to defaults.

## DATA - Data handling

- DATA-1: Xtream responses (JSON) and EPG (XMLTV) can be very large. They are parsed in a
  background isolate with streaming parsers and written to the local database in batches.
- DATA-2: Updates are incremental where possible and never block the UI.
- DATA-3: The local database (SQLite) is the source of truth for the UI. Queries are indexed,
  paged and filtered in SQL.
- DATA-4: Per profile, the app tracks: favorites, watch progress (resume position), watched
  state, recently watched, for movies, series episodes and live channels.

## SYNC - Synchronization

- SYNC-1: Without sync configured, all data stays only in the local database.
- SYNC-2: With sync configured, profiles, playlists, settings marked as syncable, favorites,
  watch progress and watched state are synchronized with a self-hosted sync server.
- SYNC-3: Sync can be switched on and off at any time. Switching on merges local data into the
  server account. Switching off keeps the local copy.
- SYNC-4: The sync server is an API service in Dart (`server/`) backed by PostgreSQL and
  shipped as a Docker image. Clients never connect to the database directly.
- SYNC-5: Authentication with a household account (server URL, username, password). All
  profiles of the household belong to that account.
- SYNC-6: Playlist passwords are synchronized encrypted and stored encrypted on the server.
- SYNC-7: Offline first: changes are queued locally and synced when the server is reachable.
  Conflicts are resolved deterministically (last write wins per field with server timestamps,
  unless a requirement says otherwise).

## PLAY - Playback

- PLAY-1: Support as many video codecs, audio codecs, containers and streaming formats as
  possible (libmpv / FFmpeg based player).
- PLAY-2: Hardware decoding where available, with software fallback.
- PLAY-3: The player is behind an interface so that alternative backends (for example
  ExoPlayer / Media3 on Android) can be added.
- PLAY-4: Audio track and subtitle selection, resume playback for VOD.

## VOD - Movies and series

- VOD-1: Browse movies and series by category from the Xtream API, with search.
- VOD-2: Detail pages with Xtream metadata, enriched by external sources that need no API key
  (for example TVmaze, Wikidata, Cinemeta for IMDb ids and ratings). Sources requiring an API
  key (TMDB, OMDb, TheTVDB) are added later as optional, user-configurable sources.
- VOD-3: Metadata lookups are cached and do not block browsing.

## LIVE - Live TV

- LIVE-1: Channel list by category, channel switching with remote keys, EPG now/next.
- LIVE-2: EPG grid (TV guide) that stays fluid with large EPG data.
- LIVE-3: Catch-up / timeshift where the provider supports it (later milestone).

## I18N - Internationalization

- I18N-1: German and English are maintained by the project.
- I18N-2: Additional languages can be added through translation files (ARB) without code
  changes beyond registration.

## CODE - Code quality

- CODE-1: Clean, modular, readable code. Strict separation of UI (widgets), state/actions
  (controllers) and data (repositories, data sources).
- CODE-2: Current best practices for Flutter and Dart. Static analysis must pass without
  warnings.
- CODE-3: Business logic is covered by unit tests. Parsers are tested with fixtures.

## DOC - Documentation

- DOC-1: All documentation is written in English and without emojis.
- DOC-2: Documentation lives in `docs/`. AI-specific files live in `ai/`.
- DOC-3: Documentation is updated in the same change as the code it describes.

## REL - Release management

- REL-1: Conventional Commits (feat, fix, chore, docs, refactor, test, ci, perf, build).
- REL-2: Semantic Versioning, tags `vX.Y.Z`, `CHANGELOG.md` in Keep a Changelog format.
- REL-3: GitHub Actions build binaries for every platform for each release (later milestone).
- REL-4: Until the first release all work goes to `develop`. Afterwards `main` is the release
  branch and features are developed in feature branches.
