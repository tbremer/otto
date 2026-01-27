---
description: Execute a plan from a phase
agent: build
argument-hint: "[plan-path or phase-number]"
tools:
  - question
  - read
  - write
  - edit
  - grep
  - glob
  - list
  - bash
---

Execute tasks from a PLAN.md file. Reads the plan and executes each task in sequence.

**Usage:** 
- `/otto-exec 01-02` — Execute plan 02 from phase 01
- `/otto-exec .otto/phases/01-setup/01-02-PLAN.md` — Execute specific plan file
- `/otto-exec` — Show available plans and let user pick

## Process

### 1. Validate Environment

Check that `.otto/` exists:

Use `glob` to confirm `.otto/PROJECT.md` and `.otto/config.json` exist.

**If not found:** Tell the user to run `/otto-init` first and stop.

### 2. Parse Arguments & Find Plan

From `$ARGUMENTS`, determine the plan to execute:

**If full path provided** (contains `/` or ends in `.md`):
- Use that path directly

**If short form provided** (e.g., `01-02`):
- Parse as `{phase}-{plan}`
- Find matching file: `.otto/phases/{phase}-*/{phase}-{plan}-PLAN.md`

**If no argument:**
- List all plans across phases with their status
- Show which are autonomous (ready) vs have unknowns
- Ask user which to execute

Use `glob` to find all plans: `.otto/phases/**/*-PLAN.md`.

### 3. Read and Parse Plan

Read the selected PLAN.md file and extract:

**From frontmatter:**
- `phase` — Phase ID
- `plan` — Plan number
- `wave` — Execution wave
- `depends_on` — Dependencies
- `autonomous` — Whether ready to execute
- `files_modified` — Files that will be touched

**From body:**
- `<objective>` — What we're accomplishing
- `<context>` — Files to reference
- `<unknowns>` — Unresolved questions
- `<tasks>` — The work to do
- `<verification>` — How to confirm success

### 4. Check Dependencies

If `depends_on` is not empty:

Use `glob` to locate each dependency plan file, then `grep`/`read` to confirm it contains `status: completed`.

**If dependencies not completed:**
```
⚠ This plan depends on:
  • Plan {dep} — {status}

Execute dependencies first, or continue anyway?
```

Wait for user confirmation to proceed.

### 5. Check Autonomous Status

```
⚠ This plan has unresolved unknowns:

- [ ] {unknown 1}
- [ ] {unknown 2}
```

**If `autonomous: false`:**
use `question`

- header: ⚠ Unknowns found
- question: How would you like to resolve?
- options:
  - `/otto-research {phase}`
  - Proceed with assumptions in plan

If `/otto-research {phase}`
  - use Task to call `otto-research` subagent
If `Proceed`
  - Continue with a not that we're using assmption

Wait for user. If they answer, update the plan. If they say proceed, continue with a note that we're using assumptions.

### 6. Present Execution Plan

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 OTTO ► EXECUTING PLAN {phase}-{plan}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

{objective text}

Tasks:
  1. {task 1 name}
  2. {task 2 name}
  3. {task 3 name}

Files to modify:
  • {file 1}
  • {file 2}

Ready to execute?
```

Wait for user confirmation (unless they invoked with a flag indicating auto-proceed).

### 7. Execute Tasks

For each `<task>` in the plan:

**7a. Announce task:**
```
━━━ Task {N}/{total}: {task name} ━━━
```

**7b. Load context:**
Read any files mentioned in `<files>` that you haven't read yet.

**7c. Execute the action:**
Follow the `<action>` instructions precisely. This is the core work — writing code, creating files, making changes.

The `<action>` should be specific enough to implement without interpretation. If it's not, note this as feedback for improving the planner.

**7d. Run verification:**
Execute the `<verify>` command/check:

```bash
# Example: run tests, type check, etc.
{verify command}
```

**7e. Check done criteria:**
Confirm the `<done>` criteria is met.

**7f. Report result:**
```
✓ Task {N}: {name}
  Verified: {verify result}
```

**7g. Capture learnings (micro-retro):**

Immediately after task completion, ask these structured questions:

**1. Decisions** — What choices were made during this task?
   - What options did you consider?
   - What did you choose and why?
   - What constraints influenced the decision?

**2. Surprises** — What worked differently than expected?
   - Did an API behave unexpectedly?
   - Was there a gotcha or edge case?
   - Did documentation differ from reality?

**3. Corrections** — Were any assumptions wrong?
   - Did the plan's assumptions hold?
   - If unknowns were resolved, what was the answer?
   - Did you have to deviate from the plan? Why?

**4. Patterns** — Any conventions established?
   - Did you establish a pattern others should follow?
   - Is there a "right way" to do this in this codebase now?
   - Any anti-patterns discovered to avoid?

**Skip criteria:** If ALL of these are true, report "Learnings: None (routine)" and move on:
- No unknowns were resolved
- No deviations from the plan
- No unexpected behavior encountered
- Task was straightforward implementation

**If learnings exist**, append to CODEBASE.md in this format:

```markdown
## Learnings

### {Date} — Phase {N}, Plan {M}: {task name}

**Decisions:**
| Decision | Rationale | Outcome |
|----------|-----------|---------|
| {choice made} | {why} | — Pending |

**Learned:**
- {concrete learning with specifics, not vague observations}

**Patterns:**
- {convention to maintain going forward}
```

Notes on format:
- **Outcome** starts as "— Pending", updated later to "✓ Good" or "⚠️ Revisit" based on results
- Only include sections that have content (skip empty Decisions/Patterns)
- Be specific: "jose requires Node 18+" not "check Node version"

**Report what was captured:**
```
  Learnings: {N} items added to CODEBASE.md
    → {brief description}
```

**If a task fails:**
```
✗ Task {N}: {name}
  Error: {what went wrong}

Options:
  • Fix and retry — I'll attempt to fix the issue
  • Skip — Move to next task
  • Abort — Stop execution
```

Wait for user input.

### 8. Run Final Verification

After all tasks complete, run the `<verification>` checklist:

```
━━━ Final Verification ━━━
```

For each item in `<verification>`:
- Run the check
- Mark as ✓ or ✗
- Report result

```
✓ Tests pass
✓ Build succeeds  
✓ Feature works as expected
```

### 9. Update Plan Status

Edit the PLAN.md file to record completion:

1. Add to frontmatter:
   ```yaml
   status: completed
   completed_at: {ISO timestamp}
   ```

2. Check off verification items that passed:
   ```markdown
   <verification>
   - [x] Tests pass
   - [x] Build succeeds
   - [x] Feature works as expected
   </verification>
   ```

### 10. Present Results

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 OTTO ► PLAN COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Plan {phase}-{plan}: {objective}

Tasks: {completed}/{total}
Verification: {passed}/{total checks}

{Summary of what was accomplished}
```

### 11. Check Phase Progress

Prefer tools for phase progress:

- Use `glob` for all plans in phase: `.otto/phases/${PHASE}-*/*.md`
- Use `grep` to count those containing `status: completed`

`bash` is still fine here if you want exact shell counts, but default to tool-based counting.

**If all plans in phase complete:**

Run the phase retrospective automatically:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 OTTO ► PHASE {N} COMPLETE — RETROSPECTIVE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**11a. Summarize accomplishments:**

Review all completed plans in the phase and summarize:
- What was built/changed
- Key decisions made
- Problems solved

```
What was accomplished:
  • {Summary point 1}
  • {Summary point 2}
  • {Summary point 3}
```

**11b. Review learnings captured:**

Read the learnings added to CODEBASE.md during this phase:
```
Learnings captured during execution:
  • {Learning 1 from task micro-retros}
  • {Learning 2}
```

**11c. Ask for additional insights:**

```
Before closing this phase:
  1. Anything else worth capturing for future reference?
  2. Any patterns or conventions established that should be documented?
  3. Anything that should be done differently next time?
```

Wait for user input. Add any additional learnings to CODEBASE.md.

**11d. Update PROJECT.md:**

1. Change phase status from "in-progress" to "completed"
2. Update Current State section
3. Add completion timestamp

**11e. Present next steps:**

**If there are remaining plans:**
```
Phase {N} progress: {completed}/{total} plans
```

use tool `question`
- header: Next steps
- question: Continue to next plan?
- options:
  - Yes, move to {next-plan}.
  - No, list remaining plans
  - No, start new work
  - No, review CODEBASE.md

- If `yes`: execute command `/otto-plan {next-plan}`
- If `No, list`: use `list` on `.otto/phases/{phase-dir}/`
- If `No, start`: execute command: `/otto-new-work`
- if `No, review`: summarize CODEBASE.md highlighting more recent updates

**If there are no remaining plans**
```
Phase {N} closed.
```

use tool `question`
- header: Next steps
- question: "What's next for us?"
- options:
  - if {next-phase} exists ? `/otto-plan` : `/otto-new-work`
  - Review CODEBASE.md

- If `Review` summarize CODEBASE.md highlighting more recent updates.
- Else execute preferred command `/otto-plan` or `/otto-new-work`

## Execution Principles

### Follow the Plan
The plan is the prompt. Execute what it says, don't reinterpret or improve on the fly. If the plan is wrong, that's feedback for the planning phase.

### Verify As You Go
Don't skip verification steps. They catch issues early and confirm the work is correct.

### Stop on Failure
If something fails, stop and get user input. Don't barrel through and create a mess.

### One Plan at a Time
Execute plans sequentially within a wave. Parallel execution across waves is a future enhancement.

## Notes

- Plans should be small enough to execute in 30-60 minutes
- If execution repeatedly fails, the plan may need revision — suggest `/otto-plan` to re-plan
- Keep the user informed of progress — they should never wonder what's happening
- The plan's `<action>` sections should be specific; if they're vague, execute your best interpretation but note it
