---
name: ios-test-runner
description: Build and run WhereWeGo iOS tests, report pass/fail results. Use on main agent for smoke tests after simple changes. Escalate to tester subagent for full coverage analysis, diagnosing complex failures, or writing new tests.
---

# iOS Test Runner

## Overview

Smoke build and test runner for the main agent. Run after simple bug fixes or minor changes to verify nothing broke — without spawning a full tester subagent.

**Announce at start:** "Using ios-test-runner skill to verify the build."

**Use this skill when:**
- Verifying a simple bug fix compiles and passes tests
- Smoke-testing before creating a PR
- Quick build check after dependency update

**Escalate to `tester` subagent when:**
- Diagnosing a complex or intermittent test failure
- Investigating code coverage gaps
- Writing new tests for a feature
- Full regression test suite analysis

---

## Commands

```bash
# Install tool versions (run once per session if needed)
mise install

# Resolve SPM dependencies
mise x -- tuist install

# Build only (fast smoke check)
mise x -- tuist build

# Run full test suite
mise x -- tuist test
```

**ALWAYS prefix tuist commands with `mise x --`**

---

## Workflow

### 1. Build first
```bash
mise x -- tuist build
```
- If build fails → fix compilation errors before running tests
- Build success → proceed to tests

### 2. Run tests
```bash
mise x -- tuist test
```

### 3. Interpret results

| Output | Meaning |
|--------|---------|
| `Test Suite ... passed` | All good |
| `Test Suite ... failed` | Check which tests failed |
| `error: build failed` | Compilation error — fix before testing |
| Timeout / no output | Simulator issue — try `mise x -- tuist build` first |

---

## Key Test Areas

| Component | What it covers |
|-----------|----------------|
| `KGDataTourManager` | API requests, response parsing, error handling |
| `TourListViewModel` | Pagination, type filtering, radius changes |
| `DeepLinkManager` | URL parsing, consume() idempotency |
| `LocationManager` | Auth status transitions |
| `WWGDefaults` | Read/write correctness |

---

## Output Format

```
## Test Run — [date]

### Build: PASS / FAIL
[error message if failed]

### Tests: N passed, N failed (Ns)

### Failures
- [TestClass.testMethod]: [error message]

### Verdict
- PASS — safe to PR / FAIL — escalate to tester subagent
```
