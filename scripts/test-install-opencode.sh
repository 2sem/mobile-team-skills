#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

export HOME="$tmpdir/home"
export XDG_CONFIG_HOME="$HOME/.config"

mkdir -p "$HOME"

"$repo_root/scripts/install-opencode.sh"

test -f "$XDG_CONFIG_HOME/opencode/skills/ios-design-spec/SKILL.md"
test -f "$XDG_CONFIG_HOME/opencode/skills/ios-simulator-skill/SKILL.md"
test -f "$XDG_CONFIG_HOME/opencode/agents/tester.md"
test -f "$XDG_CONFIG_HOME/opencode/agents/ios-developer.md"

printf 'OpenCode installer test passed\n'
