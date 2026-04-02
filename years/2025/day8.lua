return function(path)
  local lines = readLines(path)

  local function key(box)
    return string.format('%d,%d,%d', box[1], box[2], box[3])
  end

  local function parse_box(line)
    local a, b, c = line:match('^(%-?%d+),(%-?%d+),(%-?%d+)$')
    return { tonumber(a), tonumber(b), tonumber(c) }
  end

  local boxes = {}
  for i = 1, #lines do
    boxes[#boxes + 1] = parse_box(lines[i])
  end

  local function dist2(a, b)
    local dx = a[1] - b[1]
    local dy = a[2] - b[2]
    local dz = a[3] - b[3]
    return dx * dx + dy * dy + dz * dz
  end

  local edge_list = {}
  for i = 1, #boxes do
    for j = i + 1, #boxes do
      edge_list[#edge_list + 1] = { boxes[i], boxes[j], dist2(boxes[i], boxes[j]) }
    end
  end

  table.sort(edge_list, function(a, b)
    return a[3] < b[3]
  end)

  local parent = {}
  local size = {}

  local function find(x)
    if parent[x] ~= x then
      parent[x] = find(parent[x])
    end
    return parent[x]
  end

  for i = 1, #boxes do
    local k = key(boxes[i])
    parent[k] = k
    size[k] = 1
  end

  local function union(a, b)
    local ra, rb = find(a), find(b)
    if ra == rb then
      return
    end
    if size[ra] < size[rb] then
      ra, rb = rb, ra
    end
    parent[rb] = ra
    size[ra] = size[ra] + size[rb]
    size[rb] = nil
  end

  local function root_sizes()
    local out = {}
    for k, v in pairs(size) do
      out[#out + 1] = v
    end
    table.sort(out, function(x, y)
      return x > y
    end)
    return out
  end

  local function num_components()
    local n = 0
    for _ in pairs(size) do
      n = n + 1
    end
    return n
  end

  local function prod_top3()
    local rs = root_sizes()
    return rs[1] * rs[2] * rs[3]
  end

  local part1, part2
  for i = 1, #edge_list do
    local b1, b2 = edge_list[i][1], edge_list[i][2]
    local k1, k2 = key(b1), key(b2)
    union(k1, k2)
    if i == 1000 then
      part1 = prod_top3()
    end
    if num_components() == 1 then
      part2 = b1[1] * b2[1]
      break
    end
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end
