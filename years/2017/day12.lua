local function parse_line(line)
  local id, rest = line:match('^(%d+)%s+<%-%>%s*(.+)$')
  if not id then
    return nil
  end
  local n = tonumber(id)
  local adj = {}
  for x in rest:gmatch('%d+') do
    adj[#adj + 1] = tonumber(x)
  end
  return n, adj
end

local function day12(path)
  local lines = readLines(path)
  local graph = {}

  for _, line in ipairs(lines) do
    if line ~= '' then
      local id, adj = parse_line(line)
      if id then
        graph[id] = adj
      end
    end
  end

  local function dfs(start, vis)
    local stack = { start }
    while #stack > 0 do
      local u = table.remove(stack)
      if not vis[u] then
        vis[u] = true
        for _, v in ipairs(graph[u] or {}) do
          stack[#stack + 1] = v
        end
      end
    end
  end

  local vis0 = {}
  dfs(0, vis0)
  local c0 = 0
  for _ in pairs(vis0) do
    c0 = c0 + 1
  end

  local all_vis = {}
  local groups = 0
  for id in pairs(graph) do
    if not all_vis[id] then
      local vis = {}
      dfs(id, vis)
      for k in pairs(vis) do
        all_vis[k] = true
      end
      groups = groups + 1
    end
  end

  print(string.format('Part 1: %d', c0))
  print(string.format('Part 2: %d', groups))
end

return function(path)
  return day12(path)
end
