#!/usr/bin/env bash
# Install all skills in this repo for Claude Code and Codex.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
targets=("$HOME/.claude/skills" "$HOME/.agents/skills")

for dest in "${targets[@]}"; do
  mkdir -p "$dest"
  for skill_md in "$repo"/*/SKILL.md; do
    [ -e "$skill_md" ] || continue
    src="$(dirname "$skill_md")"
    name="$(basename "$src")"
    rm -rf "${dest:?}/$name"
    cp -R "$src" "$dest/$name"
    echo "Installed $name -> $dest/$name"
  done
done
