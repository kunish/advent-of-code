local function idx1(x, y, w)
  return y * w + x + 1
end

local function parse_grid(lines)
  local h = #lines
  local w = #lines[1]
  local grid = {}
  local targets = {}
  for y = 1, h do
    local row = lines[y]
    for x = 1, w do
      local ch = row:sub(x, x)
      grid[idx1(x - 1, y - 1, w)] = ch
      if ch >= '0' and ch <= '9' then
        targets[tonumber(ch)] = { x - 1, y - 1 }
      end
    end
  end
  return grid, w, h, targets
end

local function bfs_dist(grid, w, h, sx, sy, tx, ty)
  local start = idx1(sx, sy, w)
  local goal = idx1(tx, ty, w)
  local head, tail = 1, 1
  local qx, qy, qd = { sx }, { sy }, { 0 }
  local seen = { [start] = true }
  local dirs = { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }

  while head <= tail do
    local x, y, d = qx[head], qy[head], qd[head]
    head = head + 1
    if x == tx and y == ty then
      return d
    end
    for i = 1, 4 do
      local nx, ny = x + dirs[i][1], y + dirs[i][2]
      if nx >= 0 and nx < w and ny >= 0 and ny < h then
        local ch = grid[idx1(nx, ny, w)]
        if ch ~= '#' then
          local ni = idx1(nx, ny, w)
          if not seen[ni] then
            seen[ni] = true
            tail = tail + 1
            qx[tail], qy[tail], qd[tail] = nx, ny, d + 1
          end
        end
      end
    end
  end
  return nil
end

return function(path)
  local lines = readLines(path)
  local grid, w, h, targets = parse_grid(lines)

  local n = 0
  for _ in pairs(targets) do
    n = n + 1
  end
  local maxn = 0
  for k in pairs(targets) do
    if k > maxn then
      maxn = k
    end
  end

  local dist = {}
  for i = 0, maxn do
    dist[i] = {}
  end

  for i = 0, maxn do
    for j = i + 1, maxn do
      local ai, aj = targets[i], targets[j]
      if ai and aj then
        local d = bfs_dist(grid, w, h, ai[1], ai[2], aj[1], aj[2])
        dist[i][j] = d
        dist[j][i] = d
      end
    end
  end

  local full = (1 << (maxn + 1)) - 1
  local memo = {}

  local function tsp(start, mask, return0)
    local key = start .. ':' .. mask .. ':' .. (return0 and 1 or 0)
    if memo[key] then
      return memo[key]
    end
    if mask == full then
      local r = 0
      if return0 then
        r = dist[start][0]
      end
      memo[key] = r
      return r
    end
    local best = nil
    for i = 0, maxn do
      local bit = 1 << i
      if (mask & bit) == 0 then
        local d = dist[start][i]
        if d then
          local v = d + tsp(i, mask | bit, return0)
          if best == nil or v < best then
            best = v
          end
        end
      end
    end
    memo[key] = best
    return best
  end

  local part1 = tsp(0, 1, false)
  local part2 = tsp(0, 1, true)

  print('Part 1: ' .. tostring(part1))
  print('Part 2: ' .. tostring(part2))
end
