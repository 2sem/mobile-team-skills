# mobile-team-skills

Source of truth for the mobile team's Claude Code skills and agent definitions.

## Structure

```
mobile-team-skills/
├── agents/      ← agent definitions → install to ~/.claude/agents/
└── skills/      ← skill definitions → install to ~/.claude/skills/
```

## Install

```bash
# Agents
cp agents/*.md ~/.claude/agents/

# Skills
cp -r skills/* ~/.claude/skills/
```

## Skill vs Subagent — Routing Rule

| Situation | Use |
|-----------|-----|
| Sequential task, small output | Skill on main agent |
| Sequential task, large output | Subagent |
| External action (GitHub, App Store) | Always subagent |
| Implementation (Swift code) | Always ios-developer subagent |
| Parallel tasks | Always subagents |

### Skill → Subagent Escalation Thresholds

| Skill | Use skill when | Escalate to subagent when |
|-------|---------------|--------------------------|
| `ios-simulator-skill` | Lightweight simulator boot, launch, navigation, accessibility, or device lifecycle work | Full-suite testing, failure diagnosis, or broader QA coverage |
| `ios-design-spec` | HIG check, component pick, quick layout question | Full screen design, new nav flow, complex interactions |
| `aso-analysis` | ASO checklist, keyword check, quick competitor scan | Full strategy, campaign planning, detailed report |
| `ios-test-runner` | Smoke build/test after simple change | Full suite, coverage analysis, complex failure diagnosis |
