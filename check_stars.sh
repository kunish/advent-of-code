#!/usr/bin/env bash
export AOC_SESSION='53616c7465645f5f2ce6dee9de824ca54a041c35ad3f35abe746f67a2f4339d1f28a11589acd228f4b4dc3e7d1d4ffc7fe85237438dd6b771d14864eabea29e8'

total=0
for year in $(seq 2015 2025); do
  html=$(curl -fsSL --cookie "session=$AOC_SESSION" "https://adventofcode.com/$year" 2>/dev/null)
  two=$(echo "$html" | rg -c 'two stars' 2>/dev/null || echo 0)
  one=$(echo "$html" | rg -c 'one star"' 2>/dev/null || echo 0)
  zero=$(echo "$html" | rg -c 'aria-label="Day [0-9]+"[^,]' 2>/dev/null || echo 0)
  stars=$((two * 2 + one))
  total=$((total + stars))
  
  one_days=$(echo "$html" | rg -o 'Day (\d+), one star' -r '$1' 2>/dev/null | sort -n | tr '\n' ' ')
  zero_days=$(echo "$html" | rg 'aria-label="Day \d+"[^,]' -o 2>/dev/null | rg -o '\d+' 2>/dev/null | sort -n | tr '\n' ' ')
  
  maxday=25
  if [ "$year" = "2025" ]; then maxday=12; fi
  maxstars=$((maxday * 2))
  
  echo "[$year] ${stars}★/${maxstars}  need_p2:[${one_days}]  need_both:[${zero_days}]"
  sleep 1
done
echo ""
echo "Total: ${total}★"
