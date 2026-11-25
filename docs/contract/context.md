# Context directory

```mermaid
flowchart LR
    agent["Agent or subagent"]
    script["plugins/ethos/skills/context-authoring/scripts/context.sh<br/>themes, entries, show, theme, add, set, move"]
    awk["plugins/ethos/skills/context-authoring/scripts/context.awk<br/>parses, checks and renders the topic files"]
    guard["plugins/ethos/hooks/guard.sh<br/>PreToolUse for Edit, Write, MultiEdit, NotebookEdit"]
    context["docs/context/*.md of the project<br/>one topic file per theme"]
    people["People"]

    agent -->|"command, options, body on stdin"| script
    script -->|"command and topic files"| awk
    awk -->|"reads, and writes changed files"| context
    script -->|"listing, entries, new Id or one-line refusal"| agent
    agent -->|"file tool call on a path in docs/context/"| guard
    guard -->|"refused with exit code 2, naming the script"| agent
    people -->|"read on GitHub, edit by hand"| context
```

The project is the Git toplevel of the working directory, or the working directory outside Git.
`theme` creates `docs/context/` with its first topic file, and `move` deletes a topic file whose last entry it moves out.
After every write the script points every `See` line of the project at the cited entry's current file and heading.

## Topic file

```mermaid
erDiagram
    THEME ||--o{ ENTRY : holds
    ENTRY }o--o{ ENTRY : "See, Superseded by"
    THEME {
        file name "docs/context/<name>.md, lowercase kebab-case"
        line title "# <title>"
        line summary "first line after the title"
    }
    ENTRY {
        line heading "## <heading>, the anchor others cite"
        field Id "required, UUID"
        field Type "repeatable"
        field Status "required"
        field Evidence "required"
        field Source "optional"
        field Verification "optional"
        field Revisit_when "optional"
        field See "repeatable, locator, Id and date"
        field Superseded_by "with status superseded only"
        text body "Markdown prose"
    }
```

Each field is one `**<Field>:** <value>` line below the heading, in the order above; the values each field accepts are in `context.awk`.
