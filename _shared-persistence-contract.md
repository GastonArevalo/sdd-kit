# Persistence Contract (SDD — OpenSpec Mode)

## Overview

All SDD artifacts are persisted as files inside the `openspec/` directory of the project. There is no external database or memory service required.

## Directory Structure

```
openspec/
├── config.yaml              ← Project config (created by sdd-init)
├── specs/                   ← Source of truth: main specs
│   └── {domain}/
│       └── spec.md
└── changes/                 ← Active changes
    ├── archive/             ← Completed changes
    └── {change-name}/       ← Active change folder
        ├── exploration.md   ← (optional) from sdd-explore
        ├── proposal.md      ← from sdd-propose
        ├── specs/           ← from sdd-spec
        │   └── {domain}/
        │       └── spec.md  ← Delta spec
        ├── design.md        ← from sdd-design
        ├── tasks.md         ← from sdd-tasks (updated by sdd-apply)
        └── verify-report.md ← from sdd-verify
```

## Read / Write Rules

| Phase | Reads | Writes |
|-------|-------|--------|
| sdd-init | project files | `openspec/config.yaml` |
| sdd-explore | `openspec/config.yaml`, `openspec/specs/` | `openspec/changes/{name}/exploration.md` |
| sdd-propose | `openspec/specs/`, exploration.md | `openspec/changes/{name}/proposal.md` |
| sdd-spec | proposal.md, `openspec/specs/` | `openspec/changes/{name}/specs/{domain}/spec.md` |
| sdd-design | proposal.md, codebase | `openspec/changes/{name}/design.md` |
| sdd-tasks | proposal.md, spec, design | `openspec/changes/{name}/tasks.md` |
| sdd-apply | spec, design, tasks.md | updates `tasks.md` (`[x]` marks) |
| sdd-verify | spec, design, tasks.md | `openspec/changes/{name}/verify-report.md` |
| sdd-archive | all above | moves folder to `archive/`, updates `openspec/specs/` |

## Common Rules

- ALWAYS write artifacts to the exact paths shown above
- If a file already exists, READ it first and UPDATE it — never overwrite blindly
- If the change directory already exists with artifacts, the change is being CONTINUED
- NEVER write SDD artifacts outside of `openspec/`
- The only exception is `.atl/skill-registry.md` (infrastructure, not an artifact)

## Sub-Agent Context Rules

Sub-agents read and write directly from/to the filesystem. The orchestrator passes file paths — NOT file content — to avoid inflating context.

When launching a phase with dependencies, include in the sub-agent prompt:
```
Read before starting:
  - openspec/changes/{change-name}/proposal.md
  - openspec/changes/{change-name}/specs/
  - openspec/changes/{change-name}/design.md
  - openspec/changes/{change-name}/tasks.md
```

## Skill Registry

The orchestrator pre-resolves compact rules from `.atl/skill-registry.md` and injects them as `## Project Standards (auto-resolved)` in sub-agent launch prompts. Sub-agents do NOT read SKILL.md files directly — rules arrive pre-digested.

To generate or update the registry: run `/sdd-init` (which builds it automatically) or run the `skill-registry` skill.
