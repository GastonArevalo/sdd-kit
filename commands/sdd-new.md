---
description: Start a new SDD change — explores the idea and creates a proposal
---

This is a meta-command handled by the orchestrator. Do NOT invoke it as a skill.

CONTEXT:
- Working directory: !`echo -n "$(pwd)"`
- Current project: !`echo -n "$(basename $(pwd))"`
- Artifact store mode: openspec

TASK:
Start a new SDD change for the topic provided by the user.

First, check if `openspec/config.yaml` exists in the current directory. If it does not, run `/sdd-init` before proceeding.

Then:
1. Run sdd-explore to investigate the idea (read `~/.claude/skills/sdd-explore/SKILL.md`)
2. Show the exploration summary and ask the user if they want to continue
3. Run sdd-propose to create the proposal (read `~/.claude/skills/sdd-propose/SKILL.md`)
4. Show the proposal and ask the user if they want to continue to specs and design

All artifacts go to `openspec/changes/{change-name}/`.
