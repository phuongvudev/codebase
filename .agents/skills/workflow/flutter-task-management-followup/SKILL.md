---
name: flutter-task-management-followup
description: Standardize post-implementation handoff by creating or updating PR, task, implementation comment, and delivery note in the project-defined task management system after every feature or bug fix.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Wed, 17 Jun 2026 00:00:00 GMT
---
# Post-Implementation Task Management Workflow

Use this workflow after completing any **feature** or **bug fix** to ensure delivery tracking is complete in the project-defined management system.

## Purpose

Keep engineering, QA, and product aligned by publishing four required artifacts:
1. Pull Request (PR)
2. Task update (issue/ticket/card)
3. Implementation comment
4. Delivery note

## Required Inputs

- Task identifier (issue key / card ID / ticket URL).
- Change scope (feature or bug fix).
- Validation evidence (tests, analyzer/lint output, manual checks).
- Risk and rollback notes.
- Deployment or release context (if needed by the project).

## Workflow

### Step 1 — Confirm completion state
- Verify acceptance criteria are met.
- Verify tests/checks are complete and recorded.
- Capture user impact and known limitations.

### Step 2 — Create or update PR
- Open a PR from the implementation branch.
- Reference the task identifier in the PR title/body.
- Include summary, test evidence, and risk notes.
- Request required reviewers according to project policy.

### Step 3 — Update task in management system
- Move task status to the project-defined review state.
- Link the PR in the task references.
- Attach validation evidence and scope summary.
- Ensure ownership and next-responsible role are correct.

### Step 4 — Post implementation comment
- Add a concise implementation comment in the task thread.
- Cover: what changed, why, and anything deferred.
- Mention reviewer focus areas and migration concerns (if any).

### Step 5 — Add delivery note
- Record a short delivery note in the project-defined location.
- Include release impact, compatibility notes, and rollback guidance.
- Tag QA/Product stakeholders if handoff is required.

### Step 6 — Final synchronization check
- Confirm PR, task, comment, and note all cross-reference each other.
- Confirm no artifact is missing before marking implementation complete.

## Completion Checklist

- [ ] PR created/updated and linked to task.
- [ ] Task status transitioned per project workflow.
- [ ] Implementation comment posted with technical summary.
- [ ] Delivery note added in project-defined note location.
- [ ] All links validated and handoff stakeholders notified.
