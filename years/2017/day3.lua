local function spiral_distance(n)
  if n == 1 then
    return 0
  end
  local x, y = 0, 0
  local dx, dy = 1, 0
  local steps = 1
  local val = 1
  while val < n do
    for _ = 1, 2 do
      for _ = 1, steps do
        val = val + 1
        x, y = x + dx, y + dy
        if val == n then
          return math.abs(x) + math.abs(y)
        end
      end
      dx, dy = -dy, dx
    end
    steps = steps + 1
  end
  return math.abs(x) + math.abs(y)
end

local function key(x, y)
  return x .. ',' .. y
end

local function stress_first_over(target)
  local g = { [key(0, 0)] = 1 }
  local x, y = 0, 0
  local dx, dy = 1, 0
  local steps = 1
  while true do
    for _ = 1, 2 do
      for _ = 1, steps do
        x, y = x + dx, y + dy
        local sum = 0
        for ox = -1, 1 do
          for oy = -1, 1 do
            if ox ~= 0 or oy ~= 0 then
              sum = sum + (g[key(x + ox, y + oy)] or 0)
            end
          end
        end
        g[key(x, y)] = sum
        if sum > target then
          return sum
        end
      end
      dx, dy = -dy, dx
    end
    steps = steps + 1
  end
end

local function day3(path)
  local lines = readLines(path)
  local n = tonumber((lines[1] or '0'):match('%d+')) or 0
  print(string.format('Part 1: %d', spiral_distance(n)))
  print(string.format('Part 2: %d', stress_first_over(n)))
end

return function(path)
  return day3(path)
end
