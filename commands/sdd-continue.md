---
description: Continue the active SDD change — runs the next dependency-ready phase
---

CONTEXT:
- Working directory: !`echo -n "$(pwd)"`
- Current project: !`echo -n "$(basename $(pwd))"`
- Artifact store mode: openspec

TASK:
Continue the active SDD change by running the next dependency-ready phase.

1. Resolve the active change:
   - If the user passed a name, use that.
   - Else list all directories under `openspec/changes/` (excluding `archive/`), sort by directory mtime descending, pick the first.
   - If none exists, tell the user no active change was found and suggest `/sdd-new`.
   - If two or more candidates have an mtime within 60 seconds of each other, list them and ask the user which one to continue.

2. Read `openspec/changes/{name}/state.yaml` to find the last completed phase.
   If the file is missing, fall back to inspecting which artifacts already exist
   (`proposal.md`, `specs/`, `design.md`, `tasks.md`, `verify-report.md`) to determine progress.
   If no artifacts exist either, inform the user that no phases have completed yet and suggest running `/sdd-ff {name}`.

3. Map the last completed phase to the next phase using the dependency graph:

   | `state.yaml: phase` value  | Next phase to run                              |
   |----------------------------|------------------------------------------------|
   | (file missing or empty)    | proposal (or explore if user said `/sdd-new`)  |
   | proposal                   | specs (and design — they can run in parallel)  |
   | specs                      | design if missing, else tasks                  |
   | design                     | specs if missing, else tasks                   |
   | tasks                      | apply                                          |
   | apply                      | verify                                         |
   | verify                     | archive                                        |
   | archive                    | done — inform the user and suggest `/sdd-new`  |

4. Run that phase by reading its skill file at `~/.claude/skills/{phase}/SKILL.md`
   and following its instructions inline (or delegating if agent mode is on).
   Pass the change name and artifact store mode (`openspec`) to the phase.

5. After the phase returns `status: success`, write `openspec/changes/{name}/state.yaml`:
   ```yaml
   phase: <just-completed-phase>
   last_updated: <YYYY-MM-DD>
   ```
   Tell the user what ran and what the next recommended phase is.
   If the phase returns `status: blocked`, do NOT write `state.yaml` — surface the blocker to the user instead.

This is a meta-command handled by the orchestrator. Do NOT invoke it as a skill.
