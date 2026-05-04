---
description: Archive a completed change — syncs delta specs to main specs and closes the cycle
---

Read the skill file at `~/.claude/skills/sdd-archive/SKILL.md` FIRST, then follow its instructions exactly inline.

CONTEXT:
- Working directory: !`echo -n "$(pwd)"`
- Current project: !`echo -n "$(basename $(pwd))"`
- Artifact store mode: openspec

TASK:
Archive the completed SDD change.

1. Read the verify report at `openspec/changes/{change-name}/verify-report.md` — do NOT archive if there are CRITICAL issues
2. For each delta spec in `openspec/changes/{change-name}/specs/`:
   - Merge ADDED requirements into `openspec/specs/{domain}/spec.md`
   - Replace MODIFIED requirements in the main spec
   - Remove REMOVED requirements from the main spec
   - If no main spec exists, copy the delta spec directly as the new main spec
3. Move `openspec/changes/{change-name}/` to `openspec/changes/archive/YYYY-MM-DD-{change-name}/`

Return a summary with specs synced, archive location, and confirmation that the SDD cycle is complete.
