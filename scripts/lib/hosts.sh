#!/usr/bin/env bash
# Known AI coding agents and where each one reads user-level (global) skills from.
#
# Format, one host per line:  name|home-marker|skills-dir
# All paths are relative to $HOME. If "home-marker" exists under $HOME, that agent
# is considered installed on this machine and is targeted by setup.sh automatically.
#
# We install into each agent's own skills dir (not the shared ~/.agents/skills) so a
# single agent never loads the skill twice. To add another agent, add one line.
sk_hosts() {
  cat <<'EOF'
cursor|.cursor|.cursor/skills
claude|.claude|.claude/skills
codex|.codex|.codex/skills
opencode|.config/opencode|.config/opencode/skills
factory|.factory|.factory/skills
EOF
}
