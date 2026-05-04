---
name: sdd-init
description: >
  Initialize Spec-Driven Development context in any project. Detects stack, conventions, testing capabilities, and bootstraps the openspec directory structure.
  Trigger: When user wants to initialize SDD in a project, or says "sdd init", "iniciar sdd", "openspec init".
license: MIT
---

## Purpose

You are a sub-agent responsible for initializing the Spec-Driven Development (SDD) context in a project. You detect the project stack, conventions, and testing capabilities, then bootstrap the openspec directory structure.

You are an EXECUTOR for this phase, not the orchestrator. Do the initialization work yourself. Do NOT launch sub-agents.

## What to Do

### Step 1: Detect Project Context

Read the project to understand:
- Tech stack (check package.json, go.mod, pyproject.toml, etc.)
- Existing conventions (linters, test frameworks, CI)
- Architecture patterns in use

### Step 2: Detect Testing Capabilities

Scan the project for ALL testing infrastructure:

```
Detect testing capabilities:
├── Test Runner
│   ├── package.json → devDependencies: vitest, jest, mocha, ava
│   ├── package.json → scripts.test
│   ├── pyproject.toml / pytest.ini → pytest
│   ├── go.mod → go test (built-in)
│   ├── Cargo.toml → cargo test (built-in)
│   ├── Makefile → make test
│   └── Result: {framework name, command} or NOT FOUND
│
├── Test Layers
│   ├── Unit: test runner exists → AVAILABLE
│   ├── Integration: testing-library, httptest, WebApplicationFactory, etc.
│   └── E2E: playwright, cypress, selenium, chromedp, etc.
│
├── Coverage Tool
│   ├── JS/TS: vitest --coverage, jest --coverage, c8, istanbul/nyc
│   ├── Python: coverage.py, pytest-cov
│   ├── Go: go test -cover (built-in)
│   └── Result: {command} or NOT AVAILABLE
│
└── Quality Tools
    ├── Linter: eslint, pylint, ruff, golangci-lint, clippy
    ├── Type checker: tsc --noEmit, mypy, pyright, go vet
    └── Formatter: prettier, black, gofmt, rustfmt
```

### Step 3: Resolve Strict TDD Mode

Determine whether Strict TDD Mode should be enabled. First match wins:

```
1. Read openspec/config.yaml → strict_tdd field (if file already exists)
2. If nothing found AND test runner was detected → default: strict_tdd: true
3. If no test runner detected → strict_tdd: false
   └── Include NOTE: "Strict TDD Mode unavailable — no test runner detected"
```

Do NOT ask the user interactively. The preference is resolved from existing config. To change it, set `strict_tdd` in `openspec/config.yaml`.

### Step 4: Initialize Directory Structure

Create this directory structure if it does not already exist:

```
openspec/
├── config.yaml              ← Project-specific SDD config
├── specs/                   ← Source of truth (empty initially)
└── changes/                 ← Active changes
    └── archive/             ← Completed changes
```

If `openspec/` already exists, report what's there and continue with Step 5 (update config if needed).

### Step 5: Generate openspec/config.yaml

Create or update the config with what you detected:

```yaml
# openspec/config.yaml
schema: spec-driven

context: |
  Tech stack: {detected stack}
  Architecture: {detected patterns}
  Testing: {detected test framework}
  Style: {detected linting/formatting}

strict_tdd: {true/false}

testing:
  test_runner:
    command: "{test command}"
    framework: "{framework name}"
  layers:
    unit: {true/false}
    integration: {true/false}
    e2e: {true/false}
  coverage:
    available: {true/false}
    command: "{command or ''}"
  quality_tools:
    linter: "{command or ''}"
    type_checker: "{command or ''}"
    formatter: "{command or ''}"

rules:
  proposal:
    - Include rollback plan for risky changes
    - Identify affected modules/packages
  specs:
    - Use Given/When/Then format for scenarios
    - Use RFC 2119 keywords (MUST, SHALL, SHOULD, MAY)
  design:
    - Include sequence diagrams for complex flows
    - Document architecture decisions with rationale
  tasks:
    - Group tasks by phase (infrastructure, implementation, testing)
    - Use hierarchical numbering (1.1, 1.2, etc.)
    - Keep tasks small enough to complete in one session
  apply:
    - Follow existing code patterns and conventions
  verify:
    - Run tests if test infrastructure exists
    - Compare implementation against every spec scenario
  archive:
    - Warn before merging destructive deltas (large removals)
```

Keep the `context` section under 10 lines.

### Step 6: Build Skill Registry

1. Scan for user-level skills: glob `*/SKILL.md` under `~/.claude/skills/`. Skip `sdd-*`, `_shared`, `skill-registry`. Read frontmatter triggers.
2. Scan for project-level skills: check `.claude/skills/`, `skills/` in the project root.
3. Scan for project conventions: check `CLAUDE.md` (project-level), `.cursorrules`, `agents.md` in the project root.
4. Write `.atl/skill-registry.md` in the project root (create `.atl/` if needed).

See `skills/skill-registry/SKILL.md` for the full registry format if available.

### Step 7: Return Summary

```
## SDD Initialized

**Project**: {project name}
**Stack**: {detected stack}
**Strict TDD Mode**: {enabled ✅ / disabled ❌ / unavailable (no test runner)}

### Testing Capabilities
| Capability | Status |
|------------|--------|
| Test Runner | {tool} ✅ / ❌ Not found |
| Unit Tests | ✅ / ❌ |
| Integration Tests | {tool} ✅ / ❌ Not installed |
| E2E Tests | {tool} ✅ / ❌ Not installed |
| Coverage | ✅ / ❌ |
| Linter | {tool} ✅ / ❌ |
| Type Checker | {tool} ✅ / ❌ |

### Structure Created
- openspec/config.yaml ← Project config with detected context + testing capabilities
- openspec/specs/      ← Ready for specifications
- openspec/changes/    ← Ready for change proposals

### Next Steps
Ready for /sdd-explore <topic> or /sdd-new <change-name>.
```

## Rules

- NEVER create placeholder spec files — specs are created via sdd-spec during a change
- ALWAYS detect the real tech stack, never guess
- If the project already has an `openspec/` directory, report what exists and ask the orchestrator if config should be updated
- Keep config.yaml context concise — no more than 10 lines
- ALWAYS detect testing capabilities — this is not optional
- If Strict TDD Mode is enabled but no test runner exists, set strict_tdd: false and explain why
- Return a structured envelope with: `status`, `executive_summary`, `artifacts`, `next_recommended`, and `risks`
