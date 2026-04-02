local function parse(path)
  local lines = readLines(path)
  local by = {}
  local maxx, maxy = 0, 0
  local max_avail = 0
  local empty_x, empty_y

  for _, line in ipairs(lines) do
    local x, y, sz, u, av =
      line:match('node%-x(%d+)%-y(%d+)%s+(%d+)T%s+(%d+)T%s+(%d+)T')
    if x then
      x, y, sz, u, av = tonumber(x), tonumber(y), tonumber(sz), tonumber(u), tonumber(av)
      maxx = math.max(maxx, x)
      maxy = math.max(maxy, y)
      max_avail = math.max(max_avail, av)
      by[y] = by[y] or {}
      by[y][x] = { size = sz, used = u, avail = av }
      if u == 0 then
        empty_x, empty_y = x, y
      end
    end
  end

  local w, h = maxx + 1, maxy + 1
  return by, w, h, maxx, max_avail, empty_x, empty_y
end

local function movable(used, maxa)
  return used <= maxa
end

local function bfs_to(w, h, by, maxa, sx, sy, tx, ty, block_left_into)
  local head, tail = 1, 1
  local qx, qy, qd = { sx }, { sy }, { 0 }
  local seen = {}
  seen[sx .. ',' .. sy] = true

  local dirs = {
    { -1, 0, 'L' },
    { 1, 0, 'R' },
    { 0, -1, 'U' },
    { 0, 1, 'D' },
  }

  while head <= tail do
    local x, y, d = qx[head], qy[head], qd[head]
    head = head + 1
    if x == tx and y == ty then
      return d
    end
    for i = 1, 4 do
      local dx, dy, dir = dirs[i][1], dirs[i][2], dirs[i][3]
      local nx, ny = x + dx, y + dy
      if nx >= 0 and nx < w and ny >= 0 and ny < h then
        if dx == -1 and block_left_into and nx == block_left_into[1] and ny == block_left_into[2] then
          -- cannot step onto goal from the east (see AoC 2016 day 22 walkthroughs)
        else
          local cell = by[ny][nx]
          if movable(cell.used, maxa) then
            local key = nx .. ',' .. ny
            if not seen[key] then
              seen[key] = true
              tail = tail + 1
              qx[tail], qy[tail], qd[tail] = nx, ny, d + 1
            end
          end
        end
      end
    end
  end
  return nil
end

return function(path)
  local by, w, h, maxx, max_avail, ex, ey = parse(path)

  local part1 = 0
  for ya = 0, h - 1 do
    for xa = 0, w - 1 do
      local ua = by[ya][xa].used
      if ua > 0 then
        for yb = 0, h - 1 do
          for xb = 0, w - 1 do
            if xa ~= xb or ya ~= yb then
              local ub = by[yb][xb].used
              local avail_b = by[yb][xb].avail
              if ua <= avail_b then
                part1 = part1 + 1
              end
            end
          end
        end
      end
    end
  end

  local tx, ty = maxx, 0
  local total = 0

  while tx ~= 0 or ty ~= 0 do
    local dest_x, dest_y = tx - 1, ty
    local block = { tx, ty }
    local steps = bfs_to(w, h, by, max_avail, ex, ey, dest_x, dest_y, block)
    if not steps then
      error('day22: no BFS path')
    end
    total = total + steps
    ex, ey = dest_x, dest_y
    ex, ey, tx, ty = tx, ty, ex, ey
    total = total + 1
  end

  print('Part 1: ' .. tostring(part1))
  print('Part 2: ' .. tostring(total))
end
