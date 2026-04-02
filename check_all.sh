#!/usr/bin/env bash
export AOC_SESSION='53616c7465645f5f2ce6dee9de824ca54a041c35ad3f35abe746f67a2f4339d1f28a11589acd228f4b4dc3e7d1d4ffc7fe85237438dd6b771d14864eabea29e8'
cd "$(dirname "$0")"

for year in $(seq 2015 2025); do
  max_day=25
  if [ "$year" = "2025" ]; then max_day=12; fi
  for day in $(seq 1 $max_day); do
    result=$(timeout 15 lua run.lua "$year" "$day" 2>&1) || true
    ec=${PIPESTATUS[0]:-$?}
    p1=$(echo "$result" | grep 'Part 1:' | head -1)
    p2=$(echo "$result" | grep 'Part 2:' | head -1)
    if echo "$result" | grep -q "not implemented"; then
      echo "STUB $year/$day"
    elif [ "$ec" = "124" ] || echo "$result" | grep -q "killed"; then
      echo "TIMEOUT $year/$day"
    elif echo "$result" | grep -qi "error\|attempt to\|stack traceback"; then
      echo "ERROR $year/$day"
    elif [ -n "$p1" ] || [ -n "$p2" ]; then
      echo "OK $year/$day: $p1 | $p2"
    else
      echo "NO_OUTPUT $year/$day"
    fi
  done
done
echo "DONE"
