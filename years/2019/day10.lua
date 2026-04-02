local function gcd(a, b)
  a, b = math.abs(a), math.abs(b)
  while b ~= 0 do
    local t = a % b
    a = b
    b = t
  end
  return a
end

local function norm(dx, dy)
  local g = gcd(dx, dy)
  return dx // g, dy // g
end

local function parse_asteroids(lines)
  local ast = {}
  local y = 1
  while y <= #lines do
    local line = lines[y]
    local x = 1
    while x <= #line do
      if string.sub(line, x, x) == '#' then
        ast[#ast + 1] = { x - 1, y - 1 }
      end
      x = x + 1
    end
    y = y + 1
  end
  return ast
end

local function count_visible(ast, si)
  local sx, sy = ast[si][1], ast[si][2]
  local dirs = {}
  local j = 1
  while j <= #ast do
    if j ~= si then
      local ox, oy = ast[j][1], ast[j][2]
      local dx, dy = ox - sx, oy - sy
      local nx, ny = norm(dx, dy)
      dirs[nx .. ',' .. ny] = true
    end
    j = j + 1
  end
  local c = 0
  for _ in pairs(dirs) do
    c = c + 1
  end
  return c
end

local function day10(path)
  local lines = readLines(path)
  local ast = parse_asteroids(lines)

  local best_i, best_n = 1, 0
  local i = 1
  while i <= #ast do
    local n = count_visible(ast, i)
    if n > best_n then
      best_n = n
      best_i = i
    end
    i = i + 1
  end

  local sx, sy = ast[best_i][1], ast[best_i][2]
  local rays = {}
  local j = 1
  while j <= #ast do
    if j ~= best_i then
      local ox, oy = ast[j][1], ast[j][2]
      local dx, dy = ox - sx, oy - sy
      local nx, ny = norm(dx, dy)
      local ang = math.atan(nx, -ny)
      if ang < 0 then ang = ang + 2 * math.pi end
      local rkey = nx .. ',' .. ny
      if rays[rkey] == nil then
        rays[rkey] = { ang = ang, pts = {} }
      end
      local dist = dx * dx + dy * dy
      local pts = rays[rkey].pts
      pts[#pts + 1] = { dist = dist, x = ox, y = oy }
    end
    j = j + 1
  end

  local order = {}
  for _, r in pairs(rays) do
    order[#order + 1] = r
  end
  table.sort(order, function(a, b)
    return a.ang < b.ang
  end)
  local k = 1
  while k <= #order do
    table.sort(order[k].pts, function(a, b)
      return a.dist < b.dist
    end)
    k = k + 1
  end

  local vaporized = 0
  local round = 1
  local part2 = 0
  while vaporized < 200 do
    local ri = 1
    while ri <= #order do
      local pts = order[ri].pts
      if round <= #pts then
        vaporized = vaporized + 1
        if vaporized == 200 then
          local p = pts[round]
          part2 = p.x * 100 + p.y
          break
        end
      end
      ri = ri + 1
    end
    if part2 ~= 0 then
      break
    end
    round = round + 1
  end

  print(string.format('Part 1: %d', best_n))
  print(string.format('Part 2: %d', part2))
end

return function(path)
  return day10(path)
end
