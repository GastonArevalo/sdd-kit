---
description: Implement SDD tasks — writes code following specs and design
---

Read the skill file at `~/.claude/skills/sdd-apply/SKILL.md` FIRST, then follow its instructions exactly inline.

CONTEXT:
- Working directory: !`echo -n "$(pwd)"`
- Current project: !`echo -n "$(basename $(pwd))"`
- Artifact store mode: openspec

TASK:
Implement the remaining incomplete tasks for the active SDD change.

Before writing any code:
1. Read `openspec/changes/{change-name}/specs/` to understand WHAT the code must do
2. Read `openspec/changes/{change-name}/design.md` to understand HOW to structure it
3. Read `openspec/changes/{change-name}/tasks.md` to see which tasks are pending ([ ])
4. Read `openspec/config.yaml` to check strict_tdd setting and testing capabilities

Mark tasks complete with [x] in tasks.md as you go. If Strict TDD mode is enabled (strict_tdd: true in config.yaml), read `~/.claude/skills/sdd-apply/strict-tdd.md` and follow the RED-GREEN-REFACTOR cycle.

Return a structured progress report with completed tasks, files changed, deviations, and remaining tasks.
