local function valid(a, b, c)
  local x, y, z = a, b, c
  if x > y then
    x, y = y, x
  end
  if y > z then
    y, z = z, y
  end
  if x > y then
    x, y = y, x
  end
  return x + y > z
end

local function day3(path)
  local lines = readLines(path)
  local part1 = 0
  for _, line in ipairs(lines) do
    local a, b, c = line:match('(%d+)%s+(%d+)%s+(%d+)')
    if a and valid(tonumber(a), tonumber(b), tonumber(c)) then
      part1 = part1 + 1
    end
  end

  local nums = {}
  for _, line in ipairs(lines) do
    for n in line:gmatch('%d+') do
      nums[#nums + 1] = tonumber(n)
    end
  end

  local part2 = 0
  for i = 1, #nums, 9 do
    for k = 0, 2 do
      local a, b, c = nums[i + k], nums[i + 3 + k], nums[i + 6 + k]
      if a and valid(a, b, c) then
        part2 = part2 + 1
      end
    end
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end

return function(path)
  return day3(path)
end
