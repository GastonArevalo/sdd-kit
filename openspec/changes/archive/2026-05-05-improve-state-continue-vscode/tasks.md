# Tasks: Improve State Tracking, Continue Command, and VS Code Fallback

## Phase 1: Schema Documentation (Foundation)

- [x] 1.1 In `_shared-openspec-convention.md`, add a **State File Schema** section after the Artifact File Paths table. Document the two-field YAML schema (`phase`, `last_updated`), write rules (orchestrator-only, on success only, no pre-create by sdd-init), and the "filesystem wins over state.yaml" recovery principle.

## Phase 2: Orchestrator State Tracking (Core)

- [x] 2.1 In `CLAUDE-sdd-orchestrator.md`, add `/sdd-continue` to the Meta-commands list (alongside `/sdd-new` and `/sdd-ff`) with a one-line description.
- [x] 2.2 In `CLAUDE-sdd-orchestrator.md`, add a **State Tracking** section after the Dependency Graph block. Document: (a) orchestrator writes `openspec/changes/{name}/state.yaml` after each successful phase return, (b) no write on `status: blocked`, (c) two-field schema, (d) read on `/sdd-continue`.
- [x] 2.3 In `CLAUDE-sdd-orchestrator.md`, add the post-phase write step to the Sub-Agent Context Protocol table footnote or as a note after the phases table: after each phase returns `status: success`, write `state.yaml` before surfacing the result to the user.

## Phase 3: `/sdd-continue` Command File (New File)

- [x] 3.1 Create `commands/sdd-continue.md` with YAML frontmatter (`description:`), the resolution algorithm (arg → most-recent mtime → zero-candidates error → tie-breaker ask), the phase→next-phase map table (including the `state.yaml` missing fallback to filesystem inspection), and delegation/inline fork. Content target is defined in `design.md` under "Interfaces / Contracts".

## Phase 4: VS Code Fallback (sdd.instructions.md)

- [x] 4.1 In `sdd.instructions.md`, add `/sdd-continue` to the Meta-commands list (alongside `/sdd-new` and `/sdd-ff`).
- [x] 4.2 In `sdd.instructions.md`, append a **Fallback (No Agent Mode)** top-level section at the end of the file. Include: detect context, run phases inline, narrate delegation, write openspec/ artifacts with identical format, write `state.yaml` after each phase, skip Sub-Agent Launch Pattern, summarize aggressively. Section overrides Delegation Rules when delegation is unavailable.

## Phase 5: Verification

- [x] 5.1 Confirm `install.ps1` line 82 (`Copy-Item "$ScriptDir\commands\*.md"`) picks up `sdd-continue.md` automatically — no code change needed; record finding in this task as `[x] verified — wildcard covers new file`.
- [x] 5.2 Trace the `/sdd-continue` command file end-to-end: resolution algorithm → state.yaml read → DAG map → phase invocation → state.yaml write. Confirm no step references a file or path not defined in `_shared-openspec-convention.md`.
- [x] 5.3 Verify `CLAUDE-sdd-orchestrator.md` and `sdd.instructions.md` are internally consistent: both list `/sdd-continue`, both reference the same two-field schema, fallback section does not contradict standard delegation rules.

---

## Review Workload Forecast

```
Decision needed before apply: No
Chained PRs recommended: No
Chain strategy: size-exception
400-line budget risk: Low
```
