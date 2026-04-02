local function priority(c)
  local b = string.byte(c)
  if b >= string.byte('a') then
    return b - string.byte('a') + 1
  end
  return b - string.byte('A') + 27
end

local function day3(path)
  local lines = readLines(path)

  local part1 = 0
  for i = 1, #lines do
    local line = lines[i]
    local half = #line // 2
    local set = {}
    for j = 1, half do
      local c = line:sub(j, j)
      set[c] = true
    end
    for j = half + 1, #line do
      local c = line:sub(j, j)
      if set[c] then
        part1 = part1 + priority(c)
        break
      end
    end
  end

  local part2 = 0
  local g = 1
  while g + 2 <= #lines do
    local function badge_set(s)
      local t = {}
      for j = 1, #s do
        t[s:sub(j, j)] = true
      end
      return t
    end
    local a = badge_set(lines[g])
    local b = badge_set(lines[g + 1])
    local linec = lines[g + 2]
    local found = nil
    for j = 1, #linec do
      local c = linec:sub(j, j)
      if a[c] and b[c] then
        found = c
        break
      end
    end
    if found then
      part2 = part2 + priority(found)
    end
    g = g + 3
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end

return function(p)
  return day3(p)
end
