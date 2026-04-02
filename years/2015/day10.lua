local function look_say(s)
  local parts = {}
  local n = 0
  local i = 1
  local len = #s
  while i <= len do
    local c = s:sub(i, i)
    local j = i + 1
    while j <= len and s:sub(j, j) == c do
      j = j + 1
    end
    local run = j - i
    n = n + 1
    parts[n] = tostring(run)
    n = n + 1
    parts[n] = c
    i = j
  end
  return table.concat(parts)
end

local function day10(path)
  local lines = readLines(path)
  local s = (lines[1] or ''):match('^%s*(.-)%s*$') or ''

  local cur = s
  local part1 = nil
  for round = 1, 50 do
    cur = look_say(cur)
    if round == 40 then
      part1 = #cur
    end
  end
  local part2 = #cur

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end

return function(path)
  return day10(path)
end
