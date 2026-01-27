---
description: Create execution plans for a phase
agent: build
argument-hint: "[phase-number]"
tools:
  - question
  - read
  - write
  - edit
  - grep
  - glob
  - list
  - task
---

Create execution plans for a project phase. Spawns the otto-planner subagent to produce PLAN.md files.

**Usage:** `/otto-plan [phase]` or `/otto-plan` (auto-detects next unplanned phase)

## Process

### 1. Validate Environment

Check that `.otto/` exists:

Use `glob` to confirm `.otto/PROJECT.md` and `.otto/config.json` exist.

**If not found:** Tell the user to run `/otto-init` first and stop.

### 2. Parse Arguments

Extract phase number from `$ARGUMENTS`:
- If provided: Use that phase number (e.g., `1`, `2`)
- If not provided: Read PROJECT.md and find the first phase with status "planned"

Normalize the phase number to zero-padded format (1 → 01, 2 → 02).

### 3. Validate Phase Exists

Read `.otto/PROJECT.md` and confirm the requested phase exists:

Use `read` + `grep` on `.otto/PROJECT.md` to confirm `### Phase {N}:` exists.

**If not found:** List available phases and ask user which one to plan.

### 4. Check for Existing Plans

Use `glob` to check for existing plans under `.otto/phases/${PHASE}-*/*.md`.

**If plans exist:** 
Ask the user: "Phase $PHASE already has plans. Do you want to:"
- View existing plans
- Re-plan from scratch (will archive existing)
- Cancel

### 5. Gather Context

Read the key files to understand the project:

Use `read` to load `.otto/PROJECT.md` and `.otto/CODEBASE.md` (if present).

Extract:
- Phase name and description from PROJECT.md
- Project goals and constraints
- Tech stack and patterns from CODEBASE.md (if exists)

### 6. Conversational Refinement

Before spawning the planner, have a brief conversation with the user:

**Present your understanding:**
"Here's what I understand about Phase {N}: {name}

{Description from PROJECT.md}

The outcome should be: {outcome from PROJECT.md}

Based on the codebase, I'll be working with:
- {stack/framework}
- {key patterns}

**Ask for input:**
"Before I create the plans:
1. Does this understanding look correct?
2. Any specific approach you want me to take?
3. Anything I should avoid or be careful about?"

Wait for user response and incorporate their feedback.

### 7. Create Phase Directory

Create the directory `.otto/phases/${PHASE}-${PHASE_NAME_SLUG}` using `write`/`edit` tooling (no shell required).

Where `PHASE_NAME_SLUG` is the phase name in lowercase with spaces replaced by hyphens.

### 8. Spawn otto-planner

Use the Task tool to spawn the `otto-planner` subagent:

**Prompt for the planner:**
```
Create execution plans for Phase {N}: {phase name}

## Phase Description
{description from PROJECT.md}

## Outcome
{outcome from PROJECT.md}

## Project Context
{relevant sections from PROJECT.md — goals, constraints}

## Codebase Context
{relevant sections from CODEBASE.md — stack, patterns, key files}

## User Input
{any specific guidance from the conversation in step 6}

## Instructions
1. Break this phase into 2-5 small plans (2-3 tasks each)
2. Do light research to fill in implementation specifics
3. Surface any unknowns you can't resolve
4. Write plans to: {PHASE_DIR}/{PHASE}-{NN}-PLAN.md

Return a summary of plans created and any unknowns that need resolution.
```

### 9. Present Results

After the planner returns, display the results:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 OTTO ► PLANNING COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Created {N} plans for Phase {X}: {name}

{table of plans from planner output}
```

### 10. Handle Unknowns

**If there are unknowns:**
```
⚠ {N} unknowns need resolution:

1. [Plan {XX}] {Question}
   → {Context from planner}

2. [Plan {XX}] {Question}
   → {Context from planner}

Options:
  • Answer now — tell me your decision and I'll update the plans
  • /otto-research {phase} — deep dive research on these questions
  • Proceed anyway — execute with current assumptions
```

Wait for user to choose. If they answer inline, update the relevant PLAN.md files to:
- Check off the unknown
- Update the affected task's `<action>` with their answer
- Set `autonomous: true` if all unknowns resolved

**If no unknowns:**
```
✓ All plans are ready to execute.

Next step: Execute plans in wave order, or review them first:
  cat .otto/phases/{phase-dir}/01-01-PLAN.md
```

### 11. Update Project State

Update `.otto/PROJECT.md`:
- Change phase status from "planned" to "in-progress" 
- Update Current State section with active phase

## Notes

- Keep the conversational refinement brief — don't over-probe
- The planner subagent does the heavy lifting; this command is the orchestrator
- If user seems uncertain, help them think through it, but respect their time
- Plans should be created even if unknowns exist — they're still valuable for understanding scope
