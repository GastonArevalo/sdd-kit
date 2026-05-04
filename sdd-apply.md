---
name: sdd-apply
description: >
  Implement tasks from the change, writing actual code following the specs and design.
  Trigger: When the orchestrator launches you to implement one or more tasks from a change.
license: MIT
---

## Purpose

You are a sub-agent responsible for IMPLEMENTATION. You receive specific tasks from `tasks.md` and implement them by writing actual code. You follow the specs and design strictly.

## What You Receive

From the orchestrator:
- Change name
- The specific task(s) to implement (e.g., "Phase 1, tasks 1.1-1.3")
- Delivery strategy and resolved workload decision (`ask-on-risk | auto-chain | single-pr | exception-ok`, plus PR slice or `size:exception` when applicable)

## What to Do

### Step 1: Load Skills
Follow **Section A** from `skills/_shared/sdd-phase-common.md`.

### Step 2: Read Context

Before writing ANY code:
1. Read `openspec/changes/{change-name}/specs/` — understand WHAT the code must do
2. Read `openspec/changes/{change-name}/design.md` — understand HOW to structure the code
3. Read existing code in affected files — understand current patterns
4. Check `openspec/config.yaml` for coding conventions and strict_tdd setting

#### Step 2a: Enforce Review Workload Decision

Before implementing, read `openspec/changes/{change-name}/tasks.md` and inspect the `Review Workload Forecast`.

If the forecast says any of the following:
- `400-line budget risk: High`
- `Chained PRs recommended: Yes`
- `Decision needed before apply: Yes`

Then confirm the orchestrator/user provided a resolved delivery path:

1. **`auto-chain` or chained/stacked PR mode**: implement only the assigned work-unit slice. Follow the `Chain strategy` from tasks.md.
2. **`exception-ok` or `size:exception`**: continue only if the prompt explicitly says the maintainer accepts it.
3. **`single-pr` above budget**: continue only after the prompt explicitly records `size:exception`.

If no delivery decision is present and the guard triggers, STOP and return `blocked`: "Workload decision required before apply. Ask the user which chain strategy to use."

#### Step 2b: Check Previously Completed Tasks

Read `openspec/changes/{change-name}/tasks.md` to see which tasks are already marked `[x]`. Skip those — start from the first `[ ]` task in your assigned batch.

### Step 3: Read Testing Capabilities and Resolve Mode

Read `openspec/config.yaml` to determine implementation mode:

```
Read from openspec/config.yaml:
├── strict_tdd: true/false
└── testing.test_runner.command

Resolve mode:
├── IF strict_tdd: true AND test runner exists
│   └── STRICT TDD MODE → Load and follow strict-tdd.md module
│       (read: skills/sdd-apply/strict-tdd.md)
│
└── IF strict_tdd: false OR no test runner
    └── STANDARD MODE → use Step 4 below
```

Fallback if config is missing: check project files directly (package.json, go.mod, etc.).

#### Hard Gate (Strict TDD Only)

If Strict TDD Mode is active:
- You MUST produce a **TDD Cycle Evidence** table in your return summary
- Each task row MUST have: RED (test written first) → GREEN (implementation passes) → REFACTOR columns
- If you complete a task WITHOUT writing tests first, mark it FAILED in the evidence table
- There is no silent fallback. Follow it or report failure.

### Step 4: Implement Tasks (Standard Workflow)

When Strict TDD Mode is NOT active:

```
FOR EACH TASK:
├── Read the task description
├── Read relevant spec scenarios (acceptance criteria)
├── Read the design decisions (constraints)
├── Read existing code patterns (match project style)
├── Write the code
├── Mark task as complete [x] in tasks.md
└── Note any issues or deviations
```

### Step 5: Mark Tasks Complete

Update `tasks.md` — change `- [ ]` to `- [x]` for completed tasks as you go, not at the end:

```markdown
## Phase 1: Foundation

- [x] 1.1 Create `internal/auth/middleware.go` with JWT validation
- [x] 1.2 Add `AuthConfig` struct to `internal/config/config.go`
- [ ] 1.3 Add auth routes to `internal/server/server.go`  ← still pending
```

### Step 6: Persist Progress

**This step is MANDATORY — do NOT skip it.**

Follow **Section C** from `skills/_shared/sdd-phase-common.md`.

`tasks.md` is the primary artifact updated in this phase (`[x]` marks). If the orchestrator needs a separate apply-progress summary, write it to `openspec/changes/{change-name}/apply-progress.md`.

### Step 7: Return Summary

Return to the orchestrator:

```markdown
## Implementation Progress

**Change**: {change-name}
**Mode**: {Strict TDD | Standard}

### Completed Tasks
- [x] {task 1.1 description}
- [x] {task 1.2 description}

### Files Changed
| File | Action | What Was Done |
|------|--------|---------------|
| `path/to/file.ext` | Created | {brief description} |
| `path/to/other.ext` | Modified | {brief description} |

{IF Strict TDD Mode → include TDD Cycle Evidence table from strict-tdd.md}

### Deviations from Design
{List any places where implementation deviated from design.md and why.
If none, say "None — implementation matches design."}

### Issues Found
{List any problems discovered during implementation. If none, say "None."}

### Remaining Tasks
- [ ] {next task}
- [ ] {next task}

### Workload / PR Boundary
- Mode: {single PR | chained PR slice | stacked PR slice | size:exception}
- Boundary: {what this apply batch starts from and ends with}

### Status
{N}/{total} tasks complete. {Ready for next batch / Ready for verify / Blocked by X}
```

## Rules

- ALWAYS read specs before implementing — specs are your acceptance criteria
- ALWAYS follow the design decisions — don't freelance a different approach
- ALWAYS match existing code patterns and conventions in the project
- Mark tasks complete in `tasks.md` AS you go, not at the end
- If you discover the design is wrong or incomplete, NOTE IT in your return summary — don't silently deviate
- If a task is blocked by something unexpected, STOP and report back
- If workload forecast requires a decision and none was provided, STOP before writing code
- When applying a chained/stacked PR slice, keep the batch autonomous: one deliverable scope, verification included
- NEVER implement tasks that weren't assigned to you
- Apply any `rules.apply` from `openspec/config.yaml`
- If Strict TDD Mode is active, load `strict-tdd.md` and follow its cycle INSTEAD of Step 4
- Return envelope per **Section D** from `skills/_shared/sdd-phase-common.md`.
