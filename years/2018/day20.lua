local function day20(path)
  local lines = readLines(path)
  local s = lines[1] or ''
  local dirs = {
    N = { 0, -1 },
    S = { 0, 1 },
    W = { -1, 0 },
    E = { 1, 0 },
  }

  local graph = {}
  local function connect(k1, k2)
    if graph[k1] == nil then
      graph[k1] = {}
    end
    if graph[k2] == nil then
      graph[k2] = {}
    end
    graph[k1][k2] = true
    graph[k2][k1] = true
  end

  local function pack(x, y)
    return (x + 4096) * 8192 + (y + 4096)
  end

  local x, y = 0, 0
  local stack = {}
  for i = 2, #s - 1 do
    local c = s:sub(i, i)
    if c == '(' then
      stack[#stack + 1] = { x = x, y = y }
    elseif c == '|' then
      local p = stack[#stack]
      x, y = p.x, p.y
    elseif c == ')' then
      stack[#stack] = nil
    elseif dirs[c] then
      local d = dirs[c]
      local nx = x + d[1]
      local ny = y + d[2]
      connect(pack(x, y), pack(nx, ny))
      x, y = nx, ny
    end
  end

  local origin = pack(0, 0)
  local dist = { [origin] = 0 }
  local q = { origin }
  local qh, qt = 1, 1
  local maxd = 0

  while qh <= qt do
    local cur = q[qh]
    qh = qh + 1
    local d0 = dist[cur]
    local nbrs = graph[cur]
    if nbrs then
      for nk in pairs(nbrs) do
        if dist[nk] == nil then
          local nd = d0 + 1
          dist[nk] = nd
          if nd > maxd then
            maxd = nd
          end
          qt = qt + 1
          q[qt] = nk
        end
      end
    end
  end

  local part2 = 0
  for _, d in pairs(dist) do
    if d >= 1000 then
      part2 = part2 + 1
    end
  end

  print(string.format('Part 1: %d', maxd))
  print(string.format('Part 2: %d', part2))
end

return function(path)
  return day20(path)
end
