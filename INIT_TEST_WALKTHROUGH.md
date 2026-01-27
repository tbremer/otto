# Init Improvement Test Walkthrough

## Test Project: `/Users/tom/Projects/dot-dev`

A real, established Next.js project with git history.

---

## What the Discovery Subagent Would Find

### 1. Package Manifest Analysis

**File:** `package.json`

```json
{
  "name": "dotdev",
  "version": "0.0.0",
  "bin": "./cli.js",
  "scripts": {
    "dev": "next",
    "build": "next build",
    "start": "next start"
  },
  "dependencies": {
    "next": "16.0.10",
    "react": "19.2.3",
    "react-dom": "19.2.3",
    "pg": "8.16.3",
    "pg-format": "1.0.4",
    "jotai": "2.16.0",
    "valibot": "1.2.0",
    ...
  },
  "devDependencies": {
    "@biomejs/biome": "2.3.8",
    "tailwindcss": "4.1.18",
    "typescript": "5.9.3",
    ...
  }
}
```

**Extracted Values:**
- `name`: "dotdev" → HIGH confidence
- `description`: (missing) → Need user input
- `runtime`: Node (via Next.js) → HIGH confidence
- `framework`: Next.js 16.0.10 → HIGH confidence
- `database`: PostgreSQL (via pg) → HIGH confidence
- `styling`: Tailwind CSS 4.1.18 → HIGH confidence
- `state_management`: Jotai 2.16.0 → HIGH confidence
- `validation`: Valibot 1.2.0 → HIGH confidence
- `testing`: None detected (dev deps missing Jest/Vitest) → LOW confidence

### 2. README Analysis

**File:** `README.md`

```markdown
# Site.
```

**Result:**
- Generic title, no description
- No goals, features, or documentation
- **Confidence:** LOW (not useful for vision)

### 3. Git History Analysis

**Queries:**
```bash
git log --reverse --format=%aI | head -1  # First commit
# Output: 2020-08-22T15:54:13-05:00

git rev-list --count HEAD                  # Total commits
# Output: 247

git log -1 --format=%aI                    # Last commit
# Output: 2026-01-02T09:37:38-06:00

git config --get remote.origin.url         # Remote URL
# Output: git@github.com:tbremer/dot-dev.git
```

**Extracted Values:**
- `name`: "dot-dev" (from remote URL) → MEDIUM confidence (different from package.json)
- `created`: 2020-08-22 (5+ years old) → HIGH confidence
- `activity`: 247 commits, last activity Jan 2, 2026 → HIGH confidence
- `status`: Active, established project → HIGH confidence

### 4. Structure Analysis

**Directory Tree:**
```
dot-dev/
├── pages/                 (Next.js pages)
├── app/                   (Next.js app router - if used)
├── components/            (React components)
├── lib/                   (utilities)
├── public/                (static files)
├── styles/                (CSS/styling)
├── node_modules/
├── .next/                 (build output)
└── ...
```

**Detected:**
- **Source org:** By feature/route (Next.js pages structure)
- **Naming:** camelCase likely (typical Next.js)
- **Entry points:** `pages/index.js` or `app/page.tsx` (Next.js standard)
- **Tests:** No `__tests__` or `tests/` directory found → no test framework

### 5. Confidence Scoring Summary

| Finding | Source | Confidence | Action |
|---------|--------|-----------|--------|
| name: "dotdev" | package.json:name | HIGH | Show for confirmation |
| name: "dot-dev" | git remote | MEDIUM | Conflict flag |
| description | (missing) | N/A | Ask user |
| runtime: Node 16+ | Next.js + package.json | HIGH | Show in summary |
| framework: Next.js 16 | package.json:dependencies | HIGH | Show in summary |
| database: PostgreSQL | pg dependency | HIGH | Show in summary |
| styling: Tailwind | tailwindcss dependency | HIGH | Show in summary |
| created: 2020-08-22 | git first commit | HIGH | Show in summary |
| activity: 247 commits | git history | HIGH | Show in summary |
| goals: ??? | (not in docs) | N/A | Ask user |
| non-goals: ??? | (not in docs) | N/A | Skip (TBD) |
| first_milestone: ??? | (not decided) | N/A | Ask user |

---

## Discovery Report (What Subagent Returns)

```markdown
# Codebase Discovery Report

## Stack (Confidence: HIGH)
- **Runtime:** Node 16+ (from Next.js 16.0.10)
- **Framework:** Next.js 16.0.10 (from package.json)
- **Database:** PostgreSQL (via pg ORM)
- **Frontend:** React 19.2.3 + React DOM
- **Styling:** Tailwind CSS 4.1.18
- **State:** Jotai 2.16.0
- **Validation:** Valibot 1.2.0
- **CLI Tool:** Biome 2.3.8 (linting/formatting)
- **Package Manager:** pnpm 10.18.1

## Structure
```
dot-dev/
├── pages/              (Next.js routes)
├── components/         (React components)
├── lib/                (utilities, helpers)
├── public/             (static files)
├── styles/             (global styles)
├── node_modules/
└── build artifacts
```

## Entry Points
- **Main:** pages/index.js or app/page.tsx (Next.js root)
- **CLI:** cli.js (from package.json:bin)
- **API:** pages/api/ or app/api/ (if applicable)
- **Build:** pnpm build / pnpm dev

## Patterns & Conventions
- **Organization:** By Next.js routes (pages/routes directory)
- **Naming:** Likely camelCase (standard Next.js)
- **Framework:** Next.js 16 with React 19 (modern, latest versions)
- **Styling:** Tailwind CSS (utility-first approach)
- **Database:** PostgreSQL with pg driver (raw queries, not ORM)
- **Testing:** None detected (consider adding Jest/Vitest)

## Project Metadata
- **Name:** "dotdev" (package.json) vs "dot-dev" (git remote) — conflict!
- **Description:** Not documented (README empty)
- **Created:** 2020-08-22 (5+ years old, established project)
- **Activity:** 247 commits, last commit Jan 2, 2026 (active, regularly maintained)
- **Remote:** git@github.com:tbremer/dot-dev.git

## Suggested Defaults (HIGH Confidence Only)
```
name: dotdev (or dot-dev if corrected)
vision: (ask user — not documented)
runtime: Node 16+
framework: Next.js 16
database: PostgreSQL
styling: Tailwind CSS 4+
```

## Items Needing User Input
- **Project vision** (not in README or package.json description)
- **Primary goals** (not documented)
- **Non-goals** (not documented)
- **First milestone** (user's priority)
- **Name resolution** (dotdev vs dot-dev vs Site)
```

---

## Init Command Flow (Simulated)

### Step 1: Spawn Discovery Subagent

```
> /otto-init

📝 Scanning your codebase...
```

Discovery subagent runs. Takes 5-10 seconds to scan.

### Step 2: Present Discoveries & Ask for Confirmation

```
✅ Found an established Next.js project

Project Details (auto-detected):
  • Name: "dotdev" (from package.json)
  • Created: 2020-08-22 (5+ years old)
  • Status: Active (247 commits, last activity Jan 2)
  • Framework: Next.js 16, React 19, PostgreSQL
  • Styling: Tailwind CSS

⚠️  Note: Git remote shows "dot-dev" but package.json says "dotdev"

> Does "dotdev" look right as your project name?
  [A] Yes, use "dotdev"
  [B] Actually, use "dot-dev" (from GitHub)
  [C] Different name entirely
```

**User selects:** [B] "dot-dev"

### Step 3: Ask Goals

```
> What are your primary goals for this project?
  (I didn't find any documented in README or package.json)

  [A] Web application / site
  [B] CLI tool development
  [C] API backend
  [D] Dashboard or admin panel
  [E] Multiple — I'll explain
```

**User selects:** [E] "Multiple"

```
> Tell me your goals:
  (Enter goals, one per line or comma-separated)

my-input: Build a personal site and tools platform; provide domain lookup CLI
```

### Step 4: Ask for Constraints

```
I detected these from your tech stack:
  • Node 16+ (Next.js requirement)
  • TypeScript 5.9 (detected in devDeps)
  • PostgreSQL 14+ (recommended for pg driver)

> Any additional constraints or preferences?
  [A] No, what you found is complete
  [B] Yes, I have more constraints
```

**User selects:** [B]

```
> What additional constraints?
  (Enter them, one per line)

my-input: 
- Must support pnpm only (lock file committed)
- Tailwind as primary styling
```

### Step 5: Ask First Milestone

```
> What's your first milestone (Phase 1)?
  [A] Core site / homepage setup
  [B] User authentication
  [C] API development
  [D] Admin dashboard
  [E] CLI tools
  [F] Something else
```

**User selects:** [F]

```
> Describe your Phase 1:
  (What's the main focus to tackle first?)

my-input: Get basic site structure and domain lookup CLI working
```

### Step 6: Create Files

```
✅ Creating .otto/ structure...

.otto/config.json ✓
.otto/PROJECT.md ✓
.otto/CODEBASE.md ✓
.otto/phases/ ✓
```

### Step 7: Show Summary

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 OTTO ► INITIALIZED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Created:
  .otto/config.json
  .otto/PROJECT.md
  .otto/CODEBASE.md
  .otto/phases/

Project: dot-dev
Vision: A personal site and tools platform
Framework: Next.js 16, React 19, PostgreSQL
First Milestone: Phase 1 — Site & CLI Setup

Status: Ready for planning
```

### Step 8: What's Next?

```
> What would you like to do next?

  [A] Create Phase 1 execution plan
      I'll break "Site & CLI Setup" into executable tasks
      
  [B] Review project structure
      Walk through the CODEBASE.md I created
      
  [C] Skip for now
      I'll stop here. Use /otto-plan 1 when ready
```

**User selects:** [A]

```
(Continues to /otto-plan 1 flow...)
```

---

## Comparison: Before vs After

### BEFORE (6 Fixed Questions)

```
> What's the name of this project?
my-input: dot-dev

> In one sentence, what will this project do?
my-input: A personal site and tools platform

> What are the primary goals? (2-4 is plenty)
my-input: Web app for domains, CLI tools, admin dashboard

> Any constraints? (Tech stack, timeline, deployment, etc.)
my-input: Node 16+, TypeScript, PostgreSQL, pnpm, Tailwind

> Anything out of scope?
my-input: Performance optimization, multi-tenant features

> What's your first milestone?
my-input: Get site structure and CLI working

Total questions: 6
User effort: High (had to type everything)
```

### AFTER (3-4 Conditional Questions)

```
📝 Scanning...
✓ Project name: dot-dev (detected)
✓ Created: 2020-08-22 (detected)
✓ Framework: Next.js 16, React 19, PostgreSQL (detected)

> Project name look right? [Yes] [No] [Different]
my-input: [Yes]

> What are your goals?
my-input: Build personal site; provide domain lookup CLI; admin panel

> Any additional constraints?
my-input: [Yes] pnpm only, Tailwind primary

> First milestone?
my-input: Site structure and CLI setup

Total questions: 4
User effort: Low (mostly selections + minimal typing)
Benefit: 33% fewer questions + context shown upfront
```

---

## Key Findings from Test

✅ **Discovery subagent would find:**
- Project name (with name conflict detection)
- Framework stack (Next.js, React, PostgreSQL, Tailwind)
- Project age and activity level
- Entry points and structure
- Patterns and conventions

✅ **Init command would ask:**
- 1 confirmation (name)
- 3 new questions (goals, constraints, first milestone)
- Total: 4 questions vs 6 before (33% reduction)

✅ **User benefits:**
- Auto-detected context shown immediately
- Fewer assumptions to re-enter
- Smart defaults confirmed vs typed
- Clear next steps offered

⚠️ **Edge cases to handle:**
- Name conflicts (package.json vs git remote)
- Minimal README (not a blocker, just asks user)
- No testing framework found (noted for user awareness)
- Version conflicts (Next.js major version 16 is modern)

---

## Next Test Steps

To fully test on real projects:

1. **Set up symlinks** (`./setup.sh` in otto repo)
2. **Run on dot-dev** without .otto/
   ```bash
   /otto-init
   ```
3. **Observe:** Discovery scanning, question flow, files created
4. **Try on other projects:** Swift, Go, Python, Greenfield
5. **Validate output:** PROJECT.md and CODEBASE.md accuracy

This would be a good point to commit the implementation and iterate based on real usage.
