# Context authoring

how the plugin's context-authoring skill grew out of Keep the Why: our own skill, fixed settings without a configuration file, no upstream tools, scripts that read and write the context, and only rules that change what the agent does

## Keep the Why is maintained here as a modified copy

**Id:** 44f58d3d-c469-49f9-a1c5-b7d33334e9fc
**Type:** decision
**Status:** superseded
**Evidence:** confirmed
**Source:** conversation with the maintainer, 2026-11-21
**Revisit when:** an upstream release brings a change the consuming projects need
**See:** distribution.md#keep-the-why-is-a-copy-inside-the-plugin — e111390d-d6b9-4293-9d2a-d0e1995a96c0 — as of 2026-11-21
**Superseded by:** 1f4afe80-4b74-4216-9d04-6e106e663dfc

`skills/keep-the-why/` started as upstream Keep the Why at release 0.20.3 and is changed here, so it no longer follows upstream releases.
The schema version check, the migration history and the version fields in its frontmatter are gone, and so is the procedure that replaced the folder with an upstream release.

**Reason:** the skill was taken into the plugin so that its idea can be changed, and replacing it with an upstream release would undo every change, starting with the removed configuration.

**Rejected alternative:** a guide for porting chosen upstream changes, with `metadata.version` naming the release the copy is based on.
Not chosen; the maintainer preferred cutting the link without one.

**Rejected alternative:** keeping the migration history as a record of how the format evolved.
Not chosen, since nothing would read it any more.

**Consequence:** upstream fixes and improvements reach the skill only when adopted by hand.
A change to the format updates the context directories of the consuming projects in the same change.
The folder keeps upstream's licence file, which carries its copyright.

## context-authoring runs on fixed settings, with no configuration file

**Id:** f74d7caa-9ec7-48c0-bc62-74ba1e43a5bc
**Type:** decision
**Status:** active
**Evidence:** confirmed
**Source:** conversation with the maintainer, 2026-11-21
**Revisit when:** a consuming project needs to record differently from the others
**See:** context-authoring.md#keep-the-why-is-maintained-here-as-a-modified-copy — 44f58d3d-c469-49f9-a1c5-b7d33334e9fc — as of 2026-11-21
**See:** instructions.md#the-session-start-hook-sets-up-the-context-directory — c840f105-454f-4de6-b85a-47c2fe96d619 — as of 2026-11-21

The skill behaves as the settings in force on 2026-11-21 prescribed, written into its text as plain behaviour: it captures on its own, writes without a permission question when the case is clear, asks one question at a time and never asks for a ticket, with no update check, no timed consistency check and no check for unconfirmed entries at session start.
No project has a `.keep-the-why` and no home directory a `~/.keep-the-why/`, and the wizards, pins, families, timers and start-path guide went with them.
The context directory is always `docs/context/`, and a session instruction still changes the behaviour for that session.

**Reason:** the maintainer stated that the configuration in force is the configuration, which makes the per-project and per-developer files unnecessary.

**Rejected alternative:** upstream's design, with settings per project in `.keep-the-why` and per developer in `~/.keep-the-why/`.
Rejected for the reason above.

**Consequence:** the three consuming projects already shared these values, so none of them records differently.
A `See` line into another project names that repository's URL, since no project stores a `canonical` any more.
Several instances in one repository and families of projects are gone with the fields that told them apart.

## context-authoring runs without the upstream tools

**Id:** 6d40cda1-291e-4528-b2c6-dc4e1e8aca99
**Type:** decision
**Status:** needs-review
**Evidence:** confirmed
**Source:** conversation with the maintainer, 2026-11-21; probe of `keep-the-why-lint` 0.20.3.1 that day
**Revisit when:** a structural check of our own is built, or a malformed entry is found in a consuming project
**See:** context-authoring.md#context-authoring-runs-on-fixed-settings-with-no-configuration-file — f74d7caa-9ec7-48c0-bc62-74ba1e43a5bc — as of 2026-11-21

The skill no longer runs `keep-the-why-lint` after a write and no longer offers the linter in CI, the dashboard or the registry listing.

**Reason:** each of these tools reads `.keep-the-why`, and without it the linter stops with its error `E001` and checks nothing.

**Rejected alternative:** a minimal `.keep-the-why` kept only for the tools.
Rejected because the linter requires the very settings that were removed.

**Rejected alternative:** a structural check of our own, written together with the removal.
Rejected to keep that change to removing the configuration; it remains possible as a change of its own.

**Consequence:** nothing checks the structure of `docs/context/` mechanically, and the agent alone follows the format rules in the skill's specification.

## A script writes the context index

**Id:** d8318483-17f8-4fa9-8bbe-10844ba61a60
**Type:** decision
**Status:** superseded
**Evidence:** confirmed
**Source:** conversation with the maintainer, 2026-11-21
**Revisit when:** the index needs content that the topic files cannot carry
**See:** instructions.md#the-session-start-hook-sets-up-the-context-directory — c840f105-454f-4de6-b85a-47c2fe96d619 — as of 2026-11-21
**Superseded by:** 2bb81a2b-2f49-4dd2-ba07-7a5e069d1b9c

`skills/context-authoring/scripts/index.sh` writes `docs/context/index.md`: a fixed title, then every topic file sorted by name with the summary line that follows the topic file's title.
The session-start hook runs it, and the agent runs it after it adds, renames, splits or deletes a topic file or changes its summary; nobody edits the index by hand.
In a directory without topic files the index is the title alone, so the same script is the setup.

**Reason:** the index follows from the topic files by fixed rules, and the maintainer wants a script to do everything that can be done deterministically.

**Rejected alternative:** the index written by the agent under thirty-six fixed headings, `## 0` to `## Z`, as upstream specified.
The headings kept hand edits on concurrent branches apart, which a generated index settles by running the script again.

**Rejected alternative:** generating `docs/context/README.md` instead, which the agent recommended because GitHub shows a folder's README to someone browsing it.
Not chosen; the name `index.md` keeps the links to it working.

**Rejected alternative:** a generated `index.md` plus a fixed README with upstream's logo, written at setup.

**Rejected alternative:** further scripts for a new entry's Id and for checking the format; the Id comes from `uuidgen | tr A-F a-f`, and the format stays without a mechanical check.

**Consequence:** a topic file starts with its title and a summary line; the three consuming projects had their summaries moved out of their indexes into their topic files on 2026-11-21.
Someone browsing `docs/context/` on GitHub sees the file list, not the index.

## context-authoring holds only what changes what the agent does

**Id:** 001290d3-b7d2-449f-877c-e8a4d9accfe9
**Type:** decision
**Status:** active
**Evidence:** confirmed
**Source:** conversation with the maintainer, 2026-11-21
**Revisit when:** a consuming project needs a retrospective pass, an interview, unattended capture or a carry-over of decision records
**See:** context-authoring.md#keep-the-why-is-maintained-here-as-a-modified-copy — 44f58d3d-c469-49f9-a1c5-b7d33334e9fc — as of 2026-11-21

`skills/context-authoring/` is `SKILL.md` and the context script, written as short rules that each appear once.
Its upstream background, examples, help text, setup procedure and README template are gone, and so are its rules for sessions that write with nobody present, with the status `pending-confirmation`, for retrospective passes over a repository, for maintainer interviews and for carrying decision records into `docs/context/`.

**Reason:** the maintainer requires a skill to hold only instructions that change how the agent behaves, and stated that none of those four situations happens in the projects that use the skill.

**Rejected alternative:** deleting only the files nothing pointed to, keeping the wording of `SKILL.md`.
Rejected because its rules stood twice, in the core rules and in the workflow, and the whole text loads in every session.

**Rejected alternative:** limiting the change to the setup script and the hook.

**Consequence:** the text a session loads went from 24,381 to about 9,000 characters, the format included.
A request for one of the four situations gets the agent's general judgment, with no playbook.

## context-authoring is our own skill, inspired by Keep the Why

**Id:** 1f4afe80-4b74-4216-9d04-6e106e663dfc
**Type:** decision
**Status:** active
**Evidence:** confirmed
**Source:** conversation with the maintainer, 2026-11-21
**Revisit when:** the skill takes over larger parts of Keep the Why again
**See:** context-authoring.md#context-authoring-holds-only-what-changes-what-the-agent-does — 001290d3-b7d2-449f-877c-e8a4d9accfe9 — as of 2026-11-21

`skills/context-authoring/` replaces `skills/keep-the-why/`, renamed and without upstream's licence file, and the README states that it is inspired by Keep the Why and names its author.
Its format, before a reference file read when writing an entry, is part of `SKILL.md`, and the example entry and phrases copied word for word from upstream were replaced.

**Reason:** the maintainer judged the skill rewritten nearly entirely, and on that ground proposed the new name, the removal of the licence file and the single file together.

**Rejected alternative:** keeping upstream's licence file in the renamed folder, which the agent recommended because MIT asks copies or substantial portions to keep its notice and the file costs no context.
Not chosen; the maintainer preferred a notice in the README.

**Rejected alternative:** removing the licence file without any notice.

**Consequence:** the meaning of every field loads in every session with the rest of the skill, while the context script holds the syntax.
The tools list the skill as `agentic:context-authoring`.

## Scripts read and write the context directory

**Id:** 2bb81a2b-2f49-4dd2-ba07-7a5e069d1b9c
**Type:** decision
**Status:** active
**Evidence:** confirmed
**Source:** conversation with the maintainer, 2026-11-21
**Revisit when:** an agent needs an operation the script lacks, or the script refuses a well-formed entry
**See:** context-authoring.md#context-authoring-runs-without-the-upstream-tools — 6d40cda1-291e-4528-b2c6-dc4e1e8aca99 — as of 2026-11-21

`skills/context-authoring/scripts/context.sh`, with its `awk` program in `context.awk`, lists the themes and the entries of a theme, shows entries, and creates, changes and moves themes and entries.
The agent passes the heading, the field values and the body; the script makes the Id, checks every value against the format, writes the fields in their order, builds the locators of `See` and `Superseded by` from the cited entry's Id, and rewrites every `See` line that points to an entry whose heading or theme changes.
`docs/context/index.md` and the script that wrote it are gone, since listing the themes replaces the index.

**Reason:** the maintainer wants everything deterministic done by a script and the characters an agent spends on the context cut: listing a theme's entries takes about 4 to 6 % of reading its topic file, and writing the format by hand had let two of 220 entries put their fields out of order.

**Rejected alternative:** a script that only checks and orders the header fields, leaving the locators to the agent.

**Rejected alternative:** the labelled paragraphs of the body as options of their own, which would make changing one paragraph resend all of its kind.

**Rejected alternative:** one small script per task with a shared library, eight files and seven names to remember.

**Rejected alternative:** `python3`, which reads the format more clearly but adds a second language and a runtime that macOS without the Command Line Tools and Windows lack.

**Rejected alternative:** a command that deletes an entry nothing cites, which the agent recommended for entries recorded by mistake; the maintainer ruled it out because the skill forbids deleting entries.

**Rejected alternative:** an automated test in the quality gate, which the agent recommended because the script is the only writer of the context in three projects; the maintainer chose validation by probes.

**Consequence:** nothing deletes an entry; a theme disappears when its last entry moves out, and the unused type value `undefined` left the format, both proposed by the agent and approved by the maintainer.
Someone browsing `docs/context/` on GitHub sees the file list without summaries, and a later change to the script has no automated test.
The script uses only what BSD awk, GNU awk, mawk and BusyBox awk share.
