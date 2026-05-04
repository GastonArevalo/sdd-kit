---
description: Fast-forward SDD planning — proposal → specs → design → tasks in one shot
---

This is a meta-command handled by the orchestrator. Do NOT invoke it as a skill.

CONTEXT:
- Working directory: !`echo -n "$(pwd)"`
- Current project: !`echo -n "$(basename $(pwd))"`
- Artifact store mode: openspec

TASK:
Fast-forward all planning phases for the change provided by the user.

First, check if `openspec/config.yaml` exists. If not, run `/sdd-init` before proceeding.

Then run all planning phases in sequence, showing a summary after each and asking the user to confirm before continuing:

1. sdd-propose → read `~/.claude/skills/sdd-propose/SKILL.md` → write `openspec/changes/{name}/proposal.md`
2. sdd-spec → read `~/.claude/skills/sdd-spec/SKILL.md` → write `openspec/changes/{name}/specs/`
3. sdd-design → read `~/.claude/skills/sdd-design/SKILL.md` → write `openspec/changes/{name}/design.md`
4. sdd-tasks → read `~/.claude/skills/sdd-tasks/SKILL.md` → write `openspec/changes/{name}/tasks.md`

After all phases complete, show the Review Workload Forecast from tasks.md and ask if the user wants to proceed to `/sdd-apply`.
