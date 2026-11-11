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

## Data flow for large provider data

1. The Xtream client downloads responses as byte streams.
2. A background isolate parses them with a streaming parser (JSON, XMLTV).
3. Parsed records are written to SQLite in batched transactions.
4. The UI watches paged, indexed SQL queries. It never holds the full catalogue in memory.

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
