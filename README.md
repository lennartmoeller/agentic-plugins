# Agentic

Highly opinionated skills for coding agents packaged as plugins for Claude Code and GitHub Copilot CLI.

## Plugins

### `ethos`

The core skills, optimized for everyday work.

#### General working

- [`foundational-coding-principles`](./plugins/ethos/skills/foundational-coding-principles/SKILL.md)<br/>Sets the coding principles every plan and change must follow.

#### Implementation flow

- [`decision-dialogue`](./plugins/ethos/skills/decision-dialogue/SKILL.md)<br/>Refines an idea into an approved plan through a Q&A with the user.
- [`implement-plan`](./plugins/ethos/skills/implement-plan/SKILL.md)<br/>Implements an approved plan created by the `decision-dialogue` skill.
- [`ship-change`](./plugins/ethos/skills/ship-change/SKILL.md) <mark>[beta]</mark><br/>Ships a change from a feature branch through commits and a pull request to a squash merge.

#### Documentation

- [`context-authoring`](./plugins/ethos/skills/context-authoring/SKILL.md) <mark>[beta]</mark><br/>Creates and edits `docs/context/`, the record of why the code is the way it is, and keeps it current.
- [`contract-authoring`](./plugins/ethos/skills/contract-authoring/SKILL.md) <mark>[beta]</mark><br/>Creates and edits `docs/contract/`, the architecture overview of the code, and keeps it current.
- [`guidance-authoring`](./plugins/ethos/skills/guidance-authoring/SKILL.md)<br/>Creates and edits `README.md`, `CONTRIBUTING.md`, `AGENTS.md` and `CLAUDE.md`, the guidance for people and agents across the repository, and keeps them current.

#### File formats

- [`markdown-authoring`](./plugins/ethos/skills/markdown-authoring/SKILL.md)<br/>Creates and edits any Markdown file.
- [`workflow-authoring`](./plugins/ethos/skills/workflow-authoring/SKILL.md)<br/>Creates and edits GitHub Actions workflows and reusable actions/workflows.

### `empty-house-refactoring`

- [`empty-house-refactoring`](./plugins/empty-house-refactoring/skills/empty-house-refactoring/SKILL.md) <mark>[beta]</mark><br/>Rewrites a repository from its idea in an emptied checkout.

### `list-github-findings`

- [`list-github-findings`](./plugins/list-github-findings/skills/list-github-findings/SKILL.md)<br/>Lists every open code scanning, secret scanning, Dependabot and code quality finding of the current GitHub repository.

## Installation

To set up or update the plugins, run this inside each repository that should use them:

```sh
curl -fsSL https://raw.githubusercontent.com/lennartmoeller/agentic-plugins/main/install.sh | bash
```

## Change it

[CONTRIBUTING.md](./CONTRIBUTING.md) describes how to try, check and publish a change.

## License

[MIT](./LICENSE)

`context-authoring` is inspired by [Keep the Why](https://github.com/oliver-zehentleitner/keep-the-why) by Oliver Zehentleitner.
