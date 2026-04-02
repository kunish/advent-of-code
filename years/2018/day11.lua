local function power_level(serial, x, y)
  local rack = x + 10
  local pl = rack * y + serial
  pl = pl * rack
  local hundreds = (pl // 100) % 10
  return hundreds - 5
end

local function day11(path)
  local lines = readLines(path)
  local serial = tonumber((lines[1] or ''):match('%d+') or '0')
  local size = 300

  local sat = {}
  for y = 0, size do
    sat[y] = {}
    for x = 0, size do
      sat[y][x] = 0
    end
  end

  for y = 1, size do
    for x = 1, size do
      local p = power_level(serial, x, y)
      sat[y][x] = p + sat[y - 1][x] + sat[y][x - 1] - sat[y - 1][x - 1]
    end
  end

  local function square_sum(x, y, k)
    local x0, y0 = x - 1, y - 1
    return sat[y + k - 1][x + k - 1] - sat[y0][x + k - 1] - sat[y + k - 1][x0] + sat[y0][x0]
  end

  local best1, bx1, by1 = nil, 0, 0
  for y = 1, size - 2 do
    for x = 1, size - 2 do
      local s = square_sum(x, y, 3)
      if best1 == nil or s > best1 then
        best1 = s
        bx1 = x
        by1 = y
      end
    end
  end
  local part1 = string.format('%d,%d', bx1, by1)

  local best2, bx2, by2, bs2 = nil, 0, 0, 0
  for y = 1, size do
    for x = 1, size do
      local maxk = math.min(size - x + 1, size - y + 1)
      for k = 1, maxk do
        local s = square_sum(x, y, k)
        if best2 == nil or s > best2 then
          best2 = s
          bx2 = x
          by2 = y
          bs2 = k
        end
      end
    end
  end
  local part2 = string.format('%d,%d,%d', bx2, by2, bs2)

  print(string.format('Part 1: %s', part1))
  print(string.format('Part 2: %s', part2))
end

return function(path)
  return day11(path)
end
