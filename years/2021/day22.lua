local function day22_coord(x, y, z)
  return string.format('%d,%d,%d', x, y, z)
end

local function day22_cuboid_volume(c)
  return (c.x2 - c.x1 + 1) * (c.y2 - c.y1 + 1) * (c.z2 - c.z1 + 1)
end

-- Intersection of two axis-aligned cuboids; nil if empty.
local function day22_cuboid_intersect(a, b)
  local x1 = math.max(a.x1, b.x1)
  local x2 = math.min(a.x2, b.x2)
  local y1 = math.max(a.y1, b.y1)
  local y2 = math.min(a.y2, b.y2)
  local z1 = math.max(a.z1, b.z1)
  local z2 = math.min(a.z2, b.z2)
  if x1 > x2 or y1 > y2 or z1 > z2 then
    return nil
  end
  return { x1 = x1, x2 = x2, y1 = y1, y2 = y2, z1 = z1, z2 = z2 }
end

return function(path)
  local lines = readLines(path)

  local steps = {}
  for i = 1, #lines do --#lines do
    local substr = string.sub(lines[i], string.find(lines[i], 'x=') + 2)
    local x_ed, y_st = string.find(substr, ',y=')
    local y_ed, z_st = string.find(substr, ',z=')
    local x_sub = string.sub(substr, 0, x_ed - 1)
    local y_sub = string.sub(substr, y_st + 1, y_ed - 1)
    local z_sub = string.sub(substr, z_st + 1)
    local index = 1
    while string.sub(x_sub, index, index) ~= '.' do
      index = index + 1
    end
    local x1 = tonumber(string.sub(x_sub, 0, index - 1))
    local x2 = tonumber(string.sub(x_sub, index + 2))
    index = 1
    while string.sub(y_sub, index, index) ~= '.' do
      index = index + 1
    end
    local y1 = tonumber(string.sub(y_sub, 0, index - 1))
    local y2 = tonumber(string.sub(y_sub, index + 2))
    index = 1
    while string.sub(z_sub, index, index) ~= '.' do
      index = index + 1
    end
    local z1 = tonumber(string.sub(z_sub, 0, index - 1))
    local z2 = tonumber(string.sub(z_sub, index + 2))

    if string.sub(lines[i], 2, 2) == 'f' then
      steps[#steps + 1] = { 0, x1, x2, y1, y2, z1, z2 }
    else
      steps[#steps + 1] = { 1, x1, x2, y1, y2, z1, z2 }
    end
  end

  local grid = {}
  local min_x = nil
  local max_x = nil
  local min_y = nil
  local max_y = nil
  local min_z = nil
  local max_z = nil
  for i = 1, #steps do
    if min_x == nil or steps[i][2] < min_x then
      min_x = steps[i][2]
    end
    if max_x == nil or steps[i][3] > max_x then
      max_x = steps[i][3]
    end
    if min_y == nil or steps[i][4] < min_y then
      min_y = steps[i][4]
    end
    if max_y == nil or steps[i][5] > max_y then
      max_y = steps[i][5]
    end
    if min_z == nil or steps[i][6] < min_z then
      min_z = steps[i][6]
    end
    if max_z == nil or steps[i][7] > max_z then
      max_z = steps[i][7]
    end

    local x1 = steps[i][2] < -50 and -50 or steps[i][2]
    local x2 = steps[i][3] > 50 and 50 or steps[i][3]
    local y1 = steps[i][4] < -50 and -50 or steps[i][4]
    local y2 = steps[i][5] > 50 and 50 or steps[i][5]
    local z1 = steps[i][6] < -50 and -50 or steps[i][6]
    local z2 = steps[i][7] > 50 and 50 or steps[i][7]
    for x = x1, x2 do
      for y = y1, y2 do
        for z = z1, z2 do
          grid[day22_coord(x, y, z)] = steps[i][1]
        end
      end
    end
  end

  local part1 = 0
  for _, v in pairs(grid) do
    if v == 1 then
      part1 = part1 + 1
    end
  end
  print(string.format('Part 1: %d', part1))

  -- Part 2: cuboid list with cancellation (inclusion-exclusion)
  local signed = {}
  for si = 1, #steps do
    local s = steps[si]
    local on = s[1] == 1
    local C = { x1 = s[2], x2 = s[3], y1 = s[4], y2 = s[5], z1 = s[6], z2 = s[7] }
    local n_before = #signed
    for j = 1, n_before do
      local pair = signed[j]
      local I = day22_cuboid_intersect(pair.c, C)
      if I then
        signed[#signed + 1] = { c = I, sign = -pair.sign }
      end
    end
    if on then
      signed[#signed + 1] = { c = C, sign = 1 }
    end
  end

  local part2 = 0
  for i = 1, #signed do
    part2 = part2 + day22_cuboid_volume(signed[i].c) * signed[i].sign
  end
  print(string.format('Part 2: %d', part2))
end
