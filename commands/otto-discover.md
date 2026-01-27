---
description: Map and summarize the existing codebase
agent: build
tools:
  - question
  - read
  - edit
  - grep
  - glob
  - list
  - bash
  - task
---

Map the repository into a concise, high-level overview with minimal context usage. Prefer discovery via tools and delegate deep dives to sub-agents when needed.

## Process

### 1. Establish the Repository Layout

Use `list` or `glob` to identify the top-level structure and locate likely entrypoints.

### 2. Read the Project Intent

Read README or documentation entrypoints to understand the project's purpose and scope.

### 3. Detect the Stack

Locate manifests or configuration to identify language, runtime, and tooling:
- `package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `Gemfile`, etc.

Capture frameworks, core dependencies, and build/test tooling.

### 4. Identify Entry Points

Locate runtime entrypoints and primary execution paths (main, app, server, index, routes).

Use `glob` for likely files, `grep` for hints like `main`, `app`, `server`, `router`, `config`.

### 5. Decide on Sub-Agent Deep Dives

If key areas require more exploration, spawn sub-agents using the Task tool. Give each agent a tightly scoped objective and request the reporting template below.

### 6. Apply Tooling Strategy

- Use `glob` to find key files.
- Use `grep` to locate architecture hints.
- Use `read` for targeted files only.
- Use `bash` only for non-file operations (git status/log, build/test info).
- Use `edit` to update `.otto/CODEBASE.md`; do not use `write`.

### 7. Sub-Agent Reporting Template

Every sub-agent must return:
- Scope: <what you were asked to inspect>
- Findings: <2–5 bullets>
- Key files: <paths>
- Unknowns: <what could not be inferred>
- Suggested user questions: <1–3 questions the main agent could ask>

### 8. Handle Unknowns

If you cannot infer something after searching/reading, ask the user via the `question` tool. Keep questions targeted and explain what would change based on each answer.

### 9. Write Output

Update `.otto/CODEBASE.md` using `edit` to match the template below. Merge and consolidate repetitive items.

The content MUST follow this template exactly:

```markdown
# Codebase: $PROJECT_NAME
> Last updated: $DATE
> Source: /otto init
## Stack
$STACK
## Structure
```
$STRUCTURE
```
## Entry Points
$ENTRY_POINTS
## Patterns & Conventions
$PATTERNS
## Key Files
| File | Purpose |
|------|---------|
$KEY_FILES
---
## Learnings
| Type | Detail | Outcome |
|------|--------|---------|
| Question | <asked question> | <answer or pending> |
| Discovery | <technical discovery or pattern> | <why it matters> |
```

- Consolidate repetitive or closely related questions/discoveries into a single row to keep the table concise.
- Keep entries succinct and focused on what matters for future work.

## Notes

- Do not use the `write` tool.
- Avoid loading large files into context; delegate deep dives.
- Default to read-only unless explicitly asked to modify code.
