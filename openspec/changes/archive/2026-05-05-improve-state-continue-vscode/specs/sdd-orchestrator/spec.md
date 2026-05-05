# Delta for sdd-orchestrator

## ADDED Requirements

### Requirement: Write state.yaml After Each Phase

After each SDD phase completes successfully, the orchestrator MUST write `openspec/changes/{change-name}/state.yaml` with the name of the last completed phase and the current date.

The file MUST use this exact schema:

```yaml
phase: {completed-phase-name}
last_updated: {YYYY-MM-DD}
```

The orchestrator SHALL NOT write `state.yaml` if the phase ended with `status: blocked`.

#### Scenario: Phase completes successfully

- GIVEN a phase sub-agent returns `status: success`
- WHEN the orchestrator processes the result
- THEN it MUST write `openspec/changes/{change-name}/state.yaml` with `phase: {completed-phase}` and today's date

#### Scenario: Phase is blocked

- GIVEN a phase sub-agent returns `status: blocked`
- WHEN the orchestrator processes the result
- THEN it MUST NOT update `state.yaml` and MUST surface the blocker to the user

#### Scenario: state.yaml already exists

- GIVEN `state.yaml` already exists from a previous phase
- WHEN a subsequent phase completes
- THEN the orchestrator MUST overwrite it with the new phase name, preserving the two-field schema

### Requirement: Read state.yaml on /sdd-continue

When the `/sdd-continue` meta-command is received, the orchestrator MUST read `state.yaml` from the active change folder before determining the next phase.

#### Scenario: /sdd-continue invoked with valid state.yaml

- GIVEN `state.yaml` exists and contains a valid `phase` value
- WHEN the orchestrator handles `/sdd-continue`
- THEN it MUST derive the next phase from the DAG and delegate it without asking the user what phase to run

#### Scenario: /sdd-continue invoked with no state.yaml

- GIVEN `state.yaml` does not exist in the change folder
- WHEN the orchestrator handles `/sdd-continue`
- THEN it MUST inform the user that no state was found and ask which phase to start from
