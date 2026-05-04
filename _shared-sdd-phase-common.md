# SDD Phase — Common Protocol

Boilerplate shared across all SDD phase skills.

Executor boundary: every SDD phase agent is an EXECUTOR, not an orchestrator. Do the phase work yourself. Do NOT launch sub-agents, do NOT delegate, and do NOT bounce work back unless you hit a real blocker.

## A. Skill Loading

1. Check if the orchestrator injected a `## Project Standards (auto-resolved)` block in your launch prompt. If yes, follow those rules — they are pre-digested compact rules from the skill registry. **Do NOT read any SKILL.md files.**
2. If no Project Standards block was provided, check for `SKILL: Load` instructions and load those files.
3. If neither, check for `.atl/skill-registry.md` in the project root. If found, apply rules whose triggers match your current task.
4. If no registry exists, proceed with your phase skill only.

## B. Artifact Retrieval

All artifacts are files under `openspec/changes/{change-name}/`. Read them directly from the filesystem before starting work.

Do NOT assume artifact content from prior conversation context — always read fresh from disk.

Run all reads in parallel when possible.

## C. Artifact Persistence

Every phase that produces an artifact MUST write it to disk. Skipping this BREAKS the pipeline — downstream phases will not find your output.

Write your artifact to the path defined in `openspec-convention.md` for your phase. If the file already exists, read it first and update it — never overwrite blindly.

No additional persistence steps are needed beyond writing the file.

## D. Return Envelope

Every phase MUST return a structured envelope to the orchestrator:

- `status`: `success`, `partial`, or `blocked`
- `executive_summary`: 1-3 sentence summary of what was done
- `artifacts`: list of file paths written
- `next_recommended`: the next SDD phase to run, or "none"
- `risks`: risks discovered, or "None"
- `skill_resolution`: how skills were loaded — `injected` (received Project Standards from orchestrator), `fallback-registry` (self-loaded from .atl/skill-registry.md), `fallback-path` (loaded via SKILL: Load), or `none`

Example:

```markdown
**Status**: success
**Summary**: Proposal created for `{change-name}`. Defined scope, approach, and rollback plan.
**Artifacts**: `openspec/changes/{change-name}/proposal.md`
**Next**: sdd-spec or sdd-design
**Risks**: None
**Skill Resolution**: injected — 2 skills matched
```

## E. Review Workload Guard

SDD must protect reviewer cognitive load, not only generate tasks.

- The default PR review budget is **400 changed lines** (`additions + deletions`).
- The orchestrator caches a delivery strategy at session start: `ask-on-risk` (default), `auto-chain`, `single-pr`, or `exception-ok`. It passes this to `sdd-tasks` and `sdd-apply`.
- `sdd-tasks` MUST forecast whether the planned work may exceed that budget.
- The forecast MUST include these exact plain-text lines so downstream guards can match them:

```
Decision needed before apply: Yes|No
Chained PRs recommended: Yes|No
Chain strategy: stacked-to-main|feature-branch-chain|size-exception|pending
400-line budget risk: Low|Medium|High
```

- If the forecast is high, `sdd-tasks` MUST recommend chained or stacked PRs using deliverable work units.
- `sdd-apply` MUST NOT start oversized work unless the delivery strategy resolves to chained/stacked PR slices or explicitly accepted `size:exception`.
