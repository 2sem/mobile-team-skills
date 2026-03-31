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
| `appstore-review-cs` | App Store review workflow wrapper for the cs agent | External appstore skill wiring |
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

### Via `/plugin` (Claude Code only)

```
/plugin marketplace add 2sem/mobile-team-skills
/plugin install mobile-team-skills@mobile-team-skills
```

### Manual

```bash
cp agents/*.md ~/.claude/agents/
cp -r skills/* ~/.claude/skills/
```
