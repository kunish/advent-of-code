local function parse_lines(lines)
  local dist = {}
  local function key(a, b)
    if a < b then
      return a .. '\0' .. b
    end
    return b .. '\0' .. a
  end

  local cities_set = {}

  for _, line in ipairs(lines) do
    if line ~= '' then
      local a, b, d = line:match('^(.+) to (.+) = (%d+)$')
      if a and b then
        cities_set[a] = true
        cities_set[b] = true
        dist[key(a, b)] = tonumber(d)
      end
    end
  end

  local cities = {}
  for c in pairs(cities_set) do
    cities[#cities + 1] = c
  end
  table.sort(cities)

  local function get_d(c1, c2)
    return dist[key(c1, c2)] or 0
  end

  return cities, get_d
end

local function tsp_bruteforce(cities, get_d)
  local n = #cities
  local best_short = math.huge
  local best_long = -1

  local p = {}
  for i = 1, n do
    p[i] = i
  end

  local function permute(depth)
    if depth == n then
      local total = 0
      for i = 1, n - 1 do
        total = total + get_d(cities[p[i]], cities[p[i + 1]])
      end
      if total < best_short then
        best_short = total
      end
      if total > best_long then
        best_long = total
      end
      return
    end

    for i = depth, n do
      p[depth], p[i] = p[i], p[depth]
      permute(depth + 1)
      p[depth], p[i] = p[i], p[depth]
    end
  end

  permute(1)
  return best_short, best_long
end

local function day9(path)
  local lines = readLines(path)
  local cities, get_d = parse_lines(lines)
  local part1, part2 = tsp_bruteforce(cities, get_d)
  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end

return function(path)
  return day9(path)
end
