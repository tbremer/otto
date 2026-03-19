---
description: Describe what you want to build and Otto will create executable plans for it
tools:
  edit: true
  read: true
  glob: true
  grep: true
  question: true
  todowrite: true
---

<objective>
Take a user's description of what they want to build and produce executable PLAN.md files
ready for an executor agent. Handles everything: environment setup, context gathering,
codebase discovery, and plan generation.

Input: $ARGUMENTS — a short description of what to build (e.g. "user authentication with JWT")

If no arguments provided, use the question tool to ask the user interactively.
</objective>

<process>

## 1. Get Description

If $ARGUMENTS is empty, use the question tool to ask:
"What do you want to build? Describe the feature, system, or change."

Store the response as DESCRIPTION.

## 2. Initialize .otto

```bash
if [ ! -d ".otto" ]; then
  mkdir -p .otto/plans
  echo "# Otto Project State" > .otto/STATE.md
  echo "" >> .otto/STATE.md
  echo "## Plans" >> .otto/STATE.md
  echo "Created: $(date -u +%Y-%m-%dT%H:%M:%SZ)" >> .otto/STATE.md
fi
```

No error, no exit — just create it if it's missing and continue.

## 3. Gather Existing Context

Read whatever exists. Every file is optional — use empty string as fallback.

```bash
# Previous plans for continuity
PRIOR_PLANS=$(cat .otto/plans/*-PLAN.md 2>/dev/null || echo "")

# State file
STATE=$(cat .otto/STATE.md 2>/dev/null || echo "")

# Any context/notes the user has left
CONTEXT_MD=$(cat .otto/CONTEXT.md 2>/dev/null || echo "")

# Any prior research
RESEARCH_MD=$(cat .otto/RESEARCH.md 2>/dev/null || echo "")
```

## 4. Dynamic Codebase Discovery

Detect the stack and patterns by examining what's actually in the repo. Do NOT hardcode paths — adapt to what you find.

### 4a. Detect Language and Runtime

```bash
# Rust
CARGO_TOML=$(cat Cargo.toml 2>/dev/null || echo "")
RUST_FILES=$(find . -name "*.rs" -not -path "*/target/*" 2>/dev/null | head -5)

# Swift
PACKAGE_SWIFT=$(cat Package.swift 2>/dev/null || echo "")
XCODEPROJ=$(ls -d *.xcodeproj 2>/dev/null | head -1)
SWIFT_FILES=$(find . -name "*.swift" -not -path "*/.build/*" 2>/dev/null | head -5)

# JavaScript / TypeScript — check for runtime
PACKAGE_JSON=$(cat package.json 2>/dev/null || echo "")
BUN_LOCK=$(ls bun.lockb bun.lock 2>/dev/null | head -1)
PNPM_LOCK=$(ls pnpm-lock.yaml 2>/dev/null | head -1)
YARN_LOCK=$(ls yarn.lock 2>/dev/null | head -1)
NPM_LOCK=$(ls package-lock.json 2>/dev/null | head -1)
DENO_JSON=$(cat deno.json deno.jsonc 2>/dev/null || echo "")
TS_CONFIG=$(cat tsconfig.json 2>/dev/null || echo "")
JS_FILES=$(find . -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" 2>/dev/null | grep -v node_modules | grep -v .next | head -10)

# Python
PYPROJECT=$(cat pyproject.toml 2>/dev/null || echo "")
SETUP_PY=$(cat setup.py 2>/dev/null | head -20 || echo "")
REQUIREMENTS_TXT=$(cat requirements.txt 2>/dev/null || echo "")
PY_FILES=$(find . -name "*.py" -not -path "*/.venv/*" -not -path "*/__pycache__/*" 2>/dev/null | head -5)

# Go
GO_MOD=$(cat go.mod 2>/dev/null || echo "")
GO_FILES=$(find . -name "*.go" 2>/dev/null | head -5)

# Ruby
GEMFILE=$(cat Gemfile 2>/dev/null || echo "")

# Elixir
MIX_EXES=$(cat mix.exs 2>/dev/null || echo "")

# Java / Kotlin
BUILD_GRADLE=$(cat build.gradle build.gradle.kts 2>/dev/null | head -30 || echo "")
POM_XML=$(cat pom.xml 2>/dev/null | head -30 || echo "")
```

Build a STACK_SUMMARY from whatever was found. Example: "TypeScript project using Bun runtime, Next.js framework, Prisma ORM (detected from package.json and tsconfig.json)"

### 4b. Detect Project Structure

```bash
# Get directory layout (adapt to whatever exists)
TREE=$(find . -maxdepth 3 -type f \
  -not -path "*/node_modules/*" \
  -not -path "*/.git/*" \
  -not -path "*/target/*" \
  -not -path "*/.build/*" \
  -not -path "*/.next/*" \
  -not -path "*/__pycache__/*" \
  -not -path "*/.venv/*" \
  -not -path "*/dist/*" \
  -not -path "*/build/*" \
  2>/dev/null | head -60)
```

### 4c. Detect Code Patterns

Sample actual source files to understand conventions (naming, imports, error handling, structure):

```bash
# Find source files (language-agnostic)
SOURCE_FILES=$(find . -type f \( \
  -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" \
  -o -name "*.rs" -o -name "*.swift" -o -name "*.py" -o -name "*.go" \
  -o -name "*.rb" -o -name "*.ex" -o -name "*.kt" -o -name "*.java" \
  \) \
  -not -path "*/node_modules/*" \
  -not -path "*/.git/*" \
  -not -path "*/target/*" \
  -not -path "*/.build/*" \
  2>/dev/null | head -6)

PATTERNS=""
for f in $SOURCE_FILES; do
  PATTERNS="${PATTERNS}\n--- ${f} (first 40 lines) ---\n$(head -40 "$f")"
done
```

### 4d. Check for Context7 MCP Access

```bash
# Test if context7 tools are available by checking MCP config
HAS_CONTEXT7="false"
if grep -q "context7" opencode.json .opencode/opencode.json ~/.config/opencode/opencode.json 2>/dev/null; then
  HAS_CONTEXT7="true"
fi
```

Note the result — pass to the planner so it knows whether to use Context7 or fall back to WebFetch.

## 5. Calculate Plan Number

```bash
# Find highest existing plan number
LAST_PLAN=$(ls .otto/plans/*-PLAN.md 2>/dev/null | grep -oP '\d+(?=-PLAN\.md)' | sort -n | tail -1)
NEXT_PLAN_START=$(( ${LAST_PLAN:-0} + 1 ))

# Generate slug
SLUG=$(echo "$DESCRIPTION" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9 ]//g' | tr ' ' '-' | cut -c1-40)
```

## 6. Assemble Brief and Spawn @otto-planner

Construct the planning brief with everything gathered, then hand off:

```
@otto/planner

# Planning Brief

## What to Build
${DESCRIPTION}

## Plan Files
Write plans to: .otto/plans/{NN}-PLAN.md
Starting plan number: ${NEXT_PLAN_START} (zero-padded to 2 digits, e.g. 01, 02)

## Context7 MCP
Available: ${HAS_CONTEXT7}
If true, use mcp__context7__resolve_library_id and mcp__context7__get_library_docs for library documentation.
If false, use WebFetch against official docs instead.

## Prior Plans
${PRIOR_PLANS}

## Project State
${STATE}

## User Context / Decisions
${CONTEXT_MD}

## Prior Research
${RESEARCH_MD}

## Codebase Discovery

### Stack
${STACK_SUMMARY}

Package manifest:
${PACKAGE_JSON}${CARGO_TOML}${PACKAGE_SWIFT}${PYPROJECT}${GO_MOD}${DENO_JSON}

### Project Structure
${TREE}

### Code Patterns
${PATTERNS}

## Instructions
1. Derive a clear outcome-oriented goal from the description.
2. Apply goal-backward planning: truths → artifacts → key links → plans.
3. If user context/decisions exist, honor them as locked constraints.
4. Match codebase patterns from discovery — same conventions, libraries, structure.
5. Use Context7 or WebFetch for unfamiliar tech (don't research obvious patterns).
6. Write PLAN.md files to .otto/plans/
7. Self-verify before returning.
```

## 7. Handle Planner Response

### If `## PLANNING COMPLETE`:

Update .otto/STATE.md:
- Append entry with timestamp, description, plan count, wave count

Present results:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 OTTO ► PLANNED ✓
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

{Description} — {N} plan(s) in {M} wave(s)

[wave table from planner output]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

▶ Review: cat .otto/plans/*-PLAN.md
▶ Plan more: /otto-plan <next thing>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### If `## PLANNING BLOCKED`:

Extract the questions from the planner's response. Use the question tool to present them to the user. Once answered, re-assemble the brief with the new information included under "## User Context / Decisions" and spawn @otto-planner again.

This loop continues until planning succeeds. Each re-spawn is a fresh subagent call with the accumulated context.

</process>

<rules>
- Between 1 and 6 subagent calls per invocation. Typical path: 1 call. Blocked→retry adds more.
- Up to 10 WebFetch calls across all agents in the session for researching unfamiliar tech.
- Check for Context7 MCP availability and pass the result to the planner.
- If Context7 is available, prefer it over WebFetch for library/framework documentation.
- Never fail on missing files. Every context file is optional.
- If .otto doesn't exist, create it silently and continue.
- If no arguments provided, ask the user — don't error out.
- If planning is blocked, ask the user for the missing info and retry — don't give up.
- The output PLAN.md format is designed for executor agents to consume directly.
- STATE.md is updated exactly once per successful planning run, by the orchestrator.
</rules>
