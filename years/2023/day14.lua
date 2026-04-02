local function grid_to_str(rows)
  return table.concat(rows, '\n')
end

local function parse(lines)
  local rows = {}
  for i = 1, #lines do
    rows[i] = lines[i]
  end
  return rows
end

local function tilt_north(rows)
  local R = #rows
  local C = #rows[1]
  local g = {}
  local r = 1
  while r <= R do
    g[r] = {}
    local c = 1
    while c <= C do
      g[r][c] = rows[r]:sub(c, c)
      c = c + 1
    end
    r = r + 1
  end
  local c = 1
  while c <= C do
    local spot = 1
    local rr = 1
    while rr <= R do
      local ch = g[rr][c]
      if ch == '#' then
        spot = rr + 1
      elseif ch == 'O' then
        g[rr][c] = '.'
        g[spot][c] = 'O'
        spot = spot + 1
      end
      rr = rr + 1
    end
    c = c + 1
  end
  local out = {}
  rr = 1
  while rr <= R do
    local t = {}
    local cc = 1
    while cc <= C do
      t[cc] = g[rr][cc]
      cc = cc + 1
    end
    out[rr] = table.concat(t)
    rr = rr + 1
  end
  return out
end

local function tilt_west(rows)
  local R = #rows
  local C = #rows[1]
  local g = {}
  local r = 1
  while r <= R do
    g[r] = {}
    local c = 1
    while c <= C do
      g[r][c] = rows[r]:sub(c, c)
      c = c + 1
    end
    r = r + 1
  end
  r = 1
  while r <= R do
    local spot = 1
    local cc = 1
    while cc <= C do
      local ch = g[r][cc]
      if ch == '#' then
        spot = cc + 1
      elseif ch == 'O' then
        g[r][cc] = '.'
        g[r][spot] = 'O'
        spot = spot + 1
      end
      cc = cc + 1
    end
    r = r + 1
  end
  local out = {}
  r = 1
  while r <= R do
    local t = {}
    local cc = 1
    while cc <= C do
      t[cc] = g[r][cc]
      cc = cc + 1
    end
    out[r] = table.concat(t)
    r = r + 1
  end
  return out
end

local function tilt_south(rows)
  local R = #rows
  local C = #rows[1]
  local g = {}
  local r = 1
  while r <= R do
    g[r] = {}
    local c = 1
    while c <= C do
      g[r][c] = rows[r]:sub(c, c)
      c = c + 1
    end
    r = r + 1
  end
  local c = 1
  while c <= C do
    local spot = R
    local rr = R
    while rr >= 1 do
      local ch = g[rr][c]
      if ch == '#' then
        spot = rr - 1
      elseif ch == 'O' then
        g[rr][c] = '.'
        g[spot][c] = 'O'
        spot = spot - 1
      end
      rr = rr - 1
    end
    c = c + 1
  end
  local out = {}
  r = 1
  while r <= R do
    local t = {}
    local cc = 1
    while cc <= C do
      t[cc] = g[r][cc]
      cc = cc + 1
    end
    out[r] = table.concat(t)
    r = r + 1
  end
  return out
end

local function tilt_east(rows)
  local R = #rows
  local C = #rows[1]
  local g = {}
  local r = 1
  while r <= R do
    g[r] = {}
    local c = 1
    while c <= C do
      g[r][c] = rows[r]:sub(c, c)
      c = c + 1
    end
    r = r + 1
  end
  r = 1
  while r <= R do
    local spot = C
    local cc = C
    while cc >= 1 do
      local ch = g[r][cc]
      if ch == '#' then
        spot = cc - 1
      elseif ch == 'O' then
        g[r][cc] = '.'
        g[r][spot] = 'O'
        spot = spot - 1
      end
      cc = cc - 1
    end
    r = r + 1
  end
  local out = {}
  r = 1
  while r <= R do
    local t = {}
    local cc = 1
    while cc <= C do
      t[cc] = g[r][cc]
      cc = cc + 1
    end
    out[r] = table.concat(t)
    r = r + 1
  end
  return out
end

local function spin_cycle(rows)
  local a = tilt_north(rows)
  a = tilt_west(a)
  a = tilt_south(a)
  a = tilt_east(a)
  return a
end

local function total_load(rows)
  local R = #rows
  local sum = 0
  local r = 1
  while r <= R do
    local line = rows[r]
    local c = 1
    local C = #line
    while c <= C do
      if line:sub(c, c) == 'O' then
        sum = sum + (R - r + 1)
      end
      c = c + 1
    end
    r = r + 1
  end
  return sum
end

return function(path)
  local lines = readLines(path)
  local grid = parse(lines)
  local p1 = total_load(tilt_north(grid))

  local seen = {}
  local loads = {}
  local g = grid
  local step = 0
  local cycle_start
  local cycle_len
  while true do
    step = step + 1
    g = spin_cycle(g)
    local key = grid_to_str(g)
    local load = total_load(g)
    loads[step] = load
    if seen[key] then
      cycle_start = seen[key]
      cycle_len = step - cycle_start
      break
    end
    seen[key] = step
  end

  local target = 1000000000
  local idx
  if target < cycle_start then
    idx = target
  else
    idx = cycle_start + ((target - cycle_start) % cycle_len)
  end
  local p2 = loads[idx]

  print(string.format('Part 1: %d', p1))
  print(string.format('Part 2: %d', p2))
end
