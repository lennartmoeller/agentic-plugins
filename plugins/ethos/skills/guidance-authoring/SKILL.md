---
name: guidance-authoring
description: Creates and edits `README.md`, `CONTRIBUTING.md`, `AGENTS.md` and `CLAUDE.md`, the guidance for people and agents across the repository, and keeps them current.
license: MIT
metadata:
  author: Lennart Möller
---

# Guidance authoring

These instructions govern every change to `README.md`, `CONTRIBUTING.md`, `AGENTS.md`, `CLAUDE.md` across the repository.
Always strictly follow them when creating or editing any of these.

## General rules

- When editing any of these files, use the `ethos:markdown-authoring` skill.
- Keep each file current, concise and focused on its reader's task.
- Give each fact or rule one canonical home and link to it instead of maintaining duplicate explanations.
- Keep implemented contracts in code, schemas, workflows and tests.

### `AGENTS.md` or `CLAUDE.md`

- Keep the repository's agent instructions in the one of `AGENTS.md` and `CLAUDE.md` it already has, and never add the other; where it has both or neither, write `AGENTS.md` in Copilot CLI and `CLAUDE.md` in Claude Code.
- Give coding agents concise repository-specific constraints and preferences governing their changes, rather than an implementation tour or contributor manual.
- Keep root rules repository-wide and place directory-only rules in nested instruction files at the relevant scope.
- State each rule as one imperative sentence an agent can check.

### `CONTRIBUTING.md`

- Maintain a root guide for contributors preparing, extending and verifying changes, including necessary local setup, authoring conventions and check procedures.
- Point to canonical commands and source contracts instead of copying architecture, package, dependency, API or schema catalogs.

### `README.md`

- Give humans a selective overview of the repository's purpose, high-level architecture and boundaries, how to start, and where authoritative guidance for each reader task lives.
- Link to contributor and task-specific guides for detailed procedures, keeping the overview focused rather than turning it into a complete repository manual.
