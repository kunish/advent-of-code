return function(path)
  local lines = readLines(path)
  local jolts = { 0 }
  local i = 1
  while i <= #lines do
    local v = tonumber(lines[i])
    if v then
      jolts[#jolts + 1] = v
    end
    i = i + 1
  end
  table.sort(jolts)
  jolts[#jolts + 1] = jolts[#jolts] + 3

  local c1, c3 = 0, 0
  local j = 2
  while j <= #jolts do
    local d = jolts[j] - jolts[j - 1]
    if d == 1 then
      c1 = c1 + 1
    elseif d == 3 then
      c3 = c3 + 1
    end
    j = j + 1
  end
  local part1 = c1 * c3

  local ways = {}
  ways[1] = 1
  local k = 2
  while k <= #jolts do
    local total = 0
    local b = k - 1
    while b >= 1 and jolts[k] - jolts[b] <= 3 do
      total = total + (ways[b] or 0)
      b = b - 1
    end
    ways[k] = total
    k = k + 1
  end
  local part2 = ways[#jolts]

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end
