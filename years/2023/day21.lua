local function find_start(lines)
  local r = 1
  while r <= #lines do
    local c = 1
    while c <= #lines[r] do
      if lines[r]:sub(c, c) == 'S' then
        return r, c
      end
      c = c + 1
    end
    r = r + 1
  end
  return nil, nil
end

local function bfs_finite(grid, sr, sc, steps)
  local R = #grid
  local C = #grid[1]
  local cur = {}
  cur[sr .. ',' .. sc] = true
  local s = 0
  while s < steps do
    local nxt = {}
    for k in pairs(cur) do
      local comma = k:find(',')
      local r = tonumber(k:sub(1, comma - 1))
      local c = tonumber(k:sub(comma + 1))
      local dirs = { { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 } }
      local di = 1
      while di <= 4 do
        local rr = r + dirs[di][1]
        local cc = c + dirs[di][2]
        if rr >= 1 and rr <= R and cc >= 1 and cc <= C then
          local ch = grid[rr]:sub(cc, cc)
          if ch ~= '#' then
            nxt[rr .. ',' .. cc] = true
          end
        end
        di = di + 1
      end
    end
    cur = nxt
    s = s + 1
  end
  local cnt = 0
  for _ in pairs(cur) do
    cnt = cnt + 1
  end
  return cnt
end

local function bfs_infinite(grid, sr, sc, steps)
  local R = #grid
  local C = #grid[1]
  local cur = {}
  cur[sr .. ',' .. sc] = true
  local s = 0
  while s < steps do
    local nxt = {}
    for k in pairs(cur) do
      local comma = k:find(',')
      local r = tonumber(k:sub(1, comma - 1))
      local c = tonumber(k:sub(comma + 1))
      local dirs = { { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 } }
      local di = 1
      while di <= 4 do
        local rr = r + dirs[di][1]
        local cc = c + dirs[di][2]
        local tr = ((rr - 1) % R) + 1
        local tc = ((cc - 1) % C) + 1
        local ch = grid[tr]:sub(tc, tc)
        if ch ~= '#' then
          nxt[rr .. ',' .. cc] = true
        end
        di = di + 1
      end
    end
    cur = nxt
    s = s + 1
  end
  local cnt = 0
  for _ in pairs(cur) do
    cnt = cnt + 1
  end
  return cnt
end

return function(path)
  local lines = readLines(path)
  local grid = lines
  local sr, sc = find_start(lines)
  local p1 = bfs_finite(grid, sr, sc, 64)

  local R = #grid
  local half = (R - 1) / 2
  local w = R
  local y0 = bfs_infinite(grid, sr, sc, half + 0 * w)
  local y1 = bfs_infinite(grid, sr, sc, half + 1 * w)
  local y2 = bfs_infinite(grid, sr, sc, half + 2 * w)

  local a = (y2 - 2 * y1 + y0) / 2
  local b = y1 - y0 - a
  local c = y0
  local target_n = (26501365 - half) / w
  local p2 = math.floor(a * target_n * target_n + b * target_n + c + 0.5)

  print(string.format('Part 1: %d', p1))
  print(string.format('Part 2: %d', p2))
end
