return function(path)
  local lines = readLines(path)
  local cubes = {}
  local dirs = {
    { 1, 0, 0 },
    { -1, 0, 0 },
    { 0, 1, 0 },
    { 0, -1, 0 },
    { 0, 0, 1 },
    { 0, 0, -1 },
  }

  local function key(x, y, z)
    return x .. ',' .. y .. ',' .. z
  end

  local minx, maxx = 1e9, -1e9
  local miny, maxy = 1e9, -1e9
  local minz, maxz = 1e9, -1e9

  for i = 1, #lines do
    local x, y, z = lines[i]:match('^(%d+),(%d+),(%d+)$')
    x, y, z = tonumber(x), tonumber(y), tonumber(z)
    cubes[key(x, y, z)] = true
    if x < minx then
      minx = x
    end
    if x > maxx then
      maxx = x
    end
    if y < miny then
      miny = y
    end
    if y > maxy then
      maxy = y
    end
    if z < minz then
      minz = z
    end
    if z > maxz then
      maxz = z
    end
  end

  local part1 = 0
  for k, _ in pairs(cubes) do
    local x, y, z = k:match('^(%d+),(%d+),(%d+)$')
    x, y, z = tonumber(x), tonumber(y), tonumber(z)
    for di = 1, #dirs do
      local dx, dy, dz = dirs[di][1], dirs[di][2], dirs[di][3]
      local nx, ny, nz = x + dx, y + dy, z + dz
      if not cubes[key(nx, ny, nz)] then
        part1 = part1 + 1
      end
    end
  end

  print(string.format('Part 1: %d', part1))

  minx, maxx = minx - 1, maxx + 1
  miny, maxy = miny - 1, maxy + 1
  minz, maxz = minz - 1, maxz + 1

  local outside = {}
  local queue = {}
  local qh, qt = 1, 0

  local function enqueue(x, y, z)
    local k = key(x, y, z)
    if outside[k] then
      return
    end
    if cubes[k] then
      return
    end
    outside[k] = true
    qt = qt + 1
    queue[qt] = { x, y, z }
  end

  enqueue(minx, miny, minz)

  while qh <= qt do
    local cur = queue[qh]
    qh = qh + 1
    local x, y, z = cur[1], cur[2], cur[3]
    for di = 1, #dirs do
      local nx = x + dirs[di][1]
      local ny = y + dirs[di][2]
      local nz = z + dirs[di][3]
      if nx >= minx and nx <= maxx and ny >= miny and ny <= maxy and nz >= minz and nz <= maxz then
        enqueue(nx, ny, nz)
      end
    end
  end

  local part2 = 0
  for k, _ in pairs(cubes) do
    local x, y, z = k:match('^(%d+),(%d+),(%d+)$')
    x, y, z = tonumber(x), tonumber(y), tonumber(z)
    for di = 1, #dirs do
      local nx = x + dirs[di][1]
      local ny = y + dirs[di][2]
      local nz = z + dirs[di][3]
      if outside[key(nx, ny, nz)] then
        part2 = part2 + 1
      end
    end
  end

  print(string.format('Part 2: %d', part2))
end
