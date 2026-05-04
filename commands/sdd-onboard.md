---
description: Guided end-to-end SDD walkthrough using your real codebase
---

Read the skill file at `~/.claude/skills/sdd-onboard/SKILL.md` FIRST, then follow its instructions exactly inline.

CONTEXT:
- Working directory: !`echo -n "$(pwd)"`
- Current project: !`echo -n "$(basename $(pwd))"`
- Artifact store mode: openspec

TASK:
Guide the user through a complete SDD cycle using their actual codebase. Find a small, real improvement opportunity, run through all phases (explore → propose → spec → design → tasks → apply → verify → archive), and narrate each step to teach the workflow.

This is a REAL change with production-quality artifacts — not a demo.

First check if `openspec/config.yaml` exists. If not, run `/sdd-init` first.
