local function has_pair_sum(preamble, target)
  local a = 1
  while a <= #preamble do
    local b = a + 1
    while b <= #preamble do
      if preamble[a] + preamble[b] == target then
        return true
      end
      b = b + 1
    end
    a = a + 1
  end
  return false
end

return function(path)
  local lines = readLines(path)
  local nums = {}
  local i = 1
  while i <= #lines do
    local v = tonumber(lines[i])
    if v then
      nums[#nums + 1] = v
    end
    i = i + 1
  end

  local preamble_len = 25
  local invalid = 0
  local k = preamble_len + 1
  while k <= #nums do
    local pre = {}
    local p = 1
    while p <= preamble_len do
      pre[p] = nums[k - preamble_len + p - 1]
      p = p + 1
    end
    if not has_pair_sum(pre, nums[k]) then
      invalid = nums[k]
      break
    end
    k = k + 1
  end

  local part2 = 0
  local start = 1
  while start <= #nums and part2 == 0 do
    local sum = 0
    local minv, maxv = nums[start], nums[start]
    local e = start
    while e <= #nums do
      local v = nums[e]
      sum = sum + v
      if v < minv then
        minv = v
      end
      if v > maxv then
        maxv = v
      end
      if sum == invalid and e > start then
        part2 = minv + maxv
        break
      end
      if sum > invalid then
        break
      end
      e = e + 1
    end
    start = start + 1
  end

  print(string.format('Part 1: %d', invalid))
  print(string.format('Part 2: %d', part2))
end
