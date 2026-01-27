---
description: Initialize Otto planning structure for a project
agent: build
tools:
  - question
  - read
  - write
  - edit
  - grep
  - glob
  - list
---

Initialize the `.otto/` directory with project configuration and documentation.
If an existing codebase is detected, scan it and document the stack/structure.

## Process

### 1. Check for Existing .otto/

First, check if `.otto/` already exists:

Use the `list` tool on `.otto/`.

**If exists:** 
Tell the user: "Otto is already initialized for this project. Use `/otto plan` to create plans, or delete `.otto/` to start fresh."
Stop here.

### 2. Detect Existing Codebase

Check for package managers and project indicators:

Use `glob` to check for common project markers:

- `package.json`
- `Cargo.toml`
- `go.mod`
- `pyproject.toml`
- `requirements.txt`
- `composer.json`
- `Gemfile`
- `pom.xml`
- `build.gradle`
- `mix.exs`
- `deno.json`

Also check for source directories:

Use `glob` / `list` to check for common source directories:

- `src/`, `app/`, `lib/`, `pages/`, `components/`, `cmd/`, `pkg/`, `internal/`

**If codebase detected:** Note that we'll scan it after the conversation.

### 3. Conversational Discovery

Ask the user these questions to understand the project. Ask them **one or two at a time**, conversationally — not as a form to fill out:

1. "What's the name of this project?"

2. "In one sentence, what will this project do when complete?"

3. "What are the primary goals? (2-4 is plenty)"

4. "Any constraints I should know about? (Tech stack preferences, timeline, deployment target, etc.) — or 'none' is fine"

5. "Anything explicitly out of scope? Non-goals help me avoid over-engineering."

6. "What's the first milestone you want to tackle? Give it a short name and describe what 'done' looks like."

Gather the answers naturally. Adjust follow-up questions based on what the user shares.

### 4. Scan Codebase (if detected)

If a codebase was detected in step 2, scan it now. Keep this medium-depth — enough to inform planning, not exhaustive.

**Detect stack:**
- Read package.json, Cargo.toml, go.mod, pyproject.toml, etc.
- Identify framework (Next.js, FastAPI, Rails, etc.)
- Note key dependencies

**Document structure:**
- List top-level directories and their purposes
- Identify entry points (main files, index files, route handlers)
- Note test directory location and testing framework

**Identify patterns:**
- Naming conventions (camelCase, snake_case, kebab-case)
- File organization (by feature, by type, hybrid)
- Any obvious conventions from existing code

### 5. Create .otto/ Structure

Create the directory and files:

Create `.otto/phases/` and required files using `write`/`edit`.

**Write `.otto/config.json`:**
```json
{
  "version": "1",
  "created_at": "{current ISO date}",
  "model_profile": "balanced"
}
```

**Write `.otto/PROJECT.md`** with the user's answers:

```markdown
# Project: {name}

## Vision
{one sentence from answer 2}

## Goals
- {goal 1}
- {goal 2}
- {etc}

## Constraints
{from answer 4, or "None specified"}

## Non-Goals
{from answer 5, or "None specified"}

---

## Phases

### Phase 1: {milestone name}
{milestone description}
- **Outcome**: {what "done" looks like}
- **Status**: planned

---

## Current State
- **Active Phase**: 1
- **Status**: planning

### Decisions
| Decision | Rationale | Phase |
|----------|-----------|-------|

### Blockers
None

---

## Notes
{Empty — will accumulate session context}
```

**Write `.otto/CODEBASE.md`:**

If codebase was scanned:
```markdown
# Codebase: {project name}

> Last updated: {date}
> Source: /otto init

## Stack
- **Runtime**: {Node 20, Python 3.12, etc.}
- **Framework**: {Next.js 14, FastAPI, etc.}
- **Database**: {if detected}
- **Key Dependencies**: {list 5-10 major ones}

## Structure
```
{folder tree of key directories, 2-3 levels deep}
```

## Entry Points
- **Main**: {path to main entry}
- **API**: {if applicable}
- **Tests**: {test directory}

## Patterns & Conventions
- {Naming: camelCase/snake_case/etc}
- {Organization: by feature/by type}
- {Testing: Jest/pytest/etc}
- {Other notable patterns}

## Key Files
| File | Purpose |
|------|---------|
| {path} | {description} |

---

## Learnings

{Empty — populated as phases complete}
```

If no codebase detected:
```markdown
# Codebase: {project name}

> Last updated: {date}
> Source: /otto init

No existing codebase detected. This file will be populated as the project develops.

---

## Learnings

{Empty — populated as phases complete}
```

### 6. Output Summary

After creating all files, display:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 OTTO ► INITIALIZED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Created:
  .otto/config.json
  .otto/PROJECT.md
  .otto/CODEBASE.md  {add "(scanned existing codebase)" if applicable}
  .otto/phases/

Project: {name}
Vision: {one-liner}
First milestone: Phase 1 — {name}

Next step: /otto plan 1
```

## Notes

- Keep the conversation natural, not robotic or form-like
- If user gives terse answers, that's fine — don't over-probe
- The codebase scan should be quick (30-60 seconds), not exhaustive
- Don't create `phases/01-*` directory yet — that's `/otto plan`'s job
- If user seems unsure about goals/constraints, help them think through it briefly, but don't force decisions
