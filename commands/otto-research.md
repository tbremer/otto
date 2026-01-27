---
description: Deep research to resolve unknowns in phase plans
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

Resolve unknowns in phase plans through deep research. Spawns the otto-researcher subagent to investigate questions the planner couldn't answer.

**Usage:** `/otto-research [phase]` or `/otto-research` (uses current in-progress phase)

## Process

### 1. Validate Environment

Check that `.otto/` exists:

Use `glob` to confirm `.otto/PROJECT.md` and `.otto/config.json` exist.

**If not found:** Tell the user to run `/otto-init` first and stop.

### 2. Parse Arguments

Extract phase number from `$ARGUMENTS`:
- If provided: Use that phase number (e.g., `1`, `2`)
- If not provided: Read PROJECT.md and find the phase with status "in-progress"

Normalize the phase number to zero-padded format (1 → 01, 2 → 02).

### 3. Find Phase Plans

Locate the phase directory and plans:

Use `glob` to locate the phase directory:

- `.otto/phases/${PHASE}-*`

Then use `glob` to list plan files in that directory:

- `{PHASE_DIR}/*.md`

**If no plans found:** Tell the user to run `/otto-plan {phase}` first.

### 4. Extract Unknowns

Read all PLAN.md files and extract `<unknowns>` sections:

Use `grep` over the plan files to extract `<unknowns>` blocks, then parse unchecked items (`- [ ]`).

Parse the unknowns:
- Extract the question text (lines starting with `- [ ]`)
- Note which plan file it came from
- Note what it blocks (text after "— blocks")

### 5. Check if Research Needed

**If no unknowns found:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 OTTO ► NO RESEARCH NEEDED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

All plans in Phase {N} are ready to execute (autonomous: true).

Run the plans or review them:
  (use `read` on `{first-plan-path}`)
```

Stop here.

### 6. Present Unknowns

Show the user what needs research:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 OTTO ► RESEARCH NEEDED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Phase {N}: {name} has {X} unknowns to resolve:

1. [Plan {XX-YY}] {Question}
   Blocks: {task or decision}

2. [Plan {XX-YY}] {Question}
   Blocks: {task or decision}

Options:
  • Research all — I'll investigate each and update the plans
  • Pick specific — tell me which numbers to research
  • Answer now — if you already know, just tell me
```

Wait for user response.

### 7. Handle User Response

**If user provides answers directly:**
For each answer provided:
1. Update the relevant PLAN.md file
2. Check off the unknown in `<unknowns>`
3. Update the affected `<action>` with specifics
4. Set `autonomous: true` if all unknowns resolved

Then show what was updated and exit.

**If user says "research all" or picks specific items:**
Continue to step 8.

### 8. Gather Context for Researcher

For each unknown to research, collect context:

1. Read the full PLAN.md containing the unknown
2. Read referenced files in `<context>`
3. Read `.otto/PROJECT.md` for project context
4. Read `.otto/CODEBASE.md` for technical context

### 9. Spawn otto-researcher

Use the Task tool to spawn the `otto-researcher` subagent:

**Prompt for the researcher:**
```
Resolve these unknowns from Phase {N}: {phase name}

## Unknowns to Research

### Unknown 1 (Plan {XX-YY})
Question: {question text}
Blocks: {task or decision}
Plan context: {objective and relevant task from the plan}

### Unknown 2 (Plan {XX-YY})
...

## Project Context
{relevant sections from PROJECT.md}

## Codebase Context  
{relevant sections from CODEBASE.md}

## Instructions
1. Research each unknown thoroughly
2. Provide concrete, actionable answers
3. Include code snippets where helpful
4. For each answer, specify exactly how to update the plan

Return your findings with specific plan updates.
```

### 10. Apply Research Findings

After the researcher returns, for each resolved unknown:

1. **Update PLAN.md file:**
   - Check off the unknown: `- [x] {question} — RESOLVED`
   - Update the affected task's `<action>` with researched specifics
   - If all unknowns resolved, set `autonomous: true` in frontmatter

2. **Track what changed** for the summary

### 11. Present Results

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 OTTO ► RESEARCH COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Resolved {X}/{Y} unknowns in Phase {N}:

✓ [Plan {XX-YY}] {Question}
  → {Brief summary of answer}

✓ [Plan {XX-YY}] {Question}
  → {Brief summary of answer}

Plans updated:
  • {plan-path} — now autonomous: true
  • {plan-path} — now autonomous: true
```

**If some unknowns couldn't be resolved:**
```
⚠ {N} unknowns still need resolution:

✗ [Plan {XX-YY}] {Question}
  → Needs: {what the researcher determined is needed — user decision, external info, etc.}

Options:
  • Answer now — tell me your decision
  • Skip — proceed with current assumptions in the plan
```

### 12. Next Steps

**If all unknowns resolved:**
```
All plans are ready to execute.

Next: /otto-exec {phase} — or review the updated plans first
```

**If some remain:**
```
{N} plans are ready (autonomous: true).
{M} plans have remaining unknowns.

You can execute the ready plans while resolving the others.
```

## Notes

- Research should be thorough but focused — we're answering specific questions, not exploring broadly
- The researcher subagent does the investigation; this command orchestrates and applies results
- Always show the user what changed in their plan files
- If user has the answer, let them provide it directly — no need to spawn researcher
