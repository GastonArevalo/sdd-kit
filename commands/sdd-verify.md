---
description: Validate implementation against specs, design, and tasks
---

Read the skill file at `~/.claude/skills/sdd-verify/SKILL.md` FIRST, then follow its instructions exactly inline.

CONTEXT:
- Working directory: !`echo -n "$(pwd)"`
- Current project: !`echo -n "$(basename $(pwd))"`
- Artifact store mode: openspec

TASK:
Verify the implementation for the active SDD change.

1. Read `openspec/changes/{change-name}/tasks.md` — check all tasks are complete
2. Read `openspec/changes/{change-name}/specs/` — build the compliance matrix
3. Read `openspec/changes/{change-name}/design.md` — check design decisions were followed
4. Read `openspec/config.yaml` — get test runner and strict_tdd setting
5. Execute the test suite and capture results
6. Cross-reference every spec scenario against test results

If Strict TDD mode is enabled (strict_tdd: true in config.yaml), read `~/.claude/skills/sdd-verify/strict-tdd-verify.md` and apply all additional verification steps.

Save the verification report to `openspec/changes/{change-name}/verify-report.md`.
Return the full report with verdict: PASS, PASS WITH WARNINGS, or FAIL.
