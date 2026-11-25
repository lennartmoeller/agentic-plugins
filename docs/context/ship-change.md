# Ship change

how the ship-change skill takes a change from the worktree to main: who may start a stage, the five stages and how they chain, the branch rules, what review and merge do, the formats of commits and pull requests, why one script runs them, and the skill's name

## A git stage runs only on the user's own yes

**Id:** 51e06a91-1906-43a8-b3be-5a14cb6f3810
**Type:** decision
**Status:** active
**Evidence:** confirmed
**Source:** planning conversation with the maintainer, 2026-11-22
**Verification:** corroborated — Claude Code probes with its smallest model on 2026-11-22: with the plan's git steps in the prompt or in a plan file, it did the plan's other work and asked before the first git step; an earlier wording without 'even when the user asks to implement the plan' let it commit, open and merge a pull request from a plan in the prompt
**Revisit when:** an agent is found committing, pushing, opening, reviewing or merging a pull request because a plan listed the step, or asking although the user asked for the stage

`ship-change` runs a stage only when the user asks for that stage, through `/ship-change` or in their own words.
Whenever a stage is the next logical step without the user asking for it, such as once a change is done or as the next step of a plan, even of one the user approved and asked to implement, the agent asks first, through the interactive question tool where there is one, and runs only what the user says yes to.
The slash command is a shortcut, never a precondition: plain words start the same stages under the same rules.

**Reason:** the maintainer wants to say yes to every git step that changes the repository or GitHub, which is confirmed.
A plan is one case of a stage becoming the next logical step, not an exception: in any work with a coding agent a stage can become the next thing to do, and the agent asks first every time, as the maintainer stated on 2026-11-22.

**Rejected alternative:** an approved plan's step as the instruction, which saves a round-trip but lets a plan approved earlier commit or merge without a fresh look.

**Rejected alternative:** an approved plan authorizing every stage but `merge`.

**Consequence:** implementing a plan, or finishing any change, stops before the next git step until the user answers.

## Five stages run alone or chained, never with a gap

**Id:** 8898cef5-d7fc-4872-9d66-457ab4ae2a7d
**Type:** decision
**Status:** active
**Evidence:** confirmed
**Source:** planning conversation with the maintainer, 2026-11-22
**Verification:** corroborated — Claude Code probes with its smallest model on 2026-11-22: commit merge, and review merge without a pull request, were refused without a change, and the full chain ended squash-merged
**Revisit when:** a run is found skipping a stage, or a user is found needing a run the order refuses
**See:** ship-change.md#a-git-stage-runs-only-on-the-users-own-yes — 51e06a91-1906-43a8-b3be-5a14cb6f3810 — as of 2026-11-22

The stages are `branch`, `commit`, `pr`, `review` and `merge`, in that order, each making sure its result exists rather than redoing it.
A run is a contiguous part of that order, so `commit merge` is refused.
A run may start after `branch` only when the earlier stages' results exist, so `review merge` works like `pr review merge` when a pull request is open and is refused when none is.
A run starting at `pr` or later also stops when earlier work is outstanding, such as uncommitted changes or unpushed commits, and names the run that would cover it.
A run starting at `commit` still runs `branch` first, because commits go to a feature branch.
Without a stage, the skill reports the state and asks which run to do, offering only runs it accepts.

**Reason:** the stages, their order, the refused gap and the start at a later stage are the maintainer's request, which is confirmed.
Stopping on outstanding work keeps every commit and push tied to an explicit `commit` stage, and keeps the fix commits of `review` from sweeping in unrelated changes; the maintainer chose it with that reason put to them.

**Rejected alternative:** a run starting later proceeding and leaving outstanding work alone.

**Rejected alternative:** a run starting later running `commit` implicitly first.

**Rejected alternative:** `/ship-change` without a stage running the full chain, or only the next stage whose result is missing.

## A feature branch is used only when it is meant for the changes, rebased onto latest main

**Id:** 8a06b079-2b05-41f8-ad24-e3799434c12e
**Type:** decision
**Status:** active
**Evidence:** confirmed
**Source:** planning conversation with the maintainer, 2026-11-22
**Verification:** corroborated — Claude Code probes with its smallest model on 2026-11-22: on main it created a feature branch, with a CLAUDE.md saying to commit to main it committed there, and on a branch whose pull request was merged it stopped; the script rebased a branch behind main and aborted on a conflict
**Revisit when:** a commit is found on a branch not meant for it, or a rebase is found dropping or garbling a change
**See:** instructions.md#the-plugin-states-no-precedence-for-a-repositorys-own-instruction-files — 0de595a1-9c9e-405a-b0c8-f5c842960f16 — as of 2026-11-22

Commits go to a feature branch from latest main, unless the repository's own `AGENTS.md`, `CLAUDE.md` or `CONTRIBUTING.md` says to commit to main.
On main, `branch` creates the feature branch, named `<type>/<kebab-summary>` after the Conventional Commits type, as the branches of `finance-tracker` are.
On another branch, the agent first judges whether that branch is meant for the changes, a merged or closed pull request being a clear sign it is not, and stops when it is not; a branch meant for them that is behind main is rebased onto latest main.
`branch` never pushes; `commit` pushes a feature branch with `--force-with-lease`, which also carries a rebased one, and the default branch with a plain push, where a forced push could drop others' commits.

**Reason:** committing to main only on the repository's word and from latest main otherwise is the maintainer's request, the check whether a branch is meant for the changes and the rebase are the maintainer's answer, and the naming is the maintainer's choice, all confirmed.
The repository's word exists for repositories such as `home-network`, whose own instructions say to commit to main.

**Rejected alternative:** starting a new branch from latest main when the current one holds merged work.

**Rejected alternative:** merging latest main into a branch that is behind, which needs no forced push.

**Rejected alternative:** leaving a branch behind main as it is.

**Rejected alternative:** a branch name without the type, or the repository's own naming rule.

**Consequence:** a rebase rewrites commits already pushed, so the next push is forced with a lease.

## Review handles failing checks and Copilot's threads until both are clean

**Id:** df8aa898-66e3-4ad8-a584-223c0f1886f5
**Type:** decision
**Status:** active
**Evidence:** confirmed
**Source:** planning conversation with the maintainer, 2026-11-22; GitHub documentation on Copilot code review, read that day
**Verification:** uncorroborated — for Copilot: the maintainer's account has no Copilot license with code review, so a Copilot review was never waited for or worked through; Claude Code probes on 2026-11-22 corroborated the failing check: review read its log, fixed it, committed, pushed and reported clean
**Revisit when:** Copilot code review becomes available to the maintainer, or review is found running on for many rounds

`review` waits for the checks and for a pending Copilot review, never for a pending human review.
It fixes every failing check, weighs every unresolved Copilot thread and fixes the ones worth fixing, commits and pushes the fixes, and replies to and resolves every Copilot thread, as `ADDRESSED` naming the fixing commit or as `WONT_FIX` with a reason.
It repeats until every check passes and no Copilot thread is unresolved, without a round limit; people's threads, top-level comments and review summaries are left alone.

**Reason:** fixing failing checks and weighing, fixing and resolving review comments is the maintainer's request.
Committing the fixes without a further instruction, the missing round limit and the Copilot-only scope are the maintainer's choices; a fixed check shows its effect only after a push, and a reply naming the fixing commit needs the commit, which was put to the maintainer; why only Copilot's threads was not stated.
A pending Copilot request shows only in GraphQL, because `gh pr view --json reviewRequests` drops Bot reviewers.

**Rejected alternative:** every unresolved thread, people's included.

**Rejected alternative:** also answering people's top-level comments.

**Rejected alternative:** stopping after three rounds, or after one.

**Rejected alternative:** leaving the fixes uncommitted for a later `commit`, which keeps checks from rerunning.

**Consequence:** a reviewer that raises new comments on every push keeps `review` running until the user stops it, and a person's open thread stays open for that person.

## An admin merge never bypasses checks

**Id:** 4bdf1571-a8e4-4ceb-bdcf-3ca1c961bd1b
**Type:** decision
**Status:** active
**Evidence:** confirmed
**Source:** planning conversation with the maintainer, 2026-11-22
**Verification:** uncorroborated — no probe repository could block a merge, because the maintainer's plan offers branch protection only on public repositories
**Revisit when:** a merge is found blocked only by checks that cannot pass, or an admin merge is found landing a failing change

When the user asks to merge and GitHub blocks the merge, `merge` repeats it as an admin merge, but only once no check fails or is pending.
With a failing or pending check it stops without merging and suggests `review merge`.

**Reason:** the admin merge on a blocked merge is the maintainer's request; keeping it off failing and pending checks is the maintainer's choice.
`gh pr merge --admin` bypasses every requirement at once, and a solo maintainer's usual block is the approval they cannot give their own pull request, not a red check; that was put to the maintainer.

**Rejected alternative:** waiting for pending checks inside `merge`, which repeats what `review` does.

**Rejected alternative:** bypassing anything once the user asked to merge, which can merge a broken change.

## Commits and pull requests carry a title and the least text

**Id:** bc09f458-7f4f-4dcf-98a9-f45425e5815d
**Type:** decision
**Status:** active
**Evidence:** confirmed
**Source:** planning conversation with the maintainer, 2026-11-22; squash commits on main in finance-tracker, home-network and github-sso-keeper, read that day
**Verification:** corroborated — Claude Code probes with its smallest model on 2026-11-22 wrote title-only commits, pull requests with two bullets and no attribution, and squash commits titled with the pull request number
**Revisit when:** a release or changelog tool is found needing a commit description, or reviewers are found asking for longer pull request descriptions

A commit message is one Conventional Commits title of at most 72 characters, with no description, no `Co-Authored-By` trailer and no "Generated with" line, whatever the tool's default.
A pull request carries such a title for all of the branch's commits and a description of one to ten bullets on what changed and, where it is not obvious, why.
A merge is a squash merge titled "<pull request title> (#<number>)", the suffix outside the 72 characters, with the pull request's description as body; a title that is no Conventional Commits title is rewritten on the pull request too.
The script refuses titles and descriptions it can tell break these rules.

**Reason:** Conventional Commits, the 72 characters, the title-only commit, the short overview and the squash merge titled by the pull request are the maintainer's request.
No attribution, the bullets, and keeping GitHub's suffix outside the limit are the maintainer's choices; the suffix keeps the link from main's history to the pull request, as the existing histories show.
The rewrite on the pull request exists because `finance-tracker`'s release derives its version from the merged pull request's Conventional Commits title.

**Rejected alternative:** keeping the tool's trailer and footer, or the trailer alone.

**Rejected alternative:** a description as one short paragraph, or trimmed "Change" and "Why" sections.

**Rejected alternative:** at most five bullets, the first limit, which the maintainer raised to ten on 2026-11-22.

**Rejected alternative:** counting the suffix toward the 72 characters, or dropping it.

**Rejected alternative:** rewriting only the squash commit's title.

## One script carries a subcommand per stage

**Id:** c85d730f-01fe-409a-96e9-2281c7b81002
**Type:** decision
**Status:** active
**Evidence:** confirmed
**Source:** planning conversation with the maintainer, 2026-11-22; Copilot CLI and Claude Code skill documentation, read that day
**Verification:** corroborated — Claude Code probes with its smallest model on 2026-11-22 ran every stage through the script
**Revisit when:** Copilot CLI supports running a command when a skill loads, or the script grows a subcommand no stage calls

`skills/ship-change/scripts/ship-change.sh` checks the stage list, titles and descriptions, runs the git and gh sequences, waits for checks and Copilot, lists and resolves Copilot threads, and gates and runs the merge; the agent keeps every judgement.
`review` waits at most 90 seconds per call, under Claude Code's default two-minute tool timeout, and is run again while it reports pending; it trusts "no checks" or "no Copilot review" only once the head commit is a minute old.

**Reason:** the maintainer chose it, following `skill-authoring`'s rule that everything deterministic lives in scripts.
Copilot CLI cannot run a command when a skill loads and passes no argument placeholder, so every stage's state must come from a script the agent calls.

**Rejected alternative:** scripts only for waiting, threads and the merge gate, with the plain commands for the other stages in `SKILL.md`.

**Consequence:** a commit made long before its push can make `review` conclude too early that no checks or Copilot review are coming.

## The skill is named ship-change, for the path from branch to merge

**Id:** d140d684-198d-4c2a-86e0-f5b8db05ce3b
**Type:** decision
**Status:** active
**Evidence:** confirmed
**Source:** conversation with the maintainer, 2026-11-22
**Revisit when:** the skill grows a step outside the path from branch to merge, or another skill takes over git or GitHub operations it does not cover
**See:** instructions.md#the-rules-for-committing-and-for-guidance-files-are-skills-of-their-own — 38dc050f-c934-4ec1-a162-5d3e3c93b863 — as of 2026-11-22

The skill that takes a change from its branch to the merge of its pull request is `ship-change`, with the command `/ship-change` and the script `scripts/ship-change.sh`; until 2026-11-22 it was `git-operations`.
Its announcement names the steps it covers, creating a branch, committing, pushing, and opening, reviewing and merging a pull request, instead of every git and GitHub operation.

**Reason:** the maintainer stated that the skill covers only the path from creating a branch to merging, while other GitHub operations, and maybe other git operations, may come, which `git-operations` would claim; this is confirmed.
The verb phrase follows `implement-plan` and also fits a repository that commits to main without a pull request; the maintainer chose it with that reason put to them.

**Rejected alternative:** `git-operations`, which names every git and GitHub operation.

**Rejected alternative:** `pull-request-flow`, which fits a repository committing to main less and is longer to type.

**Rejected alternative:** `change-delivery`, which is more abstract, and `branch-to-merge`.

**Rejected alternative:** a name with "workflow", which reads as the GitHub Actions workflows of `workflow-authoring`.

## Stages can be named by their initials

**Id:** 8144144d-ac77-4bbb-b6f4-d3426f19a9d3
**Type:** decision
**Status:** active
**Evidence:** confirmed
**Source:** conversation with the maintainer, 2026-11-22
**Verification:** corroborated — script probes on 2026-11-22: check printed all five stages for b c p r m, bcprm and branch commit pr review merge, commit for c, pr review merge for prm on a feature branch, and the pr stage alone for pr
**Revisit when:** a stage is added whose initial another stage already has, or a user is found meaning pr review by pr
**See:** ship-change.md#five-stages-run-alone-or-chained-never-with-a-gap — 8898cef5-d7fc-4872-9d66-457ab4ae2a7d — as of 2026-11-22

`check` takes each argument as a stage name or else as a string of stage initials, so `b c p r m`, `bcprm` and `branch commit pr review merge` name the same run, `prm` names `pr review merge` and `c` names `commit`.
It prints the stage names, and the agent runs those.

**Reason:** the maintainer asked for it on 2026-11-22, because each stage starts with a different letter, so its initial identifies it.
A name wins over initials, so `pr` stays the pr stage alone while `p r` is `pr review`; the maintainer chose this with the reason put to them, that `/ship-change pr` keeps doing what it did before.

**Rejected alternative:** reading `pr` as initials, which names `pr review` and changes what `/ship-change pr` did.

**Consequence:** every stage needs an initial of its own, so a new stage sharing one would make initials ambiguous.
