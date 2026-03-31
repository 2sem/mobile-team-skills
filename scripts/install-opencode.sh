#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
config_root="${XDG_CONFIG_HOME:-$HOME/.config}"
opencode_root="$config_root/opencode"
skills_dir="$opencode_root/skills"
agents_dir="$opencode_root/agents"

mkdir -p "$skills_dir" "$agents_dir"

cp -R "$repo_root/skills/." "$skills_dir/"
cp -R "$repo_root/agents/." "$agents_dir/"

printf 'Installed skills to %s\n' "$skills_dir"
printf 'Installed agents to %s\n' "$agents_dir"
