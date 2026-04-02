local intcode = require('years.2019.intcode')

local DIRS = {
  { 1, 0, -1 },
  { 2, 0, 1 },
  { 3, -1, 0 },
  { 4, 1, 0 },
}

local function try_move(vm, inv)
  while true do
    local ev = intcode.step(vm)
    if ev == 'in' then
      intcode.apply_input(vm, inv)
    elseif type(ev) == 'table' and ev[1] == 'out' then
      return ev[2]
    elseif ev == 'halt' then
      return nil
    end
  end
end

local function explore(path)
  local lines = readLines(path)
  local vm = { mem = intcode.parse(lines[1] or ''), ip = 0, rb = 0 }
  local world = {}
  local ox, oy

  local function key(x, y)
    return x .. ',' .. y
  end

  local function dfs(x, y)
    for _, d in ipairs(DIRS) do
      local inv, dx, dy = d[1], d[2], d[3]
      local nx, ny = x + dx, y + dy
      local k = key(nx, ny)
      if world[k] == nil then
        local status = try_move(vm, inv)
        if status and status ~= 0 then
          world[k] = status
          if status == 2 then
            ox, oy = nx, ny
          end
          dfs(nx, ny)
          local back = ({ [1] = 2, [2] = 1, [3] = 4, [4] = 3 })[inv]
          try_move(vm, back)
        elseif status == 0 then
          world[k] = 0
        end
      end
    end
  end

  world[key(0, 0)] = 1
  dfs(0, 0)

  return world, ox, oy, key
end

local function bfs_shortest(world, key_fn, sx, sy, tx, ty)
  local target = key_fn(tx, ty)
  local q = { { sx, sy, 0 } }
  local qi, qn = 1, 1
  local seen = { [key_fn(sx, sy)] = true }
  while qi <= qn do
    local x, y, d = q[qi][1], q[qi][2], q[qi][3]
    qi = qi + 1
    if key_fn(x, y) == target then
      return d
    end
    for _, dd in ipairs(DIRS) do
      local nx, ny = x + dd[2], y + dd[3]
      local nk = key_fn(nx, ny)
      local cell = world[nk]
      if cell and cell ~= 0 and not seen[nk] then
        seen[nk] = true
        qn = qn + 1
        q[qn] = { nx, ny, d + 1 }
      end
    end
  end
  return nil
end

local function bfs_max_dist(world, key_fn, ox, oy)
  local q = { { ox, oy, 0 } }
  local qi, qn = 1, 1
  local seen = { [key_fn(ox, oy)] = true }
  local best = 0
  while qi <= qn do
    local x, y, d = q[qi][1], q[qi][2], q[qi][3]
    qi = qi + 1
    if d > best then
      best = d
    end
    for _, dd in ipairs(DIRS) do
      local nx, ny = x + dd[2], y + dd[3]
      local nk = key_fn(nx, ny)
      local cell = world[nk]
      if cell and cell ~= 0 and not seen[nk] then
        seen[nk] = true
        qn = qn + 1
        q[qn] = { nx, ny, d + 1 }
      end
    end
  end
  return best
end

local function day15(path)
  local world, ox, oy, key_fn = explore(path)
  local p1 = bfs_shortest(world, key_fn, 0, 0, ox, oy)
  local p2 = bfs_max_dist(world, key_fn, ox, oy)
  print(string.format('Part 1: %d', p1))
  print(string.format('Part 2: %d', p2))
end

return function(p)
  return day15(p)
end
