# OpenCode Install Docs Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add explicit OpenCode installation guidance to `README.md` without creating duplicate OpenCode-specific skill trees.

**Architecture:** Keep the repository structure unchanged and document the correct installation path for OpenCode users. The README will distinguish Claude Code plugin installation from OpenCode filesystem-based skill installation.

**Tech Stack:** Markdown, GitHub releases, OpenCode skill discovery paths

---

### Task 1: Add OpenCode installation docs

**Files:**
- Modify: `README.md`
- Reference: `docs/plans/2026-03-31-opencode-install-design.md`

**Step 1: Add an OpenCode section**

Insert a new section below the Claude Code `/plugin` install block.

Include:
- OpenCode install heading
- Recommended path: `~/.config/opencode/skills/`
- Compatibility note: `~/.agents/skills/` and `~/.claude/skills/`
- Clarification that this repo is distributed via GitHub releases and is not an OpenCode npm/plugin package

**Step 2: Keep the manual install section**

Retain the existing Claude-oriented manual copy commands.

**Step 3: Verify README wording**

Check that the text:
- clearly separates Claude Code and OpenCode flows
- does not imply OpenCode marketplace publication
- remains concise

**Step 4: Verify diff**

Run: `git diff -- README.md docs/plans/2026-03-31-opencode-install-design.md docs/plans/2026-03-31-opencode-install.md`
Expected: only the README and plan docs change

**Step 5: Commit**

```bash
git add README.md docs/plans/2026-03-31-opencode-install-design.md docs/plans/2026-03-31-opencode-install.md
git commit -m "docs: add OpenCode install guidance"
```
