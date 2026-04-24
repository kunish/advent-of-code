#!/usr/bin/env bash
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

if [[ -z "${AOC_SESSION:-}" ]]; then
  printf 'Set AOC_SESSION (or put it in gitignored .env).\n' >&2
  exit 1
fi
if [[ $AOC_SESSION == *$'\n'* || $AOC_SESSION == *$'\r'* ]]; then
  printf 'AOC_SESSION must not contain newlines.\n' >&2
  exit 1
fi

total=0
CURL_CONFIG=$(mktemp)
chmod 600 "$CURL_CONFIG"
cleanup() {
  rm -f "$CURL_CONFIG"
}
trap cleanup EXIT
escaped_session=${AOC_SESSION//\\/\\\\}
escaped_session=${escaped_session//\"/\\\"}
printf 'header = "Cookie: session=%s"\n' "$escaped_session" >"$CURL_CONFIG"

for year in $(seq 2015 2025); do
  if ! html=$(curl -fsSL --config "$CURL_CONFIG" "https://adventofcode.com/$year" 2>/dev/null); then
    printf '[%s] calendar fetch failed\n' "$year" >&2
    continue
  fi
  two=$(printf '%s\n' "$html" | rg -c 'two stars' 2>/dev/null || echo 0)
  one=$(printf '%s\n' "$html" | rg -c 'one star"' 2>/dev/null || echo 0)
  stars=$((two * 2 + one))
  total=$((total + stars))

  one_days=$(printf '%s\n' "$html" | rg -o 'Day (\d+), one star' -r '$1' 2>/dev/null | sort -n | tr '\n' ' ' || true)
  zero_days=$(printf '%s\n' "$html" | rg 'aria-label="Day \d+"[^,]' -o 2>/dev/null | rg -o '\d+' 2>/dev/null | sort -n | tr '\n' ' ' || true)

  maxday=25
  maxstars=$((maxday * 2))

  echo "[$year] ${stars}★/${maxstars}  need_p2:[${one_days}]  need_both:[${zero_days}]"
  sleep 1
done
echo ""
echo "Total: ${total}★"
