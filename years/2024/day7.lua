return function(path)
  local lines = readLines(path)

  local function can_make(target, nums, idx, acc, allow_concat)
    if idx > #nums then
      return acc == target
    end
    if acc > target then
      return false
    end
    local n = nums[idx]
    if can_make(target, nums, idx + 1, acc + n, allow_concat) then
      return true
    end
    if can_make(target, nums, idx + 1, acc * n, allow_concat) then
      return true
    end
    if allow_concat then
      local mul = 1
      local x = n
      while x >= 10 do
        mul = mul * 10
        x = math.floor(x / 10)
      end
      mul = mul * 10
      local cat = acc * mul + n
      if can_make(target, nums, idx + 1, cat, allow_concat) then
        return true
      end
    end
    return false
  end

  local part1, part2 = 0, 0
  for _, line in ipairs(lines) do
    if line ~= '' then
      local target_s, rest = line:match('^(%d+):%s*(.+)$')
      local target = tonumber(target_s)
      local nums = {}
      local k = 0
      for x in rest:gmatch('%d+') do
        k = k + 1
        nums[k] = tonumber(x)
      end
      if can_make(target, nums, 2, nums[1], false) then
        part1 = part1 + target
      end
      if can_make(target, nums, 2, nums[1], true) then
        part2 = part2 + target
      end
    end
  end

  print('Part 1: ' .. part1)
  print('Part 2: ' .. part2)
end
