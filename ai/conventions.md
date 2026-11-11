# Conventions

## Repository structure

- `app/` Flutter client. Feature-first structure:
  - `lib/core/` cross-cutting code (database, networking, logging, theme, focus helpers, i18n).
  - `lib/features/<feature>/` with sub-folders:
    - `domain/` entities and repository interfaces (pure Dart, no Flutter imports).
    - `data/` repository implementations, data sources, DTOs, mappers.
    - `application/` controllers and state (Riverpod notifiers). This is where actions live.
    - `presentation/` widgets and screens only. No business logic, no direct data access.
  - `lib/shared/` reusable widgets (focusable tiles, marquee text, dialogs).
- `server/` sync API service. Same layering: `domain`, `data`, `application`, `api` (routes).
- `packages/` shared pure Dart packages used by app and server (for example sync contracts).
- `tool/` scripts.

The repository is a Dart pub workspace so shared packages resolve without publishing.

## Code

- Dart and Flutter stable channel, latest versions. Null safety, sound types, no `dynamic`
  unless parsing raw JSON at the boundary.
- State management: Riverpod (with code generation). Navigation: go_router. Local database:
  drift (SQLite). Immutable models: freezed or plain final classes.
- Widgets never call repositories or HTTP directly. They read state and dispatch intents to
  controllers.
- Heavy work (parsing, bulk inserts, image decoding) runs off the UI isolate.
- Every focusable widget defines its focus behaviour explicitly. Use shared focus components
  instead of ad hoc `Focus` wrappers.
- All user-facing strings come from ARB localization files. No hard-coded UI text.
- Lints: `flutter_lints` plus stricter project rules in `analysis_options.yaml`.
  `dart analyze` must report zero issues.
- Formatting: `dart format`.
- Naming: files `snake_case.dart`, one public widget or class per file where practical.
- Comments explain why, not what. Public APIs of shared packages get doc comments.

## Documentation

- English only, no emojis, Markdown.
- Human docs in `docs/`, AI guidelines in `ai/`.
- Update docs in the same commit series as the code change.

## Git

- Conventional Commits, English, small and focused, imperative mood, lower-case summary,
  max 72 characters in the subject. Example: `feat(profiles): add avatar picker`.
- Author `mawiak`. No references to AI tools, no co-author trailers.
- Branching: `develop` until the first release. After that `main` holds releases only, work
  happens in `feat/<name>`, `fix/<name>` branches merged into `develop`.

## Releases

- Semantic Versioning, starting at `0.1.0`. Versions below `1.0.0` may contain breaking
  changes in minor releases.
- `CHANGELOG.md` follows Keep a Changelog. Every user-visible change adds an entry under
  `Unreleased`.
- Tags `vX.Y.Z`. The app version in `app/pubspec.yaml` matches the tag.
