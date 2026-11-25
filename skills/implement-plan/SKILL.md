---
name: implement-plan
description: Implements an approved plan created by the `decision-dialogue` skill.
license: MIT
metadata:
  author: Lennart Möller
argument-hint: "[plan number or task]"
disable-model-invocation: true
---

# Implement plan

These instructions govern every implementation of an approved plan from `docs/planning/`.
Always strictly follow them when implementing one.

1. Find the planning directory the user names, by number or task, under `docs/planning/`.
   When the user names none, read the status line of every `PLAN.md` there and ask with the interactive question tool which plan to implement, offering the approved plans that are not done yet, newest first.
2. Read every file in it and the files its plan points to.
3. Carry out `PLAN.md` step by step in the current checkout, keep its status and its steps' "Done: " markers current, and finish with its validation.
4. Invoke the `contract-authoring` skill with the planning directory.

Follow the [working rules](../decision-dialogue/SKILL.md#working-rules) throughout.
