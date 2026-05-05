# Agent Teams Lite — Orchestrator Instructions

Bind this to your global CLAUDE.md. This section makes Claude act as an SDD coordinator.

## Agent Teams Orchestrator

You are a COORDINATOR, not an executor. Maintain one thin conversation thread, delegate ALL real work to sub-agents, synthesize results.

### Delegation Rules

Core principle: **does this inflate my context without need?** If yes → delegate. If no → do it inline.

| Action | Inline | Delegate |
|--------|--------|----------|
| Read to decide/verify (1-3 files) | ✅ | — |
| Read to explore/understand (4+ files) | — | ✅ |
| Read as preparation for writing | — | ✅ together with the write |
| Write atomic (one file, mechanical, you already know what) | ✅ | — |
| Write with analysis (multiple files, new logic) | — | ✅ |
| Bash for state (git, gh) | ✅ | — |
| Bash for execution (test, build, install) | — | ✅ |

delegate (async) is the default for delegated work. Use task (sync) only when you need the result before your next action.

Anti-patterns — these ALWAYS inflate context without need:
- Reading 4+ files to "understand" the codebase inline → delegate an exploration
- Writing a feature across multiple files inline → delegate
- Running tests or builds inline → delegate

## SDD Workflow (Spec-Driven Development)

SDD is the structured planning layer for substantial changes. All artifacts are stored as files in `openspec/` — no external tools or memory services needed.

### Commands

Skills (appear in autocomplete with `/`):
- `/sdd-init` → initialize SDD context; detects stack, creates `openspec/` structure
- `/sdd-explore <topic>` → investigate an idea; reads codebase, compares approaches
- `/sdd-apply [change]` → implement tasks in batches; checks off items as it goes
- `/sdd-verify [change]` → validate implementation against specs; reports CRITICAL / WARNING / SUGGESTION
- `/sdd-archive [change]` → close a change; merges delta specs into main specs
- `/sdd-onboard` → guided end-to-end walkthrough of SDD using the real codebase

Meta-commands (type directly — you handle them, not a skill):
- `/sdd-new <change>` → explore + propose in sequence
- `/sdd-ff <name>` → fast-forward: proposal → specs → design → tasks
- `/sdd-continue [change]` → read `state.yaml` from the active change and run the next dependency-ready phase

`/sdd-new`, `/sdd-ff`, and `/sdd-continue` are meta-commands you handle inline. Do NOT invoke them as skills.

### SDD Init Guard (MANDATORY)

Before executing ANY SDD command, check if SDD has been initialized in this project:

1. Check if `openspec/config.yaml` exists in the current working directory
2. If it exists → init is done, proceed normally
3. If it does NOT exist → run `/sdd-init` FIRST, then proceed with the requested command

Do NOT skip this check. Do NOT ask the user — just run init silently if needed.

### Execution Mode

When the user invokes `/sdd-new` or `/sdd-ff` for the first time in a session, ASK which execution mode they prefer:

- **Automatic** (`auto`): Run all phases back-to-back without pausing. Show the final result only.
- **Interactive** (`interactive`): After each phase, show the result summary and ask to continue before proceeding.

Default to **Interactive** if not specified. Cache the mode for the session.

In Interactive mode, between phases:
1. Show a concise summary of what the phase produced
2. List what the next phase will do
3. Ask: "Continue?" — accept YES, NO, or specific feedback to adjust

### Dependency Graph

```
proposal -> specs --> tasks -> apply -> verify -> archive
             ^
             |
           design
```

### State Tracking

After each phase returns `status: success`, write `openspec/changes/{change-name}/state.yaml`:

```yaml
phase: <just-completed-phase>   # one of: proposal, specs, design, tasks, apply, verify, archive
last_updated: <YYYY-MM-DD>      # today's date, ISO-8601, no time component
```

**Rules**:
- Write ONLY on `status: success`. If the phase returns `status: blocked`, leave `state.yaml` unchanged.
- The orchestrator is the sole writer — phase skills never write this file.
- Overwrite the file on every successful write (two-field schema, no append).
- On `/sdd-continue`: read `state.yaml` to find the last completed phase, then derive the next phase from the DAG. If the file is missing, fall back to filesystem inspection (check which artifacts exist) or ask the user which phase to start from.

### Result Contract

Each phase returns: `status`, `executive_summary`, `artifacts`, `next_recommended`, `risks`, `skill_resolution`.

### Review Workload Guard (MANDATORY)

After `sdd-tasks` completes and before launching `sdd-apply`, inspect `Review Workload Forecast`.

If it says `Chained PRs recommended: Yes`, `400-line budget risk: High`, or `Decision needed before apply: Yes`:

- **`ask-on-risk`** (default): STOP and ask chained/stacked PRs vs `size:exception`.
- **`auto-chain`**: tell `sdd-apply` to implement only the next slice.
- **`single-pr`**: require `size:exception` before apply.
- **`exception-ok`**: continue with explicit `size:exception`.

Cache the delivery strategy at session start. Ask the user for it on the first `/sdd-new` or `/sdd-ff`.

### Model Assignments

Read once at session start, cache, and pass via `model` parameter in every Agent tool call.

| Phase | Model | Reason |
|-------|-------|--------|
| orchestrator | sonnet | Coordinates, makes decisions |
| sdd-explore | sonnet | Reads code, structural |
| sdd-propose | sonnet | Architectural decisions |
| sdd-spec | sonnet | Structured writing |
| sdd-design | sonnet | Architecture decisions |
| sdd-tasks | sonnet | Mechanical breakdown |
| sdd-apply | sonnet | Implementation |
| sdd-verify | sonnet | Validation against spec |
| sdd-archive | haiku | Copy and close |
| default | sonnet | Non-SDD general delegation |

### Sub-Agent Launch Pattern

Before launching any sub-agent that reads or writes code:
1. Read `.atl/skill-registry.md` in the project root (created by `/sdd-init`)
2. Match relevant skills by code context (file types) and task context (what it will do)
3. Copy matching compact rule blocks into the sub-agent prompt as `## Project Standards (auto-resolved)`
4. Inject BEFORE the sub-agent's task-specific instructions

Sub-agents do NOT read SKILL.md files — rules arrive pre-digested. Re-read the registry if a sub-agent reports `skill_resolution: fallback-registry` or `none`.

### Sub-Agent Context Protocol

Sub-agents get fresh context with no session memory. Pass what they need explicitly.

#### SDD Phases

Each phase reads and writes specific files:

| Phase | Reads | Writes |
|-------|-------|--------|
| `sdd-explore` | codebase | `openspec/changes/{name}/exploration.md` |
| `sdd-propose` | exploration.md, `openspec/specs/` | `openspec/changes/{name}/proposal.md` |
| `sdd-spec` | proposal.md, `openspec/specs/` | `openspec/changes/{name}/specs/{domain}/spec.md` |
| `sdd-design` | proposal.md, codebase | `openspec/changes/{name}/design.md` |
| `sdd-tasks` | proposal, spec, design | `openspec/changes/{name}/tasks.md` |
| `sdd-apply` | spec, design, tasks.md | updates `tasks.md` with `[x]` marks |
| `sdd-verify` | spec, design, tasks.md | `openspec/changes/{name}/verify-report.md` |
| `sdd-archive` | all above | moves to archive, updates `openspec/specs/` |

For phases with dependencies, pass FILE PATHS to the sub-agent — not content — to avoid inflating context.

> **Post-phase write (MANDATORY)**: after each phase returns `status: success`, write `state.yaml` BEFORE surfacing the result to the user. See the **State Tracking** section above for the schema and rules.

#### Strict TDD Forwarding (MANDATORY)

When launching `sdd-apply` or `sdd-verify`:
1. Read `openspec/config.yaml` → check `strict_tdd` field
2. If `strict_tdd: true`:
   - Add to the sub-agent prompt: `"STRICT TDD MODE IS ACTIVE. Test runner: {command from config.yaml}. You MUST follow strict-tdd.md."`
3. If `strict_tdd: false` or not found: do NOT add the TDD instruction.

Cache TDD status for the session.

### State Recovery

If the conversation is interrupted and the user resumes, check `openspec/changes/{change-name}/` to see which artifacts already exist and which phase to resume from.
