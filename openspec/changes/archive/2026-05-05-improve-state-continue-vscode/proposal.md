# Proposal: Improve State Tracking, Continue Command, and VS Code Fallback

## Intent

Three gaps identified in exploration reduce reliability and usability of the kit:
1. DAG state is implicit (inferred from which files exist) — no centralized tracking survives interruption cleanly.
2. After `/sdd-ff` produces tasks, users must manually know to type `/sdd-apply` — no guided continuation.
3. VS Code Copilot without agent mode receives delegation instructions it cannot execute — undefined behavior.

## Scope

### In Scope
- Add `state.yaml` to the change folder schema; sdd-init creates it, phases update it, orchestrator reads it
- Add `/sdd-continue` slash command for Claude Code that reads `state.yaml` and runs the next phase
- Add fallback clause to `sdd.instructions.md` defining inline behavior when agent mode is unavailable
- Update `install.ps1` to copy `commands/sdd-continue.md`

### Out of Scope
- macOS/Linux installer
- Adding sdd-propose / sdd-spec / sdd-design / sdd-tasks as direct slash commands
- VS Code full agent mode setup guide

## Capabilities

### New Capabilities
- `sdd-continue`: slash command that reads `state.yaml` and runs the next dependency-ready phase

### Modified Capabilities
- `sdd-orchestrator`: reads and writes `state.yaml` to track DAG position
- `sdd-vscode-fallback`: VS Code orchestrator behavior when agent mode is unavailable

## Approach

**state.yaml**: minimal two-field file written by the orchestrator after each phase completes.
```yaml
phase: tasks        # last completed phase
last_updated: 2026-05-05
```
The orchestrator writes it; phase skills do not need to touch it. Recovery: orchestrator reads it on session start or when `/sdd-continue` is called.

**`/sdd-continue`**: command file that reads `state.yaml` from the active change and invokes the next phase per the dependency graph. Orchestrator resolves which change is active from `openspec/changes/` (most recently modified change dir that isn't archived).

**VS Code fallback**: add a `### Fallback (No Agent Mode)` section to `sdd.instructions.md` that instructs Copilot to run phases inline, narrate what it would delegate, and still write artifacts to `openspec/`.

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `_shared-openspec-convention.md` | Modified | Add `state.yaml` to directory schema and artifact table |
| `CLAUDE-sdd-orchestrator.md` | Modified | Add state.yaml write after each phase + `/sdd-continue` meta-command |
| `sdd.instructions.md` | Modified | Add fallback clause for non-agent mode |
| `commands/sdd-continue.md` | New | Slash command: read state, run next phase |
| `install.ps1` | Modified | Add `sdd-continue` to the commands copy list |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| state.yaml gets out of sync if user manually runs phases out of order | Low | Document that state.yaml is informational, not enforced; recovery is always possible by reading existing artifacts |
| sdd-continue picks wrong "active" change if multiple are open | Low | Pick the one explicitly named by the user, fall back to most-recently-modified |

## Rollback Plan

All changes are additive (new file, new section, new command). Rollback = delete `commands/sdd-continue.md`, revert the three modified files. No existing behavior is removed.

## Dependencies

None — no external tools required.

## Success Criteria

- [ ] `openspec/changes/{name}/state.yaml` is created after each phase completes
- [ ] `/sdd-continue` appears in Claude Code autocomplete and runs the correct next phase
- [ ] VS Code Copilot without agent mode runs phases inline and still writes `openspec/` artifacts
- [ ] `install.ps1` copies `sdd-continue.md` without additional user steps
