---
name: skill-authoring
description: Creates and edits the plugin's skills in `skills/` for Claude Code and Copilot CLI.
license: MIT
metadata:
  author: Lennart Möller
---

# Skill authoring

These instructions govern every skill in `skills/`.
Always strictly follow them when creating or editing one.

## Frontmatter

- Give every skill these frontmatter fields in this order, leaving out an optional one the skill does not need, and no other field:

  | Field | Rule |
  |---|---|
  | `name` | Required: the skill's folder name. |
  | `description` | Required: as [Description](#description) says. |
  | `license` | Required: `MIT`. |
  | `compatibility` | Only when the skill or its scripts need a tool outside the agent: "Requires <tools>.", naming each tool, with a minimum version where an older one fails. |
  | `metadata` | Required: `author: Lennart Möller`, and `inspired-by: <work> by <author>` when the skill builds on someone else's work. |
  | `argument-hint` | Only when the user passes the skill an argument: the argument in square brackets, quoted, such as `"[idea]"`. |
  | `disable-model-invocation` | Only `true`, where [Announcement](#announcement) asks for it. |

- Whenever a `compatibility` field changes, update the requirement list in [`install.sh`](../../../install.sh) to the combined requirements of all skills.

## Description

- Write the frontmatter `description` as exactly one sentence in the third person present that says what the skill does and to what, such as "Creates and edits GitHub Actions workflows, reusable actions, and reusable workflows."
- Never say in the description when to use or load the skill.

## Opening

- Open the instructions with the skill's display name as the only H1, followed by exactly these two sentences, and put any further intro text below them:

  ```markdown
  # <Display name>

  These instructions govern <what the skill governs>.
  Always strictly follow them when <doing that work>.
  ```

- Write the display name as the skill's name in words, in sentence case, such as "Markdown authoring" for `markdown-authoring`.

## Announcement

- Announce every skill the agent may use on its own, and set `disable-model-invocation: true` in the frontmatter of every other skill.
- Say when to use a skill in its announcement, a list item "Use the `<skill>` skill <occasion>." without a purpose clause.
- Announce a skill as `agentic:<name>` in `hooks/instructions/`: in `session.md` for a session only, in `subagent.md` for a subagent only, and in `shared.md` for both.
- Give each skill at most one announcement per audience.
- Name another skill of the plugin wherever it matters that the skills are used together.

## README entry

- List every skill in the README, a link to its `SKILL.md` followed by `<br/>` and exactly its frontmatter description.

## What instructions include

- Only include instructions that have an impact in the way the coding agent behaves.
- Keep out anything that fill the instructions with unnecessary information.

## Writing style

- Keep instructions short and to the point.
- Use the `agentic:markdown-authoring` skill to write instructions.

## Deterministic first

- Everything that can be done deterministically should be done deterministically (e.g. setting up folders, files, ...).
- Only create shell scripts in a `scripts/` folder in the skills folder.
- Write every script in POSIX `sh`, starting with `#!/bin/sh` and `set -eu`, reaching the skill's other files through `$(dirname "$0")` and passing ShellCheck, because `sh` is dash on Debian and Ubuntu, where a Bash feature that works on macOS fails.
- Name a script in the instructions only as `sh "<this skill's base directory>/scripts/<script>.sh" <arguments>`, run with the repository as working directory, because Claude Code and Copilot CLI both print a skill's base directory above its instructions, while every other way to the skill's folder, such as `${CLAUDE_SKILL_DIR}`, exists in Claude Code only.
