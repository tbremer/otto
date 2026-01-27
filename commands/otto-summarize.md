---
description: Snapshot of codebase, Otto context, and projects
agent: build
argument-hint: ""
tools:
  - question
  - read
  - grep
  - glob
  - list
---

Give a comprehensive snapshot of the codebase, Otto's accumulated context, and project history (past, current, future).

**Usage:** `/otto-summarize`

## Process

### 1. Validate Environment

Check that `.otto/` exists:

Use `glob` to confirm `.otto/PROJECT.md` and `.otto/config.json` exist.

**If not found:** Tell the user this project hasn't been initialized with Otto. Offer to describe what they'd get from `/otto-init`.

### 2. Read All Otto Context

Gather information from all Otto files:

Use `read` to load:

- `.otto/PROJECT.md`
- `.otto/CODEBASE.md` (if present)
- `.otto/config.json`

Use `glob` to list plan files:

- `.otto/phases/**/*-PLAN.md`

### 3. Scan Codebase Structure

Get a high-level view of the codebase:

Prefer tool-based scanning:

- Use `list` on `.` and a few key subdirectories (top 2-3 levels)
- Use `glob` for key files: `package.json`, `tsconfig.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`
- Use `glob` to count source files by extension (approximate counts) or use `bash` if you need precise counts.

### 4. Present Comprehensive Summary

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 OTTO ► PROJECT SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Project Identity

**Name:** {project name from PROJECT.md}
**Description:** {what this project does — 1-2 sentences}
**Core Value:** {the key value proposition}

## Tech Stack

{From CODEBASE.md or inferred from files}

- **Language:** {TypeScript, Python, etc.}
- **Framework:** {Next.js, FastAPI, etc.}
- **Database:** {PostgreSQL, SQLite, etc.}
- **Key Libraries:** {list major dependencies}

## Codebase Structure

```
{directory tree, 2-3 levels}
```

- **Source files:** {count} files
- **Test files:** {count} files
- **Config files:** {list key configs}

## Otto Context

**Initialized:** {date from config or first commit}
**Phases defined:** {N}
**Plans created:** {N} across {M} phases
**Learnings captured:** {N} items in CODEBASE.md

### Key Decisions Made

{Table from CODEBASE.md learnings}

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| {decision 1} | {why} | {outcome} |
| {decision 2} | {why} | {outcome} |

### Patterns Established

{From CODEBASE.md learnings}

- {pattern 1}
- {pattern 2}

### Known Constraints

{From PROJECT.md}

- {constraint 1}
- {constraint 2}

## Project History

### Completed Phases

{For each completed phase}

**Phase {N}: {name}** — Completed {date}
  - {brief summary of what was accomplished}
  - Plans: {N} executed
  - Key outcome: {main deliverable}

### Current Phase

**Phase {N}: {name}** — In Progress
  - Progress: {completed}/{total} plans ({percentage}%)
  - Currently working on: {active plan objective}
  - Blockers: {any unknowns or issues}

### Upcoming Phases

**Phase {N}: {name}** — Planned
  - {description from PROJECT.md}
  - Depends on: {prior phase outcomes}

**Phase {N+1}: {name}** — Planned
  - {description}

## Quick Reference

| Command | Use When |
|---------|----------|
| `/otto-progress` | Check current status |
| `/otto-plan {N}` | Plan next phase |
| `/otto-exec {plan}` | Execute a plan |
| `/otto-research {N}` | Resolve unknowns |

## Files

| File | Purpose |
|------|---------|
| `.otto/PROJECT.md` | Vision, phases, state |
| `.otto/CODEBASE.md` | Technical docs + learnings |
| `.otto/phases/` | Execution plans |
```

### 5. Handle Sparse Information

If some information isn't available, note it gracefully:

```
### Learnings

No learnings captured yet. These accumulate as you execute plans.
```

```
### Upcoming Phases

No future phases defined yet. Add them to PROJECT.md or discuss during /otto-plan.
```

### 6. Offer Next Steps

Based on project state, suggest logical next actions:

**If no plans exist:**
```
Ready to start? Run /otto-plan 1 to plan the first phase.
```

**If plans exist but none executed:**
```
Plans are ready. Run /otto-exec {first-plan} to begin.
```

**If mid-execution:**
```
Continue with /otto-exec {next-plan} or check /otto-progress for details.
```

**If project complete:**
```
Project complete! Review learnings in CODEBASE.md for future reference.
```

## Notes

- This is a read-only command — it doesn't modify any files
- Aim for a comprehensive but scannable output
- This is useful for onboarding, context refresh, or sharing project state
- If CODEBASE.md has a lot of content, summarize rather than dump everything
- Infer tech stack from files if not explicitly documented
