---
name: flutter-feature-workflow
description: General-purpose workflow template for implementing any Flutter feature or fixing any bug. Use this skill to structure your analysis, plan, estimation, acceptance criteria, inputs, advantages, and disadvantages before writing a single line of code.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Mon, 16 Jun 2026 00:00:00 GMT
---
# Feature & Bug Fix Workflow Template

This skill is a **reusable template** to be applied at the start of every feature implementation or bug fix. Fill in each section with the specifics of your task before proceeding to code.

## Contents
- [Resolving Problem](#resolving-problem)
- [Input](#input)
- [Plan](#plan)
- [Estimation](#estimation)
- [Acceptance Criteria](#acceptance-criteria)
- [Advantages](#advantages)
- [Disadvantages](#disadvantages)
- [Workflow](#workflow)

---

## Resolving Problem

> **Describe the problem this task solves.**  
> Answer: *What is broken or missing? Who is affected? What is the impact if left unresolved?*

**Template:**

| Question | Answer |
|---|---|
| What is the current behaviour / symptom? | _(describe the bug or missing capability)_ |
| What is the expected behaviour? | _(describe the desired outcome)_ |
| Who is affected? | _(users, other services, other features)_ |
| What is the impact if not fixed? | _(crashes, data loss, poor UX, blocked releases, etc.)_ |
| Root cause (if known)? | _(state machine gap, missing null-check, wrong API field, etc.)_ |

**For a bug fix, also answer:**
- Where was the bug introduced? (commit / PR / release)
- Is it reproducible deterministically or intermittently?
- Are there related issues or workarounds currently in place?

---

## Input

> **List every artefact, decision, or piece of information needed before development can start.**  
> Unresolved inputs are blockers — surface them in planning, not mid-sprint.

**Feature checklist:**
- [ ] Product requirement document (PRD) or user story is written and approved.
- [ ] UI/UX designs or wireframes are available (Figma link / attached screenshots).
- [ ] API contract is finalized (endpoint, request/response schema, error codes).
- [ ] Domain models and DTOs are identified.
- [ ] Feature flag or rollout strategy is agreed (full release vs. gradual rollout).
- [ ] Analytics events to track are listed (name + parameters).
- [ ] Localization strings are provided for every new user-visible text.
- [ ] Accessibility requirements are noted (semantic labels, contrast ratios).
- [ ] Dependency changes are approved (new packages, version bumps).
- [ ] Target platforms are confirmed (Android, iOS, Web, Desktop).

**Bug fix checklist:**
- [ ] Steps to reproduce are documented and verified.
- [ ] Device(s) / OS version(s) affected are listed.
- [ ] A failing test or reproduction script exists (or will be created as part of the fix).
- [ ] The correct layer to fix is confirmed (UI, BLoC, repository, data source).
- [ ] Regression risk is assessed (which other features could be affected).

---

## Plan

> **Break the task into small, ordered steps. Each step should be independently reviewable.**

### Phase 1 — Analysis & Setup
1. Reproduce the bug / understand the feature scope in the running app.
2. Identify all files and layers that need to change (Domain, Data, Presentation).
3. Confirm no breaking changes to shared contracts (interfaces, DTOs, BLoC events).

### Phase 2 — Domain Layer
4. Add or update entities / value objects if the data model changes.
5. Update or create the repository interface method signature.

### Phase 3 — Data Layer
6. Update the Retrofit client / DataSource for new or changed API calls.
7. Update the repository implementation.
8. Map new DTO fields to domain entities.

### Phase 4 — Business Logic (BLoC)
9. Add or update BLoC events and states.
10. Implement the event handler, using `handleOperation` for async work.
11. Handle edge cases: empty state, error state, loading cancellation.

### Phase 5 — Presentation Layer
12. Update or create the screen and widgets.
13. Connect the BLoC via `BlocProvider` / `BlocBuilder`.
14. Add or update localization strings.
15. Verify responsive layout on all target screen sizes.

### Phase 6 — Verification
16. Write or update unit tests (BLoC, repository).
17. Write or update widget tests for new UI paths.
18. Run the full test suite and fix regressions.
19. Manually verify on at least one Android and one iOS device/emulator.

---

## Estimation

> **Provide a time estimate per phase. Be conservative — add 20 % buffer for review cycles.**

| Phase | Task | Estimate |
|---|---|---|
| 1 | Analysis & setup | 0.5–1 h |
| 2 | Domain layer | 0.5–1 h |
| 3 | Data layer | 1–2 h |
| 4 | Business logic (BLoC) | 1–2 h |
| 5 | Presentation layer | 2–4 h |
| 6 | Tests + manual verification | 1–3 h |
| **Total** | **Simple bug fix** | **~2–4 h** |
| **Total** | **Medium feature** | **~6–10 h** |
| **Total** | **Large feature** | **~12–20 h** |

> Fill in the actual estimate for your specific task by replacing the ranges with concrete numbers.

---

## Acceptance Criteria

> **Define "done." Every criterion must be verifiable — use a checkbox.**  
> Write criteria from the user's or reviewer's perspective, not the implementer's.

**Generic criteria (apply to all tasks):**
- [ ] The feature works end-to-end on the happy path.
- [ ] All known error states are handled gracefully (error widget, retry option, or inline message).
- [ ] The loading state is shown while async operations are in progress.
- [ ] No existing tests are broken.
- [ ] New code is covered by at least one unit or widget test.
- [ ] No new lint warnings (`flutter analyze` passes with zero issues).
- [ ] UI matches the approved design at all breakpoints.
- [ ] All user-visible strings are localized.
- [ ] The change is documented in the PR description with before/after screenshots if UI changed.

**Bug-fix specific:**
- [ ] The original reproduction steps no longer trigger the bug.
- [ ] A regression test is added that would have caught the bug.

**Feature-specific:**
- [ ] Analytics events are dispatched at the correct moments.
- [ ] The feature can be toggled via a feature flag if required.
- [ ] Performance: no new jank frames (verified with Flutter DevTools).

---

## Advantages

> **Describe the positive impact of implementing this task correctly.**

| Advantage | Detail |
|---|---|
| User experience | Describe how users benefit (faster, fewer errors, new capability). |
| Code quality | Describe improvements to maintainability, testability, or architecture. |
| Team velocity | Describe how this unblocks or accelerates future work. |
| Business value | Describe revenue, retention, or compliance impact. |
| Technical debt reduction | Describe any legacy patterns removed or refactored. |

---

## Disadvantages

> **Be honest about trade-offs, costs, and risks introduced by this change.**

| Disadvantage | Mitigation |
|---|---|
| Increased complexity | _(e.g., new abstraction layer — mitigate with clear naming and documentation)_ |
| Risk of regression | _(e.g., shared component changed — mitigate with comprehensive widget tests)_ |
| Performance overhead | _(e.g., additional async step — mitigate with profiling and caching)_ |
| Scope creep potential | _(e.g., touching shared code — mitigate by strict PR scope boundaries)_ |
| Migration / breaking change | _(e.g., DTO field rename — mitigate with versioned API or feature flag)_ |

---

## Workflow

Use this checklist at the start of every feature or bug fix task:

- [ ] **Step 1 — Fill in [Resolving Problem](#resolving-problem).** Confirm root cause before touching code.
- [ ] **Step 2 — Verify all [Input](#input) items** are available. Raise blockers immediately.
- [ ] **Step 3 — Draft the [Plan](#plan)** with ordered, reviewable steps.
- [ ] **Step 4 — Set the [Estimation](#estimation)** and share with the team.
- [ ] **Step 5 — Write the [Acceptance Criteria](#acceptance-criteria)** before coding begins.
- [ ] **Step 6 — Evaluate [Advantages](#advantages) and [Disadvantages](#disadvantages)** for trade-off awareness.
- [ ] **Step 7 — Implement** following the plan phases (Domain → Data → BLoC → UI).
- [ ] **Step 8 — Verify** against every acceptance criterion.
- [ ] **Step 9 — Open PR** with before/after screenshots, test results, and filled-in template sections in the description.
