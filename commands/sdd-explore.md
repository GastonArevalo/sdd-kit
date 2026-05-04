---
description: Explore and investigate an idea before committing to a change
---

Read the skill file at `~/.claude/skills/sdd-explore/SKILL.md` FIRST, then follow its instructions exactly inline.

CONTEXT:
- Working directory: !`echo -n "$(pwd)"`
- Current project: !`echo -n "$(basename $(pwd))"`
- Artifact store mode: openspec

TASK:
Investigate the topic or feature provided by the user. Read the relevant codebase, compare approaches, and return a structured analysis.

If a change name is provided, write the exploration to `openspec/changes/{change-name}/exploration.md`.

Return a structured exploration report with: current state, affected areas, approaches, recommendation, risks, and whether it is ready for a proposal.
