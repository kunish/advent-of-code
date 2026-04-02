return function(path)
  local lines = readLines(path)
  local W, H = 101, 103
  local robots = {}
  for _, line in ipairs(lines) do
    local px, py, vx, vy = line:match('p=(%-?%d+),(%-?%d+) v=(%-?%d+),(%-?%d+)')
    if px then
      robots[#robots + 1] = { tonumber(px), tonumber(py), tonumber(vx), tonumber(vy) }
    end
  end

  local function step(n)
    local out = {}
    for i = 1, #robots do
      local r = robots[i]
      local x = (r[1] + n * r[3]) % W
      local y = (r[2] + n * r[4]) % H
      if x < 0 then x = x + W end
      if y < 0 then y = y + H end
      out[i] = { x, y }
    end
    return out
  end

  local pos100 = step(100)
  local mx, my = (W - 1) / 2, (H - 1) / 2
  local q = { 0, 0, 0, 0 }
  for i = 1, #pos100 do
    local x, y = pos100[i][1], pos100[i][2]
    if x == mx or y == my then
      -- middle line: not in any quadrant
    elseif x < mx and y < my then
      q[1] = q[1] + 1
    elseif x > mx and y < my then
      q[2] = q[2] + 1
    elseif x < mx and y > my then
      q[3] = q[3] + 1
    else
      q[4] = q[4] + 1
    end
  end
  local part1 = q[1] * q[2] * q[3] * q[4]

  local n = #robots
  local best_t, best_var = 0, math.huge
  for t = 1, W * H do
    local p = step(t)
    local sx, sy, sx2, sy2 = 0, 0, 0, 0
    for i = 1, n do
      local x, y = p[i][1], p[i][2]
      sx = sx + x
      sy = sy + y
      sx2 = sx2 + x * x
      sy2 = sy2 + y * y
    end
    local var = n * (sx2 + sy2) - sx * sx - sy * sy
    if var < best_var then
      best_var = var
      best_t = t
    end
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', best_t))
end
