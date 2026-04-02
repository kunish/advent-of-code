local function set_from_string(s)
  local t = {}
  local j = 1
  while j <= #s do
    local ch = s:sub(j, j)
    t[ch] = true
    j = j + 1
  end
  return t
end

local function count_keys(t)
  local c = 0
  for _ in pairs(t) do
    c = c + 1
  end
  return c
end

local function intersect(a, b)
  local out = {}
  for k in pairs(a) do
    if b[k] then
      out[k] = true
    end
  end
  return out
end

return function(path)
  local lines = readLines(path)
  local groups = {}
  local cur = {}
  local i = 1
  while i <= #lines do
    local line = lines[i]
    if line == '' then
      if #cur > 0 then
        groups[#groups + 1] = cur
        cur = {}
      end
    else
      cur[#cur + 1] = line
    end
    i = i + 1
  end
  if #cur > 0 then
    groups[#groups + 1] = cur
  end

  local part1, part2 = 0, 0
  local g = 1
  while g <= #groups do
    local grp = groups[g]
    local union = {}
    local inter = nil
    local p = 1
    while p <= #grp do
      local st = set_from_string(grp[p])
      for k in pairs(st) do
        union[k] = true
      end
      if inter == nil then
        inter = {}
        for k in pairs(st) do
          inter[k] = true
        end
      else
        inter = intersect(inter, st)
      end
      p = p + 1
    end
    part1 = part1 + count_keys(union)
    part2 = part2 + count_keys(inter or {})
    g = g + 1
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end
