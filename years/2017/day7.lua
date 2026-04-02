local function parse_line(line)
  local name, w, rest = line:match('^(%w+)%s+%((%d+)%)%s*(.*)$')
  if not name then
    return nil
  end
  local weight = tonumber(w)
  local children = {}
  if rest:find('->') then
    local list = rest:match('->%s*(.+)')
    if list then
      for c in list:gmatch('(%w+)') do
        children[#children + 1] = c
      end
    end
  end
  return name, weight, children
end

local function day7(path)
  local lines = readLines(path)
  local prog = {}
  local child_set = {}

  for _, line in ipairs(lines) do
    if line ~= '' then
      local name, weight, children = parse_line(line)
      if name then
        prog[name] = { weight = weight, children = children }
        for _, c in ipairs(children) do
          child_set[c] = true
        end
      end
    end
  end

  local root
  for name in pairs(prog) do
    if not child_set[name] then
      root = name
      break
    end
  end

  local fixed_weight

  local function dfs(name)
    local node = prog[name]
    local ch = node.children
    if #ch == 0 then
      return node.weight
    end

    local totals = {}
    for _, c in ipairs(ch) do
      totals[c] = dfs(c)
    end

    local counts = {}
    for _, c in ipairs(ch) do
      local t = totals[c]
      counts[t] = (counts[t] or 0) + 1
    end

    local common, maxc = nil, 0
    for t, cnt in pairs(counts) do
      if cnt > maxc then
        maxc = cnt
        common = t
      end
    end

    local rare_total
    for t, cnt in pairs(counts) do
      if cnt == 1 then
        rare_total = t
      end
    end

    if rare_total and rare_total ~= common then
      for _, c in ipairs(ch) do
        if totals[c] == rare_total then
          fixed_weight = prog[c].weight + (common - rare_total)
          return node.weight + common * #ch
        end
      end
    end

    local sum = node.weight
    for _, c in ipairs(ch) do
      sum = sum + totals[c]
    end
    return sum
  end

  dfs(root)

  print(string.format('Part 1: %s', root))
  print(string.format('Part 2: %d', fixed_weight))
end

return function(path)
  return day7(path)
end
