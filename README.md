# mobile-team-skills

Claude Code skills and agent definitions for the mobile team.

## Contents

| Directory | Purpose |
|-----------|---------|
| `agents/` | Custom subagent definitions (`.md` files) |
| `skills/` | Reusable skills invocable by the main agent |

## Skills

| Skill | Purpose | Replaces (for light use) |
|-------|---------|--------------------------|
| `ios-design-spec` | Quick HIG audit, component selection, accessibility check | `designer` subagent |
| `aso-analysis` | App Store analysis checklist, keyword check | `marketer` subagent |
| `ios-test-runner` | Build + run tests, report results | `tester` subagent |

## Agents

| Agent | Role | Model |
|-------|------|-------|
| `cs` | App Store feedback collector | haiku |
| `reporter` | GitHub issue creator | haiku |
| `ios-developer` | iOS implementation | sonnet |
| `designer` | UX/UI design | sonnet |
| `tester` | Testing & QA | sonnet |
| `marketer` | Marketing strategy | sonnet |

## Install

```bash
cp agents/*.md ~/.claude/agents/
cp -r skills/* ~/.claude/skills/
```
