# Instructions

how the coding instructions reach a session and a subagent, which skill the hook says to use when, which working rules the hook carries and which live in skills, whether a repository keeps AGENTS.md or CLAUDE.md, how a hook refuses direct edits in `docs/context/`, and how a repository's own rules relate to them

## The instructions are a skill that a session-start hook tells the agent to load

**Id:** dc7b4808-f10e-4663-aab4-e4c3be395618
**Type:** decision
**Status:** active
**Evidence:** inferred
**Source:** planning conversation with the maintainer, 2026-11-21; hook and plugin documentation of Claude Code and Copilot CLI read that day
**Verification:** corroborated — probes in Claude Code and a check in Copilot CLI on 2026-11-21 showed sessions loading the skill as their first action
**Revisit when:** a session is found working without the instructions, or a plugin format learns to carry always-on instructions
**See:** distribution.md#the-setup-travels-as-a-plugin-from-a-marketplace-in-this-repository — ce0294c5-2188-42ab-8212-5dc84f02dd31 — as of 2026-11-21

The coding instructions are the skill `foundational-coding-principles`, and the plugin's session-start hook puts a rule into every session that tells the agent when to load it.

**Reason:** no plugin format carries an always-on instructions file, so the instructions need a carrier inside the plugin.
A skill has no size limit and needs no tool on the consumer's machine, and a hook that points to a skill is a pattern the maintainer's repositories already use for another plugin.
The choice itself is the maintainer's and confirmed; which of these properties decided it was not stated, so the reason is inferred from the properties of the chosen option.

**Rejected alternative:** a hook that injects the text of the instructions itself.
It puts the text into context without the agent acting, but it needs `jq` on every consumer's machine to build the JSON, and Claude Code caps hook context at 10,000 characters where the instructions already had 7,765.

**Rejected alternative:** instructions outside the plugin, loaded natively from the tools' user directories and from a committed copy in each repository.
Rejected because the copies in repositories remain and drift.

**Consequence:** the instructions reach a session only if the agent obeys the hook's rule, loading them costs a tool call, and they are no longer a plain always-on file.
The skill is not named `instructions`, because Copilot CLI has a built-in command of that name.
It was named `coding-instructions` until 2026-11-22, when the maintainer renamed it to `foundational-coding-principles` without stating why; the new name matches the skill's heading and what it has held since the rules for working on a change moved to the hook.

## The hook says which skill to use when

**Id:** c57d2458-e2a9-4442-94a5-c172d62d7436
**Type:** decision
**Status:** active
**Evidence:** inferred
**Source:** planning conversation with the maintainer, 2026-11-21; probes in Claude Code that day
**Verification:** corroborated — - the wording was probed in Claude Code on 2026-11-21 with its smallest model, and a Copilot CLI agent that day loaded the skill before it planned the addition of a skill; on 2026-11-22, after the purpose clauses were dropped, probes with the same model, three runs per prompt, loaded foundational-coding-principles for an architecture question, before writing, and in a subagent before writing in every run, context-authoring first in 7 of 9 sessions against 2 of 6 with the lists of 2026-11-21, and contract-authoring after a change in 1 of 3 against 0 of 3; the rules for git-operations, guidance-authoring, markdown-authoring and workflow-authoring are not probed
**Revisit when:** a plan or a change about code or architecture is found made without the instructions, or a skill is added that agents should use on their own
**See:** instructions.md#the-instructions-are-a-skill-that-a-session-start-hook-tells-the-agent-to-load — dc7b4808-f10e-4663-aab4-e4c3be395618 — as of 2026-11-21
**See:** instructions.md#the-rules-for-committing-and-for-guidance-files-are-skills-of-their-own — 38dc050f-c934-4ec1-a162-5d3e3c93b863 — as of 2026-11-22
**See:** skills.md#each-part-of-a-skill-has-one-job — 240ad9b3-f152-4d51-add8-78cbefc798cb — as of 2026-11-22

`hooks/instructions/shared.md` holds the rules for the skills an agent should use on its own, each naming the skill and when to use it, `hooks/instructions/session.md` the one rule only a session gets, which loads `context-authoring` at once, and `hooks/instructions/subagent.md` the one rule only a subagent gets, which loads `context-authoring` before a file in `docs/context/` changes.
Below the skill rules, `shared.md` also holds the rule to run the quality gate at the end of an implementation change, which names no skill.
The hooks print the shared list into every session and every subagent, each with the rules of its own file in front of it, and the coding instructions name no other skill.
The rule for `foundational-coding-principles` is to use it first whenever a request involves code or architecture or asks for a plan, a design, a recommendation, a review or a change of any kind, and before creating or changing any file.
Since 2026-11-22 every rule has the form "Use the `<skill>` skill <occasion>." without a purpose clause, as `skill-authoring` requires, and the rule for `docs/context/` reaches only subagents, because a session loads the skill at once.

**Reason:** every plan and every change about code or architecture must follow the coding instructions, which is the maintainer's requirement and confirmed.
That the list sits in the hook and not in the instructions is the maintainer's choice as well; its reason was not stated and is inferred: the hook's context is in a session and a subagent from the start, while a section inside the instructions is read only once that skill is loaded.
The wording of the first rule comes from probes of seven wordings in Claude Code.
The wordings that list the activities as plan, design, recommend, review and change made a session load the skill for an architecture question in every run, where the others probed on that question did so in at most two of three.
A wording that tied those activities to code and architecture alone failed in Copilot CLI: its agent planned the addition of a skill, which is not code, without the instructions, so the rule names plans and changes of any kind.
With the final wording, sessions loaded the skill before code, Markdown and planning work, subagents before writing a file, and no session loaded it for a question outside code.
Wordings without the part about creating or changing a file left subagents writing files without the instructions in most runs.
The rules lost ": every plan and every change must follow it" and ", to keep `docs/contract/` true to the code", and the session's rule its "Load … now", because the maintainer wants an announcement to say only when to use a skill.

**Rejected alternative:** a "Skills to use" section inside the coding instructions, which is where the rules for the other skills were before.
Replaced by the list in the hook, for the inferred reason above.

**Rejected alternative:** loading the instructions at the start of every session, whatever the request.
Not chosen: the rule is scoped to code and architecture, and why that scope was preferred was not stated.

**Rejected alternative:** a list of its own for subagents.
Rejected because three of the four rules would exist twice.

**Consequence:** a session that only answers questions outside code and architecture, and plans or changes nothing, works without the instructions.
The list names each skill with the plugin's prefix, as the tools list plugin skills.

## Keep the Why loads only in sessions of projects that opted in

**Id:** 6e6270e7-2687-4c10-8a03-444651834ac3
**Type:** decision
**Status:** superseded
**Evidence:** inferred
**Source:** autostart reference of the Keep the Why skill; probes in Claude Code on 2026-11-21
**Verification:** uncorroborated — probed in Claude Code on 2026-11-21 with its smallest model; Copilot CLI was not run
**Revisit when:** a project with a `.keep-the-why` file is found working without the skill, or the skill loads in a project without one
**See:** instructions.md#the-hook-says-which-skill-to-use-when — c57d2458-e2a9-4442-94a5-c172d62d7436 — as of 2026-11-21
**See:** distribution.md#keep-the-why-is-a-copy-inside-the-plugin — e111390d-d6b9-4293-9d2a-d0e1995a96c0 — as of 2026-11-21
**Superseded by:** 8b43aba6-f8e4-403c-afa0-8a324899ee7e

The list's rule for `keep-the-why` tells the agent to load the skill at once, and `hooks/context.sh` leaves that rule out for a subagent and for a project without a `.keep-the-why` file at its root.

**Reason:** Keep the Why's own guidance ties loading at session start to that file, so that a project that never opted in does not get the skill in every session, and this plugin is installed per machine, where it reaches every project.
The rule stays out of subagents because the skill's check at the start belongs to the session, as it did with the hook the repositories carried before.
Applying both here was not decided by the maintainer separately and is inferred from that guidance and from the earlier behaviour.
The rule's wording comes from probes: told only to use or load the skill "now, before doing anything else", a session answered a plain question without it in every run, and told in addition that the project uses Keep the Why and that even a plain question counts, it loaded the skill first in three of three runs.

**Rejected alternative:** a rule that leaves the check for the file to the agent.
Rejected because every session in every project would spend a step on it, and the outcome would depend on the agent.

**Consequence:** the script decides by the project directory the tool names, or by the working directory where a tool names none, so a session started below a project's root in such a tool does not load the skill.

## Keep the Why loads in every session

**Id:** 8b43aba6-f8e4-403c-afa0-8a324899ee7e
**Type:** decision
**Status:** superseded
**Evidence:** confirmed
**Source:** conversation with the maintainer, 2026-11-21; probes in Claude Code that day
**Verification:** corroborated — with the reworded rule and the new skill description, sessions on Claude Code's smallest model loaded the skill first in 3 of 3 runs in this repository and in 5 of 5 in an empty directory on 2026-11-21, and in 3 of 3 runs in a repository without `docs/context/` recorded, named and offered nothing; Copilot CLI was not run
**Revisit when:** a session is found working without the skill, or the skill records, offers or names something in a project without `docs/context/index.md`
**See:** context-authoring.md#context-authoring-runs-on-fixed-settings-with-no-configuration-file — f74d7caa-9ec7-48c0-bc62-74ba1e43a5bc — as of 2026-11-21
**Superseded by:** c840f105-454f-4de6-b85a-47c2fe96d619

The rule that loads `agentic:keep-the-why` at once reaches every session, whatever the project, and opens with "Every session uses Keep the Why".
The skill itself checks for `docs/context/index.md` and, without it, records, offers and names nothing unless asked about Keep the Why or to set it up.

**Reason:** the maintainer wants Keep the Why available in every project, and with no configuration left to set up, that takes nothing but loading the skill.
The wording is backed by probes: the rule keeps an opening that says the skill is in use, because a rule without one made sessions answer a plain question without loading the skill, and the skill's description says it loads at the start of every session, because with the old description, which said the skill is not used outside opted-in projects, a session in an empty directory skipped the rule in one of three runs.
The skill's first step forbids saying that nothing was recorded and why, because without that clause a session in a project without `docs/context/` explained that it had recorded nothing and offered to set Keep the Why up.

**Rejected alternative:** `docs/context/index.md` as the hook's marker, which the agent recommended.
Rejected because the skill would then be available only in projects already set up.

**Rejected alternative:** any `docs/context/` directory as the marker.
Not chosen; a directory used for something else would switch the skill on.

**Consequence:** every session of every repository with the plugin, other people's projects included, loads the skill and spends a step deciding whether it applies, with an outcome that depends on the agent.

## The session-start hook sets up the context directory

**Id:** c840f105-454f-4de6-b85a-47c2fe96d619
**Type:** decision
**Status:** superseded
**Evidence:** confirmed
**Source:** conversation with the maintainer, 2026-11-21
**Verification:** corroborated — on 2026-11-21 `hooks/context.sh SessionStart` created `docs/context/index.md` in a fresh Git repository and still printed its rules when the script failed, and a Claude Code session with the plugin found the file before its first step; a non-interactive Copilot CLI session in a throwaway repository ran no hook at all, so the directory Copilot CLI runs the hook in is unconfirmed
**Revisit when:** the plugin is installed at user level somewhere, or Copilot CLI is found to run the hook outside the repository
**See:** distribution.md#the-plugin-is-enabled-per-repository-never-at-user-level — ef3b3b17-21ad-4f01-af7b-7f47c3c1e7a9 — as of 2026-11-21
**See:** context-authoring.md#a-script-writes-the-context-index — d8318483-17f8-4fa9-8bbe-10844ba61a60 — as of 2026-11-21
**Superseded by:** 331f48d1-75aa-457e-9f11-c3de50b43d46

For every session start, `hooks/context.sh` runs `skills/context-authoring/scripts/index.sh`, which creates `docs/context/` when it does not exist and writes its index, so every repository that enables the plugin uses `context-authoring` from its first session on.
The skill has no check for a project that is not set up and no setup procedure.

**Reason:** the plugin is enabled per repository only, so a repository with the plugin has chosen the setup, and the maintainer wants everything that can be done deterministically done by a script instead of the agent.

**Rejected alternative:** the agent runs the script when asked to set Keep the Why up, as setup worked before.
Rejected because it keeps the skill's gate and depends on the agent.

**Rejected alternative:** the agent runs the script before its first write.
Rejected because it still depends on the agent remembering to.

**Consequence:** the first session in a newly enabled repository leaves untracked files in `docs/context/`.
A plugin installed at user level would create `docs/context/` in every repository it opens.

## The session is told to load context-authoring, not given its text

**Id:** 7f66aeaf-75a6-4a86-9d2c-1a88fd33b150
**Type:** decision
**Status:** active
**Evidence:** unknown
**Source:** conversation with the maintainer, 2026-11-21
**Verification:** contradicted — since 2026-11-25 the plugin is named ethos, so the skill is ethos:context-authoring, which 32e8dc09-dc9f-4edf-a9a5-2617d6f2d368 records
**Revisit when:** a session is found working without the skill
**See:** instructions.md#the-session-start-hook-sets-up-the-context-directory — c840f105-454f-4de6-b85a-47c2fe96d619 — as of 2026-11-21
**See:** distribution.md#the-setup-travels-as-three-plugins-from-a-marketplace-in-this-repository — 32e8dc09-dc9f-4edf-a9a5-2617d6f2d368 — as of 2026-11-25

`hooks/instructions/session.md` tells every session to load `agentic:context-authoring` at once, and the hook does not print the skill's text into the session.
The decision is confirmed; its reason was not stated.

**Rejected alternative:** the hook prints `SKILL.md` into every session, which the agent recommended so that loading no longer depends on the agent following a rule.
It would have bound `SKILL.md` to about 9,000 characters, since Claude Code shows a session only a preview of hook context longer than 10,000.

**Rejected alternative:** deciding after the rewrite of the skill, depending on the size it reached.

**Consequence:** whether a session loads the skill still depends on the model following the rule.

## A rule in the hook's list replaces the guard file in the context directory

**Id:** 486ac6f4-ea2f-41da-948c-80659db73dd7
**Type:** decision
**Status:** active
**Evidence:** confirmed
**Source:** conversation with the maintainer, 2026-11-21; the guard section of the setup reference in Keep the Why 0.20.3
**Verification:** contradicted — since 2026-11-25 the plugin is named ethos, so the skill is ethos:context-authoring, which 32e8dc09-dc9f-4edf-a9a5-2617d6f2d368 records; the hook's output was checked on 2026-11-21, but no subagent was probed
**Revisit when:** a session or subagent is found writing to `docs/context/` without the skill
**See:** instructions.md#the-hook-says-which-skill-to-use-when — c57d2458-e2a9-4442-94a5-c172d62d7436 — as of 2026-11-21
**See:** distribution.md#the-setup-travels-as-three-plugins-from-a-marketplace-in-this-repository — 32e8dc09-dc9f-4edf-a9a5-2617d6f2d368 — as of 2026-11-25

`docs/context/CLAUDE.md` is gone, the skill no longer creates guard files in the context directory, and the hook's list carries a rule for every session and subagent to use `agentic:context-authoring` before creating or editing anything in `docs/context/`.

**Reason:** the guard repeated what the skill says, and the skill loads in every session, so the file went, as the maintainer asked.
A subagent, though, gets no rule that loads the skill, and upstream added the guard after an agent was seen writing entries by hand without the skill; the rule in the hook keeps that reminder for subagents in every repository without a file in each.

**Rejected alternative:** no replacement, relying on the main session to pass the skill on when it delegates.
Rejected because a subagent then knows the skill only if the main agent remembers to pass it on.

**Rejected alternative:** the rule that loads the skill at once, for subagents too.
Rejected because it costs a tool call and the skill's context in every subagent, whatever its task.

**Consequence:** one more line in the context of every session and subagent.
The hook holds back from subagents only the rule that loads the skill at once, which sits in a file of its own, `hooks/instructions/session.md`, so that no rewording of it can let it reach subagents.

## A second hook gives Claude Code subagents the same rules

**Id:** fc11b8b4-aa2e-4684-b2a3-8e2b1073df1a
**Type:** decision
**Status:** active
**Evidence:** confirmed
**Source:** planning conversation with the maintainer, 2026-11-21; subagent and hook documentation of Claude Code and Copilot CLI read that day
**Verification:** corroborated — probes in Claude Code on 2026-11-21 showed subagents loading the skill before they wrote a file, and a subagent not receiving the session-start context
**See:** instructions.md#the-hook-says-which-skill-to-use-when — c57d2458-e2a9-4442-94a5-c172d62d7436 — as of 2026-11-21

A subagent-start hook prints the list of skills to use into every subagent, as the session-start hook does for a session.

**Reason:** a subagent does not receive the context a session-start hook adds, so without this hook a subagent that writes code would not know the instructions.
While the instructions were a committed `CLAUDE.md`, Claude Code gave them to subagents natively, and delegated implementation should keep following them.

**Rejected alternative:** telling only the main session.
Rejected because a subagent then knows the instructions only if the main agent passes them on.

**Consequence:** each subagent whose task falls under the first rule spends a tool call on loading the skill.
Copilot CLI raises no subagent-start event for its `general-purpose` subagent, so there the main agent has to pass the rules on.

## A repository's own instruction files take precedence

**Id:** 6cfe7db6-e6c8-4d23-9287-6d1fac53dbd1
**Type:** decision
**Status:** superseded
**Evidence:** confirmed
**Source:** planning conversation with the maintainer, 2026-11-21; commit history of a consuming repository
**Verification:** corroborated — by a Claude Code probe of the working tree on 2026-11-21 with its smallest model, which committed to main in a repository whose CLAUDE.md says so, against the hook's feature-branch rule
**See:** instructions.md#the-instructions-are-a-skill-that-a-session-start-hook-tells-the-agent-to-load — dc7b4808-f10e-4663-aab4-e4c3be395618 — as of 2026-11-21
**See:** instructions.md#the-rules-for-working-on-a-change-and-for-knowledge-files-are-in-the-hook-not-in-the-coding-instructions — 739f0ba4-6702-4f44-af86-42af8a0b0663 — as of 2026-11-21
**Superseded by:** 0de595a1-9c9e-405a-b0c8-f5c842960f16

`hooks/rules.md` states that a repository's own instruction files add to its rules and to the plugin's skills and take precedence where they differ.
Until 2026-11-21 the statement was in `coding-instructions` and covered only the coding instructions; it moved to the hook with the branch rule it was made for, by the maintainer's choice.

**Reason:** a consuming repository deliberately replaced the shared branch rule with one of its own.
Without a stated precedence, an agent there would read two contradicting rules, one from the plugin and one from the repository.

**Rejected alternative:** taking the branch rule out of the shared instructions.
Rejected because every repository that wants a feature branch would then repeat it.

**Rejected alternative:** a statement in the hook beside the one in `coding-instructions`, which keeps the rule twice.

**Rejected alternative:** a statement in the hook that covers only the hook's own rules, which would stop a repository from overriding the coding principles.

**Consequence:** the precedence also covers `markdown-authoring`, `workflow-authoring` and the plugin's other skills, which it did not before.

## Hook context is printed in two JSON shapes

**Id:** d40c4dc3-2b38-4f7a-81e2-e541308fe75e
**Type:** constraint
**Type:** decision
**Status:** active
**Evidence:** confirmed
**Source:** hooks reference of Copilot CLI and hooks documentation of Claude Code, read 2026-11-21
**Verification:** corroborated — Claude Code's half was probed on 2026-11-21, and a Copilot CLI session that day quoted the list word for word
**Revisit when:** a check in Copilot CLI shows that the list is not injected, or either tool changes the output it reads from a hook
**See:** instructions.md#the-hook-says-which-skill-to-use-when — c57d2458-e2a9-4442-94a5-c172d62d7436 — as of 2026-11-21

`hooks/rules.sh` prints the list of skills to use as one JSON object that carries it twice: in the top-level `additionalContext` and in `hookSpecificOutput.additionalContext`.

**Reason:** Copilot CLI consumes only the top-level field of a session-start hook and treats output that is not JSON as none, while Claude Code reads the nested field.
One object with both serves both tools from one hook file.

**Rejected alternative:** `jq` to build the JSON.
Rejected because every consumer would need it installed.

**Rejected alternative:** the text as an argument in `hooks/hooks.json`.
Rejected because the list would sit in an escaped command string, once per hook.

**Consequence:** the hooks need a POSIX shell with `sed` and `awk`.
The script escapes backslashes, double quotes and line ends and nothing else, so the list must stay free of tabs and other control characters.

## A hook refuses direct edits in the context directory

**Id:** 6bc8545b-c557-4f65-b84c-e060641936fd
**Type:** decision
**Status:** active
**Evidence:** confirmed
**Source:** conversation with the maintainer, 2026-11-21
**Verification:** contradicted — since 2026-11-25 the plugin is named ethos, so the skill is ethos:context-authoring, which 32e8dc09-dc9f-4edf-a9a5-2617d6f2d368 records; on 2026-11-21 a Claude Code session started with --dangerously-skip-permissions had its Edit of a topic file refused by the hook and the file stayed unchanged, while a session asked for a direct fix used the script on its own; Copilot CLI was not run
**Revisit when:** an agent is found writing into docs/context/ around the script, or Copilot CLI is found not to honour the refusal
**See:** instructions.md#a-rule-in-the-hooks-list-replaces-the-guard-file-in-the-context-directory — 486ac6f4-ea2f-41da-948c-80659db73dd7 — as of 2026-11-21
**See:** context-authoring.md#scripts-read-and-write-the-context-directory — 2bb81a2b-2f49-4dd2-ba07-7a5e069d1b9c — as of 2026-11-21
**See:** distribution.md#the-setup-travels-as-three-plugins-from-a-marketplace-in-this-repository — 32e8dc09-dc9f-4edf-a9a5-2617d6f2d368 — as of 2026-11-25

`hooks/guard.sh` runs as a `PreToolUse` hook for `Edit`, `Write`, `MultiEdit` and `NotebookEdit` and refuses any of them on a path in `docs/context/`, exiting with code 2 and a reason that names the context script.
Reading stays open, a shell write into `docs/context/` is forbidden only by the skill's rule, and the hook's list keeps the rule that has a subagent load `agentic:context-authoring` before writing there.

**Reason:** the maintainer requires agents to write `docs/context/` only through the script; the hook sees the exact path of a file tool, so its refusal refuses nothing it should not, holds in every permission mode and also runs inside subagents.

**Rejected alternative:** also refusing shell commands that name `docs/context/` together with a write such as `>`, `tee`, `sed -i`, `mv`, `cp` or `rm`, which only matches patterns and errs both ways.

**Rejected alternative:** refusing every shell command that names `docs/context/` other than the script, which also refuses `git add`, `git diff`, `grep` and `cat` on it.

**Rejected alternative:** answering in JSON, which the two tools read in different shapes, while both treat exit code 2 of the hook as a refusal.

**Consequence:** a deliberate shell write into `docs/context/` gets through, and people edit the files by hand as before.

## Listing the themes is a step of the skill, not of the session start

**Id:** 331f48d1-75aa-457e-9f11-c3de50b43d46
**Type:** decision
**Status:** active
**Evidence:** confirmed
**Source:** conversation with the maintainer, 2026-11-21
**Verification:** contradicted — since 2026-11-25 the plugin is named ethos, so the skill is ethos:context-authoring, which 32e8dc09-dc9f-4edf-a9a5-2617d6f2d368 records
**Revisit when:** sessions are found changing code without consulting the context
**See:** context-authoring.md#scripts-read-and-write-the-context-directory — 2bb81a2b-2f49-4dd2-ba07-7a5e069d1b9c — as of 2026-11-21
**See:** distribution.md#the-setup-travels-as-three-plugins-from-a-marketplace-in-this-repository — 32e8dc09-dc9f-4edf-a9a5-2617d6f2d368 — as of 2026-11-25

Before changing something, the agent runs the context script's `themes` command itself, as `agentic:context-authoring` instructs; `hooks/rules.sh` prints only the rules and no list of themes.
The session start no longer creates `docs/context/`: the script creates it with the first theme.

**Reason:** the maintainer keeps the hook and the skills apart: the skills own the process, and the hook only points to the right skill.
Without an index, a setup at session start would only create an empty directory, which Git does not track.

**Rejected alternative:** the session-start hook printing the themes below the rules, about 700 characters here, 3,000 in `finance-tracker` and 4,500 in `home-network`, so that the agent would not have to remember the step; the maintainer chose it first and reversed it before it was released.

**Consequence:** whether a session consults the context still depends on the agent following the skill, as reading the index did.
The hook script was renamed from `hooks/context.sh` to `hooks/rules.sh`, so that no two scripts of the plugin share a name.

## The rules for working on a change and for knowledge files are in the hook, not in the coding instructions

**Id:** 739f0ba4-6702-4f44-af86-42af8a0b0663
**Type:** decision
**Status:** superseded
**Evidence:** inferred
**Source:** planning conversation with the maintainer, 2026-11-21
**Verification:** corroborated — in Claude Code, where probes of the working tree on 2026-11-21 with its smallest model committed on a new feature branch with a Conventional Commit when told to commit, and otherwise read CONTRIBUTING.md first, tried to run the check it names and left the change uncommitted; uncorroborated in Copilot CLI until the installed plugin carries the rules
**Revisit when:** the hook context nears the 10,000 characters beyond which Claude Code shows only a preview, or a session or subagent is found breaking a rule of the hook it had received
**See:** instructions.md#the-hook-says-which-skill-to-use-when — c57d2458-e2a9-4442-94a5-c172d62d7436 — as of 2026-11-21
**See:** instructions.md#listing-the-themes-is-a-step-of-the-skill-not-of-the-session-start — 331f48d1-75aa-457e-9f11-c3de50b43d46 — as of 2026-11-21
**Superseded by:** 38dc050f-c934-4ec1-a162-5d3e3c93b863

Below the rules that name a skill, `hooks/rules.md` holds the rules for working on a change and for a repository's knowledge files, which were sections of the coding instructions until 2026-11-21.
The coding instructions, now the skill `foundational-coding-principles`, keep only the coding principles.

**Reason:** the maintainer judged that the two sections do not belong to the coding instructions but to the hook's instructions, which is confirmed.
The agent's reading, inferred: the coding instructions are the principles a plan or a change is judged by, while the procedure around a change and the rules for particular files are a different kind of rule, and the hook's context is in every session and subagent from the start, without a skill being loaded.

**Rejected alternative:** the change rules in the hook and the knowledge-file rules merged into `markdown-authoring`, which loads for every Markdown file and already states two of the three general knowledge-file rules.
The agent recommended it; the maintainer chose the hook for both without stating why.

**Rejected alternative:** the knowledge-file rules as a new skill that the hook points to, which adds a skill and a rule.

**Consequence:** the hook no longer only points to skills, a departure the maintainer chose from the earlier line that the skills own the process and the hook only points to the right skill.
A session's hook context grew from about 765 to about 3,130 characters, and a subagent's by as much.
Keeping one home per fact and keeping a file concise and focused on its reader stand both in the hook and in `markdown-authoring`, an overlap the maintainer accepted.
The rules moved with their wording, except that the rules for the instruction file name `AGENTS.md` or `CLAUDE.md`.

## A repository keeps its agent instructions in AGENTS.md or CLAUDE.md, never both

**Id:** f29d0136-d69b-4809-8a72-273f82ad359e
**Type:** decision
**Status:** active
**Evidence:** inferred
**Source:** planning conversation with the maintainer, 2026-11-21; memory documentation of Claude Code and custom-instructions documentation of Copilot CLI, read that day
**Verification:** uncorroborated — since the rule moved into guidance-authoring on 2026-11-22; while it was in the hook, probes of the working tree in Claude Code on 2026-11-21 with its smallest model wrote a new rule to AGENTS.md where only it existed, to CLAUDE.md where only it or both existed, and created CLAUDE.md where neither did, never adding the other file; not probed in Copilot CLI
**Revisit when:** Claude Code or Copilot CLI changes which of AGENTS.md and CLAUDE.md it reads, or a repository is found keeping rules in both
**See:** instructions.md#the-rules-for-committing-and-for-guidance-files-are-skills-of-their-own — 38dc050f-c934-4ec1-a162-5d3e3c93b863 — as of 2026-11-22

A rule in the `guidance-authoring` skill has the agent keep a repository's agent instructions in the one of `AGENTS.md` and `CLAUDE.md` it already has, at the root and in nested directories alike, and never add the other.
Where the repository has both or neither, the tool decides without asking: Copilot CLI writes `AGENTS.md`, Claude Code `CLAUDE.md`.
The plugin's other files name both files and leave the choice to that rule.

**Reason:** the maintainer asked not to mix the two files, to use the one that is there first and, in doubt, the tool's own, which is confirmed.
Why mixing harms is inferred from the tools' documentation as of 2026-11-21: both tools read a repository that has only one of the two files, but they read one with both differently.
Claude Code then reads only `CLAUDE.md` by default, while Copilot CLI merges both without precedence, so the two tools would follow different rules.

**Rejected alternative:** writing to the file that holds the rules and keeping the other a pointer, and asking when both hold rules, which suits rules in `AGENTS.md` with a `CLAUDE.md` that only imports it, as Claude Code's documentation recommends for repositories that share `AGENTS.md`.
The agent recommended it; the maintainer chose the tool's file without stating why.

**Rejected alternative:** asking the user whenever both files exist.

**Consequence:** which file a repository gets depends on the tool that writes its first rule.
In a repository with rules in `AGENTS.md` and a `CLAUDE.md` that only imports it, Copilot CLI adds its rules to `AGENTS.md` and Claude Code next to the import, so such a repository keeps rules in both; the maintainer accepted both costs.

## The principles skill is also the measure for any task it is invoked with

**Id:** 8793291a-7b02-4de1-92b7-195861aac706
**Type:** decision
**Status:** needs-review
**Evidence:** confirmed
**Source:** conversation with the maintainer, 2026-11-22
**Verification:** corroborated — by Claude Code probes on 2026-11-22 with its smallest model and the general wording: asked to review or to analyze, it reported verified findings by principle and changed nothing; asked to review and fix, it fixed the working tree without committing
**Revisit when:** an invoked review, fix or analysis is found ignoring the scope or the principles, or Copilot CLI is found not to pass the task to the skill
**See:** instructions.md#the-instructions-are-a-skill-that-a-session-start-hook-tells-the-agent-to-load — dc7b4808-f10e-4663-aab4-e4c3be395618 — as of 2026-11-22

`foundational-coding-principles` serves two uses: an agent loads it whenever it plans or makes a change, as the hook's rule says, and a person invokes it with a task of any kind, which the agent then carries out against the principles.
The skill's "How to apply them" section keeps an invoked task to its scope, lets it change files only when the task asks for a change, and has it report verified findings with their evidence, principle, resolving change and cost.

**Reason:** the maintainer wants the principles to be both the guard on every change and a tool a person can point at any task, such as reviewing and fixing uncommitted changes or a pull request, or analyzing a repository's architecture.

**Rejected alternative:** a description and instructions per kind of task, defining the scope of uncommitted changes and of a pull request and what a review, a fix and an analysis deliver.
The maintainer rejected it as too specific and tailored to those examples.

**Consequence:** a fix leaves its changes uncommitted, also on a pull request's branch, because the hook's rule allows a commit only on instruction.

## The rules for committing and for guidance files are skills of their own

**Id:** 38dc050f-c934-4ec1-a162-5d3e3c93b863
**Type:** decision
**Status:** active
**Evidence:** unknown
**Source:** the maintainer's change to the working tree and conversation with the maintainer, 2026-11-22
**Verification:** uncorroborated — no session or subagent was probed with the two skills
**Revisit when:** a session or subagent is found committing, pushing or editing README.md, CONTRIBUTING.md, AGENTS.md or CLAUDE.md without loading the skill for it
**See:** instructions.md#the-rules-for-working-on-a-change-and-for-knowledge-files-are-in-the-hook-not-in-the-coding-instructions — 739f0ba4-6702-4f44-af86-42af8a0b0663 — as of 2026-11-22
**See:** instructions.md#the-hook-says-which-skill-to-use-when — c57d2458-e2a9-4442-94a5-c172d62d7436 — as of 2026-11-22
**See:** ship-change.md#the-skill-is-named-ship-change-for-the-path-from-branch-to-merge — d140d684-198d-4c2a-86e0-f5b8db05ce3b — as of 2026-11-22

On 2026-11-22 the maintainer moved the rules for committing and for guidance files out of the hook into two skills, `git-operations` and `guidance-authoring`, and gave the hook's list a rule naming each.
Of the rules for working on a change, the hook keeps only the one to run the quality gate at the end of an implementation change, now only where the repository has one.
The rule to read the repository-root `CONTRIBUTING.md` before a change was dropped on purpose.
The change and the dropped rule are the maintainer's and confirmed; the reason is unknown.

**Reason:** unknown; the maintainer made the change without stating why.

**Rejected alternative:** keeping the rules in the hook, as from 2026-11-21, where they reached every session and subagent from the start; why it lost was not stated.

**Rejected alternative:** the name `git-actions`, which the skill had before its first release.
The maintainer agreed to rename it because the name reads as GitHub Actions, which `workflow-authoring` covers, and names only git, while the skill also covers pull requests and merges; `git-operations` repeats the wording of the hook's rule.

**Consequence:** the rules for committing reach an agent only once it loads `git-operations` for a git or GitHub operation, and the rules for guidance files only once it loads `guidance-authoring` for one of those files.
A session's hook context shrank from about 3,130 to about 1,180 characters, and a subagent's to about 1,080.
Nothing in the plugin tells the agent to read a repository's `CONTRIBUTING.md` any more.
The skill for the guidance files is the alternative rejected on 2026-11-21 because it adds a skill and a rule.

## The plugin states no precedence for a repository's own instruction files

**Id:** 0de595a1-9c9e-405a-b0c8-f5c842960f16
**Type:** decision
**Status:** active
**Evidence:** unknown
**Source:** conversation with the maintainer, 2026-11-22; re-checked with the maintainer that day
**Verification:** corroborated — the maintainer re-checked the entry on 2026-11-22 after ship-change, then named git-operations, named a repository's instruction to commit to main, and confirmed that naming such an override is right and grants nothing a repository lacked
**Revisit when:** an agent is found following a plugin rule against a repository's own rule, or asking which of the two to follow
**See:** instructions.md#a-repositorys-own-instruction-files-take-precedence — 6cfe7db6-e6c8-4d23-9287-6d1fac53dbd1 — as of 2026-11-22
**See:** ship-change.md#a-feature-branch-is-used-only-when-it-is-meant-for-the-changes-rebased-onto-latest-main — 8a06b079-2b05-41f8-ad24-e3799434c12e — as of 2026-11-22

Since 2026-11-22 the hook states no general precedence between a repository's own `AGENTS.md` or `CLAUDE.md` and the plugin's rules and skills.
The maintainer dropped the statement that they add to them and take precedence where they differ on purpose, which is confirmed; the reason was not stated.
A skill may still name a rule that a repository can override explicitly, as `ship-change` does for committing to the default branch.
Naming it makes the agent aware that a repository can override that rule; it is not what allows the override, so a repository's override does not depend on a skill naming it, as the maintainer stated on re-checking the entry.

**Reason:** unknown for dropping the general statement.

**Rejected alternative:** keeping the statement in the hook, as from 2026-11-21, where it was made so that a consuming repository could replace the feature-branch rule with its own.

**Consequence:** where a repository's own rule contradicts a plugin rule that names no override, nothing in the plugin says which one wins.
