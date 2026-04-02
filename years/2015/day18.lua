local function parse_grid(lines)
  local g = {}
  for y, line in ipairs(lines) do
    g[y] = {}
    for x = 1, #line do
      g[y][x] = line:sub(x, x) == '#'
    end
  end
  return g, #lines, #lines[1]
end

local function count_on(g, h, w)
  local n = 0
  for y = 1, h do
    for x = 1, w do
      if g[y][x] then
        n = n + 1
      end
    end
  end
  return n
end

local function neighbors_on(g, y, x, h, w)
  local c = 0
  for dy = -1, 1 do
    for dx = -1, 1 do
      if not (dy == 0 and dx == 0) then
        local ny, nx = y + dy, x + dx
        if ny >= 1 and ny <= h and nx >= 1 and nx <= w and g[ny][nx] then
          c = c + 1
        end
      end
    end
  end
  return c
end

local function step(g, h, w, corners_stuck)
  local ng = {}
  for y = 1, h do
    ng[y] = {}
    for x = 1, w do
      local on = g[y][x]
      local nc = neighbors_on(g, y, x, h, w)
      if on then
        ng[y][x] = (nc == 2 or nc == 3)
      else
        ng[y][x] = (nc == 3)
      end
    end
  end
  if corners_stuck then
    ng[1][1] = true
    ng[1][w] = true
    ng[h][1] = true
    ng[h][w] = true
  end
  return ng
end

local function day18(path)
  local lines = readLines(path)
  local g1, h, w = parse_grid(lines)
  for _ = 1, 100 do
    g1 = step(g1, h, w, false)
  end
  local part1 = count_on(g1, h, w)

  local g2, _, _ = parse_grid(lines)
  g2[1][1] = true
  g2[1][w] = true
  g2[h][1] = true
  g2[h][w] = true
  for _ = 1, 100 do
    g2 = step(g2, h, w, true)
  end
  local part2 = count_on(g2, h, w)

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end

return function(p)
  return day18(p)
end
