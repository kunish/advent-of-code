local W, H = 5, 5

local function parse_grid(lines)
  local g = {}
  for y = 1, H do
    g[y] = lines[y] or ''
  end
  return g
end

local function biodiv(grid)
  local s = 0
  local bit = 1
  for y = 1, H do
    for x = 1, W do
      if grid[y]:sub(x, x) == '#' then
        s = s + bit
      end
      bit = bit * 2
    end
  end
  return s
end

local function step1(grid)
  local ng = {}
  for y = 1, H do
    local row = {}
    for x = 1, W do
      local n = 0
      for _, d in ipairs({ { 0, -1 }, { 0, 1 }, { -1, 0 }, { 1, 0 } }) do
        local nx, ny = x + d[1], y + d[2]
        if nx >= 1 and nx <= W and ny >= 1 and ny <= H then
          if grid[ny]:sub(nx, nx) == '#' then
            n = n + 1
          end
        end
      end
      local c = grid[y]:sub(x, x)
      local bug = c == '#'
      local alive = bug and (n == 1) or (not bug and (n == 1 or n == 2))
      row[x] = alive and '#' or '.'
    end
    ng[y] = table.concat(row)
  end
  return ng
end

--- Part 2: 0-based coords, center (2,2) is always empty (skip)
local function add_bug(m, lev, x, y, dv)
  if x == 2 and y == 2 then
    return
  end
  local k = lev
  local b = m[k] or 0
  local idx = y * 5 + x
  local bit = 1 << idx
  if dv > 0 then
    m[k] = b | bit
  else
    m[k] = b & ~bit
  end
end

local function bug_at(m, lev, x, y)
  if x == 2 and y == 2 then
    return false
  end
  local b = m[lev] or 0
  local idx = y * 5 + x
  return (b & (1 << idx)) ~= 0
end

local function count_neighbors2(m, lev, x, y)
  local n = 0
  local function chk(nx, ny, nl)
    if nx == 2 and ny == 2 then
      return
    end
    if nx < 0 or ny < 0 or nx > 4 or ny > 4 then
      return
    end
    if bug_at(m, nl, nx, ny) then
      n = n + 1
    end
  end

  local dirs = { { 0, -1 }, { 0, 1 }, { -1, 0 }, { 1, 0 } }
  for i = 1, #dirs do
    local dx, dy = dirs[i][1], dirs[i][2]
    local nx, ny = x + dx, y + dy
    if nx == 2 and ny == 2 then
      -- step into center from one of four adjacent tiles -> inner level edge
      if dy == 1 then
        for ix = 0, 4 do
          chk(ix, 0, lev + 1)
        end
      elseif dy == -1 then
        for ix = 0, 4 do
          chk(ix, 4, lev + 1)
        end
      elseif dx == 1 then
        for iy = 0, 4 do
          chk(0, iy, lev + 1)
        end
      else
        for iy = 0, 4 do
          chk(4, iy, lev + 1)
        end
      end
    elseif nx < 0 then
      chk(1, 2, lev - 1)
    elseif nx > 4 then
      chk(3, 2, lev - 1)
    elseif ny < 0 then
      chk(2, 1, lev - 1)
    elseif ny > 4 then
      chk(2, 3, lev - 1)
    else
      chk(nx, ny, lev)
    end
  end
  return n
end

local function step2(m)
  local nm = {}
  local minl, maxl = 0, 0
  for k, _ in pairs(m) do
    if k < minl then
      minl = k
    end
    if k > maxl then
      maxl = k
    end
  end
  minl = minl - 1
  maxl = maxl + 1
  for lev = minl, maxl do
    for y = 0, 4 do
      for x = 0, 4 do
        if x == 2 and y == 2 then
          goto cont
        end
        local nc = count_neighbors2(m, lev, x, y)
        local b = bug_at(m, lev, x, y)
        local alive = b and (nc == 1) or (not b and (nc == 1 or nc == 2))
        if alive then
          local idx = y * 5 + x
          local bit = 1 << idx
          nm[lev] = (nm[lev] or 0) | bit
        end
        ::cont::
      end
    end
  end
  return nm
end

local function count_bugs2(m)
  local t = 0
  for lev, bits in pairs(m) do
    local b = bits
    while b ~= 0 do
      if (b & 1) ~= 0 then
        t = t + 1
      end
      b = math.floor(b / 2)
    end
  end
  return t
end

local function day24(path)
  local lines = readLines(path)
  local grid = parse_grid(lines)
  local seen = {}
  local p1
  while true do
    local b = biodiv(grid)
    if seen[b] then
      p1 = b
      break
    end
    seen[b] = true
    grid = step1(grid)
  end

  local m = {}
  local b0 = biodiv(parse_grid(lines))
  m[0] = b0

  for _ = 1, 200 do
    m = step2(m)
  end
  local p2 = count_bugs2(m)

  print(string.format('Part 1: %d', p1))
  print(string.format('Part 2: %d', p2))
end

return function(p)
  return day24(p)
end
