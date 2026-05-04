---
name: sdd-tasks
description: >
  Break down a change into an implementation task checklist.
  Trigger: When the orchestrator launches you to create or update the task breakdown for a change.
license: MIT
---

## Purpose

You are a sub-agent responsible for creating the TASK BREAKDOWN. You take the proposal, specs, and design, then produce a `tasks.md` with concrete, actionable implementation steps organized by phase.

## What You Receive

From the orchestrator:
- Change name
- Delivery strategy (`ask-on-risk | auto-chain | single-pr | exception-ok`)

## What to Do

### Step 1: Load Skills
Follow **Section A** from `skills/_shared/sdd-phase-common.md`.

### Step 2: Read Context

Read before breaking down:
- `openspec/changes/{change-name}/proposal.md` (required)
- `openspec/changes/{change-name}/specs/` (required)
- `openspec/changes/{change-name}/design.md` (required)

### Step 3: Write tasks.md

Create `openspec/changes/{change-name}/tasks.md`:

```markdown
# Tasks: {Change Title}

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | <rough estimate or range> |
| 400-line budget risk | Low / Medium / High |
| Chained PRs recommended | Yes / No |
| Suggested split | <single PR or PR 1 → PR 2 → PR 3> |
| Delivery strategy | <ask-on-risk / auto-chain / single-pr / exception-ok> |
| Chain strategy | <stacked-to-main / feature-branch-chain / size-exception / pending> |

Decision needed before apply: <Yes|No>
Chained PRs recommended: <Yes|No>
Chain strategy: <stacked-to-main|feature-branch-chain|size-exception|pending>
400-line budget risk: <Low|Medium|High>

### Suggested Work Units

| Unit | Goal | Likely PR | Notes |
|------|------|-----------|-------|
| 1 | <standalone deliverable> | PR 1 | <tests/docs included> |
| 2 | <standalone deliverable> | PR 2 | <depends on PR 1 or independent> |

## Phase 1: {Phase Name} (e.g., Infrastructure / Foundation)

- [ ] 1.1 {Concrete action — what file, what change}
- [ ] 1.2 {Concrete action}
- [ ] 1.3 {Concrete action}

## Phase 2: {Phase Name} (e.g., Core Implementation)

- [ ] 2.1 {Concrete action}
- [ ] 2.2 {Concrete action}
- [ ] 2.3 {Concrete action}

## Phase 3: {Phase Name} (e.g., Testing / Verification)

- [ ] 3.1 {Write tests for ...}
- [ ] 3.2 {Write tests for ...}
- [ ] 3.3 {Verify integration between ...}

## Phase 4: {Phase Name} (e.g., Cleanup / Documentation)

- [ ] 4.1 {Update docs/comments}
- [ ] 4.2 {Remove temporary code}
```

### Task Writing Rules

Each task MUST be:

| Criteria | Example ✅ | Anti-example ❌ |
|----------|-----------|----------------|
| **Specific** | "Create `internal/auth/middleware.go` with JWT validation" | "Add auth" |
| **Actionable** | "Add `ValidateToken()` method to `AuthService`" | "Handle tokens" |
| **Verifiable** | "Test: `POST /login` returns 401 without token" | "Make sure it works" |
| **Small** | One file or one logical unit of work | "Implement the feature" |

### Review Workload Forecast Rules

Before finalizing tasks, estimate whether implementation is likely to exceed the **400 changed-line review budget**. This is a planning guard, not an exact diff count.

If the estimate is **High** or likely above 400 lines:

1. Mark `Chained PRs recommended` as `Yes`.
2. Split tasks into **work units** that can become chained or stacked PRs.
3. Each suggested PR must have a clear start, clear finish, verification, and autonomous scope.
4. **Ask the user which chain strategy to use**:
   - **Stacked PRs to main** — each PR merges to main in order. Best for speed-first teams and independent slices.
   - **Feature Branch Chain** — all PRs merge into a shared branch. Only the tracker merges to main. Best for rollback control.
   - **size:exception** — keep it as a single PR with maintainer approval. Best for generated code or vendor diffs.
5. Cache the user's choice and set `Decision needed before apply` from the delivery strategy received:
   - `ask-on-risk`: `Yes` — orchestrator asks before apply.
   - `auto-chain`: `No` — orchestrator proceeds with first slice.
   - `single-pr`: `Yes` — orchestrator must require `size:exception` before apply.
   - `exception-ok`: `No` — maintainer has accepted `size:exception`.

The forecast MUST include these exact plain-text lines so downstream guards can match them literally:

```text
Decision needed before apply: Yes|No
Chained PRs recommended: Yes|No
Chain strategy: stacked-to-main|feature-branch-chain|size-exception|pending
400-line budget risk: Low|Medium|High
```

### Phase Organization Guidelines

```
Phase 1: Foundation / Infrastructure
  └─ New types, interfaces, database changes, config
  └─ Things other tasks depend on

Phase 2: Core Implementation
  └─ Main logic, business rules, core behavior

Phase 3: Integration / Wiring
  └─ Connect components, routes, UI wiring

Phase 4: Testing
  └─ Unit tests, integration tests, e2e tests
  └─ Verify against spec scenarios

Phase 5: Cleanup (if needed)
  └─ Documentation, remove dead code, polish
```

### Step 4: Persist Artifact

**This step is MANDATORY — do NOT skip it.**

Follow **Section C** from `skills/_shared/sdd-phase-common.md`.
- artifact: `openspec/changes/{change-name}/tasks.md`

### Step 5: Return Summary

Return to the orchestrator:

```markdown
## Tasks Created

**Change**: {change-name}
**Location**: `openspec/changes/{change-name}/tasks.md`

### Breakdown
| Phase | Tasks | Focus |
|-------|-------|-------|
| Phase 1 | {N} | {Phase name} |
| Phase 2 | {N} | {Phase name} |
| Phase 3 | {N} | {Phase name} |
| Total | {N} | |

### Review Workload Forecast
- Estimated changed lines: {estimate or range}
- 400-line budget risk: {Low | Medium | High}
- Chained PRs recommended: {Yes | No}
- Delivery strategy: {ask-on-risk | auto-chain | single-pr | exception-ok}
- Decision needed before apply: {Yes | No}
- Suggested work-unit PR split: {brief list or "Not needed"}

### Next Step
{Ready for implementation (sdd-apply) OR ask the user whether to use chained PRs before sdd-apply.}
```

## Rules

- ALWAYS reference concrete file paths in tasks
- Tasks MUST be ordered by dependency — Phase 1 tasks shouldn't depend on Phase 2
- Testing tasks should reference specific scenarios from the specs
- Each task should be completable in ONE session (if a task feels too big, split it)
- Use hierarchical numbering: 1.1, 1.2, 2.1, 2.2, etc.
- NEVER include vague tasks like "implement feature" or "add tests"
- Apply any `rules.tasks` from `openspec/config.yaml`
- If the project uses TDD (strict_tdd: true in config.yaml), integrate test-first tasks: RED → GREEN → REFACTOR
- **Size budget**: Tasks artifact MUST be under 530 words. Each task: 1-2 lines max.
- **Review workload guard**: ALWAYS include the Review Workload Forecast. If likely above 400 changed lines, recommend chained PRs and honor the received delivery strategy.
- Return envelope per **Section D** from `skills/_shared/sdd-phase-common.md`.
