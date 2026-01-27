# Otto Init Improvement Proposal

## Current State Analysis

### What Works Well
1. **Codebase detection** — Already scans for package managers and source directories
2. **Template system** — Has solid templates for PROJECT.md and CODEBASE.md
3. **Conversational flow** — Asks questions one or two at a time
4. **Output summary** — Clear completion message

### Key Problems

#### 1. **Redundant User Questions**
The init command asks 6 questions upfront before doing any investigation:
- "What's the name of this project?"
- "In one sentence, what will this project do?"
- "What are the primary goals?"
- "Any constraints?"
- "Anything out of scope?"
- "What's the first milestone?"

For **existing codebases**, many answers can be inferred:
- Project name from `package.json`, `pyproject.toml`, Git repo name
- Vision/description from README.md, package.json description
- Existing constraints from `package.json` or setup files
- Tech stack before asking about constraints

#### 2. **Deferred Investigation**
Steps flow as:
1. Ask all questions
2. THEN scan the codebase

This reverses logical priority. For established projects, **investigation should come first**, then ask only questions you couldn't answer via tools.

#### 3. **Lack of Smart Defaults**
Current init doesn't:
- Pre-populate phase name/description based on common first steps (setup, auth, core feature)
- Offer to auto-detect goals from issue trackers or commit history
- Suggest constraints based on tech stack choices
- Propose non-goals based on project scope

#### 4. **No Sub-Agent for Discovery**
The `/otto-discover` command exists but isn't used by init. It has sophisticated logic for:
- Finding entry points
- Identifying patterns and conventions
- Creating comprehensive CODEBASE.md

Init should delegate this work instead of re-implementing it inline.

#### 5. **Minimal Codebase Scan**
Current init only does basic detection:
- Manifest file reading
- Directory listing

It doesn't:
- Identify frameworks, major dependencies
- Find entry points, API routes, key patterns
- Document structure comprehensively

---

## Proposed Changes

### Phase 1: Leverage `/otto-discover` in Init

**Create a new subagent: `otto-init.md`** (separate from command)

This subagent should:
1. Run `/otto-discover` workflow to scan codebase thoroughly
2. Generate intelligent defaults for PROJECT.md
3. Return structured findings to orchestrator

**Command `/otto-init.md` logic:**
```
1. Check for existing .otto/ (stop if found)
2. Detect if codebase exists
3. If codebase exists:
   → Spawn otto-init subagent
   → Let it scan and generate CODEBASE.md
   → Extract auto-detected values (name, vision hints, stack)
4. Ask ONLY questions that couldn't be auto-answered
5. Merge detected values with user input
6. Create all files
```

### Phase 2: Intelligent Question Flow

**For existing codebases:**

| Question | Auto-Detect Source | Ask Only If |
|----------|-------------------|-------------|
| Project name | `package.json:name`, `Cargo.toml:[package]:name`, Git repo name, dir name | Ambiguous or generic |
| Vision | `package.json:description`, `README.md` first paragraph | Missing or too generic |
| Goals | Infer from README, issues, or .otto/PROJECT.md if exists | Not present in docs |
| Constraints | Infer from stack (Next.js → Node 18+, FastAPI → Python 3.9+) | Need clarification on choices |
| Non-goals | Suggest common ones (performance, scale, etc.) per stack | Confirm with user |
| First milestone | Suggest typical Phase 1 based on project type | User's preference differs |

**For greenfield projects:**

Ask all 6 questions, but:
- Offer templates/examples
- Suggest common first phases (Setup, Auth, Core Feature)
- Don't require all fields (allow "TBD")

### Phase 3: Better Discovery Output

Make `otto-init` subagent follow `/otto-discover` more closely:

**CODEBASE.md should include:**
- Complete Stack section (runtime, framework, db, key deps)
- Full Structure tree
- Identified Entry Points
- Patterns & Conventions (naming, organization, testing)
- Key Files table

**Auto-detected values to surface:**
```markdown
## Auto-Detected Information

**From your codebase:**
- **Runtime:** Node 20 (from .nvmrc)
- **Framework:** Next.js 14 (from package.json)
- **Key dependencies:** React 18, TypeScript, Prisma
- **Source structure:** Organized by feature in `/src/app/`
- **Tests:** Jest + React Testing Library
- **Naming:** camelCase functions, PascalCase components

**Suggested constraints:**
- Node 18+ (per Next.js docs)
- TypeScript strictness: enabled
- Database: PostgreSQL (inferred from Prisma)

**Suggested Phase 1 candidates:**
- Setup: Configure build, testing, CI/CD
- Auth: Implement user login/signup
- Core Feature: Build main feature
```

### Phase 4: Smarter Prompting

**Instead of:** "What are the primary goals?"

**Do:**
1. Scan README for goals/features section
2. Check for open issues labeled "epic" or "phase"
3. If found, ask: "I found these in your README. Did I get them right?"
4. If not found, ask: "Goals aren't documented yet. What are the top 3-4 outcomes you want?"

**Instead of:** "What's the first milestone?"

**Do:**
1. Suggest: "For a {project type} like yours, typical Phase 1 could be: {option A}, {option B}, or {option C}. Which resonates?"
2. If user picks one, offer to auto-populate description
3. If user says "something else", ask for specifics

---

## Implementation Strategy

### 1. Create `otto-init.md` Subagent
- Copy logic from `/otto-discover.md`
- Remove the final CODEBASE.md write step (command does that)
- Return structured JSON/markdown with findings
- Return detected defaults for PROJECT.md fields

**Scope: ~100 lines**

### 2. Refactor `/otto-init.md` Command
- Keep orchestration logic simple
- Call subagent early (before questions)
- Use detected values in question flow
- Make questions conditional on what wasn't auto-detected

**Scope: ~150 lines**

### 3. Update Templates
- No changes needed (templates remain generic)

### 4. Update COMPACTION.md
- Document new init flow
- Explain subagent delegation strategy

---

## Benefits

| Problem | Solution | Impact |
|---------|----------|--------|
| Redundant questions | Ask only unknowns | 50% fewer questions for existing codebases |
| User burden | Auto-detect + present | Users confirm smart defaults, don't rebuild knowledge |
| Incomplete CODEBASE.md | Delegate to discover agent | Better initial documentation |
| No intelligent defaults | Analyze project type | Faster Phase 1 planning |
| Deferred investigation | Investigate first | Smarter question flow |
| Code duplication | Reuse discover logic | Cleaner architecture |

---

## Questions for User

1. **Scope of auto-detection:** Should init suggest Phase 1 goals, or just detect existing docs?
   - Conservative: Only auto-detect what's explicitly documented
   - Aggressive: Suggest common Phase 1 patterns (Auth, API, Setup) for project type

2. **Handling ambiguous projects:** For a repo with no docs, no README, minimal package.json, what's the fallback?
   - Ask all 6 questions as-is?
   - Ask simplified 3-question version?
   - Ask 1 question (name) + suggest rest be filled in later?

3. **Presentation of discovered values:** How confident should init be when presenting auto-detected values?
   - Show them without asking (assume correct unless user corrects)
   - Ask user to confirm each one
   - Show in summary and ask "Does this look right?" once

4. **Git integration:** Should init use git to infer anything? (commit history, remote origin, branch patterns)
   - No — keep simple, file-based only
   - Yes — use git log to infer project age, activity level
   - Only for repo name/origin if file-based detection fails

5. **Phase 1 scaffolding:** Should init create a first placeholder PLAN.md, or defer to `/otto-plan 1`?
   - Create it based on detected project type (scaffolds faster)
   - Skip it, keep init lightweight
