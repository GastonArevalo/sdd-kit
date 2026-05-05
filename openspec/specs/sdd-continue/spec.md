# sdd-continue Specification

## Purpose

`/sdd-continue` is a slash command for Claude Code that reads `state.yaml` from the active change folder and invokes the next dependency-ready SDD phase without requiring the user to know the DAG manually.

## Requirements

### Requirement: Resolve Active Change

The command MUST identify which change to continue. It SHALL use the change name explicitly provided by the user. When no name is provided, it MUST fall back to the most-recently-modified non-archived change directory under `openspec/changes/`. If two candidates have an mtime within 60 seconds of each other, it MUST list them and ask the user which one to continue.

#### Scenario: User provides change name

- GIVEN a user invokes `/sdd-continue improve-state-continue-vscode`
- WHEN the command resolves the active change
- THEN it MUST read `openspec/changes/improve-state-continue-vscode/state.yaml`

#### Scenario: No change name given, one active change exists

- GIVEN no name is provided and exactly one non-archived change directory exists
- WHEN the command resolves the active change
- THEN it MUST select that directory automatically without asking the user

#### Scenario: No change name given, multiple active changes exist

- GIVEN no name is provided and multiple non-archived change directories exist
- WHEN the command resolves the active change
- THEN it MUST sort by mtime descending, pick the most recent, and ask if two candidates are within 60 seconds of each other

#### Scenario: state.yaml missing — filesystem fallback

- GIVEN the resolved change directory has no `state.yaml`
- WHEN the command attempts to read state
- THEN it MUST inspect which artifact files exist to infer progress, and proceed from the last completed phase found

### Requirement: Determine Next Phase

The command MUST read `state.yaml` and derive the next dependency-ready phase from the SDD DAG.

DAG order: `proposal → spec → design → tasks → apply → verify → archive`

#### Scenario: state.yaml reports last completed phase as tasks

- GIVEN `state.yaml` contains `phase: tasks`
- WHEN the command determines the next phase
- THEN it MUST invoke `sdd-apply` as the next phase

#### Scenario: state.yaml reports last completed phase as verify

- GIVEN `state.yaml` contains `phase: verify`
- WHEN the command determines the next phase
- THEN it MUST invoke `sdd-archive`

#### Scenario: state.yaml reports last completed phase as archive

- GIVEN `state.yaml` contains `phase: archive`
- WHEN the command determines the next phase
- THEN it MUST inform the user that the change is complete and no further phases remain

### Requirement: Invoke Next Phase

The command MUST delegate the resolved phase to the appropriate sub-agent or, in non-agent mode, execute it inline.

#### Scenario: Next phase is available and agent mode is active

- GIVEN the next phase is determined and agent mode is available
- WHEN the command invokes the phase
- THEN it MUST delegate to the correct phase sub-agent passing the change name and artifact store mode

#### Scenario: Agent mode is unavailable

- GIVEN agent mode is not available (VS Code Copilot fallback context)
- WHEN the command invokes the phase
- THEN it MUST execute the phase inline per the VS Code fallback rules defined in `sdd.instructions.md`
