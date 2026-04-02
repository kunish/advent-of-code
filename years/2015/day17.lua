local function day17(path)
  local lines = readLines(path)
  local sizes = {}
  for _, line in ipairs(lines) do
    local n = tonumber(line:match('^%s*(%d+)%s*$'))
    if n then
      sizes[#sizes + 1] = n
    end
  end

  local target = 150

  local function count_ways(i, rem)
    if rem == 0 then
      return 1
    end
    if i > #sizes or rem < 0 then
      return 0
    end
    return count_ways(i + 1, rem) + count_ways(i + 1, rem - sizes[i])
  end

  local min_used = math.huge
  local function find_min(i, rem, used)
    if rem == 0 then
      if used < min_used then
        min_used = used
      end
      return
    end
    if i > #sizes or rem < 0 then
      return
    end
    find_min(i + 1, rem, used)
    find_min(i + 1, rem - sizes[i], used + 1)
  end

  local function count_min(i, rem, used)
    if rem == 0 then
      if used == min_used then
        return 1
      end
      return 0
    end
    if i > #sizes or rem < 0 then
      return 0
    end
    return count_min(i + 1, rem, used) + count_min(i + 1, rem - sizes[i], used + 1)
  end

  local part1 = count_ways(1, target)
  find_min(1, target, 0)
  local part2 = count_min(1, target, 0)

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end

return function(p)
  return day17(p)
end
