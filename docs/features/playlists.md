# Playlists

Requirements: PL-1 to PL-4, SYNC-6.

## Behaviour

- Each profile has its own playlists. They are managed under Settings > Playlists.
- **Form:** server URL, username, password and name. Pasting a complete playlist link
  (`http://host:port/get.php?username=...&password=...`) into the server field fills server,
  username and password automatically. The name defaults to the server host.
- **Server URL normalization:** `http://` is added when missing, trailing slashes are removed.
- **Connection test:** calls `player_api.php` with the credentials and shows status, expiry
  date and connections. Saving always runs the test. When it fails (wrong credentials,
  unreachable, timeout, not an Xtream server) the user can still save the playlist.
- **Account info** of the last successful test is stored with the playlist and shown in the
  list.
- **Delete:** soft delete; the password is removed from secure storage. Deleting a profile
  deletes its playlists and passwords.

## Security

Passwords are never written to the database. They are stored with flutter_secure_storage
(Android Keystore, iOS/macOS Keychain, Linux libsecret, Windows DPAPI, WebCrypto on the web).
Synchronizing them encrypted (SYNC-6) is part of the sync milestone.

Most providers only offer plain HTTP. Cleartext traffic is therefore allowed on Android
(`usesCleartextTraffic`) and iOS/macOS (`NSAllowsArbitraryLoads`).

Building for Linux requires `libsecret-1-dev` for flutter_secure_storage.

## Code

| Layer        | Location                                                          |
|--------------|-------------------------------------------------------------------|
| Domain       | `app/lib/features/playlists/domain/` (entity, validation, interfaces) |
| Data         | `app/lib/features/playlists/data/` (drift, secure storage, Xtream client) |
| Application  | `app/lib/features/playlists/application/playlist_actions.dart`    |
| Presentation | `app/lib/features/playlists/presentation/`                        |

New source types (M3U) implement `ConnectionTester` and are added to `PlaylistType` and the
`connectionTesterProvider` switch.
