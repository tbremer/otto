# Otto

<p>
  <img src="otto-man.jpeg" alt="Otto" width="125" align="left" style="margin-right: 16px;" />

  <strong>Otto</strong> is an autonomous code discovery, planning, execution, and retrospection agent built on <a href="https://opencode.ai">OpenCode</a>.
  <br clear="left" />
</p>

## Philosophy

Otto treats **plans as prompts**. Each plan is specific enough to execute without interpretation — small, focused, and verifiable. As you execute, Otto captures learnings to build institutional knowledge in your codebase.

This project is heavily inspired by [gsd-oc](https://github.com/gsd-oc), but deliberately simplified to prioritize iteration velocity and constant reinforcement. 

Otto is intentionally opinionated about:

- Keeping the artifact surface area small (fewer files, less ceremony)
- Capturing learnings while they are fresh (task-level reinforcement)
- Treating verification as part of execution, not a separate phase

## Installation

```bash
# Clone the repo
git clone https://github.com/tbremer/otto.git
cd otto

# Install commands and agents to OpenCode
./setup.sh
```

This creates symlinks in `~/.config/opencode/` so Otto commands are available in any project as `/otto/<command>`.

## Commands

| Command | Description |
|---------|-------------|
| `/otto/plan [description]` | Create execution plans — breaks a description into small, executable plans |
| `/otto/research [topic]` | Deep research — investigates codebase or domain topics |
| `/otto/execute [plan]` | Execute a plan — runs tasks, verifies results, captures learnings |

## Workflow

```
/otto/plan "user authentication with JWT"  # Create executable plans
    ↓
/otto/research "JWT best practices"       # (optional) Resolve unknowns
    ↓
/otto/execute 01-01                        # Execute first plan
    ↓
... repeat ...
```

## Project Structure

When you first run `/otto/plan`, Otto creates:

```
.otto/
├── config.json     # Minimal settings
├── PROJECT.md      # Vision, phases, current state
├── CODEBASE.md     # Technical docs + accumulated learnings
├── STATE.md        # Plan execution history
├── RESEARCH.md     # Research findings
└── plans/
    ├── 01-PLAN.md
    ├── 02-PLAN.md
    └── ...
```

### PROJECT.md

Single source of truth for project vision, phases, and status.

### CODEBASE.md

Living technical documentation. Starts with stack and architecture, grows with learnings captured during execution.

### PLAN.md

Executable plans with:
- Clear objective
- 2-3 focused tasks (15-60 min each)
- Verification steps
- Embedded unknowns (if any)

### STATE.md

Execution history tracking all plans, timestamps, and outcomes.

### RESEARCH.md

Research findings from `/otto/research` command.

## Learning System

Otto captures learnings continuously, not just at the end:

**After each task:**
- What decisions were made? Why?
- What worked differently than expected?
- Any assumptions proven wrong?
- Patterns established to follow?

**After each phase:**
- Summary of accomplishments
- Review of captured learnings
- Prompt for additional insights

Learnings accumulate in `CODEBASE.md` with decision tracking:

```markdown
| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Use jose for JWT | Native WebCrypto | ✓ Good |
| Skip rate limiting | MVP scope | ⚠️ Revisit |
```

## Requirements

- [OpenCode](https://opencode.ai) installed and configured
- Bash shell

## Glossary

| Term | Meaning |
|------|---------|
| **Plan** | A small, executable unit of work (30-60 min). Contains 2-3 tasks. Lives in a PLAN.md file. |
| **Task** | A single focused action within a plan (15-60 min). Has an action, verification, and done criteria. |
| **Wave** | Execution order for plans. Wave 1 plans have no dependencies and can run in parallel. Wave 2 depends on Wave 1, etc. |
| **Unknown** | A question that blocks clean execution. Can be resolved via `/otto-research` or answered by the user. |
| **Autonomous** | A plan with no unresolved unknowns. Ready to execute without human input. |
| **CODEBASE.md** | Living document that accumulates technical knowledge and learnings over time. |
| **PROJECT.md** | Single source of truth for project vision, phases, constraints, and current state. |
| **STATE.md** | Execution history tracking all plans, timestamps, and outcomes. |
| **Decision** | A choice made during execution. Tracked with rationale and outcome (✓ Good / ⚠️ Revisit / — Pending). |
| **Pattern** | A convention established during execution that should be followed going forward. |
| **Context** | Files referenced by a plan (via `@` references) that provide background for execution. |

## License

MIT
