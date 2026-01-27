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
