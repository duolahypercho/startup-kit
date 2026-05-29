#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/greensock/gsap-skills"

if ! command -v npx >/dev/null 2>&1; then
  echo "npx is required to install GSAP skills with the skills CLI."
  echo "Install manually from: $REPO_URL"
  exit 1
fi

npx skills add "$REPO_URL"
