# Otto Init Implementation Plan

## User Decisions (Confirmed)

✅ **Auto-detection scope:** Only documented info (no inferential suggestions)
✅ **Minimal repo strategy:** Simplified 3-question version
✅ **Confidence level:** Show only high-confidence values; probe user to gain confidence
✅ **Git integration:** Use git history if available as additional inference source
✅ **Phase 1 scaffolding:** Don't create PLAN.md; use Question tool to ask what's next
✅ **Tool preference:** Always prefer Question tool when possible

---

## Architecture Overview

### New/Modified Files

```
otto/
├── agents/
│   ├── otto-init.md                    (NEW: Subagent for codebase discovery)
│   └── otto-researcher.md              (unchanged)
├── commands/
│   ├── otto-init.md                    (REFACTORED: Orchestrator + conditional questions)
│   └── otto-discover.md                (unchanged, but otto-init subagent will reuse patterns)
├── templates/
│   └── ... (unchanged)
└── INIT_IMPLEMENTATION_PLAN.md        (THIS FILE)
```

---

## Implementation: Phase 1 — Create `agents/otto-init.md` Subagent

**Purpose:** Scan codebase and return structured discovery data

**Input:** (implicit — current working directory)

**Output:** Markdown report with sections:
- Discovered Stack (runtime, framework, db, key deps)
- Discovered Structure
- Discovered Entry Points
- Discovered Patterns
- Confidence levels for each finding
- Suggested defaults for PROJECT.md fields
- High-confidence inferences only

**Tools:** `read`, `glob`, `grep`, `bash` (git only)

**Scope:** ~120 lines

### Key Logic

```
1. Check for package manifests
   ├─ Read package.json / Cargo.toml / go.mod / pyproject.toml / etc.
   └─ Extract: runtime, framework, key deps, name, description

2. Check for README / docs
   ├─ Read README.md (first paragraph)
   ├─ Look for "## Goals" or "## Features" section
   └─ Extract: vision hints, documented goals

3. Scan source structure
   ├─ List top-level directories
   ├─ Identify entry points (index.js, main.py, app.rs, etc.)
   ├─ Detect testing framework and test directory
   └─ Document patterns (naming, organization)

4. Git history (if repo exists)
   ├─ Get repo name from remote URL (fallback to dir name)
   ├─ Get creation date (first commit)
   ├─ Count commits (activity level indicator)
   └─ Extract: project age, activity status

5. Generate confidence scores
   ├─ For each discovered value, assign confidence: HIGH / MEDIUM / LOW
   ├─ HIGH: Explicit in manifest or docs
   ├─ MEDIUM: Inferred from patterns + git
   ├─ LOW: Best guess, needs user confirmation

6. Return structured report
   └─ Only include HIGH-confidence values in defaults
   └─ Flag MEDIUM for user verification
   └─ Omit LOW entirely (ask user instead)
```

### Output Format

```markdown
# Codebase Discovery Report

## Stack (HIGH confidence)
- **Runtime:** Node 20 (from .nvmrc and package.json engines)
- **Framework:** Next.js 14.1.0
- **Database:** PostgreSQL (via Prisma in package.json)
- **Key Dependencies:** React 18, TypeScript 5.3, Prisma ORM

## Structure
```
src/
├── app/          (Next.js pages/routes)
├── components/   (React components)
├── lib/          (utilities)
├── types/        (TypeScript definitions)
└── tests/        (Jest tests)
```

## Entry Points
- **Main:** src/app/page.tsx (Next.js root page)
- **API:** src/app/api/ (API routes)
- **Tests:** npm test (Jest with React Testing Library)

## Patterns & Conventions
- **Organization:** By feature (routes group related files)
- **Naming:** camelCase functions, PascalCase React components
- **Testing:** Jest + React Testing Library, test files co-located

## Project Metadata
- **Name:** "my-app" (from package.json)
- **Description:** "A modern web application" (from package.json)
- **Created:** 2024-01-15 (from git first commit)
- **Activity:** 127 commits, last 5 days ago (active project)

## Suggested Defaults (HIGH confidence only)
- Project name: my-app
- Vision: "A modern web application"
- Constraints: Node 20+, TypeScript
- Phase 1 suggestion: Consider "Auth" or "Core API" based on existing structure

## Items Needing User Input
- Goals (not documented in README)
- Non-goals (not documented)
- Specific first milestone (needs user direction)
```

---

## Implementation: Phase 2 — Refactor `commands/otto-init.md`

**Purpose:** Orchestrate init flow with conditional questions

**Logic Flow:**

```
┌─ Check for existing .otto/
│  └─ Stop if found
│
├─ Detect codebase (glob for manifests)
│  ├─ If exists:
│  │  └─ Spawn otto-init subagent (discovery)
│  │  └─ Parse findings
│  └─ If not:
│     └─ Mark as greenfield
│
├─ Conversational Discovery
│  └─ If codebase detected:
│     ├─ Present auto-detected name + vision (HIGH confidence only)
│     ├─ Ask: "Does this look right?" (use question tool)
│     ├─ If user modifies:
│     │  └─ Use user's version
│     ├─ Ask: "What are your goals?" (goals not in docs)
│     ├─ Ask: "Any constraints I should know?" (verify inferred ones)
│     ├─ Ask: "What's your first milestone?" (use question tool)
│     └─ (Skip non-goals for existing codebases—assume "TBD")
│  └─ If greenfield:
│     ├─ Ask: "Project name?"
│     ├─ Ask: "One-liner vision?"
│     └─ Ask: "First milestone?"
│
├─ Merge Data
│  └─ Combine discovered values + user answers
│  └─ Use user input to override detected values
│
└─ Create Files
   ├─ Write .otto/config.json
   ├─ Write .otto/PROJECT.md (with merged data)
   ├─ Write .otto/CODEBASE.md (from discovery output)
   └─ Show summary
   └─ Use question tool: "What would you like to do next?"
```

### Key Changes from Current Init

| Current | New |
|---------|-----|
| Always ask 6 questions | Ask 3-6 conditional questions |
| Ask questions first | Investigate first (if codebase detected) |
| Ask "name" always | Present detected name, ask for confirmation |
| Ask "vision" always | Present detected vision, ask for confirmation |
| Ask "goals" always | Ask only if not in docs/README |
| Ask "constraints" always | Confirm inferred constraints + ask for additions |
| Skip "non-goals" for existing | Skip entirely (TBD) |
| Manual CODEBASE scan | Use subagent discovery |
| Ask 6 questions for bare repos | Ask simplified 3 questions (name, vision, milestone) |
| No next steps prompt | Use question tool: "What's next?" |

### Conversational Examples

**Example 1: Established Next.js project**

```
📝 Scanning your codebase...

Found a Next.js 14 project. Let me gather some details...

✓ Project name: my-app
✓ Vision: A modern web application  
✓ Tech stack: Node 20, TypeScript, Prisma
✓ Tests: Jest + RTL
✓ Last activity: 5 days ago (127 commits)

I didn't find documented goals or non-goals. Let me ask you a few things:

> What are your primary goals for this project? (2-4 is plenty)
```

**Example 2: Bare repo (no docs, minimal package.json)**

```
📝 Scanning your codebase...

Found a Node.js project with minimal documentation.

I need just a few details to get started:

> What's the name of this project?
```

**Example 3: After questions answered**

```
Great! Here's what I captured:

📦 Project: my-app
🎯 Vision: A modern web application
🚀 Goals:
   - User authentication
   - Real-time notifications
   - Admin dashboard

✅ Otto initialized!

Next steps:
> What would you like to do next?
  [A] Create Phase 1 execution plan
  [B] Explore the codebase more
  [C] Review project structure
  [D] Something else
```

---

## Implementation: Phase 3 — Update Question Tool Usage

**Principle:** Prefer `question` tool for all user prompts (not `read` + conversational text)

**Locations:**
1. Project name confirmation (if detected)
2. Vision confirmation (if detected)
3. Goals inquiry (always, if not documented)
4. Constraints confirmation (if inferred)
5. First milestone inquiry
6. "What's next?" prompt after completion

**Benefits:**
- Consistent UI
- User sees all options upfront
- Easy to navigate with arrow keys
- Clear structured choices

**Example Question Structure:**

```yaml
- question: "Does your project name look right?"
  header: "Project Name"
  options:
    - label: "Yes, my-app"
      description: "Matches package.json"
    - label: "No, different name"
      description: "I'll provide a new one"

- question: "What are your primary goals?"
  header: "Project Goals"
  options:
    - label: "User authentication"
    - label: "Real-time notifications"
    - label: "Admin dashboard"
    - label: "Other goals"
  multiple: true
```

---

## Implementation: Phase 4 — High Confidence Detection Logic

**HIGH Confidence Sources** (show to user for confirmation):
- Project name from `package.json:name` or `Cargo.toml:[package]:name`
- Vision from `package.json:description` (if 50-200 chars)
- Vision from README.md first paragraph
- Runtime from `.nvmrc`, `engine.node`, `Cargo.toml`
- Framework from `package.json` (Next.js, FastAPI, etc.)
- Database from `Prisma:datasource`, `requirements.txt`, etc.
- Entry points from manifest + directory scanning
- Git metadata (name, creation date, activity level)

**MEDIUM Confidence** (ask user to verify):
- Vision from README if generic ("A web application")
- Inferred constraints from stack choices
- Project type classification (e.g., "frontend", "backend", "fullstack")

**LOW Confidence** (skip, ask user directly):
- Specific project goals (needs domain knowledge)
- Non-goals or scope exclusions
- First milestone direction (business decision)

**Confidence Algorithm:**
```
Score each discovery:
- If value from manifest or README: HIGH
- If value from git + pattern analysis: MEDIUM  
- If value requires interpretation: LOW
- Always probe if MEDIUM or LOW
```

---

## Implementation: Phase 5 — Git Integration

**If `.git/` exists, extract:**

1. **Project name**
   ```bash
   git config --get remote.origin.url | sed 's/.*\///' | sed 's/\.git$//'
   ```

2. **Creation date**
   ```bash
   git log --reverse --format=%aI | head -1
   ```

3. **Activity level**
   ```bash
   git rev-list --count HEAD  # total commits
   git log -1 --format=%aI    # last commit date
   ```

4. **Branch info** (optional, for context)
   ```bash
   git rev-parse --abbrev-ref HEAD  # current branch
   ```

**Use cases:**
- Confirm project name if package.json name is generic
- Infer project age and activity
- Decide "established" vs "greenfield" for question strategy
- Add context to CODEBASE.md (project age, commit history)

---

## Implementation: Phase 6 — Question Tool at End (What's Next?)

**After successful init:**

```
✅ Otto initialized! Here's what I set up:

.otto/config.json
.otto/PROJECT.md
.otto/CODEBASE.md
.otto/phases/

Project: my-app
Vision: A modern web application
First milestone: Phase 1 — Auth Setup

> What would you like to do next?
```

**Question options:**
```
[A] Create Phase 1 execution plan
    └─ I'll break down auth setup into executable tasks

[B] Review project structure
    └─ Let me walk you through CODEBASE.md

[C] Explore unknowns
    └─ Any blockers or open questions about the project?

[D] Skip for now
    └─ I'll stop here. Use /otto-plan 1 when ready
```

**Conditional logic:**
- If user selects [A]: Fire `/otto-plan 1` command
- If user selects [B]: Show CODEBASE.md summary
- If user selects [C]: Ask deeper questions about project scope
- If user selects [D]: End init, provide next-step guidance

---

## Files to Create/Modify

### CREATE: `agents/otto-init.md`

- ~120 lines
- Discovery subagent
- Outputs structured findings (HIGH confidence only)
- Used by init command

### MODIFY: `commands/otto-init.md`

- ~180 lines (currently ~240)
- Orchestrator logic (simplified)
- Conditional questions based on discoveries
- Heavy use of `question` tool
- Delegates discovery to subagent

### UPDATE: `.otto/CODEBASE.md` (in otto repo)

- Document new init flow
- Explain subagent architecture
- Note confidence-based probing strategy

---

## Success Criteria

- ✅ Existing codebases: 50% fewer questions (3-4 instead of 6)
- ✅ Auto-detected values shown with sources
- ✅ User probed until HIGH confidence
- ✅ Git history used for name/date/activity inference
- ✅ No Phase 1 PLAN.md auto-created
- ✅ Question tool used for all user prompts
- ✅ Bare repos: simplified 3-question flow
- ✅ End-of-init prompt: "What's next?" with guided options
- ✅ Better CODEBASE.md from discovery subagent

---

## Implementation Order

1. **Create `agents/otto-init.md`** (discovery subagent)
   - Reuse discover patterns
   - Add confidence scoring
   - Add git integration
   - Return structured findings

2. **Refactor `commands/otto-init.md`** (orchestrator)
   - Add conditional question logic
   - Integrate Question tool
   - Call subagent early
   - Add end-of-init guidance

3. **Test on real projects** (if applicable)
   - Established codebase (Next.js, Python, Go, etc.)
   - Bare repo
   - Greenfield project

4. **Update COMPACTION.md** with new flow

---

## Future Enhancements

- [ ] Store confidence scores in PROJECT.md (hidden field for debugging)
- [ ] Add `/otto-reinit` command to update CODEBASE.md without changing PROJECT.md
- [ ] Add optional deep-dive discovery (ask user if they want exhaustive scan)
- [ ] Cache discovery results (avoid re-scanning on subsequent runs)
- [ ] Auto-suggest Phase 1 name based on project type (e.g., "Setup", "Auth", "Core API")
