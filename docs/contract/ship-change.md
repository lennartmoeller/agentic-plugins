# Ship change

```mermaid
sequenceDiagram
    participant agent as Agent
    participant script as skills/ship-change/scripts/ship-change.sh
    participant git as Git and origin
    participant github as GitHub through gh

    agent->>script: check, with the run's stages as names or initials
    script->>git: fetch, status, unpushed commits
    script->>github: the branch's pull request
    script-->>agent: the run's stage names, or a one-line refusal naming the run that would cover it
    agent->>script: branch, with a name on the default branch
    script->>git: switch --create from the default branch of origin, or rebase onto it
    agent->>script: commit, with a title and --main where the repository commits to its default branch
    script->>git: add --all, commit, push, with --force-with-lease on a feature branch
    agent->>script: pr, with a title and the body on stdin
    script->>github: the branch's open pull request, or a new one against the default branch
    loop until review prints clean
        agent->>script: review
        script->>github: checks, a pending Copilot review request, unresolved Copilot threads
        script-->>agent: pending with exit 8, clean, or each failing check and Copilot thread
        agent->>script: commit with the fixes, then resolve with a reason and a reply per thread
        script->>github: reply to the thread and resolve it
    end
    agent->>script: merge, with a rewritten title where the pull request's is refused
    script->>github: no failing or pending check, squash merge titled with the pull request number, admin merge on a refusal, branch deleted
    script->>git: switch to the default branch, pull --ff-only
```

The agent reads the stages from `/ship-change` or the user's words, and `state` gives it the facts behind its judgements, such as whether a branch is meant for the changes; [`SKILL.md`](../../skills/ship-change/SKILL.md) holds the rules, and [`docs/context/ship-change.md`](../context/ship-change.md) the reasons.
