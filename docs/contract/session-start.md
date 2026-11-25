# Session start

```mermaid
sequenceDiagram
    participant tool as Claude Code or Copilot CLI
    participant hook as hooks/hooks.json
    participant script as hooks/rules.sh
    participant session as hooks/instructions/session.md
    participant subagent as hooks/instructions/subagent.md
    participant list as hooks/instructions/shared.md
    participant agent as Agent or subagent
    participant why as skills/context-authoring
    participant skill as skills/foundational-coding-principles

    tool->>hook: a session or a subagent starts
    hook->>script: the event name, SessionStart or SubagentStart
    alt a session starts
        script->>session: read
        session-->>script: the rule that loads context-authoring at once
    else a subagent starts
        script->>subagent: read
        subagent-->>script: the rule that loads context-authoring before a file in docs/context/ changes
    end
    script->>list: read
    list-->>script: one rule per skill and occasion, and the rule to run the quality gate at the end of an implementation change
    script-->>tool: one JSON object with both as hook context
    tool->>agent: the rules, before the first request
    opt a session starts, or a subagent is about to change a file in docs/context/
        agent->>why: load the skill
        why-->>agent: how to record the why, and the commands of the context script
    end
    opt the request involves code or architecture, asks for a plan or a change, or a file is about to change
        agent->>skill: load the skill
        skill-->>agent: the coding principles
    end
    opt the user invokes the skill with a task
        agent->>skill: the task
        skill-->>agent: the coding principles, and how to carry out a task against them
    end
```

A session and a subagent receive the same shared list, and each its own rule for `context-authoring`: a session loads it at once, a subagent before it changes a file in `docs/context/`.
The session start creates nothing in the project.

[The context directory](./context.md) shows how the agent then reads and writes `docs/context/`.

The JSON object carries the rules twice, in the top-level `additionalContext` that Copilot CLI reads and in `hookSpecificOutput.additionalContext` that Claude Code reads.

Copilot CLI starts its `general-purpose` subagent without a hook, so that subagent knows the rules only through what the main agent passes on.

## Instruction files of a repository

A repository's own `AGENTS.md` or `CLAUDE.md` files reach the agent through the tool itself, beside the plugin.
