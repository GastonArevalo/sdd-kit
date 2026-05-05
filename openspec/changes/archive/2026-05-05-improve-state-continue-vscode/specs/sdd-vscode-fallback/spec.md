# sdd-vscode-fallback Specification

## Purpose

Defines the expected behavior of VS Code Copilot when operating without agent mode. Without the ability to delegate to sub-agents, Copilot MUST still provide useful SDD workflow support by running phases inline and writing artifacts to `openspec/`.

## Requirements

### Requirement: Detect Non-Agent Context

The VS Code orchestrator instructions MUST include a fallback clause that activates when agent mode is unavailable (e.g., Copilot Chat without agent extension, or restricted environment).

#### Scenario: Agent mode is unavailable

- GIVEN the user invokes an SDD command in VS Code Copilot without agent mode
- WHEN Copilot processes the command
- THEN it MUST NOT attempt to delegate to sub-agents
- AND it MUST narrate what it would normally delegate and proceed inline

#### Scenario: Agent mode is available

- GIVEN the user invokes an SDD command and agent mode is active
- WHEN Copilot processes the command
- THEN it MUST follow the standard delegation path and MUST NOT apply fallback behavior

### Requirement: Run Phases Inline

In fallback mode, Copilot MUST execute each SDD phase directly in its own context without sub-agent delegation.

#### Scenario: User runs /sdd-ff in fallback mode

- GIVEN agent mode is unavailable
- WHEN the user invokes `/sdd-ff {change-name}`
- THEN Copilot MUST run proposal, spec, design, and tasks phases sequentially in its own context
- AND MUST write each artifact to the corresponding `openspec/` path before proceeding to the next phase

#### Scenario: User runs a single phase command in fallback mode

- GIVEN agent mode is unavailable
- WHEN the user invokes a single-phase command (e.g., `/sdd-apply`)
- THEN Copilot MUST execute that phase inline and write the resulting artifact to `openspec/`

### Requirement: Write openspec/ Artifacts in Fallback Mode

In fallback mode, Copilot MUST still write all SDD artifacts to the filesystem under `openspec/changes/{change-name}/`. Artifact format and path conventions MUST be identical to those produced by agent-mode delegations.

#### Scenario: Proposal generated in fallback mode

- GIVEN agent mode is unavailable and the user requests a new change
- WHEN Copilot completes the proposal phase inline
- THEN it MUST write `openspec/changes/{change-name}/proposal.md` with valid content
- AND the file MUST conform to the proposal format defined in `_shared-openspec-convention.md`

#### Scenario: state.yaml written in fallback mode

- GIVEN agent mode is unavailable and a phase completes inline
- WHEN Copilot finishes the phase
- THEN it MUST write `openspec/changes/{change-name}/state.yaml` with the completed phase name and current date

### Requirement: Narrate Delegation Steps

In fallback mode, Copilot SHOULD narrate what it would have delegated, so the user understands the workflow even without seeing actual sub-agent calls.

#### Scenario: Phase executed inline

- GIVEN fallback mode is active
- WHEN Copilot runs a phase
- THEN it SHOULD output a brief note such as "Running {phase} inline (agent mode unavailable)" before producing the artifact
