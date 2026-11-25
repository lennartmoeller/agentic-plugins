# Agentic

A set of highly opinionated skills for coding agents packaged as a plugin for Claude Code and GitHub Copilot CLI.

## Skills

### General working

- [`foundational-coding-principles`](./skills/foundational-coding-principles/SKILL.md)<br/>Sets the coding principles every plan and change must follow.

### Implementation flow

- [`decision-dialogue`](./skills/decision-dialogue/SKILL.md) <mark>[beta]</mark><br/>Refines an idea into an approved plan through a Q&A with the user.
- [`implement-plan`](./skills/implement-plan/SKILL.md) <mark>[beta]</mark><br/>Implements an approved plan created by the `decision-dialogue` skill.
- [`ship-change`](./skills/ship-change/SKILL.md)<br/>Ships a change from a feature branch through commits and a pull request to a squash merge.

### Documentation

- [`context-authoring`](./skills/context-authoring/SKILL.md) <mark>[beta]</mark><br/>Creates and edits `docs/context/`, the record of why the code is the way it is, and keeps it current.
- [`contract-authoring`](./skills/contract-authoring/SKILL.md) <mark>[beta]</mark><br/>Creates and edits `docs/contract/`, the architecture overview of the code, and keeps it current.
- [`guidance-authoring`](./skills/guidance-authoring/SKILL.md)<br/>Creates and edits `README.md`, `CONTRIBUTING.md`, `AGENTS.md` and `CLAUDE.md`, the guidance for people and agents across the repository, and keeps them current.

### File formats

- [`markdown-authoring`](./skills/markdown-authoring/SKILL.md) <mark>[beta]</mark><br/>Creates and edits any Markdown file.
- [`workflow-authoring`](./skills/workflow-authoring/SKILL.md)<br/>Creates and edits GitHub Actions workflows and reusable actions/workflows.

### Special use cases

- [`empty-house-refactoring`](./skills/empty-house-refactoring/SKILL.md) <mark>[beta]</mark><br/>Rewrites a repository from its idea in an emptied checkout.
- [`list-github-findings`](./skills/list-github-findings/SKILL.md) <mark>[beta]</mark><br/>Lists every open code scanning, secret scanning, Dependabot and code quality finding of the current GitHub repository.

## Installation

To install or update the plugin, run this inside each repository that should use it:

```sh
curl -fsSL https://raw.githubusercontent.com/lennartmoeller/agentic-plugins/main/install.sh | bash
```

## Change it

[CONTRIBUTING.md](./CONTRIBUTING.md) describes how to try, check and publish a change.

## License

[MIT](./LICENSE)

`context-authoring` is inspired by [Keep the Why](https://github.com/oliver-zehentleitner/keep-the-why) by Oliver Zehentleitner.
