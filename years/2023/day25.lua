local function parse(lines)
  local adj = {}
  local function ensure(k)
    if not adj[k] then
      adj[k] = {}
    end
  end
  local li = 1
  while li <= #lines do
    local line = lines[li]
    if line ~= '' then
      local name, rest = line:match('^(%w+):%s*(.+)$')
      ensure(name)
      for nb in rest:gmatch('%w+') do
        ensure(nb)
        adj[name][nb] = (adj[name][nb] or 0) + 1
        adj[nb][name] = (adj[nb][name] or 0) + 1
      end
    end
    li = li + 1
  end
  return adj
end

local function copy_adj(adj)
  local out = {}
  for u, nbs in pairs(adj) do
    out[u] = {}
    for v, c in pairs(nbs) do
      out[u][v] = c
    end
  end
  return out
end

local function copy_wt(wt)
  local out = {}
  for k, v in pairs(wt) do
    out[k] = v
  end
  return out
end

local function count_vertices(adj)
  local n = 0
  for _ in pairs(adj) do
    n = n + 1
  end
  return n
end

local function verts_array(adj)
  local t = {}
  for k in pairs(adj) do
    t[#t + 1] = k
  end
  return t
end

local function pick_random_edge(adj, verts)
  local u = verts[math.random(1, #verts)]
  local nbs = adj[u]
  if not nbs then
    return nil, nil
  end
  local tw = 0
  for _, c in pairs(nbs) do
    tw = tw + c
  end
  if tw == 0 then
    return nil, nil
  end
  local r = math.random() * tw
  local acc = 0
  for w, c in pairs(nbs) do
    acc = acc + c
    if r <= acc then
      return u, w
    end
  end
  return u, nil
end

local function contract(adj, wt, u, v)
  if u == v or not adj[u] or not adj[v] then
    return
  end
  for w, c in pairs(adj[v]) do
    if w ~= u then
      adj[u][w] = (adj[u][w] or 0) + c
      adj[w][u] = adj[u][w]
    end
    adj[w][v] = nil
  end
  adj[u][v] = nil
  adj[v] = nil
  wt[u] = wt[u] + wt[v]
  wt[v] = nil
end

local function karger_once(adj0, wt0)
  local adj = copy_adj(adj0)
  local wt = copy_wt(wt0)
  local guard = 0
  while count_vertices(adj) > 2 and guard < 50000 do
    guard = guard + 1
    local verts = verts_array(adj)
    local u, v = pick_random_edge(adj, verts)
    if u and v and u ~= v and adj[u] and adj[v] then
      contract(adj, wt, u, v)
    end
  end
  if count_vertices(adj) ~= 2 then
    return nil
  end
  local rem = {}
  for k in pairs(adj) do
    rem[#rem + 1] = k
  end
  local a, b = rem[1], rem[2]
  local cut = adj[a][b] or 0
  return cut, wt[a], wt[b]
end

return function(path)
  math.randomseed(os.time())
  local lines = readLines(path)
  local adj = parse(lines)
  local wt = {}
  for k in pairs(adj) do
    wt[k] = 1
  end

  local best
  local trial = 1
  while trial <= 500 do
    local cut, wa, wb = karger_once(adj, wt)
    if cut and cut == 3 then
      best = wa * wb
      break
    end
    trial = trial + 1
  end

  if not best then
    trial = 1
    while trial <= 10000 do
      local cut, wa, wb = karger_once(adj, wt)
      if cut and cut == 3 then
        best = wa * wb
        break
      end
      trial = trial + 1
    end
  end

  print(string.format('Part 1: %d', best or -1))
  print('Part 2:')
end
