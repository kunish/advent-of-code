return function(path)
  local lines = readLines(path)
  local nums = {}
  local n = 0
  local i = 1
  while i <= #lines do
    local v = tonumber(lines[i])
    if v then
      n = n + 1
      nums[n] = v
    end
    i = i + 1
  end

  local part1 = 0
  local a = 1
  while a <= n and part1 == 0 do
    local b = a + 1
    while b <= n do
      if nums[a] + nums[b] == 2020 then
        part1 = nums[a] * nums[b]
        break
      end
      b = b + 1
    end
    a = a + 1
  end

  local part2 = 0
  a = 1
  while a <= n and part2 == 0 do
    local b = a + 1
    while b <= n and part2 == 0 do
      local c = b + 1
      while c <= n do
        if nums[a] + nums[b] + nums[c] == 2020 then
          part2 = nums[a] * nums[b] * nums[c]
          break
        end
        c = c + 1
      end
      b = b + 1
    end
    a = a + 1
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end
