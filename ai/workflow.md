# Workflow

Mandatory procedure for every unit of work.

## Before starting

1. Read `requirements.md`, `conventions.md`, `decisions.md` and `roadmap.md`.
2. Identify the requirement IDs the work touches.
3. If a requirement is ambiguous or a new decision is needed, ask the project owner. Ask one
   topic at a time.

## While working

- Keep UI, actions (controllers) and data separated (CODE-1).
- Keep heavy work off the UI isolate (UI-3, DATA-1).
- Put every user-facing string into the ARB files for English and German (I18N-1).
- Keep every new screen fully D-pad operable (UI-2).

## Definition of done checklist

Run through this list before every commit series and report the result to the owner.

- [ ] `dart format` applied, `dart analyze` reports zero issues.
- [ ] Tests pass. New logic has tests.
- [ ] D-pad navigation works on the new screens, focus visible, back key behaves.
- [ ] Layout checked at TV size and phone size, long texts use marquee where needed.
- [ ] No blocking work on the UI isolate, lists virtualized, data paged.
- [ ] Strings localized in English and German.
- [ ] Sync-relevant entities have UUID, updated-at and soft-delete fields.
- [ ] Documentation in `docs/` updated, English, no emojis.
- [ ] `ai/` files updated if requirements, decisions or roadmap changed.
- [ ] `CHANGELOG.md` updated under `Unreleased` for user-visible changes.
- [ ] Commits are small Conventional Commits in English, author `mawiak`, no AI references.
- [ ] Build installed and smoke-tested on Fire TV (owner confirms) for milestone completion.
- [ ] All requirement IDs in `requirements.md` re-checked for regressions.
