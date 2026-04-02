return function(path)
  local lines = readLines(path)

  local graph = {}
  for i = 1, #lines do
    local dev, outs = lines[i]:match('^([^:]+):%s*(.+)$')
    local adj = {}
    for w in outs:gmatch('%S+') do
      adj[#adj + 1] = w
    end
    graph[dev] = adj
  end

  local memo1 = {}
  local function count_from_you(node)
    if memo1[node] then
      return memo1[node]
    end
    if node == 'out' then
      memo1[node] = 1
      return 1
    end
    local total = 0
    local adj = graph[node]
    if adj then
      for i = 1, #adj do
        total = total + count_from_you(adj[i])
      end
    end
    memo1[node] = total
    return total
  end

  local memo2 = {}
  local function count_with_middle(node, seen)
    local k = node .. '\0' .. tostring(seen)
    if memo2[k] then
      return memo2[k]
    end
    if node == 'out' then
      local ok = (seen == 3)
      memo2[k] = ok and 1 or 0
      return memo2[k]
    end
    local total = 0
    local adj = graph[node]
    if adj then
      for i = 1, #adj do
        local nx = adj[i]
        local ns = seen
        if nx == 'dac' then
          ns = ns | 1
        end
        if nx == 'fft' then
          ns = ns | 2
        end
        total = total + count_with_middle(nx, ns)
      end
    end
    memo2[k] = total
    return total
  end

  local part1 = count_from_you('you')
  local part2 = count_with_middle('svr', 0)

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end
