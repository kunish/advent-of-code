return function(path)
  local lines = readLines(path)
  local adj = {}
  local function add(a, b)
    if not adj[a] then
      adj[a] = {}
    end
    adj[a][b] = true
    if not adj[b] then
      adj[b] = {}
    end
    adj[b][a] = true
  end

  for _, line in ipairs(lines) do
    local a, b = line:match('(%w+)%-(%w+)')
    if a then
      add(a, b)
    end
  end

  local nodes = {}
  for k, _ in pairs(adj) do
    nodes[#nodes + 1] = k
  end
  table.sort(nodes)

  local function has_edge(a, b)
    return adj[a] and adj[a][b]
  end

  local p1 = 0
  for i = 1, #nodes do
    for j = i + 1, #nodes do
      for k = j + 1, #nodes do
        local a, b, c = nodes[i], nodes[j], nodes[k]
        if has_edge(a, b) and has_edge(a, c) and has_edge(b, c) then
          if a:sub(1, 1) == 't' or b:sub(1, 1) == 't' or c:sub(1, 1) == 't' then
            p1 = p1 + 1
          end
        end
      end
    end
  end

  local best_clique = {}

  local function set_to_list(s)
    local t = {}
    for k, _ in pairs(s) do
      t[#t + 1] = k
    end
    table.sort(t)
    return t
  end

  local function list_to_set(lst)
    local s = {}
    for i = 1, #lst do
      s[lst[i]] = true
    end
    return s
  end

  local function intersect(a, b)
    local o = {}
    for k, _ in pairs(a) do
      if b[k] then
        o[k] = true
      end
    end
    return o
  end

  local function union(a, k)
    local o = {}
    for x, _ in pairs(a) do
      o[x] = true
    end
    o[k] = true
    return o
  end

  local function minus(a, k)
    local o = {}
    for x, _ in pairs(a) do
      if x ~= k then
        o[x] = true
      end
    end
    return o
  end

  local function bronk(R, P, X)
    if next(P) == nil and next(X) == nil then
      local lst = set_to_list(R)
      if #lst > #best_clique then
        best_clique = lst
      end
      return
    end
    local Pu = set_to_list(P)
    for _, v in ipairs(Pu) do
      bronk(union(R, v), intersect(P, adj[v] or {}), intersect(X, adj[v] or {}))
      P = minus(P, v)
      X = union(X, v)
    end
  end

  bronk({}, list_to_set(nodes), {})

  table.sort(best_clique)
  local p2 = table.concat(best_clique, ',')

  print(string.format('Part 1: %d', p1))
  print(string.format('Part 2: %s', p2))
end
