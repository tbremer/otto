---
description: Execute plans in an Otto plan folder with wave-based parallelization
---

<objective>
Execute all plans in a plan folder using wave-based parallel execution.

Orchestrator stays lean: discover plans, group into waves, spawn executors, collect results.
Each executor gets a fresh context window with the full plan inlined.

Input: $ARGUMENTS — a plan folder name or path (e.g. "02092026-auth-jwt" or ".otto/plans/02092026-auth-jwt")

If no arguments provided, list available plan folders and ask the user to pick one.

Context budget: ~15% orchestrator, 100% fresh per executor subagent.
</objective>

<process>

## 1. Resolve Plan Folder

```bash
# Normalize input — accept folder name or full path
if echo "$ARGUMENTS" | grep -q ".otto/plans/"; then
  PLAN_DIR="$ARGUMENTS"
else
  PLAN_DIR=".otto/plans/$ARGUMENTS"
fi
```

If $ARGUMENTS is empty, list available folders and use the question tool:

```bash
ls -1d .otto/plans/*/ 2>/dev/null | sed 's|.otto/plans/||;s|/||'
```

Present the list and ask: "Which plan folder do you want to execute?"

If no plan folders exist, inform the user and suggest `/plan <description>` first.

## 2. Discover Plans

```bash
# List all plan files in folder
PLAN_FILES=$(ls "$PLAN_DIR"/plan-*.md 2>/dev/null | sort -V)
PLAN_COUNT=$(echo "$PLAN_FILES" | grep -c "plan-" || echo 0)
```

If no plan files found, error: "No plan files found in $PLAN_DIR"

Check which plans already have a matching summary (already executed):

```bash
for f in $PLAN_FILES; do
  PLAN_NUM=$(basename "$f" .md | sed 's/plan-//')
  if [ -f "$PLAN_DIR/summary-${PLAN_NUM}.md" ]; then
    echo "DONE: plan-${PLAN_NUM}"
  else
    echo "TODO: plan-${PLAN_NUM}"
  fi
done
```

Build list of incomplete plans only.

If all plans already have summaries, inform user: "All plans in this folder are already executed."

## 3. Group by Wave

Read `wave` from each incomplete plan's frontmatter:

```bash
for f in $INCOMPLETE_PLANS; do
  WAVE=$(grep "^wave:" "$f" | head -1 | awk '{print $2}')
  echo "wave:${WAVE} file:${f}"
done
```

Group plans by wave number. Report structure:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 OTTO ► EXECUTING: {folder-name}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

{N} plans in {M} waves

Wave 1: plan-00, plan-01
Wave 2: plan-02

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## 4. Execute Waves

For each wave in ascending order:

### 4a. Read plan contents and state

Before spawning, read all file contents. The `@` syntax does not work across subagent boundaries.

```bash
STATE_CONTENT=$(cat .otto/STATE.md 2>/dev/null || echo "")

# For each plan in this wave, read its content
PLAN_CONTENT=$(cat "$PLAN_FILE")
```

### 4b. Spawn executors

Spawn `@otto-executor` for each plan in the wave (parallel calls):

```
@otto-executor

Plan folder: ${PLAN_DIR}
Plan file: ${PLAN_FILE}

<plan_content>
${PLAN_CONTENT}
</plan_content>

<project_state>
${STATE_CONTENT}
</project_state>
```

All plans in the same wave run in parallel. Wait for all to complete before starting the next wave.

### 4c. Verify wave completion

After wave completes, check that each plan produced a summary:

```bash
for f in $WAVE_PLANS; do
  PLAN_NUM=$(basename "$f" .md | sed 's/plan-//')
  ls "$PLAN_DIR/summary-${PLAN_NUM}.md" 2>/dev/null
done
```

If any summary is missing, report and continue to next wave (don't block everything).

## 5. Commit Orchestrator Corrections

Check for any uncommitted changes made between executor completions:

```bash
git status --porcelain
```

If changes exist:
```bash
git add -u && git commit -m "fix(otto): orchestrator corrections during execution"
```

If clean: continue.

## 6. Update State

Update `.otto/STATE.md` with execution results:
- Append entry: timestamp, folder name, plans executed, status
- Update last activity

## 7. Present Results

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 OTTO ► EXECUTED ✓
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

{folder-name}: {N} plans executed in {M} waves

{summary of what was built — pull from executor summaries}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

▶ Review: cat ${PLAN_DIR}/summary-*.md
▶ Plan more: /plan <next thing>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

</process>

<deviation_rules>
During execution, executors handle discoveries automatically:

| Rule | Trigger | Action |
|------|---------|--------|
| 1. Auto-fix bugs | Broken behavior, incorrect output | Fix immediately, document |
| 2. Auto-add critical | Missing security, validation, error handling | Add immediately, document |
| 3. Auto-fix blockers | Missing dependency, broken import, config error | Fix to unblock, document |
| 4. Ask about architectural | New DB table, major schema change, switching libraries | STOP, return checkpoint |

Rules 1-3 need no permission. Rule 4 pauses for user input.

Priority: Rule 4 > Rules 1-3. When unsure → Rule 4.
</deviation_rules>

<commit_rules>
**Per-Task Commits** (handled by executor):
- Stage only files modified by that task (NEVER `git add .`)
- Format: `{type}(otto): {task-name}`
- Types: feat, fix, test, refactor, perf, chore
- Record commit hash for summary

**Plan Metadata Commit** (handled by executor):
- Stage: plan file + summary file
- Format: `docs(otto): complete plan-{NN}`

**Orchestrator Commit** (handled by this command):
- Only if corrections were made between executor runs
- Format: `fix(otto): orchestrator corrections during execution`
</commit_rules>

<rules>
- Between 1 and 6 subagent calls per wave. Total across all waves depends on plan count.
- Never fail on missing optional files (STATE.md, CONTEXT.md, etc.).
- If .otto doesn't exist, inform user and suggest `/plan` first.
- Plans within the same wave execute in parallel. Waves execute sequentially.
- Each executor gets a completely fresh context window — inline all content, don't use @references.
- STATE.md is updated once at the end by the orchestrator, not by individual executors.
</rules>
