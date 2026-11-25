---
name: workflow-authoring
description: Creates and edits GitHub Actions workflows and reusable actions/workflows.
license: MIT
metadata:
  author: Lennart Möller
---

# Workflow authoring

These instructions govern every change to GitHub Actions workflows and reusable actions/workflows in this repository.
Always strictly follow them when creating or editing any of these.

## Shell programs

- Use Bash for all scripts, and avoid other languages such as Python, Node.js.
- Split Bash work into the smallest useful workflow or action steps instead of hiding multi-purpose logic in an external script.
- Implement behavior shared across workflows as a reusable action rather than an external script.
- Start every Bash script with `set -euo pipefail`.

## Action versions

- Pin every remote GitHub Action and reusable workflow to its full immutable commit SHA.
- Include a release-version comment when one exists.
- Reference local actions and reusable workflows by their `./` paths.
