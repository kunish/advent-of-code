return function(path)
  local lines = readLines(path)
  local line = lines[1] or ''
  local stones = {}
  for x in line:gmatch('%d+') do
    stones[#stones + 1] = tonumber(x)
  end

  local memo = {}

  local function count_stone(n, blinks)
    if blinks == 0 then
      return 1
    end
    local key = n .. ',' .. blinks
    if memo[key] then
      return memo[key]
    end
    local res
    if n == 0 then
      res = count_stone(1, blinks - 1)
    else
      local s = tostring(n)
      local len = #s
      if len % 2 == 0 then
        local half = len / 2
        local left = tonumber(s:sub(1, half))
        local right = tonumber(s:sub(half + 1, len))
        res = count_stone(left, blinks - 1) + count_stone(right, blinks - 1)
      else
        res = count_stone(n * 2024, blinks - 1)
      end
    end
    memo[key] = res
    return res
  end

  local function total(blinks)
    local sum = 0
    for _, n in ipairs(stones) do
      sum = sum + count_stone(n, blinks)
    end
    return sum
  end

  print('Part 1: ' .. total(25))
  print('Part 2: ' .. total(75))
end
