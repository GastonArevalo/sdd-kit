---
description: Initialize SDD context — detects project stack and creates openspec/ directory
---

Read the skill file at `~/.claude/skills/sdd-init/SKILL.md` FIRST, then follow its instructions exactly inline.

CONTEXT:
- Working directory: !`echo -n "$(pwd)"`
- Current project: !`echo -n "$(basename $(pwd))"`
- Artifact store mode: openspec

TASK:
Initialize Spec-Driven Development in this project. Detect the tech stack, existing conventions, testing capabilities, and architecture patterns. Create the `openspec/` directory structure and `openspec/config.yaml` with everything detected.

Also build the skill registry at `.atl/skill-registry.md` in the project root.

Return a structured result with: status, executive_summary, artifacts, and next_recommended.
