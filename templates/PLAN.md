---
phase: $PHASE_ID
plan: $PLAN_NUMBER
wave: $WAVE
depends_on: []
files_modified: []
autonomous: true
---

<objective>
$OBJECTIVE

**Purpose**: $PURPOSE
**Output**: $OUTPUT
</objective>

<context>
@.otto/PROJECT.md
@.otto/CODEBASE.md
$ADDITIONAL_CONTEXT
</context>

<unknowns>
<!-- Unresolved questions blocking clean execution -->
<!-- /otto-research will resolve these, or user can answer inline -->
</unknowns>

<tasks>

<task type="auto">
  <name>$TASK_NAME</name>
  <files>$FILE_PATHS</files>
  <action>$SPECIFIC_IMPLEMENTATION</action>
  <verify>$VERIFICATION_COMMAND</verify>
  <done>$ACCEPTANCE_CRITERIA</done>
</task>

</tasks>

<verification>
- [ ] $VERIFICATION_ITEM
</verification>
