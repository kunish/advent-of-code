local function parse_groups(s)
  local t = {}
  for n in s:gmatch('%d+') do
    t[#t + 1] = tonumber(n)
  end
  return t
end

local function count_arrangements(s, groups, memo)
  local key = s .. '|' .. table.concat(groups, ',')
  if memo[key] then
    return memo[key]
  end

  if #groups == 0 then
    local ok = not s:find('#', 1, true)
    memo[key] = ok and 1 or 0
    return memo[key]
  end

  if s == '' then
    memo[key] = 0
    return 0
  end

  local g = groups[1]
  local rest = {}
  for i = 2, #groups do
    rest[i - 1] = groups[i]
  end

  local c = s:sub(1, 1)
  local total = 0

  if c == '.' or c == '?' then
    total = total + count_arrangements(s:sub(2), groups, memo)
  end

  if (c == '#' or c == '?') and #s >= g then
    local ok = true
    for i = 1, g do
      if s:sub(i, i) == '.' then
        ok = false
        break
      end
    end
    if ok then
      if #s == g then
        total = total + count_arrangements('', rest, memo)
      elseif s:sub(g + 1, g + 1) ~= '#' then
        local tail = s:sub(g + 2)
        total = total + count_arrangements(tail, rest, memo)
      end
    end
  end

  memo[key] = total
  return total
end

local function day12(path)
  local lines = readLines(path)
  local p1, p2 = 0, 0
  for i = 1, #lines do
    local line = lines[i]
    if line ~= '' then
      local pat, grp = line:match('([%?%.#]+)%s+(.+)')
      local groups = parse_groups(grp)
      p1 = p1 + count_arrangements(pat, groups, {})

      local parts = {}
      for j = 1, 5 do
        parts[j] = pat
      end
      local big = table.concat(parts, '?')
      local bigg = {}
      for j = 1, 5 do
        for k = 1, #groups do
          bigg[#bigg + 1] = groups[k]
        end
      end
      p2 = p2 + count_arrangements(big, bigg, {})
    end
  end
  print(string.format('Part 1: %d', p1))
  print(string.format('Part 2: %d', p2))
end

return function(p)
  return day12(p)
end
