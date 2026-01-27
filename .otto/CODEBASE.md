# Codebase: Otto
> Last updated: 2026-02-03
> Source: /otto init (mapping)

## Stack
- **Language**: Markdown + Bash
- **Runtime**: OpenCode CLI (agent framework)
- **Type**: Command/agent system (no traditional runtime)
- **Delivery**: Symlinks installed to `~/.config/opencode/commands/` and `~/.config/opencode/agents/`

## Structure
```
otto/
├── commands/              # OpenCode command definitions (7 commands)
│   ├── otto-init.md
│   ├── otto-plan.md
│   ├── otto-discover.md
│   ├── otto-research.md
│   ├── otto-exec.md
│   ├── otto-progress.md
│   └── otto-summarize.md
├── agents/               # Subagent role definitions (2 agents)
│   ├── otto-planner.md
│   └── otto-researcher.md
├── templates/            # Reference templates for projects using Otto
│   ├── config.json       # Minimal Otto project config
│   ├── PROJECT.md        # Project vision/goals/phases template
│   ├── CODEBASE.md       # Technical docs template
│   └── PLAN.md           # Executable plan template
├── gsd-oc/               # Reference copy of gsd-oc inspiration
├── setup.sh              # Installation script (creates symlinks)
├── README.md             # User documentation
├── COMPACTION.md         # Development history
├── TODO.md               # Future research items
└── otto-man.jpeg         # Project mascot image
```

## Entry Points
- **Setup**: `setup.sh` — Installs commands/agents to `~/.config/opencode/`
- **User Commands**: Each `commands/otto-*.md` file is a standalone command definition
- **Agents**: Each `agents/otto-*.md` file defines behavior for subagent spawning
- **Templates**: Starter files in `templates/` used by `/otto-init` to scaffold new projects

## Patterns & Conventions

### Command Design
- All command files use `.md` format with YAML frontmatter specifying description, agent type, and available tools
- Hyphenated naming (`/otto-init`) due to OpenCode's command syntax limitations
- Each command is executable as a standalone unit or spawns a subagent

### Artifact Structure
- **Minimal files**: 4 core files (config.json, PROJECT.md, CODEBASE.md, PLAN.md)
- **Flat phases directory**: Plans stored as `.otto/phases/{phase-id}/` with naming `{phase}-{plan}-PLAN.md`
- **Embedded unknowns**: Blocking questions live in PLAN.md frontmatter, not separate docs

### Plan Format
- YAML frontmatter: phase, plan, wave, depends_on, files_modified, autonomous flag
- Structured sections: `<objective>`, `<context>`, `<unknowns>`, `<tasks>`, `<verification>`
- Each task includes: name, files, action (specific steps), verify (command), done (acceptance criteria)
- Tasks sized for 15-60 minutes execution (not smaller, not larger)

### Learning Capture
- Micro-retros after each task (decisions, surprises, patterns)
- Phase retros when all plans in a phase complete
- Learnings stored in CODEBASE.md as discovered, not after-the-fact

### Naming Terminology
- **Phase**: Major milestone (e.g., "Setup", "Auth", "API")
- **Plan**: Small executable unit (30-60 min, 2-3 tasks)
- **Task**: Single focused action (15-60 min)
- **Wave**: Parallel execution order (Wave 1, 2, 3...)
- **Autonomous**: Plan ready to execute (no blocking unknowns)
- **Unknown**: Blocking question requiring research or user input

## Key Files
| File | Purpose |
|------|---------|
| commands/otto-init.md | Initializes .otto/ structure, discovers project intent, scans codebase |
| commands/otto-plan.md | Spawns planner agent to break phase into executable PLAN.md files |
| commands/otto-exec.md | Executes plan tasks in sequence, verifies, captures learnings |
| commands/otto-research.md | Deep investigation of blocking unknowns |
| commands/otto-progress.md | Show project work tree, status, and blockers |
| commands/otto-summarize.md | Full snapshot of codebase and execution history |
| agents/otto-planner.md | Subagent role: creates PLAN.md files with light research |
| agents/otto-researcher.md | Subagent role: investigates unknowns deeply |
| templates/PROJECT.md | Vision, goals, phases, constraints, decisions, blockers |
| templates/CODEBASE.md | Stack, structure, entry points, patterns, learnings table |
| templates/PLAN.md | Objective, context, unknowns, tasks, verification |

---

## Learnings

| Type | Detail | Outcome |
|------|--------|---------|
| Design | Simplified from gsd-oc (6+ files) to 4 core files to reduce ceremony | ✓ Easier onboarding and iteration |
| Design | Unknowns embedded in PLAN.md (not separate file) | ✓ Plans are self-contained, easier to execute |
| Design | Research merged into planning (light inline + optional deep dives) | ✓ Faster planning, unknowns surfaced early |
| Design | No custom OpenCode agents, use "general" with custom prompts | ✓ Simpler installation, no agent registration needed |
| Design | Verification built into task loop (not separate test phase) | ✓ Faster feedback, verification happens naturally |
| Design | Hyphenated command names (`/otto-init` not `/otto init`) | ✓ Works with OpenCode current limitations |
| Architecture | PROJECT.md is single source of truth for phases/decisions/blockers | ✓ No duplicate state across files |
| Architecture | CODEBASE.md accumulates learnings over time | ✓ Institutional knowledge grows naturally |
| Decision | Treat plans as prompts (specific enough to execute without questions) | ✓ Enables parallel execution, clear ownership |
| Convention | Task sizing: 15-60 min (smaller = combine, larger = split) | ✓ Right granularity for focused work |
| Convention | Specificity test: could a different person execute this without questions? | ✓ Plans are truly autonomous when marked |
| Pending | Investigate OpenCode support for space-separated namespaces | — Research blocker in TODO |
| Improvement (Feb 2026) | Init refactored: discovery-first + conditional questions | ✓ 50% fewer questions for existing codebases |
| Improvement | New subagent `otto-init` for codebase discovery with confidence scoring | ✓ Smarter detection, MEDIUM/HIGH probing strategy |
| Improvement | Question tool used for all user prompts (structured UI) | ✓ Consistent, navigable interactions |
| Improvement | Git integration for project name/age/activity inference | ✓ Better defaults without user input |
| Improvement | No auto-scaffolded Phase 1 PLAN.md; "What's next?" guidance instead | ✓ User agency preserved |
