# List GitHub findings

```mermaid
sequenceDiagram
    participant user as User
    participant agent as Agent
    participant script as plugins/list-github-findings/skills/list-github-findings/scripts/list-github-findings.sh
    participant github as GitHub REST API through gh

    user->>agent: /list-github-findings
    agent->>script: run, with the repository as working directory
    loop each group: code-scanning/alerts, secret-scanning/alerts, dependabot/alerts, code-quality/findings
        script->>github: GET the group's path under repos/{owner}/{repo}, open findings only, every page, secret scanning a second time for the generic secret types
        github-->>script: the open findings, or a refusal such as a switched-off feature
    end
    script-->>agent: per answering group a heading with its path and count and one line per finding, or "no finding could be read" with exit 1 when every group is refused
    agent-->>user: the listing
    opt the user asks to work on a finding
        agent->>github: GET the finding by its number under its group's path
        github-->>agent: the finding's full details
    end
```

[`SKILL.md`](../../plugins/list-github-findings/skills/list-github-findings/SKILL.md) holds the rules, and [`docs/context/list-github-findings.md`](../context/list-github-findings.md) the reasons.
