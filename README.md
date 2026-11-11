# TiviBuddy

TiviBuddy is an open source IPTV player for Android (including Fire TV and Android TV), iOS,
macOS, Windows, Linux and the web. Its layout and remote-control navigation follow the
established conventions of popular TV-first IPTV players, so users can switch without
relearning the interface.

Status: early development. Nothing is usable yet.

## Highlights (planned)

- Multiple user profiles with avatars and optional PIN
- Multiple Xtream Codes playlists per profile
- Video on demand (movies and series), live TV with EPG
- Watch progress, watched state and favorites per profile
- Optional synchronization through a self-hosted sync server (Docker)
- Broad codec and container support through libmpv / FFmpeg
- Remote-control first UI, responsive down to phones
- German and English, extensible through translation files

## Repository layout

| Path        | Content                                             |
|-------------|-----------------------------------------------------|
| `app/`      | Flutter client application (all platforms)          |
| `server/`   | Self-hostable sync API service (Dart, Docker image) |
| `packages/` | Shared Dart packages (for example sync contracts)   |
| `docs/`     | Project documentation                               |
| `ai/`       | Guidelines and requirement checklists for AI agents |
| `tool/`     | Developer scripts (build, deploy, release helpers)  |

## Documentation

Start with [docs/README.md](docs/README.md).

## License

TiviBuddy is licensed under the GNU General Public License v3.0. See [LICENSE](LICENSE).

TiviBuddy does not provide any content. Users are responsible for the playlists they add.
