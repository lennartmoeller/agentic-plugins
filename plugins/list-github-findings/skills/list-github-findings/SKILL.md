---
name: list-github-findings
description: Lists every open code scanning, secret scanning, Dependabot and code quality finding of the current GitHub repository.
license: MIT
compatibility: Requires a POSIX shell and GitHub CLI 2.50 or later.
metadata:
  author: Lennart Möller
disable-model-invocation: true
---

# List GitHub findings

These instructions govern the listing of a repository's open GitHub findings.
Always strictly follow them when listing these findings or working on one.

- Run `sh "<this skill's base directory>/scripts/list-github-findings.sh"` with the repository as working directory.
- Show the user every group it lists with its count, and every finding with its number, severity, rule or advisory, location or package, and link.
- Report only the groups it lists: it leaves out every group GitHub refuses, mostly because the feature is switched off.
- Read a finding's full details with `gh api repos/{owner}/{repo}/<group>/<number>` before working on it, `<group>` being the heading it is listed under.
- Change nothing unless the user asks.
