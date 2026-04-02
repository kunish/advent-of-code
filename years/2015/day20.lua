local function day20(path)
  local lines = readLines(path)
  local target = tonumber(lines[1]:match('%d+'))
  assert(target, 'expected number')

  local function find_with_sieve(fill_fn)
    local limit = 500000
    while true do
      local houses = {}
      for i = 1, limit do
        houses[i] = 0
      end
      fill_fn(houses, limit)
      for h = 1, limit do
        if houses[h] >= target then
          return h
        end
      end
      limit = limit * 2
    end
  end

  local part1 = find_with_sieve(function(houses, limit)
    for elf = 1, limit do
      local m = 1
      while elf * m <= limit do
        houses[elf * m] = houses[elf * m] + 10 * elf
        m = m + 1
      end
    end
  end)

  local part2 = find_with_sieve(function(houses, limit)
    for elf = 1, limit do
      for k = 1, 50 do
        local h = elf * k
        if h > limit then
          break
        end
        houses[h] = houses[h] + 11 * elf
      end
    end
  end)

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end

return function(p)
  return day20(p)
end
