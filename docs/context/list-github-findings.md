# List GitHub findings

how the list-github-findings skill lists a repository's open GitHub findings: where it came from, what its script prints, which groups it leaves out, who starts it, its name and what is still unverified

## list-github-findings is a rebuild of the maintainer's own ghas-findings skill

**Id:** 87b609a6-7cd4-474c-8e0e-8094f26e71a1
**Type:** decision
**Status:** active
**Evidence:** confirmed
**Source:** planning conversation with the maintainer, 2026-11-22
**See:** skills.md#every-skill-script-is-posix-sh-started-from-the-skills-base-directory — e2070f87-9e37-4962-a6de-58fd016dbc7e — as of 2026-11-22
**See:** skills.md#each-part-of-a-skill-has-one-job — 240ad9b3-f152-4d51-add8-78cbefc798cb — as of 2026-11-22

The skill started as `ghas-findings`, a skill of the maintainer's own kept outside this repository, and was rebuilt to the rules of `skill-authoring`, so its frontmatter carries no `inspired-by`.
The rebuild ported its Bash script to POSIX `sh`, dropped its optional `[owner/repo]` argument and its use of `jq`, and kept its four groups, its two secret scanning requests and its rule to change nothing unless asked.

**Reason:** the maintainer asked to integrate the skill and stated it is their own work.
No step of the skill passed the repository argument, and `gh api` resolves `{owner}/{repo}` from the current repository or from `GH_REPO`; `gh api --jq` carries its own jq.
Dropping both was the agent's proposal, which the maintainer approved with the plan.

**Rejected alternative:** keeping the argument, an option no caller set.

**Consequence:** the skill's requirements are a POSIX shell and GitHub CLI, both already in the installer's list, so `install.sh` did not change.

## The script prints a ready listing, one line per finding

**Id:** 97db7303-777e-4465-87b0-821430a667a7
**Type:** decision
**Status:** active
**Evidence:** confirmed
**Source:** planning conversation with the maintainer, 2026-11-22; GitHub REST API probes that day
**Verification:** corroborated — a run against a repository with 164 open Dependabot alerts on 2026-11-22 listed all 164, under macOS sh and dash alike
**See:** list-github-findings.md#list-github-findings-is-a-rebuild-of-the-maintainers-own-ghas-findings-skill — 87b609a6-7cd4-474c-8e0e-8094f26e71a1 — as of 2026-11-22

For each group that answers, `list-github-findings.sh` prints a heading with the group's API path and its count, such as `## dependabot/alerts: 164`, then one line per open finding: its number, severity, rule or advisory, location or package, and link.
The agent reads a finding's full details with `gh api repos/{owner}/{repo}/<group>/<number>` only when it works on that finding, which is why the heading names the API path.

**Reason:** the maintainer chose it on the agent's recommendation.
The 164 open Dependabot alerts of one repository were 1,125,916 bytes as raw JSON, about 280,000 tokens, and 22,430 bytes as such a listing; the formatting is deterministic, so the script does it.

**Rejected alternative:** one JSON object with the full API objects of every group, as `ghas-findings` printed, which floods a session on a large repository and needs `jq`.

**Consequence:** a field outside the listing takes a second request per finding.

## A group GitHub refuses is left out of the listing

**Id:** 42f1a296-60f9-4905-b354-528285b8422c
**Type:** decision
**Status:** active
**Evidence:** inferred
**Source:** planning conversation with the maintainer, 2026-11-22; GitHub REST API probes of 8 of the maintainer's repositories that day
**Verification:** corroborated — runs on 2026-11-22: a repository with three groups switched off listed only the fourth, and runs with every group refused, a bad token or no Git repository printed the refusal and exited 1
**Revisit when:** a group is found missing from the listing for a reason other than its feature being switched off, such as a missing permission
**See:** list-github-findings.md#the-script-prints-a-ready-listing-one-line-per-finding — 97db7303-777e-4465-87b0-821430a667a7 — as of 2026-11-22

A group whose request fails, by 404 or any other error, is left out of the listing without a trace, and the other groups are still listed; an empty group is listed with count 0.
Only when every group fails does the script print "no finding could be read" with the first error line and exit 1.

**Reason:** the maintainer asked to omit everything that returns 404 or an error, which is confirmed; the maintainer stated no reason.
In each of the 8 probed repositories at least one group failed because its feature was switched off, code quality in all 8, so naming those failures would be noise on every run; this reason is inferred.
The exception for every group failing was the agent's proposal, approved with the plan, so that a failed login or a directory outside a repository never reads as "no findings".

**Rejected alternative:** reporting a failed group with its reason, as `ghas-findings` asked.

**Rejected alternative:** aborting the whole run on the first failure, as the script of `ghas-findings` did, which printed nothing for any of the 8 probed repositories.

**Consequence:** a group refused for a reason worth knowing, such as a missing permission, disappears silently.

## list-github-findings is user-only

**Id:** ab436dc8-2fa3-4422-94c9-82e13f07924c
**Type:** decision
**Status:** active
**Evidence:** inferred
**Source:** planning conversation with the maintainer, 2026-11-22
**Verification:** contradicted — since 2026-11-25 the skill is a plugin of its own, so the user starts it as /list-github-findings, which 32e8dc09-dc9f-4edf-a9a5-2617d6f2d368 records
**Revisit when:** the maintainer wants the agent to list findings without being asked, or Copilot CLI is found invoking the skill on its own
**See:** skills.md#each-part-of-a-skill-has-one-job — 240ad9b3-f152-4d51-add8-78cbefc798cb — as of 2026-11-22
**See:** distribution.md#the-setup-travels-as-three-plugins-from-a-marketplace-in-this-repository — 32e8dc09-dc9f-4edf-a9a5-2617d6f2d368 — as of 2026-11-25

The skill sets `disable-model-invocation: true` and has no announcement in `hooks/instructions/`, so the user starts it as `/agentic:list-github-findings`.

**Reason:** the maintainer chose it, which is confirmed, without stating why.
The question put to the maintainer weighed one more line in every session of every consuming repository against the agent picking the skill up on a request about findings; that this cost decided it is inferred.

**Rejected alternative:** an announcement in `shared.md` for sessions and subagents, which the agent recommended.

**Rejected alternative:** an announcement in `session.md` only.

**Consequence:** Copilot CLI documents no `disable-model-invocation`, so it may still invoke the skill on its description.

## The skill is named list-github-findings

**Id:** 6d88b24b-b3a4-40e6-8b20-8f9c9d04d539
**Type:** decision
**Status:** active
**Evidence:** inferred
**Source:** planning conversation with the maintainer, 2026-11-22
**See:** list-github-findings.md#list-github-findings-is-a-rebuild-of-the-maintainers-own-ghas-findings-skill — 87b609a6-7cd4-474c-8e0e-8094f26e71a1 — as of 2026-11-22

The skill's folder and name are `list-github-findings`, its display name "List GitHub findings".

**Reason:** the maintainer named it, which is confirmed.
The agent had argued for a verb-noun name like the other user-started skills `ship-change` and `implement-plan`, and against "GHAS", which covers code and secret scanning but neither Dependabot alerts nor code quality; that the chosen name follows both points is inferred.

**Rejected alternative:** `ghas-findings`, the name of the skill it was rebuilt from.

**Rejected alternative:** `list-findings`, which the agent recommended, and `github-findings`.

## A code quality finding links to its url as GitHub gives it

**Id:** 3daf32ed-3e61-4c32-8244-1702fb4197d6
**Type:** constraint
**Status:** active
**Evidence:** inferred
**Source:** GitHub REST API documentation, read 2026-11-22; planning conversation with the maintainer that day
**Verification:** uncorroborated — code quality returned 404 in all 8 probed repositories, so no finding was seen
**Revisit when:** a repository with code quality enabled is at hand to check what url holds
**See:** list-github-findings.md#the-script-prints-a-ready-listing-one-line-per-finding — 97db7303-777e-4465-87b0-821430a667a7 — as of 2026-11-22

The code quality line ends with the finding's `url`, while the other groups end with `html_url`.

**Reason:** the documentation names only `url` for a code quality finding and does not say whether it is a web or an API link; the maintainer accepted printing it as given, as the agent recommended.

**Consequence:** the link may be an API link, which still opens with `gh api`.
