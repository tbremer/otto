# Otto Development History

## What We Built

**Otto** is a simplified planning/execution toolkit for OpenCode, inspired by `gsd-oc` (located at `/Users/tom/Projects/autonomous/gsd-oc/`). The goal is to make writing, modifying, planning, and researching code easier using agentic tooling.

## Key Design Decisions

1. **Simplified artifact structure** (reduced from gsd-oc's 6+ files):
   - `.otto/config.json` — Minimal settings
   - `.otto/PROJECT.md` — Vision, phases, current state (single source of truth)
   - `.otto/CODEBASE.md` — Living technical documentation, accumulates learnings as phases complete
   - `.otto/phases/XX-name/XX-YY-PLAN.md` — Executable plans with embedded unknowns

2. **Command naming**: Uses hyphenated format (`/otto-init`, `/otto-plan`) because OpenCode doesn't support space-separated namespaces.

3. **Research merged into planning**: The planner does light research inline (Context7, quick lookups) and surfaces "hard unknowns" that need user input or deep investigation. `/otto-research` is optional for deep dives.

4. **Single PROJECT.md** instead of separate STATE.md/ROADMAP.md — less file sprawl.

5. **Unknowns embedded in PLAN.md** rather than separate UNKNOWNS.md file.

6. **No custom OpenCode agents** — uses `general` subagent type with custom prompts (planner, researcher).

7. **Verification in task loop** — no separate test command; `<verify>` runs after each task.

8. **Continuous learning capture** — micro-retros after each task, phase retro when all plans complete. Borrowed structured approach from gsd-oc.

9. **Executor without subagent** — `/otto-exec` runs in main session so user can see progress and intervene.

## Files Created

```
/Users/tom/Projects/autonomous/otto/
├── .gitignore                    # Ignores gsd-oc/, .DS_Store
├── setup.sh                      # Creates symlinks to ~/.config/opencode/
├── COMPACTION.md                 # This file — conversation history
├── TODO.md                       # Tracks future research items
├── commands/
│   ├── otto-init.md              # /otto-init — Initialize project
│   ├── otto-plan.md              # /otto-plan — Create execution plans
│   ├── otto-research.md          # /otto-research — Deep research on unknowns
│   └── otto-exec.md              # /otto-exec — Execute a plan
├── agents/
│   ├── otto-planner.md           # Subagent for creating plans
│   └── otto-researcher.md        # Subagent for deep research
└── templates/
    ├── config.json               # Reference template
    ├── PROJECT.md                # Reference template
    ├── CODEBASE.md               # Reference template
    └── PLAN.md                   # Reference template
```

**Symlinks installed to:**
- `~/.config/opencode/commands/otto-init.md`
- `~/.config/opencode/commands/otto-plan.md`
- `~/.config/opencode/commands/otto-research.md`
- `~/.config/opencode/commands/otto-exec.md`
- `~/.config/opencode/agents/otto-planner.md`
- `~/.config/opencode/agents/otto-researcher.md`

## Commands Summary

| Command | Description |
|---------|-------------|
| `/otto-init` | Initialize project — creates `.otto/` structure, discovers goals/constraints |
| `/otto-plan [phase]` | Create execution plans — spawns planner, produces PLAN.md files |
| `/otto-research [phase]` | Deep research — resolves unknowns in plans |
| `/otto-exec [plan]` | Execute a plan — runs tasks, verifies, captures learnings |

## Roadmap Status

1. ~~Planning~~ ✓ **COMPLETE**
2. ~~Researching~~ ✓ **COMPLETE**
3. ~~Executing~~ ✓ **COMPLETE** (with verification built-in)
4. ~~Testing~~ ✓ **COMPLETE** (verification in task loop)
5. ~~Retrospecting~~ ✓ **COMPLETE** (task-level + phase-level in otto-exec)

**All core slices complete!**

## Learning System (Borrowed from GSD-OC)

After researching gsd-oc's approach, we adopted their **continuous learning capture** model:

### Task-Level Micro-Retro (after each task)

Structured questions:
1. **Decisions** — What choices were made? Why? What constraints?
2. **Surprises** — What worked differently than expected?
3. **Corrections** — Were any assumptions wrong?
4. **Patterns** — Any conventions established?

Skip criteria (all must be true to skip):
- No unknowns resolved
- No deviations from plan
- No unexpected behavior
- Straightforward implementation

Output format in CODEBASE.md:
```markdown
### {Date} — Phase {N}, Plan {M}: {task name}

**Decisions:**
| Decision | Rationale | Outcome |
|----------|-----------|---------|
| {choice} | {why} | — Pending |

**Learned:**
- {concrete learning}

**Patterns:**
- {convention to follow}
```

Decision outcomes updated later: ✓ Good / ⚠️ Revisit

### Phase-Level Retro (when all plans complete)

- Summarizes accomplishments
- Reviews captured learnings
- Asks user for additional insights
- Updates PROJECT.md status

## What's Next

Potential future enhancements:
- `/otto-status` — Show project state, phase progress
- Wave-based parallel execution
- Auto-continue to next plan after completion
- Decision outcome tracking (revisit "— Pending" decisions)

## Reference Material

- gsd-oc source: `/Users/tom/Projects/autonomous/gsd-oc/`
- OpenCode docs for commands: https://opencode.ai/docs/commands/
- OpenCode docs for agents: https://opencode.ai/docs/agents/

## User Preferences

- Prefers simplified approaches over complex gsd-oc patterns
- Wants to learn as we go — ask questions and explain decisions
- No additional OpenCode agents (use `general` subagent with prompts)
- Minimal config — only add settings if truly needed
- Reinforcement learning is key — capture learnings while fresh
- Always prefer Question tool for user prompts (structured, not conversational)

---

## Init Improvements (Feb 2026)

### Problem Statement
- Original init asked 6 questions upfront before investigating the codebase
- Many answers could be auto-detected for existing projects
- Deferred investigation (ask first, scan after) reversed logical priority
- Lack of intelligent defaults caused user fatigue on established codebases

### Solution: Two-Phase Init with Discovery

**Phase 1: Discovery (if codebase exists)**
- New subagent `agents/otto-init.md` scans codebase thoroughly
- Extracts: project name, vision, tech stack, entry points, patterns
- Assigns confidence levels: HIGH (auto-detect), MEDIUM (probe user), LOW (ask user)
- Returns structured report for orchestrator

**Phase 2: Conditional Questions**
- For existing codebases: 3-4 questions (vs 6 before)
  - Confirm auto-detected name/vision (or correct if needed)
  - Ask goals (not in docs)
  - Ask for additional constraints
  - Ask first milestone
- For greenfield: 3-question simplified flow
- For bare repos: fallback to simplified flow

### Key Changes

1. **New subagent:** `agents/otto-init.md`
   - Scans manifests, README, git history
   - Identifies frameworks, entry points, conventions
   - Runs discovery in parallel before questions
   - Returns HIGH-confidence values only for auto-detection

2. **Refactored command:** `commands/otto-init.md`
   - Orchestrator logic (simple)
   - Spawns discovery subagent via `task` tool
   - Uses `question` tool for ALL user prompts (never conversational text)
   - Conditional question flow based on what wasn't detected
   - Ends with "What's next?" prompt

3. **Git integration**
   - Uses git to infer: project name (remote), creation date, activity level
   - Fallbacks to file-based detection if no git
   - Confidence scoring: git data is HIGH

4. **Question tool everywhere**
   - All user prompts use `question` tool (consistent UI)
   - Shows discovered values with sources (e.g., "from package.json")
   - Let user confirm/correct HIGH-confidence values
   - Probe for MEDIUM items until confident

5. **Post-init guidance**
   - No auto-scaffolded Phase 1 PLAN.md
   - Instead, ask "What's next?" with guided options
   - User can create plan, review structure, or skip

### Benefits

- **50% fewer questions** for established projects
- **Smarter defaults** (users confirm, don't rebuild)
- **Better CODEBASE.md** from discovery subagent
- **Cleaner architecture** (discovery logic centralized)
- **Git-aware** (names, dates, activity inferred from repo)
- **Consistent UI** (Question tool used everywhere)

### Implementation Details

**otto-init subagent flow:**
```
1. Detect package manifests
2. Extract project metadata (name, description, version)
3. Identify framework and key dependencies
4. Scan source structure and entry points
5. Identify patterns and conventions
6. Query git history (repo name, creation date, activity)
7. Assign confidence levels
8. Return structured report (HIGH-confidence only for defaults)
```

**otto-init command flow:**
```
1. Check if .otto/ exists
2. Detect codebase type
3. Spawn otto-init subagent (if codebase)
4. Parse HIGH-confidence findings
5. Ask conditional questions based on what's missing
6. Merge discovered values + user input
7. Create .otto/ files
8. Show summary + "What's next?" prompt
```

### Files Modified/Created

- ✅ **Created:** `agents/otto-init.md` (120 lines)
- ✅ **Refactored:** `commands/otto-init.md` (180 lines)
- ✅ **Documented:** This section in COMPACTION.md
