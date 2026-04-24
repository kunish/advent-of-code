#!/usr/bin/env bash
# Load AOC_SESSION from .env if present (file is gitignored), then run complete_stars.lua.
# Usage: ./complete_stars.sh [from_year] [to_year]
set -euo pipefail
cd "$(dirname "$0")" || exit

load_aoc_session() {
  local line value

  [[ -f .env ]] || return 0
  while IFS= read -r line || [[ -n "$line" ]]; do
    case "$line" in
      AOC_SESSION=* | export\ AOC_SESSION=*)
        value=${line#export AOC_SESSION=}
        value=${value#AOC_SESSION=}
        value=${value%$'\r'}
        if [[ ${value:0:1} == '"' && ${value: -1} == '"' ]]; then
          value=${value:1:${#value}-2}
        elif [[ ${value:0:1} == "'" && ${value: -1} == "'" ]]; then
          value=${value:1:${#value}-2}
        fi
        export AOC_SESSION="$value"
        return 0
        ;;
    esac
  done <.env
}

load_aoc_session
exec lua complete_stars.lua "$@"
