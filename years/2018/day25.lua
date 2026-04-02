local function parse_points(lines)
  local pts = {}
  for i = 1, #lines do
    local a, b, c, d = lines[i]:match('(%-?%d+),(%-?%d+),(%-?%d+),(%-?%d+)')
    if a then
      pts[#pts + 1] = { tonumber(a), tonumber(b), tonumber(c), tonumber(d) }
    end
  end
  return pts
end

local function manhattan(a, b)
  return math.abs(a[1] - b[1]) + math.abs(a[2] - b[2]) + math.abs(a[3] - b[3]) + math.abs(a[4] - b[4])
end

local function find(parent, i)
  while parent[i] ~= i do
    parent[i] = parent[parent[i]]
    i = parent[i]
  end
  return i
end

local function union(parent, rank, a, b)
  local ra = find(parent, a)
  local rb = find(parent, b)
  if ra == rb then
    return
  end
  if rank[ra] < rank[rb] then
    ra, rb = rb, ra
  end
  parent[rb] = ra
  if rank[ra] == rank[rb] then
    rank[ra] = rank[ra] + 1
  end
end

local function day25(path)
  local lines = readLines(path)
  local pts = parse_points(lines)
  local n = #pts
  local parent = {}
  local rank = {}
  for i = 1, n do
    parent[i] = i
    rank[i] = 0
  end
  for i = 1, n do
    for j = i + 1, n do
      if manhattan(pts[i], pts[j]) <= 3 then
        union(parent, rank, i, j)
      end
    end
  end
  local roots = {}
  for i = 1, n do
    local r = find(parent, i)
    roots[r] = true
  end
  local count = 0
  for _ in pairs(roots) do
    count = count + 1
  end
  print(string.format('Part 1: %d', count))
  print('Part 2:')
end

return function(path)
  return day25(path)
end
