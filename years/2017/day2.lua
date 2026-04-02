local function parse_row(line)
  local nums = {}
  for x in line:gmatch('%d+') do
    nums[#nums + 1] = tonumber(x)
  end
  return nums
end

local function day2(path)
  local lines = readLines(path)
  local part1 = 0
  local part2 = 0
  for _, line in ipairs(lines) do
    if line ~= '' then
      local nums = parse_row(line)
      local lo, hi = nums[1], nums[1]
      for i = 2, #nums do
        local v = nums[i]
        if v < lo then lo = v end
        if v > hi then hi = v end
      end
      part1 = part1 + (hi - lo)

      for i = 1, #nums do
        for j = i + 1, #nums do
          local a, b = nums[i], nums[j]
          if a % b == 0 then
            part2 = part2 + a // b
            break
          elseif b % a == 0 then
            part2 = part2 + b // a
            break
          end
        end
      end
    end
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end

return function(path)
  return day2(path)
end
