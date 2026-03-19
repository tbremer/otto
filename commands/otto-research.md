---
description: Research a topic or map the existing codebase to inform planning
---

<objective>
Investigate before planning. Two modes in one command:

1. **Codebase mode** (`/research codebase`) — Analyze the existing codebase: stack, architecture, conventions, structure, concerns. Writes docs to `.otto/codebase/`.
2. **Topic mode** (`/research <topic>`) — Research how to build something: standard stack, patterns, pitfalls, code examples. Writes RESEARCH.md to a plan folder or `.otto/`.

Both modes spawn a single `@otto-researcher` subagent with the mode and context inlined.

If no arguments, ask the user what they want to research.
</objective>

<process>

## 1. Parse Mode

```bash
if [ -z "$ARGUMENTS" ]; then
  # No args — ask user
  # Use question tool: "What do you want to research?"
  # Options: "Map my codebase", "Research a topic for planning"
elif echo "$ARGUMENTS" | grep -qi "^codebase"; then
  MODE="codebase"
  TOPIC="codebase analysis"
else
  MODE="topic"
  TOPIC="$ARGUMENTS"
fi
```

## 2. Initialize .otto

```bash
if [ ! -d ".otto" ]; then
  mkdir -p .otto/plans
  echo "# Otto Project State" > .otto/STATE.md
  echo "Created: $(date -u +%Y-%m-%dT%H:%M:%SZ)" >> .otto/STATE.md
fi
```

## 3. Gather Context

Read whatever exists — everything optional:

```bash
STATE=$(cat .otto/STATE.md 2>/dev/null || echo "")
CONTEXT_MD=$(cat .otto/CONTEXT.md 2>/dev/null || echo "")

# For topic mode, check if a plan folder was specified (e.g. "/research auth-jwt for 02092026-auth-jwt")
# Otherwise research goes to .otto/RESEARCH.md
```

### For codebase mode, also gather:

```bash
# Check what already exists
EXISTING_CODEBASE=$(ls .otto/codebase/*.md 2>/dev/null)
```

If codebase docs already exist, inform user and ask: Update existing? View existing? Skip?

### For topic mode, also gather:

```bash
# Check for existing research
EXISTING_RESEARCH=$(cat .otto/RESEARCH.md 2>/dev/null || echo "")

# Quick stack detection for context (same as /plan does)
PACKAGE_JSON=$(cat package.json 2>/dev/null || echo "")
CARGO_TOML=$(cat Cargo.toml 2>/dev/null || echo "")
PACKAGE_SWIFT=$(cat Package.swift 2>/dev/null || echo "")
PYPROJECT=$(cat pyproject.toml 2>/dev/null || echo "")
GO_MOD=$(cat go.mod 2>/dev/null || echo "")
```

## 4. Check Context7 MCP Availability

```bash
HAS_CONTEXT7="false"
if grep -q "context7" opencode.json .opencode/opencode.json ~/.config/opencode/opencode.json 2>/dev/null; then
  HAS_CONTEXT7="true"
fi
```

## 5. Spawn @otto-researcher

### Codebase mode brief:

```
@otto-researcher

# Research Brief

## Mode
codebase

## Output Location
.otto/codebase/

## Context7 MCP
Available: ${HAS_CONTEXT7}

## Project State
${STATE}

## User Context
${CONTEXT_MD}

## Instructions
Analyze the codebase thoroughly. Write documents directly to .otto/codebase/:
- STACK.md — Languages, runtime, frameworks, key dependencies, platform
- ARCHITECTURE.md — Pattern overview, layers, data flow, entry points, error handling
- STRUCTURE.md — Directory tree, file purposes, naming conventions, where to add new code
- CONVENTIONS.md — Naming, style, imports, error handling, function/module patterns
- CONCERNS.md — Tech debt, bugs, security, performance, fragile areas, test gaps

Each document must include actual file paths in backticks.
Be prescriptive ("Use X pattern") not descriptive ("X pattern is used").
Write current state only — no temporal language.

Return confirmation only, not document contents.
```

### Topic mode brief:

```
@otto-researcher

# Research Brief

## Mode
topic

## Topic
${TOPIC}

## Output Location
.otto/RESEARCH.md

## Context7 MCP
Available: ${HAS_CONTEXT7}

## Project State
${STATE}

## User Context / Decisions
${CONTEXT_MD}

## Current Stack
${PACKAGE_JSON}${CARGO_TOML}${PACKAGE_SWIFT}${PYPROJECT}${GO_MOD}

## Existing Research
${EXISTING_RESEARCH}

## Instructions
Research how to implement "${TOPIC}" well.

The question is NOT "which library should I use?"
The question is: "What do I not know that I don't know?"

Discover:
- What's the established architecture pattern?
- What libraries form the standard stack?
- What problems do people commonly hit?
- What's current SOTA vs what training data thinks is SOTA?
- What should NOT be hand-rolled?

Write RESEARCH.md with sections the planner expects:
- User Constraints (from CONTEXT.md if exists — copy verbatim)
- Summary (executive overview)
- Standard Stack (with versions)
- Architecture Patterns (with code examples)
- Don't Hand-Roll (table of problems with existing solutions)
- Common Pitfalls (with warning signs)
- Code Examples (from authoritative sources)
- Sources (with confidence levels)

Be prescriptive: "Use X" not "Consider X or Y."
```

## 6. Handle Response

### `## RESEARCH COMPLETE`:

Update `.otto/STATE.md` with research activity timestamp.

Present:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 OTTO ► RESEARCHED ✓
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

{Mode}: {Topic/Codebase}
Confidence: {level}
{Brief summary from researcher}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

▶ Review: cat .otto/{output path}
▶ Plan: /plan <description>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### `## RESEARCH BLOCKED`:

Extract questions. Use the question tool to present them. Re-spawn with new context.

</process>

<rules>
- 1 subagent call for most research. Blocked→retry may add 1 more.
- Up to 10 WebFetch calls within the researcher for official docs.
- Context7 preferred over WebFetch when available.
- Never fail on missing files. Everything optional.
- If .otto doesn't exist, create it silently.
- Codebase mode writes multiple docs to .otto/codebase/. Topic mode writes one RESEARCH.md.
- The researcher writes files directly — don't transfer document contents back through the orchestrator.
- Do NOT commit research files. The user decides when to commit.
</rules>
