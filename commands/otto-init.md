---
description: Initialize Otto planning structure for a project
agent: build
tools:
  - question
  - read
  - write
  - edit
  - glob
  - bash
  - task
---

Initialize the `.otto/` directory with project configuration and documentation.

For existing codebases, run discovery first to auto-detect values, then ask only questions you couldn't answer. For greenfield projects, ask simplified questions.

## Process Overview

```
1. Check for existing .otto/ → stop if found
2. Detect codebase type → glob for manifests
3. If codebase found:
   └─ Spawn otto-init discovery subagent
   └─ Parse high-confidence findings
   └─ Ask conditional questions (verify/clarify detected values)
4. If greenfield:
   └─ Ask simplified 3-question flow
5. Create .otto/ files (merged user input + detected values)
6. Show summary + "What's next?" prompt
```

## Step 1: Check for Existing .otto/

Use `glob` to check if `.otto/PROJECT.md` exists.

**If exists:**
```
Otto is already initialized for this project.
Use `/otto plan 1` to create plans, or delete `.otto/` to start fresh.
```
Stop here.

## Step 2: Detect Codebase

Use `glob` to check for package manifests:
- `package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`, `requirements.txt`
- `composer.json`, `Gemfile`, `pom.xml`, `build.gradle`, `mix.exs`, `deno.json`

**Classify:**
- **If manifest found:** Existing codebase — proceed to Step 3
- **If no manifest:** Greenfield project — proceed to Step 4

## Step 3: Existing Codebase Discovery (if applicable)

Spawn `otto-init` subagent using the `task` tool:

```
/task:
  description: "Scan codebase and return discovery findings"
  subagent_type: "general"
  prompt: """
Follow the otto-init discovery subagent role.
Scan the current project and return a structured discovery report.
Output markdown with: Stack, Structure, Entry Points, Patterns, Project Metadata, Suggested Defaults, Items Needing User Input.
Only include HIGH-confidence findings in suggested defaults.
"""
```

Parse the report from subagent:
- Extract `name`, `vision`, `constraints` (HIGH-confidence defaults)
- Note any MEDIUM-confidence items flagged for verification
- Identify items needing user input

### Step 3a: Confirm Auto-Detected Values (if HIGH confidence found)

Use `question` tool to show discovered values:

```
question: "I found these details about your project. Do they look right?"
header: "Project Discovery"
options:
  - label: "Yes, that's correct"
    description: "Name: {name}, Vision: {vision}"
  - label: "No, let me correct them"
    description: "I'll ask you to confirm/update"
```

**If user selects "Yes":**
- Use detected values for name and vision
- Skip to Step 3b (ask remaining questions)

**If user selects "No":**
- Use `question` tool to ask for corrections:
  ```
  question: "What's the correct project name?"
  header: "Project Name"
  options:
    - label: "{detected_name} (detected)"
    - label: "Different name"
  ```
- Gather corrected values
- Proceed to Step 3b

### Step 3b: Ask Remaining Questions (conditional)

**Always ask:** "What are your primary goals?" (goals not documented in code)

```
question: "What are your primary goals for this project?"
header: "Project Goals"
options:
  - label: {goal_1}
  - label: {goal_2}
  - label: {goal_3}
  - label: "I'll add goals later"
multiple: true
```

**If constraints detected from stack:** Ask for confirmation

```
question: "Any additional constraints beyond what I detected?"
header: "Constraints"
options:
  - label: "No, what you found is complete"
    description: "{detected_constraints}"
  - label: "Yes, I have more to add"
```

**Always ask:** "What's your first milestone?"

```
question: "What's your first milestone (Phase 1)?"
header: "First Milestone"
options:
  - label: "Auth & User Management"
  - label: "Core API Setup"
  - label: "Admin Dashboard"
  - label: "Something else"
```

If "Something else": 
```
question: "Describe your first milestone"
header: "Custom Phase 1"
options:
  - label: {user_input}
```

**Skip:** Non-goals (assume TBD for established projects)

### Step 3c: Merge Data

Combine discovered values with user answers:
```
name = user_corrected_name || discovered_name
vision = user_corrected_vision || discovered_vision
goals = user_goals || [none documented]
constraints = user_constraints || detected_constraints
milestone = user_milestone || [undecided]
```

## Step 4: Greenfield Project Flow (if no codebase)

Ask simplified 3-question flow:

**Q1: Project Name**
```
question: "What's the name of this project?"
header: "Project Name"
options:
  - label: {user_input}
```

**Q2: Vision**
```
question: "In one sentence, what will this project do?"
header: "Project Vision"
options:
  - label: {user_input}
```

**Q3: First Milestone**
```
question: "What's your first milestone?"
header: "First Milestone"
options:
  - label: "Authentication & Users"
  - label: "Core API"
  - label: "Frontend UI"
  - label: "Something else"
```

Then ask: "What are your primary goals?" (same as Step 3b)

## Step 5: Create .otto/ Files

### Create .otto/config.json

```json
{
  "version": "1",
  "created_at": "{ISO date now}",
  "model_profile": "balanced"
}
```

### Create .otto/PROJECT.md

```markdown
# Project: {name}

## Vision
{vision}

## Goals
{if goals provided}
- {goal 1}
- {goal 2}
{else}
(Goals to be defined)
{/if}

## Constraints
{if constraints provided}
- {constraint 1}
- {constraint 2}
{else}
None specified
{/if}

## Non-Goals
(TBD)

---

## Phases

### Phase 1: {milestone_name}
{milestone_description}
- **Outcome**: Define what "done" looks like
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

### Create .otto/CODEBASE.md

**If existing codebase:** Use discovery report directly (refine format if needed)

**If greenfield:** 
```markdown
# Codebase: {project_name}

> Last updated: {date}
> Source: /otto init

No existing codebase detected. This file will be populated as the project develops.

---

## Learnings

{Empty — populated as phases complete}
```

### Create .otto/phases/ directory

Just create empty directory (plans added by `/otto-plan`)

## Step 6: Completion Summary

Display success message:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 OTTO ► INITIALIZED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Created:
  .otto/config.json
  .otto/PROJECT.md
  .otto/CODEBASE.md
  .otto/phases/

Project: {name}
Vision: {vision}
First milestone: Phase 1 — {milestone_name}

Status: Ready for planning
```

Then ask "What's next?" using `question` tool:

```
question: "What would you like to do next?"
header: "Next Steps"
options:
  - label: "Create Phase 1 execution plan"
    description: "I'll break {milestone_name} into executable tasks"
  - label: "Review project structure"
    description: "Walk through CODEBASE.md"
  - label: "Skip for now"
    description: "I'll stop here. Use /otto-plan 1 when ready"
```

**Conditional behavior:**
- If "Create Phase 1": Offer to run `/otto-plan 1`
- If "Review structure": Show key sections from CODEBASE.md
- If "Skip": Done — provide next-step guidance

## Implementation Notes

- Use `task` tool to spawn otto-init subagent (don't inline discovery logic)
- Use `question` tool for ALL user prompts (not conversational text)
- Show confidence levels where values came from ("from package.json", "from git", "inferred from tech stack")
- Keep conversation brief; user answers drive the flow
- Don't modify code files; only create .otto/ artifacts
- For existing codebases: aim for 3-4 total questions (vs 6 before)
- For greenfield: 3 initial questions, then 1-2 more if applicable
