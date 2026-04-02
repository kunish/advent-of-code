local function rot_l(dx, dy)
  return -dy, dx
end

local function rot_r(dx, dy)
  return dy, -dx
end

local function turn(dx, dy, deg, left)
  local k = (deg // 90) % 4
  local j = 0
  while j < k do
    if left then
      dx, dy = rot_l(dx, dy)
    else
      dx, dy = rot_r(dx, dy)
    end
    j = j + 1
  end
  return dx, dy
end

return function(path)
  local lines = readLines(path)
  local x, y = 0, 0
  local dx, dy = 1, 0

  local i = 1
  while i <= #lines do
    local line = lines[i]
    if line ~= '' then
      local op, n = line:sub(1, 1), tonumber(line:sub(2))
      if op == 'N' then
        y = y + n
      elseif op == 'S' then
        y = y - n
      elseif op == 'E' then
        x = x + n
      elseif op == 'W' then
        x = x - n
      elseif op == 'L' then
        dx, dy = turn(dx, dy, n, true)
      elseif op == 'R' then
        dx, dy = turn(dx, dy, n, false)
      elseif op == 'F' then
        x = x + dx * n
        y = y + dy * n
      end
    end
    i = i + 1
  end

  local part1 = math.abs(x) + math.abs(y)

  local sx, sy = 0, 0
  local wx, wy = 10, 1
  i = 1
  while i <= #lines do
    local line = lines[i]
    if line ~= '' then
      local op, n = line:sub(1, 1), tonumber(line:sub(2))
      if op == 'N' then
        wy = wy + n
      elseif op == 'S' then
        wy = wy - n
      elseif op == 'E' then
        wx = wx + n
      elseif op == 'W' then
        wx = wx - n
      elseif op == 'L' then
        wx, wy = turn(wx, wy, n, true)
      elseif op == 'R' then
        wx, wy = turn(wx, wy, n, false)
      elseif op == 'F' then
        sx = sx + wx * n
        sy = sy + wy * n
      end
    end
    i = i + 1
  end

  local part2 = math.abs(sx) + math.abs(sy)

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end
