# Skills

how a skill is built - its description, opening, announcement, README entry and the way it starts its scripts - and where the skill that authors the skills lives

## skill-authoring is a skill of this repository, not of the plugin

**Id:** 844ac4fb-a164-42f3-ab5f-7729c4b68538
**Type:** decision
**Status:** active
**Evidence:** confirmed
**Source:** conversation with the maintainer, 2026-11-22; plugin validator run that day
**Verification:** contradicted — since 2026-11-25 the skills it governs are in plugins/*/skills/, which .claude/CLAUDE.md and the skill name, as 32e8dc09-dc9f-4edf-a9a5-2617d6f2d368 records; claude plugin validate . --strict passed on 2026-11-22 with .claude/CLAUDE.md and failed with a root CLAUDE.md
**Revisit when:** a consuming repository needs to author skills, or the validator stops warning about a CLAUDE.md at the plugin root
**See:** distribution.md#the-repository-consumes-its-own-plugin-from-skills — 6833aac8-e37a-4ca3-89e5-58992f58e2da — as of 2026-11-22
**See:** distribution.md#the-quality-gate-is-the-local-plugin-validator — b9080fe5-e1e6-46c2-a343-b965f798a07f — as of 2026-11-22
**See:** distribution.md#the-setup-travels-as-three-plugins-from-a-marketplace-in-this-repository — 32e8dc09-dc9f-4edf-a9a5-2617d6f2d368 — as of 2026-11-25

`skill-authoring` lives in `.claude/skills/skill-authoring/`, outside the plugin and its README, and `.claude/CLAUDE.md` holds the one rule that announces it: use it whenever creating or editing a skill in `skills/`.
It governs only the skills in `skills/`, so it is not bound by its own rules.

**Reason:** the maintainer stated that the skill serves only authoring the plugin's skills in this repository, which is confirmed.
Claude Code and Copilot CLI both load project skills from `.claude/skills/` and read `.claude/CLAUDE.md`, and a skill only this repository has is not listed twice beside the plugin's, unlike a plugin skill kept there.

**Rejected alternative:** a `CLAUDE.md` at the repository root.
The root is also the plugin root, where `claude plugin validate . --strict` warns that a `CLAUDE.md` is not loaded as project context, so the gate fails; the maintainer chose `.claude/CLAUDE.md` over dropping `--strict`.

**Rejected alternative:** governing the skills in `.claude/skills/` as well, itself included, as it did at first; the maintainer narrowed it to `skills/` on 2026-11-22 without stating why.

**Rejected alternative:** a SessionStart hook in `.claude/settings.json`, which Copilot CLI does not read.

**Consequence:** consumers no longer receive the skill, which is why the plugin's version went from 0.1.0 to 0.2.0.

## Each part of a skill has one job

**Id:** 240ad9b3-f152-4d51-add8-78cbefc798cb
**Type:** decision
**Status:** active
**Evidence:** confirmed
**Source:** planning conversation with the maintainer, 2026-11-22; best-practices documentation of Anthropic and skill documentation of Claude Code and Copilot CLI, read that day
**Verification:** contradicted — since 2026-11-25 the skills are in plugins/*/skills/ and the announcements in plugins/ethos/hooks/instructions/, which 32e8dc09-dc9f-4edf-a9a5-2617d6f2d368 records; Claude Code probes with its smallest model on 2026-11-22: asked to add a skill in a copy of this repository, it loaded skill-authoring in 2 of 3 runs and read its file in the third, and every skill it drafted kept all rules
**Revisit when:** a skill is found used late or not at all because its description no longer says when, or Copilot CLI is found invoking a skill that sets disable-model-invocation
**See:** skills.md#skill-authoring-is-a-skill-of-this-repository-not-of-the-plugin — 844ac4fb-a164-42f3-ab5f-7729c4b68538 — as of 2026-11-22
**See:** instructions.md#the-hook-says-which-skill-to-use-when — c57d2458-e2a9-4442-94a5-c172d62d7436 — as of 2026-11-22
**See:** distribution.md#the-setup-travels-as-three-plugins-from-a-marketplace-in-this-repository — 32e8dc09-dc9f-4edf-a9a5-2617d6f2d368 — as of 2026-11-25

Every skill in `skills/` is built the same way, and `skill-authoring` holds the rules.
The frontmatter description is one third-person sentence that says what the skill does and to what, never when to use it.
The announcement says when, as one list item "Use the `<skill>` skill <occasion>." without a purpose clause, at most one per skill and audience, in `hooks/instructions/`.
Every skill the agent may use on its own is announced, and every other one sets `disable-model-invocation: true`, which made `implement-plan` user-only.
A plugin skill's README entry repeats its description word for word.
The instructions open with the display name as the only H1, then "These instructions govern <what>." and "Always strictly follow them when <doing it>.", and any further intro text follows below.
A skill may name another skill of the plugin wherever it matters that the skills are used together, which can remind of when to use it.
The frontmatter has only the fields `name`, `description`, `license`, `compatibility`, `metadata`, `argument-hint` and `disable-model-invocation`, in that order, and `skill-authoring` defines when and how each is set, as the skills already set them; only `git-operations` lacked the `compatibility` its use of Git asks for.
The rules rest on `skill-authoring` alone.

**Reason:** the maintainer wants each part to have a uniform structure, purpose and meaning across all skills, which is confirmed.
The third person follows Anthropic's best practices, because the description is injected into the system prompt.
The coverage rule follows from descriptions that no longer say when: a skill the model may invoke without an announcement has no trigger left.
The reasons for the third person, the coverage rule, the announcement form and relying on the skill alone were put to the maintainer with each choice, and the maintainer accepted them.

**Rejected alternative:** a description that says both what the skill does and when to use it, as Anthropic's best practices and the documentation of Claude Code and Copilot CLI advise; the maintainer asked for what alone.

**Rejected alternative:** an imperative sentence or a noun phrase as the description.

**Rejected alternative:** announcing `implement-plan` in the hook, which puts a line into every session for a skill the user starts.

**Rejected alternative:** a purpose clause after the occasion, as the rules for `foundational-coding-principles` and `contract-authoring` had, or keeping the probed rules verbatim as exceptions.

**Rejected alternative:** naming another skill only in a procedure step that hands work over to it, never to restate when to use it.
The maintainer reverted it on 2026-11-22: naming another skill is no great harm where it reminds which skill to use when.

**Rejected alternative:** exempting the procedural skills `decision-dialogue`, `implement-plan` and `empty-house-refactoring` from the opening.

**Rejected alternative:** a script beside the validator that checks the rules, which adds a file and a second gate command.

**Consequence:** Copilot CLI documents no `disable-model-invocation`, so there a user-only skill may still be invoked on its description alone.
An edit made without `skill-authoring`, such as one to the README only, can drift unnoticed.
The sentence naming what a skill governs reads like the meta-intro that `markdown-authoring` says to skip; `skill-authoring` states the opening as a rule of its own, and `markdown-authoring` is unchanged.

## Every skill script is POSIX sh, started from the skill's base directory

**Id:** e2070f87-9e37-4962-a6de-58fd016dbc7e
**Type:** decision
**Status:** active
**Evidence:** inferred
**Source:** planning conversation with the maintainer, 2026-11-22; strings of the Claude Code 2.1.330 and Copilot CLI 1.0.114 binaries, read that day
**Verification:** corroborated — Claude Code probes with its smallest model on 2026-11-22 started all three scripts in this form, and setup.sh gave the same results as its Bash version under macOS sh, dash, Debian and Alpine; the maintainer reported the same day that Copilot CLI on another Mac, with the published 0.4.1, started all three scripts in this form and each did its work, so dash is covered by the local and container runs only
**Revisit when:** either tool stops printing a skill's base directory above its instructions, both tools gain one variable for a skill's folder, or a skill needs what POSIX sh lacks
**See:** skills.md#each-part-of-a-skill-has-one-job — 240ad9b3-f152-4d51-add8-78cbefc798cb — as of 2026-11-22
**See:** distribution.md#the-quality-gate-is-the-plugin-validator-and-shellcheck — c1c1889b-f38e-4971-85cb-9b090b76ee30 — as of 2026-11-22

Every script in a skill's `scripts/` folder is POSIX `sh`, starts with `#!/bin/sh` and `set -eu` and reaches the skill's other files through `$(dirname "$0")`.
Every `SKILL.md` names its script only as `sh "<this skill's base directory>/scripts/<script>.sh" <arguments>`, run with the repository as working directory, and the refusal of `hooks/guard.sh` names `context.sh` the same way.
`skill-authoring` holds the rule, and the quality gate runs ShellCheck on every script.
`decision-dialogue`'s `setup.sh` was ported from Bash for it, so the skill no longer requires Bash.

**Reason:** the maintainer asked for one way to start a skill's script that always works in both coding agents, after `decision-dialogue` had named its Bash script without an interpreter or a base directory; the form and the dialect are the maintainer's choice, which is confirmed.
That both tools print "Base directory for this skill:" above a skill's instructions is inferred from strings in their binaries and from a Copilot CLI run on 2026-11-21 that started `setup.sh` by its installed path.
`sh` is Bash on macOS, dash on Debian and Ubuntu and BusyBox on Alpine: started through `sh`, the Bash `setup.sh` worked on macOS and failed under dash with "set: Illegal option -o pipefail".

**Rejected alternative:** `bash` with every script in Bash, which makes Bash a requirement of every skill with a script and is missing on minimal images such as Alpine.

**Rejected alternative:** starting each script directly through its shebang, which needs an executable bit that `ship-change.sh` lacked and that zip downloads or `core.fileMode=false` lose, and which an agent's habit of prefixing `sh` breaks.

**Rejected alternative:** `${CLAUDE_SKILL_DIR}`, a plugin `bin/` folder on `PATH` and `CLAUDE_PLUGIN_ROOT`, which only Claude Code offers to a skill's shell commands.

**Rejected alternative:** a PowerShell twin of every script for native Windows, which doubles every script; the skills keep requiring a POSIX shell.

**Consequence:** scripts give up Bash conveniences such as `pipefail` and `[[ ]]`, and the quotes around the base directory keep a path with a space in one argument.
