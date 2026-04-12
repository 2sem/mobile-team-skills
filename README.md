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
| `appstore-screenshot-designer` | App Store screenshot narrative, prompt, QA, and creative brief planning | `designer`/`marketer` for lightweight screenshot strategy |
| `ios-design-spec` | Quick HIG audit, component selection, accessibility check | `designer` subagent |
| `ios-simulator-skill` | iOS simulator build, UI automation, accessibility, and device lifecycle scripts | `tester` subagent for lightweight simulator tasks |
| `aso-analysis` | App Store analysis checklist, keyword check | `marketer` subagent |
| `ios-test-runner` | Build + run tests, report results | `tester` subagent |

### iOS Simulator Skill Notes

- Location: `skills/ios-simulator-skill/`
- Includes bundled automation scripts under `skills/ios-simulator-skill/scripts/`
- Also includes imported helper scripts:
  - `idb-open-work-alarm.sh`
  - `idb-session.sh`

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

### OpenCode

OpenCode loads skills and agents from filesystem directories. For this repository, use the GitHub release or clone the repo, then run the installer script.

```bash
bash scripts/install-opencode.sh
```

Compatibility note:
- the installer copies both `skills/` and `agents/` into `~/.config/opencode/`
- OpenCode also detects compatible skill folders under `~/.agents/skills/` and `~/.claude/skills/`
- this repository is distributed for OpenCode via GitHub releases and filesystem installation, not as an OpenCode npm/plugin package

### Manual

```bash
cp agents/*.md ~/.claude/agents/
cp -r skills/* ~/.claude/skills/
```
