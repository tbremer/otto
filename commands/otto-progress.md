---
description: Show current work tree and progress
agent: build
argument-hint: "[phase-number]"
tools:
  - question
  - read
  - grep
  - glob
  - list
---

Summarize the current work tree — what phase we're in, which plans are done, what's next.

**Usage:**
- `/otto-progress` — Show overall project progress
- `/otto-progress 2` — Show detailed progress for phase 2

## Process

### 1. Validate Environment

Check that `.otto/` exists:

Use `glob` to confirm `.otto/PROJECT.md` and `.otto/config.json` exist.

**If not found:** Tell the user to run `/otto-init` first and stop.

### 2. Read Project State

Read `.otto/PROJECT.md` and extract:
- Project name and description
- All phases with their status (planned, in-progress, completed)
- Current active phase

### 3. Scan Plan Files

Use `glob` to find all plans: `.otto/phases/**/*-PLAN.md`.

For each plan file, extract from frontmatter:
- `phase` and `plan` number
- `status` (pending, in-progress, completed)
- `autonomous` (ready to execute or has unknowns)
- `wave` (execution order)

### 4. Calculate Progress

For each phase:
- Count total plans
- Count completed plans
- Count plans with unknowns
- Determine phase completion percentage

### 5. Present Overview

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 OTTO ► PROJECT PROGRESS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

{Project name}

Phase Overview:
  ✓ Phase 1: {name}                    [4/4 plans] 100%
  ▶ Phase 2: {name}                    [2/5 plans]  40%  ← current
  ○ Phase 3: {name}                    [0/0 plans]   0%  (not planned)

Current Phase: {N} — {name}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

| Plan | Name | Status | Autonomous |
|------|------|--------|------------|
| 02-01 | {name} | ✓ completed | yes |
| 02-02 | {name} | ✓ completed | yes |
| 02-03 | {name} | ▶ in-progress | yes |
| 02-04 | {name} | ○ pending | no (2 unknowns) |
| 02-05 | {name} | ○ pending | yes |

Next action:
  • Continue: /otto-exec 02-03
  • Or resolve unknowns: /otto-research 2
```

### 6. Detailed Phase View (if argument provided)

If user specified a phase number, show additional detail:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 OTTO ► PHASE {N} DETAIL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Phase {N}: {name}
{description from PROJECT.md}

Progress: {completed}/{total} plans ({percentage}%)
[████████░░░░░░░░░░░░] 

Plans by Wave:
  Wave 1: {status}
    • 01 {name} — ✓ completed
    • 02 {name} — ✓ completed
  
  Wave 2: {status}
    • 03 {name} — ▶ in-progress
    • 04 {name} — ○ pending (blocked by 03)
  
  Wave 3: {status}
    • 05 {name} — ○ pending (blocked by 04)

Unknowns:
  • [Plan 04] {question}
  • [Plan 04] {question}

Learnings captured: {N} items in CODEBASE.md
```

### 7. Handle Edge Cases

**No phases planned yet:**
```
No phases planned yet.

Next: Define phases in PROJECT.md or run /otto-plan
```

**No plans in current phase:**
```
Phase {N} has no plans yet.

Next: /otto-plan {N}
```

**All phases complete:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 OTTO ► PROJECT COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

All {N} phases completed!

Total plans executed: {N}
Learnings captured: {N} items

Review the journey:
  • (use `read` on `.otto/PROJECT.md`)
  • (use `read` on `.otto/CODEBASE.md`)
```

## Notes

- This is a read-only command — it doesn't modify any files
- Use status symbols consistently: ✓ completed, ▶ in-progress, ○ pending
- Always suggest the logical next action
- Keep output scannable — users want a quick overview, not a wall of text
