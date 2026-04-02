local function fuel(mass)
  return math.max(0, mass // 3 - 2)
end

local function total_fuel(mass)
  local t = 0
  local f = fuel(mass)
  while f > 0 do
    t = t + f
    f = fuel(f)
  end
  return t
end

local function day1(path)
  local lines = readLines(path)
  local part1, part2 = 0, 0
  local i = 1
  while i <= #lines do
    local line = lines[i]
    if line ~= '' then
      local m = tonumber(line)
      part1 = part1 + fuel(m)
      part2 = part2 + total_fuel(m)
    end
    i = i + 1
  end
  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end

return function(path)
  return day1(path)
end
