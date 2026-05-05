# Design: State Tracking, Continue Command, and VS Code Fallback

## Technical Approach

Three small, independent additions to the kit that share one principle: **artifacts on disk are the source of truth — `state.yaml` is a hint, never a gate**. The orchestrator owns state writes (phase skills stay pure), `/sdd-continue` is a thin reader that maps state → next phase, and the VS Code fallback gives Copilot deterministic behavior when agent mode is off by switching from "delegate" to "execute inline" while keeping the same artifact contract.

## Architecture Decisions

### Decision: Orchestrator owns `state.yaml`, phase skills stay pure

| Option | Tradeoff | Decision |
|--------|----------|----------|
| Each phase skill writes its own state | Couples every skill to state schema; six write paths to keep in sync | Rejected |
| Orchestrator writes after each phase returns | One write path; phase skills remain self-contained and reusable | **Chosen** |
| Separate state-writer skill | Extra delegation hop for a one-line YAML write | Rejected |

**Rationale**: Phase skills already return a Result Contract envelope (`status`, `next_recommended`). The orchestrator already inspects this. Writing two YAML lines after a successful return adds no architectural cost. Keeping phase skills decoupled from state means they remain usable in `engram` mode with zero changes.

### Decision: Two-field schema, no enforcement

```yaml
phase: tasks          # last completed phase name (proposal|specs|design|tasks|apply|verify)
last_updated: 2026-05-05
```

| Option | Tradeoff | Decision |
|--------|----------|----------|
| Rich state (per-phase status, timestamps, attempts) | More info but synchronization risk; out-of-date file misleads more | Rejected |
| Two fields: last completed phase + date | Trivially recoverable from artifacts if lost; never blocks the user | **Chosen** |
| No state file, infer from filesystem each time | Works but slower for `/sdd-continue` and loses "what was last completed" hint when partial files exist | Rejected |

**Rationale**: The filesystem already encodes the truth (artifacts exist or they don't). `state.yaml` is a fast-path hint, so it stays minimal. If it ever disagrees with the filesystem, the filesystem wins.

### Decision: `/sdd-continue` resolves the active change deterministically

| Option | Tradeoff | Decision |
|--------|----------|----------|
| Require user to pass change name | Always correct, never ambiguous, but adds friction | Fallback only |
| Pick most-recently-modified non-archived dir under `openspec/changes/` | Matches user intuition ("the one I was just working on"); deterministic from `mtime` | **Chosen (default)** |
| Track "current change" in a global pointer file | Extra state to maintain; conflicts on multi-change days | Rejected |

**Resolution algorithm** (in `commands/sdd-continue.md`):
1. If user passed an argument, use that change name.
2. Else list `openspec/changes/*/` (excluding `archive/`), sort by directory mtime descending, pick the first.
3. If zero candidates → tell the user no active change found, suggest `/sdd-new`.
4. If more than one candidate within 60 seconds of each other → ask the user which one.

### Decision: VS Code fallback is a behavior switch, not a separate workflow

| Option | Tradeoff | Decision |
|--------|----------|----------|
| Maintain two separate orchestrator files (agent vs inline) | Drift risk; double maintenance | Rejected |
| Single file with a "Fallback (No Agent Mode)" section that overrides delegation rules | One source of truth; explicit override semantics | **Chosen** |
| Detect agent mode at runtime | Copilot exposes no reliable signal | Not feasible |

**Rationale**: The fallback section lives at the END of `sdd.instructions.md` so it appears after the standard rules and overrides them by precedence. It says: when you cannot delegate, EXECUTE phase skills inline yourself, narrate which sub-agent you would have launched, and still write all artifacts to `openspec/`.

## Data Flow

### State write lifecycle

```
    User runs phase command
            │
            ▼
   Orchestrator delegates (or runs inline in VS Code fallback)
            │
            ▼
    Phase returns Result Contract envelope
            │  status == success?
            ▼
   Orchestrator writes openspec/changes/{name}/state.yaml
   { phase: <just-completed>, last_updated: <today> }
            │
            ▼
    Orchestrator reports to user; suggests next_recommended
```

### `/sdd-continue` flow

```
   User: /sdd-continue [name]
            │
            ▼
   Resolve active change (arg | most-recent mtime)
            │
            ▼
   Read state.yaml → last completed phase
            │
            ▼
   Look up next phase via dependency graph
   (proposal → specs → tasks → apply → verify → archive,
    design parallel to specs/tasks)
            │
            ▼
   Invoke that phase skill (delegate or inline per mode)
            │
            ▼
   On success, orchestrator writes new state.yaml
```

### Phase → next-phase map (used by `/sdd-continue`)

| `state.yaml: phase` value | Next phase to run |
|---------------------------|-------------------|
| (file missing or empty)   | proposal (or explore if user said `/sdd-new`) |
| proposal                  | specs (and design — they can run parallel) |
| specs                     | design if missing, else tasks |
| design                    | specs if missing, else tasks |
| tasks                     | apply |
| apply                     | verify |
| verify                    | archive |
| archive                   | done — suggest `/sdd-new` |

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `commands/sdd-continue.md` | Create | New slash command — see content below |
| `_shared-openspec-convention.md` | Modify | Already lists `state.yaml` in directory schema (line 15) and artifact table (line 29). Add a new **State File Schema** section explaining the two fields and write semantics |
| `CLAUDE-sdd-orchestrator.md` | Modify | Add **State Tracking** section after Dependency Graph; add `/sdd-continue` to meta-commands list; add post-phase write step in Sub-Agent Context Protocol |
| `sdd.instructions.md` | Modify | Add `/sdd-continue` to meta-commands list; add **Fallback (No Agent Mode)** section at the end |
| `install.ps1` | Modify | No change needed — line 82 already does `Copy-Item "$ScriptDir\commands\*.md"` (wildcard picks up new file automatically). Verify only |

## Interfaces / Contracts

### `state.yaml` schema

```yaml
phase: <string>         # one of: proposal, specs, design, tasks, apply, verify, archive
last_updated: <date>    # ISO-8601 date (YYYY-MM-DD), no time component
```

**Write rules**:
- Orchestrator writes ONLY after a phase returns `status: success`.
- Field `phase` = the phase that just finished (NOT the next one).
- File is created on first phase write — `sdd-init` does NOT pre-create it (a change folder with no `state.yaml` simply means nothing has completed yet).
- Out-of-band edits are tolerated; orchestrator overwrites on next success.

### `commands/sdd-continue.md` content (target)

```markdown
---
description: Continue the active SDD change — runs the next dependency-ready phase
---

This is a meta-command handled by the orchestrator. Do NOT invoke it as a skill.

CONTEXT:
- Working directory: !`echo -n "$(pwd)"`
- Current project: !`echo -n "$(basename $(pwd))"`
- Artifact store mode: openspec

TASK:
Continue the active SDD change by running the next dependency-ready phase.

1. Resolve the active change:
   - If the user passed a name, use that.
   - Else pick the most recently modified directory under `openspec/changes/` (excluding `archive/`).
   - If none exists, tell the user and suggest `/sdd-new`.

2. Read `openspec/changes/{name}/state.yaml` to find the last completed phase.
   If the file is missing, fall back to inspecting which artifacts already exist
   (proposal.md, specs/, design.md, tasks.md, verify-report.md).

3. Map the last completed phase to the next phase via the dependency graph
   (proposal → specs/design → tasks → apply → verify → archive).

4. Run that phase by reading its skill file at `~/.claude/skills/{phase}/SKILL.md`
   and following its instructions inline (or delegating if agent mode is on).

5. After the phase returns success, write `openspec/changes/{name}/state.yaml`
   with `phase: <just-completed>` and today's date. Tell the user what ran and
   what the next recommended phase is.
```

### Fallback clause for `sdd.instructions.md` (target placement: end of file, new top-level section)

```markdown
## Fallback (No Agent Mode)

If you do not have access to delegation tools (no Agent / Task tool available in this VS Code Copilot context), switch to **inline execution mode**:

1. For every SDD phase, read the skill file directly at `~/.copilot/skills/{phase}/SKILL.md` and execute its instructions yourself in this conversation.
2. Narrate which sub-agent you would have delegated to (e.g., "Running sdd-design inline — would normally delegate to the sdd-design sub-agent").
3. Still write every artifact to its `openspec/` path per the file table above. The artifact contract does NOT change between agent and inline mode.
4. Still write `openspec/changes/{name}/state.yaml` after each phase succeeds.
5. Skip the Sub-Agent Launch Pattern (no compact-rules injection needed when you are the executor).
6. Keep the conversation concise — inline execution makes the thread longer, so summarize aggressively after each phase.

This section overrides the Delegation Rules table when delegation is unavailable.
```

## Testing Strategy

| Layer | What to Test | Approach |
|-------|--------------|----------|
| Manual | `install.ps1` copies `sdd-continue.md` to `~/.claude/commands/` | Run installer; check file exists |
| Manual | `/sdd-continue` resolves active change correctly | Create two change dirs with different mtimes; run command; verify it picks the newer |
| Manual | `state.yaml` written after each phase | Run `/sdd-ff foo`; after each phase confirm `state.yaml.phase` updates |
| Manual | VS Code fallback executes inline | Open Copilot chat without agent mode; run `/sdd-explore`; confirm artifact created and narration present |

No automated tests — this is a documentation/configuration project (`openspec/config.yaml` declares `testing.layers.unit/integration/e2e: false`).

## Edge Cases

- **Multiple open changes**: handled by mtime tie-breaker in `/sdd-continue`. Within 60s of each other → ask the user.
- **Interrupted session mid-phase**: phase did not return success → no `state.yaml` write happened → on resume, last completed phase still points to the previous one. Filesystem inspection (artifact present?) catches partial writes.
- **User edits `state.yaml` manually**: tolerated. Next successful phase overwrites.
- **`state.yaml` missing**: `/sdd-continue` falls back to filesystem inspection (which artifacts exist).
- **`sdd-init` does NOT pre-create `state.yaml`**: avoids a "phase: none" sentinel that complicates the next-phase map. Absence == nothing has run yet.

## Migration / Rollout

No migration required. All changes are additive:
- Existing changes without `state.yaml` keep working — `/sdd-continue` falls back to filesystem inspection.
- Existing Copilot users in agent mode see no behavior change — fallback section only triggers when delegation is unavailable.
- Rollback = delete `commands/sdd-continue.md` and revert the three modified docs.

## Open Questions

- [ ] Should `/sdd-continue` accept an explicit `--from-phase` override for users who want to redo a phase? (Proposal: no, keep scope minimal — user can re-run the phase command directly.)
