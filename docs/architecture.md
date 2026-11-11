# Architecture

## Overview

```
+------------------------- app/ (Flutter) -------------------------+
|  presentation   widgets and screens, focus handling, no logic     |
|       |                                                          |
|  application    Riverpod controllers: state and actions          |
|       |                                                          |
|  domain         entities, repository interfaces (pure Dart)      |
|       |                                                          |
|  data           repositories, drift database, Xtream client,     |
|                 parsers (background isolates), metadata sources, |
|                 sync client, secure storage                      |
+-------------------------------|----------------------------------+
                                | HTTPS (optional)
+-------------------------------v----------------------------------+
|  server/ (Dart)  sync API, household accounts, PostgreSQL        |
+------------------------------------------------------------------+
```

Shared contracts between app and server (sync DTOs, API paths) live in `packages/`.

## Client layers

- **Presentation** renders state and forwards user intents to controllers. It owns focus and
  layout only.
- **Application** contains controllers (Riverpod notifiers). They orchestrate use cases, call
  repositories and expose immutable state.
- **Domain** defines entities and repository interfaces. No Flutter or package dependencies
  beyond pure Dart.
- **Data** implements repositories with drift (SQLite), HTTP clients and secure storage.

## Local database

drift (SQLite) with a single `AppDatabase` (`app/lib/core/database/app_database.dart`). Tables
are defined in the data layer of their feature and registered there. Synchronizable tables
use the `SyncColumns` mixin: UUID v7 primary key, `createdAt`, `updatedAt` (UTC, stored as
ISO-8601 text with milliseconds) and a `deleted` flag. Rows are never removed directly.

Device-only settings live in a key-value table and are never synchronized.

On the web, drift needs `sqlite3.wasm` and `drift_worker.js` in `app/web/`. They are added
when web support is worked on.

## Startup and navigation

go_router with a redirect (`resolveRedirect`) that is re-evaluated whenever startup state,
the profile list or the active profile change:

1. `/startup` until the database is open and the default profile is resolved.
2. `/profiles/new` while no profile exists.
3. `/profiles` while no profile is active.
4. `/` (home) otherwise.

## Data flow for large provider data

1. The Xtream client downloads responses as byte streams.
2. A background isolate (`streamFromIsolate` in `core/data/isolate_stream.dart`) parses them
   with a streaming parser: `JsonArraySplitter` for JSON, `XmltvReader` on the event stream
   of the `xml` package for XMLTV.
3. Parsed records are written to SQLite in batches.
4. The UI reads paged, indexed SQL queries through `PagedList`. It never holds the full
   catalogue in memory.

See [Live TV](features/live-tv.md) for the concrete implementation.

## Sources

Playlist sources implement a common provider interface (categories, live streams, VOD, series,
EPG). Xtream Codes is the first implementation. M3U and external XMLTV follow later.

## Player

Playback goes through a player interface. The default implementation uses media_kit (libmpv
with FFmpeg) and hardware decoding where available. Other backends can be added per platform.

## Sync

The local database is always the source of truth for the UI. Syncable entities carry a UUID,
an updated-at timestamp and a soft-delete flag. When sync is enabled, a sync engine pushes
local changes and pulls remote changes from the self-hosted server. Details follow in the sync
milestone.
