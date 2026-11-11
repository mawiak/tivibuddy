# AI guidelines

This folder contains everything an AI agent needs to work on TiviBuddy. It is the single source
of truth for requirements, conventions and decisions. Human-facing documentation lives in
`docs/`.

| File              | Purpose                                                          |
|-------------------|------------------------------------------------------------------|
| `requirements.md` | Every product and quality requirement with a stable ID           |
| `conventions.md`  | Code, architecture, documentation, git and release conventions   |
| `decisions.md`    | Decisions already taken with the project owner (do not reopen)   |
| `roadmap.md`      | Milestones in implementation order and their current status      |
| `workflow.md`     | Mandatory procedure and checklist for every unit of work         |

Rules for maintaining this folder:

- Keep it in English and without emojis.
- When the project owner adds or changes a requirement, update `requirements.md` in the same
  change and give new requirements a new ID. Never reuse IDs.
- When a decision is taken, append it to `decisions.md` with the date.
- When a milestone status changes, update `roadmap.md`.
