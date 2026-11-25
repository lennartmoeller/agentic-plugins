# Distribution

how the setup reaches its consumers: the plugin route, enabling it per repository, updates, the repository's own use, the quality gate and the copy of Keep the Why

## The setup travels as a plugin from a marketplace in this repository

**Id:** ce0294c5-2188-42ab-8212-5dc84f02dd31
**Type:** decision
**Status:** superseded
**Evidence:** confirmed
**Source:** planning conversation with the maintainer, 2026-11-21; plugin documentation of Claude Code and Copilot CLI read that day
**Revisit when:** cloud or CI agents become a required consumer, or either tool stops reading the Claude Code plugin format
**Superseded by:** 32e8dc09-dc9f-4edf-a9a5-2617d6f2d368

The skills and the instructions are offered as one plugin, `agentic`, from a marketplace in this repository in Claude Code's plugin format.
A repository enables it for everyone who works in it through its settings files.

**Reason:** it is the one distribution mechanism Claude Code and Copilot CLI share, down to the settings file a repository uses to enable a plugin.
It reaches the three required consumers without a copy anywhere: the maintainer's sessions in every repository, collaborators in the maintainer's repositories, and other people's projects.
Before, the setup was copied by hand into each repository, and within days one copy had fallen behind and another had deliberately replaced a rule.

**Rejected alternative:** a Git submodule in each consuming repository.
Rejected because every repository needs wiring, every clone needs a submodule init, and a repository that has not adopted it gets nothing.

**Rejected alternative:** one clone per machine, linked into the tools' user directories.
Rejected because collaborators and other people's projects receive nothing from their repository.

**Rejected alternative:** committed copies in each repository, kept identical by a sync job.
Rejected because it needs sync machinery and keeps a copy per repository, while its one advantage, reaching cloud and CI agents, is not required.

**Consequence:** agents that see only a repository's own content, such as cloud sessions and agents in CI, do not receive the setup.
No plugin format carries an always-on instructions file, which the entries in `instructions.md` answer.

## The plugin is enabled per repository, never at user level

**Id:** ef3b3b17-21ad-4f01-af7b-7f47c3c1e7a9
**Type:** decision
**Status:** active
**Evidence:** confirmed
**Source:** conversation with the maintainer, 2026-11-21
**Revisit when:** a repository the maintainer works in needs the setup without enabling it, or the skills stop loading where they do not apply
**See:** distribution.md#the-setup-travels-as-a-plugin-from-a-marketplace-in-this-repository — ce0294c5-2188-42ab-8212-5dc84f02dd31 — as of 2026-11-21
**See:** instructions.md#keep-the-why-loads-in-every-session — 8b43aba6-f8e4-403c-afa0-8a324899ee7e — as of 2026-11-21

A repository enables the plugin through its settings files, which are the only way in that the README describes, and the maintainer's own machine has no install at user level either.

**Reason:** at user level the skills, Keep the Why included, would load in every repository on the machine, other people's projects among them, which never chose the setup.

**Rejected alternative:** an install at user level, once per machine, which reaches every repository on it and was the README's first way in until 2026-11-21.
Rejected for the reason above.

**Consequence:** a repository the maintainer works in gets the setup only when it enables the plugin itself, and Claude Code needs one install per clone of it.

## Each tool is enabled in its own repository settings file

**Id:** 8df2f586-a07c-4864-a699-e695f04cd886
**Type:** decision
**Status:** active
**Evidence:** confirmed
**Source:** conversation with the maintainer, 2026-11-21; Copilot CLI's configuration and plugin reference read that day
**Verification:** contradicted — copilot help config of Copilot CLI 1.0.114, read on 2026-11-22, confirms that a trusted repository's .github/copilot/settings.json installs missing plugins, but says only user or managed settings count for automatic plugin updates, against the consequence's last sentence; and since 2026-11-22 install.sh, not the README, writes the two files
**Revisit when:** Copilot CLI is found not to install the plugin from `.github/copilot/settings.json`, or the two files are found to disagree
**See:** distribution.md#the-plugin-is-enabled-per-repository-never-at-user-level — ef3b3b17-21ad-4f01-af7b-7f47c3c1e7a9 — as of 2026-11-21
**See:** distribution.md#copilot-cli-users-update-by-running-the-installer-again — e1630404-374f-428f-aced-aac1f9e142de — as of 2026-11-22
**See:** distribution.md#a-one-line-installer-sets-the-plugin-up-in-a-repository — 8834f1f7-971a-4579-9d8c-ee2e5ad99c24 — as of 2026-11-22

The README tells a repository to enable the plugin for Claude Code in `.claude/settings.json` and for Copilot CLI in `.github/copilot/settings.json`, each with the marketplace and the plugin.
Only the Claude Code file carries `autoUpdate`.

**Reason:** a Copilot CLI user does not expect a Claude file to configure their tool, so each tool gets the file it is known for.

**Rejected alternative:** one `.claude/settings.json` for both tools, which Copilot CLI reads too and which the agent recommended because nothing has to be kept in step.
Rejected for the reason above.

**Consequence:** a repository keeps the marketplace and the plugin in two files.
Copilot CLI reads both, so a repository that has both declares the plugin to it twice, and its documentation does not say which file wins.
Copilot CLI ignores `autoUpdate` in a repository's settings and updates a plugin that a repository enables by itself.

## Consumers follow the latest commit on main

**Id:** 9b7ecff1-d64e-4ff1-ba50-ce6fc93c8391
**Type:** decision
**Status:** superseded
**Evidence:** confirmed
**Source:** planning conversation with the maintainer, 2026-11-21
**Revisit when:** a faulty commit on `main` breaks consumers, or a consumer needs to stay on an older state
**See:** distribution.md#the-setup-travels-as-a-plugin-from-a-marketplace-in-this-repository — ce0294c5-2188-42ab-8212-5dc84f02dd31 — as of 2026-11-21
**Superseded by:** 44830694-f21e-4370-a254-53196daeaadf

The plugin manifest carries no version number and the repository no release tags, so every commit on `main` is the release, and a consumer receives it with its next plugin update.

**Reason:** nothing has to be maintained per release, and a forgotten version bump cannot hold a change back.

**Rejected alternative:** a semantic version in the plugin manifest.
Rejected because consumers then move only when the version is raised, which costs a bump per release.

**Rejected alternative:** a commit pin in each consuming repository that an update bot raises.
Rejected because an update bot can track such a pin only through a custom rule, which not every bot offers, and an install at machine level follows the latest commit regardless.

**Consequence:** a faulty change reaches every consumer at once, and the plugin is the one dependency that is not pinned as the coding instructions ask for dependencies.
The plugin validator warns about the missing version on every run.

## The repository consumes its own plugin from skills/

**Id:** 6833aac8-e37a-4ca3-89e5-58992f58e2da
**Type:** decision
**Status:** superseded
**Evidence:** confirmed
**Source:** planning conversation with the maintainer, 2026-11-21; probes with the plugin validator that day
**See:** distribution.md#the-setup-travels-as-a-plugin-from-a-marketplace-in-this-repository — ce0294c5-2188-42ab-8212-5dc84f02dd31 — as of 2026-11-21
**Superseded by:** c7994d11-e181-41ee-8907-5f85ae5c6ef2

The skills sit in `skills/` at the repository root, and this repository enables its own plugin in `.claude/settings.json` like every other consuming repository.
A session here therefore runs on the published state of `main`, and `claude --plugin-dir .` loads the working tree instead.

**Reason:** `skills/` is the plugin's default folder and the only one the portable Agent Plugins standard allows, and the repository needs no special case to load its own setup.

**Rejected alternative:** keeping the skills under `.claude/skills/`, where both tools load them as the project's own, with the plugin manifest pointing at that folder.
Rejected because every skill is then listed twice in this repository once the plugin is installed on the machine, unless the repository switches the plugin off for itself and gets a hook of its own.

**Consequence:** a session in this repository does not see an unpublished change unless it is started with `--plugin-dir .`.

## The quality gate is the local plugin validator

**Id:** b9080fe5-e1e6-46c2-a343-b965f798a07f
**Type:** decision
**Status:** superseded
**Evidence:** confirmed
**Source:** planning conversation with the maintainer, 2026-11-21; probes with the plugin validator that day; conversation with the maintainer, 2026-11-22
**Verification:** corroborated — by the validator on 2026-11-22, which passed without warnings, also with --strict and --profile directory
**Revisit when:** a broken change reaches `main`
**See:** distribution.md#a-one-line-installer-sets-the-plugin-up-in-a-repository — 8834f1f7-971a-4579-9d8c-ee2e5ad99c24 — as of 2026-11-22
**Superseded by:** c1c1889b-f38e-4971-85cb-9b090b76ee30

`claude plugin validate . --strict` is the only check, run locally before a commit, and the repository has no CI workflow.

**Reason:** the validator checks the manifests, the hook file and every skill's frontmatter, and a local command needs no workflow and no dependency to pin.
The maintainer chose `--strict` once the validator reported nothing, so that a new warning fails the gate instead of joining the accepted ones.

**Rejected alternative:** a CI workflow that runs the same command on every pull request.
Rejected because it needs Claude Code in CI, actions pinned by commit and an update bot configuration to keep those pins current.

**Consequence:** a broken change can reach `main`, and with it every consumer, if nobody runs the gate.
Since 2026-11-22 the manifests carry every field the validator asks for, because the maintainer wants it to report nothing: a version, and a marketplace description, an author, an icon and an empty list of network hosts, which nothing reads while the plugin is not submitted to a plugin directory.
Until then the gate ran without `--strict` and accepted warnings about the description, the author and the version.
Since the installer replaced the README's install command on 2026-11-22, the validator advises a README line that installs the plugin from the marketplace, without changing its verdict; the maintainer accepted the advice, because the line it suggests installs at user level.

## Keep the Why is a copy inside the plugin

**Id:** e111390d-d6b9-4293-9d2a-d0e1995a96c0
**Type:** decision
**Status:** superseded
**Evidence:** confirmed
**Source:** conversation with the maintainer, 2026-11-21; installation guide of Keep the Why read that day
**Revisit when:** upstream publishes a release the projects need, or a plugin can bundle another plugin's skill by reference
**See:** distribution.md#the-setup-travels-as-a-plugin-from-a-marketplace-in-this-repository — ce0294c5-2188-42ab-8212-5dc84f02dd31 — as of 2026-11-21
**Superseded by:** 44f58d3d-c469-49f9-a1c5-b7d33334e9fc

`skills/keep-the-why/` is a copy of the upstream Keep the Why skill at release 0.20.3, taken the way its installation guide describes for a manual install: a clone at the release tag, of which only the skill's folder is copied.
A repository no longer enables Keep the Why as a plugin of its own and carries no hook for it.

**Reason:** one plugin then gives a project the whole setup.
Before, every repository enabled Keep the Why as a second plugin and carried a session-start hook that told the agent to load it.

**Rejected alternative:** keeping Keep the Why a separate plugin beside this one, as it was.
Rejected because every repository then carries two plugin entries and a hook.

**Consequence:** an upstream release reaches consumers only once the copy here is replaced by hand, as `CONTRIBUTING.md` describes.
The folder keeps upstream's licence file, and the tools list the skill as `agentic:keep-the-why`.

## Each release raises the plugin's semantic version

**Id:** 44830694-f21e-4370-a254-53196daeaadf
**Type:** decision
**Status:** superseded
**Evidence:** confirmed
**Source:** conversation with the maintainer, 2026-11-22; plugin loading documentation of Claude Code, read that day
**Verification:** uncorroborated — no consumer has updated to a raised version yet, and how Copilot CLI updates a plugin with a version is not documented
**Revisit when:** a release is found to have reached no consumer because its version was not raised, or Copilot CLI is found to update regardless of the version
**See:** distribution.md#consumers-follow-the-latest-commit-on-main — 9b7ecff1-d64e-4ff1-ba50-ce6fc93c8391 — as of 2026-11-22
**See:** distribution.md#the-quality-gate-is-the-local-plugin-validator — b9080fe5-e1e6-46c2-a343-b965f798a07f — as of 2026-11-22
**Superseded by:** 37d44193-9ce0-4022-a27f-cd313c3c06d0

`.claude-plugin/plugin.json` carries a semantic version, starting at 0.1.0, and `CONTRIBUTING.md` asks every change meant for consumers to raise it.

**Reason:** the maintainer wants `claude plugin validate .` to report nothing, and it warns about a plugin without a version.
Claude Code's documentation says that once a version is set, consumers receive a new commit only when the version changes, `autoUpdate` included.

**Rejected alternative:** no version, so that every commit on `main` is the release.
The agent recommended keeping it; the maintainer chose a clean validator over it.

**Consequence:** every release costs a version raise, and a commit on `main` without one reaches no Claude Code consumer; nothing checks that the version was raised.

## A one-line installer sets the plugin up in a repository

**Id:** 8834f1f7-971a-4579-9d8c-ee2e5ad99c24
**Type:** decision
**Status:** superseded
**Evidence:** confirmed
**Source:** planning conversation with the maintainer, 2026-11-22; Claude Code 2.1.330 and Copilot CLI 1.0.114 probed that day; Claude Code's plugin loading documentation read that day; the maintainer's test of the published one-liner on another machine that day
**Verification:** corroborated — install.sh run in throwaway repositories on 2026-11-22 for a first install, a re-run, a fresh clone, an older Claude Code install and a first Copilot CLI install, and the published one-liner run by the maintainer on another machine that day, where Copilot CLI installed the plugin on folder trust, a re-run found the install, and another repository kept the plugin off
**Revisit when:** either tool gains a command that writes a repository's plugin settings completely, or a consumer cannot pipe a script into bash
**See:** distribution.md#the-plugin-is-enabled-per-repository-never-at-user-level — ef3b3b17-21ad-4f01-af7b-7f47c3c1e7a9 — as of 2026-11-22
**See:** distribution.md#each-tool-is-enabled-in-its-own-repository-settings-file — 8df2f586-a07c-4864-a699-e695f04cd886 — as of 2026-11-22
**See:** distribution.md#each-release-raises-the-plugins-semantic-version — 44830694-f21e-4370-a254-53196daeaadf — as of 2026-11-22
**Superseded by:** b42b56b4-9067-4678-8275-2a3fe195180a

`install.sh` at the repository root, run as `curl -fsSL https://raw.githubusercontent.com/lennartmoeller/agentic-plugins/main/install.sh | bash` inside a consuming repository, lets the person pick Claude Code or Copilot CLI, shows the skills' combined requirements, and installs what is missing or updates an older install.
It writes only the chosen tool's repository settings file and runs only that tool's own plugin commands; for Copilot CLI it never runs `copilot plugin install`, which has no scope and would enable the plugin in every project, and leaves the install to Copilot CLI's folder trust.
The README gives only the one-liner, and offers running it again as the way to update Claude Code at once.

**Reason:** the maintainer wanted a setup in the style of Claude Code's own `curl … | bash` installer, stored on GitHub, instead of settings copied by hand.
For Claude Code, automatic updates stay the default, but they run in the background up to ten minutes after a session's first message and apply only from the next start, so the maintainer wants a person who cannot wait to update by running the installer again.

**Rejected alternative:** keeping the hand-written settings in the README beside the one-liner.
Rejected because two descriptions of the same settings would have to stay in step.

**Rejected alternative:** `scripts/install.sh`, a longer URL for a folder with one file.

**Consequence:** a change to `install.sh` reaches every person who runs it as soon as it lands on `main`, without a version raise, and the script also lands in every plugin cache because the plugin's source is the repository root.
A person who will not pipe a script reads `install.sh` to see what to write.

## The installer carries its own copy of the skills' combined requirements

**Id:** 40ac02ff-d60d-445e-b2b6-0d46561bed9c
**Type:** decision
**Status:** superseded
**Evidence:** confirmed
**Source:** planning conversation with the maintainer, 2026-11-22; Claude Code 2.1.330 and Copilot CLI 1.0.114 probed that day
**Revisit when:** the list in install.sh is found to differ from the skills' compatibility fields
**See:** distribution.md#a-one-line-installer-sets-the-plugin-up-in-a-repository — 8834f1f7-971a-4579-9d8c-ee2e5ad99c24 — as of 2026-11-22
**Superseded by:** b42b56b4-9067-4678-8275-2a3fe195180a

`install.sh` holds the combined requirements of all skills as a list, one requirement per line with its check, and `.claude/skills/skill-authoring/SKILL.md` asks that a change to a skill's `compatibility` field updates that list.

**Reason:** the maintainer found a hand-kept list far easier than deriving one: about 8 lines instead of about 25, with no download and no parser.

**Rejected alternative:** deriving the list at run time from every skill's `compatibility` field on `main`, which the agent recommended and the maintainer first chose so that each requirement keeps one home.
Rejected once it was clear that it needs a download of the repository, a parser of the field's prose and a table from tool names to commands.

**Consequence:** each requirement lives twice, in its skill and in the installer, and only the skill-authoring rule keeps them in step.

## The installer edits settings files with jq

**Id:** 3e17918d-34e8-4674-b2ca-d2e532795c53
**Type:** decision
**Type:** constraint
**Status:** active
**Evidence:** confirmed
**Source:** planning conversation with the maintainer, 2026-11-22; Claude Code 2.1.330 and Copilot CLI 1.0.114 probed that day
**Revisit when:** claude or copilot gains a command that writes the marketplace with autoUpdate and the enabled plugin into a repository's settings
**See:** distribution.md#a-one-line-installer-sets-the-plugin-up-in-a-repository — 8834f1f7-971a-4579-9d8c-ee2e5ad99c24 — as of 2026-11-22

`install.sh` merges the plugin's keys into a repository's settings file with one `jq` deep merge that keeps every other key, and reads the tools' `--json` output with `jq`.

**Reason:** neither tool writes the keys completely: `claude plugin marketplace add --scope project` never writes `autoUpdate`, and `copilot config --repo` refuses both `extraKnownMarketplaces` and `enabledPlugins`.
macOS ships `jq` since macOS 15.

**Rejected alternative:** working without `jq`, writing a missing file whole and asking the person to merge an existing one by hand.
Rejected because it adds code paths and a manual step in the case of a collaborator whose repository already has settings.

**Rejected alternative:** `python3` or `node`, neither of which is guaranteed, so a fallback would still be needed, at the cost of a second language.

**Consequence:** on most Linux distributions a person installs `jq` before the first run.

## The installer checks its own needs before the first question

**Id:** 50bf5903-1913-4d04-a064-c7ed4015e44c
**Type:** decision
**Status:** active
**Evidence:** confirmed
**Source:** planning conversation with the maintainer, 2026-11-22; Claude Code 2.1.330 and Copilot CLI 1.0.114 probed that day
**See:** distribution.md#a-one-line-installer-sets-the-plugin-up-in-a-repository — 8834f1f7-971a-4579-9d8c-ee2e5ad99c24 — as of 2026-11-22

`install.sh` checks a terminal at `/dev/tty`, a Git repository and `jq` before anything else, and a missing one ends the run with one line saying what to install or where to run it; it has no flags or environment variables.

**Reason:** the installer cannot carry on without any of them, unlike a skill's requirement, which the person may skip, and checking first wastes no answer.

**Rejected alternative:** listing them in the ✓/✗ list of the skills' requirements, which comes after the question about the agent, so a person could answer it before learning the run cannot finish.

**Rejected alternative:** flags that answer the questions, which nobody needs yet.

## The installer is self-contained and leaves the version comparison to the tools

**Id:** 7e1fc530-fa9a-497e-98ad-a8fe990fe44f
**Type:** decision
**Status:** active
**Evidence:** confirmed
**Source:** planning conversation with the maintainer, 2026-11-22; Claude Code 2.1.330 and Copilot CLI 1.0.114 probed that day; the maintainer's test of the published one-liner on another machine that day
**Verification:** corroborated — on 2026-11-22 claude plugin update moved an install staged at 0.3.0 to 0.3.1, and copilot plugin update reported a plugin installed from repository settings as already at the latest version, 0.3.1; a Copilot CLI update to a newer version is not observed yet
**Revisit when:** copilot plugin update is found not to update a plugin installed from repository settings
**See:** distribution.md#a-one-line-installer-sets-the-plugin-up-in-a-repository — 8834f1f7-971a-4579-9d8c-ee2e5ad99c24 — as of 2026-11-22

`install.sh` fetches nothing: the requirement list, the marketplace and plugin names and the settings it writes are in the file.
To update, it refreshes the marketplace and runs `claude plugin update --scope project` or `copilot plugin update`, which compare the installed version with the marketplace's and print the outcome.

**Reason:** the maintainer asked for a script that needs no resource but itself, and the tools already compare versions.

**Rejected alternative:** fetching `.claude-plugin/plugin.json` from `main` and comparing its version with the installed one before updating.
Rejected because it solves the version comparison a second time and needs `curl` inside the script.

## Copilot CLI users update by running the installer again

**Id:** e1630404-374f-428f-aced-aac1f9e142de
**Type:** decision
**Type:** constraint
**Status:** active
**Evidence:** confirmed
**Source:** planning conversation with the maintainer, 2026-11-22; copilot help config of Copilot CLI 1.0.114 read that day
**Revisit when:** Copilot CLI honours autoUpdate in a repository's settings, or a Copilot CLI user is found on an old version
**See:** distribution.md#a-one-line-installer-sets-the-plugin-up-in-a-repository — 8834f1f7-971a-4579-9d8c-ee2e5ad99c24 — as of 2026-11-22
**See:** distribution.md#each-tool-is-enabled-in-its-own-repository-settings-file — 8df2f586-a07c-4864-a699-e695f04cd886 — as of 2026-11-22

For Copilot CLI, `install.sh` writes nothing outside the repository, and the README tells Copilot CLI users to run it again to update.

**Reason:** Copilot CLI's help says plugin updates at session start cover only its built-in marketplace and marketplaces with `autoUpdate` in user or managed settings, "repository settings do not count", so a plugin enabled in `.github/copilot/settings.json` never updates by itself.
The maintainer chose the update the installer runs over writing user settings.

**Rejected alternative:** offering to register the marketplace with `autoUpdate` in `~/.copilot/settings.json`, which enables nothing in other projects.
Rejected because it writes outside the repository, and whether it covers a plugin installed from repository settings is unverified.

**Consequence:** a Copilot CLI user stays on their installed version until they run the installer or `copilot plugin update`.

## The installer restores the settings text that claude plugin install only reorders

**Id:** 320443c8-903c-4bf6-95b3-6db5c737a2aa
**Type:** workaround
**Status:** active
**Evidence:** inferred
**Source:** probe of Claude Code 2.1.330 in a fresh clone of a repository with committed settings, 2026-11-22
**Verification:** corroborated — after the restore, git status of that clone stayed clean
**Revisit when:** claude plugin install keeps the key order of an existing settings file
**See:** distribution.md#a-one-line-installer-sets-the-plugin-up-in-a-repository — 8834f1f7-971a-4579-9d8c-ee2e5ad99c24 — as of 2026-11-22

At its end, `install.sh` writes the settings file's original text back when its content, compared with sorted keys, did not change.

**Reason:** `claude plugin install --scope project` rewrites `.claude/settings.json` in its own key order even when every key is already there, which would leave a collaborator's fresh clone with a modified committed file and the installer asking for a commit.

**Consequence:** the comparison also decides whether the installer asks the person to commit the file.

## The quality gate is the plugin validator and ShellCheck

**Id:** c1c1889b-f38e-4971-85cb-9b090b76ee30
**Type:** decision
**Status:** superseded
**Evidence:** confirmed
**Source:** planning conversations with the maintainer, 2026-11-21 and 2026-11-22; probes with the plugin validator and ShellCheck 0.11.0 on 2026-11-22
**Verification:** corroborated — on 2026-11-22 both commands passed on every shell script, and ShellCheck reported all five Bash-only constructs of the former setup.sh
**Revisit when:** a broken change reaches main
**See:** distribution.md#a-one-line-installer-sets-the-plugin-up-in-a-repository — 8834f1f7-971a-4579-9d8c-ee2e5ad99c24 — as of 2026-11-22
**Superseded by:** 067d2a37-bb9b-4595-af03-ad87ab90669e

`claude plugin validate . --strict` and `shellcheck --severity=warning install.sh hooks/*.sh skills/*/scripts/*.sh`, listed in `CONTRIBUTING.md`, are the checks, run locally before a commit, and the repository has no CI workflow.

**Reason:** the validator checks the manifests, the hook file and every skill's frontmatter, and a local command needs no workflow and no pinned action.
The maintainer chose `--strict` once the validator reported nothing, so that a new warning fails the gate instead of joining the accepted ones.
The maintainer added ShellCheck on 2026-11-22, because `sh` is Bash on macOS, where a Bash-only script passes every local run and fails only where `sh` is dash or BusyBox; ShellCheck reports such constructs statically and adds no file.
Severity `warning` leaves out style and info findings, such as the intended `$` in the GraphQL queries of `ship-change.sh`, and `install.sh` and the hooks are checked too, so one command covers every shell script.

**Rejected alternative:** a CI workflow that runs the same commands on every pull request, because it needs Claude Code in CI, actions pinned by commit and an update bot configuration to keep those pins current.

**Rejected alternative:** the rule for scripts in `skill-authoring` alone, without ShellCheck, which lets a Bash-only script ship unnoticed.

**Rejected alternative:** a script of our own that also checks how each `SKILL.md` names its script, a file of the kind turned down for the skill-structure rules.

**Consequence:** a broken change can reach `main`, and with it every consumer, if nobody runs the gate, and the maintainer needs ShellCheck installed.
The manifests carry every field the validator asks for, because the maintainer wants it to report nothing: a version, and a marketplace description, an author, an icon and an empty list of network hosts, which nothing reads while the plugin is not submitted to a plugin directory.
The validator advises a README line that installs the plugin from the marketplace, without changing its verdict; the maintainer accepted the advice, because the line it suggests installs at user level.

## CI runs the quality gate through mise

**Id:** 067d2a37-bb9b-4595-af03-ad87ab90669e
**Type:** decision
**Status:** active
**Evidence:** confirmed
**Source:** conversation 2026-11-22
**Verification:** contradicted — since 2026-11-25 the gate validates . and each plugins/* folder in a loop and ShellCheck covers install.sh plugins/*/hooks/*.sh plugins/*/skills/*/scripts/*.sh, which 32e8dc09-dc9f-4edf-a9a5-2617d6f2d368 records
**Revisit when:** a broken change reaches main
**See:** distribution.md#the-quality-gate-is-the-plugin-validator-and-shellcheck — c1c1889b-f38e-4971-85cb-9b090b76ee30 — as of 2026-11-22
**See:** distribution.md#the-setup-travels-as-three-plugins-from-a-marketplace-in-this-repository — 32e8dc09-dc9f-4edf-a9a5-2617d6f2d368 — as of 2026-11-25

`mise run check` runs `claude plugin validate . --strict`, `shellcheck --severity=warning install.sh hooks/*.sh skills/*/scripts/*.sh` and actionlint, locally and as CI's required `Quality` check on every pull request.
`mise.toml` pins Claude Code as the native binary of `aqua:anthropics/claude-code`, ShellCheck and actionlint, and Renovate keeps those pins, by the Git tags of `anthropics/claude-code`, and the workflows' action pins current.

**Reason:** What made a CI workflow too costly, Claude Code in CI, actions pinned by commit and an update bot configuration, is now the mise and Renovate setup every public repository of the maintainer shares, and since every merge releases to every consumer, a gate nobody runs no longer suffices.
The validator needs no login: it passed with Claude Code 2.1.330 in an empty home directory on 2026-11-22.
The reasons for `--strict`, for ShellCheck and for its `warning` severity are unchanged.

**Rejected alternative:** Keeping the gate local only, which lets a change nobody checked release to every consumer.

**Rejected alternative:** Claude Code from npm through mise's `npm:` backend, which needs Node and whose install hung after downloading 347 MB on 2026-11-22, while the native binary installed in 29 seconds.

## The release raises the plugin's version

**Id:** 37d44193-9ce0-4022-a27f-cd313c3c06d0
**Type:** decision
**Status:** active
**Evidence:** confirmed
**Source:** conversation 2026-11-22
**Verification:** contradicted — the computing action, which 7a599839 names as release-from-conventional-commits instead of next-version, the release on every merge, which 9d159a76-584a-4144-8a68-e5ae6114c437 replaces with a manual run, and the one manifest, which a1d4071c-aaf4-4e91-a040-0d265fe6c0d4 replaces with every plugin's
**Revisit when:** a release is found to have reached no consumer, or Copilot CLI is found to update regardless of the version
**See:** distribution.md#each-release-raises-the-plugins-semantic-version — 44830694-f21e-4370-a254-53196daeaadf — as of 2026-11-22
**See:** distribution.md#the-release-runs-release-from-conventional-commits-which-also-creates-the-github-release — 7a599839-67d0-4c4f-ad4b-3c6d1f33ddbb — as of 2026-11-25
**See:** distribution.md#the-release-runs-only-when-the-maintainer-starts-it — 9d159a76-584a-4144-8a68-e5ae6114c437 — as of 2026-11-25
**See:** distribution.md#the-plugins-share-one-version — a1d4071c-aaf4-4e91-a040-0d265fe6c0d4 — as of 2026-11-25

Every merge to `main` releases: `lennartmoeller/next-version` computes the version from the pull request title, and the release writes it into `.claude-plugin/plugin.json`, commits `chore(release): <version> [skip ci]` and tags `v<version>`.
`CONTRIBUTING.md` no longer asks a change to raise the version by hand.

**Reason:** Claude Code updates a plugin only when its version changes, so every release must raise it, and a version raised by hand was neither derived from the change's type nor checked. The validator still wants a version.

**Rejected alternative:** Raising the version by hand in each change meant for consumers.

**Consequence:** Every merge, Renovate's included, reaches every Claude Code consumer. The setup's breaking pull request moved the version from 0.5.0 to 1.0.0.

## The release runs release-from-conventional-commits, which also creates the GitHub release

**Id:** 7a599839-67d0-4c4f-ad4b-3c6d1f33ddbb
**Type:** decision
**Status:** active
**Evidence:** inferred
**Source:** conversation 2026-11-25
**Verification:** contradicted — since 2026-11-25 write_version sets the version in every plugins/*/.claude-plugin/plugin.json, which a1d4071c-aaf4-4e91-a040-0d265fe6c0d4 records
**Revisit when:** a release attaches files, or a change to a skill is merged under a type that releases nothing
**See:** distribution.md#the-release-raises-the-plugins-version — 37d44193-9ce0-4022-a27f-cd313c3c06d0 — as of 2026-11-25
**See:** https://github.com/lennartmoeller/release-from-conventional-commits — 46669e3b-4e28-444e-a992-4a5a52811336 — as of 2026-11-25
**See:** distribution.md#the-plugins-share-one-version — a1d4071c-aaf4-4e91-a040-0d265fe6c0d4 — as of 2026-11-25

The release workflow has one job, which runs `lennartmoeller/release-from-conventional-commits` pinned by commit with a `write_version` script that sets the version in `.claude-plugin/plugin.json` through `yq`; the action calculates the version from the pull request titles since the last version, commits, tags, pushes over the release deploy key and creates the GitHub release.

**Reason:** The maintainer moved the repository to the action that replaced `next-version`. The separate release job is gone because this repository attaches no files to its releases, which is when the action creates the release itself; that part is inferred from the action's documented use.

**Rejected alternative:** Keeping the release job with `create_github_release` set to `false`, which repeats the action's release step and needs an `if:` for merges that release nothing.

**Consequence:** A merge whose title has a type in the action's default `no_release_types`, `build ci docs refactor style test`, adds no bump, so a release covering only such merges releases nothing and their changes reach Claude Code consumers only with a later release; the history so far used those types only for files outside the plugin.

## The release runs only when the maintainer starts it

**Id:** 9d159a76-584a-4144-8a68-e5ae6114c437
**Type:** decision
**Status:** active
**Evidence:** confirmed
**Source:** conversation 2026-11-25
**See:** distribution.md#the-release-runs-release-from-conventional-commits-which-also-creates-the-github-release — 7a599839-67d0-4c4f-ad4b-3c6d1f33ddbb — as of 2026-11-25
**See:** distribution.md#the-release-raises-the-plugins-version — 37d44193-9ce0-4022-a27f-cd313c3c06d0 — as of 2026-11-25

The release workflow has only a `workflow_dispatch` trigger, so a merge to `main` releases nothing until the maintainer runs the workflow, and that run releases every commit since the last version.

**Reason:** The maintainer does not want to release on every merge.

**Rejected alternative:** Releasing on every push to `main`, the trigger the workflow had in `agentic`.

**Consequence:** Claude Code consumers get merged changes only once a release raises the version, while Copilot CLI consumers, who update from `main`, get them on their next `copilot plugin update`; this difference is inferred from how each tool updates, as the distribution contract describes.

## The plugin starts over at 0.1.0 in agentic-plugins

**Id:** 381ffe2a-a760-473a-a124-40ff888116ef
**Type:** decision
**Status:** active
**Evidence:** confirmed
**Source:** conversation 2026-11-25
**See:** distribution.md#the-release-runs-only-when-the-maintainer-starts-it — 9d159a76-584a-4144-8a68-e5ae6114c437 — as of 2026-11-25

`.claude-plugin/plugin.json` carries `0.0.0` and the repository has no tags, so its first release with a `feat` bump is `0.1.0`, instead of continuing from `agentic`'s `1.0.0`.

**Reason:** The maintainer wants the first release of `agentic-plugins` to be `0.1.0`.

**Rejected alternative:** Continuing at `agentic`'s `1.0.0`.

**Consequence:** A consumer who moves from `agentic` sees the version go from `1.0.0` to `0.x`, which Claude Code treats as a change like any other, since it updates whenever the version differs.

## The setup travels as three plugins from a marketplace in this repository

**Id:** 32e8dc09-dc9f-4edf-a9a5-2617d6f2d368
**Type:** decision
**Status:** active
**Evidence:** confirmed
**Source:** planning conversation with the maintainer, 2026-11-25; probes with Claude Code 2.1.330 and Copilot CLI 1.0.114 that day
**Verification:** corroborated — on 2026-11-25 Claude Code and Copilot CLI each installed list-github-findings alone from a local copy of the three-plugin marketplace, Claude Code's cache held only that plugin's folder, and an installed agentic whose marketplace entry was renamed to ethos failed to load with 'Plugin agentic not found in marketplace lennartmoeller' while ethos loaded
**Revisit when:** a skill is needed by more than one plugin, or either tool stops installing a plugin from a sub-folder of a marketplace
**See:** distribution.md#the-setup-travels-as-a-plugin-from-a-marketplace-in-this-repository — ce0294c5-2188-42ab-8212-5dc84f02dd31 — as of 2026-11-25

The marketplace `lennartmoeller` offers three plugins, each in its own folder under `plugins/`: `ethos` with the hooks and every skill but two, and `empty-house-refactoring` and `list-github-findings` with that one skill each.
`ethos` is the former `agentic`, renamed with the split, and its skills are announced as `ethos:<skill>`.
A repository enables any combination, and each plugin works without the others.

**Reason:** the maintainer split off the two user-invoked special cases, which nothing else references, so that a repository takes them without the core, or the core without them, which is confirmed.
The maintainer chose `ethos` for the core, the guiding beliefs and practices of a craft, so that the name says the plugin carries a way of working; the rename rides on the split's release, which already asks every consumer to run the installer again.
The reasons for the marketplace route itself are those of the entry this one replaces, and they are unchanged.

**Rejected alternative:** keeping the name `agentic`, which leaves every consumer's `agentic@lennartmoeller` and every `agentic:<skill>` announcement valid.

**Rejected alternative:** `base`, which is short but generic enough to clash with another marketplace's plugin and suggests that the other two plugins depend on it.

**Rejected alternative:** `house-rules`, the agent's first proposal, which the maintainer asked to improve on.

**Rejected alternative:** keeping the core at the repository root with the two new plugins in sub-folders, which copies the other plugins, the docs and the installer into every cache of the core.

**Rejected alternative:** shorter plugin names with renamed skills, such as `github-findings:list`; each single-skill plugin carries its skill's name instead, and Claude Code 2.1.330 runs `/list-github-findings` without the plugin prefix.

**Consequence:** a plugin's cache holds only its own folder, so the installer and the docs no longer reach consumers.
A repository set up before the split keeps `agentic@lennartmoeller` in its settings, since the installer only adds keys; Claude Code then lists `agentic` as failed to load, not found in the marketplace, and loads none of its hooks, until the line is deleted and the plugin uninstalled by hand.
Such a repository gets `ethos` and the two single-skill plugins only by running the installer again and saying yes to them.
The maintainer released the split as a feature, `0.2.0`, rather than as a breaking `1.0.0`, because the repository started over at `0.1.0` on purpose.
Every plugin carries the same portrait as `.claude-plugin/icon.png` and a description, a single-skill plugin its skill's description word for word, because the validator looks only inside the plugin folder, `--strict` fails without a description, and the maintainer wants the validator to report nothing.
Validating the marketplace does not validate the plugins it lists, so the quality gate validates each plugin folder as well.

## The repository consumes its own three plugins from plugins/

**Id:** c7994d11-e181-41ee-8907-5f85ae5c6ef2
**Type:** decision
**Status:** active
**Evidence:** confirmed
**Source:** planning conversation with the maintainer, 2026-11-25
**See:** distribution.md#the-setup-travels-as-three-plugins-from-a-marketplace-in-this-repository — 32e8dc09-dc9f-4edf-a9a5-2617d6f2d368 — as of 2026-11-25
**See:** distribution.md#the-repository-consumes-its-own-plugin-from-skills — 6833aac8-e37a-4ca3-89e5-58992f58e2da — as of 2026-11-25

The plugins sit in `plugins/<name>/`, each with its skills in its own `skills/`, and this repository enables all three in `.claude/settings.json` and `.github/copilot/settings.json` like every other consuming repository.
A session here therefore runs on the published state of `main`, and `claude --plugin-dir plugins` loads the working tree of all three instead.

**Reason:** every skill stays available here as before, and the repository uses each plugin as a consumer does, so a broken split shows here first; the maintainer chose all three, which is confirmed.
The reasons of the entry this one replaces for `skills/` inside the plugin and against `.claude/skills/` are unchanged.

**Rejected alternative:** enabling only `ethos`, which leaves the two single-skill plugins tried only through `--plugin-dir`.

**Consequence:** a session in this repository does not see an unpublished change unless it is started with `--plugin-dir plugins`.

## The installer asks about each plugin and updates the ones already set up

**Id:** b42b56b4-9067-4678-8275-2a3fe195180a
**Type:** decision
**Status:** active
**Evidence:** inferred
**Source:** planning conversation with the maintainer, 2026-11-25; Claude Code 2.1.330 and 2.1.332 and Copilot CLI 1.0.114 probed that day
**Verification:** corroborated — on 2026-11-25 install.sh, pointed at a local copy of the marketplace, set up single plugins, updated them on a re-run and wrote nothing when every plugin was declined, in throwaway repositories under Bash 3.2; the published one-liner and a Copilot CLI re-run against GitHub are not observed yet
**Revisit when:** either tool gains a command that writes a repository's plugin settings completely, a consumer cannot pipe a script into bash, or the requirement table is found to differ from the skills' compatibility fields
**See:** distribution.md#the-setup-travels-as-three-plugins-from-a-marketplace-in-this-repository — 32e8dc09-dc9f-4edf-a9a5-2617d6f2d368 — as of 2026-11-25
**See:** distribution.md#a-one-line-installer-sets-the-plugin-up-in-a-repository — 8834f1f7-971a-4579-9d8c-ee2e5ad99c24 — as of 2026-11-25
**See:** distribution.md#the-installer-carries-its-own-copy-of-the-skills-combined-requirements — 40ac02ff-d60d-445e-b2b6-0d46561bed9c — as of 2026-11-25

`install.sh` at the repository root, run as `curl -fsSL https://raw.githubusercontent.com/lennartmoeller/agentic-plugins/main/install.sh | bash` inside a consuming repository, lets the person pick Claude Code or Copilot CLI, updates every plugin already set up for that tool without a question, and asks yes or no for each other plugin, naming it only.
It shows one ✓/✗ row per requirement that a plugin set up or chosen needs, each row naming the plugins that need it, and leaves the list out when none does; `empty-house-refactoring`'s Git has no row, because the installer refuses to run outside a Git repository.
Before it installs or updates for Claude Code, it refreshes its copy of the marketplace.

**Reason:** the maintainer chose one run that sets up any combination, with a re-run staying the way to update everything already there, which is confirmed.
Naming the plugins without a description, leaving out the Git row and refreshing the marketplace were the agent's proposals, which the maintainer approved with the plan.
The refresh is there because a repository set up before the split holds a copy of the marketplace that lists `agentic` alone, and Claude Code, when it cannot find a plugin, says the local copy may be out of date; that it would fail without the refresh is inferred from that message.
The reasons of the entries this one replaces for a one-line installer and for a hand-kept requirement table are unchanged.

**Rejected alternative:** plugin names as arguments to the one-liner, which add arguments and one README line per plugin.

**Rejected alternative:** one plugin per run from a menu, which repeats the question about the tool for every plugin.

**Rejected alternative:** a description of each plugin in the question, a third copy of each description beside `plugin.json` and the README.

**Consequence:** the installer no longer lands in any plugin cache.
A collaborator's fresh clone with committed settings is asked about each plugin, since none is installed for that clone yet.
`skill-authoring` asks that a changed `compatibility` field updates the rows of the table.

## The plugins share one version

**Id:** a1d4071c-aaf4-4e91-a040-0d265fe6c0d4
**Type:** decision
**Type:** workaround
**Status:** active
**Evidence:** inferred
**Source:** planning conversation with the maintainer, 2026-11-25; yq 4.54.3 probed that day
**Verification:** corroborated — on 2026-11-25 the release's write_version script set 0.2.0 in all three manifests of a scratch copy
**Revisit when:** a plugin needs a release of its own, or the release action gains a path or tag-prefix input
**See:** distribution.md#the-setup-travels-as-three-plugins-from-a-marketplace-in-this-repository — 32e8dc09-dc9f-4edf-a9a5-2617d6f2d368 — as of 2026-11-25
**See:** distribution.md#the-release-runs-release-from-conventional-commits-which-also-creates-the-github-release — 7a599839-67d0-4c4f-ad4b-3c6d1f33ddbb — as of 2026-11-25
**See:** distribution.md#the-release-raises-the-plugins-version — 37d44193-9ce0-4022-a27f-cd313c3c06d0 — as of 2026-11-25

Each release writes the same version into every `plugins/*/.claude-plugin/plugin.json`, through a `write_version` that runs `yq -i` on one manifest at a time.

**Reason:** `release-from-conventional-commits` computes one version for the repository from `vX.Y.Z` tags and has no input for a path or a tag prefix; the maintainer chose the shared version, which is confirmed.
`yq -i` given several files writes every document into the first file and leaves the others unchanged, which a probe showed, so the loop gives each manifest a run of its own.

**Rejected alternative:** one version per plugin, which needs per-plugin tags and paths in the release action or another release tool, and a way to tell which plugin a pull request changed.

**Consequence:** a release raises every plugin's version even when only one changed, so Claude Code downloads unchanged plugins again and their versions skip ahead.

## APM does not replace the installer for now

**Id:** bf761ed8-c128-407e-bbbf-ef470598a784
**Type:** decision
**Status:** active
**Evidence:** confirmed
**Source:** planning conversation with the maintainer, 2026-11-25; documentation, changelog and source of APM v0.39.0 read that day
**Revisit when:** APM reaches 1.0, or its native plugin route loads in git worktrees and keeps the harness's own updates
**See:** distribution.md#the-installer-asks-about-each-plugin-and-updates-the-ones-already-set-up — b42b56b4-9067-4678-8275-2a3fe195180a — as of 2026-11-25

The maintainer considered replacing `install.sh` with Microsoft's Agent Package Manager, APM, and kept the installer.

**Considered:** each consumer declares the plugins it wants in an `apm.yml` and runs `apm install`, which since APM 0.38 copies each Claude Code plugin whole into the repository's `.agents/plugins/<plugin>/` and writes `extraKnownMarketplaces` and `enabledPlugins` into `.claude/settings.json` and `.github/copilot/settings.json`; the consumer commits `apm.yml`, `apm.lock.yaml` and the copies.

**Reason:** updates would come only from `apm update` or bot pull requests instead of Claude Code's own `autoUpdate`; every collaborator would install the `apm` CLI and run `apm install` once; APM documents that such plugins do not load in git worktrees, where `empty-house-refactoring` runs, nor in `claude -p`; it cannot check the tools the skills need; and at 0.39 it ships breaking changes about weekly, its plugin route a few days old.
The maintainer chose to keep the installer, which is confirmed, and the facts about APM come from its own documentation, changelog and source.

**Consequence:** APM can already install these plugins from the marketplace as they are, except that it parks a plugin whose `plugin.json` has a field it does not admit, such as the `network` of `ethos`'s manifest.
