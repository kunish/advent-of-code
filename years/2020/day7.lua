local function trim(s)
  return (s:gsub('^%s+', ''):gsub('%s+$', ''))
end

local function parse_line(line)
  local outer, rest = line:match('^(.-) bags contain (.+)%.$')
  if not outer then
    return nil, nil
  end
  outer = trim(outer)
  local inside = {}
  if rest == 'no other bags' then
    return outer, inside
  end
  for seg in rest:gmatch('[^,]+') do
    local piece = trim(seg)
    local n, color = piece:match('^(%d+)%s+(.-)%s+bags?$')
    if n and color then
      inside[#inside + 1] = { n = tonumber(n), color = trim(color) }
    end
  end
  return outer, inside
end

return function(path)
  local lines = readLines(path)
  local contains = {}
  local contained_by = {}
  local i = 1
  while i <= #lines do
    local line = lines[i]
    if line ~= '' then
      local outer, inside = parse_line(line)
      if outer then
        contains[outer] = inside
        local j = 1
        while j <= #inside do
          local col = inside[j].color
          if contained_by[col] == nil then
            contained_by[col] = {}
          end
          contained_by[col][#contained_by[col] + 1] = outer
          j = j + 1
        end
      end
    end
    i = i + 1
  end

  local target = 'shiny gold'
  local can_reach = {}
  local stack = { target }
  while #stack > 0 do
    local cur = stack[#stack]
    stack[#stack] = nil
    local parents = contained_by[cur]
    if parents then
      local p = 1
      while p <= #parents do
        local par = parents[p]
        if not can_reach[par] then
          can_reach[par] = true
          stack[#stack + 1] = par
        end
        p = p + 1
      end
    end
  end
  local part1 = 0
  for _ in pairs(can_reach) do
    part1 = part1 + 1
  end

  local memo = {}
  local function count_inside(color)
    if memo[color] then
      return memo[color]
    end
    local total = 0
    local inner = contains[color]
    if inner then
      local j = 1
      while j <= #inner do
        local entry = inner[j]
        total = total + entry.n + entry.n * count_inside(entry.color)
        j = j + 1
      end
    end
    memo[color] = total
    return total
  end
  local part2 = count_inside(target)

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end
