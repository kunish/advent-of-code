#!/usr/bin/env bash
set -uo pipefail

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

TIMEOUT_BIN=$(command -v timeout || command -v gtimeout || true)
if [[ -z "$TIMEOUT_BIN" ]]; then
  printf 'Missing timeout command. Install coreutils so timeout/gtimeout is available.\n' >&2
  exit 1
fi

run_solver() {
  local year="$1"
  local day="$2"

  if [[ -n "$TIMEOUT_BIN" ]]; then
    "$TIMEOUT_BIN" 15 lua run.lua "$year" "$day" 2>&1
  else
    lua run.lua "$year" "$day" 2>&1
  fi
}

for year in $(seq 2015 2025); do
  max_day=25
  for day in $(seq 1 $max_day); do
    result=$(run_solver "$year" "$day")
    ec=$?
    p1=$(printf '%s\n' "$result" | grep 'Part 1:' | head -1)
    p2=$(printf '%s\n' "$result" | grep 'Part 2:' | head -1)
    if printf '%s\n' "$result" | grep -q "not implemented"; then
      echo "STUB $year/$day"
    elif [ "$ec" = "124" ] || printf '%s\n' "$result" | grep -q "killed"; then
      echo "TIMEOUT $year/$day"
    elif printf '%s\n' "$result" | grep -qi "error\|attempt to\|stack traceback"; then
      echo "ERROR $year/$day"
    elif [ -n "$p1" ] || [ -n "$p2" ]; then
      echo "OK $year/$day: $p1 | $p2"
    else
      echo "NO_OUTPUT $year/$day"
    fi
  done
done
echo "DONE"
