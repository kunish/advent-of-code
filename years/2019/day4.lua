local function classify(n)
  local s = tostring(n)
  if #s ~= 6 then
    return false, false
  end
  local prev = -1
  local i = 1
  while i <= #s do
    local d = string.byte(s, i) - 48
    if d < prev then
      return false, false
    end
    prev = d
    i = i + 1
  end
  local has_pair = false
  local has_exact2 = false
  i = 1
  while i <= #s do
    local j = i
    local b = string.byte(s, i)
    while j <= #s and string.byte(s, j) == b do
      j = j + 1
    end
    local run = j - i
    if run >= 2 then
      has_pair = true
    end
    if run == 2 then
      has_exact2 = true
    end
    i = j
  end
  return has_pair, has_exact2
end

local function day4(path)
  local lines = readLines(path)
  local lo, hi = (lines[1] or ''):match('(%d+)%-(%d+)')
  lo = tonumber(lo)
  hi = tonumber(hi)
  local part1, part2 = 0, 0
  local n = lo
  while n <= hi do
    local a, b = classify(n)
    if a then
      part1 = part1 + 1
    end
    if b then
      part2 = part2 + 1
    end
    n = n + 1
  end
  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end

return function(path)
  return day4(path)
end
