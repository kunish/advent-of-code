#!/usr/bin/env bash
# Load AOC_SESSION from .env if present (file is gitignored), then run complete_stars.lua.
# Usage: ./complete_stars.sh [from_year] [to_year]
set -euo pipefail
cd "$(dirname "$0")"
if [[ -f .env ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi
exec lua complete_stars.lua "$@"
