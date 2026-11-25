---
name: ship-change
description: Ships a change from a feature branch through commits and a pull request to a squash merge.
license: MIT
compatibility: Requires a POSIX shell, Git 2.23 or later and GitHub CLI 2.50 or later.
metadata:
  author: Lennart Möller
argument-hint: "[branch|b] [commit|c] [pr|p] [review|r] [merge|m]"
---

# Ship change

These instructions govern every step that ships a change in this repository: creating its branch, committing, pushing, and opening, reviewing and merging its pull request.
Always strictly follow them when taking any of these steps.

## Rules

- Run a stage only when the user asks for that stage, through `/ship-change` or in their own words; asking to implement a plan that lists the stage does not count.
- Never ask for, offer or suggest a stage the user has not asked for, even when it is the next logical step: once a change is done, report what changed and stop.
- Run each stage through `sh "<this skill's base directory>/scripts/ship-change.sh" <command>`, with the repository as working directory, and anything else on GitHub through `gh`.
- Write every commit and pull request title as a Conventional Commits title of at most 72 characters that sums up the whole change.
- Never add a commit description, a trailer such as `Co-Authored-By`, or a "Generated with" line, whatever the tool's default.

## Stages

| Stage | Makes sure that | Command |
|---|---|---|
| `branch` | a feature branch from latest main exists and is checked out | `branch [<name>]` |
| `commit` | every change in the worktree is committed and pushed | `commit [--main] <title>` |
| `pr` | the branch has an open pull request | `pr <title> < body` |
| `review` | every check passes and no Copilot conversation is unresolved | `review`, `resolve <thread-id> <ADDRESSED\|WONT_FIX> <reply>` |
| `merge` | the pull request is squash-merged and the checkout is on latest main | `merge [<title>]` |

- Take the stages from the arguments or the user's words, as names or initials such as `prm`, run `check` with them before anything else, and stop on its refusal, passing on the run it names.
- Run the stages `check` prints in order, and stop at the first that fails, reporting why.
- Without a stage, run `state`, report it, and ask through the interactive question tool which run to do, offering only runs that `check` accepts.

### Branch

- On the default branch, name the new branch `<type>/<kebab-summary>`, such as `feat/account-transfers`.
- On another branch, judge from `state`, the branch name and `git log origin/<default>..HEAD` whether it is meant for the changes, and stop when it is not.

### Commit

- Start a run that begins at `commit` with `branch`.
- Where the repository's own `AGENTS.md`, `CLAUDE.md` or `CONTRIBUTING.md` says to commit to the default branch, skip `branch` unless the user asks for it, and pass `--main`.

### Pull request

- Title it for all commits in `git log origin/<default>..HEAD`, not only the last.
- Write the body as one to ten `- ` bullets on what changed and, where it is not obvious, why, without headings, test plan or per-file detail.

### Review

Repeat until `review` prints `clean`:

1. Run `review`, and run it again while it exits 8.
2. Fix every failing check, reading its log with `gh run view <run-id> --log-failed`.
3. Weigh every Copilot thread, and fix the ones worth fixing.
4. Commit and push the fixes with `commit`.
5. Resolve every thread: `ADDRESSED` with a reply naming the fixing commit, or `WONT_FIX` with a one-sentence reason.

### Merge

- Pass `merge` a rewritten title only when it refuses the pull request's title.
