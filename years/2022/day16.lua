return function(path)
  local lines = readLines(path)
  local rates = {}
  local adj = {}
  local names = {}
  local name_to_idx = {}

  local function idx_of(name)
    local j = name_to_idx[name]
    if not j then
      j = #names + 1
      names[j] = name
      name_to_idx[name] = j
      adj[j] = {}
    end
    return j
  end

  for i = 1, #lines do
    local line = lines[i]
    local v, rate, rest = line:match('^Valve (%u%u) has flow rate=(%d+); tunnels? lead to valves? (.+)$')
    if not v then
      v, rate, rest = line:match('^Valve (%u%u) has flow rate=(%d+); tunnel leads to valve (.+)$')
    end
    rate = tonumber(rate)
    local vi = idx_of(v)
    rates[vi] = rate
    for t in rest:gmatch('%u%u') do
      local ti = idx_of(t)
      adj[vi][#adj[vi] + 1] = ti
    end
  end

  local n = #names
  local dist = {}
  for i = 1, n do
    dist[i] = {}
    for j = 1, n do
      dist[i][j] = 1e9
    end
    dist[i][i] = 0
    for _, t in ipairs(adj[i]) do
      dist[i][t] = 1
    end
  end
  for kk = 1, n do
    for i = 1, n do
      for j = 1, n do
        local s = dist[i][kk] + dist[kk][j]
        if s < dist[i][j] then
          dist[i][j] = s
        end
      end
    end
  end

  local useful = {}
  local aa = name_to_idx['AA']
  for i = 1, n do
    if rates[i] and rates[i] > 0 then
      useful[#useful + 1] = i
    end
  end
  local k = #useful

  local memo = {}
  local function dfs1(pos, time_left, opened)
    if time_left <= 0 then
      return 0
    end
    local key = pos .. ',' .. time_left .. ',' .. opened
    if memo[key] then
      return memo[key]
    end
    local best = 0
    for i = 1, k do
      local v = useful[i]
      local bit = 1 << (i - 1)
      if opened & bit == 0 then
        local d = dist[pos][v]
        if d < time_left then
          local t2 = time_left - d - 1
          local gain = rates[v] * t2
          local sub = dfs1(v, t2, opened | bit)
          local total = gain + sub
          if total > best then
            best = total
          end
        end
      end
    end
    memo[key] = best
    return best
  end

  print(string.format('Part 1: %d', dfs1(aa, 30, 0)))

  local best_flow = {}

  local function dfs2(pos, time_left, opened, flow_so_far)
    local prev = best_flow[opened]
    if not prev or flow_so_far > prev then
      best_flow[opened] = flow_so_far
    end
    for i = 1, k do
      local v = useful[i]
      local bit = 1 << (i - 1)
      if opened & bit == 0 then
        local d = dist[pos][v]
        if d < time_left then
          local t2 = time_left - d - 1
          local add = rates[v] * t2
          dfs2(v, t2, opened | bit, flow_so_far + add)
        end
      end
    end
  end

  dfs2(aa, 26, 0, 0)

  local full = (1 << k) - 1
  local part2 = 0
  for a = 0, full do
    local fa = best_flow[a]
    if fa then
      local rest = full ~ a
      local b = rest
      while true do
        local fb = best_flow[b]
        if fb and fa + fb > part2 then
          part2 = fa + fb
        end
        if b == 0 then
          break
        end
        b = (b - 1) & rest
      end
    end
  end

  print(string.format('Part 2: %d', part2))
end
